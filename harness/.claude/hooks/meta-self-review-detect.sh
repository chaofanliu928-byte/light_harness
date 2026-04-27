#!/bin/bash
# meta-self-review-detect.sh
# M20 — Claude Code SessionStart hook:P0.9.1 落地后反审检测段
#
# D.1 选项 2 决策摘要(2026-04-26 用户已决,见 contracts §C5"D.1 应用说明"):
#   原 plan / spec 方案 = "扩展现有 session-init.sh 加反审检测段 + 用 marker 包裹
#   + setup.sh 用 sed 删除 marker 段以便不分发下游"。
#   D.1 选项 2 替代 = "拆分两文件":
#     - session-init.sh 保留不动(承担 PROGRESS / handoff / git status 等通用注入,
#       可分发下游)
#     - meta-self-review-detect.sh(本文件,新建)承担反审检测段,**不分发下游**
#       (M14 setup.sh 命名前缀过滤 D12 自动排除 meta-* 文件,无需 sed 编辑)
#   优势:文件分离即语义分离;sed 是脆弱编辑,拆分是结构性隔离;
#         与 M15 / M16 同套 D12 命名前缀过滤机制。
#
# 用途:
#   每次 SessionStart 触发时,检测以下两个**条件同时成立**:
#     1. git log 主分支 commit message 含 P0.9.1 落地 commit
#     2. docs/audits/ 中无 covers 字段含本 spec 路径的 audit
#   两条件成立 → 注入 system-reminder via stdout(SessionStart hook 协议:
#   stdout 内容会被 Claude Code 注入到 session 上下文)
#   提醒用户走反审流程(/design-review meta-mode 等)。
#
# 协议(Claude Code SessionStart hook):
#   - 输入:stdin 含 JSON(本 hook 不解析,SessionStart 协议无 stop_hook_active)
#   - 输出:stdout 注入 session 上下文;exit 0 = 注入成功 / 跳过(graceful degrade)
#   - 注册:`harness/.claude/settings.json` SessionStart 数组(见 C5 M18 示例)
#
# 行为:
#   - **不阻断**:仅注入 system-reminder via stdout;用户可选择忽略或走反审流程
#   - **可与现有 SessionStart hooks 并列**:与 session-init.sh 注入(PROGRESS / handoff)
#     互不覆盖(SessionStart 数组按顺序执行,各 hook stdout 拼接注入)
#
# 错误处理(graceful degrade,与 M15 / M16 范式一致):
#   - 非 git 仓库 / git log 调用失败 → exit 0(不阻断 SessionStart 其他段)
#   - audit YAML 解析失败 → 视该 audit 不存在,继续判定其他
#   - meta-scope.conf / 依赖工具缺失(awk/grep/git) → exit 0 + warning(stderr)
#
# spec 锚点:§3.1.10(SessionStart hook 反审检测契约,fix-8 A 部分)
# 第八轮 fix-8:反审本 spec 触发 = A + C 组合;A = SessionStart hook 主动推
#                                            C = handoff 反审待办字段(M1 引导写)
#
# 依赖:
#   bash, awk, grep, git
#
# 命名约定:
#   前缀 meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游 — D.1 选项 2 关键机制。

set -u

# ============================================================================
# 0. 本 spec 路径常量(C2 + spec §3.1.10 锁定)
# ============================================================================

SPEC_PATH="docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md"

# git log 主分支 commit message 关键词 grep pattern(spec §3.1.10 锁定)
# 同时匹配中英文 + . / 空格变体
COMMIT_PATTERN='P0\.9\.1.*self-governance|P0\.9\.1.*实施|P0\.9\.1.*落地|P0\.9\.1.*implementation'

# ============================================================================
# 1. 解析工作目录(双层 harness 自身仓库 / 单层下游分发兼容 — 但下游不会有此文件)
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [ -d "$PROJECT_DIR/harness/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR"
else
    exit 0
fi

cd "$WORK_DIR" 2>/dev/null || exit 0

# ============================================================================
# 2. 依赖工具检查(graceful degrade)
# ============================================================================

for tool in awk grep git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,meta-self-review-detect.sh 降级跳过" >&2
        exit 0
    fi
done

# 校验 git 仓库
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# stdin 含 JSON(SessionStart 协议),本 hook 不需要解析(无 stop_hook_active 之类字段)
# 静默丢弃以避免 SIGPIPE
if [ ! -t 0 ]; then
    cat >/dev/null 2>&1 || true
fi

# ============================================================================
# 3. 检测条件 1:git log 主分支含 P0.9.1 落地 commit
# ============================================================================

# 优先用 main 分支;若不存在,fallback 用当前 HEAD
GIT_LOG_REF="main"
if ! git rev-parse --verify "$GIT_LOG_REF" >/dev/null 2>&1; then
    GIT_LOG_REF="HEAD"
fi

# 取主分支 commit message 主题列表;失败 → exit 0
COMMIT_SUBJECTS=$(git log --format="%s" "$GIT_LOG_REF" 2>/dev/null)
if [ -z "$COMMIT_SUBJECTS" ]; then
    # 无 commit 历史(空仓库)或调用失败 — graceful degrade
    exit 0
fi

# 条件 1:grep 匹配 P0.9.1 落地关键词
if ! echo "$COMMIT_SUBJECTS" | grep -E -q "$COMMIT_PATTERN"; then
    # P0.9.1 尚未落地,反审尚不触发
    exit 0
fi

# ============================================================================
# 4. 检测条件 2:audit covers 含本 spec 路径
# ============================================================================

# extract_covers <audit_file>:输出每行一个 covers 路径(与 M15/M16 共用语义)
extract_covers() {
    local audit_file="$1"
    if [ ! -r "$audit_file" ]; then
        return
    fi
    awk '
        BEGIN { in_fm=0; in_covers=0; have_fm=0 }
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) {
                in_fm = 1; have_fm = 1; next
            } else if (in_fm == 1) {
                in_fm = 0; exit
            }
        }
        in_fm == 1 {
            if (match($0, /^[[:space:]]*covers[[:space:]]*:[[:space:]]*$/)) {
                in_covers = 1; next
            }
            if (in_covers == 1) {
                if (match($0, /^[[:space:]]*-[[:space:]]+(.+)[[:space:]]*$/, m)) {
                    p = m[1]
                    sub(/[[:space:]]+$/, "", p)
                    sub(/^"/, "", p); sub(/"$/, "", p)
                    sub(/^'\''/, "", p); sub(/'\''$/, "", p)
                    print p
                    next
                }
                if (match($0, /^[[:space:]]*[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:/)) {
                    in_covers = 0
                }
            }
        }
    ' "$audit_file" 2>/dev/null
}

# 校验 audit 是否有 meta-review: true
is_meta_review_audit() {
    local audit_file="$1"
    awk '
        BEGIN { in_fm=0; have_fm=0; ok=0 }
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) { in_fm = 1; have_fm = 1; next }
            else if (in_fm == 1) { in_fm = 0; exit }
        }
        in_fm == 1 && /^[[:space:]]*meta-review[[:space:]]*:[[:space:]]*true[[:space:]]*$/ {
            ok = 1
        }
        END { exit (ok == 1 ? 0 : 1) }
    ' "$audit_file" 2>/dev/null
    return $?
}

# 收集所有 audit 文件:主目录 + archive INDEX.md(若存在)
AUDIT_FILES=()

if [ -d "docs/audits" ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && AUDIT_FILES+=("$f")
    done < <(find "docs/audits" -maxdepth 1 -type f -name "meta-review-*.md" 2>/dev/null)
fi

ARCHIVE_INDEX="docs/audits/archive/INDEX.md"
if [ -r "$ARCHIVE_INDEX" ]; then
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        case "$path" in
            *meta-review-*.md)
                if [ -r "$path" ]; then
                    AUDIT_FILES+=("$path")
                fi
                ;;
        esac
    done < <(awk -F'|' '
        /^[[:space:]]*\|/ && NF >= 3 {
            cell = $2
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
            if (cell ~ /^[-:]+$/) next
            if (tolower(cell) ~ /audit|path|文件|路径/) next
            print cell
        }
    ' "$ARCHIVE_INDEX" 2>/dev/null)
fi

# 扫所有 audit covers,grep 本 spec 路径
# 与 M15/M16 不同:本 hook **不需要**完整 covers 失效计算;
# 只需"任一 audit 的 covers 数组中是否含本 spec 路径"的简单存在性检查
SPEC_COVERED=0
for audit in "${AUDIT_FILES[@]}"; do
    [ -r "$audit" ] || continue

    # 必须是 meta-review audit
    if ! is_meta_review_audit "$audit"; then
        continue
    fi

    covers_list=$(extract_covers "$audit" 2>/dev/null)
    if [ -z "$covers_list" ]; then
        continue
    fi

    # grep 本 spec 路径(精确匹配整行)
    if echo "$covers_list" | grep -Fxq -- "$SPEC_PATH"; then
        SPEC_COVERED=1
        break
    fi
done

if [ "$SPEC_COVERED" -eq 1 ]; then
    # 反审已完成,不注入
    exit 0
fi

# ============================================================================
# 5. 注入 system-reminder via stdout(两条件成立)
# ============================================================================

cat <<'EOF'

<system-reminder>
⚠️ P0.9.1 已落地但本 spec 反审尚未完成。

未反审 spec:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`

建议触发反审流程(/design-review meta-mode 或对应 meta-review 流程),
按 M2 pattern 节走;参见 spec §6.4 bootstrap 自洽验证。
反审完成后(audit covers 含本 spec 路径)会自动停止此提醒。

详见 docs/active/handoff.md ## 反审待办 字段。
</system-reminder>
EOF

exit 0

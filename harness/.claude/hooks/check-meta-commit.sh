#!/bin/bash
# check-meta-commit.sh
# M16 — Git pre-commit hook:meta scope staged 改动需有 audit 覆盖或 handoff skip 理由
#
# 用途:
#   git commit 前扫 staged 改动,若改动命中 .claude/hooks/meta-scope.conf 内 glob
#   但无对应 meta-review audit 覆盖、且 handoff 内无非空 skip 理由,则阻断 git commit
#   并 stderr 引导补 audit 或写 skip 理由。
#
# 与 M15 (check-meta-review.sh) 关系:
#   - 触发时机不同:M15 = Claude Code Stop hook;M16 = git pre-commit hook
#   - 扫描范围不同:M15 = unstaged + staged(git diff + git diff --cached)
#                   M16 = 仅 staged(git diff --cached --name-only --diff-filter=ACMR)
#   - 协议不同:M15 stdin JSON + stop_hook_active 防死循环;
#               M16 无 stdin 协议,无防死循环字段(git pre-commit 无 stop_hook_active)
#   - 退出码语义不同:M15 exit 2 阻断 stop;M16 exit 1 阻断 commit
#   - 其余 logic(scope.conf parse / audit covers 失效规则 / handoff skip 检测 /
#     graceful degrade)与 M15 一致(本文件 inline 复制 M15 的 helper 实现以保持
#     独立可读 + 无外部依赖)
#
# 协议(Git pre-commit hook):
#   - 输入:无 stdin JSON;工作目录 = git repo root(自动)
#   - 输出:exit 0 = 放行 commit;exit 1 = 阻断 commit(stderr 引导消息)
#   - 安装:.git/hooks/pre-commit 软链或拷贝本文件(P0.9.1 阶段 harness 自身不安装,
#     见 contracts §C5"本阶段 harness 自身行为")
#
# 错误处理(graceful degrade,与 M15 范式一致):
#   - meta-scope.conf 缺失/损坏 → stderr warning + exit 0
#   - audit YAML 解析失败 → stderr warning + 视该 audit 不存在,继续处理其他
#   - 非 git 仓库 / git diff --cached 调用失败 → exit 0
#   - 依赖工具缺失(awk/grep/sed/git/stat)→ stderr warning + exit 0
#   - 唯一 exit 1 路径:逻辑确认 uncovered 非空 + 无有效 skip 理由
#
# spec 锚点:§3.1.9(hook 执法契约)+ §4.1.5(audit covers 失效规则)
# 第七轮 fix-9:
#   (iii) covered_files = ⋃ {audit covers 实际列出的文件}(不是"主题相关即覆盖")
#   (v)   只排除流程产出物(audit / archive),不排除治理文件(meta-* / scope.conf)
#
# 依赖:
#   bash, awk, grep, sed, git, stat(GNU 或 BSD,自动适配)
#
# 命名约定:
#   前缀 check-meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游。

set -u

# ============================================================================
# 1. 解析工作目录(双层 harness 自身仓库 / 单层下游分发兼容)
# ============================================================================

# git pre-commit 默认工作目录 = git repo root,但仍兼容 CLAUDE_PROJECT_DIR
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# 优先尝试 PROJECT_DIR/harness(harness 自身仓库双层结构)
if [ -d "$PROJECT_DIR/harness/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR"
else
    # 都不存在,降级
    exit 0
fi

cd "$WORK_DIR" 2>/dev/null || exit 0

# ============================================================================
# 2. 依赖工具检查(graceful degrade)
# ============================================================================

for tool in awk grep sed git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,check-meta-commit.sh 降级跳过" >&2
        exit 0
    fi
done

# stat 可能是 GNU(-c %Y)或 BSD(-f %m),封装兼容
stat_mtime() {
    local f="$1"
    local m
    m=$(stat -c %Y "$f" 2>/dev/null) || m=$(stat -f %m "$f" 2>/dev/null) || m=""
    echo "$m"
}

# 校验 git 仓库
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# ============================================================================
# 3. 解析 M17 meta-scope.conf
# ============================================================================

SCOPE_CONF=".claude/hooks/meta-scope.conf"

if [ ! -r "$SCOPE_CONF" ]; then
    echo "⚠️ meta-scope.conf 不可读" >&2
    exit 0
fi

# 分离 include glob 与 exclude glob(! 前缀);跳过 # 注释 + 空行
INCLUDE_GLOBS=()
EXCLUDE_GLOBS=()

while IFS= read -r line || [ -n "$line" ]; do
    # 去 trailing CR(若文件含 CRLF)
    line="${line%$'\r'}"
    # trim 前导 / 尾随空白
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    # 跳空行 + 注释
    [ -z "$line" ] && continue
    case "$line" in
        \#*) continue ;;
    esac
    # 分类
    if [ "${line:0:1}" = "!" ]; then
        EXCLUDE_GLOBS+=("${line:1}")
    else
        INCLUDE_GLOBS+=("$line")
    fi
done < "$SCOPE_CONF"

# 若 conf 解析后无任何 include glob,视为损坏 / 空配置
if [ "${#INCLUDE_GLOBS[@]}" -eq 0 ]; then
    echo "⚠️ meta-scope.conf 无任何 include glob,降级跳过" >&2
    exit 0
fi

# ============================================================================
# 4. glob 匹配辅助函数
# ============================================================================

# match_glob <path> <glob>:返回 0 if path 命中 glob,1 否则
# 支持基本 glob:*、?、字符类
# `**` 在 bash case 内不天然支持,作普通 * 处理(单段);多段通配需展开
match_glob() {
    local path="$1"
    local glob="$2"
    # 处理 ** 多段通配:把 ** 替换为占位符,再用 case 匹配
    # 简化策略:把 `/**/` 视作 `/*/`(任意中间段);把 `**` 视作 `*`
    # 这样 docs/audits/archive/** 匹配 docs/audits/archive/anything
    case "$glob" in
        *'**'*)
            # 把 ** 转为 * 的扩展模式
            local g_norm="${glob//\*\*\//}"  # /**/  -> 空
            local g_alt1="${glob//\*\*/\*}"  # **    -> *
            case "$path" in
                $g_alt1) return 0 ;;
            esac
            # 同时尝试无中间段路径(`/**/` 退化为根目录直接子节点)
            case "$path" in
                $g_norm) return 0 ;;
            esac
            return 1
            ;;
        *)
            case "$path" in
                $glob) return 0 ;;
            esac
            return 1
            ;;
    esac
}

# is_in_scope <path>:返回 0 if path 在 scope 内(命中 include 且未命中 exclude)
is_in_scope() {
    local path="$1"
    # 优先 exclude
    for g in "${EXCLUDE_GLOBS[@]}"; do
        if match_glob "$path" "$g"; then
            return 1
        fi
    done
    # include
    for g in "${INCLUDE_GLOBS[@]}"; do
        if match_glob "$path" "$g"; then
            return 0
        fi
    done
    return 1
}

# ============================================================================
# 5. 扫 git diff --cached(staged only)→ changed_meta_files
# ============================================================================

# diff-filter=ACMR:仅 active staged changes(Added/Copied/Modified/Renamed),
# 不含 deleted-only(deleted 不需要 audit 覆盖,被删的文件无未来改动入仓需求)
DIFF_FILES=$(git diff --cached --name-only --diff-filter=ACMR --relative 2>/dev/null | awk 'NF' | sort -u)

# 注:不在此处因 DIFF_FILES 为空而 exit 0 — 允许 §5.5 repo 根扫描段继续执行
# (repo 根级文件如 CLAUDE.md 不含 harness/ 前缀,--relative 不显示,需 §5.5 补扫)

CHANGED_META_FILES=()
while IFS= read -r f; do
    [ -z "$f" ] && continue
    if is_in_scope "$f"; then
        CHANGED_META_FILES+=("$f")
    fi
done <<< "$DIFF_FILES"

# ============================================================================
# 5.5. repo 根扫描段(P0.9.3 (vii-a) 修 — M3 hook 不可见缺口)
# ============================================================================
# 主扫 cwd=harness/,git diff --cached --relative 输出不含 repo 根级文件(M3 = 根 CLAUDE.md)。
# 新增段:cwd=repo 根 跑 git diff --cached,过滤无 / 前缀的根级文件。
# 与 Stop hook 差异:仅扫 staged + diff-filter=ACMR(沿用 M16 主扫语义)。
# 失败降级:R1(git -C 失败)→ stderr warning + 跳过段;R2(ROOT_DIR 缺失)→ silent 跳过。

ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/.git" ]; then
    # R1: git -C 健康检查 — 若 git 调用失败(repo 损坏 / submodule 未初始化等),
    # stderr warning + 跳过段(主扫继续);spec §3.1 + §5 R1 + §5.2 要求
    if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "⚠️ repo 根 git -C 调用失败,§5.5 跳过(主扫继续)" >&2
        ROOT_DIFF=""
    else
        ROOT_DIFF=$(git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMR 2>/dev/null | \
                    awk 'NF' | sort -u)
    fi

    if [ -n "$ROOT_DIFF" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            # 仅取 repo 根级文件(无 / 前缀)— 子目录已在 harness/ 主扫覆盖
            case "$f" in
                */*) continue ;;
            esac
            if is_in_scope "$f"; then
                CHANGED_META_FILES+=("$f")
            fi
        done <<< "$ROOT_DIFF"
    fi
fi
# else: ROOT_DIR 不存在(单层下游)→ 跳过段(R2)

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 6. 扫所有 audit (主目录 + archive/INDEX.md)→ covered_files(失效后)
# ============================================================================

# 提取单 audit 的 covers 数组(YAML frontmatter)
# 输出每行一个 covers 路径
extract_covers() {
    local audit_file="$1"
    if [ ! -r "$audit_file" ]; then
        return
    fi
    awk '
        BEGIN { in_fm=0; in_covers=0; meta_review=0; have_fm=0 }
        # frontmatter 边界:首行 --- 起,第二个 --- 止
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) {
                in_fm = 1; have_fm = 1; next
            } else if (in_fm == 1) {
                in_fm = 0; exit
            }
        }
        in_fm == 1 {
            # meta-review: true 检
            if (match($0, /^[[:space:]]*meta-review[[:space:]]*:[[:space:]]*true[[:space:]]*$/)) {
                meta_review = 1; next
            }
            # covers: 起
            if (match($0, /^[[:space:]]*covers[[:space:]]*:[[:space:]]*$/)) {
                in_covers = 1; next
            }
            # covers 数组项:- <path>
            if (in_covers == 1) {
                if (match($0, /^[[:space:]]*-[[:space:]]+(.+)[[:space:]]*$/, m)) {
                    # trim 后置空白
                    p = m[1]
                    sub(/[[:space:]]+$/, "", p)
                    # 去引号(若有)
                    sub(/^"/, "", p); sub(/"$/, "", p)
                    sub(/^'\''/, "", p); sub(/'\''$/, "", p)
                    print p
                    next
                }
                # 其他键开始 → covers 段结束
                if (match($0, /^[[:space:]]*[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:/)) {
                    in_covers = 0
                }
            }
        }
        END {
            # 若 meta-review 不为 true,清空(但 awk 已 print,无法回退;
            # 由调用方再次校验更稳妥 — 此处我们靠下游 grep meta-review: true)
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

# 主目录
if [ -d "docs/audits" ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && AUDIT_FILES+=("$f")
    done < <(find "docs/audits" -maxdepth 1 -type f -name "meta-review-*.md" 2>/dev/null)
fi

# archive INDEX.md(若存在,解析其中表格行第 1 列 audit 路径)
ARCHIVE_INDEX="docs/audits/archive/INDEX.md"
if [ -r "$ARCHIVE_INDEX" ]; then
    # 简易表格解析:行格式 `| path | ... |`,跳过 header / separator
    while IFS= read -r path; do
        [ -z "$path" ] && continue
        # 仅当文件存在且为 meta-review-*.md
        case "$path" in
            *meta-review-*.md)
                if [ -r "$path" ]; then
                    AUDIT_FILES+=("$path")
                fi
                ;;
        esac
    done < <(awk -F'|' '
        /^[[:space:]]*\|/ && NF >= 3 {
            # 跳过 separator(全为 - 或 :)
            cell = $2
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", cell)
            if (cell ~ /^[-:]+$/) next
            # 跳过 header(包含 audit / 路径 关键词,大小写不敏感)
            if (tolower(cell) ~ /audit|path|文件|路径/) next
            print cell
        }
    ' "$ARCHIVE_INDEX" 2>/dev/null)
fi

# 计算 covered_files(应用失效规则)
# 用临时文件替代关联数组(POSIX bash 兼容)
COVERED_TMP=$(mktemp 2>/dev/null) || COVERED_TMP="/tmp/check-meta-commit-covered-$$"
: > "$COVERED_TMP" 2>/dev/null

cleanup_tmp() {
    [ -n "${COVERED_TMP:-}" ] && [ -f "$COVERED_TMP" ] && rm -f "$COVERED_TMP" 2>/dev/null
}
trap cleanup_tmp EXIT

for audit in "${AUDIT_FILES[@]}"; do
    [ -r "$audit" ] || continue

    # 校验 meta-review: true
    if ! is_meta_review_audit "$audit"; then
        # 不是 meta-review audit,跳过(不警告 — 可能是其他类型 audit)
        continue
    fi

    audit_mtime=$(stat_mtime "$audit")
    if [ -z "$audit_mtime" ]; then
        echo "⚠️ audit 文件 mtime 读取失败: $audit" >&2
        continue
    fi

    # 提取 covers
    covers_list=$(extract_covers "$audit" 2>/dev/null)
    if [ -z "$covers_list" ]; then
        # covers 字段缺失/空数组/YAML 损坏 → 视该 audit 不贡献 covered_files
        continue
    fi

    # 对每个 covers 文件,判失效
    while IFS= read -r covered_file; do
        [ -z "$covered_file" ] && continue
        # 跳前后空白
        covered_file="${covered_file#"${covered_file%%[![:space:]]*}"}"
        covered_file="${covered_file%"${covered_file##*[![:space:]]}"}"
        [ -z "$covered_file" ] && continue

        # 取该文件最新 commit time
        covered_ct=$(git log -1 --format=%ct -- "$covered_file" 2>/dev/null)

        if [ -z "$covered_ct" ]; then
            # 文件无 commit history(未入库或新增),视为仍有效(无新 commit > audit_mtime)
            echo "$covered_file" >> "$COVERED_TMP"
        elif [ "$covered_ct" -le "$audit_mtime" ] 2>/dev/null; then
            # 仍有效
            echo "$covered_file" >> "$COVERED_TMP"
        fi
        # 否则:失效(文件有新 commit 在 audit 之后),不加入 covered
    done <<< "$covers_list"
done

# ============================================================================
# 7. 计算 uncovered = changed_meta_files - covered_files
# ============================================================================

UNCOVERED=()
for f in "${CHANGED_META_FILES[@]}"; do
    if grep -Fxq -- "$f" "$COVERED_TMP" 2>/dev/null; then
        continue
    fi
    UNCOVERED+=("$f")
done

if [ "${#UNCOVERED[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 8. 检 handoff `## meta-review: skipped(理由: <非空>)` 字段
# ============================================================================

HANDOFF="docs/active/handoff.md"

if [ -r "$HANDOFF" ]; then
    # POSIX ERE:匹配整行,提取理由
    SKIP_LINE=$(grep -E '^[[:space:]]*##[[:space:]]+meta-review:[[:space:]]+skipped\(理由:[[:space:]]*[^)]*\)' "$HANDOFF" 2>/dev/null | head -1)

    if [ -n "$SKIP_LINE" ]; then
        # 提取括号内"理由: <reason>"中的 reason 部分
        REASON=$(echo "$SKIP_LINE" | sed -E 's/^.*\(理由:[[:space:]]*([^)]*)\).*$/\1/')
        # trim
        REASON_TRIMMED=$(echo "$REASON" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
        if [ -n "$REASON_TRIMMED" ]; then
            # skip 有效
            exit 0
        fi
    fi
fi

# ============================================================================
# 9. 阻断 commit + stderr 引导消息
# ============================================================================

{
    echo "检测到 staged meta scope 改动但无对应 audit 或跳过理由 — git commit 已阻断。"
    echo ""
    echo "Staged 的 meta 文件:"
    for f in "${CHANGED_META_FILES[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "未被任何有效 audit covers 覆盖的文件:"
    for f in "${UNCOVERED[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "处理方式(任选其一,然后重新 git commit):"
    echo "  1. 触发 /design-review meta-mode(或对应的 meta-review 流程),产出"
    echo "     docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md(YAML covers 列出上述文件)"
    echo "  2. 在 docs/active/handoff.md 写入(必须含非空理由):"
    echo "     ## meta-review: skipped(理由: <非空理由>)"
    echo ""
    echo "注意:本 hook 只扫 staged 文件(--diff-filter=ACMR),已 staged 的新建文件本 hook 能扫到"
    echo "  - 但 untracked(未 git add)文件 git diff 不输出,需先 git add"
    echo "  - 非 scope 改动(ROADMAP / handoff / decision-trail)无需 covers 覆盖"
} >&2

exit 1

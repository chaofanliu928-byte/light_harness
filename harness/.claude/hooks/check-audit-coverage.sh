#!/bin/bash
# check-audit-coverage.sh
# 凭证覆盖核对(audit coverage)— 双模式:Stop 执法(增强层,当前无任何仓库接线)
#   + `--reconcile` 开场对账(工具箱,主用形态)。治理同层化(2026-06-13)起,工具
#   从"meta scope 分流执法"降格为"凭证覆盖核对":读 credentials.conf 两字段行格式、
#   双前缀收集审查凭证、单一 frontmatter 文法(audit: true)、认 exempt 微 audit。
#
# 模式 1(无参数)— Stop 执法(增强层):
#   每次 session 末扫 git diff(未提交),若改动命中 .claude/hooks/credentials.conf
#   内 glob(凭证类型 audit)但无对应审查凭证覆盖,则阻断 stop 并 stderr 引导补 audit。
#
# 模式 2(--reconcile [天数])— 手工对账(工具箱,开场对账用):
#   bash check-audit-coverage.sh --reconcile [天数]
#   扫已提交历史(git log)中命中凭证义务的文件,对照有效 audit covers 并集,
#   stderr 输出账齐(带计数)/欠账(逐文件点名);恒 exit 0(输出给 AI 读,不阻断)。
#   - 失效锚点(对账专用):audit 自身最后 commit time(未提交/未跟踪才 mtime 兜底);
#     covered 文件最新 commit time ≤ audit commit time → 有效
#     (finishing 惯例:audit 与同批修订同 commit 打包,commit time 相等,≤ 判有效)
#   - 窗口:显式天数(正整数)→ --since="N days ago";缺省 → 仓库最新**已提交**
#     正式 audit 的最后 commit time(untracked/未提交 audit、process-audit 报告、
#     verdict: exempt 凭证均不参与窗口锚竞选,防 mtime=当下/窄豁免掩蔽已提交欠账
#     — 审查 I1;无已提交正式 audit → 30 天前)
#
# 协议(Claude Code Stop hook,模式 1):
#   - 输入:stdin JSON,字段 stop_hook_active(bool)等
#   - 输出:exit 0 = 放行;exit 2 = 阻断(stderr 引导消息)
#
# 防死循环(模式 1):
#   stop_hook_active == true 时直接 exit 0(参考 check-handoff.sh 范式)。
#
# 错误处理(graceful degrade,与 check-handoff.sh / check-evidence-depth.sh 范式一致):
#   - credentials.conf 缺失/损坏 → stderr warning + exit 0
#   - audit YAML 解析失败 → stderr warning + 视该 audit 不存在,继续处理其他
#   - 非 git 仓库 / git diff 调用失败 → exit 0(--reconcile 下另加 stderr 一行提示)
#   - 依赖工具缺失(jq/awk/grep/sed/git/stat)→ stderr warning + exit 0
#   - 唯一 exit 2 路径(仅模式 1):逻辑确认 uncovered 非空
#   - --reconcile 分支恒 exit 0,无任何 exit 2 路径
#
# 已知问题(独立待办,本文件不修不扩散):extract_covers 用 gawk 三参数 match
# 扩展语法,非 gawk 环境(mawk / busybox awk)解析失败 → 该 audit 视为不贡献
# covers;--reconcile 分支仅复用该函数,不新增 gawk 扩展语法。
#
# spec 锚点:docs/superpowers/specs/2026-06-13-governance-single-layer-design.md
#   + decisions/2026-06-13-governance-single-layer.md(治理同层化:工具降格 + 凭证覆盖)
#   + decisions/2026-06-11-session-chain-reconciliation.md(对账模式)
# covers 并集语义:covered_files = ⋃ {audit covers 实际列出的文件}(不是"主题相关即覆盖");
#   排除流程产出物(audit / archive)避免自循环。
#
# 依赖:
#   bash, jq, awk, grep, sed, git, stat(GNU 或 BSD,自动适配)
#
# 分发:无前缀,随 setup.sh hooks 循环分发下游(A 彻底同层;原 D12 命名前缀过滤已退役)。

set -u

# ============================================================================
# 0a. 参数判定(--reconcile 模式开关)
# ============================================================================
# 必须在 INPUT=$(cat) 之前:对账是手工命令,不读 stdin;若先 cat,
# 交互终端跑 --reconcile 会在 cat 上挂死。set -u 下用 ${1:-} 取参。

RECONCILE=0
RECONCILE_DAYS=""
if [ "${1:-}" = "--reconcile" ]; then
    RECONCILE=1
    RECONCILE_DAYS="${2:-}"
    if [ -n "$RECONCILE_DAYS" ]; then
        case "$RECONCILE_DAYS" in
            *[!0-9]*|0*)
                echo "⚠️ --reconcile 天数参数无效(需正整数天数): $RECONCILE_DAYS" >&2
                exit 0
                ;;
        esac
    fi
fi

# ============================================================================
# 0. 防死循环(仅 Stop 模式;--reconcile 不读 stdin、无 stop_hook_active 语义)
# ============================================================================

if [ "$RECONCILE" -eq 0 ]; then
    INPUT=$(cat)

    if command -v jq >/dev/null 2>&1; then
        if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
            exit 0
        fi
    else
        echo "⚠️ jq 缺失,check-audit-coverage.sh 降级跳过" >&2
        exit 0
    fi
fi

# ============================================================================
# 1. 解析工作目录(双层 harness 自身仓库 / 单层下游分发兼容)
# ============================================================================

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
        echo "⚠️ $tool 缺失,check-audit-coverage.sh 降级跳过" >&2
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
    if [ "$RECONCILE" -eq 1 ]; then
        echo "⚠️ 非 git 仓库,--reconcile 对账需要已提交历史,降级退出" >&2
    fi
    exit 0
fi

# ============================================================================
# 3. 解析 credentials.conf(两字段行格式:<glob> <凭证类型>;! 前缀为排除无类型)
# ============================================================================

CRED_CONF=".claude/hooks/credentials.conf"

if [ ! -r "$CRED_CONF" ]; then
    echo "⚠️ credentials.conf 不可读" >&2
    exit 0
fi

# 分离 include glob(凭证类型 audit)与 exclude glob(! 前缀);跳过 # 注释 + 空行
# 行格式:非排除行按第一个空白切 glob + type:
#   type=audit         → 入 INCLUDE_GLOBS(本工具消费)
#   type ∈ {design-review, test} → 跳过(参数位预留,本工具不消费)
#   type 为空(单字段行)→ warning + 按 audit 处理(fail-closed)
#   type 为其他未知值  → warning + 按 audit 处理(fail-closed,与缺类型同路径)
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
    # 排除行:! 前缀,无类型字段(解析不变)
    if [ "${line:0:1}" = "!" ]; then
        EXCLUDE_GLOBS+=("${line:1}")
        continue
    fi
    # 非排除行:按第一个空白切 glob + type
    glob="${line%%[[:space:]]*}"
    rest="${line#"$glob"}"
    # trim type 段前导空白
    ctype="${rest#"${rest%%[![:space:]]*}"}"
    ctype="${ctype%"${ctype##*[![:space:]]}"}"
    case "$ctype" in
        audit)
            INCLUDE_GLOBS+=("$glob")
            ;;
        design-review|test)
            # 参数位预留,本工具不消费,跳过
            ;;
        "")
            echo "⚠️ credentials.conf 行缺凭证类型字段,按 audit 处理: $line" >&2
            INCLUDE_GLOBS+=("$glob")
            ;;
        *)
            echo "⚠️ credentials.conf 行凭证类型未知($ctype),按 audit 处理(fail-closed): $line" >&2
            INCLUDE_GLOBS+=("$glob")
            ;;
    esac
done < "$CRED_CONF"

# 若 conf 解析后无任何 include glob,视为损坏 / 空配置
if [ "${#INCLUDE_GLOBS[@]}" -eq 0 ]; then
    echo "⚠️ credentials.conf 无任何 audit include glob,降级跳过" >&2
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
# 4.5. audit 解析辅助(extract_covers / is_audit_credential / extract_verdict
#       / collect_audit_files)
# ============================================================================
# 原 §6 内联定义/内联收集,为 --reconcile 分支可复用而前移为函数;
# Stop 路径(§6 调用)行为不变。frontmatter 单一文法:audit: true(无双字段兼容)。

# 提取单 audit 的 covers 数组(YAML frontmatter)
# 输出每行一个 covers 路径
extract_covers() {
    local audit_file="$1"
    if [ ! -r "$audit_file" ]; then
        return
    fi
    awk '
        BEGIN { in_fm=0; in_covers=0; audit_cred=0; have_fm=0 }
        # frontmatter 边界:首行 --- 起,第二个 --- 止
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) {
                in_fm = 1; have_fm = 1; next
            } else if (in_fm == 1) {
                in_fm = 0; exit
            }
        }
        in_fm == 1 {
            # audit: true 检
            if (match($0, /^[[:space:]]*audit[[:space:]]*:[[:space:]]*true[[:space:]]*$/)) {
                audit_cred = 1; next
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
            # 若 audit 不为 true,清空(但 awk 已 print,无法回退;
            # 由调用方再次校验更稳妥 — 此处靠下游 is_audit_credential 校验)
        }
    ' "$audit_file" 2>/dev/null
}

# 校验 audit 是否有 audit: true(单一文法,无双字段兼容)
is_audit_credential() {
    local audit_file="$1"
    awk '
        BEGIN { in_fm=0; have_fm=0; ok=0 }
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) { in_fm = 1; have_fm = 1; next }
            else if (in_fm == 1) { in_fm = 0; exit }
        }
        in_fm == 1 && /^[[:space:]]*audit[[:space:]]*:[[:space:]]*true[[:space:]]*$/ {
            ok = 1
        }
        END { exit (ok == 1 ? 0 : 1) }
    ' "$audit_file" 2>/dev/null
    return $?
}

# 提取单 audit 的 verdict(仅识别 exempt;frontmatter 内 verdict: exempt → 输出 exempt,
# 否则空)。供窗口锚竞选排除 exempt(point 11)与对账 exempt 计数(point 6)用。
extract_verdict() {
    local audit_file="$1"
    [ -r "$audit_file" ] || return
    awk '
        BEGIN { in_fm=0; have_fm=0 }
        /^---[[:space:]]*$/ {
            if (in_fm == 0 && have_fm == 0) { in_fm = 1; have_fm = 1; next }
            else if (in_fm == 1) { in_fm = 0; exit }
        }
        in_fm == 1 && /^[[:space:]]*verdict[[:space:]]*:[[:space:]]*exempt[[:space:]]*$/ {
            print "exempt"; exit
        }
    ' "$audit_file" 2>/dev/null
}

# 收集所有 audit 文件:主目录 + archive INDEX.md(若存在)→ 全局数组 AUDIT_FILES
collect_audit_files() {
    AUDIT_FILES=()

    # 主目录(双前缀:新名 audit-*.md + 历史名 meta-review-*.md)
    if [ -d "docs/audits" ]; then
        while IFS= read -r f; do
            [ -n "$f" ] && AUDIT_FILES+=("$f")
        done < <(find "docs/audits" -maxdepth 1 -type f \( -name "audit-*.md" -o -name "meta-review-*.md" \) 2>/dev/null)
    fi

    # archive INDEX.md(若存在,解析其中表格行第 1 列 audit 路径)
    ARCHIVE_INDEX="docs/audits/archive/INDEX.md"
    if [ -r "$ARCHIVE_INDEX" ]; then
        # 简易表格解析:行格式 `| path | ... |`,跳过 header / separator
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            # 仅当文件存在且为 audit-*.md(新名)或 meta-review-*.md(历史名)
            case "$path" in
                *audit-*.md|*meta-review-*.md)
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
}

# ============================================================================
# 4.6. 对账模式分支(--reconcile)— 已提交历史 audit 覆盖核(C 案,工具箱)
# ============================================================================
# 与 Stop 模式三点差异:
#   (1) 扫描对象 = git log 已提交历史(--relative,与 Stop 的 git diff --relative
#       同基准),而非未提交 diff;root 级文件经 git -C <repo根> log 过滤无 / 文件
#       加 <root>/ sentinel(复用 §5.5 逻辑形态)
#   (2) 失效锚点 = audit 自身最后 commit time(未提交/未跟踪 audit 才 mtime 兜底);
#       covered 文件最新 commit time ≤ audit commit time → 有效
#   (3) 恒 exit 0(skip 字段制度已消亡 — 豁免走 exempt 微 audit,对账天然认)
# 已删除文件处置:git log 清单不剔除删除件 — 与 Stop 模式 git diff 同口径,
#   covers 列了即覆盖(其"最新 commit"= 删除 commit,照常参与失效判定)。

if [ "$RECONCILE" -eq 1 ]; then

    collect_audit_files

    # --- 窗口起点 ---
    SINCE_ARG=""
    SINCE_DESC=""
    if [ -n "$RECONCILE_DAYS" ]; then
        SINCE_ARG="${RECONCILE_DAYS} days ago"
        SINCE_DESC="近 ${RECONCILE_DAYS} 天(显式参数)"
    else
        # 仓库最新**正式** audit(双前缀 audit-*.md + meta-review-*.md 主目录)的最后
        # commit time。
        # 审查 I1 修:窗口锚竞选只认**已提交** audit — untracked/未提交 audit 的
        # mtime 是"现在",若参选会把窗口起点拉到当下,掩蔽已提交欠账;
        # mtime 兜底仅保留在失效判定(约束 3 的正当用途),不外溢到窗口锚。
        # 必修真缺口补:竞选段加 is_audit_credential 过滤 — process-audit 报告(无
        # frontmatter)的 commit time 不得错当窗口锚;point 11:verdict=exempt 凭证亦
        # 不参选(窄豁免高频,会把默认窗锚拉到当下遮蔽窗外漏账;正式 audit 才有资格定窗)。
        LATEST_AUDIT_CT=""
        LATEST_AUDIT_FILE=""
        while IFS= read -r audit; do
            [ -z "$audit" ] && continue
            # 仅正式 audit 凭证参选(过滤 process-audit 报告 / 非凭证件)
            is_audit_credential "$audit" || continue
            # 排除 exempt 凭证参选
            [ "$(extract_verdict "$audit")" = exempt ] && continue
            a_ct=$(git log -1 --format=%ct -- "$audit" 2>/dev/null)
            [ -z "$a_ct" ] && continue
            if [ -z "$LATEST_AUDIT_CT" ] || [ "$a_ct" -gt "$LATEST_AUDIT_CT" ] 2>/dev/null; then
                LATEST_AUDIT_CT="$a_ct"
                LATEST_AUDIT_FILE="$audit"
            fi
        done < <(find "docs/audits" -maxdepth 1 -type f \( -name "audit-*.md" -o -name "meta-review-*.md" \) 2>/dev/null)

        if [ -n "$LATEST_AUDIT_CT" ]; then
            SINCE_ARG="@${LATEST_AUDIT_CT}"
            SINCE_DESC="最新正式 audit 的 commit time(${LATEST_AUDIT_FILE} @ ${LATEST_AUDIT_CT})"
        else
            SINCE_ARG="30 days ago"
            SINCE_DESC="近 30 天(无已提交正式 audit,默认窗口)"
        fi
    fi

    # --- 收集已提交改动文件(harness 层)---
    # 必须 --relative:cwd=harness/,与 Stop 模式 git diff --relative 同基准;
    # 不加则输出仓库根相对路径(harness/ 前缀),glob 永不命中 = 假"账齐"
    LOG_FILES=$(git log --since="$SINCE_ARG" --name-only --relative --format= 2>/dev/null | awk 'NF' | sort -u)

    SCOPE_FILES=()
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        if is_in_scope "$f"; then
            SCOPE_FILES+=("$f")
        fi
    done <<< "$LOG_FILES"

    # --- root 级文件段(复用 §5.5 逻辑形态:过滤无 / 文件 + <root>/ sentinel)---
    ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
    if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/.git" ]; then
        if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "⚠️ repo 根 git -C 调用失败,对账 root 级段跳过(主扫继续)" >&2
        else
            ROOT_LOG=$(git -C "$ROOT_DIR" log --since="$SINCE_ARG" --name-only --format= 2>/dev/null | awk 'NF' | sort -u)
            if [ -n "$ROOT_LOG" ]; then
                while IFS= read -r f; do
                    [ -z "$f" ] && continue
                    # 仅取 repo 根级文件(无 / 前缀)— 子目录已在 harness/ 主扫覆盖
                    case "$f" in
                        */*) continue ;;
                    esac
                    if is_in_scope "$f"; then
                        SCOPE_FILES+=("<root>/$f")
                    fi
                done <<< "$ROOT_LOG"
            fi
        fi
    fi
    # else: ROOT_DIR 无 .git(单层下游)→ 跳过段,主扫已含全部

    # --- 有效 covers 并集(commit time 锚)---
    R_COVERED_TMP=$(mktemp 2>/dev/null) || R_COVERED_TMP="/tmp/check-audit-coverage-reconcile-$$"
    : > "$R_COVERED_TMP" 2>/dev/null

    cleanup_reconcile_tmp() {
        [ -n "${R_COVERED_TMP:-}" ] && [ -f "$R_COVERED_TMP" ] && rm -f "$R_COVERED_TMP" 2>/dev/null
    }
    trap cleanup_reconcile_tmp EXIT

    VALID_AUDIT_COUNT=0
    EXEMPT_COUNT=0
    for audit in "${AUDIT_FILES[@]}"; do
        [ -r "$audit" ] || continue

        if ! is_audit_credential "$audit"; then
            continue
        fi

        # exempt 与正式 audit 同算有效覆盖(verdict 不参与覆盖判定;仅用于计数 + 窗锚排除)
        audit_verdict=$(extract_verdict "$audit")

        # 失效锚点(对账专用):audit 自身最后 commit time;未提交/未跟踪才 mtime 兜底
        audit_ct=$(git log -1 --format=%ct -- "$audit" 2>/dev/null)
        if [ -z "$audit_ct" ]; then
            audit_ct=$(stat_mtime "$audit")
        fi
        if [ -z "$audit_ct" ]; then
            echo "⚠️ audit 时间锚读取失败,跳过: $audit" >&2
            continue
        fi

        covers_list=$(extract_covers "$audit" 2>/dev/null)
        if [ -z "$covers_list" ]; then
            continue
        fi

        audit_contributed=0
        while IFS= read -r covered_file; do
            [ -z "$covered_file" ] && continue
            covered_file="${covered_file#"${covered_file%%[![:space:]]*}"}"
            covered_file="${covered_file%"${covered_file##*[![:space:]]}"}"
            [ -z "$covered_file" ] && continue

            # <root>/ sentinel:root 级文件,经 repo 根查 commit time
            case "$covered_file" in
                '<root>/'*)
                    if [ -n "${ROOT_DIR:-}" ] && [ -d "$ROOT_DIR/.git" ]; then
                        covered_ct=$(git -C "$ROOT_DIR" log -1 --format=%ct -- "${covered_file#<root>/}" 2>/dev/null)
                    else
                        covered_ct=""
                    fi
                    ;;
                *)
                    covered_ct=$(git log -1 --format=%ct -- "$covered_file" 2>/dev/null)
                    ;;
            esac

            # 无 commit history(未入库)→ 视为有效(与 Stop 模式同口径);
            # 有 history → covered_ct ≤ audit_ct 才有效
            if [ -z "$covered_ct" ]; then
                echo "$covered_file" >> "$R_COVERED_TMP"
                audit_contributed=1
            elif [ "$covered_ct" -le "$audit_ct" ] 2>/dev/null; then
                echo "$covered_file" >> "$R_COVERED_TMP"
                audit_contributed=1
            fi
        done <<< "$covers_list"

        if [ "$audit_contributed" -eq 1 ]; then
            VALID_AUDIT_COUNT=$((VALID_AUDIT_COUNT + 1))
            if [ "$audit_verdict" = exempt ]; then
                EXEMPT_COUNT=$((EXEMPT_COUNT + 1))
            fi
        fi
    done

    # --- uncovered = 近窗 scope 改动 - 有效 covers 并集 ---
    R_UNCOVERED=()
    for f in "${SCOPE_FILES[@]}"; do
        if grep -Fxq -- "$f" "$R_COVERED_TMP" 2>/dev/null; then
            continue
        fi
        R_UNCOVERED+=("$f")
    done

    # --- 输出(stderr,恒 exit 0)---
    SCOPE_N=${#SCOPE_FILES[@]}
    {
        echo "—— 凭证覆盖对账(--reconcile)——"
        echo "窗口起点: ${SINCE_DESC}"
        if [ "${#R_UNCOVERED[@]}" -eq 0 ]; then
            echo "账齐:近窗 ${SCOPE_N} 件凭证义务改动,有效凭证 ${VALID_AUDIT_COUNT} 份(其中 exempt ${EXEMPT_COUNT} 份)"
        else
            echo "欠账:近窗 ${SCOPE_N} 件凭证义务改动,有效凭证 ${VALID_AUDIT_COUNT} 份(其中 exempt ${EXEMPT_COUNT} 份),未覆盖 ${#R_UNCOVERED[@]} 件:"
            for f in "${R_UNCOVERED[@]}"; do
                echo "  - $f"
            done
            echo ""
            echo "处理:对上述文件补审查凭证(二选一),文法住 docs/governance/credentials-rules.md:"
            echo "  1. 对抗审查 audit:docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md(frontmatter audit: true + covers 逐项列出;root 级文件写 <root>/<path>)"
            echo "  2. exempt 微 audit(仅 typo/链接/注释等无语义变更):同 frontmatter + verdict: exempt + 一行理由(credentials-rules §4)"
        fi
    } >&2
    exit 0
fi

# ============================================================================
# 5. 扫 git diff(unstaged + staged)→ changed_meta_files
# ============================================================================

DIFF_FILES=$( (git diff --name-only --relative 2>/dev/null; git diff --cached --name-only --relative 2>/dev/null) | awk 'NF' | sort -u)

# 注:不在此早退 — 即使 harness/ 内 DIFF_FILES 为空,§5.5 仍要扫 repo 根
# (M3 = 根 CLAUDE.md 仅在 §5.5 中可见)。最终 §5.5 后的 CHANGED_META_FILES 空检查统一处理。
# (同一 latent bug 的修补;pre-commit 孪生已于 2026-06-04 剪枝移除,本 hook 为唯一 covers 执法器)

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
# 主扫 cwd=harness/,git diff --relative 输出不含 repo 根级文件(如 M3 = 根 CLAUDE.md)。
# 新增段:cwd=repo 根 跑 git diff,过滤无 / 前缀的根级文件,用现有 INCLUDE_GLOBS 匹配。
# 失败降级:git -C 失败 / ROOT_DIR 不存在 → stderr warning + 跳过段(主扫继续)。

ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/.git" ]; then
    # R1: git -C 健康检查 — 若 git 调用失败(repo 损坏 / submodule 未初始化等),
    # stderr warning + 跳过段(主扫继续);spec §3.1 + §5 R1 + §5.2 要求
    if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "⚠️ repo 根 git -C 调用失败,§5.5 跳过(主扫继续)" >&2
        ROOT_DIFF=""
    else
        ROOT_DIFF=$( (git -C "$ROOT_DIR" diff --name-only 2>/dev/null; \
                      git -C "$ROOT_DIR" diff --cached --name-only 2>/dev/null) | \
                     awk 'NF' | sort -u )
    fi

    if [ -n "$ROOT_DIFF" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            # 仅取 repo 根级文件(无 / 前缀)— 子目录已在 harness/ 主扫覆盖
            case "$f" in
                */*) continue ;;
            esac
            if is_in_scope "$f"; then
                # D1 sentinel 前缀:repo 根级文件加 `<root>/`,与主扫输出区分(M3 vs M4)
                CHANGED_META_FILES+=("<root>/$f")
            fi
        done <<< "$ROOT_DIFF"
    fi
fi
# else: ROOT_DIR 不存在(单层下游)→ 跳过段,主扫继续(R2)

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 6. 扫所有 audit (主目录 + archive/INDEX.md)→ covered_files(失效后)
# ============================================================================
# (extract_covers / is_audit_credential / collect_audit_files 定义见 §4.5)

collect_audit_files

# 计算 covered_files(应用失效规则)
# 用临时文件替代关联数组(POSIX bash 兼容)
COVERED_TMP=$(mktemp 2>/dev/null) || COVERED_TMP="/tmp/check-audit-coverage-covered-$$"
: > "$COVERED_TMP" 2>/dev/null

cleanup_tmp() {
    [ -n "${COVERED_TMP:-}" ] && [ -f "$COVERED_TMP" ] && rm -f "$COVERED_TMP" 2>/dev/null
}
trap cleanup_tmp EXIT

for audit in "${AUDIT_FILES[@]}"; do
    [ -r "$audit" ] || continue

    # 校验 audit: true
    if ! is_audit_credential "$audit"; then
        # 不是审查凭证,跳过(不警告 — 可能是 process-audit 报告等其他类型文件)
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
        # 不强制警告(YAML 损坏由 awk 静默退出;空 covers 是合法但未走流程)
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
# 8. 阻断 stop + stderr 引导消息
# ============================================================================
# skip 字段制度已消亡(豁免走 exempt 微 audit,对账天然认):原 handoff
# `## meta-review: skipped` 解析整段已删除,无 skip 豁免路径。

{
    echo "检测到凭证义务改动但无对应审查凭证覆盖。"
    echo ""
    echo "改动的凭证义务文件:"
    for f in "${CHANGED_META_FILES[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "未被任何有效 audit covers 覆盖的文件:"
    for f in "${UNCOVERED[@]}"; do
        echo "  - $f"
    done
    echo ""
    echo "处理方式(任选其一;文法住 docs/governance/credentials-rules.md):"
    echo "  1. 按 review-rules 维度选择表治理行 fork 审查,产出"
    echo "     docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md(frontmatter audit: true + covers 列出上述文件)"
    echo "  2. exempt 微 audit(仅 typo/链接/注释等无语义变更):同 frontmatter + verdict: exempt + 一行理由"
    echo ""
    echo "注意:本 hook 只扫 modified + staged 文件,**不扫 untracked**(git diff 不输出 untracked)"
    echo "  - 若是新建未 git add 的根级文件(如 root CLAUDE.md 全新增加),需先 git add 才会触发后续检测"
    echo "  - 非凭证义务改动(ROADMAP / handoff / decision-trail)无需 covers 覆盖"
    echo ""
    echo "路径前缀约定(sentinel 协议):"
    echo "  - <root>/<path> 表示 repo 根级文件(M3 = repo 根 CLAUDE.md / .gitignore 等)"
    echo "  - 无前缀路径表示 harness/ 内部相对(M4 / 治理 / hook 等)"
    echo "  - 写 audit covers 字段:M3 改动用 <root>/CLAUDE.md,M4 改动用 CLAUDE.md"
} >&2

exit 2

#!/bin/bash
# check-context-chain.sh
# Stop hook:docs/context/ 分层活上下文链校验(L1-L6 脊柱)
#
# 两道(软收尾 + 硬收口):
#   软(常态 Stop):断链 / 编码冲突 / 疑似全角 → stderr warning + exit 0(不阻断发散)
#   硬(收口):finishing(docs/active/evaluation-result.md 存在)且 docs/context/ 在场时,
#            handoff 必须显式声明 `## context-chain: 已核(...)` 或 `## context-chain: skipped(理由: ...)`,
#            否则 exit 2。真正的链核查由 AI 按 finishing-rules「收口硬核链」节做;
#            本 hook 只机械逼"显式声明"(与 meta-review 必须有 audit 文件同套路,不解析对错)。
#
# 协议(Claude Code Stop hook):
#   输入 stdin JSON(stop_hook_active);exit 0=放行 / exit 2=阻断 + stderr 引导
#
# 设计硬前提(本会话两轮审查实证教训,务必守):
#   - POSIX awk:禁 gawk 三参数 match($0,re,m);用 match()+RSTART/RLENGTH/substr
#   - 字节精确:只认半角 [ ] : ,;frontmatter 含全角 ［ ］ ： ， ｜ → 机读会静默漏 → 发"疑似全角"warning
#   - find 递归(非 bash ** glob,躲 globstar 未开导致漏扫子目录)
#   - LF(.gitattributes *.sh eol=lf 已覆盖);带 stop_hook_active 安全带 + 先 INPUT=$(cat)
#
# 剂量:仅在 docs/context/ 存在时生效;无则 exit 0(小探索项目零打扰)。upstream:[待定]/[] 放行。
#
# 命名:无 meta-/check-meta- 前缀 → setup.sh 不过滤 → 分发下游(下游是主战场)。
#       落 .claude/hooks/ → meta-scope.conf B 组 glob 自动纳 meta scope(改本 hook 走 meta-review)。

set -u

INPUT=$(cat)

# ============================================================================
# 0. 防死循环安全带
# ============================================================================
if command -v jq >/dev/null 2>&1; then
    if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
        exit 0
    fi
else
    echo "⚠️ jq 缺失,check-context-chain.sh 降级跳过" >&2
    exit 0
fi

# ============================================================================
# 1. 工作目录(双层 harness / 单层下游;沿用 M15 范式)
# ============================================================================
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if   [ -d "$PROJECT_DIR/harness/docs/context" ]; then WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/docs/context" ];         then WORK_DIR="$PROJECT_DIR"
else exit 0; fi   # 无 docs/context/ → 不在场,放行
cd "$WORK_DIR" 2>/dev/null || exit 0

# ============================================================================
# 2. 依赖(缺则降级 exit 0)
# ============================================================================
for t in awk grep find; do
    if ! command -v "$t" >/dev/null 2>&1; then
        echo "⚠️ $t 缺失,check-context-chain.sh 降级跳过" >&2
        exit 0
    fi
done

CTX="docs/context"

# ============================================================================
# 3. frontmatter 字段提取(POSIX awk 状态机;禁三参数 match)
# ============================================================================
# extract_field <file> <field> → 打印 frontmatter 区间内该字段的值(首个匹配)
extract_field() {
    awk -v fld="$2" '
        BEGIN { in_fm=0; have_fm=0 }
        /^---[[:space:]]*$/ {
            if (in_fm==0 && have_fm==0) { in_fm=1; have_fm=1; next }
            else if (in_fm==1) { exit }
        }
        in_fm==1 {
            if ($0 ~ ("^[[:space:]]*" fld "[[:space:]]*:")) {
                line=$0
                if (match(line, /:[[:space:]]*/)) {
                    val=substr(line, RSTART+RLENGTH)
                    sub(/[[:space:]]+$/, "", val)   # trim 尾
                    print val
                    exit
                }
            }
        }
    ' "$1" 2>/dev/null
}

# 收集文件清单(find 递归,非 ** glob)
FILES=$(find "$CTX" -type f -name '*.md' 2>/dev/null)
[ -z "$FILES" ] && exit 0   # context/ 空 → 放行

# 收集编码全集(file-level code;不解析 L2-INDEX 表格行 — 行级精确挂靠靠拆文件 / finishing AI 核)
CODES_TMP=$(mktemp 2>/dev/null) || CODES_TMP="/tmp/check-context-chain-codes-$$"
: > "$CODES_TMP" 2>/dev/null
cleanup_tmp() { [ -n "${CODES_TMP:-}" ] && [ -f "$CODES_TMP" ] && rm -f "$CODES_TMP" 2>/dev/null; }
trap cleanup_tmp EXIT

while IFS= read -r file; do
    [ -z "$file" ] && continue
    code=$(extract_field "$file" code)
    [ -n "$code" ] && echo "$code" >> "$CODES_TMP"
done <<EOF
$FILES
EOF

WARN=""

# ============================================================================
# 4. 检 A:编码唯一(同 code 出现 >1 次)
# ============================================================================
DUPS=$(sort "$CODES_TMP" 2>/dev/null | uniq -d)
if [ -n "$DUPS" ]; then
    while IFS= read -r d; do
        [ -n "$d" ] && WARN="$WARN
  编码冲突(同 code 多处): $d"
    done <<EOF
$DUPS
EOF
fi

# ============================================================================
# 5. 逐文件:全角护栏 + 断链(upstream 编码不存在)
#    注:方向合法(低层不指更高层)挪到 finishing 硬核(AI 核),软 hook 不查,守瘦身
# ============================================================================
while IFS= read -r file; do
    [ -z "$file" ] && continue

    # 全角护栏:frontmatter 内 code/upstream/layer 行含全角符号 → 机读会静默漏
    fw=$(awk '
        BEGIN { in_fm=0; have_fm=0 }
        /^---[[:space:]]*$/ {
            if (in_fm==0 && have_fm==0) { in_fm=1; have_fm=1; next }
            else if (in_fm==1) { exit }
        }
        in_fm==1 && /(code|upstream|layer)/ { print }
    ' "$file" 2>/dev/null | grep -F -e '［' -e '］' -e '：' -e '，' -e '｜' 2>/dev/null | head -1)
    if [ -n "$fw" ]; then
        WARN="$WARN
  [$file] 疑似全角符号(机读会静默漏,frontmatter 只能用半角 [ ] : ,): $fw"
    fi

    # 断链:解析 upstream 内联数组 [a, b],逐元素查是否在 CODES(纯 bash,不依赖 sed)
    up_raw=$(extract_field "$file" upstream)
    [ -z "$up_raw" ] && continue
    up_inner="$up_raw"
    up_inner="${up_inner#[}"     # 去前 [
    up_inner="${up_inner%]}"     # 去后 ]
    OLDIFS=$IFS
    IFS=','
    for u in $up_inner; do
        u="${u#"${u%%[![:space:]]*}"}"   # trim 前
        u="${u%"${u##*[![:space:]]}"}"   # trim 后
        [ -z "$u" ] && continue
        [ "$u" = "待定" ] && continue     # 章法,放行
        if ! grep -Fxq -- "$u" "$CODES_TMP" 2>/dev/null; then
            WARN="$WARN
  [$file] upstream 指向不存在的编码: $u(断链 — 改上游须当场把下游 repoint 或标 待定)"
        fi
    done
    IFS=$OLDIFS
done <<EOF
$FILES
EOF

# ============================================================================
# 6. 硬收口:finishing(evaluation-result.md 存在)→ 逼 handoff 显式声明链已核
# ============================================================================
EVAL_FILE="docs/active/evaluation-result.md"
HANDOFF="docs/active/handoff.md"
if [ -f "$EVAL_FILE" ]; then
    DECLARED=""
    if [ -r "$HANDOFF" ]; then
        DECLARED=$(grep -E '^[[:space:]]*##[[:space:]]+context-chain:[[:space:]]+(已核|skipped)' \
                   "$HANDOFF" 2>/dev/null | head -1)
    fi
    if [ -z "$DECLARED" ]; then
        {
            echo "收口阶段(docs/active/evaluation-result.md 存在)且 docs/context/ 活链在场 — Stop 已阻断。"
            echo ""
            echo "活上下文链必须在收口时核(链通 / 方向合法 / 待定补齐),核完在 handoff 显式声明(任选其一):"
            echo "  ## context-chain: 已核(<一句结论>)"
            echo "  ## context-chain: skipped(理由: <非空理由>)"
            echo ""
            echo "核法见 docs/governance/finishing-rules.md「收口硬核链」节。"
            echo "字段注意:括号必须半角 ( ) U+0028/U+0029,中文 IME 默认全角不命中。"
            if [ -n "$WARN" ]; then
                echo ""
                echo "软提醒(供核参考,逐条该修或标待定):"
                printf '%b\n' "$WARN"
            fi
        } >&2
        exit 2
    fi
fi

# ============================================================================
# 7. 软:有 warning 打 stderr,始终 exit 0
# ============================================================================
if [ -n "$WARN" ]; then
    {
        echo "⚠️ 活上下文链早提醒(软,不阻断;收口由 finishing 硬核):"
        printf '%b\n' "$WARN"
        echo "处理:改上游必须当场把下游 repoint 或标 upstream: [待定](待定是章法,静默断链是垃圾)。"
    } >&2
fi

exit 0

#!/bin/bash
# check-meta-cross-ref.sh
# P0.9.3 (互引-a) — Claude Code Stop hook:design-rules ↔ finishing-rules 互引 anchor 完整性检查
#
# 用途:
#   每次 session 末扫 git diff,若改动命中 design-rules.md 或 finishing-rules.md,
#   grep 4 条互引 anchor;任一缺失 → exit 2 + stderr 引导。
#
# 协议(Claude Code Stop hook):
#   - 输入:stdin JSON,字段 stop_hook_active(bool)
#   - 输出:exit 0 = 放行;exit 2 = 阻断 + stderr 引导
#
# 防死循环:
#   stop_hook_active == true 时直接 exit 0(参考 M15)
#
# 错误处理(graceful degrade,与 M15/M16 范式一致):
#   - 文件不可读 → stderr warning + exit 0
#   - git diff 失败 → exit 0
#   - 依赖工具缺失(grep/git)→ stderr warning + exit 0
#   - 唯一 exit 2 路径:确认 anchor 缺失 + 无 handoff skip 理由
#
# spec 锚点:§3.1(check-meta-cross-ref.sh)+ §5(R3 / C1-C8)
# anchor 字符串经 grep 验证在对应文件内字面存在(self-review 阶段验证):
#   - design-rules.md L38 `## spec §0 偏离规则`
#   - design-rules.md L45 `另见 \`finishing-rules.md\``
#   - finishing-rules.md L39 `跨阶段同步约束`
#   - finishing-rules.md L39 `见 \`design-rules.md\``
#
# 命名约定:
#   前缀 check-meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游。

set -u

INPUT=$(cat)

# ============================================================================
# 0. 防死循环
# ============================================================================

if command -v jq >/dev/null 2>&1; then
    if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
        exit 0
    fi
else
    echo "⚠️ jq 缺失,check-meta-cross-ref.sh 降级跳过" >&2
    exit 0
fi

# ============================================================================
# 1. 解析工作目录(双层 harness / 单层下游兼容,沿用 M15 范式)
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
# 2. 依赖工具检查
# ============================================================================

for tool in grep git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,check-meta-cross-ref.sh 降级跳过" >&2
        exit 0
    fi
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# ============================================================================
# 3. 触发判定:仅 design-rules / finishing-rules 改动时进入检查
# ============================================================================

DIFF_FILES=$( (git diff --name-only --relative 2>/dev/null; \
               git diff --cached --name-only --relative 2>/dev/null) | \
              awk 'NF' | sort -u )

case "$DIFF_FILES" in
    *docs/governance/design-rules.md*|*docs/governance/finishing-rules.md*) ;;
    *) exit 0 ;;
esac

# ============================================================================
# 4. PAIRS 定义 + anchor grep
# ============================================================================

# 用 single-quote 字符串避免 backtick escape;每条格式: "file|anchor"
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
    # P0.9.3 第二个 trial 加(D4 修复 — 覆盖 design L28+L45 / finishing L38 间接引用):
    'docs/governance/finishing-rules.md|## 反模式约束'
    'docs/governance/design-rules.md|**轻量级**'
)

VIOLATIONS=()
for pair in "${PAIRS[@]}"; do
    file="${pair%%|*}"
    anchor="${pair#*|}"
    if [ ! -r "$file" ]; then
        echo "⚠️ 文件不可读,check-meta-cross-ref.sh 降级跳过: $file" >&2
        exit 0
    fi
    if ! grep -F -q -- "$anchor" "$file" 2>/dev/null; then
        VIOLATIONS+=("$file 缺失 anchor: $anchor")
    fi
done

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 5. handoff skip 兜底(沿用 M15 范式,字段名 meta-cross-ref)
# ============================================================================

HANDOFF="docs/active/handoff.md"

if [ -r "$HANDOFF" ]; then
    SKIP_LINE=$(grep -E '^[[:space:]]*##[[:space:]]+meta-cross-ref:[[:space:]]+skipped\(理由:[[:space:]]*[^)]*\)' \
                "$HANDOFF" 2>/dev/null | head -1)

    if [ -n "$SKIP_LINE" ]; then
        REASON=$(echo "$SKIP_LINE" | sed -E 's/^.*\(理由:[[:space:]]*([^)]*)\).*$/\1/')
        REASON_TRIMMED=$(echo "$REASON" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
        if [ -n "$REASON_TRIMMED" ]; then
            exit 0
        fi
    fi
fi

# ============================================================================
# 6. 阻断 stop + stderr 引导
# ============================================================================

{
    echo "检测到 design-rules / finishing-rules 互引 anchor 缺失 — Stop 已阻断。"
    echo ""
    echo "缺失 anchor:"
    for v in "${VIOLATIONS[@]}"; do
        echo "  - $v"
    done
    echo ""
    echo "处理方式(任选其一):"
    echo "  1. 在对应文件补回 anchor(参考 spec §3.1 PAIRS 列表)"
    echo "  2. 若 anchor 是有意重命名,**同步改本 hook 的 PAIRS 数组 L98-103**(改 hook = scope=meta,会触发 meta-review)"
    echo "  3. 在 docs/active/handoff.md 写入(必须含非空理由):"
    echo "     ## meta-cross-ref: skipped(理由: <非空理由>)"
    echo ""
    echo "字段名注意:"
    echo "  - **必须**用 \`## meta-cross-ref: skipped\` — 与 \`## meta-review: skipped\`(M15 字段)是不同字段"
    echo "  - 写 \`## meta-review: skipped\` 不让本 hook 放行,反之亦然"
    echo "  - 三字段共存规则详见 \`docs/governance/meta-finishing-rules.md\` §5.4"
    echo ""
    echo "若 anchor 视觉存在但 hook 仍报缺:"
    echo "  - 检 design-rules.md / finishing-rules.md 文件编码(必须 UTF-8 LF)"
    echo "  - 非 UTF-8 编辑器(Win Notepad ANSI / GBK)保存可能改 anchor 字节流 → grep -F 不命中"
} >&2

exit 2

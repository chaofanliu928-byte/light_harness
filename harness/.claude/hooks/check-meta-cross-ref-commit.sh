#!/bin/bash
# check-meta-cross-ref-commit.sh
# P0.9.3 (互引-a) — Git pre-commit hook:design-rules ↔ finishing-rules 互引 anchor 完整性检查
#
# 用途:
#   git commit 前扫 staged 改动,若命中 design-rules.md / finishing-rules.md,
#   grep 4 条互引 anchor;任一缺失 → exit 1 + stderr 引导,阻断 commit。
#
# 与 check-meta-cross-ref.sh(Stop hook)关系:
#   - 触发时机:Stop hook = session 末;本 hook = git commit 前
#   - 协议:本 hook 无 stdin;无 stop_hook_active 防死循环
#   - 扫描:本 hook 仅扫 staged --diff-filter=ACMR
#   - 退出码:本 hook exit 1 阻断 commit
#   - 安装:.git/hooks/pre-commit 软链;harness 自身默认不挂(P0.9.1 §C5)
#
# spec 锚点:§3.1(check-meta-cross-ref-commit.sh)+ §5(C1-C8)
#
# 命名约定:
#   前缀 check-meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游。

set -u

# ============================================================================
# 1. 解析工作目录(沿用 M16 范式)
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
# 2. 依赖检查
# ============================================================================

for tool in grep git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,check-meta-cross-ref-commit.sh 降级跳过" >&2
        exit 0
    fi
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# ============================================================================
# 3. 触发判定:仅 staged design-rules / finishing-rules 改动时进入
# ============================================================================

DIFF_FILES=$(git diff --cached --name-only --diff-filter=ACMR --relative 2>/dev/null | awk 'NF' | sort -u)

if [ -z "$DIFF_FILES" ]; then
    exit 0
fi

case "$DIFF_FILES" in
    *docs/governance/design-rules.md*|*docs/governance/finishing-rules.md*) ;;
    *) exit 0 ;;
esac

# ============================================================================
# 4. PAIRS + anchor grep
# ============================================================================

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
        echo "⚠️ 文件不可读,check-meta-cross-ref-commit.sh 降级跳过: $file" >&2
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
# 5. handoff skip 兜底
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
# 6. 阻断 commit + stderr 引导
# ============================================================================

{
    echo "检测到 staged design-rules / finishing-rules 互引 anchor 缺失 — git commit 已阻断。"
    echo ""
    echo "缺失 anchor:"
    for v in "${VIOLATIONS[@]}"; do
        echo "  - $v"
    done
    echo ""
    echo "处理方式(任选其一,然后重新 git commit):"
    echo "  1. 在对应文件补回 anchor(参考 spec §3.1 PAIRS 列表)"
    echo "  2. 若 anchor 是有意重命名,同步改本 hook 的 PAIRS 数组(grep 'PAIRS=(' 定位)"
    echo "  3. 在 docs/active/handoff.md 写入(必须含非空理由):"
    echo "     ## meta-cross-ref: skipped(理由: <非空理由>)"
    echo ""
    echo "字段名注意:"
    echo "  - **必须**用 \`## meta-cross-ref: skipped\` — 与 \`## meta-review: skipped\`(M14 字段)是不同字段"
    echo "  - 三字段共存规则详见 \`docs/governance/meta-finishing-rules.md\` §5.4"
} >&2

exit 1

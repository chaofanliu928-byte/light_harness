#!/bin/bash
# check-handoff.sh
# Stop hook：Claude 停止前检查交接文档是否更新
#
# 如果有活跃开发（Superpowers 计划）但 handoff 文档过旧，
# 提醒 Claude 更新后再停止。

INPUT=$(cat)

# 关键：如果 stop_hook 已经激活过一次，必须放行，否则死循环
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# 如果没有活跃的开发（无 Superpowers 计划也无交接文档），不需要检查
HAS_PLAN=$(ls "$PROJECT_DIR"/docs/superpowers/plans/*.md 2>/dev/null | head -1)
if [ -z "$HAS_PLAN" ] && [ ! -f "$PROJECT_DIR/docs/active/handoff.md" ]; then
    exit 0
fi

# 检查 handoff.md 是否存在
if [ ! -f "$PROJECT_DIR/docs/active/handoff.md" ]; then
    echo "停止前请先创建 docs/active/handoff.md 记录当前进度" >&2
    exit 2
fi

# 检查 handoff.md 最近 10 分钟内是否更新过
# macOS 和 Linux 的 stat 命令不同，兼容处理
if stat --version &>/dev/null 2>&1; then
    # GNU stat (Linux)
    MODIFIED=$(stat -c %Y "$PROJECT_DIR/docs/active/handoff.md" 2>/dev/null)
else
    # BSD stat (macOS)
    MODIFIED=$(stat -f %m "$PROJECT_DIR/docs/active/handoff.md" 2>/dev/null)
fi

if [ -n "$MODIFIED" ]; then
    NOW=$(date +%s)
    DIFF=$((NOW - MODIFIED))
    
    # 超过 10 分钟未更新
    if [ "$DIFF" -gt 600 ]; then
        echo "docs/active/handoff.md 超过 10 分钟未更新。请在停止前更新交接文档，记录当前进度和下一步计划。" >&2
        exit 2
    fi
fi

exit 0


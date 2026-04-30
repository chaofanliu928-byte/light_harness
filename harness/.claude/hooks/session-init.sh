#!/bin/bash
# session-init.sh
# SessionStart hook：新会话启动时自动注入项目上下文
# 与 Superpowers 的 SessionStart hook 共存，互不冲突
#
# stdout 的内容会被添加到 Claude 的上下文中

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

echo "=== AI Dev Harness 项目状态 ==="

# 检测配置是否完成
SETUP_NEEDED=false
if grep -q "\[项目名称\]" "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi
if grep -q "\[用2-3句话\]" "$PROJECT_DIR/docs/RUBRIC.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi
if grep -q "\[待定义\]" "$PROJECT_DIR/docs/ARCHITECTURE.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi

if [ "$SETUP_NEEDED" = true ]; then
    echo ""
    echo "⚠️ 项目配置未完成。运行 /project-setup 启动配置向导（对话式引导，约 5 分钟）。"
    echo ""
    exit 0
fi

# 注入交接文档（如有）
if [ -f "$PROJECT_DIR/docs/active/handoff.md" ]; then
    echo ""
    echo "--- 交接文档 ---"
    cat "$PROJECT_DIR/docs/active/handoff.md"
    echo ""
fi

# 注入上次方向评估结果（如有）
if [ -f "$PROJECT_DIR/docs/active/evaluation-result.md" ]; then
    echo ""
    echo "--- 上次方向评估 ---"
    cat "$PROJECT_DIR/docs/active/evaluation-result.md"
    echo ""
fi

# 注入最新的活跃设计文档（排除已归档/取消的）
LATEST_DESIGN=$(ls -t "$PROJECT_DIR"/docs/superpowers/specs/*-design.md 2>/dev/null | head -1)
if [ -n "$LATEST_DESIGN" ] && ! head -3 "$LATEST_DESIGN" | grep -q "ARCHIVED\|CANCELLED"; then
    echo ""
    echo "--- 最近的设计文档（活跃）---"
    head -30 "$LATEST_DESIGN"
    echo "..."
    echo "(完整设计: $LATEST_DESIGN)"
    echo ""
fi

# 显示最近的 Superpowers plan（如有）
LATEST_PLAN=$(ls -t "$PROJECT_DIR"/docs/superpowers/plans/*.md 2>/dev/null | head -1)
if [ -n "$LATEST_PLAN" ]; then
    echo ""
    echo "--- 最近的实现计划 ---"
    head -20 "$LATEST_PLAN"
    echo "..."
    echo "(完整计划: $LATEST_PLAN)"
    echo ""
fi

# 如果什么活跃文档都没有
if [ ! -f "$PROJECT_DIR/docs/active/handoff.md" ] && \
   [ -z "$LATEST_PLAN" ] && [ -z "$LATEST_DESIGN" ]; then
    echo ""
    echo "没有活跃任务。描述你想做的东西，Superpowers 会自动开始 brainstorming。"
fi

# 简要 git 状态
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    echo ""
    echo "--- Git 状态 ---"
    echo "当前分支: $(git branch --show-current 2>/dev/null || echo '未知')"
    echo "最近提交: $(git log --oneline -3 2>/dev/null || echo '无提交')"

    CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CHANGES" -gt 0 ]; then
        echo "⚠️  有 $CHANGES 个未提交的修改"
    fi
fi

# 提醒治理规则
echo ""
echo "--- 治理提醒 ---"
echo "每个阶段前先读对应的治理文件（CLAUDE.md 中有完整列表）。"
echo "brainstorming 读 RUBRIC.md，系统设计读 design-rules.md，writing-plans 基于设计文档 + ARCHITECTURE.md。"

exit 0

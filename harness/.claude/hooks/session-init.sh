#!/bin/bash
# session-init.sh
# SessionStart hook：新会话启动时自动注入项目上下文
# 与 Superpowers 的 SessionStart hook 共存，互不冲突
#
# stdout 的内容会被添加到 Claude 的上下文中
#
# 双层探测(M15 范式,批1a):docs/ 或 harness/docs/(从仓库根启动也能看到自仓库剖面);
#   例外形:无 docs/ 也不退出,WORK_DIR=PROJECT_DIR 继续(注入端任何失败 exit 0 不阻断会话)。
# SETUP_NEEDED:提示不中断 — 命中 → stderr 提醒后继续注入,不再 exit 0 短路。
# 台账段照注全文;>80 行 → 仍照注全文 + stderr 提示超限。

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if   [ -d "$PROJECT_DIR/harness/docs" ]; then WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/docs" ];         then WORK_DIR="$PROJECT_DIR"
else WORK_DIR="$PROJECT_DIR"; fi   # 例外形:无 docs/ 也不退出,继续注入(能注多少注多少)

echo "=== AI Dev Harness 项目状态 ==="
echo "入口地图: AGENTS.md(跨运行时约定) / CLAUDE.md(治理路由)"

# 检测配置是否完成(基于双层探测后的 WORK_DIR;命中 → stderr 提醒,不中断后续注入)
SETUP_NEEDED=false
if grep -q "\[项目名称\]" "$WORK_DIR/CLAUDE.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi
if grep -q "\[用 2-3 句话" "$WORK_DIR/docs/RUBRIC.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi
if grep -q "\[待定义\]" "$WORK_DIR/docs/ARCHITECTURE.md" 2>/dev/null; then
    SETUP_NEEDED=true
fi

if [ "$SETUP_NEEDED" = true ]; then
    echo "⚠️ 项目配置未完成。运行 /project-setup 启动配置向导（对话式引导，约 5 分钟）。" >&2
fi

# 注入交接文档（如有；照注全文，>80 行时另发 stderr 超限提示）
if [ -f "$WORK_DIR/docs/active/handoff.md" ]; then
    echo ""
    echo "--- 交接文档 ---"
    cat "$WORK_DIR/docs/active/handoff.md"
    echo ""
    HANDOFF_LINES=$(wc -l < "$WORK_DIR/docs/active/handoff.md" | tr -d ' ')
    if [ "$HANDOFF_LINES" -gt 80 ] 2>/dev/null; then
        echo "⚠️ 台账超限: docs/active/handoff.md 已 $HANDOFF_LINES 行(>80 行上限)— 适时运行 /structured-handoff 清账归档。" >&2
    fi
fi

# 注入上次方向评估结果（如有）
if [ -f "$WORK_DIR/docs/active/evaluation-result.md" ]; then
    echo ""
    echo "--- 上次方向评估 ---"
    cat "$WORK_DIR/docs/active/evaluation-result.md"
    echo ""
fi

# 注入最新的活跃设计文档（排除已归档/取消的）
LATEST_DESIGN=$(ls -t "$WORK_DIR"/docs/superpowers/specs/*-design.md 2>/dev/null | head -1)
if [ -n "$LATEST_DESIGN" ] && ! head -3 "$LATEST_DESIGN" | grep -q "ARCHIVED\|CANCELLED"; then
    echo ""
    echo "--- 最近的设计文档（活跃）---"
    head -30 "$LATEST_DESIGN"
    echo "..."
    echo "(完整设计: $LATEST_DESIGN)"
    echo ""
fi

# 降级 / 待修订 banner 提醒（design-rules.md「Fork 失败降级」承诺的消费方）
if [ -n "$LATEST_DESIGN" ] && head -3 "$LATEST_DESIGN" 2>/dev/null | grep -q "降级执行\|待修订"; then
    echo ""
    echo "⚠️ 最近设计文档带「降级执行 / 待修订」标注 —— 未经独立 agent 验证。"
    echo "   建议:重新 fork 对应 agent(如 design-review)补审,或先修订再继续。"
    echo "   (来源: $LATEST_DESIGN)"
    echo ""
fi

# 显示最近的 Superpowers plan（如有）
LATEST_PLAN=$(ls -t "$WORK_DIR"/docs/superpowers/plans/*.md 2>/dev/null | head -1)
if [ -n "$LATEST_PLAN" ]; then
    echo ""
    echo "--- 最近的实现计划 ---"
    head -20 "$LATEST_PLAN"
    echo "..."
    echo "(完整计划: $LATEST_PLAN)"
    echo ""
fi

# 如果什么活跃文档都没有
if [ ! -f "$WORK_DIR/docs/active/handoff.md" ] && \
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

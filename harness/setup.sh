#!/bin/bash
# setup.sh — 将 AI Dev Harness 安装到目标项目
# 前置依赖：Superpowers 插件
#
# 用法：
#   ./setup.sh                    # 安装到当前目录
#   ./setup.sh /path/to/project   # 安装到指定目录

set -e

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔧 AI Dev Harness 安装器"
echo "========================"
echo "目标: $(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
echo ""

# 检查依赖
echo "检查依赖..."
if ! command -v jq &>/dev/null; then
    echo "⚠️  缺少 jq（hooks 需要）— brew install jq / sudo apt install jq"
fi
echo ""

# 覆盖确认
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    read -p "CLAUDE.md 已存在，覆盖？(y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消。"
        exit 0
    fi
fi

# 复制文件
echo "复制文件..."

# .claude/agents
mkdir -p "$TARGET_DIR/.claude/agents"
cp "$SCRIPT_DIR/.claude/agents/evaluator.md" "$TARGET_DIR/.claude/agents/"
cp "$SCRIPT_DIR/.claude/agents/designer.md" "$TARGET_DIR/.claude/agents/"
cp "$SCRIPT_DIR/.claude/agents/design-reviewer.md" "$TARGET_DIR/.claude/agents/"
cp "$SCRIPT_DIR/.claude/agents/security-reviewer.md" "$TARGET_DIR/.claude/agents/"
cp "$SCRIPT_DIR/.claude/agents/process-auditor.md" "$TARGET_DIR/.claude/agents/"
# research-scout 是"方案调研编排说明"(feature 侧,下游规划方案时按需用),非领审员 agent;
# 与 design-reviewer.md 同类(说明文件而非 custom agent),随 agents 分发下游。
# 注:本文件改动须 audit 凭证(命中 credentials.conf),但属下游可用工件 — "凭证义务路径" ≠ "分发范围"。
cp "$SCRIPT_DIR/.claude/agents/research-scout.md" "$TARGET_DIR/.claude/agents/"
cp "$SCRIPT_DIR/.claude/agents/review-scout.md" "$TARGET_DIR/.claude/agents/"

# .claude/workflows(review-scout — ultracode 运行时审查编排;ultracode 关时下游走现有 design-review)
mkdir -p "$TARGET_DIR/.claude/workflows"
cp "$SCRIPT_DIR/.claude/workflows/review-scout.workflow.js" "$TARGET_DIR/.claude/workflows/"

# .claude/skills
mkdir -p "$TARGET_DIR/.claude/skills/evaluate"
mkdir -p "$TARGET_DIR/.claude/skills/structured-handoff"
mkdir -p "$TARGET_DIR/.claude/skills/security-scan"
mkdir -p "$TARGET_DIR/.claude/skills/system-design"
mkdir -p "$TARGET_DIR/.claude/skills/design-review"
mkdir -p "$TARGET_DIR/.claude/skills/project-setup"
mkdir -p "$TARGET_DIR/.claude/skills/process-audit"
cp "$SCRIPT_DIR/.claude/skills/evaluate/SKILL.md" "$TARGET_DIR/.claude/skills/evaluate/"
cp "$SCRIPT_DIR/.claude/skills/structured-handoff/SKILL.md" "$TARGET_DIR/.claude/skills/structured-handoff/"
cp "$SCRIPT_DIR/.claude/skills/structured-handoff/handoff-template.md" "$TARGET_DIR/.claude/skills/structured-handoff/"
cp "$SCRIPT_DIR/.claude/skills/security-scan/SKILL.md" "$TARGET_DIR/.claude/skills/security-scan/"
cp "$SCRIPT_DIR/.claude/skills/system-design/SKILL.md" "$TARGET_DIR/.claude/skills/system-design/"
cp "$SCRIPT_DIR/.claude/skills/design-review/SKILL.md" "$TARGET_DIR/.claude/skills/design-review/"
cp "$SCRIPT_DIR/.claude/skills/project-setup/SKILL.md" "$TARGET_DIR/.claude/skills/project-setup/"
cp "$SCRIPT_DIR/.claude/skills/process-audit/SKILL.md" "$TARGET_DIR/.claude/skills/process-audit/"

# .claude/hooks:全量分发(治理同层 2026-06-13;对账工具 check-audit-coverage.sh 随分发)
mkdir -p "$TARGET_DIR/.claude/hooks"
for hook in "$SCRIPT_DIR/.claude/hooks/"*.sh; do
    [ -e "$hook" ] || continue
    cp "$hook" "$TARGET_DIR/.claude/hooks/"
done
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
# 凭证要求表(机器版;与 docs/governance/credentials-rules.md 人读版双写同步)
cp "$SCRIPT_DIR/.claude/hooks/credentials.conf" "$TARGET_DIR/.claude/hooks/"
# settings.json 用 templates/settings.json(下游唯一来源;自仓库无接线——C 案追记①)
cp "$SCRIPT_DIR/templates/settings.json" "$TARGET_DIR/.claude/"

# docs
mkdir -p "$TARGET_DIR/docs/active"
mkdir -p "$TARGET_DIR/docs/completed"
mkdir -p "$TARGET_DIR/docs/decisions"
mkdir -p "$TARGET_DIR/docs/governance"
mkdir -p "$TARGET_DIR/docs/product-specs"
mkdir -p "$TARGET_DIR/docs/references"
mkdir -p "$TARGET_DIR/docs/audits"
mkdir -p "$TARGET_DIR/docs/superpowers/specs"
mkdir -p "$TARGET_DIR/docs/superpowers/plans"
mkdir -p "$TARGET_DIR/docs/context"
cp "$SCRIPT_DIR/docs/RUBRIC.md" "$TARGET_DIR/docs/"
cp "$SCRIPT_DIR/docs/ARCHITECTURE.md" "$TARGET_DIR/docs/"
cp "$SCRIPT_DIR/templates/PROGRESS.md" "$TARGET_DIR/docs/"
# governance:全量分发(治理同层;credentials-rules.md 随 *.md 自然拷入)
for gov in "$SCRIPT_DIR/docs/governance/"*.md; do
    [ -e "$gov" ] || continue
    cp "$gov" "$TARGET_DIR/docs/governance/"
done
# 初始台账:从模板单源(skill 捆绑资源)复制;活文件守卫(I7)— 已存在不覆盖
if [ ! -f "$TARGET_DIR/docs/active/handoff.md" ]; then
    cp "$SCRIPT_DIR/.claude/skills/structured-handoff/handoff-template.md" "$TARGET_DIR/docs/active/handoff.md" 2>/dev/null || true
fi
# 活文件守卫扩展(批 0 audit F1):下游会改写这些文件,重跑安装不得覆盖
if [ ! -f "$TARGET_DIR/docs/product-specs/index.md" ]; then
    cp "$SCRIPT_DIR/templates/product-specs-index.md" "$TARGET_DIR/docs/product-specs/index.md" 2>/dev/null || true
fi
if [ ! -f "$TARGET_DIR/docs/context/README.md" ]; then
    cp "$SCRIPT_DIR/templates/context/README.md" "$TARGET_DIR/docs/context/" 2>/dev/null || true
fi
if [ ! -f "$TARGET_DIR/docs/context/L1-vision.md" ]; then
    cp "$SCRIPT_DIR/templates/context/L1-vision.md" "$TARGET_DIR/docs/context/" 2>/dev/null || true
fi
if [ ! -f "$TARGET_DIR/docs/context/L2-INDEX.md" ]; then
    cp "$SCRIPT_DIR/templates/context/L2-INDEX.md" "$TARGET_DIR/docs/context/" 2>/dev/null || true
fi
cp "$SCRIPT_DIR/docs/decisions/_TEMPLATE.md" "$TARGET_DIR/docs/decisions/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/MODULE_DOC_TEMPLATE.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/DESIGN_TEMPLATE.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/multi-agent-review-guide.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/testing-standard.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/challenger-orientation.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
# 注意:recommended-tools.md 不分发下游 — 它是 harness 仓库内的"用户级工具推荐清单",
# 下游目标项目不应混入;用户在 setup.sh 末尾 echo 中获取 URL 即可。

# CLAUDE.md
cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/"

# AGENTS.md(入口地图;活文件守卫 — 已存在不覆盖,I7)
if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
    cp "$SCRIPT_DIR/templates/AGENTS.md" "$TARGET_DIR/AGENTS.md"
fi

echo ""
echo "✅ 安装完成！共 $(find "$TARGET_DIR/.claude" "$TARGET_DIR/docs" "$TARGET_DIR/CLAUDE.md" -type f 2>/dev/null | wc -l | tr -d ' ') 个文件"
echo ""
echo "下一步："
echo "  1. 确保已安装 Superpowers: /plugin install superpowers@claude-plugins-official"
echo "  2. 启动 Claude Code，配置向导会自动引导你完成项目配置（约 5 分钟对话）"
echo "  3. 配置完成后，直接描述你想做的东西，AI 自动编排开发流程"
echo ""
echo "💡 提示:harness 治理文件不应在下游本地修改,如有改动需求请回 harness 仓库 PR"
echo ""
echo "📦 推荐工具(可选,用户级 — 不与项目绑定):"
echo "  - glassbox: AI 工作 session 内可视化(7 类 HTML 页面 + lint 工具,"
echo "    辅助审查 AI 工作产出的真实性)"
echo "    仓库: https://github.com/chaofanliu928-byte/glassbox"
echo "    建议装在 ~/tools/glassbox/ 之类全局位置,装不装、装哪、装啥版本由你决定"
echo "    harness 治理流程不依赖此工具在场,不装也能正常工作"

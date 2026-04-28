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

# .claude/skills
mkdir -p "$TARGET_DIR/.claude/skills/evaluate"
mkdir -p "$TARGET_DIR/.claude/skills/skill-extract"
mkdir -p "$TARGET_DIR/.claude/skills/structured-handoff"
mkdir -p "$TARGET_DIR/.claude/skills/session-search"
mkdir -p "$TARGET_DIR/.claude/skills/security-scan"
mkdir -p "$TARGET_DIR/.claude/skills/system-design"
mkdir -p "$TARGET_DIR/.claude/skills/design-review"
mkdir -p "$TARGET_DIR/.claude/skills/project-setup"
mkdir -p "$TARGET_DIR/.claude/skills/process-audit"
cp "$SCRIPT_DIR/.claude/skills/evaluate/SKILL.md" "$TARGET_DIR/.claude/skills/evaluate/"
cp "$SCRIPT_DIR/.claude/skills/skill-extract/SKILL.md" "$TARGET_DIR/.claude/skills/skill-extract/"
cp "$SCRIPT_DIR/.claude/skills/structured-handoff/SKILL.md" "$TARGET_DIR/.claude/skills/structured-handoff/"
cp "$SCRIPT_DIR/.claude/skills/session-search/SKILL.md" "$TARGET_DIR/.claude/skills/session-search/"
cp "$SCRIPT_DIR/.claude/skills/security-scan/SKILL.md" "$TARGET_DIR/.claude/skills/security-scan/"
cp "$SCRIPT_DIR/.claude/skills/system-design/SKILL.md" "$TARGET_DIR/.claude/skills/system-design/"
cp "$SCRIPT_DIR/.claude/skills/design-review/SKILL.md" "$TARGET_DIR/.claude/skills/design-review/"
cp "$SCRIPT_DIR/.claude/skills/project-setup/SKILL.md" "$TARGET_DIR/.claude/skills/project-setup/"
cp "$SCRIPT_DIR/.claude/skills/process-audit/SKILL.md" "$TARGET_DIR/.claude/skills/process-audit/"

# .claude/hooks
# 命名前缀过滤(D12):跳过 meta-* / check-meta-* hooks(meta scope 治理 hook 不分发下游)
mkdir -p "$TARGET_DIR/.claude/hooks"
for hook in "$SCRIPT_DIR/.claude/hooks/"*.sh; do
    [ -e "$hook" ] || continue
    name=$(basename "$hook")
    case "$name" in
        meta-*) continue ;;       # M20 反审检测段拆分文件 / 未来 meta-* hook
        check-meta-*) continue ;; # M15 / M16 治理 hook
    esac
    cp "$hook" "$TARGET_DIR/.claude/hooks/"
done
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true
# settings.json 走 M19 双轨模板(D19 a 方案):下游零 meta hook 注册痕迹
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
cp "$SCRIPT_DIR/docs/RUBRIC.md" "$TARGET_DIR/docs/"
cp "$SCRIPT_DIR/docs/ARCHITECTURE.md" "$TARGET_DIR/docs/"
cp "$SCRIPT_DIR/docs/PROGRESS.md" "$TARGET_DIR/docs/"
# governance:命名前缀过滤(D12),跳过 meta-* 治理文件(M1 / M2 不分发下游)
for gov in "$SCRIPT_DIR/docs/governance/"*.md; do
    [ -e "$gov" ] || continue
    name=$(basename "$gov")
    case "$name" in
        meta-*) continue ;;
    esac
    cp "$gov" "$TARGET_DIR/docs/governance/"
done
cp "$SCRIPT_DIR/docs/active/handoff.md" "$TARGET_DIR/docs/active/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/product-specs/index.md" "$TARGET_DIR/docs/product-specs/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/decisions/_TEMPLATE.md" "$TARGET_DIR/docs/decisions/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/MODULE_DOC_TEMPLATE.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/DESIGN_TEMPLATE.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/multi-agent-review-guide.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/references/testing-standard.md" "$TARGET_DIR/docs/references/" 2>/dev/null || true
# 注意:recommended-tools.md 不分发下游 — 它是 harness 仓库内的"用户级工具推荐清单",
# 下游目标项目不应混入;用户在 setup.sh 末尾 echo 中获取 URL 即可。

# CLAUDE.md
cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/"

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

# AI Dev Harness

> Claude Code 的开发治理框架。配合 Superpowers 插件使用，让 vibe coding 有工程质量保障。

**Superpowers 管"怎么写好代码"，AI Dev Harness 管"按什么标准写、方向对不对、文档怎么流转、人在哪里介入"。**

## 核心能力

- **多智能体治理** — 设计/审查/评估/安全/审计各由独立 agent team 执行，对抗-决策分离
- **RUBRIC 驱动方向** — 项目评分标准贯穿全生命周期，渐进式从用户反馈积累
- **文档先行** — 新建先文档再代码，变更先改文档再改代码
- **流程审计** — 每次功能完成后自动审计流程遵从度和用户满意度，记录到 `docs/audits/`
- **最小变更约束** — 融入 Andrej Karpathy 的 CLAUDE.md 简洁性原则
- **问题式任务** — 规划阶段区分契约任务（指令式）和实现任务（问题式），留给实现 agent 判断空间

## 前置依赖

安装 [Superpowers](https://github.com/obra/superpowers) 插件：

```
/plugin install superpowers@claude-plugins-official
```

## 安装

```bash
git clone https://github.com/chaofanliu928-byte/light_harness.git
cd light_harness/harness
./setup.sh /path/to/your-project
```

然后启动 Claude Code，配置向导自动引导完成项目配置（约 5 分钟对话）：

```bash
cd /path/to/your-project
claude
# AI 检测到配置未完成，自动提示运行 /project-setup
```

## 仓库结构

```
harness/                     ← 框架源码（分发的部分）
├── CLAUDE.md                ← 安装到目标项目的模板
├── README.md                ← 完整说明
├── setup.sh                 ← 安装脚本
├── .claude/
│   ├── agents/              ← 5 个领审员 agent
│   ├── skills/              ← 9 个 skill
│   └── hooks/               ← 6 个 hook
└── docs/
    ├── RUBRIC.md            ← 项目评分标准模板
    ├── governance/          ← 6 个阶段治理规则
    └── references/          ← 参考文档（含多智能体审查指南）
```

## 完整文档

- [框架说明](harness/README.md) — 架构、组件清单、十条设计原则
- [多智能体审查指南](harness/docs/references/multi-agent-review-guide.md) — 对抗-决策分离模式

## 许可证

MIT

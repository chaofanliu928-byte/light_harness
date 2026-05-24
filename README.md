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

## 可选：接入 OpenAI Codex

> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`);若日后激活 codex 接入,先读 `harness/docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `harness/docs/decision-trail.md` 2026-05-24 拐点回溯本搁置背景。下方安装步骤 + swap 决策表保留作完整参考。

harness 可选接入 OpenAI Codex 作为部分 sub-agent 角色的替代。**核心目的：成本节省**（Claude 同等能力比 codex 贵）。跨模型对抗是副产品，不是主要目的。

### 适用场景

- 你已有 ChatGPT 订阅 或 OpenAI API key
- 你接受 11 个 sub-agent 角色 swap codex(2026-05-22 修订加入实现链路 4 角色):
  - **实现链路**:designer / **planner** / **implementer** / **testing**
  - **审查链路**:silent-failure-hunter / 设计自检挑战者 / design-review 4 挑战者 / **code-reviewer** / evaluate 非关键维度 / security-scan 危险+注入
- 你接受 6 个角色保 Claude:调度者 / evaluate 关键维度 / security-scan 凭证 / meta-review / process-audit / **综合阶段**

### 安装步骤

```bash
# 1. 装 codex CLI（需 Node 18.18+）
npm install -g @openai/codex
codex login    # ChatGPT 订阅 或 OpenAI API key

# 2. 在 Claude Code 内
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins

# 3. 启用 Review Gate（可选）
/codex:setup --enable-review-gate
```

### 详细 swap 决策表

详见 [`harness/docs/governance/model-route.md`](harness/docs/governance/model-route.md) — 完整角色 × 配置（sandbox / approval / model / effort）。

### 不接入也完全可用

harness 默认所有角色保 Claude。codex 接入是**可选**增强，不接入不影响任何 harness 治理流程。

## 完整文档

- [框架说明](harness/README.md) — 架构、组件清单、十条设计原则
- [多智能体审查指南](harness/docs/references/multi-agent-review-guide.md) — 对抗-决策分离模式
- [Model-Route 治理规则](harness/docs/governance/model-route.md) — codex 接入的角色 swap 决策表
- [综合阶段规则](harness/docs/governance/synthesis-rules.md) — 调度者面对挑战者的事前/事后规则
- [推荐工具](harness/docs/references/recommended-tools.md) — 用户级可选工具链接（含 codex / glassbox）
- [Roadmap](harness/docs/ROADMAP.md) — 下一阶段方向：可观测性、真实项目迁移验证、跨项目 skill 沉淀

## 许可证

MIT

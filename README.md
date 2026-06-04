# AI Dev Harness

> Claude Code 的开发治理框架。配合 Superpowers 插件使用，让 vibe coding 有工程质量保障。

**Superpowers 管"怎么写好代码"，AI Dev Harness 管"按什么标准写、方向对不对、文档怎么流转、人在哪里介入"。**

## 设计理念

### 一句话

**让弱者高于平均线,让强者更强。**

### 给谁设计

- **弱者**(经验少 / 不熟悉 AI 协作 / 没系统化 governance 直觉)— 框架强制走流程,照着做就能超过"自己单干"
- **强者**(有经验 / 已有 governance 直觉)— 框架给约束和工具,突破自己的内省盲点 + 跨项目复用经验

### 七层核心原理

按从认知根基到物理实现 7 层组织:

#### 层 1:认知约束(根基)
- **1.1 AI 自评乐观偏差公设** — AI 评估自己产出有系统性乐观偏差;做事和判断必须分开。**实现**:所有 fork 机制 + 5 个 agent 文件
- **1.2 行动公设** — 不确定时执行外部动作(Grep/Read/WebFetch),不内省。**实现**:`session-search` skill + `session-init.sh` hook

#### 层 2:结构原则(实现公设)
- **2.1 实现-审查分离** — 调度 / 设计 / 实施 / 审查 各不同 agent。**Why**:**上下文隔离 = 独立性前提**(对抗者必须有独立心智模型才能真发现盲区 — 同 context 内分角色,挑战者脑子里还留着设计者的思路,做不出真对抗)+ 避免上下文腐烂 + 突破公设 1 单智能体维护决策的死结。**实现**:5 个 agent(designer / design-reviewer / evaluator / process-auditor / security-reviewer)
- **2.2 扁平多挑战者架构** — 调度者直接 fork N 个独立挑战者,不二级嵌套。**Why**:Claude Code subagent 平台无 Agent 工具权限。**实现**:所有 skill 第一步统一 "在一条消息中并行 fork N 个"

#### 层 3:流程哲学(vibe coding 启发)
- **3.1 前期方案 + 最后验收 = 重头戏** — 力气放在 brainstorming/design 和 finishing/audit,中间放手。**Why**:vibe coding 启发 — 方案错全白做 + 最后验收守底线 + 中间放手提效。**实现**:前期 `project-setup` / `system-design` / `design-review`;最后 `evaluate` / `process-audit` / `security-scan` / `meta-review`;中间让 Superpowers 跑 implementation
- **3.2 文档先行** — 新建/变更先有文档再写代码。**Why**:强制结构化思考 + 智能体协作前提(通过 Read 对齐意图)。**实现**:`design-rules.md` 开头硬约束 + `check-module-docs.sh` hook
- **3.3 边做边提升** — 不预设固化未来阶段,由真实需求拉动。**Why**:防 over-engineer 假设性需求 + 保留 optionality。**实现**:`ROADMAP.md` 工作哲学段 + `memory/feedback_iterative_progression.md`
- **3.4 问题完美定义比解决问题重要**(debug 方法论)— debug 时,先把问题的 "是什么 / 在哪里 / 触发条件 / 已知边界" 定义清楚,再谈解。**Why**:问题定义错 = 解决方案必然错;debug 一旦跳进 "试错修复" 思维,容易跟随表象做错诊断;大部分时间该花在"理解问题",少量花在"修"。这是 vibe coding 在 debug 端的应用(3.1 是 plan 端)。**实现**:`docs/superpowers/specs/2026-05-12-p3-debug-sop-original-framework.md`(P3 debug SOP)+ `p0-9-4-self-check.md` §D P3 框架
- **3.5 真正理解意图 > 字面执行**(人类表达缺陷原则)— 决策前必须深挖用户真正意图,不在用户说完第一句就开始设计/执行。**Why**:人类自然语言有缺陷 — 模糊 / 不完整 / 用词跟实际意思可能偏差;用户表达过程中才意识到真实需求;直接按字面执行 = 可能解决错的问题;智能体倾向"立刻动手"(响应速度优先),框架强制先深挖。跟 3.4 同精神 — 3.4 是 debug 端找问题,3.5 是 plan 端找需求。**实现**:`brainstorming-rules.md` 阶段二"需求深挖"(识别模糊/缺失/冲突/隐含假设/优先级)+ 阶段三"需求确认清单" + `memory/feedback_design_philosophy.md`(不越权决策)

#### 层 4:协作机制(智能体友好基础设施)
- **4.1 智能体友好文档系统** — CLAUDE.md 索引 + 5 产物(spec/decision-trail/audit/banner/handoff)各司其职。**Why**:索引让智能体一眼找入口 / 维护良好让 Read 任何文件能拿到 fresh+actionable / 智能体友好 ≠ 人友好(需要 self-contained + structured + cross-referenced)。**实现**:`CLAUDE.md`(索引)+ `docs/superpowers/specs/`(spec)+ `decision-trail.md` + `docs/audits/` + inline banner + `docs/active/handoff.md`
- **4.2 综合阶段中性化** — 调度者构造挑战者 prompt 必须中立(材料/排序/措辞);综合按 RUBRIC 维度评判。**Why**:防 anchoring,多智能体审查的有效性前提。**实现**:`docs/governance/synthesis-rules.md`(事前 5 条 + 事后 4 条 + 综合输出表达准则)
- **4.3 改动范围自动识别** — governance 改动 glob 机械触发 meta-review。**Why**:不靠 AI 自觉,机械触发不可被自我说服绕过。**实现**:`CLAUDE.md` §3-§4 + `.claude/hooks/meta-scope.conf` + `check-meta-*.sh` 系列 hook
- **4.4 人-智能体协作契约**(skill 输出契约)— 每个 skill 统一定义 输入/阶段/输出/反模式/自检。**Why**:可预期(智能体知道什么阶段给什么)+ 可中断恢复(handoff + skill 阶段标识 = 续接锚点)+ 智能体友好(不依赖人在旁边凭感觉指导)。**实现**:9 个 SKILL.md 统一结构
- **4.5 挑战者导览体系**(挑战者侧基础设施)— 主智能体(调度者)进项目时读 `CLAUDE.md` 知道项目结构 / Skill 地图 / 文档索引;挑战者(fork 出的子智能体)对称地需要一份"挑战者侧导览" — 知道:
  - **怎么找问题**(方法论 — 通用自检清单 + 角色专属技巧:矛盾追踪 / 场景遍历 / 反向追问 / 条款对照 等)
  - **去哪找信息**(数据来源向导 — 跨平台路径 + 命令模板 + 项目 slug 推断脚本)
  - **怎么看调度者输入**(批判看 + 自取用户原话校验主线 framing)
  - **哪些陷阱要避**(公设 1 / spec_gap_masking / framing / 反对反对 / 越权)

  **实现**:`harness/docs/references/challenger-orientation.md`。fork 挑战者时 prompt 内含"先 Read 此文件";挑战者输出格式末尾必填 `### 已对照用户原话` section,调度者综合时校验(`synthesis-rules.md` 事后规则 5 落地)。**与下游的关系**:本文件属 `references/`,setup.sh 复制下游 — 下游项目的挑战者也用同一份导览。

- **4.6 主动调研 / 重视外部输入** — harness 默认"内向"(搜本仓库 + 问用户);本能力补上"从仓库外获取新信息作决策输入"的链路。规划方案时,需求定了、讨论方案前,**按需**(可逆性主轴 × 熟悉度次轴,默认跳过)fork 联网调研员,默认用 Claude Code 自带的 deep-research 调研业界方案。**Why**:别让 AI 闭门造车;但联网有成本且无差别检索会降质,所以按需触发。**红线**:调研结果只当**证据 / 选项**(经自己思考判断是否适用),不当判断依据——"别人这么做不单独构成理由"。**实现**:`harness/.claude/agents/research-scout.md`(调研编排 + 红线契约)+ `brainstorming-rules.md` 阶段四前触发节。

#### 层 5:反模式警示(用户校准过的硬约束)
- **5.1 警惕"便利答案掩盖规范缺口"**(`spec_gap_masking`)— 遇缺口要承认,不包装成动作
- **5.2 选择类可视化要展示选项对比**(`choice_visualization`)— 拒绝直接画推荐,选项必须并排
- **5.3 判断必须基于事实和逻辑**(`judgment_basis`)— 禁用"市场判断"/"别人项目数据"
- **5.4 加维"过度工程化"判断的反向追问**(`dimension_addition_judgment`)— "不这样做会怎么解决?" 找不到替代解 = 必要复杂度
- **5.5 项目 skill 不应该扩散到其他项目**(`skill_no_cross_project`)— skill 是项目专属知识

**实现**:`memory/feedback_*.md`(用户级 persistent)+ `design-rules.md` / `brainstorming-rules.md` 反模式约束节

#### 层 6:真实需求 grounding
- **6.1 实战测试在其他项目跑**(`realworld_testing_in_other_projects`)— harness 自仓库是 governance 测试床,不是 feature 测试床;artificial trial 数据失真。**实现**:`memory/feedback_realworld_testing_in_other_projects.md` + `ROADMAP.md` 元规则

#### 层 7:实现载体(物理基础设施)
- **7.1 治理实现为可执行物** — 不只是 `governance/*.md`(描述层),还落到:
  - **skill 协议**(`.claude/skills/X/SKILL.md`)— 智能体可调用的流程单元
  - **agent 定义**(`.claude/agents/X.md`)— 角色 prompt 模板
  - **hook 脚本**(`.claude/hooks/X.sh`)— commit/Stop 时机械执法
  - **5 产物文档** — 工作沉淀与汇报
  - **Why**:**机械执法不靠自觉**(治理规则不能依赖 AI 自律 — harness 三大缺陷之首"治理文本缺执法层"的根本约束)+ 智能体友好(可直接调用)+ 角色分离物理实现 + 文档汇报构成审查轨迹

### 双轴对照(每条原理服务哪端)

| 原理 | 让弱者高于平均线 | 让强者更强 |
|---|---|---|
| 1.1 / 1.2 二公设 | 框架强制约束 | 突破内省盲点 |
| 2.1 实现-审查分离 | 框架强制 fork | 突破公设 1 |
| 2.2 扁平多挑战者架构 | 平台约束都一样 | 同左 |
| 3.1 前期 + 最后验收 | 保两端不漏 | 中间放手提效 |
| 3.2 文档先行 | **核心** | 自然遵守 |
| 3.3 边做边提升 | 防抄别人 roadmap | **核心** — 防预设大计划 |
| 3.4 问题完美定义 > 解决 | **核心** — 强迫定义不凭直觉跳修 | 跨项目复用诊断模式 |
| 3.5 真正理解意图 > 字面执行 | **核心** — 框架强迫深挖防 AI 自由发挥 | 校准自己的表达缺陷 |
| 4.1 智能体友好文档 | 入口清晰好上手 | cross-ref 复用经验 |
| 4.2 综合阶段中性化 | 框架强制中立 | 防自己 anchoring |
| 4.3 改动范围自动识别 | 不靠新手懂 | 防"我懂的不用审" |
| 4.4 人-智能体协作契约 | scaffolding | 跨项目复用界面 |
| 4.5 挑战者导览体系 | 挑战者也有上手地图 | 自取用户原话防 framing 盲点 |
| 4.6 主动调研 | 框架提示按需查,别闭门造车 | 补内向盲点,经思考用证据不照搬 |
| 5.1-5.5 反模式 5 条 | 框架避坑 | 突破自我合理化 |
| 6.1 实战测试 | 不在沙盒假训练 | 真实问题更精准 |
| 7.1 实现载体 | **核心** — 物理基础 | **核心** — 可直接调用 |

### 与现有文档的关系

- `CLAUDE.md` §1 — 二公设(1.1 + 1.2)及反向规则
- `docs/governance/*.md` — 各阶段具体规则(本理念落地为可执行流程)
- `memory/feedback_*.md` — 反模式 5 条的用户原始校准
- `docs/decision-trail.md` — 跨 session 拐点流水
- `.claude/{agents,skills,hooks}/` — 7.1 实现载体的物理形态

---

## 核心能力

- **多智能体治理** — 设计/审查/评估/安全/审计各由独立 agent team 执行，对抗-决策分离
- **RUBRIC 驱动方向** — 项目评分标准贯穿全生命周期，渐进式从用户反馈积累
- **文档先行** — 新建先文档再代码，变更先改文档再改代码
- **流程审计** — 每次功能完成后自动审计流程遵从度，记录到 `docs/audits/`
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
│   ├── agents/              ← 5 个领审员 + research-scout(调研编排说明)
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

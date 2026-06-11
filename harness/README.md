# AI Dev Harness

Superpowers 管"怎么写好代码"。AI Dev Harness 管"按什么标准写、方向对不对、文档怎么流转、人在哪里介入"。

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
- **1.2 行动公设** — 不确定时执行外部动作(Grep/Read/WebFetch),不内省。**实现**:`session-init.sh` hook(开头注入历史)+ 不确定时调度者直接 Grep/Read(行动公设本体)

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
- **分层活上下文链(下游)** — `docs/context/` L1-L6 脊柱(对应 brainstorming→testing 阶段;松紧梯度:L1/L2 可探索"待定"合法,L3 对抗审查上场转严,L5/L6 最严)。每节 frontmatter `upstream: [编码]` 机读挂链(指编码不 grep)。**Why**:把跨会话上下文从"散文交叉引用"升级为"机读分层图",改上游可机械追下游,`待定` 是章法、静默断链是垃圾。**实现**:`docs/context/`(L1-vision/L2-INDEX 默认单表,L3-L6 随开发长)+ `check-context-chain.sh`(软早提醒)+ `finishing-rules.md`「收口硬核链」(AI 核 + handoff 声明)。注:这是 4.1 之外的新机制,**不计入上面"5 产物"**;harness 自仓库不建 context/(用 README 当 vision)。
- **4.2 综合阶段中性化** — 调度者构造挑战者 prompt 必须中立(材料/排序/措辞);综合按 RUBRIC 维度评判。**Why**:防 anchoring,多智能体审查的有效性前提。**实现**:`docs/governance/synthesis-rules.md` 完整规范
- **4.3 改动范围自动识别** — governance 改动 glob 机械触发 meta-review。**Why**:不靠 AI 自觉,机械触发不可被自我说服绕过。**实现**:`CLAUDE.md` §3-§4 + `.claude/hooks/meta-scope.conf` + `check-meta-*.sh` 系列 hook
- **4.4 人-智能体协作契约**(skill 输出契约)— 每个 skill 统一定义 输入/阶段/输出/反模式/自检。**Why**:可预期(智能体知道什么阶段给什么)+ 可中断恢复(handoff + skill 阶段标识 = 续接锚点)+ 智能体友好(不依赖人在旁边凭感觉指导)。**实现**:7 个 SKILL.md 统一结构
- **4.5 挑战者导览体系**(挑战者侧基础设施)— 主智能体(调度者)进项目时读 `CLAUDE.md` 知道项目结构 / Skill 地图 / 文档索引;挑战者(fork 出的子智能体)对称地需要一份"挑战者侧导览" — 知道:怎么找问题(方法论 — 通用自检清单 + 角色专属技巧)/ 去哪找信息(数据来源向导 — 跨平台路径 + 命令模板)/ 怎么看调度者输入(批判看 + 自取用户原话校验主线 framing)/ 哪些陷阱要避(公设 1 / spec_gap_masking / framing / 越权)。**实现**:`docs/references/challenger-orientation.md`。fork 挑战者时 prompt 内含"先 Read 此文件";挑战者输出末尾必填 `### 已对照用户原话` section,调度者综合时校验(`synthesis-rules.md` 事后规则 5)
- **4.6 主动调研 / 重视外部输入** — harness 默认"内向"(搜本仓库 + 问用户);本能力补上"从仓库外获取新信息作决策输入"的链路。规划方案时,需求定了、讨论方案前,**按需**(可逆性主轴 × 熟悉度次轴,默认跳过)fork 联网调研员,默认用 Claude Code 自带的 deep-research 调研业界方案。**Why**:别让 AI 闭门造车;但联网有成本且无差别检索会降质,所以按需触发。**红线**:调研结果只当**证据 / 选项**(经自己思考判断是否适用),不当判断依据——"别人这么做不单独构成理由"。**实现**:`.claude/agents/research-scout.md`(调研编排 + 红线契约)+ `brainstorming-rules.md` 阶段四前触发节

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

## 前置依赖

安装 [Superpowers](https://github.com/obra/superpowers) 插件：

```
/plugin install superpowers@claude-plugins-official
```

## 安装

```bash
./setup.sh /path/to/your-project
```

然后启动 Claude Code，配置向导会自动引导你完成项目配置：

```bash
cd /path/to/your-project
claude
# AI 检测到配置未完成，自动提示运行 /project-setup
# 通过 5 个问题的对话，自动生成 CLAUDE.md、RUBRIC.md、ARCHITECTURE.md
```

## 架构

```
Superpowers（插件，自动编排开发流程）
    brainstorming ← 需求深挖
        → 系统设计 ← 逐节自检 + design-review 多智能体审查
            → writing-plans ← 基于设计文档 + 遵守 ARCHITECTURE.md
                → subagent-driven-development ← TDD + code-review
                    → finishing-a-development-branch
                        │
                        ▼
AI Dev Harness（项目治理层）
                        ├── /security-scan → 安全扫描
                        ├── /evaluate → 方向评估（对抗式，通过/精磨/推翻）
                        ├── /process-audit → 流程审计（记录到 docs/audits/）
                        ├── /structured-handoff → 交接归档
                        ├── milestone commit + PROGRESS.md
                        └── 下一个功能 → Superpowers 继续
```

CLAUDE.md 中的治理规则优先级高于 Superpowers 的默认行为。
Superpowers 自动编排开发流程，我们通过规则注入来约束每个阶段的行为。

## 我们做什么，Superpowers 做什么

| 职责 | 谁做 |
|------|------|
| 需求讨论 | Superpowers brainstorming |
| 生成实现计划 | Superpowers writing-plans |
| 写代码 | Superpowers subagent-driven-development |
| TDD | Superpowers test-driven-development |
| 代码审查 | Superpowers requesting-code-review |
| Git 分支管理 | Superpowers using-git-worktrees |
| **项目评分标准** | **AI Dev Harness — RUBRIC.md** |
| **架构约束** | **AI Dev Harness — ARCHITECTURE.md** |
| **方向评估（精磨/推翻）** | **AI Dev Harness — evaluate（自动触发）** |
| **提交前安全扫描** | **AI Dev Harness — security-scan** |
| **结构化交接 + 归档** | **AI Dev Harness — structured-handoff** |
| **业界方案调研（按需,默认跳过）** | **AI Dev Harness — research-scout（规划方案时按需 fork,联网搜业界方案当选项输入）** |
| **文档生命周期** | **AI Dev Harness — handoff, PROGRESS, 归档** |
| **上下文重置** | **AI Dev Harness — handoff + SessionStart hook** |
| **模块文档维护** | **AI Dev Harness — MODULE_DOC_TEMPLATE** |
| **漂移检测** | **AI Dev Harness — evaluator slop 检测** |
| **流程审计** | **AI Dev Harness — process-audit（自动触发）** |
| **人的介入点** | **AI Dev Harness — 推翻/架构/标准决策** |

## 目录结构

```
项目/
├── CLAUDE.md                            # 纯索引（≤50 行）
├── .claude/
│   ├── settings.json                    # Hooks 配置
│   ├── agents/
│   │   ├── designer.md                  # 系统设计师（自检由调度者另 fork 挑战者）
│   │   ├── design-reviewer.md           # 设计审查领审员（4 并行子智能体）
│   │   ├── evaluator.md                 # 方向评估领审员（对抗式，3+1 并行子智能体）
│   │   ├── security-reviewer.md         # 安全扫描领审员（3 并行子智能体）
│   │   ├── process-auditor.md           # 流程审计领审员（1 子智能体）
│   │   └── research-scout.md            # 方案调研编排说明（按需 fork,默认跳过；非领审员）
│   ├── skills/
│   │   ├── project-setup/SKILL.md        # 对话式项目配置向导
│   │   ├── system-design/SKILL.md       # 系统设计（fork designer）
│   │   ├── design-review/SKILL.md       # 设计审查（fork reviewer team）
│   │   ├── evaluate/SKILL.md            # 方向评估（auto fork evaluator team）
│   │   ├── security-scan/SKILL.md       # 提交前安全扫描
│   │   ├── structured-handoff/SKILL.md  # 结构化交接 + 归档(覆写经晋升门禁:归档→清账→覆写→自查)
│   │   ├── structured-handoff/handoff-template.md  # 台账模板(单源:skill 注入/分发/初始台账同源)
│   │   └── process-audit/SKILL.md       # 流程审计（auto fork auditor）
│   └── hooks/
│       ├── check-module-docs.sh         # 代码改了就提醒更新模块 README
│       ├── session-init.sh              # 新会话注入上下文
│       ├── check-handoff.sh             # Stop 硬核晋升门禁(promotion 文法/锚点/登记交叉核)
│       ├── check-shelf-registry.sh      # 落库登记软扫(未登记点名,永不阻断)
│       ├── check-evidence-depth.sh      # finishing 检查 Evidence Depth/CI 阻断字段
│       └── check-context-chain.sh        # docs/context/ 活链软提醒(断链/方向违法,只警告)
├── docs/
│   ├── RUBRIC.md                        # ⭐ 评分标准（方向盘）
│   ├── ARCHITECTURE.md                  # 分层规则
│   ├── PROGRESS.md                      # 里程碑时间线
│   ├── governance/                      # 治理规则（按阶段拆分）
│   │   ├── brainstorming-rules.md       # 需求对接时读
│   │   ├── design-rules.md              # 系统设计时读
│   │   ├── planning-rules.md            # writing-plans 时读
│   │   ├── implementation-rules.md      # 子代理执行时读
│   │   ├── testing-rules.md             # 子代理执行时读（测试）
│   │   ├── review-rules.md              # code-review 时读
│   │   └── finishing-rules.md           # 分支收尾时读
│   ├── active/
│   │   ├── handoff.md                   # 交接文档
│   │   └── evaluation-result.md         # 方向评估结果
│   ├── product-specs/index.md           # 功能索引
│   ├── context/                        # 分层活上下文链（L1-L6，编码 + upstream，下游）
│   ├── decisions/                       # 架构决策
│   ├── references/                      # 内部知识（含多智能体审查指南）
│   ├── audits/                          # 流程审计报告（自动积累）
│   └── completed/                       # 归档
└── (Superpowers 作为插件自动加载，产出到 docs/superpowers/)
```

## 工作流程

1. 描述你想做的东西 → brainstorming（受 RUBRIC 约束）
2. 确认设计 → writing-plans（遵守 ARCHITECTURE）
3. 确认计划 → subagent-driven-development（TDD + review）
4. 功能完成 → finishing-a-development-branch
5. **security-scan** → 扫描代码安全问题（Critical 阻塞，High/Medium 警告）
6. **evaluate 自动触发** → 对抗式方向评估（挑战者找问题 → 领审员做决策）
7. **process-audit 自动触发** → 流程审计（遵从度 → 记录到 docs/audits/）
8. 通过 → milestone commit + structured-handoff 归档 → 合并 → 下一个功能
9. 精磨 → structured-handoff 记录进度 → 返回迭代 → 重新 finishing
10. 推翻 → structured-handoff 记录状态 → 停下来找用户 → 重新 brainstorming

**整个流程全自动。** 用户只在需求确认和推翻决策时介入。

上下文快满时 → 更新 handoff.md → `/clear` → 新会话自动加载

## 可选：接入 OpenAI Codex（多模型成本路由）

> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`);若日后激活 codex 接入,先读 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `docs/decision-trail.md` 2026-05-24 拐点回溯本搁置背景。下方 swap 列表 + 不 Swap 列表 + 决策表入口保留作完整参考。

部分 sub-agent 角色可 swap 到 codex（Claude 同等能力比 codex 贵 → 成本节省）。

- **Swap 列表**(11 角色,2026-05-22 修订):
  - 实现链路:designer / **planner** / **implementer** / **testing**
  - 审查链路:silent-failure-hunter / 设计自检 / design-review 4 挑战者 / **code-reviewer** / evaluate 非关键 / security-scan 危险+注入
- **不 Swap**:调度者 / evaluate 关键 / security-scan 凭证 / meta-review / process-audit / 综合阶段
- **完整决策表 + sandbox/approval/model/effort**：[`docs/governance/model-route.md`](docs/governance/model-route.md)
- **综合阶段规则**（防多 Agent 旁观者效应）：[`docs/governance/synthesis-rules.md`](docs/governance/synthesis-rules.md)
- **理论锚点**（二公设）：见 `CLAUDE.md` §角色分离原则 段后的 blockquote

安装步骤详见根目录 `README.md`。

## 十条设计原则

### 一、根基性原则

**1. 文档第一公民** — 新建时先有文档再写代码，变更时先改文档再改代码。适用于设计文档、类型契约、模块 README、ARCHITECTURE。区别只在文档的厚度，不在有没有。

**2. 角色分离** — 做事的和判断的分开，设计的和审查的分开。调度者只编排不执行，设计/审查/扫描/评估各由独立 agent（context: fork）执行。一个角色可以是单个 agent 或一个 agent team。

**3. RUBRIC 驱动方向** — RUBRIC.md 是方向盘，不只是评判工具。它指导 brainstorming 的方案讨论、设计的决策取舍、实现的代码风格、code review 的检查标准、evaluate 的评分依据。标准在开发中从用户反馈持续积累。

**4. 确定性优先** — hooks 强制执行关键规则，不靠 AI 自觉。能机械验证的不靠文字指令，能阻断的不靠提醒。

**5. 人做 AI 做不好的事** — 定标准（RUBRIC）、做推翻决策、做架构决策、确认需求清单。AI 提供分析和推荐方案，人做最终选择。

### 二、需求层原则

**6. 需求深挖与收敛** — 不在用户说完第一句话后就开始设计。四维识别（模糊/缺失/冲突/隐含假设）逐个向用户确认。收敛标准：每个场景能写出"谁→做什么→系统做什么→看到什么"。3 轮确认上限防止无限循环。

### 三、设计层原则

**7. 设计自洽与逐节自检** — 设计文档逐节推进，每节写完立即自检，不通过原地修。全局 10 条交叉验证确保需求↔模块↔接口↔数据↔边界↔架构↔决策↔契约全部对齐。前后端共享同一份类型契约，先改契约再改代码。

### 四、审查层原则

**8. 对抗-决策分离审查** — 子智能体是对抗者（找问题附证据），领审员是决策者（从问题清单推导评分和决策）。找问题的和做判断的分开。同一问题被多个子智能体独立发现则严重性升级，子智能体间矛盾标注为分歧待判。参照 `docs/references/multi-agent-review-guide.md`。

### 五、知识层原则

**9. 文档有生有死** — active/ 放当前状态，完成就归档到 completed/。设计文档完成标注 ARCHIVED，取消标注 CANCELLED。交接文档具体优于概括（用函数名定位，不用行号），80 行上限。经验提取须满足三标准（项目特定+可复用+可操作），无模式时不强行提取。

### 六、回退原则

**10. 回退到问题该解决的阶段** — 需求缺陷回 brainstorming，设计缺陷回系统设计，代码 bug 原地修。回退保留产物（设计文档标注待修订，代码保留在分支）。fork 失败时调度者降级执行但标注"未经独立 agent 验证"，下次会话须由独立 agent 重新验证。

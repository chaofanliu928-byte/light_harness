# Roadmap

下一阶段的工作方向。每项都是开放方向,具体需求和验收标准待进一步 brainstorming 收敛。

> 与 PROGRESS.md 的区别:PROGRESS.md 是已完成里程碑(只追加),ROADMAP.md 是未完成规划(会重写)。
> 与 decisions/ 的区别:decisions 记录"为什么这么决定 + 替代方案",ROADMAP 记录"下一阶段做什么"。scope 级变更先写 decision,再改 ROADMAP。

> 2026-04-15 重排:测试覆盖进入 scope(详见 `docs/decisions/2026-04-15-testing-scope-expansion.md`),原 ROADMAP 1/2/3 的顺序调整。本次重排经过 5 对抗者审查 + 领审员综合(见 decision 文档)。

> 2026-04-17 重排:**承认 harness self-governance 缺口**(详见 `docs/decisions/2026-04-17-harness-self-governance-gap.md`),新增 P0.9 先于 P1。原 M0-M4(本会话拟做的 5 条治理修改)推迟为 P0.9 就绪后的首个使用批次。本次承认经过 4 挑战者扁平 fork 元审查 + 领审员综合(见 decision 文档)。

---

## P-1:Handoff residual 字段清晰化(独立小改,可即刻合入)

现有 `docs/active/handoff.md` 的"已知问题"字段易被理解成 bug 列表。扩展内涵为 residual:bug / 故意暂缓的优化 / 待外部决策 / 测试文档缺口。

- 改动:字段加一行注释说明,或改名为"已知问题 / Residual"
- 代价:极小(1 行),零依赖
- 依据:structured-handoff 是跨 session 交接的核心;residual 显性化让下一轮 agent 更快接上

---

## P0:测试覆盖纳入 harness(L1 + L2 + L3)

对齐 `docs/decisions/2026-04-15-testing-scope-expansion.md` 方案 B。

### 现状(事实层,已核查)

测试治理**散落但非真空**:
- `docs/governance/design-rules.md` 有"第 6 节:测试策略"(验收条目)
- `docs/governance/planning-rules.md` 有"测试计划"节(层级 + mock 策略)
- `docs/RUBRIC.md` "代码质量"维度的 10 分档提了"测试覆盖"
- CLAUDE.md 核心规则 6 要求 lint/类型检查 hook
- TDD 委托给 `superpowers:test-driven-development`

**缺口**:
- RUBRIC 无独立"测试充分性"维度
- 无专用 testing-rules / testing-standard 聚合治理
- 无测试相关 skill / hook(lint hook 不算测试)
- Evidence Depth 概念缺失——无法在 finishing 时显式回答"验证到第几层"

scope 是**整合 + 升级**,不是**从零起步**。

### 内部执行顺序:L2 → L1 → L3(严格串行)

#### L2 先做:治理层(定义 Evidence Depth 语言的场所)

- 新增 `docs/governance/testing-rules.md`:什么时候必须写测试、颗粒度、契约任务 vs 实现任务的区别
- 新增 `docs/references/testing-standard.md`:定义 Evidence Depth L1-L4 + CI 阻断 的语义(**术语提案,待用户确认**;草案参考 `D:/个人/coding-agent-harness/references/regression-system.md`,但最终语义由用户定)
- CLAUDE.md "治理规则"表加一行:`implementation 阶段 → 先读 testing-rules.md`
- `implementation-rules.md` / `review-rules.md` 引用新文件
- `setup.sh` 复制新文件到目标项目

**为什么先做 L2**:L1 的评分档位用"L1 tests / L2 local_smoke..."语言,定义在 L2 的 testing-standard.md 里;不先做 L2,L1 的档位指向空值。

#### L1 再做:评估层

- RUBRIC.md 增加"测试充分性"独立维度
- **前置**:RUBRIC 的权重表(当前 6 维度 100%)需结构升级,允许维度变长 + 档位非分数制
- 档位用 L2 已定义的 Evidence Depth 语言
- evaluator agent 对抗者池增加"测试充分性挑战者",负责内容质量判断

**为什么在 L2 之后**:档位语言依赖 L2 的术语定义;RUBRIC 结构升级是隐藏前置,不能绕开

#### L3 最后做:声明层(子决策 B1-b 最小版)

- `finishing-rules.md` 加"Evidence Depth 声明"步骤
- `structured-handoff` 模板加显性字段 `## Evidence Depth`
- **新增 hook**:finishing 前检查 handoff 里 `## Evidence Depth` 字段非空,字段为空阻断(**只检字段存在,不检内容质量**——内容质量归 L1 的 evaluator)
- 声明不符证据时 evaluator 报告给用户,由用户决定是否打回(**不单方面打回**,符合 F2 不越权)

**为什么在 L1 之后**:判断"声明是否符证据"依赖 L1 的档位规则

### 不做 L4

L4(Regression SSoT + Cadence Ledger 进模板)价值依赖"≥3 个 surface"场景,当前无事实支撑。L2 治理文件里写一句引导语即可:"项目到多 surface 时考虑引入 Regression SSoT,参考...(当前不做)"。

### 验收信号

- 一次真实 finishing 的 handoff 能显式回答"验证到第几层、证据是什么"
- hook 能在字段缺失时阻断
- evaluator 能针对测试维度给出内容质量判断(不是自动打回,是报告给用户)
- L1-L4 + CI 阻断 语义已由用户确认(或由用户基于草案修订)

---

## P0.5:fork 嵌套扁平化改造(P1 验证暴露,必须前置)

**背景**:P1 在目标项目 `D:\项目\智能体-生图` 验证发现,harness 的两级 fork 实际失效——被 fork 的领审员没有 Agent 工具权限,不能再 fork 子对抗者。结果所有"对抗-决策分离"退化为单 context 自问自答。

详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

**改造范围**:
- 5 个 skill:evaluate / design-review / security-scan / process-audit / system-design
- 5 个 agent:evaluator / design-reviewer / security-reviewer / process-auditor / designer
- 核心改动:skill 的 `context: fork` 去掉,改在主对话执行;主对话并行 fork N 个挑战者(扁平结构)

**为什么前置于 P1**:
- 不改的话,P1 的 evaluator "测试充分性挑战者"仍会退化为自问自答
- P0 的核心能力(对抗式方向评估 + 测试维度独立打分)需要真 fork 才有效
- 本次会话的 5 对抗者审查已经验证扁平 fork 模式可行

**验收信号**:
- 一次 evaluate 能真正 fork 出 4 个独立 context 的挑战者
- design-review、security-scan、process-audit 同样改造完成
- system-design 的 designer 和自检逻辑改为扁平

---

## P0.9:harness self-governance(根源级,先于 P1)

**背景**:2026-04-17 接收目标项目 `D:\项目\智能体-生图` 老版本审查报告,起草 5 条治理修改 M0-M4 并做 4 挑战者元审查后,识别出 harness 反复打补丁的**根源**——不是单条规则漏洞,而是三条结构性缺陷:

1. **治理文本,缺执法层**——硬强制 hook 只覆盖"字段非空"和"代码 format",涉及流程决策的规则全部落在 agent 自律
2. **bootstrap 缺陷**——harness 治理 feature 层,但 meta 层(harness 自身改动)没有治理
3. **马鞍定位错位**——harness 应有比 feature 更高的稳定性标准,实际比 feature 还松

详见 `docs/decisions/2026-04-17-harness-self-governance-gap.md`。

**P0.9 的目标**:为 harness 自身建立 self-governance 机制。具体需求和验收标准**待 brainstorming 收敛**,本 ROADMAP 不预设方案。

### 可能的方向(非既定,brainstorming 时再决定)

- meta finishing 规范(feature 层 finishing 的 meta 变种)
- hook 执法层扩充(milestone commit pre-commit / SessionStart 按阶段注入 governance / structured-handoff 强制触发等)
- self-reference 检查机制(新规则是否被自己违反)
- 治理一致性审计(断链检查 / 影响传导同步,如 RUBRIC → decisions 5.2/5.6 那种悬空引用)
- decision 模板的 meta-level 子类型
- 本会话 4 挑战者扁平 fork 元审查 → 抽象为可复用的 meta-review 流程

### 验收信号(初步)

- harness 任何 meta 改动有明确的 finishing 路径(不再 ad-hoc)
- 涉及流程决策的硬强制 hook 至少新增 1 条
- 本会话推迟的 M0-M4 能在 P0.9 规范下走完整流程,作为**首个使用批次**

### 为什么 P0.9 先于 P1

- P1 是真实项目验证,但若 P1 的 finishing 仍套在 ad-hoc meta 规范下,P1 反哺的数据无法明确归因(到底是 harness 规则有问题,还是 meta 流程有问题)
- P0.9 就绪后,P1 才能用稳定的 harness 跑闭环

### 与之前 P 项的关系

- **P-1 / P0 / P0.5 已完成项保持不变**——本 decision 不追溯推翻它们,只是承认它们都在 ad-hoc meta 状态下完成,稳定性未经 self-governance 验证
- **M0-M4 推迟**——不在本轮 commit。P0.9 建立后作为首个使用批次执行
- 推迟期间,M0-M4 的草案保留在本会话归档(`handoff` 历史 + 4 挑战者审查记录),P0.9 启动时复用

### 🟢 P0.9.1:meta-review 流程 + scope 识别 + hook 执法(2026-04-28 完成)

- spec:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`(2178 行 / 22 决策 / 20 模块)
- plan:`docs/superpowers/plans/2026-04-26-p0-9-1-self-governance-plan.md`(1293 行 / 38 任务 / 8 batch)
- 落地:29 commits(`6e8bda1..34129ae`),34 文件 +9093 行
- 测试:T10 / T4 / T8 自动化通过(T1-T3 / T5-T9 / T11 spec §6.3 授权延迟,T11 已通过本次 finishing 自然闭合 bootstrap loop)
- meta-review audit:`docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`(verdict=pass after revision)
- 修订 decision:`docs/decisions/2026-04-28-p0-9-1-meta-review-revision.md`(D9 范式,5 子项)
- **首个 P0.9.2 诊断输入数据点**:本 audit 即 scope §1.2 场景 4 的 P0.9.2 诊断数据 第 1 条

**未完成项**(推 P0.9.1.5 / P0.9.2 / P0.9.3):
- M3 hook 不可见缺口(spec §1.3 fix-9 (vii) 已 acceptance,推 P0.9.3 governance 漂移检测)
- D5 / D.2 字节软上限 enforcement(自律,推 P0.9.2)
- 反审字段重置 enforcement(自律,推 P0.9.2)
- mixed scope 双 finishing 成本量化(实战 1-2 月观察,推 P0.9.2)

**P0.9.1.5 启动条件**(D20 fix-7 = B):用户在 M0-M4 之一启动前决定;无机械触发

---

## P1:现有项目迁移到 harness(原 ROADMAP 2)

P0 + P0.5 完成后启动。把已有真实项目套上 harness,跑完整 brainstorming → design → plan → implement → finishing 闭环。

- 待定:目标项目
- 验收信号:完整闭环跑通,process-audit 产出报告,Evidence Depth 在 handoff 里显式出现
- 预期产出:暴露不适配点反哺 P2 的 ROADMAP 1 / 3 / L4

### P0 → P1 的依赖说明(补充)

P0 先于 P1 的理由**只成立一半**:P0 产物(testing-rules / Evidence Depth 字段)本身也需要 P1 真实验证才知道是否有效。单向依赖是假命题。

折中方案:**P0 完成 L2 + L1 的最小切片**(testing-rules 骨架 + RUBRIC 加维度但档位先粗略) → 启动 P1 一轮 finishing → 回来细化 L3 和 L1 档位。若 P1 暴露 L1 档位不合理,回到 P0 修订。

---

## P2:等 P1 产出真实数据后再定

### 可观测性 — 双层(2026-04-28 立 + 同日 reframe glassbox 角色)

让 harness 治理过程可见、可审计、可回溯。**空间 + 时间双层**,但两层归属不同:

**空间维度(session 内)— glassbox(用户级外部工具,harness 推荐不分发)**
- 现状:外部仓库 https://github.com/chaofanliu928-byte/glassbox(7 类 HTML 页面 + lint 工具)
- **harness 角色**:仅推荐 + 记录链接(`docs/references/recommended-tools.md`)+ setup.sh 末尾 echo 提示;**不**做 submodule / 不 clone / 不锁版本 / 不集成 API
- **用户角色**:自行决定装哪、装啥版本、装在哪(建议 `~/tools/glassbox/` 等全局位置,不与项目绑定);glassbox 是用户工具,harness 之外也可用
- **harness 治理流程不依赖 glassbox 在场**(不装也能正常工作)
- decision:`docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md`

**时间维度(跨 session)— decision-trail(项目内置)**
- 已落地:`docs/decision-trail.md`(2026-04-28 引入,scope=none)
- 自动化:M5 `docs/governance/finishing-rules.md` "通过" Step 2 + M1 `docs/governance/meta-finishing-rules.md` Step D 双路径 append
- decision:`docs/decisions/2026-04-28-decision-trail-introduction.md`

**验收信号**:
- 能回答"当前抉择的历史背景是什么"(decision-trail 链回溯)
- 能回答"上一次 design-review / meta-review 为什么打这个 verdict"(audit + decision-trail 索引)
- 用户视角:harness 推荐 → 用户装 glassbox(可选)→ AI 工作 session 内可视化产出可看
- decision-trail 在 P1 真实项目至少跑 1 次,append 频率 + 提取质量 met meta-L4

**就绪信号**:
- decision-trail meta-L4 验证:1-2 月观察 finishing append 是否真发生 / 提取质量
- glassbox 链接保鲜:每次 P0.9.x 落地或 P1 启动时复核 URL 有效性

### L4 回归层(条件启用)

如果 P1 或后续项目出现 ≥3 个 surface 的场景,再考虑引入 Regression SSoT + Cadence Ledger。默认不做。

- **就绪信号**:多 surface 项目出现,P1 单项目可能完全不触发
- 触发时同步决策:是否补 surface 清单(子决策 B3 暂不做的那部分)

---

## 建议不做(可讨论,非既定)

以下四项经 5 对抗者审查后保留"不做"倾向,但 AI 不越权划死边界——每条都有反方论据,列出来供未来翻案判断:

| 事项 | 不做理由 | 反方论据(领审员综合) | 翻案信号 |
|---|---|---|---|
| 双轨 SSoT 参考文档 | 等 L4 触发再补,避免空中楼阁 | "循环依赖":没文档用户不知道何时该建 SSoT | 首次 L4 真实项目出现时重评 |
| 完整 11 Phase Onboarding Audit | 已有 `project-setup` 部分等价 | project-setup 实际只覆盖 Phase 1-4 一部分,Phase 7(关键 surface)/8/9/10/11 完全缺失 | L4 触发时 surface 清单需求出现时 |
| Task-Type Reading Matrix 进 harness 模板 | 流程轴 Matrix 已足够 | 现有 planning-rules 已暗中按"契约/实现"二分,任务类型差异已存在只是没抽出 | 发现治理文件多处重复按任务类型分支时 |
| Planning 三件套(task_plan/findings/progress)进模板 | 和 structured-handoff 同类型,当前单任务模式够用 | findings.md 当前无对应物,research 产物一 `/clear` 就丢(P0 的 B2-b 部分补了 handoff 的 `## 研究发现` 字段,作为最小补丁) | 跨 ≥3 session 任务或多并行子任务出现时 |

---

## ROADMAP 自身的生命周期(元规则)

- **完成的 P 项** → 迁移到 `PROGRESS.md`(只追加)
- **决策记录** → 存在 `docs/decisions/`(不和 ROADMAP 混写)
- **ROADMAP 自身保持滚动**:P 项完成、抛弃、合并都会让 ROADMAP 重写,每次重写前先写对应 decision
- 每次 scope 级变更(比如本次"测试进 scope"),**先写 decision 再改 ROADMAP**,不得反向

---

## 排期逻辑

- P-1 是独立小改,无依赖可即刻合入(已完成)
- P0 两项是 scope 定义层面的缺口,内部严格串行 L2 → L1 → L3(已完成)
- P0.5 是 P1 验证暴露的应急修复(已完成)
- **P0.9 是根源级**,先于 P1。原因:harness 自身缺 self-governance,P1 套上去无法明确归因
- P1 是真实验证,**依赖 P0.9 就绪**——否则 P1 的 finishing 仍套在 ad-hoc meta 规范下
- P2 两项的就绪信号不同源(可观测性 P1 一轮即可,L4 需多 surface;skill 持久化已删除 — 用户 2026-04-28 否决,见 `feedback_skill_no_cross_project.md`)

所有"做或不做"的判断,只依据两类输入:
1. 已确认的事实(文件状态、scope 定义、设计哲学)
2. 纯逻辑推导(重复建设反模式、依赖链、价值随维度非线性变化)

**不接受**"多少百分比的项目需要"这种市场判断——harness 未在外部业务项目跑过,没有数据支持任何比例。

## 与 Superpowers 的耦合边界(盲区补救)

- L1 tests 档位的实际执行依赖 `superpowers:test-driven-development`
- L2 治理规则与 Superpowers TDD 流程互补,不替代
- **耦合风险**:Superpowers 升级若改 TDD skill 接口,L1 判定可能失效——P1 启动前,verify 兼容性
- 若出现不兼容,短期 fallback:evaluator 手动判断 tests 通过,不依赖 Superpowers 接口

## 术语与定义归属

- Evidence Depth L1-L4 + CI 阻断 语义在 `docs/references/testing-standard.md` 中定义(**术语 SSoT**)
- 其他引用该术语的文件(RUBRIC / finishing-rules / handoff 模板 / evaluator 提示词)**只引用不重复定义**
- 术语变更必须先改 testing-standard.md,再同步下游(F3 文档先行)

# 动态审查侦察(review-scout)系统设计

> 状态:第 2-9 节已填;**方向 Y(2026-06-13 用户拍板:ADD review-scout 并排,不替换现有 design-review)** 重对齐全文,取代原 X(诚实双路)。
> 规模:**重量级**(新增 workflow 脚本 + scout agent;最小改 design-review SKILL 加分支 / review-rules 加 scout 注 / setup.sh / credentials.conf+rules / QUICKREF+CLAUDE×2 最小注)。**Y 下 design-reviewer.md / synthesis-rules / design-rules 基本不改**(现有固定 4 维路原样保留作活备份)→ 必过审查(本 spec 自身走当前 design-review,见 A-5)。

---

## 1. 需求摘要

### 1.1 用户目标

把审查的"审哪些维度"从**查固定表**,改成**一个独立 agent 读完上下文(目的 / 决策 / 历史 / 代码 / 会话意图)之后现推**:钉一个最小地板兜底,其余按上下文动态加。先在**设计审查**上落地,机制设计成**三类(设计 / 代码 / 治理)通用**。

动机:现在设计审查永远固定 4 维(自洽性 / 完整性 / 合理性 / RUBRIC对齐),不管审什么都一样。而 `multi-agent-review-guide.md` 其实**已经主张**"维度由 agent 根据审查对象自行设计",治理面审查也**已经有**手工的"地板+天花板"(design-review SKILL 的 A/B/C 模板:A 推荐维度 / B 最低必选 = bootstrap 4 维地板 / C 定制理由)。本功能 = 把那一步**自动化(scout 来推)+ 隔离化(独立 fork,比调度者自己推更合公设1)+ 推广到三类**。

### 1.2 核心场景(按优先级排序)

> **方向 Y(2026-06-13 用户拍板,取代原 X/诚实双路)**:本功能 = **ADD review-scout 并排**,**不替换**现有 design-review。两条是**不同机制**:
> - **ultracode 开** → 跑 review-scout workflow(scout 现推维:地板 2 维 + 动态加)。**scout 特性 = ultracode 专属**(用户接受的取舍)。
> - **ultracode 关 / 非 Claude Code** → **现有 design-review 原样不动**(固定 4 维:自洽 / 完整 / 合理 / RUBRIC 对齐)。这是**仅在不能用 scout(ultracode 不在场)时才执行的显式回落路**——已存在、不新建、不归档;scout 是主推路。

1. **[P0] ultracode 在场:feature 设计审查走 scout**:调度者拿到设计文档要审,**且 Workflow/ultracode 可用** → 启动 review-scout workflow(传 `reviewType=design` + 指针 + 会话意图)→ scout agent 读方向盘 / 决策 / 历史 / 设计文档 → 产出 `{地板 2 维 + 动态加维(每条带证据)+ skipped 候选}` → workflow 一维一挑战者并行扇出 → 返回 plan + findings → 调度者按 `synthesis-rules.md` 综合判定(通过 / 需修复后重审)。
2. **[P0] scout 自适应"方向盘对齐"维**(scout 路内):scout 读 RUBRIC.md,检到已填(无 `[待定义]`/`[示例,请替换]` 等模板标记)→ 对齐 RUBRIC;检到是空模板(harness 自仓库)→ 回落对齐 CLAUDE.md 原则 + 二条公设。
3. **[P0] ultracode 不在场:走现有固定 4 维 design-review**:Workflow/ultracode 不可用 → design-review SKILL 分支到**现有固定 4 维流程,原样运行,不改一字**(活备份)。scout 的"动态推维"在此路不可得 = ultracode 专属取舍(D13)。
4. **[P1] 架构留口给代码 / 治理**(scout 路):workflow 入参 `reviewType` + 查地板表;代码 / 治理类型本轮**不接线**,但 schema / floor 表 / workflow 结构上支持随后增量加行即用。

### 1.3 边界与约束

**本轮做(方向 Y:ADD 并排,不替换)**:
- **新增 review-scout 路并排于现有 design-review**:ultracode 在场时 design-review SKILL 分支去调 review-scout workflow(scout 驱动:地板 2 维 = 方向盘对齐 + 自洽性 + 动态加维)。
- 新建 review-scout **workflow 脚本** + scout **agent 定义**;地板查表机制;`skipped_candidates` 强制留痕。
- **最小改动落点**:`design-review` SKILL(执行开头加运行时分支)、`review-rules.md`(设计行**新增** scout 注,不改现有 4 维)、`setup.sh`(分发 workflows)、`credentials.conf`+`credentials-rules §2`(加 workflows glob)、QUICKREF/CLAUDE.md×2(最小注)。

> **维度命名 alias(🔴-1 据实记录)**:现有 design-review 的第 3 维,**执行层**(`design-reviewer.md` L198「过度工程化挑战者」/ SKILL L26「过度工程化」)叫 **过度工程化**,**治理/入口层**(`review-rules.md` 设计行 / `synthesis-rules.md` / `CLAUDE.md` 角色表)叫 **合理性**。这是**仓库既有命名不一致**(旧账)。**本 spec 描述复用源 / 活备份内容 / scout 候选菜单时一律据实用执行层名「过度工程化」**;repo-wide 统一此 alias **不在本 feature scope**(只标注,留作未来 cleanup 候选)。

**不做(明确排除 — Y 下触点风险大幅缩小)**:
- **不替换、不改现有固定 4 维 design-review 路**:它原样保留作活备份(已存在、不新建、不归档)。`agents/design-reviewer.md` **不改**(其整块 4 维 prompt 服务非 ultracode 路;**scout 路与它零关系——不读/不抄/不镜像**,scout 挑战者 prompt 100% scout 路自有、floor/已知维 focus 住 workflow.js 常量 — 🔴 第 3 轮根治 / §3.3);`synthesis-rules.md` **L113/L151 维序不改**(服务现有 4 维路),**适用范围四处 ADD scout 行**(主表/L99/L169/L3,活规则义务 — §8.4)。
- **不做"4 维 → 2 维全仓同步"**:D1 地板 2 维**只作用 scout(ultracode)路**;非 ultracode 路仍固定 4 维。整件"全仓改 4 维"的事在 Y 下**消失**。
- **不**做代码审查、治理审查**实际接线**(🟡-5 补"不"字;只留架构口,随后增量)。代码审查**永远审、无"不审"门**;其 scout-vs-地板的门留到扩展时定,本轮不预设。
- **不动 D7 / 治理 bootstrap-4 维**(核心原则合规 / 目的达成度 / 副作用 / scope漂移,禁删)。
- **不动 governance 面 A/B/C 设计审查那条路径**(它已是手工 floor+ceiling 且涉 D7,归"治理"类、随后再接 scout)。
- **不动轻量级路径**:轻量级本来就不跑 design-review,故"轻量跳过 scout"在设计审查里 = 维持现状不审。

**兼容性要求**:
- A 方案(workflow 脚本)依赖 Workflow 工具(ultracode 运行时,逐会话 opt-in)→ 下游分发 + 跨运行时(Codex 等)拿不到 scout 路;**ultracode 不在场时回落现有 design-review**(非降级,是另一条已存在的活路 — 见 §A-4)。

### 1.4 关联需求

- **依赖**:已完成的**治理同层化**(2026-06-13)——A/B/C 现为单层统一机制,scout 自动化的就是它;上下游同一套治理与凭证义务。
- **被依赖**:未来代码审查、治理审查接 scout 走同一 workflow(同 reviewType 机制)。

### 1.5 已确认的决策(从需求对接阶段带入)

- **D1 地板大小(Y 改)**:**scout(ultracode)路** 设计地板 = 方向盘对齐 + 自洽性(2 维);完整性 / 过度工程化(执行层实际名 🔴-1)降级为"标准候选"(scout 每次必考虑,不加须写进 skipped)。**非 ultracode 路保持现有固定 4 维不变**(治理层维名:自洽 / 完整 / 合理 / RUBRIC 对齐)。即地板 2 维**只作用 scout 路**,不 shrink 全仓 4 维。
- **D2 N 不预设**:N = 地板维 + scout 动态加维,一维一挑战者。
- **D3 方向盘对齐自适应**:scout 读 RUBRIC,填了对齐 RUBRIC;空模板回落 CLAUDE.md 原则 + 二条公设。
- **D4 治理保 4 维、不动 D7**:三类地板各按各的——设计 = 方向盘+自洽性 / 代码 = 方向盘+简洁性(Superpowers 默认维仍在底下跑) / 治理 = bootstrap-4(锁死)。
- **D5 范围**:架构三类通用,交付先设计审查;代码 / 治理随后增量。
- **D6 集成载体**:A 方案 = Workflow 脚本(design-review 调用它)。理由:编排确定、结构上根治串行-fork bug(review-rules 实证踩过)、契合"用 workflow"、schema/floor 类型无关合"架构覆盖三类"。
- **D7-scope scout 是独立 fork**(合公设1:做事 / 判断分离);**skipped_candidates 强制留痕**(挡"便利答案掩盖规范缺口")。
- **D8 综合留在调度者**(对抗-决策分离 + synthesis-rules),workflow 只返回 plan + findings,不下判定。
- **D9 scout 输入**:调度者传指针(方向盘 / decisions / audits / 被审材料路径,按固定类目规则、非手挑)+ 会话意图(只能 args 传,守措辞中性);scout 用 Read/Grep 自读。
- **D10 轻量跳过判据**:复用 design-rules 规模判断表;只约束设计审查的 scout-vs-地板。
- **D11 novel 维挑战者 prompt**:对抗框固定(来自 multi-agent-review-guide:角色+数量+要证据+格式),scout 只供 `challenger_focus`;地板/已知维用现成模板;scout 加维须不与地板/候选重叠 + `why_this_time` 指证据。
- **D12 N 无硬上限**:不静默截断(plan 列全维+skipped);真实边界 = 透明 + 并发自动排队 + 1000-agent 兜底 + 调度者综合合并重叠。
- **D13 ADD 不替换(Y,用户 2026-06-13 拍板;2026-06-15 表述微调)**:review-scout 是 **ultracode 专属**的并排新路,**不替换**现有 design-review。**主次定调(2026-06-15)**:ultracode 在场时 **review-scout 是主推审查路**;现有固定 4 维 design-review **原样保留,作为 ultracode/Workflow 不在场时才执行的显式回落路**(已存在、不新建、不归档)。两路是不同机制(scout 现推维 vs 固定 4 维),非"同一 scout 两种跑法"。scout 动态推维拿不到 = 非 ultracode 环境的取舍,用户接受。**本次(2026-06-15)只调主次表述(scout 主推 / 老 4 维显式回落),不退役老路、不重建 X、架构与运行逻辑零改**——现 SKILL 分支本就是"ultracode 可用→scout / 不可用→老 4 维",仅措辞从"平级活备份/不标降级"改为"主推 + 显式回落"。**诚实**:非 ultracode 默认仍走老 4 维(这正是"不能用新功能才走旧能力")。**取代原 X(诚实双路:两路都 scout 驱动、扁平 fork 作 scout 路 B)。**
> **术语桥(2026-06-15)**:本文件后文(§1.6 奖励项 / §7.3 诚实边界 / §2.2 等)及其它工件(setup.sh / ROADMAP / PROGRESS / plans 等记录文件)沿用的「活备份」措辞 = 此「回落路」的旧称,语义相同(ultracode 不在场时执行、审查不缺失、不退役、不重建 X);**主次定调以本 D13 为准**(scout 主推 / 老 4 维显式回落)。记录/历史文件按 R12 不追溯改写;全量「活备份」→「回落」术语统一列为 ROADMAP 观察项(后续 cleanup)。

### 1.6 RUBRIC 风险标记(自仓库语境,代 RUBRIC = CLAUDE.md 原则 + 二条公设)

**惩罚项 / 风险**:
- **简洁性**:scout 路 workflow 脚本现仅 design-review 一个消费者 → 单用户编排件风险(碰"单次使用抽象")。应对方向:schema/floor 做成类型无关(reviewType 参数化),为 code/治理留口;设计须诚实标注增益边界(scout/workflow = ultracode 在场时确定性扇出 + 隔离,非"普适根治 bug")。
- **一致性**:scout 路偏离 harness 现状(全扁平 fork)→ 新增 workflow 载体;**Y 下风险缩小**:现有 design-review(skill + 扁平 fork)原样保留,scout 路是**并排 ADD**,不替换现状,共存清晰。
- **凭证义务(Y 下改动集缩小)**:命中 credentials.conf 的改动 = design-review SKILL(加分支)/ review-rules.md(加 scout 注)/ setup.sh / credentials.conf / credentials-rules.md / CLAUDE.md×2(最小注)→ **收口须 audit 凭证**。**design-reviewer.md / synthesis-rules.md / design-rules.md 几乎不改**(Y 取消了"4 维改 2 维"),凭证面随之缩小。
- **触点完整性(Y 下大幅缩小)**:**"4 维 → 2 维全仓同步"整件事消失**(D1 地板 2 维只作用 scout 路,非 ultracode 路保 4 维不变)。剩余触点 = "ADD scout 注"的最小集(design-review SKILL 分支 / review-rules 新增注 / QUICKREF/CLAUDE 最小注),§8.3 重新 grep 核。
- **bootstrap 不可证**:scout 推维质量在落地实战前不完全可证 → 声明 + 推后续实战验证,不算缺陷;但 spec 内具体可证漏洞(如循环依赖、断链)必须保留。

**奖励项 / 体现**:
- **scout 路确定性扇出 + 隔离(ultracode 专属增益,非普适根治)**:ultracode 在场跑 workflow 时,`parallel()` 屏障结构上保证一次性并行扇出(免去对"单 turn 一次性 fork"人工约束的依赖)。**诚实边界**:这是 scout 路相对即兴编排的增益,**仅 ultracode 在场兑现**;非 ultracode 路走现有 design-review,仍靠 review-rules「单 turn 一次性并行 fork」约束(同现状,本功能不碰)。不说"普适根治 bug"。
- **强化公设1(scout 路)**:独立 scout fork 比调度者自己推维更隔离(scout 路内成立)。
- **挡 spec-gap-masking(scout 路)**:`skipped_candidates` 强制留痕,scout 无法静默漏维。
- **活备份不丢能力**:现有固定 4 维 design-review 原样保留,任何运行时都有可用的设计审查路(scout 路是增量增强,不是替代,无"砍掉旧路致功能洞"风险)。

---

## 方案方向与待 designer 解决的设计决策

> 本段是 brainstorming → system-design 的交接。designer 接手后据此填第 2-9 节,并解决下列 🟡 设计决策(影响接口/数据/架构者写入 docs/decisions/ 标 🟡)。

**方案方向(Y:ADD 并排)**:D6 = A(Workflow 脚本),**新增 scout 路并排于现有 design-review,不替换**。整体形态:
```
design-review SKILL「执行」开头分支:
  ├─ ultracode/Workflow 可用 → review-scout workflow(reviewType=design + 指针 + 会话意图)
  │     ├─ 阶段A 侦察:scout agent 读上下文 → 产出审查计划(SCOUT_SCHEMA)
  │     └─ 阶段B 对抗:按计划一维一挑战者 parallel 扇出(挑战者 prompt 100% scout 路自有;floor/已知维 focus = workflow.js 常量;与 design-reviewer.md 零关系)
  │   → 返回 {plan, findings} → 调度者按 synthesis-rules 综合(scout 路用自己的维序说明:按 plan 维度清单读 findings)
  └─ 否则(ultracode 关)→ 走下面现有固定 4 维 design-review 流程(原样不动,活备份)
```
`SCOUT_SCHEMA = { inherited_floor:[…], added_dimensions:[{name, why_this_time, challenger_focus}], skipped_candidates:[{name, why_skipped}] }`(去掉了 challenger_count,N 自然从维度数掉出)。

> **scout 路 prompt 100% 自有,与 design-reviewer.md 零关系(🔴 第 3 轮根治)**:scout 路每个挑战者维(方向盘对齐 / 自洽性 / 完整性 / 过度工程化 / 动态加维)的 prompt **全部 scout 路自己写**——floor/已知维 focus = **workflow.js 常量**(workflow 无 FS,focus 必在脚本内;fix#1),动态维 focus = scout 的 challenger_focus;review-scout.md 只管推维。**不读/不抄/不镜像** design-reviewer.md(它的维度块是整块封闭 prompt,含 bootstrap-4 B 段等冲突内容,无可单取检查点)。方向盘对齐维带 A-3 template 回落分支。design-reviewer.md **零改、零关系、无双源同步义务**(守 L45 + Y 活备份)。详 §3.3。

**🟡 待设计决策(A-1/A-2/A-3 作用 scout 路;A-4 改 ADD 框;A-5 不变;A-6 按缩小集重核)**:
- **A-1 挑战者 嵌入 vs 自读**(scout 路):挑战者拿被审材料是"调度者/workflow 嵌入进 prompt"(中性可控,大材料受 64kB 软上限须拆轮)还是"挑战者自读盘"(64kB 溶解,但须另加中性约束防读到带偏材料)。scout 自身已定自读(D9)。
- **A-2 candidate 菜单边界**(scout 路):design 类的标准候选清单(完整性/过度工程化 — 执行层实际名 🔴-1 + 是否允许 scout 自由发明全新维);约束 = 不重叠 + why_this_time 指证据。
- **A-3 方向盘自适应判据**(scout 路):scout 检测 RUBRIC "已填 vs 空模板"的具体判据(模板标记串 `[待定义]`/`[示例,请替换]`/"你必须根据自己的项目替换")+ 回落目标(CLAUDE.md 原则 + 二条公设)的读取范围。
- **A-4 ADD 分发 + 非 ultracode 回落**(Y 改):review-scout 脚本随 setup.sh 分发(用户决定 A);Workflow 不可用(跨运行时)时**回落现有 design-review**(非降级,是另一条已存在的活路),不回落"扁平 fork scout"。
- **A-5 循环依赖澄清**:本 feature ADD scout;审**本 spec** 用的是**当前** design-review(治理面 → A/B/C bootstrap-4,非本 feature 的 scout)。设计须显式区分,避免"用还没造好的东西审造它的 spec"。
- **A-6 触点完整性清单(Y 缩小集)**:Y 下"4 维→2 维全仓同步"消失;只列"ADD scout 注"的最小同步触点(见 §8),重新 grep 核后逐一落实。

---

## 2. 模块划分

> 本功能"模块"= harness 工件(workflow 脚本 / agent 定义 / skill / 治理文件)。harness 自仓库无 ARCHITECTURE.md 产品分层,故"所在层"按工件类型(workflow / agent / skill / governance / 入口地图)标注,依赖方向 = "谁调用谁"。

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动/复用不改 | 工件类型 / 层 |
|------|--------------|----------|--------------|
| **M-scout-wf**(`.claude/workflows/review-scout.workflow.js`) | 编排"侦察→对抗"两阶段,返回 `{plan, findings}`(仅 scout/ultracode 路);**内含 floor/已知维挑战者 focus 常量库**(方向盘对齐/自洽/完整/过度工程化 — fix#1 单一住址,workflow 无 FS 故 focus 必在脚本内) | 新建 | workflow 脚本 |
| **M-scout-agent**(`.claude/agents/review-scout.md`) | **单一职责 = scout 推维 agent**:读上下文现推审查计划(地板+动态加+skipped),产 SCOUT_SCHEMA(含 A-3 判据 + B-8 加维引导);**不承载挑战者 focus 库**(库在 workflow.js) | 新建 | agent 定义(说明文件,随 agents 分发) |
| **M-skill**(`.claude/skills/design-review/SKILL.md`) | 「执行」开头**加运行时分支**:ultracode 可用→调 review-scout workflow;否则→走下面**现有固定 4 维流程(原样不动)** | 改动(只加分支,不动现有流程) | skill |
| **M-floor-table**(review-rules 设计行) | 设计行**新增** scout 注("ultracode 时走 review-scout:地板 2 维 + 动态";**地板维表权威住此**),**保留现有 4 维**作非 ultracode 默认 | 改动(加注,不改 4 维) | governance |
| **M-分发凭证**(`harness/setup.sh` + credentials.conf + credentials-rules §2) | setup.sh(实物 harness/ 下)分发 `.claude/workflows/`;conf+§2 加 `.claude/workflows/*` glob(双写行序同步) | 改动(加行) | 分发 / governance |
| **M-地图注**(CLAUDE.md×2 角色表+Skill地图 + QUICKREF) | 最小注:design-review 在 ultracode 下走 scout;**不动现有 4 维描述** | 改动(加注) | 入口地图 |
| **M-synth-ADD**(`docs/governance/synthesis-rules.md` 主表+L99+L169+L3) | 适用范围**四处各 ADD scout 行**(主表 L9-19 + 事前规则5 清单 L99 + 事后规则5 适用范围 L169 + 何时读 L3;活规则义务对齐 — 🟡-2);**L113/L151 维序仍零改** | 改动(多处 ADD 行) | governance |
| **M-reviewer(scout 路零涉及)**(`.claude/agents/design-reviewer.md`) | **scout 路与本文件零关系**(不读/不抄/不镜像);本文件整块 4 维 prompt **仅服务非 ultracode 现有路** | **不改(scout 路零涉及)** | agent 定义 |
| **M-现有路不动**(synthesis-rules **L15/L113/L151 维序** + design-rules L61+L181 + credentials-rules §7 L228 + model-route + references) | 仍服务现有固定 4 维路 | **不改** | governance/参考 |

> **Y 关键(ADD 不替换)**:Y 取消"把固定 4 维改 2 维"——`design-reviewer.md` / `synthesis-rules` **L15/L113/L151 维序** / `design-rules` L61+L181 / `credentials-rules §7 L228` / model-route / references **全部不改**(服务现有 4 维路活备份);`synthesis-rules` **四处 ADD scout 行**(主表/L99/L169/L3,活规则义务,合 Y "只加不换";L113/L151 维序零改)。
>
> **🔴 第 3 轮根治(scout 路 prompt 与 design-reviewer.md 零关系)**:2 轮证明 design-reviewer.md 维度块是**整块封闭 prompt**(嵌入式人设 + A/B/C 治理脚手架 + bootstrap-4 B 段 + JSONL),**无可单取检查点**;"内联副本"(1 轮)和"运行时 Read 取检查点"(2 轮)**都不成立**(读整块会把 bootstrap-4 等冲突内容带进 scout 路)。**正解:scout 路挑战者 prompt 100% scout 路自有,floor/已知维 focus = workflow.js 常量(workflow 无 FS,焦点必在脚本内;独立内容非双源),不读/不抄/不镜像 design-reviewer.md,两路 prompt 层零共享 → 无双源同步义务**。详 §3.3。
>
> **粒度反向追问(过度工程化自检)**:为何 scout 与 workflow 分两模块,不合一?——scout 是 **prompt/agent 定义**(被 fork 出的子智能体执行,有 Read/Grep 工具、独立 context),workflow 是 **编排脚本**(主对话 runtime 执行,无独立判断)。合一即让"做事(推维)"与"编排(扇出)"同 context,违公设 1 做审分离的前提隔离。故两模块是必要拆分,非投机抽象。

### 2.2 模块依赖图(Y:ADD 并排 — scout 路 vs 现有 4 维路,两条不同机制)

> **框架(Y)**:Workflow 工具是 **ultracode 运行时**的 opt-in 能力(逐会话开关,非保底基线;`docs/references/2026-06-10-scaffold-vs-ultracode-map.md` L20)。本功能 **ADD scout 路并排于现有 design-review**,两条是**不同机制**:
> - **scout 路(ultracode 开)**:review-scout workflow(scout 现推维 = 地板 2 维 + 动态加;`parallel()` 屏障确定性扇出)。scout 特性 = **ultracode 专属**。
> - **现有路(ultracode 关 / 非 Claude Code)**:**现有固定 4 维 design-review 原样运行**(skill + 扁平 fork + design-reviewer.md 4 维 prompt + synthesis 固定 4 维序),**本功能不改它一字**。这是活备份,已存在、不新建、不归档。

```
调度者(design-review SKILL「执行」开头分支)
   │  探测:ultracode/Workflow 可用?
   ├──是──▶ scout 路(新增)
   │         M-scout-wf(review-scout.workflow.js)
   │           │ phase('侦察')                    │ phase('对抗')
   │           ▼                                   ▼
   │         agent(scoutPrompt,{SCOUT_SCHEMA})    parallel(dims.map → agent(challengerPrompt(d),{FINDING_SCHEMA}))
   │           = M-scout-agent fork(纯推维)        = challengerPrompt 100% scout 路自有
   │           │ 读←被审材料(自读盘,A-1)           ↑ floor/已知维 focus = workflow.js 常量;动态维 focus = scout 的 challenger_focus
   │           │                                      不读/不抄/不镜像 design-reviewer.md
   │           ▼
   │         返回 {plan, findings} → 调度者按 synthesis-rules 综合
   │                                 (scout 路维序说明住 SKILL scout 分支段:按 plan 维度清单读 findings,不用固定 4 维序)
   │
   └──否──▶ 现有固定 4 维 design-review 路(原样不动 = 活备份)
             design-review SKILL 现有第一步 → 扁平 fork 4 挑战者(自洽性/完整性/过度工程化/RUBRIC 对齐,design-reviewer.md 实际名)
             → 调度者按 synthesis-rules 固定 4 维序(L151)综合 → design-review-result
```

- **scout 路 prompt 与 design-reviewer.md 零关系(🔴 第 3 轮根治)**:`challengerPrompt(d)` 对每个 scout 维产**统一结构** prompt = scout 路自有薄包装(自读盘 A-1 + 中性约束 + Read challenger-orientation 取通用方法论 + 主线-支线-关系 + 输出格式 + 已对照用户原话 section)+ 该维 focus。各维 focus **全 scout 路自有**:**floor/已知维(方向盘对齐[带 A-3 回落分支]/自洽性/完整性/过度工程化)focus = workflow.js 常量库**(workflow 无 FS,focus 必在脚本内;独立内容非副本)/ 动态加维 focus = scout 的 `challenger_focus` + 通用对抗框 D11。**不读/不抄/不镜像 design-reviewer.md → 无双源同步义务**;review-scout.md 只管推维(focus 库在 workflow.js)。详 §3.3。
- **现有路零改动**:ultracode 关时,design-review 现状(已含扁平 fork + 4 维 + synthesis 固定序)完整运行,本功能不碰;design-reviewer.md 整块 prompt 仅服务此路。
- **两路结果同构**:都产 findings → 调度者综合 → design-review-result;差别仅维度集(scout 动态 vs 固定 4)+ 维序说明(scout 按 plan / 现有按 L151 固定序)。

**自检**:
- [x] 每个模块只有一个明确职责?(scout-wf=scout 路编排 + focus 常量库;scout-agent=**纯推维**[focus 库不在此];skill=加运行时分支 + scout 维序说明;floor-table=加 scout 注;分发凭证=加行;地图注=加注;synth-ADD=四处 ADD scout 行;M-reviewer=scout 路零涉及/现有路不动)
- [x] 依赖方向(调用方向)无反向:scout 路 调度者→workflow→(scout/挑战者);现有路 调度者→4 挑战者,均无下层回调上层。
- [x] 无循环依赖:scout-wf 不依赖 skill;skill 单向分支调 workflow;现有路不经 workflow;**scout 路 prompt 不依赖 design-reviewer.md(零关系,无跨文件耦合)**;**focus 库住 workflow.js 自身(无跨文件取数,修取数断链)**。(A-5"用当前 design-review 审本 spec"是**流程时序**非模块依赖,§7 D-A5 专述)
- [x] 改动已有模块范围局限职责内:M-skill 只在执行开头加分支(不动现有流程);M-floor-table 只加注(不改 4 维);synthesis **四处 ADD scout 行(L113/L151 维序零改)**;design-reviewer.md / design-rules L61+L181 / credentials-rules §7 / model-route / references **零改动**。
- [x] 每个核心场景(§1.2)有实现路径:P0 场景1(ultracode 走 scout)→scout 路全链;P0 场景2(方向盘自适应)→M-scout-agent A-3;P0 场景3(非 ultracode 走现有 4 维)→现有路原样;P1(代码/治理留口)→reviewType 入参(本轮只接 design)。
- [x] 粒度合理:无"只一个函数的模块",无"做三件不相关事的模块"(已做反向追问 §2.1)。

---

## 3. 接口定义

### 3.1 workflow 入参(调度者 → M-scout-wf)

> **Workflow API 出处(🟡-6)**:本节及 §3.2/§3.3/§5 用到的 workflow 钩子(`phase`/`agent(...,{schema})`/`parallel`)、并发上限 ~min(16,核数-2)、单 prompt 64kB 软上限、1000-agent 兜底,**依据 = Workflow 工具契约(Claude Code ultracode 运行时)**,非凭空断言。

review-scout workflow 通过 Workflow 工具启动,入参由调度者提供(纯字面量,守 synthesis-rules 措辞中性):

```javascript
// review-scout.workflow.js 入参契约(经 workflow 启动参数传入)
{
  reviewType: 'design',        // 枚举: 'design' | 'code' | 'governance'(本轮只接线 'design';另两值查表有行但不接 design-review 调用)
  targets: {                   // 指针(D9: 按固定类目规则给路径,非手挑内容;scout 用 Read/Grep 自读)
    spec: 'docs/superpowers/specs/<被审 spec>.md',  // 被审材料路径(必填)
    rubric: 'docs/RUBRIC.md',                        // 方向盘路径(A-3 判据读它)
    architecture: 'docs/ARCHITECTURE.md',            // 可缺(自仓库无 → scout 标注跳过架构维)
    decisionsDir: 'docs/decisions/',                 // 决策史目录(scout 按需 Grep)
    auditsDir: 'docs/audits/'                        // 审查凭证目录(scout 按需 Grep)
  },
  sessionIntent: '<一行会话意图,措辞中性>'  // D9: 只能 args 传(workflow 无文件系统);守 synthesis-rules 事前规则 5「主线-支线-关系」边界、非结论引导
}
```

- **调用场景**:调度者在 design-review SKILL「执行」开头做运行时分支,**ultracode/Workflow 可用**时走本接口(scout 路);**不可用**时不调本接口、走**现有固定 4 维 design-review 流程**(活备份,与本接口无关 — 见 §2.2 / A-4)。本接口**仅服务 scout 路**。
- **错误处理**:入参缺 `targets.spec` → workflow `log()` 报错并返回空 `{plan:null, findings:[]}`,调度者视为审查失败按 SKILL 错误处理重试。(运行时无 Workflow 工具不是"本接口错误",是分支去走现有 4 维路,见 §5.1)

### 3.2 SCOUT_SCHEMA(M-scout-agent → workflow,经 `agent(..., {schema})` 校验)

scout fork 返回的对象,由 `agent()` 带 schema 校验。**字段权威定义见 §4.1**,此处给契约形态:

```javascript
// SCOUT_SCHEMA(去掉 challenger_count,N 自然从 inherited_floor + added_dimensions 维数掉出 — D2/D12)
{
  inherited_floor: [ /* string[]: 地板维名(仅维名,无 focus 通道);workflow 按维名映射到 workflow.js focus 常量取 focus — §3.3 */ ],
  added_dimensions: [
    {
      name: '<维度名,不得与地板/已列候选重叠>',
      why_this_time: '<证据指认: 引被审材料/决策/历史原文,说明本次为何要加这一维>',
      challenger_focus: '<该维挑战者的关注焦点,1-2 行;注入挑战者 prompt 的 A 段 focus 位>'
    }
  ],
  skipped_candidates: [
    { name: '<标准候选名,如 完整性/过度工程化>', why_skipped: '<本次为何不加,一行>' }
  ],
  rubric_mode: 'filled' | 'template',   // A-3: scout 判方向盘已填 vs 空模板的结论(供调度者综合时核 scout 判据)
  notes: '<可选: scout 的边界声明,如 "ARCHITECTURE.md 缺失,跳过架构维">'
}
```

> **scout agent prompt 须含"加维正向引导"(B-8 缓解"换汤不换药")**:scout 易退化成"只加现有 4 维同集"。故 M-scout-agent prompt 要给**正向信号 → 该加什么新维**的引导(举例,非穷举):
> - **迁移 / 兼容性信号**(spec 提到数据迁移、版本升级、向后兼容)→ 考虑加"迁移安全 / 回滚路径"维;
> - **跨文件契约信号**(spec 改动涉及产出方↔消费方、跨文件计数/枚举)→ 考虑加"契约一致性 / 触点完整性"维;
> - **特定失败模式信号**(spec 涉并发、外部依赖、状态机)→ 考虑加"并发安全 / 失败恢复"维。
> "好的动态维" = `why_this_time` 能引被审材料具体原文锚点(非泛泛"更全面")、不与地板/候选重叠。**诚实**:此引导降低退化概率但不消除,退化是实战要观察的失败模式(§6 / meta-L4)。

- **调用场景**:workflow `phase('侦察')` 内 `await agent(scoutPrompt, {schema: SCOUT_SCHEMA, label:'scout', agentType:'general-purpose'})`。
- **错误处理**:scout 空返回 / schema 校验失败 → workflow 重试一次(对齐 review-rules「挑战者空返回 → 重试一次 → 仍败标未完成」);二次失败 → workflow `return {plan:null, findings:[]}`,调度者视审查失败。`added_dimensions` 为空数组**合法**(地板足够,但 `skipped_candidates` 必须解释为何完整性/过度工程化都没加 — 挡 spec-gap-masking)。

### 3.3 challengerPrompt(d) 契约(scout 路挑战者 prompt **100% scout 路自有,与 design-reviewer.md 零关系** — 🔴 第 3 轮根治)

> **第 3 轮根治(2 轮反复的根)**:`design-reviewer.md` 每个维度块是**整块封闭 prompt**(嵌入式人设 L72 + A/B/C 治理脚手架,B 段 = bootstrap-4 L87-91 + 输出格式 + JSONL),**没有可单取的"检查点"**。故"内联副本"(1 轮)和"运行时 Read 取检查点"(2 轮)**都不成立**——读整块会把 **bootstrap-4 等冲突内容**带进 scout 路(如自洽性维读到 B 段"禁止删减维度集",与 scout floor 表互斥)。**正解:scout 路挑战者 prompt 100% 是 scout 路自己的内容,不读、不抄、不镜像 design-reviewer.md。两条路在 prompt 层零共享。**

每维一个挑战者,workflow `phase('对抗')` 内 `parallel(dims.map(d => () => agent(challengerPrompt(d), {schema: FINDING_SCHEMA, label:d.name, agentType:'general-purpose'})))`。

`challengerPrompt(d)` 对**每个** scout 维(地板 + 候选 + 动态)产**统一结构**的 prompt:

```
challengerPrompt(d) =
  [scout 路自有薄包装]
    + 给被审材料路径(自读盘指令)+ 中性约束(D-A1)
    + "先 Read docs/references/challenger-orientation.md 取通用方法论(方法/数据来源/陷阱;
       注:其 §1.2「design-review 4 挑战者专属」的固定 4 维框定不适用 scout 动态 N,不要被它误导)"
    + 顶部「主线-支线-关系」段(synthesis 事前规则 5,workflow 从 sessionIntent 构造)
    + 输出格式 + 末尾必填「### 已对照用户原话」section(守事后规则 5)
  + [该维 focus]
```

各维 focus 来源(**全 scout 路自有,不来自 design-reviewer.md;floor/已知维 focus = workflow.js 常量** — 修取数断链):

| 维类型 | focus 来源 | 取数方式 |
|---|---|---|
| **方向盘对齐 / 自洽性 / 完整性 / 过度工程化**(地板+已知维,执行层名 🔴-1) | **review-scout.workflow.js 里的 focus 常量**(scout 路自有独立内容,scout 语境,**无 bootstrap-4 B 段、无嵌入式人设、无 A/B/C 脚手架**);方向盘对齐带 **A-3 template 回落分支**(RUBRIC 已填→对齐 RUBRIC;空模板→回落 CLAUDE.md 原则+二公设) | workflow `challengerPrompt(d)` **按维名 d.name 从脚本内 focus 常量映射**(脚本自身加载,**无需 FS**) |
| scout 动态加维 | scout 返回的 `challenger_focus` 字段(SCOUT_SCHEMA)+ 通用对抗框(D11:角色+数量+要证据+格式,来自 multi-agent-review-guide) | 来自 scout fork 的 schema 返回值 |

> **为何 focus 当 workflow.js 常量,不住 review-scout.md(取数断链根因)**:**workflow 无文件系统**(禁用项),读不到 review-scout.md 的 focus 文字;且 `SCOUT_SCHEMA.inherited_floor` 是 `string[]`(只有维名、**无 focus 通道**)。故 floor/已知维 focus 必须是 **workflow.js 自身的常量**(脚本加载即在内存,无需 FS)。**这些 focus 是 scout 路自有独立内容、不镜像 design-reviewer.md → workflow.js 就是单一住址,不是双源,无同步义务**(r3 的"住 review-scout.md"不可行,已纠正)。
>
> **review-scout.md 回归单一职责(连带解 🔵 职责过载)**:`.claude/agents/review-scout.md` = **scout 推维 agent**(推维 + A-3 判据 + B-8 加维引导),**不再承载挑战者 focus 库**;挑战者 focus 全在 workflow.js 常量。
>
> **三处一并解掉**:① 🔴#1(运行时取检查点不成立)— 不读 design-reviewer.md;② 🔴#2(自洽性维读到 B 段 bootstrap-4 与 floor 表互斥)— scout 维 focus 常量无 B 段;③ 🟡#3(地板 2 维异构来源)— 所有 scout 维 focus 统一来源 = workflow.js 常量。
>
> **design-reviewer.md 仍零改**(Y 守住):它整块 prompt **只服务非 ultracode 现有 4 维路**,scout 路与它**零关系**(不读不抄不镜像)。

- **被审材料获取(A-1 裁决)**:挑战者**自读盘**(prompt 内给被审材料路径 + 中性约束),不嵌入全文。守中性办法见 §7 D-A1。
- **错误处理**:某挑战者空返回 → workflow 重试一次;仍败 → `parallel` 该项为 null,`.filter(Boolean)` 后该维标"未完成",调度者综合时按盲区处理(对齐 review-rules)。

### 3.4 FINDING_SCHEMA(挑战者 → workflow)

```javascript
// 每个挑战者返回(schema 校验)
{
  dimension: '<本维名>',
  findings: [
    { title:'...', location:'<文档节/路径>', problem:'...', evidence:'<原文引用>', impact:'...', severity:'🔴|🟡|🟢' }
  ],
  user_words_section: '<### 已对照用户原话 section 原文,供调度者综合阶段校验 — synthesis-rules 事后规则 5>'
}
```

- **不打分**(对抗-决策分离,multi-agent-review-guide):挑战者只产 findings + 证据,judging 在调度者综合阶段(D8)。

### 3.5 workflow 出参(M-scout-wf → 调度者)

```javascript
return {
  plan: { /* SCOUT_SCHEMA 原样 + 实际扇出的维列表 */ },
  findings: [ /* FINDING_SCHEMA[],已 .filter(Boolean) 去掉失败挑战者 */ ]
}
```

调度者拿 `{plan, findings}` 后**按 synthesis-rules 综合判定**(D8),写 `docs/active/design-review-result.md`(沿现状),不在 workflow 内下判定。

> **scout 路综合维序(新增说明,不改 synthesis-rules L151;🟡-3 住址钉死)**:synthesis-rules L151 的"固定 4 维序(自洽→完整→合理→对齐)"服务**现有 4 维路**,**不改**。scout 路维度由 plan 动态定,故其综合维序 = **按 plan 产出的维度清单顺序交叉读 findings**(不用固定 4 维序)。**综合是调度者行为**,调度者跑 scout 路时读 SKILL,故此说明**钉在 SKILL 的 scout 分支段**(单一住址,不"或")。是 scout 路的**新增**综合说明,**不是改 L151**;L151 仍按原文服务现有路。

**自检**:
- [x] 每个接口双方都定义:入参(调度者↔wf)/ SCOUT_SCHEMA(scout↔wf)/ challengerPrompt+FINDING_SCHEMA(挑战者↔wf)/ 出参(wf↔调度者)四对齐全。
- [x] 参数/返回类型在数据模型(§4)定义:SCOUT_SCHEMA/FINDING_SCHEMA/floor 表/plan 均 §4 有定义。
- [x] 每个接口有错误处理约定:入参缺失 / scout 空返回 / 挑战者空返回 / Workflow 不可用 全有路径。
- [x] 入参出参与需求数据对得上:reviewType/targets/sessionIntent ← D9;inherited_floor ← D1;skipped_candidates ← D7-scope;不打分 ← D8。
- [x] 接口简洁:SCOUT_SCHEMA 去 challenger_count(N 自然掉出);targets 用固定类目(非手挑)— 无冗余参数。
- [x] 前后端契约:不适用 — 本功能无 API 端点、无前后端分离;契约 = workflow 钩子签名 + schema 对象,已在本节定义。
- [x] 字段命名统一:`reviewType` / `inherited_floor` / `added_dimensions` / `skipped_candidates` / `challenger_focus` / `why_this_time` 全文一名(与 §1 方案方向 SCOUT_SCHEMA 一致)。

---

## 4. 数据模型

### 4.1 数据实体

```javascript
// (1) 地板维表(M-floor-table — 住 review-rules 设计行的 scout 注,人读 markdown;此处给逻辑结构)
//     仅作用 scout(ultracode)路;非 ultracode 路用现有固定 4 维(不查本表)
//     三类各一行;design 行本轮接线,code/governance 行留口不接调用
FloorTable = {
  design:     ['方向盘对齐', '自洽性'],                 // D1: 地板 2 维(本轮接线)
  code:       ['方向盘对齐', '简洁性'],                 // D4: Superpowers 默认维仍在底下跑(留口,本轮不接线)
  governance: ['核心原则合规','目的达成度','副作用','scope 漂移']  // D4: bootstrap-4 锁死,不动 D7(本轮不接线;治理审查仍走现 A/B/C)
}
// 反向追问(过度工程化自检 — 🟡-7):为何写 3 行(不只 design 1 行)?——用户明确要"架构覆盖三类"(§1.1/D5);
//   floor 表三行正是该需求的具体载体,加 code/governance 2 行明标"留口不接线"成本近零(纯数据行,无实现代码)。
//   不写 3 行 → 无法满足"覆盖三类"的已确认需求。故 3 行保留合理(非过度工程;非投机预留 = 已确认三类)。详 §7.3。

// (2) SCOUT_SCHEMA 实体(§3.2 形态;字段语义)
ScoutPlan = {
  inherited_floor: string[],   // 照抄 FloorTable[reviewType],scout 不可增删改
  added_dimensions: AddedDim[],
  skipped_candidates: Skipped[],
  rubric_mode: 'filled' | 'template',
  notes?: string
}
AddedDim = { name: string, why_this_time: string, challenger_focus: string }
Skipped  = { name: string, why_skipped: string }

// (3) 标准候选菜单(A-2 — scout 路 design 类;scout 每次必考虑,不加须进 skipped_candidates)
DesignCandidateMenu = ['完整性', '过度工程化']   // 执行层实际名(🔴-1 alias:design-reviewer.md L198「过度工程化」,非"合理性")。
                                                 // = 现有 4 维里地板外的 2 维,scout 路降为"必考虑候选";scout 可在此外自由发明全新维(约束: 不重叠 + why_this_time 指证据)。
                                                 // 注:降级只在 scout 路;现有 4 维路这 2 维仍是固定维。

// (4) FINDING_SCHEMA 实体(§3.4)
Finding = { title, location, problem, evidence, impact, severity }
ChallengerReturn = { dimension: string, findings: Finding[], user_words_section: string }
```

### 4.2 数据流

```
调度者构造入参(reviewType + targets 指针 + sessionIntent)
  → workflow 启动
  → phase 侦察: scout fork(读 FloorTable[design] 照抄 inherited_floor;读 targets.rubric 判 rubric_mode;Grep decisions/audits + 被审材料 → 推 added_dimensions / skipped_candidates)
  → scout 返回 ScoutPlan(schema 校验)
  → workflow 算 dims = inherited_floor ∪ added_dimensions.name
  → phase 对抗: parallel 每 dim 一挑战者 fork(自读被审材料 + focus)→ 各返回 ChallengerReturn
  → workflow return {plan: ScoutPlan, findings: ChallengerReturn[].filter(Boolean)}
  → 调度者综合(synthesis-rules)→ design-review-result.md → 判定通过/需修
```

### 4.3 状态变更

| 实体 | 从状态 | 触发事件 | 到状态 | 副作用 |
|------|-------|---------|-------|--------|
| ScoutPlan | (无) | scout fork 成功 + schema 通过 | 已产出 | workflow 进入对抗 phase |
| ScoutPlan | scout 空返回/校验失败 | 重试一次仍败 | 审查未完成 | workflow 返回空,调度者降级/重试 |
| dim 挑战者 | 已扇出 | 空返回重试仍败 | 该维未完成 | `.filter(Boolean)` 剔除,调度者按盲区处理 |
| design-review-result | (无) | 调度者综合完 findings | 已写盘 | 进入判定;不通过则回 designer 修复 |

**自检**:
- [x] 数据流每步输入/输出类型与接口一致:入参→ScoutPlan→ChallengerReturn[]→{plan,findings},与 §3 四接口对齐。
- [x] 实体字段覆盖所有接口用到的数据:reviewType/targets/sessionIntent(§3.1)、inherited_floor/added_dimensions/skipped_candidates/rubric_mode(§3.2)、challenger_focus(§3.3)、Finding 各字段(§3.4)全在 §4.1。
- [x] 状态机无死状态/不可达:scout 成功→对抗;scout 失败→空返回;挑战者失败→盲区;均有出口。
- [x] 命名规范:JS 字面量,字段名 snake/camel 与 §3 一致;无数据库,无 snake↔camel 映射需求(N/A)。
- [x] 数据校验位置明确:schema 校验由 `agent({schema})` 在 workflow 层做;rubric_mode 判据由 scout 在 fork 内做(A-3)。

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 场景 | 输入条件 | 期望行为 |
|------|---------|---------|
| scout 空返回(scout 路) | scout fork 返回 null / schema 不过 | workflow 重试一次;仍败 → `{plan:null, findings:[]}`,调度者标审查失败,报用户(对齐 review-rules 错误处理)。**不静默回落现有 4 维路**(scout 路失败 ≠ ultracode 不在场,须显式报) |
| added_dimensions 为空 | scout 判地板已足够 | **合法**;但 `skipped_candidates` 必须解释完整性/过度工程化为何都不加(空 skipped + 空 added → 视 scout 失职,调度者综合时质疑) |
| 维度爆量(N 很大,scout 路) | scout 加了很多维 | 不静默截断(D12):plan 列全维 + skipped;`parallel` 自动排队(**并发上限 ~min(16,核数-2),依据 = Workflow 工具契约 / ultracode 运行时**);调度者综合时合并重叠维。**真实边界 = 透明 + 排队** |
| 维度重叠 | scout 加的维与地板/候选语义重叠 | scout 侧约束(D11: 不重叠);漏防时调度者综合阶段按 synthesis-rules 去重升级(共识合并) |
| 某挑战者空返回(scout 路) | 单挑战者失败 | 重试一次;仍败该维标"未完成"(`parallel` null `.filter(Boolean)`)→ 调度者按盲区处理(不静默当通过) |
| **ultracode 关 / Workflow 工具不在场** | 跨运行时(Codex 等)/ 非 Claude Code / 逐会话未 opt-in | **不是错误,是 SKILL 执行开头分支去走现有固定 4 维 design-review 流程**(活备份,原样运行 — §2.2 现有路)。**不标"降级执行"**(现有 4 维路是已存在的正常路,不是 scout 的降级)。scout 动态推维在此路不可得 = ultracode 专属取舍(D13) |
| RUBRIC 检测误判(scout 路) | scout 判 filled/template 判错 | rubric_mode 写进 plan,调度者综合时可见 scout 判据;误判 → 调度者据全局上下文纠正(scout 判据透明可推翻,非黑箱) |
| ARCHITECTURE.md 缺失 | 自仓库无该文件 | scout `notes` 标"跳过架构维"(沿 design-reviewer.md 现状「ARCHITECTURE.md 不存在则跳过架构合规检查」) |
| 被审材料超 64kB(scout 路) | 自读盘,不嵌入 | A-1 自读盘规避嵌入软上限;若 scout/挑战者自读后内部超 context → 挑战者按需 Grep 局部读(不强求全文一次性载入) |

### 5.2 错误传播路径

```
[scout 路] scout fork 失败 → workflow 重试1次 → 仍败 → workflow return 空 → 调度者(SKILL 错误处理)→ 报用户(不静默回落 4 维路)
[scout 路] 挑战者 fork 失败 → workflow 重试1次 → 仍败 → parallel 该项 null → filter 剔除 → 该维"未完成" → 调度者综合标盲区(不当通过)
ultracode 关 / Workflow 不在场 → SKILL 执行开头分支 → 走现有固定 4 维 design-review(活备份,原样运行)→ 不标降级
[现有 4 维路] 沿现状 design-review 错误处理(本功能不碰)
```

**自检**:
- [x] 每个接口错误情况都有边界处理:§3 接口错误约定 ↔ §5.1 行对应(scout 路;现有 4 维路沿现状不碰)。
- [x] 错误传播路径完整,无吞错:scout 路空返回→重试→标未完成/盲区,均显式;ultracode 关→分支走现有 4 维路(非错误、非降级);scout 路失败显式报(不静默回落)。
- [x] 用户能看到有意义错误:调度者综合报告按 synthesis-rules 4 段,审查失败给原因摘要,非堆栈。
- [x] §1.2 核心场景异常路径都覆盖:场景1(scout 失败→报用户)、场景2(rubric 误判→透明可纠)、场景3(ultracode 关→现有 4 维路原样跑)、P1(reviewType 留口未接→查表无 design 调用即现状)。

---

## 6. 测试策略

> harness 自仓库无产品 runtime 单测框架;本功能验证 = (a) workflow 脚本结构静态核 + (b) bootstrap 实战(本机制落地后,用它审下一个 feature spec — meta-L4 实战留痕,非自仓库 artificial trial,对齐用户偏好 `feedback_realworld_testing_in_other_projects`)。

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | mock 策略 |
|---------|---------|---------|----------|
| §1.2 场景1 | review-scout.workflow.js 能 `export const meta` + 侦察→对抗两 phase 跑通,返回 `{plan, findings}` 结构 | 脚本结构静态核(读脚本核钩子用法 + 禁用项:无 Date.now/Math.random/无参 new Date) | 不 mock — 结构核,不跑 fork |
| §1.2 场景2 | scout prompt 内 A-3 判据(RUBRIC filled/template)— 给"已填 RUBRIC"与"空模板 RUBRIC"两输入,scout 应分别产 rubric_mode=filled/template | bootstrap 实战观察(落地后首次用) | N/A(实战) |
| §1.5 D1 | inherited_floor 恒含且仅含 `方向盘对齐 + 自洽性`(scout 照抄 floor 表,不增删) | 脚本/prompt 静态核 + 实战观察 | N/A |
| §1.5 D7-scope | 完整性/过度工程化不加时,skipped_candidates 必有对应条目(挡 spec-gap-masking) | bootstrap 实战观察 plan 输出 | N/A |
| §5.1 scout 空返回 | 重试一次 → 仍败返回空 → 不静默当通过、不静默回落 4 维路 | 脚本逻辑核(读 workflow 重试分支) | N/A |
| §1.2 场景3 ADD 分支 | SKILL 执行开头分支文字完整(ultracode 开→调 review-scout workflow / 关→走下面现有 4 维流程,原样不动);**现有 4 维流程零改动** | SKILL 文档核(分支只加在开头,下面现有流程逐字未变) | N/A |
| D13 scout 路 prompt 自有零关系(🔴 第 3 轮) | scout 路挑战者 prompt **100% scout 路自有(floor/已知维 focus = workflow.js 常量,review-scout.md 纯推维)**,不读/不抄/不镜像 design-reviewer.md;`design-reviewer.md` / `synthesis-rules` L113/L151 维序 / `design-rules` / `credentials-rules §7` / model-route / references **零改动、零关系** | 文档核(① workflow.js 含 focus 常量库 + review-scout.md 纯推维;② **§8.3 CMD1 全仓 git diff** 现有路文件零 diff,synthesis 仅四处 ADD 行) | N/A |
| **退化失败模式(B-8 诚实标注 — meta-L4 实战必观察)** | scout 是否退化成"只加现有 4 维同集"(动态价值落空 = 换汤不换药)?加维是否真带 `why_this_time` 原文锚点? | bootstrap 实战观察 plan(连续 N 次审查的 added_dimensions 分布) | N/A(实战;失败则回看 scout prompt 正向引导是否足够) |
| §8 触点同步(收敛闭合) | **§8.3 CMD1 全仓 git diff** 确认 diff 只含 §8.1 ADD 文件(现有路 design-reviewer/synthesis 维序/design-rules/model-route/references 零 diff;synthesis 仅四处 ADD 行)— 结构兜底,枚举漏一也被逮 | 收口前实跑 §8.3 命令组(已设计期实跑验证) | N/A |

### 6.2 测试边界

- **不测**:Workflow 工具引擎本身(平台层,不在本功能 scope);scout 推维"质量好坏"在落地前不可证(bootstrap 不可证,§1.6;声明 + 推实战,不算缺陷);现有固定 4 维路(本功能不碰,沿现状)。
- **mock 策略**:无传统 mock;脚本结构核靠读脚本 + 静态规则(禁用项、钩子签名),fork 行为靠 bootstrap 实战。
- **诚实标注的实战观察项(meta-L4)**:① 退化回固定 4 维(B-8);② 非 ultracode 路原始痛点未解(§1.6/§7.3 — 空 RUBRIC 自仓库默认仍走固定 4 维,动态推维不兑现);③ 自读盘中性的循环性(§7 D-A1 — 锚点同源带偏)。三者均**不可在落地前证**,推实战回看,不算本设计缺陷,但**如实列出不粉饰**。

**自检**:
- [x] §1.2 每个核心场景有对应测试/观察:场景1(结构核)、场景2(实战)、场景3(ADD 分支文档核 + 现有流程零改动)、P1(查表无 design 调用 = 现状,文档核)。
- [x] §5 每个边界有对应:scout 空返回 / ultracode 关分支去现有 4 维路 / D13 scout 路 prompt 自有零关系 / 退化失败模式 / 触点同步 均列;爆量/重叠由"实战观察 plan + 调度者综合去重"覆盖。
- [x] 测试层级合理:能静态核的(脚本结构/文档完整/git diff 文件空/grep 触点)不上实战;推维质量 + 三个诚实观察项(退化/痛点未解/中性循环)留实战(本质不可证,合理)。

---

## 7. 设计决策记录

### 7.1 已确认决策(§1.5 D1-D13 流转,本节登记便于 §9 双向引用)

| 决策 | 选择 | 原因(已锁,见 §1.5) |
|------|------|------|
| D1 地板大小(Y) | **scout 路** 地板 = 方向盘对齐 + 自洽性(2 维);**非 ultracode 路保现有固定 4 维** | §1.5;地板 2 维只作用 scout 路 |
| D2 N 不预设 | N = 地板 + scout 动态加,一维一挑战者 | §1.5 |
| D3 方向盘自适应 | 填了对齐 RUBRIC,空模板回落 CLAUDE.md+二公设 | §1.5;判据细化见 D-A3 |
| D4 三类地板各异、不动 D7 | design=方向盘+自洽 / code=方向盘+简洁 / governance=bootstrap-4 | §1.5;FloorTable §4.1 |
| D5 范围 | 架构三类通用,先交付设计审查 | §1.5 |
| D6 集成载体 | A 方案 = Workflow 脚本 | §1.5;非过度工程论证见 §7.3 |
| D7-scope | scout 独立 fork + skipped_candidates 强制留痕 | §1.5;公设1 + 挡 spec-gap-masking |
| D8 综合留调度者 | workflow 只返回 plan+findings | §1.5;对抗-决策分离 |
| D9 scout 输入 | 指针(固定类目)+ 会话意图(args 传) | §1.5;§3.1 入参 |
| D10 轻量跳过判据 | 复用 design-rules 规模判断表 | §1.5;§8 不动轻量路径 |
| D11 novel 维挑战者 prompt | 对抗框固定,scout 只供 challenger_focus | §1.5;§3.3 |
| D12 N 无硬上限 | 不静默截断,透明+排队+综合合并 | §1.5;§5.1 爆量行 |
| D13 ADD 不替换(Y) | review-scout 并排;现有 4 维 design-review 原样作活备份 | §1.5;用户 2026-06-13 拍板,取代 X |

### 7.2 本轮裁决的 🟡 设计决策(A-1~A-6;A-1/A-2/A-3 作用 scout 路 / A-4 改 ADD 框 / A-5 不变 / A-6 缩小集重核)

#### D-A1 挑战者拿被审材料:**自读盘**(裁决:自读盘 + 中性约束)

- **选择**:挑战者**自读盘**(prompt 给被审材料路径 + 中性约束),**不**由 workflow 嵌入全文。
- **原因(具体可验证)**:
  1. **scout 已定自读(D9),挑战者同构降复杂度**:若挑战者改嵌入,workflow 须自己读盘(但脚本**无文件系统 API**,禁用项明列)→ 只能让调度者先读再传入 args,大材料触 64kB 软上限须拆轮(review-rules 实证约束)。自读盘把"读"下放给有工具的 fork 子智能体,绕开脚本无 FS + 64kB 双重限制。
  2. **现状已是自读混合**:现 design-review 挑战者已自读 `challenger-orientation.md` 并从 JSONL 自抽用户原话(design-reviewer.md L70/L117)——自读盘不是新风险面,是沿用已验证模式。
  3. **守中性的具体办法**(回应权衡中性的代价):① 路径来自 `targets` 固定类目规则(D9,非调度者手挑带偏文件);② prompt 内写明"只读 `targets.spec` 指定的被审材料 + 你这一维 focus 相关的 decisions/audits,**不要**主动搜罗支持某结论的旁证"(对齐 synthesis-rules 事前规则 1 材料 selection 中性);③ scout 产 `why_this_time` 指明每维证据锚点,挑战者按锚点读,减少漫游带偏;④ 中性度由 process-audit 抽检(synthesis-rules 事前规则 4 抽检兜底)。
  - **诚实标注:办法 ③ 的循环性(🟡-10,不标"中性已够")**:`why_this_time` 锚点由**同一条 scout fork** 产出,**非独立环节**;若 scout 推维阶段已带偏,锚点会把挑战者**导向同一带偏切片**——③ 不是独立中性保障,是同源引导。①②④ 是真减偏(固定类目 / 措辞约束 / 抽检),③ 只减"漫游"不减"同源偏"。且 process-audit 抽检**不绑每批**(synthesis 事前规则 4 抽检兜底),故循环性在未抽到的批次不被拦。**这是已知残留风险,推 meta-L4 实战观察(§6),不算落地前可消除的缺陷,但如实写出不粉饰。**
- **被排除项**:嵌入 vs 自读 — 嵌入排除原因:脚本无 FS,嵌入须经调度者 args 传全文,大 spec 触 64kB 拆轮(依据 = Workflow 工具契约 ultracode 运行时,见 §3.1/§5 出处注),编排复杂度反升;且嵌入不消除带偏风险(调度者选嵌什么仍是 selection 点)。

#### D-A2 candidate 菜单边界:**标准候选 = {完整性, 过度工程化};允许 scout 发明全新维(双约束)**

- **选择**(scout 路):design 类标准候选清单 = `完整性` + `过度工程化`(🔴-1:执行层实际名,design-reviewer.md L198「过度工程化挑战者」,非治理层别名"合理性";= 现有 4 维里地板外的 2 维,在 scout 路降为"必考虑候选";现有 4 维路这 2 维仍固定),scout **每次必考虑**,不加须进 skipped_candidates;**允许** scout 在菜单外自由发明全新维。
- **双约束**:(1) **不重叠** — 新维不得与地板(方向盘对齐/自洽性)或已列候选语义重合;(2) **why_this_time 指证据** — 新维必须在 `why_this_time` 引被审材料/决策/历史原文说明本次为何需要(非泛泛"更全面")。
- **原因**:
  1. **完整性/过度工程化留作"必考虑候选"而非删除**:它们是原 4 维里地板外的 2 维(执行层实际名 🔴-1),实战高频有用;降级为候选(必考虑+不加须解释)既给 scout 自由、又靠 skipped 强制留痕挡静默漏维(D7-scope)。
  2. **允许发明全新维 = 本功能动机本体**:§1.1「维度由 agent 根据审查对象自行设计」+ multi-agent-review-guide「维度由 agent 自行设计,不存在通用模板」。若禁止发明、只能选菜单 → 退化回固定表,动机落空(过度限制的反向追问:不允许发明,"现固定 4 维不灵活"的原问题怎么解?无解 → 必须允许)。
  3. **双约束防发明失控**:不重叠挡冗余 fork;why_this_time 指证据挡"为发明而发明"(对齐 feedback_judgment_basis 决策须指事实)。

#### D-A3 方向盘自适应判据:**模板标记串命中即判 template,回落 CLAUDE.md 原则 + 二公设**

- **判据(具体串,scout 在 fork 内 Read `targets.rubric` 后判)**:RUBRIC「项目特定标准」段命中以下任一模板标记 → `rubric_mode='template'`:
  - 段标题含 `（示例，请替换）`(实测 harness 模板 L61/L79/L93)
  - 含 `你必须根据自己的项目替换`(实测 L58)
  - 项内容为占位 `[列出...]` / `[例如：...]`(实测 L65-105)
  - 设计文档「方案方向」段原列 `[待定义]`/`[示例,请替换]`(模板标记串,与上同族)
  - 全部项目特定标准段均命中模板标记 → 判 template;**部分已替换部分仍占位** → 已替换段按 filled 用、占位段标"⚠️ 该段未自定义跳过"(沿 design-reviewer.md 现状「每节独立判断」L33)。
- **回落目标(template 时)**:对齐 `CLAUDE.md` 原则(文档第一公民 / 最小变更 / 角色分离 / 回退规则)+ **二条公设**(Pathological Optimist 做审分离 / 行动公设 不确定执行外部动作)。读取范围 = scout Read `CLAUDE.md`(自仓库读 `/CLAUDE.md` 治理入口或 `harness/CLAUDE.md` 分发模板,二者均含二公设全文)。
- **原因**:① 判据是**实测模板标记串**(非臆测),可 grep 验证(§6.1 场景2);② 通用基线段(功能完整性/代码质量/测试/一致性/简洁性,L21+)**始终检查**(沿 design-reviewer.md L33「通用基线始终检查」),template 模式只影响"项目特定标准"段是否回落;③ 回落到 CLAUDE.md+二公设 = 自仓库真方向盘(§1.6「自仓库 RUBRIC 是空模板,真方向盘 = CLAUDE.md 原则 + 二条公设」),非另造标准。

#### D-A4 ADD 分发 + 非 ultracode 回落现有 design-review(Y):**setup.sh 加 `.claude/workflows/` 复制段;ultracode 关 → 走现有固定 4 维 design-review(活备份)**

> **框架(Y)**:Workflow 工具是 **ultracode 运行时**的逐会话 opt-in 能力,非保底基线(`docs/references/2026-06-10-scaffold-vs-ultracode-map.md` L20)。本裁决 = **ADD scout 路并排**,ultracode 不在场时回落**现有 design-review**(已存在的活路,非新造的降级)。

- **分发**:setup.sh 新增 `mkdir -p "$TARGET_DIR/.claude/workflows"` + `cp review-scout.workflow.js`(对齐现 agents/skills/hooks 复制段写法)。scout agent 定义随 `.claude/agents/` 复制段分发(对齐 research-scout.md 同类"说明文件"分发,setup.sh L46-49 注记)。**用户拍板保 A:分发 + 纳凭证义务都不变**,故 setup.sh 必复制此目录、credentials.conf 必纳 `.claude/workflows/*` glob(§7.4 decision 🟢)。
- **运行时分支(ADD,不替换)**:
  - **ultracode 开(Workflow 工具在场)**:design-review SKILL 执行开头分支 → 调 review-scout workflow(scout 现推维 + `parallel()` 确定性扇出)。
  - **ultracode 关 / 非 Claude Code / 逐会话未 opt-in**:分支 → **走下面现有固定 4 维 design-review 流程,原样不动**(扁平 fork 4 挑战者:自洽/完整/合理/RUBRIC)。**这是已存在的活路,不是 scout 的降级**;不标"降级执行"。scout 动态推维在此路不可得 = ultracode 专属取舍(D13,用户接受)。
- **原因**:① 分发写法对齐现有 setup.sh 段,最小变更;② "ADD 并排 + 回落现有路"对齐 harness "机器增强层不丢保底可校验性"理念(AGENTS.md「hook 是增强层,换运行时不丢可校验性」同构);③ 现有 design-review 原样保留 = 任何运行时都有可用设计审查路,无功能洞;④ **相比原 X**:不需要"扁平 fork 跑 scout"这条新路(那是 X 的路 B),Y 直接复用现有 4 维路,改动更小、风险更低。
- **🟢 上抛点已定**:`.claude/workflows/` 新目录分发 + 纳凭证义务 = 用户拍板保 A;目录命名 `workflows/`(ultracode 约定名)。decision 文件 §7.4 / §8.4。

#### D-A5 循环依赖澄清:**审本 spec 用当前 design-review(治理面 A/B/C bootstrap-4),非本 feature 的 scout**

- **澄清(显式写清,挡"用没造好的东西审造它的 spec")**:
  - 本 spec(`2026-06-13-dynamic-review-scout-design.md`)是 **治理面**改动?——本 spec 改动落点(design-review SKILL / review-rules.md / setup.sh / credentials.conf / credentials-rules.md / CLAUDE.md)**全命中 credentials.conf**(治理规则/skills/setup/hooks),故本 spec 实施收口走 **治理审查**(A/B/C bootstrap-4 维),产 audit 凭证(§1.6 凭证义务)。
  - **审本 spec 文档本身**(design-review 阶段):用**当前** design-review skill 的现状路径。当前 design-review 对治理面 spec 走 SKILL「对抗式 A/B/C 模板(治理面改动审查时嵌入)」段(bootstrap-4 维),**非**本 feature 待造的 scout。
  - **时序无环**:本 feature 造的 scout 用于**未来** design 类 feature 的审查;审**本 spec** 用的是**已存在**的 design-review。两者时间错开 = bootstrap 自举正常形态(对齐 P0.9.1「本 spec 用旧 4 维 ad-hoc 审,落地后新机制反审」先例,grep 实证 specs/2026-04-17 L17)。
- **依赖类型澄清**:这不是**模块循环依赖**(§2 模块图无环),是**流程时序**问题。模块层 workflow 不依赖 skill;时序层"造它的 spec 用旧机制审"是 bootstrap,不算缺陷(§1.6 bootstrap 不可证;feedback_unprovable_in_bootstrap)。
- **Y 下额外清晰**:Y 不改现有 4 维 design-review,故"用当前 design-review 审本 spec"更无歧义——审本 spec 用的路与本 spec 保留的活备份路**是同一条**(现有 4 维),本 spec 只是在它旁边 ADD 了 scout 路。
- **落地动作(Y 缩小 covers)**:本 spec 收口时,调度者按 review-rules 治理行 fork bootstrap-4(+触点完整性维,因本改动跨多文件 + 加分发 glob,命中"跨文件计数/枚举 + 分发链")挑战者,产 audit,covers 列 §8.1 全部改动文件(Y 缩小集:SKILL / review-rules / setup.sh / credentials.conf / credentials-rules / CLAUDE.md×2 + 两新建)。

#### D-A6 触点完整性清单(Y 缩小集):见 §8.1(逐文件落实)+ §8.3(grep 自核命令)

- 裁决(Y / 收敛闭合):**"4 维→2 维全仓同步"取消**——现有固定 4 维路**原样保留**,故 `design-reviewer.md` / `synthesis-rules` **L113/L151 维序** / `design-rules`(L61/L181 等)/ `credentials-rules §7 L228` / model-route / references **不改**。改动 = **ADD**:SKILL 加分支 / review-rules 加 scout 注 / **synthesis 适用范围四处 ADD scout 行**(活规则义务,非改维序)/ QUICKREF + CLAUDE×2 最小注 / 分发凭证加行。**枚举尽力而为,完整性靠 §8.3 CMD1 全仓 git diff 兜底**(#3/#4)。

### 7.3 RUBRIC 应对方式(§1.6 风险标记展开 — Y 诚实)

- **惩罚项「简洁性」+ 过度工程化反向追问(诚实)**:
  - **反向追问("不现在 author 脚本会怎样")诚实回答**:不 author 脚本 → ultracode 用户拿不到 scout 的"现推维 + 确定性扇出";**但设计审查不缺失**(现有固定 4 维 design-review 仍在,活备份)。即 workflow + scout 的价值是"给 ultracode 用户一个动态推维 + 比即兴更可靠的执行壳",**不是**"补功能洞"。**用户已决定保 A**,故采纳此增益。
  - **诚实增益边界(不说普适根治 bug)**:scout/workflow 路 = **ultracode 在场时**确定性扇出(`parallel()` 屏障,比即兴手动发 N 个 fork 可靠,process-audit P-3 实证踩过串行)+ scout 隔离推维;**非 ultracode 路**走现有 design-review,仍靠 review-rules「单 turn 一次性并行 fork」约束(同现状,本功能不碰)。增益仅 ultracode 兑现,不普适。
  - **简洁性应对 + FloorTable 三行反向追问(🟡-7)**:schema/floor 表 `reviewType` 参数化(FloorTable 三行)、类型无关 — 为 code/治理留口。**反向追问"不写 3 行怎么满足用户'架构覆盖三类'?"**:用户明确要了"架构三类通用"(§1.1/D5),floor 表三行**正是该需求的具体载体**;加 code/governance 2 行明标"留口不接线"成本近零(纯数据行,无实现代码)。不写 3 行 = 无法满足已确认需求 → **判定:保留 3 行合理(非过度工程;非投机预留,是已确认三类的载体)**。**诚实边界**:workflow 脚本本身只 design 一个真消费者(单消费者账),用户拍板保 A 接受;Y 下未触碰现有路,简洁性风险只在新增 scout 路自身。
- **惩罚项「一致性」(偏离全扁平 fork)的应对(Y 诚实)**:design-review **仍是 skill**(入口不变);执行开头**加分支**——ultracode 开调 workflow、关走**现有固定 4 维流程(原样不动)**。**现有扁平 fork 4 维路零改动**,与 harness 现状完全一致;scout 路是**并排 ADD** 的新机制,与现有路并存(§2.2)。Y 比 X 更一致:不碰现有路。
- **诚实:原始痛点在非 ultracode 路未解(🟡-9,Pathological Optimist 自检,别用活备份粉饰)**:本功能动机(§1.1)= 解"设计审查永远固定 4 维、空 RUBRIC 自仓库不灵活"的痛点。**但动态推维仅 ultracode 路兑现**;**非 ultracode 路(含 harness 自仓库默认运行 / 空 RUBRIC 场景)保持固定 4 维,原始痛点在该路依然未解**。"活备份不丢能力"说的是**审查不缺失**,**不等于**"痛点已解"——这两件事不能混。在 ultracode 未普及前,多数实际运行可能走非 ultracode 路,即痛点在主流路径上仍在。如实承认:本功能是"给 ultracode 路解痛点 + 给其余路保底",**不是**全路径解痛点。
- **Workflow API 出处(🟡-6)**:并发 ~min(16,核数-2)/ 单 prompt 64kB 软上限 / 1000-agent 兜底 / `phase`-`agent({schema})`-`parallel` 钩子——**依据 = Workflow 工具契约(Claude Code ultracode 运行时)**,非凭空断言;§3.1/§3.2/§3.3/§5.1 引用处均标此出处。
- **凭证义务(Y 缩小)**:命中 credentials.conf 的改动集缩小(SKILL/review-rules/setup.sh/credentials.conf/credentials-rules/CLAUDE×2)→ 收口产 audit(D-A5 落地动作;§8 covers 清单);用户拍板 `.claude/workflows/*` **纳入**凭证义务(§7.4)。
- **触点完整性(Y 大幅缩小)**:"4 维→2 维全仓同步"消失;只 ADD scout 注的最小集(§8.1)+ grep 确认未误改现有 4 维(§8.3)。
- **bootstrap 不可证**:scout 推维质量落地前不可证 → §6.2 声明 + 推 meta-L4 实战;但本 spec 内具体可证漏洞(循环依赖 D-A5、触点断链 §8、schema 字段断链 §9)已保留并核。
- **奖励项「scout 路确定性扇出 + 隔离(ultracode 专属,非普适根治)」**:ultracode 在场跑 workflow 时 `parallel()` 屏障结构上确定性扇出;非 ultracode 走现有路靠 review-rules 约束(同现状)。诚实标条件边界,不说"普适根治 bug"。
- **奖励项「强化公设1(scout 路)」**:scout 独立 fork 比调度者自己推维更隔离(scout 路内成立)。
- **奖励项「挡 spec-gap-masking(scout 路)」**:skipped_candidates 强制留痕。
- **奖励项「活备份不丢能力」**:现有固定 4 维 design-review 原样保留,任何运行时都有可用设计审查路(scout = 增量增强,非替代,无功能洞)。

### 7.4 写入 docs/decisions/ 的项(用户已拍板 🟢)

- **D-A4 决策已定** → `docs/decisions/2026-06-13-review-scout-workflows-dir.md`:**用户拍板"保 A"= 分发 + 纳凭证义务**(三方案中 A),并要求实现成 **Y(ADD 不替换:scout 并排,现有 design-review 活备份)**。decision 文件状态 🟢,后续影响已记(含 Y 框架)。
- 其余 A-1/A-2/A-3/A-5/A-6 = 实现/流程细节裁决(不新增架构方向),记本节,不单独建 decision 文件。

**自检**:
- [x] 每个决策原因具体可验证:D-A1(脚本无 FS+64kB 实证)/D-A2(动机本体+反向追问)/D-A3(实测标记串 grep 可验)/D-A4(对齐现 setup.sh 段 + Y ADD 框)/D-A5(grep P0.9.1 先例)/D-A6(Y 缩小集分类)— 无"更好/更灵活"空话。
- [x] 无决策与架构冲突:自仓库无 ARCHITECTURE.md;与 CLAUDE.md 角色分离/二公设一致(scout 独立 fork = 做审分离);Y 下现有架构零改动,一致性更强。
- [x] 无决策与 RUBRIC 惩罚项冲突:简洁性/一致性已 §7.3 诚实应对(Y 增益边界明确,不说普适根治)。
- [x] 不确定决策(D-A4)已写 decisions 标 🟡。
- [x] §1.6 每个 RUBRIC 惩罚项有应对:简洁性/一致性/凭证/触点/bootstrap 全 §7.3 列。

---

## 8. 与既有系统的影响

### 8.1 需要改动/新建的文件

| 文件 | 改什么 | 为什么 | 影响范围 |
|------|-------|--------|---------|
| `.claude/workflows/review-scout.workflow.js` | **新建** — 侦察→对抗两 phase 编排 | D6 载体 | 被 design-review SKILL 调用 |
| `.claude/agents/review-scout.md` | **新建** — **单一职责 = scout 推维 prompt**(读上下文推 SCOUT_SCHEMA;含 A-3 判据 + B-8 加维正向引导)。**不含挑战者 focus 库**(focus 库 = workflow.js 常量,fix#1);**地板维表权威住 review-rules 设计行 scout 注(🟡-2 钉死,非本文件)** | M-scout-agent | 被 workflow fork |
| `.claude/workflows/review-scout.workflow.js`(focus 常量补) | 新建件**内含 floor/已知维 focus 常量库**(方向盘对齐/自洽/完整/过度工程化;workflow 无 FS,focus 必在脚本内 — fix#1 单一住址,非双源) | (并入上方 workflow 新建行) | workflow 脚本 |
| `.claude/skills/design-review/SKILL.md` | 「执行」开头**加运行时分支段**:"Workflow/ultracode 可用 → 调 review-scout workflow(reviewType=design);否则 → 走下面现有固定 4 维流程"。**下面现有 4 维流程逐字不动**;**scout 路综合维序说明钉在此 scout 分支段**(#5 消"或",单一住址) | 改动(只加分支,不动现有流程) | 凭证义务命中(`.claude/skills/*/*.md`) |
| `docs/governance/review-rules.md` | 设计行(L12)**保留现有"自洽性/完整性/合理性/RUBRIC 对齐(4 维)"**作非 ultracode 默认,**新增一行/注**:"ultracode 时走 review-scout(地板 2 维:方向盘对齐+自洽性 + 动态加;**地板维表权威住此 scout 注**)"。**不把 4 维改 2 维**(治理层维名沿用"合理性",alias 注见 §1.3) | 改动(加注,不改 4 维) | 凭证义务命中(`docs/governance/*.md`) |
| `docs/governance/synthesis-rules.md` **四处 ADD**(🟡-1/-2 fix#2) | 适用范围是**活规则义务**(L98 明说"对齐本文件适用范围表")→ **四处各 ADD scout 行**:① 主适用范围表(L9-19)加 `\| review-scout \| 动态 N(地板 2+加) \| 调度者 \|`;② 事前规则5 清单(L99)加 `- review-scout(scout 驱动 N 挑战者)`;③ 事后规则5 适用范围(L169)加 review-scout;④ 何时读(L3)枚举加 review-scout。**L113/L151 维序零改**(服务现有 4 维路) | 改动(四处 ADD 行,维序零改) | 凭证义务命中(`docs/governance/*.md`) |
| `setup.sh`(实物 = `harness/setup.sh`,无根级) | 新增 `.claude/workflows/` mkdir + cp review-scout.workflow.js(用户拍板保 A) | 分发(D-A4 🟢) | 凭证义务命中(`setup.sh`) |
| `.claude/hooks/credentials.conf` + `docs/governance/credentials-rules.md §2` | **新增** `.claude/workflows/*` include glob(audit)— 用户拍板纳凭证义务;conf 与 §2 人读表双写同步(行序一致)。**注(🟡-6)**:review-scout.md 落在已有 `.claude/agents/*.md` glob,**自动入凭证不需改 conf**;只有 workflow.js 需此新 glob | 分发凭证归属(D-A4 🟢) | 凭证义务命中(conf 自身 `.claude/hooks/*` + governance) |
| `CLAUDE.md`(根治理入口,L30) | 角色分离表「设计审查」行**最小注**:行尾或备注加"(ultracode 下走 review-scout:scout 现推维)";**不动现有"4 个挑战者 / 自洽性/完整性/合理性/RUBRIC 对齐"描述** | 触点(加注,不改 4 维) | 凭证义务命中(根级,covers 写 `<root>/CLAUDE.md`) |
| `harness/CLAUDE.md`(M4 分发模板,L16 + L112) | 同根 CLAUDE.md 角色分离表行**最小注**(L16,与根双写)+ Skill 全局地图 design-review 行(L112)加"(ultracode 走 scout)"注;**均不改现有 4 维描述** | 触点(加注,2 处;角色分离行与根双写对) | 凭证义务命中(M4 在 hook `--relative` 视角 = `CLAUDE.md`) |
| `QUICKREF.md`(L44) | Skill 表 L44`design-review ... fork reviewer team(4 并行子智能体)`**加注** "(ultracode 走 review-scout)";**保留 4 并行描述**;L13 工作流图泛指不动 | 触点(加注 L44) | **凭证义务不命中**(实核 credentials.conf:无 `QUICKREF.md` 行、无顶层 `*.md` glob)→ **不进 covers**,但仍要改(触点完整性 ≠ 凭证义务) |

> **两新建件凭证状态(🟡-6 分别标清)**:
> - `.claude/agents/review-scout.md` → 落已有 `.claude/agents/*.md` glob → **自动入凭证,不需改 conf**;新建即在 covers 义务内。
> - `.claude/workflows/review-scout.workflow.js` → **无现成 glob 命中** → 须新增 `.claude/workflows/*` 到 conf + credentials-rules §2(双写)。

> **Y 缩小集对照(相比原 X 删掉的改动;第 3 轮再缩)**:
> - **design-reviewer.md:不改、scout 路零关系**(原 X 要拆 4 维 prompt / 2 轮的"内联副本""运行时 Read"都不成立;第 3 轮 scout 路 prompt 100% 自有,与本文件零关系 — 🔴 / §3.3 / §8.4)。
> - **synthesis-rules:L113/L151 维序零改;适用范围四处 ADD scout 行**(主表/L99/L169/L3,活规则义务,合 Y 只加不换 — §8.4 fix#2)。
> - **design-rules Fork失败降级段 + L61 角色分离段:不改**(服务现有路 — §8.4)。
> - **credentials-rules §7 L228 + model-route + references 多图:不改**(描述现有路,Y 下准确 — §8.4)。

### 8.2 触点分类依据(D-A6 / Y — 改哪些、不改哪些)

> **Y 关键**:现有固定 4 维路**原样保留**,故**不存在"改 4 维维序"的触点**;所有改动是 **ADD scout 注 / 分支 / 适用范围行 / 分发行**(synthesis 适用范围四处 ADD scout 行 = 活规则义务,非改维序)。
> **枚举尽力而为(#4 诚实)**:下表 + §8.4 力求列全,但**不声称已穷尽**;完整性靠 **§8.3 CMD1 全仓 `git diff --stat`** 结构兜底(任何现有路文件入 diff = 违 Y 被逮),终结触点打地鼠。

| 不改类 | 实例(grep 命中) | 为何不改 |
|---|---|---|
| **现有 design-review 固定 4 维路(Y 活备份)** | design-reviewer.md 4 维 prompt(L67-323,第 3 维 L198「过度工程化」)/ synthesis **L113 + L151 维序**(适用范围四处是 ADD 非改)/ design-rules L61 角色分离 + L181 Fork失败降级 / SKILL 现有第一步 4 挑战者 | **D13 ADD 不替换**:现有 4 维路原样作活备份;**scout 路与 design-reviewer.md 零关系**(不读/不抄/不镜像 — 🔴 第 3 轮)。改它即违 Y |
| **治理/参考层 design-review 4 挑战者引用(描述现有路)** | model-route.md L41/L58/L127(模型路由 swap 行)/ references:business-module-map L44 / scaffold-vs-ultracode-map L50 / recommended-tools L28 / 2026-05-22-self-check L133 / direction-overview / ROADMAP L109 | 均描述**现有 4 挑战者路**,Y 下现有路不变 → 描述仍准确,**不改**(详 §8.4) |
| **challenger-orientation §1.2「design-review 4 挑战者专属」** | challenger-orientation.md L44 | scout 路薄包装让挑战者 Read 它取**通用方法论/数据来源/陷阱**(§1.1 区),**不取** §1.2 固定 4 维框定(scout 是动态 N);**不改它**,§3.3 注明"§1.2 固定框定不适用 scout"避免误导 |
| bootstrap-4 维(治理审查) | design-reviewer.md B 段 / evaluator.md B 段 / review-rules L20 / SKILL A/B/C 段 / 所有 audit 的"bootstrap 4 维" | D4/§1.3 不动 D7;治理审查基线,非 design 地板 |
| evaluate 4 维 | evaluator.md(RUBRIC/架构/文档/Slop)/ QUICKREF evaluate 行 | 方向评估维度,非设计审查 |
| 历史 audit / 归档 / 旧 spec | docs/audits/*.md / docs/completed/*.md / 2026-04-17 / 2026-06-13-governance-single-layer 等 | immutable 考古层(R12「不追溯改写历史」) |
| brainstorming「四维识别」 | README.md L268(模糊/缺失/冲突/隐含假设) | 需求识别四维,与审查无关 |

### 8.3 触点完整性 grep 自核命令(收口前跑 — Y 缩小集;🔴-2 修 pattern + 行号 bug)

> **🔴-2 修正**:旧命令 2 用全称「自洽性 / 完整性 / 合理性」在 synthesis(用缩写「自洽 / 完整 / 合理」)**零命中**(假绿);且把适用范围行误标 L113/L151(实际 **L15**;L113=「4 维度独立评分」/L151=「维度固定顺序」是另两处)。下面 pattern 已校准为**能真命中**的写法 + 正确行号。

```bash
# 1. 【结构兜底 — #3 终结触点打地鼠】全仓 git diff,无文件参数
git diff --stat
#   判据:改动集**只应出现 §8.1 列的 ADD/新建文件**(2 新建 + SKILL + review-rules + synthesis[四处 ADD] + harness/setup.sh + credentials.conf + credentials-rules + CLAUDE×2 + QUICKREF)。
#   任何现有路文件(design-reviewer.md / synthesis L113-L151 维序段 / design-rules / model-route / references / README / ROADMAP / multi-agent-review-guide …)
#   出现在 diff 里 = 违 Y,回退。**枚举漏一个也被全仓 diff 逮到**(枚举尽力而为,完整性靠本条兜底)。
git diff harness/docs/governance/synthesis-rules.md   # 期望:只有四处 ADD 新行(主表/L99/L169/L3 各 +1);L113/L151 维序原文零改(diff 无维序段)
# 2. 现有 4 维原文仍在(没被误删/误改)— synthesis 用实际缩写
grep -nE '自洽 / 完整 / 合理|4 维度独立评分|维度固定顺序' harness/docs/governance/synthesis-rules.md
#   期望命中: 主表行(自洽/完整/合理/RUBRIC)+ 4 维度独立评分 + 维度固定顺序 原文仍在
grep -nE '过度工程化挑战者' "harness/.claude/agents/design-reviewer.md"   # 期望 L198 原文仍在(第 3 维实际名)
grep -nE '4 个并行子智能体|design-reviewer fork 失败' harness/docs/governance/design-rules.md  # 期望 L61 + L181 原文仍在
# 3. 现有路 4 挑战者引用(治理+参考层,Y 下不改,确认仍在)— pattern 加宽覆盖 references 实际措辞
grep -rnE 'design-review 4 挑战者|4 并行子智能体|fork reviewer team|design-review 多智能体|4 维并行挑战者|4 挑战者扇出|4 路并行扇出|4 维选定|4 维约 [0-9]+ 条|自洽性/完整性/合理性/RUBRIC' README.md harness/README.md harness/docs/governance/model-route.md harness/docs/governance/design-rules.md harness/docs/references/ harness/docs/ROADMAP.md
#   期望: README×2 / model-route L41/L58/L127 / references(business-module-map L44+L50 / scaffold L50+L57 / recommended-tools / 2026-05-22 / challenger-orientation §1.2 / multi-agent-review-guide L123)/ ROADMAP L109 原描述仍在
# 4. ADD 的 scout 注/分支/synth 行已落(新增物存在)
grep -rnE 'review-scout|ultracode .*走|走 scout' harness/docs/governance/review-rules.md harness/docs/governance/synthesis-rules.md "harness/.claude/skills/design-review/SKILL.md" harness/QUICKREF.md CLAUDE.md harness/CLAUDE.md
#   期望: review-rules scout 注 + synthesis 四处 scout 行 + SKILL 分支 + QUICKREF/CLAUDE×2 注 各命中
# 5. 双写对核(CLAUDE.md×2 角色分离表加注语义一致)
diff <(grep '设计审查' CLAUDE.md) <(grep '设计审查' harness/CLAUDE.md)
# 6. 分发 + 凭证双写(setup.sh 实物在 harness/ 下,无根级!🟡-5 path 修正)
grep -nE 'workflows' harness/setup.sh "harness/.claude/hooks/credentials.conf" harness/docs/governance/credentials-rules.md
#   期望: harness/setup.sh 复制段 + conf glob 行 + credentials-rules §2 人读表行 各命中
# 7. AGENTS×2 仍零命中(不改)
grep -nE '设计审查|4 维' AGENTS.md harness/templates/AGENTS.md   # 期望: 无输出
```

> **设计期 grep 实测记录(收敛闭合 pass;含实跑验证)**:
> - **改动 = ADD,文件清单**:① 2 新建(workflow[含 focus 常量库] + scout agent[纯推维])② SKILL 加分支 + scout 维序说明 ③ review-rules 加 scout 注(地板维表权威住此)④ **synthesis-rules 四处 ADD scout 行**(主表/L99/L169/L3;fix#2)⑤ harness/setup.sh 加复制段 ⑥ credentials.conf + credentials-rules §2 加 glob 行 ⑦ CLAUDE×2 加最小注 ⑧ QUICKREF L44 加注。
> - **明确不改(Y 活备份)**:design-reviewer.md(第 3 维 L198「过度工程化」,**scout 路与它零关系**)/ synthesis-rules **L113/L151 维序**(适用范围四处是 ADD 不是改维序)/ design-rules **L28/L30/L40-43/L59/L61/L74/L78/L171/L175/L181** / credentials-rules §7 L228 / model-route L41/L58/L127 / multi-agent-review-guide L123 / references 多图 / ROADMAP L109 / README L25/L27 —— 现有 4 挑战者路原样。
> - **🔴 第 3 轮根治**:scout 路挑战者 prompt 100% scout 路自有;**floor/已知维 focus = workflow.js 常量**(workflow 无 FS,focus 必在脚本内;fix#1 修取数断链),review-scout.md 回归纯推维;不读/不抄/不镜像 design-reviewer.md → 无双源同步义务。
> - **触点枚举尽力而为 + 全仓 diff 兜底(#3/#4)**:本记录枚举力求全,但**不声称已穷尽**;完整性靠 **§8.3 CMD1 全仓 `git diff --stat`** 兜底——任何现有路文件出现在 diff = 违 Y 被逮。终结触点打地鼠。
> - **凭证 vs 触点两套独立**:凭证命中 = SKILL/review-rules/synthesis/harness setup.sh/credentials.conf/credentials-rules/CLAUDE×2 + review-scout.md(`.claude/agents/*.md` 自动)+ workflow.js(新 glob);QUICKREF + README×2 + references(非 governance)改/可不改但**不命中凭证**;model-route 在 governance 命中凭证但**本功能不改它**→ 不进 covers。
>
> **实跑验证(🟡-5 防假绿 + #3 全仓 diff,设计期在 harness/ 真执行)**:
> - **CMD1 全仓 `git diff --stat`**:命令可执行(无文件参数,不会 file-not-found);判据 = diff 只含 §8.1 ADD 文件,枚举漏一也被逮。
> - **CMD3 加宽 pattern**:实跑命中 18 行 — 覆盖 README×2 / model-route L41/L58/L127 / references(business-module-map L44+L50 / scaffold L50+L57 / multi-agent-review-guide L123 / challenger-orientation §1.2)/ ROADMAP L109,旧窄 pattern 漏掉的"4 维并行挑战者/4 路并行扇出/4 维约 N 条"现全命中(防假绿)。
> - **CMD6 setup.sh 路径**:根级 `setup.sh` **No such file**(旧假绿根因已修);`harness/setup.sh` 存在 → 真命中。
> - **CMD2/CMD7**:现有 4 维原文 + design-reviewer L198 + design-rules L61/L181 真命中;AGENTS×2 零命中。
> - 全组命令无 file-not-found,判据条条可验(非假绿)。

### 8.4 不改动但需验证兼容的

| 文件/模块 | 改/不改 + 凭证命中? | 理由 |
|----------|---------|------|
| `.claude/agents/design-reviewer.md`(**全文不改 — Y 活备份**) | 不改 / 凭证命中(本功能不改→不进 covers) | ① 整块 4 维 prompt 原样服务非 ultracode 路;② **scout 路与它零关系**(不读/不抄/不镜像 — 🔴 第 3 轮;scout 挑战者 prompt 100% 自有,floor/已知维 focus 住 workflow.js 常量);③ A/B/C 治理面段不动(本 spec 自身走它 — D-A5)。收口 git diff = 空 |
| `docs/governance/synthesis-rules.md` **四处 ADD / L113+L151 维序不改**(🟡-2 fix#2) | **主表+L99+L169+L3 改(各 ADD scout 行)/ L113+L151 维序不改** / 凭证命中 | 适用范围是**活规则义务**(L98「对齐本文件适用范围表」)→ scout 路同受事前5/事后5/D8 综合治理,故主适用范围表(L9-19)+ 事前5 清单(L99)+ 事后5 适用范围(L169)+ 何时读(L3)**四处各 ADD scout 行**。**L113/L151 维序**服务现有 4 维路**不改**;scout 路维序住 SKILL scout 分支段(§3.5)。git diff = 四处各 +1 行,维序段无 diff |
| `docs/governance/design-rules.md`(多处,**全不改 — Y**) | 不改 / 凭证命中(不改→不进 covers) | L28/L30 规模判断、L40-43 spec§0/emergency、L59/L61 角色分离、L74/L78/L171/L175 design-review 流程步、L181 Fork失败降级——**全描述/服务现有路**,Y 不碰。收口 git diff = 空 |
| `docs/governance/credentials-rules.md` §7 L228(证据档位)(**不改正文 — Y**;**仅 §2 加 workflows glob 行**) | §7 不改 / §2 改(加 glob 行,凭证命中) | L228"design-review 4 维审查通过"对现有 4 维路仍准确,不改;scout 路证据由 scout 文档自述。仅 §2 凭证要求表加 `.claude/workflows/*` 行(与 conf 双写) |
| `docs/governance/model-route.md` L41/L58/L127(🟡-4)| **不改 / 凭证命中(governance glob)但本功能不改→不进 covers** | 三处「design-review 4 挑战者」= 模型路由 swap 行 + 审查链路,描述**现有路**,Y 下不变 → 准确,**不改** |
| `docs/references/`(business-module-map L44+L50 / scaffold-vs-ultracode-map L50+L57 / recommended-tools L28 / 2026-05-22-self-check L133 / direction-overview / **challenger-orientation §1.2 L44** / **multi-agent-review-guide L123**)(🟡-4)| **不改 / 凭证不命中(references 非 governance glob)** | 现役参考图/指南,「design-review 4 维/4 挑战者/自洽性·完整性·合理性·RUBRIC」描述**现有路**,Y 下准确,**不改**。challenger-orientation §1.2:scout 路用其通用方法论(§1.1),§1.2 固定框定不适用 scout(§3.3 注明) |
| `docs/ROADMAP.md` L109(🟡-4)| **不改 / 凭证不命中** | 审查链路枚举,描述现有路,Y 下准确,不改 |
| **`README.md`(根)L167 + L25/L27 + `harness/README.md` L124/L174/L182/L244**(🟡-4;精确行)| **不改 / 凭证不命中** | 「4 挑战者 / 4 并行子智能体 / fork reviewer team / 多智能体审查 / 实现-审查分离原则」均描述**现有 4 维路 / 通用原则**,Y 下准确,**不改**。README 不在 credentials.conf glob → 不进 covers |
| `.claude/skills/evaluate/SKILL.md` + evaluator.md | 不改 / — | evaluate 的 4 维不受影响(§8.2 不改类) |
| `AGENTS.md`(根)+ `templates/AGENTS.md` | 不改 / 凭证命中(不改→不进 covers) | grep 零命中"设计审查"/"4 维",不改 |
| `QUICKREF.md` | 改 L44(加注)/ **凭证不命中** | 无 glob 命中 → 改但不进 covers(触点 ≠ 凭证) |
| `check-context-chain.sh` | 不改 / — | 自仓库无 docs/context/,不涉活上下文链,exit 0 静默 |

**自检**:
- [x] 改动已有文件时调用方都考虑:SKILL 加分支 → 调用方 = 调度者(入口);review-rules 加注 → 消费方 = SKILL/CLAUDE(已同步);现有 4 维路消费方不受影响(零改动)。
- [x] 新旧模块交互无不兼容:scout 路 ADD 并排,现有 4 维路零改动并存(§2.2);ultracode 关回落现有路(D-A4)。
- [x] §2 标"改动/新建"的模块都在 §8.1 列具体文件:M-skill→SKILL / M-floor-table→review-rules / **M-synth-ADD→synthesis 四处 ADD** / M-分发凭证→harness setup.sh+conf+credentials-rules §2 / M-地图注→CLAUDE×2+QUICKREF + 2 新建(workflow 含 focus 库);**M-reviewer(scout 路零涉及)/ M-现有路不动 → §8.4 列(零改动)**;§2↔§8 一致。
- [x] 触点完整性 grep 7 组覆盖 + **CMD1 全仓 diff 结构兜底(#3 终结打地鼠)+ 实跑验证**(🔴-2 pattern+行号;🟡-4 补 synthesis 四处/README×2/model-route/design-rules 多处/references[+multi-agent L123]/ROADMAP;🟡-5 setup.sh 路径修正+实跑;CMD3 加宽 pattern 实跑命中 18 行);枚举尽力而为 + diff 兜底;凭证 vs 触点两套独立已厘清。
- [x] D-A4 用户已拍板(🟢 保 A + Y),decision 文件状态 🟢(§7.4),无悬空 🟡。

---

## 9. 全局自洽性检查

- [x] **需求 ↔ 模块**:P0 场景1(ultracode 走 scout)→M-scout-wf 全链;P0 场景2(方向盘自适应)→M-scout-agent A-3;P0 场景3(非 ultracode 走现有 4 维)→现有 design-review 路(M-skill 分支,不改现有流程);P1→FloorTable 三类行 + reviewType 留口。每场景有路径(§2.1 自检)。
- [x] **模块 ↔ 接口**:M-scout-wf↔§3.1/3.5(+ floor/已知维 focus 常量库);M-scout-agent↔§3.2(纯推维);scout 路挑战者↔§3.3/3.4(**100% scout 路自有 prompt;floor/已知维 focus = workflow.js 常量;与 design-reviewer.md 零关系**);M-floor-table↔§4.1 FloorTable(权威住 review-rules scout 注);无孤岛模块(M-地图注/M-分发凭证/M-synth-ADD 职责=同步引用/分发/适用范围补行,经 §8.1 体现)。
- [x] **接口 ↔ 数据**:SCOUT_SCHEMA(§3.2)字段全在 §4.1 ScoutPlan;FINDING_SCHEMA(§3.4)在 §4.1 Finding/ChallengerReturn;入参 targets/reviewType/sessionIntent 在 §4.1/§3.1。
- [x] **数据 ↔ 边界**:ScoutPlan 各字段边界有处理 — inherited_floor(照抄不可改)/added_dimensions(空合法但 skipped 须解释,§5.1)/skipped_candidates(强制留痕)/rubric_mode(误判透明可纠,§5.1)。
- [x] **依赖 ↔ 架构**:自仓库无 ARCHITECTURE.md;依赖方向(§2.2)无环,符合 CLAUDE.md 做审分离(scout 独立 fork)。
- [x] **决策 ↔ 需求**:D1-D13 + A-1~A-6 均锚 §1 需求(§7.1/7.2 逐条注来源),无偏离边界(§1.3 不做清单:不接 code/governance、不动 D7、不动轻量路径、**不替换/不改现有 4 维路、不 shrink 全仓 4 维** — §8.2/§8.4 守住)。
- [x] **决策 ↔ 架构(Y)**:D6(workflow)/D-A4(ADD 分发)/D13(ADD 不替换)与 CLAUDE.md 现状架构**并存**:scout 路 ADD,现有扁平 fork 4 维路**零改动**作活备份(§2.2 / §7.3 一致性);Y 比 X 更一致(不碰现有路);D-A4 新目录用户已拍板 🟢 保 A。
- [x] **影响 ↔ 模块(Y)**:§8.1 改动/新建文件 ↔ §2.1 标"新建/改动"模块对应(2 新建 + M-skill/M-floor-table/M-synth-ADD/M-分发凭证/M-地图注);**不改模块(M-reviewer scout 路零涉及 / M-现有路不动:含 synthesis L113+L151 维序、design-rules、model-route、references)→ §8.4 列、git diff 应为空**;synthesis **适用范围四处 ADD scout 行**(活规则,非改维序);§2↔§8 一致;🟡-4 漏网(synthesis 四处 / README×2+L25/L27 / model-route / design-rules 多处 / references[+multi-agent L123] / ROADMAP)已全纳 §8.4,**完整性靠 §8.3 CMD1 全仓 diff 兜底**。
- [x] **RUBRIC ↔ 设计(Y 诚实)**:§1.6 每个惩罚项(简洁性/一致性/凭证/触点/bootstrap)→ §7.3 应对;奖励项**诚实化**(scout 路确定性扇出 = ultracode 专属增益,非普适根治 bug;活备份不丢能力)→ §7.3;Y 下触点/凭证风险大幅缩小(不碰现有路)。
- [x] **契约 ↔ 接口**:无 API 端点(§3 自检);schema 契约(SCOUT_SCHEMA/FINDING_SCHEMA)字段命名全文一致(reviewType/inherited_floor/added_dimensions/skipped_candidates/challenger_focus/why_this_time),§3↔§4 无字段断链。

### 9.1 决策状态(用户拍板 🟢)

1. **D-A4(🟢 已定)**:用户 2026-06-13 拍板"保 A" = `.claude/workflows/` 随 setup.sh 分发 + `.claude/workflows/*` 纳 credentials.conf 凭证义务 + 实现成 **Y(ADD review-scout 并排,不替换现有 design-review)**。decision 文件 `docs/decisions/2026-06-13-review-scout-workflows-dir.md` 状态 🟢(§7.4 / §8.4)。
2. **D13(🟢 已定)**:ADD 不替换,现有 4 维 design-review 原样作活备份。
3. **无悬空 🟡**:本轮所有原上抛点已由用户决策吸收;designer 侧无擅自决定的架构方向。

### 9.2 未发现需求缺陷

§1 需求摘要 + 方案方向 + D1-D13 自洽(Y 重对齐后无遗漏/矛盾)。A-1~A-6 均为 designer 可裁决的设计/流程决策(D-A4/D13 经用户拍板),非需求层缺口。

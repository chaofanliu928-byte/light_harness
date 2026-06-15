# 代码审查侦察(code-review-scout)系统设计

> 状态:第 1-9 节已填。本功能 = **给 review-scout 扩展代码审查(`reviewType='code'`)**,fork-N 同形,新建 harness 侧 **code-review skill** 入口(镜像 design-review SKILL 的运行时分支)。
> 规模:**重量级**(新建 1 skill + 改 review-scout.workflow.js + 改 review-scout.md agent + 改 review-rules.md governance + 凭证/地图 ≥4 工件)→ DESIGN_TEMPLATE 全节填写,不适用节写"不适用"+理由。
> 依据上游:`docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md`(review-scout 主设计;本文件复用其 SCOUT_SCHEMA / FINDING_SCHEMA / challengerPrompt 结构 / 编排,只新增 code 分支与常量)。
> 权威输入:本会话 designer 输入文件 A 需求清单(用户拍板) + B 维度分类 + C 两路权衡(推荐 A)+ D 待决策 + E 须覆盖工件 + F 守住 + G 自仓库 RUBRIC/ARCHITECTURE 语境。

---

## 1. 需求摘要

### 1.1 用户目标

把**代码审查**也接上 review-scout 的"动态选维"机制——和设计审查一样:一个独立 scout fork 读完代码 diff + 上下文之后**现推该审哪些对抗维**(钉一个最小地板兜底,其余按 diff 信号动态加),workflow 一维一挑战者并行扇出,调度者综合。落地宿主 = **新建 harness 侧 code-review skill**(镜像 design-review SKILL):开头探测 ultracode/Workflow 是否可用——在场→走 review-scout workflow(`reviewType='code'`)/ 不在场→回落现有 Superpowers `requesting-code-review`(不改 Superpowers 包)。

动机:设计审查已落地 scout 路(`reviewType='design'`),代码审查目前仍走 Superpowers 固定流程 + review-rules「代码类维度集」五节(RUBRIC / 架构合规 / 类型契约 / 简洁性 / 模块文档一致性),不管 diff 改了什么都是同一套静态维。本功能把"代码审查的对抗维"也变成 **scout 按 diff 现推**,与设计审查完全同形(用户要的),实现最小(workflow.js 已 `reviewType` 参数化,补 code 常量 + 两 prompt 函数加 reviewType 分支;**reviewScout 默认导出编排骨架/SCOUT_SCHEMA/FINDING_SCHEMA 不改**;两 prompt 函数体须改、design else 逐字保留 — A 簇诚实修订,见 §3.3)。

### 1.2 核心场景(按优先级排序)

> **机制 = fork-N 同形 + ADD 并排(同 design 路 D13)**:code-review scout 是 **ultracode 专属**的并排新路,**不替换** Superpowers 现有代码审查。两条是不同机制:
> - **ultracode 开** → 跑 review-scout workflow(`reviewType='code'`:scout 现推维 = code 地板 + 动态加)。**scout 特性 = ultracode 专属**(用户接受的取舍,同 design 路)。
> - **ultracode 关 / 非 Claude Code** → **回落现有 Superpowers `requesting-code-review`,不改 Superpowers 包**(已存在、不新建、不归档)。

1. **[P0] ultracode 在场:代码改动走 code-review scout**:开发者完成一批代码改动要审,**且 Workflow/ultracode 可用** → 新 code-review skill 执行开头分支 → 启动 review-scout workflow(传 `reviewType='code'` + targets 指针 + 会话意图)→ scout fork 读方向盘 / 代码 diff / spec / 决策史 → 产出 `{code 地板维 + 动态加维(每条带 diff 证据)+ skipped 候选}` → workflow 一维一挑战者 `parallel` 扇出 → 返回 `{plan, findings}` → 调度者按 `synthesis-rules.md` 综合判定。
2. **[P0] scout 自适应"方向盘对齐"维**(code 路内,复用 design 路 A-3 判据):scout 读 RUBRIC.md,检到已填→对齐 RUBRIC;检到空模板(harness 自仓库)→ 回落 CLAUDE.md 原则 + 二条公设。判据 100% 复用 design 路(D-A3),不另造。
3. **[P0] ultracode 不在场:走现有 Superpowers requesting-code-review**:Workflow/ultracode 不可用 → code-review skill 分支到**现有 Superpowers `requesting-code-review` 流程,原样调用,不改 Superpowers 包**。scout 的"动态推维"在此路不可得 = ultracode 专属取舍(同 design 路 D13)。
4. **[P0] either-or 分支 + spec 忠实性入 code 地板(D-C2 用户拍板)**:两路是 **either-or**——ultracode 开**只走 scout 路、不并跑 Superpowers**;ultracode 关才走 Superpowers `requesting-code-review`。因 ultracode 路不跑 Superpowers,Superpowers 内嵌的「spec 忠实性」在该路会留**真空** → 用户拍板让 **scout 地板兜住:code 地板 = 方向盘对齐 + 简洁性 + spec忠实性(3 维)**。「代码质量」不单设地板维——它已被「方向盘对齐」focus 的通用基线段(功能完整性/代码质量/测试/一致性/简洁性)覆盖(design 版含、code 版同构保留)。scout 路在 3 维地板之上再做"diff 驱动对抗维扇出"。
5. **[P1] 三层选维**(同 design 路三层架构):① **地板**(固定必跑,兜底)② **候选**(预定义 `CodeCandidateMenu`,scout 按 diff 选加不加、不加须 `skipped_candidates` 留痕)③ **发明维**(清单外按 diff 信号现推全新维);防乱发明双闸(不与地板/候选重叠 + `why_this_time` 引 diff 具体证据锚点)。

### 1.3 边界与约束

**本轮做(接通-usable,D-C4 倾向)**:
- **新建 code-review skill**(`.claude/skills/code-review/SKILL.md`):镜像 design-review SKILL 的运行时分支(ultracode 开→review-scout workflow `reviewType='code'` / 关→Superpowers `requesting-code-review` 回落)+ scout 路综合维序说明。
- **改 `review-scout.workflow.js`**:`reviewType='code'` 接线——`FloorTable.code` 填真数据(替占位为 **3 维:方向盘对齐 + 简洁性 + spec忠实性**)+ 新增 `CodeCandidateMenu`(类型契约合规 + 架构合规 + 模块文档一致性)+ 新增 **`FLOOR_FOCUS_CODE` 常量**(code 维 focus,scout 路自有、**不镜像 design-reviewer.md**;含 **code 版方向盘对齐** + **spec忠实性** + 简洁性 + 三候选 focus)+ **`scoutPrompt` 加 reviewType 分支**(候选菜单/被审材料指针/语境;governance 守卫)+ **`challengerPrompt` 加 reviewType 形参 + 三处串分支**(角色行/材料路径/location)。**design else 分支逐字保留现状(行为零变),非"零改函数体"**(A 簇修订;现两函数写死 design 串,见 §3.3)。
- **改 `review-scout.md`**:scout 推维步骤按 `reviewType` 切候选菜单 / 语境 / B-8 code 加维引导(现第 3 步硬编码 design 候选)。
- **改 `review-rules.md`**:代码行(L11)加 scout 注 + code 地板维表(权威住此,对齐设计行 scout 注;裁决五节与 scout 地板/候选的叠加关系)。
- **凭证/地图**:新 skill(`.claude/skills/*/*.md` glob 自动入凭证)+ review-rules(governance glob)+ synthesis-rules(governance glob,C 簇)+ workflow.js(`.claude/workflows/*` glob,2026-06-13 已立)+ review-scout.md(`.claude/agents/*.md` glob 自动)→ 收口须 audit;`FloorTable.code` 接线后纳入 credentials-rules §8 #6 已立的 FloorTable↔review-rules 双写对(三类逐类一致);CLAUDE.md×2 角色表「开发」行加注 + harness Skill 地图新增 code-review 行 + QUICKREF Skill 表新增 code-review 行(非映射行 L34)。

**不做(明确排除)**:
- **不改 Superpowers 包 / 不改 Superpowers `requesting-code-review` 流程**(回落路原样,不碰)。
- **不把 Superpowers 与 scout 叠加跑(仍 either-or)**:ultracode 开只走 scout 路、**不并跑** Superpowers `requesting-code-review`;Superpowers 仅作非 ultracode 回落(D-C2 用户拍板:不叠加)。
- **不为代码质量单设 scout 地板维**(D-C2):代码质量由「方向盘对齐」focus 的通用基线段(功能完整性/代码质量/测试/一致性/简洁性)覆盖,不另立专名维(避免与 Superpowers 同名维概念混淆 + 防冗余)。**spec 忠实性则入 code 地板**(见下"做"——either-or 下若不入地板会留真空,D-C2)。
- **不污染 design 路(`reviewType='design'`)**:design 语境 / 常量(`FloorTable.design` / `DesignCandidateMenu` / design 维 FLOOR_FOCUS)/ focus **零改**;code 扩展全部按 `reviewType` 分支,design 路逐字不退化(F 守住)。
- **不读/不抄/不镜像 `design-reviewer.md`**:code 路 focus 是 **scout 路自有**(住 workflow.js FLOOR_FOCUS 常量,code 语境),同 design 路第 3 轮根治。design-reviewer.md 服务的是设计审查非 ultracode 路,与 code 路零关系。
- **不接线 governance scout 路**(本轮只接 code;`FloorTable.governance` 留口不变)。
- **不预设 scout-vs-地板的硬门**(D-C3 倾向:无门,scout 每次读 diff 自由推 + 候选 skipped 留痕;同 design 路 §1.3「代码审查永远审、无不审门;其 scout-vs-地板的门留到扩展时定」现兑现为"无门")。
- **不为 code 造一堆用不上的留口**(G RUBRIC 简洁性:只接 code 一类真消费者,governance 行不动)。

**兼容性要求**:
- `reviewType='code'` 路依赖 Workflow 工具(ultracode 运行时,逐会话 opt-in)→ 下游分发 + 跨运行时拿不到 scout 路;**ultracode 不在场时回落现有 Superpowers `requesting-code-review`**(非降级,是另一条已存在的活路)。
- 与 design 路同 workflow 脚本共存:同一 `review-scout.workflow.js`,`reviewType` 分支隔离,互不污染。

> **维度命名据实(对齐 design 路 🔴-1 alias 处理)**:review-rules 代码行五节 = RUBRIC审查 / 架构合规 / 类型契约合规 / 简洁性审查 / 模块文档一致性(节标题用「简洁性审查」L66,而 L11 维度集 list + L19 地板维表注 + workflow.js 占位用维名「简洁性」)。**本 spec 一律用维名「简洁性」**(与 workflow.js 现占位 + review-rules L11/L19 双写源逐字一致 — 最小变更,不引入新 token `简洁性审查`);「简洁性审查」仅作 review-rules 节标题被引用。其余 code 维据实用 review-rules 实际名(架构合规 / 类型契约合规 / 模块文档一致性),不另造别名。

### 1.4 关联需求

- **依赖**:已落地的 review-scout 设计路(`reviewType='design'`,2026-06-13 spec)——本功能复用其 SCOUT_SCHEMA / FINDING_SCHEMA / challengerPrompt 薄包装 / 两阶段编排 / A-3 判据 / B-8 引导框架;只新增 code 分支与常量。`FloorTable` / `scoutPrompt(reviewType,…)` 的 `reviewType` 参数化(workflow L129/L128)是本功能的接线点。
- **依赖**:Superpowers `requesting-code-review`(回落路宿主)+ review-rules「代码类维度集」五节(Superpowers 激活时读)。
- **被依赖**:未来 governance scout 路接线走同一 workflow(同 reviewType 机制);本功能是"三类通用"的第二类落地(design→code→governance 渐进)。

### 1.5 已确认的决策(从需求对接阶段带入 — 输入 A 用户拍板,authoritative)

- **A1 机制 = fork-N 同形**:代码审像设计审一样,scout 现推维 → workflow `parallel` 一维一挑战者扇出 → 调度者综合。
- **A2 触发宿主 = 新建 harness 侧 code-review skill**:镜像 design-review SKILL——执行开头探测 ultracode/Workflow,在场→走 review-scout workflow(`reviewType='code'`)/ 不在场→回落 Superpowers `requesting-code-review`(不改 Superpowers 包)。
- **A3 scout 与固定维 = A(动态选维 + 地板兜底),不是 B(五节恒跑+加维)**:Superpowers 内嵌两段(spec 忠实性 + 代码质量)沿 Superpowers 恒跑、scout 不碰;scout 路在代码 diff 上做"按 diff 现推的对抗维扇出"。
- **A4 三层选维**:① 地板(固定必跑,兜底)② 候选(预定义,scout 按 diff 选加不加、不加须 `skipped_candidates` 留痕)③ 发明维(清单外按 diff 信号现推全新维);防乱发明双闸(不与地板/候选重叠 + `why_this_time` 引 diff 具体证据锚点)。
- **A5 地板大小/候选/focus/门/范围 交 designer 提方案**,影响架构/接口者标 🟡 交用户(本 spec §7 D-C1~D-C4 提方案,影响接口者写入 decisions)。

### 1.6 RUBRIC 风险标记(自仓库语境,代 RUBRIC = CLAUDE.md 原则 + 二条公设 — 输入 G)

**惩罚项 / 风险**:
- **简洁性**:code scout 路是 workflow 的第二个真消费者(design 之后)→ 缓解了 design 路"单消费者抽象"风险(reviewType 参数化现有 2 个真用户),不再是单次使用抽象。但须诚实标注:为 code 造的留口(CodeCandidateMenu / FLOOR_FOCUS_CODE)必须**全部被 code 路真用**,不为未来 governance 多造行(governance 行不动)。应对见 §7.3。
- **一致性**:code 路须与 design 路**完全同构 pattern**(同 SCOUT_SCHEMA / 同 challengerPrompt 薄包装 / 同 ADD-不替换框 / 同 ultracode 专属取舍),不引入第二套机制(否则碰一致性惩罚)。应对:全部复用 design 路结构,只换常量与语境。
- **凭证义务**:命中 credentials.conf 的改动 = 新 skill(`.claude/skills/*/*.md`)/ review-rules.md(governance)/ workflow.js(`.claude/workflows/*`)/ review-scout.md(`.claude/agents/*.md`)/ CLAUDE.md×2 → 收口须 audit 凭证。
- **触点完整性**:`FloorTable.code` 接线后须与 review-rules code 地板维表注**双写一致**(credentials-rules §8 #6);新 skill 入口须在 CLAUDE×2 角色表 + Skill 地图 + QUICKREF 同步登记。§8.3 grep 自核。
- **bootstrap 不可证**:code scout 推维质量在落地实战前不完全可证(同 design 路 §1.6)→ 声明 + 推后续实战验证,不算缺陷;但 spec 内具体可证漏洞必须保留。

**奖励项 / 体现**:
- **scout 路确定性扇出 + 隔离(ultracode 专属)**:同 design 路;`parallel()` 屏障结构上一次性并行扇出。诚实边界:仅 ultracode 在场兑现;非 ultracode 路走 Superpowers `requesting-code-review`(同现状)。
- **强化公设1**:独立 scout fork 比调度者自己推维更隔离。
- **挡 spec-gap-masking**:`skipped_candidates` 强制留痕,scout 无法静默漏候选维。
- **复用增量(简洁性奖励)**:code 路不新造编排/schema,100% 复用 design 路骨架,只加常量 + 分支,最小变更。
- **either-or 无重复 fork**:ultracode 路只走 scout(spec忠实性入地板、代码质量靠方向盘对齐基线),非 ultracode 才走 Superpowers——两路互斥,scout 地板维与 Superpowers 内嵌段**不会同时跑**,无冗余 fork。

---

## 2. 模块划分

> 本功能"模块"= harness 工件(skill / workflow 脚本 / agent 定义 / 治理文件)。harness 自仓库无 ARCHITECTURE.md 产品分层,故"所在层"按工件类型标注,依赖方向 = "谁调用谁"。

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动/复用不改 | 工件类型 / 层 |
|------|--------------|----------|--------------|
| **CM-skill**(`.claude/skills/code-review/SKILL.md`) | **新建** code-review skill 入口:执行开头运行时分支(ultracode 可用→调 review-scout workflow `reviewType='code'`;否则→回落 Superpowers `requesting-code-review`)+ scout 路综合维序说明 | 新建 | skill |
| **CM-wf-code**(`review-scout.workflow.js` 内 code 分支) | **改动**:① `FloorTable.code` 填真数据(3 维:方向盘对齐+简洁性+spec忠实性)② 新增 `CodeCandidateMenu` + `FLOOR_FOCUS_CODE` 常量(code 维 focus,含 code 版方向盘对齐 + spec忠实性)③ **`scoutPrompt` 加 reviewType 分支**(候选菜单/被审材料指针/语境;governance 守卫)④ **`challengerPrompt` 加 reviewType 形参 + 三处串分支**(角色行/材料路径/location;design else 逐字保留)。reviewScout 默认导出/SCOUT_SCHEMA/FINDING_SCHEMA 编排骨架不改;**design 路行为零变靠"else 分支逐字 = 改前文本"+ §8.3 prompt 文本等价核**,非"零改函数体" | 改动(加常量 + 函数内 reviewType 分支;design else 逐字保留) | workflow 脚本 |
| **CM-scout-agent**(`review-scout.md`) | **改动**:推维步骤按 `reviewType` 切候选菜单 / 语境 / B-8 code 加维引导(现第 3 步硬编码 design 候选 → 参数化为按 reviewType 取菜单) | 改动(加 reviewType 分支说明,不动单一职责=推维) | agent 定义 |
| **CM-floor-table**(review-rules 代码行 L11) | **改动**:代码行加 scout 注 + code 地板维表(权威住此,对齐设计行 scout 注);裁决五节与 scout 地板/候选的叠加关系 | 改动(加注,不改 Superpowers 五节描述) | governance |
| **CM-地图注**(CLAUDE.md×2「开发」行 + harness Skill 地图 + QUICKREF Skill 表) | **改动**:CLAUDE×2「开发」行加注(无独立「代码审查」行)+ harness Skill 地图 + QUICKREF Skill 表(L40-48)各新增 code-review 行;code-review 在 ultracode 下走 review-scout `reviewType='code'`、否则 Superpowers 回落 | 改动(加注 + 新行) | 入口地图 |
| **CM-Superpowers(回落路零涉及)**(Superpowers `requesting-code-review`) | **scout 路与它零关系**;ultracode 不在场时 code-review skill 原样调用它 | **不改(回落路,不碰 Superpowers 包)** | 外部 skill(Superpowers) |
| **CM-reviewer(零涉及)**(`design-reviewer.md`) | **scout 路与本文件零关系**(code 路 focus 住 workflow.js,不读/不抄/不镜像);本文件服务设计审查非 ultracode 路 | **不改(零关系)** | agent 定义 |
| **CM-design 路不动**(`FloorTable.design` / `DesignCandidateMenu` / design 维 FLOOR_FOCUS / design-review SKILL / synthesis 维序) | design 路常量/语境/编排原样 | **不改(F 守住,code 按 reviewType 分支隔离)** | workflow/skill/governance |

> **关键(ADD 不替换 + reviewType 分支隔离 — A 簇诚实修订)**:
> - code 扩展按 `reviewType` 分支挂在**同一** `review-scout.workflow.js` 上。**诚实**:`scoutPrompt` 与 `challengerPrompt` **函数体须改**(加 reviewType 分支),不是"零改函数体"——现状两函数写死 design 串(challengerPrompt L160「设计审查挑战者」/L166 `targets.spec`/L180「文档节」;scoutPrompt L136 `DesignCandidateMenu`/L139 `targets.spec`),"零改"与"code 须给 diffRef/code 语境"不可兼得。正解:**两函数加 `reviewType==='code'` 分支,`else` 分支逐字保留 design 现状**。`FloorTable.design`/`DesignCandidateMenu`/design 版 `FLOOR_FOCUS` 键/`reviewScout` 默认导出/SCOUT_SCHEMA/FINDING_SCHEMA = **真零改**。
> - **design 路行为零变的验证(不只靠常量零 diff)**:行为流经被改的两函数 → 须核 `reviewType==='design'` 时两函数产出的 prompt 文本**与改前逐字相同**(else 分支即改前文本)。判据写进 §6.1 + §8.3(prompt 文本快照对比)。
> - **scout 路 prompt 与 design-reviewer.md 零关系(沿 design 路第 3 轮根治)**:code 维 focus = workflow.js `FLOOR_FOCUS_CODE` 常量(code 语境,scout 路自有),不读/不抄/不镜像 design-reviewer.md → 无双源同步义务。
> - **粒度反向追问(过度工程化自检)**:为何新建 skill 而不复用 design-review skill 加 code 分支?——design-review skill 的输入段(L14 `ls *-design.md`)、回落路(design-reviewer.md 4 维)、综合维序全是 design 专属;code 审的输入是代码 diff、回落是 Superpowers、维序是 code plan,二者除"探测 ultracode + 调 review-scout workflow"外几乎无共享。合一会让一个 skill 背两套输入/回落/维序,违单一职责。故新建 skill 是必要拆分(对齐 A2 用户拍板"新建 code-review skill")。

### 2.2 模块依赖图(ADD 并排 — code scout 路 vs Superpowers 回落路)

```
调度者(code-review SKILL「执行」开头分支)
   │  探测:ultracode/Workflow 可用?
   ├──是──▶ code scout 路(新增)
   │         review-scout.workflow.js(reviewType='code')
   │           │ phase('侦察')                          │ phase('对抗')
   │           ▼                                         ▼
   │         agent(scoutPrompt('code',…),{SCOUT_SCHEMA}) parallel(dims.map → agent(challengerPrompt(d),{FINDING_SCHEMA}))
   │           = review-scout.md fork(纯推维,code 语境) = challengerPrompt 100% scout 路自有
   │           │ 读←代码 diff/spec(自读盘,A-1 复用)      ↑ floor(方向盘对齐/简洁性/spec忠实性)+候选维 focus = workflow.js FLOOR_FOCUS_CODE[维] 常量(按 reviewType 选)
   │           │                                            动态维 focus = scout 的 challenger_focus
   │           ▼                                            不读/不抄/不镜像 design-reviewer.md
   │         返回 {plan, findings} → 调度者按 synthesis-rules 综合
   │                                 (code 路维序说明住 CM-skill scout 分支段:按 plan 维度清单读 findings)
   │           ★ ultracode 路【不并跑】Superpowers(either-or);spec 忠实性由地板维兜、代码质量由方向盘对齐通用基线兜
   │
   └──否──▶ 现有 Superpowers requesting-code-review(原样调用 = 回落路)
             Superpowers 流程(内嵌 spec 忠实性 + 代码质量两段)+ review-rules 代码类五节
             → Superpowers 现有综合 → code review 结果

  注:two 路 either-or——ultracode 开走 scout 路(不跑 Superpowers);ultracode 关走 Superpowers(不跑 scout)。
      spec 忠实性在 ultracode 路由 scout 地板第 3 维保证(D-C2);代码质量由「方向盘对齐」通用基线段覆盖。
      故 ultracode 路无"Superpowers 两段真空",且不与 Superpowers 重复 fork。
```

- **code scout 路 prompt 与 design-reviewer.md 零关系**:`challengerPrompt(d)`(复用现有薄包装,不改函数)对每个 code scout 维产统一结构 prompt;code 地板/已知维 focus = workflow.js `FLOOR_FOCUS` 常量扩充的 code 维条目(scout 路自有,code 语境)/ 动态加维 focus = scout 的 `challenger_focus`。
- **Superpowers 回落路零改动**:ultracode 关时,code-review skill 原样调用 Superpowers `requesting-code-review`,不碰 Superpowers 包;Superpowers 内嵌两段在该(非 ultracode)路跑。ultracode 路不调 Superpowers(either-or)。
- **两路结果同构**:都产 findings → 综合 → code review 结果;差别仅维度集(scout 动态[地板 3 维+候选+发明] vs Superpowers 五节+两段)+ 综合主体(scout 路调度者按 plan / Superpowers 路按其流程)。

**自检**:
- [x] 每个模块只有一个明确职责?(CM-skill=code 入口分支+维序说明;CM-wf-code=code 常量+scoutPrompt 菜单分支;CM-scout-agent=推维按 reviewType 切语境;CM-floor-table=加 code scout 注;CM-地图注=加注;CM-Superpowers/CM-reviewer/CM-design 路=零涉及/不改)
- [x] 依赖方向(调用方向)无反向:code scout 路 调度者→workflow→(scout/挑战者);回落路 调度者→Superpowers;均无下层回调上层。
- [x] 无循环依赖:CM-wf-code 不依赖 skill;CM-skill 单向分支调 workflow 或 Superpowers;**code 路 focus 住 workflow.js 自身(无跨文件取数);不依赖 design-reviewer.md(零关系)**;FloorTable.code↔review-rules 是双写一致(文档上游、代码派生,非运行时依赖)。
- [x] 改动已有模块范围局限职责内:CM-wf-code 加 code 常量 + scoutPrompt/challengerPrompt 的 reviewType 分支(design else 逐字保留,行为零变;reviewScout 编排/SCOUT_SCHEMA/FINDING_SCHEMA 真零改);CM-scout-agent 只把第 3 步候选取数参数化(单一职责=推维不变);CM-floor-table 只加 code scout 注(不改 Superpowers 五节);design 路常量 + design else 分支文本零改(reviewType 分支隔离,§8.3 prompt 文本等价核)。
- [x] 每个核心场景(§1.2)有实现路径:P0 场景1(ultracode 走 code scout)→code scout 路全链;P0 场景2(方向盘自适应)→CM-scout-agent 复用 A-3;P0 场景3(非 ultracode 走 Superpowers)→CM-skill 回落分支;P0 场景4(either-or + spec忠实性入地板)→FloorTable.code 3 维 + 代码质量靠方向盘基线;P1(三层选维)→FloorTable.code + CodeCandidateMenu + 发明维。
- [x] 粒度合理:无"只一个函数的模块",无"做三件不相关事的模块"(已做反向追问 §2.1)。

---

## 3. 接口定义

> 复用 review-scout 主设计(2026-06-13)的接口契约;本节只标 code 路的新增/分支点,未变部分指向主 spec §3。

### 3.1 workflow 入参(调度者 → review-scout workflow,code 路)

复用现有入参契约(主 spec §3.1),`reviewType='code'`,`targets` 指针按 code 审查语境给:

```javascript
// review-scout.workflow.js 入参契约(code 路;reviewType='code')
{
  reviewType: 'code',          // 本功能接线 'code'(design 已接;governance 留口不接)
  targets: {                   // 指针(D9 固定类目规则,scout 用 Read/Grep 自读)
    spec: 'docs/superpowers/specs/<被实现 spec>.md',  // 被实现的设计 spec 路径(code 审查对照"实现 vs 设计";可缺=纯 bugfix 无 spec 时 scout notes 标)
    diffRef: '<git 改动范围引用,如 "HEAD~N..HEAD" 或分支名>',  // ★ code 路新增:代码改动范围(scout/挑战者据此 Grep/Read 改动文件)
    rubric: 'docs/RUBRIC.md',                        // 方向盘路径(A-3 判据读它)
    architecture: 'docs/ARCHITECTURE.md',            // 可缺(自仓库无 → scout notes 标跳过架构维)
    decisionsDir: 'docs/decisions/',                 // 决策史目录(scout 按需 Grep)
    auditsDir: 'docs/audits/'                        // 审查凭证目录(scout 按需 Grep)
  },
  sessionIntent: '<一行会话意图,措辞中性>'  // D9:只能 args 传;守 synthesis-rules 事前规则 5 边界、非结论引导
}
```

- **code 路新增字段 `targets.diffRef`**:代码改动范围引用(git ref / 分支 / commit 范围)。理由:design 路审"一份设计文档"(`targets.spec` 单文件够),code 路审"一批代码改动"(须知道改了哪些文件、改了什么),`diffRef` 让 scout/挑战者自己 `git diff`/`Read` 改动文件(自读盘,A-1 复用)。**design 路不传 `diffRef`**(分支隔离;workflow 对 design 路忽略该字段)。
- **`targets.spec` 在 code 路语义微调**:design 路 = 被审材料本体;code 路 = 被实现的设计 spec(用于"实现 vs 设计"对照,即 spec忠实性地板维的对照源)。**可缺**(纯 bugfix 无 spec 时,scout 在 notes 标"无对照 spec";**spec忠实性地板维仍跑**——回落对照"任务描述 / diff 自身意图",FLOOR_FOCUS_CODE['spec忠实性'] 已含此回落,§4.1)。
  - **F 簇 — sessionIntent 不当忠实度评分锚**:`sessionIntent` 守 synthesis 事前规则 5「只界定审什么边界、不暗示结论 / 不当评分依据」。故 spec 缺时,spec忠实性维**不把 sessionIntent 当"忠实度判据"**(那会让一行会话意图变成评分标准),而是对照 **diff 自身意图 / 任务描述**审"做的是否内部自洽、是否就是这批改动该做的";sessionIntent 只用于"主线-支线-关系"段界定审查范围。厘清见 §4.1 FLOOR_FOCUS_CODE['spec忠实性'] + §5.1 边界行。
- **调用场景**:调度者在 code-review SKILL「执行」开头做运行时分支,ultracode/Workflow 可用时走本接口(code scout 路);不可用时不调本接口、走 Superpowers `requesting-code-review`(回落路,与本接口无关)。
- **错误处理**:入参缺 `targets.diffRef` 且缺 `targets.spec` → workflow `log()` 报错并返回 `{plan:null, findings:[]}`,调度者视审查失败按 SKILL 错误处理重试。(运行时无 Workflow 工具 = 分支去走 Superpowers,非本接口错误。)

> **scoutPrompt 改动点(A 簇 — 三处串 → reviewType 分支;governance 留口守卫)**:现 `scoutPrompt(reviewType, targets, sessionIntent)`(workflow.js L128-151)写死 ① `DesignCandidateMenu`(L136)② `targets.spec` 作"被审材料(必读)"(L139,无 diffRef)③ 通篇 design 语境。改为:
> - **候选菜单按 reviewType 取**:`const menu = reviewType === 'code' ? CodeCandidateMenu : DesignCandidateMenu;`(L136 注入 `menu`)。
> - **被审材料指针按 reviewType**:code 路注入 `改动范围(必读,git diff/Read): ${targets.diffRef}` + `对照 spec(如有): ${targets.spec}`;design 路逐字保留 `被审材料(必读): ${targets.spec}`。
> - **governance 留口守卫(A 簇收尾)**:`reviewType==='governance'`(本轮不接线)**不得落空注入 design 菜单**——`scoutPrompt` 加 guard:`const menu = reviewType === 'code' ? CodeCandidateMenu : reviewType === 'design' ? DesignCandidateMenu : [];`(governance → 空菜单 + 注 `notes:"governance 类未接线,本轮不应被调用"`);且 code-review/design-review SKILL 都不会用 `reviewType='governance'` 调本 workflow(治理审查仍走现 A/B/C)。即"留口"= FloorTable 有 governance 行但无调用方,不是"会落空跑 design 菜单"。

### 3.2 SCOUT_SCHEMA(复用,不改)

code 路**复用现有 `SCOUT_SCHEMA`**(主 spec §3.2 / workflow.js L59-93),**零改字段**:`inherited_floor` / `added_dimensions[{name,why_this_time,challenger_focus}]` / `skipped_candidates[{name,why_skipped}]` / `rubric_mode` / `notes`。差异仅**值**:

- `inherited_floor` 在 code 路 = `FloorTable.code` 维名(照抄)= **方向盘对齐 + 简洁性 + spec忠实性(3 维)**(见 §4.1)。
- `skipped_candidates` 在 code 路 = `CodeCandidateMenu`(类型契约合规 / 架构合规 / 模块文档一致性)里本次不加的候选。
- `added_dimensions` = scout 按 code diff 现推的动态维(B-8 code 引导)。
- `rubric_mode` / `notes` 同 design 路语义。

> **spec 忠实性入地板、代码质量不单设维(D-C2 用户拍板)**:① **spec 忠实性** = code 地板第 3 维(在 `inherited_floor`,scout 照抄),解 either-or 下 ultracode 路不跑 Superpowers 的真空;② **代码质量** 不单设 scout 维(不在 floor/候选/added)——由「方向盘对齐」focus 通用基线段(功能完整性/代码质量/测试/一致性/简洁性)覆盖;③ scout **不得**把"代码质量"另立为 `added_dimensions`(已被基线覆盖,另立 = 冗余;review-scout.md code 语境注明,若误加调度者综合去重)。

### 3.3 challengerPrompt(d) 契约(复用薄包装结构 + 加 reviewType 分支;design 分支逐字保留)

> **诚实修订(A 簇 🔴 — 撤回"零改函数体/100% 复用 challengerPrompt"的过度乐观措辞)**:现 `challengerPrompt`(workflow.js L156-183)**写死 design 串**——「你是设计审查挑战者」(L160)、`targets.spec`(L166,无 diffRef)、「文档节/路径」(L180)。**"零改函数体"与"code 须给 diffRef / code 语境"不可兼得**。正解:**这三处(含 scoutPrompt、FLOOR_FOCUS['方向盘对齐'])改为 `reviewType` 分支——`reviewType==='code'` 走 code 分支,`else` 走 design 分支并逐字保留现状**。design 路行为零变(else 分支逐字 = 改前文本),code 路是新增分支。**复用的是薄包装的"结构"(自读盘+中性约束+challenger-orientation+主线支线关系+输出格式+已对照用户原话 section 这套骨架),不是"函数体一字不改"。**

**`challengerPrompt` 改动点(三处串 → reviewType 分支;design else 逐字保留)**:

| 串(workflow.js 行) | design 分支(else,逐字保留现状) | code 分支(reviewType==='code' 新增) |
|---|---|---|
| 角色行 L160 | `你是设计审查挑战者,负责「${d.name}」这一维…` | `你是代码审查挑战者,负责「${d.name}」这一维。审查对象 = 本次代码改动(diff),不是设计文档…`(对抗者/不打分语义同 design) |
| 被审材料路径 L166 | `被审材料路径(自己 Read…): ${targets.spec}` | `改动范围(自己 git diff / Read 改动文件): ${targets.diffRef}` + `对照 spec/任务(如有,审 spec 忠实性用): ${targets.spec}`(spec 可缺,缺则注"对照 sessionIntent") |
| 输出格式 location 提示 L180 | `location(文档节/路径)` | `location(改动文件路径:行号)` |

> 实现方式(D-C 实现细节,§7.2):`challengerPrompt(d, targets, sessionIntent, reviewType)` **增 `reviewType` 形参**(调用点 workflow.js L224 的 `challengerPrompt(d, targets, sessionIntent)` 同步加传 `reviewType`)。函数内三处串用 `reviewType === 'code' ? <code串> : <design串>`(else 即现状逐字)。**不靠"`targets.diffRef` 是否存在"隐式分支**(易误判;显式 reviewType 形参更可核 — 撤回上一稿"倾向后者零新参"的取巧)。

**各维 focus 来源(全 scout 路自有,住 workflow.js `FLOOR_FOCUS`;不镜像 design-reviewer.md)**:

| 维类型(code 路) | focus 来源 | 取数方式 |
|---|---|---|
| **code 地板 + 已知候选维**(地板:方向盘对齐 / 简洁性 / **spec忠实性**;候选:类型契约合规 / 架构合规 / 模块文档一致性,见 §4.1) | **`FLOOR_FOCUS_CODE` 常量的 code 维条目**(scout 路自有,code 语境,与 design `FLOOR_FOCUS` 分开)。**方向盘对齐 focus 不两路共用**(D 簇 🔴):design 版「审查设计是否对齐项目方向盘」(L42),code 版独立——「审查本次代码改动(diff)是否对齐项目方向盘 + code 基线(功能正确/真实代码质量/测试/一致性/简洁性)」。A-3 判据(读 RUBRIC 判 filled/template + 回落 CLAUDE.md)两路通用,但 **focus 文字按 reviewType 分** | focus 取数处按 reviewType 选(§4.1 (3) 注 / §7.2 D-C5):`reviewType==='code'` → 取 `FLOOR_FOCUS_CODE[维]`;否则取 design `FLOOR_FOCUS[维]` / `d.challenger_focus`。**维名两路一致**(都叫「方向盘对齐」),focus 按 reviewType 分 |
| **scout 动态加维** | scout 返回的 `challenger_focus`(SCOUT_SCHEMA)+ 通用对抗框 D11 | 现有逻辑,fallback 到 `d.challenger_focus`(此处真不改) |

> **键冲突核(撤回"方向盘对齐两路共用同键"的错误 — D 簇)**:design 与 code 的 `方向盘对齐` focus **文字不同**(语境不同),不能共用一个值。**裁决(§7.2 D-C5)**:**code focus 住独立 `FLOOR_FOCUS_CODE` 常量**,focus 取数处按 reviewType 选(`reviewType==='code' ? FLOOR_FOCUS_CODE.方向盘对齐 : FLOOR_FOCUS.方向盘对齐`);**维名两路都叫「方向盘对齐」不加后缀**(避免污染 SCOUT_SCHEMA.inherited_floor / FloorTable↔review-rules 双写)。`自洽性`/`完整性`(design 键)code 路不用、`spec忠实性`/三候选(code 键)design 路不用,无键冲突。

> **E 簇 — 三地板维 focus 须写互斥边界(可证的别推 bootstrap)**:`spec忠实性` / `简洁性` / `方向盘对齐` 在「做多了 / 与任务无关变更 / 功能完整性」上有重叠风险 → 各 focus 文字**显式写互斥边界**(§4.1 已落):**spec忠实性** = 忠于本次任务 spec/需求的"**该做的做了没 / 做歪没(跑题)**"(对象 = 实现 vs 任务意图);**简洁性** = "**多做的害处**"(过度抽象 / 单次使用 helper / 与任务无关的格式重写);**方向盘对齐** = 对齐**项目长期标准 + 通用基线**(功能正确/真实代码质量/测试/一致性)。三者切面不同(忠于任务 vs 多做 vs 对齐长期标准),边界写进 focus 即可证,不推实战。

### 3.4 FINDING_SCHEMA(复用,不改)

code 路**完全复用现有 `FINDING_SCHEMA`**(主 spec §3.4 / workflow.js L96-118):`{dimension, findings:[{title,location,problem,evidence,impact,severity}], user_words_section}`。code 路 `location` 字段 = 改动文件路径 + 行号(而非 design 路的文档节);`evidence` = 代码原文引用。schema 形态零改。

### 3.5 workflow 出参(复用,不改)

复用现有出参 `{plan, findings}`(主 spec §3.5 / workflow.js L237-240)。调度者拿 `{plan, findings}` 按 synthesis-rules 综合,写 code review 结果(沿 Superpowers/现状结果落点;**code 路综合维序说明钉在 CM-skill 的 scout 分支段**——按 plan 维度清单顺序读 findings,不用固定维序,同 design 路 §3.5 处理)。

**自检**:
- [x] 每个接口双方都定义:入参(调度者↔wf,code 增 diffRef)/ SCOUT_SCHEMA(复用 schema,值变)/ challengerPrompt(加 reviewType 分支)+FINDING_SCHEMA(复用 schema)/ 出参(复用)四对齐全。
- [x] 参数/返回类型在数据模型(§4)定义:FloorTable.code / CodeCandidateMenu / FLOOR_FOCUS_CODE / diffRef 均 §4 有定义;SCOUT_SCHEMA/FINDING_SCHEMA 复用主 spec §4(schema 零改)。
- [x] 每个接口有错误处理约定:入参缺失(diffRef+spec 双缺)/ scout 空返回(复用)/ 挑战者空返回(复用)/ Workflow 不可用(走 Superpowers)全有路径。
- [x] 入参出参与需求数据对得上:reviewType='code' ← A1;diffRef ← code 审"一批改动";FloorTable.code ← A4 地板;CodeCandidateMenu ← A4 候选;不打分 ← 复用 D8。
- [x] 接口简洁:复用 schema 结构(SCOUT/FINDING 零改),code 新增 = `diffRef` 字段 + `FLOOR_FOCUS_CODE` 常量 + scoutPrompt/challengerPrompt 的 reviewType 分支(非零改函数体,A 簇);无冗余新接口(过度工程化反向追问:不加 diffRef,code 审怎么知道改了哪些文件?无替代 → 必要)。
- [x] 前后端契约:不适用——本功能无 API 端点、无前后端分离;契约 = workflow 钩子签名 + schema 对象(复用),已在主 spec §3 定义。
- [x] 字段命名统一:`reviewType` / `inherited_floor` / `added_dimensions` / `skipped_candidates` / `challenger_focus` / `why_this_time` / `diffRef` 全文一名,与主 spec 一致。

---

## 4. 数据模型

### 4.1 数据实体(code 路新增/改值)

```javascript
// (1) FloorTable.code 接线(替占位)——住 review-scout.workflow.js;权威上游 = review-rules 代码行 scout 注(双写,credentials-rules §8 #6)
//     仅作用 scout(ultracode)路;非 ultracode 路用 Superpowers requesting-code-review(不查本表)
FloorTable = {
  design:     ['方向盘对齐', '自洽性'],                              // 不改(F 守住)
  code:       ['方向盘对齐', '简洁性', 'spec忠实性'],               // ★ 接线:code 地板 3 维(D-C1=A 地板 + D-C2 spec忠实性入地板;用户拍板)
  governance: ['核心原则合规', '目的达成度', '副作用', 'scope 漂移'], // 不改(本轮不接线)
}
// 注:现 workflow.js 占位 code 行为 ['方向盘对齐','简洁性'];本 spec 接线为 3 维 = 方向盘对齐 + 简洁性 + spec忠实性(用户拍板)。
//   维名「简洁性」= review-rules L11/L19 + workflow.js 占位双写源 token(节标题 L66「简洁性审查」同一维);维名须与 review-rules code scout 注双写逐字一致。
//   spec忠实性入地板理由(D-C2):either-or 下 ultracode 路不跑 Superpowers requesting-code-review → spec 忠实性若不入地板会留真空;故由 scout 地板维兜住(详 §7.2 D-C2)。
//   代码质量不单设地板维:已被「方向盘对齐」focus 通用基线段(功能完整性/代码质量/测试/一致性/简洁性)覆盖(见 (3) 注)。

// (2) CodeCandidateMenu(★ 新增——scout 路 code 类标准候选;scout 每次必考虑,不加须进 skipped_candidates — A4)
//     = review-rules 代码类五节里"非地板、且 diff 驱动条件相关"的维(B 维度分类:条件相关降候选)
CodeCandidateMenu = ['类型契约合规', '架构合规', '模块文档一致性']  // D-C1=A:类型契约入候选(diff 驱动,非地板)
// 说明(B 维度分类结论 + D-C1=A 裁决):
//   - 类型契约合规:改 API/共享类型才相关 → 条件相关 → 候选(D-C1=A;scout 按 diff 选,改了 API 不加须 skipped 解释)
//   - 架构合规:改动涉及分层/动文件位置才相关 → 条件相关 → 候选(scout 按 diff 选;无 ARCHITECTURE.md 则 scout notes 标跳过)
//   - 模块文档一致性:改导出接口才相关 → 条件相关 → 候选
//   - ★ spec 忠实性:入地板(D-C2),NOT 候选;代码质量:被方向盘对齐通用基线覆盖,NOT 候选(均不在本菜单)

// (3) FLOOR_FOCUS 扩 code 维 focus(★ 住 review-scout.workflow.js;scout 路自有,code 语境,不镜像 design-reviewer.md)
//     现有 FLOOR_FOCUS 已含 design 维键(方向盘对齐/自洽性/完整性/过度工程化),design 维键全不改(F 守住)。
//     ★ A 簇修订:方向盘对齐 focus 不能两路共用(design 版「审查设计」语境);故 focus 取数处按 reviewType 选。
//        取数实现(裁决 (b),§3.3/§7.2):challengerPrompt 取 focus 时 ——
//          const isCode = reviewType === 'code';
//          let focus;
//          if (d.name === '方向盘对齐') focus = isCode ? FLOOR_FOCUS_CODE['方向盘对齐'] : FLOOR_FOCUS['方向盘对齐'];
//          else if (d.name in FLOOR_FOCUS_CODE && isCode) focus = FLOOR_FOCUS_CODE[d.name];   // code 独有维
//          else focus = (d.name in FLOOR_FOCUS) ? FLOOR_FOCUS[d.name] : d.challenger_focus;    // design 维 / 动态维
//        维名两路一致(都叫「方向盘对齐」,不加后缀污染 SCOUT_SCHEMA/双写),focus 文字按 reviewType 分。

FLOOR_FOCUS = {   // design 路键,全不改(F 守住;design 路 challengerPrompt 走此)
  '方向盘对齐': '<现状不改:design 版「审查设计是否对齐项目方向盘…」(workflow.js L41-46 原文)>',
  '自洽性': '<design 路用,不改>',   '完整性': '<design 路用,不改>',  '过度工程化': '<design 路用,不改>',
};

// ★ 新增 code 维 focus 常量(scout 路自有,code 语境;与 design FLOOR_FOCUS 分开,避免污染 design 键)
const FLOOR_FOCUS_CODE = {
  '方向盘对齐':   // ★ D 簇:code 独立方向盘对齐 focus(不复用 design「审查设计」语境)
    '审查本次代码改动(diff)是否对齐项目方向盘 + code 通用基线。先 Read docs/RUBRIC.md(自仓库 harness/docs/RUBRIC.md)判 rubric_mode:' +
    '「项目特定标准」段已填(无模板标记串)→ 按 RUBRIC 项目特定标准逐项对齐 diff;空模板 → 回落 CLAUDE.md 原则(文档第一公民/最小变更/角色分离/回退)+ 二条公设(读取范围 = /CLAUDE.md 或 harness/CLAUDE.md)。' +
    'code 通用基线段始终检查 = 功能正确(diff 是否真实现了功能,不只编译过)/ 真实代码质量(命名/结构/错误处理是否达项目标准)/ 测试(改动有无对应测试)/ 一致性(与既有代码风格/pattern 一致)/ 简洁性。据 targets.diffRef 读改动文件核。' +
    '⚠️ 互斥边界(E 簇):本维审"对齐项目长期标准 + 通用基线",不审"是否忠于本次任务 spec"(那是 spec忠实性维)、不审"多做的害处"(那是简洁性维)。',
  'spec忠实性':   // ★ 地板第 3 维(D-C2 用户拍板入地板);scout 路自有,不镜像 design-reviewer.md
    '审实现代码是否忠于"本次任务"的 spec/需求:① 该做的做了没(本次任务 spec 列的需求/场景是否都在 diff 中落地)?② 做歪没 / 跑题没(diff 是否偏离任务要求做了别的)?' +
    '据 targets.diffRef 读改动文件,对照 targets.spec(被实现的设计 spec)逐项核,引 diff 具体锚点。' +
    'targets.spec 缺(纯 bugfix)→ 对照"任务描述 / diff 自身意图"审"做的是否就是这次该做的"(回落不把 sessionIntent 当评分锚——F 簇,sessionIntent 只界定审什么、不当忠实度判据),notes 标无 spec。' +
    '⚠️ 互斥边界(E 簇):本维只审"实现 vs 本次任务意图的吻合度(该做的/做歪的)";不审"多做了 spec 没要求的"那一面里"过度抽象/单次 helper"(归简洁性维)、不审"是否达项目长期标准"(归方向盘对齐)。与 design 路「自洽性」(设计内部一致)/「完整性」(设计覆盖需求)对象不同——本维对象 = 代码 vs 本次任务 spec。',
  '简洁性':
    '查"多做的害处":有无明显更简方案 / 只用一次的抽象(helper/wrapper/factory 建议内联)/ diff 中与任务无关的变更(格式/注释重写/import 排序)/ 200 行能 50 行解决的(critical)。' +
    '据 targets.diffRef 读改动文件。(对齐 review-rules「简洁性审查」节 L66)' +
    '⚠️ 互斥边界(E 簇):本维只审"多做 / 过度抽象 / 无关变更";不审"该做的没做"(归 spec忠实性维)、不审"是否对齐项目长期标准"(归方向盘对齐)。',
  '类型契约合规':   // 候选维 focus(D-C1=A 入候选;scout 选加时映射本键)
    '查涉 API 的代码是否从共享类型文件 import(无前后端各自定义)、新增/改 API 字段是否在共享类型文件有对应定义、字段命名与 DB 映射是否一致;自定义应在契约中的类型 = critical。(对齐 review-rules「类型契约合规」节)',
  '架构合规':
    '查改动是否违反 ARCHITECTURE.md 分层规则(跨层依赖)、新文件是否放在正确目录。' +
    '先 Read targets.architecture;若缺失(自仓库无)→ 本维由 scout 在 notes 标跳过,不硬推。(对齐 review-rules「架构合规」节)',
  '模块文档一致性':
    '查涉及模块的 README.md 是否存在、接口描述是否与代码导出一致、依赖关系是否与 import 一致、变更历史是否更新;文档与代码不一致 = critical。(对齐 review-rules「模块文档一致性」节)',
};

// (4) SCOUT_SCHEMA / FINDING_SCHEMA / ScoutPlan / Finding / ChallengerReturn:复用主 spec §4.1,零改
```

### 4.2 数据流(code 路)

```
调度者构造入参(reviewType='code' + targets{spec?, diffRef, rubric, …} + sessionIntent)
  → review-scout workflow 启动
  → phase 侦察: scout fork(读 FloorTable[code] 照抄 inherited_floor=[方向盘对齐,简洁性,spec忠实性];读 targets.rubric 判 rubric_mode;
                 git diff targets.diffRef + Read 改动文件 + Read targets.spec[如有] + Grep decisions/audits
                 → 推 added_dimensions / skipped_candidates;★ spec忠实性已在地板(照抄,非 added);★ 不另立"代码质量" added 维 — 基线覆盖,D-C2)
  → scout 返回 ScoutPlan(schema 校验,复用)
  → workflow 算 dims = inherited_floor ∪ added_dimensions.name(复用编排)
  → phase 对抗: parallel 每 dim 一挑战者 fork(focus: 按 reviewType='code' 取 FLOOR_FOCUS_CODE[维] 或 challenger_focus;自读 diffRef/spec)→ ChallengerReturn
  → workflow return {plan, findings.filter(Boolean)}(复用出参)
  → 调度者综合(synthesis-rules;按 plan 维序)→ code review 结果 → 判定通过/需修
  ── 与 Superpowers 的关系:either-or——ultracode 路走本数据流(不跑 Superpowers);spec忠实性由地板维兜、代码质量由方向盘对齐基线兜(无真空,§7.2 D-C2)
```

### 4.3 状态变更(复用 design 路;code 语境)

| 实体 | 从状态 | 触发事件 | 到状态 | 副作用 |
|------|-------|---------|-------|--------|
| ScoutPlan(code) | (无) | scout fork 成功 + schema 通过 | 已产出 | workflow 进入对抗 phase |
| ScoutPlan(code) | scout 空返回/校验失败 | 重试一次仍败 | 审查未完成 | workflow 返回空,调度者标审查失败(不静默回落 Superpowers — code scout 失败 ≠ ultracode 不在场) |
| dim 挑战者 | 已扇出 | 空返回重试仍败 | 该维未完成 | `.filter(Boolean)` 剔除,调度者按盲区处理 |
| code review 结果 | (无) | 调度者综合完 findings | 已写盘 | 进入判定;不通过则回开发修复 |

**自检**:
- [x] 数据流每步输入/输出类型与接口一致:入参→ScoutPlan→ChallengerReturn[]→{plan,findings},与 §3 对齐;diffRef 在侦察/对抗两 phase 被 scout/挑战者用 git diff/Read。
- [x] 实体字段覆盖所有接口用到的数据:reviewType/targets(含 diffRef)/sessionIntent(§3.1)、SCOUT_SCHEMA 字段(复用)、FLOOR_FOCUS_CODE 键(§4.1(3))、Finding 各字段(复用)全在 §4。
- [x] 状态机无死状态/不可达:scout 成功→对抗;scout 失败→空返回标审查失败;挑战者失败→盲区;均有出口(复用 design 路状态机)。
- [x] 命名规范:JS 字面量,字段名与 §3/主 spec 一致;无数据库,无 snake↔camel 映射(N/A)。
- [x] 数据校验位置明确:schema 校验由 `agent({schema})` 在 workflow 层做(复用);rubric_mode 判据由 scout 在 fork 内做(A-3 复用);**spec忠实性=地板维(scout 照抄)、代码质量不另立(基线覆盖)**的约束由 review-scout.md code 语境强制(§3.2 注 / D-C2)。

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 场景 | 输入条件 | 期望行为 |
|------|---------|---------|
| **ultracode 关 / Workflow 不在场** | 跨运行时 / 非 Claude Code / 逐会话未 opt-in | **不是错误,是 code-review SKILL 执行开头分支去走 Superpowers `requesting-code-review`(回落路,原样调用,不改 Superpowers 包)**。不标"降级"。scout 动态推维在此路不可得 = ultracode 专属取舍(同 design 路 D13) |
| scout 空返回(code 路) | scout fork 返回 null / schema 不过 | workflow 重试一次;仍败 → `{plan:null,findings:[]}`,调度者标审查失败,报用户(复用 design 路)。**不静默回落 Superpowers**(scout 失败 ≠ ultracode 不在场) |
| **无对照 spec(纯 bugfix)** | `targets.spec` 缺、仅 `targets.diffRef` | 合法:scout 在 notes 标"无对照 spec";**spec忠实性地板维仍跑**(D-C2,该维在 ultracode 路是地板必跑)——挑战者**回落对照"任务描述 / diff 自身意图"**审"做的是否就是这次该做的",**不把 sessionIntent 当忠实度评分锚**(F 簇,守 synthesis 事前规则 5;sessionIntent 只界定审查范围)。notes 标无 spec(FLOOR_FOCUS_CODE['spec忠实性'] 已含此回落,§4.1) |
| **diffRef 缺 + spec 缺** | 两者皆缺 | workflow `log()` 报错 + 返回空,调度者标审查失败(无改动范围无法审 — §3.1 错误处理) |
| **ARCHITECTURE.md 缺失** | 自仓库无该文件 | scout `notes` 标"跳过架构维";若"架构合规"在 CodeCandidateMenu 被 scout 考虑加,scout 检 targets.architecture 缺失则不加 + skipped 写"无 ARCHITECTURE,跳过"(沿 design 路 + review-rules 现状) |
| **scout 误把代码质量另立为 added 维** | scout 把"代码质量"加进 added_dimensions | 代码质量已被「方向盘对齐」通用基线覆盖(D-C2)→ 另立 = 冗余;review-scout.md code 语境注明不另立;漏防时调度者综合识别并去重(synthesis 去重) |
| added_dimensions 为空(code 路) | scout 判地板已足够 | 合法;但 `skipped_candidates` 必须解释 CodeCandidateMenu(类型契约合规/架构合规/模块文档一致性)为何都不加(空 skipped + 空 added → 视失职,调度者质疑) |
| 维度爆量 / 维度重叠 | 同 design 路 | 复用 design 路处理(不静默截断 + parallel 排队 + 调度者综合合并;约束不重叠 + synthesis 去重) |
| 某挑战者空返回 | 单挑战者失败 | 复用 design 路(重试一次→仍败 filter 剔除→调度者标盲区) |
| **方向盘对齐 focus 按 reviewType 选(D 簇)** | code 与 design 同用维名 `方向盘对齐`,但 focus 文字不同 | A-3 判据两路通用,但 **focus 文字不可共用**(design「审查设计」/ code「审查 diff + code 基线」语境不同)→ focus 取数处按 reviewType 选(`reviewType==='code' ? FLOOR_FOCUS_CODE.方向盘对齐 : FLOOR_FOCUS.方向盘对齐`,§4.1/§3.3)。维名一致不污染 SCOUT_SCHEMA/双写,键不冲突 |
| **三地板维 focus 重叠风险(E 簇)** | spec忠实性/简洁性/方向盘对齐 切面可能重叠 | 各 focus 文字写"⚠️ 互斥边界"(spec忠实性=忠于本次任务"该做的做了/做歪没";简洁性=多做的害处;方向盘对齐=对齐长期标准+基线)→ 切面不重叠,可证(§4.1 FLOOR_FOCUS_CODE 三键已含边界句);漏防时调度者综合去重 |
| RUBRIC 检测误判 | scout 判 filled/template 判错 | 复用 design 路(rubric_mode 写 plan,调度者综合可见可纠) |
| 被审改动超 64kB | 自读盘 | 复用 A-1(自读盘 + 按需 Grep 局部读,不嵌入) |

### 5.2 错误传播路径

```
[code scout 路] scout fork 失败 → workflow 重试1次 → 仍败 → return 空 → 调度者(SKILL 错误处理)→ 报用户(不静默回落 Superpowers)
[code scout 路] 挑战者 fork 失败 → workflow 重试1次 → 仍败 → parallel 该项 null → filter 剔除 → 该维"未完成" → 调度者综合标盲区
ultracode 关 / Workflow 不在场 → code-review SKILL 执行开头分支 → 走 Superpowers requesting-code-review(回落,原样)→ 不标降级
[Superpowers 回落路] 沿 Superpowers 现有错误处理(本功能不碰)
```

**自检**:
- [x] 每个接口错误情况都有边界处理:§3 接口错误约定 ↔ §5.1 行对应(code 路;Superpowers 回落路沿现状不碰)。
- [x] 错误传播路径完整,无吞错:scout 路空返回→重试→标未完成/盲区,均显式;ultracode 关→分支走 Superpowers(非错误、非降级);scout 路失败显式报(不静默回落)。
- [x] 用户能看到有意义错误:调度者综合报告按 synthesis-rules 段,审查失败给原因摘要,非堆栈。
- [x] §1.2 核心场景异常路径都覆盖:场景1(scout 失败→报用户)、场景2(rubric 误判→透明可纠)、场景3(ultracode 关→Superpowers 原样)、场景4(either-or + spec忠实性入地板→无对照 spec 时该地板维仍跑、回落对照任务描述/diff 自身意图、不把 sessionIntent 当评分锚 — F 簇)、场景5(三层选维→爆量/重叠/空 added 边界)。

---

## 6. 测试策略

> 同 review-scout 主设计:harness 自仓库无产品 runtime 单测框架;本功能验证 = (a) workflow 脚本结构静态核 + (b) bootstrap 实战(落地后用 code-review 审下一批真实代码改动 — meta-L4 实战留痕,对齐 `feedback_realworld_testing_in_other_projects` 推真实项目跑)。

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | mock 策略 |
|---------|---------|---------|----------|
| §1.2 场景1 | reviewType='code' 跑通:scoutPrompt 注入 CodeCandidateMenu(非 DesignCandidateMenu)、FloorTable.code 照抄、两 phase 返回 {plan,findings} | 脚本结构静态核(读脚本核 reviewType 分支 + 禁用项:无 Date.now/Math.random/无参 new Date/无 FS) | 不 mock — 结构核 |
| §1.2 场景2 | A-3 判据 code 路复用(给已填/空模板 RUBRIC → rubric_mode=filled/template) | bootstrap 实战观察 | N/A |
| §1.5 A4 地板 | inherited_floor 恒含且仅含 FloorTable.code = 方向盘对齐 + 简洁性 + **spec忠实性**(3 维,D-C1=A 地板 + D-C2),scout 照抄不增删 | 脚本/prompt 静态核 + 实战 | N/A |
| §1.5 A4 候选 | CodeCandidateMenu = 类型契约合规 + 架构合规 + 模块文档一致性;维不加时 skipped_candidates 必有对应条目(挡 spec-gap-masking) | bootstrap 实战观察 plan | N/A |
| **D-C2 spec忠实性入地板 / 代码质量基线覆盖** | FloorTable.code 含 `spec忠实性`(地板第 3 维);plan **不含**"代码质量"另立维(被 code 版方向盘对齐基线覆盖);FLOOR_FOCUS_CODE 含 `spec忠实性` 键 | 脚本静态核(FloorTable.code 含 spec忠实性、FLOOR_FOCUS_CODE 有该键、无"代码质量"另立维)+ review-scout.md code 语境文字核 + 实战观察 plan | N/A |
| §1.2 场景3 回落分支 | code-review SKILL 执行开头分支文字完整(ultracode 开→review-scout workflow reviewType='code' / 关→Superpowers requesting-code-review);**不改 Superpowers 包** | SKILL 文档核(分支文字 + Superpowers 调用方式正确) | N/A |
| **A 簇 — design 路 prompt 文本等价(行为零变)** | `reviewType='design'` 调 `scoutPrompt`/`challengerPrompt` 产出的 prompt 文本**与改前逐字相同**(else 分支 = 改前文本)。**不能只靠"design 常量零 diff"**——行为流经被改的两函数 | **prompt 文本快照核**:改前先存 design 路两函数对一组固定入参的输出快照(fixture);改后对同入参重跑,**逐字 diff = 空**。或静态读 else 分支与原 L160/L166/L180、L136/L139 串逐字一致(§8.3 CMD2 加文本核) | 固定入参 fixture(不跑 fork) |
| F 守住 design 路常量零退化 | design 路常量(FloorTable.design/DesignCandidateMenu/design 版 FLOOR_FOCUS 键)+ reviewScout 编排/SCOUT_SCHEMA/FINDING_SCHEMA **零 diff**;design-review SKILL **零 diff** | §8.3 git diff 核(design 路常量 + 编排骨架零改;workflow.js 改动仅 = code 常量[FloorTable.code/CodeCandidateMenu/FLOOR_FOCUS_CODE] + 两函数 reviewType 分支[design else 逐字]) | N/A |
| F 守住 design-reviewer.md 零关系 | code 路 focus 住 workflow.js `FLOOR_FOCUS_CODE` 常量,不读/不抄/不镜像 design-reviewer.md;design-reviewer.md 零 diff | 文档核(workflow.js 含 FLOOR_FOCUS_CODE;design-reviewer.md git diff 空) | N/A |
| §5.1 diffRef 缺+spec 缺 | 报错返回空,不静默当通过、不静默回落 Superpowers | 脚本逻辑核 | N/A |
| **E 簇 — 三地板维 focus 互斥边界** | `方向盘对齐`/`spec忠实性`/`简洁性` 的 code focus 文字各含"⚠️ 互斥边界"句(切面不重叠:对齐长期标准 vs 忠于本次任务 vs 多做的害处) | 静态文本核(FLOOR_FOCUS_CODE 三键各含互斥边界句) | N/A |
| **C 簇 — synthesis 主表地板数对 code 准** | synthesis L16/L99「地板 2」对 code(地板 3)不准 → ADD 注"地板按类:design 2 / code 3" | 文档核(synthesis 已加 code 地板数注) | N/A |
| §8 触点同步 | FloorTable.code↔review-rules code 地板维表注双写(三维有序逐字);CodeCandidateMenu↔review-rules 候选注;新 skill 入口在 CLAUDE×2 角色表(开发行)+ CLAUDE×2 Skill 地图 + QUICKREF Skill 表(新行,非映射行 L34) 登记 | 收口前 grep 自核(§8.3) | N/A |
| 退化失败模式(B-8 code,诚实标注 — meta-L4 实战必观察) | scout 是否退化成"只加现有五节同集"?code 加维是否真带 diff 原文锚点 `why_this_time`? | bootstrap 实战观察 plan(连续 N 次 code 审的 added_dimensions 分布) | N/A(实战) |

### 6.2 测试边界

- **不测**:Workflow 工具引擎本身(平台层);Superpowers `requesting-code-review` 流程(不碰);scout code 推维"质量好坏"落地前不可证(bootstrap 不可证,§1.6;声明 + 推实战)。
- **mock 策略**:无传统 mock;脚本结构核靠读脚本 + 静态规则,fork 行为靠 bootstrap 实战。
- **诚实标注的实战观察项(meta-L4)**:① 退化回 Superpowers 五节同集(B-8 code);② code 版 spec忠实性地板维与 design 路自洽性/完整性的边界在实战中是否清晰(对象=代码 vs 设计文档,会不会有挑战者审跑偏);③ 自读盘 diffRef 中性的循环性(同 design 路 D-A1 残留)。三者落地前不可证,推实战回看,不算缺陷但如实列出。

**自检**:
- [x] §1.2 每个核心场景有对应测试/观察:场景1(结构核)、场景2(实战)、场景3(回落分支文档核)、场景4(spec忠实性入地板 + 代码质量基线覆盖核)、场景5(三层选维 floor/候选/added 核)。
- [x] §5 每个边界有对应:scout 空返回 / ultracode 关走 Superpowers / diffRef+spec 缺 / 无对照 spec(spec忠实性维仍跑、F 簇不当评分锚) / scout 误加代码质量维 / 方向盘 focus 按 reviewType 选无冲突 / design 路 prompt 文本等价 均列。
- [x] 测试层级合理:能静态核的(reviewType 分支/FloorTable.code 3 维/**design prompt 文本等价快照**/互斥边界文本/synthesis 注/双写 grep)不上实战;推维质量 + 三诚实观察项留实战(本质不可证)。**A 簇:design 路行为零变靠 prompt 文本快照核(非只常量 diff)。**

---

## 7. 设计决策记录

### 7.1 复用的已确认决策(从 review-scout 主设计 + 输入 A 流转)

| 决策 | 选择 | 来源 |
|------|------|------|
| A1 fork-N 同形 | code 审 = scout 推维 → parallel 扇出 → 调度者综合 | 输入 A1 用户拍板 |
| A2 触发宿主 = 新建 code-review skill | 镜像 design-review SKILL,运行时分支 | 输入 A2 用户拍板 |
| A3 scout 与固定维 = A(动态选维) | scout 路做 diff 驱动对抗维扇出;Superpowers 仅作非 ultracode 回落(either-or,不叠加 — D-C2 细化) | 输入 A3 用户拍板 |
| A4 三层选维 | 地板 + 候选(skipped 留痕)+ 发明维(双闸) | 输入 A4 用户拍板 |
| 复用 SCOUT/FINDING_SCHEMA + challengerPrompt + 编排 | code 路零改 schema/编排骨架,只加常量+分支 | review-scout 主 spec §3/§4(D6 reviewType 参数化) |
| 复用 D8 综合留调度者 / D9 scout 输入 / D11 novel 维框 / D12 N 无上限 / A-1 自读盘 / A-3 判据 | code 路同构沿用 | review-scout 主 spec §7 |
| ADD 不替换 + ultracode 专属(同 D13) | code scout 并排,Superpowers requesting-code-review 作回落 | 输入 A2 + 主 spec D13 同构 |

### 7.2 本轮 designer 裁决的实现细节决策(D-C 系列)

> **D-C 系列 = 用户已拍板(2026-06-15)**:D-C1=A / D-C2=spec忠实性入地板(either-or 不叠加)/ D-C3=B(无门)/ D-C4=A(接通-usable)。下记裁决 + 理由;决策文件 `docs/decisions/2026-06-15-code-review-scout-decisions.md`「## 决定」段已填。

#### D-C1 code 地板大小 — ✅ 用户拍板 = A(类型契约入候选)

- **裁决 = A**:类型契约合规 → **候选**(`CodeCandidateMenu`,diff 驱动),不入地板。`CodeCandidateMenu = [类型契约合规, 架构合规, 模块文档一致性]`。
- **理由**:① 类型契约合规是**条件相关**(只有改 API/共享类型才有对象,B 维度分类),放候选 + scout 按 diff 信号选 = 精准且省(用户核心价值"动态选维");② 漏维风险由 `skipped_candidates` 强制留痕兜(scout 不选类型契约须解释为何——若 diff 真改了 API 却 skip,调度者综合质疑),候选 ≥ 入地板的安全性且更省。
- **注**:本轮 code 地板第 3 维是 **spec忠实性**(D-C2),非类型契约——D-C1 决定的是"类型契约去候选",地板第 3 维由 D-C2 定。
- **影响接口**:`CodeCandidateMenu` 值(含类型契约)+ FLOOR_FOCUS_CODE 含类型契约候选键(§4.1)。

#### D-C2 代码质量 / spec 忠实性 落点 — ✅ 用户拍板 = **spec忠实性入 code 地板(either-or 不叠加);代码质量靠方向盘对齐通用基线**

- **背景(输入 D2)**:维度分类 agent 倾向把代码质量/spec 忠实性也算 scout 地板;权衡 agent 倾向让它们沿 Superpowers 两段恒跑、scout 不碰。**designer 初裁"scout 不碰"被自检揪出真空(见下),用户据此拍板修正**:
- **关键事实(自检揪出的真空)**:本功能两路是 **either-or**——**ultracode 开走 scout 路时不并跑 Superpowers `requesting-code-review`**。故"Superpowers 两段恒跑"在 ultracode 路**不成立**;若把 spec 忠实性留给"Superpowers 恒跑"而 scout 不碰 → ultracode 路的 spec 忠实性会留**真空**(没人审实现是否忠于 spec)。
- **用户拍板裁决(修正初裁)**:
  1. **spec 忠实性入 code 地板(第 3 维)**:`FloorTable.code = [方向盘对齐, 简洁性, spec忠实性]`(3 维)。scout 路每次必跑 spec忠实性挑战者(照抄地板,非发明),**填上 either-or 下的真空**——ultracode 路 spec 忠实性由 scout 地板维保证(不再"靠综合间接覆盖、不保证等价")。新增 `FLOOR_FOCUS_CODE['spec忠实性']`(scout 路自有,不镜像 design-reviewer.md;code 语境:审实现代码是否忠于本次任务的 spec/需求——该做的做了没?做歪/跑题没?对照 `targets.spec`,缺则回落任务描述/diff 自身意图、不把 sessionIntent 当评分锚[F 簇],引 diff 锚点)。与 design 路「自洽性」「完整性」**区分**(对象 = 代码 vs 设计文档)。
  2. **代码质量不单设地板维**:它已被「方向盘对齐」focus 的通用基线段(功能完整性/代码质量/测试/一致性/简洁性,workflow.js L46 design 版含)覆盖——code 路共用「方向盘对齐」键 → 通用基线段同构保留 → 代码质量被该基线覆盖,无须另立专名维(避免与 Superpowers 同名维概念混淆 + 防冗余)。
  3. **仍 either-or 不叠加**:Superpowers `requesting-code-review` **仅作非 ultracode 回落**;ultracode 路只走 scout(地板已含 spec 忠实性 + 代码质量由基线覆盖,**无真空**)。不改成"scout + Superpowers 叠加跑"(那增复杂度且 ultracode 路本已无真空)。
- **理由(具体可验证)**:① **填真空**:either-or 下 ultracode 路不跑 Superpowers,spec 忠实性入地板是该路覆盖 spec 忠实性的唯一可靠途径;② **避免重复 fork**:仍 either-or(不叠加),故 scout 地板的 spec忠实性 与 Superpowers 内嵌段**不会同时跑**(两路互斥),无冗余;③ **代码质量不另立**有据:design 版方向盘对齐 focus 已含代码质量基线段(workflow.js L46 实证),code 版 `FLOOR_FOCUS_CODE['方向盘对齐']` 同结构含基线即覆盖(D 簇:文字独立、按 reviewType 选),另立 = 冗余。
- **此裁决取代 designer 初裁("scout 不碰")**:初裁误以为"Superpowers 两段恒跑"在 ultracode 路成立(实为 either-or 下不跑),自检揪出后用户拍板让 scout 地板兜 spec 忠实性。§9.2 张力据此**收敛**(见 §9.2)。

#### D-C3 scout-vs-地板门 — ✅ 用户拍板 = B(无门)

- **裁决 = B**:无门——scout 每次读 diff 自由推动态维 + 候选必考虑(不加须 skipped 留痕)。
- **理由**:① 与 design 路一致(design 路无 scout-vs-地板硬门);② 有门 = 又一个静态规则表(与"动态选维"动机相悖);diff 大小 ≠ 该不该加维(小 diff 也可能碰 migration/并发 critical,B-8 信号);③ 轻量跳过已由上游"是否走 code-review 审查"门控,不必在 scout 内再设门;④ 无门 + skipped 留痕已足够透明。**反向追问**:无门会不会让小 diff 也爆维?——不会:scout 的 `why_this_time` 须引 diff 具体证据,小 diff 无信号则 added 自然为空(地板 3 维足够),不会无证据硬加。

#### D-C4 范围/时机 — ✅ 用户拍板 = A(接通-usable)

- **裁决 = A**:本轮接通-usable——新建 code-review skill + workflow code 接线(FloorTable.code 真数据 3 维 + CodeCandidateMenu + FLOOR_FOCUS_CODE[含 code 方向盘对齐/spec忠实性] + scoutPrompt/challengerPrompt reviewType 分支 + diffRef)+ review-rules code 权威节 + synthesis ADD + 地图/凭证,调用真跑。
- **理由**:① workflow.js 已 reviewType 参数化、FloorTable.code 已有占位,工作量小,一步到位避免"骨架就绪但没入口、下轮重新捡上下文";② design 路已是接通-usable 完整形态,code 路同形一次接通保持一致;③ 用户输入 A2 明确要"新建 code-review skill"作触发宿主。**诚实边界**:接通-usable ≠ 实战验证过——推维质量仍 bootstrap 不可证,落地后实战观察(§6.2),但接通是落地实战的前提。

#### D-C5 实现细节裁决(designer 自定 — A 簇审查后细化;非用户决策项)

> A 簇审查揪出"零改函数体"过度乐观,以下是 designer 对实现方式的细化裁决(实现细节,不上抛用户):

- **`scoutPrompt` / `challengerPrompt` 改 reviewType 分支(非零改)**:撤回上一稿"零改函数体 / 100% 复用 challengerPrompt"。两函数现写死 design 串(§3.3 表),必改为 `reviewType==='code'` 分支;**design `else` 分支逐字保留现状**(= 行为零变)。`challengerPrompt` **增 `reviewType` 形参**(调用点 workflow.js L224 同步加传),不靠"`targets.diffRef` 是否存在"隐式分支(显式更可核)。
- **code focus 住独立 `FLOOR_FOCUS_CODE` 常量(不污染 design `FLOOR_FOCUS`)**:design 版 `FLOOR_FOCUS` 键全不改;code 维 focus(含 **code 版方向盘对齐** + **spec忠实性** + 简洁性 + 三候选)住新增 `FLOOR_FOCUS_CODE`。focus 取数处按 reviewType 选(§4.1 (3) 注的取数实现):`方向盘对齐` 命中时 `reviewType==='code' ? FLOOR_FOCUS_CODE.方向盘对齐 : FLOOR_FOCUS.方向盘对齐`——**维名两路都叫「方向盘对齐」**(不加后缀,避免污染 SCOUT_SCHEMA.inherited_floor / 双写),focus 文字按 reviewType 分(D 簇:design「审查设计」vs code「审查代码 diff」语境不可共用)。
- **design 路行为零变的验证机制(非只常量 diff)**:行为流经被改的两函数 → 验证 = `reviewType==='design'` 时两函数产出 prompt 文本与改前**逐字相同**(fixture 快照对比 + else 分支文本静态核,§6.1 A 簇行 / §8.3 CMD2)。
- **governance 留口守卫**:`scoutPrompt` 对 `reviewType==='governance'`(本轮不接线)→ 空菜单 + notes 标"未接线";且无调用方用 governance 调本 workflow(治理审查走现 A/B/C)。"留口"= FloorTable 有 governance 行但无调用,**不是"落空跑 design 菜单"**(§3.1 scoutPrompt 守卫注)。

### 7.3 RUBRIC 应对方式(§1.6 风险标记展开 — 自仓库 RUBRIC = CLAUDE.md + 二公设)

- **惩罚项「简洁性」+ 过度工程化反向追问**:
  - **反向追问("不为 code 加这些常量会怎样")**:不加 FloorTable.code 真数据/CodeCandidateMenu/FLOOR_FOCUS_CODE → 无法满足用户拍板 A1/A2(code 审走 scout)。这些常量**全部被 code 路真用**(地板照抄 / 候选 skipped 判定 / focus 映射),非投机预留。**与 design 路对比的简洁性增益**:code 路是 workflow 的第二个真消费者,把"单消费者抽象"(design 路 §1.6 简洁性风险)转为"双消费者复用",reviewType 参数化现实兑现 → 简洁性风险**降低**(不是新增)。
  - **不为未来 governance 多造**:`FloorTable.governance` 行不动、不为 code 加 governance 相关留口、CodeCandidateMenu 只含 code 真候选。诚实边界:workflow 现有 2 个真消费者(design+code),governance 仍是留口(不接线、不扩)。
  - **简洁性应对(复用最大化,A 簇诚实)**:code 路**真零改** = SCOUT_SCHEMA/FINDING_SCHEMA/reviewScout 编排骨架;**加 reviewType 分支(非零改)** = `scoutPrompt`/`challengerPrompt` 函数体(design else 逐字保留,行为零变);**新增常量** = FloorTable.code 值 + CodeCandidateMenu + FLOOR_FOCUS_CODE + diffRef 字段。诚实标注:两 prompt 函数体须改(加分支),不说"零改函数体";最小变更体现在 design else 逐字保留 + 每行 code diff 可追溯到 code 接线。
- **惩罚项「一致性」**:code 路与 design 路**结构同构**——同 fork-N 机制、同 SCOUT/FINDING_SCHEMA、同薄包装骨架、同 ADD-不替换框、同 ultracode 专属取舍、同 A-3 判据(focus 文字按 reviewType 分,判据通用)、同 B-8 引导框、同自读盘。**不引入第二套机制**;code 特化 = 常量值 + diffRef + 候选菜单 + code 版 focus(含 code 方向盘对齐/spec忠实性)+ 两 prompt 函数的 reviewType 分支。一致性奖励而非惩罚。
- **诚实:原始痛点在非 ultracode 路未解**:同 design 路 §7.3——动态推维仅 ultracode 路兑现;非 ultracode 路走 Superpowers `requesting-code-review`(固定五节+两段),"代码审查永远静态维"的痛点在该路依然未解。如实承认:本功能给 ultracode 路解痛点 + 给其余路保底(Superpowers),非全路径解痛点。
- **either-or 真空已由 spec忠实性入地板解决(D-C2 收敛)**:designer 初裁"scout 不碰 spec忠实性"会在 either-or 下留 ultracode 路真空(不跑 Superpowers 则无人审 spec 忠实性);自检揪出后用户拍板让 **spec忠实性入 code 地板**填真空。**故 ultracode 路 spec 忠实性由地板维保证(不再"靠综合间接覆盖、不保证等价")**;代码质量由方向盘对齐通用基线覆盖。残留观察项 = code 版 spec忠实性维与 design 自洽性/完整性的边界清晰度(§6.2 ②),非"覆盖真空"。
- **凭证义务**:命中 credentials.conf = 新 skill(`.claude/skills/*/*.md`)/ review-rules(governance)/ workflow.js(`.claude/workflows/*`)/ review-scout.md(`.claude/agents/*.md`)/ CLAUDE×2 → 收口产 audit(§8 covers 清单)。QUICKREF 不命中凭证(同 design 路)但仍改(触点)。
- **触点完整性**:FloorTable.code↔review-rules code 地板维表注双写(credentials-rules §8 #6 已立的对;现状 L19 code 行 2 维占位 → 本功能同步更新为 3 维 + 补候选/either-or 注)+ synthesis 主表 L16/L99 地板数为 code ADD 注(C 簇)+ 新 skill 入口在 CLAUDE×2 角色表「开发」行/CLAUDE×2 Skill 地图/QUICKREF Skill 表(新行,非映射行 L34)登记。§8.3 grep 自核。
- **bootstrap 不可证**:code scout 推维质量 + code版spec忠实性维边界清晰度(§6.2 ②)落地前不可证 → 声明 + 推 meta-L4 实战;但 spec 内具体可证漏洞(方向盘 key 共用冲突 §5.1、spec忠实性 vs 自洽性/完整性键不冲突 §5.1、双写断链 §8)已保留并核。
- **奖励项**:scout 路确定性扇出(ultracode 专属)/ 强化公设1 / 挡 spec-gap-masking(skipped)/ 复用增量(最小变更)/ either-or 无重复 fork(scout 与 Superpowers 互斥)/ **spec忠实性入地板填 either-or 真空** — 均 §1.6 列、§7 兑现。

**自检**:
- [x] 每个决策原因具体可验证:D-C1=A(条件相关+候选 skipped 兜)/D-C2=spec忠实性入地板(either-or 填真空+代码质量基线覆盖)/D-C3=B(与 design 一致+动态动机+无门反向追问)/D-C4=A(工作量+A2 要求+诚实边界)— 无空话,均用户拍板。
- [x] 无决策与架构冲突:自仓库无 ARCHITECTURE.md;与 CLAUDE.md 角色分离/二公设一致(scout 独立 fork);与 design 路严格同构(一致性强;code 地板 3 维 vs design 2 维是 either-or 填真空的合理差异,§9.2 已述)。
- [x] 无决策与 RUBRIC 惩罚项冲突:简洁性(复用最大化、双消费者降风险)/一致性(严格同构)已 §7.3 诚实应对;either-or 真空已由 spec忠实性入地板解决(§9.2 收敛)。
- [x] 决策(D-C1/D-C2/D-C3/D-C4)用户已拍板,decisions 文件「## 决定」段已填(§7.4);spec 据此修订无悬空 🟡。
- [x] §1.6 每个 RUBRIC 惩罚项有应对:简洁性/一致性/痛点未解/either-or 真空(已解)/凭证/触点/bootstrap 全 §7.3 列。

### 7.4 写入 docs/decisions/ 的项(✅ 用户已拍板)

- **D-C1 / D-C2 / D-C3 / D-C4** → `docs/decisions/2026-06-15-code-review-scout-decisions.md`(本 spec 同批产出),「## 决定」段已填用户裁决:D-C1=A(类型契约候选)/ D-C2=spec忠实性入 code 地板(either-or 不叠加,scout 地板兜真空,代码质量靠方向盘对齐通用基线)/ D-C3=B(无门)/ D-C4=A(接通-usable)。无悬空 🟡。

---

## 8. 与既有系统的影响

### 8.1 需要改动/新建的文件

| 文件 | 改什么 | 为什么 | 影响范围 |
|------|-------|--------|---------|
| `.claude/skills/code-review/SKILL.md` | **新建** — 镜像 design-review SKILL:执行开头运行时分支(ultracode→review-scout workflow reviewType='code' / 否则→Superpowers requesting-code-review)+ scout 路综合维序说明(钉此,按 plan 维序) | A2 触发宿主 | 凭证义务命中(`.claude/skills/*/*.md`);被调度者调用 |
| `.claude/workflows/review-scout.workflow.js` | **改动** — ① `FloorTable.code` 3 维(方向盘对齐+简洁性+spec忠实性)② 新增 `CodeCandidateMenu` + `FLOOR_FOCUS_CODE` 常量(code 维 focus,含 code 版方向盘对齐 + spec忠实性,scout 路自有)③ **`scoutPrompt` 加 reviewType 分支**(候选菜单按 reviewType 取 / 被审材料指针 code 路注 diffRef+spec / governance 守卫 → 空菜单)④ **`challengerPrompt` 加 `reviewType` 形参 + 三处串分支**(角色行 L160/材料路径 L166/location L180;**design else 逐字保留**)。**design else 分支 = 改前文本(行为零变);非"零改函数体"**(A 簇修订)。reviewScout 编排/SCOUT_SCHEMA/FINDING_SCHEMA 真零改 | code 接线(CM-wf-code) | 凭证义务命中(`.claude/workflows/*`);design 路常量 + design else 文本零改(§8.3 prompt 文本等价核) |
| `.claude/agents/review-scout.md` | **改动** — 推维步骤按 reviewType 切候选菜单/语境(现第 3 步硬编码 DesignCandidateMenu → 参数化"按 reviewType 取菜单")+ B-8 code 加维引导(code 信号举例)+ **code 语境注明:spec忠实性是地板维(scout 照抄,非自己发明);代码质量不另立 added 维(基线覆盖,D-C2)** | CM-scout-agent | 凭证义务命中(`.claude/agents/*.md`,自动);被 workflow fork |
| `docs/governance/review-rules.md` | **改动三处**:① **L11 代码行五节描述**:加 scout 主推注(对齐 L12 设计行写法:"ultracode/Workflow 在场时,代码行默认走 review-scout `reviewType='code'`;Superpowers 五节+两段为 ultracode 不在场回落")—— 不改五节正文 ② **L19 现有 code 行 2 维占位 → 3 维同步更新**:现状 L19 = `code = 方向盘对齐 + 简洁性(留口,后续可加)`(地板维表注里 code 行仍 2 维占位),改为 `code = 方向盘对齐 + 简洁性 + spec忠实性`(去"留口"措辞)——**防旧 L19 2 维与新权威节 3 维两份打架** ③ **建/补 code 地板维表权威节**(对齐 L15-24 设计行 scout 注:code 地板 3 维 + 候选[类型契约合规/架构合规/模块文档一致性] + either-or 说明 + 双写派生注 ↔ workflow.js FloorTable.code/FLOOR_FOCUS_CODE)。**注**:L17-22 地板维表已是三类注(design/code/governance 各一行),故 ② = 更新该表 code 行 + ③ 补 code 候选/either-or 说明,不另起重复表 | CM-floor-table(权威住此) | 凭证义务命中(`docs/governance/*.md`);FloorTable.code/CodeCandidateMenu 双写上游 |
| `docs/governance/synthesis-rules.md`(**C 簇 ADD**) | **改动** — 主表 L16「review-scout \| 动态 N(地板 2 + 动态加)」+ 事前规则5 清单 L99「review-scout(scout 驱动 N 挑战者,N=地板 2+动态加)」对 code(地板 3)不准 → **两处各 ADD 注**"地板按类:design 2 / code 3"(或表述改"地板按类 2-3 + 动态加")。维序 L153 仍零改 | C 簇(synthesis 真触点,design 批四处 ADD 未含此) | 凭证义务命中(`docs/governance/*.md`) |
| `CLAUDE.md`(根治理入口) | **改动** — 角色分离表**「开发」行**(`\| 开发 \| Superpowers subagent \| 写代码(TDD + code review) \|`,L32;**无独立"代码审查"行**)→ 在该行说明列**加注** "(代码审查:ultracode 走 review-scout `reviewType='code'`;否则 Superpowers requesting-code-review)";不动现有描述 | CM-地图注 | 凭证义务命中(根级,covers 写 `<root>/CLAUDE.md`) |
| `harness/CLAUDE.md`(M4 分发模板) | **改动** — ① 角色分离表「开发」行同根加注(与根**双写**)② Skill 全局地图**新增 code-review 行**(design-review 行下方,镜像其写法:"ultracode 走 review-scout `reviewType='code'`;否则 Superpowers");不改现有描述 | CM-地图注(双写对) | 凭证义务命中(hook `--relative` 视角 = `CLAUDE.md`) |
| `QUICKREF.md`(**Skill 表 L40-48,非映射行 L34**) | **改动** — 在 **Skill 表**(L40-48,design-review 在 L44)**新增 code-review 行**:`\| code-review \| 代码改动审查 — 主推 ultracode 走 review-scout(reviewType=code);回落 Superpowers requesting-code-review \|`。**L34 是「治理规则→文件」映射行(code-review→review-rules.md),不动它**(skill 登记落 Skill 表,非映射行) | CM-地图注 | **凭证义务不命中**(无 QUICKREF glob)→ 不进 covers,但仍改(触点) |
| `.claude/hooks/credentials.conf` + `credentials-rules §2` | **不改** — `.claude/skills/*/*.md`(新 skill 自动)/ `.claude/workflows/*`(workflow.js,2026-06-13 已立)/ `.claude/agents/*.md`(review-scout.md 自动)glob **已存在**,新 skill/改动自动入凭证,无须加新 glob | 复用现有 glob | (无 diff) |
| `setup.sh`(`harness/setup.sh`) | **改动** — 新增 `mkdir -p .claude/skills/code-review` + `cp code-review/SKILL.md`(对齐现 skills 复制段 L57-71) | 分发新 skill | 凭证义务命中(`setup.sh`) |

> **新 skill 凭证状态**:`.claude/skills/code-review/SKILL.md` → 落已有 `.claude/skills/*/*.md` glob → **自动入凭证,不需改 conf**;新建即在 covers 义务内。**无新 glob 需求**(workflow.js 的 `.claude/workflows/*` glob 2026-06-13 已立;agent 的 `.claude/agents/*` 早立)。

### 8.2 不改动但需验证兼容的(F 守住声明)

| 文件/模块 | 改/不改 + 凭证命中? | 理由 |
|----------|---------|------|
| **Superpowers `requesting-code-review`(回落路)** | **不改 / 不在 harness 仓**(Superpowers 包) | F 守住:回落路原样,不碰 Superpowers 包;code-review skill 原样调用它(ultracode 不在场时) |
| **`.claude/agents/design-reviewer.md`** | **不改 / 凭证命中(不改→不进 covers)** | F 守住:code 路与它零关系(不读/不抄/不镜像);code focus 住 workflow.js `FLOOR_FOCUS_CODE` 常量。收口 git diff = 空 |
| **review-scout.workflow.js design 路常量 + 编排骨架** | **真零改部分**(`FloorTable.design` / `DesignCandidateMenu` / design 版 FLOOR_FOCUS 键 / SCOUT_SCHEMA / FINDING_SCHEMA / reviewScout 默认导出) | F 守住:design 路常量/编排骨架零退化。**注**:`scoutPrompt`/`challengerPrompt` 函数体**会改**(加 reviewType 分支),不在本"零改"行——它们的 design **else 分支逐字保留** = 行为零变,靠 §8.3 prompt 文本等价核(非只 git diff 常量) |
| **`.claude/skills/design-review/SKILL.md`** | **不改 / 凭证命中(不改→不进 covers)** | F 守住:design 审入口/回落/维序不动;code 审是**独立新 skill**,不复用 design-review skill。收口 git diff = 空 |
| **synthesis-rules.md(C 簇:由"零改"修正为"两处 ADD 注")** | **改动(主表 L16 + 事前5 清单 L99 各 ADD code 地板数注)** / 凭证命中 | **修正上一稿"零改"**:适用范围按 workflow 名 `review-scout` 登记(L3/L16/L99/L171)对 code 仍覆盖,但 **L16「动态 N(地板 2+动态加)」+ L99「N=地板 2+动态加」写死"地板 2"对 code(地板 3)不准** → 两处各 ADD 注"地板按类:design 2 / code 3"。**维序 L153 仍零改**(scout 路维序住 CM-skill);L3/L171 按 workflow 名已覆盖 code,不改 |
| **review-rules Superpowers 代码类五节正文(L46-79)** | **正文不改**(整体文件改:L11 加注 + L19 code 行 2→3 维 + 补候选注,见 §8.1)/ 凭证命中 | F 守住:五节正文服务 Superpowers `requesting-code-review` 激活时读,Superpowers 路不变;scout 路从五节**取候选维名**(架构合规/模块文档一致性/类型契约/简洁性)但**不改五节正文**。文件改动 = L11 行加 scout 主推注 + L19 code 地板行 2→3 维同步 + 补 code 候选/either-or 注(§8.1),五节 L46-79 正文零改 |
| `AGENTS.md`×2 | **不改 / 凭证命中(不改→不进 covers)** | grep 无 code-review/4 维相关,不改 |
| **`harness/README.md` L150 职责表 `\| 代码审查 \| Superpowers requesting-code-review \|`** | **不改(豁免留 cleanup)/ 凭证不命中(README 不在 credentials.conf glob)** | **豁免理由(对齐 design 路对该表的处理)**:① README **不分发下游**(setup.sh 不复制根 README),该行失真是**陈述失真非分发断裂**;② 该表 **design 路同例**也无 design-review 行(只列 Superpowers 原能力)——本功能不为 code 单独破例改它,与 design 路对该表的处理**对称**;③ 列入 ROADMAP/cleanup 候选(未来 README 审查链路整体刷新时一并更)。**非阻断**(CLAUDE×2 角色表[分发模板,命中凭证]已同步,可校验入口不失真) |
| `model-route.md` / `references/` / `ROADMAP.md` | **不改 / —** | 描述现有审查链路,Y 下不变(若有 code-review 链路描述则核;预期零改) |

### 8.3 触点完整性 grep 自核命令(收口前跑)

```bash
# 1. 【结构兜底】全仓 git diff,确认改动集只含 §8.1 列文件
git diff --stat
#   判据:diff 只应出现 §8.1 ADD/新建文件(code-review/SKILL.md 新建 + workflow.js + review-scout.md + review-rules + synthesis-rules + CLAUDE×2 + QUICKREF + harness/setup.sh)。
#   design 路文件(design-review SKILL / design-reviewer.md)出现任何 diff = 违 F 守住,回退。
# 2. 【A 簇 — design 路行为零变:不只看常量 diff,看 prompt 文本等价】
#   (a) workflow.js diff 应只 = 新增 code 常量(FloorTable.code/CodeCandidateMenu/FLOOR_FOCUS_CODE)+ 两函数 reviewType 分支;
git diff "harness/.claude/workflows/review-scout.workflow.js"
#       FloorTable.design / DesignCandidateMenu / FLOOR_FOCUS design 键 / SCOUT_SCHEMA / FINDING_SCHEMA / reviewScout 默认导出 零 diff。
#   (b) design else 分支文本 = 改前文本:核 challengerPrompt else 仍含原串、scoutPrompt else 仍注 DesignCandidateMenu/targets.spec:
grep -nF '你是设计审查挑战者,负责' "harness/.claude/workflows/review-scout.workflow.js"          # 期望:仍命中(design else 角色行原文)
grep -nF 'location(文档节/路径)' "harness/.claude/workflows/review-scout.workflow.js"             # 期望:仍命中(design else location 原文)
grep -nF 'DesignCandidateMenu)' "harness/.claude/workflows/review-scout.workflow.js"              # 期望:scoutPrompt design else 仍注 DesignCandidateMenu
#   (c) 行为级:reviewType='design' 时两函数产出 prompt 文本 == 改前快照(fixture 对比,§6.1 A 簇行)。
# 3. design-reviewer.md / design-review SKILL 零 diff(F 守住)
git diff "harness/.claude/agents/design-reviewer.md" "harness/.claude/skills/design-review/SKILL.md"   # 期望:空
# 4. 【B 簇 — FloorTable.code 三维有序集逐字一致,不是散词搜】(credentials-rules §8 #6)
grep -noE "code:[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"
#   期望:输出含 `code: ['方向盘对齐', '简洁性', 'spec忠实性']`(三维有序集);
grep -nF "方向盘对齐 + 简洁性 + spec忠实性" harness/docs/governance/review-rules.md   # 期望:review-rules L19 code 地板行命中同序三维(双写逐字)
grep -nF "code = 方向盘对齐 + 简洁性(留口" harness/docs/governance/review-rules.md   # 期望:零命中(旧 2 维占位已被 3 维替换;若命中=两份打架,回退)
grep -noE "CodeCandidateMenu = \[[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"  # 期望:['类型契约合规', '架构合规', '模块文档一致性']
grep -nF "类型契约合规 + 架构合规 + 模块文档一致性" harness/docs/governance/review-rules.md   # 期望:review-rules 候选注命中同序(双写)
# 5. 【B 簇 — 新 skill 入口登记:正则命中无引号实际文字;落点对真实结构】
grep -rnE "review-scout|reviewType=.?code" CLAUDE.md harness/CLAUDE.md harness/QUICKREF.md "harness/.claude/skills/code-review/SKILL.md"
#   期望:CLAUDE×2「开发」行加注 + harness/CLAUDE Skill 地图新 code-review 行 + QUICKREF Skill 表(L40-48)新 code-review 行 + 新 SKILL 分支 各命中。
#   注:正则 `reviewType=.?code` 同时命中 reviewType='code' / reviewType=code(防引号假绿——上一稿 `reviewType='code'` 带引号与实际无引号注文不命中)。
grep -nF "code-review" harness/QUICKREF.md   # 期望:2 处 = L34 映射行(原有,不动)+ Skill 表新行;只 1 处 = 漏建 Skill 表行
# 6. 双写对核(CLAUDE×2「开发」行加注语义一致)
diff <(grep -E '开发.*Superpowers|code-review|review-scout' CLAUDE.md) <(grep -E '开发.*Superpowers|code-review|review-scout' harness/CLAUDE.md)
# 7. 分发(setup.sh code-review skill 复制段)
grep -nF "code-review" harness/setup.sh   # 期望:mkdir + cp code-review/SKILL.md 命中
# 8. 【C 簇 — synthesis 主表 L16/事前5清单 L99 地板数为 code ADD 注】
grep -nE "地板 2|design 2 / code 3|地板按类" harness/docs/governance/synthesis-rules.md
#   期望:L16 + L99 原"地板 2"处已 ADD code 地板数注(design 2 / code 3);(grep 按内容命中,不依赖行号)
git diff harness/docs/governance/synthesis-rules.md   # 期望:只在 L16/L99 各 +注;维序 L153 段无 diff;L3/L171 无 diff
```

### 8.4 不改动但需验证兼容的(汇总自检)

**自检**:
- [x] 改动已有文件时调用方都考虑:新 code-review skill → 调用方 = 调度者(入口);workflow.js code 分支 → 消费方 = 新 skill;review-rules code 注 → 消费方 = skill/CLAUDE(已同步);design 路消费方不受影响(reviewType 分支隔离,零改)。
- [x] 新旧模块交互无不兼容:code scout 路 ADD 并排,design 路 + Superpowers 回落路零改动并存;ultracode 关回落 Superpowers(不碰包)。
- [x] §2 标"改动/新建"的模块都在 §8.1 列具体文件:CM-skill→新 SKILL / CM-wf-code→workflow.js / CM-scout-agent→review-scout.md / CM-floor-table→review-rules(L11 注 + L19 code 行 2→3 维 + 补候选注)/ **synthesis(C 簇 ADD)** / CM-地图注→CLAUDE×2「开发」行 + harness Skill 地图 + QUICKREF Skill 表新行 + setup.sh;不改模块(CM-Superpowers/CM-reviewer/CM-design 路)→ §8.2 列、git diff 应为空;§2↔§8 一致(synthesis 由 §8.2 不改移入 §8.1 改动)。
- [x] 触点完整性 grep 8 组(B 簇修订:CMD2 加 prompt 文本等价核 + CMD4 有序集 grep + CMD5 正则命中无引号文字 + CMD8 synthesis ADD)+ CMD1 全仓 diff 兜底;凭证(新 skill/workflow/agent/review-rules/synthesis/CLAUDE×2/setup.sh)vs 触点(QUICKREF 不命中凭证)两套独立已厘清。
- [x] D-C1~D-C4 用户已拍板,decisions 文件「## 决定」段已填;接口方向已定(FloorTable.code = 3 维[方向盘对齐+简洁性+spec忠实性]/ CodeCandidateMenu = 类型契约+架构合规+模块文档一致性),无悬空 🟡。

---

## 9. 全局自洽性检查

- [x] **需求 ↔ 模块**:P0 场景1(ultracode 走 code scout)→CM-wf-code 全链;P0 场景2(方向盘自适应)→CM-scout-agent 复用 A-3;P0 场景3(非 ultracode 走 Superpowers)→CM-skill 回落分支;P0 场景4(either-or + spec忠实性入地板 + 代码质量基线覆盖)→D-C2 + FloorTable.code 3 维;P1(三层选维)→FloorTable.code + CodeCandidateMenu + 发明维。每场景有路径(§2.1 自检)。
- [x] **模块 ↔ 接口**:CM-skill↔§3.1/3.5(入口分支+综合维序);CM-wf-code↔§3.1(diffRef + scoutPrompt 分支)/§3.3(challengerPrompt reviewType 分支)/§4.1(FloorTable.code/CodeCandidateMenu/FLOOR_FOCUS_CODE);CM-scout-agent↔§3.2(复用 SCOUT_SCHEMA,值变)；code 挑战者↔§3.3/3.4(challengerPrompt 加 reviewType 分支、focus 住 FLOOR_FOCUS_CODE);无孤岛模块(CM-地图注职责=同步登记,经 §8.1 体现)。
- [x] **接口 ↔ 数据**:入参 reviewType='code'/targets(含 diffRef)/sessionIntent 在 §3.1/§4;SCOUT_SCHEMA/FINDING_SCHEMA 复用主 spec §4(零改);FloorTable.code/CodeCandidateMenu/FLOOR_FOCUS_CODE 在 §4.1。
- [x] **数据 ↔ 边界**:FloorTable.code 3 维(照抄不可改)/CodeCandidateMenu(空合法但 skipped 须解释)/diffRef(缺+spec 缺则报错)/无对照 spec(spec忠实性维仍跑、回落任务描述、F 簇不当评分锚)/方向盘对齐 focus 按 reviewType 选(D 簇,非共用同一文字;维名一致键不冲突)/spec忠实性 vs design 自洽性·完整性(不同键不同对象,无冲突;E 簇互斥边界写进 focus)/scout 误加代码质量维(基线已覆盖+综合去重)均 §5.1 有处理。
- [x] **依赖 ↔ 架构**:自仓库无 ARCHITECTURE.md;依赖方向(§2.2)无环;符合 CLAUDE.md 做审分离(scout 独立 fork);code 路与 design 路 reviewType 分支隔离,无循环。
- [x] **决策 ↔ 需求**:A1-A5(用户拍板)+ D-C1~D-C4(用户已拍板)均锚 §1 需求,无偏离边界(§1.3 不做清单:不改 Superpowers 包/Superpowers 不与 scout 叠加跑(either-or)/代码质量不单设地板维/design 路不污染/不读 design-reviewer.md/不接 governance/不预设硬门/不为 code 造多余留口 — §8.2 守住)。
- [x] **决策 ↔ 架构**:D-C1=A(类型契约候选)/D-C2(spec忠实性入地板、either-or 不叠加)/D-C3=B(无门)/D-C4=A(接通-usable)与 CLAUDE.md 现状架构并存;code scout 路 ADD,design 路 + Superpowers 回落路零改动;与 design 路严格同构(code 地板 3 维 vs design 2 维 = either-or 填真空的合理差异)。
- [x] **影响 ↔ 模块**:§8.1 改动/新建文件 ↔ §2.1 标"新建/改动"模块对应(CM-skill/CM-wf-code/CM-scout-agent/CM-floor-table/synthesis C 簇 ADD/CM-地图注 + setup.sh);不改模块(CM-Superpowers/CM-reviewer/CM-design 路常量+编排)→ §8.2 列、git diff 应为空;§2↔§8 一致;完整性靠 §8.3 CMD1 全仓 diff 兜底。**A 簇:两 prompt 函数体改(加分支)、design else 逐字保留——靠 §8.3 CMD2 prompt 文本等价核,非只常量 diff。**
- [x] **RUBRIC ↔ 设计**:§1.6 每个惩罚项(简洁性/一致性/痛点未解/either-or 真空[已由 spec忠实性入地板解决]/凭证/触点/bootstrap)→ §7.3 应对;奖励项(确定性扇出 ultracode 专属/复用增量/either-or 无重复 fork)诚实化;ultracode 路 spec 忠实性由地板维保证(不再标"不保证等价")。**A 簇:撤回"零改函数体/100% 复用"过度乐观措辞,改诚实 reviewType 分支 + design 行为零变验证机制。**
- [x] **契约 ↔ 接口**:无 API 端点(§3 自检);schema 契约(SCOUT_SCHEMA/FINDING_SCHEMA)复用零改;新字段命名(diffRef/CodeCandidateMenu/FloorTable.code/FLOOR_FOCUS_CODE)全文一致;§3↔§4 无字段断链;**方向盘对齐 focus 按 reviewType 选(D 簇,design/code 文字不同),维名一致键不冲突,已校验(§3.3/§4.1/§5.1)**。

### 9.1 决策状态

1. **复用决策(已定)**:A1-A5 用户拍板 + 主 spec D6/D8/D9/D11/D12/A-1/A-3/D13 复用,无悬空。
2. **D-C1~D-C4 用户已拍板(2026-06-15)**:D-C1=A(类型契约候选)/ D-C2=spec忠实性入 code 地板(either-or 不叠加)/ D-C3=B(无门)/ D-C4=A(接通-usable)。decisions 文件「## 决定」段已填,spec 正文据此修订。**无悬空 🟡**。
3. **接口最终值**:`FloorTable.code = ['方向盘对齐','简洁性','spec忠实性']`(3 维);`CodeCandidateMenu = ['类型契约合规','架构合规','模块文档一致性']`;新增 `FLOOR_FOCUS_CODE` 含 code 版方向盘对齐 + spec忠实性 + 简洁性 + 三候选键。实现细节(diffRef 字段、FLOOR_FOCUS_CODE 独立常量、scoutPrompt/challengerPrompt reviewType 分支 + design else 逐字保留、design 行为零变靠 prompt 文本快照核)designer 自定记 §7.2 D-C5。

### 9.2 张力收敛记录(either-or 真空 → spec忠实性入地板)

> 上一轮 designer 初裁 §9.2 曾把"either-or 下 ultracode 路不跑 Superpowers、spec 忠实性留真空"列为须用户确认的张力(初裁 = scout 不碰两段、靠综合间接覆盖、不保证等价)。**用户已拍板收敛**:

1. **张力根因(已确认)**:本功能两路 **either-or**——ultracode 开走 scout 路时**不调用 Superpowers**,故"Superpowers 两段恒跑"在 ultracode 路不成立;若 scout 不碰 spec 忠实性 → 该路留真空(无人审实现是否忠于 spec)。
2. **用户拍板收敛 = spec忠实性入 code 地板(either-or 不叠加)**:
   - **spec 忠实性** = code 地板第 3 维(scout 路每次必跑)→ ultracode 路 spec 忠实性**由地板维保证**(真空已填,不再"靠综合间接覆盖、不保证等价")。
   - **代码质量** 由 **`FLOOR_FOCUS_CODE['方向盘对齐']` 的 code 通用基线段**覆盖(D 簇:code 版方向盘对齐 focus 自含"功能正确/真实代码质量/测试/一致性/简洁性"基线;design 版含同结构基线,**同构但 focus 文字按 reviewType 分,非共用同一键值**),无须单设地板维。
   - **仍 either-or 不叠加**:Superpowers `requesting-code-review` 仅作非 ultracode 回落;不改成 scout+Superpowers 并跑(ultracode 路已无真空,叠加只增复杂度 + 冗余 fork)。
3. **D-C1 类型契约落点(已拍板 = 候选)**:类型契约合规入 `CodeCandidateMenu`(diff 驱动,scout 按 diff 选,不加须 skipped 留痕);非地板。
4. **收敛后无悬空缺陷**:§9.2 原 1/2 张力(either-or vs "恒跑"措辞)已由"spec忠实性入地板"实质解决——ultracode 路不依赖 Superpowers 恒跑、自有地板维兜底;原 3(类型契约落点)已拍板候选。**未发现新的需求缺陷/矛盾**。
5. **残留实战观察项(非缺陷,推 meta-L4)**:code 版 spec忠实性地板维与 design 路自洽性/完整性的边界清晰度(对象=代码 vs 设计文档,§6.2 ②)——落地前不可证,实战回看,如实列出不粉饰。

### 9.3 design-review 审查后修订记录(7 挑战者,需修复后重审 — 4🔴+16🟡 逐簇收敛)

> dogfood review-scout 审本 spec,产 4🔴+16🟡。逐簇修订(基于真实文件核):

- **A 簇(🔴 最重)— 撤回"零改函数体/100% 复用"过度乐观**:核实 `challengerPrompt`(L160/166/180)+ `scoutPrompt`(L136/139)+ `FLOOR_FOCUS['方向盘对齐']`(L42)全写死 design 串,"零改"与"code 须给 diffRef/code 语境"不可兼得。改为:两 prompt 函数 + 方向盘 focus **加 reviewType 分支,design else 逐字保留**;design 行为零变验证 = **prompt 文本快照核(非只常量 diff)**(§3.3/§6.1 A 簇行/§8.3 CMD2/§7.2 D-C5)。
- **D 簇(并入 A)— 方向盘对齐 focus 不两路共用**:新增 `FLOOR_FOCUS_CODE['方向盘对齐']`(code-context:审 diff 对齐方向盘 + code 基线),focus 按 reviewType 选,维名仍一致不污染 SCOUT_SCHEMA/双写(§4.1)。
- **B 簇(🟡 触点错位)— §8.1/§8.3 对齐真实文件**:CLAUDE×2 无「代码审查」行 → 落「开发」行加注;QUICKREF skill 登记落 **Skill 表(L40-48 新行)**非映射行 L34;§8.3 正则改 `reviewType=.?code`(命中无引号文字,防假绿);review-rules **真建 code 地板维表权威节**(非只声称);CMD4 改**有序集 grep**(三维逐字,非散词)。
- **C 簇(🟡)— synthesis 主表 L16/事前5清单 L99「地板 2」对 code 不准** → 两处 ADD 注"地板按类:design 2 / code 3"(synthesis 移入 §8.1 改动,design 批四处 ADD 未含此处)。
- **E 簇(🟡)— spec忠实性/简洁性/方向盘对齐 focus 互斥边界**:三 focus 文字各写"⚠️ 互斥边界"(忠于本次任务 vs 多做的害处 vs 对齐长期标准);可证边界写进 focus,不推 bootstrap。并修 §4.2「scout 不产 spec 忠实性维」与"入地板照抄"的对冲(改为 scout 照抄地板含 spec忠实性)。
- **F 簇(🟡)— spec 缺时 sessionIntent 回落**:spec忠实性维 spec 缺时**回落对照"任务描述/diff 自身意图"**,不把 sessionIntent 当忠实度评分锚(守 synthesis 事前规则 5)(§3.1 F 簇/§4.1 spec忠实性 focus/§5.1)。
- **decisions 文件同步**:D-C2「代码质量靠通用基线」措辞同步更新为"code 版方向盘对齐 focus 自含基线"(D 簇连带)。

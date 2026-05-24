# codex 接入搁置 batch 系统设计

> **标准级 spec**(`design-rules.md` §规模判断 — 默认升级原则)— 11 处文件改动超 designer.md 轻量级"1-2 文件"条件,跨 governance / ROADMAP / self-check / README 多文件类型 = 跨子模态,按默认升级原则升至标准级。

> **scope**:meta(A 组 `docs/governance/*.md`)+ mixed 跟随(ROADMAP / self-check / decision-trail / handoff / README)— 按 CLAUDE.md §3 §4 "任一命中即 meta",**整个 batch 走 meta 路径**。走 `meta-finishing-rules.md`(M1)四步流程 + `meta-review-rules.md`(M2)fork N=4 挑战者审查。

> **流程深度**:用户 2026-05-24 选**完整流程**(brainstorming + design + design-review + M1 + M2)— 在 harness meta path 基础上加严走 design + design-review(harness meta path 默认只 M1 + M2)。

---

## §0 偏离说明

不偏离 `DESIGN_TEMPLATE.md` 模板结构。

**结构差异**(2026-05-25 Critical 10 修订 — §0 偏离规则 L40 限定"只允许记录结构差异:用什么 heading / 用什么编号 / 调整哪节顺序"):
- **编号差异**:使用 §0 + §1 + §2-§4(标"不适用")+ §5-§9 完整编号 — 未跳过任何节(各节正文内自行声明"不适用 — meta scope 措辞调整")
- **节顺序**:不变(沿用 DESIGN_TEMPLATE 默认顺序)
- **heading 风格**:不变(沿用 DESIGN_TEMPLATE 默认 markdown 标题层级)

**§2 / §3 / §4 内容判定**(从 §0 结构差异下移至各节正文):各节正文开头已声明 "**不适用 — meta scope 措辞调整**"(详 §2 / §3 / §4 各节开头第一句),这是各节内容判定而非 §0 结构差异。

**§5 / §6 主题适配**:§5 主题改为"措辞冲突场景 + 跨文件互引悬空处理"、§6 主题改为"措辞一致性验证 + meta-review 4 挑战者维度"— 各节正文内已声明,这是各节内容定制非 §0 结构差异。

**RUBRIC 引用约定**(澄清 Critical 11 修订 2026-05-25):本 spec **描述性引用 RUBRIC**(§1.6 "简洁性" / "一致性" 等维度名称、§6.2 挑战者 #4 子焦点"RUBRIC 简洁性"、§7.1 应对方式表 — 用于描述风险/应对/审查焦点),**但不作 design-review 豁免依据**(M2 / M4 约束;即不用 RUBRIC 维度免除某项 design-review 维度检查)。两种用法显式区分:
- **allowed**(描述性):引用 RUBRIC 维度名描述风险(§1.6)、作为挑战者子焦点(§6.2)、作为应对方式锚点(§7.1)
- **disallowed**(豁免依据):用 RUBRIC 维度证明某 design-review 维度可跳过 / 用 RUBRIC 评分代替挑战者 verdict — 本 spec 不做

---

## 1. 需求摘要

### 1.1 用户目标

搁置 codex 接入 batch(11 swap 角色入 governance);fork 子任务维持全 Claude;不删现有规划文档(model-route.md / synthesis-rules P2 阶段约束段 / 3 governance rules 引用),改"搁置中"状态。**不预设重启时间 / 启动条件 / 触发信号**(对齐 `feedback_iterative_progression`:不预设固化未来阶段)。

**背景**:
- 2026-05-13 ~ 2026-05-22 P0.9.4 主线立 "P2 codex 接入" 规划(model-route.md + synthesis-rules P2 阶段约束段 + 3 governance rules 引用 + p0-9-4-self-check §C)
- 2026-05-24 用户与调度者 cross-check 发现:
  - **实施层 0% 落地** — model-route §4 列的 11 swap 角色中,5-6 个在 `harness/.claude/{agents,skills}/` 里本身不存在
  - **plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝**(实证)
  - **codex exec 直调 gpt-5.5 通**(本机 Test 1 验证)但 harness 入口需在 skill/agent 文件里设计调用范式,非 5 分钟改动
  - `feedback_iterative_progression`:无具体真实需求拉动时不做

### 1.2 核心场景

> meta scope 是治理改动,无 feature 用户场景。改为"治理意图触发场景"。

1. **[P0] 后续读者识别搁置状态**:Claude / 用户 / 挑战者 后续读 `model-route.md` → 看到文件头 banner `[2026-05-24] codex 接入搁置` → 知道当前不主动实施 → 不试图按 §4 swap 11 角色
   - **现状缺口**:无 banner,后续读者可能误启动实施,浪费往返(已在本会话耗 ~2 小时排查"已实施还是规划")

2. **[P0] 重启时定位需重审的文档**:未来用户决定重启 codex 接入时 → grep "搁置中" 关键词 → 找到全部 11 处需重审/重写的位置(model-route banner + 4 governance 引用 + ROADMAP + self-check §C/§G3/§G4/§F2 + decision-trail 拐点 + handoff + 2 README)
   - **现状缺口**:无统一搁置标记,重启时需重新逐文件 grep "codex" 找上下文

3. **[P1] 下游分发感知**(2026-05-25 Critical 8 修订 — 从 P0 降为 P1):下游用户 setup.sh 部署 harness → `harness/README.md` 提示 §144-147 "可选:接入 OpenAI Codex" 段加 banner → 下游知道 codex 接入选项**当前搁置**(不主动实施)
   - **现状缺口**:harness/README.md(M4 分发模板)直接提"swap codex 角色"作为"可选接入",下游误以为是 active feature
   - **P1 而非 P0 的原因**:本 batch 是 harness 自仓库改动,真实下游分发验证属 P1 真实项目阶段(§6.3 测试边界明确);C3 落地依赖 setup.sh 行为(Critical 9 验证后,setup.sh **不复制** harness/README.md,故 #11 改动对下游用户**无直接可见路径**,需通过 GitHub 仓库浏览访问 — 不阻塞本 batch 但缺验收手段);C1/C2 仍为 P0(harness 自仓库内 Claude / 用户 / 挑战者读 harness/README.md 即可识别搁置状态)

### 1.3 边界与约束

> **数字口径**(全 spec 统一,2026-05-25 修订澄清):
> - "**11 处**" = **11 改动 #** = **11 处文件改动条目**(见下方列表,改动 #1 ~ #11)
> - 改动 #1(model-route.md)虽含 2 段 banner,仍算 **1 改动 #**(位置 1 + 位置 2 同文件、同决策)
> - **改动 #** ≠ "banner 字面 grep 命中数"(后者按 banner 字面落地数计,详 §6.1 验证 1 计数表 = 15 次)
> - **改动 #** ≠ "commit 文件数"(后者按 commit 含的文件名数计,3 commits = 5 / 2 / 4 = 11 文件,详 §8.4)

> **风格命名约定**(全 spec 统一,2026-05-25 修订澄清 — Critical 2):
> - "**D 风格**" = **D1 选项 D**(banner 不写启动条件,只标搁置)— D1 选 D
> - "**B 风格**" = **D2 选项 B / D6 选项 B**(段头加 banner + 正文保留,不删不改写)— D2 + D6 同选项字母,共享同一 B 风格语义("段头 banner 承认搁置 + 正文保留历史")
> - "**A 风格**" / "**C 风格**" 同理 = D2 / D6 选项 A / 选项 C(disallowed)
> - "**C 风格 commit 拆分**" = **D3 选项 C**(3 commits 按文件类型分)— D3 选 C(注:此 "C 风格" 与 D2/D6 选项 C 不同语境,通过决策号 D3 区分)

**做什么(11 改动 # — 11 处文件改动条目)**:

A 类(scope=meta,5 文件 governance — Commit 1):
1. `harness/docs/governance/model-route.md` — 文件头加 banner + "何时读"加搁置标注
2. `harness/docs/governance/synthesis-rules.md` P2 阶段约束段 — 段头加 banner + 加 conditional 措辞句"若未来重启 codex 接入..."
3. `harness/docs/governance/planning-rules.md` 顶部 — "swap codex 场景"行加"(当前搁置)"
4. `harness/docs/governance/implementation-rules.md` 顶部 — 同 #3
5. `harness/docs/governance/testing-rules.md` 顶部 — 同 #3

B 类(scope=none 跟随 meta,2 处 — Commit 2):
6. `harness/docs/ROADMAP.md` — 新增"已识别但搁置:codex 接入(model-route.md)"段
7. `harness/docs/references/2026-05-22-p0-9-4-self-check.md` §C / §G3 / §G4 / §F2 — 段头加 `[2026-05-24] codex 接入搁置` banner(§8.2 变体 2 self-check 段头版),段内容不动

C 类(scope=none 跟随 meta,4 处 — Commit 3):
8. `harness/docs/decision-trail.md` — append 2026-05-24 拐点
9. `harness/docs/active/handoff.md` — 状态行同步
10. `README.md`(harness 根)§57-75 "可选:接入 OpenAI Codex" — 段头加 `[2026-05-24] codex 接入搁置` banner(§8.2 主模板),内容保留
11. `harness/README.md`(M4 分发模板)§144-147 "可选:接入 OpenAI Codex(多模型成本路由)" — 同 #10

**不做什么**:
- 不删 `model-route.md` / `synthesis-rules.md` P2 阶段约束段 / 3 governance rules 引用(保留作日后基线)
- 不改 `docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11(历史决策不重写,经 decision-trail append 拐点 supersede)
- 不改 `docs/references/recommended-tools.md`(工具推荐与接入决策无关)
- 不改 `CLAUDE.md`(harness 根 M3)/ `harness/CLAUDE.md`(M4 分发模板)— 本身不提 codex
- 不改 `harness/.claude/{agents,skills,hooks}/`(本来就没 codex 调用)
- 不预设**重启时间 / 启动条件 / 触发信号**(`feedback_iterative_progression` 硬约束)
- 不回滚今天的 plugin-cc patch(已确认保留为现存备主)
- **不**改写 self-check §F2 正文为"swap codex 是潜在方案,但 P2 codex 接入已搁置 — 当前承认 gap"风格(= D2 选项 A 风格 — disallowed:删除/改写正文)。用户选 D2 选项 B,§F2 原句不动,**只加段头 banner 承认搁置**(= B 风格 — allowed:正文保留 + 段头标搁置,亦属"承认 gap"语义但不假装填补)
- **clarification**(Critical 4 修复 2026-05-25):"承认 gap" 一词在本 spec 有两种用法 — **A 风格"承认 gap"**(改写正文假装填补,disallowed)/ **B 风格"承认 gap"**(段头加 banner 标搁置 + 正文保留历史,allowed,§8.1 改动 #7 用此风格);本条不做清单禁止的是 A 风格内容改写,**不是** B 风格段头加 banner

**性能要求**:无(纯文档改动)

**安全要求**:无(无凭证 / 无执行变更)

**兼容性要求**:
- 下游已装项目不自动更新(本 batch 不改下游分发会触达的文件 — 2026-05-25 Critical 9 verified:setup.sh **不复制** harness/README.md;harness/CLAUDE.md M4 模板本 batch **不改动**,下游已装 CLAUDE.md 因此不受影响)
- M3 路径前缀同步约束(CLAUDE.md §3 §5)— 本 batch 不改 CLAUDE.md,不触发同步

### 1.4 关联需求

**依赖的已有功能**:
- `feedback_iterative_progression.md`(2026-04-28 用户原则确立)— banner 措辞 D 风格(只搁置不预设时间)的硬依据
- `feedback_spec_gap_masking.md`(2026-04-17 用户原则)— 承认 gap 不掩盖,但 §F2 选 B 是"内容不动+banner"形式承认
- `feedback_choice_visualization.md`(2026-04-26 用户原则)— 本 spec 决策展示 A/B/C/D 对比格式遵守
- `feedback_judgment_basis.md`(2026-04-15 用户原则)— 本 spec 论据全部基于本会话事实验证(Test 1/2/3 + grep 数据),无"市场判断"
- harness 自治理流程:M1 finishing(`meta-finishing-rules.md`)+ M2 review(`meta-review-rules.md`)

**被哪些未来功能依赖**:
- 未来 codex 接入重启时 → 重新走完整 brainstorming + design,**不从本 spec 草拟启动条件**(D 风格)
- self-check §C 若 codex 接入重启 + 落地 → 解除 banner 激活检查项(避用"时/后"时序触发措辞,对齐 Critical 3 修订禁用词约束)

### 1.5 已确认的决策(从 brainstorming 阶段带入)

| # | 决策 | 用户选择 | 时间 |
|---|---|---|---|
| D1 | banner / decision-trail 启动条件措辞 | D 风格:不写启动条件,只标搁置(对齐 iterative_progression) | 2026-05-24 |
| D2 | self-check §F2 "唯一解药 swap codex" 措辞调整 | B:留原句不动 + 段头加 banner | 2026-05-24 |
| D3 | commit 粒度 + meta-review N | C:按文件类型 3 commits(A 类/B 类/C 类各 1 commit)+ N=4 标准 meta-review | 2026-05-24 |
| D4 | 流程深度 | 完整 — brainstorming + design + design-review + M1 + M2(harness meta path 默认只 M1+M2 之上加严) | 2026-05-24 |
| D5 | 11 处清单完整性 | OK,可启动 | 2026-05-24 |
| D6 | README codex 段处理 | 加 banner,内容保留(下游可读到搁置状态) | 2026-05-24 |
| D7 | 今天 plugin-cc patch 去留 | 保留(背景,不影响本 batch) | 2026-05-24 |

### 1.6 RUBRIC 风险标记

> **澄清**(2026-05-25 Critical 11 修订):本节**描述性引用 RUBRIC 术语**(简洁性 / 一致性 / 功能完整性 / 不引入新流程 / C 风格 commit 拆分)用于描述 risk 和 应对方式;**不作 design-review 豁免依据**(M2 / M4 约束;§0 已声明 — 显式区分:allowed "描述性引用 RUBRIC 描述 risk" vs disallowed "用 RUBRIC 维度豁免审查")。本 spec 5 维 RUBRIC 风险全部走描述性引用,无任何一处用作豁免依据。

- 涉及的"产出健康性"维度:
  - **简洁性**:11 处改动是同一决策(搁置 codex)的散布同步 — spec §8 须明确"为什么 11 处而不是 1 处" + meta-review 挑战者 #4 scope 漂移(子焦点 RUBRIC 简洁性)必查"是否过度工程"
  - **一致性**(2026-05-25 Critical 12 修订):11 处 banner **核心字段**(日期 `[2026-05-24]` + "codex 接入搁置" 短语 + spec 路径)**完全统一**;**长度变体**(主模板 + 变体 1 段内嵌入版 + 变体 2 self-check 段头版 + 变体 3 handoff 行版 + 变体 4 ROADMAP 段头版,共 1 主 + 4 变体 — 详 §8.2)按场景适配 — 主+4 变体在核心字段层面统一,在表达密度层面差异化(blockquote vs 内嵌、含/不含 decision-trail 拐点路径);不一致会被 meta-review 挑战者 #1 核心原则合规(子焦点 D1 D 风格措辞一致性 — 验证**核心字段**完全统一)打 needs-revision,**变体长度差异不视为不一致**
  - **功能完整性**:meta 改动无 feature 验收,以 meta-review verdict=pass / pass-after-revision 为通过
- 涉及的"治理机制"维度:
  - 不引入新流程(沿用现有 M1 + M2 meta path)
  - **C 风格 commit 拆分** = 3 commits(A 类 governance / B 类 ROADMAP+self-check / C 类 decision-trail+handoff+README)— 顺序约束(Commit 2/3 引用 Commit 1 的 banner 措辞,顺序错会 cross-ref 悬空)

**自检**:
- [x] 每个核心场景都有完整的"谁→做什么→系统做什么→看到什么"?(C1/C2 P0 完整;C3 P1 — Critical 8 修订)
- [x] "不做什么"列了用户可能误以为在范围内的事?(不删 model-route / 不改 ECC §11 / 不预设启动条件 / §F2 选 B 不改写正文为 A 风格 — Critical 4 clarification 已澄清"承认 gap"双线语义)
- [x] 和 brainstorming 阶段的需求确认清单对得上?(D1-D7 全部带入,§1.3 范围与上轮一致)
- [x] 优先级排序反映用户确认优先级?(C1/C2 标 P0 harness 自仓库内可即时验证;C3 标 P1 下游分发感知 — 真实下游分发验证属 P1 真实项目阶段;详 §6.3 测试边界 + Critical 8/9 修订)

---

## 2. 模块划分

**不适用 — meta scope 措辞调整**。

本 batch 是 11 处文档措辞改动(banner / 状态标注 / decision-trail append),无代码模块概念,无新建/改动模块。`ARCHITECTURE.md` 的分层规则(UI / Service / Repository / Types)对纯文档治理改动不适用。

- §2.1 模块清单:不适用
- §2.2 模块依赖图:不适用

**与 §8 的关系**:模块视角不适用,但**文件视角**完整;详见 §8.1 11 处文件改动表 + §8.4 commit 拆分明细。

**自检**:
- [x] 已明确标注"不适用"理由(meta scope 措辞调整,非模块工程)
- [x] 已声明此判断依据(ARCHITECTURE.md 分层规则对文档治理改动不适用)
- [x] 已指出替代视角(§8 文件级视角)
- [x] "不适用"理由与 §0 偏离说明一致

---

## 3. 接口定义

**不适用 — meta scope 措辞调整**。

本 batch 无模块间接口、无外部 API、无前后端类型契约。涉及的"读者"是 Claude / 用户 / 挑战者后续读文档,而非函数调用方;banner 措辞是给"读者认知"的提示,不是给"调用方"的接口。

- §3.1 模块间接口:不适用
- §3.2 外部接口:不适用
- §3.3 前后端类型契约:不适用

**替代视角 — "文档间互引"**(详 §5.2 cross-ref 悬空场景 + §8.6 文档互引影响):
- model-route.md banner(Commit 1)→ 被 planning/implementation/testing-rules.md(同 Commit 1)、self-check §C(Commit 2)、decision-trail(Commit 3)、handoff(Commit 3)、2 README(Commit 3)引用
- decision-trail 2026-05-24 拐点(Commit 3)→ 引用 spec 自身路径 + Commit 1 改的 model-route.md banner

**自检**:
- [x] 已明确标注"不适用"理由(meta scope 无接口契约概念)
- [x] 已指出替代视角(文档互引,在 §5.2 / §8.6 详述)
- [x] "不适用"理由与 §0 偏离说明一致

---

## 4. 数据模型

**不适用 — meta scope 措辞调整**。

本 batch 无数据实体、无数据流、无状态机。涉及的"数据"是 markdown 文本字符串(banner 模板字符串),不进入运行时类型系统,不需要校验规则,不需要数据库映射。

- §4.1 数据实体:不适用
- §4.2 数据流:不适用
- §4.3 状态变更:不适用

**替代视角 — "状态标注的语义"**:
- 改动前状态:文档无搁置标注 → 后续读者无法识别 codex 接入是 "规划/已实施/搁置" 的哪一种
- 改动后状态:文档头部带 `[2026-05-24] codex 接入搁置` banner → 后续读者一眼识别为"搁置"
- 这不是"实体状态机",是"读者认知状态" — 故不归 §4 数据模型

**自检**:
- [x] 已明确标注"不适用"理由(meta scope 无数据建模需求)
- [x] 已指出替代视角("读者认知状态"非"实体状态")
- [x] "不适用"理由与 §0 偏离说明一致

---

## 5. 边界条件与错误处理

> meta scope 适配 — 改为"措辞冲突场景 + 跨文件互引悬空处理"。

### 5.1 场景 5.1 — 11 处 banner 措辞不统一

**输入条件**:Commit 1 用 banner 字面 A(例:日期写 `[2026-05-24]`、风格用 "接入搁置"),Commit 2 用 banner 字面 B(例:日期写 `[2026-05-23]` 或风格用 "决策推迟")。

**预期行为**:meta-review 挑战者 #1 核心原则合规(子焦点 D1 D 风格措辞一致性,见 §6.2)grep "搁置" 在 11 文件应有 N 次命中且**字面统一**,任一处偏离打 verdict=needs-revision。

**预防(优先)**:
- §8.2 定义**唯一 banner 模板字符串**(日期 + 风格 + 字段顺序固定),11 处全部复制粘贴,**不允许 paraphrase**
- §8.4 commit 拆分明细列出每个 commit 用的是同一字符串(从 §8.2 取),implementer 不自行改写

**检测**(meta-review 阶段):
- 挑战者 #1(核心原则合规,子焦点措辞一致性)跑 `grep -F "[2026-05-24] codex 接入搁置" docs/` 计数
- 应得固定计数(详 §6.1 验证 1 计数表 — 单一形态 A 类 6 + B 类 5 + C 类 4 = 15 次完全字面命中;2026-05-25 Critical 1 修订收敛自原"6/5/4 或 6/5/5"双形态)— 偏离视为不统一

**修复**:
- 任一处不统一 → 调度者按 §8.2 模板字符串覆盖该处 → 重跑 meta-review

### 5.2 场景 5.2 — Commit 1 改 model-route.md 后 Commit 2/3 引用悬空

**输入条件**:Commit 1 改了 model-route.md 文件头 banner 措辞,但 Commit 2(self-check §C 引用 model-route §4 swap 11 角色)或 Commit 3(decision-trail 2026-05-24 拐点引用 model-route 路径)在 Commit 1 之前 push 或顺序颠倒。

**预期行为**:
- 顺序约束(详 §8.5):**Commit 1 必须先于 Commit 2 / 3**,Commit 2/3 可参考 Commit 1 已落定的 banner 措辞
- 若调度者在分支上颠倒 commit 顺序 → meta-review 挑战者 #3(副作用,子焦点 cross-ref 完整)发现引用悬空打 verdict=needs-revision

**预防(优先)**:
- §8.5 明确顺序约束,implementer 按顺序执行(Commit 1 → Commit 2 → Commit 3)
- 单 push 一次性 push 三个 commit(顺序在 commit graph 上锁定)

**检测**(meta-review 阶段):
- 挑战者 #3(副作用,子焦点 cross-ref 完整)验证:打开 self-check §C banner / decision-trail 2026-05-24 拐点 / handoff 状态行,每个引用的 model-route.md 文件头 banner 是否字面存在且一致
- 若 Commit 2 自检产物提及 banner 字面 X,但 Commit 1 后 model-route.md 实际 banner 是 Y → 悬空

**修复**:
- 调度者读取 Commit 1 已 push 的 banner 字面,用 §8.2 模板覆盖所有 Commit 2/3 引用处

### 5.3 场景 5.3 — 用户读到 banner 误以为有"启动条件"

**输入条件**:banner 措辞写"待 X 触发"/"下个版本启动"/"等 codex CLI 升级"等隐含启动条件(违反 D1 决策 = `feedback_iterative_progression`)。

**预期行为**:
- D1 决策为 D 风格(只标搁置,不写启动条件,不预设触发信号)
- meta-review 挑战者 #4(scope 漂移,子焦点启动条件泄漏 + RUBRIC 简洁性)发现"启动条件"措辞泄漏 → needs-revision

**预防(优先)**:
- §8.2 banner 模板**只含 5 个字段**:日期、"codex 接入搁置"短语、"fork 子任务维持全 Claude"现状陈述、"日后基线"+"不预设重启时间"+"`iterative_progression`"原则引用、spec + decision-trail 路径互引
- **禁用词列表**:"等待"、"下个版本"、"待 X 触发"、"启动条件"、"何时重启"、"v Next"、"X 时启用"、"X 完成后"(后两个为 2026-05-25 Critical 3 修订增加 — 时序触发型措辞)— implementer 在 §8.1 11 文件改动中 grep 自查;banner 字面用"若 X 则激活"(非时序)替代

**检测**(meta-review 阶段):
- 挑战者 #4(scope 漂移,子焦点启动条件泄漏)跑 `grep -E "等待|下个版本|待.*触发|启动条件|何时重启|v ?Next|until.*ready|.*时启用|.*完成后" docs/` 命中即违反(2026-05-25 Critical 3 修订:增加 "X 时启用 / X 完成后" pattern 与 §6.1 验证 2 / §6.2 挑战者 #4 同步)
- 同时挑战者 #4 验证 §8.2 模板字符串中"不预设重启时间(iterative_progression)"字面存在

**修复**:
- 任一处命中禁用词 → implementer 用 §8.2 模板覆盖该处文本 → 重跑 meta-review

### 5.4 错误处理总表

| 场景 | 预防 | 检测 | 修复 |
|---|---|---|---|
| 5.1 措辞不统一 | §8.2 唯一模板字符串 + §8.4 commit 拆分明细 | 挑战者 #1 核心原则合规(子焦点措辞一致性)grep 计数 | 按 §8.2 模板覆盖 → 重审 |
| 5.2 cross-ref 悬空 | §8.5 顺序约束 + 单 push | 挑战者 #3 副作用(子焦点 cross-ref 完整)引用字面比对 | 按 Commit 1 实际 banner 覆盖 Commit 2/3 引用 |
| 5.3 启动条件泄漏 | §8.2 模板禁用词列表 + implementer grep 自查 | 挑战者 #4 scope 漂移(子焦点启动条件泄漏)grep 禁用词 | 用 §8.2 模板覆盖 → 重审 |

**自检**:
- [x] 三个核心场景全部覆盖"输入 / 预期 / 预防 / 检测 / 修复"五要素
- [x] 错误处理路径不吞错(每个场景都给具体的 grep / 比对 / 重审动作,不是"看着办")
- [x] 每个场景关联到 §1.2 核心场景(5.1 ↔ C2 重启定位;5.2 ↔ C1 后续读者识别;5.3 ↔ C1 + iterative_progression 硬约束)
- [x] 与 §0 偏离说明声明的"措辞冲突 + cross-ref 悬空"主题一致

---

## 6. 测试策略

> meta scope 适配 — 改为"措辞一致性验证 + meta-review 4 挑战者维度"。

### 6.1 措辞一致性验证(meta-L1 节内自检 + meta-L2 全局自检)

**验证 1 — grep 命中数**:

```bash
# 在 harness 仓库根跑
grep -rF "[2026-05-24] codex 接入搁置" \
  harness/docs/governance/ \
  harness/docs/ROADMAP.md \
  harness/docs/references/2026-05-22-p0-9-4-self-check.md \
  harness/docs/decision-trail.md \
  harness/docs/active/handoff.md \
  README.md \
  harness/README.md
```

**预期命中数**(banner 字面 grep -F 命中数 — 注:口径 ≠ "改动 #",一个改动 # 内可出现多次完整字面):

| 改动 # | 文件 | 完整字面命中数 |
|---|---|---|
| #1 | model-route.md | **2**(文件头 banner 1 + "何时读"段尾 banner 1 — 两段都含完整字面) |
| #2 | synthesis-rules.md P2 段 | **1**(段头 banner;段内"若未来重启"语境句不含完整 banner 字面) |
| #3 | planning-rules.md 顶部 | **1**(变体 1 段内嵌入版) |
| #4 | implementation-rules.md 顶部 | **1**(同 #3) |
| #5 | testing-rules.md 顶部 | **1**(同 #3) |
| #6 | ROADMAP "已识别但搁置"段 | **1**(段头 banner 行 1 处;下方列表项 6 行不含完整 banner 字面,计 0 处 — N #11 修订) |
| #7 | self-check §C/§G3/§G4/§F2 段头 | **4**(每段段头 1 个 banner = 4 段 × 1) |
| #8 | decision-trail 2026-05-24 拐点 | **1**("影响"行含完整字面 `[2026-05-24] codex 接入搁置 banner`;段头 markdown 标题"## 2026-05-24 — codex 接入搁置"无方括号 + 无后置短语不计入) |
| #9 | handoff 状态行 | **1**(变体 3) |
| #10 | README.md(harness 根)§57-75 | **1** |
| #11 | harness/README.md(M4 模板)§144-147 | **1** |

**总计预期**:**15 次完全字面命中**(2+1+1+1+1+1+4+1+1+1+1 = 15)— A 类小计 6 / B 类小计 5 / C 类小计 4。

> 计数口径(单一形态,无浮动 — 修订自原"6/5/4 或 6/5/5"双形态):`grep -F "[2026-05-24] codex 接入搁置"` 字面计每次出现含**半角方括号** `[2026-05-24]` 的完整 banner 字面。implementer 实施时按本表精确落地;改动 #8 decision-trail "抉择/替代/触发"行**不加**完整 banner 字面,完整字面仅在"影响"行一次出现。挑战者 #1 跑 grep 后对照本表计数表,任一改动 # 偏离即 verdict=needs-revision。

**验证 2 — 禁用词清单 grep**:

```bash
grep -rE "等待|下个版本|待.*触发|启动条件|何时重启|v ?Next|until.*ready|.*时启用|.*完成后|启用 codex|日后启用" \
  harness/docs/governance/model-route.md \
  harness/docs/governance/synthesis-rules.md \
  harness/docs/governance/planning-rules.md \
  harness/docs/governance/implementation-rules.md \
  harness/docs/governance/testing-rules.md \
  harness/docs/ROADMAP.md \
  harness/docs/references/2026-05-22-p0-9-4-self-check.md \
  harness/docs/decision-trail.md \
  harness/docs/active/handoff.md \
  README.md \
  harness/README.md
```

**预期**:**11 文件 banner 范围内 0 命中**(在 banner 之外允许保留历史规划上下文,但 banner 内本身严禁出现启动条件词汇)。

> 注:本测试只针对 banner 本身 — model-route §3 / synthesis-rules P2 阶段约束段 / self-check §G3/§G4 正文等保留作日后基线,grep 整文件可能命中正文历史语境;实操上挑战者 #4(scope 漂移,子焦点启动条件泄漏)应 Read 每个 banner 块字面比对,而非 grep 整文件 verdict。`.*时启用 / .*完成后` regex 仅匹配 "X 时启用 / X 完成后" 时序触发型措辞(Critical 3 修复后,banner 字面用"若...激活"非时序);若挑战者 grep 整文件命中正文历史语境(如 §G4 正文 "0.108 时启用"),挑战者需 Read 上下文判断是 banner 还是正文。

### 6.2 meta-review 4 挑战者维度(D3 决定 N=4)

按 `meta-review-rules.md` §6 对抗式 agent prompt 模板 B 段 — **bootstrap 4 维基线**(任何 meta 改动必须包含:核心原则合规 / 目的达成度 / 副作用 / scope 漂移)。本 batch 不禁用任一基线维度;原 4 焦点(措辞一致性 / 完整性 / cross-ref 完整 / RUBRIC 对齐)作为各维度子焦点纳入。

**挑战者 #1 — 核心原则合规**(bootstrap 维度;子焦点:措辞一致性 + 各 feedback memory + 二公设):
- 输入:11 处文件改动 diff(全部 3 commits 合并 view)+ `feedback_iterative_progression.md` / `feedback_spec_gap_masking.md` / `feedback_choice_visualization.md` / `feedback_judgment_basis.md` + CLAUDE.md §1 二公设
- 焦点:
  - **D1 D 风格措辞一致性**(Critical 12 修订):§8.2 banner **核心字段**(日期 `[2026-05-24]` + "codex 接入搁置" 短语 + spec 路径)在 11 处 1:1 复制粘贴出现(完全字面相同 — 半角括号、引用路径);**长度变体**(主+4 变体)按场景适配 — 主模板用于 model-route 文件头 / 2 README / decision-trail / handoff;变体 1 用于 governance rules 顶部嵌入;变体 2 用于 self-check 段头;变体 4 用于 ROADMAP 段头(详 §8.2)— 变体长度差异不视为不一致
  - **`feedback_iterative_progression` 对齐**:11 处 banner / 决策记录 / spec 自身有无"启动条件 / 重启时间 / 触发信号"预设(违反 D1 硬约束 = 违反核心原则)
  - **`feedback_spec_gap_masking` 对齐**:§F2 / 2 README 是否以"段头 banner + 正文不动"形式承认 gap,而非删除 / 改写(B 风格)
  - **公设 1+2 对齐**:本 batch 走完整 brainstorming + design + design-review + M1 + M2(D4 决策落地),不让同一 agent 做与审同窗口
- 通过判据:`grep -F "[2026-05-24] codex 接入搁置"` 在 11 文件计数 = §6.1 验证 1 预期值;`feedback_*` + 公设 1+2 全部对齐;禁用词清单(§5.3 / §6.1 验证 2)0 命中
- 失败信号:任一处偏离字面;banner / spec 出现启动条件预设;§F2 原句被改写或删除;违反公设 1+2

**挑战者 #2 — 目的达成度**(bootstrap 维度;子焦点:11 处清单完整 + 搁置目的真达成):
- 输入:harness 全仓 + harness 自身仓库内 grep `codex` 全部命中 + §1.1 用户目标 + §1.2 三个核心场景 C1/C2/C3
- 焦点:
  - **11 处清单完整**:11 处是否覆盖所有 codex 引用?哪些"剩余命中"是历史 audit / decision / ECC 等不动?(D5 验证)
  - **搁置目的真达成**:C1(后续读者识别)/ C2(重启时定位)/ C3(下游分发感知)三个核心场景是否在 11 处改动中真落地?剩余命中是否归类合理?
- 通过判据:`grep -rln "codex" harness/docs/ README.md harness/README.md` 输出与 §8.1 11 处清单对比;剩余命中应全部归类到"历史 audit / decision-trail 旧条 / ECC §11 / recommended-tools / harness CLAUDE 文档不提"等不动类;C1/C2/C3 在 §9.1 已勾选且 §8 改动中可验证落地
- 失败信号:存在 codex 引用既不在 11 处清单也不在"不动归类"内;C1/C2/C3 任一未在 11 处改动中体现

**挑战者 #3 — 副作用**(bootstrap 维度;子焦点:cross-ref 完整 + ECC §11 不重写 + 下游分发副作用 + 历史 audit / decision 未污染):
- 输入:Commit 1 已 push 后的 model-route.md banner 实际字面 + Commit 2/3 引用 model-route 的位置 + `docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11 + harness/setup.sh + 已装下游项目兼容性
- 焦点:
  - **cross-ref 完整**:model-route.md ↔ synthesis-rules P2 段 ↔ planning/implementation/testing-rules ↔ self-check §C/§G3/§G4/§F2 ↔ decision-trail 2026-05-24 拐点 ↔ handoff ↔ 2 README — 互引在改 banner 后是否仍自洽(路径有效 + 引用语义一致)
  - **ECC §11 不重写副作用**:`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11 P2 实施路径未被本 batch 改动,改由 decision-trail 2026-05-24 拐点 supersede(§8.6);验证 ECC §11 字面无任何改动
  - **下游分发副作用**:`harness/README.md`(M4 模板)改动 #11 进入下次 setup;已装下游不自动更新 — 验证无破坏性变更
  - **历史 audit / decision-trail 旧条未污染**:本 batch 不改 docs/audits/* / docs/decisions/* 既有内容(仅 append decision-trail 2026-05-24 拐点)
- 通过判据:每个引用**按各自视角验证目标路径有效**(改动 #10 harness 仓库根 README.md 引用 `harness/docs/...`,在仓库根视角能打开;改动 #11 M4 模板 harness/README.md 引用 `docs/...`,在下游 setup 后单层结构视角能打开 — 详 §8.6 路径前缀差异显式说明)+ 语义与本 spec §1 + §8 一致;ECC §11 字面无改动;harness/README.md 改动只 propagate 到新 setup;docs/audits/* 和 docs/decisions/* 历史条目字面无改动
- 失败信号:任一互引指向旧 banner 字面 / 错路径 / 段落已重命名;ECC §11 被偷偷重写;harness/README.md 改动破坏旧 setup 兼容性;历史 audit / decision 被改

**挑战者 #4 — scope 漂移**(bootstrap 维度;子焦点 4 项:11 处是否扩散 + RUBRIC 简洁性 + 启动条件泄漏 grep + D1-D7 决策都在 §8/§7 体现):
- 输入:11 处文件改动 + §1.3 边界与约束(做什么 + 不做什么)+ §1.6 RUBRIC 风险标记 + spec §7 决策 D1-D7
- 焦点:
  - **11 处是否扩散到不该改的文件**:对照 §1.3 不做清单 8 条(不删 model-route / 不改 ECC §11 / 不改 recommended-tools / 不改 CLAUDE.md / 不改 .claude/{agents,skills,hooks}/ / 不预设重启时间 / 不回滚 plugin-cc / 不改写 §F2 正文为 A 风格"承认 gap" — 详 Critical 4 修订澄清),验证 §8 改动无"顺手扩散"
  - **RUBRIC 简洁性(11 vs 1 处)**:11 处是否过度工程(挑战:为什么不能只改 1 处)?— spec §8.1 + §1.6 应明确给出"11 处是同一决策的散布同步"理由,挑战者验证可信度
  - **启动条件泄漏**(§5.3 验证):`grep -E "等待|下个版本|待.*触发|启动条件|何时重启|v ?Next|until.*ready|.*时启用|.*完成后|启用 codex|日后启用"` 命中即 scope 漂移(D1 决策 D 风格的反向裂缝;2026-05-25 Critical 3 修订增加"X 时启用 / X 完成后"两个 pattern 与 §6.1 验证 2 同步;2026-05-25 verify 后置修订追加"启用 codex / 日后启用"避免 banner 字面"日后启用"漏检)
  - **D1-D7 决策都在 §8 体现**(无范围扩散反模式 designer.md 自查 #5):每个决策都能在 §8 找到落地位置或 §7 D7 明确"不在 §8"理由
- 通过判据:§1.3 不做清单 8 条全部未被偷做;§8.1 + §1.6 给出"11 处散布同步"可信理由;启动条件禁用词 0 命中;D1-D7 全部在 §8 / §7 体现
- 失败信号:任一不做清单条目被偷做;简洁性受质疑且 §8.1 + §1.6 未给出可信理由;启动条件禁用词命中;决策 D1-D7 任一未在 §8 / §7 体现

> 维度选择记录(对应 `meta-review-rules.md` §6 B 段 C 段):
> - **启用的推荐维度**:无(本 batch 不启用 A 段推荐维度,如 evidence-depth 适配 / 模态自洽等)
> - **禁用的 minimum 维度 + 理由**:无(bootstrap 4 维全部启用)
> - **新增的定制维度 + 理由**:无(原 4 焦点措辞一致性 / 完整性 / cross-ref 完整 / RUBRIC 对齐已作为 bootstrap 4 维子焦点纳入,不另增第 5 维"过度工程化" — 对齐 D3 决策"标准 meta-review N=4 bootstrap 4 维基线,不缩不扩")

### 6.3 测试边界

**不测什么**:
- 不测**实际 commit hook 通过性**(属 M1 finishing Step B 验收;hook 是 check-meta-review / check-meta-commit / check-meta-cross-ref / check-meta-cross-ref-commit — 它们在 finishing 阶段自然跑,本 spec 不验证 hook 自身正确性)
- 不测**下游分发兼容性**(C3 已 P1 — Critical 8 修订;setup.sh 已 verified 不复制 harness/README.md — Critical 9 修订;改动 #11 对下游用户走 GitHub 浏览路径,无 P0 级验收手段;本 spec 不验证下游 setup 后表现 — 属 P1 真实项目阶段)
- 不测**codex CLI 自身行为**(2026-05-22 self-check §C4 已记录 codex CLI 0.106.0 / 0.133.0 gpt-5.5 不支持等;本 batch 是搁置决策的文档化,不验证 codex 实际可用性)
- 不测**未来重启时的流程**(D1 不预设重启时间,故未来流程不在本 spec 范围)

**外部依赖 mock 策略**:无外部依赖(纯 markdown 改动),无 mock 需求。

**自检**:
- [x] §1.2 三个核心场景都映射到测试:C1 ↔ 挑战者 #1 核心原则合规 / C2 ↔ 挑战者 #2 目的达成度 / C3 ↔ 挑战者 #1 + #4(scope 漂移子焦点 — 下游分发感知)
- [x] §5 三个边界场景都映射到测试:5.1 ↔ 挑战者 #1(措辞一致性子焦点)/ 5.2 ↔ 挑战者 #3(cross-ref 完整子焦点)/ 5.3 ↔ 挑战者 #4(启动条件泄漏子焦点)
- [x] 测试层级合理(meta scope 无单元/集成/E2E 概念,改用 meta-L1 节内自检 / meta-L2 全局自检 / meta-L3 4 挑战者对抗审查;meta-L4 留 P1 真实项目阶段)
- [x] 已声明"不测什么"(hook / 下游分发 / codex CLI 自身)
- [x] 与 §0 偏离说明声明的"措辞一致性验证 + 4 挑战者"主题一致

---

## 7. 设计决策记录

> 展开 §1.5 表格 D1-D7,每个含"选项 / 选择 / 原因"。

### D1 banner / decision-trail 启动条件措辞 — 选 D

| 选项 | 内容 |
|---|---|
| A | banner 写"待 codex CLI 升级 + gpt-5.5 解锁后启动" |
| B | banner 写"等待用户决定重启,无具体时间" |
| C | banner 写"日后启动,触发信号为 X" |
| **D**(选) | banner 只标搁置(`[2026-05-24] codex 接入搁置 — fork 子任务维持全 Claude`),**不写启动条件** |

**原因**:
- A/B/C 都隐含或显式预设"启动条件",违反 `feedback_iterative_progression`(2026-04-28 用户原则:不预设固化未来阶段;ROADMAP / decision-trail / handoff 已多次清理"P1 真实项目迁移"等预设)
- D 风格与 ROADMAP 自身的"边做边提升"哲学一致(`ROADMAP.md` 顶部 + `feedback_iterative_progression.md`)
- 决策影响:§5.3 + §6.1 验证 2 (禁用词清单)硬约束;§8.2 banner 模板严守 D 风格

### D2 self-check §F2 措辞调整 — 选 B

| 选项 | 内容 |
|---|---|
| A | 删 §F2 原句("swap 挑战者到不同模型(P2 codex 接入正是为此)") |
| **B**(选) | 留 §F2 原句不动 + 段头加 `[2026-05-24] codex 接入搁置` banner(§8.2 变体 2)|
| C | 改写 §F2 原句为"swap 挑战者是潜在方案,但 P2 codex 接入已搁置 — 当前承认 gap" |

**原因**:
- A 删除会丢失"P2 codex 接入正是为此"的设计意图记录(后续重启时需要这段历史推导)
- C 重写会"内容动" — 违反用户在 brainstorming 阶段对 §F2 的明确指令("留原句不动")
- B 是 `feedback_spec_gap_masking` 框架内"承认 gap 不掩盖"的合理形式:**段头 banner 承认 gap(搁置),正文保留历史推导**(内容不动)— 不假装填充新方案,也不删除历史
- 决策影响:§8.1 第 #7 行 self-check §F2 改动只加段头 banner,不动正文 [`F2. 独立 fork 是否真发现主对话漏的问题?` 节内任何字面]

### D3 commit 粒度 + meta-review N — 选 C(3 commits + N=4)

| 选项 | 内容 |
|---|---|
| A | 1 个 batch commit(11 处全部一起)+ N=4 |
| B | 11 个独立 commit(每文件一个)+ N=4 |
| **C**(选) | 3 commits 按文件类型分(A 类 governance / B 类 ROADMAP+self-check / C 类 decision-trail+handoff+README)+ N=4 标准 meta-review |
| D | 3 commits + N=2 缩减挑战者 |

**原因**:
- A 单 commit 牺牲回滚精度:若 banner 字面有问题需 revert 时无法只 revert 5 governance 或 4 引用
- B 11 commits 过度细碎:每个 banner 改动太小,push 后 commit graph 噪音大,且增加 PR review 成本
- D 缩 N=2 违反 `meta-review-rules.md` §6 B 段 + §"bootstrap 4 维基线(D7)"硬约束(L244-248 + L280):任何 meta 改动的对抗式审查**必须**包含 bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移),禁用 minimum 维度需用户确认(C 段记录);本 batch 用户 D3 选择"标准 meta-review"未授权禁用,缩 N=2 强制丢弃 2 维 → 违反硬约束;另外本 batch 4 维都实质涉及(D 风格措辞 = 核心原则;搁置目的落地 = 目的达成度;ECC §11 不重写 + 下游分发 = 副作用;不做清单 8 条 = scope 漂移),缩 N 会漏维度
- C 提供**回滚精度**(单类型独立 revert)+ **标准 meta-review 力度**(N=4 1:1 对应 bootstrap 4 维基线,详 §6.2 挑战者 #1-#4)+ **顺序约束清晰**(A → B → C,因果可追)
- 决策影响:§8.4 commit 拆分明细 + §8.5 顺序约束 + §6.2 4 挑战者维度(挑战者 #1 核心原则合规 / #2 目的达成度 / #3 副作用 / #4 scope 漂移)

### D4 流程深度 — 选完整(brainstorming + design + design-review + M1 + M2)

| 选项 | 内容 |
|---|---|
| harness meta path 默认 | M1 + M2(brainstorming + design / design-review 可选,通常 meta 改动跳过) |
| **完整**(选) | brainstorming + design + design-review + M1 + M2(用户主动加严) |

**原因**:
- 用户 2026-05-24 主动选择"完整流程"作为 user instruction
- 加严理由(用户语境):本 batch 是治理改动,跨 5 governance + 2 引用 + decision-trail + handoff + 2 README,影响面广;design + design-review 多一道审查可减少 11 处 banner 措辞不统一 / 启动条件泄漏 / cross-ref 悬空风险
- 决策影响:本 spec 自身存在 = D4 决策落地;design-review 阶段调度者 fork 4 挑战者(详 §6.2)

### D5 11 处清单完整性 — OK,可启动

| 选项 | 内容 |
|---|---|
| 不全 | 11 处遗漏某些 codex 引用,需补充 |
| **OK**(选) | 11 处清单完整,可启动 |

**原因**:
- brainstorming 阶段调度者跑 `grep -rln "codex" harness/docs/ README.md harness/README.md` cross-check,确认 11 处覆盖了所有"现行规划文档 + 自查清单 + 引用入口"
- 剩余 codex 命中分类为"历史 audit / decision-trail 旧条 / ECC §11 / recommended-tools / harness CLAUDE 文档不提"等不动类(详 §6.2 挑战者 #2 目的达成度 — 子焦点 11 处清单完整 — 通过判据)
- 决策影响:§8.1 11 处文件改动表 = 完整清单 + §6.2 挑战者 #2 验证

### D6 README codex 段处理 — 加 banner,内容保留

| 选项 | 内容 |
|---|---|
| A | 删 README §57-75 / §144-147 "可选:接入 OpenAI Codex" 段 |
| **B**(选) | 加段头 banner,**内容保留** |
| C | 改写段内容为"已搁置,日后实现" |

**原因**:
- A 删除会丢失下游对 codex 接入选项的认知,新 setup 下游用户看不到选项(信息丢失)
- C 改写会"内容动" — 违反 §F2 同款 B 风格(`feedback_spec_gap_masking` 框架)
- B 加 banner 保留内容:下游既能看到"当前搁置"明确信号,又能读到详细 swap 决策表(待重启时直接复用);信息不丢失,认知不混淆
- 决策影响:§8.1 第 #10 + #11 行 README 改动 + §1.2 C3 下游分发感知场景落地

### D7 plugin-cc patch 去留 — 保留

| 选项 | 内容 |
|---|---|
| A | 回滚今天的 plugin-cc patch |
| **B**(选) | 保留 plugin-cc patch |

**原因**:
- plugin-cc patch 是为日常 `/codex:consult` 等 plugin 调用准备(独立于 11 swap 角色接入决策)
- 回滚 patch 不影响 codex 搁置决策(本 batch),反而会破坏现有 plugin 调用通路
- 保留 patch 与 codex 接入搁置**正交独立**:plugin-cc 用于一次性 consult / 工具调用;11 swap 角色用于持续 fork 子任务 — 是两个独立维度
- 决策影响:不在 §8 列改动(本 decision 仅说明 plugin-cc patch **不动**)

### 7.1 RUBRIC 应对方式

> 从 §1.6 风险标记展开。本 spec **描述性引用 RUBRIC** 维度(用于描述应对方式 / 锚点挑战者子焦点 / 自洽性映射)— **不作 design-review 豁免依据**(§0 / §1.6 已声明 Critical 11 修订)。本节 5 维应对方式全部走描述性引用。

- **简洁性**应对:§1.6 显式解释"11 处是同一决策的散布同步,不是过度工程";§8.1 11 处文件改动表为"为什么 11 处"提供事实支撑;§6.2 挑战者 #4(scope 漂移,子焦点 RUBRIC 简洁性)验证 spec 给出的可信度
- **一致性**应对:§8.2 唯一 banner 模板字符串 + §6.1 验证 1 grep 命中数 + §6.2 挑战者 #1(核心原则合规,子焦点措辞一致性)字面验证
- **功能完整性**应对:meta 改动无 feature 验收,以 meta-review verdict=pass / pass-after-revision 为通过;§7 D1-D7 决策表 + §6.2 挑战者 #4(scope 漂移,子焦点 D1-D7 决策都在 §8 体现)验证每个决策都在 §8 体现

**自检**:
- [x] D1-D7 每个决策都列出"选项 / 选择 / 原因"(D5 / D7 是单选择型,选项栏简化为二选)
- [x] 每个决策的"原因"基于具体事实/原则/用户指令(无空话)
- [x] 决策与 ARCHITECTURE.md 分层规则无冲突(本 batch 是 meta scope,ARCHITECTURE.md 不适用 — 已在 §2 / §3 / §4 声明)
- [x] 决策与 RUBRIC.md 无冲突(§7.1 RUBRIC 应对方式)
- [x] §1.6 标记的每个 RUBRIC 风险都有应对方式
- [x] D1 D 风格 + D2 B 风格 + D6 B 风格在 §8 改动中体现(§8.2 模板 + §8.1 第 #7 + #10 + #11 行)

---

## 8. 与既有系统的影响

> 本 batch 核心节。列 11 处文件改动 diff 预览 + banner 模板 + commit 拆分 + 顺序约束 + 影响面。

### 8.1 11 改动 # 文件改动 diff 预览

> 数字口径(承 §1.3 修订):本节列 **11 改动 #**(#1-#11),其中改动 #1 model-route.md 含 2 段 banner 算 1 改动 #(详 §1.3 数字口径)。diff 风格:`before:` / `after:`。`before:` 标"现状字面",`after:` 标"加 banner / append 后的字面"。banner 字面统一用 §8.2 模板字符串。

#### A 类 — 5 文件 governance(Commit 1)

##### 改动 #1 — `harness/docs/governance/model-route.md`

> banner 字面字段顺序见 §8.2 主模板(SSoT)— 本改动 #1 位置 1 用 §8.2 **主模板**完整字面;位置 2 用 §8.2 主模板**核心字段**(日期 + "codex 接入搁置" + spec 路径 + decision-trail 拐点)在 "何时读" 段尾内嵌(长度适配,不重复"详见 spec"前置短语)。

**位置 1**:文件头 `# Model-Route 治理规则` 之后,`> **何时读本文件**` blockquote **之前**插入 banner。

```diff
 # Model-Route 治理规则
+
+> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本文件保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。

 > **何时读本文件**:进入 P2 codex 接入实施时(swap fork 角色到 codex)+ 后续维护 swap 范围时。
```

**位置 2**:`> **何时读本文件**` blockquote 内末尾加搁置标注。

```diff
-> **何时读本文件**:进入 P2 codex 接入实施时(swap fork 角色到 codex)+ 后续维护 swap 范围时。
+> **何时读本文件**:进入 P2 codex 接入实施时 — **[2026-05-24] codex 接入搁置,本文件保留作日后基线;若重启接入,详见 spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点回溯本搁置背景。**
```

> 注:本文件加 **2 段** banner — 文件头 1(给跨文件检索读者)+ "何时读"段尾 1(给 already-reading 读者)。两段都用"搁置 / 日后基线"语义,但字面允许小幅适配(blockquote 内不重复"详见 spec"路径,避免冗长)。`§8.2` 模板字符串特指文件头格式。

##### 改动 #2 — `harness/docs/governance/synthesis-rules.md` P2 阶段约束段(L21 段)

> 注:本文件实际**无 §21 编号** — 当前正文最高编号是"事前 + 事后规则的逻辑链"段(后接"引用本文件的治理文件"+"相关 spec / decision"段)。早期 brainstorming 用"§21"作简称指代 L21 行附近的 **"P2 阶段约束(P2 = codex 接入,明确计划阶段)"** 段;全 spec 2026-05-25 修订后统一用"P2 阶段约束段"(或"L21 段")命名,不再用"§21"简称(详 §8.6 文档互引影响表)。

**位置**:`P2 阶段约束(P2 = codex 接入,明确计划阶段) — 综合阶段全部保 Claude,不 swap codex...` 段头加 banner。

```diff
-**P2 阶段约束(P2 = codex 接入,明确计划阶段)** — 综合阶段全部保 Claude,不 swap codex。理由:Generator(实现)与 Evaluator(综合判断)角色异源是公设 1(Pathological Optimist)的直接推论;综合判断是聚合多挑战者结论的关键节点,需保持模型一致性以稳定基线。
+**P2 阶段约束(P2 = codex 接入,明确计划阶段)** — **[2026-05-24] codex 接入搁置 — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。** 综合阶段全部保 Claude,不 swap codex。理由:Generator(实现)与 Evaluator(综合判断)角色异源是公设 1(Pathological Optimist)的直接推论;综合判断是聚合多挑战者结论的关键节点,需保持模型一致性以稳定基线。**若未来重启 codex 接入,本段约束仍然成立(保 Claude 综合)** — 详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。
```

##### 改动 #3 — `harness/docs/governance/planning-rules.md` 顶部

**位置**:`> **调度者 fork agent 时遵守 ..synthesis-rules.md.. 事前/事后规则**...` blockquote 内 `model-route.md 已列入 swap 角色` 之后加搁置标注。

```diff
-> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 planner swap codex 场景(model-route.md 已列入 swap 角色)。
+> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 planner swap codex 场景(model-route.md 已列入 swap 角色;**[2026-05-24] codex 接入搁置,fork 子任务维持全 Claude — 详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`**)。
```

##### 改动 #4 — `harness/docs/governance/implementation-rules.md` 顶部

**位置**:`> **调度者 fork agent 时遵守 ..synthesis-rules.md.. 事前/事后规则**...` blockquote 同 #3 模式加搁置标注。

```diff
-> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 implementer swap codex 场景(model-route.md 列为 P2 核心 swap 角色)。
+> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 implementer swap codex 场景(model-route.md 列为 P2 核心 swap 角色;**[2026-05-24] codex 接入搁置,fork 子任务维持全 Claude — 详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`**)。
```

##### 改动 #5 — `harness/docs/governance/testing-rules.md` 顶部

**位置**:`> **调度者 fork agent 时遵守 ..synthesis-rules.md.. 事前/事后规则**...` blockquote 同 #3 模式加搁置标注。

```diff
-> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 testing swap codex 场景(model-route.md 已列入 swap 角色)。
+> **调度者 fork agent 时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-22 加入)— 适用 testing swap codex 场景(model-route.md 已列入 swap 角色;**[2026-05-24] codex 接入搁置,fork 子任务维持全 Claude — 详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`**)。
```

#### B 类 — 2 处(Commit 2)

##### 改动 #6 — `harness/docs/ROADMAP.md` 新增"已识别但搁置"段

**位置**(2026-05-25 N #3 修订 — anchor 精确化):在 `### P2:可观测性 — 双层(2026-04-28 立 + 同日 reframe glassbox 角色)` 段**之前**新建 `### 已识别但搁置` 段(实际 ROADMAP 内**无 `### 已识别下一步` 三级标题**;改 anchor 引用为"**`**已识别下一步**` 段后**" — 即 `### P0.9 / P0.9.x 系列` 段内 `**已识别下一步**` 加粗段后,`### P2:可观测性...` 之前)。

> **语义边界**(2026-05-25 N #6 修订):`### 已识别但搁置` 与 ROADMAP 内现有 `**已识别下一步**`(P0.9 段内加粗段) 共存,语义边界:
> - `**已识别下一步**`(现有)= 已识别 + **未启动**的下一步候选(无搁置态)
> - `### 已识别但搁置`(新建)= 已识别 + **曾启动规划但当前搁置**的项(本 batch codex 接入即此类)
> - 两段独立标题,**不合并** — 合并会丢失"搁置"独立语义

```diff
 - 🟡 **D 类残留**(D2 untracked / D3 anchor 写死 / D6 case 子串包含):YAGNI 接受不修(详 decision `2026-04-30-d-class-tech-debt-batch.md` §不做)

+### 已识别但搁置
+
+> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。
+
+- **codex 接入**(11 swap 角色 — `model-route.md` §4):
+  - 实现链路 4:designer / planner / implementer / testing
+  - 审查链路 7:silent-failure-hunter / 设计自检 / design-review 4 挑战者 / code-reviewer / evaluate 非关键 / security-scan 危险 / security-scan 注入
+  - 不 swap 6:调度者 / evaluate 关键 / security-scan 凭证 / meta-review / process-audit / 综合阶段
+  - 现状:0% 落地(实施层 swap 配置未进 `.claude/{agents,skills,hooks}/`);plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝(实证)
+  - 保留作日后基线:`model-route.md` / `synthesis-rules.md` P2 段 / `planning/implementation/testing-rules.md` 顶部引用 / `p0-9-4-self-check.md` §C/§G3/§G4/§F2
+  - **不预设重启时间 / 启动条件 / 触发信号**(`feedback_iterative_progression` 硬约束)

 ### P2:可观测性 — 双层(2026-04-28 立 + 同日 reframe glassbox 角色)
```

##### 改动 #7 — `harness/docs/references/2026-05-22-p0-9-4-self-check.md` §C/§G3/§G4/§F2 段头 banner

> 4 处段头**各加一行 banner**,段内容**不动**(D2 B 风格 — 内容保留 + 段头加 banner)。
>
> **banner 位置精确化**(2026-05-25 N #7 修订):banner 紧贴 `### Cx / ### Gx / ### Fx` 标题**正下方**(标题行 + 1 空行 + banner blockquote + 1 空行 + 正文首行)— 不黏连原句"唯一解药"(§F2 中);若 §F2 原句出现在 banner 之后任何位置,banner 不重写、不挪动。

**位置 §C(L125)**:

```diff
 ## C. P2 codex 接入实施

+> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,若 codex 接入重启 + 落地则自查项激活,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`。
+
 ### C1. swap 角色实际接入了几个?
```

**位置 §G3(L347)**:

```diff
 ### G3. Trust 项目级 codex config

+> **[2026-05-24] codex 接入搁置** — 本项检查项若 codex 接入重启则激活,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`。
+
 **当前**:`D:\个人\harness` 不在 codex trusted projects list
```

**位置 §G4(L358)**:

```diff
 ### G4. codex CLI 升级 + gpt-5.5 解锁

+> **[2026-05-24] codex 接入搁置** — 本项检查项若 codex 接入重启则激活,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`。
+
 **当前**:codex CLI 0.106.0,gpt-5.5 不可用(返回"requires a newer version")
```

**位置 §F2(L306)**:

```diff
 ### F2. 独立 fork 是否真发现主对话漏的问题?

+> **[2026-05-24] codex 接入搁置** — 本项 §F2 末"唯一解药"若 codex 接入重启则激活;原句保留(`feedback_spec_gap_masking` B 风格 — 段头 banner 承认 gap,正文保留历史推导)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`。
+
 **预期**:meta-review fork 出的挑战者,**应比主对话多发现 ≥ 50% 问题**。
```

> 注:§F2 原句"**唯一解药**:swap 挑战者到不同模型(**P2 codex 接入正是为此**)"**保持原样不动**(D2 决策)。

#### C 类 — 4 处(Commit 3)

##### 改动 #8 — `harness/docs/decision-trail.md` append 2026-05-24 拐点

**位置**:在 `## 2026-05-22 — P0.9.4 主线:二公设 + synthesis-rules + P2 codex 接入` 段**之前**(时间倒序最新在上)新建 2026-05-24 段。

```diff
+## 2026-05-24 — codex 接入搁置
+
+- **抉择**:搁置 P2 codex 接入(11 swap 角色 — `model-route.md` §4),fork 子任务维持全 Claude;**不删** `model-route.md` / `synthesis-rules.md` P2 段 / `planning/implementation/testing-rules.md` 顶部引用 / `p0-9-4-self-check.md` §C/§G3/§G4/§F2(保留作日后基线);11 处文件改动 = 5 governance(scope=meta)+ ROADMAP + self-check(scope=none 跟随)+ decision-trail + handoff + 2 README(scope=none 跟随)
+- **替代**:A 全删 codex 规划文档(信息丢失,重启时需重写)/ C 改写为"日后启动 + 触发信号"(违反 `feedback_iterative_progression`);banner 内容动版本(违反 `feedback_spec_gap_masking` B 风格)
+- **触发**:2026-05-24 用户 + 调度者 cross-check 发现实施层 0% 落地(11 swap 角色中 5-6 个在 `.claude/{agents,skills}/` 里本身不存在)+ plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝实证 + codex exec 直调 gpt-5.5 通但 harness 入口需 skill/agent 文件设计调用范式 + `feedback_iterative_progression`(无具体真实需求拉动时不做)
+- **影响**:11 处文件加 `[2026-05-24] codex 接入搁置` banner(字面统一,详 spec §8.2);3 commits(A 类 governance / B 类 ROADMAP+self-check / C 类 decision-trail+handoff+README);N=4 标准 meta-review(bootstrap 4 维基线 — 挑战者 #1 核心原则合规 / #2 目的达成度 / #3 副作用 / #4 scope 漂移;各维子焦点详 spec §6.2);**不预设重启时间 / 启动条件 / 触发信号**(D1 决策 D 风格);未来重启时重走完整 brainstorming + design,不从本 spec 草拟启动条件;plugin-cc patch 保留(D7 决策,独立于 11 swap 角色搁置)
+- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` 自身构成完整记录;`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11 P2 实施路径 superseded by 本拐点);spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`(本 batch 设计文档);audit:待 meta-review 跑完后回填(预期 `docs/audits/meta-review-2026-05-24-HHMMSS-codex-shelved-batch.md`)

 ## 2026-05-22 — P0.9.4 主线:二公设 + synthesis-rules + P2 codex 接入
```

##### 改动 #9 — `harness/docs/active/handoff.md` 状态行同步

**位置 1**(2026-05-25 N #4 修订 — anchor 精确化):`## 目标` 段末尾,**`下一步:边做边提升,无预设阶段...` 行后插 1 空行 + 1 banner 行**(banner 之前空 1 行避免与"下一步"行黏连;banner 之后空 1 行再接 `## 进度` 标题)。

```diff
 下一步:边做边提升,无预设阶段;P0.9.2 候选累积(harness self-trial 局限 / cross-file 互引脆弱 / 反模式段膨胀 / 挑战者有效性元疑问 等 spec §9.4 #5-#9 推后续);P0.9.4 候选(本 trial 新发现 M3/M4 路径混淆)。

+**[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点;11 处文件改动已落地(5 governance + ROADMAP + self-check + decision-trail + handoff + 2 README);不预设重启时间(`feedback_iterative_progression`)。
+
 ## 进度
```

**位置 2**(本 spec **不启用** — 简化版同步 — 仅位置 1 已满足"handoff 状态行同步"需求):本 spec 不要求 implementer 加位置 2;挑战者 #2 目的达成度(子焦点 11 处清单完整)维度对单位置 1 通过(2026-05-25 N #14 修订:删"可选"含糊措辞,明确"不启用")。

##### 改动 #10 — `README.md`(harness 根)§57-75 加段头 banner

**位置**:`## 可选:接入 OpenAI Codex` 段头之后,`harness 可选接入 OpenAI Codex...` 正文之前加 banner。

```diff
 ## 可选：接入 OpenAI Codex

+> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`);若日后激活 codex 接入,先读 `harness/docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `harness/docs/decision-trail.md` 2026-05-24 拐点回溯本搁置背景。下方安装步骤 + swap 决策表保留作完整参考。
+
 harness 可选接入 OpenAI Codex 作为部分 sub-agent 角色的替代。**核心目的：成本节省**（Claude 同等能力比 codex 贵）。跨模型对抗是副产品，不是主要目的。
```

> 注:全角冒号 `：` 在 `## 可选：接入 OpenAI Codex` 段头保留原状(本文件其他位置混用全角/半角,此处为已有现状,不在本 batch 改动范围内)。

##### 改动 #11 — `harness/README.md`(M4 分发模板)§144-147 加段头 banner

**位置**:`## 可选：接入 OpenAI Codex（多模型成本路由）` 段头之后,`部分 sub-agent 角色可 swap 到 codex...` 正文之前加 banner。

```diff
 ## 可选：接入 OpenAI Codex（多模型成本路由）

+> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`);若日后激活 codex 接入,先读 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `docs/decision-trail.md` 2026-05-24 拐点回溯本搁置背景。下方 swap 列表 + 不 Swap 列表 + 决策表入口保留作完整参考。
+
 部分 sub-agent 角色可 swap 到 codex（Claude 同等能力比 codex 贵 → 成本节省）。
```

> 注(2026-05-25 Critical 9 修订):本文件**不经 setup.sh 分发下游**(setup.sh 已 verified 不复制 harness/README.md — 详 §8.6);下游用户通过 GitHub 仓库浏览路径(`https://github.com/.../harness/blob/main/harness/README.md`)访问此 banner;C3 场景因此降为 P1(详 §1.2 Critical 8 修订)。

### 8.2 banner 措辞模板(D 风格,统一格式)

**主模板字符串**(11 处中**最完整版**,用于 model-route.md 文件头 / 2 README / decision-trail 拐点首行 — 长版):

```
> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本{文件/段}保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。
```

**变体 1 — 段内嵌入版**(用于 governance rules 顶部 blockquote 嵌入,planning/implementation/testing-rules.md 顶部 + synthesis-rules.md P2 段):

```
**[2026-05-24] codex 接入搁置,fork 子任务维持全 Claude — 详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`**
```

**变体 2 — self-check 段头版**(用于 §C / §G3 / §G4 / §F2 段头,简短):

```
> **[2026-05-24] codex 接入搁置** — 本{项/段}若 codex 接入重启则激活,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`。
```

> Critical 3 修复:原措辞"在 codex 接入重启时启用"含"时启用"时序触发语义,与禁用词清单同构;改写为"若 codex 接入重启则激活"避用"时"字时序触发(2026-05-25 修订)。

**变体 3 — handoff 状态行**(简洁版):

```
**[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。
```

**变体 4 — ROADMAP "已识别但搁置"段头版**(同变体 2 风格,但用 blockquote):

```
> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。
```

**占位符替换规则**(2026-05-25 N #20 修订):主模板 + 变体 2 + 变体 4 中 `{文件/段/项}` 占位符 implementer 按改动 # 上下文替换 — model-route.md 文件头用 "文件"、synthesis-rules.md P2 阶段约束段用 "段"、self-check §C/§G3/§G4 用 "项"、§F2 用 "项"、ROADMAP "已识别但搁置" 段用 "段"、2 README 用 "段"。替换后字面**完全无 `{}` 字符**;若 implementer 未替换留 `{文件/段/项}` 字面,挑战者 #1 grep `{文件/段/项}` 命中即 verdict=needs-revision。

**字段顺序约束**(所有变体共有):
1. `[2026-05-24]` 日期(半角方括号,固定 YYYY-MM-DD)
2. `codex 接入搁置` 短语(固定,不写"codex 接入推迟"/"codex swap 暂停"等近义词)
3. `fork 子任务维持全 Claude` 现状陈述(主模板 + 变体 1 + 变体 3)
4. `本{文件/段/项}保留作日后基线`(主模板 + 变体 2 + 变体 4)
5. `不预设重启时间`(主模板 + 变体 2 + 变体 4)+ `\`feedback_iterative_progression\`` 原则引用(主模板 + 变体 2 + 变体 4)
6. `详见 \`docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md\``(全部变体必有)
7. `+ \`decision-trail.md\` 2026-05-24 拐点`(主模板 + 变体 3 — model-route.md 文件头 / 2 README / decision-trail / handoff)

**禁用词列表**(D1 决策严守,§5.3 检测,§6.1 验证 2):
- 启动条件类:"等待"、"待...触发"、"启动条件"、"何时重启"、"v Next"、"until ready"、"when X"
- 时间类:"下个版本"、"近期"、"暂时"、"短期"(都暗示有时间预设)
- 触发信号类:"X 时启用"、"X 完成后"、"等 codex CLI 升级"、"启用 codex"、"日后启用"(2026-05-25 Critical 3 修复后,banner 字面统一用"若 X 则激活"非时序触发语义;2026-05-25 verify 后置追加"启用 codex / 日后启用"覆盖 §8.1 改动 #10/#11 修复前残留模式)
- **clarification**:"重启时激活"与"重启时启用"看似近义,但"启用"是被动接收触发信号语义(disallowed),"激活"是状态切换语义(allowed,无时序触发暗示);banner 字面统一用"激活";若 implementer 误写"启用"挑战者 #4 grep 应捕获

**半角约束**:所有方括号 `[` `]` / 括号 `(` `)` / 反引号 ` ` 必须半角(避免与 hook grep 字面比对冲突;详 M2 §7.3 sentinel + 半角约束)。

### 8.3 decision-trail 2026-05-24 拐点全文

> 完整 append 内容已在 §8.1 改动 #8 给出。本节冗余保留以便挑战者快速定位。append 位置:`## 2026-05-22 — P0.9.4 主线...` 段**之前**(时间倒序最新在上)。

字段约束:
- **抉择**:1-2 句,核心动作(搁置 codex 接入 + 11 处文件改动)
- **替代**:列被否决的方案 + 否决理由(A 全删 / C 改写 / banner 内容动)
- **触发**:本次启动本 batch 的具体事实(用户 cross-check 发现 / 实证拒绝 / 实施 0% 落地)
- **影响**:11 处 banner + 3 commits + N=4 meta-review + D1 D 风格 + 不预设重启
- **decision file**:暂无(留痕型;spec + decision-trail 自身构成完整记录;ECC §11 superseded by 本拐点)

### 8.4 3 commit 拆分明细(D3)

> 数字口径(承 §1.3):3 commits 文件数 5/2/4 = 11 文件 = 11 改动 #(每文件 1 改动 #;改动 #1 model-route.md 含 2 段 banner 仍计 1 改动 # / 1 文件)。

| Commit | scope | 文件数 / 改动 # | 文件清单 | 备注 |
|---|---|---|---|---|
| **Commit 1** | **scope=meta**(A 组 `docs/governance/*.md`) | 5 文件 / 5 改动 #(#1-#5) | model-route.md / synthesis-rules.md / planning-rules.md / implementation-rules.md / testing-rules.md | governance 改动;触发 M2 meta-review;hook 检 covers(covers 字段路径写 **不含 `harness/` 前缀**:`docs/governance/model-route.md` 等 — hook cwd=harness/,M2 §7.3 sentinel 协议;详 §8.6 hook 行为说明) |
| **Commit 2** | **scope=none 跟随**(mixed 因 Commit 1 标 meta,Commit 2/3 在同一 PR / 同一 finishing 走 meta path) | 2 文件 / 2 改动 #(#6-#7) | ROADMAP.md / 2026-05-22-p0-9-4-self-check.md | 跟随 meta 走 M1 finishing 但不单独触发 meta-review(已被 Commit 1 audit covers 包含) |
| **Commit 3** | **scope=none 跟随**(同 Commit 2) | 4 文件 / 4 改动 #(#8-#11) | decision-trail.md / handoff.md / README.md / harness/README.md | append 拐点 + 状态同步 + 下游分发感知 |

**为何不合并**(对照 D3 选项 A 单 commit):
- 回滚精度:若 Commit 1 banner 字面在 meta-review 后需调整,只 revert Commit 1,Commit 2/3 不动(它们的 self-check + ROADMAP + decision-trail 内容已落地,无需重做)
- 因果分离:Commit 2/3 引用 Commit 1 的 banner — commit graph 上"Commit 1 → Commit 2 → Commit 3" 因果清晰

**为何不细分到 11 commits**(对照 D3 选项 B):
- 单文件单 commit 噪音大;按类型分 3 commits 是回滚精度 + 因果清晰的平衡点

### 8.5 顺序约束(D3 + §5.2 cross-ref 悬空预防)

**顺序**:**Commit 1** → **Commit 2** → **Commit 3**(严格,无并行 / 颠倒)。

**理由**:
- Commit 2 self-check §C / ROADMAP "已识别但搁置"段引用 Commit 1 已落地的 banner 措辞(详 §8.1 改动 #6 / #7)
- Commit 3 decision-trail / handoff / 2 README 引用 Commit 1 已落地的 banner 措辞(详 §8.1 改动 #8 / #9 / #10 / #11)
- 颠倒顺序会让 Commit 2/3 在 push 时引用 Commit 1 还未落定的 banner 字面 → §5.2 cross-ref 悬空场景触发

**实操**:
- implementer 按 §8.1 改动顺序逐 commit 落地
- 单 push 一次性 push 三个 commit(顺序在 commit graph 上锁定)
- 不分支并行(本 batch 在 main 主线上单线性 commit)

**revert 约束**(2026-05-25 N #10 修订):**若 Commit 1 需 revert(meta-review 后 banner 字面有改写需求),Commit 2/3 必须同步 revert**(因 Commit 2/3 内 banner 字面引用 Commit 1 已落定字面;若只 revert Commit 1,Commit 2/3 内 banner 字面 stale → cross-ref 悬空场景 5.2 触发);若 Commit 2 或 Commit 3 独立有问题,可只 revert 该 commit(不影响 Commit 1 + 其他 commit)。

### 8.6 影响面 — 下游分发 + 文档互引

**下游分发**(F 组 `harness/setup.sh` + `harness/README.md`):
- 本 batch **不改 setup.sh**
- **setup.sh 行为已 verified(2026-05-25 Critical 9)**:setup.sh 复制 `harness/CLAUDE.md`(L117 `cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/"` = M4 分发模板)+ `.claude/agents`(L41-45)+ `.claude/skills/*/SKILL.md`(L57-65)+ `.claude/hooks/*.sh`(L70-78,排除 meta-* / check-meta-*)+ `docs/*` 多文件(L84-112,排除 meta-* governance)— **不复制** `harness/README.md`(setup.sh 全文 grep 无 `cp.*README.md` 行,只 cp `harness/CLAUDE.md` 作 M4 分发模板)
- **gap 承认**(2026-05-25 Critical 9):setup.sh **不复制** harness/README.md,故改动 #11(harness/README.md §144-147 banner)对下游用户**无直接可见路径**,需通过 GitHub 仓库浏览(`https://github.com/.../harness/blob/main/harness/README.md`)访问;C3 落地依赖此路径 → §1.2 已将 C3 从 P0 降为 P1(Critical 8 修订)— 不阻塞本 batch,但需在 §6.3 测试边界 + §1.2 C3 备注明确"无 P0 级验收手段"
- `harness/README.md`(改动 #11)是 M4 概念分发模板(实际 setup.sh 不复制 — 见上),改动会保留在 harness 仓库,下游新装用户通过 GitHub 浏览仓库时可读到 §144-147 banner;**已装项目不自动更新**(详 §1.3 兼容性要求)
- `README.md`(harness 仓库根,改动 #10)**不分发**,仅作仓库根 README 给 GitHub 访问 / 本仓库内开发者读 — 行为与 harness/README.md 一致,都不进 setup.sh 复制清单

**文档互引影响表**(挑战者 #3 副作用 — 子焦点 cross-ref 完整 — 验证用):

| 引用源 | 引用目标 | 改动后状态 |
|---|---|---|
| `model-route.md` 文件头 banner | `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点 | Commit 3 落地拐点后引用有效 |
| `synthesis-rules.md` P2 段 banner | 同上 | 同上 |
| `planning/implementation/testing-rules.md` 顶部 banner | 同上 | 同上 |
| `self-check §C/§G3/§G4/§F2` 段头 banner | 同上(简化为只引 spec) | 同上 |
| `ROADMAP.md` "已识别但搁置"段 banner | 同上 | 同上 |
| `decision-trail.md` 2026-05-24 拐点 | spec 自身 + Commit 1 的 model-route.md 路径 | Commit 1 落地后引用有效 |
| `handoff.md` 状态行 | spec + decision-trail 2026-05-24 拐点 | Commit 3 内 decision-trail 已落地 → handoff 引用有效(同 commit 内可前向引用) |
| `README.md`(harness 根)§57-75 banner | `harness/docs/superpowers/specs/...` + `harness/docs/decision-trail.md` 2026-05-24 拐点(**根 README 仓库根视角 — path 含 `harness/` 前缀**;详 §8.1 改动 #10) | Commit 3 已落地 |
| `harness/README.md`(M4)§144-147 banner | `docs/superpowers/specs/...` + `docs/decision-trail.md` 2026-05-24 拐点(**M4 模板下游视角 — path 不含 `harness/` 前缀**;详 §8.1 改动 #11) | Commit 3 已落地 |

> **路径前缀差异显式说明**(回应 Minor #18):改动 #10(harness 仓库根 README.md)写 `harness/docs/...` 是因为从仓库根视角看 spec / decision-trail 在 harness/ 子目录;改动 #11(M4 分发模板 harness/README.md)写 `docs/...` 是因为 setup.sh 分发到下游后,下游单层结构内 spec / decision-trail 直接在 docs/ 下。两个视角各自正确,挑战者 #3 验证 cross-ref 时按各自视角验证目标路径有效性。

**与既有 superseded 决策的关系**:
- `docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11 P2 实施路径 **不重写**(详 §1.3 不做清单);改由 decision-trail 2026-05-24 拐点 supersede(M1 Step C 范式 — 历史 decision 不重写,新拐点 append 起 supersede 作用)

**自检**:
- [x] 11 处改动都列出"位置 / before / after / 备注"
- [x] §8.1 改动 #2 已澄清 synthesis-rules.md 实际无 §21 编号,全 spec 统一用"P2 阶段约束段"命名
- [x] §8.2 banner 模板 4 变体覆盖 11 处使用场景(主 + 段内嵌入 + 段头 + handoff 行 + ROADMAP 段头)
- [x] §8.4 3 commits 拆分明细 + §8.5 顺序约束完整
- [x] §8.6 文档互引影响表覆盖所有 cross-ref(挑战者 #3 副作用 — 子焦点 cross-ref 完整 — 验证用)
- [x] §8.1 已声明的所有改动都在 §2 / §3 / §4 标"不适用"的合理替代视角内体现(§8 = 文件视角)

---

## 9. 全局自洽性检查

> 各节填完后做最终全局检查。meta scope 适配:用"需求 ↔ 文件改动 / 决策 ↔ 改动 / 决策 ↔ harness 原则 / 改动 ↔ scope / 不做清单 ↔ 各节"替代标准模板的"需求 ↔ 模块 / 模块 ↔ 接口 ..."。

### 9.1 需求 ↔ 文件改动(§1.2 三个核心场景是否都在 §8 11 文件改动中体现?)

| 核心场景 | 落地的文件 | 改动 # |
|---|---|---|
| **C1** 后续读者识别搁置状态 | model-route.md(文件头 banner)+ governance rules 顶部 banner(给读者快速识别) | #1 + #3 + #4 + #5 |
| **C2** 重启时定位需重审的文档 | 11 处全部命中 banner / 段头 / 拐点 / 状态行 — grep "搁置" 一次找全 | #1-#11 |
| **C3** 下游分发感知(P1 — Critical 8 修订) | harness/README.md(改动 #11)§144-147 banner — 下游通过 GitHub 仓库浏览访问(setup.sh **不复制** harness/README.md — Critical 9 verified) | #11 |

- [x] **C1 ↔ 改动 #1/#3/#4/#5**:✅ model-route + 3 governance rules 顶部都加 banner,后续读者打开任一文件可即时识别
- [x] **C2 ↔ 改动 #1-#11**:✅ 全部 11 处都用统一 banner 字面,grep "[2026-05-24] codex 接入搁置" 可一次定位全部
- [x] **C3 ↔ 改动 #11**:✅(P1 — Critical 8 修订)harness/README.md banner 改动到位,但 setup.sh 不复制(Critical 9 verified)— 下游通过 GitHub 仓库浏览路径访问;无 P0 级验收手段

### 9.2 决策 ↔ 改动(§7 D1-D7 每个决策是否在 §8 改动中体现?)

| 决策 | 落地处 |
|---|---|
| **D1** D 风格 banner | §8.2 模板字符串"不预设重启时间(`feedback_iterative_progression`)" + 禁用词清单严守;§5.3 + §6.1 验证 2 检测 |
| **D2** §F2 选 B(原句不动+段头 banner) | §8.1 改动 #7 §F2 段头加 banner,原句"swap 挑战者...P2 codex 接入正是为此"不动 |
| **D3** 3 commits + N=4 | §8.4 commit 拆分明细 + §8.5 顺序约束 + §6.2 4 挑战者维度 |
| **D4** 完整流程 | 本 spec 自身存在 + design-review 阶段 fork 4 挑战者(详 §6.2);D4 在流程层落地,非文件改动 |
| **D5** 11 处清单完整 | §8.1 11 处改动表 + §6.2 挑战者 #2 目的达成度(子焦点 11 处清单完整)验证 |
| **D6** README 加 banner 内容保留 | §8.1 改动 #10 + #11 README 段头加 banner,正文不动 |
| **D7** plugin-cc patch 保留 | 不在 §8 列改动(D7 = 不动);§7 D7 文字说明 |

- [x] **D1 ↔ §8.2**:✅ 模板字符串严守 D 风格 + 禁用词清单
- [x] **D2 ↔ §8.1 #7**:✅ §F2 段头加 banner,原句保留
- [x] **D3 ↔ §8.4 / §8.5 / §6.2**:✅ 3 commits + N=4 完整落地
- [x] **D4 ↔ 流程**:✅ design + design-review 走完
- [x] **D5 ↔ §8.1 / §6.2**:✅ 11 处清单 + 挑战者 #2 目的达成度(子焦点 11 处清单完整)验证
- [x] **D6 ↔ §8.1 #10 / #11**:✅ README 内容保留,只加段头 banner
- [x] **D7 ↔ §7 D7 + 不在 §8**:✅ plugin-cc 不动

### 9.3 决策 ↔ harness 原则

| 决策 | 对齐的 harness 原则 |
|---|---|
| **D1** D 风格 banner | `feedback_iterative_progression`(2026-04-28 用户原则:不预设固化未来阶段)+ ROADMAP "边做边提升"哲学 |
| **D2** §F2 选 B | `feedback_spec_gap_masking`(2026-04-17 用户原则:承认 gap 但不掩盖)— B 风格"段头 banner 承认 + 正文保留历史"是合理形式 |
| **D3** 3 commits + N=4 RUBRIC | RUBRIC §一通用基线"简洁性"(N=4 是标准,不缩;3 commits 是回滚精度与因果清晰的平衡)+ M2 §6 bootstrap 4 维基线必含 |
| **D4** 完整流程 | 用户主动选(2026-05-24 user instruction);加严 harness meta path 默认 |
| **D5** 11 处清单完整 | `feedback_judgment_basis`(基于 grep 事实证明,无市场判断) |
| **D6** README 加 banner 内容保留 | `feedback_spec_gap_masking` B 风格 + `feedback_iterative_progression`(信息保留,日后重启可复用) |
| **D7** plugin-cc patch 保留 | 决策正交独立(plugin-cc 日常 consult ≠ 11 swap 角色接入);不主动改无关代码(`feedback_judgment_basis` + 实施 rules.md 最小变更) |

- [x] **D1 ↔ feedback_iterative_progression**:✅ 强对齐
- [x] **D2 ↔ feedback_spec_gap_masking**:✅ B 风格是承认 gap 的合理形式
- [x] **D3 ↔ RUBRIC + M2**:✅ 标准做法
- [x] **D4 ↔ user instruction**:✅ 用户主动加严
- [x] **D5 ↔ feedback_judgment_basis**:✅ 基于事实(grep cross-check)
- [x] **D6 ↔ feedback_spec_gap_masking + iterative_progression**:✅ 双对齐
- [x] **D7 ↔ feedback_judgment_basis + 最小变更**:✅ 不主动改无关代码

### 9.4 改动 ↔ scope

| Commit | 文件 | scope 分类 |
|---|---|---|
| Commit 1 | 5 governance | scope=**meta**(A 组 `docs/governance/*.md` glob 命中) |
| Commit 2 | ROADMAP + self-check | scope=**none**(`docs/ROADMAP.md` / `docs/references/*.md` 在 scope.conf include glob 外) |
| Commit 3 | decision-trail + handoff + 2 README | scope=**none** 同上 |

**mixed 判定**(按 CLAUDE.md §3 §4 "任一命中即 meta"):
- 整个 batch(11 改动 #)= 5 改动 # meta + 6 改动 # none = **mixed → 走 meta 路径**(M1 finishing + M2 review)— 拆分:Commit 1 5 改动 # 全 meta(改动 #1-#5)+ Commit 2 2 改动 # 全 none(改动 #6-#7)+ Commit 3 4 改动 # 全 none(改动 #8-#11)
- 即"任一命中即 meta"的整个 batch 走 meta path(详 §0 + spec 头部 scope 声明)

- [x] **Commit 1 = meta**:✅ A 组 governance/*.md
- [x] **Commit 2 = none 跟随 mixed**:✅ ROADMAP / self-check 在 scope.conf 外但 batch 整体走 meta path
- [x] **Commit 3 = none 跟随 mixed**:✅ decision-trail / handoff / README 在 scope.conf 外但同上
- [x] **整体 = mixed 走 meta path**:✅ 按 CLAUDE.md §3 §4 规则

### 9.5 不做清单 ↔ 各节(§1.3 不做的事是否被某节正文偷偷做了?)

| 不做清单条目 | 是否被 §2-§8 偷偷做? |
|---|---|
| 不删 model-route / synthesis P2 阶段约束段 / 3 governance 引用 | ✅ §8.1 改动 #1-#5 全部只加 banner / 标搁置,正文不动 |
| 不改 ECC §11 | ✅ §8 + §7 D7 + §8.6 都明确 ECC §11 由 decision-trail 拐点 supersede,不重写 |
| 不改 recommended-tools.md | ✅ 不在 §8.1 11 处清单内 |
| 不改 CLAUDE.md / harness/CLAUDE.md | ✅ 不在 §8.1 11 处清单内 |
| 不改 .claude/{agents,skills,hooks}/ | ✅ 不在 §8.1 11 处清单内 |
| 不预设重启时间 / 启动条件 / 触发信号 | ✅ §8.2 D1 模板 + 禁用词清单 + §6.1 验证 2 grep 检测 |
| 不回滚 plugin-cc patch | ✅ §7 D7 + §8 不在改动清单内 |
| 不改写 §F2 正文为 A 风格"swap 是潜在方案 + 承认 gap"(Critical 4 修订:此处"承认 gap"指 A 风格内容改写,disallowed;B 风格段头 banner allowed) | ✅ §8.1 改动 #7 仅加段头 banner(B 风格 — allowed),§F2 原句不动 |

- [x] 8 条不做清单**全部 ✅** — 各节正文无偷偷做

### 9.6 RUBRIC ↔ 设计(§6 / §7.1 对 RUBRIC 风险的应对方式)

| §1.6 标记的 RUBRIC 风险 | 应对方式 | 落地节 |
|---|---|---|
| **简洁性**:11 处是否过度工程 | §1.6 + §8.1 给"11 处是同一决策散布同步"理由 + §6.2 挑战者 #4 scope 漂移(子焦点 RUBRIC 简洁性)验证可信度 | §1.6 + §8.1 + §6.2 |
| **一致性**:11 处 banner 措辞统一 | §8.2 唯一模板字符串 + §6.1 验证 1 grep + §6.2 挑战者 #1 核心原则合规(子焦点措辞一致性)字面 | §8.2 + §6.1 + §6.2 |
| **功能完整性**:meta 无 feature 验收 | 以 meta-review verdict 为通过 + §6.2 挑战者 #4 scope 漂移(子焦点 D1-D7 决策都在 §8 体现)验证 | §6.2 + §7.1 |
| **不引入新流程**:沿用 M1 + M2 | 全 spec 无新建 governance 文件 / 无新建 hook | §0 + §6.2 |
| **C 风格 commit 拆分**(含顺序约束) | §8.4 拆分明细 + §8.5 顺序约束 严守 | §8.4 + §8.5 |

- [x] §1.6 标记的所有 RUBRIC 维度都有应对方式(简洁性 / 一致性 / 功能完整性 / 不引入新流程 / C 风格 commit 拆分,5 维全部覆盖)

### 9.7 与 ARCHITECTURE.md 分层规则

- [x] **不冲突**:本 batch 是 meta scope 文档改动,ARCHITECTURE.md 分层规则(UI / Service / Repository)对纯文档治理改动**不适用**(§2 / §3 / §4 已声明)
- [x] **不引入新依赖**:无新文件 / 无新模块 / 无新 hook / 无新 settings 配置

### 9.8 与 §0 偏离说明

- [x] §0 声明的"§2 / §3 / §4 不适用"全部在各节标注且给替代视角
- [x] §0 声明的"§5 改为措辞冲突 + cross-ref 悬空"在 §5 三个场景体现
- [x] §0 声明的"§6 改为措辞一致性验证 + 4 挑战者"在 §6 体现
- [x] §0 声明的"不引 RUBRIC 维度作豁免"在 §1.6 / §6 / §7 / §9 全节遵守

### 9.9 与 brainstorming 阶段需求

- [x] D1-D7 全部带入(§1.5 表格 + §7 决策记录)
- [x] §1.3 边界与约束与 brainstorming 输出一致(11 处 + 不做清单 8 条)
- [x] 无范围扩散(没实现 brainstorming 未确认的内容 — §1.6 自检 + §9 各节都验证)

### 9.10 跨节引用一致

| 引用 | 目标 | 验证 |
|---|---|---|
| §0 → §2 / §3 / §4 标"不适用" | §2 / §3 / §4 各节存在且标"不适用" | ✅ |
| §1.6 → 挑战者 #1(核心原则合规)/ #4(scope 漂移) | §6.2 对应挑战者存在且子焦点对应 | ✅ |
| §5.1 / §5.2 / §5.3 → §6 / §8 | §6 / §8 对应位置存在 | ✅ |
| §7 D1 → §8.2 + §5.3 + §6.1 | 3 处都存在且语义匹配 | ✅ |
| §7 D2 → §8.1 改动 #7 | §8.1 改动 #7 + §F2 段头 banner | ✅ |
| §7 D3 → §8.4 + §8.5 + §6.2 | 3 处都存在 | ✅ |
| §7 D6 → §8.1 改动 #10 + #11 | 2 处都存在 | ✅ |
| §8.6 文档互引表 → §8.1 11 处改动 | 1:1 对应 | ✅ |
| §9.1-§9.10 自洽检查 → §1-§8 各节 | 全部勾选 | ✅ |

- [x] **全部 ✅** — 跨节引用一致,无悬空

---

> **设计文档完成。** 提交给独立自检挑战者(若调度者按扁平 fork 架构 fork 自检)+ design-review 4 挑战者(§6.2 标准维度)。

> 调度者读取本 spec 后,按 D4 完整流程进入下一步:design-review 阶段 fork 4 挑战者(bootstrap 4 维基线:#1 核心原则合规 / #2 目的达成度 / #3 副作用 / #4 scope 漂移 — 各维度子焦点详 §6.2);通过后进入 writing-plans + subagent-driven-development 实施 11 处改动;完成后进入 M1 meta-finishing + M2 meta-review N=4 fork。

> 本 spec 自身路径:`harness/docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`(在 §8.2 模板中被 11 处文件 banner 引用)。

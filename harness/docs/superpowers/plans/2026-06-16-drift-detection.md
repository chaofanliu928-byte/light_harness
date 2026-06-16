# ③b 漂移检测(drift-scout 收口子智能体)实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. 每个任务一个 commit(C 风格频繁提交)。

**Goal:** 在 ③a `touchpoint-registry.md`(13 触点机读表)地基上,**收口·凭证批·audit 内 fork 一个 `drift-scout` 子智能体**:读注册表、逐触点读两端点实际内容、按该行判据(5 类全覆盖)判一致性、报漂移(✅一致 / 🔴漂移[附差异指针] / ⚠️不确定),报告分层(🔴 突出 / ✅折叠),软不阻断、只读不写、需 agent 运行时无则跳过回落人工触点维。改动物 = 新建 1 个 agent 契约 markdown(`drift-scout.md`)+ setup.sh agents 段加 1 行 cp(自指分发)+ finishing-rules 收口工序加「触点漂移检测」一步。

**Architecture:** ADD 一条「触点漂移检测」步,接在 finishing-rules「凭证义务核对」节(step 15-18)内/后,**门控 = 仅本批命中 `credentials.conf`(收口须产 audit)即在该凭证批 audit 内自动跑**(不依赖审查者是否选了「触点完整性维」)。依赖方向单向无环:`finishing-rules 步` → `调度者 fork drift-scout`(独立 context,Read/Grep 工具)→ `读 touchpoint-registry.md + 各端点文件`(只读)→ `报告` → `调度者据报告手工回填注册表现状列`。drift-scout 与现有 6 个 `check-*` hook + 3 个既有 scout(freshness/review/research)**零耦合、不互调**;复用 freshness-scout 形态范式(HTML 注释新鲜度标签 ≠ YAML `---` custom agent;入参/出参契约;fork 失败降级)。

**Tech Stack:** markdown 纯文件治理约定(无运行时代码、无 API、无 DB)+ 一个 fork 子智能体的**行为契约**(自然语言 prompt + 判据映射)+ bash 一行 cp(setup.sh 分发)+ bash/grep(静态核 + 红线测验证)+ git(每任务一 commit)。**无 bash hook**(收口用 fork 子智能体,非第 7 个 `check-*` hook);**无可跑的 pytest**。

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-16-drift-detection-design.md`(544 行,已过自检 + design-review 两轮修订,已锁;§1.5 决策 / §1.7 两死结 / §2 模块 / §3 接口[入参/出参契约]/ §4 数据[§4.3 判据→判法映射 · §4.4 三前缀解析 · §4.5 分发模型分类]/ §5 边界 / §6 测试[§6.1 红线测]/ §7 决策 D1-D5 / §8.1 改动集 / §10 守住段+不做清单)

**同类计划范本(结构/粒度/验证写法仿它,同为 harness meta + scout 契约):** `harness/docs/superpowers/plans/2026-06-16-freshness-mechanism.md`(同为 harness meta 改动、非 pytest)
**agent 文件形态范本:** `harness/.claude/agents/freshness-scout.md`(L1 HTML 注释新鲜度标签 + L2 裸文本角色句 + 形态说明 blockquote,无 YAML frontmatter tools — drift-scout.md 逐字同形)
**scout 消费对象:** `harness/docs/governance/touchpoint-registry.md`(13 触点机读主表,TP-01~TP-13)
**setup.sh 分发范本行:** `harness/setup.sh` L51(`cp "$SCRIPT_DIR/.claude/agents/freshness-scout.md" ...` — drift-scout.md cp 行紧随其后,逐 cp 行类)

---

## 适配说明(本功能是文档+契约为主的 harness meta 改动,不是代码+pytest)

- **改动物 = 1 新建契约 markdown + 1 行 setup.sh cp + finishing-rules 加 1 步**:`drift-scout.md` 的"漂移检测逻辑"住其契约(prompt / 判据→判法映射 / 三前缀解析 / 分发模型分类),收口时由调度者 fork 它执行。**没有可跑的 pytest**。
- **"验证" = 静态核 + 红线测**(照范本 + spec §6):
  - (a) **契约一致性静态核**:`drift-scout.md` 入参 6 字段 / 出参二态(AllAligned/DriftReport)/ TouchpointVerdict 字段 / 5 类判据 enum / 三前缀解析 / 报告分层 / fork 失败降级 / 需 agent 运行时 / 只读不写 各节齐全且取值域一致(grep 核)。
  - (b) **形态核**:`drift-scout.md` 首行 HTML 注释新鲜度标签、**无 YAML `---` 块**(不被解析成 custom agent type),镜像 freshness-scout.md L1-L4。
  - (c) **类型一致核(单源)**:出参契约字段 / 5 类判据 enum / 三态符号(✅🔴⚠️)在 `drift-scout.md` 各节 + spec §3.1/§4.3 逐字一致。
  - (d) **分发自指核**:setup.sh agents 段有 `cp .../drift-scout.md` 行(否则 scout 跑起来自查 TP-09 报 🔴)。
  - (e) **接线落点核**:finishing-rules「触点漂移检测」步落在「凭证义务核对」节(step 15-18)内/后,门控 = 仅凭证批,软不阻断,不动既有 step 15-18 原文 + 不动既有 §安全扫描/方向评估/流程审计步。
  - (f) **守住核(零改)**:注册表 13 行 + 判据 enum / 现有 6 个 `check-*` hook / 对账三命令 / finishing 既有步 / credentials.conf glob / 既有 scout 契约 **零改**(spec §10.1)。
  - **红线测(验 scout 真能逮漂移 — spec §6.1/§6.3,核心证据)**:造真漂移看 scout 报 🔴。**至少两个红线**(覆盖 §1.7 两死结):
    - **红线 A(分发链 glob覆盖)**:setup.sh 删 `cp drift-scout.md` 行(或删 freshness-scout cp 行)→ scout 判 TP-09 应报 `🔴 分发链漏改:<工件>`(逐 cp 行类)。git stash/临时改 + 还原。
    - **红线 B(逐字一致)**:review-rules 地板维表改一个维名、**不同步** workflow.js `FloorTable` → scout 判 TP-06 应报 `🔴 逐字漂移`(指明哪维不一致)。临时改 + 还原。
  - **每个任务的"验证"步给实际可跑的 grep/命令 + 期望输出**(照范本)。
- **凭证 vs 触点(本批命中清单)**:`drift-scout.md`(`.claude/agents/*.md` glob)/ `finishing-rules.md`(`docs/governance/*.md` glob)/ `setup.sh`(`setup.sh` glob)三处命中 credentials.conf → 收口须产 **audit 凭证**(对抗审查,covers 列上述三文件;非 typo,不走 exempt)。**`credentials.conf` 不改**(本机制不新增 glob:所需 glob[agents/governance/setup.sh]均已存在);**注册表 schema 不改**(scout 是消费方,"是否加结构化列"是 🟡-1 反馈交回 ③a,不在本批)。

## 待回设计清单(写作时点逐文件核真实文本的结果)

> 规则:计划不静默偏离 spec;执行中发现 spec 不可执行点,停下回设计裁决(不静默偏离)。本计划写作时点逐文件核真实文本:`freshness-scout.md`(形态范本 L1-L12)/ `touchpoint-registry.md`(13 行主表 + 维护节)/ `setup.sh`(agents 段 L41-51 逐 cp 行 + hooks/governance 循环段 L78/L103)/ `finishing-rules.md`(凭证义务核对节 step 15-18 L79-93 + 治理批适用注)/ `review-rules.md`(地板维表 L16-34)/ `review-scout.workflow.js`(`FloorTable` L26-30)/ `credentials.conf`(L30 `docs/references/DESIGN_TEMPLATE.md audit`),**未发现阻塞性不可执行点**。三条实情登记(不构成偏离,见末尾 Self-Review「需回设计阶段的偏离点」):
> - ① finishing-rules「凭证义务核对」是 **step 15-18**(L79-93),治理批适用注在 L90-93——「触点漂移检测」步接在本节末(step 18 之后,治理批适用注之前或之后均可,任务 3 给精确落点),编号续 step(不打乱既有 1-18)。
> - ② setup.sh agents 逐 cp 行止于 **L51 freshness-scout**,drift-scout cp 紧随其后(L52 位置);行号会因本改动下移,故 §4.5/§8.1 已约定"行号仅参考、按分发模式判",任务 2 不以行号当判据。
> - ③ 红线 B 的真实端点已核:review-rules.md 地板维表住 L16-34(「地板维表(三类,权威住本注)」),workflow.js `FloorTable` 住 L26-30(`design`/`code`/`governance` 三类维名)——TP-06 逐字一致判据端点真实存在,红线可造。

## 模块文档处置(新建文件是否要 README)

**结论:不建 README。** 依据(同 freshness 计划结论):harness 自仓库无 ARCHITECTURE.md 产品分层,`.claude/agents/` 各文件均无 per-目录 README(各文件自述);planning-rules「模块文档」节针对产品代码模块 README,与 harness meta 工件目录惯例不同。`drift-scout.md` 自身即其文档(子智能体契约自述)。**故本计划不创建 README。**

---

## 任务依赖与排序(契约前置 — planning-rules 硬规矩)

契约任务(`drift-scout.md` 子智能体契约)**前置**于接线任务(setup.sh 分发 / finishing-rules 接线)。理由:`drift-scout.md` 是 scout↔注册表的消费契约,setup.sh 分发它、finishing-rules 引它,都依赖契约先定。排序:

1. **任务 1【契约】** — 新建 `.claude/agents/drift-scout.md`(drift-scout 完整契约:入参 6 字段 / 出参二态 / 5 类判据→判法映射 / 三前缀解析 / 分发模型分类 / 报告分层 / 边界条件 / fork 失败降级 / 需 agent 运行时 / 只读不写;**自带 HTML 注释新鲜度标签** owner=调度者)
2. **任务 2【接线】** — `setup.sh` agents 段加一行 `cp drift-scout.md`(逐 cp 行类,L51 freshness-scout 之后;**自指——不加则 scout 跑起来逮自己漏分发 🔴**)
3. **任务 3【接线】** — `finishing-rules.md`「凭证义务核对」节加「触点漂移检测」步(门控=仅凭证批 audit 内自动跑 fork drift-scout、消费报告、手工回填现状列、降级回落人工触点维)
4. **任务 4【收口】** — 收口:全组静态核(契约一致性 + 形态核 + 分发自指核 + 接线落点核 + 守住零改核)+ **两红线测**(造真漂移看 scout 报 🔴)+ 凭证预告

> **契约任务 = 任务 1**(`drift-scout.md`)。**接线/收口任务 = 任务 2-4**(契约之后)。

---

## 任务 1:新建 .claude/agents/drift-scout.md(漂移检测子智能体契约)【契约任务 — 指令式】

> 契约任务:精确给定义(planning-rules)。本文件是 drift-scout 的**完整行为契约**——入参(registry 指针 + scope + repoRoot + today + credentialsConf + rulesPointer)、出参二态(AllAligned / DriftReport[带 drifts/unsure/alignedCount,checked 动态])、5 类判据→判法映射(逐触点读两端判)、端点三前缀解析、TP-09 分发模型分类、报告分层、边界条件、fork 失败降级、需 agent 运行时、只读不写。镜像 `freshness-scout.md` 形态(HTML 注释新鲜度标签 + 裸文本角色句 + 形态说明 blockquote,**无 YAML frontmatter tools**)。判据/取值域**派生自 spec + 注册表**,引指针不重定义注册表 schema。

**Files:**
- create: `harness/.claude/agents/drift-scout.md`

**依据:** spec §2.1(形态说明)/ §3.1(入参/出参契约 + 调用契约)/ §4.1(注册表行消费契约)/ §4.3(判据→判法映射)/ §4.4(三前缀解析)/ §4.5(分发模型分类)/ §5.1(边界条件)/ §5.2(错误传播)/ §5.3(报告分层 vs 全一致)/ §6.3(退化诚实声明)/ §7 D4(只读不写)。

- [ ] **写自带 frontmatter + 角色句**(递归闭环 — 镜像 freshness-scout.md L1-L2;本文件落 `.claude/agents/*.md`,带 HTML 注释新鲜度标签免被未来 freshness 侦察报"缺 frontmatter")。文件**第 1 行** HTML 注释标签、**第 2 行**裸文本角色句:

```markdown
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->
你是**触点漂移侦察员**(被调度者在收口·凭证批·audit 内 fork)。你在自己的上下文里读触点机读注册表,逐触点读两端点的实际内容、按该行判据判有没有"漂"(端点失配),**只把有问题的(🔴)突出报、把全对齐的(✅)折叠计数**;全 13 触点都对齐就返回一个明确的"全一致"信号,不刷主对话。
```

- [ ] **写 §形态说明**(镜像 freshness-scout.md L4-L10 blockquote):本文件是"子智能体怎么读注册表 + 怎么逐触点判漂移 + 怎么报"的说明(与 freshness-scout.md / research-scout.md / design-reviewer.md 同类),**不是带 YAML frontmatter tools 的 custom agent type**;首行 HTML 注释新鲜度标签 **≠ YAML `---` frontmatter 块**,不被 Claude Code 解析成 custom agent type;调度者读本文件后按扁平 fork 架构操作。路径前缀:`docs/...` = `harness/docs/...`、`.claude/...` = `harness/.claude/...`(自仓库视角);判据/触点数据**派生自上游**(注册表 `touchpoint-registry.md` 的判据列 + spec),改判据/触点先改注册表(或其源文件),本文件引指针不另立第二权威。

- [ ] **写 §核心边界(只读不写)**(spec §7 D4 + §1.2 场景5):你只**读**注册表 + 各端点文件 + 报告,**不写、不删、不改注册表**(防写坏机读表 `|` 格式自伤;软强度安全边界,同 freshness-scout 只读)。现状列回填(`待③b查` → `✅一致`/`🔴漂移`)由**调度者据你的报告手工做**,不是你擅自改。沿 harness 扁平 fork + 公设 1(做事/判断分开):你读端点判漂移 = 做事;🔴 修不修、怎么回填 = 判断,归调度者/用户。

- [ ] **写 §入参契约(调度者 fork 时注入)**(spec §3.1,逐字落 6 字段):

```text
入参 = {
  registryPointer:  "docs/governance/touchpoint-registry.md"  // 注册表住址(自 Read,指针不是内容)
  scope:            "all"                                       // 范围:MVP 固定 "all"(全 13 触点)
                                                              //   预留 "changed:<file>,<file>"(未来按本批 git diff 碰过的端点文件筛触点)
  repoRoot:         "<仓库根绝对/相对路径>"                      // 路径前缀解析锚(双层仓 vs 下游单层)
  today:            "YYYY-MM-DD"                                // 调度者注入(全角护栏报告用;不自取系统时钟避环境漂移)
  credentialsConf:  ".claude/hooks/credentials.conf"           // TP-09 glob 覆盖判据的凭证 glob 源(自 Read)
  rulesPointer:     "docs/governance/credentials-rules.md"     // TP-13 单源派生一致对照上游
}
```

- [ ] **写 §注册表行消费契约**(spec §4.1):把每条数据行(AI 读,非 awk 切,对散文端点宽容)理解为 `TouchpointRow { id / type / endpoints(散文) / criterion(enum) / source / status }`;跳过表头行(`| id |`)、分隔行(`|---|`)、表外散文(AI 读表自然识别);`scope='all'` 读全部 13 行,`scope='changed:...'`(预留)只读端点列命中给定文件的触点行;**status 列只读不据此判、也不回写**。

- [ ] **写 §判据→判法映射(最关键 — 逐触点读两端判 5 类,全覆盖无 ⏭️ 盲区)**(spec §4.3,逐字落表):

| 判据(enum) | 适用触点 | scout 怎么读两端判 | 三态产出 |
|---|---|---|---|
| **存在性** | TP-03 + 各行端点"文件:锚"成分 | 解析端点路径(§三前缀解析)→ Read/`test -f` 文件在不在;字面锚 → `grep -F` 查锚文本在不在 | 都在 → ✅;文件缺 → 🔴端点文件缺失:<path>;锚缺 → 🔴端点锚缺失:<文件>内未见<锚> |
| **glob覆盖** | TP-09 | 按分发模型分类(§分发模型分类):循环分发类查"通配段覆盖该 glob";逐 cp 行类查"每命中凭证 glob 的工件有 cp 行" | 都覆盖 → ✅;某工件漏分发 → 🔴分发链漏改:<工件>(指明哪类、缺什么) |
| **逐字一致** | TP-01, TP-06, TP-07 | 读懂两端散文锚指的实际内容(描述性锚 → 定位真实标题/表/常量),抽出两端可比内容(如三类维名 vs `FloorTable` 键),逐字比 | 逐字同 → ✅;有差异 → 🔴附差异指针(哪端、哪项不一致);定位不到 → ⚠️定位不准 |
| **结构等价(允许路径前缀差异)** | TP-04, TP-05, TP-08, TP-10, TP-11 | 读两端,**前缀归一**(自仓库 `harness/` 前缀 vs 下游裸路径 vs `<root>/` 视作同一)后比结构(A/B/C 三段同构 / 同核步骤齐不齐) | 结构等价 → ✅;某段/步缺失或不同构 → 🔴附差异指针;判不准 → ⚠️ |
| **单源派生一致** | TP-02, TP-12, TP-13 | 读上游权威端(credentials.conf / freshness-rules / §8)+ 派生端,判派生是否忠于上游(派生端有没有漏/改上游项;TP-13:§8 每条是否都映射到注册表唯一行) | 派生忠实 → ✅;派生漏/改上游 → 🔴附差异指针;判不准 → ⚠️ |

  - 写 **TP-13 单源派生护栏(防双向 1:1 误报)**(spec §4.3 护栏 + 注册表维护节):判据是**单向覆盖/子集 `§8 ⊆ 本表`**,不是双向逐行 1:1。§8 每条双写义务都须映射到本表唯一一行(§8 新增而本表漏登 → 🔴);但本表另有体检来源行 TP-09~12(来源=「体检YYYY-MM-DD」)无 §8 对应,**不要求计数相等**——**只查"§8 的每条都有本表行覆盖",不可反向拿本表行数 == §8 条数当判据**对 TP-09~12 误报 🔴。
  - 写 **关键澄清(对照上一版 hook 的 ⏭️)**:上一版 hook 把 `逐字一致/结构等价/单源派生一致` 全标 ⏭️需人核(bash 机械查不了散文端点);本版 scout **全判**(能读懂描述性锚、定位实际内容、前缀归一、判派生忠实)——**这是选 scout 的核心增益**。scout 判不准的**个例**(端点读不到/锚太模糊/语义没把握)→ 标 **⚠️不确定**(不是整类 ⏭️,是这一个触点没把握),并入治理审查触点完整性维人核,不静默漏。
  - 写 **退化诚实声明(过 spec_gap_masking 戒条)**(spec §4.3 + §6.3):scout 全覆盖 5 类判据 **≠ 永不判错**——可能误报 ✅(判松、漏报,最危险)/ 误报 🔴(噪音)/ 描述性锚定位错对象。本契约**不声称已根除**;降低退化靠:注册表判据列明确 + 报告带 `endpointsChecked` 留痕(可复核)+ ⚠️ 不硬判 + 终兜仍是治理审查触点完整性维人核 + meta-L4 观实战漏报率。

- [ ] **写 §出参契约(二态)**(spec §3.1,逐字落):

```text
出参 = AllAligned | DriftReport

AllAligned: { aligned: true, checked: <本次扫描的触点行数> }
            // 全一致态 = aligned:true,不依赖 checked==13:checked 是"本次扫了几行"动态计数
            //   (scope=all 时通常 13;scope=changed 时 <13;空表 checked:0 也算 aligned)
            // 无 🔴/⚠️ → 调度者据此只输出一句"触点全一致",不刷长报告

DriftReport: { aligned: false,
               drifts:   [ TouchpointVerdict(verdict='🔴'), ... ],   // 🔴 逐条突出(非空才进 DriftReport)
               unsure:   [ TouchpointVerdict(verdict='⚠️'), ... ],   // ⚠️ 逐条(读不到/判不准)
               alignedCount: <整数>,                                  // ✅ 折叠计数(不逐条)
               summary:  "<一行:N 触点 🔴 / M ⚠️ / K ✅>" }

TouchpointVerdict = {
  id:        "TP-06"                                  // 触点行标识
  criterion: "逐字一致"                                // 该行判据(enum:存在性/glob覆盖/逐字一致/结构等价/单源派生一致)
  verdict:   "✅" | "🔴" | "⚠️"                         // 三态
  detail:    "<一句话>"                                // 🔴: 差异指针(哪端点、差在哪);⚠️: 读不到/判不准原因;✅: 可空
  endpointsChecked: ["<端点路径1>", "<端点路径2>"]      // scout 实际读了哪两(几)端,留痕供调度者复核(防判松无据)
}
```

  - 写明:scout 扫完全部触点后**一次性返回**(不流式、不中途刷主对话)。

- [ ] **写 §报告分层(🔴 突出 / ✅ 折叠 / ⚠️ 逐条)**(spec §3.1 + §5.3):
  - **全一致(AllAligned)**:本次扫描触点**全 ✅ 且无任何 🔴/⚠️** → 返回 `{aligned:true, checked:<本次扫描行数>}` → 调度者只输出一句"触点全一致"(沿 freshness-scout"全干净静默"惯例,不刷长报告)。
  - **报告分层(DriftReport)**:出现任一 🔴/⚠️ → 返回 `DriftReport`:**🔴 突出逐条**(每条列 `id + criterion + detail(差异指针)+ endpointsChecked`)/ **⚠️ 逐条**(每条列 `id + detail(读不到/判不准原因)`)/ **✅ 只进 `alignedCount` 折叠计数,不逐条**(避免 13 行 ✅ 刷屏)。

- [ ] **写 §端点路径三前缀解析(操作指引)**(spec §4.4,逐字落判定顺序):注册表端点路径混三类前缀,逐端点路径走判定顺序——
  - 路径以 `<root>/` 开头 → 剥 7 字节 sentinel,挂 repoRoot 根(指 repo 根级文件 `<root>/CLAUDE.md`·`<root>/AGENTS.md`,**不**加 `harness/`)。
  - 路径以 `harness/` 开头 → 直接挂 repoRoot 根(第 3 类 `harness/templates/AGENTS.md`,已含 `harness/` 前缀,不再二次加;下游分发版去前缀)。
  - 其余裸相对路径(`docs/...`·`.claude/...`)→ 双层仓(`repoRoot/harness/` 存在)则加 `harness/` 前缀;下游单层则裸路径挂根。
  - 解析后文件**读不到** → 标 **⚠️**(不假装 🔴 端点缺失,因可能 scout 解析错前缀,留痕 `endpointsChecked` 让调度者复核);**多端点有的成有的不成** → 成的判、不成的在 detail 标"该端点解析不到"。
  - 写 **全角护栏**(沿 freshness-scout / check-context-chain 实证):读端点锚时若锚文本疑似含全角 `｜ ： ， 「 」` 且因此定位不到,在该触点 detail 附"疑似全角符号,端点锚约定半角",标 ⚠️,不静默漏。

- [ ] **写 §TP-09 分发模型分类(判分发链漏改的指引)**(spec §4.5,逐字落):判 TP-09 时对每个"命中 credentials.conf include glob 的可分发工件",先判它属哪种分发模型(**主判据 = 分发模式判断,不依赖行号**)——
  - **循环分发**(通配段覆盖整类):`.claude/hooks/*.sh`、`docs/governance/*.md`(setup.sh `for ... in ".../*.sh"|".../*.md"; do cp`)→ 按模式查"setup.sh 有覆盖该 glob 的通配 for 循环段":有 → ✅(新工件自动被通配分发);通配段被删/改 glob → 🔴。**不**因"没有逐文件 cp 行"误报 🔴(死结二)。
  - **逐 cp 行**(每文件一行):`.claude/agents/*.md`、`.claude/workflows/*`、`.claude/skills/*/*`、`docs/references/DESIGN_TEMPLATE.md`(命中凭证 glob 的工件,credentials.conf 第 30 行 `docs/references/DESIGN_TEMPLATE.md audit` — TP-09 判据**只覆盖命中凭证 glob 的工件**,故 references 段只判 DESIGN_TEMPLATE 一个,不判其余 4 个 references 文件)→ 按模式查"每个命中凭证 glob 的工件都有自己的 cp 行":某工件无 cp 行 → 🔴分发链漏改:<工件>。
  - 写 **关键自指**:`drift-scout.md` 自己落 `.claude/agents/*.md`,属**逐 cp 行类**——故 setup.sh agents 段须有 `cp .../drift-scout.md` 行(任务 2),否则 scout 判 TP-09 会逮到自己漏分发(🔴)。这是本设计的自指影响。

- [ ] **写 §边界条件**(spec §5.1,逐条落):注册表读不到 → 返回 `⚠️ 注册表读不到,漂移检测无料`(调度者软提醒+回落人工触点维)/ 注册表空表无 TP 行 → `{aligned:true, checked:0}` + note / 端点解析不到 → 该触点 ⚠️ + detail"端点解析不到:<尝试路径>" + endpointsChecked 留痕(**不直接判 🔴**,防解析错误误报)/ 端点真缺(存在性判据 + 路径明确)→ 🔴端点文件缺失:<path> / 描述性锚定位不到 → ⚠️ + detail"锚为描述性,未定位到实际内容,需人核"(**不误判 🔴**,死结一)/ 语义判断没把握(结构等价/单源派生)→ ⚠️ + detail"语义一致性 scout 判不准,需人核" / 全角符号污染端点锚 → ⚠️ + detail"疑似全角符号,端点锚约定半角" / TP-09 工件属循环分发类 → 查通配段覆盖该 glob → ✅(**不**因无逐文件 cp 行误报 🔴)/ drift-scout 自己漏分发(setup.sh agents 段无 cp drift-scout.md)→ 🔴分发链漏改:drift-scout.md(逐 cp 行类缺 cp)/ 全一致(13 触点全 ✅ 无 🔴/⚠️)→ `AllAligned` → 调度者一句"触点全一致"。

- [ ] **写 §错误传播 + fork 失败降级**(spec §5.2):
  - **单触点端点解析不到/判不准** → 该触点 ⚠️ + detail + endpointsChecked 留痕 → 收集进报告 → **不中断其余触点**(不吞错:解析/判不准也作"问题"上报)。
  - **单触点真漂移** → 该触点 🔴 + 差异指针 → 收集进 `drifts[]` → 调度者读 🔴 决定修/登记。
  - **fork 失败(超时/上下文溢出/工具不可用)** → 调度者捕获 → 软提醒"本会话漂移检测未执行(fork 失败)" → **回落人工触点完整性维,不阻断收口、不算欠账**(软强度)。

- [ ] **写 §需 agent 运行时(诚实降级)**(spec §1.3 + §5.1):本检测须 fork 子智能体(需 agent 运行时,纯人工跑不了);**无 agent 运行时则跳过 drift-scout**,同样回落人工触点完整性维(诚实降级,同 freshness);对账三命令仍纯人工可跑、不受影响。

- [ ] **写 §触发起源 + 设计依据**(镜像 freshness-scout.md L89-91):本能力 2026-06-16 加入,知识系统 Step2 ③b。门控 = 收口·凭证批·audit 内自动跑(机械触点漂移预检,不依赖审查者是否选触点完整性维;人工触点完整性维保持 review-rules 条件必选作互补深审)。依据见 spec `docs/superpowers/specs/2026-06-16-drift-detection-design.md`。判据/触点数据单源权威住 `docs/governance/touchpoint-registry.md`。

- [ ] **验证**(契约一致性静态核):
  - 自带 frontmatter 核(递归闭环):`grep -nE "^<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->" harness/.claude/agents/drift-scout.md` → 期望:**命中第 1 行**
  - 非 custom agent 形态核:`grep -nE "^---$" harness/.claude/agents/drift-scout.md` → 期望:**无输出**(无 YAML `---` 块,不被解析成 custom agent)
  - 入参 6 字段核:`grep -noE "registryPointer|scope|repoRoot|today|credentialsConf|rulesPointer" harness/.claude/agents/drift-scout.md | sort -u` → 期望:六字段各命中
  - 出参二态核:`grep -nE "AllAligned|DriftReport|aligned: true|alignedCount|TouchpointVerdict" harness/.claude/agents/drift-scout.md` → 期望:AllAligned + DriftReport + alignedCount + TouchpointVerdict 命中
  - 5 类判据 enum 核(单源一致 = 注册表判据列):`grep -noE "存在性|glob覆盖|逐字一致|结构等价|单源派生一致" harness/.claude/agents/drift-scout.md | sort -u` → 期望:五类各命中
  - 三态符号核:`grep -noE "✅|🔴|⚠️" harness/.claude/agents/drift-scout.md | sort -u` → 期望:三态各命中
  - 三前缀解析核:`grep -nE "<root>/|harness/ 开头|裸相对|前缀归一" harness/.claude/agents/drift-scout.md` → 期望:三类前缀 + 解析顺序命中
  - 分发模型分类核:`grep -nE "循环分发|逐 cp 行|分发链漏改" harness/.claude/agents/drift-scout.md` → 期望:两模型 + 漏改判命中
  - 自指核:`grep -nE "drift-scout.md.*逐 cp 行|setup.sh.*cp.*drift-scout|逮到自己漏分发" harness/.claude/agents/drift-scout.md` → 期望:自指影响命中
  - TP-13 护栏核:`grep -nE "§8 ⊆ 本表|子集|不要求计数相等|TP-09~12" harness/.claude/agents/drift-scout.md` → 期望:单向子集护栏命中
  - 只读不写核:`grep -nE "只读不写|不写.*不改注册表|手工回填|手工做" harness/.claude/agents/drift-scout.md` → 期望:只读边界命中
  - fork 失败降级核:`grep -nE "fork 失败|不阻断|回落人工触点|需 agent 运行时" harness/.claude/agents/drift-scout.md` → 期望:降级 + 需 agent 运行时命中
  - 退化诚实声明核(过 spec_gap_masking):`grep -nE "判松|不声称.*根除|endpointsChecked.*留痕|meta-L4" harness/.claude/agents/drift-scout.md` → 期望:诚实声明命中
  - 全角护栏核:`grep -nE "全角|端点锚约定半角" harness/.claude/agents/drift-scout.md` → 期望:命中
- [ ] commit:`feat: drift-detection - 新建 drift-scout.md(触点漂移侦察子智能体契约)`

---

## 任务 2:setup.sh agents 段加一行 cp drift-scout.md(逐 cp 行类,自指分发)【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):`setup.sh` agents 逐 cp 行区 = L41-51(evaluator/designer/design-reviewer/security-reviewer/process-auditor/research-scout/review-scout/freshness-scout 各一行 cp),止于 **L51 freshness-scout**。本任务在 freshness-scout cp 行之后**加一行** drift-scout cp(逐 cp 行类,§4.5/§8.1)。

**Files:**
- modify: `harness/setup.sh`(agents 逐 cp 行区,L51 freshness-scout 之后)

**问题:** `drift-scout.md` 落 `.claude/agents/*.md`,属**逐 cp 行**分发模型(agents 段是逐文件 cp,不是循环)——必须显式加一行 cp,否则:① 下游拿不到 drift-scout 没法跑;② **scout 自查 TP-09 会逮到自己漏分发(🔴)**(死结二自指落点,§4.5/§8.1)。

**约束(精确落点 + 内容):**
- **落点**:在 `cp "$SCRIPT_DIR/.claude/agents/freshness-scout.md" ...`(L51)之后、`# .claude/workflows ...`(L53)之前,加一行(形如 freshness-scout 那行):

```bash
cp "$SCRIPT_DIR/.claude/agents/drift-scout.md" "$TARGET_DIR/.claude/agents/"
```

- **最小变更**:只追加一行 drift-scout cp,**不动**其余 agents cp 行(evaluator~freshness-scout 8 行)+ 不动 research-scout 那段注释(L46-48)+ 不动 hooks/governance 循环段(L78/L103)+ 不动其余分发段(spec §8.2 守住)。
- **行号会下移**:加 cp 后 workflows/skills/hooks 段行号下移,但 §4.5/§8.1 已约定"行号仅参考、按分发模式判",不影响 scout 判据。

**验证标准:**
- drift-scout cp 行存在核:`grep -nF 'cp "$SCRIPT_DIR/.claude/agents/drift-scout.md" "$TARGET_DIR/.claude/agents/"' harness/setup.sh` → 期望:命中一行
- 落在 agents 逐 cp 段内核(紧随 freshness-scout):`grep -nE 'agents/(freshness-scout|drift-scout)\.md"' harness/setup.sh` → 期望:freshness-scout 行 + drift-scout 行相邻有序(drift-scout 在 freshness-scout 之后)
- 既有 agents cp 行未动核(守住):`grep -cE 'cp "\$SCRIPT_DIR/\.claude/agents/.*\.md"' harness/setup.sh` → 期望:**9 行**(原 8 行 evaluator~freshness-scout + 新增 drift-scout 1 行)
- hooks/governance 循环段未动核(守住):`grep -nE 'for hook in|for gov in' harness/setup.sh` → 期望:两循环段原行仍在(L78 附近 hooks / L103 附近 governance,未被碰)
- agents 落点正确核(不在 workflows/skills 段):`grep -nF "drift-scout.md" harness/setup.sh` → 期望:命中行的目标是 `$TARGET_DIR/.claude/agents/`(非 workflows/skills)
- [ ] commit:`feat: drift-detection - setup.sh agents 段加 cp drift-scout.md(逐 cp 行类自指分发)`

---

## 任务 3:finishing-rules.md 凭证义务核对节加「触点漂移检测」步【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):`finishing-rules.md`「凭证义务核对(改动命中 credentials.conf 时)」节 = **step 15-18**(L79-93),节末 L90-93 是「治理批收口工序适用」注。本任务在本节末(step 18 之后)**新增「触点漂移检测」一步**,门控 = 仅凭证批 audit 内自动跑 fork drift-scout。**不动既有 step 15-18 原文 + 不动既有 §安全扫描/方向评估/流程审计/分流步**(spec §10.1 守住)。

**Files:**
- modify: `harness/docs/governance/finishing-rules.md`(「凭证义务核对」节,step 18 + 治理批适用注之后)

**问题:** drift-scout 是触点完整性的**机械预检**——收口·凭证批·audit 内自动跑一遍"碰过的触点有没有漂"。它绑在「凭证批」(本批命中 credentials.conf 即在 audit 内自动跑),**不**绑在"审查者有没有选触点完整性维"上(关掉"凭证批∧未选维→无人查"缝隙;§4.2 注)。须接进收口工序,否则没人 fork 它。软、不阻断;非凭证批不 fork;无 agent / fork 失败回落人工触点维。

**约束(精确落点 + 内容):**
- **落点**:在「凭证义务核对」节末——step 18 + 治理批适用注(L90-93)**之后**,新增一个子节「### 触点漂移检测(凭证批 audit 内机械预检)」。续既有编号(step 18 之后用 step 19,或作子节列表项;以子节标题 + bullet 形式落,与本节「治理批收口工序适用」注同款 markdown 风格)。**不打乱既有 step 1-18 编号、不动既有 step 15-18 原文**。
- **新「触点漂移检测」子节内容**(软、门控仅凭证批、引 drift-scout + 注册表指针):

```markdown
### 触点漂移检测(凭证批 audit 内机械预检)

> 仅当**本批命中 `credentials.conf`(收口须产 audit)**时执行——在该凭证批的 audit 内,drift-scout 作触点完整性的**机械预检自动跑**(不依赖审查者是否选了「触点完整性维」;人工触点完整性维保持 review-rules 条件必选作互补深审,机械预检 + 人工深审双层,不互斥)。**非凭证批 → 不 fork**(注册表 13 触点端点多落 governance/config 凭证-hit 文件,非凭证批罕碰触点端点,真漏由人工触点维终兜)。门控理由详 spec `docs/superpowers/specs/2026-06-16-drift-detection-design.md` §4.2 注。

19. **需 agent 运行时** → 调度者 fork `drift-scout`(契约 `.claude/agents/drift-scout.md`),注入 `{registryPointer: docs/governance/touchpoint-registry.md, scope: all, repoRoot, today, credentialsConf, rulesPointer}` → scout 读注册表、逐触点读两端点、按判据判 → 返回报告(每触点 ✅一致 / 🔴漂移[附差异指针] / ⚠️不确定;报告分层:🔴 突出逐条 / ✅ 折叠计数)。
20. 消费报告:**🔴** 当场修或登记;**⚠️** 并入治理审查触点完整性维人核;据报告**手工回填**注册表现状列(`待③b查` → `✅一致`/`🔴漂移`;scout 只读不写,回填由调度者手工 — spec §7 D4)。
21. **软、不阻断**:**无 agent 运行时 / fork 失败** → 软提醒"本会话漂移检测未执行" + **回落人工触点完整性维**(治理审查那个维本就在查),不阻断收口、不算欠账(诚实降级,同 freshness-scout)。
```

  - **门控四处统一**(spec §4.2 注):门控判据 = 仅"本批命中 credentials.conf",凭证批 audit 内自动跑,**不依赖选维**——与 spec §1.2 P0 场景1 / §3.1 调用契约 / §8.1 接线同口径。
  - **最小变更**:只在本节末追加子节,不动 step 15-18 + 不动「治理批收口工序适用」注 + 不动 §安全扫描/方向评估/流程审计/分流。

**验证标准:**
- 触点漂移检测步存在核:`grep -nE "触点漂移检测|drift-scout|touchpoint-registry" harness/docs/governance/finishing-rules.md` → 期望:子节标题 + drift-scout fork + 注册表指针命中
- 门控仅凭证批核:`grep -nE "凭证批|命中 credentials.conf|非凭证批.*不 fork|不依赖.*选.*维" harness/docs/governance/finishing-rules.md` → 期望:门控 = 凭证批 + 不依赖选维命中
- 软不阻断 + 降级核:`grep -nE "软.*不阻断|回落人工触点|无 agent 运行时|fork 失败.*软提醒|不算欠账" harness/docs/governance/finishing-rules.md` → 期望:软 + 降级 + 不算欠账命中
- 只读不写手工回填核:`grep -nE "手工回填|只读不写|scout 只读" harness/docs/governance/finishing-rules.md` → 期望:命中
- 既有 step 15-18 未动核(守住):`grep -nE "^15\. 对照|^16\. 凭证义务的履行|^17\. verdict 处置|^18\. fork 失败降级" harness/docs/governance/finishing-rules.md` → 期望:step 15-18 原行仍在(凭证义务核对原工序未被碰)
- 治理批适用注未动核(守住):`grep -nF "方向评估 = 全批适用,含治理批" harness/docs/governance/finishing-rules.md` → 期望:原注仍在
- 既有分流/方向评估步未动核(守住):`grep -nF "运行 evaluate" harness/docs/governance/finishing-rules.md` 且 `grep -nF "milestone commit" harness/docs/governance/finishing-rules.md` → 期望:既有方向评估 + 分流原文仍在
- [ ] commit:`feat: drift-detection - finishing-rules 凭证义务核对节加触点漂移检测步(门控仅凭证批,软不阻断)`

---

## 任务 4:收口 — 全组静态核 + 两红线测 + 守住零改核 + 凭证预告【收口任务 — 指令式(收口验证)】

> 收口验证任务:不改产物,跑全组静态核命令确认契约一致 + 形态正确 + 分发自指 + 接线落点 + 守住零改,**跑两红线测**(造真漂移看 scout 报 🔴 — spec §6.1 核心证据)+ 凭证预告。**在 harness 仓库根执行**(`D:\个人\harness`)。

**Files:** 无改动(纯验证)。

**操作(逐条跑命令,记录实际输出对照期望):**

- [ ] **C1 结构兜底(全仓 diff,终结打地鼠)**:`git diff --stat`
  - 判据:改动集**只应出现** spec §8.1 列文件 + 新建文件:新建 `.claude/agents/drift-scout.md` + 改 `setup.sh`(加 1 行 cp)+ 改 `docs/governance/finishing-rules.md`(加触点漂移检测步)。
  - **守住文件**(注册表 `touchpoint-registry.md` / 现有 6 个 `check-*` hook / 对账三命令 / credentials.conf / 既有 scout 契约 / setup.sh 其余段)出现任何非预期 diff = **违守住,回退**。

- [ ] **C2 契约一致性核(drift-scout.md 各节 + 取值域)**:
  - 入参 6 字段:`grep -noE "registryPointer|scope|repoRoot|today|credentialsConf|rulesPointer" harness/.claude/agents/drift-scout.md | sort -u` → 期望:六字段齐
  - 出参二态:`grep -nE "AllAligned|DriftReport|alignedCount|TouchpointVerdict|endpointsChecked" harness/.claude/agents/drift-scout.md` → 期望:二态 + TouchpointVerdict + endpointsChecked 齐
  - 5 类判据 enum(单源 = 注册表判据列):`grep -noE "存在性|glob覆盖|逐字一致|结构等价|单源派生一致" harness/.claude/agents/drift-scout.md | sort -u` 与 `grep -noE "存在性|glob覆盖|逐字一致|结构等价|单源派生一致" harness/docs/governance/touchpoint-registry.md | sort -u` → 期望:**两输出相同**(五类齐,scout↔注册表单源一致)
  - 三态符号:`grep -noE "✅|🔴|⚠️" harness/.claude/agents/drift-scout.md | sort -u` → 期望:三态齐

- [ ] **C3 形态核(HTML 注释 ≠ YAML frontmatter)**:
  - `grep -nE "^---$" harness/.claude/agents/drift-scout.md` → 期望:**无输出**(无 YAML `---` 块,不被解析成 custom agent type)
  - `sed -n '1p' harness/.claude/agents/drift-scout.md | grep -E "<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->"` → 期望:首行自带 HTML 注释新鲜度标签命中(递归闭环,镜像 freshness-scout.md L1)

- [ ] **C4 分发自指核(setup.sh 已加 drift-scout cp)**:
  - `grep -nF 'cp "$SCRIPT_DIR/.claude/agents/drift-scout.md"' harness/setup.sh` → 期望:命中(否则 scout 跑起来自查 TP-09 报 🔴)
  - `grep -cE 'cp "\$SCRIPT_DIR/\.claude/agents/.*\.md"' harness/setup.sh` → 期望:**9 行**(原 8 + drift-scout)

- [ ] **C5 接线落点核(finishing-rules 触点漂移检测步)**:
  - `grep -nE "### 触点漂移检测|drift-scout" harness/docs/governance/finishing-rules.md` → 期望:子节 + drift-scout fork 命中
  - 门控仅凭证批:`grep -nE "凭证批|不依赖.*选.*维|非凭证批.*不 fork" harness/docs/governance/finishing-rules.md` → 期望:门控命中
  - 软不阻断:`grep -nE "软.*不阻断|回落人工触点|不算欠账" harness/docs/governance/finishing-rules.md` → 期望:命中

- [ ] **C6 守住零改核(逐条)**:
  - 注册表 13 行 + 判据 enum 未动:`git diff harness/docs/governance/touchpoint-registry.md` → 期望:**空**(scout 只读,不碰注册表)
  - 现有 6 个 `check-*` hook 未动:`git status --short harness/.claude/hooks/` → 期望:无 `check-*.sh` 改动
  - credentials.conf 未动:`git diff harness/.claude/hooks/credentials.conf` → 期望:**空**(本机制不新增 glob)
  - 既有 scout 契约未动:`git status --short harness/.claude/agents/freshness-scout.md harness/.claude/agents/review-scout.md harness/.claude/agents/research-scout.md` → 期望:无改动
  - 对账三命令未动:`git diff harness/.claude/hooks/check-handoff.sh harness/.claude/hooks/check-shelf-registry.sh harness/.claude/hooks/check-audit-coverage.sh` → 期望:**空**
  - setup.sh 循环段 + 其余 cp 未动:`git diff harness/setup.sh | grep -E "^-"` → 期望:**无删除行**(只 +1 行 drift-scout cp,无删改)

- [ ] **C7 红线测 A(分发链 glob覆盖 — TP-09)**:造真漂移,验 scout 真报 🔴(覆盖死结二判据)。
  - 造漂移:临时从 setup.sh 删 `cp .../drift-scout.md`(或 `cp .../freshness-scout.md`)行(`git stash` 备份或手工删后记位)。
  - fork drift-scout(`scope: all`)→ **期望**:报告 `DriftReport` 含 `TouchpointVerdict(id=TP-09, criterion=glob覆盖, verdict=🔴, detail≈"分发链漏改:drift-scout.md(或 freshness-scout.md),逐 cp 行类缺 cp")`。
  - **还原**:`git checkout harness/setup.sh`(或 `git stash pop`)→ 确认 setup.sh 复原(`grep -cE 'cp "\$SCRIPT_DIR/\.claude/agents/.*\.md"' harness/setup.sh` 回到 9 行)。
  - **判据**:scout 必须报这一条 🔴(不是"跑了不报错"就算过 — spec §6.2)。

- [ ] **C8 红线测 B(逐字一致 — TP-06)**:造真漂移,验 scout 真报逐字漂移(覆盖死结一判据)。
  - 造漂移:临时改 `review-rules.md` 地板维表(L16-34「地板维表(三类)」)的一个 code 维名(如 `spec忠实性` → `spec-fidelity`),**不同步** `review-scout.workflow.js` `FloorTable.code`(L28)。
  - fork drift-scout(`scope: all`)→ **期望**:报告 `DriftReport` 含 `TouchpointVerdict(id=TP-06, criterion=逐字一致, verdict=🔴, detail≈"review-rules 地板维表 code 维名 与 workflow.js FloorTable.code 不一致:<哪维>")`。
  - **还原**:`git checkout harness/docs/governance/review-rules.md` → 确认复原。
  - **判据**:scout 必须报这一条 🔴,且 detail 指明哪维不一致(验 scout 能读懂描述性锚 + 定位真实那张表 — 死结一,§4.4)。

- [ ] **C9 死结不误报核(可选补强,验 scout 不满屏误报)**:
  - 干净仓库(无造漂移)fork drift-scout → **期望**:循环分发类(TP-09 的 hooks/governance)**不**因"没有逐文件 cp 行"误报 🔴(查通配段 → ✅);描述性锚(TP-06「设计行地板维表注」)定位到 review-rules 真实那张表(不因 `grep`=0 误判端点缺失)。多数触点 ✅、个别难判 ⚠️,无虚假 🔴。

- [ ] **凭证预告(写进 handoff / 交收口):**
  - 本改动命中 credentials.conf 的文件:`.claude/agents/drift-scout.md`(新建,`.claude/agents/*.md` glob)/ `docs/governance/finishing-rules.md`(`docs/governance/*.md` glob)/ `setup.sh`(`setup.sh` glob)。**三处均命中** → 收口须产 **audit 凭证**(对抗审查)。
  - **`credentials.conf` 不改**:所需 glob(agents / governance / setup.sh)均已存在 → 无新 glob,无 conf↔§2 双写改动。
  - **注册表 schema 不改**:scout 是消费方;"是否加结构化抽取/分发模型列"是 🟡-1 反馈交回 ③a,**另一批**改动(届时单独 audit 覆盖 `touchpoint-registry.md`),不并入本批。
  - **finishing 须产 audit 凭证**(对抗审查):本改动新建 scout 契约 + 改收口工序 + 改分发脚本 → 走 review-rules 治理行,**触点完整性维优先选用**(本批新增机制契约 + 跨文件接线;且 drift-scout 自身就是触点完整性预检,审它合宜)。audit covers 列:`.claude/agents/drift-scout.md` + `docs/governance/finishing-rules.md` + `setup.sh`(spec §8.3)。非 typo,**不走 exempt**。
  - **守住自核**:audit 须确认注册表 13 行 + 判据 enum / 现有 6 个 `check-*` hook / 对账三命令 / credentials.conf / 既有 scout 契约 收口 git diff = 空(spec §10.1)。
  - 无 commit(纯验证);验证结果(含两红线测实际输出)记入 handoff 收口段。

---

## Self-Review(spec 覆盖 §8.1 / 占位符扫 / 类型一致)

### spec 覆盖核(§8.1 改动集 ↔ 任务)

| spec §8.1 改动 | 计划任务 | 覆盖 |
|---|---|---|
| **新建** `.claude/agents/drift-scout.md`(说明型子智能体契约,自带 HTML 注释标签) | 任务 1 | ✅ |
| `setup.sh` agents 逐 cp 段加一行 `cp drift-scout.md`(自指分发) | 任务 2 | ✅ |
| `docs/governance/finishing-rules.md` 凭证义务核对节新增「触点漂移检测」步(门控仅凭证批,软不阻断) | 任务 3 | ✅ |
| 收口验证(契约一致 / 形态 / 分发自指 / 接线落点 / 守住零改 / 两红线测) | 任务 4 | ✅ |
| 注册表 schema 不改(🟡-1 交回 ③a) | 全任务守住 + 任务 4 凭证预告 | ✅(不在本批) |

| spec 契约(§3 接口 / §4 数据) | 计划任务 | 覆盖 |
|---|---|---|
| §3.1 fork 入参 6 字段(registryPointer/scope/repoRoot/today/credentialsConf/rulesPointer) | 任务 1(§入参契约)+ 任务 3(收口注入) | ✅ |
| §3.1 出参二态(AllAligned/DriftReport + TouchpointVerdict 字段 + endpointsChecked) | 任务 1(§出参契约) | ✅ |
| §3.1/§5.3 报告分层(🔴 突出 / ✅ 折叠 / ⚠️ 逐条) | 任务 1(§报告分层) | ✅ |
| §4.1 注册表行消费契约(6 列 / 跳表头分隔行 / status 只读) | 任务 1(§注册表行消费契约) | ✅ |
| §4.3 判据→判法映射(5 类全覆盖 + TP-13 子集护栏) | 任务 1(§判据→判法映射) | ✅ |
| §4.4 端点三前缀解析(`<root>/` / `harness/` / 裸相对 + 解析顺序 + 全角护栏) | 任务 1(§端点路径三前缀解析) | ✅ |
| §4.5 TP-09 分发模型分类(循环分发 vs 逐 cp 行 + 自指) | 任务 1(§TP-09 分发模型分类)+ 任务 2(自指落点) | ✅ |
| §7 D4 只读不写(回填调度者手工) | 任务 1(§核心边界)+ 任务 3(手工回填) | ✅ |

| spec 核心场景(§1.2) | 计划任务 | 覆盖 |
|---|---|---|
| P0 场景1(凭证批 audit 内 fork 逐触点判漂移) | 任务 1(全契约)+ 任务 3(门控接线) | ✅ |
| P0 场景2(报告分层不刷屏) | 任务 1(§报告分层 / AllAligned) | ✅ |
| P0 场景3(覆盖全 5 类判据,无 ⏭️ 盲区) | 任务 1(§判据→判法映射) | ✅ |
| P1 场景4(fork 失败 / 无 agent 降级) | 任务 1(§fork 失败降级 + §需 agent 运行时)+ 任务 3(回落人工维) | ✅ |
| P1 场景5(只读不写,回填手工) | 任务 1(§核心边界)+ 任务 3(手工回填) | ✅ |

| spec 测试场景(§6.1) | 计划验证步 | 覆盖 |
|---|---|---|
| 红线·分发链(setup.sh 删 cp → 🔴 TP-09) | 任务 4 C7 | ✅ |
| 红线·逐字(review-rules 维名改不同步 workflow.js → 🔴 TP-06) | 任务 4 C8 | ✅ |
| 死结二·不误报(循环分发类不误报 🔴) | 任务 4 C9 | ✅ |
| 死结一·描述性锚定位 | 任务 4 C8/C9 | ✅ |
| 全一致 → AllAligned | 任务 4 C9 | ✅ |
| 形态正确(HTML 注释非 YAML) | 任务 4 C3 | ✅ |
| 分发自指(setup.sh 加 cp 否则 scout 自报 🔴) | 任务 2 + 任务 4 C4/C7 | ✅ |
| 凭证义务(三文件命中 → audit covers) | 任务 4 凭证预告 | ✅ |

### 占位符扫

- 新建文件 `drift-scout.md` 全节内容(入参/出参/判据映射/三前缀/分发模型/边界/降级)**给实际可照抄文本 + 表格**(任务 1,逐字落 spec §3.1/§4.1/§4.3/§4.4/§4.5/§5)。
- 接线两处(setup.sh cp 行 / finishing-rules 触点漂移检测子节)**给实际可照抄 bash/markdown 块 + before→after 落点**(任务 2/3)。
- 两红线测**给实际造漂移命令 + 期望 🔴 输出 + 还原命令**(任务 4 C7/C8)。
- **无 `[待填]`/`[TODO]`/`<占位>`/"类似任务 N"/"加适当处理" 类未定义占位符**。入参/出参块内 `<仓库根绝对/相对路径>`/`<本次扫描的触点行数>`/`<端点路径1>`/`<一句话>` 是契约字段格式占位(= spec §3.1 写法,契约形态非计划缺口)。

### 类型一致核(出参契约 / 判据 enum / 路径解析在各任务一致)

- **入参 6 字段** `registryPointer` / `scope` / `repoRoot` / `today` / `credentialsConf` / `rulesPointer` — 任务 1(§入参契约)↔ 任务 3(收口注入)↔ 任务 4 C2(核)同名同义,= spec §3.1。
- **出参二态** `AllAligned`(aligned/checked)/ `DriftReport`(aligned/drifts/unsure/alignedCount/summary)+ `TouchpointVerdict`(id/criterion/verdict/detail/endpointsChecked)— 任务 1(§出参契约)↔ 任务 4 C2(核)逐字一致,= spec §3.1。
- **5 类判据 enum** `存在性` / `glob覆盖` / `逐字一致` / `结构等价` / `单源派生一致` — 任务 1(§判据→判法映射)↔ 任务 4 C2(scout↔注册表单源核)逐字一致,= spec §4.3 + 注册表判据列。
- **三态符号** `✅` / `🔴` / `⚠️` — 任务 1(出参 + 判法映射 + 报告分层)↔ 任务 4 C2/C7/C8 一致,= spec 全文。
- **三前缀解析** `<root>/`(剥 sentinel 挂根)/ `harness/`(已含前缀直挂根)/ 裸相对(双层加 `harness/`)— 任务 1(§端点路径三前缀解析)= spec §4.4 解析判定顺序,与注册表端点真实三类写法(TP-03/TP-05/TP-08/TP-10 含三类)对齐。
- **TP-09 分发模型** `循环分发`(通配段)/ `逐 cp 行`(每文件一行)+ drift-scout.md 属逐 cp 行类自指 — 任务 1(§TP-09 分发模型分类)↔ 任务 2(setup.sh 加 cp)↔ 任务 4 C4/C7 一致,= spec §4.5/§8.1。
- **门控判据** = 仅"本批命中 credentials.conf"(凭证批 audit 内自动跑,不依赖选维)— 任务 3(finishing-rules 接线)↔ 任务 4 C5 一致,= spec §1.2 P0 场景1 / §3.1 调用契约 / §4.2 注 / §8.1 四处统一口径。

### 需回设计阶段的偏离点

**无。** 计划全程对齐 spec §1-§10 + 守住段 + 不做清单 + D1-D5,逐文件基于真实文本(`freshness-scout.md` L1-L92 形态范本 / `touchpoint-registry.md` 13 行主表 + 维护节 / `setup.sh` agents 段 L41-51 + 循环段 L78/L103 / `finishing-rules.md` 凭证义务核对 step 15-18 L79-93 / `review-rules.md` 地板维表 L16-34 / `review-scout.workflow.js` `FloorTable` L26-30 / `credentials.conf` L30),未发现需偏离设计文档之处。

> **spec 不可执行点回报(给上抛参考,非偏离)**:无阻塞点。三条实情登记(已在任务内处理,不需回设计):
> - ① finishing-rules「凭证义务核对」是 **step 15-18**(非"附近"模糊行号)——任务 3 给精确落点(本节末、step 18 + 治理批适用注之后,续 step 19-21),与 spec §8.1「在凭证义务核对节附近新增一步」一致,非偏离。
> - ② setup.sh agents 逐 cp 行止于 **L51 freshness-scout**——任务 2 给精确落点(L51 之后加一行),行号下移已由 spec §4.5/§8.1「行号仅参考、按分发模式判」消解,非偏离。
> - ③ 红线 B 端点真实存在(review-rules.md L16-34 地板维表 ↔ workflow.js L26-30 `FloorTable`)——TP-06 逐字判据可造红线,非偏离。

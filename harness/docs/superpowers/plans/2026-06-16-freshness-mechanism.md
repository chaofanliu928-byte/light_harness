# 反腐烂 / 新鲜度机制(freshness)实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. 每个任务一个 commit(C 风格频繁提交)。

**Goal:** 给会腐的"活文档"加保质期标签(frontmatter)+ 会话开场 fork 一个**新鲜度侦察子智能体**扫活文档、只回有问题的、全干净静默 + 复核动作 = 推 `last-reviewed` 到今天。**软**机制(报告/提醒,不阻断、不自动修复)。改动物 = 新建 2 个 markdown(governance 规则 `freshness-rules.md` + agent 契约 `freshness-scout.md`)+ 核心集回填 frontmatter + 入口规程接线(根 CLAUDE 第 3 步 + AGENTS×2 新鲜度侦察节 + harness/CLAUDE #11 指针)+ credentials §8 新增拷贝组登记。

**Architecture:** ADD 一条新鲜度侦察路并排于既有「装载/对账」两步;**不替换**对账三命令、**不嵌入**手工校验段。依赖方向 = 单向 fork + 读契约:开场接线 → fork `freshness-scout` 子智能体 → 子智能体读 `freshness-rules.md` 契约 → 扫核心集 frontmatter,无环(spec §2.2)。新鲜度第 3 步与对账第 2 步**并列**(时序对账在前),互不依赖、互不调用。子智能体 = 说明型 agent(镜像 `research-scout.md` / `design-reviewer.md` 形态,真实同位 `.claude/agents/`,**非带 YAML frontmatter tools 的 custom agent type**)。新鲜度标签 = **HTML 注释** `<!-- owner...; last-reviewed...; 生命周期... -->`(≠ YAML `---` custom-agent,无解析冲突)。

**Tech Stack:** markdown 纯文件治理约定(无运行时代码、无 API、无 DB)+ 一个 fork 子智能体的**行为契约**(自然语言 prompt + 判据)+ bash/grep(静态核验证)+ git(每任务一 commit)。**无 bash hook**(开场用子智能体,非第四个 hook);**无可跑的 pytest**。

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-16-freshness-mechanism-design.md`(505 行,已过自检 + design-review 两轮修订,已锁;§1.5 决策表 D-1~D-9 / §2 模块 / §3 接口 / §4 数据 / §5 边界 / §6 测试 / §7 决策 / §8 影响[§8.1 改动表]/ §9 自洽 / 守住段 / 不做清单)
**同类计划范本(结构/粒度/验证写法仿它):** `harness/docs/superpowers/plans/2026-06-15-code-review-scout.md`(同为 harness meta 改动、非 pytest)
**frontmatter 数据契约范本:** `harness/docs/preferences.md` L2(`<!-- owner: 用户; last-reviewed: 2026-06-11; 生命周期: evolving -->`,逐字同形)
**agent 文件形态范本:** `harness/.claude/agents/research-scout.md`(L1 裸文本 + L2-L3 形态说明,无 YAML frontmatter tools)

---

## 适配说明(本功能是文档为主的 harness meta 改动,不是代码+pytest)

- **无 bash hook**:用户定开场用**子智能体**(非第四个 hook)。"扫描逻辑"住 `freshness-scout.md` 的契约(prompt/判据),开场由调度者 fork 它。本批改动物 = 新建 2 个 markdown + 核心集回填 frontmatter + 入口规程接线 + credentials §8 拷贝组登记。**没有可跑的 pytest**。
- **"验证" = 静态核**(照范本 + spec §6):
  - (a) **接线三处同核一致**(结构/语义等价,**非 literal diff**):根 CLAUDE 第 3 步 ↔ 根 AGENTS 新鲜度侦察节 ↔ templates AGENTS 新鲜度侦察节 同核步骤齐全,仅允许路径前缀差异(`harness/` 有无)+ 根 AGENTS 多一条凭证义务 bullet 是合法差异,逐字 `diff` 恒不为空,故核「同核步骤是否齐全 + 差异是否仅限路径前缀/凭证 bullet」。
  - (b) **落点正确性**:新鲜度步是 AGENTS「开场新鲜度侦察(需 agent 运行时)」**另起一节**,**不在**「手工校验(纯人工)」段内;根 CLAUDE 是会话开场规程**第 3 步**(与「1.装载/2.对账」平级)。
  - (c) **frontmatter 格式核**:回填的 frontmatter 与 preferences L2 逐字同形(半角 `:` `;`,日期半角 `YYYY-MM-DD`)。
  - (d) **单源一致核**:scope 白名单(scout)↔ 范围清单(freshness-rules)↔ kind 取值域 三处单源一致;routeTo 三值 / owner 二分 / kind 三类取值域在两份新文件一致。
  - (e) **递归闭环核**:两份新建文件**自带 frontmatter**(owner=调度者、生命周期 evolving),不自报"缺 frontmatter"。
  - (f) **守住核**(零改):对账三命令 / credentials §8 既有第 5 条对账拷贝组 / references 过时横幅 / audit 失效判定(credentials §5)/ preferences 既有 frontmatter 格式 **零改**。
  - **每个任务的"验证"步给实际可跑的 grep/命令 + 期望输出**(照范本)。
- **凭证 vs 触点**:凭证命中 = `freshness-rules.md`(governance glob `docs/governance/*.md`)/ `credentials-rules.md`(同 governance glob)/ 回填的 governance/*.md(同 glob)/ `freshness-scout.md`(`.claude/agents/*.md` glob)/ 根 `CLAUDE.md`(`CLAUDE.md` glob,covers 写 `<root>/CLAUDE.md`)/ `harness/CLAUDE.md`(`CLAUDE.md` glob)/ 根 `AGENTS.md`(`AGENTS.md` glob,covers 写 `<root>/AGENTS.md`)/ `templates/AGENTS.md`(`AGENTS.md` + `templates/*.md` glob)/ `docs/RUBRIC.md`(`docs/RUBRIC.md` glob)。**`docs/ARCHITECTURE.md` 不命中任何凭证 glob**(credentials.conf 无 ARCHITECTURE 行,已核实 — spec §8.2 凭证缺口注)→ 回填它**无强制 audit 义务**,自愿连带进同批 governance audit covers。**`credentials.conf` 不改**(本机制不新增 glob;所需 glob 均已存在,§8.1 行)。

## 待回设计清单(写作时点逐文件核真实文本的结果)

> 规则:计划不静默偏离 spec;执行中发现 spec 不可执行点,停下回设计裁决(不静默偏离)。本计划写作时点逐文件核真实文本(preferences.md L2 / 根 AGENTS.md / templates/AGENTS.md / 根 CLAUDE.md 开场规程 / harness/CLAUDE.md #11 / credentials-rules.md §8 / 10 份 governance/*.md / ARCHITECTURE.md / RUBRIC.md / research-scout.md / design-reviewer.md),**未发现阻塞性不可执行点**。两条实情登记(不构成偏离,见末尾 Self-Review「需回设计阶段的偏离点」):① harness/CLAUDE.md 核心规则 **#11 现文 = "会话开场先装载再对账…跑 AGENTS.md「手工校验」命令"**(无第 3 步指针),任务 8 给精确补法;② templates/AGENTS.md 用户偏好格未住 preferences.md(下游个人层),与回填核心集无关,不动。

## 模块文档处置(两份新建文件是否要 README)

**结论:不建 README。** 依据(同范本结论):harness 自仓库无 ARCHITECTURE.md 产品分层,`.claude/agents/` 与 `docs/governance/` 各文件均无 per-目录 README(各文件自述);planning-rules「模块文档」节针对产品代码模块 README,与 harness meta 工件目录惯例不同。两份新文件自身即其文档(`freshness-rules.md` = 规矩权威住址;`freshness-scout.md` = 子智能体契约自述)。**故本计划不创建 README。**

---

## 任务依赖与排序(契约前置 — planning-rules 硬规矩)

契约任务(三份契约:freshness-rules.md / freshness-scout.md / frontmatter 数据契约)**前置**于接线/回填任务。frontmatter 数据契约(HTML 注释格式)= preferences L2 逐字同形,作为任务 1 的子节给定(不另起任务,因它是单行格式约定,且任务 1 的 freshness-rules.md 就是它的权威住址)。排序:

1. **任务 1【契约】** — 新建 `freshness-rules.md`(单一权威住址:frontmatter 三字段语义+取值域 / 范围清单 / owner 二分+routeTo 三值映射[单源权威] / N=90 初值 / 复核动作 / §6/§8 边界声明;**含 frontmatter 数据契约子节**;**自带 frontmatter**)
2. **任务 2【契约】** — 新建 `.claude/agents/freshness-scout.md`(子智能体侦察契约:入参 / 扫描判据 / 出参二态 / 展示粒度 / fork 失败降级 / 需 agent 运行时;**自带 frontmatter**)
3. **任务 3【回填】** — 核心集回填 frontmatter(10 份 governance/*.md + ARCHITECTURE.md + RUBRIC.md;preferences.md 已有,不动)
4. **任务 4【接线】** — 根 `CLAUDE.md` 会话开场规程**新增第 3 步「开场新鲜度侦察(需 agent 运行时)」**
5. **任务 5【接线】** — 根 `AGENTS.md` + `templates/AGENTS.md` 各**另起「开场新鲜度侦察(需 agent 运行时)」节**(与「手工校验」节并列分开,三处同核)
6. **任务 6【接线】** — `harness/CLAUDE.md` 核心规则 #11 补半句指针指向「开场新鲜度侦察」节
7. **任务 7【接线】** — `credentials-rules.md` §8 新增一条拷贝组「新鲜度开场步三处同改」(独立于既有第 5 条对账拷贝组)
8. **任务 8【收口】** — 收口:跑全组触点完整性命令(三处同核等价核 + 落点核 + frontmatter 格式核 + 单源一致核 + 递归闭环核 + 守住零改核)+ 凭证预告

> **契约任务 = 任务 1 / 任务 2**(三份契约中的 freshness-rules + freshness-scout;第三份「frontmatter 数据契约」作为任务 1 的子节给定)。**接线/回填任务 = 任务 3-7**(契约之后)。

---

## 任务 1:新建 docs/governance/freshness-rules.md(新鲜度机制单一权威住址)【契约任务 — 指令式】

> 契约任务:精确给定义(planning-rules)。本文件是新鲜度机制的**单一权威住址**——frontmatter 三字段语义+取值域、范围清单(核心集/增量/不纳入)、owner 二分+routeTo 三值映射(单源权威)、N=90 初值、复核动作、§6/§8 边界声明、字段→kind 映射(单源)。`freshness-scout.md`(任务 2)+ 接线(任务 4-5)引本文件指针,不各自重定义。

**Files:**
- create: `harness/docs/governance/freshness-rules.md`

**依据:** spec §1.3 / §1.5 决策表 D-1~D-9 / §4.1(frontmatter 三字段)/ §4.2(范围清单)/ §4.3(owner→routeTo 映射)/ §4.4 / §7 决策表 / §8.1(§6/§8 边界声明)/ 守住段。

- [ ] **写自带 frontmatter**(递归闭环 — spec §4.2 + §8.1:本文件落核心集 governance 范围,本轮即标,免首次开场子智能体把自家规矩报"缺 frontmatter")。文件第 1 行标题、第 2 行 frontmatter(与 preferences L2 同形):

```markdown
# 反腐烂 / 新鲜度机制(freshness)规则
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->
```

- [ ] **写 §定位**:本文件 = 新鲜度机制的单一权威住址(约定/范围/owner/阈值/子智能体契约/复核动作)。软机制:报告/提醒,不阻断、不自动修复。开场由调度者 fork `freshness-scout` 子智能体执行(需 agent 运行时,无则跳过)。

- [ ] **写 §frontmatter 数据契约(= 第三份契约,HTML 注释格式)**——逐字同 preferences.md L2,放文档标题下一行:

```markdown
<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving|immutable -->
```

  三字段语义 + 取值域 + 必填 + 缺失判法(spec §4.1 表,逐字落):

| 字段 | 语义 | 取值域 | 必填 | 缺失时怎么判 |
|---|---|---|---|---|
| `owner` | 谁有权确认"这份还准" | `用户` \| `调度者` | ✅ | 缺 = **孤儿**(kind="孤儿") |
| `last-reviewed` | 上次有人确认还准的日期 | `YYYY-MM-DD`(半角连字符) | ✅(evolving 类) | 缺或不可解析 = **时间腐**(kind="时间腐") |
| `生命周期` | 这份会不会演进 | `evolving` \| `immutable` | ✅ | 缺 → 默认按 `evolving` 处理(保守纳入时间腐) |

  - 写明:HTML 注释形式渲染不可见、对正文零干扰;放文档标题(`# …`)的**下一行**(同 preferences L2)。
  - 写明:**HTML 注释标签 ≠ YAML `---` custom-agent frontmatter,无解析冲突**——`.claude/agents/*.md`(含 freshness-scout.md)带此 HTML 注释新鲜度标签**不破坏**「非 custom agent type」约定(spec §1.3 + §4.1)。
  - 写明 `immutable` 语义:**不参与时间腐检查**(本就不该更新),但**仍查 owner**(孤儿检查)。

- [ ] **写 §字段→kind 映射(单源权威住此)**(spec §4.1 注):
  - 缺 `owner` → **孤儿**
  - `last-reviewed` 缺或 `today − last-reviewed > N` → **时间腐**(边界 `== N` 仍新鲜,`> N` 才报)
  - 核心集成员无标签 → **缺 frontmatter**
  - 写明:此映射的**单一权威住址 = 本文件**;`freshness-scout.md` / spec 各处对它的重述均"派生自 freshness-rules",改判据先改本文件。

- [ ] **写 §范围清单(哪些是活文档)**(spec §4.2 表,逐字落)。判据 = **范围清单(路径白名单 + frontmatter 存在性),不靠"有没有 frontmatter"反推**:

| 类别 | 路径 | 纳入方式 | 缺 frontmatter 时 |
|---|---|---|---|
| 治理规则 | `docs/governance/*.md` | **核心集**(本轮回填) | 报"缺 frontmatter"(核心集必须有) |
| 架构 | `docs/ARCHITECTURE.md` | **核心集**(本轮回填) | 同上 |
| 方向盘 | `docs/RUBRIC.md` | **核心集**(本轮回填,**owner=用户**) | 同上 |
| 偏好 | `docs/preferences.md` | **核心集**(已有,沿用) | —(已有) |
| 模块 README | `**/README.md` | **增量采纳** | 标"缺 frontmatter"(温和,不算硬欠账) |
| 标准件 | `docs/references/` 内**无日期前缀** | **增量采纳** | 标"缺 frontmatter"(增量长) |
| agent/skill 契约 | `.claude/agents/*.md` + `.claude/skills/*/*.md` | **增量采纳**(本轮不批量回填) | 标"缺 frontmatter"(折叠一行,owner=调度者) |

  **明确不纳入**(子智能体跳过):`docs/references/` **带日期前缀**留痕件(用过时横幅)/ `docs/audits/`(audit 失效判定 credentials §5 管)/ `docs/decisions/`(append-only 不腐)/ `docs/active/handoff.md`(每会话覆写)/ `docs/ROADMAP.md` + `docs/PROGRESS.md`(台账不腐)。
  - 写**路径前缀约定**(双层仓,scout 据此解析,spec 头注):`docs/...` = `harness/docs/...`;`.claude/...` = `harness/.claude/...`;根级 `/CLAUDE.md`·`/AGENTS.md` = 仓库根两份;分发下游去 `harness/` 前缀。
  - 写**核心集 vs 增量处理差异**:核心集缺 frontmatter = "该有却没有"真问题(报出来催补);增量缺 = 温和提示(顺手补、自然长,不算欠账)。

- [ ] **写 §owner 二分 + routeTo 三值映射(单源权威住此)**(spec §4.3 表,逐字落):

| owner | routeTo(三值之一) | 谁动手 |
|---|---|---|
| `用户` | `报给用户拍` | 用户确认还准/拍要不要改;**AI 不自证**(方向级只有用户能自证) |
| `调度者` | `调度者自己复核` | AI 自己复核内容是否还准;真要改走凭证义务(governance 改动 → audit) |
| `未知`(孤儿/缺 frontmatter) | `报给用户拍 owner 归属` | 默认升给用户决定该文档归谁 |

  - 写明 routeTo 三值 = `报给用户拍` / `调度者自己复核` / `报给用户拍 owner 归属`(取值域与 freshness-scout 出参逐字一致)。
  - 写 **owner 词诚实说明**(spec §4.1):`调度者` owner ≈ **无专人、AI 日常维护 + 机制兜底**(对齐 CLAUDE.md「防遗忘靠机制不靠纪律」);本质是二分「谁有权确认还准」——`用户`(方向级)vs `调度者`(执行级);"调度者"是临时角色名,非"有个叫调度者的专人"。
  - 写 **`调度者` owner 自评加固**(spec §4.1,对齐公设 1):推日期 = 软自评可独走;**改内容**(改正文/改规矩)须走对抗审查(governance 改动 → audit)。防"AI 自己说还准就算数"的乐观偏差闭环。

- [ ] **写 §阈值 N = 90(初值)**(spec D-5 + §7):一季度没回头看就提醒。**90 非实证最优**,首批实战观察(误报率/漏报率/刷屏感)后标定,像 review-scout/research-scout「阈值不写死、实战调」。不把"季度=自然复核节奏"当成立依据(避便利论证)。

- [ ] **写 §复核动作 = 推日期**(spec §1.2 场景 3 + D-6):owner 确认还准(或顺手修了)→ `last-reviewed` 推到今天;**收口时若本批动过某活文档,顺手把它的 `last-reviewed` 推到今天**(复核搭收口便车,不另起独立动作)。

- [ ] **写 §6/§8 边界声明**(spec §8.1 边界表态,显式写出):
  - credentials-rules **§6(开场对账规程权威)仅管对账三命令**;新鲜度开场步权威住本文件,**不写入 §6 正文**。
  - credentials-rules **§8 既有对账拷贝组(第 5 条)保持锚对账三命令不变**;新鲜度只在 §8 新增独立一条(任务 7)。
  - 即:freshness 既不进 §6 正文、也不进 §8 既有对账拷贝组。

- [ ] **写 §不做清单**(spec 守 MVP):不做漂移检测(留 ★ 设计层子项)/ 不做硬阻断 / 不做自动修复 / 不一次性回填全仓 / 不重复管 immutable 留痕件(过时横幅)/ 不重复管 audit 漂移(credentials §5)。

- [ ] **验证**(契约一致性静态核):
  - 自带 frontmatter 核:`grep -nE "^<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->" harness/docs/governance/freshness-rules.md` → 期望:**命中第 2 行**(递归闭环)
  - frontmatter 数据契约逐字核:`grep -nF "<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving|immutable -->" harness/docs/governance/freshness-rules.md` → 期望:命中(= preferences L2 同形)
  - routeTo 三值核:`grep -noE "报给用户拍 owner 归属|调度者自己复核|报给用户拍" harness/docs/governance/freshness-rules.md` → 期望:三值各命中
  - owner 二分核:`grep -nE "用户.*调度者|调度者.*用户" harness/docs/governance/freshness-rules.md` → 期望:命中二分
  - kind 三类核:`grep -noE "孤儿|时间腐|缺 frontmatter" harness/docs/governance/freshness-rules.md` → 期望:三类各命中
  - N=90 核:`grep -nE "90|初值|实战" harness/docs/governance/freshness-rules.md` → 期望:90 初值 + 实战标定命中
  - §6/§8 边界核:`grep -nE "§6|§8|对账三命令|对账拷贝组" harness/docs/governance/freshness-rules.md` → 期望:边界声明命中
- [ ] commit:`feat: freshness - 新建 freshness-rules.md(新鲜度机制单一权威住址 + frontmatter 数据契约)`

---

## 任务 2:新建 .claude/agents/freshness-scout.md(新鲜度侦察子智能体契约)【契约任务 — 指令式】

> 契约任务:子智能体侦察契约——入参 `scopeList`/`today`/`N`、扫描判据(孤儿/时间腐/缺 frontmatter)、出参二态(clean / problems[] 带 file/kind/owner/detail/routeTo)、展示粒度(核心集逐条/增量汇总)、fork 失败降级、需 agent 运行时。镜像 `research-scout.md` / `design-reviewer.md` 形态(L1 裸文本 + 形态说明 + 路径前缀,**无 YAML frontmatter tools**)。判据/范围/取值域**派生自 `freshness-rules.md`**(任务 1,权威上游),引指针不重定义。

**Files:**
- create: `harness/.claude/agents/freshness-scout.md`

**依据:** spec §3.1(入参/出参契约)/ §4.2(扫描白名单)/ §4.3(数据流)/ §5.1(边界条件)/ §5.2(错误传播)/ §7 S-2(展示粒度)/ 决策表「子智能体住址=说明型」。

- [ ] **写自带 frontmatter**(递归闭环 — spec §4.2:本文件落 `.claude/agents/*.md` 增量范围,本轮自带标签,故虽在扫描范围内但**不自报**"缺 frontmatter")。第 1 行裸文本角色句、frontmatter 作为标签放角色句之后(本文件无 `# 标题` 行,镜像 research-scout.md 形态 L1 即裸文本)。处置:文件**开头加一行 HTML 注释新鲜度标签**:

```markdown
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->
你是**新鲜度侦察员**(被调度者在会话开场 fork)。你在自己的上下文里扫一遍"活文档"的 frontmatter,算出三类问题,**只把有问题的报回去**;全干净就返回一个明确的"全干净"信号,不刷主对话。
```

  - 注:HTML 注释标签放文件首行(渲染不可见,不破坏裸文本角色句)。

- [ ] **写形态说明**(镜像 research-scout.md L3-L5):本文件是"子智能体怎么找活文档 + 怎么算问题 + 怎么报"的说明(与 research-scout.md / design-reviewer.md 同类),**不是带 YAML frontmatter tools 的 custom agent type**;调度者读本文件后按扁平 fork 架构操作。路径前缀:`docs/...` = `harness/docs/...`、`.claude/...` = `harness/.claude/...`(自仓库视角)。

- [ ] **写 §核心边界(只读不写)**(spec §1.3 安全要求):子智能体只**读** frontmatter + 报告,**不写、不删、不自动改文档**(软强度安全边界);唯一"改"动作(推 `last-reviewed`)由 owner 复核后触发,不是子智能体擅自改。

- [ ] **写 §入参契约**(spec §3.1 forkFreshnessScout 入参):

```text
入参 = {
  today:        "YYYY-MM-DD"   // 当天日期(调度者注入, 据此算超期, 不自取系统时钟避免环境漂移)
  scopeList:    核心集 + 增量 glob   // 范围清单(权威定义在 freshness-rules.md, 本处引指针)
  N:            90              // 时间腐阈值(天); 默认 90, 由 freshness-rules.md 定
  rulesPointer: "docs/governance/freshness-rules.md"  // 读完整契约的指针
}
```

- [ ] **写 §扫描判据(派生自 freshness-rules.md)**(spec §4.3):逐文件读 frontmatter →
  - **孤儿**:缺 `owner` 字段;
  - **时间腐**:`last-reviewed` 缺或不可解析,或 `today − last-reviewed > N`(`== N` 仍新鲜);
  - **缺 frontmatter**:核心集成员无 `<!-- owner... -->` 行。
  - 判"是不是活文档" = **靠范围清单白名单(freshness-rules §范围清单)+ frontmatter 存在性,不靠"有没有 frontmatter"反推**(否则核心集缺标签永远扫不到)。范围外文件直接跳过、不报(spec §5.2 防误报)。

- [ ] **写 §出参契约(二态)**(spec §3.1 FreshnessReport):

```text
出参 = CleanSignal | ProblemList

CleanSignal:  { clean: true }   // 全干净 → 调度者据此不向用户输出任何新鲜度内容(静默)

ProblemList:  { clean: false,
                problems: [ FreshnessProblem, ... ],   // 核心集问题逐条(空数组等价 clean, 不允许)
                incrementalNote: "<一行汇总>" | null }   // 增量类"缺 frontmatter"折叠一行; 无则 null

FreshnessProblem = {
  file:    "<仓库相对路径>"
  kind:    "孤儿" | "时间腐" | "缺 frontmatter"     // 派生自 freshness-rules 字段→kind 映射
  owner:   "用户" | "调度者" | "未知"               // 孤儿/缺 frontmatter 时可能"未知"
  detail:  "<一句话>"                               // 如 "last-reviewed 2026-03-01, 已 107 天"
  routeTo: "报给用户拍" | "调度者自己复核" | "报给用户拍 owner 归属"  // 三值, 由 owner 推(freshness-rules §owner→routeTo)
}
```

  - 写明:scout 扫完核心集后**一次性返回**(不流式、不中途刷主对话)。

- [ ] **写 §展示粒度**(spec §7 S-2 + §3.1):
  - **核心集问题** → `problems[]` **逐条报**(每条带 owner+routeTo 可分流)。
  - **增量类"缺 frontmatter"**(模块 README / 标准件 / agent·skill 契约)→ 默认**不逐条进 problems[]**,**折叠成 `incrementalNote` 一行**(如 "N 份增量文档可采纳 frontmatter"),语气温和、**不刷紧迫感**。
  - detail 区分语气:核心集缺 frontmatter = "本轮应回填"(催补);增量缺 = "可增量采纳"(温和)。

- [ ] **写 §边界条件**(spec §5.1,逐条落):
  - 核心集缺 frontmatter → `kind="缺 frontmatter"`, owner="未知", routeTo="报给用户拍 owner 归属", detail 注"核心集成员本轮应回填"。
  - 增量缺 frontmatter → 折叠 `incrementalNote`(不逐条、不刷紧迫感)。
  - 缺 owner(有其他字段)→ `kind="孤儿"`, routeTo="报给用户拍 owner 归属"。
  - `last-reviewed` 不可解析(全角连字符/乱填/缺)→ `kind="时间腐"`, 当"过期"处理(保守);**全角符号特别提示**(check-context-chain 教训:中文 IME 默认全角,机读静默漏)→ detail 注"疑似全角连字符,frontmatter 日期须半角 YYYY-MM-DD"。
  - `last-reviewed` 在未来 → 不报时间腐;detail 可附"日期疑似填错(在未来)"温和提示,不升级(软强度)。
  - `生命周期: immutable` → **跳过时间腐检查**(只查孤儿)。
  - `生命周期` 取值非法 → 默认按 evolving 处理,detail 附"生命周期取值非法: <原值>"。
  - 全干净 / 范围清单为空(极早期空仓)→ 返回 `{clean:true}`,不报错。
  - 边界 `today − last-reviewed == 90` → **仍新鲜**(`> N` 才报;满 90 当天不催,第 91 天催)。

- [ ] **写 §错误传播 + fork 失败降级**(spec §5.2):
  - **单文件 frontmatter 损坏/不可解析** → 捕获、不崩整体 → 降级为一条 problem(detail 注解析失败原因)→ 继续扫其余 → 汇总回报(**不吞错**:解析失败也作为"问题"上报)。
  - **fork 失败(超时/上下文溢出/工具不可用)** → 调度者捕获 → 软提醒"本会话新鲜度侦察未执行(fork 失败),下会话重试" → **不阻断会话、不挡收口**(软强度:fork 失败不是欠账)。

- [ ] **写 §需 agent 运行时(诚实降级)**(spec §1.3):本侦察须 fork 子智能体(需 agent 运行时,纯人工跑不了);**无 agent 运行时则跳过新鲜度侦察**(同 hook 降级——丢自动触发,不丢可校验性);对账三命令仍纯人工可跑、不受影响。

- [ ] **验证**(契约一致性静态核):
  - 自带 frontmatter 核(递归闭环):`grep -nE "^<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->" harness/.claude/agents/freshness-scout.md` → 期望:**命中第 1 行**
  - 非 custom agent 形态核:`grep -nE "^---$" harness/.claude/agents/freshness-scout.md` → 期望:**无输出**(无 YAML frontmatter `---` 块,不被解析成 custom agent)
  - 入参三项核:`grep -nE "today|scopeList|N|rulesPointer" harness/.claude/agents/freshness-scout.md` → 期望:四项命中
  - 出参二态核:`grep -nE "clean: true|problems|incrementalNote" harness/.claude/agents/freshness-scout.md` → 期望:CleanSignal + problems[] + incrementalNote 命中
  - kind 取值域核(单源一致):`grep -noE "孤儿|时间腐|缺 frontmatter" harness/.claude/agents/freshness-scout.md` → 期望:三类各命中(= freshness-rules 字段→kind 映射)
  - routeTo 三值核(单源一致):`grep -noE "报给用户拍 owner 归属|调度者自己复核|报给用户拍" harness/.claude/agents/freshness-scout.md` → 期望:三值各命中(= freshness-rules §owner→routeTo)
  - fork 失败降级核:`grep -nE "fork 失败|不阻断|跳过.*侦察|需 agent 运行时" harness/.claude/agents/freshness-scout.md` → 期望:降级 + 需 agent 运行时命中
  - 全角教训核:`grep -nE "全角|半角 YYYY-MM-DD" harness/.claude/agents/freshness-scout.md` → 期望:命中
- [ ] commit:`feat: freshness - 新建 freshness-scout.md(新鲜度侦察子智能体契约)`

---

## 任务 3:核心集回填 frontmatter(governance/*.md + ARCHITECTURE + RUBRIC)【回填任务 — 问题式】

> 回填任务(契约之后)。现状(真实文本,已核):10 份 `docs/governance/*.md` **L2 均无 frontmatter**;`docs/ARCHITECTURE.md` / `docs/RUBRIC.md` **L2 为空(无 frontmatter)**;`docs/preferences.md` **L2 已有 frontmatter,沿用不动**。本任务给核心集回填保质期标签,与 preferences L2 逐字同形。

**Files:**
- modify: `harness/docs/governance/brainstorming-rules.md` · `design-rules.md` · `planning-rules.md` · `implementation-rules.md` · `testing-rules.md` · `review-rules.md` · `finishing-rules.md` · `synthesis-rules.md` · `credentials-rules.md` · `model-route.md`(10 份;**`freshness-rules.md` 任务 1 已自带,不重复**)
- modify: `harness/docs/ARCHITECTURE.md`
- modify: `harness/docs/RUBRIC.md`
- **不动**:`harness/docs/preferences.md`(L2 已有 frontmatter,沿用 — spec 守住段)

**问题:** 核心集是"该有 frontmatter"的活文档,本轮回填后子智能体不再把它们报成"缺 frontmatter"。每份在**标题(`# …`)的下一行**插入 HTML 注释新鲜度标签,格式 = preferences L2 同形。

**约束(精确落点 + owner 取值):**
- **格式**:`<!-- owner: <owner>; last-reviewed: 2026-06-16; 生命周期: evolving -->`(半角 `:` `;`,日期半角连字符;放标题下一行;`last-reviewed` = 回填当天 2026-06-16)。
- **owner 取值**(spec D-3 + §4.2 范围清单):
  - 10 份 `governance/*.md` → **owner: 调度者**(AI 日常维护的治理规则)。
  - `ARCHITECTURE.md` → **owner: 调度者**(AI 日常维护的架构)。
  - `RUBRIC.md` → **owner: 用户**(方向级只有用户能自证还准 — spec §4.2 RUBRIC 行特标 owner=用户)。
- **生命周期**:全部 `evolving`(均会演进;无 immutable 核心集成员)。
- **最小变更**:**只插入 frontmatter 一行,不动各文件正文**(spec §2.1 自检「核心集只加 frontmatter 行、不动正文」)。每份文件标题行格式不一(有的 `# 凭证与对账规则(credentials)`、有的 `# Writing-plans 阶段治理规则`),插在各自真实标题行的下一行。
- **不回填**:`docs/references/` 标准件 / 模块 README / `.claude/agents`·`skills` 契约(**增量采纳**,本轮不批量回填 — spec §1.3 不做 + §4.2);`ARCHITECTURE.md` 回填**无强制 audit 义务**(不在凭证 glob,spec §8.2),但本轮连带回填、自愿进同批 audit covers。

**验证标准:**
- governance 全回填核:`for f in harness/docs/governance/*.md; do printf "%s: " "$f"; sed -n '2p' "$f" | grep -oE "owner: (调度者|用户)" || echo MISSING; done` → 期望:**11 份全部命中**(10 份本任务回填 owner: 调度者 + freshness-rules.md 任务 1 自带 owner: 调度者),**无 MISSING**
- RUBRIC owner=用户核:`sed -n '2p' harness/docs/RUBRIC.md | grep -oE "owner: 用户"` → 期望:`owner: 用户`(方向级 — spec §4.2)
- ARCHITECTURE 回填核:`sed -n '2p' harness/docs/ARCHITECTURE.md | grep -oE "owner: 调度者"` → 期望:`owner: 调度者`
- 格式同形核(半角 + 三字段):`grep -rhoE "<!-- owner: [^;]+; last-reviewed: [0-9]{4}-[0-9]{2}-[0-9]{2}; 生命周期: evolving -->" harness/docs/governance/ harness/docs/ARCHITECTURE.md harness/docs/RUBRIC.md | sort -u` → 期望:全部匹配此半角格式(= preferences L2 同形),无全角漏网
- preferences 未动核(守住):`sed -n '2p' harness/docs/preferences.md` → 期望:`<!-- owner: 用户; last-reviewed: 2026-06-11; 生命周期: evolving -->`(原行,日期仍 2026-06-11 未被改)
- 正文未动核:`git diff --stat harness/docs/governance/ harness/docs/ARCHITECTURE.md harness/docs/RUBRIC.md` → 期望:每份文件只 +1 行(frontmatter),无正文删改
- [ ] commit:`feat: freshness - 核心集回填 frontmatter(governance ×10 + ARCHITECTURE + RUBRIC)`

---

## 任务 4:根 CLAUDE.md 会话开场规程新增第 3 步「开场新鲜度侦察(需 agent 运行时)」【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):根 `CLAUDE.md`「会话开场规程」L68-77 = **2 个编号步**(1.装载 L70 / 2.对账 L71-75,对账下挂三条子命令);L77 = 依据行。无新鲜度步。本任务**新增第 3 步**(与装载/对账平级;**不**叫"第 4 步"——对账下挂三命令是子命令非平级步)。

**Files:**
- modify: `D:\个人\harness\CLAUDE.md`(根治理入口;会话开场规程段 L68-77)

**问题:** 会话开场第 1 步装载 + 第 2 步对账(三命令)走完后,第 3 步 fork `freshness-scout` 扫活文档、只报问题、全干净静默。软、不阻断;需 agent 运行时,无则跳过。

**约束(精确落点 + 内容):**
- **落点**:在 L75(对账「欠账处置」子项末)之后、L77(`依据:` 行)之前,插入新的编号步「3. 开场新鲜度侦察(需 agent 运行时)」。**不动** 1.装载 / 2.对账 两步原文与三命令(spec 守住段)。
- **新第 3 步内容**(软、平级、引 freshness-rules 指针;**三处同核拷贝组成员之一** — 与根 AGENTS / templates AGENTS 新鲜度侦察节同核):

```markdown
3. **开场新鲜度侦察(需 agent 运行时;软,不阻断)**:第 1 步装载 + 第 2 步对账走完后,fork 一个 `freshness-scout` 子智能体扫活文档 frontmatter(范围/判据/owner 二分权威住 `harness/docs/governance/freshness-rules.md`),**只回有问题的、全干净静默**:
   - 入参 `{today: 当天日期, scopeList: 核心集+增量, N: 90}`;子智能体算三类问题(孤儿/时间腐/缺 frontmatter),按 owner 二分回 routeTo(`用户` owner → 报给用户拍 / `调度者` owner → AI 自己复核)。
   - **全干净 → 不向用户输出任何新鲜度内容**(静默,不刷屏)。
   - 复核确认还准(或顺手修了)→ 把该文档 `last-reviewed` 推到今天;收口时本批动过的活文档顺手推。
   - **诚实降级**:无 agent 运行时(纯人工)则**跳过**本步(对账三命令不受影响,仍纯人工可跑);fork 失败 → 软提醒"本会话新鲜度未扫",不阻断、不挡收口。
```

  - 与对账区别(写进或引 freshness-rules):对账三命令是机械 bash hook 查凭证/台账文法(只读账本);新鲜度要读文档内容做判断,故用子智能体(spec §1.2 机制定位)。

**验证标准:**
- 第 3 步存在核:`grep -nE "开场新鲜度侦察|freshness-scout|freshness-rules" "D:\个人\harness\CLAUDE.md"` → 期望:第 3 步 + scout fork + rules 指针命中
- 落点正确核(在对账之后、依据之前):`grep -nE "1\. \*\*装载|2\. \*\*对账|3\. \*\*开场新鲜度侦察" "D:\个人\harness\CLAUDE.md"` → 期望:**三步有序**(1/2/3),新鲜度是第 3 步
- 软不阻断 + 静默核:`grep -nE "全干净.*静默|静默.*全干净|不阻断|需 agent 运行时|跳过" "D:\个人\harness\CLAUDE.md"` → 期望:静默 + 软 + 降级命中
- 对账三命令未动核(守住):`grep -nF "check-handoff.sh --reconcile" "D:\个人\harness\CLAUDE.md"` 且 `grep -nF "check-shelf-registry.sh" "D:\个人\harness\CLAUDE.md"` 且 `grep -nF "check-audit-coverage.sh --reconcile" "D:\个人\harness\CLAUDE.md"` → 期望:三命令原行仍在
- [ ] commit:`feat: freshness - 根 CLAUDE 会话开场规程新增第 3 步开场新鲜度侦察`

---

## 任务 5:根 AGENTS.md + templates/AGENTS.md 各另起「开场新鲜度侦察(需 agent 运行时)」节【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):根 `AGENTS.md` L40-46 = 「## 手工校验(无 hook 运行时 / 纯人工)」节(三命令 + 注);`templates/AGENTS.md` L38-44 = 同款「## 手工校验」节。本任务在两份各**另起一节「## 开场新鲜度侦察(需 agent 运行时)」**——**与「手工校验」节并列但分开,不嵌入手工校验段**(理由:手工校验节是「纯人工可跑的 bash」,新鲜度是 fork 子智能体需 agent 运行时,语义不同宿)。**三处同核**(根 CLAUDE 第 3 步 ↔ 根 AGENTS 本节 ↔ templates AGENTS 本节)。

**Files:**
- modify: `D:\个人\harness\AGENTS.md`(根入口地图;在「## 手工校验」节 L40-46 之后另起新节)
- modify: `harness/templates/AGENTS.md`(M4 分发模板;在「## 手工校验」节 L38-44 之后另起新节)

**问题:** AGENTS.md 是运行时中立的 agent 第 0 步地图。开场新鲜度侦察(需 agent 运行时)须在此登记,但**不能塞进「手工校验(纯人工)」段**(会自相矛盾:纯人工跑不了 fork)。两份各另起一节,结构/语义等价、同批改,仅路径前缀差(`harness/` 有无)+ 根版多一条凭证义务 bullet 为合法差异。

**约束(精确落点 + 内容):**
- **落点**:在两份各自「## 手工校验」节末(注行之后)新起一节,**不碰「手工校验」三命令原文与该节**(spec 守住段)。
- **根 `AGENTS.md` 新节内容**(带 `harness/` 前缀 + 一条凭证义务 bullet):

```markdown
## 开场新鲜度侦察(需 agent 运行时)

- 开场对账(步 2)之后,fork 一个 `freshness-scout` 子智能体扫活文档 frontmatter,**只回有问题的、全干净静默**(软,不阻断)。
- 范围清单 / 三类问题判据(孤儿 / 时间腐 / 缺 frontmatter)/ owner 二分(用户·调度者)+ routeTo:权威住 harness/docs/governance/freshness-rules.md;子智能体契约住 harness/.claude/agents/freshness-scout.md。
- 复核确认还准 → 把该文档 last-reviewed 推到今天(收口时本批动过的顺手推)。
- 凭证义务:freshness-rules.md 落 governance glob;改动须 audit(详 harness/docs/governance/credentials-rules.md)。

(需 agent 运行时;无 agent 运行时则跳过本步——同 hook 降级,丢自动触发不丢可校验性;对账三命令不受影响)
```

- **`templates/AGENTS.md` 新节内容**(下游视角,**去 `harness/` 前缀**,**无凭证义务 bullet** — 下游个人层不套凭证;其余同核步骤齐全):

```markdown
## 开场新鲜度侦察(需 agent 运行时)

- 开场对账(步 2)之后,fork 一个 `freshness-scout` 子智能体扫活文档 frontmatter,**只回有问题的、全干净静默**(软,不阻断)。
- 范围清单 / 三类问题判据(孤儿 / 时间腐 / 缺 frontmatter)/ owner 二分(用户·调度者)+ routeTo:权威住 docs/governance/freshness-rules.md;子智能体契约住 .claude/agents/freshness-scout.md。
- 复核确认还准 → 把该文档 last-reviewed 推到今天(收口时本批动过的顺手推)。

(需 agent 运行时;无 agent 运行时则跳过本步——同 hook 降级,丢自动触发不丢可校验性;对账三命令不受影响)
```

  - **合法差异**:根版带 `harness/` 前缀 + 多一条「凭证义务」bullet;templates 版去前缀 + 无凭证 bullet。这是与既有 AGENTS×2 双写(九格表/手工校验)同款的合法前缀差异(根 CLAUDE.md L65 双写说明)。
  - **三处同核**:本节步骤须与根 CLAUDE 第 3 步(任务 4)同核——fork scout / 三类问题 / owner 二分 / 全干净静默 / 推日期 / 需 agent 运行时降级,六要素齐全。

**验证标准:**
- 两份新节存在核:`grep -nE "## 开场新鲜度侦察" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md` → 期望:**各 1 处**(两份各另起一节)
- 不嵌入手工校验核(另起节):`grep -nE "## 手工校验|## 开场新鲜度侦察" "D:\个人\harness\AGENTS.md"` → 期望:两节**并列分开**(手工校验节在前、新鲜度节在后,各自 `##` 标题)
- 手工校验三命令未动核(守住):`grep -nF "check-handoff.sh --reconcile" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md` → 期望:两份各命中(三命令原文未被碰)
- 三处同核要素齐全核:`grep -nE "freshness-scout|全干净静默|owner 二分|last-reviewed 推到今天|需 agent 运行时" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md` → 期望:两份各命中六要素子集
- 路径前缀差异合法核:`grep -nF "harness/docs/governance/freshness-rules.md" "D:\个人\harness\AGENTS.md"`(根版带前缀)+ `grep -nF "docs/governance/freshness-rules.md" harness/templates/AGENTS.md`(下游去前缀)→ 期望:各命中(前缀差异符合预期)
- 凭证 bullet 仅根版核:`grep -nE "凭证义务.*freshness-rules" "D:\个人\harness\AGENTS.md"` → 命中;`grep -nE "凭证义务" harness/templates/AGENTS.md` → 期望:**新鲜度节内无**(下游不套凭证;若 templates 它处既有凭证字样属原文,只核新节内无)
- [ ] commit:`feat: freshness - AGENTS×2 另起开场新鲜度侦察节(三处同核, 不嵌入手工校验段)`

---

## 任务 6:harness/CLAUDE.md 核心规则 #11 补半句指针指向「开场新鲜度侦察」节【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):`harness/CLAUDE.md` 核心规则 **#11 = 「会话开场先装载再对账:读 docs/active/handoff.md(台账)→ 跑 AGENTS.md「手工校验」命令核上次收口凭证;欠账先补再开新工作(会话链自执法)」**(指针指向 AGENTS「手工校验」,无新鲜度步指针)。本任务 **#11 补半句指针**指向「开场新鲜度侦察」节(spec §8.1:定死,不留"按需";只做指针、不复述散文)。

**Files:**
- modify: `harness/CLAUDE.md`(M4 分发模板;核心规则 #11)

**问题:** 新鲜度步在 AGENTS 另起节(任务 5)而非塞进手工校验,故 #11 须补半句指针指向「开场新鲜度侦察」节,保持指针完整性(下游跳 AGENTS 自见新鲜度节)。**裁断而非搁置**(spec §8.1)。

**约束(精确落点 + 改法):**
- 把 #11 现文(`harness/CLAUDE.md` 核心规则段「11. **会话开场先装载再对账**…」)行尾补半句指针(**只做指针、不复述散文**;对账「手工校验」指针保留不动):

```
11. **会话开场先装载再对账**:读 docs/active/handoff.md(台账)→ 跑 AGENTS.md「手工校验」命令核上次收口凭证;欠账先补再开新工作(会话链自执法)。**有 agent 运行时**再走 AGENTS.md「开场新鲜度侦察」节(fork freshness-scout 扫活文档、只报有问题的、全干净静默;权威 docs/governance/freshness-rules.md)
```

- **最小变更**:只在 #11 行尾追加新鲜度指针半句,不动「装载/对账」前半句与「手工校验」指针。
- **harness/CLAUDE.md 是 M4 分发模板**:指针用下游视角裸路径(`docs/...` `AGENTS.md`,不带 `harness/` 前缀,与 #11 现文一致)。

**验证标准:**
- #11 指针补全核:`grep -nE "开场新鲜度侦察|freshness-scout|freshness-rules" harness/CLAUDE.md` → 期望:#11 处命中新鲜度节指针
- 装载/对账前半句保留核:`grep -nF "会话开场先装载再对账" harness/CLAUDE.md` 且 `grep -nF "手工校验" harness/CLAUDE.md` → 期望:原前半句 + 手工校验指针仍在
- 不复述散文核(只指针):`grep -nE "arpRubric|入参 \{today" harness/CLAUDE.md` → 期望:**无输出**(#11 只做指针,不抄 freshness-rules 契约细节)
- [ ] commit:`feat: freshness - harness/CLAUDE #11 补指针指向开场新鲜度侦察节`

---

## 任务 7:credentials-rules.md §8 新增拷贝组「新鲜度开场步三处同改」【接线任务 — 问题式】

> 接线任务(契约之后)。现状(真实文本,已核):`credentials-rules.md` §8「双写同步义务清单」L240-251 = **7 条编号项**(第 5 条 = 对账命令四处拷贝组;第 6/7 条 = review-rules↔workflow.js FloorTable/候选菜单)。本任务**新增一条(第 8 条)**「新鲜度开场步三处同改」,**独立于既有第 5 条对账拷贝组**(不并入、不动既有第 5 条)。

**Files:**
- modify: `harness/docs/governance/credentials-rules.md`(§8 清单 L240-251;在第 7 条之后新增第 8 条)

**问题:** 新鲜度开场步横跨三宿主同核(根 CLAUDE 第 3 步 ↔ 根 AGENTS 新鲜度侦察节 ↔ templates AGENTS 新鲜度侦察节),改一处必同改三处,否则静默漂移无触点可捕。须登记为一条新拷贝组,且与既有对账拷贝组(第 5 条)显式区隔。

**约束(精确落点 + 内容):**
- 在 §8 清单第 7 条(L250)之后新增第 8 条(接续编号):

```markdown
8. 新鲜度开场步拷贝组**三处同改**:根 CLAUDE.md 会话开场规程「第 3 步 开场新鲜度侦察」/ 根 AGENTS.md「开场新鲜度侦察」节 / templates/AGENTS.md「开场新鲜度侦察」节(同核步骤:fork freshness-scout / 三类问题 / owner 二分 + routeTo / 全干净静默 / 推 last-reviewed / 需 agent 运行时降级)。**与第 5 条对账命令拷贝组独立**:第 5 条只锚对账三命令,本条只锚新鲜度开场步,两条各管各的同核面,不并入。新鲜度机制权威住 `docs/governance/freshness-rules.md`(不写入本件 §6 对账正文)。
```

- **不动既有第 5 条**(对账命令四处拷贝组,仍锚对账三命令 — spec 守住段)。
- **不动第 6/7 条**(review-rules↔workflow.js 双写)。
- credentials-rules.md 本身命中 governance glob(`docs/governance/*.md`)→ 本改动随收口产 audit(任务 3 已给它回填 frontmatter,本任务改正文)。

**验证标准:**
- 第 8 条新增核:`grep -nE "^8\. 新鲜度开场步拷贝组" harness/docs/governance/credentials-rules.md` → 期望:命中(接第 7 条编号)
- 三处同核登记核:`grep -nE "根 CLAUDE.md.*第 3 步|根 AGENTS.md.*开场新鲜度|templates/AGENTS.md.*开场新鲜度" harness/docs/governance/credentials-rules.md` → 期望:三宿主命中
- 与第 5 条区隔核:`grep -nE "与第 5 条.*独立|对账命令拷贝组.*独立|不并入" harness/docs/governance/credentials-rules.md` → 期望:区隔声明命中
- 既有第 5 条未动核(守住):`grep -nF "对账命令拷贝组**四处同改**" harness/docs/governance/credentials-rules.md` → 期望:第 5 条原文仍在(对账拷贝组零改)
- [ ] commit:`feat: freshness - credentials §8 新增新鲜度开场步三处同改拷贝组`

---

## 任务 8:收口 — 全组触点完整性命令 + 三处同核等价核 + 守住零改核 + 凭证预告【收口任务 — 指令式(收口验证)】

> 收口验证任务:不改产物,跑全组静态核命令确认触点完整 + 三处同核一致 + 守住零改 + 递归闭环 + 凭证预告。**在 harness 仓库根执行**(`D:\个人\harness`)。

**Files:** 无改动(纯验证)。

**操作(逐条跑命令,记录实际输出对照期望):**

- [ ] **C1 结构兜底(全仓 diff,终结打地鼠)**:`git diff --stat`
  - 判据:改动集**只应出现** spec §8.1 列文件 + 两份新建文件:新建 `freshness-rules.md` + `freshness-scout.md` + 回填 `governance/*.md`(10 份)+ `ARCHITECTURE.md` + `RUBRIC.md` + 根 `CLAUDE.md` + 根 `AGENTS.md` + `templates/AGENTS.md` + `harness/CLAUDE.md` + `credentials-rules.md`(回填+§8)。
  - **守住文件**(对账三命令 hook / preferences.md / references README 过时横幅 / docs/audits)出现任何 diff = **违守住,回退**。

- [ ] **C2 三处同核等价核(结构/语义等价,非 literal diff — 适配说明 a)**:
  - 三处节存在:`grep -lE "开场新鲜度侦察" "D:\个人\harness\CLAUDE.md" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md` → 期望:**三文件全命中**
  - 同核六要素齐全(每处都含):`for f in "D:\个人\harness\CLAUDE.md" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md; do echo "== $f =="; grep -cE "freshness-scout|全干净静默|owner 二分|last-reviewed|需 agent 运行时" "$f"; done` → 期望:每处计数 ≥4(六要素子集齐全;措辞可微调,核要素在不在)
  - 合法差异(仅路径前缀 + 凭证 bullet):根 AGENTS 带 `harness/` 前缀 + 凭证 bullet,templates 去前缀无凭证 bullet — 逐字 diff 恒不为空,**不做 literal diff**,人工核差异仅限此两项。

- [ ] **C3 落点正确核(新鲜度步非手工校验段 / 是开场第 3 步)**:
  - `grep -nE "## 手工校验|## 开场新鲜度侦察" "D:\个人\harness\AGENTS.md"` → 期望:两节并列分开(新鲜度**不在**手工校验段内)
  - `grep -nE "1\. \*\*装载|2\. \*\*对账|3\. \*\*开场新鲜度侦察" "D:\个人\harness\CLAUDE.md"` → 期望:开场规程三步有序(新鲜度是第 3 步)

- [ ] **C4 frontmatter 格式与 preferences 一致核**:
  - `grep -rhoE "<!-- owner: [^;]+; last-reviewed: [0-9]{4}-[0-9]{2}-[0-9]{2}; 生命周期: (evolving|immutable) -->" harness/docs/governance/ harness/docs/ARCHITECTURE.md harness/docs/RUBRIC.md | sort -u` → 期望:全部匹配半角格式(= preferences L2 同形),无全角漏网
  - 核心集无 MISSING:`for f in harness/docs/governance/*.md harness/docs/ARCHITECTURE.md harness/docs/RUBRIC.md; do sed -n '2p' "$f" | grep -qE "owner:" || echo "MISSING: $f"; done` → 期望:**无输出**(全部已回填)

- [ ] **C5 单源一致核(scope 白名单↔范围清单↔kind 取值域)**:
  - kind 三类两文件一致:`grep -oE "孤儿|时间腐|缺 frontmatter" harness/docs/governance/freshness-rules.md | sort -u` 与 `grep -oE "孤儿|时间腐|缺 frontmatter" harness/.claude/agents/freshness-scout.md | sort -u` → 期望:**两输出相同**(三类齐)
  - routeTo 三值两文件一致:`grep -oE "报给用户拍 owner 归属|调度者自己复核|报给用户拍" harness/docs/governance/freshness-rules.md | sort -u` 与 scout 同命令 → 期望:**两输出相同**(三值齐)
  - owner 二分两文件一致:`grep -oE "用户|调度者" harness/docs/governance/freshness-rules.md | sort -u`(含「用户」「调度者」)与 scout → 期望:二分一致

- [ ] **C6 routeTo 三值 + owner 二分核**(契约取值域):
  - `grep -noE "报给用户拍 owner 归属|调度者自己复核|报给用户拍" harness/docs/governance/freshness-rules.md` → 期望:三值各命中(无第四值)

- [ ] **C7 递归闭环核(两新建文件自带 frontmatter)**:
  - `sed -n '1,2p' harness/.claude/agents/freshness-scout.md | grep -E "<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->"` → 期望:scout 首部自带标签命中
  - `sed -n '2p' harness/docs/governance/freshness-rules.md | grep -E "<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->"` → 期望:rules L2 自带标签命中

- [ ] **C8 非 custom agent type 核**(HTML 注释 ≠ YAML frontmatter):
  - `grep -nE "^---$" harness/.claude/agents/freshness-scout.md` → 期望:**无输出**(无 YAML `---` 块,不被解析成 custom agent;HTML 注释标签无冲突)

- [ ] **C9 守住零改核**(逐条):
  - 对账三命令未动:`git diff "D:\个人\harness\CLAUDE.md" "D:\个人\harness\AGENTS.md" harness/templates/AGENTS.md | grep -E "^-.*check-(handoff|shelf-registry|audit-coverage)"` → 期望:**无输出**(无删除三命令行)
  - credentials §8 第 5 条对账拷贝组未动:`grep -nF "对账命令拷贝组**四处同改**" harness/docs/governance/credentials-rules.md` → 期望:命中(第 5 条原文在);`git diff harness/docs/governance/credentials-rules.md | grep -E "^-.*对账命令"` → 期望:无删除
  - preferences 未动:`git diff harness/docs/preferences.md` → 期望:**空**
  - references 过时横幅 / audit 失效判定零改:`git status --short harness/docs/references/ harness/docs/audits/` → 期望:无新鲜度相关改动

- [ ] **凭证预告(写进 handoff / 交收口):**
  - 本改动命中 credentials.conf 的文件:`docs/governance/freshness-rules.md`(新建,governance glob)/ `docs/governance/credentials-rules.md`(§8 改 + 回填,governance glob)/ 回填的 `docs/governance/*.md` ×10(governance glob)/ `.claude/agents/freshness-scout.md`(新建,`.claude/agents/*.md` glob)/ 根 `CLAUDE.md`(`CLAUDE.md` glob,covers 写 `<root>/CLAUDE.md`)/ `harness/CLAUDE.md`(`CLAUDE.md` glob)/ 根 `AGENTS.md`(`AGENTS.md` glob,covers 写 `<root>/AGENTS.md`)/ `templates/AGENTS.md`(`AGENTS.md` + `templates/*.md` glob)/ `docs/RUBRIC.md`(`docs/RUBRIC.md` glob)。
  - **`docs/ARCHITECTURE.md` 不命中凭证**(credentials.conf 无 ARCHITECTURE 行,已核 — spec §8.2)→ 回填它**无强制 audit 义务**,**自愿连带进同批 governance audit covers**(自愿覆盖,不擅扩 glob)。
  - **`credentials.conf` 不改**:所需 glob(governance / agents / CLAUDE / AGENTS / templates / RUBRIC)均已存在 → 无新 glob,无 conf↔§2 双写改动。
  - **finishing 须产 audit 凭证**(对抗审查):本改动跨多文件 + 三处同核拷贝组(根 CLAUDE/AGENTS/templates AGENTS)+ governance 新规矩 → 走 review-rules 治理行,**触点完整性维优先选用**(跨文件计数/枚举 + 同核组)。audit covers 列上述全部命中文件 + 自愿覆盖 ARCHITECTURE。
  - **守住自核**:audit 须确认对账三命令 / credentials §8 第 5 条 / preferences / references 过时横幅 / audit 失效判定 收口 git diff = 空。
  - 无 commit(纯验证);验证结果记入 handoff 收口段。

---

## Self-Review(spec 覆盖 §8.1 / 占位符扫 / 类型一致)

### spec 覆盖核(§8.1 改动集 ↔ 任务)

| spec §8.1 改动 | 计划任务 | 覆盖 |
|---|---|---|
| `/CLAUDE.md`(根)会话开场规程新增第 3 步 | 任务 4 | ✅ |
| `/AGENTS.md`(根)另起「开场新鲜度侦察」节 | 任务 5 | ✅ |
| `harness/templates/AGENTS.md` 同批另起新节(等价) | 任务 5 | ✅ |
| `credentials-rules.md` §8 新增拷贝组「新鲜度开场步三处同改」 | 任务 7 | ✅ |
| `harness/CLAUDE.md` 核心规则 #11 补指针 | 任务 6 | ✅ |
| `docs/governance/*.md` 回填 frontmatter | 任务 3(10 份)+ 任务 1(freshness-rules 自带) | ✅ |
| `docs/ARCHITECTURE.md` 回填 frontmatter | 任务 3 | ✅ |
| `docs/RUBRIC.md` 回填 frontmatter(owner=用户) | 任务 3 | ✅ |
| **新建** `docs/governance/freshness-rules.md`(自带 frontmatter) | 任务 1 | ✅ |
| **新建** `.claude/agents/freshness-scout.md`(自带 frontmatter) | 任务 2 | ✅ |
| 收口验证(三处同核 / 落点 / frontmatter 格式 / 守住零改) | 任务 8 | ✅ |

| spec 契约(§3 接口 / §4 数据) | 计划任务 | 覆盖 |
|---|---|---|
| §3.1 fork 入参(today/scopeList/N/rulesPointer) | 任务 2(入参契约)+ 任务 4(开场注入) | ✅ |
| §3.1 出参二态(CleanSignal/ProblemList + FreshnessProblem 字段) | 任务 2(出参契约) | ✅ |
| §4.1 frontmatter 三字段语义+取值域(数据契约) | 任务 1(§frontmatter 数据契约子节) | ✅ |
| §4.1 字段→kind 映射(单源权威) | 任务 1(§字段→kind 映射) | ✅ |
| §4.2 范围清单(核心集/增量/不纳入) | 任务 1(§范围清单)↔ 任务 2(扫描白名单) | ✅ |
| §4.3 owner→routeTo 三值映射(单源权威) | 任务 1(§owner 二分+routeTo) | ✅ |

| spec 核心场景(§1.2) | 计划任务 | 覆盖 |
|---|---|---|
| P0 场景1(开场扫描只回问题清单) | 任务 2 + 任务 4 全链 | ✅ |
| P0 场景2(全干净静默) | 任务 2(CleanSignal)+ 任务 4(静默)+ 任务 5 | ✅ |
| P0 场景3(复核动作=推日期) | 任务 1(§复核动作)+ 任务 4/5(收口顺手推) | ✅ |
| P1 场景4(owner 二分定责) | 任务 1(owner→routeTo)+ 任务 3(回填 owner) | ✅ |
| P1 场景5(核心集先上+增量采纳) | 任务 1(§范围清单)+ 任务 3(只回填核心集) | ✅ |

| spec 测试场景(§6.1) | 计划验证步 | 覆盖 |
|---|---|---|
| 三处同核拷贝组等价 | 任务 8 C2 + 任务 5 验证 | ✅ |
| frontmatter 格式一致(半角) | 任务 3 验证 + 任务 8 C4 | ✅ |
| 全角连字符 → 报不可解析 | 任务 2(边界条件 + 全角教训) | ✅ |
| 边界 == N 不报 | 任务 1(字段→kind 映射)+ 任务 2(边界) | ✅ |
| fork 失败降级不阻断 | 任务 2(降级)+ 任务 4(软提醒) | ✅ |
| 凭证义务(freshness-rules 落 governance glob) | 任务 8 凭证预告 | ✅ |
| 递归闭环(两新建文件自带 frontmatter) | 任务 1/2 自带 + 任务 8 C7 | ✅ |

### 占位符扫

- 两份新建文件(freshness-rules.md 全节内容 / freshness-scout.md 全节内容)**给实际可照抄文本 + 表格**(任务 1/2,逐字落 spec §4.1/§4.2/§4.3/§3.1)。
- 接线四处(根 CLAUDE 第 3 步 / AGENTS×2 新鲜度节 / harness/CLAUDE #11 / credentials §8 第 8 条)**给实际可照抄 markdown 块 + before→after 落点**(任务 4-7)。
- 回填 frontmatter **给实际格式 + owner 取值映射**(任务 3,governance/ARCHITECTURE=调度者 / RUBRIC=用户)。
- **无 `[待填]`/`[TODO]`/`<占位>`/"类似任务 N"/"加适当处理" 类未定义占位符**。frontmatter 数据契约内 `<谁>`/`YYYY-MM-DD` 是格式占位(= preferences L2 同形,契约形态非计划缺口);scout 入参块内 `<仓库相对路径>`/`<一句话>` 是契约字段占位(同 spec §3.1 写法)。

### 类型一致核(frontmatter 字段 / kind / routeTo / owner 取值在各任务一致)

- **frontmatter 三字段** `owner` / `last-reviewed` / `生命周期` — 任务 1(数据契约)↔ 任务 2(扫描)↔ 任务 3(回填)同名同义;格式 = preferences L2 半角同形(任务 1/3/8 C4)。
- **kind 三类** `孤儿` / `时间腐` / `缺 frontmatter` — 任务 1(字段→kind 映射单源)↔ 任务 2(扫描判据 + 出参 kind 取值域)逐字一致(任务 8 C5 两文件同源核)。
- **routeTo 三值** `报给用户拍` / `调度者自己复核` / `报给用户拍 owner 归属` — 任务 1(owner→routeTo 单源)↔ 任务 2(出参 routeTo 取值域)逐字一致(任务 8 C5/C6 核,无第四值)。
- **owner 二分** `用户` / `调度者`(+ 孤儿/缺 frontmatter 时出参 owner 可"未知")— 任务 1(二分映射)↔ 任务 2(出参 owner 取值域)↔ 任务 3(回填取值:governance/ARCHITECTURE=调度者 / RUBRIC=用户)一致。
- **N=90** — 任务 1(阈值初值)↔ 任务 2(入参 N 默认)↔ 任务 4(开场注入 N:90)同值;边界 `== N` 仍新鲜、`> N` 才报,任务 1/2 一致。
- **路径前缀约定** — 任务 1(freshness-rules 写约定)↔ 任务 5(根 AGENTS 带 `harness/`、templates 去前缀)合法差异,与既有 AGENTS×2 双写同款(根 CLAUDE L65)。

### 需回设计阶段的偏离点

**无。** 计划全程对齐 spec §1-§9 + 守住段 + 不做清单 + D-1~D-9,逐文件基于真实文本(preferences.md L2 / 根 AGENTS.md L40-46 / templates/AGENTS.md L38-44 / 根 CLAUDE.md 开场规程 L68-77 / harness/CLAUDE.md #11 / credentials-rules.md §8 L240-251 / 10 份 governance/*.md L2 / ARCHITECTURE.md L2 / RUBRIC.md L2 / research-scout.md L1-5 / design-reviewer.md L1-3),未发现需偏离设计文档之处。

> **spec 不可执行点回报(给上抛参考,非偏离)**:无阻塞点。两条实情登记(已在任务内处理,不需回设计):
> - ① **harness/CLAUDE.md #11 现文** = 「会话开场先装载再对账…跑 AGENTS.md「手工校验」命令」(无第 3 步指针),spec §8.1 要求 #11「补半句指针指向开场新鲜度侦察节(定死,不留按需)」——任务 6 给精确补法(行尾追加「有 agent 运行时再走 AGENTS『开场新鲜度侦察』节」),与 spec §8.1 一致,非偏离。
> - ② **`docs/ARCHITECTURE.md` 不在凭证 glob**(spec §8.2 已诚实登记的既存缺口,非本 spec 引入)——任务 3 回填它无强制 audit 义务,任务 8 凭证预告处置 = 自愿连带进同批 governance audit covers,不擅扩 credentials glob(扩 glob 是 credentials 制度改动,需独立 audit,不在本批范围)。

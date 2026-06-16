# 反腐烂 / 新鲜度机制(freshness)系统设计

> 状态:第 0-9 节已填。本功能 = 给会腐的"活文档"加保质期标签(frontmatter)+ 会话开场 fork 一个**新鲜度侦察子智能体**扫活文档、只回有问题的、全干净静默 + 复核动作 = 推 `last-reviewed` 日期。**软**机制(报告/提醒,不阻断、不自动修复)。
> 规模:**标准级**(新建 1 个 governance 规则文件 + 新建 1 个 agent 说明文件 + 改根 CLAUDE.md 会话开场规程加**第 3 步「开场新鲜度侦察(需 agent 运行时)」** + 改 AGENTS.md×2 **另起一节「开场新鲜度侦察(需 agent 运行时)」**(与「手工校验(纯人工 bash 对账三命令)」并列分开,**不嵌入**手工校验段)+ 核心集 4 类文件回填 frontmatter + 凭证/地图触点)→ 按 DESIGN_TEMPLATE 全节填写,不适用节写"不适用"+ 理由。
> 上游料:`docs/references/2026-06-16-knowledge-system-what-to-preserve.md`(brainstorming 收敛快照;新鲜度 = Step 1)+ 2026-06-16 用户拍板的锁定设计输入(本 spec 第 1.5 节直录)。
> 路径前缀约定(双层仓,子智能体 scopeList 扫描据此解析,无歧义):
> - `docs/...` 一律指 harness 自仓库的 `harness/docs/...`;
> - `.claude/...` 一律指 `harness/.claude/...`;
> - 根级 `/CLAUDE.md` · `/AGENTS.md` = **仓库根两份**(`<root>/CLAUDE.md` · `<root>/AGENTS.md`,M3 自治理入口),**区别于** `harness/CLAUDE.md`(M4 分发模板);
> - 分发下游同形**去 `harness/` 前缀**。

---

## 0. 偏离说明(结构差异)

- 无结构偏离。沿用 `DESIGN_TEMPLATE.md` 全部 9 节标题与编号,新增 §0 仅记此声明(本节不豁免 design-review,见 design-rules §spec §0 偏离规则)。
- 技术栈说明:本功能产物 = **文档约定 + 一个 fork 子智能体的行为契约**,无运行时代码、无 API、无数据库。模板中 TypeScript / API 契约 / 数据库字段等示例,按"项目实际技术栈 = Markdown 文档 + Claude Code fork agent"映射:接口 = 子智能体的入参/出参契约;数据模型 = frontmatter 字段语义。

---

## 1. 需求摘要

### 1.1 用户目标

harness 已建起一批"活文档"(治理规则 / 架构 / 偏好 / 模块说明),它们会随时间和仓库演进而**腐烂**——5 天前的方向地图已部分过时,但没有任何机制提醒"这份该回头看了"。用户要一个**最小、最快、软**的反腐烂机制:给会腐的活文档贴一个"保质期标签",每次会话开场派一个聪明的子智能体扫一遍、**只把有问题的报出来**(全干净就闭嘴,不刷屏),复核确认后顺手把日期推到今天。

一句话:**给活文档加保质期 + 开场派子智能体查、只报有问题的 + 看过重贴日期**。

### 1.2 核心场景(按优先级排序)

> **机制定位**:这是会话开场规程的**新增第 3 步**——与现有「1.装载 / 2.对账」**并列**(根 CLAUDE.md 开场规程是 2 个编号步,对账下挂 check-handoff / check-shelf-registry / check-audit-coverage **三条子命令**,不是三个平级步;新鲜度是与装载/对账平级的第 3 步)。它不替换、不嵌入、不改对账三命令。区别:对账三命令是机械 bash hook 查凭证/台账文法(只读账本);新鲜度要**读文档内容做判断**(缺 owner?日期超期?该有 frontmatter 却没有?),故用**子智能体**(更聪明、少误报、能干净静默),不是第四个 hook。

1. **[P0] 会话开场扫描、只回问题清单**:调度者在会话开场规程走完第 1 步装载 + 第 2 步对账(对账三命令)后 → 第 3 步 fork 一个"新鲜度侦察"子智能体 → 子智能体在自己的上下文里扫所有活文档的 frontmatter → 算三类问题(孤儿 / 时间腐 / 该有却没有)→ **只回问题清单**(每条带 owner + 指明报给谁、谁处理)→ 调度者按清单分流(`用户` owner 的报给用户拍、`调度者` owner 的 AI 自己复核)。
2. **[P0] 全干净则静默**:子智能体扫完发现零问题 → **不回报、不刷主对话**(返回一个明确的"全干净"信号,调度者据此不向用户输出任何新鲜度内容)。这是"少打扰"的核心:绝大多数会话开场应当看不到新鲜度噪声。
3. **[P0] 复核动作 = 推日期(顺手,不另起)**:某活文档被 owner 确认"还准"(或顺手修了)→ 把它的 `last-reviewed` 推到今天;**收口时若本批动过某活文档,顺手把它的 `last-reviewed` 推到今天**(复核搭收口便车,不另起独立动作)。
4. **[P1] owner 二分定责**:每份活文档的 `owner` 取 `用户` 或 `调度者` 之一——`用户` = 只有用户能自证还准的(偏好 / RUBRIC 方向盘 / 方向级),脏了**报给用户拍,AI 不自证**;`调度者` = AI 日常维护的(治理规则 / 架构 / 模块 README / 标准件),AI **自己复核**、真要改走凭证义务。
5. **[P1] 核心集先上 + 增量采纳**:不一次性回填全仓 frontmatter。先给**核心集**(governance / ARCHITECTURE / RUBRIC / preferences)回填;模块 README / 标准件**增量采纳**——子智能体扫到"该有 frontmatter 却没有"时标缺失,owner 后续补,frontmatter 覆盖面自然长。

### 1.3 边界与约束

**本轮做(最小可用)**:
- **frontmatter 约定**(沿用 preferences.md 既有格式,不另造):活文档头带 `<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving|immutable -->`。
- **新建 `docs/governance/freshness-rules.md`**:新鲜度机制的**单一权威住址**(约定 / 范围清单 / owner 二分判据 / N=90 阈值 / 子智能体行为契约 / 复核动作)。
- **新建 `.claude/agents/freshness-scout.md`**(说明型 agent,镜像 research-scout.md / design-reviewer.md 形态、真实同位 `.claude/agents/`,非带 frontmatter tools 的 custom agent type):子智能体怎么找活文档、怎么算三类问题、怎么组织问题清单、全干净怎么静默。
  - **「非 custom agent type」与本机制新鲜度标签无冲突(显式消解张力)**:既有 agent 文件(research-scout / design-reviewer / review-scout)L2 声明的「不是带 frontmatter 的 custom agent type」,防的是 **YAML `---` frontmatter tools 块**被 Claude Code 解析成 custom agent。本机制的新鲜度标签是 **HTML 注释 `<!-- owner...; last-reviewed...; 生命周期... -->`**(§4.1),**不是 YAML `---`,不会被解析成 custom agent type**。故 `freshness-scout.md` 及其它 agent 文件**可安全带 HTML 注释新鲜度标签**,不破坏「非 custom agent type」形态约定。
- **接线(三处同核 — 落点语义)**:① **根 `CLAUDE.md`「会话开场规程」加第 3 步「开场新鲜度侦察(需 agent 运行时)」**(fork 新鲜度侦察,软,与「1.装载 / 2.对账」平级);② **AGENTS.md×2(根 `AGENTS.md` + `harness/templates/AGENTS.md`)各另起一节「开场新鲜度侦察(需 agent 运行时)」**——**与既有「手工校验(纯人工 / 无 hook 运行时跑对账三命令)」节并列但分开,不嵌入手工校验段**。理由:「手工校验」节标题即「无 hook 运行时 / 纯人工」、内容是纯人工可跑的 bash 命令;新鲜度步是 **fork 子智能体(需 agent 运行时,纯人工跑不了)**,语义不同宿,塞进「纯人工」段会自相矛盾。诚实降级:**无 agent 运行时则跳过新鲜度侦察**(同 hook 降级——丢自动触发,不丢可校验性);**对账三命令仍纯人工可跑、不受影响**。③ `harness/CLAUDE.md` 核心规则 #11 指针处置见 §8.1(定死,不留"按需")。
- **三宿主同核拷贝组(须登记 credentials §8)**:上述 ① 根 CLAUDE 第 3 步 ↔ ② 根 AGENTS 新鲜度侦察节 ↔ ② templates AGENTS 新鲜度侦察节 是**同一根因的三处同核**(改一处必同改三处),登记为**一条新拷贝组「新鲜度开场步三处同改」**,详 §8 + §8.1。**注**:这与 credentials-rules §8 **第 5 条**(即 finding 所称「§8.5」)既有的「对账命令四处拷贝组」是**两条独立拷贝组**——既有对账拷贝组只锚**对账三命令**、本 spec 零改它;新鲜度另立新拷贝组,**不并入**对账拷贝组。
- **核心集回填 frontmatter**:`docs/governance/*.md` + `docs/ARCHITECTURE.md` + `docs/RUBRIC.md` + `docs/preferences.md`(后者已有,沿用不改)。

**不做(明确排除——守"小而快")**:
- **不做漂移检测**(文档 ↔ 代码不一致):留给后续 ★ 设计层子项;新鲜度只看"时间 + 孤儿",不读代码判文档是否还描述对了实现。
- **不做硬阻断**:强度 = 软,只报告 / 提醒,绝不 exit 2 阻断会话、不挡收口。
- **不做自动修复**(LLM doc-gardening / 自动改文档内容):子智能体只**报问题**,改由 owner 决定;唯一"自动"动作是复核后推日期(也由 owner 触发,不是子智能体擅自改)。
- **不一次性回填全仓 frontmatter**:核心集先上,其余增量采纳。
- **不重复管 immutable 留痕件**:references 带日期前缀的留痕件用既有"过时横幅"约定,新鲜度**不纳入、不重复管**。
- **不重复管 audit 漂移**:凭证的"漂移腐"(covered 文件改了 audit 失效)已由 credentials §5 失效判定管,新鲜度**不碰**。

**性能要求**:子智能体扫描在自己的 fork 上下文里跑,不刷主对话上下文;核心集 ~10 份文件量级,单次扫描读 frontmatter 行级即可,无性能压力。

**安全要求**:子智能体只**读** frontmatter + 报告,不写、不删、不自动改文档(软强度的安全边界)。

**兼容性要求**:对账三命令(check-handoff / check-shelf-registry / check-audit-coverage)**零改**;references 过时横幅约定**零改**;audit 失效判定(credentials §5)**零改**;preferences.md 既有 frontmatter 格式**沿用不改**(详见 §8 + §“守住”段)。

### 1.4 关联需求

- **依赖的已有约定**:preferences.md 既有 frontmatter(本机制的现成格式范本,纳入即可);会话开场规程(根 CLAUDE.md 加第 3 步 + AGENTS.md×2 **另起「开场新鲜度侦察」节**的接入点,与「手工校验」段并列分开);扁平 fork 架构 + 公设 1(做事/判断分开:子智能体扫描报问题 = 做事,owner 拍"还准不准" = 判断);credentials.conf governance glob(`freshness-rules.md` 落 `docs/governance/*.md` 自动入凭证义务)。
- **被依赖**:后续 ★ 设计层子项——设计层地图一旦旧了会误导实现者,比没有还糟,本机制是 ★ 的**保鲜地基**(上游料 E §排序理由)。

### 1.5 已确认的决策(2026-06-16 用户拍板,锁定不偏离)

| # | 决策 | 用户拍板 |
|---|---|---|
| D-1 | frontmatter 约定 | 沿用 preferences.md 既有:`<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving\|immutable -->`,不另造 |
| D-2 | 范围 | 核心集先上(governance/*.md + ARCHITECTURE + RUBRIC + preferences)+ 增量采纳;不一次性回填全仓 |
| D-3 | owner 二分 | `用户`(只有用户能自证:偏好/RUBRIC/方向级)/ `调度者`(AI 日常维护:governance/ARCHITECTURE/模块 README/标准件) |
| D-4 | 开场检查形态 | 会话开场规程**新增第 3 步**(与「装载/对账」平级;对账下挂三命令是子命令非平级步)= fork 一个新鲜度侦察子智能体(不是第四个 bash hook),只回问题清单、全干净静默 |
| D-5 | N 天阈值 | 90 天(一季度没回头看就提醒) |
| D-6 | 复核动作 | 推日期(`last-reviewed` 推到今天);收口时动过某活文档顺手推 |
| D-7 | 强度 | 软(报告/提醒,不阻断、不自动修复) |
| D-8 | 规矩住址 | 新建 `docs/governance/freshness-rules.md`(单一权威住址,命中 governance 凭证 glob) |
| D-9 | 时间腐 + 孤儿腐轻组合;漂移腐不做 | 漂移留给后续 ★ 设计层子项 |

### 1.6 RUBRIC 风险标记

> harness 自仓库 `docs/RUBRIC.md` 是**空模板**(§二/§三全是 `[待定义]` 示例占位)。按既有 scout spec 同例(`2026-06-15-code-review-scout-design.md` §1.6),**代 RUBRIC = CLAUDE.md 核心规则 + 二条公设**(方向盘缺位时的回落基准,这本身就是本机制要保护的活文档之一)。

- 涉及的惩罚项(代 RUBRIC):
  - **简洁性**(RUBRIC §一·简洁性 / CLAUDE.md 核心规则 5「最小变更」):本机制最易踩"过度工程化"——加 frontmatter 字段、加 hook、加阈值表都可能膨胀。守:复用 preferences 既有 frontmatter(不造新格式)、复用 fork 架构(不造新机制)、只接核心集一类真消费者。
  - **一致性**(RUBRIC §一·一致性):新鲜度子智能体须与现有 scout / reviewer 同形(说明型 agent + 扁平 fork),frontmatter 须与 preferences 既有逐字一致,不引入第二套元数据格式。
- 涉及的奖励项(代 RUBRIC):
  - **防遗忘靠机制不靠纪律**(CLAUDE.md 二公设·行动公设 + 「`调度者` owner ≈ 无专人、AI 日常维护 + 机制兜底」):本机制正是把"该回头看了"从依赖记忆变成开场自动触发的外部动作。
  - **做事/判断分开**(公设 1):子智能体扫描报问题(做事)≠ owner 判"还准不准"(判断),严格分离。

(具体应对方式在 §7 设计决策展开。)

**自检**:
- [x] 每个核心场景都有完整的"谁 → 做什么 → 系统做什么 → 看到什么"?(场景 1-3 完整;4-5 是约束/范围说明,在 §3/§4 落契约)
- [x] "不做什么"列了用户可能误以为在范围内的事?(漂移检测 / 硬阻断 / 自动修复 / 全仓回填 / 重复管 immutable·audit)
- [x] 和 brainstorming 锁定输入对得上?没有遗漏或偷换?(D-1~D-9 直录用户拍板,逐条对照)
- [x] 优先级排序反映用户确认的优先级?(开场扫描 + 静默 = P0 核心;owner 二分 / 增量采纳 = P1 支撑)

---

## 2. 模块划分

> 本功能"模块" = 文档约定 + 子智能体行为契约 + 接线点。无运行时代码层,按 harness 自仓库的**概念分层**(治理规则层 / agent 说明层 / 入口规程层 / 受治理的活文档层)归类,不套 DESIGN_TEMPLATE 的 web 层(UI/Service/Repository——harness 自仓库 ARCHITECTURE 那套层是空模板示例,不适用)。

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动 | 所在层(harness 概念分层) |
|------|--------------|----------|---------------------------|
| `freshness-rules.md` | 新鲜度机制的单一权威规矩(约定/范围/owner/阈值/契约) | 新建 | 治理规则层(`docs/governance/`) |
| `freshness-scout.md` | 新鲜度侦察子智能体的行为契约(怎么找/怎么算/怎么报/怎么静默) | 新建 | agent 说明层(`.claude/agents/`,与 research-scout/design-reviewer 同位) |
| 开场接线(根 CLAUDE 第 3 步 + AGENTS.md×2 新鲜度侦察节) | 根 CLAUDE.md 加第 3 步;AGENTS.md×2 各**另起「开场新鲜度侦察(需 agent 运行时)」节**(与「手工校验(纯人工)」节并列分开),软,与装载/对账平级 | 改动 | 入口规程层(`<root>/CLAUDE.md` + `<root>/AGENTS.md` + `harness/templates/AGENTS.md`) |
| 核心集 frontmatter | governance/* + ARCHITECTURE + RUBRIC 回填保质期标签(preferences 已有,沿用) | 改动 | 受治理的活文档层 |
| 凭证 + 地图触点 | freshness-rules 入凭证义务 + 文档索引/Skill 地图登记 | 改动 | 治理元数据层 |

### 2.2 模块依赖图

```
[开场接线: 根 CLAUDE 第3步 + AGENTS.md×2 新鲜度侦察节]  ──fork──►  [freshness-scout 子智能体]
         (与装载/对账平级; 与「手工校验」节并列分开, 不依赖)        │
         ▼                                                 │读契约
[对账三命令 hook]  (零改, 仅时序在前)             [freshness-rules.md]◄──权威住址
                                                           │定义
                                                           ▼
                                              [核心集活文档 frontmatter]
                                              governance/* + ARCHITECTURE
                                              + RUBRIC + preferences(已有)
```

依赖方向:开场接线 → fork 子智能体 → 子智能体读 freshness-rules 契约 → 扫核心集 frontmatter。单向,无环。对账三命令(第 2 步)与新鲜度第 3 步**并列**(时序上对账在前、新鲜度在后),互不依赖、互不调用。

**自检**:
- [x] 每个模块只有一个明确职责?(规矩住址 / 子智能体契约 / 接线 / 数据 / 凭证,各一职)
- [x] 依赖方向符合架构?(单向 fork + 读契约,无反向;并列不耦合)
- [x] 没有循环依赖?(线性链,无环)
- [x] 改动已有模块时改动范围局限于职责内?(根 CLAUDE.md 只加第 3 步、不动装载/对账两步;AGENTS.md×2 只**另起新鲜度侦察节**、不碰「手工校验」三命令原文与该节;核心集只加 frontmatter 行、不动正文)
- [x] 每个核心场景都能找到实现路径?(场景 1-2 → 子智能体 + 开场规程;场景 3 → freshness-rules 复核动作约定 + finishing 顺手推;场景 4-5 → freshness-rules owner 二分 + 范围清单)
- [x] 粒度合理?(无"只有一个字段"的模块,无"做三件不相关事"的模块)

---

## 3. 接口定义

> 本功能无运行时函数接口。"接口" = ① 调度者 fork 子智能体的**入参契约** ② 子智能体回给调度者的**出参契约** ③ 子智能体读取的 frontmatter **数据契约**。下面用伪签名表达(实际是自然语言 prompt + 结构化报告)。

### 3.1 模块间接口

**[会话开场规程] → [freshness-scout 子智能体](fork 时的入参)**

```text
forkFreshnessScout(input):
  input = {
    today:        "YYYY-MM-DD"            // 当天日期(调度者注入, 子智能体据此算超期, 不自取系统时钟避免环境漂移)
    scopeList:    CoreSet + IncrementalGlobs // 范围清单(见 §4.2; 权威定义在 freshness-rules.md, fork prompt 引指针)
    N:            90                       // 时间腐阈值(天); 默认 90, 由 freshness-rules.md 定
    rulesPointer: "docs/governance/freshness-rules.md" // 子智能体读完整契约的指针
  }

// 调用场景:会话开场规程第 3 步, 第 1 步装载 + 第 2 步对账(三命令)走完后, 由调度者(主对话)fork。
// 错误处理:fork 失败(超时/上下文溢出/工具不可用)→ 调度者降级(见 §5.2 E-1), 软提醒"本会话新鲜度未扫", 不阻断。
```

**[freshness-scout 子智能体] → [会话开场规程](回给调度者的出参)**

```text
FreshnessReport = CleanSignal | ProblemList

CleanSignal:        // 场景 2:全干净
  { clean: true }   // 调度者据此不向用户输出任何新鲜度内容(静默)

ProblemList:        // 场景 1:有问题
  {
    clean: false,
    problems:        [ FreshnessProblem, ... ]   // 核心集问题: 逐条(非空数组; 空数组等价于 clean:true, 不允许)
    incrementalNote: "<一行汇总>" | null         // 增量类"缺 frontmatter": 折叠为一行(见展示粒度 §7 S-2); 无则 null
  }
  // 展示粒度(§7 S-2): 核心集问题 → problems[] 逐条报(每条 owner+routeTo 可分流);
  //                增量类"缺 frontmatter" → 默认不逐条进 problems[], 折叠成 incrementalNote 一行
  //                (如 "N 份增量文档(模块 README / 标准件 / agent·skill 契约)可采纳 frontmatter"), 不刷紧迫感。

FreshnessProblem = {
  file:       "<仓库相对路径>"          // 哪份文档
  kind:       "孤儿" | "时间腐" | "缺 frontmatter"  // 三类问题之一(字段→kind 映射单源 = freshness-rules.md; 本处派生自 freshness-rules)
  owner:      "用户" | "调度者" | "未知"  // 该文档 owner(孤儿/缺 frontmatter 时可能"未知")
  detail:     "<一句话>"                 // 如"last-reviewed 2026-03-01, 已 107 天" / "缺 owner 字段" / "核心集成员却无 frontmatter"
  routeTo:    "报给用户拍" | "调度者自己复核" | "报给用户拍 owner 归属"  // 三值, 由 owner 推出的分流动作(见 §4.3 路由表; 末值 = owner=未知 的孤儿/缺 frontmatter 兜底分流)
}
// 字段→kind 映射(缺 owner→孤儿 / last-reviewed 缺或超 N→时间腐 / 核心集成员无标签→缺 frontmatter)单源权威 = freshness-rules.md;
//   §3.1 / §4.1 / §4.3 / §5.1 四处对该映射的重述均"派生自 freshness-rules",不另立第二权威。

// 调用场景:子智能体扫完核心集后一次性返回(不流式、不中途刷主对话)。
// 错误处理:子智能体内部单文件解析失败 → 不崩整体, 把该文件作为一条 problem(kind 视情况, detail 注明"frontmatter 不可解析")上报, 继续扫其余(见 §5.1)。
```

### 3.2 外部接口

不适用——本功能不涉及任何网络 / HTTP / DB 外部接口。子智能体的"外部"仅限读本仓 Markdown 文件(经 Read/Grep 工具),无跨系统交互。

### 3.3 前后端类型契约

不适用——本功能不涉及任何 API 端点,无前后端分离。**数据契约 = frontmatter 字段**,定义在 §4.1;子智能体出参契约定义在 §3.1。两份契约的**单一权威住址** = `freshness-rules.md`(字段语义 + 取值域)+ `freshness-scout.md`(报告结构),agent 与 rules 引指针不各自重定义,避免双源漂移。

**自检**:
- [x] 每个接口双方都定义了?(fork 入参:开场规程↔子智能体;出参:子智能体↔开场规程;数据:子智能体↔frontmatter)
- [x] 参数/返回类型在"项目类型系统"(= Markdown 约定)中存在或已定义?(frontmatter 三字段 §4.1;报告字段 §3.1 + 取值域)
- [x] 每个接口都有错误处理约定?(fork 失败 → 降级;单文件解析失败 → 降级为一条 problem)
- [x] 入参/出参与需求数据对得上?(today/N/scope → 算超期;problems 带 owner+routeTo → 场景 1 的"指明报给谁")
- [x] 接口简洁?(入参 4 项、出参二态;无冗余参数)
- [x] 字段命名统一?(owner / last-reviewed / 生命周期 三字段在 frontmatter / rules / scout / 报告中同名)

---

## 4. 数据模型

> 本功能的"数据" = ① 活文档 frontmatter 三字段语义 ② 范围清单(哪些是活文档)③ owner→路由映射 ④ 阈值常量 N=90。

### 4.1 数据实体:活文档 frontmatter

格式(沿用 preferences.md 既有,**逐字不另造**):

```text
<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving|immutable -->
```

> 放置位置:文档标题(`# …`)的**下一行**(与 preferences.md L2 一致)。HTML 注释形式(`<!-- -->`)→ 渲染不可见、对正文零干扰,沿用既有。**注**:HTML 注释标签 ≠ YAML `---` custom-agent frontmatter,**无解析冲突**——故 `.claude/agents/*.md`(含 freshness-scout.md)带此 HTML 注释新鲜度标签**不破坏**「非 custom agent type」约定(§1.3 已展开)。

> **字段→kind 映射单源(权威 = freshness-rules.md)**:「缺 owner → 孤儿 / last-reviewed 缺或 today−last-reviewed > N → 时间腐 / 核心集成员无标签 → 缺 frontmatter」这套映射的**单一权威住址 = `freshness-rules.md`**;本 spec §3.1 / §4.1(本表)/ §4.3 / §5.1 四处对它的重述均为**派生自 freshness-rules**(便于就地阅读),非第二权威,改判据先改 freshness-rules.md。

| 字段 | 语义 | 取值域 | 必填 | 缺失时子智能体怎么判 |
|---|---|---|---|---|
| `owner` | 谁有权确认"这份还准" | `用户` \| `调度者` | ✅ | 缺 = **孤儿**(无人认领, kind="孤儿") |
| `last-reviewed` | 上次有人确认还准的日期 | `YYYY-MM-DD`(半角连字符) | ✅(evolving 类) | 缺或不可解析 = **时间腐**(kind="时间腐", detail 注明"缺/不可解析") |
| `生命周期` | 这份会不会演进 | `evolving` \| `immutable` | ✅ | 缺 → 默认按 `evolving` 处理(保守:纳入时间腐检查) |

> **`生命周期: immutable` 的语义**:该文档是留痕/快照,**不参与时间腐检查**(它本就不该更新, last-reviewed 推日期对它无意义)。但 immutable 文档**仍查 owner**(孤儿检查):一份没人认领的留痕件也值得提醒补 owner。注:references 带日期前缀的 immutable 留痕件**不在本机制范围内**(用过时横幅那套, §4.2 范围清单已排除),此处 immutable 仅指"被纳入范围、但标了 immutable"的边缘个案(如某标准件被人手动标 immutable)。

> **owner 词的诚实说明**(写入 freshness-rules.md):`调度者` owner ≈ **无专人、AI 日常维护 + 机制兜底**(对齐 CLAUDE.md「防遗忘靠机制不靠纪律」)。本质是**二分:谁有权确认还准** —— `用户`(只有用户能自证的方向级)vs `调度者`(AI 日常能复核的执行级)。"调度者"虽是临时角色名,二分语义清晰即可;freshness-rules.md 须写明此注,避免读者误解为"有个叫调度者的专人"。

> **`调度者` owner 自评加固**(写入 freshness-rules.md,对齐公设 1「AI 自评有系统性乐观偏差」):调度者 owner 文档的"还准"确认是**软自评**——AI 复核内容是否还准、顺手推 `last-reviewed`。但**自评不替代对抗审查**:`调度者` owner 文档**真要改时**(改正文/改规矩,非仅推日期)由凭证义务的 **audit 独立审兜底**(governance 改动 → audit)。即:推日期=软自评可独走;改内容=须走对抗审查。这条防止"AI 自己说还准就算数"的乐观偏差闭环。

### 4.2 数据实体:范围清单(哪些是活文档)

**子智能体判"这是不是活文档"的判据 = 范围清单(路径白名单 + frontmatter 存在性),不靠"有没有 frontmatter"反推**(否则核心集成员缺 frontmatter 就永远扫不到,自我消解)。权威清单住 `freshness-rules.md`:

| 类别 | 路径 | 纳入方式 | 缺 frontmatter 时 |
|---|---|---|---|
| 治理规则 | `docs/governance/*.md` | **核心集**(本轮回填) | 报"缺 frontmatter"(核心集成员必须有) |
| 架构 | `docs/ARCHITECTURE.md` | **核心集**(本轮回填) | 同上 |
| 方向盘 | `docs/RUBRIC.md` | **核心集**(本轮回填,**owner=用户**——方向级只有用户能自证还准,脏了报给用户拍,AI 不自证) | 同上 |
| 偏好 | `docs/preferences.md` | **核心集**(已有,沿用) | — (已有) |
| 模块 README | `**/README.md`(模块目录) | **增量采纳** | 标"缺 frontmatter"(提示 owner 补,**不算硬欠账**) |
| 标准件 | `docs/references/` 内**无日期前缀**(如 `DESIGN_TEMPLATE.md`) | **增量采纳** | 标"缺 frontmatter"(增量长) |
| agent/skill 契约 | `.claude/agents/*.md` + `.claude/skills/*/*.md` | **增量采纳**(在扫描范围、随时间标缺失;本轮**不批量回填**) | 标"缺 frontmatter"(温和,汇总折叠一行,§7 S-2);它们是带凭证 glob 的活契约文档,owner=调度者,后续顺手补 |

**明确不纳入**(子智能体跳过,不扫不报):
- `docs/references/` **带日期前缀**留痕件(`YYYY-MM-DD-*.md`/`.html`)→ immutable,用过时横幅约定(§守住)。
- `docs/audits/` → 已有 audit 失效判定(credentials §5)。
- `docs/decisions/` → 历史决策记录,定了就不腐(append-only)。
- `docs/active/handoff.md` → 工作记忆,短期,每会话覆写,无保质期语义。
- `docs/ROADMAP.md` / `docs/PROGRESS.md` → 台账 / append 记录,不腐。

> **核心集 vs 增量的处理差异**:核心集成员缺 frontmatter = **"该有却没有"的真问题**(本轮就该回填,报出来催补);增量类成员缺 frontmatter = **温和提示**(owner 顺手补、自然长,不算欠账、不刷紧迫感)。子智能体报告时 detail 区分这两种语气。

> **递归闭环(本机制新建文件自己也在扫描范围)**:`.claude/agents/freshness-scout.md` 落在 `.claude/agents/*.md` 增量范围、`docs/governance/freshness-rules.md` 落在 governance 核心集范围——两份新文件都会被子智能体扫到。为免首次开场子智能体把自己/自家规矩报成"缺 frontmatter",**两份新文件本轮即自带 frontmatter**(owner=调度者、生命周期 evolving;详 §8.1 新建段)。故 freshness-scout.md 虽在增量范围内但已有 frontmatter,**不自报**。

### 4.3 数据流 + owner→路由映射

```
[会话开场: today + scopeList + N=90]
   → [子智能体: 逐文件读 frontmatter]
   → [算三类问题: 孤儿(缺owner) / 时间腐(last-reviewed 缺或 today-last-reviewed > N) / 缺frontmatter(核心集成员无标签)]
   → [按 owner 映射 routeTo]
   → [全干净? → CleanSignal 静默 : ProblemList 回调度者]
   → [调度者分流: 用户owner→报给用户拍 / 调度者owner→AI自己复核]
   → [复核确认还准(或修了) → last-reviewed 推到 today]   ← 复核动作(场景3)
```

owner → routeTo 映射表(**单源权威住 freshness-rules.md**;本表派生自 freshness-rules,routeTo 取值域三值与 §3.1 接口 / §5.1 边界表逐字一致):

| owner | routeTo(三值之一) | 谁动手 |
|---|---|---|
| `用户` | `报给用户拍` | 用户确认还准 / 拍要不要改;**AI 不自证**(方向级只有用户能自证) |
| `调度者` | `调度者自己复核` | AI 自己复核内容是否还准;真要改走凭证义务(governance 改动 → audit) |
| `未知`(孤儿/缺 frontmatter) | `报给用户拍 owner 归属` | 默认升给用户决定该文档归谁(owner 二分的兜底) |

### 4.4 状态变更

| 实体 | 从状态 | 触发事件 | 到状态 | 副作用 |
|------|-------|---------|-------|--------|
| 活文档 | `新鲜`(today-last-reviewed ≤ N) | 时间流逝过 N 天 | `时间腐` | 下次开场被子智能体报出 |
| 活文档 | `时间腐` | owner 复核确认还准/修了 → 推日期 | `新鲜` | `last-reviewed` 改为 today(governance 文档则该 commit 走 audit) |
| 活文档 | `无 frontmatter`(核心集/增量) | owner 回填标签 | `新鲜` | 进入正常时间腐周期 |
| 活文档 | `孤儿`(缺 owner) | 用户拍定 owner 归属 | `有主` | 补 owner 字段 |

无死状态 / 不可达状态:`immutable` 文档不进时间腐流转(只查孤儿);其余三态可互相到达。

**自检**:
- [x] 数据流每步类型与接口一致?(today/N/scope 入 → problems 出,与 §3.1 契约对齐)
- [x] 实体字段覆盖所有接口用到的数据?(owner→routeTo / last-reviewed→时间腐 / 生命周期→是否查时间腐,全覆盖)
- [x] 状态变更完整,无死状态?(§4.4 四态可达,immutable 旁路明确)
- [x] 字段命名规范明确?(frontmatter 半角 `: ;`,日期 `YYYY-MM-DD` 半角连字符,与 preferences 既有 + check-context-chain "只认半角"教训一致)
- [x] 数据校验在哪做?(子智能体读 frontmatter 时校验:owner 取值域 / 日期可解析性 / 生命周期取值域,§5.1)

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 场景 | 输入条件 | 期望行为 |
|------|---------|---------|
| 文档缺 frontmatter(核心集) | 范围清单内核心集成员,无 `<!-- owner... -->` 行 | 报一条 `kind="缺 frontmatter"`, owner="未知", routeTo="报给用户拍 owner 归属", detail 注明"核心集成员本轮应回填" |
| 文档缺 frontmatter(增量) | 模块 README / 标准件 / agent·skill 契约无 frontmatter | **不逐条进 problems[]**,折叠进 `incrementalNote` 一行汇总(语气温和"可增量采纳",**不刷紧迫感**,§3.1 + §7 S-2) |
| 缺 owner 字段(有其他字段) | 有 frontmatter 但 `owner` 缺 | `kind="孤儿"`, routeTo="报给用户拍 owner 归属" |
| `last-reviewed` 不可解析 | 值非 `YYYY-MM-DD`(全角连字符 / 乱填 / 缺) | `kind="时间腐"`, detail="last-reviewed 不可解析: <原值>", 当作"过期"处理(保守:不能解析 = 不知道多久没看 = 该提醒)。**全角符号特别注意**(check-context-chain 教训:中文 IME 默认全角,机读静默漏)→ detail 明确提示"疑似全角连字符,frontmatter 日期须半角 YYYY-MM-DD" |
| `last-reviewed` 在未来 | today - last-reviewed < 0 | 不报时间腐(未来日期 ≤ N 恒成立);但 detail 可附"日期疑似填错(在未来)"作温和提示, 不升级为问题(软强度) |
| `生命周期: immutable` | 标了 immutable | **跳过时间腐检查**(只查孤儿);不因"日期老"报它 |
| `生命周期` 取值非法 | 非 evolving/immutable | 默认按 evolving 处理(保守纳入时间腐),detail 附"生命周期取值非法: <原值>" |
| 全干净 | 扫完零问题 | 返回 `{clean:true}`, 调度者**不向用户输出任何新鲜度内容**(场景 2) |
| 范围清单为空 / 全仓无活文档 | 极早期空仓 | 返回 `{clean:true}`(无可扫 = 无问题),不报错 |
| 边界正好 N 天 | today - last-reviewed == 90 | `== N` 视为**仍新鲜**(`> N` 才报,与 §4.3 判据 `> N` 一致;边界含义"满 90 天当天不催,第 91 天催") |

### 5.2 错误传播路径

```
[单文件 frontmatter 损坏/不可解析]
   → [子智能体捕获, 不崩整体]
   → [降级为一条 problem(detail 注明解析失败原因)]
   → [继续扫其余文件]
   → [汇总进 ProblemList 回调度者]    ← 不吞错: 解析失败也作为"问题"上报

[子智能体 fork 失败(超时/上下文溢出/工具不可用)]  ← E-1
   → [调度者捕获]
   → [软提醒用户"本会话新鲜度侦察未执行(fork 失败), 下会话重试"]
   → [不阻断会话, 不挡收口]    ← 软强度: fork 失败不是欠账

[子智能体读到范围外文件(误扫)]
   → [按范围清单白名单过滤, 范围外直接跳过, 不报]    ← 防误报
```

**自检**:
- [x] 每个接口的错误情况都有边界条件处理?(fork 失败 / 单文件解析失败 / 全干净 / 空仓,全覆盖)
- [x] 错误传播完整,无吞错?(单文件解析失败不静默丢弃 → 升为一条 problem 上报)
- [x] 用户看到有意义的错误信息?(detail 一句话人话,如"已 107 天"/"疑似全角连字符",非技术堆栈)
- [x] 每个核心场景的异常路径都有边界条件?(场景 1 异常=解析失败/fork 失败;场景 2 异常=空仓也走 clean;场景 3 异常=未来日期)
- [x] **覆盖 frontmatter 每字段极端值?**(owner 缺/非法、last-reviewed 缺/不可解析/未来/全角、生命周期缺/非法,逐一列在 §5.1)

---

## 6. 测试策略

> harness meta 工件,无可跑的单测框架。验证 = **静态核(文档约定一致性 + 双写同步)** + **子智能体行为的 fixture 式验收(干跑一次,人核报告)**。证据档位按 credentials §7「治理改动」列:L1 节内自检全勾 / L2 全局一致性核(双写比对)/ L3 落地后实战(首会话开场实跑)。

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | 验证方式(无 mock,静态/干跑) |
|---------|---------|---------|----------|
| §1.2 场景 1 | 有腐文档时子智能体回出带 owner+routeTo 的问题清单 | 行为(干跑) | 准一份 `last-reviewed` = 100 天前的 fixture 文档 + 一份缺 owner 的 → fork 子智能体 → 人核报告含这两条、kind/owner/routeTo 正确 |
| §1.2 场景 2 | 全干净时静默 | 行为(干跑) | 所有 fixture 都 today + 有 owner → 子智能体回 `{clean:true}` → 调度者无输出 |
| §5.1 缺 frontmatter(核心集) | 核心集成员漏标 → 报"缺 frontmatter" | 行为(干跑) | 临时移除某核心集文档 frontmatter → 子智能体报出该条 |
| §5.1 last-reviewed 全角连字符 | 全角日期 → 报不可解析 + 提示半角 | 行为(干跑) | fixture 填全角 → 报 detail 含"疑似全角" |
| §5.1 边界 == N | 正好 90 天 → 不报 | 静态推演 | 按 `> N` 判据核:90 不报、91 报 |
| §5.2 fork 失败 | 降级软提醒不阻断 | 静态推演 | 核 freshness-scout.md + 根 CLAUDE.md 第 3 步写了降级路径 |
| §8 三处同核拷贝组 | 新鲜度开场步**三处同改**(根 CLAUDE 第 3 步 ↔ 根 AGENTS 新鲜度侦察节 ↔ templates AGENTS 新鲜度侦察节)+ AGENTS×2 结构/语义等价 | 静态核 | **结构/语义等价核(非逐字 diff)**:两份 AGENTS.md 的新鲜度侦察节**同核步骤齐全 + 仅允许路径前缀差异(`harness/` 有无)**——根版带 `harness/` 前缀且多一条凭证义务 bullet 是**合法差异**,逐字 `diff` 恒不为空,故核「同核步骤是否齐全 + 差异是否仅限路径前缀」,不做 literal diff。再核根 CLAUDE.md「会话开场规程」确有第 3 步「开场新鲜度侦察(需 agent 运行时)」(与装载/对账平级、与三处同核);freshness-rules 范围清单 ↔ scout 扫描白名单一致 |
| §8 凭证义务 | freshness-rules.md 落 governance glob 触发 audit 义务 | 静态核 | 核 credentials.conf `docs/governance/*.md audit` 命中,收口产 audit |

### 6.2 测试边界

- **不测什么**:不测漂移检测(不在范围);不测自动修复(不做);不构造跑得起来的 CI 单测(meta 工件无框架,用静态核 + 干跑代替——bootstrap 自举不可证不算缺陷,首会话开场实跑验证,见 design-rules `feedback_unprovable_in_bootstrap`)。
- **外部依赖 mock 策略**:无外部依赖,无 mock。子智能体读真实仓内 Markdown,fixture 用临时文档(验证后删,不污染核心集)。

**自检**:
- [x] 每个核心场景都有对应测试?(场景 1/2/3 各有干跑验收)
- [x] 每个边界条件都有对应测试?(§5.1 关键边界:缺 frontmatter/全角/== N/fork 失败,均列入 6.1)
- [x] 测试层级选择合理?(能静态核的(双写/凭证/边界推演)不干跑;须看子智能体真实判断的(报告内容)才干跑)

---

## 7. 设计决策记录

| 决策 | 选项 | 选择 | 原因(具体可验证) |
|------|------|------|------|
| 开场检查形态 | A: 第四个 bash hook / B: fork 子智能体 | **B** | hook 只能机械查文法(check-context-chain 教训:awk 状态机查 frontmatter 存在性),判不了"这份内容是否该回头看"——新鲜度的"孤儿/缺该有/语气区分核心集vs增量"需读文档语义判断;子智能体更聪明、少误报、能干净静默(用户明确指令 D-4) |
| frontmatter 格式 | A: 新造 YAML / B: 沿用 preferences HTML 注释 | **B** | preferences.md L2 已有现成范本;新造第二套格式违反一致性(RUBRIC)+ 简洁性(造无必要的新约定);HTML 注释渲染不可见、零正文干扰 |
| 子智能体怎么找"活文档" | A: 靠"有 frontmatter"反推 / B: 靠范围清单白名单 | **B** | A 自我消解:核心集成员缺 frontmatter 就永远扫不到(正是要报的"该有却没有"会漏);B 用路径白名单(权威住 freshness-rules)+ frontmatter 存在性双判,缺标签反成可报问题(§4.2) |
| 范围铺开节奏 | A: 一次性回填全仓 / B: 核心集先上 + 增量采纳 | **B** | 守"小而快"(用户锁定 D-2);全仓回填是大工程、易引噪声、违简洁性;核心集 ~10 份先护住最关键的活文档,其余子智能体标缺失、自然长 |
| 强度 | A: 硬阻断 / B: 软提醒 | **B** | 用户锁定 D-7;硬阻断会挡发散/收口(与 check-context-chain 软收尾同哲学:不阻断发散);doc 新鲜不是凭证义务,无需 exit 2 |
| 阈值 N | 30/60/90/180 | **90(初值)** | 用户锁定 D-5「一季度没回头看就提醒」取 90 作**初值**。**90 非实证最优**:首批实战观察(误报率/漏报率/刷屏感)后标定,像 review-scout/research-scout「阈值不写死、实战调」那样处理。**不**把"季度=自然复核节奏"当成立依据(那是便利论证,避 spec_gap_masking)——它只是初值的来源直觉,真值待实战标定。过短刷屏、过长失效是调参方向,非 90 已证最优 |
| 复核动作 | A: 独立复核流程 / B: 推日期(顺手) | **B** | 用户锁定 D-6;独立流程是新工序(违最小变更);推日期搭 owner 确认/收口便车,零额外动作 |
| 规矩住址 | A: 散在 CLAUDE.md / B: 新建 freshness-rules.md | **B** | 用户锁定 D-8;单一权威住址,命中 governance 凭证 glob(改它须 audit),与治理同层化一致(规矩住 governance/) |
| owner 取值 | A: 自由文本 / B: 二分枚举 用户/调度者 | **B** | 用户锁定 D-3;二分定责清晰(谁有权确认还准)+ 可机械路由(§4.3);自由文本无法稳定推 routeTo |
| 子智能体住址 | A: `.claude/agents/freshness-scout.md`(说明型)/ B: custom agent type | **A** | 镜像 research-scout.md / design-reviewer.md 既有形态与**真实同位 `.claude/agents/`**(一致性);harness 扁平 fork 用说明型 agent,调度者读后操作,不引入新 agent 机制(简洁性);命中 `.claude/agents/*.md` 凭证 glob(S-1 已落,见悬空项注) |

> 🟡 **待用户拍板的悬空项**:见本节末「悬空项」段。

### RUBRIC 应对方式(代 RUBRIC = CLAUDE.md 核心规则 + 二公设)

- **简洁性(惩罚项)应对**:复用 preferences 既有 frontmatter(不造新格式)+ 复用扁平 fork(不造新机制)+ 核心集先上(不全仓回填)+ 只接核心集一类消费者(不为未来留一堆口);每条决策都选了"最小变更"那侧(§7 决策表 B 列多为"不新造")。
- **一致性(惩罚项)应对**:frontmatter 与 preferences 逐字一致;子智能体与 research-scout/design-reviewer 同形;范围清单与 check-context-chain 的"半角"教训对齐;不引入第二套元数据/agent 机制。
- **防遗忘靠机制不靠纪律(奖励项)体现**:开场自动 fork(机制兜底)替代"记得回头看"(纪律);`调度者` owner ≈ 无专人 + 机制兜底,诚实写入 rules。
- **做事/判断分开(奖励项·公设 1)体现**:子智能体扫描报问题(做事)严格区别于 owner 判"还准不准"(判断);`用户` owner 文档 AI 不自证。

> **反向追问留痕(防"过度工程化"误判,design-rules `feedback_dimension_addition_judgment`)**:若有人判本机制"过度工程化"——反问"不用 frontmatter 标签 + 开场子智能体,怎么解决'5 天前的地图已腐却无人知'?"。替代解法(纯靠 AI 每次自觉回头看)= 靠纪律,违 CLAUDE.md「防遗忘靠机制不靠纪律」,且公设 1 证 AI 自评不可靠。故本机制是**必要复杂度**,非过度工程化。

### 悬空项(🟡 待用户拍板)

> 均非阻塞性(不影响接口/数据/架构骨架),可在 design-review 后或实现期顺手定;此处显式登记,不静默。

- ✅ **S-1 子智能体说明文件住址(已落地)**:经实测既有 scout 说明实际住 `.claude/agents/`(如 `.claude/agents/research-scout.md` / `design-reviewer.md`),`docs/agents/` 当前不存在。**本 spec 定址 `.claude/agents/freshness-scout.md`**(与 research-scout/design-reviewer 真实同位,命中 `.claude/agents/*.md` 凭证 glob)。§2 模块表 / §4.2 范围清单 / §8 触点已同步落此住址。
- ✅ **S-2 增量类"缺 frontmatter"展示粒度(已落地)**:模块 README / 标准件 / agent·skill 契约缺 frontmatter,定为"温和提示、不算欠账"。为免首次开场一次报一长串,**核心集问题逐条报;增量类"缺 frontmatter"默认折叠为一行汇总**("N 份增量文档可采纳 frontmatter")。已写入 §3.1 出参 / freshness-scout 回报格式(见 §4.2 + §8.1 scout 文件)。

**自检**:
- [x] 每个决策"原因"具体可验证?(引用户锁定编号 / check-context-chain 教训 / 公设,非"更好")
- [x] 有决策与架构冲突?(无;子智能体走扁平 fork,与架构一致)
- [x] 有决策与 RUBRIC 惩罚项冲突?(无;§7 RUBRIC 应对逐条守简洁/一致)
- [x] 不确定的决策都写入并标 🟡?(S-1/S-2 登记;均非阻塞,故 spec 内登记而非另起 decisions 文件——若用户要正式裁决再迁 docs/decisions/)
- [x] §1.6 每个 RUBRIC 惩罚项都有应对?(简洁性 / 一致性,均在"RUBRIC 应对方式"展开)

---

## 8. 与既有系统的影响

### 8.1 需要改动的已有文件

| 文件 | 改什么 | 为什么 | 影响范围 |
|------|-------|--------|---------|
| `/CLAUDE.md`(根) | 「会话开场规程」**新增第 3 步「开场新鲜度侦察(需 agent 运行时)」**(fork 新鲜度侦察,软,与「1.装载 / 2.对账」平级;**不**叫"第 4 步"——对账下挂三命令是子命令非平级步)。**三处同核拷贝组成员之一**(见 §8.1 末「新鲜度开场步三处同改」) | 接线点(D-4) | 命中 `CLAUDE.md` audit glob → 收口产 audit;`<root>/CLAUDE.md` 入 covers |
| `/AGENTS.md`(根) | **另起一节「开场新鲜度侦察(需 agent 运行时)」**——与既有「手工校验(纯人工 / 无 hook 运行时跑对账三命令)」节**并列但分开,不嵌入手工校验段**(理由:手工校验节是「纯人工可跑的 bash」,新鲜度是 fork 子智能体需 agent 运行时,语义不同宿)。只加新节,不碰「手工校验」三命令原文。**三处同核拷贝组成员之一** | M4 分发链开场规程的实际住址(非 harness/CLAUDE 散文) | 命中 `AGENTS.md` audit glob → 收口 covers 写 `<root>/AGENTS.md` |
| `harness/templates/AGENTS.md`(M4 分发模板) | **与根 AGENTS.md 结构/语义等价、同批改**另起「开场新鲜度侦察(需 agent 运行时)」节(同核步骤齐全,仅路径前缀差 `harness/` 有无,§6.1 等价核)。**三处同核拷贝组成员之一** | 分发下游也要有新鲜度侦察节 | 命中 `AGENTS.md` audit glob;`templates/*.md` glob 亦命中;入 covers |
| `harness/docs/governance/credentials-rules.md` §8 | **新增一条双写同步拷贝组「新鲜度开场步三处同改:根 CLAUDE 第 3 步 / 根 AGENTS 新鲜度侦察节 / templates AGENTS 新鲜度侦察节」**(独立于既有 §8 第 5 条「对账命令四处拷贝组」,不并入、不动既有第 5 条) | 三宿主同核须有触点可捕,否则静默漂移(🔴) | 命中 `docs/governance/*.md` audit glob → 收口产 audit;入 covers |
| `harness/CLAUDE.md`(M4 分发模板)核心规则 #11 指针 | **定死(不留"按需")**:#11 现一句指针指向 AGENTS.md「手工校验」;新鲜度步在 AGENTS **另起节**而非塞进手工校验,故 **#11 补半句指针指向「开场新鲜度侦察」节**(只做指针、不复述散文;下游跳 AGENTS 自见新鲜度节) | 指针完整性(非散文拷贝),裁断而非搁置 | 命中 `CLAUDE.md` audit glob;轻改可随 audit |
| `docs/governance/*.md`(各治理文件) | 回填 frontmatter(owner/last-reviewed/生命周期) | 核心集回填(D-2) | 命中 `docs/governance/*.md` audit glob → 收口产 audit(回填本身是 governance 改动) |
| `docs/ARCHITECTURE.md` | 回填 frontmatter | 核心集回填 | 不在现有凭证 glob 内(`docs/ARCHITECTURE.md` 未列 credentials.conf)→ 见 §8.2 凭证缺口注 |
| `docs/RUBRIC.md` | 回填 frontmatter | 核心集回填 | 命中 `docs/RUBRIC.md` audit glob → 收口产 audit |
| `docs/references/README.md`(可选) | 若纳标准件入增量范围,补一句"标准件 frontmatter 复用 freshness 约定"指针 | 与既有"标准件 evolving:owner 保鲜"行衔接 | 不在凭证 glob;轻改,可 exempt |
| `CLAUDE.md` 文档索引 + Skill 地图(根+harness 两份) | 新增 freshness-rules / freshness-scout 索引行(可选,看是否上 Skill 地图) | 可发现性 | 同 CLAUDE.md audit |

**新建文件**(不在"改动"表,但列出供凭证核对 + 递归闭环说明):
- `docs/governance/freshness-rules.md` → 命中 `docs/governance/*.md` audit glob。**自带 frontmatter**(owner=调度者、生命周期 evolving、last-reviewed=创建日)——它落在核心集 governance 范围,本轮即标,免首次开场子智能体把自家规矩报成"缺 frontmatter"。
- `.claude/agents/freshness-scout.md`(S-1 已落住址)→ 命中 `.claude/agents/*.md` audit glob。**自带 frontmatter**(owner=调度者、生命周期 evolving、last-reviewed=创建日)——它落在 `.claude/agents/*.md` 增量范围,本轮即标,故虽在扫描范围内但**不自报**"缺 frontmatter"(递归闭环,§4.2)。

> **递归闭环登记(诚实)**:本机制新建的两份文件自己都落在扫描范围内(rules→核心集 / scout→增量)。处置 = **两份新文件本轮自带 frontmatter**(如上),不靠"将来某次开场再补"。这样首次开场子智能体扫到它们时已合规,不产生"机制刚上线就报自己缺标签"的尴尬闭环。

**新拷贝组登记(🔴 — 须加进 credentials-rules §8)**:本机制的新鲜度开场步**横跨三宿主同核**——根 `CLAUDE.md` 第 3 步 ↔ 根 `AGENTS.md` 新鲜度侦察节 ↔ `harness/templates/AGENTS.md` 新鲜度侦察节,**改一处必同改三处**。原 spec 只把 AGENTS×2 登记为双写对,**漏了根 CLAUDE 第 3 步入同核集** → 静默漂移无触点可捕。处置:

1. **登记为一条新拷贝组**「新鲜度开场步三处同改:根 CLAUDE 第 3 步 / 根 AGENTS 新鲜度侦察节 / templates AGENTS 新鲜度侦察节」,并**加进 `credentials-rules.md` §8 双写同步义务清单**(新增一条,接在既有第 7 条之后)。`credentials-rules.md` 本身命中 governance 凭证 glob(`docs/governance/*.md`),故此改动须随收口产 audit,**入 §8.1 改动表**(本 spec 已列上一行 credentials-rules §8 改动行)。
2. **与既有 credentials §8 第 5 条(finding 所称「§8.5」)「对账命令四处拷贝组」显式区隔**:既有对账拷贝组(根 CLAUDE 开场规程 / 根 AGENTS「手工校验」/ templates AGENTS「手工校验」/ credentials §6)**只锚对账三命令**,本 spec **零改它**(只读不动);新鲜度开场步**另立新拷贝组,不并入对账拷贝组**——两条独立,各管各的同核面。

> **§6 / §8 边界表态(显式写出,不靠读者推)**:credentials-rules **§6(开场对账规程权威)仅管对账三命令**,新鲜度开场步的权威住址 = `freshness-rules.md`(子智能体契约 + 范围 + 判据),**不写入 §6 正文**;**§8 既有四处对账拷贝组(第 5 条)保持锚对账三命令不变**,新鲜度只在 §8 新增独立一条。即:freshness 既不进 §6 正文、也不进 §8 既有对账拷贝组,只在 §8 末另立一条新拷贝组。

### 8.2 不改动但需要验证兼容的

| 文件/模块 | 验证什么 |
|----------|---------|
| `check-handoff.sh` / `check-shelf-registry.sh` / `check-audit-coverage.sh` | **零改**:新鲜度第 3 步与对账(第 2 步)并列,不嵌入、不改这三命令的输入/输出/退出码;改 AGENTS.md×2 时只加新鲜度步、不碰「手工校验」三命令原文(§守住) |
| `check-context-chain.sh` / `check-module-docs.sh` | **零改**:新鲜度不是 hook,不与这俩软提醒重叠;module-docs 管"README 是否同步改",freshness 管"README 是否过期",职责不冲突(可互补,但不耦合) |
| `docs/references/README.md` 过时横幅约定 | **零改**:immutable 留痕件继续用过时横幅,新鲜度范围清单已排除带日期前缀件(§4.2),不重复管(§守住) |
| `credentials-rules.md §5` audit 失效判定 | **零改**:凭证漂移腐已它管,新鲜度不碰 audits(§4.2 排除 + §守住) |
| `docs/preferences.md` 既有 frontmatter | **沿用不改格式**:它是本机制的现成范本,纳入范围即可,不动其 L2 那行(§守住) |

> **凭证缺口注(诚实登记,design-rules `feedback_spec_gap_masking`)**:`docs/ARCHITECTURE.md` 当前**不在** credentials.conf 任一 include glob(governance glob 是 `docs/governance/*.md`,不含 ARCHITECTURE/preferences 以外的 docs 根文件;RUBRIC/preferences 有专行,ARCHITECTURE 无)。后果:给 ARCHITECTURE 回填 frontmatter 这次改动**无强制 audit 义务**(机制不报欠账)。**这不是本 spec 引入的缺口**(既存),**补救方向**:① 本轮回填 ARCHITECTURE frontmatter 可主动连带进同批 governance audit 的 covers(自愿覆盖);② 若用户认为 ARCHITECTURE 该入凭证义务,另起一条 credentials.conf + §2 双写改动(不在本 spec 范围,登记待裁)。本 spec 不擅自扩 credentials glob(那是 credentials 制度改动,需独立 audit)。

**自检**:
- [x] 改动已有文件时所有调用方都考虑到了?(根 CLAUDE 第 3 步;AGENTS.md×2 共享核双写;核心集回填触发各自凭证 glob;两份新文件自带 frontmatter 闭环)
- [x] 新模块和已有模块交互无不兼容?(子智能体与对账三命令并列零耦合;与 module-docs hook 职责不冲突)
- [x] §2 标记"改动"的模块都在这里列了具体改动文件?(开场接线→根 CLAUDE 第 3 步 + AGENTS.md×2 新鲜度侦察节 + harness/CLAUDE #11 指针定死;新拷贝组登记→credentials-rules §8 新增项;核心集→governance/ARCHITECTURE/RUBRIC;凭证触点→§8.1 末 + §8.2 注)

---

## 9. 全局自洽性检查

- [x] **需求 ↔ 模块**:每个需求场景都有模块实现路径?(场景1-2→freshness-scout+开场规程;3→freshness-rules复核约定+finishing顺手推;4→owner二分;5→范围清单增量条目。§2.1 自检已逐场景核)
- [x] **模块 ↔ 接口**:每个模块职责都通过接口体现?无孤岛?(开场规程→fork入参§3.1;子智能体→出参§3.1+数据契约§4.1;freshness-rules→被引指针;无孤岛模块)
- [x] **接口 ↔ 数据**:接口用的数据类型都在数据模型定义了?(fork入参 today/N/scope §4.2-4.3;出参 problems 字段 §3.1 取值域 ↔ frontmatter 三字段 §4.1)
- [x] **数据 ↔ 边界**:每个字段边界值都有处理?(owner缺/非法、last-reviewed缺/不可解析/未来/全角、生命周期缺/非法,§5.1 逐字段列;§4.1 缺失列已标"子智能体怎么判")
- [x] **依赖 ↔ 架构**:模块依赖方向符合架构?(单向 fork+读契约,无环 §2.2;扁平 fork 架构,无两级嵌套)
- [x] **决策 ↔ 需求**:设计决策没偏离需求约束?(§7 决策表 9 项中 7 项直引用户锁定 D-1~D-9,2 项(住址/找活文档)是落地推论,不偏离)
- [x] **决策 ↔ 架构**:决策的架构选择与架构一致?(子智能体=说明型 agent+扁平 fork,与 research-scout/design-reviewer 同;规矩住 governance/,与治理同层化一致)
- [x] **影响 ↔ 模块**:§8 改动文件与 §2 标"改动"模块对应?(开场接线↔根 CLAUDE 第 3 步 + AGENTS.md×2 新鲜度侦察节;核心集 frontmatter↔governance/ARCHITECTURE/RUBRIC;凭证触点↔§8.1/8.2,含**三宿主同核新拷贝组**「根 CLAUDE 第 3 步 / 根 AGENTS / templates AGENTS」+ credentials-rules §8 新增项,与既有对账拷贝组区隔)
- [x] **RUBRIC ↔ 设计**:§7 对每个 RUBRIC 惩罚项都有应对?(简洁性/一致性,代 RUBRIC §1.6 标记 → §7 RUBRIC 应对逐条;反向追问留痕防过度工程化误判)
- [x] **契约 ↔ 接口**:共享类型覆盖所有"端点"?字段命名一致?(无 API 端点,§3.3 写不适用;frontmatter 三字段在 rules/scout/报告/数据模型同名 owner/last-reviewed/生命周期,字段命名一致 §3.3 自检已核)

---

## 守住(显式声明:不破坏现有,逐条对照锁定输入"守住"段)

| 守住对象 | 处置 | spec 落点 |
|---|---|---|
| 对账三命令(check-handoff/check-shelf-registry/check-audit-coverage) | **逐字零改**——新鲜度是新增第 3 步(与对账第 2 步平级)、软、并列,不动这三条子命令的输入/输出/退出码/调用顺序/邻接文本;改 AGENTS.md×2 时**另起新鲜度侦察节**,不碰「手工校验」节三命令原文 | §1.2 机制定位 + §2.2 并列 + §8.2 |
| credentials §8 既有「对账命令四处拷贝组」(第 5 条) | **只读不改**——新鲜度另立新拷贝组并入 §8,不动既有第 5 条对账拷贝组(仍锚对账三命令) | §1.3 接线注 + §8.1 末 |
| references 过时横幅约定 | **零改**——immutable 留痕件继续用过时横幅,新鲜度范围清单排除带日期前缀件,不重复管 | §1.3 不做 + §4.2 排除 + §8.2 |
| audit 失效判定(credentials §5) | **零改**——凭证漂移腐已它管,新鲜度不碰 docs/audits/ | §1.3 不做 + §4.2 排除 + §8.2 |
| preferences.md 既有 frontmatter | **沿用不改格式**——它是本机制现成范本,纳入范围即可,不动其 L2 那行 | §1.3 做 + §4.1 + §8.2 |

## 不做清单(MVP 边界,守"小而快")

| 不做 | 理由 | 留给 |
|---|---|---|
| 漂移检测(文档↔代码不一致) | 需读代码判文档是否还描述对实现,大、需 brainstorm 收敛 | 后续 ★ 设计层子项 |
| 硬阻断(exit 2 挡会话/收口) | 强度=软(D-7);doc 新鲜不是凭证义务 | 不做(永久) |
| 自动修复(LLM doc-gardening 自动改文档内容) | 软强度;改由 owner 决定,子智能体只报不改 | 不做(本轮) |
| 一次性回填全仓 frontmatter | 守小而快;全仓回填大、易引噪声 | 增量采纳(自然长) |

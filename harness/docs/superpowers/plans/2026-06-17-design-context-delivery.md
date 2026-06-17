# C「设计层到手边」(design-context delivery)实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让"代码答不出的"设计层背景(契约/数据/边界/业务规则/坑/残留 why)在写代码/调试/重构时按场景**自动到手边**——建一份机读·设计背景地图 + 一个 fork 侦察员,克隆 ③b drift-scout 形态,复用现有家不新建 wiki。

**Architecture:** 一份机读地图(`design-context-map.md`,一行一业务模块,只指不抄,套 ③a touchpoint-registry 范式)+ 一个说明型 fork 子智能体契约(`design-context-scout.md`,克隆 drift-scout:pull 主动 fork / 读地图两跳 / 按 scenario 取片 / 消化成 briefing / 只读不写 / 全干净静默 / 软降级)+ 治理接线(finishing-rules 入口步 + 保鲜触点登记 + setup.sh 分发 + 两洞模板支撑)。**单向依赖**:治理规则 → 子智能体 → 数据。

**Tech Stack:** Markdown 治理文档 + Claude Code fork 子智能体契约(HTML 注释 frontmatter,非 YAML custom-agent)+ bash 分发脚本。**无运行时代码、无 HTTP API、无数据库**。

> **验证范式适配(harness-meta,非 pytest TDD)**:本功能产物是文档 + fork 契约 + 分发接线,**没有运行时代码可单测**。每个任务的"验证"步 = **静态/结构核**(形态正确 / 接线成对 / 字段一致)+ scout 行为靠 **fixture 红线测**(造有料地图看 scout 递对 briefing / 造无料看 EmptyHanded / 造边界糊看 ⚠️ 不硬猜)。依据锁定 spec §6。无 CI 阻断(harness meta)。
>
> **红线测 scope(对账 spec §6.1 九行,诚实分界)**:T9 做 **fixture 红线两条**(spec §6.2 硬要求):(a) 有料 → scout 递对场景片、gist 不抄代码;(b) 料缺/边界糊 → ⚠️ 不编造不硬猜 + EmptyHanded 闭环。spec §6.1 另三行**不另起 fixture**:`§4.4 三前缀解析`(复用 ③b drift-scout 单源,上游已验)、`§4.5 保鲜触点`(由 T9 Step 1 登记后交 drift-scout 收口凭证批**联测**)、`§5.1 fork 失败/无 agent 降级`(退化路径不可 fixture 模拟,靠 T2 契约 + 静态核确认降级语义在)。**不假装这三行也跑了 fixture**。

**锁定 spec(唯一权威源):** `docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`(§1-§10)。计划任何偏离须回系统设计改 spec,不在计划静默偏离。

---

## 规划决策(本阶段对 spec 显式留待项的裁决 — 带证据)

> spec 把两个"洞"的落地细节显式留给 writing-plans 复核(§8.1 A6 / §8.3 covers #6)。本节据**实读证据**裁决,供后续 design-review / 收口 audit 对账。

### 决策 P-1:洞② `// WHY:` 注释约定 = **采纳但有界(scattered-only)**

- **复核问题(spec §8.1 A6)**:不加 `// WHY:` 注释、仅靠 known-pitfalls-index(留"已关闭"行对照)能否覆盖洞②(残留 why / Chesterton 栅栏)?
- **证据(实读 `docs/references/known-pitfalls-index.md`)**:该索引按**场景**(8 类工作区)组织,列 = `坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度`。**无独立"已关闭"列**(`✅已关闭` 只是 `生命周期` 的一个取值);`来源指针` 解析到**源文档**(ROADMAP/decision-trail/audit/handoff),**从不指向承重墙所在的代码 file:line**。它编目的是 ~30 条**项目级**坑;零散承重墙 guard(bug 修复的边界检查 / 历史兼容分支 / 外部库 quirk 绕过——正是 spec L85 点名的残留 why 来源)**不是项目级坑、永远不会进索引行**。
- **裁决**:**采纳 `// WHY:`,但 scope 收紧到"索引覆盖不到的零散承重墙"**——已编入坑索引的不重复加(避免会腐双写,守 D2 简洁侧)。索引覆盖"已编目"平面,`// WHY:` 覆盖"零散未编目"平面,两不重叠。
- **落地住址**:`docs/governance/implementation-rules.md`(管"写代码那一刻"的规则,正是 guard 被引入的时刻);**不**放 DESIGN_TEMPLATE(高度不对,那是设计阶段;洞② 是 code-time 约定)。
- **凭证影响**:implementation-rules.md 在 `docs/governance/` 下 → **命中 `docs/governance/*.md` 凭证 glob → 进本批 audit covers**(spec §8.1 注/§8.3 已预期"若加,命中对应凭证 glob,纳本批 audit",非偏离)。

### 决策 P-2:洞① DESIGN_TEMPLATE 业务规则段 = **需新增(确定)**;DESIGN_TEMPLATE **进 covers**

- **复核问题(spec §8.3 #6 conditional)**:DESIGN_TEMPLATE 需不需要新「业务规则」段(否则地图「业务规则索引」列无锚可聚)?
- **证据(实读 `docs/references/DESIGN_TEMPLATE.md`)**:扫全部 9 个顶层节,**无任何节承载领域业务规则**——§1.2 是用户向场景叙事(谁→做什么→看到什么)、§1.3 是范围+非功能约束、§7 是设计取舍。地图「业务规则索引」列要指进设计文档却**无稳定锚**。
- **裁决**:**新增 `### 1.7 业务规则`**(领域规则锚,放 §1 末尾不动编号);**§5.1 边界条件表加「理由」列** + 把 `[并发]` 示例行**泛化为 `[并发/同步/排序]`**(地图「并发/同步/排序约束」列要锚"约束 + 为什么有此约束",当前 3 列表装不下理由)。
- **MODULE_DOC_TEMPLATE = 不改**:实读确认 `## 对外接口` / `## 约束和规则` / `## 已知问题和技术债` 三个稳定锚已在,scout 第二跳可定位;**只需地图列注明准确锚名**(全名"已知问题和技术债"非"已知问题"),不改模板。
- **凭证影响**:DESIGN_TEMPLATE.md 被编辑 → **命中 `docs/references/DESIGN_TEMPLATE.md` 凭证 glob → 从「可能」升「必含」进 covers**(spec §8.3 #6)。
- **锚名细化(收口 audit 对账用)**:本计划把业务规则/并发理由锚具体化为 `§1.7业务规则` / `§5.1`,**细化** spec §8.4 B2-1 样板行的 illustrative 名(`业务规则段` / `§5`)——spec §8.3 #6 已授权 writing-plans 定具体节名,T1 地图样板行 / T3 migration / T4 模板三处内部一致,**非 spec↔plan 漂移**。

### 最终 audit covers(8 文件 — 收口须产对抗审查 audit,非 typo 不走 exempt)

1. `.claude/agents/design-context-scout.md`(新建,`.claude/agents/*.md`)
2. `docs/governance/design-context-map.md`(新建,`docs/governance/*.md`)
3. `docs/governance/design-context-migration.md`(新建,`docs/governance/*.md`)
4. `docs/governance/finishing-rules.md`(改,`docs/governance/*.md`)
5. `docs/governance/touchpoint-registry.md`(改,`docs/governance/*.md`)
6. `docs/governance/implementation-rules.md`(改,`docs/governance/*.md`)← **P-1 新增**
7. `setup.sh`(改,`setup.sh`)
8. `docs/references/DESIGN_TEMPLATE.md`(改,`docs/references/DESIGN_TEMPLATE.md`)← **P-2 升格必含**

> `docs/references/MODULE_DOC_TEMPLATE.md` **不改 → 不在 covers**(P-2)。`docs/decisions/*.md`(若 🟡-1/2/3 另立)**不命中凭证 glob**,无 audit 义务。

---

## 文件结构(改动地图)

| 文件 | 责任 | 新建/改 | 任务 |
|------|------|--------|------|
| `docs/governance/design-context-map.md` | 机读地图:模块→设计背景住址索引(**数据契约**+业务模块权威清单);自仓库示意不填数据 | 新建 | T1 |
| `.claude/agents/design-context-scout.md` | fork 侦察员契约:读地图两跳、按 scenario 取片、消化 briefing、只读不写 | 新建 | T2 |
| `docs/governance/design-context-migration.md` | 下游迁移指南:必备 11 类 + 搬进三步(EmptyHanded.seeGuide 指它) | 新建 | T3 |
| `docs/references/DESIGN_TEMPLATE.md` | 洞①:加 §1.7 业务规则锚 + §5.1 理由列 | 改 | T4 |
| `docs/governance/implementation-rules.md` | 洞②:加有界 `// WHY:` 承重墙留痕约定 | 改 | T5 |
| `docs/governance/finishing-rules.md` | 写码/调试/重构入口 pull fork 步 + 保鲜触点登记 | 改 | T6 |
| `docs/governance/touchpoint-registry.md` | 加 TP-14/TP-15 地图保鲜触点(体检来源,无 §8) | 改 | T7 |
| `setup.sh` | scout cp + 地图 basename skip↔守卫 cp **成对** + echo 指引 | 改 | T8 |
| (验证) | 静态核 + fixture 红线测 + drift-scout 自指核 | — | T9 |

**任务顺序依据(planning-rules 契约前置)**:T1 地图 schema = scout 消费 + migration 引用的**数据契约**,排最前;T2 scout 消费地图;T3 migration 引地图+scout;T4/T5 备齐两洞模板锚;T6 finishing 调用 scout;T7 登记地图保鲜;T8 分发(全工件就位后);T9 验证。

---

## Task 1: 建设计背景地图模板(数据契约 + 业务模块权威清单)

**Files:**
- Create: `docs/governance/design-context-map.md`

- [ ] **Step 1: 写地图模板全文**

写入以下完整内容(列头 = scout 消费契约 = 数据契约;只一行示意样板行,自仓库不填真实数据——dogfood 边界):

````markdown
# 设计背景地图(design-context-map)
<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->

> 机读·设计背景地图:一行一**业务模块**,列 = 成员文件 glob(第一跳 file→模块匹配键)+ 各类设计背景**住址指针**(第二跳照拉,**只指不抄**)。本表**就是业务模块的权威清单**(`references/2026-06-10-business-module-map.md` 旧件留痕不升格)。
>
> 被 `.claude/agents/design-context-scout.md` 侦察员消费:进写代码/调试/重构场景 → 调度者 fork 侦察员 → 第一跳 touchedFiles 匹配成员 glob 命中模块 → 第二跳照住址列 Read 源 → 消化成 briefing 到手边。
>
> **dogfood 边界(harness 自仓库)**:自仓库**不填**业务模块数据行(下方仅留示意样板行演示填法);自仓库用 README/现有 specs/decisions 当设计背景,不套本产品式地图。本地图随 `setup.sh` **活文件守卫 cp** 分发到下游,由下游逐模块填。
>
> **怎么填见迁移指南**:`docs/governance/design-context-migration.md`(必备内容 11 类 + 搬进格式三步)。

## 主表

| 业务模块 | 成员文件 glob | 接口契约 | 数据模型 | 模块边界 | 取舍决策 | 不变量约束 | 既知坑/已知问题 | 业务规则索引 | 并发/同步/排序约束 |
|---|---|---|---|---|---|---|---|---|---|
<!-- 示意样板行(填法演示,非真实数据;下游按此格式逐模块填,自仓库不填——dogfood 边界): -->
| 订单 | src/order/**;src/checkout/** | design/order.md:§3 + src/order/README.md:对外接口 | design/order.md:§4 | ARCHITECTURE.md:订单层 + src/order/README.md:职责 | decisions/2025-xx-order-split.md + design/order.md:§7 | ARCHITECTURE.md:订单不变量 + src/order/README.md:约束和规则 | known-pitfalls-index.md:订单 + src/order/README.md:已知问题和技术债 | design/order.md:§1.7业务规则 | design/order.md:§5.1 |
<!-- 怎么填:① 一模块一行;② 成员 glob 指本模块代码文件(多 glob 分号分隔);③ 各列填"文件:锚"住址指针(只指不抄),无料填 —;④ 照 design-context-migration.md B1 清单确保住址真有料;⑤ 残留 why 不进本表列——由侦察员 grep 代码就近 // WHY: 注释拉 -->
````

- [ ] **Step 2: 静态核(结构)**

确认:① 首行是 HTML 注释 frontmatter(`<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->`),非 YAML `---`;② 主表 10 列(业务模块 + 成员文件 glob + 8 设计背景列),列头字面与 scout 契约「按 scenario 取片」表右列**逐字一致**(尤其"既知坑/已知问题""业务规则索引""并发/同步/排序约束");③ 仅 1 行示意样板行 + HTML 注释标"非真实数据";④ dogfood 边界注在;⑤ 残留 why **无列**(注释里说明 scout grep 拉)。

- [ ] **Step 3: Commit**

```bash
git add harness/docs/governance/design-context-map.md
git commit -m "feat: design-context delivery - 新建设计背景地图模板(数据契约 + 业务模块权威清单)"
```

---

## Task 2: 建设计背景侦察员契约(克隆 drift-scout 形态)

**Files:**
- Create: `.claude/agents/design-context-scout.md`
- Reference: `.claude/agents/drift-scout.md`(克隆形态源,尤其「端点路径三前缀解析」节为单源)

- [ ] **Step 1: 写侦察员契约全文**

写入以下完整内容(镜像 drift-scout 形态:HTML 注释 frontmatter / 形态说明四连 blockquote / 只读不写 / 入参出参二态 / 三前缀解析复用单源 / 软降级 / 全角护栏;**字段语义换血**为 Briefing|EmptyHanded 而非 verdict):

````markdown
<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->
你是**设计背景侦察员**(被调度者在进写代码/调试/重构场景时 fork)。你在自己的上下文里读**设计背景地图**(`design-context-map.md`),按场景两跳拉对应的设计背景片,消化成一小段 **briefing** 递回去;**只把有料的递、料缺/边界糊标 ⚠️、完全无料返回空手信号**,不刷主对话。

> **形态说明**:本文件是"侦察员怎么读地图 + 怎么按场景取片 + 怎么消化成 briefing"的说明(与 `drift-scout.md` / `freshness-scout.md` / `research-scout.md` 同类),**不是带 YAML frontmatter tools 的 custom agent type**。调度者读本文件后按扁平 fork 架构操作。
>
> **注**:文件首行的 `<!-- owner... -->` 是新鲜度标签(HTML 注释,渲染不可见),**≠ YAML `---` frontmatter tools 块**,不会被 Claude Code 解析成 custom agent type,不破坏「非 custom agent type」形态约定。
>
> **路径前缀**(本文件路径用下游视角裸 `docs/...` / `.claude/...`;harness 自仓库内 `docs/...` = `harness/docs/...`、`.claude/...` = `harness/.claude/...`;根级 `/CLAUDE.md` · `/AGENTS.md` = 仓库根两份;分发下游去 `harness/` 前缀)。
>
> **判据 / 形态派生自上游契约**:本文件的地图消费判据、按场景取片表、出参二态、端点三前缀解析均**派生自锁定 spec `docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`**(§3/§4/§5)+ 复用 `drift-scout.md` 三前缀解析单源。改契约先改 spec,本文件引指针不另立第二权威。

## 核心边界(只读不写)

- 你只**读**地图 + 各设计背景端点(设计文档/README/ARCHITECTURE/decisions/known-pitfalls-index + 代码 `// WHY:` 注释),**报 briefing**;**不写、不改地图、不产料**(软强度安全边界,守 drift-scout D4 只读不写)。
- 唯一"递料"是把**已有的**设计背景消化成提要;下游**没写**设计文档/README → 你**空手而归**(EmptyHanded),**不编造**(只递已有料,赌注①)。
- 沿 harness 扁平 fork 架构 + 公设 1(做事/判断分开):你拉料消化 briefing = 做事;料怎么用、信不信、要不要据此改 = 判断,归调度者/实现者,不归你。公设 2:不确定时执行外部动作(Read 端点)而非内省。

## 入参契约(调度者 fork 时注入)

```text
入参 = {
  scenario:      "write" | "debug" | "refactor"   // 场景:决定取哪几片设计背景(下方按 scenario 取片表)
  touchedFiles:  ["<正在动/排错/重构的文件路径>", ...]  // 第一跳 file→模块匹配输入(可空:空则整图概览,见边界条件)
  mapPointer:    "docs/governance/design-context-map.md"  // 地图住址(你自 Read,指针不是内容)
  repoRoot:      "<仓库根路径>"                     // 路径前缀解析锚(双层仓 vs 下游单层;复用 drift-scout 三前缀解析)
  today:         "YYYY-MM-DD"                       // 调度者注入(全角护栏 briefing 用;不自取系统时钟避环境漂移)
}
```

## 地图行消费契约 + 两跳

地图主表一行一业务模块,列 = `业务模块 | 成员文件 glob | 接口契约 | 数据模型 | 模块边界 | 取舍决策 | 不变量约束 | 既知坑/已知问题 | 业务规则索引 | 并发/同步/排序约束`。每条数据行(**AI 读,非 awk 切**,对散文住址宽容)理解为:

- `module` = 业务模块名(行标识)
- `memberGlob` = 成员文件 glob(第一跳匹配键,多 glob 分号分隔)
- 8 个设计背景列各填**住址指针**(`文件:锚`)或 `—`(无料)。列名引号包以消歧(列名内 `/` 不是分隔符):`"接口契约"` `"数据模型"` `"模块边界"` `"取舍决策"` `"不变量约束"` `"既知坑/已知问题"` `"业务规则索引"` `"并发/同步/排序约束"`。

跳过表头行(`| 业务模块 |`)、分隔行(`|---|`)、表外散文(AI 读表自然识别,无须机械正则)。

**两跳数据流**:
1. **第一跳(file→模块)**:touchedFiles 逐个匹配各行 memberGlob → 命中业务模块(可多个,跨模块各自命中)。
   - 匹配不上 → ⚠️ "<file> 未匹配到业务模块,模块边界待厘清"(**不硬猜模块**,赌注③)。
   - touchedFiles 空 → 整图概览模式(只回"有哪些业务模块",不给具体片)。
2. **第二跳(模块→住址→料)**:对每个命中模块,按 `scenario` 取片 → 照住址列**解析路径**(三前缀解析)→ Read/grep 源 → 消化成 gist(**只指不抄,代码=SSoT**)。
   - 住址列 `—` 或源料缺 → 该片 ⚠️/skip(**不编造**,赌注①)。
   - 残留 why 片(无地图列)→ grep 代码就近 `// WHY:` **限本命中模块 memberGlob 覆盖的代码文件内**(非全仓)+ 对照 known-pitfalls-index。

## 按 scenario 取片(核心机制)

> 片概念名 ↔ 地图列头字面(出参 `ContextSlice.kind` **取列头字面**直查,不模糊匹配):接口契约→接口契约 / 模块边界→模块边界 / 数据模型→数据模型 / 业务规则→**业务规则索引** / 取舍决策→取舍决策 / 不变量约束→不变量约束 / 并发同步排序约束→**并发/同步/排序约束** / 既知坑→既知坑/已知问题 / 残留 why→(无列,grep 代码 `// WHY:` 限本模块 + known-pitfalls 对照)。

| scenario | 取哪几片 | 对应地图住址列 / 来源 |
|---|---|---|
| **write** | 接口契约 + 模块边界 + 数据模型 + 业务规则 + 并发/同步/排序约束 | 接口契约列 + 模块边界列 + 数据模型列 + 业务规则索引列 + 并发/同步/排序约束列 |
| **debug** | 既知坑/已知问题 + 业务规则 + 数据模型 + 接口契约 + 并发/同步/排序约束 + 残留 why | 既知坑列 + 业务规则索引列 + 数据模型列 + 接口契约列 + 并发/同步/排序约束列 + 残留 why grep(限本模块代码) |
| **refactor** | 模块边界 + 取舍决策 + 不变量约束 + 残留 why(过度抽象护栏) | 模块边界列 + 取舍决策列 + 不变量约束列 + 残留 why(grep 限本模块代码 + known-pitfalls 对照) |

片有交集(数据模型 write/debug 都取等)是 B 表设计、非冗余;按 scenario 取片是**过滤**(不每次拉全 9 类),省得大 wiki 全塞窗。**过度抽象护栏(refactor 专属)** = 残留 why + 取舍决策一起看,让 AI 重构前先问"这层抽象为什么在",防越改越抽象 / 防瞎删承重墙。

## 出参契约(二态)

```text
出参 = Briefing | EmptyHanded

EmptyHanded: { delivered: false,
               reason: "<一句话>",                    // 如"地图无对应模块行" / "住址料全缺,下游未写设计文档/README" / "地图读不到"
               missingKinds: ["<本场景该取却缺的片>", ...],  // 本 scenario 取片子集里缺的(≠ B1 全 11 类)
               seeGuide: "docs/governance/design-context-migration.md 下游迁移指南" }
            // 空手态 = 地图无对应模块行 / 住址料全缺 / 地图读不到
            //   → 调度者一句话提示,不刷屏(沿 drift-scout/freshness 全干净静默惯例),不阻断写码

Briefing:   { delivered: true,
              scenario: "write" | "debug" | "refactor",
              modules:  [ ModuleBrief, ... ],          // 第一跳命中的业务模块(可多)
              unsure:   [ "<file 未匹配模块 / 住址料缺>", ... ],  // ⚠️ 逐条(不硬猜)
              summary:  "<一行:N 模块 briefed / M ⚠️>" }
            // 概览态复用 Briefing(touchedFiles 空):delivered:true,modules[] 装"有哪些业务模块"
            //   (各 ModuleBrief.matchedFiles 空、slices 空),summary 注"未传 touchedFiles,仅概览";不另立第三态

ModuleBrief = {
  module:        "<业务模块名>"
  matchedFiles:  ["<touchedFiles 中落本模块 glob 的>", ...]
  slices:        [ ContextSlice, ... ]                 // 按 scenario 取的片
  endpointsRead: ["<第二跳实际 Read/grep 的 文件:锚>", ...]  // 读源留痕(防判松无据/可复核;镜像 drift-scout endpointsChecked)
}

ContextSlice = {
  kind:     "接口契约" | "模块边界" | "数据模型" | "业务规则索引" | "取舍决策"
          | "不变量约束" | "并发/同步/排序约束" | "既知坑/已知问题" | "残留 why"
            // kind 字面 = 地图列头字面;「残留 why」是唯一无地图列特例(grep 代码 // WHY: 限本模块 + known-pitfalls 对照)
  pointer:  "<住址指针:文件:锚>"                       // 照地图住址列,只指不抄;残留 why 特例 = grep 命中的 代码文件:行 + known-pitfalls 对照锚
  gist:     "<一两句要点>"                              // 读源消化的提要(非复制原文/代码)
  note:     "<可空:料缺/全角/定位不准 → ⚠️ 说明>"
}
```

- 你两跳完成后**一次性返回**(不流式、不中途刷主对话)。

## 端点路径三前缀解析(复用 drift-scout 单源)

> 读地图住址列 / 端点文件时,路径混三类前缀(裸相对 `docs/...`·`.claude/...` / `<root>/` sentinel / `harness/...`)。**解析规则 + 判定顺序 + `<root>/` 不加 `harness/` 护栏完全复用 `.claude/agents/drift-scout.md` 的「## 端点路径三前缀解析(操作指引)」节为单源权威,本文件不另立第二套**:
> - **先判 `<root>/` 前缀**(剥 sentinel 挂 repoRoot 根,**不**加 `harness/`)、**再判 `harness/` 前缀**(直接挂根,不二次加)、**先于**裸相对路径的双层仓补 `harness/` 逻辑;
> - 解析后**读不到** → 标 ⚠️ + `endpointsRead` 留痕(不假装料缺,可能解析错前缀,让调度者复核)。

> **全角护栏**(沿 freshness-scout / drift-scout 实证):读住址锚时疑似含全角 `｜ ： ， 「 」` 且因此定位不到 → 该片 detail 附"疑似全角符号,住址锚约定半角",标 ⚠️,不静默漏。

## 报告分层 vs 全干净静默

- **EmptyHanded(全干净静默)**:地图无对应模块行 ∨ 住址料全缺 ∨ 地图读不到 → 返回 `EmptyHanded{reason, missingKinds, seeGuide}` → 调度者只输出一句话,不刷长报告。
- **Briefing(有料分层)**:正常片进 `modules[].slices`(kind+pointer+gist,**gist 一两句要点不抄代码**);⚠️(file 未匹配 / 住址料缺 / 定位不准)进 `unsure[]` 逐条,不硬猜不静默漏。

## 边界条件(逐条)

- **地图读不到**(不在 / Read 失败)→ `EmptyHanded{reason:"地图读不到"}` → 软提醒,不阻断。
- **地图空表 / 无模块行**(自仓库 dogfood 边界 / 下游未填)→ `EmptyHanded{reason:"地图无模块行(自仓库 dogfood 边界 / 下游未填)"}` → 不报错。
- **touchedFiles 空** → 整图概览模式:`modules[]` 装"有哪些业务模块"(matchedFiles/slices 空),summary 注"未传 touchedFiles,仅概览"。
- **第一跳匹配不上**(赌注③)→ 该 file 进 `unsure[]` ⚠️ "未匹配到业务模块,模块边界待厘清",**不硬猜模块**。
- **第二跳住址料缺**(赌注①)→ 该片 ⚠️/skip,detail "下游未写<该类>设计背景,见 `design-context-migration.md` 该类住哪/怎么补";**不编造**(missingKinds + seeGuide 闭环)。
- **住址指针失效**(锚已改名/删)→ 该片 ⚠️ "住址指针失效,见 drift-scout 收口检测";漂移由 drift-scout 收口逮。
- **描述性住址锚定位不到** → 该片 ⚠️ "住址锚为描述性,未定位到实际内容,需人核"(同 drift-scout 死结一处理,不误判料缺)。
- **全角符号污染住址锚** → 该片 ⚠️ "疑似全角符号,住址锚约定半角"。
- **touchedFiles 跨多模块** → `modules[]` 多条,各模块各自取片(不合并,让调度者看清跨模块)。
- **全无料**(无对应模块行 ∧ 住址料全缺)→ `EmptyHanded{missingKinds, seeGuide}`,不刷屏。

## 错误传播 + fork 失败降级

- **单 file 未匹配模块 / 单片住址料缺/失效** → 该 file/片 ⚠️ + detail + `endpointsRead` 留痕 → 收集进 briefing → **不中断其余**(不吞错:解析/料缺也作"问题"上报)。
- **单片正常** → `ContextSlice` gist+pointer → 进 `modules[]` → 调度者据此写码/调试/重构。
- **fork 失败(超时 / 上下文溢出 / 工具不可用)** → 调度者捕获 → 软提醒"本次设计背景未拉(fork 失败)" → **回落 AI 自读代码(本机制上线前的原状)**,不阻断写码、不算欠账(软强度)。

## 需 agent 运行时(诚实降级)

- 本侦察须 fork 子智能体(需 agent 运行时,纯人工跑不了)。
- **无 agent 运行时则跳过 design-context-scout**,软提醒 + 回落 AI 自读代码(诚实降级,同 drift-scout/freshness);**不阻断写码/收口、不算欠账**(软强度,对称 fork 失败行)。
- 关键诚实:fork 失败/无 agent 时回落"自己读代码" = 本机制上线前的原状——本机制是**增量**(读不全风险残留,赌注②),不引入新退化。

## 触发起源 + 设计依据

本能力 2026-06-17 加入,属知识系统 Step2 ★ 主项 C「设计层到手边」。**触发点 = pull 主动 fork**:进写代码/调试/重构场景时,调度者按 `docs/governance/finishing-rules.md`「设计背景到手边(写码/调试/重构入口)」节 fork 本侦察员(非 push hook,无强制力,赌注②)。设计经 brainstorming 收敛 + 用户锁定,依据见锁定 spec `docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`(§3.1 入参/出参 / §4.1 地图消费 / §4.3 按场景取片 / §4.4 三前缀解析 / §5 边界与错误)。形态范式复用 `drift-scout.md`(只读不写 / 二态出参 / 全角护栏 / 软降级 / 三前缀解析单源)。
````

- [ ] **Step 2: 静态核(形态 + 字段一致)**

确认:① 首行 HTML 注释 frontmatter,**全文无 YAML `---` 块**(否则被 Claude Code 解析成 custom agent type);② 形态说明四连 blockquote 在;③ 入参 5 字段(scenario/touchedFiles/mapPointer/repoRoot/today)、出参二态(Briefing|EmptyHanded)字段名与 spec §3.1 **逐字一致**;④ `ContextSlice.kind` 9 取值与地图列头(T1)+ 按 scenario 取片表右列**逐字一致**;⑤ 三前缀解析是**引 drift-scout 单源**(不复制正文)且写明判定顺序;⑥ 三软降级块(fork 失败 / 无 agent / 全角护栏)在。

- [ ] **Step 3: Commit**

```bash
git add harness/.claude/agents/design-context-scout.md
git commit -m "feat: design-context delivery - 新建设计背景侦察员契约(克隆 drift-scout 形态)"
```

---

## Task 3: 建下游迁移指南

**Files:**
- Create: `docs/governance/design-context-migration.md`

- [ ] **Step 1: 写迁移指南全文**

写入以下完整内容(B1 必备 11 类 + B2 搬进三步 + B2-3 空手闭环 + missingKinds vs B1 消歧 + 洞② 边界):

````markdown
# 下游迁移指南:设计背景到手边(design-context-migration)
<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->

> **给谁**:用 harness 的下游项目。本指南教你把已有项目的设计背景**搬进** `design-context-map.md` 地图格式,让设计背景侦察员(`design-context-scout`)能在你写代码/调试/重构时按场景把它们拉到手边。
>
> **为什么**:侦察员**只递已有的**设计背景——你没写,它就空手而归(EmptyHanded),不替你编造。本指南 = 必备内容清单(照着补)+ 搬进格式三步(照着填),把"赌你写了"变"给你可勾清单 + 可填模板"。
>
> **只读指南**:本文件随 governance `*.md` 无条件分发,下游不必改它;改的是你的 `design-context-map.md`(活文件,守卫式分发,你填)。

## B1. 必备内容清单(11 类 — 设计层"代码答不出的那层")

> 每类标"住哪 / 哪个 harness 模板"。照模板写齐 → 侦察员第二跳照地图住址即能拉到。**11 类里 9 类 harness 现成模板已给位置,真要新加约定的只有 2 条(业务规则段 + `// WHY:` 注释)。**

| 必备内容 | 住哪 / 模板 | 现成 / 新约定 |
|---|---|---|
| 意图 / 真问题 | 设计文档 §1 | 现成(DESIGN_TEMPLATE) |
| 数据库 / 数据模型(实体 / schema / 状态) | 设计文档 §4 | 现成(DESIGN_TEMPLATE) |
| 接口契约 | 设计文档 §3 + 模块 README「对外接口」 | 现成(DESIGN_TEMPLATE + MODULE_DOC) |
| 业务流程 / 业务规则 | 设计文档 §1 场景 + **§1.7 业务规则段** | **新约定(洞①)** |
| 模块边界 / 职责 / 依赖 | ARCHITECTURE + 模块 README「职责」 | 现成(ARCHITECTURE + MODULE_DOC) |
| 设计决策 / 取舍 | decisions/ + 设计文档 §7 | 现成 |
| 不变量 / 硬约束 | ARCHITECTURE + 模块 README「约束和规则」 | 现成(ARCHITECTURE + MODULE_DOC) |
| 非功能约束(性能 / 安全 / 合规) | 设计文档 §1.3 / §7 | 现成 |
| 并发 / 同步 / 排序约束 | 设计文档 §5.1(含「理由」列) | 现成(DESIGN_TEMPLATE §5.1 理由列) |
| 已知坑 / 技术债 | known-pitfalls-index + 模块 README「已知问题和技术债」 | 现成 |
| 残留 why(承重墙) | 代码就近 **`// WHY:` 注释** | **新约定(洞②;有界,见 `implementation-rules.md`)** |

> **关键认知**:9 类靠现成模板(DESIGN_TEMPLATE / MODULE_DOC / decisions/ / 坑索引)照填即有;2 类是本设计补的两个洞(业务规则段 + `// WHY:` 注释)。这印证"复用现有家不新建 wiki":绝大多数内容现成有家,只补 2 洞 + 1 张索引地图。

## B2. 搬进格式三步

**第一步:按业务能力切业务模块**(不按材料切)。
- 顶层切法 = 业务能力(订单 / 支付 / 库存…),**不是**按材料属性切(触发/知识/状态是模块内部的面,不是顶层模块)。
- 每模块定**成员文件 glob**(指本模块的代码文件,多 glob 分号分隔)。

**第二步:一模块一行填地图**(`design-context-map.md`)。
- 各设计背景列指向你的设计文档 / 模块 README / ARCHITECTURE / decisions / 坑索引(**住址指针 `文件:锚`,只指不抄**);该类暂无料填 `—`。
- 列名↔住址对照(地图列头):接口契约→设计§3+README「对外接口」 / 数据模型→设计§4 / 模块边界→ARCHITECTURE+README「职责」 / 取舍决策→decisions+设计§7 / 不变量约束→ARCHITECTURE+README「约束和规则」 / 既知坑/已知问题→坑索引+README「已知问题和技术债」 / 业务规则索引→设计§1.7业务规则 / 并发/同步/排序约束→设计§5.1。

**第三步:照 B1 清单确保那些住址真有料**。
- 侦察员只递**已写的**:契约写进 README「对外接口」、业务规则写进设计文档 §1.7、承重墙加 `// WHY:` 注释(有界,见下)。
- 缺哪类 → 对照 B1 去补;补完地图住址就有料可拉。

## B2-3. 空手闭环(EmptyHanded)

侦察员空手时 reason **不只说"没料"**——带 `missingKinds`(本次该场景缺哪几片)+ `seeGuide`(指本指南)。你据此知道"缺哪类、去哪补"。

> **`missingKinds` vs B1 11 类(消同名歧义)**:`missingKinds` = 本次那个 scenario **该取却缺的可递片**(write/debug/refactor 各取片子集,见侦察员契约「按 scenario 取片」),**不是 B1 全 11 类**;B1 11 类是"下游整体该补哪些设计层内容"的更广全清单(含意图/非功能等侦察员各场景不拉的)。空手时侦察员报 missingKinds(本场景视角),你按 seeGuide 跳本指南看 B1 全清单(全局视角)补料。

## 洞② `// WHY:` 注释的边界(别过度加)

残留 why 的 `// WHY:` 是**有界**约定(详 `docs/governance/implementation-rules.md`「承重墙留痕」):只对**承重墙 / 非显然 guard** 且**理由不在 known-pitfalls-index 里**(零散未编目)的,才就近加 `// WHY: 防[X],见[路径]`;理由已编入坑索引的**不重复加**。不是给每个 if 加注释。
````

- [ ] **Step 2: 静态核**

确认:① 首行 HTML 注释 frontmatter;② B1 表 11 行,"住哪"列锚名与 T1 地图列、T4 DESIGN_TEMPLATE §1.7/§5.1、MODULE_DOC 实际锚名(对外接口/约束和规则/已知问题和技术债)一致;③ B2-3 的 `missingKinds`/`seeGuide` 字面与 T2 scout 出参 `EmptyHanded` 字段**逐字一致**;④ seeGuide 指向本文件路径,不指根 README。

- [ ] **Step 3: Commit**

```bash
git add harness/docs/governance/design-context-migration.md
git commit -m "feat: design-context delivery - 新建下游迁移指南(必备 11 类 + 搬进三步)"
```

---

## Task 4: DESIGN_TEMPLATE 洞① — 加 §1.7 业务规则锚 + §5.1 理由列

**Files:**
- Modify: `docs/references/DESIGN_TEMPLATE.md`(§1 末尾加 1.7;§5.1 加列)

- [ ] **Step 1: §1 末尾加 §1.7 业务规则**

在 §1.6 RUBRIC 风险标记的「自检」块之后、§1 结束的 `---` 之前,插入:

````markdown
### 1.7 业务规则（领域规则 — 地图「业务规则索引」列锚）

> 本节是设计背景地图（`design-context-map.md`）「业务规则索引」列指向的**稳定锚**：把本功能的领域业务规则单源写在这里，地图只聚锚成索引（只指不抄）。

- [规则1]：[领域约束 / 校验逻辑 / 不变量，用业务语言。如"订单金额必须 > 0"、"已支付订单不可改收货地址"]
- [规则2]：...

**自检**：
- [ ] 业务规则是"领域为什么这么要求"，不是"代码怎么实现"（实现细节留给代码，本节是规则源）？
- [ ] 写代码/调试场景需要知道的领域约束都在此（侦察员 write/debug 场景会拉本节）？
````

- [ ] **Step 2: §5.1 边界条件表加「理由」列 + 泛化并发行**

把 §5.1 当前的表(header + 分隔 + 三示例行)替换为带「理由」列、并发行泛化为「并发/同步/排序」的版本:

````markdown
| 场景 | 输入条件 | 期望行为 | 理由（为什么有此约束 — 地图「并发/同步/排序约束」列锚） |
|------|---------|---------|--------------------------------|
| [空输入] | [描述] | [系统做什么] | [为什么] |
| [超限] | [描述] | [系统做什么] | [为什么] |
| [并发/同步/排序] | [描述] | [系统做什么] | [为什么有此并发/同步/排序约束 — 侦察员 write/debug 场景拉本行理由] |
````

- [ ] **Step 3: 静态核**

确认:① §1.7 标题字面 = `### 1.7 业务规则`(与地图样板行 `design/order.md:§1.7业务规则` + migration B1/B2 对照一致);② §5.1 表 4 列、并发行已泛化为「并发/同步/排序」、「理由」列锚与地图「并发/同步/排序约束」列对照一致;③ 未动 §2-§9 编号(最小变更)。

- [ ] **Step 4: Commit**

```bash
git add harness/docs/references/DESIGN_TEMPLATE.md
git commit -m "feat: design-context delivery - 洞① DESIGN_TEMPLATE 加 §1.7 业务规则锚 + §5.1 理由列"
```

---

## Task 5: implementation-rules 洞② — 加有界 `// WHY:` 承重墙留痕约定

**Files:**
- Modify: `docs/governance/implementation-rules.md`(「## 实现行为约束」节内)

- [ ] **Step 1: 在「简洁性自检」子节后、「## 提交规范」前,插入新子节**

````markdown
### 承重墙留痕（`// WHY:` 注释 — 残留 why，有界）

> 设计背景侦察员（`design-context-scout`）在重构/调试场景会 grep 代码就近 `// WHY:` 注释拉"这段为什么在"（防瞎删承重墙 / Chesterton 栅栏）。配合此机制，落一条**有界**约定：

- **承重墙 guard 留痕**：写下一个**承重墙 / 非显然的 guard**（bug 修复的边界检查 / 历史兼容分支 / 外部库 quirk 绕过等，"删了会回归但看着多余"的那种），且**该 guard 的理由不在 `known-pitfalls-index` 里**（零散、未编入坑索引）→ 就近加一行 `// WHY: 防[X]，见[路径]`。
- **不重复（守 D2 简洁侧）**：若该 guard 的理由**已是** `known-pitfalls-index` 的一行（已编目的坑）→ 坑索引那行即够，**不再加 `// WHY:`**（避免同一理由两处维护的会腐双写）。即：坑索引覆盖"已编目"平面，`// WHY:` 覆盖"零散未编目"平面，两者不重叠。
- **边界**：`// WHY:` 是**软约定**（只对承重墙、只对索引覆盖不到的零散 guard），**不是给每个 if 加注释**；它服务"重构/调试时 AI 能就地看到为什么不能删"，不替代设计文档 / 坑索引。
````

- [ ] **Step 2: 静态核**

确认:① 子节落在「## 实现行为约束」内(与最小变更/孤儿代码/简洁性同级);② 约定是**有界**(scattered-only + 不与坑索引重复),与规划决策 P-1 一致;③ `// WHY: 防[X],见[路径]` 格式与 T2 scout「残留 why grep」+ T3 migration 洞② 边界段、spec §1.5 一致。

- [ ] **Step 3: Commit**

```bash
git add harness/docs/governance/implementation-rules.md
git commit -m "feat: design-context delivery - 洞② implementation-rules 加有界 // WHY: 承重墙留痕约定"
```

---

## Task 6: finishing-rules 写码/调试/重构入口步 + 保鲜触点登记

**Files:**
- Modify: `docs/governance/finishing-rules.md`(在「### 触点漂移检测」节之后、「### decision 立档」之前插入新 `###` 节)

- [ ] **Step 1: 插入新 `###` 节(承「凭证义务核对」父节步号,接 21 后为 22-24)**

在「21. **软、不阻断**…」行之后、「### decision 立档(若有架构决策)」之前,插入:

````markdown
### 设计背景到手边(写码/调试/重构入口)

> 进**写代码 / 调试 / 重构**场景时,设计层背景(契约/边界/数据/业务规则/坑/残留 why)按场景**pull 拉到手边**——调度者主动 fork `design-context-scout` 读设计背景地图、按 scenario 取片、消化成 briefing。**软、只读不写、不阻断**;pull 主动 fork 无 push 强制力(赌注②:AI 得记得 fork)。契约详 spec `docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`(§3.1/§4.3/§5)。

22. **需 agent 运行时** → 进写码/调试/重构场景,调度者 fork `design-context-scout`(契约 `.claude/agents/design-context-scout.md`),注入 `{scenario: write|debug|refactor, touchedFiles: [正在动的文件], mapPointer: docs/governance/design-context-map.md, repoRoot, today}` → scout 读地图两跳(file→业务模块 glob→各设计背景住址)、按 scenario 取片、照住址 Read 源消化成 briefing → 返回 `Briefing`(modules[].slices: kind+pointer+gist / unsure[] ⚠️)或 `EmptyHanded`(料缺,带 missingKinds + seeGuide)。
23. 消费 briefing:据 `slices` 的 pointer/gist 写码/调试/重构;**⚠️**(file 未匹配模块 / 住址料缺 / 定位不准)→ 复核模块边界 / 推下游补料(对照 `docs/governance/design-context-migration.md`)/ 人核;**EmptyHanded** → 一句话提示(料缺/未匹配),继续,**不阻断**(赌注① 暴露面:下游未写设计文档/README)。
24. **软、不阻断、只读不写**:scout 只读地图+端点、报 briefing,不写不改地图;**无 agent 运行时 / fork 失败** → 软提醒"本次设计背景未拉" + **回落 AI 自读代码**(本机制上线前的原状,诚实降级,同 drift-scout/freshness),不阻断、不算欠账(软强度)。

> **保鲜闭环(地图登记成触点)**:`design-context-map.md` 是活文档会腐——已登记进 `docs/governance/touchpoint-registry.md`(地图住址漂移点 + 成员 glob 漂移点,类型=漂移点(spec↔代码),判据=存在性 + 单源派生一致),由 drift-scout 收口凭证批逮地图指针失效 / 成员漂移 + 人工触点完整性维兜(spec §4.5)。登记是机制落地时的**一次性动作**(非每次收口重做)。
````

- [ ] **Step 2: 静态核**

确认:① 新节是 `### ` 同级,落在「凭证义务核对」父节内(line 132 `---` 之前)、「触点漂移检测」(步 19-21)之后、「decision 立档」之前;② 步号续 22-24(承父节运行计数);③ 注入参数 5 字段与 T2 scout 入参逐字一致;④ 保鲜闭环 note 与 T7 touchpoint TP-14/15 描述一致(类型/判据)。

- [ ] **Step 3: Commit**

```bash
git add harness/docs/governance/finishing-rules.md
git commit -m "feat: design-context delivery - finishing-rules 加写码/调试/重构入口 pull 步 + 保鲜触点登记"
```

---

## Task 7: touchpoint-registry 加 2 行地图保鲜触点(体检来源,无 §8)

**Files:**
- Modify: `docs/governance/touchpoint-registry.md`(在 TP-13 行之后、「## 维护」之前加 TP-14/TP-15)

> **drift-scout「13」计数 deferral(用户 2026-06-17 拍板,plan-review 🟡 #2)**:加 TP-14/15 后注册表 15 行,但 `drift-scout.md` 4 处 illustrative「13 触点」(L2/L24/L48/L146)会变 stale。drift-scout 检测 **count-agnostic**(L85-87 不依赖 13),功能不受影响;**本批按 spec §10.1「drift-scout 零改」不动 drift-scout**(只动注册表加行)。"13 计数 count-agnostic 化"**单独一批后改**——已登记 `docs/references/known-pitfalls-index.md`「文档健康/反腐烂」组(待办,⚪)。

- [ ] **Step 1: 加 TP-14 + TP-15**

在 TP-13 行(line 34)之后、`## 维护`(line 36)之前插入:

````markdown
| TP-14 | 漂移点(spec↔代码) | `docs/governance/design-context-map.md` 各业务模块行的设计背景住址指针列(接口契约/数据模型/模块边界/取舍决策/不变量约束/既知坑/业务规则索引/并发约束);各指针指向的设计文档/README/ARCHITECTURE/decisions/坑索引实际锚 | 存在性(地图住址指针指向的锚还在不在;指针失效=漂移) | 体检2026-06-17 | 待③b查 |
| TP-15 | 漂移点(spec↔代码) | `docs/governance/design-context-map.md` 各行成员文件 glob;被指向的实际业务模块代码文件成员 | 单源派生一致(地图 memberGlob 还覆盖不覆盖实际模块成员;成员漂移=地图边界腐化) | 体检2026-06-17 | 待③b查 |
````

- [ ] **Step 2: 静态核(不破 TP-13 计数 + 顺序)**

确认:① 两行类型/判据取值在表头 enum 内(类型=`漂移点(spec↔代码)`;判据=`存在性`/`单源派生一致`);② **来源=`体检2026-06-17`(无 §8 backing)**——与 TP-09~12 体检来源同组,**不破 TP-13 的 §8⊆本表计数**(§维护 line 39:体检来源行不要求计数相等);③ 现状=`待③b查`(MVP 只建数据);④ 先确认源(本 spec / T1 地图)再登本表,顺序未反(§维护 line 38);⑤ TP-14/15 端点描述与 T6 finishing 保鲜 note + spec §4.5 一致。

- [ ] **Step 3: Commit**

```bash
git add harness/docs/governance/touchpoint-registry.md
git commit -m "feat: design-context delivery - touchpoint-registry 加 TP-14/15 地图保鲜触点"
```

---

## Task 8: setup.sh 分发(scout cp + 地图 skip↔守卫 cp 成对 + echo)

**Files:**
- Modify: `setup.sh`(agents cp 段 + governance 循环段 + echo 段)

> **carry-forward 🟡 红线(必钉死)**:地图排除出 governance 无条件循环的 `basename skip` 必须与活文件守卫 cp(`if [ ! -f ]`)**成对**——漏 skip = 重装覆盖下游已填地图;漏守卫 = 地图不分发空转。Step 2 两改一并做,Step 4 静态核成对验。

- [ ] **Step 1: agents 逐 cp 段加 scout cp 行**

在 `cp "$SCRIPT_DIR/.claude/agents/drift-scout.md" "$TARGET_DIR/.claude/agents/"`(当前末行,约 line 52)之后追加一行:

```bash
cp "$SCRIPT_DIR/.claude/agents/design-context-scout.md" "$TARGET_DIR/.claude/agents/"
```

- [ ] **Step 2: governance 循环段加地图 basename skip + 成对活文件守卫 cp**

把当前 governance 循环段(约 line 103-107):

```bash
# governance:全量分发(治理同层;credentials-rules.md 随 *.md 自然拷入)
for gov in "$SCRIPT_DIR/docs/governance/"*.md; do
    [ -e "$gov" ] || continue
    cp "$gov" "$TARGET_DIR/docs/governance/"
done
```

替换为(加 basename skip + 紧随成对守卫 cp):

```bash
# governance:全量分发(治理同层;credentials-rules.md 随 *.md 自然拷入)
for gov in "$SCRIPT_DIR/docs/governance/"*.md; do
    [ -e "$gov" ] || continue
    [ "$(basename "$gov")" = "design-context-map.md" ] && continue   # 活文件(下游逐模块填),守卫单独 cp,不无条件覆盖
    cp "$gov" "$TARGET_DIR/docs/governance/"
done
# 设计背景地图:活文件守卫(I7)— 下游逐模块填,已存在不覆盖(与上方 basename skip 成对:漏 skip=重装覆盖下游已填地图 / 漏守卫=地图不分发空转)
if [ ! -f "$TARGET_DIR/docs/governance/design-context-map.md" ]; then
    cp "$SCRIPT_DIR/docs/governance/design-context-map.md" "$TARGET_DIR/docs/governance/" 2>/dev/null || true
fi
```

- [ ] **Step 3: echo 段加迁移指引(在末行 line 157 之后)**

在最后一行 `echo "    harness 治理流程不依赖此工具在场,不装也能正常工作"` 之后追加:

```bash
echo ""
echo "🗺️  设计背景地图:进写码/调试/重构时,AI 可 fork design-context-scout 把设计层背景按场景拉到手边。"
echo "    已有项目搬进地图格式见 docs/governance/design-context-migration.md(必备内容 11 类 + 三步)。"
```

- [ ] **Step 4: 静态核(成对 + 无冗余 cp)**

确认:① scout cp 行在 agents 逐 cp 段(与 drift-scout/freshness-scout 同形);② **basename skip 与守卫 cp 成对在**(两者缺一即红线);③ 守卫 cp 源 = `$SCRIPT_DIR/docs/governance/design-context-map.md`(**governance 文件自身即单源示意模板**——dogfood 边界 = 只列头+一行示意,无真实数据;**有意不另建 `templates/` 种子**,与 handoff/index/context 守卫从 `templates/` 取种子不同,因地图住址锁 governance、自身即模板;未来维护者勿"修正"成 templates/ 种子);④ **migration / implementation-rules / finishing-rules / touchpoint-registry 不另加 cp**(随 governance 无条件循环已分发,且**不**被 basename skip 排除——只地图被排除);⑤ DESIGN_TEMPLATE 仍走 line 127 既有 cp(不动);⑥ echo 指向 migration 文档,不指根 README。

- [ ] **Step 5: bash 语法核 + Commit**

```bash
bash -n harness/setup.sh    # 期望:无语法错(exit 0,无输出)
git add harness/setup.sh
git commit -m "feat: design-context delivery - setup.sh 分发 scout + 地图守卫 cp(skip 成对)+ echo 指引"
```

---

## Task 9: 验证 — 静态核汇总 + fixture 红线测 + drift-scout 自指核

> 本任务是 harness-meta 验收(无运行时单测)。**不提交 fixture 为仓库数据**(dogfood 边界:自仓库不建地图数据 — spec §10.2);fixture 是一次性红线脚手架,验完丢弃。

- [ ] **Step 1: drift-scout 自指漏分发核(setup.sh TP-09)**

确认 `setup.sh` 已加 `design-context-scout.md` cp 行——否则 drift-scout 收口 TP-09(分发链 glob 覆盖)会报 🔴(新 agent 命中 `.claude/agents/*.md` 逐 cp 行类凭证 glob 却无 cp)。核:scout cp 行在,地图守卫 cp + skip 成对在。**地图 TP-09 不误报**:`design-context-map.md` 属 `docs/governance/*.md` **循环分发类**——TP-09 判据 = "有覆盖该 glob 的通配 for 循环段:有 → ✅"(drift-scout.md L130 死结二:不逐文件 cp 行也不误报 🔴),basename skip 在循环**体内**、for 循环段仍在,故 TP-09 见循环存在判 ✅,不因 skip 误报漏分发。

- [ ] **Step 2: fixture 红线测(a)有料 → 递对片,gist 不抄代码**

造临时 fixture(不提交):一份 fixture 地图(1-2 模块,成员 glob + 住址列指向 fixture 设计文档/README,业务规则索引指 fixture §1.7、并发列指 fixture §5.1)+ fixture 代码带 `// WHY:` 注释。fork `design-context-scout`,逐 scenario 验:
- `scenario=write` + touchedFiles 落某模块 → Briefing 含「接口契约+模块边界+数据模型+业务规则索引+并发/同步/排序约束」片,各 ContextSlice 有 pointer + gist,**gist 是要点非抄代码**。
- `scenario=debug` → 含「既知坑+业务规则+数据+接口+并发+残留 why(grep 限本模块 `// WHY:`)」。
- `scenario=refactor` → 含「模块边界+取舍决策+不变量+残留 why」。
- 期望:`endpointsRead` 留痕列出实际读的 文件:锚;summary 一行。

- [ ] **Step 3: fixture 红线测(b)料缺/边界糊 → ⚠️ 不编造不硬猜**

- 住址列填 `—` 或指向不存在的 fixture 文件 → 该片进 `unsure[]` ⚠️ "下游未写…",**不编造内容**。
- touchedFiles 不落任何 memberGlob → ⚠️ "未匹配到业务模块,模块边界待厘清",**不硬猜模块**。
- 空 fixture 地图 / 无模块行 → `EmptyHanded{reason, missingKinds, seeGuide}`,missingKinds 是本 scenario 取片子集(非 B1 全 11 类),seeGuide 指 migration。

- [ ] **Step 4: 静态核汇总(全工件一致性)**

逐项核(对照各任务 Step「静态核」):① scout 无 YAML `---`(HTML 注释 frontmatter);② 地图列头 = scout `ContextSlice.kind` = 按 scenario 取片表右列,三处字面一致;③ scout 入参 5 字段 = finishing 注入参数;④ EmptyHanded.missingKinds/seeGuide = migration B2-3;⑤ DESIGN_TEMPLATE §1.7/§5.1 锚名 = 地图样板行 = migration B1/B2;⑥ implementation-rules `// WHY:` 格式 = scout 残留 why grep = migration 洞② 边界;⑦ TP-14/15 = finishing 保鲜 note;⑧ setup.sh skip↔守卫成对、无冗余 cp。

- [ ] **Step 5: 记录验收结果**

把红线测结果(Briefing/EmptyHanded/⚠️ 各态符合契约)+ 静态核结论记入收口 handoff 的 Evidence Depth L4。fixture 不入库。

---

## Self-Review(对照 spec 全节 — 我自跑,非派子智能体)

**1. Spec 覆盖**:
- §1.2 五场景:write/debug/refactor 片(T2 按 scenario 取片表 + T9 红线测)/ 报告分层(T2 出参二态 + 报告分层节)/ pull+降级+只读不写(T6 入口步 + T2 降级块)✓
- §2 模块划分:6 模块(地图 T1 / scout T2 / finishing T6 / setup.sh T8 / migration T3 / DESIGN_TEMPLATE T4)+ 洞② implementation-rules(T5,规划决策 P-1 新增)✓ **`freshness-rules.md 范围清单` 不改**(spec §2.1 列为"可能自动")——地图落 `docs/governance/*.md` 已自动进 freshness 核心集(spec §8.2),无显式加行义务,已账。
- §3 接口:入参/出参契约(T2)+ 地图行消费契约(T1+T2)✓
- §4 数据:地图行结构(T1)/ 两跳(T2)/ 按 scenario 取片(T2)/ 三前缀复用(T2)/ 保鲜登记(T6+T7)✓
- §5 边界:T2 边界条件逐条 + T9 红线测料缺/边界糊/EmptyHanded ✓
- §6 测试:T9 静态核 + **fixture 红线两条**(有料 / 料缺·边界糊·EmptyHanded — spec §6.2 至少两条红线);**三前缀/保鲜/降级不另 fixture**(三前缀复用 ③b 上游已验、保鲜由 T9 Step 1 登记后交 drift-scout 收口批联测、降级是退化路径不可 fixture 模拟 — 见 T9 intro「红线测 scope」诚实分界)✓
- §8 影响 + 凭证:T4-T8 改动文件 = §8.1;covers 8 文件(规划决策节)= §8.3 + P-1/P-2 修正 ✓
- §10 守住:③b 判据/类型 enum + freshness/review-scout/6 hook/business-module-map/根 README 零改(T8 静态核确认只地图被 skip)✓ **注**:drift-scout.md **本批不动**(spec §10.1 零改);其 4 处 illustrative「13 触点」计数在 TP-14/15 后变 stale 但检测 count-agnostic 不受影响,count-agnostic 化 deferral 已登 known-pitfalls-index(用户 2026-06-17 拍板,单独一批)。

**2. Placeholder 扫描**:新文件(T1/T2/T3)给全文;模板类占位(`[规则1]`/`[描述]`)是 DESIGN_TEMPLATE **模板体裁本身**(下游填),非计划失败。无 "TBD/implement later/类似 Task N"。✓

**3. 类型一致**:scout 字段名(scenario/touchedFiles/mapPointer/repoRoot/today;Briefing/EmptyHanded;modules/matchedFiles/slices/endpointsRead;ContextSlice.kind/pointer/gist/note;delivered/reason/missingKinds/seeGuide)在 T2/T3/T6/T9 全程一致;地图列头(10 列)在 T1/T2/T3/T4 一致;TP-14/15 描述在 T6/T7 一致。✓

---

## 收口须知(finishing 阶段执行,非本计划任务)

- **审计凭证(必做)**:本批命中 `credentials.conf` → 收口前按 `finishing-rules.md` step 15-18 产**对抗审查 audit**(非 typo,不走 exempt),covers 列**8 文件**(见规划决策节)。审查维度按 `review-rules.md` 维度选择表治理行选(治理面改动 + 分发链 + 触点完整性 + spec_gap_masking 三赌注)。
- **触点漂移机械预检**:收口凭证批内 drift-scout 自动跑(TP-14/15 新登,首轮 `待③b查`)。
- **方向评估**:治理批适用(全批)。
- **保鲜搭便车**:本批动过的 governance 活文档(finishing-rules / touchpoint-registry / implementation-rules / 新建 map / migration)收口时 `last-reviewed` 推到当天。
- **🟡-1/🟡-2/🟡-3**:三诚实赌注已与用户确认接受为已知边界(handoff);是否另立 `docs/decisions/` 由收口按 finishing decision 立档规则判(spec §7 已显式留痕,decisions 不命中凭证 glob)。
- **handoff 更新**:走 `/structured-handoff` 晋升门禁覆写,状态转 C 实现完成 → 待收口 / 已收口。

---

## Execution Handoff

计划存于 `docs/superpowers/plans/2026-06-17-design-context-delivery.md`。两种执行选项:

1. **Subagent-Driven(推荐)** — 调度者每任务 fork 新子智能体(Superpowers subagent-driven-development:TDD + 两阶段审),任务间审查,适合本批跨多文件契约一致性。
2. **Inline Execution** — 本会话内按 executing-plans 批量执行 + 检查点。

**选哪个?**

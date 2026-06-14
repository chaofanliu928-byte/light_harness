# review-scout 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. 每个任务一个 commit(C 风格频繁提交)。

**Goal:** ADD 一条 `review-scout` 审查路并排于现有 design-review,**不替换**现有固定 4 维路(Y 方向,用户 2026-06-13 拍板)。ultracode/Workflow 在场时 design-review SKILL 分支去调 `review-scout.workflow.js`(scout agent 现推维:地板 2 维 + 动态加 + skipped 强制留痕),`parallel()` 一维一挑战者扇出,返回 `{plan, findings}` 交调度者综合;ultracode 不在场时走**现有固定 4 维 design-review 流程,原样不动**(活备份)。

**Architecture:** 新增 2 个工件 + 一组 ADD 式 markdown 治理改动。工件类型按 workflow / agent / skill / governance / 入口地图标注,依赖方向 = 调用方向(调度者→workflow→scout/挑战者),无循环。`review-scout.workflow.js`(workflow 脚本,主对话 runtime 执行,无 FS、无独立判断)**内含 floor/已知维挑战者 focus 常量库**;`review-scout.md`(agent 定义,被 fork 出的子智能体执行,有 Read/Grep)= **纯推维**。scout 路挑战者 prompt **100% scout 路自有**,floor/已知维 focus = workflow.js 常量,**不读/不抄/不镜像** `design-reviewer.md`(它整块 4 维 prompt 仅服务现有路;scout 路与它零关系、无双源同步义务)。现有 4 维路(design-reviewer.md / synthesis-rules L113/L151 维序 / design-rules)**零改动**。

**Tech Stack:** JavaScript(Workflow 工具脚本:`export const meta` 纯字面量 + `phase`/`agent(...,{schema})`/`parallel` 钩子,Claude Code ultracode 运行时契约;禁用 `Date.now` / `Math.random` / 无参 `new Date` / 文件系统 API)+ markdown 纯文件治理约定 + bash(setup.sh 分发段)+ git(每任务一 commit)。

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md`(687 行,已锁 2026-06-13;§2 模块 / §3 接口 / §4 数据 / §5 边界 / §6 测试 / §8 影响 + §8.3 grep 自核命令组)
**拍板锚:** `harness/docs/decisions/2026-06-13-review-scout-workflows-dir.md`(🟢 保 A + Y,用户 2026-06-13)

---

## 适配说明(本功能是 harness meta 改动,不是代码+pytest)

- 改动物 = 1 个 workflow 脚本(含 challenger focus 常量库)+ 1 个 agent 定义(纯推维)+ 一组 ADD 式 markdown 治理改动。
- **"验证"不套 pytest**:用 spec §6 定的 =(a)workflow 脚本结构静态核(`export const meta` 纯字面量 / `phase`·`agent`·`parallel` 用法 / 禁用项无 `Date.now`·`Math.random`·无参 `new Date`·无 FS)+(b)spec §8.3 grep / 全仓 `git diff --stat` 兜底命令 +(c)文档一致性核。每个任务的"验证"步给**实际可跑的 grep/命令 + 期望输出**。
- **守 Y(零改清单)**:`design-reviewer.md` / `synthesis-rules.md` **L113/L151 维序** / `design-rules.md` 全程**零改**;收口靠 §8.3 CMD1 全仓 diff 验证它们不在改动集。
- **凭证 vs 触点两套独立**:凭证命中 = SKILL / review-rules / synthesis-rules / harness setup.sh / credentials.conf / credentials-rules / CLAUDE×2 + review-scout.md(`.claude/agents/*.md` 自动)+ workflow.js(新 glob);QUICKREF + README 改但**不命中凭证**(触点 ≠ 凭证)。

## 待回设计清单(0 条)

> 规则:计划不静默偏离 spec;执行中发现 spec 不可执行点,停下回设计裁决。本计划写作时点未发现阻塞性不可执行点。

## 模块文档处置(.claude/workflows/ 是否要 README)

**结论:不建 README。** 依据:① harness 自仓库无 ARCHITECTURE.md 产品分层,workflow/agent/skill 各目录现状均无 per-目录 README(`.claude/agents/`、`.claude/skills/` 无目录 README,各 SKILL.md/agent.md 自述);planning-rules「模块文档」节针对的是产品代码模块的 README,与 harness meta 工件目录惯例不同;② 单一 workflow 文件 `review-scout.workflow.js` 自身头注 + spec §3 接口契约已是其文档;③ 凭证义务由 workflow.js 自身(新 glob)兜,目录卡登记不适用(`.claude/workflows/` 无目录卡机制)。**故本计划不创建 `.claude/workflows/README.md`**;workflow.js 文件头注承担"这是什么/怎么被调"说明。

---

## 任务依赖与排序

契约任务(schema / floor / focus 常量 / challengerPrompt 结构)**前置**于 wiring(planning-rules 硬规矩)。排序:

1. 任务 1 — 契约定义(SCOUT_SCHEMA / FINDING_SCHEMA / FloorTable / DesignCandidateMenu / focus 常量 / challengerPrompt 结构),全部写进 `review-scout.workflow.js` 骨架(workflow 即契约住址)
2. 任务 2 — `review-scout.workflow.js` 编排骨架(侦察→对抗两 phase + 错误处理 + 出参)
3. 任务 3 — `review-scout.md`(纯推维 agent)
4. 任务 4 — `design-review` SKILL 加运行时分支 + scout 综合维序说明
5. 任务 5 — `review-rules.md` 加 scout 注 + 地板维表(权威住此)
6. 任务 6 — `synthesis-rules.md` 四处 ADD scout 行(主表 / L99 / L169 / L3;L113/L151 维序零改)
7. 任务 7 — `harness/setup.sh` 加 `.claude/workflows/` 复制段 + review-scout.md 复制
8. 任务 8 — `credentials.conf` + `credentials-rules §2` 加 `.claude/workflows/*` glob(双写行序同步)
9. 任务 9 — CLAUDE×2 + QUICKREF 加最小注
10. 任务 10 — 收口:跑 §8.3 全组命令(含全仓 diff 兜底)+ 凭证预告

---

## 任务 1:创建 review-scout.workflow.js 的契约骨架(SCOUT_SCHEMA / FINDING_SCHEMA / FloorTable / DesignCandidateMenu / focus 常量)【契约任务 — 指令式】

> 契约任务:精确给定义(planning-rules)。本任务只建文件 + 写所有**契约级常量/schema/纯函数定义**;编排逻辑(phase/agent/parallel 调用、错误处理)在任务 2 接上。两任务可合并为一个文件分两 commit,本任务 commit = 契约部分。

**Files:**
- create: `harness/.claude/workflows/review-scout.workflow.js`(本任务写文件头注 + 契约常量段;任务 2 在同文件追加编排段)

**依据:** spec §3.1(入参)/ §3.2(SCOUT_SCHEMA)/ §3.3(challengerPrompt + focus 常量来源表)/ §3.4(FINDING_SCHEMA)/ §4.1(FloorTable / DesignCandidateMenu / 实体)。

- [ ] 创建 `harness/.claude/workflows/` 目录(harness 此前无此目录)
- [ ] 写文件头注(说明"这是什么/怎么被调"——承担目录无 README 的文档职责):

```javascript
// review-scout.workflow.js — 动态审查侦察 workflow(ultracode/Workflow 运行时专属)
//
// 被 design-review SKILL 在「执行」开头分支调用(ultracode/Workflow 可用时);
// 不可用时 SKILL 走现有固定 4 维 design-review 流程(本脚本不参与)。
//
// 两阶段编排:
//   phase('侦察')  → review-scout.md agent fork 读上下文现推审查计划(SCOUT_SCHEMA)
//   phase('对抗')  → 按计划一维一挑战者 parallel 扇出(FINDING_SCHEMA),挑战者 prompt 100% 本脚本自有
// 返回 { plan, findings } → 调度者按 synthesis-rules 综合判定(本脚本不下判定 — D8)。
//
// 本脚本与 .claude/agents/design-reviewer.md 零关系(不读/不抄/不镜像 — spec §3.3 第 3 轮根治):
//   floor/已知维挑战者 focus = 本脚本 FLOOR_FOCUS 常量(workflow 无 FS,focus 必在脚本内);
//   动态加维 focus = scout 返回的 challenger_focus 字段。
//
// 权威 spec: docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md
// 禁用项(确定性约束): Date.now / Math.random / 无参 new Date / 文件系统 API(脚本无 FS)。
```

- [ ] 写 `export const meta`(纯字面量,无运行时求值):

```javascript
export const meta = {
  name: 'review-scout',
  description: '动态审查侦察:scout 现推维(地板+动态加)→ 一维一挑战者并行扇出 → 返回 {plan, findings}',
};
```

- [ ] 写 `FloorTable`(spec §4.1(1);三类各一行,design 本轮接线,code/governance 留口不接调用):

```javascript
// 地板维表(仅作用 scout/ultracode 路;非 ultracode 路用现有固定 4 维,不查本表)
// 三类各一行;design 本轮接线,code/governance 留口(纯数据行,无实现代码 — spec §7.3 反向追问保 3 行)
const FloorTable = {
  design:     ['方向盘对齐', '自洽性'],                              // D1: 地板 2 维(本轮接线)
  code:       ['方向盘对齐', '简洁性'],                              // D4: 留口,本轮不接线
  governance: ['核心原则合规', '目的达成度', '副作用', 'scope 漂移'], // D4: bootstrap-4 锁死,本轮不接线
};
```

- [ ] 写 `DesignCandidateMenu`(spec §4.1(3);执行层实际名 🔴-1):

```javascript
// 标准候选菜单(scout 路 design 类;scout 每次必考虑,不加须进 skipped_candidates — D-A2)
// 执行层实际名(design-reviewer.md L198「过度工程化」,非治理层别名"合理性");
// = 现有 4 维里地板外的 2 维,scout 路降为"必考虑候选"(降级只在 scout 路)。
const DesignCandidateMenu = ['完整性', '过度工程化'];
```

- [ ] 写 `FLOOR_FOCUS` 常量库(spec §3.3 focus 来源表第 1 行 — floor/已知维 focus = workflow.js 常量;**scout 路自有独立内容,无 bootstrap-4 B 段、无嵌入式人设、无 A/B/C 脚手架**;方向盘对齐带 A-3 template 回落分支):

```javascript
// floor/已知维挑战者 focus 常量库(spec §3.3 — 100% scout 路自有,不镜像 design-reviewer.md)
// workflow 无 FS → focus 必在脚本内;SCOUT_SCHEMA.inherited_floor 是 string[](只有维名、无 focus 通道),
// 故 workflow 按维名 d.name 从本常量映射 focus。
const FLOOR_FOCUS = {
  '方向盘对齐':
    '审查设计是否对齐项目方向盘。先 Read docs/RUBRIC.md 判断:' +
    '若「项目特定标准」段已填(无模板标记串「(示例,请替换)」/「你必须根据自己的项目替换」/占位 [列出...] [例如:...])→ 按 RUBRIC 项目特定标准逐项对齐;' +
    '若是空模板 → 回落对齐 CLAUDE.md 原则(文档第一公民/最小变更/角色分离/回退规则)+ 二条公设(Pathological Optimist 做审分离 / 行动公设 不确定执行外部动作),' +
    '读取范围 = Read 仓库根 /CLAUDE.md 或 harness/CLAUDE.md(均含二公设全文)。' +
    '通用基线段(功能完整性/代码质量/测试/一致性/简洁性)始终检查,template 模式只影响项目特定标准段是否回落。',
  '自洽性':
    '矛盾追踪:把设计各章节映射到「章节→关键概念→描述」,跨章节比对同一概念描述是否一致;' +
    '核接口双方对齐(调用方期望 vs 实现方签名)、数据模型一致、状态机完整(无死状态/不可达)、模块依赖无循环、错误传播连贯。',
  '完整性':
    '查需求覆盖与缺口:每个核心场景(设计文档 §1.2)是否有实现路径;边界条件/错误处理是否覆盖;' +
    '接口/数据模型字段是否被需求用到且无悬空;有无场景设计里没覆盖(漏需求)。',
  '过度工程化':
    '查多做的害处(副作用维):有无未被需求要求的抽象层、"未来可能用到"的配置/预留、不可能触发的错误处理;' +
    '对每个新增抽象做反向追问「不用这个方式,原问题怎么解?」有替代解则视过度工程。',
};
```

- [ ] 写 SCOUT_SCHEMA(spec §3.2;去掉 challenger_count,N 自然从维数掉出):

```javascript
// scout fork 返回对象的 schema(agent({schema}) 校验)— spec §3.2 / §4.1(2)
const SCOUT_SCHEMA = {
  type: 'object',
  required: ['inherited_floor', 'added_dimensions', 'skipped_candidates', 'rubric_mode'],
  properties: {
    inherited_floor: {
      type: 'array',
      items: { type: 'string' }, // 地板维名(仅维名,无 focus 通道;workflow 按维名映射 FLOOR_FOCUS)
    },
    added_dimensions: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'why_this_time', 'challenger_focus'],
        properties: {
          name: { type: 'string' },            // 不得与地板/已列候选重叠
          why_this_time: { type: 'string' },   // 证据指认:引被审材料/决策/历史原文
          challenger_focus: { type: 'string' },// 该维挑战者关注焦点 1-2 行
        },
      },
    },
    skipped_candidates: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'why_skipped'],
        properties: {
          name: { type: 'string' },
          why_skipped: { type: 'string' },
        },
      },
    },
    rubric_mode: { type: 'string', enum: ['filled', 'template'] }, // A-3 判据结论
    notes: { type: 'string' }, // 可选:边界声明(如 "ARCHITECTURE.md 缺失,跳过架构维")
  },
};
```

- [ ] 写 FINDING_SCHEMA(spec §3.4;挑战者不打分,judging 在调度者):

```javascript
// 每个挑战者返回对象的 schema — spec §3.4
const FINDING_SCHEMA = {
  type: 'object',
  required: ['dimension', 'findings', 'user_words_section'],
  properties: {
    dimension: { type: 'string' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['title', 'location', 'problem', 'evidence', 'impact', 'severity'],
        properties: {
          title: { type: 'string' },
          location: { type: 'string' },   // 文档节/路径
          problem: { type: 'string' },
          evidence: { type: 'string' },   // 原文引用
          impact: { type: 'string' },
          severity: { type: 'string', enum: ['🔴', '🟡', '🟢'] },
        },
      },
    },
    user_words_section: { type: 'string' }, // 「### 已对照用户原话」section 原文(synthesis 事后规则 5)
  },
};
```

- [ ] **验证**(脚本结构静态核 — spec §6.1):
  - 跑 `grep -nE "export const meta|FloorTable|DesignCandidateMenu|FLOOR_FOCUS|SCOUT_SCHEMA|FINDING_SCHEMA" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:6 个常量/schema 名各命中
  - 跑禁用项核 `grep -nE "Date\.now|Math\.random|new Date\(\)" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**无输出**(禁用项不存在)
  - 跑 `grep -nE "方向盘对齐|自洽性|完整性|过度工程化" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:FloorTable design 行 + DesignCandidateMenu + FLOOR_FOCUS 四键命中(floor/已知维 focus 在脚本内,非取自 design-reviewer.md)
  - 人工核:FLOOR_FOCUS 各 focus 文本**无** "bootstrap" / "禁止删减维度" / A/B/C 脚手架字样(scout 路自有,无 B 段冲突内容)
- [ ] commit:`feat: review-scout - workflow 契约骨架(SCOUT/FINDING_SCHEMA + FloorTable + focus 常量库)`

---

## 任务 2:解决 review-scout.workflow.js 的两阶段编排【实现任务 — 问题式】

> 实现任务:给问题+约束+验证标准(planning-rules)。

**Files:**
- modify: `harness/.claude/workflows/review-scout.workflow.js`(在任务 1 契约段后追加 challengerPrompt 构造 + 默认导出编排函数)

**问题:** 编排"侦察→对抗"两阶段。侦察 phase fork scout agent 读上下文产 ScoutPlan;对抗 phase 按 `dims = inherited_floor ∪ added_dimensions.name` 一维一挑战者 `parallel` 扇出;返回 `{plan, findings}` 给调度者,不下判定。

**约束:**
- 入参契约遵循 spec §3.1:`{ reviewType, targets:{spec,rubric,architecture,decisionsDir,auditsDir}, sessionIntent }`;`reviewType` 本轮只接 `'design'`;缺 `targets.spec` → `log()` 报错 + 返回 `{plan:null, findings:[]}`(spec §3.1 错误处理)。
- 侦察 phase:`await agent(scoutPrompt, {schema: SCOUT_SCHEMA, label:'scout', agentType:'general-purpose'})`(spec §3.2)。scout 空返回/校验失败 → **重试一次**;二次失败 → `return {plan:null, findings:[]}`(spec §3.2 / §5.1 错误处理)。
- `scoutPrompt` 构造:把 `targets` 指针 + `sessionIntent` + `FloorTable[reviewType]`(供 scout 照抄 inherited_floor)+ `DesignCandidateMenu`(供 scout 判 skipped)传入;scout 自读盘(D9),prompt 指明 scout 读 `review-scout.md` 的推维指令(scout agentType=general-purpose,通过 prompt 引导其读 agent 定义文件)。
- `challengerPrompt(d)` 构造(spec §3.3 统一结构,**100% scout 路自有**):薄包装(给被审材料路径 `targets.spec` 自读盘指令 + 中性约束 + "先 Read docs/references/challenger-orientation.md 取通用方法论,注:其 §1.2「design-review 4 挑战者专属」固定 4 维框定不适用 scout 动态 N,勿被误导" + 顶部「主线-支线-关系」段[从 sessionIntent 构造,synthesis 事前规则 5]+ 输出格式 + 末尾必填「### 已对照用户原话」section[守事后规则 5])+ **该维 focus**;focus 来源 = `FLOOR_FOCUS[d.name]`(地板+已知维,按维名映射)**或** `d.challenger_focus`(scout 动态加维)。
- 对抗 phase:`await parallel(dims.map(d => () => agent(challengerPrompt(d), {schema: FINDING_SCHEMA, label:d.name, agentType:'general-purpose'})))`(spec §3.3)。某挑战者空返回 → 重试一次;仍败该项为 null,`.filter(Boolean)` 剔除(spec §3.3 / §5.1)。
- 出参:`return { plan: ScoutPlan(+实际扇出维列表), findings: ChallengerReturn[].filter(Boolean) }`(spec §3.5)。
- **不下判定**(D8):workflow 只返回 plan+findings,综合在调度者。
- **禁用项**:无 `Date.now` / `Math.random` / 无参 `new Date` / 文件系统 API(spec §6.1 / 文件头注)。
- 放在 `harness/.claude/workflows/review-scout.workflow.js`(spec §2.1 / §8.1)。

**验证标准:**
- 脚本结构静态核:`grep -nE "phase\(|agent\(|parallel\(|challengerPrompt|filter\(Boolean\)" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:`phase('侦察')`、`phase('对抗')`、`agent(...,{schema})`(scout + 挑战者两处)、`parallel(`、`challengerPrompt`、`.filter(Boolean)` 各命中
- 重试分支核:`grep -nE "重试|retry|二次|仍败" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:scout 重试 + 挑战者重试两处分支存在(spec §5.1)
- 入参错误分支核:`grep -nE "targets\.spec|plan:\s*null|plan: null" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:缺 spec → `{plan:null,findings:[]}` 分支存在
- focus 映射核:`grep -nE "FLOOR_FOCUS\[|challenger_focus" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:floor/已知维按 `FLOOR_FOCUS[d.name]` 映射 + 动态维用 `d.challenger_focus` 两路存在
- 禁用项复核:`grep -nE "Date\.now|Math\.random|new Date\(\)|require\(|readFileSync|import .* from 'fs'" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**无输出**
- [ ] commit:`feat: review-scout - workflow 侦察→对抗两阶段编排 + 错误处理`

---

## 任务 3:创建 review-scout.md(纯推维 agent 定义)【实现任务 — 问题式】

**Files:**
- create: `harness/.claude/agents/review-scout.md`

**问题:** 写 scout 推维 agent 的指令文件。scout 被 workflow fork(general-purpose,有 Read/Grep),读上下文(被审材料 / RUBRIC / decisions / audits)现推审查计划,产 SCOUT_SCHEMA。

**约束:**
- **单一职责 = 推维**(spec §2.1 M-scout-agent):推维 + A-3 判据 + B-8 加维正向引导;**不承载挑战者 focus 库**(focus 库在 workflow.js;spec §3.3)。
- **形态对齐 research-scout.md**(同类"说明文件而非 custom agent type",无 frontmatter tools):scout 读本文件后按指令操作。开头点明形态 + 路径前缀(下游裸 `docs/`,自仓库实际 `harness/docs/`),对齐 research-scout.md 写法。
- **推维步骤**:① 读 `FloorTable[reviewType]` 照抄进 `inherited_floor`(不增删改 — spec §4.1 ScoutPlan 注);② Read `targets.rubric` 判 `rubric_mode`(A-3 判据,spec §7.2 D-A3:模板标记串「(示例,请替换)」/「你必须根据自己的项目替换」/ 占位 `[列出...]` `[例如:...]` 命中即 template;全命中→template,部分替换部分占位→已替换段 filled、占位段标跳过);③ 对 `DesignCandidateMenu`(完整性/过度工程化)**每次必考虑**,不加须写进 `skipped_candidates`(强制留痕挡 spec-gap-masking — D7-scope);④ Grep `decisionsDir`/`auditsDir` + 读被审材料 → 推 `added_dimensions`(每条带 `why_this_time` 引原文锚点 + `challenger_focus`,约束:不与地板/候选重叠 + why_this_time 指证据 — D11/D-A2)。
- **B-8 加维正向引导**(spec §3.2 引导块,缓解"换汤不换药"退化):给"信号→该加什么新维"举例(非穷举):迁移/兼容性信号→"迁移安全/回滚路径"维;跨文件契约信号→"契约一致性/触点完整性"维;特定失败模式信号→"并发安全/失败恢复"维。诚实标:此引导降退化概率但不消除,退化是实战观察的失败模式(§6 / meta-L4)。
- **ARCHITECTURE.md 缺失**:`notes` 标"跳过架构维"(spec §5.1)。
- **输出 = SCOUT_SCHEMA**(workflow `agent({schema})` 校验);scout 不下审查判定(只产计划)。
- 放在 `harness/.claude/agents/`(随 agents 分发,spec §8.1;落已有 `.claude/agents/*.md` glob 自动入凭证)。

**验证标准:**
- `grep -nE "inherited_floor|rubric_mode|skipped_candidates|added_dimensions|why_this_time" "harness/.claude/agents/review-scout.md"` → 期望:四字段 + why_this_time 均出现(推维步骤覆盖 schema 字段)
- A-3 判据串核:`grep -nE "示例,请替换|你必须根据自己的项目替换|template|filled" "harness/.claude/agents/review-scout.md"` → 期望:模板标记串 + rubric_mode 两值出现
- 单一职责核:`grep -nE "FLOOR_FOCUS|挑战者 prompt|challengerPrompt" "harness/.claude/agents/review-scout.md"` → 期望:**无输出或仅说明"focus 库不在此(在 workflow.js)"**(scout 不承载 focus 库)
- B-8 引导核:`grep -nE "迁移安全|契约一致性|触点完整性|并发安全|换汤不换药|退化" "harness/.claude/agents/review-scout.md"` → 期望:加维引导 + 退化诚实标注出现
- [ ] commit:`feat: review-scout - 纯推维 agent 定义(A-3 判据 + B-8 加维引导)`

---

## 任务 4:design-review SKILL 加运行时分支 + scout 综合维序说明【实现任务 — 问题式】

**Files:**
- modify: `harness/.claude/skills/design-review/SKILL.md`

**问题:** 在 SKILL「执行」开头加运行时分支:ultracode/Workflow 可用 → 调 review-scout workflow(reviewType=design);否则 → 走下面现有固定 4 维流程(原样不动)。并在 scout 分支段钉死 scout 路综合维序说明。

**约束:**
- **只加分支,现有 4 维流程逐字不动**(spec §1.3 / §8.1 M-skill;现有「执行」第 1-4 步 + A/B/C 模板段零改)。
- 分支段写在「## 执行」标题下、现有"按 design-reviewer.md 指令执行"之前。**内容须实际可照抄**,建议如下(engineer 可微调措辞,语义须含全要点):

```markdown
## 执行

> **运行时分支(ADD review-scout 并排 — Y,不替换现有 4 维路;spec §1.2/§2.2/D-A4)**:
> 进入执行先做一次运行时探测——**Workflow/ultracode 工具是否可用**:
>
> - **可用(ultracode 开)→ 走 review-scout 路**:调度者用 Workflow 工具启动 `review-scout`,入参
>   `{reviewType:'design', targets:{spec:<最新 *-design.md 路径>, rubric:'docs/RUBRIC.md', architecture:'docs/ARCHITECTURE.md', decisionsDir:'docs/decisions/', auditsDir:'docs/audits/'}, sessionIntent:'<一行会话意图,措辞中性>'}`。
>   workflow 返回 `{plan, findings}`。**scout 路综合维序说明(钉死此处,单一住址 — spec §3.5)**:scout 路维度由 `plan` 动态定,综合维序 = **按 plan 产出的维度清单顺序**交叉读 findings(**不用** synthesis-rules L151 固定 4 维序,L151 服务下面现有 4 维路)。综合仍按 synthesis-rules 事后规则(回意图/决策/客观/避先入为主 + 校验「已对照用户原话」section),写 `docs/active/design-review-result.md`。
>   - scout 空返回/审查失败(`plan:null`)→ **显式报用户审查失败**(按本 skill 错误处理重试);**不静默回落现有 4 维路**(scout 失败 ≠ ultracode 不在场 — spec §5.1)。
> - **不可用(ultracode 关 / 非 Claude Code / 逐会话未 opt-in)→ 走下面现有固定 4 维 design-review 流程,原样不动**(活备份,已存在的正常路,**不标"降级执行"** — spec §5.1)。scout 动态推维在此路不可得 = ultracode 专属取舍(D13)。

按 `.claude/agents/design-reviewer.md` 的指令执行审查。关键步骤:
（…现有 1-4 步原样不动…）
```

- description frontmatter **可保留或最小注**(不动现有 4 维描述;若加注,行尾括注"ultracode 下走 review-scout")。
- 放在现有 SKILL.md(凭证义务命中 `.claude/skills/*/*.md`)。

**验证标准:**
- `grep -nE "review-scout|运行时分支|ultracode|按 plan 产出的维度清单" "harness/.claude/skills/design-review/SKILL.md"` → 期望:分支段 + scout 综合维序说明命中
- 现有流程零改核:`grep -nE "并行 fork 4 个挑战者|自洽性 / 完整性 / 过度工程化 / RUBRIC 对齐|对抗式挑战者 prompt 模板" "harness/.claude/skills/design-review/SKILL.md"` → 期望:现有第 1 步 + A/B/C 模板段标题原文仍在(未被改/删)
- [ ] commit:`feat: review-scout - design-review SKILL 加运行时分支 + scout 综合维序说明`

---

## 任务 5:review-rules.md 设计行加 scout 注 + 地板维表(权威住此)【实现任务 — 问题式】

**Files:**
- modify: `harness/docs/governance/review-rules.md`

**问题:** 审查维度选择表「设计」行(L12)保留现有"自洽性/完整性/合理性/RUBRIC 对齐(4 维)"作非 ultracode 默认,**新增** scout 注:ultracode 时走 review-scout(地板 2 维 + 动态加),**地板维表权威住此**。

**约束:**
- **不把 4 维改 2 维**(治理层维名沿用"合理性",alias 注见 spec §1.3);只 ADD scout 注。
- **地板维表权威住此 scout 注**(spec §2.1 M-floor-table / §8.1;🟡-2 钉死,非住 review-scout.md)。建议在设计行下方加一条注/子项(engineer 可选注脚或表内追加列说明),含:
  - "ultracode/Workflow 在场时走 review-scout workflow:scout 现推维 = 地板 2 维(**方向盘对齐 + 自洽性**)+ 动态加维;完整性/过度工程化降为'必考虑候选'(不加须 skipped 留痕)。地板维表(三类)权威住本注:design=方向盘对齐+自洽性 / code=方向盘对齐+简洁性(留口)/ governance=核心原则合规+目的达成度+副作用+scope 漂移(留口,治理审查仍走现 bootstrap-4)。非 ultracode 路用上面现有固定 4 维。"
- 放在 governance/(凭证义务命中 `docs/governance/*.md`)。

**验证标准:**
- `grep -nE "review-scout|地板 2 维|方向盘对齐 \+ 自洽性|地板维表" "harness/docs/governance/review-rules.md"` → 期望:scout 注 + 地板维表命中
- 现有 4 维零改核:`grep -nE "自洽性 / 完整性 / 合理性 / RUBRIC 对齐" "harness/docs/governance/review-rules.md"` → 期望:L12 现有 4 维原文仍在
- [ ] commit:`feat: review-scout - review-rules 设计行加 scout 注 + 地板维表(权威住此)`

---

## 任务 6:synthesis-rules.md 四处 ADD scout 行(L113/L151 维序零改)【实现任务 — 问题式】

**Files:**
- modify: `harness/docs/governance/synthesis-rules.md`

**问题:** 适用范围是**活规则义务**(L98「对齐本文件适用范围表」),scout 路同受事前规则 5 / 事后规则 5 / D8 综合治理,故四处各 ADD 一行 scout;**L113/L151 维序原文零改**(服务现有 4 维路)。

**约束(四处 ADD,spec §8.1 / §8.4 fix#2,精确落点):**
- ① **主适用范围表(L13-19)**:在表内 design-review 行附近 ADD 一行 `| review-scout | 动态 N(地板 2 + 动态加) | 调度者(Claude) |`(列对齐现有三列:场景 / 挑战者数量 / 综合者)。
- ② **事前规则 5 适用范围清单(L98-103)**:在 design-review/evaluator/process-audit/security-scan/治理审查列表 ADD 一项 `- review-scout(scout 驱动 N 挑战者,N=地板 2+动态加)`。
- ③ **事后规则 5 适用范围(L169)**:在 "design-review / evaluate / process-audit / security-scan / 治理审查" 枚举 ADD `review-scout`。
- ④ **何时读(L3)**:文件头「何时读本文件」枚举 ADD `review-scout`。
- **L113(「4 维度独立评分」)/ L151(「维度固定顺序(自洽→完整→合理→对齐)」)维序原文零改**(spec §8.4;scout 路维序住 SKILL scout 分支段,任务 4 已钉)。
- 放在 governance/(凭证义务命中)。

**验证标准:**
- `grep -nE "review-scout" "harness/docs/governance/synthesis-rules.md"` → 期望:**4 处命中**(主表 / 事前 5 清单 / 事后 5 适用范围 / 何时读)
- L113/L151 维序零改核:`grep -nE "4 维度独立评分|维度固定顺序|自洽 → 完整 → 合理 → 对齐" "harness/docs/governance/synthesis-rules.md"` → 期望:L113 + L151 原文仍在(未被改)
- [ ] commit:`feat: review-scout - synthesis-rules 四处 ADD scout 适用范围行(维序零改)`

---

## 任务 7:harness/setup.sh 加 .claude/workflows/ 复制段【实现任务 — 问题式】

**Files:**
- modify: `harness/setup.sh`

**问题:** setup.sh 分发新目录 `.claude/workflows/`(含 `review-scout.workflow.js`);`review-scout.md` 落已有 `.claude/agents/` 复制段(须显式加一行 cp,对齐 research-scout.md 写法)。

**约束:**
- workflows 复制段对齐现有 agents/skills/hooks 段写法(spec §A-4 / decision §后续影响):
  - 在 `.claude/agents` cp 段(L41-49)后,加 `cp review-scout.md`(对齐 L49 research-scout.md 注记)。
  - 新增 `.claude/workflows` 复制段(建议放在 `.claude/skills` 段之后、`.claude/hooks` 段之前,或紧邻 agents 段):

```bash
# .claude/workflows(review-scout — ultracode 运行时审查编排;ultracode 关时下游走现有 design-review)
mkdir -p "$TARGET_DIR/.claude/workflows"
cp "$SCRIPT_DIR/.claude/workflows/review-scout.workflow.js" "$TARGET_DIR/.claude/workflows/"
```

  - agents 段加 review-scout.md(对齐现有 cp 行):
```bash
cp "$SCRIPT_DIR/.claude/agents/review-scout.md" "$TARGET_DIR/.claude/agents/"
```
- **最小变更**:只加复制段/行,不动现有段。
- setup.sh 实物 = `harness/setup.sh`(无根级;spec §8.3 CMD6 path 修正)。命中凭证义务 `setup.sh`。

**验证标准:**
- `grep -nE "workflows|review-scout" "harness/setup.sh"` → 期望:mkdir + cp workflow.js + cp review-scout.md 各命中
- 现有复制段未损:`bash -n "harness/setup.sh"` → 期望:语法检查通过(exit 0,无报错)
- [ ] commit:`feat: review-scout - setup.sh 分发 .claude/workflows/ + review-scout.md`

---

## 任务 8:credentials.conf + credentials-rules §2 加 .claude/workflows/* glob【契约任务 — 指令式】

> 契约任务:双写同步,行序一致(planning-rules + credentials-rules §8 双写义务第 1 条)。

**Files:**
- modify: `harness/.claude/hooks/credentials.conf`
- modify: `harness/docs/governance/credentials-rules.md`(§2 凭证要求表)

**操作(精确,两处行序同步):**
- **credentials.conf**:在 `# === skills + agents ===` 段内、`.claude/agents/*.md audit` 行后(或新建一段)ADD:
```
.claude/workflows/* audit
```
  建议位置:与 agents 同段(均为 `.claude/` 工件),即在 `.claude/agents/*.md audit` 下一行。
- **credentials-rules.md §2 人读表**:在 `| agents | \`.claude/agents/*.md\` | audit |` 行后 ADD(列对齐:文件类别 / glob / 凭证类型):
```
| workflows(review-scout 等 ultracode 编排脚本) | `.claude/workflows/*` | audit |
```
- **行序契约**:conf 与 §2 表行序同序(credentials-rules §2 表头注 + §8 第 1 条);两处 ADD 行的相对位置一致(均紧跟 agents 行)。
- **注**(spec §8.1):`review-scout.md` 落已有 `.claude/agents/*.md` glob,**自动入凭证不需改 conf**;只有 `workflow.js` 需此新 glob。
- 依据:spec §8.1 / decision §后续影响 / credentials-rules §8 双写同步义务。

**验证标准:**
- `grep -nE "\.claude/workflows/\*" "harness/.claude/hooks/credentials.conf" "harness/docs/governance/credentials-rules.md"` → 期望:**两文件各 1 行命中**
- 双写行序核:人工核两处 ADD 行均紧跟各自的 agents 行(conf 的 `.claude/agents/*.md audit` / §2 的 `| agents |` 行)
- [ ] commit:`feat: review-scout - credentials.conf + §2 加 .claude/workflows/* glob(双写同步)`

---

## 任务 9:CLAUDE×2 + QUICKREF 加最小注【实现任务 — 问题式】

**Files:**
- modify: `D:\个人\harness\CLAUDE.md`(根治理入口,角色表设计审查行 L30)
- modify: `harness/CLAUDE.md`(M4 分发模板,角色表 L16 + Skill 全局地图 design-review 行 L112)
- modify: `harness/QUICKREF.md`(Skill 表 L44)

**问题:** 三个入口地图加最小注:design-review 在 ultracode 下走 review-scout;不动现有 4 维描述。

**约束(精确落点 + 注内容):**
- **根 CLAUDE.md L30**(角色分离表「设计审查」行)说明列行尾加注:`自洽性 / 完整性 / 合理性 / RUBRIC 对齐(ultracode 下走 review-scout:scout 现推维)`。
- **harness/CLAUDE.md L16**(角色分离表「设计审查」行)同款行尾加注(**与根双写,语义一致** — spec §8.1 / §8.3 CMD5 双写对核;credentials-rules §8 同类双写对)。
- **harness/CLAUDE.md L112**(Skill 全局地图 design-review 行)做什么列加注:`调度者并行 fork 4 个挑战者审查设计文档(ultracode 走 scout)`。
- **QUICKREF.md L44**(`design-review | 设计完成后 — fork reviewer team(4 并行子智能体)`)加注:`(ultracode 走 review-scout)`,**保留 4 并行描述**;L13 工作流图泛指不动。
- **均不改现有 4 维描述**(spec §8.1);只追加括注。
- 凭证:CLAUDE×2 命中凭证(根级 covers 写 `<root>/CLAUDE.md`,M4 写 `CLAUDE.md`);QUICKREF **不命中凭证**(无 glob)但仍要改(触点 ≠ 凭证 — spec §8.1/§8.4)。

**验证标准:**
- `grep -nE "review-scout|ultracode 走 scout|ultracode 下走" "D:\个人\harness\CLAUDE.md" "harness/CLAUDE.md" "harness/QUICKREF.md"` → 期望:根 CLAUDE 1 处 + harness CLAUDE 2 处 + QUICKREF 1 处命中
- 双写对核:`diff <(grep '设计审查' "D:\个人\harness\CLAUDE.md") <(grep '设计审查' "harness/CLAUDE.md")` → 期望:角色表设计审查行加注语义一致(spec §8.3 CMD5)
- 4 维描述保留核:`grep -nE "自洽性 / 完整性 / 合理性 / RUBRIC 对齐|4 并行子智能体" "D:\个人\harness\CLAUDE.md" "harness/CLAUDE.md" "harness/QUICKREF.md"` → 期望:现有 4 维/4 并行描述仍在
- [ ] commit:`feat: review-scout - CLAUDE×2 + QUICKREF 加 ultracode 走 scout 最小注`

---

## 任务 10:收口 — 跑 §8.3 全组触点完整性命令 + 凭证预告【契约任务 — 指令式(收口验证)】

> 收口验证任务:不改产物,跑 spec §8.3 全组命令确认触点完整 + 守 Y(现有路零改)+ 凭证预告。

**Files:** 无改动(纯验证)。

**操作(逐条跑 spec §8.3 命令组,记录实际输出对照期望;在 harness 仓库根执行):**

- [ ] **CMD1 结构兜底(全仓 diff,终结打地鼠)**:`git diff --stat`
  - 判据:改动集**只应出现** §8.1 列的 ADD/新建文件(2 新建 workflow.js + review-scout.md + SKILL + review-rules + synthesis[四处 ADD] + harness/setup.sh + credentials.conf + credentials-rules + CLAUDE×2 + QUICKREF)。
  - **任何现有路文件**(design-reviewer.md / synthesis L113-L151 维序段 / design-rules / model-route / references / README / ROADMAP / multi-agent-review-guide)出现在 diff = **违 Y,回退**。枚举漏一也被本条逮到。
- [ ] **CMD1b synthesis 精核**:`git diff harness/docs/governance/synthesis-rules.md`
  - 期望:只有四处 ADD 新行(主表 / L99 / L169 / L3 各 +1);L113/L151 维序原文零改(diff 无维序段)
- [ ] **CMD2 现有 4 维原文仍在**(synthesis 用实际缩写):`grep -nE '自洽 / 完整 / 合理|4 维度独立评分|维度固定顺序' harness/docs/governance/synthesis-rules.md`
  - 期望:主表行 + 4 维度独立评分 + 维度固定顺序 原文仍在
  - `grep -nE '过度工程化挑战者' "harness/.claude/agents/design-reviewer.md"` → 期望 L198 原文仍在
  - `grep -nE '4 个并行子智能体|design-reviewer fork 失败' harness/docs/governance/design-rules.md` → 期望 L61 + L181 原文仍在
- [ ] **CMD3 现有路 4 挑战者引用(治理+参考层不改,确认仍在)**:
  `grep -rnE 'design-review 4 挑战者|4 并行子智能体|fork reviewer team|design-review 多智能体|4 维并行挑战者|4 挑战者扇出|4 路并行扇出|4 维选定|自洽性/完整性/合理性/RUBRIC' README.md harness/README.md harness/docs/governance/model-route.md harness/docs/governance/design-rules.md harness/docs/references/ harness/docs/ROADMAP.md`
  - 期望:README×2 / model-route / references / ROADMAP 原描述仍在(未被改)
- [ ] **CMD4 ADD 的 scout 注/分支/synth 行已落**:
  `grep -rnE 'review-scout|ultracode .*走|走 scout' harness/docs/governance/review-rules.md harness/docs/governance/synthesis-rules.md "harness/.claude/skills/design-review/SKILL.md" harness/QUICKREF.md CLAUDE.md harness/CLAUDE.md`
  - 期望:review-rules scout 注 + synthesis 四处 + SKILL 分支 + QUICKREF/CLAUDE×2 注 各命中
- [ ] **CMD5 双写对核**:`diff <(grep '设计审查' CLAUDE.md) <(grep '设计审查' harness/CLAUDE.md)`
  - 期望:角色表设计审查行加注语义一致
- [ ] **CMD6 分发 + 凭证双写**(setup.sh 实物在 harness/ 下):
  `grep -nE 'workflows' harness/setup.sh "harness/.claude/hooks/credentials.conf" harness/docs/governance/credentials-rules.md`
  - 期望:harness/setup.sh 复制段 + conf glob 行 + credentials-rules §2 行 各命中
- [ ] **CMD7 AGENTS×2 仍零命中(不改)**:`grep -nE '设计审查|4 维' AGENTS.md harness/templates/AGENTS.md`
  - 期望:**无输出**
- [ ] **新建件结构复跑**(任务 1/2 验证):workflow.js 禁用项零命中 + `export const meta`/phase/agent/parallel 用法核;review-scout.md 纯推维(无 FLOOR_FOCUS/挑战者 prompt 库)

**凭证预告(写进 handoff / 交收口):**
- [ ] 本改动命中 credentials.conf 的文件:`.claude/skills/design-review/SKILL.md`(skills glob)/ `docs/governance/review-rules.md` + `synthesis-rules.md` + `credentials-rules.md`(governance glob)/ `setup.sh` / `.claude/hooks/credentials.conf`(hooks glob)/ 根 `CLAUDE.md`(写 covers `<root>/CLAUDE.md`)+ `harness/CLAUDE.md`(写 `CLAUDE.md`)/ `.claude/agents/review-scout.md`(agents glob 自动)/ `.claude/workflows/review-scout.workflow.js`(**新 glob**)。
- [ ] **finishing 须产 audit 凭证**(对抗审查;review-rules 治理行 bootstrap-4 维 + **触点完整性维**——本改动跨多文件 + 加分发 glob,命中"跨文件计数/枚举 + 分发链",触点完整性维优先选用)。audit covers 列上述全部命中文件(QUICKREF 不命中凭证 → 不进 covers;design-reviewer.md / model-route / references 本功能不改 → 不进 covers)。
- [ ] **守 Y 自核**:audit 须确认 design-reviewer.md / synthesis-rules L113/L151 维序 / design-rules 收口 git diff = 空(D13 活备份零改)。
- [ ] 无 commit(纯验证任务);验证结果记入 handoff 收口段。

---

## Self-Review(spec 覆盖 / 占位符扫 / 类型一致)

### spec 覆盖核

| spec 模块(§2.1) | 计划任务 | 覆盖 |
|---|---|---|
| M-scout-wf(workflow.js + focus 常量库) | 任务 1(契约+focus 库)+ 任务 2(编排) | ✅ |
| M-scout-agent(review-scout.md 纯推维) | 任务 3 | ✅ |
| M-skill(SKILL 加分支 + scout 维序说明) | 任务 4 | ✅ |
| M-floor-table(review-rules scout 注 + 地板维表权威) | 任务 5 | ✅ |
| M-synth-ADD(synthesis 四处 ADD) | 任务 6 | ✅ |
| M-分发凭证(setup.sh + conf + §2) | 任务 7(setup.sh)+ 任务 8(conf+§2) | ✅ |
| M-地图注(CLAUDE×2 + QUICKREF) | 任务 9 | ✅ |
| M-reviewer / M-现有路不动(零改) | 任务 10 CMD1/CMD2 验证零改 | ✅(验证守 Y) |

| spec 接口(§3) | 计划任务 | 覆盖 |
|---|---|---|
| §3.1 workflow 入参 | 任务 2(入参契约+错误处理)+ 任务 4(SKILL 传参) | ✅ |
| §3.2 SCOUT_SCHEMA | 任务 1(schema 定义)+ 任务 3(scout 产出) | ✅ |
| §3.3 challengerPrompt + focus 来源 | 任务 1(FLOOR_FOCUS)+ 任务 2(challengerPrompt 构造) | ✅ |
| §3.4 FINDING_SCHEMA | 任务 1 | ✅ |
| §3.5 出参 + scout 综合维序 | 任务 2(出参)+ 任务 4(维序说明住 SKILL) | ✅ |

| spec 核心场景(§1.2) | 计划任务 | 覆盖 |
|---|---|---|
| P0 场景1(ultracode 走 scout) | 任务 1-4 全链 | ✅ |
| P0 场景2(方向盘自适应 A-3) | 任务 3(scout A-3 判据)+ 任务 1(FLOOR_FOCUS 方向盘维带回落分支) | ✅ |
| P0 场景3(非 ultracode 走现有 4 维) | 任务 4(分支 else 走现有流程,零改) | ✅ |
| P1(代码/治理留口) | 任务 1(FloorTable 三行 + reviewType 枚举) | ✅ |

| spec 测试场景(§6.1) | 计划验证步 | 覆盖 |
|---|---|---|
| workflow 结构静态核 + 禁用项 | 任务 1/2 验证 + 任务 10 复跑 | ✅ |
| SKILL 分支文档核 + 现有流程零改 | 任务 4 验证 + 任务 10 CMD4 | ✅ |
| D13 scout 路 prompt 自有零关系 | 任务 1(focus 在 workflow.js)+ 任务 3(纯推维)+ 任务 10 CMD1/CMD2 | ✅ |
| §8 触点同步(CMD1 全仓 diff 兜底) | 任务 10 全组 | ✅ |

### 占位符扫

- workflow.js 骨架:`export const meta`、FloorTable、DesignCandidateMenu、FLOOR_FOCUS(四维 focus 全文)、SCOUT_SCHEMA、FINDING_SCHEMA **实际内容已写出**(任务 1),engineer 照抄;challengerPrompt 结构/编排逻辑给"问题+约束+验证标准"(任务 2,实现任务式,留 engineer 判断具体 JS 写法,但所有约束精确)。
- 各治理文件 ADD 文本:review-rules scout 注(任务 5)、synthesis 四处行(任务 6)、conf+§2 glob 行(任务 8)、CLAUDE×2/QUICKREF 注(任务 9)**均给实际可照抄文本**。
- SKILL 分支段(任务 4)给实际 markdown 块。
- **无 `[待填]`/`[TODO]`/`<占位>` 类未定义占位符**(FLOOR_FOCUS 内的 `<被审 spec>` 等是入参占位,属契约形态,非计划缺口)。

### 类型一致核

- schema 字段名全文一致:`reviewType` / `inherited_floor` / `added_dimensions` / `skipped_candidates` / `challenger_focus` / `why_this_time` / `rubric_mode`(任务 1 schema ↔ 任务 3 scout 产出 ↔ spec §3/§4 一致)。
- FloorTable design 行 `['方向盘对齐','自洽性']` ↔ inherited_floor ↔ review-rules 地板维表(任务 5)↔ spec §4.1 一致。
- FLOOR_FOCUS 键(方向盘对齐/自洽性/完整性/过度工程化)= FloorTable.design ∪ DesignCandidateMenu,workflow 按 d.name 映射无断键(任务 2 验证 focus 映射核)。

### 发现的 gap → 已补

- 模块文档处置:planning-rules 要求"新建模块任务含 README",但 harness meta 工件目录惯例无 per-目录 README(`.claude/agents/`/`.claude/skills/` 现状无目录 README)→ 已在「模块文档处置」段明确**不建 README**,由 workflow.js 文件头注承担文档职责(任务 1 已含头注步)。**非偏离 spec**(spec §2 注明 harness 自仓库无 ARCHITECTURE.md 产品分层,模块=工件)。

### 需回设计阶段的偏离点

**无。** 计划全程对齐 spec §2-§9,未发现需偏离设计文档之处。

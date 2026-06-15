# code-review-scout 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. 每个任务一个 commit(C 风格频繁提交)。

**Goal:** 给 review-scout 扩展**代码审查**(`reviewType='code'`),fork-N 同形,新建 harness 侧 **code-review skill** 入口(镜像 design-review SKILL 的运行时分支)。ultracode/Workflow 在场时 code-review SKILL 分支去调 `review-scout.workflow.js`(传 `reviewType='code'`:scout 现推维 = code 地板 3 维 [方向盘对齐 + 简洁性 + spec忠实性] + 动态加 + 候选 skipped 强制留痕),`parallel()` 一维一挑战者扇出,返回 `{plan, findings}` 交调度者综合;ultracode 不在场时**回落现有 Superpowers `requesting-code-review` 流程,原样不动、不改 Superpowers 包**(either-or,不叠加)。

**Architecture:** ADD 一条 code scout 路并排于 Superpowers 回落路;**不替换** Superpowers。改动物 = ① `review-scout.workflow.js` 扩展(加 code 常量 + 两 prompt 函数加 reviewType 分支,**design else 分支逐字保留** = 行为零变)② 新建 `.claude/skills/code-review/SKILL.md`(镜像 design-review SKILL)③ `review-scout.md` 推维步骤按 reviewType 切语境 ④ 一组 ADD 式 markdown 治理改动(review-rules / synthesis-rules / CLAUDE×2 / QUICKREF)+ setup.sh 分发段。依赖方向 = 调用方向(调度者→workflow→scout/挑战者),无循环。**code 路挑战者 prompt 与 `design-reviewer.md` 零关系**(code focus = workflow.js `FLOOR_FOCUS_CODE` 常量,scout 路自有,不读/不抄/不镜像 design-reviewer.md)。design 路(`reviewType='design'`)+ design-review SKILL + Superpowers 回落路**零改动**。

**Tech Stack:** JavaScript(Workflow 工具脚本:`export const meta` 纯字面量 + `phase`/`agent(...,{schema})`/`parallel` 钩子,Claude Code ultracode 运行时契约;禁用 `Date.now` / `Math.random` / 无参 `new Date` / 文件系统 API)+ markdown 纯文件治理约定 + bash(setup.sh 分发段)+ git(每任务一 commit)。

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-15-code-review-scout-design.md`(627 行,已锁 2026-06-15;§2 模块 / §3 接口 / §4 数据 / §5 边界 / §6 测试 / §8 影响[改动文件表 §8.1 + grep 自核命令组 §8.3] / §9)
**拍板锚:** `harness/docs/decisions/2026-06-15-code-review-scout-decisions.md`(🟢 D-C1=A / D-C2=spec忠实性入地板 / D-C3=B 无门 / D-C4=A 接通-usable,用户 2026-06-15)
**上游主 spec(复用 SCOUT_SCHEMA/FINDING_SCHEMA/编排):** `harness/docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md`
**同类计划范本(结构/粒度/验证写法仿它):** `harness/docs/superpowers/plans/2026-06-13-review-scout.md`

---

## 适配说明(本功能是 harness meta 改动,不是代码+pytest)

- 改动物 = 1 个 workflow 脚本扩展(加 code 常量 + 两 prompt 函数 reviewType 分支)+ 1 个新建 skill(markdown)+ 1 个 agent 定义改动 + 一组 ADD 式 markdown 治理改动 + setup.sh 分发段。
- **"验证"不套 pytest**:用 spec §6 / §8.3 定的 =
  - (a)workflow 脚本结构静态核(`grep`/`diff`:`reviewType==='code'` 分支用法 / `FloorTable.code` 3 维 / `CodeCandidateMenu` / `FLOOR_FOCUS_CODE` 键 / 禁用项无 `Date.now`·`Math.random`·无参 `new Date`·无 FS);
  - (b)**design 路零变验证**(spec §6.1 A 簇行 / §8.3 CMD2):design 路两函数固定入参输出**改前后逐字 diff=空**(prompt 文本快照 fixture)+ else 分支静态 grep(design 串仍命中)+ design 常量/编排 `git diff` 零改;
  - (c)spec §8.3 grep 自核命令组 + 全仓 `git diff --stat` 兜底;
  - (d)文档一致性核(FloorTable.code↔review-rules 双写、新 skill 入口登记)。
  - **每个任务的"验证"步给实际可跑的 grep/命令 + 期望输出**(照范本)。
- **守 Y(零改清单)**:`reviewType='design'` 路行为**逐字零变**(design else 分支即改前文本,§8.3 CMD2 prompt 文本等价核,非只常量 diff);`design-reviewer.md` / `design-review/SKILL.md` / Superpowers `requesting-code-review` 回落路 / `FloorTable.design` / `DesignCandidateMenu` / design 版 `FLOOR_FOCUS` 键 / `SCOUT_SCHEMA` / `FINDING_SCHEMA` / `reviewScout` 默认导出**零改动**;收口靠 §8.3 CMD1/CMD2/CMD3 验证它们不在(或正确在)改动集。
- **凭证 vs 触点两套独立**:凭证命中 = 新 SKILL(`.claude/skills/*/*.md` glob)/ review-rules + synthesis-rules(governance glob)/ workflow.js(`.claude/workflows/*` glob,2026-06-13 已立)/ review-scout.md(`.claude/agents/*.md` glob 自动)/ setup.sh / CLAUDE×2;**QUICKREF 改但不命中凭证**(无 QUICKREF glob — 触点 ≠ 凭证)。`credentials.conf` / `credentials-rules` **不改**(所需 glob 均已存在,§8.1 行)。

## 待回设计清单(0 条)

> 规则:计划不静默偏离 spec;执行中发现 spec 不可执行点,停下回设计裁决。本计划写作时点逐文件核真实文本(workflow.js / SKILL.md / review-rules.md / synthesis-rules.md / setup.sh / QUICKREF.md / CLAUDE×2 / review-scout.md),**未发现阻塞性不可执行点**。

## 模块文档处置(.claude/skills/code-review/ 是否要 README)

**结论:不建 README。** 依据(同范本任务结论):① harness 自仓库无 ARCHITECTURE.md 产品分层,`.claude/skills/` 各目录现状均无 per-目录 README(各 SKILL.md 自述);planning-rules「模块文档」节针对产品代码模块 README,与 harness meta 工件目录惯例不同;② 新 SKILL.md 自身即其文档(说明"这是什么/怎么被调")。**故本计划不创建 `.claude/skills/code-review/README.md`**。

---

## 任务依赖与排序

契约任务(reviewType 分支契约 / FloorTable.code 3 维 + CodeCandidateMenu + FLOOR_FOCUS_CODE 常量 / challengerPrompt 增 reviewType 形参签名 / code-review skill 分支契约 / SCOUT_SCHEMA·FINDING_SCHEMA 复用声明)**前置**于 wiring/实现任务(planning-rules 硬规矩)。排序:

1. **任务 1【契约】** — `review-scout.workflow.js` code 常量契约(`FloorTable.code` 3 维替占位 + 新增 `CodeCandidateMenu` + 新增 `FLOOR_FOCUS_CODE`,含三互斥边界 focus)
2. **任务 2【契约】** — `scoutPrompt` 加 reviewType 分支(候选菜单按 reviewType 取 + 被审材料指针 code 路注 diffRef+spec + governance 守卫;design else 逐字保留)
3. **任务 3【契约】** — `challengerPrompt` 增 `reviewType` 形参 + 三处串 reviewType 分支 + focus 取数按 reviewType 选(`FLOOR_FOCUS_CODE`);调用点 + 入参错误处理(diffRef 缺+spec 缺)同步(design else 逐字保留)
4. **任务 4【实现】** — `review-scout.md` 推维步骤按 reviewType 切候选菜单/语境 + B-8 code 加维引导 + code 语境注(spec忠实性是地板维照抄 / 代码质量不另立)
5. **任务 5【契约】** — 新建 `.claude/skills/code-review/SKILL.md`(镜像 design-review SKILL 运行时分支 + scout 综合维序说明)
6. **任务 6【实现】** — `review-rules.md` 三处改(L11 代码行 scout 主推注 + L19 code 地板行 2→3 维 + 补 code 候选/either-or 权威说明)
7. **任务 7【实现】** — `synthesis-rules.md` 两处 ADD code 地板数注(主表 L16 + 事前 5 清单 L101;维序段零改)
8. **任务 8【实现】** — CLAUDE×2「开发」行加注 + harness Skill 地图新 code-review 行 + QUICKREF Skill 表新 code-review 行
9. **任务 9【实现】** — `harness/setup.sh` 加 code-review skill 复制段
10. **任务 10【契约/收口】** — 收口:跑 §8.3 全组命令(全仓 diff 兜底 + design 路零变三层核)+ 凭证预告

---

## 任务 1:review-scout.workflow.js — code 常量契约(FloorTable.code 3 维 + CodeCandidateMenu + FLOOR_FOCUS_CODE)【契约任务 — 指令式】

> 契约任务:精确给定义(planning-rules)。本任务只改/加**契约级常量**;两 prompt 函数的 reviewType 分支在任务 2/3 接上。常量是 code 路的全部数据契约住址。

**Files:**
- modify: `harness/.claude/workflows/review-scout.workflow.js`(改 `FloorTable.code` L28;新增 `CodeCandidateMenu` + `FLOOR_FOCUS_CODE` 常量,紧贴现有 `FLOOR_FOCUS`[L40-56] 之后)

**依据:** spec §4.1(1)(2)(3) / §3.3 互斥边界表 / D-C1=A(类型契约入候选)/ D-C2(spec忠实性入地板)/ decisions「综合结果」。

- [ ] **改 `FloorTable.code`**(现 L28 占位 `['方向盘对齐', '简洁性']` → 3 维)。把:

```javascript
  code:       ['方向盘对齐', '简洁性'],                              // D4: 留口,本轮不接线
```

  改为:

```javascript
  code:       ['方向盘对齐', '简洁性', 'spec忠实性'],               // D-C1=A 地板 + D-C2 spec忠实性入地板(用户拍板 2026-06-15)
```

  - **派生自 review-rules 代码行地板维表注**(权威上游,任务 6 同步为 3 维);改维名先改 review-rules 注、再改本常量 — 双写对见 credentials-rules §8 第 6 条(现有 FloorTable 头注 L25 已声明此义务,不改头注)。
  - **`design` 行 L27 / `governance` 行 L29 逐字零改**(F 守住)。

- [ ] **新增 `CodeCandidateMenu`**(spec §4.1(2);紧贴现有 `DesignCandidateMenu`[L35] 之后,与之并列):

```javascript
// 标准候选菜单(scout 路 code 类;scout 每次必考虑,不加须进 skipped_candidates — A4 / D-C1=A)
// = review-rules 代码类五节里"非地板、且 diff 驱动条件相关"的维(B 维度分类:条件相关降候选)。
// 派生自 review-rules 代码行 code 候选注(权威上游,任务 6);改名先改 review-rules、再改本常量。
const CodeCandidateMenu = ['类型契约合规', '架构合规', '模块文档一致性'];  // D-C1=A:类型契约入候选(diff 驱动,非地板)
```

- [ ] **新增 `FLOOR_FOCUS_CODE`**(spec §4.1(3);紧贴现有 `FLOOR_FOCUS`[L56 闭合 `};`] 之后)。**照抄 spec §4.1(3) 给的 focus 全文**(scout 路自有,code 语境,**不镜像 design-reviewer.md**;三地板维各含「⚠️ 互斥边界」句 — E 簇可证边界):

```javascript
// ★ 新增 code 维 focus 常量(scout 路自有,code 语境;与 design FLOOR_FOCUS 分开,避免污染 design 键)。
// design 版 FLOOR_FOCUS(L40-56)键全不改(F 守住);focus 取数处按 reviewType 选(challengerPrompt,任务 3)。
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
```

  - 6 个键 = code 地板 3(方向盘对齐 / 简洁性 / spec忠实性)+ code 候选 3(类型契约合规 / 架构合规 / 模块文档一致性)= `FloorTable.code ∪ CodeCandidateMenu`,workflow 按 `d.name` 映射无断键。

- [ ] **验证**(脚本结构静态核 — spec §6.1):
  - `grep -noE "code:[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:含 `code: ['方向盘对齐', '简洁性', 'spec忠实性']`(三维有序集,B 簇 §8.3 CMD4)
  - `grep -nF "design:     ['方向盘对齐', '自洽性']" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:命中(FloorTable.design 零改)
  - `grep -noE "CodeCandidateMenu = \[[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:`CodeCandidateMenu = ['类型契约合规', '架构合规', '模块文档一致性']`
  - `grep -nE "FLOOR_FOCUS_CODE|spec忠实性|类型契约合规" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:`FLOOR_FOCUS_CODE` 常量 + 两键命中
  - 互斥边界核(E 簇):`grep -noE "⚠️ 互斥边界" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**3 处命中**(方向盘对齐 / spec忠实性 / 简洁性 三 code 地板维 focus 各含一句)
  - 禁用项核:`grep -nE "Date\.now|Math\.random|new Date\(\)|require\(|readFileSync" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**无输出**
- [ ] commit:`feat: code-review-scout - workflow code 常量契约(FloorTable.code 3 维 + CodeCandidateMenu + FLOOR_FOCUS_CODE)`

---

## 任务 2:review-scout.workflow.js — scoutPrompt 加 reviewType 分支(候选菜单/被审材料/governance 守卫)【契约任务 — 指令式】

> 契约任务:`scoutPrompt(reviewType, targets, sessionIntent)` 现写死 design 串(`DesignCandidateMenu` L136 / `targets.spec` 作"被审材料(必读)" L139),改为 `reviewType` 分支;**design else 逐字保留现状 = 行为零变**(A 簇修订,非"零改函数体")。

**Files:**
- modify: `harness/.claude/workflows/review-scout.workflow.js`(`scoutPrompt` 函数体 L128-151)

**依据:** spec §3.1 scoutPrompt 改动点(三处串 → reviewType 分支 + governance 守卫)/ §5.1 ARCHITECTURE 缺失行 / §7.2 D-C5。

- [ ] **候选菜单按 reviewType 取 + governance 守卫**(spec §3.1 governance 留口守卫):在 `scoutPrompt` 函数体开头(现 `const floor = FloorTable[reviewType] || [];` L129 之后)加:

```javascript
  // 候选菜单按 reviewType 取;governance(本轮不接线)→ 空菜单 + 守卫注,不落空注入 design 菜单(spec §3.1)
  const menu = reviewType === 'code' ? CodeCandidateMenu
             : reviewType === 'design' ? DesignCandidateMenu
             : [];  // governance 留口:无调用方用 governance 调本 workflow(治理审查走现 A/B/C)
```

- [ ] **候选菜单行注入 `menu`**(现 L136 写死 `JSON.stringify(DesignCandidateMenu)`)。把:

```javascript
    `标准候选菜单(每次必考虑,不加须写进 skipped_candidates 留痕): ${JSON.stringify(DesignCandidateMenu)}`,
```

  改为(用 `menu`,governance 时为空数组并附 notes 提示):

```javascript
    `标准候选菜单(每次必考虑,不加须写进 skipped_candidates 留痕): ${JSON.stringify(menu)}`,
    ...(reviewType !== 'code' && reviewType !== 'design'
        ? ['(注:本 reviewType 未接线,不应被调用——notes 标 "未接线")'] : []),
```

- [ ] **被审材料指针按 reviewType 分支**(现 L138-139 写死 design 的 `被审材料(必读): ${targets.spec}`)。把这两行:

```javascript
    '被审材料 / 上下文指针(用 Read / Grep 自读,不要等人喂内容):',
    `  被审材料(必读): ${targets.spec}`,
```

  改为(code 路注 diffRef + 对照 spec;design else 逐字保留原 `被审材料(必读)` 行):

```javascript
    '被审材料 / 上下文指针(用 Read / Grep 自读,不要等人喂内容):',
    ...(reviewType === 'code'
        ? [`  改动范围(必读,git diff / Read 改动文件): ${targets.diffRef}`,
           `  对照 spec(被实现的设计 spec,如有;缺则纯 bugfix,notes 标无对照 spec): ${targets.spec}`]
        : [`  被审材料(必读): ${targets.spec}`]),
```

  - 其余指针行(rubric / architecture / decisionsDir / auditsDir L140-143)+ sessionIntent 段 + SCOUT_SCHEMA 输出段 **逐字零改**(两路通用)。
  - **design 分支(`else`)逐字 = 改前 L138-139 文本**(行为零变,§8.3 CMD2 (b) 核)。

- [ ] **验证**(spec §6.1 / §8.3 CMD2):
  - code 分支核:`grep -nE "reviewType === 'code'|改动范围\(必读|CodeCandidateMenu|menu" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:reviewType 分支 + diffRef 注 + menu 取数命中
  - **design else 逐字保留核**(A 簇行为零变):`grep -nF '被审材料(必读): ${targets.spec}' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**仍命中**(design else 原行)
  - governance 守卫核:`grep -nE "governance 留口|未接线" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:守卫注命中
  - 禁用项复核:`grep -nE "Date\.now|Math\.random|new Date\(\)" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**无输出**
- [ ] commit:`feat: code-review-scout - scoutPrompt 加 reviewType 分支(候选菜单/diffRef/governance 守卫;design else 逐字保留)`

---

## 任务 3:review-scout.workflow.js — challengerPrompt 增 reviewType 形参 + 三处串分支 + focus 按 reviewType 取 + 入参错误处理【契约任务 — 指令式】

> 契约任务:`challengerPrompt` 现签名 `(d, targets, sessionIntent)`、写死 design 串(角色行 L160 / 材料路径 L166 / location L180)、focus 取数 `(d.name in FLOOR_FOCUS) ? FLOOR_FOCUS[d.name] : d.challenger_focus`(L158)。本任务**增 `reviewType` 形参**(签名变更是契约改动)+ 三处串 reviewType 分支 + focus 按 reviewType 选 `FLOOR_FOCUS_CODE`;调用点 L224 同步加传;入参错误处理补 diffRef+spec 双缺。**design else 逐字保留 = 行为零变**(A 簇修订)。

**Files:**
- modify: `harness/.claude/workflows/review-scout.workflow.js`(`challengerPrompt` 函数 L156-183 + 调用点 L224 + 默认导出入参校验 L191-194)

**依据:** spec §3.3 challengerPrompt 改动点表(三处串)+ focus 来源表 + §4.1(3) 注的取数实现 / §3.1 错误处理(diffRef+spec 双缺)/ §5.1 边界行 / §7.2 D-C5。

- [ ] **签名增 `reviewType` 形参**(现 L156 `function challengerPrompt(d, targets, sessionIntent) {`)→ 末尾加 `reviewType`:

```javascript
function challengerPrompt(d, targets, sessionIntent, reviewType) {
```

- [ ] **focus 取数按 reviewType 选**(现 L158 单行)。把:

```javascript
  const focus = (d.name in FLOOR_FOCUS) ? FLOOR_FOCUS[d.name] : d.challenger_focus;
```

  改为(spec §4.1(3) 注的取数实现:code 维优先取 `FLOOR_FOCUS_CODE`,含 code 版方向盘对齐;design 维 / 动态维走原路):

```javascript
  // focus 取数按 reviewType 选(spec §4.1(3) / §3.3):code 路优先取 FLOOR_FOCUS_CODE(含 code 版方向盘对齐),
  // design 维 / 动态维(无 code 键)回落 design FLOOR_FOCUS 或 scout 的 challenger_focus。维名两路一致(不加后缀污染 SCOUT_SCHEMA/双写)。
  const isCode = reviewType === 'code';
  const focus = (isCode && d.name in FLOOR_FOCUS_CODE) ? FLOOR_FOCUS_CODE[d.name]
              : (d.name in FLOOR_FOCUS) ? FLOOR_FOCUS[d.name]
              : d.challenger_focus;
```

- [ ] **三处串 reviewType 分支**(spec §3.3 表;`reviewType === 'code' ? <code串> : <design串>`,else 即现状逐字):
  - **角色行**(现 L160):把 `你是设计审查挑战者,负责「${d.name}」这一维。...` 整行改为:

```javascript
    (reviewType === 'code'
      ? `你是代码审查挑战者,负责「${d.name}」这一维。审查对象 = 本次代码改动(diff),不是设计文档。你是对抗者,不是评分员(只产 findings + 证据,不打总分 — D8)。`
      : `你是设计审查挑战者,负责「${d.name}」这一维。你是对抗者,不是评分员(只产 findings + 证据,不打总分 — D8)。`),
```

  - **被审材料路径行**(现 L166 `被审材料路径(自己 Read,不要等人喂全文): ${targets.spec}`):改为:

```javascript
    (reviewType === 'code'
      ? `改动范围(自己 git diff / Read 改动文件): ${targets.diffRef}\n对照 spec/任务(如有,审 spec 忠实性用;缺则注"对照 sessionIntent / diff 自身意图"): ${targets.spec}`
      : `被审材料路径(自己 Read,不要等人喂全文): ${targets.spec}`),
```

  - **输出格式 location 提示**(现 L180 `... findings = [{title, location(文档节/路径), problem, ...`):把 `location(文档节/路径)` 串改为按 reviewType 分支。建议把该行拆成变量再注入:在 `return [` 之前加 `const locHint = reviewType === 'code' ? 'location(改动文件路径:行号)' : 'location(文档节/路径)';`,再把 L180 的 `location(文档节/路径)` 替换为 `${locHint}`。design else 时 `locHint` = `'location(文档节/路径)'`(逐字现状)。

  - **主线-支线-关系段 / challenger-orientation 引导 / 中性约束 / user_words_section 段**(L162-181 其余行)**逐字零改**(两路通用骨架)。

- [ ] **调用点同步加传 `reviewType`**(现 L224 `const prompt = challengerPrompt(d, targets, sessionIntent);`):

```javascript
        const prompt = challengerPrompt(d, targets, sessionIntent, reviewType);
```

  - `reviewType` 已在 `reviewScout` 解构(L188 `const { reviewType, targets, sessionIntent } = input || {};`),作用域可见,无需额外取。

- [ ] **入参错误处理补 diffRef+spec 双缺**(spec §3.1 / §5.1:code 路审"一批改动",diffRef+spec 皆缺无法审)。现默认导出 L191-194 仅校验 `!targets || !targets.spec`。改为兼顾 code 路(diffRef 缺且 spec 缺才报错;design 路仍要求 spec):

```javascript
  // 入参校验(spec §3.1 / §5.1):
  // - 缺 targets 整体 → 报错返回空。
  // - design 路:缺 targets.spec(被审材料路径)→ 报错。
  // - code 路:缺 targets.diffRef 且缺 targets.spec(改动范围与对照 spec 皆无,无法审)→ 报错。
  const codeMissing = reviewType === 'code' && !targets?.diffRef && !targets?.spec;
  const designMissing = reviewType !== 'code' && (!targets || !targets.spec);
  if (!targets || codeMissing || designMissing) {
    log('review-scout: 入参缺被审材料指针(design 缺 targets.spec / code 缺 targets.diffRef+spec)→ 返回 {plan:null, findings:[]}');
    return { plan: null, findings: [] };
  }
```

  - **注**:design 路语义零变(仍 `!targets.spec` 报错);code 路新增"diffRef+spec 双缺"判据。`targets?.diffRef` 用可选链(纯属性读,非禁用项;无 `Date.now`/`Math.random`/FS)。

- [ ] **验证**(spec §6.1 / §8.3 CMD2):
  - code 分支核:`grep -nE "你是代码审查挑战者|location\(改动文件路径|FLOOR_FOCUS_CODE\[|reviewType\)" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:code 角色行 + code location + code focus 取数 + 调用点加传命中
  - **design else 逐字保留核**(A 簇):
    - `grep -nF '你是设计审查挑战者,负责' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**仍命中**(design else 角色行原文)
    - `grep -nF 'location(文档节/路径)' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**仍命中**(design else location 原文)
    - `grep -nF '被审材料路径(自己 Read,不要等人喂全文): ${targets.spec}' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**仍命中**(design else 材料路径原文)
  - 错误处理核:`grep -nE "codeMissing|designMissing|diffRef" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:diffRef+spec 双缺分支命中
  - 禁用项复核:`grep -nE "Date\.now|Math\.random|new Date\(\)|readFileSync|import .* from 'fs'" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:**无输出**
- [ ] commit:`feat: code-review-scout - challengerPrompt 增 reviewType 形参 + 三处串分支 + focus 取数 + 入参错误处理(design else 逐字保留)`

---

## 任务 4:review-scout.md — 推维步骤按 reviewType 切语境 + B-8 code 加维引导 + code 语境注【实现任务 — 问题式】

> 实现任务:给问题+约束+验证标准(planning-rules)。现 `review-scout.md` 第 3 步硬编码 design 候选(L48-57 `DesignCandidateMenu = ['完整性', '过度工程化']`),"你会收到" L16 写死 `reviewType` 只接 `'design'`。改为按 reviewType 取菜单/语境,**不动单一职责(=推维)**。

**Files:**
- modify: `harness/.claude/agents/review-scout.md`

**问题:** scout 被 workflow fork 后读本文件按 reviewType 推维。现指令通篇 design 语境(候选 = 完整性/过度工程化,A-3 回落,B-8 引导举例),须补 code 路语境:候选菜单按 reviewType 取(code = 类型契约合规/架构合规/模块文档一致性)、code 地板 3 维照抄、B-8 给 code 信号举例、明确 code 语境约束(spec忠实性是地板维照抄、代码质量不另立)。

**约束:**
- **单一职责 = 推维不变**(spec §2.1 CM-scout-agent):仍只推维 + A-3 判据 + B-8 引导;**不承载挑战者 focus 库**(focus 库在 workflow.js `FLOOR_FOCUS_CODE`,任务 1)。
- **改"你会收到"段 L16**:`reviewType` 由"本轮只接 `'design'`"改为"本轮接 `'design'` 或 `'code'`(governance 留口未接线)";`targets` 段补 code 路 `diffRef`(改动范围引用,code 路必读;design 路无此字段)说明。
- **改第 1 步(照抄地板)L23-25**:补 code 类地板 = `方向盘对齐` + `简洁性` + `spec忠实性`(3 维),照抄不增删;design 类仍 2 维。**明确:code 路 `spec忠实性` 是地板维(照抄,非自己发明);`代码质量` 不另立 added 维(已被 code 版方向盘对齐 focus 通用基线覆盖 — D-C2;误加则调度者综合去重)**。
- **改第 3 步(候选菜单)L48-57**:候选菜单按 reviewType 取——design = `['完整性', '过度工程化']`(现状);code = `['类型契约合规', '架构合规', '模块文档一致性']`(每个候选不加须 `skipped_candidates` 留痕)。**架构合规候选**:code 路若考虑加但 `targets.architecture` 缺失(自仓库无)→ 不加 + skipped 写"无 ARCHITECTURE,跳过"(spec §5.1)。
- **改第 4 步约束 L63**:不重叠约束按 reviewType 取地板/候选集(code 路 = 不与 `方向盘对齐/简洁性/spec忠实性` 地板或 `类型契约合规/架构合规/模块文档一致性` 候选重叠)。
- **改 B-8 引导(L69-79)**:现 design 信号举例可保留为 design 路;**新增 code 路信号举例**(spec D-C 发明维 + decisions「综合结果」发明维):迁移/schema 变更信号 → "迁移安全 / 回滚路径"维;跨文件契约/双写信号 → "触点完整性"维;并发/外部依赖信号 → "并发安全"维;鉴权/输入边界信号 → "安全边界"维;接口签名变更信号 → "向后兼容"维。诚实标注退化(降概率不消除)保留。
- **A-3 判据(第 2 步 L27-46)两路通用**(读 RUBRIC 判 filled/template + 回落 CLAUDE.md + 二公设);**focus 文字按 reviewType 分由 workflow.js 管,不归 scout 写**(现 L46 已声明,保留)。
- **形态/路径前缀(L1-5)不动**(说明文件,无 frontmatter tools)。

**验证标准:**
- code 语境核:`grep -nE "reviewType|code|类型契约合规|架构合规|模块文档一致性|diffRef" "harness/.claude/agents/review-scout.md"` → 期望:reviewType 两值 + code 候选三维 + diffRef 说明命中
- code 地板 + spec忠实性照抄核:`grep -nE "spec忠实性|代码质量.*不另立|地板维.*照抄" "harness/.claude/agents/review-scout.md"` → 期望:spec忠实性是地板维(照抄)+ 代码质量不另立 注命中
- B-8 code 信号核:`grep -nE "迁移安全|触点完整性|并发安全|安全边界|向后兼容" "harness/.claude/agents/review-scout.md"` → 期望:code 加维信号举例命中
- 单一职责守住核:`grep -nE "FLOOR_FOCUS_CODE|挑战者 prompt|challengerPrompt" "harness/.claude/agents/review-scout.md"` → 期望:**无输出,或仅说明"focus 库不在此(在 workflow.js)"**(scout 不承载 focus 库)
- A-3 判据保留核:`grep -nE "示例,请替换|rubric_mode|filled|template" "harness/.claude/agents/review-scout.md"` → 期望:A-3 判据串仍在(两路通用)
- [ ] commit:`feat: code-review-scout - review-scout.md 推维按 reviewType 切语境 + B-8 code 加维引导`

---

## 任务 5:新建 .claude/skills/code-review/SKILL.md(镜像 design-review SKILL 运行时分支)【契约任务 — 指令式】

> 契约任务:新 skill 入口契约(运行时分支 + scout 综合维序说明)。镜像 `design-review/SKILL.md`(L1-31 frontmatter + 执行分支),但输入 = 代码 diff、回落 = Superpowers `requesting-code-review`、维序 = code plan。**不复用 design-review skill**(spec §2.1 粒度反向追问:输入/回落/维序 code 专属,合一违单一职责)。

**Files:**
- create: `harness/.claude/skills/code-review/SKILL.md`

**依据:** spec §1.3「做」第 1 项 / §2.1 CM-skill / §3.5(综合维序住此)/ §5.1(ultracode 关→Superpowers 回落)/ §8.1。镜像范本 = `harness/.claude/skills/design-review/SKILL.md`。

- [ ] 写 frontmatter(镜像 design-review SKILL L1-6,description 改 code 语境;**either-or 不叠加** + ultracode 专属据实写):

```markdown
---
name: code-review
description: "代码审查。一批代码改动完成后触发。ultracode/Workflow 在场时走 review-scout(reviewType='code',scout 现推维:code 地板 3 维 + 动态加);否则回落 Superpowers requesting-code-review(either-or,不叠加,不改 Superpowers 包)。"
invocation: manual
allowed-tools: Read, Glob, Grep, Bash, Agent
---

# 代码审查

> **架构**:ADD review-scout code 路并排于 Superpowers `requesting-code-review` 回落路(**either-or**,不替换、不叠加)。详见 `docs/superpowers/specs/2026-06-15-code-review-scout-design.md`。
```

  - 注:**不写 `Write` 工具**(design-review SKILL 有 Write 因它写 result 盘;code 路综合落点沿 Superpowers/现状,调度者综合时按需,allowed-tools 据实写 Read/Glob/Grep/Bash/Agent;若实现中确需 Write 落 result,可加——engineer 据真实落点定,不投机预留)。

- [ ] 写「## 执行」运行时分支段(镜像 design-review SKILL L22-31 结构,**code 语境**:ultracode→review-scout `reviewType='code'` + diffRef / 否则→Superpowers `requesting-code-review`;scout 路综合维序钉死此处 — spec §3.5):

```markdown
## 执行

> **运行时分支(ADD review-scout code 路并排 — either-or,不替换、不叠加 Superpowers;spec §1.2/§2.2/§5.1)**:
> 进入执行先做一次运行时探测——**Workflow/ultracode 工具是否可用**:
>
> - **可用(ultracode 开)→ 走 review-scout 路(主推审查路)**:调度者用 Workflow 工具启动 `review-scout`,入参
>   `{reviewType:'code', targets:{spec:<被实现的设计 spec 路径,纯 bugfix 无 spec 可缺>, diffRef:'<git 改动范围,如 HEAD~N..HEAD 或分支名>', rubric:'docs/RUBRIC.md', architecture:'docs/ARCHITECTURE.md', decisionsDir:'docs/decisions/', auditsDir:'docs/audits/'}, sessionIntent:'<一行会话意图,措辞中性>'}`。
>   workflow 返回 `{plan, findings}`。**scout 路综合维序说明(钉死此处,单一住址 — spec §3.5)**:scout 路维度由 `plan` 动态定(code 地板 3 维 = 方向盘对齐 + 简洁性 + spec忠实性,+ 动态加维),综合维序 = **按 plan 产出的维度清单顺序**交叉读 findings(不用固定维序)。综合仍按 synthesis-rules 事后规则(回意图/决策/客观/避先入为主 + 校验「已对照用户原话」section)。
>   - scout 空返回/审查失败(`plan:null`)→ **显式报用户审查失败**(按本 skill 错误处理重试);**不静默回落 Superpowers**(scout 失败 ≠ ultracode 不在场 — spec §5.1)。
>   - **★ either-or**:ultracode 路**不并跑** Superpowers `requesting-code-review`。spec 忠实性由 scout 地板第 3 维(spec忠实性)保证、代码质量由「方向盘对齐」通用基线覆盖(无真空 — D-C2)。
> - **不可用(ultracode 关 / 非 Claude Code / 逐会话未 opt-in)→ 回落到 Superpowers `requesting-code-review` 流程,原样调用**(已存在的活路,**不改 Superpowers 包**、**不标"降级执行"** — spec §5.1)。scout 动态推维在此回落路不可得 = ultracode 专属取舍。
```

- [ ] **不嵌入 Superpowers 流程内容 / 不抄 design-reviewer.md**(回落路原样调用 Superpowers `requesting-code-review`;code focus 住 workflow.js `FLOOR_FOCUS_CODE`,本 SKILL 不载 focus/不抄 design-reviewer.md)。
- [ ] 放在 `harness/.claude/skills/code-review/SKILL.md`(凭证义务命中 `.claude/skills/*/*.md` glob,自动入凭证)。

**验证标准:**
- 文件存在 + 分支段核:`grep -nE "review-scout|reviewType.?code|requesting-code-review|按 plan 产出的维度清单|either-or" "harness/.claude/skills/code-review/SKILL.md"` → 期望:运行时分支 + reviewType='code' + Superpowers 回落 + scout 综合维序 + either-or 各命中
- frontmatter 核:`grep -nE "^name: code-review|^description:" "harness/.claude/skills/code-review/SKILL.md"` → 期望:name + description 命中
- 不抄 design-reviewer 核:`grep -nE "design-reviewer|DesignCandidateMenu|自洽性 / 完整性 / 合理性" "harness/.claude/skills/code-review/SKILL.md"` → 期望:**无输出**(code SKILL 与 design-reviewer.md 零关系)
- [ ] commit:`feat: code-review-scout - 新建 code-review SKILL(镜像 design-review 运行时分支 + scout 综合维序)`

---

## 任务 6:review-rules.md 三处改(代码行 scout 注 + L19 code 地板 2→3 维 + 补 code 候选/either-or 权威说明)【实现任务 — 问题式】

> 实现任务。现状(真实文本):L11 代码行五节描述无 scout 注;L17-22 地板维表三类注里 **L19 code 行 = `code = 方向盘对齐 + 简洁性(留口,后续可加)`(2 维占位)**;无 code 候选/either-or 权威说明。本任务三处改,**防旧 L19 2 维与新 workflow.js 3 维两份打架**。

**Files:**
- modify: `harness/docs/governance/review-rules.md`

**问题:** review-rules 是 FloorTable.code↔review-rules 双写的**权威上游**(L22 已声明)。code 地板由 2 维占位接线为 3 维,且要补 code 候选/either-or 权威说明,与 workflow.js 双写逐字一致。

**约束(三处,精确落点):**
- ① **L11 代码行五节描述加 scout 主推注**(对齐 L12 设计行/ L15 设计行 scout 注写法):**不改五节正文 L46-79**,在 L11 单元格(或紧邻新增注行)加:"ultracode / Workflow 在场时,代码行**默认走 review-scout `reviewType='code'`**(主推:scout 现推维 = code 地板 3 维 + 动态加);Superpowers 五节 + 内嵌两段(spec 忠实性 + 代码质量)为 **ultracode 不在场时回落**(either-or,不与 scout 叠加跑)。code 地板/候选权威见下方 code scout 注。"
- ② **L19 code 地板行 2→3 维**(防两份打架)。把现状:

```
> - **code** = 方向盘对齐 + 简洁性(留口,后续可加)
```

  改为:

```
> - **code** = 方向盘对齐 + 简洁性 + spec忠实性
```

  - 去"留口,后续可加"措辞(已接线);三维顺序与 workflow.js `FloorTable.code` 逐字一致(双写,§8.3 CMD4)。
- ③ **补 code scout 权威节**(对齐 L15-24 设计行 scout 注的写法,在地板维表注 L17-24 之后或代码类维度集 L46 之前新增一段「代码行 scout 注 / code 地板·候选(权威住此)」),含:
  - code 地板 3 维 = **方向盘对齐 + 简洁性 + spec忠实性**(D-C2:spec忠实性入地板填 either-or 真空;代码质量由方向盘对齐通用基线覆盖,不单设维)。
  - code 候选 = **类型契约合规 + 架构合规 + 模块文档一致性**(D-C1=A:类型契约入候选,diff 驱动;scout 按 diff 选,不加须 skipped 留痕)。**双写**:`.claude/workflows/review-scout.workflow.js` 的 `CodeCandidateMenu` 是本注机读镜像。
  - either-or 说明:ultracode 路走 scout(不跑 Superpowers);非 ultracode 路走 Superpowers `requesting-code-review`(五节 + 两段)。两路互斥,不叠加。
  - 双写派生注:`FloorTable.code` / `CodeCandidateMenu` 是本注机读镜像,改维名须先改本注、再改 workflow.js(对齐 L22 design 双写派生注;credentials-rules §8 第 6 条)。
- **不改 L12 设计行 / L15-24 设计行 scout 注 / L46-79 代码类五节正文**(F 守住;scout 路从五节取候选维名,不改正文)。

**验证标准:**
- L19 3 维核(B 簇,§8.3 CMD4):`grep -nF "方向盘对齐 + 简洁性 + spec忠实性" harness/docs/governance/review-rules.md` → 期望:code 地板行命中同序三维
- 旧 2 维占位已除核:`grep -nF "code = 方向盘对齐 + 简洁性(留口" harness/docs/governance/review-rules.md` → 期望:**零命中**(若命中 = 两份打架,回退)
- code 候选双写核:`grep -nF "类型契约合规 + 架构合规 + 模块文档一致性" harness/docs/governance/review-rules.md` → 期望:候选注命中同序
- code scout 注 + either-or 核:`grep -nE "review-scout.*code|reviewType.?code|either-or|不叠加" harness/docs/governance/review-rules.md` → 期望:代码行 scout 主推注 + either-or 命中
- 五节正文 + 设计行零改核:`grep -nE "自洽性 / 完整性 / 合理性 / RUBRIC 对齐|## 简洁性审查|## 类型契约合规" harness/docs/governance/review-rules.md` → 期望:设计行 4 维 + 五节正文标题原文仍在
- [ ] commit:`feat: code-review-scout - review-rules 代码行 scout 注 + L19 code 地板 3 维 + code 候选/either-or 权威`

---

## 任务 7:synthesis-rules.md 两处 ADD code 地板数注(主表 L16 + 事前 5 清单 L101;维序段零改)【实现任务 — 问题式】

> 实现任务(C 簇 ADD)。现状(真实文本):主表 L16 `| review-scout | 动态 N(地板 2 + 动态加) | 调度者(Claude) |`;事前规则 5 清单 L101 `- review-scout(scout 驱动 N 挑战者,N=地板 2+动态加)`。两处写死"地板 2"对 code(地板 3)不准 → 各 ADD 注"地板按类:design 2 / code 3"。

**Files:**
- modify: `harness/docs/governance/synthesis-rules.md`

**问题:** synthesis 适用范围按 workflow 名 `review-scout` 已覆盖 code 路(L3/L16/L101 列了 review-scout),但 L16/L101 的"地板 2"是 design 数,对 code(地板 3)不准。**两处各 ADD 注**(不改维序段)。

**约束(两处 ADD,精确落点 — spec §8.1 C 簇行):**
- ① **主表 L16**:把 `| review-scout | 动态 N(地板 2 + 动态加) | 调度者(Claude) |` 改为:

```
| review-scout | 动态 N(地板按类:design 2 / code 3 + 动态加) | 调度者(Claude) |
```

- ② **事前规则 5 清单 L101**:把 `- review-scout(scout 驱动 N 挑战者,N=地板 2+动态加)` 改为:

```
- review-scout(scout 驱动 N 挑战者,N=地板按类 design 2/code 3+动态加)
```

- **维序段 / L3 何时读 / 事后规则适用范围 零改**(L3 已含 review-scout,按 workflow 名覆盖 code,不改;scout 路维序住 code-review SKILL scout 分支段,任务 5 已钉)。
- 放在 governance/(凭证义务命中 `docs/governance/*.md`)。

**验证标准:**
- ADD 注核(C 簇,§8.3 CMD8):`grep -nE "地板按类|design 2 / code 3|design 2/code 3" harness/docs/governance/synthesis-rules.md` → 期望:**2 处命中**(L16 主表 + L101 事前 5 清单)
- 旧"地板 2"裸写已除核:`grep -nE "地板 2 \+ 动态加|N=地板 2\+动态加" harness/docs/governance/synthesis-rules.md` → 期望:**零命中**(已被 code ADD 注替换;若命中 = 漏改一处)
- review-scout 行仍在核:`grep -nE "review-scout" harness/docs/governance/synthesis-rules.md` → 期望:L3 + L16 + L101 + 事后规则适用范围 各命中(适用范围未丢)
- [ ] commit:`feat: code-review-scout - synthesis-rules 主表/事前5 ADD code 地板数注(design 2/code 3)`

---

## 任务 8:CLAUDE×2「开发」行加注 + harness Skill 地图新 code-review 行 + QUICKREF Skill 表新行【实现任务 — 问题式】

> 实现任务。现状(真实文本):根 `CLAUDE.md` L32 / `harness/CLAUDE.md` L17 = `| **开发** | Superpowers subagent | 写代码(TDD + code review) |`(**无独立「代码审查」行**);`harness/CLAUDE.md` L112 = Skill 全局地图 design-review 行;`QUICKREF.md` L34 = 治理映射行 `code-review | review-rules.md`(**不动**)、L44 = Skill 表 design-review 行。

**Files:**
- modify: `D:\个人\harness\CLAUDE.md`(根治理入口,角色表「开发」行 L32)
- modify: `harness/CLAUDE.md`(M4 分发模板,角色表「开发」行 L17 + Skill 全局地图 L112 后新增行)
- modify: `harness/QUICKREF.md`(Skill 表 L44 后新增行;**L34 映射行不动**)

**问题:** 四个入口地图登记 code-review:CLAUDE×2「开发」行加注(无独立代码审查行)+ harness Skill 地图 + QUICKREF Skill 表各新增 code-review 行;不动现有描述。

**约束(精确落点 + 注内容):**
- **根 CLAUDE.md L32「开发」行**:说明列 `写代码(TDD + code review)` 行尾加注(不动现有描述):`(代码审查:ultracode 走 review-scout reviewType='code';否则 Superpowers requesting-code-review)`。
- **harness/CLAUDE.md L17「开发」行**:同款行尾加注(**与根双写,语义一致** — spec §8.3 CMD6 双写对核)。
- **harness/CLAUDE.md Skill 全局地图(L112 design-review 行之后)新增 code-review 行**(镜像 design-review 行写法):

```
| **code-review** | 一批代码改动完成后 | 主推:ultracode 走 review-scout(reviewType='code',scout 现推维)。回落:Superpowers requesting-code-review(either-or,仅 ultracode 不在场) |
```

- **QUICKREF.md Skill 表(L44 design-review 行之后)新增 code-review 行**(镜像 L44 写法;**L34 映射行不动**——skill 登记落 Skill 表,非映射行):

```
| code-review | 代码改动完成后 — 主推 ultracode 走 review-scout(reviewType=code);回落 Superpowers requesting-code-review（either-or） |
```

- **均不动现有描述**(spec §8.1);只追加注 / 新行。
- 凭证:CLAUDE×2 命中凭证(根级 covers 写 `<root>/CLAUDE.md`,M4 写 `CLAUDE.md`);QUICKREF **不命中凭证**(无 glob)但仍改(触点 ≠ 凭证)。

**验证标准:**
- 三入口注核(B 簇正则命中无引号文字,§8.3 CMD5):`grep -rnE "review-scout|reviewType=.?code" "D:\个人\harness\CLAUDE.md" harness/CLAUDE.md harness/QUICKREF.md` → 期望:根 CLAUDE 开发行注 + harness CLAUDE 开发行注 + harness CLAUDE Skill 地图新行 + QUICKREF Skill 表新行 各命中
- QUICKREF code-review 两处核(§8.3 CMD5):`grep -nF "code-review" harness/QUICKREF.md` → 期望:**2 处** = L34 映射行(原有,不动)+ Skill 表新行;只 1 处 = 漏建 Skill 表行
- 双写对核:`diff <(grep -E '开发.*Superpowers|code-review|review-scout' "D:\个人\harness\CLAUDE.md") <(grep -E '开发.*Superpowers|code-review|review-scout' harness/CLAUDE.md)` → 期望:「开发」行加注语义一致(harness 多 Skill 地图新行属预期差异)
- 现有描述保留核:`grep -nF "写代码(TDD + code review)" "D:\个人\harness\CLAUDE.md" harness/CLAUDE.md` → 期望:开发行原描述仍在
- [ ] commit:`feat: code-review-scout - CLAUDE×2 开发行加注 + harness Skill 地图/QUICKREF Skill 表新 code-review 行`

---

## 任务 9:harness/setup.sh 加 code-review skill 复制段【实现任务 — 问题式】

> 实现任务。现状(真实文本):skills 复制段 L56-71,每 skill = `mkdir -p .../skills/<name>` + `cp .../skills/<name>/SKILL.md`。code-review 是新 skill,须显式加 mkdir + cp 行(对齐现有 design-review 段 L61/L69)。

**Files:**
- modify: `harness/setup.sh`

**问题:** setup.sh 分发新 skill `code-review`(含 `SKILL.md`)。对齐现有 skills 复制段写法加 mkdir + cp。

**约束:**
- 在 skills `mkdir -p` 段(L57-63)末尾加一行(对齐 L61 design-review):

```bash
mkdir -p "$TARGET_DIR/.claude/skills/code-review"
```

- 在 skills `cp` 段(L64-71)末尾加一行(对齐 L69 design-review):

```bash
cp "$SCRIPT_DIR/.claude/skills/code-review/SKILL.md" "$TARGET_DIR/.claude/skills/code-review/"
```

- **最小变更**:只加这两行,不动现有段。`.claude/workflows/` 复制段(L52-54,2026-06-13 已立)/ `.claude/agents/` 段(含 review-scout.md L50)**不动**(workflow.js + review-scout.md 已被现有段分发,本功能只改其内容不新增文件)。
- setup.sh 实物 = `harness/setup.sh`,命中凭证义务 `setup.sh`。

**验证标准:**
- 复制段核:`grep -nF "code-review" harness/setup.sh` → 期望:**2 处** = mkdir 行 + cp SKILL.md 行
- 语法核:`bash -n "harness/setup.sh"` → 期望:exit 0,无报错
- 现有段未损核:`grep -nF "skills/design-review" harness/setup.sh` → 期望:design-review mkdir + cp 原行仍在
- [ ] commit:`feat: code-review-scout - setup.sh 分发 code-review skill`

---

## 任务 10:收口 — 跑 §8.3 全组触点完整性命令 + design 路零变三层核 + 凭证预告【契约任务 — 指令式(收口验证)】

> 收口验证任务:不改产物,跑 spec §8.3 全组命令确认触点完整 + 守 Y(design 路 + Superpowers 回落路零改)+ 凭证预告。**在 harness 仓库根执行**(`D:\个人\harness`)。

**Files:** 无改动(纯验证)。

**操作(逐条跑 spec §8.3 命令组 + design 路零变三层核,记录实际输出对照期望):**

- [ ] **CMD1 结构兜底(全仓 diff,终结打地鼠)**:`git diff --stat`
  - 判据:改动集**只应出现** §8.1 列文件:新建 `code-review/SKILL.md` + `review-scout.workflow.js` + `review-scout.md` + `review-rules.md` + `synthesis-rules.md` + 根 `CLAUDE.md` + `harness/CLAUDE.md` + `QUICKREF.md` + `harness/setup.sh`。
  - **design 路文件**(`design-review/SKILL.md` / `design-reviewer.md`)或 Superpowers 包出现任何 diff = **违 F 守住,回退**。
- [ ] **CMD2 design 路行为零变三层核(不只看常量 diff,看 prompt 文本等价 — A 簇)**:
  - (a) `git diff "harness/.claude/workflows/review-scout.workflow.js"` → 期望:diff 只 = 新增 code 常量(`FloorTable.code` 3 维 / `CodeCandidateMenu` / `FLOOR_FOCUS_CODE`)+ 两函数 reviewType 分支 + 调用点加传 + 入参校验扩展;`FloorTable.design` / `DesignCandidateMenu` / design 版 `FLOOR_FOCUS` 键 / `SCOUT_SCHEMA` / `FINDING_SCHEMA` / `reviewScout` 默认导出编排 **零 diff**(除调用点 L224 加传 reviewType + 入参校验块)。
  - (b) **design else 分支文本 = 改前文本**(静态 grep):
    - `grep -nF '你是设计审查挑战者,负责' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:仍命中
    - `grep -nF 'location(文档节/路径)' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:仍命中
    - `grep -nF 'DesignCandidateMenu' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:scoutPrompt design 分支仍注 DesignCandidateMenu(`menu` 取数命中 design 三元)
    - `grep -nF '被审材料(必读): ${targets.spec}' "harness/.claude/workflows/review-scout.workflow.js"` → 期望:scoutPrompt design else 仍命中
  - (c) **行为级(prompt 文本快照,§6.1 A 簇行)**:改前先存 design 路两函数对一组固定入参(`reviewType='design'`, 固定 targets/sessionIntent/d)的输出快照 fixture;改后对同入参重跑两函数,**逐字 diff = 空**。若实现时未预存快照,则以 (a)+(b) 静态核 + 人工逐行核 else 分支为准(spec §8.3 CMD2 (c) 注)。
- [ ] **CMD3 design-reviewer.md / design-review SKILL 零 diff(F 守住)**:`git diff "harness/.claude/agents/design-reviewer.md" "harness/.claude/skills/design-review/SKILL.md"` → 期望:**空**
- [ ] **CMD4 FloorTable.code 三维有序集 + 候选双写逐字一致(B 簇,credentials-rules §8 #6)**:
  - `grep -noE "code:[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:`code: ['方向盘对齐', '简洁性', 'spec忠实性']`
  - `grep -nF "方向盘对齐 + 简洁性 + spec忠实性" harness/docs/governance/review-rules.md` → 期望:review-rules code 地板行命中同序三维(双写)
  - `grep -nF "code = 方向盘对齐 + 简洁性(留口" harness/docs/governance/review-rules.md` → 期望:**零命中**(旧 2 维占位已除;命中 = 两份打架,回退)
  - `grep -noE "CodeCandidateMenu = \[[^]]*\]" "harness/.claude/workflows/review-scout.workflow.js"` → 期望:`['类型契约合规', '架构合规', '模块文档一致性']`
  - `grep -nF "类型契约合规 + 架构合规 + 模块文档一致性" harness/docs/governance/review-rules.md` → 期望:候选注命中同序(双写)
- [ ] **CMD5 新 skill 入口登记(正则命中无引号实际文字,防假绿)**:
  - `grep -rnE "review-scout|reviewType=.?code" CLAUDE.md harness/CLAUDE.md harness/QUICKREF.md "harness/.claude/skills/code-review/SKILL.md"` → 期望:CLAUDE×2「开发」行注 + harness Skill 地图新行 + QUICKREF Skill 表新行 + 新 SKILL 分支 各命中
  - `grep -nF "code-review" harness/QUICKREF.md` → 期望:**2 处**(L34 映射行原有 + Skill 表新行);只 1 处 = 漏建 Skill 表行
- [ ] **CMD6 双写对核(CLAUDE×2「开发」行语义一致)**:`diff <(grep -E '开发.*Superpowers|code-review|review-scout' CLAUDE.md) <(grep -E '开发.*Superpowers|code-review|review-scout' harness/CLAUDE.md)` → 期望:「开发」行加注语义一致(harness 多 Skill 地图新行属预期差异)
- [ ] **CMD7 分发(setup.sh code-review skill 复制段)**:`grep -nF "code-review" harness/setup.sh` → 期望:mkdir + cp SKILL.md 各命中(2 处)
- [ ] **CMD8 synthesis 主表/事前5 ADD code 地板数注(C 簇)**:
  - `grep -nE "地板按类|design 2 / code 3|design 2/code 3" harness/docs/governance/synthesis-rules.md` → 期望:L16 + L101 各命中
  - `git diff harness/docs/governance/synthesis-rules.md` → 期望:只在主表行/事前5清单行各 +注;维序段无 diff;L3/何时读/事后规则适用范围无 diff
- [ ] **新建/改动件结构复跑**(任务 1-5 验证):workflow.js 禁用项零命中(`grep -nE "Date\.now|Math\.random|new Date\(\)|readFileSync" "harness/.claude/workflows/review-scout.workflow.js"` → 无输出);新 `code-review/SKILL.md` 不抄 design-reviewer(`grep -nE "design-reviewer|DesignCandidateMenu" "harness/.claude/skills/code-review/SKILL.md"` → 无输出);review-scout.md 不承载 focus 库(`grep -nF "FLOOR_FOCUS_CODE" "harness/.claude/agents/review-scout.md"` → 无输出或仅"focus 库不在此"说明)

**凭证预告(写进 handoff / 交收口):**
- [ ] 本改动命中 credentials.conf 的文件:`.claude/skills/code-review/SKILL.md`(`.claude/skills/*/*.md` glob,新建自动入)/ `docs/governance/review-rules.md` + `synthesis-rules.md`(governance glob)/ `.claude/workflows/review-scout.workflow.js`(`.claude/workflows/*` glob,2026-06-13 已立)/ `.claude/agents/review-scout.md`(`.claude/agents/*.md` glob 自动)/ `harness/setup.sh`(setup glob)/ 根 `CLAUDE.md`(写 covers `<root>/CLAUDE.md`)+ `harness/CLAUDE.md`(写 `CLAUDE.md`)。**QUICKREF 不命中凭证**(无 glob)→ 不进 covers,但仍改(触点)。
- [ ] **credentials.conf / credentials-rules 不改**:所需 glob(skills / workflows / agents / governance / setup / CLAUDE)均已存在(spec §8.1 行)→ 无新 glob 需求,无双写改动。
- [ ] **finishing 须产 audit 凭证**(对抗审查;review-rules 治理行 **bootstrap-4 维** + **触点完整性维**——本改动跨多文件 + 双写对 `FloorTable.code`↔review-rules + 分发链,命中"跨文件计数/枚举 + 分发链",触点完整性维优先选用)。audit covers 列上述全部命中文件(QUICKREF 不命中凭证 → 不进 covers;design-reviewer.md / design-review SKILL / Superpowers 包本功能不改 → 不进 covers)。
- [ ] **守 Y 自核**:audit 须确认 `design-reviewer.md` / `design-review/SKILL.md` / Superpowers 包 收口 git diff = 空;`reviewType='design'` 路 prompt 文本等价(CMD2 三层核)。
- [ ] 无 commit(纯验证任务);验证结果记入 handoff 收口段。

---

## Self-Review(spec 覆盖 / 占位符扫 / 类型一致)

### spec 覆盖核(§8.1 改动集 ↔ 任务)

| spec §8.1 改动 | 计划任务 | 覆盖 |
|---|---|---|
| ① workflow.js code 扩展 — FloorTable.code 3 维 + CodeCandidateMenu + FLOOR_FOCUS_CODE | 任务 1 | ✅ |
| ① workflow.js code 扩展 — scoutPrompt reviewType 分支(候选菜单/diffRef/governance 守卫) | 任务 2 | ✅ |
| ① workflow.js code 扩展 — challengerPrompt reviewType 形参+三处串分支+focus 取数+diffRef 错误处理 | 任务 3 | ✅ |
| ② 新建 .claude/skills/code-review/SKILL.md(镜像 design-review 运行时分支) | 任务 5 | ✅ |
| ③ review-scout.md code 推维分支(reviewType 切语境 + B-8 code) | 任务 4 | ✅ |
| ④ review-rules code 注(L11 scout 主推 + L19 2→3 维 + 候选/either-or + code 地板维表权威) | 任务 6 | ✅ |
| ⑤ synthesis 主表/事前5 ADD "地板按类 design2/code3" | 任务 7 | ✅ |
| ⑥ CLAUDE×2「开发」行 + harness Skill 地图 + QUICKREF Skill 表 + setup.sh 复制段 | 任务 8(CLAUDE×2/地图/QUICKREF)+ 任务 9(setup.sh) | ✅ |
| ⑦ design 路零变 fixture/验证 | 任务 2/3(design else 逐字保留)+ 任务 10 CMD2 三层核 | ✅ |
| ⑧ 收口验证(§8.3 全组 + 全仓 diff + design 路零变三层核) | 任务 10 | ✅ |

| spec 接口(§3) | 计划任务 | 覆盖 |
|---|---|---|
| §3.1 workflow 入参(reviewType='code' + diffRef + governance 守卫) | 任务 2(scoutPrompt)+ 任务 3(错误处理)+ 任务 5(SKILL 传参) | ✅ |
| §3.2 SCOUT_SCHEMA 复用(值变,schema 零改) | 任务 1(FloorTable.code 照抄源)+ 任务 4(scout 照抄) | ✅ |
| §3.3 challengerPrompt reviewType 分支 + focus 来源(FLOOR_FOCUS_CODE) | 任务 3(分支+focus 取数)+ 任务 1(FLOOR_FOCUS_CODE) | ✅ |
| §3.4 FINDING_SCHEMA 复用(零改) | 复用,无改动任务(任务 10 CMD2 核编排骨架零 diff) | ✅ |
| §3.5 出参复用 + scout 综合维序住 SKILL | 任务 5(维序说明住 code-review SKILL) | ✅ |

| spec 核心场景(§1.2) | 计划任务 | 覆盖 |
|---|---|---|
| P0 场景1(ultracode 走 code scout) | 任务 1-5 全链 | ✅ |
| P0 场景2(方向盘自适应 A-3 复用) | 任务 4(scout A-3 两路通用)+ 任务 1(FLOOR_FOCUS_CODE 方向盘 template 回落) | ✅ |
| P0 场景3(非 ultracode 走 Superpowers 回落) | 任务 5(SKILL 回落分支) | ✅ |
| P0 场景4(either-or + spec忠实性入地板) | 任务 1(FloorTable.code 3 维)+ 任务 5(either-or 不叠加)+ 任务 6(权威注) | ✅ |
| P1(三层选维:地板/候选/发明维) | 任务 1(FloorTable.code + CodeCandidateMenu)+ 任务 4(B-8 发明维引导) | ✅ |

| spec 测试场景(§6.1) | 计划验证步 | 覆盖 |
|---|---|---|
| reviewType='code' 跑通 + 禁用项 | 任务 1/2/3 验证 + 任务 10 复跑 | ✅ |
| FloorTable.code 3 维 / CodeCandidateMenu / 候选 skipped | 任务 1 验证 + 任务 4(scout 照抄/skipped) | ✅ |
| D-C2 spec忠实性入地板 / 代码质量基线覆盖 | 任务 1(FLOOR_FOCUS_CODE)+ 任务 4(code 语境注)+ 任务 6 | ✅ |
| 回落分支文档核 | 任务 5 验证 + 任务 10 CMD5 | ✅ |
| **A 簇 design 路 prompt 文本等价(行为零变)** | 任务 2/3(design else 逐字)+ 任务 10 CMD2 三层核 | ✅ |
| F 守住 design 常量/编排零 diff + design-reviewer.md 零关系 | 任务 10 CMD2(a)/CMD3 | ✅ |
| E 簇 三地板维 focus 互斥边界 | 任务 1 验证(⚠️ 互斥边界 3 处) | ✅ |
| C 簇 synthesis 地板数注 | 任务 7 验证 + 任务 10 CMD8 | ✅ |
| §8 触点同步(FloorTable.code↔review-rules 双写 / 新 skill 入口登记) | 任务 10 CMD4/CMD5 | ✅ |

### 占位符扫

- workflow.js code 常量(`FloorTable.code` / `CodeCandidateMenu` / `FLOOR_FOCUS_CODE` 六键 focus 全文)**实际内容已写出**(任务 1,照抄 spec §4.1(3)),engineer 照抄;scoutPrompt/challengerPrompt reviewType 分支给精确的 before→after 改法 + 实际代码块(任务 2/3),非"加适当分支"。
- 新 `code-review/SKILL.md` frontmatter + 执行分支段 **给实际可照抄 markdown 块**(任务 5)。
- 各治理文件 ADD/改文本:review-rules 三处(任务 6)、synthesis 两处(任务 7)、CLAUDE×2/QUICKREF/Skill 地图注(任务 8)、setup.sh 两行(任务 9)**均给实际可照抄文本 + before→after**。
- **无 `[待填]`/`[TODO]`/`<占位>`/"类似任务 N"/"加适当错误处理" 类未定义占位符**。FLOOR_FOCUS_CODE 内 `targets.diffRef`/`targets.spec` 是入参占位(契约形态,非计划缺口);SKILL 块内 `<git 改动范围>`/`<被实现的设计 spec 路径>` 是入参指针占位(契约形态,同 design SKILL 写法)。

### 类型一致核

- schema/字段名全文一致:`reviewType`('design'|'code'|governance 留口)/ `inherited_floor` / `added_dimensions` / `skipped_candidates` / `challenger_focus` / `why_this_time` / `rubric_mode` / `diffRef` — 任务 1-5 与 spec §3/§4 逐字一致;`reviewType=.?code` 正则跨文件命中(CMD5)。
- `FloorTable.code = ['方向盘对齐','简洁性','spec忠实性']`(任务 1)↔ inherited_floor 照抄(任务 4)↔ review-rules L19 双写(任务 6)↔ spec §4.1(1) 一致(任务 10 CMD4 有序集核)。
- `CodeCandidateMenu = ['类型契约合规','架构合规','模块文档一致性']`(任务 1)↔ review-rules 候选注(任务 6)↔ spec §4.1(2) 一致。
- `FLOOR_FOCUS_CODE` 六键 = `FloorTable.code ∪ CodeCandidateMenu`(方向盘对齐/简洁性/spec忠实性/类型契约合规/架构合规/模块文档一致性),challengerPrompt 按 `d.name` 映射无断键(任务 3 focus 取数核)。
- 维名「简洁性」全文一名(workflow.js `FloorTable.code` + `FLOOR_FOCUS_CODE` 键 + review-rules L19/L11 + 节标题「简洁性审查」同一维),不引入新 token「简洁性审查」(spec §1.3 alias 处理)。
- 维名「方向盘对齐」两路一致(design `FLOOR_FOCUS` + code `FLOOR_FOCUS_CODE` 同键名),focus 文字按 reviewType 分(D 簇),不加后缀污染 SCOUT_SCHEMA.inherited_floor / 双写(任务 1/3)。

### 发现的 gap → 已补

- **模块文档处置**:planning-rules 要求"新建模块任务含 README",但 harness `.claude/skills/` 各目录现状无 per-目录 README → 已在「模块文档处置」段明确**不建 README**,由 SKILL.md 自身承担文档职责(任务 5)。**非偏离 spec**(spec §2 注明 harness 自仓库无 ARCHITECTURE.md 产品分层,模块=工件)。
- **入参校验扩展(diffRef+spec 双缺)落在默认导出 `reviewScout`**:spec §3.1 错误处理要求 code 路 diffRef+spec 双缺报错,现默认导出仅校验 `!targets.spec`(对 design 路够)。任务 3 把校验改为按 reviewType 分支(design 仍 `!targets.spec`、code 新增双缺判据),design 路语义零变 — 这是 spec §3.1 明列的 code 接线,**非偏离**。

### 需回设计阶段的偏离点

**无。** 计划全程对齐 spec §2-§9 + decisions D-C1~D-C4,逐文件基于真实文本(workflow.js L26-241 / SKILL.md / review-rules.md L11-79 / synthesis-rules.md L16/L101 / setup.sh L40-83 / QUICKREF.md L34/L44 / CLAUDE×2「开发」行 / review-scout.md),未发现需偏离设计文档之处。

> **spec 不可执行点回报(给上抛参考,非偏离)**:无阻塞点。一个**实现细节提示**(已在任务内处理,不需回设计):spec §3.3 表把 challengerPrompt 角色行/材料路径/location 列为"三处串分支",但现 challengerPrompt 还有 focus 取数行(L158)也写死 design 路 `(d.name in FLOOR_FOCUS)` — 该行 spec §4.1(3) 注已要求按 reviewType 选 `FLOOR_FOCUS_CODE`,故任务 3 实为**四处改**(三处串 + 一处 focus 取数);spec 在 §4.1(3) 注与 §3.3 focus 来源表已分别覆盖该行,合起来无遗漏,计划照两处合并实现,不构成 spec 缺口。

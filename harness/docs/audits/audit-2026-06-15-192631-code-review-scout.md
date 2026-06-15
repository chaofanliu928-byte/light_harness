---
audit: true
covers:
  - <root>/CLAUDE.md
  - CLAUDE.md
  - .claude/skills/code-review/SKILL.md
  - .claude/agents/review-scout.md
  - .claude/workflows/review-scout.workflow.js
  - docs/governance/review-rules.md
  - docs/governance/synthesis-rules.md
  - setup.sh
---

# audit:code-review-scout(指令1 — review-scout 扩展代码审查 reviewType='code' 治理面收口凭证)

> 本批 = 指令1:给 review-scout(ultracode 专属动态审查侦察:scout 现推维 → workflow `parallel` 一维一挑战者扇出 → 调度者综合)扩展**代码审查**(reviewType='code'),fork-N 同形于设计审。ADD 一条 code scout 路**并排**于 Superpowers `requesting-code-review` 回落路(**either-or**,不替换/不退役老路);design 路(reviewType='design')**逐字零变**。covers = 本批命中 credentials.conf 的 8 文件(QUICKREF / spec / decisions / plan 不命中凭证 → 不进 covers)。

## 1. 元信息

- 批次:code-review-scout(指令1);分支 `code-review-scout`
- 审查对象:commit `2501421`(T1-3 workflow.js)+ `392189f`/`20bee4e`(spec/decisions/plan)+ `e7a2263`..`05318eb`(T4-9)+ B-8 措辞修订 commit(收口中产出)
- 凭证类型:对抗审查 audit(命中 credentials.conf:`docs/governance/*.md` / `CLAUDE.md`×2 / `.claude/skills/*/*.md` / `.claude/agents/*.md` / `.claude/workflows/*` / `setup.sh` glob)
- 模态:对抗式;治理审查 N=5(bootstrap-4 + 触点完整性)+ 方向评估 N=4(RUBRIC / 架构 / 文档 / Slop);单 turn 并行 fork(workflow `code-review-scout-finishing`,9 独立中性挑战者);synthesis-rules 事前中性化 + 事后按证据综合
- **方向评估站位**:本批是 review-scout 的**新能力扩展**(AI 提议的设计,机制/触发宿主由用户拍板,但"扩什么维/怎么实现"含 AI 设计判断),故跑**完整方向评估 4 挑战者**(区别于 reframe 批——那批方向纯用户指令 framing 故免方向评估)。review-scout 大方向上轮已评估通过(`audit-2026-06-15-112342-review-scout.md`),本批方向评估核 code 扩展是否对齐 RUBRIC/架构,不重开 review-scout 本身。
- 时间:2026-06-15 19:26

## 2. 维度选取

- **治理审查** = B(bootstrap-4,治理行强制基线,未删减):核心原则合规 / 目的达成度 / 副作用 / scope 漂移 + A(条件必选):**触点完整性维**(本批跨多入口登记 + 两对 code 双写 = 跨文件枚举/双写,必选)
- **方向评估** = 4 挑战者:RUBRIC 合规 / 架构一致 / 文档健康 / Slop 检测
- 禁用:安全扫描 / 流程审计(治理批暂不纳入,finishing-rules §治理批收口工序适用)

## 3. 挑战者执行记录

9 独立 fork(workflow 并行;git diff main...HEAD + node 渲染 design 路双版本对比实核,公设 1 不采信实现者自报)。

### 治理审查(5/5 pass)

- **核心原则合规**:verdict=**pass**(4🟢)。① 文档第一公民——spec/decisions(`392189f`)先于 plan(`20bee4e`)先于全部代码任务,文档与代码逐字一致(FloorTable.code/CodeCandidateMenu ↔ review-rules 权威注 ↔ decisions 综合结果段 grep 双写一致);② 最小变更 + 守 Y——改动严限 §8.1 的 12 文件,design 路逐字零变;③ 角色分离 + 二公设——reviewType 显式形参分支真隔离 design/code,独立 scout/challenger fork 做审分离,spec忠实性入地板后由独立 challenger 审(非实现者自审);④ 回退——D-C2 either-or 真空 + A 簇"零改函数体"过度乐观两处均回设计阶段根治,非下游打补丁。
- **目的达成度**:verdict=**pass**(2🟢)。新 code-review SKILL 入口逐字镜像已运行的 design-review 运行时分支;ultracode 路 SKILL 传 reviewType=code+diffRef → workflow 入参校验 → scoutPrompt code 分支 → challengerPrompt code 分支端到端贯通,diffRef/spec 字段两处全消费(无悬空);scout 现推维 code 地板 3 维 + 候选 3 维 + B-8 发明维链齐全,三处(review-rules 权威 ↔ workflow.js ↔ agent)双写逐字一致;非 ultracode 回落 Superpowers 保留(目标 skill 真实存在)。非空壳。
- **副作用(守Y退化核,最高优先)**:verdict=**pass**(2🟢)。node 真值表实证:reviewType='design' 路 scoutPrompt/challengerPrompt(地板+候选+动态维)全部 main↔HEAD **字节相同**,design 校验门对全 targetCases 与 main `!targets||!targets.spec` **逐例相等**,返回值 `{plan:null,findings:[]}` 不变;FloorTable.design / DesignCandidateMenu / FLOOR_FOCUS / SCOUT_SCHEMA / FINDING_SCHEMA / reviewScout 编排全 JSON 相同;design-reviewer.md / design-review SKILL / design-rules.md / synthesis L153 维序段全零改。code 路纯 ADD 与 design 路干净隔离。两 🟢 = design 路失败 log 串改写(仅错误态诊断,happy-path/返回行为零变)+ B-8 措辞 drift(下方修订)。
- **scope 漂移**:verdict=**pass**(0 findings)。12 文件全落 spec §1.3 做清单内,无计划外"顺手"改动/多余抽象/未被要求留口;§1.3 不做清单(不改 Superpowers 包 / 不与 scout 叠加跑 / 代码质量不单设地板维 / design 路不污染 / 不读 design-reviewer.md / 不接 governance / 不预设硬门 / 不为 code 造多余留口)全守;FLOOR_FOCUS_CODE 6 键全被 code 路真用。
- **触点完整性**:verdict=**pass**(1🟢)。两对 code 双写(FloorTable.code↔review-rules 地板注、CodeCandidateMenu↔review-rules 候选注)grep 实证逐字同序;新 skill 入口五处全登记(CLAUDE×2 开发行 byte-identical + harness Skill 地图新行 + QUICKREF Skill 表新行[区别于 L34 映射行] + setup.sh mkdir+cp);synthesis 主表 L16 + 事前清单 L101 地板数注同步;credentials §2 既有 `.claude/skills/*/*.md` glob 已覆盖新 SKILL,无新 glob 需求。1🟢 = §8 双写清单未列 CodeCandidateMenu 这对(下方观察)。

### 方向评估(4/4 pass)

- **RUBRIC 合规**:verdict=**pass**(2🟢)。对照 CLAUDE.md 核心原则 + 二公设(自仓库 RUBRIC.md 空模板回落),全维对齐:文档第一公民 ✓、最小变更/简洁性 ✓(6 个 FLOOR_FOCUS_CODE 键全可达=地板3+候选3,无死留口)、角色分离/做审分离 ✓(either-or 正确阻止与 Superpowers 叠加跑)、一致性 ✓(三处双写逐字、focus 引用的 review-rules 节名真实存在)。2🟢 = governance 留口未接线(main 已存在,本批反而新增空菜单守卫=改善)+ 设计文档体量(第一公民,spec §0 自标重量级全节填写,非惩罚)。
- **架构一致**:verdict=**pass**(2🟢)。code 路与 design 路严格同构(同扁平 fork-N、同两阶段编排[侦察→对抗]、同 SCOUT_SCHEMA/FINDING_SCHEMA、同 either-or 框);做审分离守住;reviewType 分支隔离无循环;依赖方向=调用方向(SKILL→workflow→scout/挑战者,无上向回调);工件落对层。2🟢 = spec §5.1 "自仓库无 ARCHITECTURE.md" 措辞瑕疵(实为模板占位,运行时已兜底)+ allowed-tools 剔除 Write 合理差异。
- **文档健康**:verdict=**pass**(3🟢)。spec↔实现一致(FloorTable.code/CodeCandidateMenu/FLOOR_FOCUS_CODE/scoutPrompt 3-way/challengerPrompt reviewType 形参/diffRef+spec 双缺错误处理逐字对得上);"design else 逐字保留=行为零变"git diff+grep 实证(4 处 design 串全在);§9.3 已诚实撤回"零改函数体"过度乐观、无残留;decisions 拍板锚清晰;无真 TODO/TBD;术语一致(scout 主推/Superpowers 回落,无"活备份"混用)。3🟢 = spec 伪码 vs 等价实现形态差 / spec 同注 2-way→3-way 分层冗余 / README L150 已声明豁免轻失真。
- **Slop 检测**:verdict=**pass**(2🟢)。6 个 FLOOR_FOCUS_CODE 键全被 code 路真消费,无死键/未消费留口;实现实际把 spec 里冗余的方向盘对齐特判简化掉(slop 减项);design else 逐字零变;无 TODO/stub。2🟢 = isCode 单次别名风格 + governance 守卫属有据防御(spec §3.1/§7.2 论证,~2 行成本)。每行 code diff 可追溯到指令1 reviewType='code' 接线真需求。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:**9/9 pass,零🔴零🟡,全🟢观察**。守 Y 三处零改(design-reviewer.md / synthesis L153 维序 / design-rules.md)+ design 路 reviewType='design' 行为**逐字零变**(node 双版本渲染 byte-identical + design gate 真值表逐例等价)经治理审查"副作用"维 + 方向评估"RUBRIC/架构/文档/Slop"四维 + 调度者 §8.3 自核(逐 hunk 核每条删除行的 design 值在 design 臂保留)**多方独立印证**。指令1 接通-usable(D-C4=A)端到端贯通,fork-N 同形于设计审。
- **真修订(1,本批引入)**:B-8 诚实标注 `review-scout.md` L109 "退化成只加固定 4 维同集" 与同段 L91 已泛化措辞("固定几维/固定维集")不一致(prose drift)→ 收口中**已修订**泛化为"固定维集(按类:design/code 地板/候选)的同集",使 design/code 两路 caveat 一致。属本批自身不完全泛化的内联修订,非新增缺陷。
- **不阻塞观察(🟢)→ ROADMAP backlog**:
  1. `credentials-rules` §8 双写清单未列 CodeCandidateMenu↔review-rules 候选注 —— pre-existing 模式(既有 DesignCandidateMenu↔review-rules 设计注同样未登记),spec/plan 已决策 credentials 不改(所需 glob 均存在),review-rules code-scout 注内联"改名先改本注"自约束兜;非本批漏改。
  2. spec 文档勘误(§4.1(3) focus 取数伪码 vs 等价实现形态差 / §3.1 同注 2-way→3-way 分层冗余 / §5.1 ARCHITECTURE.md "无" 实为模板占位):行为等价/不影响实现,记 spec 勘误观察。
  3. README L150 代码审查行未提 ultracode scout 路 —— spec §8.2 已声明有据豁免(README 不分发下游 + 与设计审查行对称缺席 + 分发模板 CLAUDE×2 已同步);列 cleanup。
  4. 退化失败模式(scout 推维退化成只加固定维集)meta-L4 实战观察(沿用 review-scout 既有观察项)。
- **接受不处置**:design 路失败 log 串改写(仅错误态诊断,design happy-path/返回行为零变,且 log 现正确覆盖 design+code 双路,反 design-only 措辞会失真)。
- **透明披露**:code-review SKILL allowed-tools 剔除 Write(design-review 有)= 按需最小授权(code 审无 result 落盘约定),非断链;未列 Workflow = 与 design-review SKILL 同形既有 pattern(Workflow 是调度者运行时能力,不经 SKILL allowed-tools 授权)。
- 无新决策拐点(D-C1~D-C4 用户已拍板入 decisions;decision-trail 将 append)。

## 5. 判定

**verdict: pass**(9/9 挑战者 pass;1🟢 观察[B-8 措辞 drift]收口中 proactively 修订落地,无 🟡/🔴 阻塞)。本 audit covers 命中凭证 8 文件(`<root>/CLAUDE.md` / `CLAUDE.md` / 新 SKILL / review-scout.md / workflow.js / review-rules / synthesis-rules / setup.sh)。守 Y 全程保持(design-reviewer.md / synthesis L153 维序 / design-rules.md 零改;design 路行为逐字零变 node 实证)。双写逐字同序(FloorTable.code↔review-rules)+ CLAUDE×2 开发行字节一致 + 新 skill 五处入口登记。4 ROADMAP 观察项(见 §4,全非阻断)。指令1(审代码接 scout,接通-usable)忠实落实用户拍板 D-C1~D-C4,可收口。

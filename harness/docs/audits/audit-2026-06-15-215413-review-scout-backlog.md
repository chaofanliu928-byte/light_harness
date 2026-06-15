---
audit: true
covers:
  - docs/governance/credentials-rules.md
  - docs/governance/review-rules.md
  - .claude/workflows/review-scout.workflow.js
---

# audit:review-scout backlog 清理(候选菜单双写收紧 + spec 勘误 + 架构 focus 同步 — 治理面收口凭证)

> 本批 = review-scout 三批落地后的 backlog 清理(纯收尾,无新方向):**子项1** credentials §8 加第 7 条(候选菜单双写对 DesignCandidateMenu/CodeCandidateMenu ↔ review-rules 候选注)+ workflow.js DesignCandidateMenu 派生注 + review-rules design 候选权威注;**子项2** code-review-scout spec 3 处勘误(focus 伪码对齐实现 / menu 2-way 冗余 / ARCHITECTURE.md 措辞);**架构 focus 同步** workflow.js `FLOOR_FOCUS_CODE['架构合规']` 随 spec 勘误改"模板占位也跳过"(修运行时噪音 + spec↔workflow.js 复字节一致);**子项3** 术语统一「活备份」→「回落」= 实质已完成(活治理文档已无,reframe 批统一),本批零改动。covers = 命中 credentials.conf 的 3 文件(spec 不命中凭证 → 不进 covers)。

## 1. 元信息

- 批次:review-scout backlog 清理;分支 `review-scout-backlog`
- 审查对象:commit `d260cbb`(子项1)+ `08cf05f`(子项2 spec)+ `ac775ef`(架构 focus 同步)+ `737681c`(收口 🟡 修订)
- 凭证类型:对抗审查 audit(命中 credentials.conf:`docs/governance/*.md`×2 / `.claude/workflows/*`)
- 模态:对抗式;治理审查 N=5(bootstrap-4 + 触点完整性);单 turn 并行 fork(workflow `rs-backlog-audit`,5 独立中性挑战者);synthesis-rules 事前中性化 + 事后按证据综合
- **方向评估站位**:纯收尾批(review-scout 大方向已两轮评估通过:`audit-...-112342` + `audit-...-192631`),无新方向 → **不跑方向评估**(对齐 reframe 批先例),仅治理审查核"忠实收尾 + 合规达标"。
- 时间:2026-06-15 21:54

## 2. 维度选取

- B(bootstrap-4,治理行强制基线):核心原则合规 / 目的达成度 / 副作用 / scope 漂移
- A(条件必选):**触点完整性维**(本批核心 = 双写对收紧 + spec↔workflow.js 字节一致,必选)
- 禁用:安全扫描 / 流程审计(治理批暂不纳入,finishing-rules §治理批收口工序适用);方向评估(纯收尾,无新方向)

## 3. 挑战者执行记录(5 独立 fork;git diff main...HEAD + node 渲染实核,公设1 不采信自报)

- **核心原则合规**:verdict=**pass**(2🟢)。文档第一公民(子项1 先立 §8 #7 规则再派生 workflow.js 注;子项2 把 doc 改回与实现/事实一致)、最小变更(workflow.js 仅 +1 注释 +1 focus 串;design 候选权威注是补既存不对称所必需)、角色分离(implementer 做、独立挑战者据 git/grep/node 实证核)。
- **目的达成度**:verdict=**concern→已修订**(1🟡)。三子项实质达成;1🟡 = review-rules L33 code 双写注的 §8 指针仍指第 6 条(只管 FloorTable),未跟新增第 7 条对齐,与 design 候选注 L24(→第 7 条)不对称。**修订**:commit `737681c` 把 L33 拆为 `FloorTable.code`→§8 第 6 条 + `CodeCandidateMenu`→§8 第 7 条,两候选注 §8 指针对称。
- **副作用(守Y退化核)**:verdict=**pass**(5🟢)。node 重建实证:从 HEAD 仅删 L35 注释 + 把 L85 focus 还原为 main 版 → `reconstructed === main: true`,证明除这 2 处外 workflow.js 全文(含整条 design 路)逐字节不变;reviewType='design' 跑完整两阶段(scoutPrompt + 全 challengerPrompt)main↔HEAD `byte-identical: true`。FLOOR_FOCUS_CODE['架构合规'] 仅 isCode 时读(L201 `isCode && d.name in FLOOR_FOCUS_CODE` 守卫),design 路 isCode=false 永不读;DesignCandidateMenu 值 `['完整性','过度工程化']` 未变;FloorTable/FLOOR_FOCUS design 键/SCOUT_SCHEMA/FINDING_SCHEMA/reviewScout 编排零改;禁用项无;design-path 文件(design-reviewer.md/design-review SKILL/design-rules.md/synthesis 维序/review-scout.md)全 untouched。
- **scope 漂移**:verdict=**pass**(4🟢)。三子项均可追溯自身必要性:子项1c(design 候选权威注)补 §8 #7 的 design 半上游缺口(main 上 DesignCandidateMenu 双写注不存在,CodeCandidateMenu 已有);架构 focus 同步修 main 上"若缺失(自仓库无)"对模板占位 ARCHITECTURE.md 不触发跳过的运行时噪音(实证文件存在且含占位标记);子项2 spec 自洽性勘误(伪码非可执行注释、逻辑等价;删与权威 3-way guard 自相矛盾的冗余 2-way);子项3 零改守 R12。无计划外文件(git diff --stat 仅 4 文件)。
- **触点完整性**:verdict=**pass**(🟢)。① 候选菜单双写:workflow.js DesignCandidateMenu=[完整性,过度工程化] / CodeCandidateMenu=[类型契约合规,架构合规,模块文档一致性] ↔ review-rules L24/L31 注 ↔ credentials §8 #7 三处菜单项逐字一致、上游/派生方向一致;② 架构 focus:spec §4.1(3) ↔ workflow.js L85 经 grep -F 提取字节相同;③ spec 勘误未引入新不一致(伪码三元 = workflow.js L200-203 实际逐字一致;menu 概述指向真实 3-way guard)。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:4/5 pass + 1 concern(目的达成度,1🟡 §8 指针陈旧引用)。守 Y 经"副作用"维 node 双版本渲染 byte-identical + 重建等式 reconstructed===main 实证未破;design-path 文件全 untouched。双写三处一致(触点完整性维独立印证)。
- **真修订(1🟡,已落地)**:review-rules L33 code 双写注 §8 指针(第 6 条→拆为第 6 条[FloorTable]+第 7 条[CodeCandidateMenu]),commit `737681c`,与 L24 design 候选注对称。修订本身仍命中凭证(review-rules governance glob,已在 covers)。
- **接受不处置**:子项3 术语统一零改动 = 活治理文档(review-rules/synthesis/CLAUDE)实测无"活备份"(reframe 批已统一),残留仅在锁定 spec(术语桥兜)+ 记录文件(R12 不追溯),克制不 churn 是 R12/最小变更的正确结果。
- 无新决策拐点(纯收尾;decision-trail 既有 review-scout 拐点不新增)。

## 5. 判定

**verdict: pass-after-revision**(4/5 pass + 1🟡[§8 指针陈旧引用]收口中 commit `737681c` 修订落地;无 🔴)。本 audit covers 命中凭证 3 文件(credentials-rules / review-rules / workflow.js)。守 Y 全程保持(design 路 reviewType='design' 行为 node 实证逐字零变;design-path 文件零改)。候选菜单双写对收紧(§8 #7 + 两侧权威注/派生注对称 + 三处菜单项逐字一致)+ spec 3 勘误(doc↔实现/事实一致)+ 架构 focus 同步(spec↔workflow.js 复字节一致 + 修模板占位运行时噪音)。子项3 术语统一实质已完成(零 churn 守 R12)。review-scout backlog 清理可收口。

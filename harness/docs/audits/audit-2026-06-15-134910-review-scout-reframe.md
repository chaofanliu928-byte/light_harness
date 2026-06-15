---
audit: true
covers:
  - <root>/CLAUDE.md
  - CLAUDE.md
  - .claude/skills/design-review/SKILL.md
  - docs/governance/review-rules.md
  - docs/governance/credentials-rules.md
  - .claude/workflows/review-scout.workflow.js
---

# audit:review-scout reframe(指令3 表述调整 + 指令2 文档上游双写 — 治理面收口凭证)

> 本批 = 用户拍板的两件:**指令3(表述调整,轻版)**——把 review-scout 作主推先讲、固定 4 维 design-review 显式标为「仅 ultracode/Workflow 不在场时执行的回落路」(不退役老路、不重建非 ultracode 的 X、架构/运行逻辑零改);**指令2(文档上游双写)**——把 FloorTable(workflow.js 机读)↔ review-rules 地板维表注(文档权威上游)登记为 credentials-rules §8 第 6 条双写对。covers = 本批命中 credentials.conf 的 6 文件(spec/decision/QUICKREF 不命中凭证 → 不进 covers)。

## 1. 元信息

- 批次:review-scout reframe(指令3 主次表述调整 + 指令2 FloorTable 文档上游双写);分支 `review-scout-reframe`
- 审查对象:commit `61576cf`(reframe 9 文件)+ `2d97a11`(术语桥 revision-fix)
- 凭证类型:对抗审查 audit(治理面 framing + 双写规则改动,命中 credentials.conf:skills/governance/CLAUDE×2/workflows glob)
- 模态:对抗式;N=5(bootstrap-4 + 触点完整性);单 turn 并行 fork(workflow `rs-reframe-audit`);synthesis-rules 事前中性化 + 事后按证据综合
- **方向评估站位**:本批方向(scout 主推 / 老 4 维回落)= **用户明确指令**(非 AI 提议);review-scout 大方向上轮已评估通过(`audit-2026-06-15-112342-review-scout.md` + 方向评估 4/4 不推翻)。本批是用户指令内的 framing 微调,方向由用户拍板,故不另跑 4 挑战者方向评估;审查站位 = 核「忠实落实用户指令 + 合规达标」(治理审查),非「方向该不该推翻」。
- 时间:2026-06-15 13:49

## 2. 维度选取

- B(bootstrap 4 维,治理行强制基线,未删减):核心原则合规 / 目的达成度 / 副作用 / scope 漂移
- A(条件必选):**触点完整性维**(本批跨多入口 framing 同步 + FloorTable 双写对 = 跨文件枚举/双写,必选)
- 禁用:安全扫描 / 流程审计(治理批暂不纳入,finishing-rules §治理批收口工序适用)

## 3. 挑战者执行记录

5 挑战者独立 fork(workflow 并行;git diff main...HEAD 实核,公设 1 不采信实现者自报)。

**核心原则合规**:verdict=**pass**。① 文档第一公民——意图文档(spec D13/§1.2 + decision 后续影响)与接线文档(CLAUDE×2/QUICKREF/review-rules/SKILL)同处单 commit,无码先于文;② 最小变更——只触措辞/主次/注 + 一条双写,SKILL 分支执行体 + 守 Y 三文件经 git diff 确认零改;③ 角色分离 + 二公设未碰;④ 诚实——无任何措辞暗示 scout 跨环境/非 ultracode 可跑,回落路标"不标降级执行",§7.3/§1.6 痛点未解诚实边界行未触碰。

**目的达成度**:verdict=**pass**。指令3 五入口(根/harness CLAUDE 角色表 / harness skill 地图 / QUICKREF / SKILL / review-rules)口径一致:scout 主推先讲、老 4 维标"仅 ultracode 不在场时执行的回落路",且不退役(守 Y 三文件零改、4 维串逐字保留)、不重建 X(无 added line 暗示 scout 非 ultracode 可跑);指令2 双写对三处闭环(credentials-rules §8 第 6 条 + review-rules 上游注 + workflow.js 派生注),口径统一"文档上游、代码派生",FloorTable 三类维名与上游逐字一致。**透明披露**:用户原指令3 含"甚至把老功能的部分隐藏起来",按用户自身 refinement(AskUserQuestion 答"旧的四个放到后面")软化为"显式标回落、保持可见"而非真隐藏——真隐藏会与 D13 不退役 + 守 Y 冲突,属忠实解读非擅自执行。

**副作用**:verdict=**needs-revision**(1🟡)。reframe 措辞只传播到 D13/§1.2 + 入口,**spec 正文 ~28 处 + setup.sh/ROADMAP/PROGRESS/plans/handoff 仍用旧「活备份/平级」措辞,新旧 framing 并存**(🟡)。其余副作用项经反向追问不构成欠缺:双写对未上 hook 机读校验 = 与现存 5 对双写同构(文字义务 + 触点维核),反向追问"不上 hook 怎么解漂移"→ 文字义务 + 审查兜即可,非欠缺;workflow.js 注释-only 改动抬高凭证范围 = 合理代价(注释也是 .claude/workflows/* 内容)。

**scope 漂移**:verdict=**pass**。守 Y 三文件(design-reviewer.md / synthesis L113·L151 维序 / design-rules)经 git diff 零改;只 framing + 双写,无架构/运行逻辑改;D13 两支柱(不替换 + ultracode 专属)无漂移;"自洽性 / 完整性 / 合理性 / RUBRIC 对齐"4 维串逐字保留;无功能蔓延(未退役老路、未重建 X)。

**触点完整性**:verdict=**pass**。① 入口一致——scout 主推/老 4 维回落措辞在所有 design-review 入口一致,无入口仍框固定 4 维为主;② 根 CLAUDE↔harness CLAUDE 设计审查行字节一致(`diff` 空);③ 指令2 新双写对三处齐全、口径一致、互相指认,两源三类维名逐字一致;④ spec 正文未随 reframe 升级措辞 = decision 改动落点段显式 scope 排除(非漏改)。

**任务级结论登记簿(本批 = designer 设计 + 8 路 workflow 实现+逐文件 review)**:
- 8 文件实现(spec/decision/SKILL/CLAUDE×2/QUICKREF/review-rules/credentials-rules/workflow.js)各经独立 reviewer 核 compliant(workflow `rs-reframe-impl`,16 agent);CLAUDE×2 双写 diff 空;workflow.js 禁用项零、FloorTable byte-identical;4 维串逐字保留。
- 收口审计副作用维 needs-revision → 术语桥 fix(commit `2d97a11`)。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:4/5 pass(核心原则 / 目的达成 / scope 漂移 / 触点完整性)。守 Y 守住、D13 两支柱保留、双写对三处闭环且维名逐字一致、诚实边界守住、CMD5 双写空——五方独立印证。framing 忠实落实用户指令3,双写忠实落实指令2。
- **真 revision(副作用维 needs-revision,1🟡)**:reframe 部分传播,spec 正文 + 记录文件仍旧「活备份」措辞,新旧并存。**关键:触点完整性维(consistency 主维)独立判 pass**——decision 改动落点显式 scope 排除 + "活备份"与"回落路"语义不矛盾(都指 ultracode 不在场时执行、不退役),即这是"术语未全量统一"而非"逻辑矛盾"。**处置**:术语桥(commit `2d97a11`)在 D13 后钉一句"后文及记录文件的『活备份』= 此『回落路』旧称、主次以 D13 为准、历史文件按 R12 不追溯改写",使 spec 内部自洽,最小变更解掉新旧并存困惑;**全量术语统一(spec 正文 + setup.sh/ROADMAP/PROGRESS 等)列 ROADMAP 观察项**(非阻断)。
- 副作用维其余两点(双写未上 hook / 注释抬凭证范围)经反向追问不构成欠缺,不处置。
- **透明披露**(目的达成度):"隐藏老功能"按用户 refinement 软化为"显式回落保持可见",对齐用户拍板,非擅自。
- 无新决策拐点(decision 2026-06-13 + 本批 D13 表述微调已记 decision 后续影响段;decision-trail 将 append)。

## 5. 判定

**verdict: pass-after-revision**。revision(副作用维:reframe 部分传播、新旧并存)经术语桥 commit `2d97a11` 落地(spec 内部自洽)。本 audit covers 命中凭证 6 文件(SKILL / review-rules / credentials-rules / `<root>/CLAUDE.md` / `CLAUDE.md` / workflow.js)。守 Y 全程保持(design-reviewer.md / synthesis L113·L151 维序 / design-rules 零改)。1 ROADMAP 观察项(全量「活备份」→「回落」术语统一,含 spec 正文 + setup.sh/ROADMAP/PROGRESS;历史/记录文件按 R12 不追溯改写)。指令3 表述调整 + 指令2 文档上游双写忠实落实用户拍板,可收口。

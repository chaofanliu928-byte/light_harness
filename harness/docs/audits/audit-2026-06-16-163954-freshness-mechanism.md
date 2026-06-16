---
audit: true
covers:
  - docs/governance/freshness-rules.md
  - docs/governance/credentials-rules.md
  - docs/governance/brainstorming-rules.md
  - docs/governance/design-rules.md
  - docs/governance/planning-rules.md
  - docs/governance/implementation-rules.md
  - docs/governance/testing-rules.md
  - docs/governance/review-rules.md
  - docs/governance/finishing-rules.md
  - docs/governance/synthesis-rules.md
  - docs/governance/model-route.md
  - <root>/CLAUDE.md
  - CLAUDE.md
  - <root>/AGENTS.md
  - templates/AGENTS.md
  - .claude/agents/freshness-scout.md
  - docs/RUBRIC.md
---

# audit:freshness 反腐烂/新鲜度机制实现批(知识系统 backlog Step 1 — 治理面收口凭证)

> 本批 = llm-wiki/知识组织方向 backlog 清理 **Step 1:反腐烂/新鲜度机制**。给会腐的"活文档"加保质期标签(frontmatter owner/last-reviewed/生命周期)+ 会话开场 fork 新鲜度侦察子智能体(扫活文档、**只报问题、干净静默、需 agent 运行时无则跳过**)+ owner 二分(用户/调度者)+ 90 天初值待实战调 + 复核=推日期 + **软不阻断**。**时间腐+孤儿腐轻组合,漂移腐留 ★**。covers = 命中 credentials.conf 的 17 文件(spec/plan/Step0 留痕/ARCHITECTURE[不命中 glob,自愿连带]不进 covers)。

## 1. 元信息

- 批次:freshness 机制实现(知识系统 backlog Step 1);分支 `knowledge-freshness`
- 审查对象:commit `72b3543`(T1)..`17d3785`(T7)+ `2b4a957`(plan)+ 前序 `118d1fa`(Step0 留痕)/`fd856a4`(spec)
- 凭证类型:对抗审查 audit(命中 credentials.conf:`docs/governance/*.md`×11 / `CLAUDE.md`×2 / `AGENTS.md`+`templates/*.md`×2 / `.claude/agents/*.md` / `docs/RUBRIC.md`)
- 模态:对抗式;治理审查 N=5(bootstrap-4 + 触点完整性);单 turn 并行 fork(workflow `freshness-finishing-audit`,5 独立中性挑战者);synthesis-rules 事前中性化 + 事后按证据综合
- **方向评估站位**:本机制方向(反腐烂轻组合)+ spec 已经 **design-review(review-scout dogfood,4 挑战者 + scout 现推维)** 独立对抗审过(RUBRIC对齐/自洽性/完整性/触点完整性/守住边界凭证,1🔴三处同核拷贝组+7🟡 全修);实现忠实落 spec(per-task reviewer 7 任务 pass + 调度者 §6/§8 静态核全过)。故 finishing **不另跑方向评估**——治理审查核「实现忠实 spec + 守住不退化 + 触点完整 + 凭证不漏」。
- 时间:2026-06-16 16:39

## 2. 维度选取

- B(bootstrap-4,治理行强制基线):核心原则合规 / 目的达成度 / 副作用 / scope 漂移
- A(条件必选):**触点完整性维**(本批核心 = 三处同核拷贝组 + frontmatter 单源 + 凭证 covers 完整,必选)
- 禁用:安全扫描 / 流程审计(治理批暂不纳入,finishing-rules §治理批收口工序适用);方向评估(已由 design-review 覆盖,见 §1 站位)

## 3. 挑战者执行记录(5 独立 fork;git diff main...HEAD + 逐文件 diff 实核,公设1 不采信自报)

- **核心原则合规**:verdict=**pass**(5🟢)。文档第一公民(spec 504 行/plan 542 行先于实现且一致;两份新文件互为单源——scout 显式"判据/范围/取值域派生自 freshness-rules,不另立第二权威");最小变更(numstat 证回填 12 文件全 `1 added/0 deleted` 纯 frontmatter 零正文改;接线三宿主仅 additions 零 deletions);角色分离+二公设(scout L16"扫描报问题=做事;owner 拍还准=判断,不归你"+ L14 只读不写;freshness-rules"推日期=软自评可独走;改内容=须对抗审查"闭合公设1 乐观偏差);软不阻断降级。
- **目的达成度**:verdict=**pass**(1🟢)。端到端真接通无空壳:三处接线(根 CLAUDE 第3步 + AGENTS×2 + harness/CLAUDE #11 指针)同核齐备且 §8 第8条登记;scout 契约二态出参(clean | problems[])/三类判据/展示粒度/降级 全且单源引 freshness-rules;核心集 11 文件 frontmatter 已回填(格式逐字同 preferences、RUBRIC owner=用户其余调度者)、scout 扫得到;复核=推日期可落。1🟢 = 根 AGENTS 多一条"凭证义务"bullet(自仓库 vs 下游既有非对称,不在 §8 同核六步集内,非缺陷)。
- **副作用(守住退化核)**:verdict=**pass**(5🟢)。逐文件 diff 实证:对账三命令(check-handoff/check-shelf-registry/check-audit-coverage)**四处拷贝位全 IDENTICAL**;credentials §8 **第5条对账拷贝组逐字零改**(仅行号位移因首行插 frontmatter)+ 新增第8条显式"与第5条独立、不并入";references 过时横幅约定 / audit 失效判定(credentials §5)/ preferences frontmatter **零改**(均不在 changeset 或仅留痕索引行);回填 12 文件**纯插入零正文删改**(全分支唯一删行=harness/CLAUDE #11 纯 append 替换、原文逐字保留为前缀);新鲜度节**另起独立 ## 节(L48)、未嵌入手工校验纯人工段(L40)**,fork 指令不污染 bash 段。
- **scope 漂移**:verdict=**pass**(0 findings)。MVP 不做清单(漂移腐/硬阻断/自动修复/全仓回填/重复管 immutable·audit)逐条守住未越界;核心集先上 + agents/skills/README 增量不批量(仅 freshness-scout 自带标签做递归闭环);两份新文件无顺手扩写(恰 3 字段/范围三分/唯一 N=90)、按节追溯 spec;90 天显式标初值待实战调、避便利论证。
- **触点完整性**:verdict=**pass**(1🟢)。三处同核拷贝组(根CLAUDE第3步/根AGENTS/templates AGENTS)6 核步骤齐全、仅路径前缀差异(结构等价);credentials §8 第8条登记三处同改且显式独立于第5条(第5条/conf 零改);frontmatter 三字段 + kind 三类 + routeTo 三值 + owner 二分 在 freshness-rules(单源)↔ freshness-scout 逐字一致;两份新文件自带 frontmatter 递归闭环;harness/CLAUDE #11 指针宿主对齐。1🟢 = 本实现批尚无对应 audit(=本文件,收口产出),covers 须含全部命中-glob 文件(本 audit 已列 17 文件;ARCHITECTURE 不命中 glob、自愿连带回填无须列入)。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:**5/5 pass,零🔴零🟡,全🟢观察**。守住五项铁律(对账三命令 / credentials §8 第5条对账拷贝组 / references 过时横幅 / audit 失效判定 / preferences frontmatter 格式)经"副作用"维逐文件 diff 实证**全零改**;三处同核拷贝组 + §8 第8条独立登记 + frontmatter 单源一致 经"触点完整性"维独立印证;实现忠实落 spec(numstat 纯插入 + 接线纯 append)经"核心原则/scope"两维印证。叠加前序 design-review(review-scout dogfood)对 spec 的对抗审 + per-task reviewer 对实现的逐任务审,多层独立印证。
- **无真 revision**:全🟢观察(根 AGENTS 凭证 bullet 非对称=合法既有差异;audit 待产=本文件)。无 🔴/🟡 阻塞。
- **接受不处置**:① 根 AGENTS vs templates AGENTS 的"凭证义务"bullet 非对称——下游分发无 §8 凭证制度本体,该 bullet 是自仓库特有,不在 §8 第8条同核六步锚定范围(fork/三类问题/owner+routeTo/静默/推日期/降级),三处六步齐备即同核;② ARCHITECTURE.md 回填无强制 audit(不命中 glob),自愿连带、不入 covers(spec §8.2 已诚实登记)。
- **meta-L4 正向数据点**(归 review-scout 观察项):本批 design-review 用 review-scout dogfood,scout 现推维**未退化**——保留 2 地板维、跳过 2 候选(留痕)、按 spec 信号现推 2 专属维(触点完整性·双写 / 守住边界·凭证映射),后者抓出"三处同核拷贝组只登 2 处"的真 🔴。
- 无新决策拐点(D-1~D-9 brainstorming 已拍;decision-trail 将 append)。

## 5. 判定

**verdict: pass**(5/5 治理审查挑战者 pass;零🔴零🟡,全🟢观察)。本 audit covers 命中凭证 17 文件(11 governance + CLAUDE×2 + AGENTS×2[根+templates]+ freshness-scout + RUBRIC)。守住五项铁律全零改实证(对账三命令四处 IDENTICAL / §8 第5条对账拷贝组逐字零改 / references 横幅 / audit 失效 / preferences 格式)。三处同核拷贝组(根 CLAUDE 第3步 + AGENTS×2)经 §8 第8条独立登记(显式独立于第5条)、结构等价齐全;frontmatter 单源一致 + 递归闭环。实现忠实落已 design-review 通过的 spec。知识系统 backlog Step 1(反腐烂轻组合)可收口;Step 2 = ★ 设计层到手边(待启)。

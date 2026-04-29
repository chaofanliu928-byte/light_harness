# M1+M2+M4 — 治理改动 batch(P0.9.1.5 第二个 trial)

**类型**:方案选择型 + P0.9.1.5 第二个 trial(用 harness 治理 harness 自身)
**日期**:brainstorming/spec/plan 写于 2026-04-28(用户":启动 M1-M4");meta-review fork 实际跑于 2026-04-29 09:58:21(跨日继续)
**触发**:用户(2026-04-28)指示":启动 M1-M4"(2026-04-17 起草的 M0-M4 治理修改批次第二项起)
**关联**:
- 上游 decision:`2026-04-17-harness-self-governance-gap.md`(M0-M4 起草)
- 上游 retrospective:`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`(P0 / P2 改进建议来源)
- 上游 spec:`docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md`(brainstorming 产出 + meta-review 后修订)
- 上游 plan:`docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md`(本批次实施计划)
- 同期 trial:`2026-04-28-m0-delete-block-dangerous.md`(P0.9.1.5 第一个 trial)
- meta-review audit:`docs/audits/meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md`(verdict=pass after revision,4+2 挑战者扁平 fork,1 轮修订)
- 用户原则:`feedback_iterative_progression.md` / `feedback_dimension_addition_judgment.md` / `feedback_unprovable_in_bootstrap.md` / `feedback_judgment_basis.md` / `feedback_spec_gap_masking.md`

---

## 问题

2026-04-17 retrospective 报告(老版本审查)识别 P0/P2 三条治理改进:
1. **P0 封死"规则可选化"路径**(M1):agent 主动提"A 严格 / B 简化"二元让用户选,治理文档无反应
2. **P0 spec §0 偏离 + RUBRIC 简洁性维度作跳过依据**(M2 + M4 部分):评分标准被反向用作规避标准
3. **P2 spec §0 偏离不能用来免 design-review**(M4 部分):轻量级判定标准弱,易被滥用

M0(删 block-dangerous)2026-04-28 完成,P0.9.1.5 第二个 trial 起 M1 + M2 + M4(M3 drop,见下)。

## 方案

**A. batch 1 个 trial(M1+M2+M4 一起)**(本次选定)
- 共享 brainstorming + meta-review fork + commit batch
- audit covers 改动 governance 文件 + spec / plan
- meta-L4 数据点:1 个 batch 验证 P0.9.1 流程

**B. separate 4 个 trial(M1 / M2 / M3 / M4 各 1 个)**
- 4 次完整流程 + 4 个独立 audit
- meta-L4 数据点 ×4(治理流程被 trial 4 次)

## 决定

**采用 A(batch)+ M3 drop**

### A 选择理由

1. M1+M2+M4 都是 governance 文档级 hardcode,scope 全在 A 组(`governance/*.md`),改动相邻
2. M0 已产 1 个数据点;再 1 个 batch 数据点(改动多样化覆盖)对验证 P0.9.1 流程已足够,4 个数据点边际收益递减
3. 4 改动相互引用清晰(M2 通用 + M4 落地 design-rules.md 时同步声明 — `M4 表第 4 列条件 4 与 M2 同步约束`),batch 一次性看完比 4 次 trial 减少冲突可能

### M3 drop 理由

retrospective 报告里 M3 列两条 finishing 内部冲突:
- **#1 finishing-rules.md §15 vs archival 删除时机**:**已解决** — 当前 finishing-rules.md security-scan-result.md 在 §方向评估第 7 项用于检查存在 + 无 Critical,在 §通过 Step 9 归档时删除 — 两处职责不同,不存在单一事实源冲突;archival-rules.md 已不存在(归档逻辑已融入 finishing-rules.md "通过分流"段)
- **#2 structured-handoff skill 分工模糊**:**超 scope** — skill 改动属 scope=C 组(`.claude/skills/*/SKILL.md`),需走自己的 trial,不在本 batch

**注**:#1 验证方式 — 重读 finishing-rules.md 时序逻辑,无独立 agent 验证;无 P0.9.1 主动修复行动,仅"重读判断"(meta-review D2-F6 documented)

→ 本批次 drop M3,#2 推 P0.9.2 实战观察期

## 反向追问(`feedback_dimension_addition_judgment` 原则要求)

**Q1:不删 fork-fail-degradation 路径 — 是否仍留 bypass 后门?**
A:fork-fail 是技术阻碍(可外部观测:fork 调用返回错误 / agent 不可用),与 rule-bypass(主观判断)有本质区别。fork-fail 不删,rule-bypass 走 decision 立档 — 区分清晰。**meta-review D2-F1 进一步加防滑条款**:agent 不得在未实际发起 fork 调用前就声称 fork 失败 — 已落地 finishing-rules.md M1 子项。

**Q2:M2 / M4 仅约束"如何引用 RUBRIC",RUBRIC.md 自身不变,是否漏了上游?**
A:RUBRIC 仍是评分标准(用于 evaluator agent 给分);本 batch 只禁止"用 RUBRIC 维度作跳过依据"。改 RUBRIC 自身=改评分语义,scope 完全不同,不在本 batch。**meta-review D3-F8 加 evaluator 防护澄清**:M2 第一子项加"RUBRIC 仍是 evaluator agent 的评分依据;本约束仅限于'用 RUBRIC 维度推导是否跳过某治理 step'的决策语境" — 已落地。

**Q3:M4 第 4 列"改动行数 < 100 行"是否过严?**
A(meta-review D1-F1+F2 修订后):**100 行是本 batch 自洽所用的内部阈值** — 本 batch 改动约 +20~+28 行,远低于 100 行。**该阈值的合理性尚无实测数据支撑**(M0 trial +345/-39 是已升标准级反例,不构成"轻量级上限"佐证)。后续 P0.9.2 实战观察期可能调整(spec §9.4 缺口同类)。**真正反向追问**:如果不加第 4 列前置硬条件,"spec §0 偏离用 RUBRIC 维度做免审"问题如何解决?A:无替代解法 — 旧机制仅"改动 1-2 个文件 + 不涉新模块/接口",无法阻止 spec 自宣告 + RUBRIC 简洁性滥用,故第 4 列必要,不是过度工程化。

**Q4(meta-review D2-F4 衍生):M4 条件 (2)(3) 是语义判定不是机械门槛,如何防滥用?**
A:design-rules.md 加默认升级原则 — "对 (2)(3) 任何疑义时,默认升至标准级,与 §规模判断段尾'按标准级执行'原则一致",不要靠 spec 自宣告"我觉得不涉及"绕过。

**Q5(meta-review D2-F3 衍生):M2 落地 finishing-rules.md(finishing 阶段读),原始违规在 design 阶段写 spec §0,时序错位 M2 是否真生效?**
A:M2 是 finishing 阶段的**反向回顾性**约束,M4(design-rules.md spec §0 偏离规则段)是 design 阶段的**正向阻断性**约束,两者协同。**已加跨阶段同步约束**(finishing-rules.md M2 子项 + design-rules.md `## spec §0 偏离规则` 段双向互引)。

## 不做(防 scope 扩散)

- 不改 RUBRIC.md 自身(评分语义不变)
- 不改 meta-review-rules.md(M2 是反模式硬编码,不涉及 review 维度选取段)
- 不改 hook 校验(语义判断,M2 / M9 治理层负责)
- 不批量改 spec / plan / decision 中现有 RUBRIC 引用(本批次后产出的新文档遵守新规则即可)
- 不在本 batch 修 M3 #2(structured-handoff skill 分工)— 推 P0.9.2

## 已知缺口(显式承认 — `feedback_spec_gap_masking` 原则要求)

> spec §9.4 共 9 条已知缺口(初版 4 条 + meta-review 修订加 5 条),此处概览,完整见 spec §9.4。

1. **agent 自律依赖**:M1/M2/M4 都是文字硬编码,无 hook 检测语义违规 — 接受,P0.9.2 实战观察期收集
2. **下游分发未覆盖**:本 batch 改 `harness/docs/governance/*.md`,下游已装项目本地副本不自动更新,不在本 batch 处理
3. **bootstrap 自指**:M2 提议"不引 RUBRIC 作跳过依据"在本 batch spec §1.6 自身遵守 — 接受,依据 `feedback_unprovable_in_bootstrap.md`
4. **M3 drop 决定**:基于"#1 已解决 + #2 超 scope"判断;若 P0.9.2 实战观察期发现重现,M3 重新进 ROADMAP
5. **harness self-trial 验证局限**(meta-review D2-F2/F7 共识):M0 / 本 batch 验证局限于 harness 自身,执行者(调度者主对话)在 meta 路径有大量上下文注入,不代表下游 agent 在 feature 路径 finishing 时的遵从度。P0.9.2 应在下游真实项目首次使用 finishing-rules.md 时采集第一手数据
6. **cross-file 互引脆弱性**(meta-review D3-F3):M4 表 L28 条件 (4) 互引 finishing-rules.md M2;若未来改名/删除,design-rules.md 保留悬空引用。无自动同步机制,后续维护需人工核查,P0.9.3 hook 兜底候选
7. **下游 retrospective 引用不可见**(meta-review D3-F5):M1/M2 条款引"2026-04-17 retrospective P0 报告"— 该文件在 harness 仓库本地,分发后下游不可见。规则本身语义独立,不阻断下游遵守
8. **反模式段膨胀无约束**(meta-review D3-F6):finishing-rules.md `## 反模式约束` 段从 2→4 条;无规则约束"段最多多少条"。P0.9.2 可考虑数量门槛或分类
9. **挑战者有效性元疑问**(meta-review D1-F5):若 4 挑战者 first-pass 全 pass 无 finding,无机制强制加 D5 元验证 — 接受调度者主动判断;P0.9.2 收集场景频率

## meta-review 概览(13 处修订)

第 1 轮 4 挑战者 verdict=needs-revision,共识 finding 见 audit §3。第 1 轮修订执行 13 处(spec 7 处 + finishing-rules 3 处 + design-rules 2 处 + DESIGN_TEMPLATE 1 处),解决全部 P1 finding(D1-F1+F2 / D2-F1+F3+F4+F7 / D3-F3+F4 / D4-F1+F4)和关键 P2 finding(D1-F3+F4+F5 / D2-F2+F5+F6 / D3-F1+F2+F5+F6+F7+F8 / D4-F3+F5)。第 2 轮 N=2 简化 fork(D2+D4)双 verdict=pass,**final verdict=pass after revision**。

## 关联

- decision-trail append 一条新抉择"M1+M2+M4 — 治理改动 batch(P0.9.1.5 第二个 trial)"
- handoff:M1+M2+M4 完成留痕(P0.9.1.5 段更新);Evidence Depth 段加 meta-L4 第 2 条数据点
- ROADMAP:P0.9.1.5 段 M1/M2/M4 状态 🟢 已完成,M3 标 ⚪ drop;P0.9.1.5 整体闭合
- audit:`docs/audits/meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md`(verdict=pass after revision)
- spec / plan(brainstorming + writing-plans 产出)

## 后续

- **P0.9.1.5 整体闭合**(M0 完成 / M1+M2+M4 完成 / M3 drop)→ 无剩余 M
- **P0.9.2 候选**(本 batch 推后续条目,5 条):
  - 反审字段重置 enforcement(C2 P-4)
  - D5 / D.2 字节软上限 enforcement(C2 P-3)
  - mixed scope 双 finishing 成本量化
  - **decision-trail meta-L4 验证**(append 频率 / 提取质量 / 调度者忽略率)
  - **harness self-trial vs 下游 agent 遵从度差异**(本 batch §9.4 #5 推后续)
  - **反模式段膨胀分类治理**(本 batch §9.4 #8 推后续)
  - **挑战者有效性元疑问 D5 场景频率**(本 batch §9.4 #9 推后续)
  - **M3 #2 若重现** — structured-handoff skill 分工(scope=C 组,走自己的 meta-finishing + meta-review M2 流程)
- **P0.9.3 候选**:
  - cross-file 互引 hook 检测(本 batch §9.4 #6 推后续)
  - M3 hook 不可见缺口(spec §1.3 fix-9 (vii))
  - 现有 fix-9 (i)(ii)(iv)(vi)
  - decision-trail hook 校验(若 P0.9.2 显示频繁忽略 append)
- **链接保鲜**:无 — 本 decision 不依赖外部 URL
- **用户实际反馈**:落地后是否真的不再见"agent 主动提简化收尾"或"RUBRIC 维度作免审依据"?P0.9.2 实战观察期收集

## 杂项注

- **GPG 授权链**(meta-review D1-F6):本 batch commit 用 `git -c commit.gpgsign=false` — 用户在 M0 trial 时(2026-04-28)实证 GPG 在 Win 环境失败时授权,本 batch 沿用同一处理。若用户对此处理有异议,可改为 GPG sign 重 commit。
- **行号悬空修复**(meta-review D4-F4):本 decision 不再用"L49+L84"等行号引用 finishing-rules.md / design-rules.md,改为节标题 + 步骤号语义引用(如"§方向评估第 7 项")。

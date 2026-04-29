# M1+M2+M4 治理改动 batch 系统设计(P0.9.1.5 第二个 trial)

> **轻量级 spec**(`design-rules.md` §规模判断)— 改动 2 个 governance 文件,3 处文字硬编码,不涉及新模块或接口。
> 只填第 1 节(需求摘要) + 第 8 节(涉及文件和改动说明) + 第 9 节(自洽性检查)。

> **scope**:meta(A 组 governance/*.md);走 `meta-finishing-rules.md`(M1)四步流程 + `meta-review-rules.md`(M2)fork N 挑战者审查。

---

## 1. 需求摘要

### 1.1 用户目标

P0.9.1.5 第二个 trial — 验证 P0.9.1 治理流程在多改动 batch 下仍生效(M0 是单改动数据点)。同时落地 2026-04-17 retrospective 报告 P0/P2 三条治理改进:封死"简化收尾"、防 RUBRIC 维度作跳过依据、轻量级判定收紧。

### 1.2 核心场景

1. **[P0] M1 封死简化收尾**:agent 读 `finishing-rules.md` 后,**不得**主动框出"A 严格 / B 简化"二元让用户选,**不得**给"简化"倾向性推荐。区分:
   - **fork-fail-degradation**(允许):security-scan / evaluate / process-audit 任一 fork 失败 → 调度者按对应 agent.md 自审,标 `⚠️ 降级执行,未经独立 agent 验证`
   - **rule-bypass**(需 decision):用户明确指示跳过 → 写 `docs/decisions/<date>-skip-finishing-<reason>.md` 立档

2. **[P0] M2 元规则评分维度不得作跳过依据**:RUBRIC.md 是评分标准(产出衡量),**不**是 process 选取标准。禁止句式"因 RUBRIC X 维度权重 Y%,本 spec 不需要 Z step"。

3. **[P0] M4 轻量级判定收紧 + spec §0 偏离规则**:
   - `design-rules.md` 轻量级判定加 4 条前置硬条件(改动行数 < 100 / 不涉 RUBRIC 红线 / 不涉多模块共用接口 / spec §0 偏离不引 RUBRIC 维度免审)
   - 加新段 `## spec §0 偏离规则`:偏离说明只允许记结构差异,**不允许**用来豁免 design-review

### 1.3 边界与约束

**做什么**:
- 改 `docs/governance/finishing-rules.md`(反模式约束段加 2 条:M1 封死 + M2 RUBRIC 不作跳过依据)
- 改 `docs/governance/design-rules.md`(轻量级判定表加第 4 列前置硬条件 + 新段 spec §0 偏离规则)

**不做什么**:
- **不**改 `RUBRIC.md` 自身(RUBRIC 评分语义不变,只改"如何引用 RUBRIC"的规则)
- **不**改 `meta-review-rules.md`(M2 是反模式硬编码,不涉及 review 维度选取段)
- **不**做 M3(2026-04-17 报告里 M3 列的两条冲突,#1 已在 P0.9.1 落地后解决,#2 是 skill 层问题超出本 trial scope)
- **不**加 hook 校验(语义判断,M2 / M9 治理层负责;P0.9.2 实战观察是否真生效)
- **不**改下游分发(改的都是 harness/docs/governance/*.md,不在 setup.sh 分发清单的 PROBLEM ZONE — 待确认 — **见 §9 自洽性检查**)

**性能要求**:无(纯文档改动)
**安全要求**:无
**兼容性要求**:下游已装项目本地副本不会自动更新(setup.sh 不做反向同步,与 M0 一致;新跑 setup.sh 的项目会得到新 governance 文件)

### 1.4 关联需求

**依赖的已有功能**:
- P0.9.1 meta-finishing-rules.md(M1)+ meta-review-rules.md(M2)流程
- decision-trail.md 自动 append(2026-04-28 落地)
- M17 scope.conf A 组 glob 命中 `docs/governance/*.md`

**被哪些未来功能依赖**:
- 暂无 — 本 batch 是改进项,不引下游新功能

### 1.5 已确认的决策(从 brainstorming 阶段带入)

1. **批量 vs 分开**:用户选 A(批量),理由 — 4 改动都是 governance 文档级 hardcode,scope 高度相邻;M1+M3 都改 finishing-rules.md(若 M3 不 drop),batch 一次性看完比分开 trial 减少冲突可能;trial 价值是验证 P0.9.1 流程,M0 已产 1 个数据点,再 1 个 batch 数据点(改动多样化覆盖)对验证流程已足够
2. **M3 drop**:retrospective 报告里 M3 列的"finishing 内部冲突"#1 已在 P0.9.1 落地后解决(security-scan-result.md 在 §方向评估第 7 项用于检查存在 + 无 Critical,在 §通过 Step 9 归档时删除 — 两处职责不同,不存在单一事实源冲突;**注**:本批次落地后行号会偏移,故用语义描述而非行号),#2(`structured-handoff` skill 分工模糊)是 skill 层改动 scope=C 组,要走自己的 trial,不在本 batch
3. **不引入 hook 校验**:M2 / M9 治理层(语义判断)负责,与 spec §1.3 fix-9 (iv) 一致

### 1.6 RUBRIC 风险标记

> 本节按 governance scope 类比适配(harness 自仓库的 governance 改动不直接套 feature RUBRIC):
> **澄清**:以下描述性使用 RUBRIC 术语(简洁性 / 内部一致性等)是为便于对话,**不作为**设计规模或 design-review 豁免的判定依据(M2 / M4 约束)。
- 涉及的"产出健康性"维度:简洁性(改动行数最小,3 处硬编码)、内部一致性(M1+M2+M4 三条不互相矛盾、与既有反模式段不冲突)
- 涉及的"治理机制"维度:不引入新模块、不增加流程负担(只加反模式硬编码 + 表列前置硬条件)
- **本 spec 不引 RUBRIC 维度作"是否走 design-review / 是否跳过任何 step"的判定依据**(M2 自约束声明 — 本文件即遵守 M2 提议的新规则,bootstrap 自洽)

---

## 8. 涉及文件和改动说明

### 8.1 改动清单

| 文件 | 类型 | 改点 | 行数估计 |
|------|------|------|---------|
| `docs/governance/finishing-rules.md` | 改 | `## 反模式约束` 段(L24-L29 区域)新增 2 条 — M1 封死简化收尾 + M2 RUBRIC 不作跳过依据 | +12 ~ +16 行 |
| `docs/governance/design-rules.md` | 改 | (1) 规模判断表(L26-L30)加第 4 列"前置硬条件" — 4 个机械门槛;(2) 表后新增 `## spec §0 偏离规则` 段 — 偏离不能用来免 design-review | +8 ~ +12 行 |

合计 +20 ~ +28 行,删 0 行。轻量级。

### 8.2 改动前后对比(关键文字)

#### M1 — finishing-rules.md `## 反模式约束` 段加(在现有 2 条后追加):

```markdown
- **不得主动提"简化收尾"二元方案**(2026-04-17 retrospective P0 报告 §"规则摩擦点"#1):agent 读本文件后,**不得**框出"A 严格 / B 简化"让用户选,**不得**给倾向性推荐"简化收尾"。
  - 唯一允许的降级路径:**fork-fail-degradation** — security-scan / evaluate / process-audit 任一 fork 失败 → 调度者按对应 agent.md 自审,标 `⚠️ 降级执行,未经独立 agent 验证`(本文件 §安全扫描 step 4 / §方向评估 step 9 / §流程审计 step 14 已有此约定)
  - 不允许的:**rule-bypass** — agent 觉得"重"主动跳过完整流程。若用户明确指示跳过,需写 `docs/decisions/<date>-skip-finishing-<reason>.md` 立档
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)
```

#### M2 — finishing-rules.md `## 反模式约束` 段加(M1 后追加):

```markdown
- **RUBRIC 维度不得作跳过治理 step 的依据**(2026-04-17 retrospective P0 报告 §"完全没预料到的模式"#2 "spec §0 偏离说明成 bypass 载体"):
  - RUBRIC.md 是**评分标准**(产出衡量),**不**是 process 选取标准
  - 禁止句式:"因 RUBRIC 简洁性权重 23%,本 spec 不需要 design-review" / "RUBRIC 没有 X 维度,所以跳过 X step"
  - 评分维度 ≠ 流程豁免;治理流程的跳过依据由 governance/*.md 自身定义(如 design-rules.md "轻量级"判定),**不**引 RUBRIC
```

#### M4 — design-rules.md 规模判断表加第 4 列(L26-L30):

```markdown
| 级别 | 判断标准 | 设计深度 | 前置硬条件(任一不满足升至标准级) |
|------|---------|---------|----------------------------------|
| **轻量级** | 改动 1-2 个文件,不涉及新模块或接口变更 | 写**精简版设计文档**:只填第 1 节(需求摘要)+ 第 8 节(涉及文件和改动说明)+ 第 9 节自洽性检查中适用的项。不需要 design-review | (1) 改动行数 < 100 行(`git diff --stat` 总和);(2) 不涉及 `docs/RUBRIC.md` 红线段(目录约定 / 命名规范 / 架构边界);(3) 不涉及多模块共用接口或类型;(4) spec §0 偏离说明不引 RUBRIC 维度做免审依据(与 M2 同步约束) |
| **标准级** | 涉及新模块或接口变更,但不超过 3 个模块 | 写完整设计文档,不适用的节可写"不适用" | — |
| **重量级** | 涉及 4 个以上模块或跨系统交互 | 写完整设计文档,所有节必填 | — |
```

#### M4 — design-rules.md 加新段(规模判断表后追加,§角色分离前):

```markdown
## spec §0 偏离规则

- spec §0 "偏离说明"只允许记录**结构差异**(用什么 heading / 用什么编号 / 调整哪节顺序),**不允许**用来豁免 design-review(2026-04-17 retrospective P2 #"spec §0 偏离说明 不能用来免 design-review")
- 任何非 emergency 的 spec **必须至少过一次 design-review**;偏离模板者反而应**加强 review,不是减轻**
- 唯一不需要 design-review 的路径:轻量级判定(本文件 §规模判断 表)— 由表中四列前置硬条件机械判定,**不**由 spec 自宣告
- emergency 路径定义:线上故障紧急修复 + 同时缺时间走 design-review;事后必须补 design-review,不能"emergency 一次永久免审"
```

### 8.3 元改动同步(M1 meta-finishing 四步引导)

按 `meta-finishing-rules.md` Step D 通用同步项:
1. **decision-trail.md append**:1 条新抉择"M1+M2+M4 — 治理改动 batch(P0.9.1.5 第二个 trial)"(时间倒序,最新在上)
2. **PROGRESS.md**:不更新 — `meta-finishing-rules.md` L190 Step D 要求 PROGRESS 仅在"跨阶段"改动时更新;P0.9.1.5 trial 本身不算跨阶段,M0 trial 也未补 PROGRESS 行,本 batch 一致不补
3. **ROADMAP.md**:`P0.9.1.5` 段 M1/M2/M4 状态从"等用户启动"改 🟢 已完成,M3 标 ⚪ drop(原因 + 推 P0.9.2)
4. **handoff.md**:目标段 + Evidence Depth 段更新,加 meta-L4 第二条数据点
5. **decision file**:`docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md`(方案选择型 — 含 batch vs separate 选择 + M3 drop 理由)
6. **memory**:
   - `memory/MEMORY.md`(用户 feedback 索引)— 不新建条目(本 batch 不立新原则,沿用既有 feedback)
   - `memory/project_harness_overview.md`(meta-finishing-rules.md Step D L192 引用)— 不更新(M1/M2/M4 不涉新模块/接口/架构变更)

---

## 9. 自洽性检查

### 9.1 改动间一致性

- [ ] **M1 ↔ M2** 不冲突:M1 封死"简化收尾",M2 封死"RUBRIC 作跳过依据" — 两条都是反模式硬编码,语义独立(简化 vs 评分维度)
- [ ] **M2 ↔ M4** 协同:M2 通用规则(RUBRIC 不作跳过依据),M4 在 design-rules.md 落地具体(轻量级判定第 4 列条件 4 + spec §0 偏离规则);两者无冲突,且 M4 自指 M2 同步约束
- [ ] **M1 ↔ 现有 §安全扫描 step 4 / §方向评估 step 9 / §流程审计 step 14** 不冲突:这些 step 已有 fork-fail 降级文字(`⚠️ 降级执行,未经独立 agent 验证`),M1 封死段是"反向"约束(防 rule-bypass),与 step 内允许的 fork-fail-degradation 协同
- [ ] **M1 ↔ `meta-finishing-rules.md` Step A skip 路径** 路径不重叠:M1 在 feature 路径(finishing-rules.md);meta-finishing Step A 的"小修 skip"在 meta 路径(meta-finishing-rules.md);两者无重叠。**mixed scope** 时调度者同时遵守两套规则,无语义冲突但认知负担增加(已在缺口 #5 documented)

### 9.2 既有治理引用未断

- [ ] `meta-finishing-rules.md` Step D 通用同步项要求 `decision-trail.md` append — 本 batch 满足
- [ ] `meta-scope.conf` A 组 glob `docs/governance/*.md` 命中本 batch 改动 — 触发 M15 hook 检查 audit covers
- [ ] M0 trial 为 P0.9.1.5 第一个 trial,本 batch 是第二个 — 序号一致

### 9.3 反向追问(`feedback_dimension_addition_judgment` 原则)

**Q1:M1 封死条款只是文字硬编码,agent 仍可不读 — 是否有意义?**
A:语义判断本就不适合 hook(spec §1.3 fix-9 (iv) 承认);治理文档反模式段是 fallback,M2 / M9 治理层负责。M0 验证了反模式硬编码方式有效(M0 在 finishing-rules.md / planning-rules.md 加了 6 条用户 feedback 反模式,后续 P0.9.1 落地未见违反)。**有意义,作 fallback 层**。

**Q2:M2 / M4 约束 RUBRIC 引用方式,但 RUBRIC.md 自身不变 — 是否漏了上游?**
A:M2 约束的是"如何引用 RUBRIC",不是"RUBRIC 写了什么"。RUBRIC 仍是评分标准(用于 evaluator agent 给分);本 batch 只禁止"用 RUBRIC 维度作跳过依据"。RUBRIC 自身无需改。

**Q3:M4 加的 4 条前置硬条件中"改动行数 < 100 行"是否过严?**
A:**100 行是本 batch 自洽所用的内部阈值** — 本 batch 改动约 +20~+28 行,远低于 100 行,因此满足自身轻量级判定。**该阈值的合理性尚无实测数据支撑**(M0 trial +345/-39 是已升标准级反例,不构成"轻量级上限"正面佐证;无 harness governance 改动行数分布实测)。后续 P0.9.2 实战观察期可能调整(spec §9.4 缺口同类)。**反向追问**(`feedback_dimension_addition_judgment.md`):如果不加第 4 列前置硬条件(去掉 4 条机械门槛),"spec §0 偏离用 RUBRIC 维度做免审"问题如何解决?A:无替代解法 — 旧机制仅"改动 1-2 个文件 + 不涉新模块/接口",无法阻止 spec 自宣告 + RUBRIC 简洁性滥用,故第 4 列必要,不是过度工程化。

**Q4:不删 fork-fail-degradation 路径 — 是否仍留 bypass 后门?**
A:fork-fail 是技术阻碍(可外部观测:fork 调用返回错误 / agent 不可用),与 rule-bypass(主观判断)有本质区别。M0 trial 删除 block-dangerous hook 时已用 fork-fail 概念,与本 batch 一致。**不删**。

**Q5:本 batch 自身需走 design-review?**
A:轻量级,改动 < 100 行,不涉新模块/接口,不涉 RUBRIC 红线,不涉多模块共用接口,spec §0 无 RUBRIC 引用 — 满足新规则 4 条前置硬条件 → **不需要 design-review**。但因 scope=meta,**走 meta-review**(M2 fork N 挑战者),与 design-review 不互替。

### 9.4 已知缺口(显式承认 — `feedback_spec_gap_masking` 原则)

1. **agent 自律依赖**:M1 / M2 / M4 都是文字硬编码,无 hook 检测语义违规 — 接受,P0.9.2 实战观察期收集是否真生效
2. **下游分发未覆盖**:本 batch 改 `harness/docs/governance/*.md`,setup.sh 复制时下游会得到新文字。已装下游本地副本不自动更新(与 M0 一致),不在本 batch 处理
3. **bootstrap 自指**:M2 提议的"不引 RUBRIC 作跳过依据"在本 spec §1.6 自身遵守(明确声明不引 RUBRIC 作判定)。本 spec 写时 M2 还没落地,但写法上预判 — 接受,依据 `feedback_unprovable_in_bootstrap.md`:自举系统在自己落地前不可证有效不算缺陷,声明 + 推后续实战验证即可
4. **M3 drop 决定**:基于"#1 已解决 + #2 超 scope"判断;若 P0.9.2 实战观察期发现 structured-handoff skill 分工模糊在新场景重现,M3 重新进 ROADMAP
5. **harness self-trial 验证局限**(meta-review D2-F2/F7 共识):M0 / 本 batch 的"agent 未违反新规则"验证局限于 harness 自身 trial,执行者(调度者主对话)在 meta 路径下有大量治理上下文注入,**不代表下游 agent 在普通 feature 路径 finishing 时的遵从度**。**实战验证时间线**:P0.9.2 应在下游真实项目首次使用 finishing-rules.md 时采集第一手数据,不以 harness 内部 trial 替代
6. **cross-file 互引脆弱性**(meta-review D3-F3):M4 表 L28 条件 (4) 互引 finishing-rules.md `## 反模式约束` 段 + M2 条款;若未来 finishing-rules.md M2 改名/删除,design-rules.md L28 保留悬空引用。**无自动同步机制**(无 hook 检测 cross-file 标题引用有效性);后续维护需人工核查两文件一致性,**P0.9.3 hook 兜底候选**
7. **下游 retrospective 引用不可见**(meta-review D3-F5):M1/M2 条款文字引"2026-04-17 retrospective P0 报告" — 该文件在 harness 仓库本地(`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`),分发后下游不可见。规则本身语义独立,不阻断下游遵守,但来源溯源受限
8. **反模式段膨胀无约束**(meta-review D3-F6):finishing-rules.md `## 反模式约束` 段从 2 → 4 条;无规则约束"段最多多少条"。长期会膨胀,**P0.9.2 可考虑数量门槛或分类**(通用反模式 vs 阶段特定反模式)
9. **挑战者有效性元疑问**(meta-review D1-F5):若 4 挑战者 first-pass 全 pass 无 finding,**无机制强制加 D5 元验证**(挑战者本身的有效性)— 接受调度者主动判断;P0.9.2 实战观察期收集此场景出现频率

---

## 关联

- **上游 decision**:`docs/decisions/2026-04-17-harness-self-governance-gap.md`(M0-M4 起草)
- **上游 retrospective**:`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`(P0 / P2 改进建议来源)
- **同期 trial**:`docs/decisions/2026-04-28-m0-delete-block-dangerous.md`(P0.9.1.5 第一个 trial,本 batch 第二个)
- **下游 decision**:`docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md`(本 batch 落地后 commit 时立)
- **decision-trail**:落地后 append 1 条新抉择

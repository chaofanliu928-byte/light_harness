---
meta-review: true
covers:
  - docs/governance/finishing-rules.md
  - docs/governance/meta-finishing-rules.md
---

# meta-review:引入 decision-trail.md(P2 可观测性时间维度)

## 1. 元信息

- **审查日期**:2026-04-28
- **审查触发**:scope=mixed 改动(meta 部分:`docs/governance/finishing-rules.md` + `docs/governance/meta-finishing-rules.md` 修订后);其他 3 文件 scope=none(`docs/decision-trail.md` / `docs/decisions/2026-04-28-decision-trail-introduction.md` / `docs/ROADMAP.md`)
- **流程归属**:M1 §3 Step B → M2 §3 流程
- **流程架构**:扁平 fork(M2 §3.1 工具层并行 — 单 turn 一次 4 调用)
- **挑战者数量**:4(D6 弹性 N — 主题为新机制接入,采用 bootstrap 4 维基线)
- **agent 模态**:对抗式(M2 §6 子节 1)
- **改动主题**:引入 `docs/decision-trail.md` 作为 P2 可观测性"时间维度"载体,空间维度由外部仓库 glassbox 覆盖;ROADMAP P2 删除"重复工作 skill 化持久化"条目(用户 2026-04-28 否决)

## 2. 维度选取

### A. 推荐维度清单

- 核心原则合规:F 系列设计哲学 / 用户 feedback memory 一致性 / 不越权 [默认启用: 是]
- 目的达成度:decision-trail 是否真覆盖跨 session 抉择缺口 / 与现有载体差异化 [默认启用: 是]
- 副作用:维护负担 / 文件膨胀 / 自动化 trigger 频率 / 现有载体重叠 [默认启用: 是]
- scope 漂移:本次改动是否扩散 / 触及 scope.conf / 下游污染 [默认启用: 是]

### B. 最低必选维度(bootstrap 4 维基线 — 强制)

- 核心原则合规(不可省 — 第八轮 fix-3 / D7)
- 目的达成度(不可省 — D7)
- 副作用(不可省 — D7)
- scope 漂移(不可省 — D7)

### C. 本次定制

- 启用的推荐维度:全 4 维(=B 段最低必选)
- 禁用的推荐维度 + 理由:无
- 新增的定制维度 + 理由:无(非定制场景 — 主题为常规新机制接入)

## 3. 挑战者执行记录

### 挑战者 1:核心原则合规(verdict: 待修)

**问题清单**:
- [Medium] decision file §决定 — judgment_basis 边缘:"用户已确认形态"列入采用 A 的理由,接近"诉诸权威";建议把"用户确认"从"理由"降为"输入触发"
- [High] decision-trail.md — spec_gap_masking:全文未声明"已知缺口"段,但 meta-L4 验证 / hook 不校验 / 调度者忽略 append 无 enforcement 都是真实缺口
- [Medium] decision file §问题表 + §方案 — dimension_addition_judgment 反向追问未明:未论证"完全不加 finishing 触发步骤,纯手工维护是否够"
- [Low] §后续 / §不做 / §决定:realworld_testing / skill_no_cross_project / choice_visualization 三条合规
- [Medium] finishing-rules.md §通过 step 2 — 最小变更边缘:5 条子规则信息密度高;但作为新治理节点均必要,可接受

**理由**:核心原则未根本违反,但 spec_gap_masking 维度未显式声明 3 条已知缺口

### 挑战者 2:目的达成度(verdict: 待修)

**问题清单**:
- [Medium] decision-trail.md §自动化 / finishing-rules.md step 2 — 触发**仅**绑 milestone commit (M5),但 10 条历史回填中 6 条来自 meta scope;本次改动自身 scope=meta 走 M1,无 append 触发步 → 自指失败
- [High] decision-trail.md — "skill 不跨项目"+"实战在其他项目跑"两条触发条件均为 2026-04-28 用户原则,**无 decision file**;decision file §问题列"用户原则不对应 milestone"作为方案 A 优势,但 finishing-rules step 2 触发点恰只在 milestone — **机制与诉求矛盾**
- [Low] decision-trail.md L20 自指条 §影响 — 叙述"两步实施"与实际 4 文件一次性改动不符
- [Low] 10 条回填均为真判断拐点,无凑数
- [Medium] 与 decisions/ / PROGRESS / memory 三方差异化职责真实(8 个 decision file 验证无索引,真填空白)

**理由**:缺口诊断准确、差异化职责真实、回填合格;但触发机制只挂 M5 milestone,无法承载用户原则级抉择,**结构性错位**

### 挑战者 3:副作用(verdict: 待修)

**问题清单**:
- [High] meta-finishing-rules.md Step D — **未同步加 append decision-trail**。本次改动 scope=meta 走 M1 不走 M5;M5 §1 顶部分流入口明示 "scope=meta → 本文件后续不适用"。结果:本次改动自身落地 finishing 走 M1 无 append 触发 — bootstrap 自洽断裂
- [High] finishing-rules.md L68 step 2 vs L83 step 9 — 动作冗余:两者输入相同(`docs/decisions/`),目标重叠;调度者 1 commit 操作 decisions/ 2 次。建议合并或显式说明区别
- [Medium] decision-trail.md §维护规则 — **无修剪 / 归档策略**。decisions/ 已声明半年归档,本文件未声明;1 年累积 30-50 条后头部信息密度衰减
- [Medium] finishing-rules.md "通过" step 8→9 renumber — grep 全仓未见外部引用 (pass);但 hook 序号未直接核到 hook 源码,需 P0.9.1.5 落地前再确认
- [Medium] finishing-rules.md L72 跳过条款 — skip 阈值无下限,P0.9.1 实施 29 commits 中可能 25+ 次 skip,长期使用率低 + 无监控 = 易死信
- [Low] decision-trail.md L14 自指条:首条自指设计是否允许 artifact 进自身索引未表态,后续若做趋势统计需特判
- [Low] finishing-rules.md L73 依据链:Step 2 ↔ decision file 双向自引,易遗漏同步(本次 M1 同步缺失就是首例)

**理由**:M1 同步缺失导致 bootstrap 不自洽;其余冗余 / 修剪 / skip 阈值为长期治理负担

### 挑战者 4:scope 漂移(verdict: 待修)

**问题清单**:
- [High] meta-finishing-rules.md (M1) — M5 加了 "通过" 路径 append 步,但 meta scope 改动走 M1 不是 M5;M1 §3 Step D 仅说"ROADMAP / PROGRESS 同步",未加 decision-trail。**meta-level 拐点(治理 / 缺口承认 / 用户原则)恰是 decision-trail 最该捕获的**,反而无 append 触点 — 半成品扩散
- [Medium] decision file §自动化定位错误:多数 decision 来自 meta scope,本次 4 文件改 M5 = 选错落点 — scope 错位
- [Low] scope.conf — decision-trail.md / decisions/2026-04-28-*.md 均不命中 include glob,**正确**(产出物非治理规则);bootstrap 自洽,无自循环风险(与 audits/meta-review-* 显式 ! 排除不同结构,是天然 scope 外)
- [Low] setup.sh — 未将 decision-trail.md / decision file cp 到下游,**正确**(harness 自治理 artifact)。无下游污染
- [Low] M4 分发模板 harness/CLAUDE.md — 未加 decision-trail 治理表行,**正确**(下游不需要,同 D13 meta-review 不分发)
- [Medium] ROADMAP P2 line 196-208 — "已落地" + "自动化" + "decision file" 同时声明,语气近乎闭环承诺;但 line 207 "meta-L4 1-2 月观察"明示未验证;line 204 "双层闭环 P1 跑 1 次"是验收信号未达成 — 轻微越界

**理由**:M5 加 append 但 M1 未加是关键漏(meta 拐点 = 主要供给源,落点错位即半成品扩散),需补 M1 §3 Step D 同步加 decision-trail append 才能闭合 scope 边界

## 4. 综合

### 共识发现(高一致性)

| 共识点 | 挑战者交叉 | 严重性 |
|---|---|---|
| **M1 meta-finishing-rules.md 未同步加 append step** | 2/3/4(三方共识) | High 起 |
| 触发只挂 milestone commit 无法承载用户原则级抉择 | 2 + 3(skip 死信)+ 4(scope 错位) | Medium-High |
| decision-trail.md 缺"已知缺口"段(spec_gap_masking) | 1 | High |
| 修剪 / 归档策略缺失 | 3 | Medium |
| step 2 与 step 9 动作冗余,需澄清关系 | 3 | High |

### 分歧

无重大分歧。4 挑战者 verdict 一致"待修",修补方向高度收敛。

### 盲区

- **回填 10 条质量**:挑战者 2 抽查"均为真判断拐点",但未对全部 10 条逐条验证;若有混入 milestone 级条目反而稀释信息密度,推 P0.9.2 实战观察
- **glassbox 集成**:本次 audit 未审查 glassbox 仓库结构兼容性(空间维度承诺与实际能力对齐),推 P1 真实项目验证

## 5. 判定

### 初判:needs-revision

**理由**:bootstrap 不自洽(本次改动自身 scope=meta,但 M1 无 append 触发 → 落地后自指失败);spec_gap_masking 缺已知缺口段;触发机制结构性错位(用户原则不对应 milestone)

### 修订动作(P0+P1+P2)

**P0(必修 — bootstrap 自洽)**:
- ✅ M1 `meta-finishing-rules.md` Step D 加 append decision-trail 通用同步项,明示 meta 拐点是主要供给源
- ✅ decision file §自动化 段重写为"双路径触发"(M1 + M5 同步加),明示"触发不限于 milestone commit"

**P1(必修 — spec_gap_masking + 结构性错位)**:
- ✅ decision-trail.md 顶部加"已知缺口"段(meta-L4 验证延后 / hook 不校验 / 修剪策略缺失 / 元条目自指 4 条)
- ✅ M5 step 2 + M1 Step D 加"触发不限于 milestone commit"clarifier
- ✅ M5 step 2 加"与 step 9 区别"clarifier(前向链 vs 反向链)

**P2(可修 — 长期治理)**:
- ✅ decision-trail.md 已知缺口段加修剪策略:6 月后旧条目移 `docs/audits/archive/decision-trail/YYYY-HN.md`
- ⏳ skip 阈值监控 / step 8→9 renumber hook 验证 推 P0.9.2 / P0.9.1.5 落地前

### 终判:pass(after revision)

修订后 4 挑战者关切的 P0+P1+P2 已落地。bootstrap 自洽闭合(M1 + M5 双路径触发);已知缺口显式承认;触发机制扩展支持非 milestone 时点。

### 后续

- **meta-L4 验证**:推 P1 真实项目阶段 — 在真实 finishing 中观察 append 频率 / 提取质量 / 调度者忽略率
- **若 P0.9.2 诊断阶段**显示调度者频繁忽略 → 考虑加 hook 校验(P0.9.3 议题)
- **skill_no_cross_project 原则配套**:本次 ROADMAP P2 删除"skill 持久化"是触发,decision-trail 自身设计也遵守该原则(project-local,不跨项目)

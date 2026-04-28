# Roadmap

> **工作哲学**:harness 是**边做边提升**的工具 — 不预设固化的"未来阶段"作为计划。具体做什么由实际需求 / 用户原则确立 / 当前发现拉动。已完成的 P-1 / P0 / P0.5 / P0.9.1 都不是预设的,都是边做边发现下一步。
>
> 依据:`memory/feedback_iterative_progression.md`(2026-04-28 用户原则确立)+ `docs/decisions/2026-04-28-iterative-progression-no-fixed-roadmap-stages.md`

> 与 PROGRESS.md 的区别:PROGRESS.md 是已完成里程碑(只追加),ROADMAP.md 是当前在做 + 已识别下一步(会重写)。
> 与 decisions/ 的区别:decisions 记录"为什么这么决定 + 替代方案",ROADMAP 记录"当前在做什么"。scope 级变更先写 decision 再改 ROADMAP。

---

## 已完成阶段(概要,详情推 PROGRESS / decisions/)

- **P-1**:Handoff residual 字段清晰化(独立小改)
- **P0**:测试覆盖纳入 harness(L1 + L2 + L3 串行;L4 不做 — 见 `decisions/2026-04-15-testing-scope-expansion.md`)
- **P0.5**:fork 嵌套扁平化改造(P1 验证暴露的应急前置 — 见 `decisions/2026-04-16-fork-flat-refactor.md`)
- **P0.9.1**:meta-review 流程 + scope 识别 + hook 执法(2026-04-28 — 见 `PROGRESS.md` + `meta-review-2026-04-28-102359-p0-9-1-self-review.md`)

---

## 当前在做

### P0.9:harness self-governance(根源级)

**背景**:2026-04-17 起草 5 条治理修改 M0-M4 时识别 harness 反复打补丁的根源 — 三条结构性缺陷(治理文本缺执法层 / bootstrap 缺陷 / 马鞍定位错位)。详见 `docs/decisions/2026-04-17-harness-self-governance-gap.md`。

**已完成**:
- 🟢 **P0.9.1**(2026-04-28):meta-review 流程 + scope 识别 + hook 执法。29 commits。audit verdict=pass after revision。

**已识别下一步**(由 P0.9.1 落地暴露,非预设):

- **P0.9.1.5 — M0-M4 启动**:用户决定型(D20 fix-7 = B);P0.9.1 治理流程的首批使用(无机械触发条件,等用户启动 M0 删 block-dangerous 等)
- **P0.9.2 — 诊断流程**:实战观察期累积数据后启动
  - 反审字段重置 enforcement(C2 P-4)
  - D5 / D.2 字节软上限 enforcement(C2 P-3)
  - mixed scope 双 finishing 成本量化
  - decision-trail meta-L4 验证(append 频率 / 提取质量 / 调度者忽略率)
- **P0.9.3 — governance 漂移检测兜底**:
  - M3 hook 不可见缺口(spec §1.3 fix-9 (vii))
  - 现有 fix-9 (i)(ii)(iv)(vi)
  - decision-trail hook 校验(若 P0.9.2 显示频繁忽略)

### P2:可观测性 — 双层(2026-04-28 立 + 同日 reframe glassbox 角色)

让 harness 治理过程可见、可审计、可回溯。**空间 + 时间双层**,两层归属不同:

**空间维度(session 内)— glassbox(用户级外部工具,harness 推荐不分发)**
- 现状:外部仓库 https://github.com/chaofanliu928-byte/glassbox(7 类 HTML 页面 + lint 工具)
- **harness 角色**:仅推荐 + 链接记录(`docs/references/recommended-tools.md`)+ setup.sh 末尾 echo 提示;**不**做 submodule / 不 clone / 不锁版本 / 不集成 API
- **用户角色**:自行决定装哪、装啥版本、装在哪(建议 `~/tools/glassbox/` 等全局位置)
- **harness 治理流程不依赖 glassbox 在场**(不装也能正常工作)
- decision:`docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md`

**时间维度(跨 session)— decision-trail(项目内置)**
- 已落地:`docs/decision-trail.md`(2026-04-28 引入)
- 自动化:M5 + M1 双路径 finishing 时 append
- decision:`docs/decisions/2026-04-28-decision-trail-introduction.md`

**当前状态**:已落地基础形态,边用边迭代。后续提升由实际使用反馈拉动,不预设。

---

## ROADMAP 自身的生命周期(元规则)

- **完成的 P 项** → 概要保留 + 详情推 `PROGRESS.md`(只追加)
- **决策记录** → 存在 `docs/decisions/`(不和 ROADMAP 混写)
- **ROADMAP 自身保持滚动**:scope 级变更**先写 decision 再改 ROADMAP**,不得反向
- **不预设未实现的"未来阶段"**:不写"P1 真实项目迁移"/"L4 回归层"/"测试 surface 扩张"等(违反"边做边提升"原则);具体动作由"做的过程"暴露后再加

---

## 与 Superpowers 的耦合边界(事实层,不是计划)

- L1 tests 档位的实际执行依赖 `superpowers:test-driven-development`
- L2 治理规则与 Superpowers TDD 流程互补,不替代
- **耦合风险**:Superpowers 升级若改 TDD skill 接口,L1 判定可能失效;若出现不兼容,短期 fallback 是 evaluator 手动判断不依赖 Superpowers 接口

## 术语与定义归属(事实层)

- Evidence Depth L1-L4 + CI 阻断 语义在 `docs/references/testing-standard.md` 中定义(**术语 SSoT**)
- 其他引用该术语的文件(RUBRIC / finishing-rules / handoff 模板 / evaluator 提示词)**只引用不重复定义**
- 术语变更必须先改 testing-standard.md,再同步下游(F3 文档先行)

# Finishing 阶段治理规则
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->

> 当 Superpowers 的 finishing-a-development-branch skill 激活时,读取本文件。
> 以下步骤在 Superpowers 的合并/PR/清理**之前**执行。
> **治理同层**(2026-06-13):本文件是唯一收口流程,不分流不分轨(原 meta-finishing-rules(M1)已并入)。
> 改动命中凭证义务(`.claude/hooks/credentials.conf` glob)时多走一节「凭证义务核对」,其余步骤(含「方向评估」,治理批照走)全员同一条路。

> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入) — 涉及阶段:evaluate / process-audit / security-scan / 治理审查。

## 反模式约束(用户 feedback 硬编码 — 必读)

> 依据:`memory/MEMORY.md` 索引下的 feedback 条目。

- **实战验证不阻塞 harness 开发**(`feedback_realworld_testing_in_other_projects.md`):finishing 阶段评估"是否完成"时,**不**把"等实战数据"当 blocking 条件。涉及实战留痕 / 真实场景验证 / 治理改动 L4(credentials-rules §7)项推 P1 真实项目阶段;handoff 中明确 documented 推后,本阶段不为补 artificial 数据停留。
- **handoff 写入断言前必须 verification-before-completion**(2026-04-28 process-audit P-2 + N2 事件 5 实证):若 handoff 含"下次 SessionStart hook 自动注入 X"/"下次 session 会自动 Y"等断言,**必须先用 superpowers:verification-before-completion skill 验证**(实际 hook 是否注册 / 文件是否就位等),不得先写断言再口头说"应该会"。
- **不得主动提"简化收尾"二元方案**(2026-04-17 retrospective P0 报告 §"规则摩擦点"#1):agent 读本文件后,**不得**框出"A 严格 / B 简化"让用户选,**不得**给倾向性推荐"简化收尾"。
  - 唯一允许的降级路径:**fork-fail-degradation** — security-scan / evaluate / process-audit / 凭证义务核对 任一 fork 失败 → 调度者按对应 agent.md 自审,标 `⚠️ 降级执行,未经独立 agent 验证`(本文件 §安全扫描 第 4 项 / §方向评估 第 9 项 / §流程审计 第 14 项 / §凭证义务核对 step 18 已有此约定)
  - 不允许的:**rule-bypass** — agent 觉得"重"主动跳过完整流程。若用户明确指示跳过,需写 `docs/decisions/<date>-skip-finishing-<reason>.md` 立档
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)
  - **防滑条款**(2026-04-29 meta-review D2-F1):agent **不得在未实际发起 fork 调用前**就声称 fork 失败。若 fork 调用未发出,跳过理由须在 decision 中写明"未尝试 + 原因",不适用 fork-fail 降级路径
- **RUBRIC 维度不得作跳过治理 step 的依据**(2026-04-17 retrospective P0 报告 §"完全没预料到的模式"#2 "spec §0 偏离说明成 bypass 载体"):
  - RUBRIC.md 是**评分标准**(产出衡量),**不**是 process 选取标准。**澄清**(2026-04-29 meta-review D3-F8):RUBRIC 仍是 evaluator agent 的评分依据(evaluate skill 正当引用);本约束仅限于"用 RUBRIC 维度推导是否跳过某治理 step"的决策语境
  - 禁止句式:"因 RUBRIC 简洁性权重 23%,本 spec 不需要 design-review" / "RUBRIC 没有 X 维度,所以跳过 X step"(以及任何**以 RUBRIC 评分维度推导 process 路径的变体句式**)
  - 评分维度 ≠ 流程豁免;治理流程的跳过依据由 governance/*.md 自身定义(如 design-rules.md "轻量级"判定),**不**引 RUBRIC
  - **跨阶段同步约束**(2026-04-29 meta-review D2-F3):本条款也适用于 **design 阶段** spec §0 写法;designer agent 在写 spec §0 偏离说明时同步遵守(见 `design-rules.md` `## spec §0 偏离规则`)。M2 是 finishing 阶段的**反向回顾性**约束,M4(design-rules.md spec §0 偏离规则段)是 design 阶段的**正向阻断性**约束,两者协同

## 安全扫描

>(治理批暂不纳入,见「凭证义务核对」节治理批收口工序适用——decision 2026-06-13 追记三)

1. 运行 `/security-scan`（fork security-reviewer agent team）
2. **等待安全扫描结果出来后再继续**
3. Critical 发现 → **必须修复后才能继续**；High/Medium 列出供参考
4. 如果 security-scan fork 失败 → 调度者按 security-reviewer.md 的检测模式自行扫描（降级），在结果中标注 `⚠️ 降级执行，未经独立 agent 验证`

## Evidence Depth 声明（方向评估之前）

5. 在 `docs/active/handoff.md` 中填写 `## Evidence Depth` 和 `## CI 阻断` 两个字段
   - 格式规则见 `docs/references/testing-standard.md`
   - 四层逐行列出,每层 ✅/❌/⚠️ + 证据引用
   - CI 阻断独立标 ✅/❌
   - **hook 会检查字段非空,为空则阻断 finishing**
6. 对照 `docs/governance/testing-rules.md` 的决策表,自检:本次变更的 Evidence Depth 是否满足最低要求?不满足 → 回到 implementation 补测试,不要带着缺口进 evaluate

## 收口硬核链（方向评估之前 — 仅当 docs/context/ 存在）

> 软收尾(`check-context-chain.sh` Stop hook)平时只早提醒、放行;**这一步是硬收口**。
> 一个功能算"做完",活上下文链必须通、方向合法、`待定` 该补的补上。
> **由你(调度者)按本节当场核**,核完在 `docs/active/handoff.md` 写一句声明(hook 机械逼显式声明,不解析对错):
> `## context-chain: 已核(<一句结论>)` 或 `## context-chain: skipped(理由: <非空>)`。
> 无声明 → `check-context-chain.sh` 在收口(evaluation-result.md 存在)时 exit 2 阻断。括号必须半角。

若本功能在 `docs/context/` 留了链(整条没用 context 链则写 skipped 跳过):

- **链必通**:从本功能最高层文件顺 `upstream` 编码逐跳上溯,每跳目标编码必须在 `docs/context/` 实际存在(含拆出的 L2-F<n> 文件)。断到不存在的编码 = 静默断链,**当场修**(repoint 或标 `待定`)。
- **方向合法**:每个 upstream 编码层号严格高于本文件层号(L6→L5→L4→L3→L2→L1)。低层定义高层 = 方向反,**回退到该问题应解决的层修**(见回退规则),不在下层打补丁。
- **待定补齐**:扫链上所有 `upstream: [待定]`,收口时本就在定稿,该定的定;仍要保留的写一句为什么还待定。
- **上游改→下游对齐**:本批若改过任一上游(L1-L3)文件,确认挂在其下的所有下游已 repoint 或标待定,不留孤儿。

> 软/硬协同:平时软提醒让你别忘;收口这道是真闸。软 hook 即便降级(jq/awk 缺失)也只丢提醒,真保证在本节 + handoff 声明。

## 方向评估

7. **确认 `docs/active/security-scan-result.md` 存在且无 Critical** 后，运行 evaluate
8. evaluate skill 自动触发（`invocation: auto`），fork evaluator agent team
9. 如果 evaluator fork 失败 → 调度者按 evaluator.md 的评分维度自行评估（降级），在结果中标注 `⚠️ 降级执行，未经独立 agent 验证`

## 流程审计

>(治理批暂不纳入,见「凭证义务核对」节治理批收口工序适用——decision 2026-06-13 追记三)

10. **确认 evaluate 已完成后**，运行 `/process-audit`（structured-handoff 在分流路径中执行，不作为前置条件）
11. process-audit skill 自动触发（`invocation: auto`），fork process-auditor agent
12. 审计结果写入 `docs/audits/audit-YYYY-MM-DD-HHMMSS.md`
13. **审计结果不影响分流判断**——无论审计发现什么，都按 evaluate 结果分流
14. 如果 process-auditor fork 失败 → 调度者标注 `⚠️ 降级执行，未经独立 agent 验证`，继续分流，不阻断

## 凭证义务核对(改动命中 credentials.conf 时)

> 凭证制度全文(audit 文法 / exempt 豁免 / 失效规则 / 对账)住 `docs/governance/credentials-rules.md`,本节只给收口时刻的动作序,不重复文法。

15. 对照 `.claude/hooks/credentials.conf`(凭证要求表机器版)核对本批改动:任一文件命中 include glob → 本批负有 audit 凭证义务
16. 凭证义务的履行(二选一,均产凭证文件,无第三条路):
    - **对抗审查 audit**:按 `docs/governance/review-rules.md`「审查维度选择表」治理行 fork N 个挑战者审查本批改动 → 产 `docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md`(文法见 credentials-rules §3;covers 列出本批全部命中文件)
    - **exempt 微 audit**(仅限 typo / 链接 / 注释等无语义变更):按 credentials-rules §4 文法产微 audit(`verdict: exempt` + 一行理由)
17. verdict 处置:`needs-revision` → 按 audit 所列问题修改后重审(可产新 audit);`overturn` → 撤回本批改动,记录到 ROADMAP / handoff,不进分流
18. fork 失败降级:沿「反模式约束」fork-fail-degradation 条款 — 调度者按 review-rules 维度自审,audit 标 `⚠️ 降级执行,独立性未达`

**治理批收口工序适用**(2026-06-13 decision 追记三,用户拍板):
- 凭证审查:按本节 step 15-18(命中 credentials.conf 即负义务)。
- **方向评估 = 全批适用,含治理批**(用户原话:"方向评估重要")。分工:治理审查核"这批合规达标"(以 decision/spec 为前提),方向评估问"方向本身对不对/该不该推翻"(连前提一起审)——verdict 三路同构但站位不同,非重复。
- **安全扫描与流程审计 = 维持 feature 侧,治理批暂不纳入**(用户原话:"其他的我觉得可以暂时不用担心了";连带风险登记 ROADMAP 观察项)。

### 触点漂移检测(凭证批 audit 内机械预检)

> 仅当**本批命中 `credentials.conf`(收口须产 audit)**时执行——在该凭证批的 audit 内,drift-scout 作触点完整性的**机械预检自动跑**(不依赖审查者是否选了「触点完整性维」;人工触点完整性维保持 review-rules 条件必选作互补深审,机械预检 + 人工深审双层,不互斥)。**非凭证批 → 不 fork**(注册表 13 触点端点多落 governance/config 凭证-hit 文件,非凭证批罕碰触点端点,真漏由人工触点维终兜)。门控理由详 spec `docs/superpowers/specs/2026-06-16-drift-detection-design.md` §4.2 注。

19. **需 agent 运行时** → 调度者 fork `drift-scout`(契约 `.claude/agents/drift-scout.md`),注入 `{registryPointer: docs/governance/touchpoint-registry.md, scope: all, repoRoot, today, credentialsConf, rulesPointer}` → scout 读注册表、逐触点读两端点、按判据判 → 返回报告(每触点 ✅一致 / 🔴漂移[附差异指针] / ⚠️不确定;报告分层:🔴 突出逐条 / ✅ 折叠计数)。
20. 消费报告:**🔴** 当场修或登记;**⚠️** 并入治理审查触点完整性维人核;据报告**手工回填**注册表现状列(`待③b查` → `✅一致`/`🔴漂移`;scout 只读不写,回填由调度者手工 — spec §7 D4)。
21. **软、不阻断**:**无 agent 运行时 / fork 失败** → 软提醒"本会话漂移检测未执行" + **回落人工触点完整性维**(治理审查那个维本就在查),不阻断收口、不算欠账(诚实降级,同 freshness-scout)。

### decision 立档(若有架构决策)

**调度者动作**:

- 治理面改动若涉及架构决策(如新增 / 修改一条 governance 规则 / 改 spec 边界 / 引入新 hook 等),**必做** decision 立档
- 若治理面改动仅是工程调整(如 hook 文件内重构、注释润色)且无架构决策,可不立档,但需在 handoff 或 PROGRESS 内简记
- decision 文件位置:`docs/decisions/<YYYY-MM-DD>-<主题>.md`

**模板范式选择**:

| 决策类型 | 范式 | 模板使用 |
|---|---|---|
| 普通方案选择型(A/B/C 比较) | `docs/references/decision-template.md`(若有) | 标准 "问题 / 方案 A/B / 决定 / 后续" 节 |
| **根源承认型** | **`docs/decisions/2026-04-17-harness-self-governance-gap.md` 范式**(D9) | 加 **"Bootstrap 声明"** 节 + **"不做"** 节防 scope 扩散 |

**D9 范式应用规则**(spec §7.1 D9):

- 当治理面改动是"承认存在性问题 / 系统缺口 / bootstrap 限制"等无 A/B 可选的单选择型 decision → 采用 D9 范式
- 文件头部加 **"Bootstrap 声明"** 节:声明本 decision 是 ad-hoc bootstrap 动作,后续治理规范不应追溯性要求其通过流程
- 文件头部加类型标记:**"根源承认型"**(替代标准的"方案选择型"标记)
- 加 **"不做(防 scope 扩散)"** 节:明示本 decision 不解决 / 不推翻 / 不定义的内容
- 加 **"突破模板骨架的说明"** 节:说明为何本次不沿用标准模板

**范式参考文件**:`docs/decisions/2026-04-17-harness-self-governance-gap.md`

**错误处理**:

- decision 立档完成后发现本次改动破坏了现有 decision → 新建 superseding decision(覆盖型),旧 decision 标 🔴 已废弃 + 在新 decision 头部 "关联" 节链回旧 decision

---

## 根据评估结果分流

### 通过

1. 创建 milestone commit：`milestone: [功能名称] 验收通过`
2. **append decision-trail**:从本次 commit 涉及的 `docs/decisions/` 与 `docs/audits/` 提取 1-2 条**判断拐点**,append 到 `docs/decision-trail.md`(时间倒序,最新在上)
    - **抉择 = 判断拐点**:架构选择 / 用户原则确立 / 缺口承认 / 替代方案否决
    - **不写**:任务进度(归 PROGRESS) / 技术细节(归 decisions/ 单 file) / 用户偏好(归 memory)
    - **link**:有 decisions/ 文件必须链;无 file 标"暂无 + 原因"
    - **跳过**:本次 commit 无架构 / 原则级抉择 → 跳过 append,commit message 简记即可
    - **触发不限于 milestone commit**:用户原则确立 / 缺口承认 等关键时点不在 milestone 时,调度者也应即时 append(不必等到下次 finishing)
    - **与 step 8 区别**:step 8 是 decisions/ 文件标 commit hash(反向链);本步是 commit 提取抉择 append(前向链)。两者不冲突
    - **依据**:`docs/decisions/2026-04-28-decision-trail-introduction.md`
3. 更新 `docs/PROGRESS.md` 里程碑表格
4. 更新 `docs/product-specs/index.md` 状态为 🟢 已完成
5. 运行 `/structured-handoff`（归档旧版本到 `docs/completed/`;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）
6. Superpowers 继续合并/PR/清理
7. 合并后归档：
    - `docs/active/evaluation-result.md` → `docs/completed/eval-[功能名]-[日期].md`
    - 设计文档 → 在顶部标注 `> ARCHIVED [日期] — 功能已合并，本文档仅供历史参考`
    - `docs/active/security-scan-result.md` → 删除（一次性结果）
8. 检查 `docs/decisions/` 中与本功能相关的决策文件，已决定的标注关联 commit hash
9. 更新 `docs/ROADMAP.md`:本批状态/进展行推进(原 M1 Step D 独有义务并入)
10. 结构性变化(角色/流程/凭证制度类)同步 `memory/project_harness_overview.md`(原 M1 Step D 独有义务并入)

### 精磨

1. 运行 `/structured-handoff`（记录进度和评估器指出的问题;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）
2. 阅读 `docs/active/evaluation-result.md` 中"需要修复的问题"
3. **检查设计文档是否仍与代码一致**：对比设计文档第 2 节（模块划分）和第 3 节（接口定义）与当前代码。如果已偏离，先更新设计文档再继续迭代
4. 返回 subagent-driven-development 阶段迭代
5. 迭代完成后重新进入 finishing

### 推翻

1. 运行 `/structured-handoff`（记录状态和推翻原因;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）
2. **停下来和用户讨论**，不自行决定
3. 如果用户决定**调整方向**：重新从 brainstorming 开始
4. 如果用户决定**取消功能**：
    - 设计文档顶部标注 `> CANCELLED [日期] — 用户决定不做此功能`
    - 更新 `docs/product-specs/index.md` 状态为 ❌ 已取消
    - 相关 `docs/decisions/` 文件标记为 🔴 已废弃

---

## 上下文管理

对话变长或表现下降时，建议用户 `/structured-handoff` + `/clear`

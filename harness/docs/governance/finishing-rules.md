## scope 分流入口（进入 finishing 时第一步）

> **harness 自身仓库**：本段触发分流；改动若 scope=meta 或 mixed，**不**走本文件，改读 `meta-finishing-rules.md`（M1）。
>
> **下游目标项目**：本段保留但 meta 分支不会触达（下游无 meta scope 改动 / meta-finishing-rules.md 由分发过滤自然不存在），feature 路径继续走本文件流程。

### 步骤

1. 识别本次改动 scope（参考仓库根 `/CLAUDE.md`（M3）的 scope 触发判定段落 + `.claude/hooks/meta-scope.conf` 配置）
   - 命中 A/B/C/D/F 任一组 glob → scope=meta
   - 部分命中 + 部分未命中 → scope=mixed
   - 完全未命中 → scope=feature 或 none
2. 按 scope 分流：
   - **scope=meta 或 mixed** → 走 `docs/governance/meta-finishing-rules.md`（M1）— **本文件后续内容不适用**
   - **scope=feature 或 none** → 继续本文件后续内容（feature 侧 finishing 流程）

---

# Finishing 阶段治理规则

> 当 Superpowers 的 finishing-a-development-branch skill 激活时，读取本文件。
> 以下步骤在 Superpowers 的合并/PR/清理**之前**执行。

## 反模式约束(用户 feedback 硬编码 — 必读)

> 依据:`memory/MEMORY.md` 索引下的 feedback 条目。

- **实战验证不阻塞 harness 开发**(`feedback_realworld_testing_in_other_projects.md`):finishing 阶段评估"是否完成"时,**不**把"等实战数据"当 blocking 条件。涉及实战留痕 / 真实场景验证 / meta-L4 项推 P1 真实项目阶段;handoff 中明确 documented 推后,本阶段不为补 artificial 数据停留。
- **handoff 写入断言前必须 verification-before-completion**(2026-04-28 process-audit P-2 + N2 事件 5 实证):若 handoff 含"下次 SessionStart hook 自动注入 X"/"下次 session 会自动 Y"等断言,**必须先用 superpowers:verification-before-completion skill 验证**(实际 hook 是否注册 / 文件是否就位等),不得先写断言再口头说"应该会"。
- **不得主动提"简化收尾"二元方案**(2026-04-17 retrospective P0 报告 §"规则摩擦点"#1):agent 读本文件后,**不得**框出"A 严格 / B 简化"让用户选,**不得**给倾向性推荐"简化收尾"。
  - 唯一允许的降级路径:**fork-fail-degradation** — security-scan / evaluate / process-audit 任一 fork 失败 → 调度者按对应 agent.md 自审,标 `⚠️ 降级执行,未经独立 agent 验证`(本文件 §安全扫描 第 4 项 / §方向评估 第 9 项 / §流程审计 第 14 项 已有此约定)
  - 不允许的:**rule-bypass** — agent 觉得"重"主动跳过完整流程。若用户明确指示跳过,需写 `docs/decisions/<date>-skip-finishing-<reason>.md` 立档
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)
  - **防滑条款**(2026-04-29 meta-review D2-F1):agent **不得在未实际发起 fork 调用前**就声称 fork 失败。若 fork 调用未发出,跳过理由须在 decision 中写明"未尝试 + 原因",不适用 fork-fail 降级路径
- **RUBRIC 维度不得作跳过治理 step 的依据**(2026-04-17 retrospective P0 报告 §"完全没预料到的模式"#2 "spec §0 偏离说明成 bypass 载体"):
  - RUBRIC.md 是**评分标准**(产出衡量),**不**是 process 选取标准。**澄清**(2026-04-29 meta-review D3-F8):RUBRIC 仍是 evaluator agent 的评分依据(evaluate skill 正当引用);本约束仅限于"用 RUBRIC 维度推导是否跳过某治理 step"的决策语境
  - 禁止句式:"因 RUBRIC 简洁性权重 23%,本 spec 不需要 design-review" / "RUBRIC 没有 X 维度,所以跳过 X step"(以及任何**以 RUBRIC 评分维度推导 process 路径的变体句式**)
  - 评分维度 ≠ 流程豁免;治理流程的跳过依据由 governance/*.md 自身定义(如 design-rules.md "轻量级"判定),**不**引 RUBRIC
  - **跨阶段同步约束**(2026-04-29 meta-review D2-F3):本条款也适用于 **design 阶段** spec §0 写法;designer agent 在写 spec §0 偏离说明时同步遵守(见 `design-rules.md` `## spec §0 偏离规则`)。M2 是 finishing 阶段的**反向回顾性**约束,M4(design-rules.md spec §0 偏离规则段)是 design 阶段的**正向阻断性**约束,两者协同

## 安全扫描

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

## 方向评估

7. **确认 `docs/active/security-scan-result.md` 存在且无 Critical** 后，运行 evaluate
8. evaluate skill 自动触发（`invocation: auto`），fork evaluator agent team
9. 如果 evaluator fork 失败 → 调度者按 evaluator.md 的评分维度自行评估（降级），在结果中标注 `⚠️ 降级执行，未经独立 agent 验证`

## 流程审计

10. **确认 evaluate 已完成后**，运行 `/process-audit`（structured-handoff 在分流路径中执行，不作为前置条件）
11. process-audit skill 自动触发（`invocation: auto`），fork process-auditor agent
12. 审计结果写入 `docs/audits/audit-YYYY-MM-DD-HHMMSS.md`
13. **审计结果不影响分流判断**——无论审计发现什么，都按 evaluate 结果分流
14. 如果 process-auditor fork 失败 → 调度者标注 `⚠️ 降级执行，未经独立 agent 验证`，继续分流，不阻断

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
    - **与 step 9 区别**:step 9 是 decisions/ 文件标 commit hash(反向链);本步是 commit 提取抉择 append(前向链)。两者不冲突
    - **依据**:`docs/decisions/2026-04-28-decision-trail-introduction.md`(meta scope 改动同步走 M1 `meta-finishing-rules.md` Step D 的对应项)
3. 更新 `docs/PROGRESS.md` 里程碑表格
4. 更新 `docs/product-specs/index.md` 状态为 🟢 已完成
5. 运行 `/skill-extract`（不强求，无模式时跳过）
6. 运行 `/structured-handoff`（归档旧版本到 `docs/completed/`）
7. Superpowers 继续合并/PR/清理
8. 合并后归档：
    - `docs/active/evaluation-result.md` → `docs/completed/eval-[功能名]-[日期].md`
    - 设计文档 → 在顶部标注 `> ARCHIVED [日期] — 功能已合并，本文档仅供历史参考`
    - `docs/active/security-scan-result.md` → 删除（一次性结果）
9. 检查 `docs/decisions/` 中与本功能相关的决策文件，已决定的标注关联 commit hash

### 精磨

1. 运行 `/structured-handoff`（记录进度和评估器指出的问题）
2. 阅读 `docs/active/evaluation-result.md` 中"需要修复的问题"
3. **检查设计文档是否仍与代码一致**：对比设计文档第 2 节（模块划分）和第 3 节（接口定义）与当前代码。如果已偏离，先更新设计文档再继续迭代
4. 返回 subagent-driven-development 阶段迭代
5. 迭代完成后重新进入 finishing

### 推翻

1. 运行 `/structured-handoff`（记录状态和推翻原因）
2. **停下来和用户讨论**，不自行决定
3. 如果用户决定**调整方向**：重新从 brainstorming 开始
4. 如果用户决定**取消功能**：
    - 设计文档顶部标注 `> CANCELLED [日期] — 用户决定不做此功能`
    - 更新 `docs/product-specs/index.md` 状态为 ❌ 已取消
    - 相关 `docs/decisions/` 文件标记为 🔴 已废弃

---

## 上下文管理

对话变长或表现下降时，建议用户 `/structured-handoff` + `/clear`

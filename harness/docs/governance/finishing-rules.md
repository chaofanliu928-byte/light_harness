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
2. 更新 `docs/PROGRESS.md` 里程碑表格
3. 更新 `docs/product-specs/index.md` 状态为 🟢 已完成
4. 运行 `/skill-extract`（不强求，无模式时跳过）
5. 运行 `/structured-handoff`（归档旧版本到 `docs/completed/`）
6. Superpowers 继续合并/PR/清理
7. 合并后归档：
    - `docs/active/evaluation-result.md` → `docs/completed/eval-[功能名]-[日期].md`
    - 设计文档 → 在顶部标注 `> ARCHIVED [日期] — 功能已合并，本文档仅供历史参考`
    - `docs/active/security-scan-result.md` → 删除（一次性结果）
8. 检查 `docs/decisions/` 中与本功能相关的决策文件，已决定的标注关联 commit hash

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

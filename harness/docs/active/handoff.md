# 工作交接文档

> 只保留当前状态，给"下一个 AI"看。SessionStart hook 自动注入。
> 详细见 docs/PROGRESS.md / docs/decisions/ / docs/ROADMAP.md。

更新时间：2026-04-17

## 目标

承接 decision `2026-04-17-harness-self-governance-gap.md`：harness 自身改动暂停，下一阶段聚焦 **P0.9 self-governance brainstorming**。

## 进度

### 本会话已完成
- 接收目标项目老版本审查报告（`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`）
- 起草 M0-M4（5 条治理改动）→ 4 挑战者扁平 fork 元审查 → 31 条发现
- 用户追问识别根源三条 → 立 decision `2026-04-17-harness-self-governance-gap.md`
- ROADMAP 加 P0.9 节，M0-M4 推迟为其首个使用批次

### 阻塞
P1 阻塞于 P0.9 就绪。

## 关键决策
- `decisions/2026-04-15-testing-scope-expansion.md`
- `decisions/2026-04-16-fork-flat-refactor.md`
- **`decisions/2026-04-17-harness-self-governance-gap.md`**（本会话产出，根源承认 + P0.9 启动）

## 涉及文件
- 新建 `docs/decisions/2026-04-17-harness-self-governance-gap.md`
- 改 `docs/ROADMAP.md`（加 P0.9 + 排期逻辑 + 顶部 2026-04-17 重排）
- 重写 `docs/active/handoff.md`（本文件）
- 待改 memory `project_harness_overview.md`（当前状态加根源三条）

## 下一步

1. **下一会话启动 P0.9 brainstorming**——收敛 self-governance 的具体需求和验收
2. **不做**：M0-M4 任一条治理规则改动（已推迟）
3. **不做**：在 P0.9 没规范时继续 ad-hoc 修补 harness（这是根源 2 反模式）
4. **可复用**：本会话 4 挑战者审查记录 + 用户已确认的判断（block-dangerous 拟删 / bypass 模式放弃 / 简洁性维度待重审）

## 研究发现

### 根源三条（详见 decision）
1. 治理文本，缺执法层（硬 hook 仅覆盖"字段非空"和"format"）
2. bootstrap 缺陷（meta 层无治理）
3. 马鞍定位错位（稳定性标准比 feature 还松，反了）

### 用户已确认的判断（待 P0.9 落实）
- block-dangerous 拟删除（理由：harness 是治理框架不是安全沙箱；删时补 decision）
- bypass decision 模式放弃，finishing 不允许"用户主动跳过"通道
- 简洁性维度从 RUBRIC 降级为 CLAUDE.md 行为准则（待 decision）

### meta finishing 与 feature finishing 关键差异
- 评估视角：feature 外部 ✅；meta 循环（评估者=被评估者）❌
- RUBRIC evaluate：feature ✅；meta 改 RUBRIC 时无法用 RUBRIC 评 ❌
- 完成边界：feature 有 milestone；meta 无自然边界

### 元教训
本会话调度者两次踩"用便利答案掩盖规范缺口"的坑（"统一更新一次" / 路径 1/2/3 假设有收尾方式），证明 rule-negotiation 不是 agent 道德问题，是规范缺口 + 便利偏向的必然产物。P0.9 设计需特别警惕此模式。

## 当前阶段
**阶段切换**：从"等目标项目审查" → "根源 decision 已立，待 P0.9 brainstorming"。

## 当前分支
`main`，与 origin/main 一致（10 提交已推送）。本会话 decision + ROADMAP + handoff 改动尚未 commit。

## 已知问题 / Residual

> 包含 4 类：bug / 故意暂缓的优化 / 待外部决策 / 测试或文档缺口。

- **故意暂缓**：M0-M4 推迟到 P0.9 就绪后；P1 阻塞于 P0.9；P2 三项保持
- **测试文档缺口**：harness 自身仍未走完整 finishing 闭环（self-dogfood）—— 已上升为根源 2/3
- **bootstrap 自承认**：本 decision 是 ad-hoc 动作，写在 self-governance 建立之前，不可避免

## Evidence Depth + CI
> 格式见 `docs/references/testing-standard.md`。

- L1 单测 ❌ 不适用 / L2 冒烟 ⚠️ 部分（文档交叉引用核查完成）/ L3 ❌ 不适用 / L4 ❌ 不适用
- CI 阻断 ❌ harness 仓库未配 CI

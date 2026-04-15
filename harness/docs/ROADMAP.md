# Roadmap

下一阶段的工作方向。每项都是开放方向，具体需求和验收标准待进一步 brainstorming 收敛。

> 与 PROGRESS.md 的区别：PROGRESS.md 是已完成里程碑（只追加），ROADMAP.md 是未完成规划（会重写）。

## 1. 可观测性

让 harness 的治理过程可见、可审计、可回溯。

- 待定：可观测的对象 —— agent team 内部决策过程？fork 执行历史？RUBRIC 演变轨迹？audit 趋势？
- 待定：呈现形式 —— CLI 命令？静态报告？hook 输出？
- 验收信号：能回答"上一次 design-review 为什么打这个分""这条 skill 最初是哪次会话提炼的"
- 预期涉及：可能新增 hook / skill / references 文档，不一定需要新 agent

## 2. 现有项目迁移到 harness

把已有的真实项目套上 harness，跑一遍完整流程作为首次真实验证。

- 待定：目标项目
- 验收信号：完整跑通一个功能的 brainstorming → design → plan → implement → finishing 闭环，process-audit 产出报告
- 预期产出：迁移过程中暴露的不适配点，回流成 harness 的改进条目（反哺 1 和 3）
- 注意：这是使用 harness 的任务，不是框架内部改动。但暴露的问题会驱动框架改动。

## 3. 重复工作 skill 化持久化

把 harness 执行过程中反复出现的手动步骤自动归纳为 skill，并跨项目复用。

- 现状：已有 `skill-extract`，但产出落在当前项目的 `.claude/skills/`，不跨项目
- 待定：持久化的载体 —— 用户级 skill 目录？framework 侧的可选 skill 池？
- 待定：触发条件 —— 人工标记？模式识别？execute/audit 的回顾中自动提议？
- 验收信号：一次开发中识别出的可复用模式，下一次/下一个项目中自动可用
- 预期涉及：`skill-extract` 的增强或新增一个上游归纳环节

## 排期

优先级待定。2 能给 1 和 3 提供真实素材，所以先做 2 可能更经济；但如果 1 的基础设施缺失导致 2 执行时盲飞，也可能先补 1。brainstorming 时再定。

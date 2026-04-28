# 边做边提升 — ROADMAP 不预设固化"未来阶段"

**类型**:用户原则确立 + 治理调整(D9 范式 — 根源承认型)
**日期**:2026-04-28
**触发**:用户(2026-04-28)指示"将迁移和测试都移除计划中,我们这个是边做边提升的"
**关联**:
- memory `feedback_iterative_progression.md`(同日确立)
- 上游 decision:`2026-04-15-testing-scope-expansion.md`(P0 测试 — 完成,不再预设增强)
- 上游 decision:`2026-04-17-harness-self-governance-gap.md`(P0.9 加塞 — 验证了"边做边提升"模式)

---

## Bootstrap 声明

本 decision 是用户原则确立 + ROADMAP 治理调整,后续治理规范不应追溯性要求其经过完整 brainstorming → design → meta-review 流程(原则性 + 文档级 cleanup,scope=none)。

## 问题

ROADMAP 当前包含多个**预设的"未来阶段"**:
- **P1**:现有项目迁移到 harness — 假设"未来必须有迁移阶段"
- **P2 L4 回归层**:条件启用,等多 surface 出现 — 假设"将来会有"
- **建议不做**段:含 4 项远期可能反案
- **排期逻辑**:大段假设各 P 之间的依赖关系,前提是这些 P 都会发生
- 测试相关:P0 已完成,但 ROADMAP 仍列"测试 surface 扩张" / "L4 回归"等增强方向

用户指出:这些"未来阶段"等于把未来需求**假装当成已知**;实际真正方向由"做的过程"暴露 — **不该提前固化**。

事实证据:
- P-1 / P0 / P0.5 都不是预设的(P0.5 是 P1 验证暴露的;P0.9 是 P0+P1 想用时暴露的根源缺口)
- 已完成的 P 项 中,没有一项是"按预设计划走完"的 — 都是边做边发现 + 边迭代

## 决定

ROADMAP **简化** — 只保留:
- **当前正在做**(P0.9 系列,已展开;P2 可观测性,已展开)
- **已识别的具体下一步**(P0.9.1.5 / P0.9.2 / P0.9.3 — 这些由 P0.9.1 落地暴露,非预设)
- 元规则(本文件作用 / 与 PROGRESS / decisions/ 的关系)
- 工作哲学声明:"边做边提升,不预设大计划"

ROADMAP **删除**:
- P1 真实项目迁移整段(line 169-181)
- P2 L4 回归层(line 205-210)
- "建议不做"段中纯远期反案(双轨 SSoT / Phase 11 Audit / Task-Type Matrix / Planning 三件套 — 这些都是预设未来的反案)
- 排期逻辑大段(替换为简短"边做边提升"声明)
- 与 Superpowers 耦合 + 术语归属(保留 — 这些是事实约束 / 文档归属,不是计划)

ROADMAP **不删**:
- P0.9 系列(P0.9.1 完成,P0.9.1.5 / P0.9.2 / P0.9.3 由 P0.9.1 暴露)
- P2 可观测性(刚立 + reframe,在做)
- ROADMAP 自身生命周期元规则
- 与 Superpowers 耦合 / 术语归属(事实层)

## 不做(防 scope 扩散)

- **不删除已完成的 decision 文件**(`2026-04-15-testing-scope-expansion.md` / `2026-04-16-fork-flat-refactor.md` / `2026-04-17-harness-self-governance-gap.md` 等)— 历史决策保留
- **不修改 PROGRESS.md 现有 milestone 行**(只追加,不重写)
- **不删除已完成的 governance 文件**(testing-rules.md / testing-standard.md 等仍存在 — 它们是落地的治理规则,不是 ROADMAP 计划项)
- **不强制 hook 校验**"ROADMAP 是否预设阶段"— 这是用户判断范围,无可机械化校验逻辑

## 关联

- 同日 decision-trail append 一条新抉择"边做边提升 — ROADMAP 简化"
- handoff "下一步建议"段同步精简(去 P1 迁移)

## 后续

- **新需求出现时**:再开 brainstorming + 立 decision,不预设
- **若用户后续重新需要某个被删的预设阶段**:重立 decision + 重加 ROADMAP 段(轻松,文档级)
- **PROGRESS 阶段性总结**:可选添加"P-1 ~ P0.9.1 基础架构 + 自治理阶段"总结(由"人"在合适时点写)

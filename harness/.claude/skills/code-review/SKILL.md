---
name: code-review
description: "代码审查。一批代码改动完成后触发。ultracode/Workflow 在场时走 review-scout(reviewType='code',scout 现推维:code 地板 3 维 + 动态加);否则回落 Superpowers requesting-code-review(either-or,不叠加,不改 Superpowers 包)。"
invocation: manual
allowed-tools: Read, Glob, Grep, Bash, Agent
---

# 代码审查

> **架构**:ADD review-scout code 路并排于 Superpowers `requesting-code-review` 回落路(**either-or**,不替换、不叠加)。详见 `docs/superpowers/specs/2026-06-15-code-review-scout-design.md`。

## 执行

> **运行时分支(ADD review-scout code 路并排 — either-or,不替换、不叠加 Superpowers;spec §1.2/§2.2/§5.1)**:
> 进入执行先做一次运行时探测——**Workflow/ultracode 工具是否可用**:
>
> - **可用(ultracode 开)→ 走 review-scout 路(主推审查路)**:调度者用 Workflow 工具启动 `review-scout`,入参
>   `{reviewType:'code', targets:{spec:<被实现的设计 spec 路径,纯 bugfix 无 spec 可缺>, diffRef:'<git 改动范围,如 HEAD~N..HEAD 或分支名>', rubric:'docs/RUBRIC.md', architecture:'docs/ARCHITECTURE.md', decisionsDir:'docs/decisions/', auditsDir:'docs/audits/'}, sessionIntent:'<一行会话意图,措辞中性>'}`。
>   workflow 返回 `{plan, findings}`。**scout 路综合维序说明(钉死此处,单一住址 — spec §3.5)**:scout 路维度由 `plan` 动态定(code 地板 3 维 = 方向盘对齐 + 简洁性 + spec忠实性,+ 动态加维),综合维序 = **按 plan 产出的维度清单顺序**交叉读 findings(不用固定维序)。综合仍按 synthesis-rules 事后规则(回意图/决策/客观/避先入为主 + 校验「已对照用户原话」section)。
>   - scout 空返回/审查失败(`plan:null`)→ **显式报用户审查失败**(按本 skill 错误处理重试);**不静默回落 Superpowers**(scout 失败 ≠ ultracode 不在场 — spec §5.1)。
>   - **★ either-or**:ultracode 路**不并跑** Superpowers `requesting-code-review`。spec 忠实性由 scout 地板第 3 维(spec忠实性)保证、代码质量由「方向盘对齐」通用基线覆盖(无真空 — D-C2)。
> - **不可用(ultracode 关 / 非 Claude Code / 逐会话未 opt-in)→ 回落到 Superpowers `requesting-code-review` 流程,原样调用**(已存在的活路,**不改 Superpowers 包**、**不标"降级执行"** — spec §5.1)。scout 动态推维在此回落路不可得 = ultracode 专属取舍。

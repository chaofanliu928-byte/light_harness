# AI Dev Harness 速查卡

> 本文件是派生文档。Skill 详情见各 SKILL.md，Hook 详情见各 .sh 脚本，治理步骤见 governance/*.md。

## 工作流

```
调度者           独立 Agent
  │
  ├→ brainstorming（需求深挖）
  ├→ 需求确认清单锁定
  ├→ fork designer agent ──→ 系统设计（逐节自检）
  ├→ fork design-reviewer ──→ 设计审查
  ├→ writing-plans → fork subagent dev → code review
  ├→ fork security-reviewer ──→ 安全扫描
  ├→ fork evaluator ──→ 方向评估
  │                          │
  │    ├─ 通过 → milestone → structured-handoff → 合并
  │    ├─ 精磨 → structured-handoff → 返回迭代
  │    └─ 推翻 → structured-handoff → 找用户

做事的和判断的分开。调度者只编排，不亲自设计/审查/写代码。
回退：需求缺陷 → brainstorming | 设计缺陷 → 系统设计 | 代码 bug → 原地修
```

## 治理规则

| 阶段 | 治理文件 |
|-----|---------|
| brainstorming（需求对接） | docs/governance/brainstorming-rules.md |
| **系统设计** | **docs/governance/design-rules.md** |
| writing-plans | docs/governance/planning-rules.md |
| subagent dev | docs/governance/implementation-rules.md + testing-rules.md |
| code-review | docs/governance/review-rules.md |
| finishing | docs/governance/finishing-rules.md |
| **凭证与对账(跨阶段)** | **docs/governance/credentials-rules.md** |

## Skill

| Skill | 什么时候 |
|-------|---------|
| project-setup | 首次使用 — 对话式引导 |
| system-design | 需求锁定后 — fork designer（自检由调度者另 fork 挑战者） |
| design-review | 设计完成后 — 主推 ultracode 走 review-scout（scout 现推维）；回落 fork reviewer team（4 并行子智能体，仅 ultracode 不在场） |
| code-review | 代码改动完成后 — 主推 ultracode 走 review-scout(reviewType=code);回落 Superpowers requesting-code-review（either-or） |
| evaluate | finishing — 自动触发（invocation: auto） |
| security-scan | finishing — evaluate 之前 |
| process-audit | finishing — evaluate 之后、分流之前 |
| structured-handoff | finishing 三路 + /clear 前 |

## Hook

| Hook | 作用 |
|------|------|
| prettier | 自动格式化 |
| check-module-docs | 代码改了就提醒更新模块 README |
| session-init | 注入交接文档 + 治理提醒 |
| check-handoff | Stop 硬核晋升门禁(promotion 文法/锚点/登记交叉核) |
| check-shelf-registry | 落库登记软扫(未登记点名,永不阻断) |
| check-evidence-depth | finishing 检查 Evidence Depth/CI 阻断字段 |
| check-context-chain | docs/context/ 活链软提醒(断链/方向违法,只警告) |
| check-audit-coverage | 凭证覆盖对账(--reconcile 开场用;治理面改动的 audit 凭证核) |

## 人必须做的事

1. **填写 docs/RUBRIC.md** — 方向盘
2. **填写 docs/ARCHITECTURE.md** — 分层规则
3. **确认需求清单** — brainstorming 阶段
4. **推翻/架构决策** — AI 不确定时

## 关键文件

| 文件 | 用途 |
|------|------|
| **docs/RUBRIC.md** | 评分标准（方向盘）|
| **docs/references/DESIGN_TEMPLATE.md** | 系统设计文档模板 |
| docs/ARCHITECTURE.md | 分层规则 |
| docs/active/handoff.md | 交接台账(覆写经晋升门禁 /structured-handoff) |
| AGENTS.md | agent 第 0 步地图(跨运行时) |
| docs/completed/ | 归档（手动 grep 深查历史）|
| docs/decisions/ | 架构决策 |
| docs/context/ | 分层活上下文链(L1-L6;upstream 编码挂链) |
| docs/references/ | 内部知识 + 提取的参考 |
| docs/audits/ | 审查凭证(audit-*;频次低但生死攸关) |

## 上下文重置

`/structured-handoff` → `/clear` → 新会话自动加载

## 自定义

| 要改什么 | 去哪改 |
|---------|--------|
| 评分标准 | docs/RUBRIC.md |
| 架构规则 | docs/ARCHITECTURE.md |
| 系统设计模板 | docs/references/DESIGN_TEMPLATE.md |
| 各阶段治理规则 | docs/governance/*.md |
| 评估维度和权重 | .claude/agents/evaluator.md |

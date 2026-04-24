# P0.9 harness self-governance 系统设计

> **阶段状态**：brainstorming 完成（2026-04-17），design 阶段待启动。
>
> **规模级别**：重量级（涉及 1 个新治理文件 + CLAUDE.md 改动 + 4 个现有 agent + 4 个现有 skill + 可能 1 个新 reference 文档，超过 3 个模块）。必须通过 `/design-review`。
>
> **Bootstrap 状态**：本 spec 是 meta 改动的元审查（审查"设计 self-governance"本身）。第 2-8 节必须在 design 阶段由 designer agent fork 填写，并由本 spec 自身产出的 meta-review 流程回溯检查。不符合新流程之处作为测试用例反哺 P0.9.1 完善，不追溯推翻本 spec。

---

## 1. 需求摘要

### 1.1 用户目标

harness 作为治理框架需要**治理自己的改动**。具体实现三件事：

1. harness 改动有明确 finishing 路径（不再 ad-hoc）
2. rule-negotiation 无便利路径（流程清晰到可事后 grep 验证）
3. harness 的 leverage 定位（比 feature 高一个量级的稳定性）显式化

**背景**：见 `docs/decisions/2026-04-17-harness-self-governance-gap.md` 承认的三条根源。

### 1.2 核心场景（按优先级排序）

#### 场景 1 [P0.9.1 主体] meta 改动走流程化对抗审查

- **谁**：调度者（主对话 AI）+ 用户
- **做什么**：准备改 harness scope 内文件（A + B + C + D + F，见 1.3 边界）
- **系统做什么**：
  - 触发 meta-review 流程（扁平 fork 挑战者）
  - 挑战者维度由调度者按主题定制（推荐清单 + 最低必选 + 定制理由留痕）
  - 领审员综合共识/分歧/盲区
  - audit trail 归档到 `docs/audits/meta-review-YYYY-MM-DD-[主题].md`
- **看到什么**：改动附带对应 audit 产物，grep audit 目录可检出是否"走过流程"

#### 场景 2 [P0.9.1 主体] meta finishing 路径明确

- **谁**：调度者 + 用户
- **做什么**：完成一次 meta 改动后收尾
- **系统做什么**：按 `docs/governance/meta-finishing-rules.md`（新文件）指引完成 decision 立档 / ROADMAP 更新 / PROGRESS 迁移 / memory 同步
- **看到什么**：meta 改动不再临时编动作（即本会话 2026-04-17 反复踩的坑的系统化修复）

#### 场景 3 [P0.9.1 主体] 4 个现有审查 agent 维度可定制化

- **谁**：调度者
- **做什么**：准备用 design-review / evaluate / security-scan / process-audit
- **系统做什么**：每个 agent 支持"推荐清单 + 最低必选维度 + 定制理由留痕"混合结构；调度者按主题选维度，理由写入 audit trail
- **看到什么**：同类主题的审查维度一致可复现，跨主题则允许按实际定制。维度选择事后可追溯

#### 场景 4 [P0.9.2 诊断] leverage 定位复盘

- **谁**：用户或调度者
- **做什么**：P0.9.1 跑了 N 轮后复盘
- **系统做什么**：回顾 meta 改动 audit trail，判断稳定性标准是否比 feature 高一个量级
- **看到什么**：有数据支撑的 leverage 诊断报告。若已隐含满足则写一段原则说明；若不足则补强

#### 场景 5 [P0.9.3 兜底] 最小硬 hook 补强（可能不触发）

- **谁**：调度者
- **做什么**：如 P0.9.1 流程被绕
- **系统做什么**：加最小硬 hook（pre-commit 检测 scope 内文件改动 + audit 产物存在）
- **看到什么**：违规 commit 被拦

### 1.3 边界与约束

**做什么（scope 内 A+B+C+D+F）**：
- A `governance/*.md`, `CLAUDE.md` 核心规则
- B `.claude/hooks/*.sh`, `settings.json` 注册
- C `.claude/skills/*/SKILL.md`, `.claude/agents/*.md`
- D `docs/RUBRIC.md`, `docs/references/DESIGN_TEMPLATE.md`
- F `setup.sh`, 分发给下游项目的模板 `CLAUDE.md`

**不做什么**：
- E `docs/ROADMAP.md`, `docs/PROGRESS.md`, `docs/active/handoff.md` 不走对抗审查（改动频率过高会反效应；走轻量一致性检查即可）
- G `README.md`, `QUICKREF.md`, 用户文档 不走对抗审查（文档追随）
- 不加新硬 hook 作为主强制（Q2 选光谱 B）
- 不在 P0.9 内为 harness 自身填"项目特定 RUBRIC"（挪后续条目）
- 不追溯审查 P-1/P0/P0.5 已完成项
- P0.9.2 诊断不在 P0.9.1 scope 内
- P0.9.3 兜底可能完全不触发

**性能要求**：meta finishing 额外成本估算每月 2.5-10 小时（每月 5-10 次触发 × 30-60 分钟/次），作为"马鞍 leverage"合理代价

**安全要求**：audit 产物为 markdown，无敏感信息

**兼容性要求**：
- M0-M4（block-dangerous 删除 / 封死简化收尾 / 简洁性维度降级 / 修 finishing 内部冲突 / 轻量级判定）作为 P0.9.1 落地后**首个使用批次**，不在本 spec scope
- 现有 design-review / evaluate / security-scan / process-audit skill 的用户调用接口**保持不变**（向后兼容）

### 1.4 关联需求

**依赖的已有功能**：
- 2026-04-17 本会话 4 挑战者扁平 fork 元审查模式（原型）
- P0.5 扁平 fork 基础设施（`docs/decisions/2026-04-16-fork-flat-refactor.md`）
- `docs/decisions/` 归档结构
- `docs/audits/` 目录（process-audit 已在用）
- `docs/references/multi-agent-review-guide.md`（对抗-决策分离 + 共识/分歧/盲区）

**被哪些未来功能依赖**：
- **P1 真实项目验证阻塞于 P0.9.1 完成**
- M0-M4 治理改动批次
- 后续任何 harness meta 改动

### 1.5 已确认的决策（从 brainstorming 带入）

| 问题 | 回答 | 来源 |
|---|---|---|
| scope 纳入哪些修改类型 | A+B+C+D+F 纳入，E+G 排除 | Q1（用户确认推荐） |
| 强制层级 | 光谱 B（对抗审查流程化，不加主强制 hook） | Q2 |
| audit trail 机制 | 每次 meta 改动必须产出 audit，无产物视为未走流程 | Q2 补 |
| 分批次序 | P0.9.1 主体 / P0.9.2 诊断 / P0.9.3 兜底 | Q3 |
| 审查维度策略 | 每次按主题定制，不固定 4 维。扩展到现有 design-review / evaluate / security-scan / process-audit 也采用"具体情况具体分析" | Q2 后续 |
| 混合结构 | 推荐清单 + 最低必选维度 + 定制理由留痕 | Q3 补 |
| audit 归档路径 | `docs/audits/meta-review-YYYY-MM-DD-[主题].md` | 第二轮补问 |
| 前置已确认待 P0.9 落实 | block-dangerous 删除 / bypass decision 模式放弃 / 简洁性维度降级为 CLAUDE.md 行为准则 | 前述会话 |
| scope 选 X1 | P0.9.1 既做 meta finishing 又改 4 审查 agent | Q2 后续补问 |

### 1.6 RUBRIC 风险标记

基于 `docs/RUBRIC.md` 通用基线（harness 自身**项目特定标准为空**，是 self-governance 缺口的具体面之一，挪后续处理）：

**涉及的惩罚项（主动规避）**：
- **简洁性**：P0.9 要防 over-engineering —— meta finishing 流程不能变成比 feature finishing 更大的怪物。新增治理文件和 pattern 必须最小够用
- **一致性**：meta-review 流程与现有 4 个审查 agent 改造必须共享同一个"混合结构" pattern（推荐 + 最低必选 + 理由），避免各处一套
- **测试充分性**：meta 改动的 Evidence Depth 语义需重定义（feature 的 L1-L4 不完全适用 meta 场景）
- **代码质量**：audit 产物模板需设计清晰（字段 / 维度清单 / 综合结构 / 用户决策位）

**涉及的奖励项（主动争取）**：无项目特定奖励项可参考（项目特定 RUBRIC 空模板，本 spec 不填，挪后续）

**元警告**：harness 的项目特定 RUBRIC 空白本身是 self-governance 缺口的具体面。P0.9.1 的 design 阶段不能依赖项目特定惩罚项作参考 —— 这限制了 RUBRIC 应对方式的完整性。

---

## 2. 模块划分

> **待 design 阶段填写**。

### 2.1 模块清单

候选模块（brainstorming 阶段初步识别，design 阶段锁定）：
- 新建 `docs/governance/meta-finishing-rules.md`
- 新建 `docs/references/review-dimension-pattern.md`（混合结构通用 pattern，TBD）
- 改动 `CLAUDE.md`（治理表加 meta-finishing 引用）
- 改动 `.claude/agents/design-reviewer.md`
- 改动 `.claude/agents/evaluator.md`
- 改动 `.claude/agents/security-reviewer.md`
- 改动 `.claude/agents/process-auditor.md`
- 改动 `.claude/skills/design-review/SKILL.md`
- 改动 `.claude/skills/evaluate/SKILL.md`
- 改动 `.claude/skills/security-scan/SKILL.md`
- 改动 `.claude/skills/process-audit/SKILL.md`
- 改动 `docs/governance/finishing-rules.md`（加 scope 判定入口）

### 2.2 模块依赖图

> 待 design 阶段填写。

---

## 3. 接口定义

> **待 design 阶段填写**。

### 3.1 模块间接口

> 待 design 阶段定义 meta-review 流程与现有 design-review / evaluate / security-scan / process-audit skill 的调用契约。

### 3.2 外部接口

**不适用** —— 本功能不涉及 API 接口。

### 3.3 前后端类型契约

**不适用** —— 本功能不涉及 API 端点变更。

---

## 4. 数据模型

> **待 design 阶段填写**。

候选数据结构（brainstorming 初步）：
- audit trail 文件格式（字段 / 维度清单 / 定制理由 / 综合结果 / 用户决策）
- 混合结构维度定义（推荐维度 / 最低必选 / 可选扩展）

---

## 5. 边界条件与错误处理

> **待 design 阶段填写**。

候选边界（brainstorming 初步）：
- 调度者判错 scope（本应 meta 却按 feature 处理，或反之）
- meta-review fork 失败
- 定制维度漏掉最低必选（需要在定制阶段检出）
- audit 产物缺失（违反规定）

---

## 6. 测试策略

> **待 design 阶段填写**。

关键问题：meta 改动的 Evidence Depth 语义重定义（feature 的 L1 单元测试 / L2 冒烟 / L3 API 测试 / L4 用户行为对 meta 不完全适用）。

---

## 7. 设计决策记录

> **待 design 阶段填写**。

候选决策（brainstorming 阶段识别的）：
- 是否新建独立的 `meta-review` skill，还是扩展现有 `process-audit` skill？
- 4 个现有 agent 改造时是否统一 prompt 结构？
- 推荐维度清单是否以 markdown table 形式嵌入 agent prompt，还是单独文件？
- 最低必选维度如何强制（agent prompt 内含检查 / 调度者层面检查）？

### RUBRIC 应对方式

> 待 design 阶段展开（从 1.6 风险标记逐项设计应对）。

---

## 8. 与既有系统的影响

> **待 design 阶段填写**。

### 8.1 需要改动的已有文件

见第 2.1 候选模块清单。

### 8.2 不改动但需要验证兼容的

- `docs/governance/brainstorming-rules.md`（需验证 meta finishing 不与之冲突）
- `docs/governance/design-rules.md`（同上）
- `docs/governance/planning-rules.md`（同上）
- `docs/governance/implementation-rules.md`（同上）
- `docs/governance/review-rules.md`（同上）
- 现有 `docs/decisions/*.md`（是否都符合新 meta finishing 规则）

---

## 9. 全局自洽性检查

> 第 2-8 节完成后做最终检查。当前阶段（brainstorming 完成）**所有项未勾选**。

- [ ] 需求 ↔ 模块：每个需求场景在模块划分中有实现路径？
- [ ] 模块 ↔ 接口：每个模块职责通过接口体现？
- [ ] 接口 ↔ 数据：接口中数据类型在数据模型中定义？
- [ ] 数据 ↔ 边界：数据模型每个字段的边界值有处理？
- [ ] 依赖 ↔ 架构：依赖方向符合 ARCHITECTURE.md？（**注意**：ARCHITECTURE.md 对 harness 自身不适用，此项在 design 阶段可能需要判"不适用"或专门定义 harness 自身的"架构"概念）
- [ ] 决策 ↔ 需求：设计决策没偏离需求约束？
- [ ] 决策 ↔ 架构：同上，harness 自身 ARCHITECTURE 待定
- [ ] 影响 ↔ 模块：第 8 节改动文件与第 2 节"改动"模块对应？
- [ ] RUBRIC ↔ 设计：第 7 节对每个 RUBRIC 惩罚项都有应对方式？
- [ ] 契约 ↔ 接口：**不适用**（无 API 端点）

---

## Brainstorming → Design 切换检查

按 `docs/governance/brainstorming-rules.md` 收敛判断：

- ✅ 每个核心场景都能写出"谁 → 做什么 → 系统做什么 → 看到什么"的完整描述（1.2 五个场景均完成）
- ✅ 需求确认清单覆盖用户说过的所有要点
- ✅ "不做什么"列了多项明确排除
- ✅ 前置已确认的判断作为"前置已确认"标记
- ✅ RUBRIC 惩罚项已基于通用基线标记（项目特定空白已元警告）

**Brainstorming 阶段可收敛**。下一步：design 阶段由调度者 fork designer agent 填写第 2-8 节，再过 `/design-review` 四挑战者审查。

**Design 阶段的特殊注意**：
1. designer agent 填写时，需**明确判定**本 spec 属标准级还是重量级（我初判重量级，待 designer 复核）
2. ARCHITECTURE.md 对 harness 自身不适用 —— designer 遇到"依赖 ↔ 架构"自检项时需要判"不适用"或先定义 harness 自身的层级概念
3. design-review 阶段会用到"每次按主题定制"维度的新机制 —— 但该机制正是 P0.9.1 要产出的，**存在 self-reference 悖论**。权宜：本 spec 的 design-review 使用本会话已原型验证的 4 挑战者（核心原则合规 / 目的达成度 / 副作用 / scope 漂移）作 bootstrap 维度，P0.9.1 落地后反向验证这 4 维是否符合新机制的"推荐清单"

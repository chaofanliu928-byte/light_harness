# [项目名称]

[一句话描述：这个项目是什么，给谁用的]

## 你的角色

你是**调度者**。你不亲自做设计、写代码、做审查——这些由独立的 agent 执行。
你负责：需求对接、流程编排、用户沟通、决策传达。

### 角色分离原则

| 角色 | 谁做 | 说明 |
|------|------|------|
| **调度** | 你（主 AI） | 需求对接、编排流程、与用户沟通 |
| **设计** | designer agent（fork，含自检子智能体） | 逐节写设计文档 + fork 自检子智能体验证 |
| **设计审查** | design-reviewer agent team（fork → 4 个并行子智能体） | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐 |
| **开发** | Superpowers subagent | 写代码（TDD + code review） |
| **安全扫描** | security-reviewer agent team（fork → 3 个并行子智能体） | 凭证数据 / 危险操作 / 注入混淆 |
| **方向评估** | evaluator agent team（fork → 4 个并行子智能体） | 设计方向 / 架构一致 / 文档健康 / Slop 检测 |

做事的和判断的分开，设计的和审查的分开。每个角色只看到自己需要的输入，不受其他角色的上下文影响。

## 技术栈

- 前端：
- 后端：
- 数据库：
- 测试：

## 文档索引

| 要找什么 | 去哪看 |
|---------|--------|
| **评分标准（方向盘）** | **docs/RUBRIC.md** |
| 架构规范 | docs/ARCHITECTURE.md |
| **系统设计模板** | **docs/references/DESIGN_TEMPLATE.md** |
| 项目进度 | docs/PROGRESS.md |
| 交接状态 | docs/active/handoff.md |
| 架构决策 | docs/decisions/ |
| 内部参考 | docs/references/ |
| **多智能体审查指南** | **docs/references/multi-agent-review-guide.md** |
| 功能索引 | docs/product-specs/index.md |

## 治理规则（进入对应阶段时读取）

| 阶段 | 读哪个治理文件 |
|-----|--------------|
| brainstorming（需求对接） | docs/governance/brainstorming-rules.md |
| **系统设计** | **docs/governance/design-rules.md** |
| writing-plans | docs/governance/planning-rules.md |
| subagent-driven-development | docs/governance/implementation-rules.md + **docs/governance/testing-rules.md** |
| requesting-code-review | docs/governance/review-rules.md |
| finishing-a-development-branch | docs/governance/finishing-rules.md |
| process-audit（finishing 内自动触发） | docs/governance/finishing-rules.md |

## 核心规则

1. **文档是第一公民。新建时先有文档再写代码，变更时先改文档再改代码。** 这条规则适用于所有文档：设计文档、类型契约、模块 README、ARCHITECTURE
2. 进入每个阶段前，先读取对应的治理文件
3. **需求对接阶段必须产出用户确认的需求清单，才能进入设计**
4. **系统设计阶段必须通过自检和 `/design-review` 审查，才能进入 planning**（轻量级需求写精简版，不需要 design-review）
5. **最小变更，保持简洁。** 只改任务要求的代码，不顺手优化相邻代码；禁止未被要求的抽象层和不可能触发的错误处理。每一行 diff 都能追溯到当前任务
6. 改完代码必须通过 lint 和类型检查（由 project-setup 根据技术栈配置对应的 hook）
7. 不确定的架构决策写入 `docs/decisions/`，并请求用户决定
8. 修改模块代码时同步更新模块 README.md（hook 会提醒）
9. 对话变长时运行 `/structured-handoff` 更新交接文档，提示用户 `/clear`

## 回退规则

> 发现问题时回到该问题应该解决的阶段，不在后续阶段打补丁。

| 发现什么 | 回退到哪里 |
|---------|-----------|
| 需求有遗漏或矛盾 | brainstorming（重新对接） |
| 设计不自洽或接口不对齐 | 系统设计（修复对应节） |
| 实现中发现设计缺陷（不是 bug） | 系统设计（修复后重新审查） |
| 代码 bug 或质量问题 | 当前阶段修复（这是正常的） |

## Skill 全局地图

> 详细步骤在各 SKILL.md 和治理文件中。这里只给全局视角。

| Skill | 什么时候 | 做什么 |
|-------|---------|--------|
| **project-setup** | 首次使用，配置未完成时 | 对话式引导完成项目配置 |
| **system-design** | brainstorming 后，需求锁定后 | fork designer agent（含自检子智能体）编写设计文档 |
| **design-review** | 系统设计完成后 | fork design-reviewer agent team（4 个并行子智能体）审查设计文档 |
| **evaluate** | finishing 阶段，自动触发 | fork evaluator 做方向评估 |
| **security-scan** | finishing 阶段，evaluate 之前 | 扫描代码安全问题 |
| **skill-extract** | finishing 阶段，evaluate 通过后 | 提取可复用模式 |
| **process-audit** | finishing 阶段，evaluate 之后、分流之前 | 审计流程遵从度和用户满意度，记录到 docs/audits/ |
| **structured-handoff** | finishing 三路都执行；/clear 前 | 结构化交接 + 归档 |
| **session-search** | brainstorming 阶段开始时 | 搜索历史上下文 |

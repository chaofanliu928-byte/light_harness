# Testing 阶段治理规则

> 当 Superpowers 的 subagent-driven-development 或 executing-plans 激活时,agent 在动手写代码前读取本文件。
> 本文件与 implementation-rules.md 并列,专注"测试决策"。

## 定位

本文件只回答两个问题:

1. 这次变更**必须写测试**吗?
2. 必须写的话,**最低 Evidence Depth** 是什么?

**不回答**:测试怎么写、覆盖率门槛、mock 策略——那些是项目级决策或 Superpowers TDD 的职责。
**术语 SSoT**:`docs/references/testing-standard.md`(Evidence Depth L1-L4 + CI 阻断)。

## 决策表:变更类型 → 最低 Evidence Depth

| 变更类型 | 最低强度 | 说明 |
|---|---|---|
| 核心场景新功能 | **L1 + L2** | 最完整的变更,隔离测试 + 主路径冒烟双证据 |
| 非核心场景新功能 | **L1** | 隔离测试起步 |
| Bug 修复(任何场景) | **L1** | 至少写一个复现用例,防回归 |
| 重构(行为不变) | **L2** | 冒烟测试验证行为未变(单元测试次要,因为内部实现变了) |
| 配置 / 环境变量改动 | 无要求 | 无运行时逻辑 |
| 纯文档 / 注释 / 类型定义改动 | 无要求 | 无运行时影响 |

**"核心场景"定义**:设计文档 `docs/superpowers/specs/[功能]-design.md` 第 1.2 节;若无设计文档,取 RUBRIC 项目特定标准里的核心用户路径。

## 契约任务 vs 实现任务(planning-rules 的二分在测试层的差异)

planning-rules.md 把任务分为"契约任务(指令式)"和"实现任务(问题式)",测试要求不同:

| 任务类型 | 最低强度 | 说明 |
|---|---|---|
| **契约任务**(接口 / 类型契约 / 跨模块声明) | **L1 + L3** | 隔离测试 + 自动化 API 测试验证契约;契约是双方合同,测试必须更严 |
| **实现任务**(模块内部逻辑) | **L1**(核心场景加 L2) | 单元测试为主,核心场景补冒烟 |

契约任务排在实现任务之前(planning-rules 已规定),测试强度也更高。

## 与其他治理文件的分工

| 文件 | 管什么 |
|---|---|
| `design-rules.md` 第 6 节"测试策略" | 设计阶段定"测试什么"(抽象层,对应设计文档第 5 节边界条件) |
| `planning-rules.md` "测试计划"节 | 计划阶段排"测试任务"(层级 / mock 策略 / 任务拆分) |
| **`testing-rules.md`(本文件)** | implementation 阶段判"是否必须写 + 最低 Evidence Depth"(决策层) |
| `docs/references/testing-standard.md` | Evidence Depth 术语 SSoT + handoff 字段格式 |

决策规则**只**在本文件出现,其他文件不得重复写;需要引用时用链接。

## 回退判断

| 遇到什么 | 怎么办 |
|---|---|
| 一次变更跨多类(比如 bug 修复 + 顺手重构) | 按**最严**的类别处理(L1 + L2 都要) |
| 明确不写测试但担心 RUBRIC 扣分 | 在 handoff 的 Evidence Depth 字段显式说明"本次变更类型不要求测试",evaluator 会识别 |
| 不确定是否属于"核心场景" | 回到 brainstorming 重新确认,不在 implementation 阶段猜 |
| 决策表没覆盖的变更类型 | 回到 brainstorming 补规则,不在当次任务自行扩展本文件 |

## RUBRIC 关联

本文件定义的"最低 Evidence Depth"是 RUBRIC"测试充分性"维度的打分基准。

- 低于最低要求 → 测试充分性扣分 → 触发回退到 implementation 重新补测试
- 高于最低要求 + 非核心路径 → 可能触发"简洁性"惩罚(过度测试也是反模式)
- "最低"不是"目标",是**底线**。核心场景追求更高 Evidence Depth 是加分项,但超出必要的非核心测试是扣分项

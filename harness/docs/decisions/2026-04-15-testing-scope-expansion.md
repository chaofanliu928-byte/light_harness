# 决策: 测试覆盖纳入 harness scope

**状态**:🟢 已决定

**日期**:2026-04-15

**关联功能**:ROADMAP 重排(原 ROADMAP 1/2/3 调整为 P0/P1/P2)

## 问题

harness 最初定位为"Claude Code 治理层",测试策略委托给 Superpowers TDD + lint/类型检查 hook。用户明确指出"我们的框架要覆盖测试"——即测试应进入 harness 自身 scope,不完全外包。

同时前一轮判断中使用了"90% 项目不需要回归"这类市场判断修辞,被用户纠正——决策必须只基于事实 + 逻辑,详见 `feedback_judgment_basis`。

本决策处理:
1. 测试纳入 scope 后,覆盖到什么深度
2. 覆盖深度决定后,几个具体设计分歧

## 方案

### 方案 A:维持现状(不纳入 scope)

- **做法**:测试继续委托 Superpowers TDD,lint/类型检查 hook 兜底,不加专用治理文件、不加 RUBRIC 独立维度
- **优点**:零改动,无重叠建设
- **缺点**:违反用户明确的 scope 定义;evaluator 无法对测试维度打分;长程项目无"验证到第几层"的显式表达

### 方案 B:纳入 scope,覆盖到 L1+L2+L3(评估 + 治理 + 声明)

- **做法**:
  - L1 评估层:RUBRIC 加"测试充分性"维度
  - L2 治理层:新增 testing-rules.md + testing-standard.md,implementation 阶段强制读
  - L3 声明层:finishing 阶段显式声明 Evidence Depth,hook 检查字段非空
- **优点**:覆盖"事前指导 / 事后打分 / 收口声明"完整闭环;职责分层清晰(hook 管硬约束,evaluator 管内容质量);不越权到自动执行测试
- **缺点**:改动跨 7+ 文件;L1-L5 档位语言需用户确认语义;文档同步成本增加

### 方案 C:纳入 scope 并做 L4(Regression SSoT + Cadence Ledger)

- **做法**:方案 B + 完整 Regression SSoT + Cadence Ledger + surface 清单
- **优点**:完整对齐 coding-agent-harness 方法论
- **缺点**:harness 未在任何外部业务项目跑过,价值依赖"多 surface"场景,当前无事实支撑;会产生大面积死文档

## 决定

选择:**方案 B**

原因:
- 方案 A 与用户明确 scope 定义冲突,排除
- 方案 C 依赖"多 surface 项目"场景,当前无数据支撑,违反"决策只基于事实"原则
- 方案 B 是"事前 + 事后 + 收口"最小闭环,不越权到自动执行,与"hook 管硬约束 / evaluator 管软判断"的职责分层兼容

## 关联子决策

方案 B 的具体落地涉及三个设计分歧,本次一并决定:

### 子决策 B1:L3 声明层的实现方式

**问题**:L3 标题叫"确定性执行层"但内容是文字指令,是否名实不符

**选择**:做 pre-commit hook 但只检查"Evidence Depth 字段是否为空",不检查证据质量

**理由**:
- "字段必填"是硬约束 → 用 hook
- "字段内容对不对"是软判断 → 给 evaluator
- 职责清晰,不互相侵占
- 符合 F6 确定性优先哲学(hook 强制 > 文字指令)

**后续影响**:
- `finishing-rules.md` 加"Evidence Depth 声明"步骤
- `structured-handoff` 模板加 `## Evidence Depth` 字段
- 新增 hook:finishing 前检查 handoff 里该字段非空(技术方案待实施时定)
- evaluator 对抗者池加"测试充分性挑战者",负责内容质量判断

### 子决策 B2:findings 存放方式

**问题**:research 产物当前无归宿,一 `/clear` 就丢。补 Planning 三件套(task_plan/findings/progress)还是扩 handoff?

**选择**:扩展 handoff 加 `## 研究发现` 字段;同时在 `planning-rules.md` 埋升级路径提示

**理由**:
- 当前开发模式是"连续聚焦式单任务",handoff 单文件够用
- 引入三件套是结构性扩张,违反"等 P1 暴露真实不足再定"
- 升级路径显式标记:"跨 ≥3 session 或多并行子任务时,拆到 `docs/09-PLANNING/TASKS/` 独立目录"
- 最小改动解决真痛点(research 不丢),不关死未来结构扩张的门

**后续影响**:
- `docs/active/handoff.md` 模板加 `## 研究发现` 字段
- `.claude/skills/structured-handoff/SKILL.md` 说明归档时该字段随行
- `docs/governance/planning-rules.md` 加升级路径提示
- 未来若升级到三件套,需补 `docs/references/planning-three-piece.md`(当前不做)

### 子决策 B3:是否补 surface 清单(对齐 11 Phase 的 Phase 7)

**问题**:project-setup 不问"关键 surface 清单",而 Evidence Depth 未来 L4 需要这个输入

**选择**:当前不做 surface 清单,testing-standard.md 或 project-setup 下一次迭代时埋一个提示性问题(不阻断流程)

**理由**:
- L1-L3 是任务级指标,不依赖 surface 数量
- L4 暂缓,surface 清单是为还不存在的问题做准备
- 硬性问 surface 可能用户答不上来,答了也会过时
- 提示性问题:用户意识到 surface 多时主动记录,不多时流程无感

**后续影响**:
- `project-setup` 不做结构性改动
- 未来 L4 触发(≥3 surface 场景出现)时,补 surface 清单的决策重新评估

## 本决策之外的 ROADMAP 修订(不属于本决策,但同步执行)

以下是本次 ROADMAP 重写顺带修订的项,属于前一版 ROADMAP 的事实/流程错误修复,不是新决策:

- 修正事实声称:"测试覆盖极浅"改为"测试治理散落在 design-rules / planning-rules,需要整合+升级"(事实基础挑战者发现原陈述夸大)
- "harness 未在任何真实项目跑过"改为"未在外部业务项目跑过;作者在仓内 dogfood 中"(定义模糊修正)
- P0 拆分:residual 字段清晰化降级为 P-1(独立小改),P0 只保留测试覆盖
- P0 内部顺序:L2 → L1 → L3 严格串行(L1 档位语言依赖 L2,L3 判断依赖 L1 规则)
- "明确不做"改为"建议不做,待确认"(AI 不越权划治理边界)
- L1-L5 档位语言标"术语提案,待用户确认语义"(F7 定标准是人的活)

## 后续影响

- `docs/ROADMAP.md` 按本决策重写
- 后续 P0 实施时,按子决策 B1/B2/B3 落地,不再重新讨论
- 下次 scope 级变更必须先写 decision 再改 ROADMAP(本次已违反 F3 一次,现补偿)

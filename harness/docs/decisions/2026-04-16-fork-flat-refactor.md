# 决策: fork 嵌套扁平化改造

**状态**:🟢 已决定

**日期**:2026-04-16

**关联功能**:P0.5 fork 拓扑改造(紧急修复 P1 验证发现)

## 问题

harness 的核心价值主张是**对抗-决策分离**(做事的和判断的分开,对抗者和决策者独立 context)。实现方式是"两级 fork":
- skill 用 `context: fork` 启动领审员 agent(evaluator / design-reviewer / security-reviewer / process-auditor / designer)
- 领审员再 fork N 个并行对抗者

P1 验证(在目标项目 `D:\项目\智能体-生图`)发现:**第二级 fork 实际失效**。

- Claude Code 的 subagent 默认没有 Agent 工具权限——被 fork 的子 agent 不能再 fork 子 subagent
- 领审员收到 fork 失败后,按 design-rules.md 的"Fork 失败降级"规则,自己在单 context 里分角色推演
- 结果:所有"对抗式"审查实际是同一个 LLM 在同一 context 里自问自答
- 对抗张力是虚的,独立性是幻觉,文档顶部的 `⚠️ 降级执行` 标注变成常态

**这不是项目特例**,是所有用 harness 的项目都会遇到的结构性问题。harness 核心价值主张受影响。

## 方案

### 方案 A:等平台支持嵌套 fork(被动等待)

- **做法**:不改 harness,等 Claude Code 将来支持 subagent nested fork
- **优点**:零改动
- **缺点**:时间不可控;现在 harness 上所有项目的对抗-决策分离都是虚的;与 harness 设计初衷严重背离
- **否决**

### 方案 B:扁平化 fork — 调度者(主对话)直接 fork N 个并行挑战者

- **做法**:
  - skill 的 `context: fork` 去掉,在主对话(调度者)中执行
  - 主对话直接用 Agent 工具并行 fork N 个挑战者(每个挑战者是独立 context)
  - 主对话自己做领审员(综合 / 推导评分 / 写结果)
- **优点**:
  - 挑战者之间独立性保留(真 fork)
  - 平台现实可行(本次会话的 5 对抗者审查就验证过这个模式)
  - 不依赖嵌套 fork
- **缺点**:
  - 主对话(调度者)参与了综合,不是"完全独立的领审员"
  - 对抗 vs 决策分离弱化为"对抗独立、决策在调度者"——但仍比当前全在主对话强
- **接受**

### 方案 C:接受降级 + 明确文档化

- **做法**:不改代码,只在 CLAUDE.md 和各 agent 文档里显式声明"当前 harness 实际是单 context 模拟多智能体"
- **优点**:成本最低
- **缺点**:harness 核心价值主张消失,退化为"AI 写了一堆规则文件"
- **否决**

## 决定

选择:**方案 B**

原因:
- 方案 A 被动且不可控
- 方案 C 放弃核心价值
- 方案 B 在平台现实约束下保留最大独立性
- 本次会话实际做过 5 对抗者并行审查(领审员是主对话),证明模式可行

## 对抗 vs 决策分离在方案 B 下的新形态

| 角色 | 旧架构 | 新架构(方案 B) |
|---|---|---|
| 对抗者 | 领审员 fork N 个 | 主对话 fork N 个 |
| 决策者 | 领审员(fork 层) | 主对话(调度者) |
| 独立性 | 对抗者独立 + 决策者独立 | 对抗者独立,决策者 = 调度者 |
| 真实性 | 实际降级为全模拟 | 对抗部分真实,决策部分非独立但透明 |

方案 B 承认"决策者的独立性"不可得,但保证"对抗者的独立性"可得。这比当前虚假的两层都好。

## 影响的组件

需要重构的 skill(5 个):
- `evaluate`
- `design-review`
- `security-scan`
- `process-audit`
- `system-design`(designer 的自检子智能体同样受影响)

需要重构的 agent(5 个):
- `evaluator.md`
- `design-reviewer.md`
- `security-reviewer.md`
- `process-auditor.md`
- `designer.md`

## 重构原则

1. skill 的 frontmatter:`context: fork` 去掉,skill 在主对话执行
2. skill 的 body:明确"主对话在一条消息中并行 fork N 个挑战者,用 Agent 工具"
3. agent 文件:
   - 去除"第一步 fork 子智能体"的指令
   - 保留对抗者的角色提示词和问题清单格式
   - 转化为"如果你被以挑战者身份 fork,按以下提示工作"的单角色说明
   - 或拆分为多个独立的 challenger 文件
4. 每个 skill 保留:上下文注入(!` ... `)+ 并行 fork 指令 + 领审员综合逻辑

## 与现有降级补偿机制的关系

当前 CLAUDE.md 规则:"降级执行必须标注 ⚠️ 降级执行 + 下次 agent 重新验证"。方案 B 实施后:

- "领审员独立"不再是 harness 承诺 → 不标注降级(方案 B 就是新架构)
- "对抗者独立"是 harness 承诺 → fork 失败仍需标注降级
- 更新 CLAUDE.md 删除"领审员独立"的隐含承诺

## 后续影响

- P0.5 是 P1 之前必须完成的修复(否则 P1 的 evaluator 测试充分性挑战者仍会退化为自问自答)
- ROADMAP 插入 P0.5 条目,优先级在 P1 之前
- 本次会话的 5 对抗者审查记录可以作为"方案 B 可行性"的历史证据

# 流程审计（Process Audit）设计文档

> 状态：✅ 已确认
> 日期：2026-04-13

## 1. 需求摘要

### 1.1 用户目标

在每次 finishing 阶段结束时，自动回顾整个开发过程，审计两个维度：
1. AI 对 harness 流程的遵从度
2. 最终效果是否令用户满意，不满意的原因归因到流程/skill 层面

审计结果记录到 `docs/audits/`，**不自动优化流程**，仅供 harness 开发者作为优化输入。

### 1.2 核心场景

1. [P0] finishing 阶段触发审计：finishing 流程到达审计节点 → 系统 fork process-auditor agent → 读取当前项目所有会话 JSONL + 过程产物 → 产出审计报告 → 写入 `docs/audits/`
2. [P0] 跨会话审计：审计 agent 读取 `~/.claude/projects/<项目路径>/` 下所有 JSONL 文件，覆盖项目全部会话历史
3. [P1] 历史模式识别：如果 `docs/audits/` 下已有历史报告，领审员在汇总时标注重复出现的问题

### 1.3 边界与约束

- 做什么：审计 + 记录
- 不做什么：不自动修改治理文件、不自动修改 skill、不阻断 finishing 流程
- 审计失败时：标注"⚠️ 审计未完成"继续 finishing，不阻断

## 2. 架构

### 2.1 组件

```
/process-audit（skill）
  └── process-auditor（领审员 agent，fork）
        ├── 第一步：预处理 JSONL → 提取对话摘要
        ├── 第二步：派发 2 个并行子 agent
        │     ├── 子 agent 1：流程遵从度审计
        │     └── 子 agent 2：效果与满意度审计
        ├── 第三步：汇总报告
        └── 第四步：写入 docs/audits/audit-YYYY-MM-DD-HHMMSS.md
```

### 2.2 在 finishing 流程中的位置

```
security-scan → evaluate → structured-handoff → /process-audit → 合并/归档/回退
```

- 无论 finishing 结果是通过、精磨还是推翻，都触发
- 审计结果不影响 finishing 的分流判断

### 2.3 JSONL 预处理

会话 JSONL 可能很大（6MB+），不能直接塞给子 agent。领审员第一步用脚本提取精简的对话摘要：

| 提取什么 | 给谁用 |
|---------|--------|
| 用户消息原文 | 两个子 agent |
| AI 回复中被用户否定/纠正的部分 | 效果满意度 |
| skill 调用记录（哪些 skill 被触发、什么顺序） | 流程遵从度 |
| tool_use 记录（读了哪些治理文件、改了哪些文件） | 流程遵从度 |
| 阶段转换信号 | 两个子 agent |

JSONL 结构（每行一个 JSON 对象）：
- `type`: `user` / `assistant` / `attachment` / `permission-mode` / `file-history-snapshot` / `system`
- `message.role`: `user` / `assistant`
- `message.content`: 字符串或数组（含 `text` / `tool_use` / `tool_result` / `thinking` 类型块）

预处理脚本用 Node.js 编写（项目环境已有 Node），提取后写入临时文件供子 agent 读取。

## 3. 子 agent 1：流程遵从度审计

### 3.1 输入

- 预处理后的对话摘要
- 所有治理文件（brainstorming-rules.md、design-rules.md、planning-rules.md、implementation-rules.md、review-rules.md、finishing-rules.md）
- CLAUDE.md 中的核心规则和回退规则

### 3.2 检查项

| 检查项 | 对照什么 | 从对话中找什么信号 |
|--------|---------|-----------------|
| brainstorming 是否执行 | brainstorming-rules.md | 是否有需求深挖对话、是否产出需求确认清单 |
| 需求确认后才进入设计 | brainstorming-rules.md 阶段四 | 用户是否显式确认需求清单 |
| 系统设计是否执行 | design-rules.md | 是否调用了 /system-design、是否产出设计文档 |
| 设计审查是否执行 | design-rules.md | 是否调用了 /design-review（轻量需求可跳过） |
| planning 是否基于设计文档 | planning-rules.md | writing-plans 时是否先读取设计文档 |
| 实现是否遵守行为约束 | implementation-rules.md | diff 中是否有与任务无关的变更、是否有过度工程化 |
| 文档是否先于代码更新 | implementation-rules.md | commit 中文档和代码是否同步 |
| 类型契约是否被遵守 | implementation-rules.md | 是否从共享类型文件 import |
| 回退规则是否被执行 | CLAUDE.md 回退规则 | 发现设计缺陷时是否回退到设计阶段 |
| RUBRIC 是否被参考 | 各阶段治理文件 | 各阶段是否读取了 RUBRIC.md |

### 3.3 输出格式

```markdown
## 流程遵从度

### 阶段覆盖
| 阶段 | 是否执行 | 备注 |
|------|---------|------|
| brainstorming | ✅/❌/⚠️ 部分 | [具体说明] |
| system-design | ... | ... |
| design-review | ... | ... |
| writing-plans | ... | ... |
| implementation | ... | ... |
| code-review | ... | ... |
| finishing | ... | ... |

### 规则违反
1. [哪条规则] — [什么行为违反了] — [对话中的证据]

### 规则遵守亮点
1. [哪条规则被良好执行] — [证据]

### 流程建议（仅记录，不执行）
- [观察到的流程摩擦点或可优化处]
```

## 4. 子 agent 2：效果与满意度审计

### 4.1 输入

- 预处理后的对话摘要
- evaluate 评分结果（docs/active/evaluation-result.md）
- 设计文档
- 最终代码 diff

### 4.2 信号识别

| 信号类型 | 怎么识别 | 含义 |
|---------|---------|------|
| 显式否定 | "不要"、"不对"、"别这样"、"重新来" | 用户对 AI 产出不满 |
| 重复请求 | 用户就同一件事发了 2+ 条消息，措辞递进 | AI 没理解或没做到位 |
| 用户接管 | 用户直接给出代码/方案而非描述需求 | AI 的方案不被信任 |
| 方向推翻 | evaluate 结果为"推翻"、用户说"换个方向" | 方向性失败 |
| 精磨轮次 | finishing 被触发的次数 | 轮次越多，一次性做对的能力越差 |
| 显式满意 | "好"、"对"、"就这样"、"完美" | 正向信号 |
| 沉默接受 | AI 产出后用户直接给下一个指令，无纠正 | 中性偏正向 |

### 4.3 归因分析

发现不满意信号后，归因到流程/skill 层面（不归因到用户或 AI 个体）：

| 不满意现象 | 可能的流程归因 |
|-----------|--------------|
| 需求理解偏差导致返工 | brainstorming 阶段深挖不够、需求清单不精确 |
| 设计方向被推翻 | design-review 未拦截、RUBRIC 标准不够具体 |
| 过度工程化被纠正 | implementation-rules 行为约束未生效 |
| 代码风格不一致 | review-rules 未检查、ARCHITECTURE 描述不够细 |
| 文档与代码脱节 | implementation-rules 文档先行未执行 |
| 多轮精磨才通过 | evaluate 标准与用户期望不对齐 |
| AI 跳过了某个流程步骤 | 治理文件中该步骤的强制性不够明确 |

### 4.4 输出格式

```markdown
## 效果与满意度

### 量化指标
| 指标 | 值 |
|------|-----|
| 用户显式否定次数 | N |
| 用户重复请求次数 | N |
| 用户接管次数 | N |
| 精磨轮次 | N |
| evaluate 最终得分 | X.X/10 |
| 用户显式满意次数 | N |

### 不满意事件清单
1. **[事件描述]**
   - 对话证据：[用户原话摘录]
   - AI 当时的行为：[AI 做了什么]
   - 归因：[哪个流程/skill/治理规则的问题]
   - 严重程度：🔴 高 / 🟡 中 / 🟢 低

### 满意事件清单
1. **[事件描述]**
   - 对话证据：[用户原话]
   - 归因：[哪个流程/skill 起了作用]

### 效果建议（仅记录，不执行）
- [观察到的效果问题和可能的优化方向]
```

## 5. 领审员汇总报告

### 5.1 报告模板

```markdown
# 流程审计报告

> 本报告由 process-audit 自动生成，供 harness 开发者优化流程使用。
> 不触发任何自动修改。

## 元信息
- 项目：[项目名称]
- 审计时间：[YYYY-MM-DD HH:MM]
- 触发节点：finishing — [通过/精磨/推翻]
- 会话数量：[本次审计覆盖的 JSONL 文件数]
- 功能名称：[当前功能]

## 一、流程遵从度
[子 agent 1 的完整输出]

## 二、效果与满意度
[子 agent 2 的完整输出]

## 三、综合发现

### 高优先级问题（建议 harness 开发者优先处理）
1. [问题] — 来源：[流程遵从度/效果满意度] — 影响：[描述]

### 模式识别（跨多次审计才有意义）
- [如果 docs/audits/ 下已有历史报告，对比指出重复出现的问题]

## 四、原始数据引用
- 会话文件：[列出读取的 JSONL 路径]
- 过程产物：[列出读取的设计文档、评估结果等路径]
```

### 5.2 存储

- 路径：`docs/audits/audit-YYYY-MM-DD-HHMMSS.md`
- `docs/audits/` 目录只做积累，不自动清理
- 领审员在写入前检查历史报告，在"模式识别"节标注重复出现的问题

### 5.3 错误处理

- 某个子 agent 失败：该维度标记"⚠️ 未完成"，另一个维度正常输出
- 两个子 agent 都失败：写入最小报告（仅元信息 + 失败原因），标注"⚠️ 审计未完成"
- 审计整体失败不阻断 finishing 流程

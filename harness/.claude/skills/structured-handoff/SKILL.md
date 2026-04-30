---
name: structured-handoff
description: "结构化交接。上下文快满或 finishing 阶段触发。按固定模板更新 handoff.md，归档旧版本到 docs/completed/。"
---

# 结构化交接

> 灵感来源：Hermes Agent 的 Context Compressor 结构化摘要模板。
> 核心思想：自由格式的交接文档质量不稳定，固定结构让新会话恢复上下文更可靠。

## 触发时机

- finishing 阶段（无论 evaluate 结果如何——通过、精磨、推翻都要更新交接）
- 上下文快满、准备 `/clear` 前
- 用户手动调用 `/structured-handoff`

## 当前交接文档

!`cat docs/active/handoff.md 2>/dev/null || echo "无交接文档"`

## 当前分支和改动

!`git branch --show-current 2>/dev/null || echo "未知"`

!`git log --oneline -5 2>/dev/null || echo "无 git 历史"`

---

## 执行流程

### 第一步：归档旧版本

如果 `docs/active/handoff.md` 内容不是初始模板（包含"[待更新]"则视为初始模板），将其归档：

```bash
# 生成时间戳文件名
cp docs/active/handoff.md "docs/completed/handoff-$(date +%Y%m%d-%H%M%S).md"
```

归档文件存入 `docs/completed/`，供 session-search 技能检索。

### 第二步：收集信息

从当前会话上下文中收集以下信息：

1. **目标**：本次会话要完成什么
2. **进度**：
   - 已完成的工作（含具体文件路径、命令、结果）
   - 进行中的工作
   - 阻塞项
3. **关键决策**：做了什么技术决策，为什么
4. **涉及文件**：读过、改过、创建过的文件清单
5. **下一步**：接下来该做什么
6. **关键上下文**：具体的值、错误信息、配置细节——不记下来就会丢失的信息

### 第三步：按模板写入

用以下**固定结构**覆盖 `docs/active/handoff.md`：

```markdown
# 工作交接文档

> 只保留当前状态，给"下一个 AI"看。SessionStart hook 自动注入。
> 详细设计在 docs/superpowers/specs/，实现计划在 docs/superpowers/plans/。
> 里程碑历史在 docs/PROGRESS.md。

更新时间：{YYYY-MM-DD HH:MM}

## 目标

{当前要完成什么——一两句话}

## 进度

### 已完成
{已完成的工作，含具体文件路径和关键命令}
- [文件/模块] — [做了什么]

### 进行中
{当前正在做的事}

### 阻塞
{遇到的阻塞项，如果没有写"无"}

## 关键决策

{做过的技术决策和原因}
- [决策] — 因为 [原因]

## 涉及文件

{本次会话涉及的文件，按重要性排序}
- `path/to/file` — [读/改/创建] — [简述]

## 下一步

1. {接下来最优先做的事}
2. {其次}

## 关键上下文

{不记下来就会丢失的具体值、错误信息、配置细节}

## 当前阶段

{brainstorming / writing-plans / subagent-driven-development / requesting-code-review / finishing}

## 当前分支

{分支名和状态}

## 已知问题

{当前存在的问题，如果没有写"无"}
```

### 写入规则

- **具体优于概括**：写 `src/api/auth.ts 的 validateToken()` 而不是 "改了认证模块"（用函数名/类名定位，不用行号——行号会随代码改动失效）
- **保留关键值**：错误信息、端口号、版本号、环境变量名——这些丢了新会话就得重新查
- **不写废话**：不要写"本次会话进展顺利"这种没有信息量的话
- **不含敏感信息**：不写密钥、token、密码
- **一屏以内**：整个文档控制在 80 行以内，超了就精简低优先级内容

### 第四步：确认

写入后读取一遍 `docs/active/handoff.md`，确认：
1. 结构完整（所有 section 都有内容，没有遗留 `{placeholder}`）
2. 文件路径真实存在
3. 没有敏感信息
4. 行数不超过 80（用 `wc -l < docs/active/handoff.md` 检查），超出则精简低优先级内容

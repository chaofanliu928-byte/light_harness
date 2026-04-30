---
name: session-search
description: "跨会话知识检索。在 brainstorming 阶段或需要历史上下文时使用。搜索归档交接文档、评估结果、决策记录，返回相关历史上下文。"
---

# 跨会话知识检索

> 灵感来源：Hermes Agent 的 SQLite FTS5 Session Search 系统。
> 核心思想：历史会话的细节不应随 /clear 消失，归档文档是可检索的项目记忆。
> 适配方式：Hermes 用 SQLite FTS5 存完整对话，我们用 Grep 工具搜索结构化归档文档——更轻量，不依赖额外基础设施。
> 能力边界：只搜索归档到 docs/ 中的结构化文档，不包含完整对话记录。只支持精确子串匹配，不支持模糊匹配或语义搜索。搜索质量取决于 structured-handoff 的归档质量。

## 触发时机

- brainstorming 阶段（自动：检查是否有相关历史经验）
- 用户手动调用 `/session-search {关键词}`
- 开始新功能前，想了解之前类似工作的上下文

## 数据来源

检索以下目录中的 `.md` 文件：

| 目录 | 内容 | 优先级 |
|------|------|--------|
| `docs/completed/` | 归档的交接文档和评估结果 | 高 |
| `docs/decisions/` | 架构决策记录 | 高 |
| `docs/PROGRESS.md` | 里程碑时间线 | 中 |
| `docs/references/` | 参考资料和提取的知识 | 中 |
| `docs/product-specs/` | 功能规格 | 低 |

!`ls docs/completed/ 2>/dev/null | head -20 || echo "无归档文档（structured-handoff 会在每次交接时归档）"`

!`ls docs/decisions/ 2>/dev/null | grep -v _TEMPLATE || echo "无决策记录"`

---

## 执行流程

### 第一步：确定搜索关键词

如果是 brainstorming 阶段自动触发：
- 从当前讨论的需求中提取 2-3 个核心关键词
- 关键词应覆盖：功能领域、技术方案、涉及模块

如果是用户手动调用：
- 直接使用用户提供的关键词

### 第二步：搜索

使用 Grep 工具按优先级依次搜索各数据源。**不要用 Bash 执行 grep 命令，必须使用 Grep 工具。**

**高优先级**：
- Grep 工具搜索 `docs/completed/`，`output_mode: files_with_matches`
- Grep 工具搜索 `docs/decisions/`，`output_mode: files_with_matches`

**中优先级**：
- Grep 工具搜索 `docs/PROGRESS.md`，`output_mode: files_with_matches`
- Grep 工具搜索 `docs/references/`，`output_mode: files_with_matches`

**低优先级**：
- Grep 工具搜索 `docs/product-specs/`，`output_mode: files_with_matches`

对每个命中的文件，再用 Grep 工具获取上下文（`output_mode: content`，`-C: 3`）。

**多关键词策略**：先用 AND（所有关键词都命中的文件），结果不足时回退到 OR（逐个关键词分别搜索）。

### 第三步：整理结果

**最多呈现 5 个最相关的文件。** 超出时按目录优先级（completed > decisions > references > product-specs）排序，只列文件名。

对每个呈现的文件，提取：

1. **文件名和类型**（交接归档 / 决策记录 / 参考文档）
2. **时间**（从文件名或内容中的时间戳）
3. **相关段落**（匹配行 ± 3 行上下文）
4. **摘要**（用一句话概括这个文件和当前搜索的关联）

### 第四步：输出

按以下格式输出检索结果：

```
## 历史上下文检索结果

搜索关键词：{keywords}
命中文件：{N} 个

### 1. {文件名} ({类型}, {时间})

**关联摘要**：{一句话说明和当前需求的关系}

**相关内容**：
> {匹配的关键段落}

### 2. ...

---

### 建议

{基于历史上下文，对当前工作的建议。例如：}
- "上次做类似功能时在 X 上踩了坑，建议提前考虑"
- "已有决策 ADR-003 约束了 Y 的实现方式"
- "docs/references/z.md 有相关的集成指南"
```

### 无结果时

如果没有命中任何文件：
1. 说明搜索了哪些目录
2. 确认 `docs/completed/` 是否为空（可能是新项目，还没有归档）
3. **冷启动降级**：如果 `docs/completed/` 为空，尝试搜索 `docs/superpowers/specs/` 和 `docs/superpowers/plans/` 中的历史设计文档作为替代数据源
4. 正常继续后续流程，不阻塞

## 与 brainstorming 的集成

当从 brainstorming 阶段自动触发时：
- 检索结果作为额外上下文注入 brainstorming
- 不需要用户确认，直接把相关历史融入讨论
- 如果没有命中，静默跳过，不打断 brainstorming 流程

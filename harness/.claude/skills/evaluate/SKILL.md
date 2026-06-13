---
name: evaluate
description: "方向评估。当 Superpowers 的 finishing-a-development-branch 完成、功能分支准备合并时自动触发。判断方向是否正确、是否需要推翻。"
invocation: auto
allowed-tools: Read, Glob, Grep, Bash, Write, Agent
---

# 方向评估

> 你不是 Superpowers 的 code-review。你是更高层的方向判断。
> **架构**:扁平 fork(2026-04-16 改造)。你(调度者)= 领审员,直接并行 fork 4 个挑战者,挑战者在独立 context。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 项目评分标准

!`cat docs/RUBRIC.md 2>/dev/null || echo "⚠️ 缺少项目评分标准"`

## 架构规范

!`cat docs/ARCHITECTURE.md 2>/dev/null || echo "⚠️ 无架构规范"`

## 历史评估(分数趋势)

!`cat docs/active/evaluation-result.md 2>/dev/null || echo "首轮评估,无历史数据"`

## Superpowers 设计文档

!`f=$(ls -t docs/superpowers/specs/*-design.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无设计文档"`

## Superpowers 实现计划

!`f=$(ls -t docs/superpowers/plans/*.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无实现计划"`

---

## 执行

按 `.claude/agents/evaluator.md` 的指令执行评估。关键步骤:

1. **第二步:并行 fork 4 个挑战者** — 用 Agent 工具,subagent_type: general-purpose,在**一条消息**中发起 4 个调用(RUBRIC 合规 / 架构一致性 / 文档健康 / Slop 检测)。每个挑战者的 prompt 从 evaluator.md 中取,把相关的 RUBRIC / ARCHITECTURE / 设计文档 / 代码变更**嵌入 prompt** 传给挑战者(挑战者看不到本对话上下文)
2. **第三步:综合** — 共识 / 分歧 / 盲区
3. **第四-七步:推导评分 + 通过判定 + 方向判断 + 人工介入信号**
4. **第八步:写入 `docs/active/evaluation-result.md`**

不使用 `context: fork` 启动领审员——本 skill 在主对话执行,主对话就是领审员。

> **evidence depth 档位引导**:挑战者按改动类别引相应 evidence depth 文件:
> - 代码改动 → `docs/references/testing-standard.md`(L1-L4)
> - 治理改动 → `docs/governance/credentials-rules.md` §7 证据档位表(治理列)
> - 混合改动 → 双引(代码列 + 治理列 各列出)

## 对抗式挑战者 prompt 模板(治理面改动审查时嵌入)

> 维度选择权威 = docs/governance/review-rules.md「审查维度选择表」;治理面改动审查产 audit 凭证(credentials-rules)
>
> 治理面改动(命中 credentials.conf include glob)的审查走本模板:调度者在第二步 fork 挑战者**之前**,把下列 A/B/C 三段嵌入每个挑战者 prompt。

A. 推荐维度清单(按 agent 默认填,markdown 列表)
   格式:`- [维度名]: [关注焦点] [默认启用: 是/否]`

B. 最低必选维度(禁止删减,markdown 列表)
   格式:`- [维度名]: [不可省略理由]`
   bootstrap 4 维基线(任何治理面改动必须包含;权威 = review-rules 维度选择表):
     - 核心原则合规
     - 目的达成度
     - 副作用
     - scope 漂移

C. 定制理由字段(结构化)
   ### 本次定制
   - 启用的推荐维度: [列表]
   - 禁用的推荐维度 + 理由: [列表](禁用 minimum 项需用户确认)
   - 新增的定制维度 + 理由: [列表]

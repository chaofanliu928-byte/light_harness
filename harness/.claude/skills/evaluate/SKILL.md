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

> **scope 参数传递引导(spec 第七轮 fix-6 — 永远生效)**:
>
> 调度者在第二步 fork 挑战者**之前**,按 spec §3.1.1 识别本次改动的 scope(`feature` / `meta` / `mixed`),并把 `scope` 参数传给每个挑战者 prompt(配合 I5.2 evaluator.md 内 4 挑战者 prompt 的 scope 分流字段)。
>
> 挑战者按 scope 引相应 evidence depth 文件:
> - `scope=feature` → `docs/references/testing-standard.md`(L1-L4)
> - `scope=meta` → `docs/governance/meta-finishing-rules.md`(meta-L1~meta-L4)
> - `scope=mixed` → 双引(meta-L + L 各列出)
>
> 下游项目大多数情况 scope=feature(下游无 meta-* 文件)。
>
> **scope=meta 时的 §3.1.7 runtime 嵌入引导**(仅在 harness 自身仓库,且调度者按 spec §3.1.1 识别本次改动 scope=meta 或 mixed 的 meta 部分时触发):
>
> 调度者在第二步 fork 挑战者**之前**,按 spec §3.1.7 runtime 嵌入契约**手工** Read 下列治理文件必要节,把内容嵌入每个挑战者 prompt 的 A/B/C 三段(对抗式模板):
>
> - **M2** `harness/docs/governance/meta-review-rules.md` 第 6 节"对抗式 agent prompt 模板"子节(A 推荐维度 / B 最低必选 bootstrap 4 维基线 / C 定制理由)
> - **M1** `harness/docs/governance/meta-finishing-rules.md` 必要节(包含 evidence depth meta-L1~meta-L4,scope=meta 路径下嵌入)
>
> 不新增 `!` 注入读取 M2(B5 / D3 决策):`!` 注入在下游 skill 执行时也会运行,M2 在下游不存在(M14 命名前缀过滤),会返回空且语义模糊。**调度者手工 Read + 嵌入**更清晰。
>
> **下游兼容性**:scope=meta 是 harness 自身仓库的 bootstrap 场景;下游项目执行 `/evaluate` 时,调度者识别 scope=feature(下游无 meta-* 文件,自然不会进入 meta 路径),本节 meta 嵌入引导**条件化跳过**,行为完全不变(spec §3.1.4 兼容性声明 B6)。
>
> 详见 spec §3.1.7 runtime 嵌入契约 + spec §3.1.6 agent 文件静态约束节(第七轮 fix-2 防下游污染)+ 第七轮 fix-6 scope 分流。

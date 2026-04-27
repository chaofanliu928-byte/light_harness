---
name: process-audit
description: "流程审计。finishing 阶段 evaluate 和 structured-handoff 之后触发。扁平 fork 2 个独立挑战者审计 AI 对流程的遵从度和用户满意度,记录到 docs/audits/,不自动优化。"
invocation: auto
allowed-tools: Read, Glob, Grep, Bash, Write, Agent
---

# 流程审计

> 你不是 evaluator(方向评估),也不是 code-reviewer。
> 你是 harness 流程本身的审计员——审计流程有没有被遵守、效果好不好。
> **架构**:扁平 fork(2026-04-16 改造)。主对话 = 领审员,直接并行 fork 2 个挑战者,每个在独立 context。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 项目评分标准

!`cat docs/RUBRIC.md 2>/dev/null || echo "⚠️ 缺少项目评分标准"`

## 方向评估结果

!`cat docs/active/evaluation-result.md 2>/dev/null || echo "无评估结果"`

## 设计文档

!`f=$(ls -t docs/superpowers/specs/*-design.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无设计文档"`

## 实现计划

!`f=$(ls -t docs/superpowers/plans/*.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无实现计划"`

## 历史审计报告

!`ls -t docs/audits/audit-*.md 2>/dev/null | head -5 || echo "无历史审计报告"`

## 治理文件索引

!`ls docs/governance/*.md 2>/dev/null || echo "无治理文件"`

---

## 执行

按 `.claude/agents/process-auditor.md` 的指令执行审计。关键步骤:

1. **第一步:收集输入** — 读 RUBRIC / evaluation-result / 设计文档 / 实现计划 / 历史审计
2. **第二步:预处理会话 JSONL** — 定位项目目录,用 Node.js 脚本提取摘要到 `/tmp/process-audit-summaries/`
3. **第三步:并行 fork 2 个挑战者** — 用 Agent 工具,subagent_type: general-purpose,**一条消息**发起 2 个调用(流程遵从度 / 效果满意度)。提示词和路径从 process-auditor.md 取,**嵌入**每个挑战者 prompt
4. **第四步:汇总报告** — 合并两个维度,对比历史报告找重复问题
5. **第五步:写入 `docs/audits/audit-YYYY-MM-DD-HHMMSS.md`**

当前功能的 finishing 结果由调度者在触发时告知。不使用 `context: fork` 启动领审员——本 skill 在主对话执行,主对话就是领审员。

> **事实统计式 agent — 仅引 M2 G 段粒度细化**:
>
> 本 skill 对应 M9 事实统计式 agent(spec D2)。事实统计式**不需要对抗模板**(不引 A/B/C 三段),固定 N1 流程遵从度 + N2 效果满意度二维分工由 process-auditor.md 静态承载。
>
> **scope=meta 时的 §3.1.7 runtime 嵌入引导**(仅在 harness 自身仓库,且调度者按 spec §3.1.1 识别本次改动 scope=meta 时触发):
>
> 调度者在第三步 fork 挑战者**之前**,按 spec §3.1.7 runtime 嵌入契约**手工** Read 下列治理文件必要节,把内容嵌入每个挑战者 prompt 的 G 段(可选粒度细化):
>
> - **M2** `harness/docs/governance/meta-review-rules.md` 第 6 节"事实统计式 agent prompt 模板"子节内的 **G 段(调度者按主题细化粒度)**:
>   - 范围:全 session / 本批次 / 时间窗口
>   - 维度细化:N1/N2 维度内的子项
> - 不引"对抗式 agent prompt 模板"子节(A 推荐 / B 最低必选 / C 定制理由 — 事实统计式不需对抗模板)
> - 不引"混合式 agent prompt 模板"子节(同理)
>
> 不新增 `!` 注入读取 M2(B5 / D3 决策):`!` 注入在下游 skill 执行时也会运行,M2 在下游不存在(M14 命名前缀过滤),会返回空且语义模糊。**调度者手工 Read + 嵌入**更清晰。
>
> **下游兼容性**:scope=meta 是 harness 自身仓库的 bootstrap 场景;下游项目执行 `/process-audit` 时,调度者识别 scope=feature(下游无 meta-* 文件,自然不会进入 meta 路径),本节 G 段嵌入引导**条件化跳过**,固定 N1/N2 二维分工不变,行为完全不变(spec §3.1.4 兼容性声明 B6)。
>
> 详见 spec §3.1.7 runtime 嵌入契约 + spec §3.1.6 agent 文件静态约束节(第七轮 fix-2 防下游污染)。

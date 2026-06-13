---
name: process-audit
description: "流程审计。finishing 阶段 evaluate 之后、分流之前触发。扁平 fork 1 个独立挑战者审计 AI 对流程的遵从度,记录到 docs/audits/,不自动优化。"
invocation: auto
allowed-tools: Read, Glob, Grep, Bash, Write, Agent
---

# 流程审计

> 你不是 evaluator(方向评估),也不是 code-reviewer。
> 你是 harness 流程本身的审计员——审计流程有没有被遵守、效果好不好。
> **架构**:扁平 fork(2026-04-16 改造)。主对话 = 领审员,直接 fork 1 个挑战者,在独立 context。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

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
3. **第三步:fork 1 个挑战者** — 用 Agent 工具,subagent_type: general-purpose,发起 1 个调用(流程遵从度)。提示词和路径从 process-auditor.md 取,**嵌入**挑战者 prompt
4. **第四步:汇总报告** — 整理 N1 维度,对比历史报告找重复问题
5. **第五步:写入 `docs/audits/audit-YYYY-MM-DD-HHMMSS.md`**

当前功能的 finishing 结果由调度者在触发时告知。不使用 `context: fork` 启动领审员——本 skill 在主对话执行,主对话就是领审员。

## 事实统计式挑战者 prompt 模板(治理面改动审查时嵌入)

> 维度选择权威 = docs/governance/review-rules.md「审查维度选择表」;治理面改动审查产 audit 凭证(credentials-rules)
>
> 本 skill 是事实统计式 agent:**不需要对抗模板**(不引 A/B/C 三段),固定 N1 流程遵从度单维分工由 process-auditor.md 静态承载。治理面改动审查时,调度者在第三步 fork 挑战者**之前**,把下列模板嵌入挑战者 prompt(G 段可选粒度细化)。

N1. 流程遵从度(固定维度,可细化粒度)
G.  调度者按主题细化粒度(可选)
    ### 本次粒度细化
    - 范围: [全 session / 本批次 / 时间窗口]
    - 维度细化: [每维度内的子项]

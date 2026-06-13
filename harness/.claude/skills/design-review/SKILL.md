---
name: design-review
description: "设计审查。系统设计完成后触发。扁平 fork 4 个独立挑战者从自洽性、完整性、合理性、RUBRIC 对齐四个维度审查设计文档。"
invocation: manual
allowed-tools: Read, Glob, Grep, Bash, Write, Agent
---

# 设计审查

> **架构**:扁平 fork(2026-04-16 改造)。主对话 = 领审员,直接并行 fork 4 个挑战者,每个在独立 context。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 输入

!`f=$(ls -t docs/superpowers/specs/*-design.md 2>/dev/null | head -1); [ -n "$f" ] && echo "设计文档: $f" && cat "$f" || echo "无设计文档"`

!`cat docs/RUBRIC.md 2>/dev/null || echo "无评分标准"`

!`cat docs/ARCHITECTURE.md 2>/dev/null || echo "无架构规范"`

---

## 执行

按 `.claude/agents/design-reviewer.md` 的指令执行审查。关键步骤:

1. **第一步:并行 fork 4 个挑战者** — 用 Agent 工具,subagent_type: general-purpose,**一条消息**发起 4 个调用(自洽性 / 完整性 / 过度工程化 / RUBRIC 对齐)。每个挑战者的 prompt 从 design-reviewer.md 中取,**完整嵌入**设计文档 / RUBRIC / ARCHITECTURE(挑战者看不到本对话上下文)
2. **第二步:汇总** — 共识 / 分歧 / 盲区,去重升级
3. **第三步:判定** — 通过 / 需修复后重审
4. **第四步:写入 `docs/active/design-review-result.md`**

不使用 `context: fork` 启动领审员——本 skill 在主对话执行,主对话就是领审员。

## 对抗式挑战者 prompt 模板(治理面改动审查时嵌入)

> 维度选择权威 = docs/governance/review-rules.md「审查维度选择表」;治理面改动审查产 audit 凭证(credentials-rules)
>
> 治理面改动(命中 credentials.conf include glob)的审查走本模板:调度者在第一步 fork 挑战者**之前**,把下列 A/B/C 三段嵌入每个挑战者 prompt。

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

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

> **运行时分支(review-scout 主推 + 老 4 维显式回落 — Y,不替换、不重建 X;spec §1.2/§2.2/D13/D-A4;2026-06-15 主次定调)**:
> 进入执行先做一次运行时探测——**Workflow/ultracode 工具是否可用**:
>
> - **可用(ultracode 开)→ 走 review-scout 路(主推审查路)**:调度者用 Workflow 工具启动 `review-scout`,入参
>   `{reviewType:'design', targets:{spec:<最新 *-design.md 路径>, rubric:'docs/RUBRIC.md', architecture:'docs/ARCHITECTURE.md', decisionsDir:'docs/decisions/', auditsDir:'docs/audits/'}, sessionIntent:'<一行会话意图,措辞中性>'}`。
>   workflow 返回 `{plan, findings}`。**scout 路综合维序说明(钉死此处,单一住址 — spec §3.5)**:scout 路维度由 `plan` 动态定,综合维序 = **按 plan 产出的维度清单顺序**交叉读 findings(**不用** synthesis-rules L151 固定 4 维序,L151 服务下面现有 4 维路)。综合仍按 synthesis-rules 事后规则(回意图/决策/客观/避先入为主 + 校验「已对照用户原话」section),写 `docs/active/design-review-result.md`。
>   - scout 空返回/审查失败(`plan:null`)→ **显式报用户审查失败**(按本 skill 错误处理重试);**不静默回落现有 4 维路**(scout 失败 ≠ ultracode 不在场 — spec §5.1)。
> - **不可用(ultracode 关 / 非 Claude Code / 逐会话未 opt-in)→ 回落到下面现有固定 4 维 design-review 流程,原样执行**(**仅在 review-scout 不可用时才走的显式回落路**;完整保留、不退役、不标"降级执行" — spec §5.1/D13)。scout 是主推路;其动态推维在此回落路不可得 = ultracode 专属取舍(D13)。

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

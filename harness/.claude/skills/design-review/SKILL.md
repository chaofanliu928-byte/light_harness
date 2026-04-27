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

> **scope=meta 时的 §3.1.7 runtime 嵌入引导**(仅在 harness 自身仓库,且调度者按 spec §3.1.1 识别本次改动 scope=meta 时触发):
>
> 调度者在第一步 fork 挑战者**之前**,按 spec §3.1.7 runtime 嵌入契约**手工** Read 下列治理文件必要节,把内容嵌入每个挑战者 prompt 的 A/B/C 三段(对抗式模板):
>
> - **M2** `harness/docs/governance/meta-review-rules.md` 第 6 节"对抗式 agent prompt 模板"子节(A 推荐维度 / B 最低必选 bootstrap 4 维基线 / C 定制理由)
> - **M1** `harness/docs/governance/meta-finishing-rules.md` 必要节(若涉及 evidence depth 等)
>
> 不新增 `!` 注入读取 M2(B5 / D3 决策):`!` 注入在下游 skill 执行时也会运行,M2 在下游不存在(M14 命名前缀过滤),会返回空且语义模糊。**调度者手工 Read + 嵌入**更清晰。
>
> **下游兼容性**:scope=meta 是 harness 自身仓库的 bootstrap 场景;下游项目执行 `/design-review` 时,调度者识别 scope=feature(下游无 meta-* 文件,自然不会进入 meta 路径),本节引导**条件化跳过**,行为完全不变(spec §3.1.4 兼容性声明 B6)。
>
> 详见 spec §3.1.7 runtime 嵌入契约 + spec §3.1.6 agent 文件静态约束节(第七轮 fix-2 防下游污染)。

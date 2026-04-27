---
name: security-scan
description: "提交前安全扫描。finishing 阶段 evaluate 之前触发。扁平 fork 3 个独立挑战者扫描 git diff,检测凭证泄露、危险操作、prompt 注入、数据外泄风险。"
allowed-tools: Read, Glob, Grep, Bash, Write, Agent
---

# 安全扫描

> **架构**:扁平 fork(2026-04-16 改造)。主对话 = 领审员,直接并行 fork 3 个挑战者,每个在独立 context。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 扫描范围

!`git diff $(git rev-parse --verify main 2>/dev/null || git rev-parse --verify master 2>/dev/null || echo HEAD~10)...HEAD --name-only 2>/dev/null || echo "无法获取变更文件列表"`

---

## 执行

按 `.claude/agents/security-reviewer.md` 的指令执行扫描。关键步骤:

1. **第一步:获取变更文件列表** — 过滤出需要扫描的文本文件
2. **第二步:并行 fork 3 个挑战者** — 用 Agent 工具,subagent_type: general-purpose,**一条消息**发起 3 个调用(凭证数据 / 危险操作 / 注入混淆)。变更文件列表和提示词从 security-reviewer.md 取,**嵌入**每个挑战者 prompt
3. **第三步-四步:汇总 + 判定** — Critical 不通过,High 警告,Medium 通过
4. **第五步:写入 `docs/active/security-scan-result.md`**

不使用 `context: fork` 启动领审员——本 skill 在主对话执行,主对话就是领审员。凭证扫描挑战者失败时**必须**重试或降级手动扫描。

> **混合式 agent — 仅对抗维度部分加 M2 引用**:
>
> 本 skill 对应 M8 混合式 agent(spec D2)。**硬编码扫描部分**(凭证 / 数据 / 危险操作 / 注入 pattern grep,Critical / High / Medium 标级)由 security-reviewer.md 静态承载,执行步骤**不变**(凭证扫描挑战者失败必须重试或降级手动扫描的现行约束保留)。
>
> **仅对抗维度部分**(扫描后的"场景判定 / 风险等级判定")在 scope=meta 时按下列引导:
>
> **scope=meta 时的 §3.1.7 runtime 嵌入引导**(仅在 harness 自身仓库,且调度者按 spec §3.1.1 识别本次改动 scope=meta 时触发):
>
> 调度者在第二步 fork 挑战者**之前**,按 spec §3.1.7 runtime 嵌入契约**手工** Read 下列治理文件必要节,把内容嵌入每个挑战者 prompt 的对抗维度段(混合式模板的 A/B/C):
>
> - **M2** `harness/docs/governance/meta-review-rules.md` 第 6 节"混合式 agent prompt 模板"子节(X 凭证/数据扫描 pattern 引用 + A 推荐对抗维度 + B 最低必选对抗维度 — 凭证泄露场景判定永远不可绕 + C 定制理由)
> - **M1** `harness/docs/governance/meta-finishing-rules.md` 必要节
>
> 不新增 `!` 注入读取 M2(B5 / D3 决策):`!` 注入在下游 skill 执行时也会运行,M2 在下游不存在(M14 命名前缀过滤),会返回空且语义模糊。**调度者手工 Read + 嵌入**更清晰。
>
> **下游兼容性**:scope=meta 是 harness 自身仓库的 bootstrap 场景;下游项目执行 `/security-scan` 时,调度者识别 scope=feature(下游无 meta-* 文件,自然不会进入 meta 路径),本节 meta 嵌入引导**条件化跳过**,行为完全不变(spec §3.1.4 兼容性声明 B6)。**硬编码扫描部分(凭证 / 数据 / 危险 / 注入 pattern)在所有 scope 下行为一致**。
>
> 详见 spec §3.1.7 runtime 嵌入契约 + spec §3.1.6 agent 文件静态约束节(第七轮 fix-2 防下游污染)。

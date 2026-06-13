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

## 混合式挑战者 prompt 模板(治理面改动审查时嵌入)

> 维度选择权威 = docs/governance/review-rules.md「审查维度选择表」;治理面改动审查产 audit 凭证(credentials-rules)
>
> 本 skill 是混合式 agent:**硬编码扫描部分**(凭证 / 数据 / 危险操作 / 注入 pattern grep,Critical / High / Medium 标级)由 security-reviewer.md 静态承载,执行步骤**不变**(凭证扫描挑战者失败必须重试或降级手动扫描的现行约束保留),所有 scope 下行为一致。**仅对抗维度部分**(扫描后的"场景判定 / 风险等级判定")在治理面改动审查时按下列模板嵌入挑战者 prompt 的对抗维度段。

X. 凭证 / 数据扫描 pattern(硬编码,不变)
   格式同现 security-reviewer.md(pattern grep 列表 + Critical/High/Medium 标级)

A. 推荐对抗维度(仅在"扫描后场景判定"维度采用)
   例:凭证泄露的风险等级判定 / 危险操作的副作用范围

B. 最低必选对抗维度
   - 凭证泄露场景判定(混合式永远不可绕)

C. 定制理由字段(格式同对抗式 C 段)

# 决策: 删除 process-audit 效果满意度维度(N2)

**状态**:🟢 已决定(用户拍板,2026-06-04)

**日期**:2026-06-04

**关联功能**:harness 自治理(meta 层)— process-audit / meta-review

**类型**:移除型 decision(非方案选择型)

---

## 背景

本次会话对 harness 里"满意度"机制做了全量梳理(6-agent workflow + 完整性复核),结论:harness 里跟"满意度"沾边的其实是**三种不同的东西**,价值天差地别——

| | 是什么 | 存哪 | 有没有牙 | 方向 |
|---|---|---|---|---|
| **A 即时显式校准** | 用户当场"不要这样/这个对" | RUBRIC 项目特定标准(罚则/奖励) | 有(review-rules 拿它当 critical issue 卡) | 前向 |
| **B 事后情绪审计(N2)** | 从 JSONL 推断用户这轮爽不爽(7 信号) | docs/audits/ | 无(finishing-rules §13 明写不影响分流) | 后向 |
| **C 意图对齐** | 活儿对没对上用户原话 | 挑战者 `### 已对照用户原话` | 有(🔴 偏离触发返工) | 即时 |

B 的实证弱点:事后推断、混杂重(被模型质量/任务难度/心情共同决定,挑不出 harness 那一份)、不 gate 任何决策、**实际只落地过 1 次**(`audit-2026-04-28-133251.md`)。作为"效果证据"近乎无用,作为"流程 debug"ROI 极低。

## 决定

1. **删除 B**(process-audit N2 效果满意度维度),**一刀删,不留轻量残留**。
2. **两边一起删**:feature 级 process-audit 的 N2 + meta-review 自审复用的 N2 模板(`meta-review-rules.md` 事实统计式 agent 模板)。
3. **保留 A**(RUBRIC 渐进式积累)和 **C**(已对照用户原话意图对齐)——二者有牙、不可替代。
4. process-audit 从"2 挑战者(流程遵从度 + 效果满意度)"变为"**1 挑战者(仅流程遵从度 N1)**";skill 本身保留。

## 影响范围(meta-review 后精确化 — 已落地 9 文件)

经独立 designer 穷尽扫描 + 3 挑战者 meta-review(全 pass-after-revision),最终改动 9 个 LIVE 文件:

- `.claude/agents/process-auditor.md`(删 N2 挑战者整块 + JSONL "AI回复→效果满意度"抽取行 + L5/核心原则措辞 + "2 挑战者→1"架构 + 报告"二、效果与满意度"删除并重编号三→二/四→三)
- `.claude/skills/process-audit/SKILL.md`(description + fork 2→1 + N1/N2 二维→N1 单维 全收口)
- `docs/governance/synthesis-rules.md`(L18 表行 + L101 fork 列表,均 2→1)
- `docs/references/challenger-orientation.md`(§1.1 "13→12 挑战者" + §1.4 删挑战者2 情绪信号块)
- `docs/governance/meta-review-rules.md`(删 §6 模板 N2 行 + L150 "2 维→1 维(N1)")
- `docs/governance/model-route.md`(L50/L60/L142 "process-audit 2 挑战者→挑战者")
- `harness/CLAUDE.md`(M4)技能地图 L111("和用户满意度"去掉)
- 根 `README.md`(L109 "和用户满意度"去掉)
- `harness/README.md`(L179 "2 并行子智能体→1 子智能体" + L227 "遵从度 + 满意度→遵从度")

**meta-review 抓到、已规避的两个坑**:
1. 🔴 C3 JSONL 脚本:只删内层 assistant-text `if`(原 L140-142),保留外层 `if`/`for` + tool_use 抽取(否则 N1 命脉 JS 语法崩)。
2. 🔴 challenger-orientation §1.1 派生计数 13→12(设计者只点了 §1.4,漏了 §1.1)。

**确认勿动**:根 `CLAUDE.md`(无满意度描述,no-op)/ `finishing-rules.md:31`(N2 历史引用,留)/ `model-route.md:123`(security-scan 的 2 挑战者,非本次)/ A 段 RUBRIC 渐进式积累 / C 段已对照用户原话 / evaluator 精磨-推翻 verdict / docs/{decisions,audits,specs,plans} 历史留痕。

## 反向追问留痕(原理 5.4)

> "删了 B,原来的问题(系统性发现流程让用户不满)怎么解决?"

- 跨会话:`retrospective-guide.md` 触发器"用户感觉重复犯错" + `decision-trail.md` 触发字段(用户否决/红线)已覆盖大部分。
- 当场:用户显式反馈走 A(进 RUBRIC)。
- 丢掉的只是"事后系统性自动归因到具体 skill"——ROI 低(1 次落地),**接受不补**。

## 不做

- 不动 A(RUBRIC 渐进式积累);不动 C(已对照用户原话)。
- 不删 process-audit skill 本身(保留 N1 流程遵从度)。
- 不在本 decision 给逐文件 diff——那是 designer + meta-review 的工作。

## 后续

fork designer 出精确删除设计 → fork 挑战者 meta-review(重点查断链 / 漏改 / N1-only 后 process-audit 是否仍自洽)→ 实现 → finishing(M1 + M2)。

## 关联

- 本次会话(满意度三分类全量梳理 + 锐评核查)
- `memory/feedback_realworld_testing_in_other_projects.md`(B 在自仓库失真,实证只 1 次)
- `docs/governance/finishing-rules.md` §13(B 不 gate 分流的依据)

**签署**:用户 + Claude(调度者)

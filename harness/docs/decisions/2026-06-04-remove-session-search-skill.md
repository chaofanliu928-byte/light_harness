# 决策: 删除 session-search skill(继承靠 session-init,不靠 invoke-skill)

**状态**:🟢 已决定(用户拍板,2026-06-04)

**日期**:2026-06-04

**关联功能**:harness 功能层剪枝 — 跨会话知识检索

**类型**:移除型 decision

---

## 背景

功能层剪枝(继 N2 满意度之后)。session-search 是"跨会话知识检索"skill,也是 README 里**公设2(行动公设)的命名实现之一**("公设2 实现 = session-search skill + session-init hook")。

但实测它对用户真实需求是冗余的:

- **用户从不手动调用** `/session-search`,也没察觉过它的自动注入(用户原话:"基本没碰,没有注意他有没有自动注入")。
- **自动触发挂在 brainstorming 阶段,无 hook 强制** → 靠 AI 自觉,自动路径不可靠(违反"机械执法不靠自觉")。
- 用户需要的是**继承①(接着上次干 / 连续性)**,而这个**已由 `session-init.sh`(SessionStart hook,机械必跑)+ `structured-handoff` 机械提供**——这也是用户从没碰 session-search、项目却照样接得上的原因。
- session-search 真正想覆盖的是**继承②(自动召回相关旧经验)**,但它靠 invoke、不可靠;**用户明确只要①,不要②**(本次不新建②)。

引擎本质是"对 docs/ 跑 Grep + 排版 + 综合建议",AI 需要时可直接 grep。

## 决定

1. **删除 session-search skill**(删 `.claude/skills/session-search/SKILL.md`)。
2. **改写公设2 实现引用**:`session-search skill + session-init hook` → **`session-init hook(开头注入历史)+ 不确定时调度者直接 Grep/Read(行动公设本体)`**。公设2 本体是"做外部动作"的**行为**,不绑某个 skill,axiom 不受影响。
3. **brainstorming 自动触发集成段**:去掉对 session-search 的自动触发引用,**留一句**"需要深挖历史归档时,手动 grep `docs/{completed,decisions}`"。
4. **下游一并去除**:session-search 无 `meta-` 前缀、原本分发下游;删源文件即不再分发;确认下游 settings 模板 / 技能引用无残留(下游同样有 session-init,继承①照旧)。
5. **继承①** 由 `session-init` + `structured-handoff` 兜底,**不变**。

## 反向追问留痕(原理 5.4)

> "删了 session-search,原来的问题怎么解决?"

- **继承①(连续性)**:session-init 已机械提供(最新 handoff/eval/设计/计划)→ 不丢。
- **手动深查归档**:AI 直接 Grep `docs/completed`、`docs/decisions` → 能力不丢,只是不再是独立 skill。
- **公设2**:实现改挂 session-init + 行动公设本体(直接 Grep/Read)→ axiom 仍可落地。
- 丢的只是"自动召回旧经验(继承②)"——而它本就不可靠、用户也不要。

## 不做

- 不动 `session-init.sh` / `structured-handoff` / 公设2 本身。
- 不新建继承②(自动召回)——用户只要①。
- 不改写历史留痕(docs/{decisions,audits,specs,plans})。

## 后续

fork 独立 designer 穷尽扫 touchpoints → fork 挑战者 meta-review(查断链 / 公设2 改写自洽 / 下游残留)→ 实现 → finishing(M1 + M2)。

## 关联

- 本次会话(功能层剪枝讨论;继承①/②拆分)
- `docs/decisions/2026-06-04-remove-process-audit-satisfaction-n2.md`(同批功能剪枝,N2)
- `.claude/hooks/session-init.sh`(继承① 的真实承载)

**签署**:用户 + Claude(调度者)

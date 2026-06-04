# 决策: 剪枝批次 — 删 5 个死/冗余 hook(基础设施减负)+ 删 skill-extract(功能层)

**状态**:🟢 已决定(用户拍板,2026-06-04)

**日期**:2026-06-04

**关联功能**:harness 剪枝 — hook 基础设施 + 功能层

**类型**:移除型 decision(合并批次,两部分有交互)

---

## 背景

继 N2 + session-search 之后,用户要求一并做:① 基础设施减负(hook 层死/冗余代码)② 功能层剪枝 skill-extract。两者有交互(见下),合一批处理。

## 第一部分:基础设施减负(删 5 个 hook)

| 脚本 | 为什么删 | 反向追问"删了怎么办" |
|---|---|---|
| `check-meta-commit.sh`(~478 行) | 死孪生:git pre-commit 钩子但 `.git/hooks` 未装、settings 未注册、setup.sh 不 wire → 从没运行;check-meta-review.sh(Stop)已覆盖同覆盖检查 | Stop 侧 check-meta-review 兜住,零执法缺口 |
| `check-meta-cross-ref-commit.sh`(~142 行) | 死孪生,同上;check-meta-cross-ref.sh(Stop)已在 | 同上 |
| `meta-self-review-detect.sh`(~258 行) | 一次性 nag:绑死 2026-04-17 p0-9 spec,该 spec 早被反审 → 条件永假、永远空转 | bootstrap 用途已完成,删后无影响;删 + 从 settings.json SessionStart 摘注册 |
| `notify-done.sh` | 孤儿:settings.json + templates 都没注册 → 从不触发 | 删,无功能损失 |
| `check-finishing-skills.sh` | 软(exit 0 不拦)+ 冗余:交接新鲜度 check-handoff(硬)已管;唯一独有是提醒 skill-extract,而 skill-extract 本批也删 | 删 + 从 settings.json Stop 摘注册;软的 `## 目标` 模板检查本就无牙,structured-handoff 自会产出模板 |

**保留不动**:check-meta-review / check-meta-cross-ref / check-handoff / check-evidence-depth / session-init / check-module-docs(下游用)。**无真执法器受损。**

## 第二部分:功能层剪枝(删 skill-extract)

| 症状 | 证据 |
|---|---|
| **0 产出** | skill 注册表从无"提取出的新 skill"(N2/session-search 删前是原始 9 个,删后 8 个,无一是 skill-extract 产物) |
| 自承低优先 | finishing-rules 明确"不强求、无模式跳过" |
| 场景稀薄 | harness 自仓库以 meta 工作为主、无 feature 模式可提;5.5 规定 skill 不跨项目,提了也只能本地 |

**反向追问"删了怎么办"**:真有可复用模式时手动存(本就罕见);两个月 0 产出。

**删除范围**:skill 目录 + 引用(CLAUDE 技能地图、两份 README 技能枚举、finishing-rules 触发、setup.sh mkdir+cp、QUICKREF 若有);技能计数 **8→7**(session-search 批刚把 9→8,本批再 →7)。

## 两部分的交互

- `check-finishing-skills.sh`(第一部分删)唯一独有功能 = 提醒跑 skill-extract;skill-extract(第二部分删)一并消失 → **该提醒自然作废,无需迁移**。
- 两部分都碰 setup.sh,但不同段(hook 复制循环 vs skill 逐个 mkdir/cp),不冲突。

## 不做

- 不动保留的 hook、session-init、其它 skill。
- 不动历史留痕(docs/{decisions,audits,specs,plans})。

## 后续

fork 独立 designer 穷尽扫两条线 touchpoints → fork 挑战者 meta-review(查:settings.json JSON 仍合法 / 被删 hook 的文档引用断链 / skill 计数 8→7 全仓一致 / 无孤儿)→ 实现 → finishing(M1 + M2)。

## 关联

- `docs/decisions/2026-06-04-remove-process-audit-satisfaction-n2.md`(N2)
- `docs/decisions/2026-06-04-remove-session-search-skill.md`(session-search)
- 本次会话 hook 逐个讲解 + 功能剪枝讨论

**签署**:用户 + Claude(调度者)

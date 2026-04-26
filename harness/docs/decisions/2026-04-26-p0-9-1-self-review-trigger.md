# 决策: P0.9.1 落地后反审本 spec 的触发机制

> 由 P0.9.1 spec 第七轮 fix-8 创建,**升 🟡 待用户决定**;第八轮用户拍板 → 🟢 已决定。

**状态**:🟢 已决定(2026-04-26 第八轮用户拍板)

**日期**:2026-04-26

**关联功能**:P0.9.1 self-governance(spec §6.4 bootstrap 自洽验证 + §1.6 元警告)

## 问题

P0.9.1 spec §6.4 / §1.6 / §6.7 多处声明"P0.9.1 落地后必须用新机制(M2 pattern 节)反向审查本 spec",这是 bootstrap 闭环的关键:本 spec 当下用 4 维 ad-hoc 审查,落地后用新流程反审一次,作为 meta-L4 真实使用验证第一数据点。

但**触发机制空缺** — 即:P0.9.1 commit 进 main 后,什么机制提醒/强制反审本 spec?如果不强制,反审可能被遗漏,bootstrap 闭环无法验证。

第七轮 spec /design-review 第二轮 D2 完整性 + D3 副作用挑战者点出此缺口。

## 方案

### 方案 A:SessionStart hook 检测 + 注入提示

- **做法**:新增/扩展 SessionStart hook,检测以下两个条件同时成立时注入提醒:
  1. `git log` 中出现 P0.9.1 完成相关 commit(主题含 "P0.9.1" + 实施类标签)
  2. `docs/audits/` 不存在反审本 spec 的 audit(grep covers 字段含本 spec 路径)
- 满足两条件 → SessionStart 注入 system-reminder:"P0.9.1 已落地但未反审本 spec,建议用 M2 pattern 节走 meta-review 流程审 spec"
- **优点**:
  - 自动化:用户每次 session 启动都被提醒,不易遗忘
  - 与现有 SessionStart hook 机制一致(harness 已用 SessionStart 注入 PROGRESS / handoff)
  - 不阻断:仅提醒,用户可选择忽略(适合"建议而非强制"语义)
- **缺点**:
  - hook 复杂度增加(条件检测涉及 git log + audit covers grep)
  - "建议而非强制"可能导致反审被无限拖延(用户每次见提醒可忽略)
  - SessionStart 注入消息多了反而被忽视

### 方案 B:ROADMAP 硬卡口

- **做法**:ROADMAP 加硬条目 "P0.9.1 完成 → 必须先反审本 spec 才能进入 P0.9.1.5";brainstorming-rules 在启动 P0.9.1.5 brainstorming 时检测反审 audit 是否存在,无 → 拒绝启动
- **优点**:
  - 强约束:ROADMAP 顺序明示,brainstorming 阶段强制检测,反审不可绕
  - 与"吃自己狗粮"语义最一致(反审是 P0.9.1 落地后第一件事,也是 P0.9.1.5 启动前置)
- **缺点**:
  - 与 fix-7(P0.9.1.5 触发条件)耦合 — 若 fix-7 选方案 B(P0.9.1.5 灵活启动),本方案 B 强卡口冲突
  - brainstorming-rules 增加新检测逻辑(读 audit covers,与 hook 类似但在治理层)
  - 反审若不通过(发现 P0.9.1 自身缺陷),P0.9.1.5 启动被阻塞 — 闭环风险

### 方案 C:handoff 加"反审待办"字段

- **做法**:P0.9.1 落地的最后一次 finishing(commit 进 main 时)在 handoff 加一行 `## 反审待办: P0.9.1 落地反审 — 未完成`;后续 session 由 check-handoff.sh / 调度者读 handoff 见此待办,引导反审
- **优点**:
  - 最轻量:不改 hook 代码,不卡 ROADMAP,只在 handoff 里留一笔
  - 用户可灵活节奏(看到待办就处理,不阻塞其他工作)
  - 与现有 handoff 机制对齐(handoff 本就是"未完成事项"清单)
- **缺点**:
  - 弱约束:handoff 字段可被覆盖 / 漏读,反审仍可能遗漏
  - 没有 hook 强制,依赖调度者自律读 handoff 反审字段(与 fix-2 第七轮 fix-2 同根问题)
  - 反审若被遗漏,无人提醒(SessionStart 不检)

### 方案 D:其他

- 候选 D1:P0.9.1 落地 commit 自身就是反审的触发 — pre-commit hook 检测"本 commit 包含 P0.9.1 完成标记 + 不含反审 audit covers" → 拦 commit。但反审本来就需要 P0.9.1 已 commit 的状态(反审是落地后做),pre-commit 拦不通(顺序矛盾)
- 候选 D2:不设触发,纯靠用户主动 + spec 文档登记(类似 §1.3 提醒)— 最弱,反审极可能遗漏

## designer 倾向(基于 spec 内逻辑,不替用户决定)

倾向 **方案 A(SessionStart hook)+ 方案 C(handoff 反审待办)组合**,理由:

1. **A + C 互补**:A 提供 session 级提醒(主动推),C 提供文档级登记(被动留痕);单独 A 易被忽视,单独 C 弱约束,组合最稳
2. **不选 B**:与 fix-7 耦合(若 fix-7 选灵活方案 B,本方案 B 冲突);brainstorming-rules 加 audit 检测增加治理层复杂度
3. **`feedback_spec_gap_masking` 原则**:反审是缺口承认 → 留痕 + 提醒比"硬卡 + 阻塞"更符合"承认而非掩盖"
4. **复用 SessionStart 机制**:harness 已用 SessionStart hook 注入 PROGRESS / handoff,加一个反审提醒是边际增量

但若用户偏"严闭环",方案 B 单独使用合理 — B 把反审做成 P0.9.1.5 启动的前置,语义最强。

## 决定

**选择**:**方案 A + 方案 C 组合**

**原因**:A+C 互补 — A SessionStart hook 主动推(每次 session 启动检测条件并注入提醒),C handoff 反审待办字段被动留痕(P0.9.1 落地最后一次 finishing 时写入)。单 A 易被忽视(SessionStart 注入消息多了反而被忽视);单 C 弱约束(依赖调度者自律读 handoff 反审字段,与根源 1 自律问题同根)。组合最稳。

## 后续影响

### 实施层
- **SessionStart hook 扩展**(A 部分):session-init.sh 加反审检测逻辑(参 spec §3.1.10)— 检测条件:`git log` 主分支历史含 P0.9.1 落地 commit + `docs/audits/` 中无 covers 含本 spec 路径的 audit;满足 → 注入 system-reminder
- **M1 meta-finishing-rules 引导**(C 部分):P0.9.1 落地的最后一次 finishing(commit 进 main)时,引导调度者在 handoff 加 `## 反审待办: P0.9.1 落地反审 — 未完成` 字段(反审完成后改为"已完成 — audit:`docs/audits/...`")

### spec 落地
- **spec §3.1.10**(新增节)— SessionStart hook 反审检测契约(A 部分)
- **spec §4.1.7**(新增实体)— `handoff_self_review_pending` 字段定义(C 部分)
- **spec §6.4 bootstrap 自洽验证** — 反审段加 A+C 触发机制描述
- **spec §8.1 / §8.2 影响表** — session-init.sh 改造(归入 §8.1 改动)+ handoff.md 模板加反审待办字段示例

### 与 fix-7 解耦
- fix-8 反审触发(本 decision)与 fix-7 P0.9.1.5 触发(`2026-04-26-p0-9-1-5-trigger-condition.md`)各自决策
- 反审是 P0.9.1 自审,不依赖 P0.9.1.5 启动节奏

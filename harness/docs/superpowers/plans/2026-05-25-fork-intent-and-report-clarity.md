# Fork 前意图识别 + 报告通俗化 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地 `2026-05-25-fork-intent-and-report-clarity-design.md`(方向「己」)— synthesis-rules.md 加事前规则 5(fork 前意图识别) + 综合输出表达准则节 + 4 个领审员 agent 文件应用新规则。

**Architecture:** 纯 governance 层规则扩展 + agent 文件配套改动。不引入新 hook / 新 skill / 新 agent / 新代码。改动绑在 fork 事件触发点(调度者准备 fork 挑战者前现场提取意图),不实现 GateGuard 全套三层 hook 系统。

**Tech Stack:** Markdown(治理文档 + agent prompt 模板)+ git commit 工作流 + 后续 meta-finishing / meta-review 治理流程。

---

## Scope Check

本 batch 是 governance 层改动,不是代码,不需要 TDD。"测试"以**实战验证**形式呈现(落地后下次 fork 审查时 grep 挑战者 prompt 是否含"主线-支线-关系"节)。

Spec 范围(7 文件 / 14 处改动)适合**单 plan / 2 commit** 落地,不需拆。

---

## File Structure

| 文件 | 责任 | 改 / 新建 |
|---|---|---|
| `harness/docs/governance/synthesis-rules.md` | 综合阶段规则主体(事前 4→5 条 + 加通俗化节) | 改 |
| `harness/docs/governance/meta-review-rules.md` | meta-review 流程引用 synthesis 事前规则 5 | 改(1 行) |
| `harness/.claude/agents/design-reviewer.md` | 工作流加 fork 前意图识别 + 综合输出用户视图段 | 改 |
| `harness/.claude/agents/evaluator.md` | 同上 | 改 |
| `harness/.claude/agents/process-auditor.md` | 同上(适配 2 挑战者) | 改 |
| `harness/.claude/agents/security-reviewer.md` | 同上(适配 3 挑战者) | 改 |
| `README.md` | §4.2 实现字段微调 | 改(1 行) |
| `harness/docs/decision-trail.md` | append 2026-05-25 拐点 | 改 |

文件 8 个(spec §4 表格列 7 个 + decision-trail.md 是 meta-finishing 必产)。

---

## Commit 策略(参 spec §9)

- **Commit 1**(Governance 主体 + 锚点):Tasks 1-5 + Task 6 commit
  - synthesis-rules.md + meta-review-rules.md + README.md + decision-trail.md + spec 自身(spec 已 commit f4604f6,本 batch 不再 add)
- **Commit 2**(Agent 文件应用规则):Tasks 7-10 + Task 11 commit
  - design-reviewer + evaluator + process-auditor + security-reviewer

---

## Task 1: synthesis-rules.md 加事前规则 5 + 数量更新

**Files:**
- Modify: `harness/docs/governance/synthesis-rules.md`

**Anchor**:在"### 4 条硬规则"节(line 29-34)结尾、"### Bad / Good 对照"节(line 36)之前,**插入规则 5**;同时在 line 84 "## 事前 + 事后规则的逻辑链" 节内更新事前规则数量措辞。

- [ ] **Step 1.1: Read synthesis-rules.md 当前事前规则 4 条结尾位置**

Run: `Read harness/docs/governance/synthesis-rules.md offset=29 limit=10`
Expected output: 见 "### 4 条硬规则" 节 4 条编号 + 紧接的 "### Bad / Good 对照"

- [ ] **Step 1.2: Edit 插入事前规则 5 + 配套引用注**

在 "### 4 条硬规则" 节最后一行(规则 4)之后、空行之后、"### Bad / Good 对照" 之前,插入以下完整内容:

```markdown
### 事前规则 5 — fork 前必做意图识别

调度者准备 fork N 个挑战者前,**先做一次意图识别**,把结果作为独立段
注入每个挑战者 prompt 的顶部(在 A/B/C 三段或 N/G 段之前)。

调度者按以下三个字段提取(LLM 自然语义提取,不用规则匹配):

| 字段 | 提取什么 | 来源 |
|---|---|---|
| **主线** | 本会话整体在做什么 | handoff.md / brainstorming 需求清单 / 最新活跃 spec |
| **支线** | 本次 fork 的 sub-task 是什么 | 本次调用对应的具体审查目标(如"审 X spec 自洽性") |
| **关系** | 本 fork 服务于主线的哪一节 / 哪个决策点 | 调度者综合上面两项推导 |

注入挑战者 prompt 的固定段格式:

```text
## 主线-支线-关系(领审员 fork 前注入)
- **主线**:[本会话整体任务,1-3 行]
- **支线**:[本次挑战者的具体任务,1 行]
- **关系**:[本支线服务于主线的哪一节,1-2 行]
```

挑战者审查时:
- **先读这一节**,理解审查的整体语境
- 然后按 A/B/C(或 N/G)段做审查
- 输出问题时,**可选**标注"是否真服务于主线"作为附加观察
  (不强制纳入评分;附加观察 vs 评分维度的边界详见下方)

#### 与事前规则 1-3(中性化)的关系

规则 5 提供的"主线-支线-关系" 是**任务边界**(给挑战者明确审什么),不是
**结论引导**(不暗示"重点是 X、应找 Y"):
- ✅ "主线:本次会话整体在做 GateGuard 全套设计" — 任务边界,允许
- ❌ "主线:本次会话整体在做 GateGuard,**关键问题是 hook 触发频次**,
  请重点审" — 结论引导,违反规则 1-3 中性化

规则 5 的输出**必须只描述边界,不暗示结论**。

#### 附加观察 vs 评分维度的边界(防 scope creep)

挑战者在"是否真服务于主线"上的附加观察:
- **允许**:挑战者发现"本 fork 审的产物明显偏离主线意图" → 在输出末尾加
  一条 `🟡 偏离主线观察`,不纳入评分
- **不允许**:挑战者把"是否服务主线"当一个评分维度,扣分;这会违反
  "挑战者是对抗者不是评分员"原则(参 multi-agent-review-guide.md)

附加观察纳入调度者综合阶段判断(事后规则 1 "基于上下文意图综合"扩展点),
不影响挑战者打分逻辑。

#### 提取源失败 / 边界

- **提取源全缺失**(handoff / spec / decision-trail 都没东西):"主线"字段
  标 `[本会话无历史上下文,仅基于当前 user prompt]` — 不阻止 fork,但
  audit trail 记一行警告
- **支线无明确目标**(用户没说审什么):调度者必须先跟用户对齐"本次 fork
  审什么",再开始 fork — 不允许"猜支线"
- **关系字段写不出**(主线和支线明显无关):标
  `[本 fork 独立于主线,可能是 user 临时插入的 sub-task]` — 不阻止 fork,
  但 process-audit 应抓这种 case 作复盘

#### 适用范围(哪些 fork 必须做)

事前规则 5 适用所有"调度者面对挑战者"的 fork 场景(对齐本文件适用范围表):
- design-review(4 挑战者)
- evaluator(4 挑战者)
- process-audit(2 挑战者)
- security-scan(3 挑战者)
- meta-review(N 挑战者,模态决定)

**不适用**:
- designer fork(designer 是产生设计文档,不属综合阶段)
- 普通 Agent 工具调用(非"挑战者 fork"场景,如用 general-purpose agent 跑研究任务)

```

- [ ] **Step 1.3: Edit 更新 "事前 + 事后规则的逻辑链" 节内的事前规则数量**

Read 找到 line 84 附近("## 事前 + 事后规则的逻辑链" 节):

```
| 阶段 | 适用规则 | 目的 |
|---|---|---|
| **fork 之前**(构造 prompt) | 事前 4 条 | 调度者给挑战者的 prompt 不带倾向 |
```

把 `事前 4 条` 改为 `事前 5 条`。

- [ ] **Step 1.4: Grep 验证插入成功**

Run: `Grep pattern="### 事前规则 5" path="harness/docs/governance/synthesis-rules.md" output_mode="content" -n=true`
Expected: 1 处命中,在 "### 4 条硬规则" 节后

Run: `Grep pattern="事前 5 条" path="harness/docs/governance/synthesis-rules.md" output_mode="content"`
Expected: 1 处命中,在 "事前 + 事后规则的逻辑链" 节内

---

## Task 2: synthesis-rules.md 加"综合输出表达准则"节

**Files:**
- Modify: `harness/docs/governance/synthesis-rules.md`

**Anchor**:在 "## 事后规则" 4 条结尾(约 line 82)之后、"## 事前 + 事后规则的逻辑链" 节(line 84)之前,**插入综合输出表达准则节**(独立 `##` 二级标题)。

- [ ] **Step 2.1: Read 当前事后规则 4 结尾 + 逻辑链节起点**

Run: `Read harness/docs/governance/synthesis-rules.md offset=75 limit=15`
Expected: 见事后规则 4 末尾 + "---" 分隔符 + "## 事前 + 事后规则的逻辑链" 节

- [ ] **Step 2.2: Edit 在事后规则 4 结尾与逻辑链节之间插入新节**

在事后规则 4 节末尾后的空行 + "---" 分隔符之后(逻辑链节之前),插入完整新节:

```markdown
## 综合输出表达准则(调度者综合后给用户的报告)

调度者综合多挑战者结论 → 给用户报告时,遵守以下 4 条:

### 1. 不预设用户和你有相同的上下文(信息论原则)

- 不写 "M2 §3.1.5" / "fix-7 N #10" / "spec §4.1.4" 这类只有维护者懂的 ID
- 引用任何文件 / 节号时,**简短解释这是什么**
- 例:
  - ✅ "synthesis-rules.md(综合阶段的中性化规则)加了一节"
  - ❌ "M2 §3.1.7 runtime 嵌入契约 fix-2 已落地"

依据:用户校准 `feedback_choice_visualization`(不预设上下文)+
用户原话(2026-05-25)"不要预设用户和你有相同的上下文(信息论)"。

### 2. 关键术语保留 + 1 行解释

- 不可避免的术语(如"挑战者 / 意图链 / scope=meta / 公设 1")第一次出现时
  **1 行解释**,但不要全部翻译成大白话(会丢失精确度)
- 例:
  - ✅ "scope=meta(改动命中 governance 规则文件等,走 meta-review)"
  - ❌ "scope=meta"(无解释,用户记不住所有 scope 类别)
  - ❌ "本次改动属于元数据范畴需要走元数据审查流程"(术语翻译过度,丢精确度)

### 3. 报告固定结构 4 段

调度者综合后给用户的报告按以下 4 段:

```text
## 结论先行
[1 句话:审查通过 / 不通过 / 需修;不通过原因摘要]

## 关键发现
[挑战者发现的核心问题,通俗描述;不堆术语]
- 发现 1:...
- 发现 2:...

## 建议下一步
[用户 / 调度者接下来做什么]

## 细节链接
[挑战者具体输出文件路径,需要深挖时看]
- design-review-result:docs/active/design-review-result.md
- 审查 audit:docs/audits/meta-review-YYYY-MM-DD-HHMMSS-...md
```

### 4. 避免术语堆叠

- 一句话超过 2 个术语 → **拆成两句**
- 标题不用术语 ID,用动作描述
  - ✅ "## fork 前要做意图识别"
  - ❌ "## §3.1.5 事前规则 5 落地"
- 列表项不嵌套 3 层以上(读着累)

### 应用范围

本准则适用调度者对**用户**的报告输出。
**不适用**:
- 调度者给挑战者的 prompt(挑战者是 AI,术语精确度优先于通俗)
- 调度者写到 audit / decision / spec 等持久化产物的内容(持久化产物供未来调度者读,术语精确优先)
- 调度者内部 reasoning(thinking 块,不输出给用户)

---

```

- [ ] **Step 2.3: Grep 验证插入成功**

Run: `Grep pattern="## 综合输出表达准则" path="harness/docs/governance/synthesis-rules.md" output_mode="content"`
Expected: 1 处命中,在事后规则节后、逻辑链节前

---

## Task 3: meta-review-rules.md 补 synthesis 事前规则 5 引用一行

**Files:**
- Modify: `harness/docs/governance/meta-review-rules.md`

**Anchor**:line 93-95 的 "2. 调度者并行 fork N 个挑战者" 步骤,在该步骤的展开说明里加一行引用。

- [ ] **Step 3.1: Read 当前 §3 流程 fork 步骤上下文**

Run: `Read harness/docs/governance/meta-review-rules.md offset=90 limit=15`
Expected: 见步骤 2 "调度者并行 fork N 个挑战者" + 工具层并行约束等

- [ ] **Step 3.2: Edit 在步骤 2 末尾(挑战者 prompt 构造说明前)加引用行**

找到原文:
```
  2. 调度者并行 fork N 个挑战者(N 由主题 + 模态决定)
     每个挑战者 prompt 按本文件 §4 构造
     **工具层并行约束**:...
```

改为(在 "每个挑战者 prompt 按本文件 §4 构造" 行之后,"**工具层并行约束**" 行之前加一行):

```
  2. 调度者并行 fork N 个挑战者(N 由主题 + 模态决定)
     每个挑战者 prompt 按本文件 §4 构造
     **fork 前意图识别**(2026-05-25 加):调度者按 `synthesis-rules.md` 事前规则 5,
     fork 前做意图识别,把"主线-支线-关系"独立段注入每个挑战者 prompt 顶部
     (在 A/B/C 三段之前)。规则细节见 `synthesis-rules.md`,本文件不重复全文。
     **工具层并行约束**:...
```

- [ ] **Step 3.3: Grep 验证引用插入**

Run: `Grep pattern="fork 前意图识别" path="harness/docs/governance/meta-review-rules.md" output_mode="content" -n=true`
Expected: 1 处命中,在 §3 流程步骤 2 内

---

## Task 4: README.md §4.2 实现字段微调

**Files:**
- Modify: `README.md`(仓库根级)

**Anchor**:line 39 "**4.2 综合阶段中性化**" 段的 "**实现**" 字段。

- [ ] **Step 4.1: Read 当前 README §4.2 行**

Run: `Read README.md offset=38 limit=3`
Expected: 见 "**4.2 综合阶段中性化** — 调度者构造挑战者 prompt 必须中立..." 行,末尾 `**实现**:docs/governance/synthesis-rules.md 完整规范`

- [ ] **Step 4.2: Edit 实现字段**

把:
```
**实现**:`docs/governance/synthesis-rules.md` 完整规范
```

改为:
```
**实现**:`docs/governance/synthesis-rules.md`(事前 5 条 + 事后 4 条 + 综合输出表达准则)
```

- [ ] **Step 4.3: Grep 验证**

Run: `Grep pattern="事前 5 条 \+ 事后 4 条 \+ 综合输出表达准则" path="README.md" output_mode="content"`
Expected: 1 处命中,在 §4.2 行

---

## Task 5: decision-trail.md append 2026-05-25 拐点

**Files:**
- Modify: `harness/docs/decision-trail.md`

**Anchor**:在 line 30 "## 2026-05-24 — codex 接入搁置" 拐点之前(时间倒序最新在上)。

- [ ] **Step 5.1: Read decision-trail.md 顶部 + 2026-05-24 拐点位置**

Run: `Read harness/docs/decision-trail.md offset=20 limit=15`
Expected: 见维护规则结尾 + "---" 分隔 + "## 2026-05-24 — codex 接入搁置" 拐点

- [ ] **Step 5.2: Edit 在 2026-05-24 拐点之前插入 2026-05-25 拐点**

找到 "## 2026-05-24 — codex 接入搁置" 行,在其之前插入完整拐点条目:

```markdown
## 2026-05-25 — fork 前现场意图识别 + 报告通俗化(方向「己」)

- **抉择**:落地用户原诉求"审查时 fork 智能体知道主线" + "报告通俗化(不预设用户和 AI 上下文,信息论)"。实现路径选方向「己」 — fork 前调度者现场意图识别,绑在 fork 事件;**不**实现 GateGuard 全套三层 hook(SessionStart + UserPromptSubmit + PreToolUse),GateGuard 设计哲学(`decisions/2026-05-12-ecc-analysis-snapshot.md §11.12`)保留作未来参考。
- **触发**:2026-05-25 用户会话提"审查的时候要有主线任务和分支任务的概念...将这主线任务+支线任务都输入给 fork 的智能体" + "汇报使用通俗的语言,不预设用户和你有相同的上下文(信息论)"。
- **走过的弯路(决策追溯)**:意图源初指 GateGuard → 选方案 D 三层 hook 全启 → 提取动力纠正为 LLM → 撞上"用 LLM + 不每次跑 + 不懒触发"三条结构性张力 → 用户提"或者使用 fork 之前进行意图识别?" → 收敛到方向「己」(最小可行实现:fork 事件触发点)。
- **改动 scope**:meta(7 个文件 / 14 处改动)— `synthesis-rules.md`(主改:加事前规则 5 + 综合输出表达准则节)+ `meta-review-rules.md`(补引用行)+ 4 个领审员 agent 文件(design-reviewer / evaluator / process-auditor / security-reviewer 各加 fork 前意图识别节 + 综合输出加用户视图段)+ `README.md`(§4.2 实现字段微调)。
- **不在 scope**:GateGuard 全套三层 hook / 不可逆动作前 C 确认 / 状态文件 / LLM CLI 调用 / brainstorming-rules 改动 / designer.md 改动 / hook 体系改动。
- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md` 自身构成完整记录);spec `docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md`(本 batch 设计文档);plan `docs/superpowers/plans/2026-05-25-fork-intent-and-report-clarity.md`(实施计划);audit:待 meta-review 跑完后回填(预期 `docs/audits/meta-review-2026-05-25-HHMMSS-fork-intent.md`)。

```

- [ ] **Step 5.3: Grep 验证拐点 header**

Run: `Grep pattern="## 2026-05-25 — fork 前现场意图识别" path="harness/docs/decision-trail.md" output_mode="content" -n=true`
Expected: 1 处命中,在 2026-05-24 拐点之前

---

## Task 6: Commit 1 — Governance 主体 + 锚点

**Files:** 4 个文件(synthesis-rules + meta-review-rules + README + decision-trail)

- [ ] **Step 6.1: Git status 看 staged + untracked**

Run: `git status`
Expected: 4 个 modified 文件,无 untracked

- [ ] **Step 6.2: Git diff --stat 看改动规模**

Run: `git diff --stat`
Expected: 4 个文件,大致 synthesis-rules 加 ~100 行,其他各 1-3 行

- [ ] **Step 6.3: Git add + commit**

Run:
```bash
git add harness/docs/governance/synthesis-rules.md harness/docs/governance/meta-review-rules.md README.md harness/docs/decision-trail.md && git commit -m "$(cat <<'EOF'
docs(fork-intent): 加事前规则 5 + 综合输出表达准则 — governance 主体 (Commit 1/2)

synthesis-rules.md 加事前规则 5(fork 前意图识别) + 综合输出表达准则节;
meta-review-rules.md §3 流程补 synthesis 引用行;
README.md §4.2 实现字段微调;
decision-trail.md append 2026-05-25 拐点。

Spec: docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: 1 commit 成功,working tree 4 文件改动归零

- [ ] **Step 6.4: Git status 确认 commit 成功**

Run: `git status`
Expected: `nothing to commit, working tree clean`(若 Tasks 7-10 已在并行进行,则 working tree 有 4 个 agent 文件待 commit)

---

## Task 7: design-reviewer.md 加 fork 前意图识别节 + 综合输出加用户视图段

**Files:**
- Modify: `harness/.claude/agents/design-reviewer.md`

**Anchor**:
- 改动 1:在 "### 第一步:在一条消息中并行 fork 4 个挑战者" 段**之前**,加新节
- 改动 2:在 "### 第四步:写入结果" 段**之后**(写入结果模板末尾),加新节

- [ ] **Step 7.1: Read design-reviewer.md 找两个 anchor**

Run: `Read harness/.claude/agents/design-reviewer.md offset=30 limit=15`(找第一步起点)
Run: `Grep pattern="### 第四步:写入结果" path="harness/.claude/agents/design-reviewer.md" output_mode="content" -n=true`(找第四步起点)

- [ ] **Step 7.2: Edit 在第一步之前插入"fork 前意图识别"节**

在 "### 第一步:在一条消息中并行 fork 4 个挑战者" 行之前,插入:

```markdown
### 第一步前 — fork 前意图识别(synthesis-rules 事前规则 5)

调度者按 `harness/docs/governance/synthesis-rules.md` 事前规则 5,提取主线 / 支线 / 关系
三字段,作为独立段加入每个挑战者 prompt 的顶部(在 A/B/C 三段之前)。

提取来源:
- **主线**:本会话整体在做什么 — handoff.md / brainstorming 需求清单 / 最新活跃 spec
- **支线**:本次 design-review 的 sub-task 是什么 — 如"审 X spec 的自洽性"
- **关系**:本支线服务于主线的哪一节 / 哪个决策点

注入挑战者 prompt 的固定段格式:

```text
## 主线-支线-关系(领审员 fork 前注入)
- **主线**:[本会话整体任务,1-3 行]
- **支线**:[本次挑战者的具体任务,1 行]
- **关系**:[本支线服务于主线的哪一节,1-2 行]
```

注意:此段是任务边界,**不是结论引导**(参 synthesis-rules.md 事前规则 5 与中性化 1-3 的关系)。
不要写"重点是 X、应找 Y";只描述审什么、为什么。

```

- [ ] **Step 7.3: Edit 在第四步末尾加"第五步 — 综合后给用户的口语报告"节**

找到 "### 第四步:写入结果" 节末尾(写入结果的 markdown 模板代码块结束之后),加新节:

```markdown
### 第五步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)

将 `docs/active/design-review-result.md`(持久化产物,术语精确)写完后,
**额外**给用户口语报告,按 `synthesis-rules.md` "综合输出表达准则" 4 段格式:

```text
## 结论先行
[1 句话:审查通过 / 不通过 / 需修;不通过原因摘要]

## 关键发现
[挑战者发现的核心问题,通俗描述;不堆术语]
- 发现 1:...
- 发现 2:...

## 建议下一步
[用户 / 调度者接下来做什么]

## 细节链接
- design-review-result:docs/active/design-review-result.md
```

通俗化原则:
- 不预设用户和你有相同上下文(不写 raw ID 如 "§3.1.5")
- 术语第一次出现时 1 行解释
- 一句话超过 2 个术语 → 拆成两句

```

- [ ] **Step 7.4: Grep 验证两节插入**

Run: `Grep pattern="### 第一步前 — fork 前意图识别|### 第五步 — 综合后给用户的口语报告" path="harness/.claude/agents/design-reviewer.md" output_mode="content" -n=true`
Expected: 2 处命中(分别在第一步前 + 第四步后)

---

## Task 8: evaluator.md 加 fork 前意图识别节 + 综合输出加用户视图段

**Files:**
- Modify: `harness/.claude/agents/evaluator.md`

**Anchor**:
- 改动 1:在 "### 第二步:在一条消息中并行 fork 4 个挑战者" 段之前,加新节(注意 evaluator 第一步是"收集输入",第二步才是 fork)
- 改动 2:在 "### 第八步:写入结果" 段之后,加新节

- [ ] **Step 8.1: Read evaluator.md 找两个 anchor**

Run: `Grep pattern="### 第二步:在一条消息中并行 fork|### 第八步:写入结果" path="harness/.claude/agents/evaluator.md" output_mode="content" -n=true`

- [ ] **Step 8.2: Edit 在第二步之前插入"fork 前意图识别"节**

在 "### 第二步:在一条消息中并行 fork 4 个挑战者" 行之前,插入(与 Task 7.2 内容**结构相同,适配 evaluator**):

```markdown
### 第二步前 — fork 前意图识别(synthesis-rules 事前规则 5)

调度者按 `harness/docs/governance/synthesis-rules.md` 事前规则 5,提取主线 / 支线 / 关系
三字段,作为独立段加入每个挑战者 prompt 的顶部(在 A/B/C 三段之前)。

提取来源:
- **主线**:本会话整体在做什么 — handoff.md / brainstorming 需求清单 / 最新活跃 spec
- **支线**:本次 evaluator 的 sub-task 是什么 — 如"评估 X 功能方向是否对、是否推翻"
- **关系**:本支线服务于主线的哪一节 / 哪个决策点

注入挑战者 prompt 的固定段格式:

```text
## 主线-支线-关系(领审员 fork 前注入)
- **主线**:[本会话整体任务,1-3 行]
- **支线**:[本次挑战者的具体任务,1 行]
- **关系**:[本支线服务于主线的哪一节,1-2 行]
```

注意:此段是任务边界,**不是结论引导**(参 synthesis-rules.md 事前规则 5 与中性化 1-3 的关系)。
不要写"重点是 X、应找 Y";只描述审什么、为什么。

```

- [ ] **Step 8.3: Edit 在第八步末尾加"第九步 — 综合后给用户的口语报告"节**

在 "### 第八步:写入结果" 节末尾(写入结果模板代码块结束之后),加:

```markdown
### 第九步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)

将 `docs/active/evaluation-result.md`(持久化产物,术语精确)写完后,
**额外**给用户口语报告,按 `synthesis-rules.md` "综合输出表达准则" 4 段格式:

```text
## 结论先行
[1 句话:总分 / 通过 / 不通过 / 方向建议;不通过原因摘要]

## 关键发现
[挑战者发现的核心问题,通俗描述;不堆术语]
- 共识问题 1:...
- 共识问题 2:...

## 建议下一步
[用户 / 调度者接下来做什么 — 精磨 / 推翻 / finishing]

## 细节链接
- evaluation-result:docs/active/evaluation-result.md
```

通俗化原则同 design-reviewer:
- 不预设用户和你有相同上下文(不写 raw ID)
- 术语第一次出现时 1 行解释
- 一句话超过 2 个术语 → 拆成两句

```

- [ ] **Step 8.4: Grep 验证两节插入**

Run: `Grep pattern="### 第二步前 — fork 前意图识别|### 第九步 — 综合后给用户的口语报告" path="harness/.claude/agents/evaluator.md" output_mode="content" -n=true`
Expected: 2 处命中

---

## Task 9: process-auditor.md 加 fork 前意图识别节 + 综合输出加用户视图段

**Files:**
- Modify: `harness/.claude/agents/process-auditor.md`

**Anchor**:
- 改动 1:在 "### 第三步:在一条消息中并行 fork 2 个挑战者" 段之前,加新节
- 改动 2:在 "### 第五步:写入结果" 段之后,加新节

- [ ] **Step 9.1: Read process-auditor.md 找 anchor**

Run: `Grep pattern="### 第三步:在一条消息中并行 fork|### 第五步:写入结果" path="harness/.claude/agents/process-auditor.md" output_mode="content" -n=true`

- [ ] **Step 9.2: Edit 在第三步之前插入"fork 前意图识别"节**

在 "### 第三步:在一条消息中并行 fork 2 个挑战者" 之前,插入(适配 process-audit **2 挑战者 + N/G 段**结构):

```markdown
### 第三步前 — fork 前意图识别(synthesis-rules 事前规则 5)

调度者按 `harness/docs/governance/synthesis-rules.md` 事前规则 5,提取主线 / 支线 / 关系
三字段,作为独立段加入每个挑战者 prompt 的顶部(在 N1/N2/G 段之前)。

提取来源:
- **主线**:本会话整体在做什么 — handoff.md / brainstorming 需求清单 / 最新活跃 spec
- **支线**:本次 process-audit 的 sub-task 是什么 — 如"审 X 功能开发过程的流程遵从度 + 用户满意度"
- **关系**:本支线服务于主线的哪一节 / 哪个决策点

注入挑战者 prompt 的固定段格式:

```text
## 主线-支线-关系(领审员 fork 前注入)
- **主线**:[本会话整体任务,1-3 行]
- **支线**:[本次挑战者的具体任务,1 行]
- **关系**:[本支线服务于主线的哪一节,1-2 行]
```

注意:此段是任务边界,**不是结论引导**(参 synthesis-rules.md 事前规则 5 与中性化 1-3 的关系)。
process-audit 是事实统计式 D2 模态,不涉及对抗,但意图识别仍应用 — 让挑战者知道审什么。

```

- [ ] **Step 9.3: Edit 在第五步末尾加"第六步 — 综合后给用户的口语报告"节**

在 "### 第五步:写入结果" 节末尾(写入结果模板代码块结束之后),加:

```markdown
### 第六步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)

将 `docs/audits/audit-YYYY-MM-DD-HHMMSS.md`(持久化产物,术语精确)写完后,
**额外**给用户口语报告,按 `synthesis-rules.md` "综合输出表达准则" 4 段格式:

```text
## 结论先行
[1 句话:本次流程遵从度如何 / 用户满意度如何 / 是否有高优先级流程问题]

## 关键发现
[挑战者发现的核心流程问题,通俗描述;不堆术语]
- 流程问题 1:...
- 用户不满意事件 1:...

## 建议下一步
[harness 开发者应关注哪些流程优化点]

## 细节链接
- 完整 audit 报告:docs/audits/audit-YYYY-MM-DD-HHMMSS.md
```

通俗化原则同其他 agent:
- 不预设用户和你有相同上下文
- 术语 1 行解释
- 避免堆叠

```

- [ ] **Step 9.4: Grep 验证两节插入**

Run: `Grep pattern="### 第三步前 — fork 前意图识别|### 第六步 — 综合后给用户的口语报告" path="harness/.claude/agents/process-auditor.md" output_mode="content" -n=true`
Expected: 2 处命中

---

## Task 10: security-reviewer.md 加 fork 前意图识别节 + 综合输出加用户视图段

**Files:**
- Modify: `harness/.claude/agents/security-reviewer.md`

**Anchor**:需先 Read 看 security-reviewer 步骤编号(我未在 plan 编写时核实其具体步骤编号),找:
- 改动 1:第一个"并行 fork N 个挑战者"步骤之前
- 改动 2:最后一个"写入结果"步骤之后

- [ ] **Step 10.1: Read security-reviewer.md 完整结构**

Run: `Read harness/.claude/agents/security-reviewer.md`(完整读,了解步骤编号)

- [ ] **Step 10.2: Grep 找两个 anchor**

Run: `Grep pattern="### 第.{1,2}步:.{0,30}fork|### 第.{1,2}步:.{0,20}写入" path="harness/.claude/agents/security-reviewer.md" output_mode="content" -n=true`

- [ ] **Step 10.3: Edit 在 fork 步骤之前插入"fork 前意图识别"节**

按 security-scan **3 挑战者结构**(凭证 / 危险操作 / 注入混淆),在 fork 步骤之前插入:

```markdown
### [步骤号]前 — fork 前意图识别(synthesis-rules 事前规则 5)

调度者按 `harness/docs/governance/synthesis-rules.md` 事前规则 5,提取主线 / 支线 / 关系
三字段,作为独立段加入每个挑战者 prompt 的顶部(在该 prompt 主体之前)。

提取来源:
- **主线**:本会话整体在做什么 — handoff.md / brainstorming 需求清单 / 最新活跃 spec
- **支线**:本次 security-scan 的 sub-task 是什么 — 如"扫描 X 功能 commit 前的安全风险"
- **关系**:本支线服务于主线的哪一节 / 哪个决策点

注入挑战者 prompt 的固定段格式:

```text
## 主线-支线-关系(领审员 fork 前注入)
- **主线**:[本会话整体任务,1-3 行]
- **支线**:[本次挑战者的具体任务,1 行]
- **关系**:[本支线服务于主线的哪一节,1-2 行]
```

注意:此段是任务边界,**不是结论引导**(参 synthesis-rules.md 事前规则 5 与中性化 1-3 的关系)。
security-scan 是模式匹配为主,但意图识别仍应用 — 让挑战者知道审的是哪个功能 / 哪个 commit。

```

(具体步骤编号在 Step 10.2 grep 后填入)

- [ ] **Step 10.4: Edit 在写入结果步骤之后加"综合后口语报告"节**

按其他 agent 同结构,在 security-scan 写入结果之后加:

```markdown
### [步骤号] — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)

将持久化 security audit 产物写完后,**额外**给用户口语报告,按
`synthesis-rules.md` "综合输出表达准则" 4 段格式:

```text
## 结论先行
[1 句话:扫描通过 / 发现 N 个安全问题 / 阻塞 commit]

## 关键发现
[挑战者发现的安全问题,通俗描述]
- 凭证泄露 / 危险操作 / 注入混淆 各列关键问题

## 建议下一步
[用户应采取的修复 / 撤回操作]

## 细节链接
- 完整 security audit 路径
```

通俗化原则同其他 agent。

```

- [ ] **Step 10.5: Grep 验证两节插入**

Run: `Grep pattern="fork 前意图识别|综合后给用户的口语报告" path="harness/.claude/agents/security-reviewer.md" output_mode="content" -n=true`
Expected: 2 处命中

---

## Task 11: Commit 2 — Agent 文件应用规则

**Files:** 4 个 agent 文件(design-reviewer + evaluator + process-auditor + security-reviewer)

- [ ] **Step 11.1: Git status 确认 4 个 agent 文件改动**

Run: `git status`
Expected: 4 个 modified 文件(`.claude/agents/{design-reviewer,evaluator,process-auditor,security-reviewer}.md`)

- [ ] **Step 11.2: Git diff --stat 看改动规模**

Run: `git diff --stat`
Expected: 4 个文件,每个加 ~50-70 行(2 个新节)

- [ ] **Step 11.3: Git add + commit**

Run:
```bash
git add harness/.claude/agents/design-reviewer.md harness/.claude/agents/evaluator.md harness/.claude/agents/process-auditor.md harness/.claude/agents/security-reviewer.md && git commit -m "$(cat <<'EOF'
docs(fork-intent): 4 个领审员 agent 应用事前规则 5 + 综合输出准则 (Commit 2/2)

design-reviewer / evaluator / process-auditor / security-reviewer 各加:
1. fork 前意图识别节(应用 synthesis-rules 事前规则 5)
2. 综合后给用户口语报告节(应用 synthesis-rules 综合输出表达准则)

Spec: docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: 1 commit 成功

- [ ] **Step 11.4: Git status 确认 commit 成功 + working tree clean**

Run: `git status`
Expected: `nothing to commit, working tree clean`,本地 ahead origin/main by 3 commits(spec + Commit 1 + Commit 2)

---

## Task 12: handoff.md 更新 + 下一步引导

**Files:**
- Modify: `harness/docs/active/handoff.md`(若不存在则不动 — 本 batch 未到 finishing,handoff 在 meta-finishing 流程内更新)

- [ ] **Step 12.1: Check handoff.md 是否存在**

Run: `Glob pattern="harness/docs/active/handoff.md"`
Expected: 若有 → 进 Step 12.2;若无 → 跳过本 Task,handoff 由 meta-finishing 流程产出

- [ ] **Step 12.2: 若存在,Read 当前 handoff 看是否需更新**

Run: `Read harness/docs/active/handoff.md`
判断:本 batch(fork-intent-and-report-clarity)的状态是否需在 handoff 反映

- [ ] **Step 12.3: 若需更新,Edit handoff.md 加本 batch 完成状态行**

(具体格式按现有 handoff.md 风格;不在 plan 内预制,由 implementer 现场判断)

- [ ] **Step 12.4: 不 commit handoff** — handoff 更新通常在 meta-finishing 流程内做,本 plan 完成即可

---

## 实现完成后的下一步(不在本 plan 内,仅引导)

本 plan 12 个 Task 完成后,本 batch 进入 **finishing 阶段**:

1. **Meta-finishing**(按 `harness/docs/governance/meta-finishing-rules.md` M1):
   - 完整 handoff 更新
   - meta-finishing 流程触发

2. **Meta-review**(按 `harness/docs/governance/meta-review-rules.md` M2):
   - 模态选择:**对抗式 D2**(governance 规则改动)
   - 挑战者数量:**4-6**(基线 4 + 可选 2 个定制维度)
   - 产 audit 文件:`docs/audits/meta-review-2026-05-25-HHMMSS-fork-intent.md`,covers 字段覆盖 7 个改动文件

3. **实战验证**(meta-L2 关键):
   - 下次跑 design-review / evaluator / process-audit / security-scan / meta-review 时,grep 挑战者 prompt 是否含"主线-支线-关系"节
   - 验证调度者综合后报告应用通俗化 4 段格式
   - process-audit 抽检无违反

4. **Push origin/main**(若 meta-review 通过):
   - `git push origin main` 推 3 个本地 commit(spec + Commit 1 + Commit 2)
   - 推送前确认 audit 文件存在

---

## Self-Review

### 1. Spec 覆盖

| Spec §  | 内容 | Plan Task | 状态 |
|---|---|---|---|
| §3.1 意图识别协议 | synthesis-rules 加事前规则 5 | Task 1 | ✅ |
| §3.2 报告通俗化协议 | synthesis-rules 加综合输出表达准则节 | Task 2 | ✅ |
| §4.1 synthesis-rules 改 | 4 处(加规则 5 + 加节 + 数量更新 + 适用范围不动) | Task 1 + 2 | ✅ |
| §4.2 design-reviewer 改 | 2 处(fork 前 + 综合后) | Task 7 | ✅ |
| §4.3 evaluator 改 | 2 处 | Task 8 | ✅ |
| §4.4 process-auditor 改 | 2 处 | Task 9 | ✅ |
| §4.5 security-reviewer 改 | 2 处 | Task 10 | ✅ |
| §4.6 meta-review-rules 改 | 1 处(补引用行) | Task 3 | ✅ |
| §4.7 README 改 | 1 处(实现字段微调) | Task 4 | ✅ |
| §5 scope + finishing 路径 | 描述,不需 Task | (引导节) | ✅ |
| §6 测试 / 验收 | 实战验证,不需 Task | (引导节 + Step 验证) | ✅ |
| §9 Commit 策略 | 分 Commit 1 + Commit 2 | Task 6 + Task 11 | ✅ |
| decision-trail append | (meta-finishing 必产) | Task 5 | ✅ |
| handoff 更新 | (meta-finishing 必产) | Task 12 | ✅ |

**无 spec 覆盖缺口**。

### 2. Placeholder 扫描

- 无 "TBD" / "TODO" / "implement later" / "add appropriate error handling"
- Task 10 Step 10.3/10.4 含 `[步骤号]` 占位符 — 这是因为 security-reviewer.md 的步骤编号在 plan 编写时未实测,**保留为占位让 implementer Step 10.1 / 10.2 现场填入**(已标注理由,不算 placeholder 失败)
- Task 12 Step 12.3 写"具体格式按现有 handoff.md 风格" — 是引导而非 placeholder(handoff 风格因项目而异,不应在 plan 预制)

### 3. Type consistency

- `synthesis-rules.md` 在 Task 1 / 2 / 3 / 6 / 7-10 中名称一致 ✅
- 路径前缀 `harness/` 全 plan 一致 ✅
- "事前规则 5" 措辞在 Task 1 / 3 / 7-10 一致 ✅
- "综合输出表达准则" 节名在 Task 2 / 4 / 7-10 一致 ✅
- 4 个 agent 文件名 (design-reviewer / evaluator / process-auditor / security-reviewer) 在 plan 内一致 ✅

**无 type consistency 问题**。

---

## Plan 完成

Plan 已保存到:`harness/docs/superpowers/plans/2026-05-25-fork-intent-and-report-clarity.md`

两个执行选项:

**1. Subagent-Driven(推荐)** — 我 dispatch 一个 fresh subagent 跑每个 Task,Task 之间审查,快速迭代

**2. Inline Execution** — 在本会话内用 executing-plans 跑,批量执行 + checkpoint 审查

哪种?

---
status: brainstorming-approved
date: 2026-05-25
purpose: fork 前现场意图识别 + 综合输出表达准则 — synthesis-rules.md 扩展(事前规则 5 + 报告通俗化节)+ 4 个领审员 agent 文件配套
scope: meta
batch_name: fork-intent-and-report-clarity
---

# Fork 前意图识别 + 报告通俗化 设计文档(2026-05-25)

> 本 batch 落地用户原诉求两件事:
> 1. **审查的时候 fork 智能体知道主线是什么**(主线任务 + 深度意图)
> 2. **汇报使用通俗语言,不预设用户和 AI 有相同上下文**(信息论)
>
> 实现路径选择"方向「己」 — fork 前调度者现场意图识别 + 报告通俗化规则" — 不引入新 hook、不实现 GateGuard 全套三层 hook,纯 governance 层规则扩展。

---

## 0. 摘要

| 字段 | 内容 |
|---|---|
| **本 batch 名** | fork-intent-and-report-clarity |
| **改动 scope** | meta(governance + agent 文件 + README) |
| **涉及文件** | 7 个(`synthesis-rules.md` + 4 个领审员 agent + `meta-review-rules.md` + `README.md`) |
| **改动数** | 14 处 |
| **工程量** | 1-2 天落地 + meta-finishing + meta-review 半天 |
| **Evidence Depth** | meta-L2(规则文档 + agent 文件 + 实战验证) |
| **finishing 路径** | meta-finishing-rules.md(M1)+ meta-review-rules.md(M2 模态:对抗式 D2,4-6 挑战者) |
| **不在 scope 内** | GateGuard 全套三层 hook / 不可逆动作前 C 确认 / 状态文件 / LLM CLI 调用 / brainstorming-rules 改动 |

---

## 1. 背景 / 触发原因

### 1.1 用户原诉求(2026-05-25 会话)

用户原话:
> "审查的时候,要有一个主线任务和分支任务的概念,主线任务是当前开发的内容,以及其深度意图是什么,这个是我们之前有的一个功能,判断用户潜在意图。
> 然后将这主线任务(目前的主要任务+深度意图)+支线任务(这个会话需要审查的东西)都输入给fork的智能体。这样子智能体还是会审查,但是他知道主线是什么。
> 另外要求汇报的时候使用通俗的语言,只保留关键术语。不要有过多术语,不要预设用户和你有相同的上下文(信息论)"

**两件事**:
1. fork 挑战者审查时拿到"主线意图 + 支线任务",而不是只拿"待审查产物"
2. 调度者综合后给用户的报告通俗化,不堆术语,不假设用户掌握内部 ID

### 1.2 走过的弯路(决策追溯)

用户提"主线意图来源"指向"我们之前有的一个功能,判断用户潜在意图" — 调度者初次理解为 **GateGuard**(`ecc-analysis-snapshot.md §11.12` 的纸面设计,P1 未实现)。

经过 5 轮澄清:
- Q1:意图源(用户选 C — GateGuard,但 GateGuard 未实现 → 用户选"先做 GateGuard 再改 fork")
- Q2:GateGuard hook 形态(用户选方案 D — 三层 hook 全启:SessionStart + UserPromptSubmit + PreToolUse)
- Q3a:三层 hook 各自职责拆分(详细呈现)
- Q3b:意图提取动力(用户纠正:**应该用 LLM,不用规则**)
- Q3c:LLM 调用如何落到 bash hook(发现 Claude Code 支持 `async: true` + `claude -p` headless,但用户要求"用 LLM + 不每次跑 + 不懒触发"三条存在结构性张力)

**收敛拐点**:用户提"**或者使用 fork 之前进行意图识别?**" — 调度者意识到原诉求最小可行实现就是"fork 之前现场提取",不需要 GateGuard 全套 hook 系统。

**最终方向(方向「己」)**:fork 事件作为意图识别触发点,调度者(主对话 AI)现场提取意图注入挑战者 prompt。GateGuard 全套搁置(`ecc-analysis-snapshot.md §11.12` 保留作未来参考)。

---

## 2. 设计目标 + scope 边界

### 2.1 设计目标

| 目标 | 落地形式 |
|---|---|
| **G1**:fork 挑战者审查时拿到主线意图 | `synthesis-rules.md` 加事前规则 5 + 4 个领审员 agent 文件 fork 流程加"意图识别"步骤 |
| **G2**:调度者综合后报告通俗化 | `synthesis-rules.md` 加"综合输出表达准则"节 + 4 个领审员 agent 文件综合输出加"用户视图"段 |
| **G3**:不引入新 hook / skill / agent / 代码 | 纯 governance 文档 + agent 文件修改;`.claude/hooks/` 不动,`.claude/skills/` 不动,`.claude/agents/` 不新增文件 |
| **G4**:对齐 synthesis-rules 现有架构 | 事前 4 → 5 条;事后 4 条不动;新增"综合输出表达准则"作为独立节 |
| **G5**:README 原理段如实更新 | 4.2 综合阶段中性化的"实现"字段微调,反映新增节;不另起 1.3 GateGuard 原理(决策 Y) |

### 2.2 Scope 边界

**在 scope 内**:
- `synthesis-rules.md`:加事前规则 5(意图识别)+ 综合输出表达准则节
- `design-reviewer.md` / `evaluator.md` / `process-auditor.md` / `security-reviewer.md` 工作流改动
- `meta-review-rules.md` §3 流程引用 synthesis-rules 处补"事前规则 5 适用"
- `README.md` §4.2 实现字段微调
- (按 meta finishing)decision-trail.md 加 2026-05-25 拐点 + 本 spec 自身 + audit 文件

**不在 scope 内**:
- **GateGuard 全套三层 hook**(SessionStart / UserPromptSubmit / PreToolUse hook 实现) — 搁置,`ecc-analysis-snapshot.md §11.12` 保留作未来参考
- **C 用户确认 / 不可逆动作前拦截**(commit / push / 改 governance 前的强制确认) — 不实现
- **状态文件**(`intent-session.json` / `intent-task.json`) — 不创建
- **LLM CLI 调用**(`claude -p` headless 模式) — 不引入
- **brainstorming-rules.md 改动** — brainstorming 阶段的"需求深挖"已有(阶段二/三),不与本 batch 重叠;不在本 batch 改
- **designer.md 改动** — designer 是产生设计文档的 agent,不 fork 挑战者,不属"综合阶段",不动
- **新 skill / 新 agent / 新 hook 创建** — 全部不做

---

## 3. 详细设计

### 3.1 意图识别协议(synthesis-rules.md 事前规则 5)

#### 3.1.1 加在哪里

`synthesis-rules.md` 当前"事前规则 — 挑战者 prompt 构造中性化"节有 4 条硬规则。**在 4 条之后追加规则 5**。

#### 3.1.2 规则 5 全文(逐字落入 synthesis-rules.md)

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

  ## 主线-支线-关系(领审员 fork 前注入)
  - **主线**:[本会话整体任务,1-3 行]
  - **支线**:[本次挑战者的具体任务,1 行]
  - **关系**:[本支线服务于主线的哪一节,1-2 行]

挑战者审查时:
- **先读这一节**,理解审查的整体语境
- 然后按 A/B/C(或 N/G)段做审查
- 输出问题时,**可选**标注"是否真服务于主线"作为附加观察
  (不强制纳入评分;附加观察 vs 评分维度的边界详见 §3.1.4)

#### 与事前规则 1-3(中性化)的关系

规则 5 提供的"主线-支线-关系" 是**任务边界**(给挑战者明确审什么),不是
**结论引导**(不暗示"重点是 X、应找 Y"):
- ✅ "主线:本次会话整体在做 GateGuard 全套设计" — 任务边界,允许
- ❌ "主线:本次会话整体在做 GateGuard,**关键问题是 hook 触发频次**,
  请重点审" — 结论引导,违反规则 1-3 中性化

规则 5 的输出**必须只描述边界,不暗示结论**。
```

#### 3.1.3 规则 5 失败 / 边界

- **提取源全缺失**(handoff / spec / decision-trail 都没东西):提取出的"主线"字段标"[本会话无历史上下文,仅基于当前 user prompt]" — 不阻止 fork,但 audit trail 记一行警告
- **支线无明确目标**(用户没说审什么):调度者必须先跟用户对齐"本次 fork 审什么",再开始 fork — 不允许"猜支线"
- **关系字段写不出**(主线和支线明显无关):标"[本 fork 独立于主线,可能是 user 临时插入的 sub-task]" — 不阻止 fork,但 process-audit 应抓这种 case 作复盘

#### 3.1.4 附加观察 vs 评分维度的边界(防 scope creep)

挑战者在"是否真服务于主线"上的附加观察:
- **允许**:挑战者发现"本 fork 审的产物明显偏离主线意图" → 在输出末尾加一条 `🟡 偏离主线观察`,不纳入评分
- **不允许**:挑战者把"是否服务主线"当一个评分维度,扣分;这会违反"挑战者是对抗者不是评分员"原则

附加观察纳入调度者综合阶段判断(事后规则 1 "基于上下文意图综合"扩展点),不影响挑战者打分逻辑。

#### 3.1.5 适用范围(哪些 fork 必须做)

事前规则 5 适用所有"调度者面对挑战者"的 fork 场景(对齐 `synthesis-rules.md` 适用范围表):
- design-review(4 挑战者)
- evaluator(4 挑战者)
- process-audit(2 挑战者)
- security-scan(3 挑战者)
- meta-review(N 挑战者,模态决定)

不适用:
- designer fork(designer 是产生设计文档,不属综合阶段)
- 普通 Agent 工具调用(非"挑战者 fork"场景,如用 general-purpose agent 跑研究任务)

---

### 3.2 报告通俗化协议(synthesis-rules.md 综合输出表达准则节)

#### 3.2.1 加在哪里

`synthesis-rules.md` 当前结构:
1. 适用范围
2. 事前规则 4 条
3. 事后规则 4 条
4. 事前+事后规则的逻辑链
5. 引用本文件的治理文件
6. 相关 spec / decision

**在事后规则 4 条之后,逻辑链之前**,插入新节"综合输出表达准则"。

#### 3.2.2 综合输出表达准则全文(逐字落入 synthesis-rules.md)

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

### 4. 避免术语堆叠

- 一句话超过 2 个术语 → **拆成两句**
- 标题不用术语 ID,用动作描述
  - ✅ "##  fork 前要做意图识别"
  - ❌ "## §3.1.5 事前规则 5 落地"
- 列表项不嵌套 3 层以上(读着累)

### 应用范围

本准则适用调度者对**用户**的报告输出。
**不适用**:
- 调度者给挑战者的 prompt(挑战者是 AI,术语精确度优先于通俗)
- 调度者写到 audit / decision / spec 等持久化产物的内容(持久化产物供未来调度者读,术语精确优先)
- 调度者内部 reasoning(thinking 块,不输出给用户)
```

#### 3.2.3 与现有报告产物的关系

调度者综合产出的现有产物:
- design-review-result.md(design-review 综合)
- evaluation-result.md(evaluator 综合)
- 进程审计报告 audit-YYYY-MM-DD-HHMMSS.md(process-audit 综合)
- meta-review audit(meta-review 综合)

这些**持久化产物**写到 `docs/active/` 或 `docs/audits/`,**仍按现有格式**(术语精确优先),**不应用通俗化准则**。

调度者**对话中**给用户的报告(synthesis 后总结、回答用户问"这次审查通过了吗"等)应用通俗化准则。

---

## 4. 涉及文件 + 改动清单(逐文件)

### 4.1 `harness/docs/governance/synthesis-rules.md`(主改)

**改动 1**:在"事前规则 — 挑战者 prompt 构造中性化"节的 4 条硬规则之后,追加规则 5(详 §3.1.2 全文)

**改动 2**:在"事后规则 — 调度者综合阶段"节的 4 条之后、"事前 + 事后规则的逻辑链"节之前,插入"综合输出表达准则"节(详 §3.2.2 全文)

**改动 3**:"事前 + 事后规则的逻辑链"节内,事前规则数量从 "4 条" 改为 "5 条"

**改动 4**:适用范围段的表格不动(适用 scope 不变);"P2 阶段约束" 段不动

### 4.2 `harness/.claude/agents/design-reviewer.md`

**改动 1**:在"工作流程 → 第一步:在一条消息中并行 fork 4 个挑战者"段开头,加一节:

```markdown
### 第一步前 — fork 前意图识别(synthesis-rules 事前规则 5)

调度者按 synthesis-rules.md 事前规则 5,提取主线 / 支线 / 关系三字段,
作为独立段加入每个挑战者 prompt 的顶部(在 A/B/C 三段之前)。

格式:
  ## 主线-支线-关系(领审员 fork 前注入)
  - 主线:[...]
  - 支线:[...]
  - 关系:[...]
```

**改动 2**:在"第四步:写入结果"段后,加一节(可选,描述综合输出给用户时的通俗化适用):

```markdown
### 第五步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)

将 design-review-result.md(持久化产物,术语精确)写完后,**额外**
按 synthesis-rules "综合输出表达准则" 4 段格式给用户口语报告:
- 结论先行 / 关键发现 / 建议下一步 / 细节链接
```

### 4.3 `harness/.claude/agents/evaluator.md`

**改动 1**:同 4.2 改动 1(在 4 挑战者并行 fork 步骤前加意图识别节)

**改动 2**:同 4.2 改动 2(综合后给用户口语报告应用通俗化准则)

### 4.4 `harness/.claude/agents/process-auditor.md`

**改动 1**:同 4.2 改动 1,但适配 process-audit 2 挑战者(N1/N2 维度)结构

**改动 2**:同 4.2 改动 2

### 4.5 `harness/.claude/agents/security-reviewer.md`

**改动 1**:同 4.2 改动 1,适配 security-scan 3 挑战者结构(凭证 / 危险操作 / 注入混淆)

**改动 2**:同 4.2 改动 2

### 4.6 `harness/docs/governance/meta-review-rules.md`

**改动 1**:在 §3 流程"调度者并行 fork N 个挑战者"步骤,补一行说明:

```markdown
> 调度者按 synthesis-rules.md 事前规则 5,fork 前做意图识别,
> 把"主线-支线-关系"独立段注入每个挑战者 prompt 顶部。
```

(不在 meta-review-rules.md 内重复规则 5 全文 — 引用 synthesis-rules 路径即可)

### 4.7 `README.md`

**改动 1**:§4.2 综合阶段中性化原理 — 实现字段:

```diff
- 4.2 综合阶段中性化 ... 实现:`docs/governance/synthesis-rules.md` 完整规范
+ 4.2 综合阶段中性化 ... 实现:`docs/governance/synthesis-rules.md`(事前 5 条 + 事后 4 条 + 综合输出表达准则)
```

**不另起 1.3 节**(决策 Y) — 方向「己」的精神(fork 前现场意图识别)自然属于"综合阶段中性化"的扩展,不应作为独立第 7 个原理。

### 改动汇总

| 文件 | 改动数 | 性质 |
|---|---|---|
| synthesis-rules.md | 4 | 主改:加规则 5 + 加节 + 数量更新 |
| design-reviewer.md | 2 | 工作流加 2 节 |
| evaluator.md | 2 | 工作流加 2 节 |
| process-auditor.md | 2 | 工作流加 2 节 |
| security-reviewer.md | 2 | 工作流加 2 节 |
| meta-review-rules.md | 1 | 补引用一行 |
| README.md | 1 | 实现字段微调 |
| **合计** | **14 处** | 7 个文件(初摘要写 12 处,实际 14 处更准) |

---

## 5. Scope 判定 + finishing 路径

### 5.1 Scope 判定

按 `harness/.claude/hooks/meta-scope.conf` glob 命中(2026-05-25 已查证):
- `docs/governance/*.md` → 命中(synthesis-rules / meta-review-rules)— **A 组**
- `.claude/agents/*.md` → 命中(4 个 agent 文件)— **C 组**
- `README.md` → **不命中**(根级 README 不在 meta-scope.conf glob 内;A 组仅含 `docs/governance/*.md` + `CLAUDE.md`)

**判定**:**scope = meta**(主体 7 文件中 6 个命中 meta glob;README 改动作为本 batch 附带改动,按"任一命中即 meta / mixed 走 meta"规则,本 batch 整体走 meta finishing)

### 5.2 Finishing 路径

走 `harness/docs/governance/meta-finishing-rules.md`(M1):
1. 完整 commit 改动(分 1-2 commit,见 §9)
2. handoff 更新
3. decision-trail.md 加 2026-05-25 拐点
4. meta-review 触发(按 meta-review-rules.md M2)
5. audit 文件产出

### 5.3 Meta-review 模态选择

按 `meta-review-rules.md` §6 模态:
- **对抗式 D2**(自洽 / 完整 / 合理 / RUBRIC)— 适用 governance 规则改动
- 本 batch 是 governance 规则扩展 → 选**对抗式 D2 + minimum 4 维**
- 挑战者数量:**4-6**(基线 4,可加 2 个定制维度,如"通俗化准则的具体例子是否准确"等)

---

## 6. 测试 / 验收 / Evidence Depth

### 6.1 Evidence Depth

**meta-L2** — 规则文档 + agent 文件改动,无可执行代码逻辑,但有结构性约束。

档位标准(参 `harness/docs/governance/meta-finishing-rules.md`):
- meta-L1:文档级改动,无结构性约束
- **meta-L2**:文档 + 结构性约束(治理规则被引用 / 必须遵守) ✅ 本 batch 适用
- meta-L3:文档 + 自动化检查 hook
- meta-L4:文档 + 真实项目跑通

### 6.2 验收清单

- [ ] meta-review 走完,无 🔴 阻断项
- [ ] synthesis-rules.md 改后,事前规则数从 4 改为 5,各节顺序保持
- [ ] 4 个 agent 文件改后,工作流第一步前 + 写入结果后各加一节,格式与现有节风格统一
- [ ] meta-review-rules.md §3 补引用行,不重复规则全文(避免双源不一致)
- [ ] README.md §4.2 实现字段微调,不影响 §1.2 / §3.5 / §4.2 其他段
- [ ] decision-trail.md 加 2026-05-25 拐点(append 到顶部)
- [ ] handoff.md 更新本 batch 完成状态

### 6.3 实战验证(meta-L2 关键)

**落地后下次跑** design-review / evaluator / process-audit / security-scan / meta-review 时:
- 验证挑战者 prompt 真的含"主线-支线-关系"节(grep `## 主线-支线-关系` 在挑战者 prompt 或 audit trail 中)
- 验证调度者综合后给用户的报告应用通俗化准则(无 "M2 §3.1.5" 这类 raw ID,有结论先行 4 段格式)

**抽检在 process-audit 中跑** — 流程审计员检查最近一次 fork 的 prompt 是否含"主线-支线-关系",报告是否通俗;若违反,记到 audit。

---

## 7. 风险 / 反向追问 / 已知边界

### 7.1 反向追问(`feedback_dimension_addition_judgment`)

| 追问 | 答 |
|---|---|
| **不做意图识别,fork 还能拿到主线吗?** | 不能。现状是挑战者完全看不到调度者的主线意图;`synthesis-rules.md §1 "基于上下文意图综合"` 只管调度者综合时回到意图,不传给挑战者 |
| **不做通俗化,用户能读懂报告吗?** | 读不全。当前 audit / decision 文件含大量 M2/fix-N/§ID,用户每次得问"这是什么"才能跟上 |
| **只做意图识别不做通俗化,或反过来?** | 可分 2 batch,但 scope 一致(都是综合阶段 governance),分两次反而增加 meta-finishing / meta-review 开销 |
| **调度者每次 fork 前手动提取会漏吗?** | 三重兜底:synthesis-rules 强制治理规则 + meta-review 抽检 + process-audit 复盘;`feedback_iterative_progression` 适用 — 先做规则版,真出问题再加 hook |
| **为什么不做 GateGuard 全套?** | 全套 hook 解决"动作前 C 确认 + 三层意图粒度",超出 fork 拿主线这一个原诉求 — over-engineer;`ecc-analysis-snapshot.md §11.12` 保留作未来参考,真需求拉动时再启 |
| **为什么不引入 LLM CLI 调用?** | 方向「己」由调度者(主对话 AI 本身就是 LLM)现场提取,不需要 bash 调外部 LLM;成本 0,延迟 0 |

### 7.2 风险

**R1 — 调度者忘记做意图识别**
- **概率**:中等(治理规则可被绕过)
- **影响**:中等(挑战者拿不到主线,审查质量下降但不致命)
- **缓解**:meta-review 抽检 + process-audit 复盘 + 落地后跑首次审查时人工检查 prompt

**R2 — "主线-支线-关系" 提取质量差**
- **概率**:低(调度者就是 LLM,语义提取通常质量高)
- **影响**:低(质量差时挑战者只是少一点上下文,不影响审查独立性)
- **缓解**:无强制兜底;若实战发现质量差,后续 batch 加格式约束或 evidence depth 提升到 meta-L3

**R3 — 通俗化准则与现有 audit 持久化格式冲突**
- **概率**:低(本 spec §3.2.3 明确"持久化产物按现有格式")
- **影响**:低
- **缓解**:本 spec 已显式区分"对话报告 vs 持久化产物",4 个 agent 文件改动按此区分

**R4 — 事前规则 5 与中性化规则 1-3 边界混淆**
- **概率**:中等("主线-支线-关系" 措辞不当可能滑入"结论引导")
- **影响**:中等(违反中性化 → 多挑战者被 anchored,审查独立性受损)
- **缓解**:本 spec §3.1.2 明确边界(任务边界 ≠ 结论引导)+ 给出 ✅/❌ 例子 + meta-review 抽检措辞

### 7.3 已知边界 / 不在本 spec 范围内

- **不实现 GateGuard 全套**(三层 hook / 不可逆动作前 C 确认 / 状态文件 / LLM CLI 调用)
- **不改 brainstorming-rules.md**(brainstorming 阶段的"需求深挖"已有,不与本 batch 重叠)
- **不改 designer.md**(designer 不 fork 挑战者,不属综合阶段)
- **不改 hook 体系**(`.claude/hooks/` 不动)
- **不创建新 skill / 新 agent / 新 hook 文件**
- **不改 CLAUDE.md**(本 spec 改动不需要 CLAUDE.md 镜像;角色分离表中 4 个领审员 agent 已列,只是它们的 agent 文件内部加节)

---

## 8. 与现有架构的关系

### 8.1 与 GateGuard(`ecc-analysis-snapshot.md §11.12`)

- GateGuard 是设计哲学层(D 意图溯源链 + C 用户确认),P1 hook 未实现
- 方向「己」是 GateGuard "D 意图溯源链"在 fork 事件触发点上的**最小可行实现**
- GateGuard 全套(SessionStart + UserPromptSubmit + PreToolUse 三层 + C 确认)**搁置**,不在本 batch
- `ecc-analysis-snapshot.md §11.12` 内容**保留不动**(它是未来参考蓝本,本 batch 不 supersede 它)

### 8.2 与 synthesis-rules.md §1 "基于上下文意图综合"

- §1 是事后规则(综合阶段调度者回到意图)
- 事前规则 5 是事前规则(fork 前调度者把意图传给挑战者)
- **前后呼应**:挑战者拿到意图(事前 5) → 调度者综合时回到意图(事后 1) → 完整闭环
- §1 引用的"GateGuard 查意图机制提取的"措辞**保留** — 但事前规则 5 落地后,这句话不再仅是"未来参考",而是"事前规则 5 提取的"

> §1 的修订(可选,不强制本 spec 范围):"GateGuard 查意图机制" 改为 "事前规则 5 提取的" — 后续 batch 跟进,本 spec 不强制改

### 8.3 与 brainstorming-rules.md 阶段二/三 "需求深挖"

- brainstorming-rules 阶段二/三是**用户对接阶段**的需求清单,产出 `docs/superpowers/specs/[功能名]-design.md` §1 节
- 事前规则 5 的"主线"字段**复用** brainstorming 产出的需求清单作为来源
- 两者**串联**:brainstorming 产出主线 → 事前规则 5 提取主线 → 挑战者审查带主线

### 8.4 与 multi-agent-review-guide.md

- multi-agent-review-guide 是审查类 agent 设计的指南(对抗-决策分离原则)
- 事前规则 5 不改 multi-agent-review-guide 的核心原则(挑战者独立 / 决策者综合)
- 只是给挑战者多一个"语境上下文"输入(主线-支线-关系),挑战者仍独立审查

---

## 9. Commit 策略

### 9.1 分 commit 推荐

**Commit 1**:Governance 主体 + 锚点(synthesis-rules + meta-review-rules + README + decision-trail + spec 自身)
- `synthesis-rules.md`(加规则 5 + 通俗化节 + 数量更新)
- `meta-review-rules.md`(补引用行)
- `README.md`(实现字段微调)
- `decision-trail.md`(append 2026-05-25 拐点)
- `docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md`(本 spec)

**Commit 2**:Agent 文件应用新规则
- `design-reviewer.md`
- `evaluator.md`
- `process-auditor.md`
- `security-reviewer.md`

**理由**:Commit 1 是新规则诞生(治理层),Commit 2 是规则应用(执行层)。两者 cross-ref:Commit 2 引用 Commit 1 的规则路径,反向 Commit 1 描述规则也引用 4 个 agent 应用点。

**revert 约束**:Commit 1 revert 必须连带 Commit 2 revert(否则 Commit 2 引用的规则路径悬空);Commit 2 单独有问题可只 revert Commit 2,不影响 Commit 1。

### 9.2 也可合 1 commit

scope 小(14 处改动),如果偏好原子性,合一个 commit 也可。

### 9.3 不分支并行

本 batch 在 main 主线上单线性 commit(对齐 `2026-05-24-codex-shelved-batch-design.md §10` 既定模式)。

---

## 10. 验收 Checklist(spec 验收 → 落地 → finishing)

### Spec 验收
- [x] 设计方向(方向「己」)用户已批准
- [x] 6 节核心设计用户已批准(OK)
- [ ] **本 spec 文件用户审过**(下一步)
- [ ] spec 落到 `docs/superpowers/specs/` 并 commit

### 落地(implementer)
- [ ] 7 个文件按 §4 改动清单逐文件改
- [ ] 改完 + grep 验证(synthesis-rules 数量 5 / 4 agent 文件含"主线-支线-关系"节)
- [ ] 按 §9 分 commit(Commit 1 + Commit 2)
- [ ] handoff.md 更新

### Finishing
- [ ] decision-trail.md 加 2026-05-25 拐点
- [ ] meta-finishing 流程触发(参 M1)
- [ ] meta-review 跑(参 M2)— 4-6 挑战者 + 对抗式 D2
- [ ] audit 文件产出 + covers 字段覆盖 7 个改动文件

### 实战验证(meta-L2 关键)
- [ ] 落地后下次 fork 审查时,挑战者 prompt 真的含"主线-支线-关系"节
- [ ] 调度者综合后给用户的报告应用通俗化 4 段格式
- [ ] process-audit 抽检无违反

---

## 11. 关联文件

- 本 spec:`harness/docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md`
- 决策追溯:`harness/docs/decision-trail.md`(2026-05-25 拐点)
- 治理主改:`harness/docs/governance/synthesis-rules.md`
- 触发起源:`harness/docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11.12(GateGuard 设计哲学,保留作未来参考)
- 用户原诉求:2026-05-25 会话第 1 条 user message(本 spec §1.1 录入)

---

> **本 spec 版本 v1.0** — 2026-05-25 brainstorming approved,等待用户审 spec 文件本身 → 通过后转 writing-plans

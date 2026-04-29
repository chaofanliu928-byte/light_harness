# M1+M2+M4 治理改动 batch 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `finishing-rules.md` 反模式段加 M1(封死简化收尾)+ M2(RUBRIC 不作跳过依据)两条;在 `design-rules.md` 加 M4(轻量级判定第 4 列前置硬条件 + spec §0 偏离规则段)。走 meta-finishing 四步 + meta-review fork N 挑战者审查,batch 一次 commit + push。

**Architecture:** 纯 governance 文档文字硬编码改动,2 文件 / 3 处改动 / +20~+28 行;不涉及代码 / 不涉及测试 / 不涉及接口。验证靠 grep 回读 + meta-review fork N 挑战者(scope=meta,M2 流程)。

**Tech Stack:** Markdown(governance/*.md) + git + Claude Code Agent fork(meta-review 挑战者)

**Spec:** `docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md`(已批准 — 2026-04-28 brainstorming)

---

## File Structure

| 路径 | 操作 | 责任 |
|------|------|------|
| `docs/governance/finishing-rules.md` | 修改 | M1 + M2 反模式硬编码(在 L29 现有 2 条后追加 2 条) |
| `docs/governance/design-rules.md` | 修改 | M4-1 规模判断表加第 4 列(L26-L30)+ M4-2 加新段 `## spec §0 偏离规则`(在规模判断表后、§角色分离前) |
| `docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md` | 已存在 | brainstorming 产出 spec(本 plan 不再改) |
| `docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md` | 创建 | 本文件 |
| `docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md` | 创建 | meta-review pass 后立 — 方案选择型 decision(batch vs separate / M3 drop 理由 / 4 条已知缺口) |
| `docs/audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md` | 创建 | meta-review 挑战者审查 audit(YAML frontmatter `meta-review: true` + `covers:` 列改动文件路径) |
| `docs/decision-trail.md` | 修改 | append 1 条新抉择(时间倒序最新在上) |
| `docs/active/handoff.md` | 修改 | 目标段 / 已完成段 / 推后续阶段段 / Evidence Depth 段更新 |
| `docs/ROADMAP.md` | 修改 | P0.9.1.5 段 M1/M2/M4 标 🟢 已完成,M3 标 ⚪ drop |

---

## Task 1: M1 — finishing-rules.md 加封死简化收尾反模式条款

**Files:**
- Modify: `docs/governance/finishing-rules.md`(在 L29 后追加新条目,§反模式约束 段尾)

- [ ] **Step 1: 读取当前 L24-L31 区域,确认编辑锚点**

Run: `Read tool D:\个人\harness\harness\docs\governance\finishing-rules.md offset=24 limit=10`
Expected output 包含 L29 内容:
```
- **handoff 写入断言前必须 verification-before-completion**(2026-04-28 process-audit P-2 + N2 事件 5 实证):若 handoff 含"下次 SessionStart hook 自动注入 X"/"下次 session 会自动 Y"等断言,**必须先用 superpowers:verification-before-completion skill 验证**(实际 hook 是否注册 / 文件是否就位等),不得先写断言再口头说"应该会"。
```
L30 是空行,L31 是 `## 安全扫描`。

- [ ] **Step 2: Edit 工具追加 M1 条款**

old_string(精确匹配现有 L29 + L30 空行):
```
- **handoff 写入断言前必须 verification-before-completion**(2026-04-28 process-audit P-2 + N2 事件 5 实证):若 handoff 含"下次 SessionStart hook 自动注入 X"/"下次 session 会自动 Y"等断言,**必须先用 superpowers:verification-before-completion skill 验证**(实际 hook 是否注册 / 文件是否就位等),不得先写断言再口头说"应该会"。

## 安全扫描
```

new_string(在 L29 后追加 M1 条款,保留 L30 空行 + L31 `## 安全扫描`):
```
- **handoff 写入断言前必须 verification-before-completion**(2026-04-28 process-audit P-2 + N2 事件 5 实证):若 handoff 含"下次 SessionStart hook 自动注入 X"/"下次 session 会自动 Y"等断言,**必须先用 superpowers:verification-before-completion skill 验证**(实际 hook 是否注册 / 文件是否就位等),不得先写断言再口头说"应该会"。
- **不得主动提"简化收尾"二元方案**(2026-04-17 retrospective P0 报告 §"规则摩擦点"#1):agent 读本文件后,**不得**框出"A 严格 / B 简化"让用户选,**不得**给倾向性推荐"简化收尾"。
  - 唯一允许的降级路径:**fork-fail-degradation** — security-scan / evaluate / process-audit 任一 fork 失败 → 调度者按对应 agent.md 自审,标 `⚠️ 降级执行,未经独立 agent 验证`(本文件 §安全扫描 step 4 / §方向评估 step 9 / §流程审计 step 14 已有此约定)
  - 不允许的:**rule-bypass** — agent 觉得"重"主动跳过完整流程。若用户明确指示跳过,需写 `docs/decisions/<date>-skip-finishing-<reason>.md` 立档
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)

## 安全扫描
```

- [ ] **Step 3: 验证编辑成功**

Run: `Grep tool pattern="不得主动提.{0,5}简化收尾" path="docs/governance/finishing-rules.md" output_mode=content -n=true`
Expected: 命中 1 行,包含 "**不得主动提"简化收尾"二元方案**" 文字

- [ ] **Step 4: 验证 §安全扫描 标题仍存在**

Run: `Grep tool pattern="^## 安全扫描" path="docs/governance/finishing-rules.md" output_mode=content -n=true`
Expected: 命中 1 行,行号约 L36(原 L31 + 5 行新内容)

---

## Task 2: M2 — finishing-rules.md 加 RUBRIC 不作跳过依据反模式条款

**Files:**
- Modify: `docs/governance/finishing-rules.md`(在 Task 1 追加的 M1 条款后再追加 M2 条款,仍在 §反模式约束 段尾)

- [ ] **Step 1: 读取 Task 1 后的 finishing-rules.md L29-L40 确认锚点**

Run: `Read tool D:\个人\harness\harness\docs\governance\finishing-rules.md offset=28 limit=15`
Expected: 看到 L29 现有"verification-before-completion" + Task 1 追加的 M1 条款(5 行) + 空行 + `## 安全扫描`

- [ ] **Step 2: Edit 工具在 M1 条款后追加 M2 条款**

old_string(精确匹配 M1 条款的最后一子项 + 空行 + `## 安全扫描`):
```
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)

## 安全扫描
```

new_string(在 M1 条款最后一子项后追加 M2 条款,保留空行 + `## 安全扫描`):
```
  - 区分依据:fork-fail 是技术阻碍(下游可观测 — fork 调用返回错误 / agent 不可用),rule-bypass 是判断决策(需 decision 留痕)
- **RUBRIC 维度不得作跳过治理 step 的依据**(2026-04-17 retrospective P0 报告 §"完全没预料到的模式"#2 "spec §0 偏离说明成 bypass 载体"):
  - RUBRIC.md 是**评分标准**(产出衡量),**不**是 process 选取标准
  - 禁止句式:"因 RUBRIC 简洁性权重 23%,本 spec 不需要 design-review" / "RUBRIC 没有 X 维度,所以跳过 X step"
  - 评分维度 ≠ 流程豁免;治理流程的跳过依据由 governance/*.md 自身定义(如 design-rules.md "轻量级"判定),**不**引 RUBRIC

## 安全扫描
```

- [ ] **Step 3: 验证 M2 文字命中**

Run: `Grep tool pattern="RUBRIC 维度不得作跳过治理 step 的依据" path="docs/governance/finishing-rules.md" output_mode=content -n=true`
Expected: 命中 1 行

- [ ] **Step 4: 验证 §反模式约束 段共 4 条 bullet(2 现有 + 2 新增)**

Run: `Grep tool pattern="^- \*\*" path="docs/governance/finishing-rules.md" output_mode=content -n=true head_limit=10`
Expected: 4 行命中(`实战验证不阻塞` / `handoff 写入断言前` / `不得主动提.+简化收尾` / `RUBRIC 维度不得作跳过`),都在 L24-L40 范围内

---

## Task 3: M4-1 — design-rules.md 规模判断表加第 4 列前置硬条件

**Files:**
- Modify: `docs/governance/design-rules.md`(L26-L30 规模判断表)

- [ ] **Step 1: 读取当前规模判断表确认锚点**

Run: `Read tool D:\个人\harness\harness\docs\governance\design-rules.md offset=26 limit=5`
Expected output 精确匹配:
```
| 级别 | 判断标准 | 设计深度 |
|------|---------|---------|
| **轻量级** | 改动 1-2 个文件，不涉及新模块或接口变更 | 写**精简版设计文档**：只填第 1 节（需求摘要）+ 第 8 节（涉及文件和改动说明）+ 第 9 节自洽性检查中适用的项。不需要 design-review |
| **标准级** | 涉及新模块或接口变更，但不超过 3 个模块 | 写完整设计文档，不适用的节可写"不适用" |
| **重量级** | 涉及 4 个以上模块或跨系统交互 | 写完整设计文档，所有节必填 |
```

> **重要标点提示**:本表用全角中文标点(`，` `（` `）` `"`),Edit 必须用相同字符。复制粘贴 Step 1 Read 结果作为 old_string 来源。

- [ ] **Step 2: Edit 工具替换整个规模判断表 + 替换表头加第 4 列**

old_string(精确复制 Step 1 Read 输出 — 注意全角标点):
```
| 级别 | 判断标准 | 设计深度 |
|------|---------|---------|
| **轻量级** | 改动 1-2 个文件，不涉及新模块或接口变更 | 写**精简版设计文档**：只填第 1 节（需求摘要）+ 第 8 节（涉及文件和改动说明）+ 第 9 节自洽性检查中适用的项。不需要 design-review |
| **标准级** | 涉及新模块或接口变更，但不超过 3 个模块 | 写完整设计文档，不适用的节可写"不适用" |
| **重量级** | 涉及 4 个以上模块或跨系统交互 | 写完整设计文档，所有节必填 |
```

new_string(加第 4 列;轻量级行填 4 条前置硬条件,标准/重量级行填 `—` 表示无):
```
| 级别 | 判断标准 | 设计深度 | 前置硬条件(任一不满足升至标准级) |
|------|---------|---------|----------------------------------|
| **轻量级** | 改动 1-2 个文件，不涉及新模块或接口变更 | 写**精简版设计文档**：只填第 1 节（需求摘要）+ 第 8 节（涉及文件和改动说明）+ 第 9 节自洽性检查中适用的项。不需要 design-review | (1) 改动行数 < 100 行(`git diff --stat` 总和);(2) 不涉及 `docs/RUBRIC.md` 红线段(目录约定 / 命名规范 / 架构边界);(3) 不涉及多模块共用接口或类型;(4) spec §0 偏离说明不引 RUBRIC 维度做免审依据(与 finishing-rules.md `## 反模式约束` 段 M2 同步约束) |
| **标准级** | 涉及新模块或接口变更，但不超过 3 个模块 | 写完整设计文档，不适用的节可写"不适用" | — |
| **重量级** | 涉及 4 个以上模块或跨系统交互 | 写完整设计文档，所有节必填 | — |
```

- [ ] **Step 3: 验证表头加了第 4 列**

Run: `Grep tool pattern="前置硬条件\(任一不满足升至标准级\)" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行(L26 表头行)

- [ ] **Step 4: 验证轻量级行 4 条前置硬条件文字命中**

Run: `Grep tool pattern="改动行数 < 100 行" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行(L28)

Run: `Grep tool pattern="与 finishing-rules.md.+M2 同步约束" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行(L28)

- [ ] **Step 5: 验证标准/重量级行内容未误改**

Run: `Grep tool pattern="^\| \*\*标准级\*\* \| 涉及新模块或接口变更" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行,完整保留原"涉及新模块或接口变更，但不超过 3 个模块" 文字

---

## Task 4: M4-2 — design-rules.md 加新段 `## spec §0 偏离规则`

**Files:**
- Modify: `docs/governance/design-rules.md`(在规模判断表后、§角色分离前插入新段)

- [ ] **Step 1: 读取当前 L30-L40 确认锚点**

Run: `Read tool D:\个人\harness\harness\docs\governance\design-rules.md offset=30 limit=12`
Expected output 包含:
```
| **重量级** | 涉及 4 个以上模块或跨系统交互 | 写完整设计文档，所有节必填 | — |

**文档是第一公民。新建时先有文档再写代码，变更时先改文档再改代码。** 区别只在文档的厚度，不在有没有。

如果不确定级别，按**标准级**执行。

## 角色分离

本阶段由**独立的 designer agent** 执行（context: fork），不是调度者亲自做设计。
```

> 注:Task 3 改了表行加 `| —` 列;Step 1 Read 结果应反映 Task 3 的最新状态。

- [ ] **Step 2: Edit 工具在 L34 `## 角色分离` 前插入新段**

old_string(精确匹配现有 `如果不确定级别` 行 + 空行 + `## 角色分离`):
```
如果不确定级别，按**标准级**执行。

## 角色分离
```

new_string(在 `## 角色分离` 前插入新段,保留 `如果不确定级别` 行 + 空行 + 新段 + 空行 + `## 角色分离`):
```
如果不确定级别，按**标准级**执行。

## spec §0 偏离规则

- spec §0 "偏离说明"只允许记录**结构差异**(用什么 heading / 用什么编号 / 调整哪节顺序),**不允许**用来豁免 design-review(2026-04-17 retrospective P2 #"spec §0 偏离说明 不能用来免 design-review")
- 任何非 emergency 的 spec **必须至少过一次 design-review**;偏离模板者反而应**加强 review,不是减轻**
- 唯一不需要 design-review 的路径:轻量级判定(本文件 §规模判断 表)— 由表中四列前置硬条件机械判定,**不**由 spec 自宣告
- emergency 路径定义:线上故障紧急修复 + 同时缺时间走 design-review;事后必须补 design-review,不能"emergency 一次永久免审"

## 角色分离
```

- [ ] **Step 3: 验证新段标题命中**

Run: `Grep tool pattern="^## spec §0 偏离规则" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行(行号约 L36-L38)

- [ ] **Step 4: 验证新段 4 条 bullet 命中**

Run: `Grep tool pattern="emergency 一次永久免审" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行

Run: `Grep tool pattern="加强 review,不是减轻" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行

- [ ] **Step 5: 验证 §角色分离 仍存在且未误改**

Run: `Grep tool pattern="^## 角色分离" path="docs/governance/design-rules.md" output_mode=content -n=true`
Expected: 命中 1 行(行号约 L43-L45,因 Task 4 插入了 6 行新段)

---

## Task 5: 整体一致性回检

**Files:**
- 验证 finishing-rules.md / design-rules.md 改动后整体一致(无破坏性 / 无重复 / link 完整)

- [ ] **Step 1: finishing-rules.md 行数变化验证**

Run: `Bash tool wc -l "D:/个人/harness/harness/docs/governance/finishing-rules.md"`
Expected: 比改前 +9 行(M1 5 行 + M2 4 行)。原 110 行 → 现 119 行(±2 因换行差异)

- [ ] **Step 2: design-rules.md 行数变化验证**

Run: `Bash tool wc -l "D:/个人/harness/harness/docs/governance/design-rules.md"`
Expected: 比改前 +6 行(M4-1 表头加列不增行 + M4-2 新段 6 行含空行)

- [ ] **Step 3: 互引完整性验证**

Run: `Grep tool pattern="finishing-rules.md.+M2|design-rules.md.+M4|与 M2 同步约束" path="docs/governance" glob="*.md" output_mode=content -n=true`
Expected: 至少 1 命中(Task 3 design-rules.md L28 互引 finishing-rules.md M2)

- [ ] **Step 4: 反模式段总条数验证**

Run: `Grep tool pattern="^- \*\*" path="docs/governance/finishing-rules.md" output_mode=count`
Expected: 反模式段范围内 4 条;若 grep 不限范围可能更多(`^- \*\*` 也可能匹配其他行 — 接受多匹配,只要包含 M1/M2 两条新加的)

- [ ] **Step 5: 自指 bootstrap 自检**

调度者口头自检(无 grep):本批次 spec(`docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md`)是否符合 M2 / M4 新规则?
- M2:本 spec §1.6 是否引 RUBRIC 维度作跳过依据? 检查 spec §1.6 → 应明确声明"不引 RUBRIC 维度作判定" → ✅ 自洽
- M4:本 spec 是否符合轻量级 4 条前置硬条件? (1) 改动 < 100 行 ✅(目标 +20~+28) /(2) 不涉 RUBRIC 红线 ✅ /(3) 不涉多模块共用接口 ✅(governance 文档无接口) /(4) spec §0 不引 RUBRIC 免审 ✅ → 走轻量级合规
- 走 design-review? 否(轻量级路径);但走 meta-review(scope=meta) → ✅ 与轻量级 / meta-review 不互替一致

Expected: 5 条自检全 ✅

- [ ] **Step 6: 阶段性提交点 staging(不立即 commit)**

Run: `Bash tool git add docs/governance/finishing-rules.md docs/governance/design-rules.md docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md`
Expected: 4 文件 staged,无 error

Run: `Bash tool git status --short`
Expected: 4 行 `M ` / `A ` 标记,无 untracked 关键文件遗漏

> **不立即 commit**:走 meta-review(Task 6)再 batch commit(Task 8 / Task 9)

---

## Task 6: 走 meta-review fork N 挑战者(scope=meta,M2 流程)

**Files:**
- Create: `docs/audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`(挑战者 fork 完成后写)

> **流程**:严格按 `docs/governance/meta-review-rules.md`(M2)+ `meta-finishing-rules.md`(M1)Step B 走。

- [ ] **Step 1: 维度选取 — 调度者按 §6 pattern 节选**

按 `meta-review-rules.md` §6 子节 1(对抗式 4 维 A/B/C 三段)选维度。本 batch 主题"治理文档反模式硬编码 + 规则收紧",参考 M0 trial 选的 4 维基线:
- D1 核心原则合规(必选 minimum):是否违反 10 条用户原则 / spec_gap_masking / dimension_addition_judgment 等
- D2 目的达成度(必选 minimum):M1/M2/M4 各自宣称的"封死 / 不作依据 / 收紧"是否真有效
- D3 副作用(推荐):M1/M2/M4 改动是否有意外阻塞合法工作流(如 fork-fail-degradation 路径是否仍畅通)
- D4 scope 漂移(推荐):是否真在 §1.3 不做范围内,有无悄悄扩散到 RUBRIC.md / meta-review-rules.md / hook 等

- [ ] **Step 2: 构造挑战者 prompt(每个挑战者独立 context)**

每挑战者 prompt 包含:
1. 挑战者角色定义("你是 P0.9.1.5 batch trial meta-review 挑战者 N,关注维度: D[N]")
2. 维度焦点(从 §6 pattern 节 + 当次选取结果摘 1 段)
3. 待审查对象:
   - spec 文件 `docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md` 全文
   - plan 文件本身(这份 plan 全文)
   - 改动后的 `docs/governance/finishing-rules.md` + `docs/governance/design-rules.md`(完整文件,挑战者用 Read 工具读)
   - 上游 retrospective 报告 `C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`(P0/P2 改进建议来源,挑战者用 Read 工具读)
   - 上游 decision `docs/decisions/2026-04-17-harness-self-governance-gap.md`(M0-M4 起草背景)
4. 治理参考:`docs/governance/meta-review-rules.md` 全文 + `docs/governance/meta-finishing-rules.md` 全文 + `memory/MEMORY.md` 索引下 10 条 feedback
5. 输出约束:
   - 维度内 finding 列表(每个 finding:严重度 P0/P1/P2 + 证据引用 + 建议修补)
   - 给出 D[N] 维度 verdict:`pass` / `needs-revision` / `推翻`
   - 字节软上限:`meta-review-rules.md` §3.1.5 = 64KB;若超走拆维度多轮 fork

- [ ] **Step 3: 4 挑战者扁平 fork 并行(单 turn 4 个 Agent tool call)**

调度者在单个 message 中并行 4 个 Agent tool call,subagent_type 用 general-purpose(harness 当前 runtime 限制,详 `2026-04-16-fork-flat-refactor.md`)。

```
Agent({description: "Meta-review D1 核心原则合规", subagent_type: "general-purpose", prompt: "<D1 prompt>"})
Agent({description: "Meta-review D2 目的达成度", subagent_type: "general-purpose", prompt: "<D2 prompt>"})
Agent({description: "Meta-review D3 副作用", subagent_type: "general-purpose", prompt: "<D3 prompt>"})
Agent({description: "Meta-review D4 scope 漂移", subagent_type: "general-purpose", prompt: "<D4 prompt>"})
```

Expected: 4 挑战者各返回独立 finding 列表 + 维度 verdict

- [ ] **Step 4: 综合 4 挑战者结果**

调度者主对话:
- 列各挑战者 finding(去重 + 共识标注 — 多挑战者交叉的 finding 优先级最高)
- 综合 verdict:
  - 全 pass → 整体 `pass`
  - 任一 `推翻` → 整体 `推翻`(回 brainstorming)
  - 否则 → 整体 `needs-revision`(走 Step 5 修订)

- [ ] **Step 5: 写 audit 文件(5 段正文 + YAML frontmatter)**

按 `meta-review-rules.md` §7.5 的精确 5 段标题写到 `docs/audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`(HHMMSS 用当前实际时间)。

YAML frontmatter(精确格式见 spec §4.1.1 + `2026-04-28-m0-delete-block-dangerous` audit 参考):
```yaml
---
meta-review: true
covers:
  - docs/governance/finishing-rules.md
  - docs/governance/design-rules.md
verdict: pass / needs-revision / 推翻
date: 2026-04-28
challengers: 4
---
```

5 段正文:
- `## 1. 元信息`
- `## 2. 维度选取`
- `## 3. 挑战者执行记录`(每挑战者一节)
- `## 4. 综合`
- `## 5. 判定`

- [ ] **Step 6: 处理 verdict**

| verdict | 后续 |
|---------|------|
| `pass` | 直接进 Task 7 |
| `needs-revision` | 列 P0+P1+P2 修补点 → 修 spec/plan/governance 文件 → 重跑 Step 3-5 第 2 轮 fork(N=2 即可,不再 4 个) → 直到 pass |
| `推翻` | 停下与用户讨论,可能回 brainstorming 改方案 |

> M0 trial 是 `needs-revision → pass after revision`,本 batch 大概率类似;若 first-pass 直接 pass 反而要怀疑挑战者是否真在挑战(Step 7 自洽性反查)

- [ ] **Step 7: revision 后自洽性反查**

revision 后跑一遍 Task 5 整体一致性回检,确认修补未引入新冲突。

---

## Task 7: 立 decision file + decision-trail append + ROADMAP / handoff 同步(M1 Step D 通用同步项)

**Files:**
- Create: `docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md`(方案选择型 decision)
- Modify: `docs/decision-trail.md`(append 1 条新抉择,时间倒序最新在上)
- Modify: `docs/active/handoff.md`
- Modify: `docs/ROADMAP.md`

- [ ] **Step 1: 写 decision 文件**

文件路径:`docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md`

模板 — 方案选择型 + 含 batch vs separate 对比 + M3 drop 理由 + 4 条已知缺口:

```markdown
# M1+M2+M4 — 治理改动 batch(P0.9.1.5 第二个 trial)

**类型**:方案选择型 + P0.9.1.5 第二个 trial(用 harness 治理 harness 自身)
**日期**:2026-04-28
**触发**:用户(2026-04-28)指示":启动 M1-M4"(2026-04-17 起草的 M0-M4 治理修改批次第二项起)
**关联**:
- 上游 decision:`2026-04-17-harness-self-governance-gap.md`(M0-M4 起草)
- 上游 retrospective:`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`(P0 / P2 改进建议来源)
- 上游 spec:`docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md`(brainstorming 产出)
- 上游 plan:`docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md`(本批次实施计划)
- 同期 trial:`2026-04-28-m0-delete-block-dangerous.md`(P0.9.1.5 第一个 trial)
- 用户原则:`feedback_iterative_progression.md` / `feedback_dimension_addition_judgment.md`

---

## 问题

2026-04-17 retrospective 报告(老版本审查)识别 P0/P2 三条治理改进:
1. **P0 封死"规则可选化"路径**(M1):agent 主动提"A 严格 / B 简化"二元让用户选,治理文档无反应
2. **P0 spec §0 偏离 + RUBRIC 简洁性维度作跳过依据**(M2 + M4 部分):评分标准被反向用作规避标准
3. **P2 spec §0 偏离不能用来免 design-review**(M4 部分):轻量级判定标准弱,易被滥用

M0(删 block-dangerous)2026-04-28 完成,P0.9.1.5 第二个 trial 起 M1 + M2 + M4(M3 drop,见下)。

## 方案

**A. batch 1 个 trial(M1+M2+M4 一起)**(本次选定)
- 共享 brainstorming + meta-review fork + commit batch
- audit covers 4 文件(实际 2 个改动 + 2 个 spec/plan)
- meta-L4 数据点:1 个 batch 验证 P0.9.1 流程

**B. separate 4 个 trial(M1 / M2 / M3 / M4 各 1 个)**
- 4 次完整流程 + 4 个独立 audit
- meta-L4 数据点 ×4(治理流程被 trial 4 次)

## 决定

**采用 A(batch)+ M3 drop**

### A 选择理由

1. M1+M2+M4 都是 governance 文档级 hardcode,scope 全在 A 组(`governance/*.md`),改动相邻
2. M0 已产 1 个数据点;再 1 个 batch 数据点(改动多样化覆盖)对验证 P0.9.1 流程已足够,4 个数据点边际收益递减
3. 4 改动相互引用清晰(M2 通用 + M4 落地 design-rules.md 时同步声明 — `M4 表第 4 列条件 4 与 M2 同步约束`),batch 一次性看完比 4 次 trial 减少冲突可能

### M3 drop 理由

retrospective 报告里 M3 列两条 finishing 内部冲突:
- **#1 finishing-rules.md §15 vs archival 删除时机**:**已解决** — 当前 finishing-rules.md L49(确认存在用)+ L84(合并后删除)逻辑一致,archival-rules.md 已不存在(归档逻辑已融入 finishing-rules.md "通过分流"段)
- **#2 structured-handoff skill 分工模糊**:**超 scope** — skill 改动属 scope=C 组(`.claude/skills/*/SKILL.md`),需走自己的 trial,不在本 batch

→ 本批次 drop M3,#2 推 P0.9.2 实战观察期

## 反向追问(`feedback_dimension_addition_judgment` 原则要求)

**Q1:不删 fork-fail-degradation 路径 — 是否仍留 bypass 后门?**
A:fork-fail 是技术阻碍(可外部观测:fork 调用返回错误 / agent 不可用),与 rule-bypass(主观判断)有本质区别。fork-fail 不删,rule-bypass 走 decision 立档 — 区分清晰。

**Q2:M2 / M4 仅约束"如何引用 RUBRIC",RUBRIC.md 自身不变,是否漏了上游?**
A:RUBRIC 仍是评分标准(用于 evaluator agent 给分);本 batch 只禁止"用 RUBRIC 维度作跳过依据"。改 RUBRIC 自身=改评分语义,scope 完全不同,不在本 batch。

**Q3:M4 第 4 列"改动行数 < 100 行"是否过严?**
A:经验值 — 本 batch 改动 +20~+28 行,自身落入轻量级。100 行作经验上限,后续若实战不合理可在 P0.9.2 调整。

## 不做(防 scope 扩散)

- 不改 RUBRIC.md 自身(评分语义不变)
- 不改 meta-review-rules.md(M2 是反模式硬编码,不涉及 review 维度选取段)
- 不改 hook 校验(语义判断,M2 / M9 治理层负责)
- 不批量改 spec / plan / decision 中现有 RUBRIC 引用(本批次后产出的新文档遵守新规则即可)

## 已知缺口(显式承认 — `feedback_spec_gap_masking` 原则要求)

1. **agent 自律依赖**:M1 / M2 / M4 都是文字硬编码,无 hook 检测语义违规 — 接受,P0.9.2 实战观察期收集
2. **下游分发未覆盖**:本 batch 改 `harness/docs/governance/*.md`,下游已装项目本地副本不自动更新(与 M0 一致),不在本 batch 处理
3. **bootstrap 自指**:M2 提议的"不引 RUBRIC 作跳过依据"在本 batch spec §1.6 自身遵守;写时 M2 还没落地,但写法上预判 — 接受 bootstrap 自指
4. **M3 drop**:基于"#1 已解决 + #2 超 scope"判断;若 P0.9.2 实战观察期发现 structured-handoff skill 分工模糊在新场景重现,M3 重新进 ROADMAP

## 关联

- decision-trail append 一条新抉择"M1+M2+M4 — 治理改动 batch(P0.9.1.5 第二个 trial)"
- handoff:M1+M2+M4 完成留痕(P0.9.1.5 段更新)
- ROADMAP:P0.9.1.5 段 M1/M2/M4 状态 🟢 已完成,M3 标 ⚪ drop

## 后续

- **P0.9.1.5 已无剩余 M**(M0 完成 / M1+M2+M4 完成 / M3 drop)→ P0.9.1.5 整体闭合
- **P0.9.2 候选**:M3 #2(structured-handoff 分工)若实战重现 → 重启
- **链接保鲜**:无 — 本 decision 不依赖外部 URL
- **用户实际反馈**:落地后是否真的不再见"agent 主动提简化收尾"或"RUBRIC 维度作免审依据"?P0.9.2 实战观察期收集
```

- [ ] **Step 2: append decision-trail.md(`meta-finishing-rules.md` Step D 通用同步项)**

文件:`docs/decision-trail.md`

old_string(精确匹配现有 M0 条目顶部 — 当前最新在上):
```
## 2026-04-28 — M0:删 block-dangerous hook(P0.9.1.5 第一个 trial)
```

new_string(在 M0 条目前插入新条目,保留 M0 条目;新条目"最新在上"):
```
## 2026-04-28 — M1+M2+M4:治理改动 batch(P0.9.1.5 第二个 trial)

- **抉择**:batch 1 个 trial(M1 封死简化收尾 + M2 RUBRIC 不作跳过依据 + M4 轻量级判定收紧 + spec §0 偏离规则);M3 drop(报告 #1 已解决 + #2 超 scope)
- **替代**:separate 4 个 trial(meta-L4 数据点 ×4 但边际收益递减 + M0 已产 1 个数据点)
- **触发**:用户(2026-04-28)指示":启动 M1-M4"(2026-04-17 起草的 M0-M4 治理修改批次第二项起)
- **影响**:`finishing-rules.md` 反模式段加 M1+M2 两条;`design-rules.md` 规模判断表加第 4 列前置硬条件 + 加新段 spec §0 偏离规则;ROADMAP P0.9.1.5 段 M1/M2/M4 🟢 已完成 + M3 ⚪ drop;P0.9.1.5 整体闭合
- **decision file**:[2026-04-28-m1-m2-m4-governance-batch.md](decisions/2026-04-28-m1-m2-m4-governance-batch.md);audit:[meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md](audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md)

## 2026-04-28 — M0:删 block-dangerous hook(P0.9.1.5 第一个 trial)
```

> 注:`<HHMMSS>` 用 Task 6 Step 5 创建 audit 时的实际时间替换。

- [ ] **Step 3: 更新 ROADMAP.md**

文件:`docs/ROADMAP.md` L33-L34 区域(P0.9.1.5 段)

old_string(精确匹配当前 M0 / M1-M4 描述):
```
  - 🟢 **M0**(2026-04-28 完成):删 block-dangerous hook — 首个 trial,验证 P0.9.1 治理流程从 brainstorming → meta-review → finishing 跑通(audit `meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`)
  - M1-M4:封死简化收尾 / 元规则评分维度不得作跳过依据 / 修 finishing 内部冲突 / 轻量级判定收紧 — 等用户启动
```

new_string(M0 不变;M1-M4 段更新为已完成 + drop):
```
  - 🟢 **M0**(2026-04-28 完成):删 block-dangerous hook — 首个 trial,验证 P0.9.1 治理流程从 brainstorming → meta-review → finishing 跑通(audit `meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`)
  - 🟢 **M1+M2+M4**(2026-04-28 完成):治理改动 batch — 第二个 trial(audit `meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`,decision `2026-04-28-m1-m2-m4-governance-batch.md`);finishing-rules.md 加 M1 封死简化收尾 + M2 RUBRIC 不作跳过依据;design-rules.md 加 M4 轻量级判定第 4 列前置硬条件 + spec §0 偏离规则段
  - ⚪ **M3 drop**(2026-04-28):报告 #1 已解决(finishing 删除时机 L49+L84 已统一) + #2 超 scope(structured-handoff skill 分工属 C 组,推 P0.9.2 实战观察)
```

随后,P0.9.1.5 整体可在 ROADMAP "已完成下一步"段从"M0-M4 启动"改为"P0.9.1.5 整体闭合"。

- [ ] **Step 4: 更新 handoff.md**

文件:`docs/active/handoff.md`

改三处:

(a) 顶部 `## 目标` 段(L9-L14):加 P0.9.1.5 第二个 trial 完成

old_string:
```
P0.9.1 self-governance 已完成 + meta-review pass(audit `meta-review-2026-04-28-102359-p0-9-1-self-review.md`);
P2 可观测性双层落地 + glassbox 角色 reframe(用户级外部工具,推荐不分发);decision-trail harness 自带。
**P0.9.1.5 第一个 trial 已完成 — M0 删 block-dangerous**(2026-04-28,audit `meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`,verdict=pass after revision)。
下一步:由用户决定何时启动 M1-M4 之一,或继续其他方向 — 边做边提升,无预设阶段。
```

new_string:
```
P0.9.1 self-governance 已完成 + meta-review pass(audit `meta-review-2026-04-28-102359-p0-9-1-self-review.md`);
P2 可观测性双层落地 + glassbox 角色 reframe(用户级外部工具,推荐不分发);decision-trail harness 自带。
**P0.9.1.5 整体闭合**(2026-04-28):
- M0 删 block-dangerous(第一个 trial,audit `meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`)
- M1+M2+M4 治理改动 batch(第二个 trial,audit `meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`)
- M3 drop(报告 #1 已解决,#2 超 scope 推 P0.9.2 实战观察)

下一步:边做边提升,无预设阶段。
```

(b) `## 进度 ### 已完成(本会话最最最后一批)` 段:加 M1+M2+M4 batch 详情(在 M0 trial 段之前,作为最新)

(c) `## Evidence Depth` 段:加 meta-L4 第二条数据点(M1+M2+M4 batch trial 跑通 P0.9.1 流程)

(d) `## 下一步建议` 段:删原"启动 M1-M4 之一"选项,改为"M1+M2+M4 已完成,P0.9.1.5 闭合;边做边提升的下一步等用户决定"

具体文字按 §8.3 spec 元改动同步要求,内容与本 plan 一致。

- [ ] **Step 5: 验证所有 4 文件改动 staged**

Run: `Bash tool git status --short`
Expected: `M docs/decision-trail.md` / `M docs/ROADMAP.md` / `M docs/active/handoff.md` / `A docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md` / `A docs/audits/meta-review-...md` 等

---

## Task 8: batch commit + push

**Files:**
- 全 batch 改动一次 commit(governance 改动 + spec + plan + audit + decision + decision-trail + handoff + ROADMAP)

- [ ] **Step 1: 最终 staging 检查**

Run: `Bash tool git status --short`
Expected: 至少 9 个文件 staged:
```
M  docs/governance/finishing-rules.md
M  docs/governance/design-rules.md
A  docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md
A  docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md
A  docs/audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md
A  docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md
M  docs/decision-trail.md
M  docs/active/handoff.md
M  docs/ROADMAP.md
```

- [ ] **Step 2: git diff --stat 总和验证**

Run: `Bash tool git diff --cached --stat`
Expected: 9+ 文件,改动行数大致 +400~+600 行(spec ~300 行 + plan ~500 行 + decision ~120 行 + audit ~150 行 + governance 改动 ~30 行 + ROADMAP/handoff/decision-trail ~30 行)

- [ ] **Step 3: commit message + commit**

Run: `Bash tool` 执行:
```bash
git -c commit.gpgsign=false commit -m "$(cat <<'EOF'
feat(p0.9.1.5): M1+M2+M4 治理改动 batch(第二个 trial,P0.9.1.5 闭合)

- M1: finishing-rules.md 加封死简化收尾反模式条款(防"A 严格/B 简化"二元再现 + 区分 fork-fail-degradation vs rule-bypass)
- M2: finishing-rules.md 加 RUBRIC 维度不得作跳过治理 step 的依据反模式条款(评分维度 ≠ 流程豁免)
- M4: design-rules.md 规模判断表加第 4 列前置硬条件(4 条机械门槛) + 加新段 spec §0 偏离规则(偏离不能用来免 design-review)
- M3 drop: 报告 #1 已解决(finishing 删除时机已统一) / #2 超 scope(structured-handoff skill 推 P0.9.2)
- meta-review: 4 挑战者扁平 fork,verdict=<pass/pass after revision>(audit `meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`)
- P0.9.1.5 整体闭合: M0 + M1+M2+M4 共 2 个 trial 数据点,P0.9.1 治理流程双重验证

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

> **--gpg-sign 处理**:M0 trial commit 用 `-c commit.gpgsign=false`(2026-04-28 实证,GPG 在 Win 环境时失败);保留同一处理。

- [ ] **Step 4: 验证 commit 成功**

Run: `Bash tool git log -1 --format="%h %s"`
Expected: 输出本次 commit 的 short hash + commit message 第一行

- [ ] **Step 5: push**

Run: `Bash tool git push origin main`
Expected: 推送成功,远程更新到本次 commit

- [ ] **Step 6: 回填 commit hash 到 decision file 关联段(可选)**

decision file `## 关联` 段加 commit hash(从 Step 4 输出取):

Edit decision file 末尾的 `## 关联` 段加 1 行 — `- commit hash:<hash>`,然后 amend?

> **不 amend**:M0 trial 也未 amend,与 P0.9.1 finishing-rules.md L85 "已决定的标注关联 commit hash" 在 feature 路径生效,meta 路径用 audit covers 做反向链(audit YAML covers + 落地 commit 时间),不需要在 decision file 里硬写 hash。**跳过 Step 6**。

---

## Task 9: 反审待办字段 + 后续

- [ ] **Step 1: handoff `## 反审待办` 段更新**

old_string:
```
P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`
```

new_string:
```
P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`
P0.9.1.5 第二个 trial(M1+M2+M4)反审 — 已完成 — audit:`docs/audits/meta-review-2026-04-28-<HHMMSS>-m1-m2-m4-governance-batch.md`
```

- [ ] **Step 2: 把更新后的 handoff.md 单独再 commit + push(若 Task 8 后才更新)**

若 handoff `## 反审待办` 在 Task 8 commit 时已包含 → 跳过 Step 2;若是 Task 8 后单独更新 → 单独 commit:

Run: `Bash tool git -c commit.gpgsign=false commit -am "docs(handoff): P0.9.1.5 反审待办更新"`

> **建议**:Task 7 Step 4 (d) 时一起改 handoff `## 反审待办` 段,不留单独 commit,避免 git history 碎片化

- [ ] **Step 3: TaskList 状态更新**

调度者主对话:把 Task 30-35 全标 `completed`(已建好 task graph 见 brainstorming 流程)。

---

## Self-Review

### Spec coverage

- [x] M1 封死简化收尾 — Task 1
- [x] M2 RUBRIC 不作跳过依据 — Task 2
- [x] M4-1 轻量级判定第 4 列 — Task 3
- [x] M4-2 spec §0 偏离规则段 — Task 4
- [x] §8.3 元改动同步项(decision-trail / ROADMAP / handoff / decision file) — Task 7
- [x] §1.5 决策(batch / M3 drop / 不引 hook) — decision file 内 + Task 7 Step 1
- [x] §9.4 4 条已知缺口 — decision file `## 已知缺口` 段
- [x] meta-review fork N 挑战者(scope=meta) — Task 6
- [x] PROGRESS.md 不更新 — §8.3 #2 与本 plan Task 7 一致
- [x] memory 不新建 — §8.3 #6 与本 plan 一致

### Placeholder scan

- 无 TBD/TODO
- `<HHMMSS>` 占位:audit 文件名 / decision-trail link / ROADMAP / handoff / commit message — 在 Task 6 Step 5 创建 audit 时获取实际时间后**全文 replace**(写在 Task 7 / Task 8 之前完成 replace)
- `<pass/pass after revision>` 占位:Task 8 Step 3 commit message — 在 Task 6 Step 6 verdict 确定后填实际 verdict
- `<hash>` 跳过(Task 8 Step 6 决定不 amend)

### Type/path consistency

- spec / plan 文件名一致:`2026-04-28-m1-m2-m4-governance-batch-design.md` + `-plan.md`
- decision 文件名一致:`2026-04-28-m1-m2-m4-governance-batch.md`(无 design 后缀)
- audit 文件名格式与 M0 一致:`meta-review-YYYY-MM-DD-HHMMSS-<topic>.md`
- ROADMAP / handoff / decision-trail 三处都引同一个 audit 文件名 — 落地时一致 replace

### 反向追问(plan 自身)

**Q:Task 6 meta-review 拿到 first-pass `pass` 是否要怀疑挑战者真在挑战?**
A:M0 trial first-pass `needs-revision`(挑战者发现 git tracking + 措辞偏移 + 缺口未承认 3 类问题)。本 batch 改动 +20~+28 行更小,挑战者 finding 数量预期更少。但若直接 `pass` 无任何 finding,Task 6 Step 7 的 revision 自洽性反查作为兜底——若 4 挑战者都 0 finding 反而触发"挑战者是否真在审"的元疑问,调度者可主动加一轮 D5 维度(meta:挑战者本身的有效性)再 fork 1 个挑战者审挑战者。**写入 Task 6 Step 6 备注**(若直接 pass 无 finding → 加 D5 元挑战)。

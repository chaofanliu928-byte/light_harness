# harness 回溯指南(self-retrospective)

> **scope**:本指南限于 **harness 自仓库自身的回溯**(对 self-trial / 阶段性总结 / 技术债评估)。
>
> **不适用**:下游项目用 harness 后做项目级 retrospective(那是 P0.9.2 实战观察期议题,scope 不同)。
>
> **触发**:本指南由 2026-05-07 用户问"下次回溯参考哪些文件"立。后续每次回溯前读本指南做参照,不必从头摸索。

---

## 1. 何时做回溯(触发条件)

下列任一发生时值得做:

- **单 trial 闭合后**:比对前 trial,看模式是否重现(本 trial P0.9.3 第二个 trial 闭合 → 比对第一个 trial 的 22 已知缺口继承情况)
- **累积 N 个 trial 后**(N=3-5):看跨 trial 共性问题(本期 trial 序列 = M0 / M1+M2+M4 / P0.9.3 第一+第二 = 4 trials 已可做)
- **进入新阶段前**:如 P0.9.2 实战启动前,先做 self-trial 数据 retrospective
- **用户感觉"重复犯错"**:本 trial 的 6 错链 spec_gap_masking 模式正是此类信号
- **ROADMAP 长期不动**:看是否有未识别 blocker

## 2. 看什么(按层次)

### 2.1 第一入口:`docs/decision-trail.md`

时间倒序判断拐点索引。读法:从最新条目读 N 条,每条 5 字段:
- **抉择**:做了什么 / 不做什么
- **替代**:被否决的方案 + 否决理由
- **触发**:数据 / 用户原则 / 实战观察驱动
- **影响**:实际改动 + 副产物 + 跨 trial 传染
- **decision file 链接**:深入单条完整推理

→ 找模式:同类抉择反复出现?用户原则被违反?

### 2.2 单 trial 三联文档

每 trial 由四联文档构成(任一缺失说明 trial 不完整):

| 文档 | 角色 | 位置 |
|---|---|---|
| **spec** | 设计快照 + §0 偏离说明 + §9.4 已知缺口 + 教训留痕 | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` |
| **plan** | bite-sized TDD 实施步骤 + Pre-Task / Post-Implementation 引导 | `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` |
| **audit** | 独立 meta-review(N challengers,verdict) | `docs/audits/meta-review-YYYY-MM-DD-HHMMSS-<topic>.md` |
| **decision** | 决策记录 + 不做段 + 教训留痕 + 实施清单 commits | `docs/decisions/YYYY-MM-DD-<topic>.md` |

回溯时四联同读,完整还原 trial 的判断链。

### 2.3 跨 trial 模式:spec §9.4 已知缺口

每 trial spec 的 §9.4 列已知缺口(不修但承认)。回溯比对:

- 哪些缺口**继承**(persisting across trials)?是否积累到值得开 trial 闭合?
- 哪些是**新增**?是不是同根因再次显现?
- 教训留痕节(本 trial #25):是不是值得抽到 memory feedback 跨项目持久化?

### 2.4 governance 健康度:`docs/governance/*.md`

- 哪条 governance 在本 trial 被**违反**?(违反 ≠ 忘读;是有意 / 无意 不遵守)
- 哪条 governance 在 trial 中**新加 / 修改**?(governance 演化轨迹)
- 哪条 governance 是"纸面"(无 hook enforcement,仅 documented)?

### 2.5 用户原则:`memory/MEMORY.md` + `feedback_*.md`

每条 user feedback 验证:
- 本 trial 是否遵守?(失败案例 = 流程错处)
- 是否有新原则需要 persist?(如本会话 codex+claude 编排 已 persist 为 `project_codex_claude_orchestration.md`)
- 是否有"原则被违反但留痕完整"?(如本 trial 第 4-6 错的 spec_gap_masking 模式)

### 2.6 阶段状态:`docs/ROADMAP.md` + `docs/PROGRESS.md`

- ROADMAP 哪些条目长期不动?为什么(等数据 / 主动需求弱 / 已 accept 关闭)?
- PROGRESS 里程碑节奏健康?
- 有"完成"被悄悄 reopen 的项?

### 2.7 当前 session 上下文:`docs/active/handoff.md`

- **Evidence Depth 段**(最重要):meta-L1~L4 评级 + 当前批 / 历史批 + 数据点
- **反审待办**:P0.9.1 落地反审 / 历次 trial 反审完成状态
- **跳过字段**(`## meta-review/cross-ref: skipped`):若残留说明 finishing 未跑全,需补

## 3. 关注哪些模式(本 trial 实证 — 后续 trial 拿来对照)

### 3.1 spec_gap_masking(便利答案掩盖规范缺口)

- **用户原则**:`feedback_spec_gap_masking.md`("便利答案掩盖规范缺口")
- **本 trial 实证**:6 错链(spec §9.4 #25 + decision §教训留痕)
  - 第 1 错(P0.9.3 trial 1 audit revision 接受叙事未自验)
  - 第 2 错(brainstorming 视觉跳过间接引用)
  - 第 3 次纠正(用户提示后 grep 重审)
  - 第 4 错(spec 写 anchor 未 grep 验证字面)
  - 第 5 错(correction commit sweep 不全)
  - 第 6 错(meta-review challenger 3 暴露 sweep scope 仍局限本 trial,漏上游)
- **5 教训**(spec §9.4 #25 教训):
  1. 写 PAIRS 时**当场** grep 验 anchor 字面在目标文件存在
  2. 区分**形式声明** vs **引用文字**;anchor 应在被引方形式声明 site
  3. 区分**直接引用** vs **间接引用**
  4. 修字面错时**全仓库 grep 扫**(包含跨 trial 上游 + 引用方文字镜像 + commit msg template)
  5. 测试场景预期列必须标"是否依赖外部状态"(handoff 字段 / git 工作树状态)

**回溯关注**:
- 本期 trial 有没有新的 spec_gap_masking 实例被识别但**未留痕**?
- 教训第 4 / 5 条是否被真正应用?(还是又重犯)
- 5 错链 / 6 错链是否积累成值得 persist 的 memory feedback?(目前埋在 spec §9.4,memory 未提取)

### 3.2 self-trial 通胀(self-trial inflation)

- **用户原则**:`feedback_iterative_progression.md` + `feedback_realworld_testing_in_other_projects.md`
- **风险**:harness 自仓库做太多 trial,没真实数据 → 自言自语
- **本 trial 实证**:13 commits + ~36 行 code + ~440 行 spec + ~640 行 plan(文档/代码 ≈ 30:1)— 是 meta-trial 惯例还是过度文档化?

**回溯关注**:
- 本期 trial 多少由**用户判断拉动**?多少是 AI"建议补做"?
- meta-L4 实战数据是否累积?(P0.9.2 启动 gating)
- 是否在 self-trial 内 try 替代真实项目数据?(违反 `feedback_realworld_testing_in_other_projects`)

### 3.3 governance bootstrap 循环

- **用户原则**:`feedback_unprovable_in_bootstrap.md`(bootstrap 系统在落地前不可证)
- **本 trial 实证**:meta-review-rules.md 改自身 → 由自身 hook 审 → 接受自指(M2 §1.1 已 documented bootstrap 接受)

**回溯关注**:
- 是否在 bootstrap 阶段对未落地系统提出"应该已 work"的判断?(违反原则)
- 是否清楚区分"具体可证缺陷"vs"bootstrap 阶段不可证问题"?

### 3.4 文档/代码体量比例

本 trial:~36 行 code + ~1080 行 spec/plan = 30:1 文档代码比。

**回溯关注**:
- 过度文档化(`feedback_iterative_progression` 视角)?
- spec/plan 内有冗余可删?(本 trial spec §9.4 #24/#25/#26 留痕必要,但 plan inline fixture 代码块对 ~36 行改动可能过厚)

## 4. 历史记录索引(找上次怎么做的)

| 想了解 | 去哪查 |
|---|---|
| 时间顺序 + 跨 session 抉择 | `docs/decision-trail.md`(顶部最新) |
| 单条决策完整推理 | `docs/decisions/<YYYY-MM-DD>-<topic>.md` |
| 设计偏离 / 已知缺口 / 教训留痕 | `docs/superpowers/specs/<...>-design.md` §0 + §9.4 |
| 独立 review(挑战者真发现) | `docs/audits/meta-review-<...>.md` |
| 实施细节(commit-level) | `git log --oneline <range>` + commit messages(本 trial = `d54754f..ecc05ed`) |
| 用户原则(跨项目持久化) | `~/.claude/projects/<proj>/memory/MEMORY.md` + `feedback_*.md` |
| 阶段状态 | `docs/ROADMAP.md`(粗) + `docs/PROGRESS.md`(细) |
| 当前 session 状态 | `docs/active/handoff.md`(Evidence Depth 段最重要) |
| 归档老 trial | `docs/audits/archive/` + `docs/completed/`(若有) |
| 关键 commit hash 速查 | trial decision file §实施清单(本 trial 例:13 commits 列表 in `2026-04-30-d-class-tech-debt-batch.md`) |

## 5. 不应做的事(防止 retrospective 滥用)

- ❌ **基于 retrospective 推预设阶段**(P0.9.4 / P0.9.5 / 等)— 违反 `feedback_iterative_progression`
- ❌ **推翻已闭合 decision 但无新数据**支撑 — 违反 `feedback_judgment_basis`
- ❌ **在 self-trial 内补 meta-L4 实战数据** — 违反 `feedback_realworld_testing_in_other_projects`
- ❌ **把 retrospective 当 meta-review 替代**(retrospective 是回顾,不替代独立 challenger fork)
- ❌ **推 dream-skill / Outcomes / Anthropic 产品作改进项 without 数据** — 违反 `feedback_judgment_basis`(Harvey 6x / Wisedocs 50% 是 specific case 不可外推到 harness solo dev / well-curated 状态)
- ❌ **更新 README / QUICKREF 仅为"形式完整"** — 违反 `feedback_iterative_progression`(仅在用户实际反馈不清楚时才更)

## 6. retrospective 输出形式(轻重选择)

不必每次都立 decision file:

| 形式 | 字数 | 位置 | 适用 |
|---|---|---|---|
| **极轻** | < 200 字 | 调度者口头汇报,handoff Evidence Depth 段微调 | 单 trial 闭合即时小结 |
| **轻** | < 500 字 | handoff.md 末尾"Retrospective"段(临时,structured-handoff 时归档) | 单 trial 关键发现 |
| **中** | 1-2 页 | `docs/active/retrospective-YYYY-MM-DD.md` | 跨 trial 模式总结 |
| **重** | 完整 trial 级 | 立 decision file(D9 范式 — 根源承认型) | 发现根源问题需要立档 |

**不立任何文档也合理** — retrospective 价值是**调度者下次 session 的判断依据**,不一定要 artifact。`feedback_iterative_progression` 适用。

## 7. 一个完整回溯流程示例(供参考)

假设你在 P0.9.3 第三个 trial 启动前回溯:

1. **读 decision-trail.md 顶部 5-10 条** — 看最近 1-2 个月的判断拐点
2. **找 trial 序列**:M0 → M1+M2+M4 → P0.9.3 第一 → P0.9.3 第二
3. **每 trial 读 4 联文档**(spec / plan / audit / decision)— 这步可以让 subagent 做(读完 summarize finding)
4. **比对 §9.4 已知缺口**:列出 4 个 trial 各自缺口数 + 继承情况(本 trial 22+3+1+1 = 4 个 trial 累积 27 已知缺口)
5. **找模式**:本指南 §3 的 4 个模式各对照检查
6. **检查用户原则**:本 trial 是否违反某条 feedback?
7. **决定**:
   - 是否值得开新 trial?(`feedback_iterative_progression` — 数据驱动 ✓)
   - 是否需要新 memory feedback?(本 trial 6 错链是候选)
   - 是否值得 update 治理 rule?(违反次数 ≥ 3 是信号)

---

## 关联

- **本指南触发**:2026-05-07 用户问"下次回溯参考哪些文件"
- **上一次 retrospective 实例**(参考但不可直接套用):`D:\项目\智能体-生图\docs\active\harness-retrospective-2026-04-29.md`(下游项目对老 harness 的 retrospective,**P0.5 重构前数据**;现状架构变了,数据不可直接外推)
- **trial 序列**(本指南 §7 示例引用):
  - M0(2026-04-28):删 block-dangerous(P0.9.1.5 第一个 trial)
  - M1+M2+M4(2026-04-28~29):治理 batch(P0.9.1.5 第二个 trial)
  - P0.9.3 第一个 trial(2026-04-29):governance 漂移检测(commit `c0810e8`)
  - P0.9.3 第二个 trial(2026-04-30~05-06):D 类技术债 batch D1+D4(commit `ecc05ed`)
- **下一阶段 gate**:P0.9.2 实战观察期启动条件 — meta-L4 真实数据点 ≥ N(N 由用户判断,不预设)

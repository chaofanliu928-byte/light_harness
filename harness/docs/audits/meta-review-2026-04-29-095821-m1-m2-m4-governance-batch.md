---
meta-review: true
covers:
  - docs/governance/finishing-rules.md
  - docs/governance/design-rules.md
  - docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md
  - docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md
verdict: pass-after-revision
date: 2026-04-29
challengers: 4+2
revision_rounds: 1
---

# Meta-Review: M1+M2+M4 治理改动 batch(P0.9.1.5 第二个 trial)

## 1. 元信息

- **改动主题**:M1+M2+M4 治理改动 batch — 封死简化收尾 / RUBRIC 不作跳过依据 / 轻量级判定收紧 + spec §0 偏离规则
- **scope**:meta(A 组 governance/*.md);M3 drop(理由见 decision file)
- **改动范围**:`docs/governance/finishing-rules.md`(L24-L37 §反模式约束加 M1+M2 共 9 行)+ `docs/governance/design-rules.md`(L26-L30 表加第 4 列 + L36-L41 spec §0 偏离规则段)
- **trial 序号**:P0.9.1.5 第二个 trial(M0 是第一个,2026-04-28 完成)
- **brainstorming 当天**:2026-04-28(用户 ":启动 M1-M4")
- **meta-review 实际 fork 时间**:2026-04-29 09:58:21(跨日继续 trial)
- **挑战者数**:4(D1 / D2 / D3 / D4)+ revision 后第 2 轮(待补)
- **使用 model**:挑战者全用 sonnet(implementer 用 haiku)
- **关联**:
  - spec:`docs/superpowers/specs/2026-04-28-m1-m2-m4-governance-batch-design.md`
  - plan:`docs/superpowers/plans/2026-04-28-m1-m2-m4-governance-batch-plan.md`
  - 上游 retrospective:`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`
  - 上游 decision:`docs/decisions/2026-04-17-harness-self-governance-gap.md`(P0.9 / M0-M4 起草)
  - 同期 trial:`docs/audits/meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`(M0 trial)

## 2. 维度选取

按 `docs/governance/meta-review-rules.md` §6 子节 1 对抗式 pattern,选 bootstrap 4 维基线(任何 meta 改动必选):

### 本次定制
- **启用的推荐维度**:无新增推荐维度(基线 4 维已覆盖本次审查需求)
- **禁用的推荐维度 + 理由**:无禁用
- **新增的定制维度 + 理由**:无新增
- **本次具体维度焦点**:
  - **D1 核心原则合规**:10 条用户 feedback 原则 / harness 治理范畴 / bootstrap 自指
  - **D2 目的达成度**:M1/M2/M4 各自宣称"封死/不作依据/收紧"是否真有效;具体场景反例
  - **D3 副作用**:合法工作流是否被阻塞 / 下游污染 / 既有治理冲突 / 维护负担 / cross-file 互引脆弱性
  - **D4 scope 漂移**:应改未改(grep 检查)/ 多改了 / M3 drop 理由验证 / 元改动同步项完整性

scope=meta,evidence depth 文件按 `meta-review-rules.md` L286 引 `docs/governance/meta-finishing-rules.md` 内含的 meta-L1~meta-L4。

## 3. 挑战者执行记录

### 挑战者 1(D1 — 核心原则合规)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P1) — spec §9.3 Q3 "100 行经验值"违反 judgment_basis 原则
- **证据**:spec §9.3 Q3 用"P0.9.1 多数 governance 改动的上限"作 100 行依据;但引用的 M0 trial +345/-39 是"已升标准级反例",逻辑方向反向佐证轻量级上限。无 harness governance 改动行数分布实测。
- **建议修补**:改为诚实声明 — "100 行是本 batch 自洽所用的内部阈值,无实测支撑,P0.9.2 实战观察期可能调整(spec §9.4 缺口同类)"

#### F2 (P1) — spec §9.3 Q3 反向追问未真正覆盖"100 行"阈值选择本身
- **证据**:Q3 只回答"是否过严",未做 dimension_addition_judgment 原则要求的反向追问"如果不加第 4 列前置硬条件,原问题如何解决"
- **建议修补**:补真正反向追问 — "如果不加,旧机制只'改动 1-2 个文件',无法阻止 spec 自宣告 + RUBRIC 简洁性滥用,故第 4 列必要,不是过度工程化"

#### F3 (P2) — spec §9.4 缺口 #3 "类似 decision-trail 元条目"类比包装
- **证据**:类比依据未论证为何同构,有 spec_gap_masking 倾向(轻微)
- **建议修补**:删类比,直接引 `feedback_unprovable_in_bootstrap.md`

#### F4 (P2) — spec §1.6 RUBRIC 风险标记节自反声明歧义
- **证据**:用 RUBRIC 术语描述节,内含"不引 RUBRIC 作判定"声明 — 两步阅读才可消歧义
- **建议修补**:开头加澄清 — "以下描述性使用 RUBRIC 术语是为便于对话,不作判定依据(M2 约束)"

#### F5 (P2) — plan Task 6 反向追问"D5 元挑战"未在 spec §9.4 立缺口
- **证据**:"4 挑战者全 pass 无 finding 触发 D5 元挑战"是治理判断逻辑,只在 plan 反向追问段提到,无 spec 缺口立档
- **建议修补**:spec §9.4 加新缺口"挑战者有效性元疑问 — first-pass 全 pass 无 finding 时无机制强制加 D5 元验证;接受,P0.9.2 收集场景频率"

#### F6 (P2) — plan Task 8 `-c commit.gpgsign=false` 用户授权链
- **证据**:plan 引"M0 trial 实证"作为复用依据,但先例不等于显式授权
- **建议修补**:decision file / plan 注 — "用户在 M0 trial 时授权(2026-04-28 GPG Win 失败实证),本 batch 沿用"

### 挑战者 2(D2 — 目的达成度)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P1) — M1 fork-fail vs rule-bypass 区分有"未发起 fork 即声称失败"滑动路径
- **证据**:retrospective 原始违规是 agent 读完 rules 后**预判性**主动框 A/B,发生在真正尝试 fork 之前。M1 子项区分依据"下游可观测"在 Claude Code runtime 主对话中无 fork 调用 audit trail 强制
- **建议修补**:M1 子项加防滑条款 — "agent 不得在未实际发起 fork 调用前就声称 fork 失败。若 fork 调用未发出,跳过理由须在 decision 中写明'未尝试 + 原因',不适用 fork-fail 降级路径"

#### F2 (P2) — M0 "后续未见违反"验证局限于 harness self-trial
- **证据**:M0 trial 验证执行者(主对话)在 meta 路径下有大量治理上下文注入,不代表下游 feature 路径 agent 遵从度
- **建议修补**:spec §9.4 #1 补 — "实战验证时间线:P0.9.2 应在下游真实项目首次使用 finishing-rules.md 时采集,不以 harness 内部 trial 替代"

#### F3 (P1) — M2 落地层(finishing-rules.md)与原始违规发生层(design 阶段写 spec §0)错位
- **证据**:retrospective P.71 原始违规是 designer agent 在 design 阶段写 spec §0 时引 RUBRIC 简洁性免审。M2 在 finishing-rules.md(finishing 阶段读),M4 spec §0 偏离规则段在 design-rules.md(design 阶段读)— M4 才是真正预防层,M2 是辅助。spec 把 M2 和 M4 并列为独立"封死",有夸大效果之嫌
- **建议修补**:design-rules.md `## spec §0 偏离规则` 段加互引 — "另见 finishing-rules.md `## 反模式约束` 段 RUBRIC 维度不作跳过依据条款(M2 同步约束)";finishing-rules.md M2 条款加 — "本条款也适用于 design 阶段 spec §0 写法;designer 在写 spec §0 偏离说明时同步遵守(见 design-rules.md `## spec §0 偏离规则`)"

#### F4 (P1) — M4 条件 (2)(3) 实质是语义判定,与"机械门槛"目的矛盾
- **证据**:条件 (1) 改动行数 < 100 行 ✅ 机械(`git diff --stat`);(4) spec §0 不引 RUBRIC ✅ 可 grep 检测;但 (2) "不涉 RUBRIC 红线段(目录约定/命名规范/架构边界)" + (3) "不涉多模块共用接口或类型" 是语义判断,依赖 agent 理解
- **建议修补**:design-rules.md 在 4 条前置硬条件后加"对条件 (2)(3) 有疑问时,默认升至标准级 — 不确定就走 design-review,与 §规模判断段尾'按标准级执行'一致"

#### F5 (P2) — M4 emergency 路径定义对 harness 自身是 dead code
- **证据**:emergency = "线上故障紧急修复",harness 自仓库无线上故障场景
- **建议修补**:design-rules.md emergency 段加注 — "(harness 自身仓库:harness feature scope 改动同样适用;meta scope 改动走 meta-review,不经本路径)"

#### F6 (P2) — M3 drop #1 验证依赖内部重读,无独立验证
- **证据**:"L49+L84 一致"是重读判断,不是 P0.9.1 主动修复;无 decision 文件对应该判断
- **建议修补**:decision file M3 drop 理由补 — "#1 验证方式:重读 finishing-rules.md L49+L84(改后行号会漂移)时序逻辑,无冲突;无独立 agent 验证"

#### F7 (P1) — spec §9.4 #1 验证论据偏弱,未声明 harness self-trial ≠ 下游 agent 的局限
- **证据**:同 F2,但作为独立 P1 升级
- **建议修补**:spec §9.4 #1 补充"M0 后续未见违反的验证限于 harness 自身 trial,执行者(调度者主对话)在 meta 路径有大量上下文注入,不代表下游 agent 在普通 feature 路径 finishing 时的遵从度。P0.9.2 应在下游真实场景采集第一手数据"

### 挑战者 3(D3 — 副作用)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P2) — M1 文字"§安全扫描 step 4"等引用与 finishing-rules.md 实际结构错位
- **证据**:文件中无显式 "step 4" 节标题,只有数字列表 "4."。下游 agent 可能误读
- **建议修补**:改"§安全扫描 step 4"为"§安全扫描第 4 项"或类似清晰引用

#### F2 (P2) — M2 禁止句式枚举不完备 — 严格按字面执行的 agent 可能找变体
- **证据**:列了 2 个具体例子,无"等同类"说明
- **建议修补**:在两例后加"(以及任何以 RUBRIC 评分维度推导 process 路径的变体句式)"

#### F3 (P1) — M4 表 L28 cross-file 互引 finishing-rules.md M2 缺失效检测,spec §9.4 #1 未覆盖
- **证据**:spec §9.4 #1 声明"agent 自律依赖",不覆盖"两文件间标题/语义引用失效"维护脆弱性。若 finishing-rules.md M2 改名/删除,design-rules.md 保留悬空
- **建议修补**:spec §9.4 加 #5 — "M4 表 L28 条件 (4) 互引 finishing-rules.md `## 反模式约束` 段 + M2 条款;无自动同步机制(无 hook 检测 cross-file 标题引用有效性);后续维护需人工核查两文件一致性,P0.9.3 hook 兜底候选"

#### F4 (P1) — emergency 路径"线上故障"语言对 harness 自身语义失配
- **证据**:design-rules.md 分发下游(setup.sh L97-L103);harness 仓库 feature scope 改动场景仍读到 emergency 路径但"线上故障"不适用;spec 未声明此点
- **建议修补**:同 D2 F5,design-rules.md emergency 段加 harness 语境注

#### F5 (P2) — 下游分发污染:M1/M2 条款引"retrospective 报告"对下游不可见
- **证据**:M1/M2 条款文字引"2026-04-17 retrospective P0 报告" — 该文件在 harness 仓库本地,下游不可见。规则本身语义独立,不阻断
- **建议修补**:spec §9.4 #2 扩充 — "新装下游得到 M1/M2 条款时,条款中的 retrospective 来源引用对下游不可见(文件在 harness 仓库本地),但规则本身语义独立,不影响下游遵守"

#### F6 (P2) — §反模式约束 段从 2→4 条,无膨胀约束
- **证据**:无规则约束"段最多多少条",长期会膨胀
- **建议修补**:spec §9.4 加 #6 — "finishing-rules.md 反模式约束段从 2→4 条;无上限约束;P0.9.2 可考虑数量门槛或分类(通用反模式 vs 阶段特定)"

#### F7 (P2) — M1 ↔ meta-finishing-rules.md Step A skip 路径关系未声明
- **证据**:M1 在 feature 路径,meta-finishing-rules.md Step A 在 meta 路径,无重叠;mixed scope 时调度者同时遵守两套但 spec §9.1 未声明
- **建议修补**:spec §9.1 自洽性检查加"M1 ↔ meta-finishing Step A:路径不重叠;mixed scope 同时遵守但无语义冲突"

#### F8 (P2) — M2 文字可能被宽泛解读阻断 evaluator 评分
- **证据**:M2 "RUBRIC 不是 process 选取标准",evaluator agent 读 finishing-rules.md 时可能误读为"不能引 RUBRIC 给分"
- **建议修补**:M2 第一子项后加 — "RUBRIC 仍是 evaluator agent 的评分依据(evaluate skill 正当引用);本约束仅限于'用 RUBRIC 维度推导是否跳过某治理 step'的决策语境"

### 挑战者 4(D4 — scope 漂移)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P2) — DESIGN_TEMPLATE.md L14 "轻量级"描述未同步 M4 第 4 列
- **证据**:DESIGN_TEMPLATE.md L14 仍写"轻量级需求只填第 1、8、9 节",未提 4 条前置硬条件;DESIGN_TEMPLATE.md 是 D 组(scope 内)
- **建议修补**:DESIGN_TEMPLATE.md L14 加引用 — "轻量级判定需满足 design-rules.md §规模判断 4 条前置硬条件";或 spec §1.3 "不做"显式排除 DESIGN_TEMPLATE.md
- **决定**:加引用(DESIGN_TEMPLATE.md 进 staged 文件)

#### F2 (P1) — staged 文件目前 4 个,Task 7 未执行,Task 8 Stage 时需校验完整 9 文件清单
- **证据**:meta-review 在 Task 7 之前(正确流程);最终 commit 范围必须覆盖 decision/audit/decision-trail/ROADMAP/handoff
- **建议修补**:Task 8 Stage 前严格 grep 占位符 + 对照 plan Task 8 Step 1 Expected 清单

#### F3 (P2) — spec §8.3 "memory 不新建" vs meta-finishing-rules.md Step D `project_harness_overview.md` 区分不清
- **证据**:两者是不同 memory 项,spec/plan 措辞混淆
- **建议修补**:spec §8.3 加 — "memory/project_harness_overview.md 无需更新 — M1/M2/M4 不涉新模块/接口/架构变更"

#### F4 (P1) — spec/decision "L49+L84" 行号在 M1+M2 新增 9 行后悬空
- **证据**:spec §1.5 #2 + decision file 引"finishing-rules.md L49+L84"作 M3 drop #1 解决证据;落地后实际行号变为 L57+L92
- **建议修补**:decision file M3 drop 理由 + spec §1.5 #2 改为语义描述 — "security-scan-result.md 在 §方向评估 step 7 用于检查,在 §通过 Step 9 归档删除 — 两处职责不同,不存在单一事实源冲突"

#### F5 (P2) — M3 drop #2 后续 trial 路径未明
- **证据**:decision 说"#2 推 P0.9.2",但未说 P0.9.2 启动时走什么 trial 流程
- **建议修补**:decision file `## 后续` 加 — "M3 #2 若 P0.9.2 启动,scope=C 组(`.claude/skills/*/SKILL.md`),走 meta-finishing + meta-review(M2 流程)"

#### F6 (P2) — handoff/ROADMAP 残留"等用户启动"文字(待 Task 7 执行)
- **证据**:plan Task 7 已布步骤;风险在 `<HHMMSS>` 占位符替换是否全文完成
- **建议修补**:Task 7 执行后 + Task 8 Stage 前,grep `<HHMMSS>` 验证已替换

## 4. 综合

### 共识 finding(多挑战者交叉,优先级最高)

| Finding 主题 | 挑战者 | 严重度 | 修补优先级 |
|---|---|---|---|
| spec §9.4 #1 验证论据偏弱(harness self-trial ≠ 下游) | D2-F2 + D2-F7 | P1 | 高 |
| emergency 路径"线上故障"对 harness 自用语义失配 | D2-F5 + D3-F4 | P1 | 高 |
| spec §9.4 缺 cross-file 互引脆弱性条目 | D3-F3 | P1 | 高 |
| spec §9.3 Q3 100 行经验值 + 反向追问不彻底 | D1-F1 + D1-F2 | P1 | 高 |
| M1 fork-fail 区分有"未发起即声称失败"滑动 | D2-F1 | P1 | 高 |
| M2 落地层与违规发生层错位(M2 是辅助,M4 才是主) | D2-F3 | P1 | 高 |
| M4 条件 (2)(3) 是语义判定不是机械门槛 | D2-F4 | P1 | 高 |
| spec/decision "L49+L84" 行号悬空 | D4-F4 | P1 | 高 |
| DESIGN_TEMPLATE.md L14 轻量级描述未同步 M4 | D4-F1 | P2 | 中(staged 多 1 文件) |
| Task 8 Stage 完整性校验 | D4-F2 | P1 | 流程性,Task 8 严格执行 |

### 独立 finding(单挑战者,P2 多但建议修)

- D1-F3 删 bootstrap 自指类比 / D1-F4 §1.6 加澄清 / D1-F5 加 D5 元挑战缺口 / D1-F6 GPG 授权链
- D2-F6 M3 drop #1 验证方式注
- D3-F1 step X 改第 X 项 / D3-F2 禁止句式补"等同类" / D3-F5 retrospective 不可见 / D3-F6 反模式段膨胀缺口 / D3-F7 M1 ↔ Step A 路径不重叠 / D3-F8 evaluator 误读防护
- D4-F3 project_harness_overview vs memory 不新建区分 / D4-F5 P0.9.2 trial 路径

### 整体特征

挑战者们识别了 **声称强度 vs 实际约束强度** 的根本张力:
- spec 用"封死"一词夸大效果(M1/M2/M4 都不能真"封死")
- 实际是文字硬编码反模式(降低概率,无机械执法)
- 主要争点不是设计错误,而是 spec 自我评价的措辞精度

修补集中在:
1. **spec §9.4 加 5 条新缺口**(F2-7 / F3-3 / F3-5 / F3-6 / F1-5)
2. **spec §9.3 Q3 重写**(F1-1 / F1-2)
3. **finishing-rules.md M1/M2 条款加防滑/澄清**(F2-1 / F2-3 / F3-1 / F3-2 / F3-8)
4. **design-rules.md emergency / 默认升级 / 互引**(F2-3 / F2-4 / F3-4)
5. **DESIGN_TEMPLATE.md 同步**(F4-1)
6. **decision file 行号语义化 + GPG 注 + P0.9.2 路径**(F4-4 / F1-6 / F4-5)

无需推翻整体设计,所有 P1/P2 修补在本批次内可完成(spec 文字 + 2 governance 文件 + DESIGN_TEMPLATE.md + decision file)。

## 5. 判定

### 5.1 第 1 轮 verdict — needs-revision

4 挑战者(D1/D2/D3/D4)全部 needs-revision,共识 finding 见 §4。

### 5.2 修订执行(13 处,4 文件)

| # | 修订 | 文件 | 解决 finding |
|---|------|------|------------|
| 1 | spec §9.3 Q3 重写(诚实声明 + 真正反向追问) | spec | D1-F1 + D1-F2 |
| 2 | spec §9.4 加 5 条新缺口(#5-#9) | spec | D1-F5 / D2-F2+F7 / D3-F3 / D3-F5 / D3-F6 |
| 3 | spec §1.6 加 RUBRIC 术语澄清 | spec | D1-F4 |
| 4 | spec §9.4 #3 删 bootstrap 类比 + 引 unprovable_in_bootstrap | spec | D1-F3 |
| 5 | spec §1.5 #2 行号悬空改语义化 | spec | D4-F4 |
| 6 | spec §8.3 #6 拆 memory/MEMORY 与 project_harness_overview | spec | D4-F3 |
| 7 | spec §9.1 加 M1↔Step A 关系条目 | spec | D3-F7 |
| 8 | finishing-rules.md M1 加防滑条款 | finishing-rules.md | D2-F1 |
| 9 | finishing-rules.md M1 step X → 第 X 项 | finishing-rules.md | D3-F1 |
| 10 | finishing-rules.md M2 加跨阶段同步 + evaluator 防护 + 等同类变体 | finishing-rules.md | D2-F3 / D3-F2 / D3-F8 |
| 11 | design-rules.md spec §0 偏离规则段加 M2 互引 + harness 语境注 | design-rules.md | D2-F3 / D2-F5 / D3-F4 |
| 12 | design-rules.md 4 条前置硬条件后加默认升级原则 | design-rules.md | D2-F4 |
| 13 | DESIGN_TEMPLATE.md L14 同步 4 条前置硬条件引用 | DESIGN_TEMPLATE.md | D4-F1 |

### 5.3 第 2 轮 fork(N=2,简化验证)

**D2 第 2 轮挑战者**(model=sonnet):
- D2-F1 防滑条款 — ✅(命中 finishing-rules.md L34)
- D2-F3 跨阶段同步约束 — ✅(finishing-rules.md L39 + design-rules.md L45 双向互引)
- D2-F4 默认升级原则 — ✅(design-rules.md L36)
- D2-F7 spec §9.4 #5 缺口 — ✅(spec L175)
- P2 D2-F2/F5/F6 — ✅
- 新问题:无结构性冲突,2 处轻微观察不影响规则
- **D2 verdict**:**pass**

**D4 第 2 轮挑战者**(model=sonnet):
- D4-F4 spec §1.5 #2 行号语义化 — ✅(无 L49+L84 引用,改语义描述)
- D4-F1 DESIGN_TEMPLATE.md L14 — ✅(内容已写入)
- D4-F3 project_harness_overview 区分 — ✅
- 三处互引闭环验证 — ✅(finishing M2 ↔ design-rules `## spec §0 偏离规则`;design-rules 表第 4 列 ↔ finishing M2;design-rules `## spec §0 偏离规则` 底部 ↔ finishing M2)
- scope 边界:所有改动在 A 组(governance/*.md)+ D 组(DESIGN_TEMPLATE.md)内,无 scope 外文件被改 — ✅
- **预警**:DESIGN_TEMPLATE.md / 部分 governance 第 2 轮修订仍 unstaged(MM 状态)— Task 8 re-stage 时一并处理(流程性,非 spec 缺陷)
- **D4 verdict**:**pass(带预警)**

### 5.4 Final verdict

**pass after revision**

(参考 M0 trial:`meta-review-2026-04-28-215638-m0-delete-block-dangerous.md` 也是 pass after revision — P0.9.1 治理流程对 batch trial 仍然有效,本批次产 **P0.9.1.5 第二个 meta-L4 数据点**)

### 5.5 落地承诺(Task 7 / Task 8 执行)

1. Task 7 立 decision file(`docs/decisions/2026-04-28-m1-m2-m4-governance-batch.md`)— 含本 audit 引用 + 13 处修订记录 + 4 条 P0/P1 共识缓口在 spec §9.4 #5-#9
2. Task 7 同步 ROADMAP / handoff / decision-trail
3. Task 8 batch commit:**re-stage** 全部修订(尤其 DESIGN_TEMPLATE.md 当前未 staged + design-rules.md / finishing-rules.md 第 2 轮修订未 staged + spec 第 2 轮修订未 re-staged)
4. Task 8 commit message 含 verdict=pass after revision,引本 audit 文件名

### 5.6 已知未办

- D4-F2 staged 完整性:Task 8 严格按 plan Task 8 Step 1 Expected 9 文件清单核对
- D4-F6 `<HHMMSS>` 占位符:Task 7 落地后 grep `<HHMMSS>` 验证全文替换为 `2026-04-29-095821`
- D4-F5 P0.9.2 trial 路径:写入 decision file `## 后续` 段
- D1-F6 GPG 授权:决定 file 注明"用户在 M0 trial 时授权(2026-04-28),本 batch 沿用"

---

> Audit 完整。落地见 Task 7 / Task 8。

# 治理同层化(凭证参数化)设计

> **状态**:**已锁定**(2026-06-13,用户审阅"没意见")。流程:designer 落稿(736 行)→ 调度者降级自检(⚠️ 子代理限额,六项高危声明实证全过,留痕)→ design-review 四挑战者(自洽/完整/合理/原则对齐,全 needs-revision——其中合理性挑战者迁移演练实证三发全中)→ 合并修订 40 项(八簇+杂项,修订者自查 6 处清单冲突)→ 合并复核(可提交,2 Minor)→ 收尾(R1-R14 计数+件 28 批次归属)→ 用户审阅通过。审阅轮拍板三项随审随落:R13 字段全换/R14 cross-ref 删除/工序适用(decision 追记一至三)。
> **需求源**:`docs/decisions/2026-06-13-governance-single-layer.md`(用户拍板,commit c8e4b4a;追记锚:ffc4b3a = 追记一/二(R13 字段全换 + R14 cross-ref 删除)、2ebc7b7 = 追记三(收口工序适用);乙案三件套 + 第一性重推四件 + 地图硬要求 + 命名收敛 + 不做清单)。本 spec 不得偏离该 decision;发现 decision 内部张力之处记入 §10「待回决策」,不自行裁决方向。
> **锁定性质**:沿既有惯例**单件 immutable + 方向级变化整体取代**(与 `2026-06-12-context-layer-design.md` 状态头同款)——笔误级微修正走本状态头留痕;再有方向级变化 → 新 decision + 新版 spec 整体取代本文件。
> **路径约定**:文内 `docs/...`、`.claude/...` 以 `harness/` 为基准(与台账锚点写法同形);仓库根文件写「根 CLAUDE.md」「根 AGENTS.md」;audit covers 中根级文件沿 `<root>/` sentinel 现协议。
> **取证声明**:本 spec 全部"现状"断言基于 2026-06-13 对实物的 Read/Grep(行动公设);§7 枚举为 git grep 实跑(命中并集 98 件)。

---

## §1 需求摘要(从 decision 忠实转录)

### 1.1 问题(decision「问题」节原文要义)

meta 治理比正常治理多一层:两套 finishing(M1/M5)、两套审查规则、scope 分流机器(M3 三表 ↔ M17 conf 双写)、三个 skip 字段、两套证据档位。实证:每个仓库实际只活在一条轨上(自仓库几乎全 meta、下游零 meta),双轨复杂度两边都付,收益只在理论上的 mixed;开场对账只核 meta scope,凭证制度不完整。

### 1.2 用户原话(判断锚点,逐字转录)

- "我希望可以回退一个概念,也就是meta治理需要比正常治理多一层,我不建议这样,最好是使用同一层,你觉得呢?"(2026-06-12,发起)
- "先治理,后交接"(排序拍板)
- 下游统一性选 **A 彻底同层**(同文分发/同凭证义务/对账工具分发/meta-* 消亡)
- 结构方案选 **乙**:"乙吧,做好地图"(凭证制度独立成件;**地图=硬要求**)
- "这个地方要以第一性原理去重新审查"(对迁移方案的纠偏——否决"搬箱子"式迁移)
- "同意"(2026-06-13,对第一性重推版)
- "换,并且全换,我们不改内容,这个应该是格式问题,这样也不会出现两个章。"(2026-06-13 spec 审阅轮:凭证字段名全换 — R13;decision 追记)
- "删除"(2026-06-13 spec 审阅轮:cross-ref 件删除 — R14;decision 追记)

### 1.3 需求清单(R1-R14:R1-R12 由 decision「决定」「地图」「命名收敛」「不做」四节转录,R13/R14 由追记转录)

| # | 需求 | decision 出处 |
|---|------|--------------|
| R1 | finishing-rules = 唯一收口(原 M1 步骤并入) | 决定·三件套 |
| R2 | review-rules = 唯一审查(维度选择表:代码\|设计\|治理 → 维度集+力度;治理类 = bootstrap 4 维强制 + 触点完整性按需 + N 弹性) | 决定·三件套 |
| R3 | credentials-rules.md 新件:凭证与对账(audit 产物规范/失效规则/对账规程/凭证要求表人读版/证据档位参数化) | 决定·三件套 |
| R4 | credentials.conf = 原 meta-scope.conf 改名降格(凭证要求表机器版) | 决定·三件套 |
| R5 | 契约锁机制退役(非"迁锁"):contracts-locked.md 加退役注记转考古;残余真双端(规则文本↔hook 正则)以 fixture+审查守,如实声明 | 第一性重推 1 |
| R6 | 三段 pattern 不整体搬:各审查 skill 自带模板;review-rules 只载维度选择表 | 第一性重推 2 |
| R7 | skip 字段消亡:豁免 = 微型 audit(同 frontmatter 文法,`verdict: exempt` + 一行理由)——走凭证正道,对账天然认,消除"reconcile 不认 skip"的制度洞;豁免成本不变 | 第一性重推 3 |
| R8 | cross-ref hook 不扩边不分发(原定降为工具箱件改名保留)——**后由 R14 取代为删除**(2026-06-13 用户拍板) | 第一性重推 4 → 追记取代 |
| R9 | **地图硬要求**:credentials-rules 发现链五处同批——AGENTS×2(硬规矩行+对账命令,下游补第三条)/ M3(治理表单表化+分流机器拆除+开场规程命令)/ M4(治理表同步)/ QUICKREF+README / 上下文层现行版 spec 状态头注记。**自检标准:任一入口 ≤3 步走到 credentials-rules** | 地图 |
| R10 | 命名收敛:check-meta-review.sh→check-audit-coverage.sh(分发)/ check-meta-cross-ref.sh→check-cross-ref.sh(工具箱;**后由 R14 取代为删除**)/ meta-scope.conf→credentials.conf(新增分发)/ 新 audit 命名 `audit-*.md`(工具 glob 双前缀兼容 meta-review-*.md)/ "meta-review"、"meta-L1~L4" 术语退役(**Evidence Depth 字段名不动**) | 命名收敛 |
| R11 | 下游统一 = A 彻底同层:同文分发/同凭证义务/对账工具分发/meta-* 消亡 | 用户原话 |
| R12 | **不做**:不动承重件(做审分离/二公设、bootstrap 4 维、audit+covers 文法与失效规则、开场对账、晋升门禁、书架登记、handoff 路径);不追溯改写历史(历史 audit/旧 spec/旧 decision = 考古层,双前缀 glob 保兼容);不做细节交接/工作底稿(另案);不做渐进过渡(一步到位) | 不做 |
| R13 | 凭证字段名**全换 `audit: true`**,含 21 份历史凭证同批格式迁移(用户立解释:immutable 保护内容,纯格式迁移不算改;**文件名不换**——被 immutable 文档引用;迁移前后全窗对账对照防掩蔽) | 追记(2026-06-13 spec 审阅轮) |
| R14 | check-meta-cross-ref.sh **删除**(不改名不保留);互引守法归审查触点完整性维;第三 skip 字段随灭;无需任何分发排除机制 | 追记(2026-06-13 spec 审阅轮) |

### 1.4 取代关系(沿 decision)

取代 P0.9.1 的双轨结构(M1/M2/scope 分流/meta-* 体系);其"**治理改动必须被审查留凭证**"的不变量保留。2026-04-17 根源承认决策**不被推翻**(承认的缺口依旧成立,改的是解法结构)。

---

## §2 三件套设计

> 三件各归各业务:**finishing-rules = 收口流程** / **review-rules = 审查维度** / **credentials-rules = 凭证与对账**。互引只用指针(谁干什么时刻的事,去谁家读),不复制正文——三件套互引指针是新增同步面(decision 残余风险 1),守法见 §6。

### §2.1 finishing-rules.md 改造(R1:唯一收口)

#### 2.1.1 删除:顶部「scope 分流入口」段(现 L1-L17)

整段删除(含"harness 自身仓库/下游目标项目"两条引语 + 步骤 1-2)。分流机器消亡:不再有 scope=meta/mixed/feature/none 四标签,不再有"任一命中即 meta"规则。

**删除后开头(逐字草文)**:

```markdown
# Finishing 阶段治理规则

> 当 Superpowers 的 finishing-a-development-branch skill 激活时,读取本文件。
> 以下步骤在 Superpowers 的合并/PR/清理**之前**执行。
> **治理同层**(2026-06-13):本文件是唯一收口流程,不分流不分轨(原 meta-finishing-rules(M1)已并入)。
> 改动命中凭证义务(`.claude/hooks/credentials.conf` glob)时多走一节「凭证义务核对」,其余步骤(含「方向评估」,治理批照走)全员同一条路。

> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入) — 涉及阶段:evaluate / process-audit / security-scan / 治理审查。
```

#### 2.1.2 原 M1 四步的去向(逐步裁决)

| 原 M1 步骤 | 去向 | 理由 |
|---|---|---|
| Step A(scope 判断 + skip 决定) | **消亡**。scope 判定无对象(单层);skip 字段消亡(R7)。残余语义"小修可免重审"由 exempt 微 audit 承接(文法住 credentials-rules §4,豁免边界一并迁去) | 第一性重推 3 |
| Step B(触发 meta-review 流程) | 改造为本文件新节「**凭证义务核对**」(见 2.1.3):命中 conf 的改动按 review-rules 维度选择表「治理」行 fork 审查 → 产 audit(文法住 credentials-rules §3) | 决定·三件套 |
| Step C(decision 立档,D9 范式) | **逐字迁入**本文件「凭证义务核对」节末小节「decision 立档(若有架构决策)」:含 M1 §3 Step C 的范式选择表(普通方案选择型 / **根源承认型 D9 范式**)、D9 应用规则四条、范式参考文件指针、superseding decision 错误处理。D9 范式是承重内容(R12 不动) | 内容无双轨性,本就适用一切架构决策 |
| Step D(ROADMAP/PROGRESS/decision-trail/memory 同步) | **合并去重**:M5「通过」分流 step 2(decision-trail append)与 M1 Step D 同源条目已存在,删 M1 文本中"与 M5 同源"的互指注;M1 Step D 独有增量**两条**并入 M5「通过」清单:①`docs/ROADMAP.md` 状态更新义务(M5「通过」清单现无此条);②`memory/project_harness_overview.md` 结构性变化同步 | 同一动作两处写是双轨病灶本身 |
| Step D 特例(P0.9.1 反审待办字段,C3 字段 2) | **转考古不迁**:反审已完成(audit `docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md` 在案,2026-04-28),字段已是闭环留痕;现行 handoff 模板无此字段。文法留在退役件与 contracts-locked(考古层)可考 | 一次性历史事件,无现行消费者 |
| M1 §4(meta evidence depth,meta-L1~L4 + 三 scope 填法示例) | 档位语义**参数化迁入** credentials-rules §7(证据档位表,治理\|设计\|代码三列);`meta-L` 前缀名退役(R10);mixed 双套并列示例消亡(无 scope 概念,一批多类改动按类各填行,形不变名变) | 决定·三件套 + 命名收敛 |
| M1 §5(handoff 字段引导汇总:skip×2+反审待办) | **消亡**(R7;字段 3 cross-ref skip 同灭,见 §4.2;反审待办随上行 Step D 特例转考古) | 第一性重推 3 |

#### 2.1.3 新增节「凭证义务核对」(逐字草文;插入位置 = 「流程审计」节之后、「根据评估结果分流」之前)

```markdown
## 凭证义务核对(改动命中 credentials.conf 时)

> 凭证制度全文(audit 文法 / exempt 豁免 / 失效规则 / 对账)住 `docs/governance/credentials-rules.md`,本节只给收口时刻的动作序,不重复文法。

15. 对照 `.claude/hooks/credentials.conf`(凭证要求表机器版)核对本批改动:任一文件命中 include glob → 本批负有 audit 凭证义务
16. 凭证义务的履行(二选一,均产凭证文件,无第三条路):
    - **对抗审查 audit**:按 `docs/governance/review-rules.md`「审查维度选择表」治理行 fork N 个挑战者审查本批改动 → 产 `docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md`(文法见 credentials-rules §3;covers 列出本批全部命中文件)
    - **exempt 微 audit**(仅限 typo / 链接 / 注释等无语义变更):按 credentials-rules §4 文法产微 audit(`verdict: exempt` + 一行理由)
17. verdict 处置:`needs-revision` → 按 audit 所列问题修改后重审(可产新 audit);`overturn` → 撤回本批改动,记录到 ROADMAP / handoff,不进分流
18. fork 失败降级:沿「反模式约束」fork-fail-degradation 条款 — 调度者按 review-rules 维度自审,audit 标 `⚠️ 降级执行,独立性未达`

### decision 立档(若有架构决策)

[此处逐字迁入原 M1 §3 Step C 全文:触发条件两条 / 范式选择表 / D9 范式应用规则 / 范式参考文件 / superseding decision 错误处理 — 实施时从退役件复制,本 spec 不重抄]
```

> 编号续接现文件 step 14;实施时以落地文件实际编号为准。

**收口工序适用(decision 追记三,2026-06-13 用户拍板,commit 2ebc7b7)**——治理批收口走哪些工序,随本节落稿:

- **凭证审查**:按凭证要求表(命中 credentials.conf → 本节 step 15-18 动作序)。
- **方向评估(evaluate)= 全批适用,含治理批**(用户原话:"方向评估重要")。分工注记:治理审查核"这批合规达标"(以 decision/spec 为前提),方向评估问"方向本身对不对/该不该推翻"(连前提一起审)——verdict 三路同构但站位不同,非重复。
- **安全扫描与流程审计 = 维持 feature 侧,治理批暂不纳入**(用户原话:"其他的我觉得可以暂时不用担心了")。连带风险(hook 危险操作面/注入面暂无机器扫、exempt 抽查不绑每批)登记见 §10.2-h/i 与 §2.4-4。

#### 2.1.4 文内残余术语清扫

- 「反模式约束」第 4 条内"meta-review D3-F8 / D2-F1 / D2-F3"等**历史 audit 引语不动**(引的是考古凭证名,非活流程);
- step 12 process-audit 产物命名 `audit-YYYY-MM-DD-HHMMSS.md` **不动**(与新审查凭证 `audit-YYYY-MM-DD-HHMMSS-[主题].md` 的命名空间共存分析见 §10-b;机器区分靠 frontmatter,见 credentials-rules §3);
- 「通过」step 2 内"(meta scope 改动同步走 M1 `meta-finishing-rules.md` Step D 的对应项)"括注删除(M1 消亡,本文件即唯一收口);
- 「反模式约束」fork-fail-degradation 条款的适用点枚举(现三处:§安全扫描 第 4 项 / §方向评估 第 9 项 / §流程审计 第 14 项)随新增「凭证义务核对」step(2.1.3 step 18 引用该条款)扩为**四处**,同批改。

### §2.2 review-rules.md 改造(R2:唯一审查)

#### 2.2.1 结构

现 review-rules.md(40 行,code review 细则五节)保留为"代码类维度集细则";顶部新增「审查维度选择表」节 + 头注改写。**三段 pattern 不进本文件**(R6)。

**头注改写(逐字草文)**:

```markdown
# 审查阶段治理规则(唯一审查规则 — 治理同层)

> 一切审查(代码 / 设计 / 治理)的维度选择从本文件「审查维度选择表」出发;各模态的挑战者 prompt 模板由对应 skill 自带(design-review / evaluate / security-scan / process-audit 的 SKILL.md),本文件不载模板全文。
> Superpowers 的 requesting-code-review skill 激活时,读本文件「代码类维度集」各节(在 Superpowers 默认审查维度之上追加)。
> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入)。
```

#### 2.2.2 审查维度选择表(全文草案,逐字)

```markdown
## 审查维度选择表

| 改动类别 | 判定(人读;机器判据 = `.claude/hooks/credentials.conf`) | 维度集 | 力度 / N 弹性 |
|---|---|---|---|
| **代码** | 业务代码 / 测试 / 构建脚本(不命中 credentials.conf) | Superpowers 默认维度 + 本文件「代码类维度集」五节(RUBRIC / 架构合规 / 类型契约 / 简洁性 / 模块文档一致性) | 实现内嵌两段审查(spec 忠实性 + 代码质量);重大改动可加 fork |
| **设计** | `docs/superpowers/specs/` 设计文档 | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐(4 维;模板住 design-review SKILL) | 并行 fork 4 挑战者(design-review skill 定义) |
| **治理** | 命中 credentials.conf include glob(治理规则 / 入口地图 / hooks / skills / agents / RUBRIC / 设计模板 / setup / 分发模板) | **bootstrap 4 维强制基线(禁止删减;禁用需用户确认)**:核心原则合规 / 目的达成度 / 副作用 / scope 漂移。**+ 触点完整性维(条件必选)**:改动涉及机制的产出/消费契约、跨文件计数/枚举、或分发链时必选;孤立单文件 typo 可不选(定制理由段记录) | N 弹性 2-5+(由主题复杂度定,不机械按 skill 数;上限受单 prompt 64 kB 软上限约束,超限拆多轮 fork)。审查产物 = audit 凭证(文法住 credentials-rules §3) |

- 一批含多类改动:按类各取维度集,审查可同批 fork、凭证按 credentials-rules 归账(audit covers 列治理面文件即可)。
- 模态与模板的住址:对抗式模板住 design-review / evaluate SKILL;混合式(凭证扫描 + 对抗判定)住 security-scan SKILL;事实统计式住 process-audit SKILL。本表只定"选哪些维度、多大力度",模板细节去 skill 家读。
- 多 fork 并行约束(逐字迁自 M2 §3.1,适用一切多 fork 审查):必须在单一 assistant turn 内一次性发起 N 个 Agent 调用,不得串行下发(依据 2026-04-28 process-audit P-3 实证:曾致 4 挑战者跨 12 分钟串行)。
- 挑战者错误处理(迁自 M2 §4.4):挑战者空返回 → 重试一次 → 仍败标"未完成",不得静默当通过。
```

#### 2.2.3 bootstrap 4 维与触点完整性维(逐字保留义务)

- **bootstrap 4 维**(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)与"禁用 minimum 项需用户确认"约束,从退役件 M2 §6 B 段**逐字**进入上表治理行(R12 承重件;D7 沿革注一行带上:"沿 D7,4 维不加第 5 维")。
- **触点完整性维**全文(与 D7 撤回维的正交区分留痕 / 实证段 / 怎么查 / 何时优先选)从 M2 §6**逐字迁入** review-rules 作独立小节「### 触点完整性维(治理行条件必选维)」,表内该维以指针引此小节。实证内容(剪枝三批 / 2026-06-05 A/B/E 簇)是防"被当 scope 漂移咬回"的留痕,不可摘。

#### 2.2.4 各 skill 自带模板的引用关系(R6 落位)

| skill | 自带模板(从 M2 §6 对应子节逐字迁入 SKILL.md) | 现状改造点 |
|---|---|---|
| design-review | 对抗式 A/B/C 三段(A 推荐维度 / B 最低必选 = bootstrap 4 维基线 / C 定制理由) | 现 SKILL.md L33-42「scope=meta 时的 §3.1.7 runtime 嵌入引导」段(指 M2/M1 路径)整段替换为内嵌模板 + 一行"维度选择权威 = review-rules 维度选择表" |
| evaluate | 对抗式 A/B/C 三段(同上;evidence depth 档位指针改 credentials-rules §7) | 同上(现 L52-66) |
| security-scan | 混合式(X 硬编码扫描 pattern 引用 + A/B/C 对抗部分) | 同上(现 L32-43) |
| process-audit | 事实统计式(N1 流程遵从度 + G 粒度细化) | 同上(现 L56-68) |

- **B 段维度名的单源**:review-rules 维度选择表是 4 维名 + 禁用约束的权威;SKILL 模板 B 段列维度名并标"权威 = review-rules 维度选择表"(与现状"agent B 段静态列名 + 引 M2"同构,只换权威地址)。
- **防下游污染约束(M2 §5.4)消亡**:A 彻底同层后下游同文分发、同凭证义务,"meta 语境不得进分发件"前提不复存在 — pattern 进 SKILL 随分发到下游正是 R11 的意图。M2 §5 runtime 嵌入契约(调度者 Read M2 再嵌入)随之消亡:模板就在 SKILL 里,skill 激活即在场,无需二跳。8 KB(D.2)/64 kB(D5)软上限语义处置:64 kB 入维度选择表治理行(N 弹性栏);8 KB 嵌入上限随"嵌入"动作消亡而消亡,不再声明。
- agent 文件(design-reviewer / evaluator / security-reviewer / process-auditor / designer)的 M1/M2 指针行改法见 §7 逐件裁决。

### §2.3 credentials-rules.md 完整骨架(R3:新件)

> **逐字×换名通则**(适用本 spec 一切「逐字沿用/逐字迁入」承诺):凡『逐字沿用/迁入』= 规则**语义**逐字;**机械名**按以下映射统一替换:`meta-review: true`→`audit: true` / check-meta-review.sh→check-audit-coverage.sh / meta-scope.conf 与 scope.conf→credentials.conf / M15→check-audit-coverage.sh / "meta 改动·meta scope"→"治理面改动·凭证义务" / M1·M2 指针→新住址(finishing-rules / review-rules / credentials-rules 对应节)。此为 R13『格式≠内容』的延伸:语义=内容,机械名=格式。保真核见 §8.3 V9。

- **路径**:`docs/governance/credentials-rules.md`(无前缀,setup.sh governance 循环自然分发 — R11)
- **定位**:凭证与对账的**单入口**——谁欠凭证(§2)、凭证长什么样(§3/§4)、何时失效(§5)、怎么对账(§6)、证据档位怎么填(§7)。
- **节级目录 + 每节一段说明**(实施时按此骨架成文;标注「逐字沿」处从退役件原文复制):

**§1 定位与读法** — 一段话定位(本文件 = 凭证制度单入口;治理同层 decision 指针);三个进入时刻:finishing「凭证义务核对」节跳来(收口)/ 开场对账欠账时跳来(补账)/ 写 audit 前跳来(查文法)。与 finishing-rules / review-rules 的分工一句话:收口动作序住 finishing,维度选择住 review,凭证文法与对账住本件。

**§2 凭证要求表(人读版)** — 与 credentials.conf(机器版)**双写同步**(改一处必同改另一处;审查时 grep 比对——双写面从原 M3 三表 ↔ M17 收敛为本表 ↔ conf 一对)。表列:文件类别 | glob | 凭证类型。当前全部行凭证类型 = audit;`design-review` / `test` 类型为参数位预留(§3 conf 设计同此),工具现阶段只消费 audit 行。人读表正文即本 spec §3(conf 草案)的逐行对照转写,含排除规则(流程产出物防自循环)与「不命中任何 glob = 无凭证义务」兜底句。原 M3 §5「scope 内对照表」的实存文件注记(如 settings.json 已撤、templates/handoff.md 已删的考古注)精简后并入本表附注;附注承接清单点名:「全新建未 git add 的根级文件走 untracked 漏检」活缺口注记(原住 M3 §5 A 组注,随 §5 删除迁居本表附注;缺口本体详 `docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md` §9.4 #11)。

**§3 audit 产物规范** — 逐字沿 C2/M2 §7 为底,改名收敛:
- 位置:`docs/audits/`;命名:**`audit-YYYY-MM-DD-HHMMSS-[主题].md`**(新);**双前缀兼容**:工具收集 glob = `audit-*.md` + `meta-review-*.md`(历史 21 份 meta-review-*.md 零改继续有效 — R12 不追溯);半年归档策略沿 D15(`docs/audits/archive/YYYY-HN/` + INDEX.md)。
- 与 process-audit 产物(`audit-YYYY-MM-DD-HHMMSS.md`,无主题段、无 frontmatter)的命名空间共存:**机器区分靠 frontmatter,不靠文件名**——审查凭证必有 `audit: true` + 非空 `covers`;process-audit 报告无 frontmatter,被 `is_audit_credential` 自然滤除(已对实物 `audit-2026-04-28-133251.md` 验证无 frontmatter)。本节写明此规则。
- **frontmatter 文法**:**`audit: true`** + `covers:` 字符串数组(R13,2026-06-13 用户拍板"换,并且全换"——字段名全换,含 21 份历史凭证同批格式迁移:仅 frontmatter 一行替换,covers 与正文零碰,git 史保原貌;依据 = 用户立的解释「immutable 保护内容,纯格式迁移不算改」,decision 追记)。工具**单一解析路径**(无双字段兼容)。**文件名不换**(历史 meta-review-*.md 留名,收集 glob 双前缀)——文件名被 decisions/ROADMAP/trail/归档台账大量引用,改名即迫改 immutable 内容,恰违"不改内容"。**迁移防护**:迁移前后各跑一次全窗对账(`--reconcile 99999`)留对照,欠账集合不得缩小(迁移刷新凭证 commit time,防掩蔽 stale 覆盖)——详 §4.1-10。
- covers 路径规则逐字沿 M2 §7.3 五条(仓库相对 / 正斜杠 / 实存 / 无去重要求 / **`<root>/` sentinel 协议全文**)。
- 5 段正文标题逐字沿(`## 1. 元信息` ~ `## 5. 判定`);**任务级结论登记簿**(M2 §7.5.1,2026-06-12 加)逐字迁入:子代理驱动批的批级 audit 在「## 3. 挑战者执行记录」逐任务一行结论,行文法逐字沿(`任务 <N>(<主题>):verdict=...;关键发现 ...;修复 commit ...`,多 commit 用 + 连写)。
- 写侧契约逐字沿 M2 §7.4(实际覆盖文件,不是主题相关;不漏列不误列)。
- 读侧错误处理表逐字沿 M2 §7.6(YAML 损坏 / covers 缺失 / 空数组 / 标识缺失四情形)。

**§4 exempt 微 audit(豁免文法 — 本 spec 唯一新设计点)** — 全文见本 spec §2.4。

**§5 audit 失效规则** — 逐字沿 M2 §8 四小节:单 audit 单文件失效判定(covered 最新 commit time vs audit mtime)/ 多 audit 跨覆盖并集 / 实现细节(GNU/BSD stat 兼容、不用 ctime)/ 归档 audit 处理。对账模式的差异锚(audit 自身最后 commit time;同 commit 打包 ≤ 判有效)沿 check-meta-review.sh §4.6 现状声明于本节末。

**§6 开场对账规程** — 三条命令(自仓库形态,下游去 `harness/` 前缀同形):
1. `bash .claude/hooks/check-handoff.sh --reconcile`(台账凭证)
2. `echo '{}' | bash .claude/hooks/check-shelf-registry.sh`(落库登记)
3. `bash .claude/hooks/check-audit-coverage.sh --reconcile`(凭证覆盖——本件主角;**A 彻底同层后下游同跑三条**)

欠账处置:缺 audit → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)补 exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账。欠账先补再开新工作。本节与根 CLAUDE.md「会话开场规程」/AGENTS×2 对账行互为指针(权威动作序住本节,入口行只一句引)。

**§7 证据档位参数化表(治理|设计|代码)** — 统一 L1-L4 名(`meta-L` 前缀退役,R10),按改动类别给解释列:

```markdown
| 档位 | 代码改动 | 设计改动 | 治理改动 |
|---|---|---|---|
| L1 | 单元测试通过 | 设计文档节内自检 [x] 全勾选 | 节内自检 / hook fixture 先红后绿 |
| L2 | 集成测试输出 | 全局自检(design-rules 10 项) | 全局一致性核(双写比对 / 装机验证) |
| L3 | 自动化验证脚本 | design-review 4 维审查通过 | 对抗审查 audit verdict=pass(凭证在 docs/audits/) |
| L4 | 真实场景验证记录 | 落地后实战回看 | 实战留痕(后续改动的 audit / 对账引用本规则) |
```

handoff `## Evidence Depth` / `## CI 阻断` **字段名与格式不动**(check-evidence-depth.sh 零改,R12):每行 `- L<n>: <状态> <证据位置>` 三段,状态 ✅/⏳/❌/➖;一批含多类改动按类各填行(原 mixed 双套并列的形保留、`meta-` 名退役)。**证据位置必须含具体路径或 audit 文件名,不能用"已完成"类无指向词**(逐字沿 M1 §4.3 第 5 条)。原 M1 §4.2 三示例改写为"代码批 / 治理批 / 混合批"三示例(实施时成文)。

**§8 双写同步义务清单** — 本件 §2 ↔ credentials.conf;review-rules 维度表治理行判定语 ↔ conf;根 CLAUDE.md 治理表凭证行 ↔ 本件存在性;对抗式模板 design-review SKILL ↔ evaluate SKILL(A/B/C 三段同构,同批改);对账命令拷贝组**四处同改**(根 CLAUDE.md 开场规程 / 根 AGENTS.md「手工校验」/ templates/AGENTS.md「手工校验」/ 本件 §6)。另:根 CLAUDE.md 治理表「凭证义务一句话」**不复制类目枚举**(只写"命中 credentials.conf 任一 include glob"+ 本件指针,防散文拷贝失同步——§5.2 草文已按此成文)。逐对列出 + "改一处同批改另一处" + 审查触点完整性维优先选用声明。

### §2.4 exempt 微 audit 文法(新设计,逐字模板)

**逐字模板**:

```markdown
---
audit: true
verdict: exempt
covers:
  - <仓库相对路径 1>
---

# audit(exempt):<一句话主题>

豁免理由:<一行,非空——为何无需对抗审查(仅限 typo / 链接 / 注释等无语义变更)>
```

**文法规则**:

1. 文件名同正式 audit:`audit-YYYY-MM-DD-HHMMSS-[主题].md`,位置 `docs/audits/`。
2. frontmatter 三键:`audit: true`(§2.3 文法,凭证标识)/ **`verdict: exempt`**(新键,固定小写字面)/ `covers:`(非空数组,路径规则同正式 audit 含 `<root>/` sentinel)。**键序固定如模板**(verdict 在 covers 之前)——非解析必需(见下兼容分析),但消除一切顺序歧义、便于人眼一行定位。
3. 正文两行起步:标题行 + 豁免理由行(非空非全空白)。无 5 段结构义务(微 audit 之"微")。
4. 豁免边界(从原 M1 Step A 迁语义):仅 typo / 链接修复 / 注释措辞等**无语义变更**;语义变更一律走对抗审查。**例外两类**(同走 exempt,理由行写明类别):①**D11 偏好条目用户原话直录**——忠实性由逐字引录自保证(D11 既有拍板,该类审查口径本就是忠实性对照);②**初装/升级 scaffold**——内容 = 上游分发原样,上游已审(下游首跑对账面对约 30 件欠账墙的制度出口)。exempt 理由质量由 process-audit **按需/周期回看**反向抽查(不绑每批——decision 追记三:流程审计治理批暂不纳入;沿 D22 fix-9 (iv) 对 skip reason 的同构安排);**covers 超 5 件的 exempt 必抽**。
5. 失效规则与正式 audit 完全一致(credentials-rules §5):covered 文件在 exempt 之后有新 commit → exempt 失效,需重新豁免或补审。**豁免不是永久免检**。
6. 成本对照(decision 论证保真):3-5 行文件 ≈ 一行 skip 字段,但走凭证正道——`--reconcile` 对账天然认(skip 字段对账从来不认,这正是被消除的制度洞)。

**与现解析器的兼容分析**(对 check-meta-review.sh 实物逐函数核过):

| 解析器 | 现行为 | exempt 微 audit 下 |
|---|---|---|
| `is_audit_credential`(原 is_meta_review_audit 改名;awk:frontmatter 内匹配 `audit: true` 行——迁移后单一文法,R13) | 命中即认 | 模板含该行 → 认 |
| `extract_covers`(awk:`covers:` 起,数组项逐行,**遇到下一个 `key:` 行终结**——终结正则 `^[[:space:]]*[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:`) | 输出 covers 数组 | `verdict:` 行匹配终结正则:放 covers 前(模板键序)对扫描零影响;即便放 covers 后也正确终结数组 → **两序皆兼容,零改** |
| `verdict` 解析 | **无**(现工具不读 verdict;任何有 covers 的有效 audit 都贡献覆盖) | 新增 `extract_verdict`(本 spec §4.1):用于对账输出展示("其中 exempt N 份")与窗口锚竞选排除(§4.1-11),**覆盖判定不依赖 verdict**——exempt 与 pass 同算有效覆盖,语义与现行为连续 |

> 既有正式 audit 正文内的 verdict 写法(如「## 5. 判定」节内 `verdict=pass`)在 frontmatter 无 `verdict:` 键 → `extract_verdict` 返回空 → 按正式 audit 计,无歧义。

---

## §3 credentials.conf 设计(R4:机器版凭证要求表)

### 3.1 身份与格式

- **路径**:`.claude/hooks/credentials.conf`(由 `meta-scope.conf` git mv 改名;住址不迁,沿 B 组单一住址惯例)。
- **降格语义**:从"scope 分流判据"(决定走哪条 finishing 轨)降为"凭证要求表"(只回答:这个文件的改动欠什么凭证)。不再有"scope=meta"概念,只有"命中 → 凭证类型"映射。
- **行格式**(沿现 conf 行格式 + 注释风格,新增类型字段):
  - 注释行 `# ...` / 空行:不参与解析(同现状)
  - include 行:`<glob><空白><凭证类型>`(单空格分隔;glob 不含空白,现集合已验证)
  - exclude 行:`!<glob>`(无类型字段,同现状;**误带类型字段 = 整串按 glob 字面解析,不匹配任何路径 → 该排除失效**,属 fail-closed 噪声而非漏放——V1 fixture 含此例)
  - 凭证类型枚举:`audit` | `design-review` | `test` —— **参数位**;当前全部行 = audit,后两类为下游/未来扩展预留(例:下游可加 `src/payments/** test` 行表"支付模块改动须测试凭证")。check-audit-coverage.sh 只消费 `audit` 行;`design-review` / `test`(已知预留类型)跳过;**未知类型 fail-closed**:warning + 按 audit 处理(与缺类型同路径,见 §4.1-2)。
- **编码**:UTF-8 + LF,无 BOM(沿 C1 不变量 6;awk/grep 解析前提)。

### 3.2 完整文件草案(逐字)

```
# credentials.conf - 凭证要求表(机器版)
# 行格式:<glob> <凭证类型>;! 前缀为排除(排除行无类型字段)
# 凭证类型:audit(对抗审查凭证)| design-review | test(参数位预留,当前工具只消费 audit)
# 由 check-audit-coverage.sh 读;人读版 = docs/governance/credentials-rules.md §2(双写同步,改一处同改另一处)
# 文件编码: UTF-8;行尾: LF
# 沿革:原 meta-scope.conf(M17)改名降格 — 治理同层化(decisions/2026-06-13-governance-single-layer.md)

# === 治理规则 + 核心入口 ===
docs/governance/*.md audit
CLAUDE.md audit
# 入口地图 = 治理面,与 CLAUDE.md 对称;根级文件经 root 扫描段命中,audit covers 写 <root>/AGENTS.md
AGENTS.md audit
# 偏好层:治理上当规范同等对待(D11 ✅ A;审查口径 = 忠实性对照用户原话锚点)
docs/preferences.md audit

# === hooks + settings ===
# glob 用 * 统一覆盖 .sh / .conf / 未来 hook 配置类型,也使本文件自身入凭证义务
.claude/hooks/* audit
.claude/settings.json audit
.claude/settings.local.json audit

# === skills + agents ===
# skill 捆绑资源 = 契约本体(D15):glob */*.md 覆盖 SKILL.md + 捆绑模板(如 structured-handoff/handoff-template.md)
.claude/skills/*/*.md audit
.claude/agents/*.md audit

# === RUBRIC + 设计模板 ===
docs/RUBRIC.md audit
docs/references/DESIGN_TEMPLATE.md audit

# === setup + 分发模板 ===
# 下游单层仓库无 setup.sh / templates/,以下行不命中即无义务(同一份 conf 双层通用)
setup.sh audit
templates/*.json audit
templates/*.md audit

# === 排除规则(流程产出物,避免自循环)===
# 审查凭证自身不欠凭证;双前缀(audit-* 新名 / meta-review-* 历史名)+ 归档全排除
!docs/audits/audit-*.md
!docs/audits/meta-review-*.md
!docs/audits/archive/**
```

### 3.3 与现 meta-scope.conf 的逐组对照

| 现组 | 处置 |
|---|---|
| A 组(governance/CLAUDE/AGENTS/preferences) | 全保留,加 ` audit` 类型字段;组名退役(A-G 字母组概念随 M3 三表拆除消亡,conf 注释改用业务名) |
| B 组(.claude/hooks/* + settings ×2) | 全保留 + 类型字段;"glob 扩 * 解决 line 406"注释精简保留(它解释为何不是 *.sh) |
| C 组(skills/agents) | 全保留 + 类型字段;D15 注释保留 |
| D 组(RUBRIC/DESIGN_TEMPLATE) | 全保留 + 类型字段 |
| F 组(setup.sh/templates) | 全保留 + 类型字段;"M4 经 A 组 CLAUDE.md glob 覆盖"的视角注释删除(组概念消亡,glob 本身已自明);新增"下游不命中无义务"注 |
| 排除规则 | `!docs/audits/meta-review-*.md` 保留 + **新增** `!docs/audits/audit-*.md`(新命名的审查凭证与 process-audit 报告同前缀,一并排除——防御性:docs/audits/ 本不命中任何 include glob,排除行为双保险,沿现 conf"必须排除流程产出物"不变量) |
| E+G 组注释("不命中即 scope 外") | 改写为兜底句"不命中任何 include glob = 无凭证义务",并入人读版 §2 |

### 3.4 消费者

唯一消费者 = `check-audit-coverage.sh`(解析改动见 §4.1)。原"M15 和 M16 读"注释中 M16(pre-commit 孪生)已于 2026-06-04 剪枝,头注按实情只写一个消费者。`check-context-chain.sh` / `check-shelf-registry.sh` 注释中对 meta-scope.conf 的**提及**(非读取)按 §7 裁决改字。

---

## §4 工具改造

### §4.1 check-meta-review.sh → check-audit-coverage.sh(改名 + 改造,继续分发链内?见 4.1.7)

**改名**:`git mv .claude/hooks/check-meta-review.sh .claude/hooks/check-audit-coverage.sh`(保 git 史)。改名后无 `meta-`/`check-meta-` 前缀。

**逐点改造**(对实物 725 行脚本逐段核对后列出;未列段 = 零改):

1. **头注重写**:身份改"凭证覆盖核对(audit coverage)——双模式:Stop 执法(增强层,当前无任何仓库接线)+ `--reconcile` 开场对账(工具箱,主用形态)";术语全换(meta-review → 审查凭证 / meta scope → 凭证义务);命名约定段(D12 前缀过滤)删除,改写"无前缀,随 setup.sh hooks 循环分发下游(A 彻底同层)";spec 锚点行改指本 spec + decision。
2. **conf 读取**(§3 段):`SCOPE_CONF=".claude/hooks/credentials.conf"`;解析循环改两字段行格式——非排除行按第一个空白切 `glob` + `type`:`type=audit` → 入 INCLUDE_GLOBS;`type` ∈ {design-review, test} → 跳过(本工具不消费);`type` 为空(单字段行)→ stderr 一行 warning(`⚠️ credentials.conf 行缺凭证类型字段,按 audit 处理: <行>`)+ 按 audit 处理(graceful,防手误丢执法);`type` 为其他未知值 → **warning + 按 audit 处理(fail-closed,与缺类型同路径)**——类型 typo 与漏写同属手误,不应得到相反处置。排除行 `!` 解析不变。"无任何 include glob 视为损坏降级"逻辑不变,提示文案改名。
3. **audit 收集双前缀**(`collect_audit_files` + 窗口锚竞选两处 find):`-name "audit-*.md" -o -name "meta-review-*.md"`;archive INDEX.md 表格行过滤的 `case` 同步加 `audit-*.md` 分支。**process-audit 报告防误收**:`audit-YYYY-MM-DD-HHMMSS.md` 会被 find 捞起,但无 frontmatter → `is_audit_credential` 滤除(实物已验证);窗口锚竞选处同样过 `is_audit_credential` 再参选(**现脚本竞选段不过滤,需补此一行**——否则 process-audit 报告的 commit time 可能错当窗口锚,这是改造中必须修的真缺口,非锦上添花)。
4. **frontmatter 解析**:`extract_covers` **零改**;`is_meta_review_audit` **改名 `is_audit_credential` 且匹配行换 `audit: true`**(R13 迁移后单一文法,无双字段兼容);新增 `extract_verdict`(awk,frontmatter 内匹配 `^[[:space:]]*verdict[[:space:]]*:[[:space:]]*exempt[[:space:]]*$` → 输出 exempt,否则空)。
5. **覆盖判定零改**:exempt 与正式 audit 同算有效覆盖(verdict 不参与判定);失效规则两套锚(Stop=mtime / reconcile=commit time)零改。
6. **对账输出**:`VALID_AUDIT_COUNT` 旁新增 `EXEMPT_COUNT`;账齐/欠账行改为 `账齐:近窗 N 件凭证义务改动,有效凭证 M 份(其中 exempt K 份)` 同形;标题行 `—— meta-review 对账(--reconcile)——` → `—— 凭证覆盖对账(--reconcile)——`。
7. **skip 字段解析路径删除**(R7):脚本 §8 整段(读 handoff `## meta-review: skipped`)删除;§4.6 头注三差异点中"忽略 skip"句改为"skip 字段制度已消亡(豁免走 exempt 微 audit,对账天然认)";对账欠账输出末行"注:对账不认 skip 字段"删除,处理指引改:
   - `处理:对上述文件补审查凭证(二选一),文法住 docs/governance/credentials-rules.md:`
   - `  1. 对抗审查 audit:docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md(frontmatter audit: true + covers 逐项列出;root 级文件写 <root>/<path>)`
   - `  2. exempt 微 audit(仅 typo/链接/注释等无语义变更):同 frontmatter + verdict: exempt + 一行理由(credentials-rules §4)`
8. **Stop 模式 stderr 引导**(脚本 §9):"触发 /design-review meta-mode" 改"按 review-rules 维度选择表治理行 fork 审查";"写 skip 理由"选项删除,替换为 exempt 微 audit 选项;`<root>/` sentinel 协议段保留(文法不动);"不扫 untracked"已知注保留。
9. **双层探测段零改**(WORK_DIR 探测/root 扫描段/`<root>/` sentinel/`git -C` 健康检查);gawk 三参数 match 已知问题注保留(独立待办,本批不修不扩散——沿原头注纪律)。
10. **历史凭证字段迁移(R13,与本件改造同批)**:21 件 `meta-review-*.md` 的 frontmatter 行 `meta-review: true` 替换为 `audit: true`(**锚定 sed**:`s/^meta-review: true$/audit: true/`,逐件断言替换数 = 1——演练已证 21 件该行均恰 1 处、位于 L2,正文无同字面;**幂等可重跑**;covers 与正文零碰;git 史保原貌)。验证断言:①`grep -rl '^audit: true' docs/audits/meta-review-*.md | wc -l` = 21;②`grep -rl 'meta-review: true' docs/audits/` = 0;③**迁移防护对照(可执行协议,V2/V7 同此)**:
    - **基线定义(写死)**:迁移基线 = **批 1 动任何东西之前**,用旧工具 `check-meta-review.sh --reconcile 99999` 全窗跑一次留痕(批 1 第一动作,§9)。
    - **对照**:本件迁移完成后,新工具 `check-audit-coverage.sh --reconcile 99999` 再跑全窗,与基线 diff 欠账名单。
    - **判据**:欠账**缩小必然发生**——迁移刷新全部凭证 commit time,把"曾被 covers、后因新提交失效"的既存欠账洗活(演练实证:25→18 缩 7 件)。处置:缩小集合**逐件列出逐件归因**,确认均属"迁移时刻已失效的既存欠账"→ 转入手工欠账留痕(plan/handoff 登记),由批 5 V8 audit covers 或补审吸收;出现**无法归因**的缩小 = **abort 停批查因**。
    - **防对照盲区**:基线后、迁移前的一切治理面提交在 plan 显式登记(它们的新增欠账属预期 delta;V8 covers 的机械汇编义务见 §9 批 5)。
11. **窗口锚竞选排除 exempt(对账锚加固)**:锚竞选循环对候选凭证过 `extract_verdict`,verdict=exempt 跳过不参选(一行;函数已由第 4 点新增)。理由:exempt 高频窄豁免会把默认窗锚拉到当下,遮蔽窗外"忘补凭证"的改动(实验实证:一次合法豁免即可遮蔽);正式 audit 才有资格定默认窗。覆盖判定不受影响(exempt 仍算有效覆盖,第 5 点)。

#### 4.1.7 分发与接线裁决

- **分发**:✅ 随 setup.sh hooks 循环自然分发(改名后无前缀;R11"对账工具分发"明令)。conf 同批显式分发(§4.3)。
- **下游 settings(templates/settings.json)Stop 数组**:**不加 check-audit-coverage.sh,模板零改**。裁决理由(按 C 案哲学,2026-06-11 decision):①对账是**开场手工命令**(下一会话当验收者),不是 Stop 执法——把它接进 Stop 等于重走"常驻守门人"路线,与 C 案"会话链自执法"相反;②Stop 模式扫的是未提交 diff,凭证义务的真闸在"已提交历史对账"(reconcile),Stop 接线收益重复;③不烧桥:脚本双模式保留,下游用户若自愿接线,加一行 settings 即可(文件已在场)。AGENTS.md(下游版)第三条对账命令承担发现链(§5)。
- **自仓库**:无 settings(追记①已撤),不存在接线问题;开场对账命令行三处同改(§5/§9 批序耦合)。

### §4.2 check-meta-cross-ref.sh:删除(R14,2026-06-13 用户拍板)

- **处置**:`git rm .claude/hooks/check-meta-cross-ref.sh`——不改名、不保留(原话:"删除");git 史即考古,需要时可捞回。
- **依据**(第一性):机器值得存在 = 形式可判 × 高频/高损;互引断链低频、审查「触点完整性维」全覆盖此病——本件是防线一(审查)的自动化小子集(6 条 grep),冗余度高、覆盖面窄、喊了无人强制听(不接线)。
- **连锁**:`## meta-cross-ref: skipped` 字段彻底消亡(唯一消费者即本件;M1 §5.3 文法随 M1 退役同灭);setup.sh **无需任何点名排除**(§4.3 同步简化);原"PAIRS 扩三角边"方案作废——三件套互引守法全归审查触点完整性维 + 同批耦合纪律(§6.2 行 6)。
- **消费点**:check-meta-cross-ref 命中 24 件——活引用(M1/M2/setup.sh/templates/README/agents 指针行)随各自改动消亡或改写(§7.1 对应件),考古层不动。

<!-- 以下为被 R14 取代的原 §4.2 方案(改名保留+PAIRS 扩边),留痕不执行:
- **PAIRS 按文本合并后实情更新**:现 6 条 anchor 全在 design-rules.md / finishing-rules.md,逐条核:
  | 现 PAIRS 条目 | 合并后状态 |
  |---|---|
  | design-rules.md「## spec §0 偏离规则」 | 不动(design-rules 本批零改) |
  | design-rules.md「另见 \`finishing-rules.md\`」 | 不动 |
  | finishing-rules.md「跨阶段同步约束」 | 保留——所在「反模式约束」节不删(2.1.1 只删顶部分流段) |
  | finishing-rules.md「见 \`design-rules.md\`」 | 保留(同上) |
  | finishing-rules.md「## 反模式约束」 | 保留 |
  | design-rules.md「**轻量级**」 | 不动 |
  **新增对**(三件套互引指针,decision 残余风险 1 的"手工 cross-ref 工具守"落点):
  | 新 PAIRS 条目 | 守什么 |
  |---|---|
  | `docs/governance/finishing-rules.md\|credentials-rules.md` | 凭证义务核对节 → credentials-rules 指针 |
  | `docs/governance/finishing-rules.md\|## 凭证义务核对` | 节锚本体在场 |
  | `docs/governance/review-rules.md\|## 审查维度选择表` | 维度表节锚在场 |
  | `docs/governance/review-rules.md\|credentials-rules.md` | 治理行 → credentials-rules 指针 |
  | `docs/governance/credentials-rules.md\|review-rules.md` | 对账欠账处置 → review-rules 指针 |
  | `docs/governance/credentials-rules.md\|finishing-rules.md` | 定位节 → finishing 指针 |
  触发判定 `case`(脚本 §3)加 `*docs/governance/credentials-rules.md*` 分支。
- **skip 兜底段删除**(R7 全线):脚本 §5(读 `## meta-cross-ref: skipped`)删除;stderr 处理方式三选一改二选一(补 anchor / 同步改 PAIRS),"字段名注意"整段删除(字段制度消亡)。exit 2 语义保留(手工跑时的信号值;无接线消费者,不构成执法)。
- 头注 anchor 行号注释(L24-27)按 PAIRS 新表重写;"命名约定 D12"段删除。
原 §4.2 留痕结束 -->

### §4.3 setup.sh 改造

1. **hooks 循环**:删除 `meta-*) continue` / `check-meta-*) continue` 两分支(D12 前缀过滤机制退役);**无任何点名排除**(check-meta-cross-ref.sh 已删,R14)。净效果:check-audit-coverage.sh 开始分发,hooks 目录所有 .sh 全量分发。
2. **credentials.conf 入分发**:hooks 循环只拷 `*.sh`,conf 需显式行——在 `cp templates/settings.json` 行前加:
   ```bash
   # 凭证要求表(机器版;与 docs/governance/credentials-rules.md 人读版双写同步)
   cp "$SCRIPT_DIR/.claude/hooks/credentials.conf" "$TARGET_DIR/.claude/hooks/"
   ```
3. **governance 循环**:删除 `meta-*) continue` 分支 → 循环退化为无条件拷贝(保留循环形或改直拷,实施层自决;退役的 meta-finishing/meta-review 两件已物理删除,无需过滤)。credentials-rules.md 作为 `docs/governance/*.md` 一员**自然拷入**,无需新行。
4. **注释清理**:hooks 段注释("命名前缀过滤(D12)…")与 settings 行注释("下游零 meta hook 注册痕迹")改写为同层化口径(§7 裁决件 9)。

### §4.4 settings 模板与无关 hook(零改清单)

- `templates/settings.json`:**零改**(4.1.7 裁决;Stop 数组按现状维持实有四件——check-handoff / check-shelf-registry / check-evidence-depth / check-context-chain;本 spec 不增删任何注册行)。
- `check-evidence-depth.sh` / `check-context-chain.sh` / `check-module-docs.sh` / `session-init.sh`:**功能零改**(§8 不变量 3;check-context-chain.sh / check-shelf-registry.sh / check-handoff.sh 仅注释行换名,见 §7 件 13-15,逻辑零碰)。
- `templates/README.md`:三处注释行改写(§7 件 8)。

---

## §5 地图(R9 硬要求:五处发现链,逐字插入/改写文本)

> 自检标准:**任一入口 ≤3 步走到 credentials-rules**(走查表见 5.6)。五处同批改(与三件套/工具改名同 plan,不许跨批漂)。

### 5.1 AGENTS.md ×2(共享核同批改义务沿 spec 2026-06-12 §5)

**根 AGENTS.md**(自仓库)三处:

① 接手顺序步 4 下的两行(现 L16-17)整体改写为:

```markdown
- 凭证义务(治理面改动须 audit 凭证): 权威单入口 harness/docs/governance/credentials-rules.md(机器版 harness/.claude/hooks/credentials.conf)
- 开场对账(步 1 读完台账后):跑下方「手工校验」三命令;欠账先补再干活(会话链自执法,详 harness/docs/decisions/2026-06-11-session-chain-reconciliation.md + 2026-06-13-governance-single-layer.md)
```

② 「手工校验」节(现 L41-42 两命令)扩为三命令:

```markdown
- bash harness/.claude/hooks/check-handoff.sh --reconcile
- echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh
- bash harness/.claude/hooks/check-audit-coverage.sh --reconcile
```

③ 硬规矩节追加一行(与既有三行同形:一行引用 + 权威住址):

```markdown
- 治理面改动留凭证: 命中 credentials.conf 的改动收口前必有 audit(或 exempt 微 audit) → 全文住 harness/docs/governance/credentials-rules.md
```

**templates/AGENTS.md**(下游)两处(R9"下游补第三条"):

① 「手工校验」节(现 L39-40)扩为三命令:

```markdown
- bash .claude/hooks/check-handoff.sh --reconcile
- echo '{}' | bash .claude/hooks/check-shelf-registry.sh
- bash .claude/hooks/check-audit-coverage.sh --reconcile
```

② 硬规矩节追加一行(下游单层路径):

```markdown
- 治理面改动留凭证: 命中 credentials.conf 的改动收口前必有 audit(或 exempt 微 audit) → 全文住 docs/governance/credentials-rules.md
```

(开场对账行 L15"跑下方「手工校验」两命令"改"三命令"。九格表零改——格 6 干活规矩 `docs/governance/` 已含新件。)

### 5.2 根 CLAUDE.md(M3):治理表单表化 + 分流机器拆除 + 开场规程命令

**删除**:§3「scope 触发判定」表 / §4「meta vs feature 分流引导」/ §5「scope 内对照表」三节整体删除(分流机器拆除;§5 实存文件注记精简并入 credentials-rules §2 附注——§2.3)。§1 角色表「meta-review(harness 自治理)」行改为「治理审查 | 调度者按 review-rules 维度选择表 fork N 挑战者 | 治理面改动审查(凭证义务详 credentials-rules)」;二公设/反向规则/角色分离正文零改(R12 承重件)。

**§2 治理规则表替换为单表(逐字草文)**:

```markdown
## 2. 治理规则表(单层 — 治理同层化 2026-06-13)

| 阶段 | 治理文件 |
|------|----------|
| brainstorming | `harness/docs/governance/brainstorming-rules.md` |
| system-design | `harness/docs/governance/design-rules.md` |
| writing-plans | `harness/docs/governance/planning-rules.md` |
| implementation + testing | `harness/docs/governance/implementation-rules.md` + `testing-rules.md` |
| 审查(代码/设计/治理) | `harness/docs/governance/review-rules.md`(维度选择表) |
| finishing(唯一收口) | `harness/docs/governance/finishing-rules.md` |
| **凭证与对账(跨阶段)** | **`harness/docs/governance/credentials-rules.md`(单入口)+ `harness/.claude/hooks/credentials.conf`(机器版,双写同步)** |
| 跨阶段综合 | `harness/docs/governance/synthesis-rules.md`(fork 多挑战者前后必读) |
| 模型路由(跨阶段) | `harness/docs/governance/model-route.md`([2026-05-24] P2 codex 接入搁置,当前全 Claude) |

> 凭证义务一句话:改动命中 credentials.conf 任一 include glob → 收口前必有 audit 凭证(对抗审查 audit 或 exempt 微 audit);类目与 glob 详 credentials-rules.md §2,制度全文住 credentials-rules.md,本文件不重复(防散文拷贝,§2.3-§8)。
```

**会话开场规程**对账第 3 条改为(欠账处置句同步):

```markdown
   - `bash harness/.claude/hooks/check-audit-coverage.sh --reconcile`(已提交凭证义务改动的 audit 覆盖)
   - 欠账处置:缺凭证 → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账
```

(「M3↔M17 双写约束」声明随 §3 表删除而消亡,双写面移交 credentials-rules §8;「活上下文链 dogfood 边界」「上下文层地图行」「仓库结构」节零改——其中"meta-review「触点完整性」维"一处提法改"治理审查「触点完整性」维(review-rules)"。)

### 5.3 harness/CLAUDE.md(M4):治理表同步

文档索引/治理规则表加同款两行(下游路径,无 harness/ 前缀):「审查(代码/设计/治理)| docs/governance/review-rules.md(维度选择表)」行替换现 requesting-code-review 行;新增「**凭证与对账(跨阶段)** | **docs/governance/credentials-rules.md + .claude/hooks/credentials.conf**」行。角色表下 D13 注(「本表是分发到下游的角色清单…还含 meta-review 角色行…不分发下游」)整段删除,替换一行:「> 注:治理同层(2026-06-13)——上下游同一套治理与凭证义务,无另册。」核心规则 11(开场对账)零改(命令住 AGENTS.md)。

### 5.4 QUICKREF.md + README.md(双份:根 + harness/)

**QUICKREF**:治理规则表加一行 `| **凭证与对账(跨阶段)** | **docs/governance/credentials-rules.md** |`;Hook 表加一行 `| check-audit-coverage | 凭证覆盖对账(--reconcile 开场用;治理面改动的 audit 凭证核) |`;关键文件表加一行 `| docs/audits/ | 审查凭证(audit-*;频次低但生死攸关) |`。

**README ×2(根 README.md 与 harness/README.md 两份独立维护,以下三处改法对两份各自适用)**:

- 原则 3.1 行:`security-scan` / `meta-review` → `security-scan` / 治理审查(同层,见 credentials-rules)
- 原则 4.3 行(逐字):`- **4.3 改动范围自动识别** — 治理面改动按凭证要求表机械负担 audit 凭证义务,开场对账核账。**Why**:不靠 AI 自觉,机械判据不可被自我说服绕过。**实现**:docs/governance/credentials-rules.md + .claude/hooks/credentials.conf + check-audit-coverage.sh --reconcile`
- 模型路由「不 Swap」行:`meta-review` → `治理审查`

### 5.5 上下文层现行版 spec 状态头注记(交界处置)

`docs/superpowers/specs/2026-06-12-context-layer-design.md` 为 immutable 单件,正文不追改;状态头追加一行注记(与"微修正 ×1"行同位同形,逐字):

```markdown
> 受波及注记(2026-06-13,治理同层化):§5「scope 治理触点」、§6 对账命令 3 与欠账处置句、§7 工具箱成员行中的 meta-review / check-meta-review / check-meta-cross-ref / meta-scope.conf 表述,自治理同层化落地起以 `2026-06-13-governance-single-layer-design.md` 为准(对应物:治理审查凭证 / check-audit-coverage.sh / check-meta-cross-ref 已删除(互引守法归审查触点完整性维)/ credentials.conf;skip 字段制度消亡,豁免走 exempt 微 audit)。本文正文按 immutable 惯例不追改。
```

### 5.6 发现链走查表(自检标准:任一入口 ≤3 步)

| 入口 | 路径 | 步数 |
|---|---|---|
| 跨运行时 agent(根 AGENTS.md) | 凭证义务行 / 硬规矩行 → credentials-rules.md | 1 |
| Claude Code 自仓库(根 CLAUDE.md) | §2 治理表「凭证与对账」行 → credentials-rules.md | 1 |
| 下游(CLAUDE.md=M4 / AGENTS.md) | 治理表行 或 硬规矩行 → credentials-rules.md | 1 |
| 工作流内(finishing 收口) | finishing-rules「凭证义务核对」节 → credentials-rules.md | 1 |
| 工作流内(审查) | review-rules 维度表治理行 → credentials-rules.md | 1 |
| 对账报错现场 | check-audit-coverage stderr 指引 → credentials-rules.md | 1 |
| 冷读者(README) | 原则 4.3 行 → credentials-rules.md | 1 |

> 全部入口 1 步直达(设计裕量:标准是 ≤3 步)。走查在 §8 验证策略列为人工核条目。

---

## §6 契约锁退役与残余双端(R5)

### 6.1 contracts-locked.md 退役注记(逐字草文,文件顶部插入;正文一字不动)

```markdown
> ⚠️ **已退役(2026-06-13,治理同层化)** — 本文件转考古层。
> 契约锁防的是"批次实施期多 agent 拷贝漂移";单源 + 引用体制已消灭拷贝,锁无对象(decision `docs/decisions/2026-06-13-governance-single-layer.md` 第一性重推 1:退役非"迁锁")。
> C1(scope.conf)→ 后继 `.claude/hooks/credentials.conf` + `docs/governance/credentials-rules.md` §2;C2(audit 文法)→ credentials-rules §3(文法语义逐字沿用;标识字段名按 R13 统一为 `audit: true`,21 份历史件同批格式迁移;文件名不换);C3(handoff skip/反审字段)→ skip 制度消亡(豁免=exempt 微 audit,credentials-rules §4),反审字段为已闭环历史;C4(三段 pattern)→ 各审查 skill SKILL.md 自带;C5(settings 双轨)→ 自仓库 settings 已撤(2026-06-12 追记①),templates/settings.json 为下游唯一来源。
> 残余真双端(规则文本 ↔ hook 正则)清单与守法住 spec `docs/superpowers/specs/2026-06-13-governance-single-layer-design.md` §6.2。
```

### 6.2 残余"规则文本 ↔ hook 正则"双端清单(GRAMMAR 类,逐对列出 + 守法)

> 锁退役 ≠ 双端消失。以下每对的两端是"人读文法声明"与"机器解析正则",**结构上无法单源**(一端是散文一端是代码);守法 = fixture(机器端锁行为)+ 审查触点完整性维(改一端时人工核另一端)。如实声明,不假装单源。

| # | 文本端 | 正则/代码端 | 守法 |
|---|---|---|---|
| 1 | structured-handoff SKILL「promotion 声明文法」节(三处同文法声明) | check-handoff.sh `GRAMMAR=` ERE(Stop 与 --reconcile 共用同一条,已单源于脚本内) | 既有 fixture(--reconcile 38+34 断言);本批零碰 |
| 2 | credentials-rules §3 audit frontmatter 文法(`audit: true` + covers) | check-audit-coverage.sh `is_audit_credential`(原名 is_meta_review_audit)/ `extract_covers` awk 正则 | 工具 fixture(文件名双前缀/迁移后样本)+ 真仓库对账账齐实证(§8) |
| 3 | credentials-rules §4 exempt 文法(`verdict: exempt` 行) | check-audit-coverage.sh `extract_verdict` 正则(新) | 新增 fixture:exempt 样本入账 + 计数行断言 |
| 4 | credentials-rules §2 人读表 / conf 行格式声明 | check-audit-coverage.sh conf 解析段(两字段切分) | fixture(缺类型字段 warning 分支/未知类型 fail-closed 按 audit/exclude 行误带类型字段)+ §8 双写比对核 |
| 5 | covers `<root>/` sentinel 协议(credentials-rules §3) | check-audit-coverage.sh §5.5 root 扫描段 + reconcile root 段 | 既有逻辑零改;fixture 沿用 |
| 6 | 三件套互引指针 + finishing/review 节锚 | (无机器端——cross-ref 件已删除,R14) | 审查触点完整性维:改任一端同批核互引(同批耦合纪律) |
| 7 | finishing-rules「收口硬核链」context-chain 声明行文法 | check-context-chain.sh 解析 | 存量双端,本批零碰(列出为全) |
| 8 | credentials-rules §7 Evidence Depth 填法 | check-evidence-depth.sh(只检字段非空) | 存量,零改不变量(§8) |

### 6.3 C1-C4 锁内容的法定后继(逐契约)

| 契约 | 后继住址 | 性质 |
|---|---|---|
| C1 scope.conf 锁定版 | credentials.conf(§3 草案)+ credentials-rules §2 | 文法沿用,语义降格(分流→凭证要求),类型字段为新参数位 |
| C2 audit covers 文法 | credentials-rules §3 | **逐字沿用**(R12);命名双前缀扩展 |
| C3 字段 1/3(两 skip) | 消亡(R7);后继 = exempt 微 audit(credentials-rules §4) | 制度替换非迁移 |
| C3 字段 2(反审待办) | 无后继(已闭环历史,2.1.2) | 考古 |
| C4 三段 pattern + 嵌入约束 | 四 SKILL.md 各自带(§2.2.4);嵌入契约消亡 | pattern 逐字迁,约束消亡 |
| C5 settings 双轨 | 已被 2026-06-12 追记①先行取代(本批零碰) | 考古 |

---

## §7 消费点全枚举(本 spec 的生死节)

### 7.0 方法与总数

- **实跑**:`git grep -l -E "<术语>"`(LC_ALL=C.UTF-8,仓库根,2026-06-13),九术语:`meta-finishing-rules` / `meta-review-rules` / `meta-scope.conf` / `check-meta-review` / `check-meta-cross-ref` / `meta-review: skipped` / `meta-cross-ref: skipped` / `scope=meta` / `meta-L[1-4]`。
- **逐术语命中文件数(全量,含考古)**:45 / 49 / 35 / 44 / 24 / 18 / 9 / 43 / 53;**命中并集 98 件**(任务下发的粗扫基数 33/33/23/26/15/11/7/34/35 为预排考古后的口径;本节以全量并集为准逐件裁决,宁多勿漏)。取证时点注:计数截至 commit c8e4b4a;decision 追记 commit ffc4b3a 自身为术语 7(`meta-cross-ref: skipped`)新增 1 件命中(8→9),该件(decision 本体)已在 §7.3 不动清单,并集不变仍 98。
- **裁决三类**:**改**(活引用——现行流程/分发链/入口地图仍消费,改法逐件列)/ **不动**(考古层——audits、completed、decisions、旧 plans、旧 specs、references 日期留痕件、decision-trail、PROGRESS 历史行;R12 不追溯)/ **删**(随母件消亡)。
- **统计**:改 36 件(= 命中 33 件 + 无命中但负地图/模板义务 3 件:QUICKREF.md、templates/AGENTS.md、review-rules.md)/ 删 2 件 / 不动 63 件。校验:33 + 2 + 63 = 98 ✓。

### 7.1 改(36 件,逐件改法)

> 行号为 2026-06-13 实物行号,实施时以届时文件为准。「§」指本 spec 设计节。

| # | 文件 | 命中术语(处) | 改法 |
|---|---|---|---|
| 1 | 根 CLAUDE.md(M3) | 五术语多处 | §5.2:删 §3/§4/§5 三节;§2 单表化;角色行/开场规程命令/触点完整性维提法改 |
| 2 | 根 AGENTS.md | check-meta-review(L17) | §5.1:凭证义务行+对账行改写、三命令、硬规矩加行 |
| 3 | 根 README.md | meta-review(L31,168)/meta-scope.conf+check-meta-*(L41) | §5.4 三行改(根与 harness/README.md 两份独立维护,改法各自适用) |
| 4 | harness/README.md | 同上(L29,39,245) | 同上 |
| 5 | harness/CLAUDE.md(M4) | scope=meta/meta-review(L24 D13 注) | §5.3:D13 注删换同层注;治理表两行 |
| 6 | QUICKREF.md | 无命中 | §5.4 加三行(地图义务) |
| 7 | templates/AGENTS.md | 无命中 | §5.1 下游补第三条+硬规矩行 |
| 8 | templates/README.md | check-meta-review/check-meta-cross-ref(L8)/meta- 前缀(L13)/meta-review(L24) | L8 改"hooks 全量分发(check-meta-cross-ref 已删除,R14)";L13 改"确认脚本随 hooks 循环分发(无排除机制)";L24 改"入凭证义务(credentials.conf templates/*.json 行)— 改模板必触发审查凭证" |
| 9 | setup.sh | 前缀过滤两段(L69-77,L98-105)+注释 | §4.3:删两 case 段(无任何点名排除)、加 conf cp 行、注释改口径 |
| 10 | .claude/hooks/check-meta-review.sh | 自身+全文 | **改名** check-audit-coverage.sh + §4.1 十一点改造 |
| 11 | .claude/hooks/check-meta-cross-ref.sh | 自身+全文 | **git rm 删除**(§4.2,R14 用户拍板;第三 skip 字段随灭) |
| 12 | .claude/hooks/meta-scope.conf | 自身 | **改名** credentials.conf + §3.2 草案(git mv + 内容重写) |
| 13 | .claude/hooks/check-handoff.sh | 注释 L39(meta-finishing-rules.md:116)/L52、L138(check-meta-review) | 仅注释:L39 教训出处改"(半角纪律,权威住 structured-handoff SKILL;沿 2026-04-28 C3 Y3 教训)";L52/L138 改 check-audit-coverage。**逻辑零碰** |
| 14 | .claude/hooks/check-context-chain.sh | 注释 L10/L23-24 | 仅注释:L10"与 meta-review 必须有 audit 同套路"→"与治理审查必须有 audit 凭证同套路";L23-24 命名/scope 注 → "无点名排除 → 分发下游;落 .claude/hooks/ → credentials.conf 自动纳凭证义务" |
| 15 | .claude/hooks/check-shelf-registry.sh | 注释 L25-26 | 同件 14 口径 |
| 16 | docs/governance/finishing-rules.md | 分流段/scope=meta/M1 指针(L1-17,104) | §2.1 全套 |
| 17 | docs/governance/review-rules.md | 无命中 | §2.2 加维度选择表+触点完整性维节+头注 |
| 18 | docs/governance/synthesis-rules.md | meta-review ×7(L3,17,34,103,169,227,276)/scope=meta(L201-205) | 流程名 meta-review → 治理审查(L3,17,103,169 场景清单);L34"由 meta-review/process-audit 抽检"→"由治理审查/process-audit 抽检";L201-205 术语示例行:`scope=meta` 示例替换为现行术语示例(如"凭证义务(改动命中 credentials.conf,须 audit 凭证)");L227 audit 路径示例改 `docs/audits/audit-YYYY-MM-DD-HHMMSS-...md`;L276 引用行改 `docs/governance/review-rules.md + credentials-rules.md(上下游同文分发)`并去"仅 harness 自仓库"警示 |
| 19 | .claude/agents/design-reviewer.md | M2 指针(L67,95,164,230,293) | L67 runtime 嵌入引导段删除(嵌入契约消亡),换一行"维度选择权威 = docs/governance/review-rules.md 维度选择表;治理面改动审查产 audit 凭证(credentials-rules)";L95 等四处"B 段维度名引用自 M2"→"引用自 review-rules 维度选择表" |
| 20 | .claude/agents/evaluator.md | M1/M2/meta-L/scope=meta(L76,85,93,96,127,148,217,293,370) | 同件 19 口径;L85/93/96 evidence depth 分流表:scope 三行表删,改单行"档位解释按改动类别 → credentials-rules §7";L148 档位话术改"治理改动用 L1-L4 治理列解释" |
| 21 | .claude/agents/security-reviewer.md | M2 指针(L71,115,187,256) | 同件 19 口径(模板住 security-scan SKILL) |
| 22 | .claude/agents/process-auditor.md | M1/M2 指针(L214,231) | 同件 19 口径(模板住 process-audit SKILL;L231 G 段示例路径改 credentials-rules) |
| 23 | .claude/agents/designer.md | meta-L1(L53) | "对应 spec evidence depth meta-L1 / feature L1" → "对应证据档位 L1(节内自检,credentials-rules §7)" |
| 24 | .claude/skills/design-review/SKILL.md | scope=meta 段(L33-42) | §2.2.4:整段替换为内嵌对抗式 A/B/C 模板 + 权威指针行;下游兼容注(B6)删除(同层后无条件分支) |
| 25 | .claude/skills/evaluate/SKILL.md | 同上(L52-66) | 同上 + L52 档位指针改 credentials-rules §7 |
| 26 | .claude/skills/security-scan/SKILL.md | 同上(L32-43) | 同上(混合式模板) |
| 27 | .claude/skills/process-audit/SKILL.md | 同上(L56-68) | 同上(事实统计式模板) |
| 28 | .claude/skills/structured-handoff/SKILL.md | meta-review(L83,85)/skip 轻路径(L85)/meta-finishing-rules.md:116(L117-118) | L83/85 晋升路由表:"走 meta-review"→"须 audit 凭证(credentials-rules)";L85"可走 skip 字段轻路径"→"可走 exempt 微 audit 轻路径(credentials-rules §4)";L117-118 教训出处改与件 13 同口径 |
| 29 | docs/governance/planning-rules.md | meta-L4(L11) | "实战留痕 / 真实场景验证 / meta-L4"→"实战留痕 / 真实场景验证 / 治理改动 L4(credentials-rules §7)" |
| 30 | docs/references/testing-standard.md | 适用域注(L3) | 改:"**适用域**:本文档定义 feature/代码改动的 L1-L4 细则;治理/设计改动的档位解释列见 `docs/governance/credentials-rules.md` §7(同名 L1-L4,按改动类别参数化;Evidence Depth 字段按类各填行)" |
| 31 | docs/references/challenger-orientation.md | L77 档位分流/L166 目录树 | L77 改"治理改动 → 引 credentials-rules §7 治理列";L166 树图行 `meta-review-rules.md / meta-finishing-rules.md` → `review-rules.md / credentials-rules.md / finishing-rules.md`(无日期前缀标准件、随 setup 分发,属活层) |
| 32 | docs/references/recommended-tools.md | L29 不 Swap 行/L63 scope 话术 | L29 同 §5.4 口径;L63 改"新增推荐工具:append 即可(不命中凭证义务);若要改 setup.sh 提示,setup.sh 命中 credentials.conf → 须 audit 凭证" |
| 33 | docs/superpowers/specs/2026-06-12-context-layer-design.md | §5/§6/§7 多处 | **仅状态头加受波及注记**(§5.5 逐字);正文 immutable 不动 |
| 34 | docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md | 全文(母体) | **仅顶部加退役注记**(§6.1 逐字);正文一字不动转考古 |
| 35 | docs/active/handoff.md | 对账命令(L48,50)/meta-L(L20,61-64)/已知问题(L54) | **经覆写改**:实施批收尾走 /structured-handoff 按新模板与新术语覆写(对账命令第 3 条、Evidence Depth 治理列话术);不做专项文本编辑(台账 mutable,覆写是正路) |
| 36 | docs/ROADMAP.md | L36,42,63(历史进展行)/L77(活观察项) | **仅活条目改**:L77 观察项内 check-meta-review 提及改新名(该条目描述的是仍在跟踪的工具行为);L36/42/63 为已完成批次的历史叙述(引历史 audit 文件名/当时术语),**不动**(改了反而失真) |

### 7.2 删(2 件,随并入消亡)

| # | 文件 | 去向 |
|---|---|---|
| D1 | docs/governance/meta-finishing-rules.md(M1) | `git rm`(git 史即考古);内容去向 = §2.1.2 逐步裁决表(Step C 逐字迁 finishing-rules;§4 档位迁 credentials-rules §7;skip 汇总消亡) |
| D2 | docs/governance/meta-review-rules.md(M2) | `git rm`;内容去向 = §2.2(维度/4 维/触点维 → review-rules)+ §2.2.4(三段 pattern → 四 SKILL)+ §2.3(§7 audit 规范/§8 失效 → credentials-rules §3/§5)+ 消亡件(§2/§5 scope 与嵌入契约、§9 skip 字段) |

> 改名 3 件(check-meta-review.sh / check-meta-cross-ref.sh / meta-scope.conf)计入 7.1 件 10-12,旧名经 git mv 消亡,不另计删。

### 7.3 不动(63 件,考古层——按目录批量裁决)

> 共同理由:R12「不追溯改写历史」;immutable 格(decisions/decision-trail/references 日期件)与凭证层(audits)过时标注不删改;completed 为归档快照;旧 plans/specs 为已执行完的批次文档(其指涉的是当时的制度,改写即失真)。双前缀 glob + frontmatter 兼容保证这些文件在新工具下继续有效(§8)。

| 目录/文件 | 件数 | 明细 |
|---|---|---|
| docs/audits/ | 19 命中 + 3 零命中 = **22 全目录** | 命中术语 19 件:meta-review-2026-{04-28-102359, 04-28-174615, 04-28-215638, 04-29-095821, 04-29-150902, 05-06-143426, 05-13-165053, 05-25-010353, 05-26-094034, 05-29-081645, 05-29-184740, 06-04-140746, 06-04-231235, 06-05-184052, 06-05-204125, 06-11-182559, 06-11-222130, 06-12-230048}-*.md + audit-2026-04-28-133251.md;**零命中同裁决 3 件**(不在 §7.0 并集 98 内,本行清点求全——2026-06-13 自检补列):meta-review-2026-{04-28-182335-glassbox-recommendation-reframe, 06-04-203756-remove-session-search, 06-11-135802-context-layer-batch0}.md(凭证层;文件名与 frontmatter 永不追改) |
| docs/completed/ | 5 | _handoff_disabled-2026-04-28.md、handoff-20260611-183048.md、handoff-20260611-222330.md、handoff-20260612-230153.md、p0-9-1-flows-visualization-2026-04-26.html(归档快照) |
| docs/decisions/ | 15 | 2026-04-26-bypass-paths-handling、04-26-p0-9-1-self-review-trigger、04-28-decision-trail-introduction、04-28-m1-m2-m4-governance-batch、04-28-p0-9-1-meta-review-revision、04-29-p0-9-3-governance-drift-detection-batch、05-12-ecc-analysis-snapshot、06-04-prune-dead-hooks-and-skill-extract、06-04-remove-process-audit-satisfaction-n2、06-05-audit-bugfix-batch、06-05-living-context-chain、06-05-prune-orphans、06-10-preferences-scope-membership、06-11-session-chain-reconciliation、**06-13-governance-single-layer**(immutable 只追加;末件是本 spec 需求源,其文内旧术语是被裁决对象本身) |
| docs/superpowers/plans/ | 8 | 04-26-p0-9-1-self-governance-plan、04-28-m1-m2-m4-governance-batch-plan、04-29-p0-9-3-governance-drift-detection-batch-plan、04-30-d-class-tech-debt-batch、05-25-fork-intent-and-report-clarity、05-26-challenger-orientation-system、05-29-solution-research-scout、06-11-context-layer(已执行完批次;contracts-locked 单列 7.1 件 34) |
| docs/superpowers/specs/ | 9 | 04-17-p0-9-self-governance-design、04-28-m1-m2-m4-governance-batch-design、04-29-p0-9-3-governance-drift-detection-batch-design、04-30-d-class-tech-debt-batch-design、05-24-codex-shelved-batch-design、05-25-fork-intent-and-report-clarity-design、05-26-challenger-orientation-design、05-29-solution-research-scout-design、06-10-context-layer-design(已取代/已落地 spec;06-12 现行版单列 7.1 件 33) |
| docs/references/ 日期留痕件 | 4 | 2026-05-22-p0-9-4-self-check、2026-06-10-business-module-map、2026-06-10-scaffold-vs-ultracode-map、2026-06-10-handoff-kb-integration-analysis(immutable 只追加格) |
| 其他 | 3 | docs/decision-trail.md(immutable 只追加)、docs/PROGRESS.md(里程碑历史行,引当时凭证名)、docs/active/design-review-result.md(一次性流程产物,随下次 design-review 覆写,不专项清扫) |

### 7.4 收尾断链核(枚举的可验证收口)

**批 5 收尾、/structured-handoff 覆写台账(件 35)之后**跑九术语 grep 复核(V4;与 §9 批 5 行同步——handoff 含命中且不在下方排除清单,覆写前跑必红),**活层零命中**判据(排除口径 = 7.3 考古清单 + 7.1 件 33/34 的注记件 + ROADMAP/PROGRESS/decision-trail/completed/audits/decisions 目录 + 旧 plans/specs):

```bash
git grep -l -E "meta-finishing-rules|meta-review-rules|meta-scope\.conf|check-meta-review|check-meta-cross-ref|meta-review: skipped|meta-cross-ref: skipped|scope=meta|meta-L[1-4]" -- . \
  ':!harness/docs/audits' ':!harness/docs/completed' ':!harness/docs/decisions' \
  ':!harness/docs/decision-trail.md' ':!harness/docs/PROGRESS.md' ':!harness/docs/ROADMAP.md' \
  ':!harness/docs/superpowers/plans' ':!harness/docs/superpowers/specs' \
  ':!harness/docs/references/2026-*' ':!harness/docs/active/design-review-result.md'
```

预期输出:空(活层零命中)。注:specs/plans 整目录入排除是因新 spec(本文件)与受波及注记自身必然含这些术语(指称性使用);ROADMAP 排除后其 L77 活观察项的改写由 plan 任务单独断言(`grep -c check-meta-review docs/ROADMAP.md` 仅历史行命中)。排除清单本身的膨胀风险见 §10-e。

---

## §8 兼容不变量 + 错误处理 + 验证策略

### 8.1 兼容不变量(对话已确认版,逐条)

| # | 不变量 | 机制 |
|---|---|---|
| I1 | **历史 audit 全量有效**(实数 21 份 meta-review-*.md;另 1 份 process-audit 报告本就不是审查凭证)。covers 与正文零 backfill;frontmatter 字段名统一格式迁移 `audit: true`(R13 用户拍板"格式≠内容") | 文件名双前缀收集 glob(§4.1-3)+ 字段迁移防护对照(§4.1-10) |
| I2 | **handoff 路径与 promotion 文法零碰**:docs/active/handoff.md 路径、promotion 四态 GRAMMAR、晋升门禁、书架登记全不动 | check-handoff.sh / check-shelf-registry.sh 逻辑零改(仅注释行,§7 件 13/15);handoff-template.md 零命中零改 |
| I3 | **四件无关 hook 零改**:check-evidence-depth.sh / check-context-chain.sh / check-module-docs.sh / session-init.sh 功能零碰(check-context-chain / check-handoff / check-shelf-registry 的注释行换名为声明的唯一例外,逻辑 diff 必须为零) | §4.4 零改清单;plan 任务以 `git diff` 逐 hook 断言 |
| I4 | **Evidence Depth / CI 阻断字段名与 check-evidence-depth.sh 零改**(R10 括注) | credentials-rules §7 只改档位解释列,不改字段名/行格式 |
| I5 | **covers 文法 / `<root>/` sentinel / 失效规则零改** | §2.3 逐字沿 + §4.1-5 |
| I6 | **承重治理件零碰**:做审分离/二公设(M3 §1 正文)、bootstrap 4 维(逐字迁移非改写)、design-rules.md、brainstorming/planning/implementation/testing-rules(planning-rules 仅 L11 档位名一处词,非规则语义) | R12;§7 裁决 |
| I7 | **下游既装项目不破**:未重跑 setup.sh 的老下游无 credentials.conf / credentials-rules / check-audit-coverage——无新文件即无新义务,旧行为(本就无 meta 件)不变;重跑 setup.sh 增量获得全套(活文件守卫保护其 handoff/AGENTS 等不被覆盖) | setup.sh 现有守卫机制 + conf 缺失降级(8.2) |
| I8 | **自仓库双层路径兼容**:check-audit-coverage 的 WORK_DIR 双层探测、root 扫描段、`git diff --relative` 基准全部沿用 | §4.1 第 9 点零改 |

### 8.2 错误处理(新增/变更路径)

| 情形 | 处置 |
|---|---|
| credentials.conf 缺失/不可读 | stderr warning + exit 0(沿现 graceful degrade;老下游常态,见 I7) |
| conf 行缺凭证类型字段 | warning + 按 audit 处理(§4.1-2;防手误丢执法) |
| conf 行未知凭证类型 | warning + 按 audit 处理(fail-closed,与缺类型同路径——类型 typo 与漏写同属手误,不应得到相反处置;§4.1-2) |
| 字段迁移半途中断 | 未迁件 frontmatter 仍为旧字面 → 新工具失认 → 欠账暴增(fail-loud 信号,非静默掩蔽);锚定 sed 幂等(§4.1-10),直接重跑迁移补齐 |
| exempt 微 audit 理由行缺失/空 | 工具不解析正文(凭证有效性只看 frontmatter);理由质量由 process-audit 按需/周期抽查(§2.4-4)——与正式 audit 正文质量同一守法层级,不加机器闸 |
| 双前缀误收 process-audit 报告 | `is_audit_credential` 滤除(§4.1-3);窗口锚竞选补同一过滤(改造中必修缺口) |
| 改名过渡期旧命令(check-meta-review.sh)被调用 | 文件不存在即报错——这是地图断链信号;防御 = §9 批序耦合(工具改名与三处命令行同批)+ §5.6 走查 |
| audit-* 新旧凭证同名冲突 | 不可能同名(新名含 [主题] 段;即便撞名,HHMMSS 粒度 + 同目录文件系统唯一性兜底) |

### 8.3 验证策略(对话已确认版,逐项可执行)

| # | 验证 | 形式 |
|---|---|---|
| V1 | **工具 fixture**(check-audit-coverage):按仓库惯例重建 fixture(临时不入仓)——双前缀收集(meta-review-* 与 audit-* 各一样本)/ exempt 入账与计数行 / conf 两字段解析(正常行/缺类型 warning 按 audit/未知类型 fail-closed 按 audit/排除行/exclude 行误带类型字段 → 排除失效例)/ 窗口锚竞选排除 process-audit 报告与 exempt(§4.1-3/-11) | 先红后绿(治理改动 L1) |
| V2 | **字段迁移核 + 全窗对账对照**(R13;V7 并入同一协议,全文 §4.1-10):迁移后 `grep -l '^audit: true'` 于 21 件历史凭证计数=21、`meta-review: true` 全仓 audits 残留=0、逐件 sed 替换数=1;基线(批 1 第一动作,旧工具 `--reconcile 99999`)↔ 迁移后(新工具同参数)**欠账名单对照 modulo 显式声明的预期 delta**(= 洗活集合 + 批内新增欠账):缩小集合逐件归因,均属"迁移时刻已失效的既存欠账"→ 转手工欠账留痕;无法归因 = abort | 脚本断言 + 实跑留痕 |
| V3 | **装机 fixture**:setup.sh 装 /tmp 目标,断言——credentials.conf 在场 / credentials-rules.md 在场 / check-audit-coverage.sh 在场且可执行 / 任何 cross-ref 件不存在(已删,R14)/ 全树零 `meta-*` 与 `check-meta-*` 文件名 / governance 目录含 review-rules+finishing-rules 且零 meta-* 件。**时点**:批 2 末首跑(零 meta-* 两断言除外——M1/M2 批 4 末才 git rm),批 4 末复跑补齐全部断言(§9) | 脚本断言(治理改动 L2) |
| V4 | **断链核 grep 清单**:§7.4 命令活层零命中 | grep 断言 |
| V5 | **双写比对核**:credentials-rules §2 人读表 globs ↔ credentials.conf include globs 逐行一致(可脚本抽取比对) | grep/diff |
| V6 | **地图链走查**:§5.6 七入口逐条人工走一遍,每条 ≤3 步到 credentials-rules | 人工核 + handoff 声明 |
| V7 | **真仓库对账账齐实证**(与 V2 同一对照协议):改造后在本仓库跑 `check-audit-coverage.sh --reconcile`——历史 21 份凭证被正确收集、窗口锚正确(最新已提交正式 audit,exempt 不参选);与旧工具基线的对照**不是"输出等价"**(两工具输出文法不相交,字面等价不存在),而是**欠账名单对照 modulo 显式声明的预期 delta**(= 洗活集合 + 批内新增欠账;判据与归因处置全文 §4.1-10) | 实跑留痕 |
| V8 | **制度自证(收尾 checkpoint)**:本批改动自身命中 credentials.conf(governance/hooks/skills/agents/setup/模板全中)→ 收尾时用**新工具**核出**本批自己的 audit 凭证**(凭证文件用**新命名** audit-YYYY-MM-DD-HHMMSS-governance-single-layer.md)——账齐输出即制度运转的第一个实证(decision「后续」节明令) | 实跑留痕(治理改动 L3+L4 起点) |
| V9 | **逐字迁移保真核**(§2.3 通则):落地后对每个"逐字沿用/迁入"承诺段 diff(退役件源段 vs 新居所段),仅通则映射表内的机械名替换为合法差异,语义零漂;含四 SKILL 内嵌模板的**正向在场断言**(对抗式 A/B/C / 混合式 / 事实统计式逐 SKILL grep 在场) | diff + grep 断言(排批 3 验证列) |

---

## §9 实施批次草案(供 writing-plans 输入)

> 原则:每批独立可验证、批内自洽(批末仓库处处可用);跨批耦合点显式标注。批序逻辑 = 基线留痕 + 新件先立(有处可指)→ 机器面同批换轨(工具/conf/迁移/setup/命令行)→ 文本合并 → 地图清扫 + 指针归一后退役件删除(消费者先于生产者退役)→ 收尾自证 + 断链核。

| 批 | 内容 | 验证 | 耦合注意 |
|---|---|---|---|
| 批 1 基线 + 新件先立 | **第一动作 = 迁移基线**(§4.1-10 协议):旧工具 `check-meta-review.sh --reconcile 99999` 全窗留痕。然后**纯新增** credentials-rules.md 成文(§2.3 骨架,逐字沿用段从退役件复制)。conf 改名挪批 2——旧工具 + meta-scope.conf 全程在岗,**执法真空窗归零** | credentials-rules 通读自检;基线留痕在案 | ⚠️ credentials-rules §2 的 conf 指针(credentials.conf)悬空一批——可接受:此时无任何入口指向本件(地图行批 4 才接);本批治理面提交(新件自身)在 plan 显式登记,属对照预期 delta 的"批内新增欠账"(§4.1-10 防盲区) |
| 批 2 机器面同批换轨 | check-meta-review.sh → check-audit-coverage.sh(§4.1 十一点)+ **meta-scope.conf git mv credentials.conf + §3.2 重写(与工具改造同批同 commit)** + **21 件历史凭证字段迁移**(§4.1-10 锚定 sed + 对照协议)+ check-meta-cross-ref.sh `git rm`(§4.2)+ **setup.sh 改造**(件 9,§4.3:删过滤段、加 conf cp 行、注释改口径)+ **同批改三处对账命令行**(根 AGENTS.md 对账行/根 CLAUDE.md 开场规程/templates/AGENTS.md 第三条)——开场规程指旧名一刻都不许跨会话。注:**根 AGENTS 的对账行与「手工校验」节是成对最小单位,不可拆半** | V1 先红后绿 + V2(基线对照,含缩小集合逐件归因)+ V3 装机 fixture(批末跑,消下游装机半态窗;零 meta-* 两断言待批 4 复跑补齐)+ V7 | ⚠️ 工具改名/conf 改名/字段迁移/命令行三处必须同批同 commit(§8.2);⚠️ **批 2 起至批 5 audit 落账前,开场对账带显式全窗参数(`--reconcile 99999`)**——字段迁移刷新全部凭证 commit time,默认窗(最新 audit 锚)语义失真;⚠️ setup.sh governance 过滤删除后至批 4 M1/M2 `git rm` 前,装机会拷入两退役件(过渡窗,批 4 自愈,V3 复跑断之) |
| 批 3 文本合并 | finishing-rules 改造(§2.1,含收口工序适用)+ review-rules 维度表(§2.2)+ 四 SKILL 内嵌模板(§2.2.4)+ contracts-locked 退役注记(§6.1)。**M1/M2 本体保留,`git rm` 挪批 4 末**(先改全部指针后删本体) | 三件套互引人工核(触点完整性维,cross-ref 件已删无机器核)+ V9 逐字迁移保真核 | ⚠️ 批 3 末 M1/M2 成"无收口入口但仍被 M3/agents/synthesis 指针引用"的过渡件(指针批 4 改),不得提前删除 |
| 批 4 地图清扫 + 退役件删除 | §5 五处其余改动(M3 三节删除/单表/M4/QUICKREF/README×2)+ §7.1 件 13-15(hook 注释)、18-23(synthesis+agents)、28(structured-handoff SKILL 指针行,M1 引用须于 git rm 前改完)、29-32(references)、件 8(templates/README)+ 上下文层 spec 状态头注记(件 33)+ **末位 `git rm` M1/M2 两退役件**(全部指针已于本批前段改完:消费者先于生产者退役) | governance 目录零 meta-* 断言(随 git rm 挪入本批)+ V3 复跑(补零 meta-* 断言)+ V5 双写比对 + V6 走查 | setup.sh 已批 2 完成(挪出);V4 断链核**不在本批**(件 35 handoff 未覆写,跑必红——挪批 5) |
| 批 5 收尾自证 + 断链核 | ROADMAP 活观察项(件 36)+ ROADMAP 登记治理批安全扫观察项(§10.2-i)+ decision-trail append + PROGRESS + /structured-handoff 覆写台账(件 35,新术语)+ **V8 制度自证**:新工具核出本批 audit(新命名),账齐留痕。**V8 covers = 批 1-5 全部 commit 的 `git log --name-only` 并集机械汇编(不靠记忆)**,含批 2 对照中转入手工留痕的洗活欠账(吸收或补审) | V4 断链核(/structured-handoff 覆写后跑,§7.4)+ V8 | 本批自身的 audit 凭证覆盖批 1-5 全部命中文件;V4 必须排在 /structured-handoff 之后 |

> 批粒度供 writing-plans 细化为任务;若合批执行,验证项不得合并省略。

---

## §10 残余风险(decision 忠实转录 + 设计中新发现)

### 10.1 转录自 decision(三条)

1. 三件套互引指针为新增同步面(低频、点状、可机核;触点完整性维 + 手工 cross-ref 工具守——§6.2 对 6 已落)(R14 后工具守作废,见 10.2-g)。
2. 下游认知负担 +1 文件名(地图行缓解);下游首次背 audit 制度(低频事件,credentials-rules 单入口可读)。
3. 改名期引用断链是"修一处漏同步"老病高发地形——本 spec §7 已带消费点全枚举实数(98 件并集/改 36/删 2/不动 63),计划须逐处验证(V4 断链核收口)。

### 10.2 设计中新发现(a-i)

- **a. 批 1-2 执法真空窗:已以批序设计消除**:conf 改名(git mv)与工具改造**同批同 commit**(批 2,§9)——批 1 = 纯新增 credentials-rules.md,旧工具 check-meta-review.sh + meta-scope.conf 全程在岗,真空窗**归零**。代价:credentials-rules §2 的 conf 指针悬空一批(指向尚不存在的 credentials.conf),可接受——此时无任何入口指向该件。
- **b. audit-* 命名空间与 process-audit 报告共存**:`audit-YYYY-MM-DD-HHMMSS.md`(process-audit,无 frontmatter)与 `audit-YYYY-MM-DD-HHMMSS-[主题].md`(审查凭证)同前缀同目录。机器区分靠 frontmatter 已闭环(§2.3/§4.1-3,含窗口锚竞选补漏);**人眼区分**靠"[主题]段有无",弱信号——若未来 process-audit 命名加主题段则人眼歧义,届时再议(本批不动 process-audit 命名,R12 最小变更)。
- **c. exempt 滥用面**:豁免成本 3-5 行,边界("无语义变更"+ 两类例外)靠自觉 + process-audit 按需/周期抽查(§2.4-4),无机器闸。定性如实:**skip 在现行体制下账面效力为零**(零接线 + reconcile 不认),**exempt 具满血清账力**(对账天然认)——滥用面在账本维度**变大**,非"同级风险"。仍判净改善的真实理由:①合法豁免此前无正路(skip 不被对账认,制度上等于无豁免出口);②永久落盘可审计、可失效(skip 随台账覆写蒸发;exempt 受 §5 失效规则约束);③抽查可达(covers 超 5 件必抽)。
- **d. 老下游的凭证义务空窗**:I7——未重跑 setup 的下游不知道新制度。属"分发更新"通病,非本案新增;README/CLAUDE 模板更新随下次安装到达。
- **e. 断链核排除清单膨胀**:§7.4 grep 排除口径含整目录(specs/plans/decisions/audits…),未来活文件误入这些目录会被漏检。缓解:排除口径与 7.3 考古清单同源声明,审查时触点完整性维核;接受为工具性残余。
- **f. ROADMAP/PROGRESS 历史行术语残留**(裁决保留,§7.1 件 36):读旧行的人会见旧术语——考古层本性,decision 明令不追溯;地图行已给新读者正路。
- **g. 互引断链仅审查兜**:cross-ref 件已删除(R14),互引守法唯一防线 = 审查触点完整性维 + 同批耦合纪律——与 decision 定性"低频+审查可抓"一致,如实声明(原"exit 2 无消费者"风险随删除消解)。
- **h. 治理批收口成本**(decision 追记三):凭证审查(2-5 fork)+ 方向评估(4 fork)/ 批——用户知情接受(原话:"方向评估重要")。
- **i. 治理批暂无机器安全扫**(decision 追记三):安全扫描/流程审计维持 feature 侧,hook 脚本危险操作面与 AI 指令文本注入面在治理批暂无机器扫——登记 ROADMAP 观察项(触发器:实战出险或用户重启;落点 §9 批 5)。

### 10.3 张力点处置记录(原「待回决策」;①②已由用户 2026-06-13 spec 审阅轮拍板,③按实数)

| # | 张力 | 处置 |
|---|---|---|
| ① | frontmatter 字段名(术语退役 vs 文法不动的交界) | **已决(用户)**:全换 `audit: true`,含历史 21 件同批格式迁移——用户立解释「immutable 保护内容,纯格式迁移不算改」(原话:"换,并且全换,我们不改内容,这个应该是格式问题,这样也不会出现两个章");单一解析路径;文件名不换(被 immutable 文档引用)。落点 §2.3/§4.1-10,需求 R13 |
| ② | cross-ref 件的去留(删机制后靠什么不分发) | **已决(用户)**:删除(原话:"删除")——问题消解,无需任何排除机制;互引守法归审查。落点 §4.2,需求 R14 |
| ③ | decision 行文"16 份 audit"与实数 21 份 | 按实数 21 设计与验证(V7);"16"为拍板时凭印象笔误,decision 追记已按实数留痕 |

---

## 自检(designer 节内自检,meta 习惯沿用——逐节)

- [x] §1 需求转录与 decision 原文逐条对照(R1-R14 全覆盖,用户原话逐字)
- [x] §2 三件套各节给出"删什么/迁哪里/逐字草文";exempt 文法给逐字模板 + 解析器兼容分析(对实物 awk 函数核过)
- [x] §3 conf 草案完整、与现 conf 逐组对照、类型字段参数位预留(已知预留类型跳过,未知类型 fail-closed 按 audit)
- [x] §4 工具改造逐点对实物脚本段落核过(含窗口锚竞选过滤真缺口);分发/接线给明确裁决与理由
- [x] §5 五处地图全部给逐字文本;走查表全入口 1 步直达(≤3 步标准有裕量)
- [x] §6 退役注记逐字;残余双端 8 对逐对列守法;C1-C5 后继逐契约
- [x] §7 九术语 grep 实跑(45/49/35/44/24/18/9/43/53,并集 98;取证时点注见 §7.0);改 36/删 2/不动 63 逐件裁决,加法自洽
- [x] §8 不变量 8 条/错误处理 8 情形/验证 9 项均可执行
- [x] §9 五批各带验证;批间耦合注逐批如实标注(真空窗归零/全窗参数/装机过渡窗/先改指针后删本体/V4 排序)
- [x] §10 decision 三风险转录 + 新发现 9 条(a-i)+ 张力点处置 3 项(①②用户已拍板,③按实数)

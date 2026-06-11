# 决策演化轨迹

> P2 可观测性的**时间维度**(空间维度由 glassbox 覆盖,session 内可视化)。
> 跨 session 关键抉择的连续记录,链到 `decisions/` 单条文件看完整推理。

> 与 `PROGRESS.md` 区别:PROGRESS = 里程碑(功能维度,粗);本文件 = 抉择(判断维度,细)
> 与 `decisions/` 区别:decisions = 单条决策完整推理;本文件 = 决策之间的因果链 + 索引
> 与 memory(`feedback_*.md`)区别:memory = 用户跨项目原则(私域);本文件 = 项目内可见 artifact

## 已知缺口(2026-04-28 引入时显式承认)

- **meta-L4 验证延后**:append 是否真发生 / 提取质量如何,1-2 月观察期才能验证(推 P1 真实项目阶段)
- **hook 不校验 append**:M15 / M16 不增加 append 校验项(光谱 B+ 最小硬 hook 原则);调度者忽略 append 无 enforcement
- **若调度者频繁忽略** → P0.9.3 议题考虑加 hook 校验(decision file §后续段已注明)
- **修剪策略**:本文件不淘汰旧条目。1 年累积 30-50 条后头部信息密度衰减;参 `decisions/` 半年归档惯例,**6 月后旧条目移 `docs/audits/archive/decision-trail/YYYY-HN.md`**(P0.9.1 仅声明策略,首次归档由后续阶段触发)
- **元条目自指**:首条"引入 decision-trail(本条,自指)"是 artifact 进自身索引的元条目。后续若做趋势统计需特判此类条目

## 维护规则

- **追加位置**:最新在上(时间倒序)
- **触发**:milestone commit / scope 级抉择 / 用户原则确立 / decision 文件创建时(**不限于 milestone commit**)
- **粒度**:抉择 = 判断拐点(不是任务完成);单条 ≤ 6 行
- **link**:有 decision file 必须链;无 file 标"暂无 + 原因"
- **不写**:任务进度(→ PROGRESS.md);技术细节(→ decisions/ 单 file);用户偏好(→ memory)

时间倒序。最新在上。

---

## 2026-06-11 — 会话链自执法取代常驻守门人(hook 降级工具箱)

- **抉择(立原则 + 消解)**:用户第一性重审("不要被之前的hook影响……用第一性原理开始思考")后拍板 **C 案会话链自执法**——下一会话开场对账上一会话的收口凭证(只读账本不读流水),取代"hook 接线上岗"的 A/B 之争;hook 降级为工具箱(手工模式=正身,自动触发=从 harness/ 启动时的增强)。原则:凡只靠"怕模型不听话"撑着的机制都在贬值,凡靠结构性事实(会话必死/自评乐观/内省无效)撑着的不贬值。
- **机制落点**:入口指令「开场两步」(M3 会话开场规程/M4 核心规则 11/AGENTS×2 对账行)+ check-meta-review `--reconcile`(已提交历史 audit 覆盖核,commit time 锚)——执法时点错位(C6)被对账吸收。
- **link**:`docs/decisions/2026-06-11-session-chain-reconciliation.md` + audit `docs/audits/meta-review-2026-06-11-222130-session-chain-reconciliation.md`

## 2026-06-11 — 上下文层批 1:晋升门禁上线(防遗忘从纪律转机制)

- **抉择(立机制)**:工作台(handoff 台账)与书架(九格)之间立**晋升门禁**(`/structured-handoff` 固定序:归档→清账四裁决→覆写→自查)+ 两道机器闸(check-handoff 硬核 promotion 文法/锚点/登记交叉核;check-shelf-registry 落库登记软扫)——"防遗忘"从对话纪律转为机器可核机制(四层谱:同批耦合>机器闸>凭证制度>版本兜底;两闸:空白即未做/没讨论清楚不放行)。
- **连带确立**:偏好=项目规范入 A 组审查(D11,忠实性口径不评判内容,不分发下游);AGENTS.md 入口地图×2(跨运行时第 0 步,共享核同批改);台账模板单源化(D3,双写面 4→2)。
- **link**:`docs/superpowers/specs/2026-06-10-context-layer-design.md`(D1-D17)+ `docs/decisions/2026-06-10-preferences-scope-membership.md` + audit `docs/audits/meta-review-2026-06-11-182559-context-layer-batch1.md`

## 2026-06-05 — 活上下文链 L1-L6 脊柱 + 审查 bug 修复 + 孤悬剪枝(三批)

- **抉择(立机制 + 立原则)**:建分发下游的 **L1-L6 分层活上下文链**(`docs/context/` 编码 + 机读 `upstream` + `check-context-chain.sh` 软/硬 hook),把跨会话上下文从散文交叉引用升级为机读分层图;同时锁定定位原则 **"探索工程并重 / 上松下严梯度"**(方向可探索、实现严谨,对抗审查=松转严分界;层=既有 workflow 阶段)。
- **抉择 2(软收尾硬收口)**:hook 平时只软警告(不拦发散),收口逼 handoff 写 `## context-chain: 已核/skipped` 机械牙齿(真核 AI 做)——meta-review 指出"软+硬都不机械拦=违立身原则"后加。
- **配套两批**:audit-bugfix(两轮多智能体审查逮的确认 bug:RUBRIC 令牌/防死循环守卫/字段契约/分发污染/~12 drift + `.gitattributes`);prune-orphans(11-agent 孤悬审计证伪后删 experience-index + retrospective-guide)。
- **流程**:每批 decision → 独立 designer → 4 挑战者 meta-review(grep 窗口坑/gawk 死锁/全角静默漏/孤悬空壳全由独立挑战者揪出,非领审员)→ 实现 + fixture/grep 自验 → audit。
- **link**:decisions `2026-06-05-{living-context-chain,audit-bugfix-batch,prune-orphans}.md` + audits `meta-review-2026-06-05-{184052-audit-bugfix-batch,204125-living-context-chain-spine}.md`;commit `80c018e`

---

## 2026-06-04 — 剪枝批次:删 5 死/冗余 hook + skill-extract + 治理诚实化

- **抉择**:删 2 个 pre-commit 孪生(M16,从没装)+ meta-self-review-detect(M20,永空转)+ notify-done(孤儿)+ check-finishing-skills(软冗余)+ skill-extract(0 产出);并把治理文档里 M16/M20 的"现行执法"描述收口(删掉一套描述了但从没运行的执法层)。
- **抉择 2(删 vs 落地)**:对"从没运行的 pre-commit 执法",选**删 + 文档诚实化**,不落地——问题(mid-turn commit 绕过 Stop 门)两个月没咬过,落地需正经测试+fail-loud,属投机性过度工程;记为候选 feature。
- **流程**:decision → 独立 designer 穷尽扫 → 3 挑战者 meta-review(抓到 memory 误删 process-audit 风险 + M20 对称盲点 + meta-scope.conf/templates 残留,pass-after-revision)→ 实现 20 文件(净 −1156 行)→ grep+jq 校验全绿
- **link**:`decisions/2026-06-04-prune-dead-hooks-and-skill-extract.md` + `audits/meta-review-2026-06-04-231235-prune-dead-hooks-and-skill-extract.md`

---

## 2026-06-04 — 删除 session-search skill(继承靠 session-init,不靠 invoke-skill)

- **抉择**:功能层剪枝第二刀。session-search(跨会话检索)无人手动用、自动触发无 hook 不可靠;用户只要继承①(连续性),而它已由 session-init(SessionStart hook)+ structured-handoff 机械提供 → 删。继承②(自动召回旧经验)用户不要,不做。
- **触发**:功能剪枝讨论 → 拆"继承①连续性 vs ②自动召回";用户确认"基本没碰"+ 只要①
- **流程**:decision → 独立 designer 穷尽扫 → 3 挑战者 meta-review(抓到设计者把 harness/README 行号错套到根 README + 漏树计数,pass-after-revision)→ 实现 9 文件 → grep 校验全绿
- **link**:`decisions/2026-06-04-remove-session-search-skill.md` + `audits/meta-review-2026-06-04-203756-remove-session-search.md`

---

## 2026-06-04 — 删除 process-audit 效果满意度维度(N2)

- **抉择**:把"满意度"拆成三类后,删事后情绪审计(N2,弱 / 无牙 / record-only / 仅落地 1 次),保留 A=RUBRIC 渐进式校准(有牙、前向)+ C=已对照用户原话(意图对齐)
- **触发**:锐评核查 → 满意度全量梳理(6-agent workflow)→ 用户拍板一刀删、feature + meta 两边删
- **流程**:decision → 独立 designer 穷尽扫描 → 3 挑战者 meta-review(pass-after-revision)→ 实现 9 文件 → grep 校验
- **link**:`decisions/2026-06-04-remove-process-audit-satisfaction-n2.md` + `audits/meta-review-2026-06-04-140746-remove-process-audit-n2.md`

---

## 2026-05-29 — 方案调研员(research-scout):主动调研 / 联网调研外部方案

- **抉择**:给 harness 加"方案调研员"能力 — 规划多智能体方案时,需求定了、方案讨论前,**按需** fork 联网调研员搜业界现有方案。核心:harness **不造调研引擎**(重复造轮子=犯本 batch 要防的红线),只加薄纪律层(何时调研 + 结果怎么用),引擎**默认用 Claude Code 自带的 deep-research workflow**(调不到则 WebSearch fork 兜底)。触发判据 = 可逆性主轴 × 熟悉度次轴,默认 skip,由调度者(独立方)判断(非待调研 agent 自评 — 做事/判断分离)。红线核心:调研产出只当**证据/选项**(经自己思考判断是否适用),**不给推荐排名**、不当判断依据("别人这么做不单独构成理由")。
- **触发**:用户 2026-05-29 原诉求"遇到不了解主动搜寻 + 重视模型输入 + 规划方案时分智能体联网搜方案"。缺口核查(Workflow 4 reader)证实三诉求统一为"harness 缺从仓库外拿新信息做输入"的链路。
- **红线澄清(误解多次)**:用户纠正 `feedback_judgment_basis` 红线 = **"不照搬要思考",不是"不许看/查"**;调研业界技术方案当证据是允许的(尤其为下游用)。修正上 batch challenger-orientation §2.4 写错的"跨项目→不查"。memory 已同步钉死。
- **走过的弯路**:原想造 research-scout 引擎 → 用户引导"复用现成的" → 发现 deep-research 是 Claude Code 自带 workflow(读源码:5 角度→fetch→3 票对抗验证→带引用)→ 设计简化成"薄纪律层 + 编排现成 deep-research"。三轮调研(缺口核查 / 业界做法 8 agent 全联网 / 触发判据跑现成 deep-research 102 agent)全程 dogfood — 用要做的能力设计它自己。
- **改动 scope**:meta(research-scout.md 新建 + brainstorming-rules + challenger-orientation §2.4 + README + CLAUDE M3/M4 + setup.sh + harness/README)。"重视模型的输入"用户明确推迟(独立诉求,记未来)。
- **push 前核查(2026-05-30)**:用户问"是否更新 readme" → fork 5 reader(Workflow)核查覆盖完整性,捞出 **setup.sh 漏发 research-scout.md**(下游断链 — brainstorming-rules/challenger/M4 CLAUDE 引用却没分发;原 audit covers 盲区 = 4 挑战者无人查分发链)+ 两 README drift(双轴表/角色表/目录/"18个"计数)→ 全修 + 独立 verifier 6 条全 PASS。**元教训 KG-F**:meta-review 应显式核查分发链。**澄清固化**:"改动走 meta-review(scope=meta)" ≠ "文件不分发下游"(写入 spec §5)。
- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-29-solution-research-scout-design.md` + audit `docs/audits/meta-review-2026-05-29-184740-solution-research-scout.md`(verdict=pass-after-revision,4 挑战者 + 1 验证者,0 🔴,A 类 7 修 + B 类 5 KG + §7 push 前核查追记)构成完整记录);plan `docs/superpowers/plans/2026-05-29-solution-research-scout.md`。

## 2026-05-29 — 挑战者导览体系(挑战者侧基础设施)+ KG3 顺手解

- **抉择**:给挑战者(fork 出的子智能体)建一份"导览"`challenger-orientation.md` — 主智能体侧 CLAUDE.md + Skill 地图的**对称物**。4 块:方法论(通用自检 + 4 agent 角色专属技巧)/ 数据来源向导(架构 + 跨平台路径 + 命令模板)/ 输入策略(批判看调度者输入 + **挑战者侧自取用户原话**校验主线 framing)/ 常见陷阱(公设 1 / spec_gap_masking / 反对反对 / 越权)。挑战者输出必填 `### 已对照用户原话` section,调度者综合时缺/空 reject(synthesis-rules 加事后规则 5)。同 batch 4 agent 文件 prompt 改 include 模式(删 governance 实文重复,fix-2 静态约束恢复)= KG3 顺手解。
- **触发**:上 batch(fork-intent)meta-review 暴露 4 个同根问题 — 挑战者没方法论(只 freestyle)/ 不知道去哪找信息 / 主线 framing 防御缺失 / KG3 4 agent 176 行重复。本质同根:挑战者跟 governance 之间没有标准"知识传递"机制。
- **走过的弯路**:议题 C(挑战者拿什么输入)→ 暴露方法论 + 数据源向导缺失 → 候选"用户原话提取 skill"被用户否决("跑了不一定有人读,调度者不读相当于白跑")→ 收敛到**挑战者侧自取**(挑战者用自带 Read/Grep 工具直接读会话 JSONL,不依赖调度者预提取)。
- **改动 scope**:meta(challenger-orientation.md 新建 + 4 agent + synthesis-rules + multi-agent-review-guide + setup.sh + README)。**dogfooding 里程碑**:meta-review 本身是导览体系第一次实战 — 4 挑战者全部成功 Read 导览 + 自取用户原话 + 输出合规 section,自取机制防住 framing(上 batch KG1 本次未触发);meta-L2 验收通过。
- **meta-review 修订**:共识 1(导览声明分发下游但 setup.sh 没复制 + 22 处 `harness/docs/` 前缀下游断链)— **用户选 A 扩 scope**:setup.sh 加复制 + 路径统一裸 `docs/`(下游视角)+ §2 加路径前缀约定。共识 2(命令 bash-only vs PowerShell 默认)+ 共识 3/KG-D(reject 不对称)低成本修。
- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-26-challenger-orientation-design.md` + audit `docs/audits/meta-review-2026-05-29-081645-challenger-orientation.md`(verdict=pass-after-revision,4 挑战者 + 2 验证者,5 known-gaps)构成完整记录);plan `docs/superpowers/plans/2026-05-26-challenger-orientation-system.md`。

## 2026-05-25 — fork 前现场意图识别 + 报告通俗化(方向「己」)

- **抉择**:落地用户原诉求"审查时 fork 智能体知道主线" + "报告通俗化(不预设用户和 AI 上下文,信息论)"。实现路径选方向「己」 — fork 前调度者现场意图识别,绑在 fork 事件;**不**实现 GateGuard 全套三层 hook(SessionStart + UserPromptSubmit + PreToolUse),GateGuard 设计哲学(`decisions/2026-05-12-ecc-analysis-snapshot.md §11.12`)保留作未来参考。
- **触发**:2026-05-25 用户会话提"审查的时候要有主线任务和分支任务的概念...将这主线任务+支线任务都输入给 fork 的智能体" + "汇报使用通俗的语言,不预设用户和你有相同的上下文(信息论)"。
- **走过的弯路(决策追溯)**:意图源初指 GateGuard → 选方案 D 三层 hook 全启 → 提取动力纠正为 LLM → 撞上"用 LLM + 不每次跑 + 不懒触发"三条结构性张力 → 用户提"或者使用 fork 之前进行意图识别?" → 收敛到方向「己」(最小可行实现:fork 事件触发点)。
- **改动 scope**:meta(7 个文件 / 14 处改动)— `synthesis-rules.md`(主改:加事前规则 5 + 综合输出表达准则节)+ `meta-review-rules.md`(补引用行)+ 4 个领审员 agent 文件(design-reviewer / evaluator / process-auditor / security-reviewer 各加 fork 前意图识别节 + 综合输出加用户视图段)+ `README.md`(§4.2 实现字段微调)。
- **不在 scope**:GateGuard 全套三层 hook / 不可逆动作前 C 确认 / 状态文件 / LLM CLI 调用 / brainstorming-rules 改动 / designer.md 改动 / hook 体系改动。
- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md` 自身构成完整记录);spec `docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md`(本 batch 设计文档);plan `docs/superpowers/plans/2026-05-25-fork-intent-and-report-clarity.md`(实施计划);audit:`docs/audits/meta-review-2026-05-26-094034-fork-intent.md`(verdict=pass-after-revision,9 covers,10 known-gaps;4 挑战者对抗式 D2 — C1 核心+副作用 / C2 目的+scope / C3 规则 5↔中性化张力专项 / C4 通俗化+4 agent 一致专项;35 finding / 6 🔴 全部接受为 known-gap 或 1 实施 bug fix 修补)。

## 2026-05-24 — codex 接入搁置

- **抉择**:搁置 P2 codex 接入(11 swap 角色 — `model-route.md` §4),fork 子任务维持全 Claude;**不删** `model-route.md` / `synthesis-rules.md` P2 段 / `planning/implementation/testing-rules.md` 顶部引用 / `p0-9-4-self-check.md` §C/§G3/§G4/§F2(保留作日后基线);11 处文件改动 = 5 governance(scope=meta)+ ROADMAP + self-check(scope=none 跟随)+ decision-trail + handoff + 2 README(scope=none 跟随)
- **替代**:A 全删 codex 规划文档(信息丢失,重启时需重写)/ C 改写为"日后启动 + 触发信号"(违反 `feedback_iterative_progression`);banner 内容动版本(违反 `feedback_spec_gap_masking` B 风格)
- **触发**:2026-05-24 用户 + 调度者 cross-check 发现实施层 0% 落地(11 swap 角色中 5-6 个在 `.claude/{agents,skills}/` 里本身不存在)+ plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝实证 + codex exec 直调 gpt-5.5 通但 harness 入口需 skill/agent 文件设计调用范式 + `feedback_iterative_progression`(无具体真实需求拉动时不做)
- **影响**:11 处文件加 `[2026-05-24] codex 接入搁置` banner(字面统一,详 spec §8.2);3 commits(A 类 governance / B 类 ROADMAP+self-check / C 类 decision-trail+handoff+README);N=4 标准 meta-review(bootstrap 4 维基线 — 挑战者 #1 核心原则合规 / #2 目的达成度 / #3 副作用 / #4 scope 漂移;各维子焦点详 spec §6.2);**不预设重启时间 / 启动条件 / 触发信号**(D1 决策 D 风格);未来重启时重走完整 brainstorming + design,不从本 spec 草拟启动条件;plugin-cc patch 保留(D7 决策,独立于 11 swap 角色搁置)
- **decision file**:暂无(留痕型,本拐点 + spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` 自身构成完整记录;`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11 P2 实施路径 superseded by 本拐点);spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md`(本 batch 设计文档);audit:待 meta-review 跑完后回填(预期 `docs/audits/meta-review-2026-05-24-HHMMSS-codex-shelved-batch.md`)

## 2026-05-22 — P0.9.4 主线:二公设 + synthesis-rules + P2 codex 接入

- **抉择**:确立二公设(Pathological Optimist + 行动公设)+ 反向硬约束;新建 synthesis-rules.md(事前+事后规则,Council 轻量替代)+ model-route.md(P2 codex swap 决策表 7 swap / 6 保 Claude);P2 路径选 codex-plugin-cc + ChatGPT 订阅(gpt-5.4 / gpt-5.4-mini 验证可用;gpt-5.5 需 CLI 升级,spark 仅 API key)
- **替代**:Council 完整机制(剔除 — 扁平 fork 已 prompt 隔离)/ 脚手架主动拆(剔除 — 冗余)/ 分两波 swap(剔除 — git 兜底足够)/ 监控同质化(剔除 — 主观)
- **触发**:ECC 项目分析(`vendor/everything-claude-code` 3 agent + 反向找漏 + 用户红线 grep)→ 23 条吸收清单 + 黑名单 7 条;P2 codex 目的修正"成本节省核心,跨模型对抗副产品"
- **影响**:N=5 meta-review 24 问题(5 高)→ 14 修订 + 3 cosmetic + 4 model-route 兼容性修订;N=2 复核 verdict=pass;7 新建文件;3 governance 加 synthesis 引用;M3/M4 二公设;setup.sh 加 cp experience-index;README/harness-README/recommended-tools 加 codex GitHub 入口
- **decision files**:[2026-05-12-ecc-analysis-snapshot.md](decisions/2026-05-12-ecc-analysis-snapshot.md)+ [2026-05-12-p3-debug-sop-original-framework.md](decisions/2026-05-12-p3-debug-sop-original-framework.md);audit:[meta-review-2026-05-13-165053-twin-axioms-and-synthesis-rules.md](audits/meta-review-2026-05-13-165053-twin-axioms-and-synthesis-rules.md)

---

## 2026-05-06 — P0.9.3 第二个 trial 闭合:D 类技术债 batch(D1+D4)

- **抉择**:闭合 P0.9.3 第一个 trial §9.4 #10(M3/M4 路径混淆)+ #12(PAIRS 覆盖度 2/4 不足)— D1 形态选 sentinel 前缀 B(0 backfill,与 5/6 现有 audit 约定一致);D4 加 PAIRS 2 条(实际 4 处互引全覆盖,原 audit 写 5 处经第三次审查重审为 4 处);M2 §7.3 加第 5 条 sentinel 协议规则
- **替代**:D1 候选 A(全仓库相对路径,需 backfill 5/6 历史 audit) / C(scope.conf 锚点 glob,fnmatch 不可行)— 都被否决;D4 候选 A(不修)/ C(语义比对 LLM-call,YAGNI)— 都被否决
- **触发**:用户判定"P0.9.3 第一个 trial 留下 #10/#12 用'调度者人工记忆'兜底脆弱",D 类技术债积累值得做 batch 闭合;`feedback_iterative_progression`(实战需求拉动)+ `feedback_judgment_basis`(D2/D3/D6 实战暴露面接近 0 不预防)
- **影响**:13 commits;~36 行 hook + governance 改动 + sentinel 协议 documented;trial 序列 hook 实现类的高 finding 密度部分由"视觉跳过 / 字面未验证 / 修复 sweep 不全"模式贡献,留痕 5 错链(audit revision 后扩第 6 错)+ 5 教训(spec §9.4 #25)。M3 root `/CLAUDE.md` §5 A 组描述同步更新("hook §5.5 可见");额外 D5 单独 commit `0e8283d` 修 `.gitignore` 精确化 + 11 historical untracked 治理文件入仓
- **decision file**:[2026-04-30-d-class-tech-debt-batch.md](decisions/2026-04-30-d-class-tech-debt-batch.md);audit:[meta-review-2026-05-06-143426-d-class-tech-debt-batch.md](audits/meta-review-2026-05-06-143426-d-class-tech-debt-batch.md)(verdict=pass-after-revision,4 挑战者扁平 fork,3 Important + 9 Minor — 3 Important + 4 Minor 修复,5 Minor 接受)

---

## 2026-05-06 — meta-review 元过程留痕:spec_gap_masking 6 错链(P0.9.3 第二个 trial 副产物)

- **抉择**:本 trial 累积 6 错(audit revision 时由 challenger 3 暴露第 6 错 — sweep scope 仍局限本 trial 文件,漏上游 P0.9.3 第一个 trial spec L23 "2/5" + decision §不做 L141 "5 处" stale ref)→ 教训第 4 条扩"全仓库 + 跨 trial 上游文件";challenger 3 F3.4 暴露 spec §6.1 测试预期未标注 handoff skip 干扰 → 加 §9.4 #26 留痕 + 教训扩第 5 条"测试场景预期列必须标外部状态依赖"
- **替代**:沿用原"修字面错只 sweep 命中点"叙事(被 challenger 3 否决);沿用 spec §6.1 原"hook exit 2"单态描述(被 F3.4 否决,改双态)
- **触发**:meta-review 4 challenger 中 challenger 3 维度("`feedback_spec_gap_masking` 元过程留痕完整性"混合式 pattern)主动找未识别的 spec_gap_masking 实例;challenger 3 自身就是抓出 trial 内部修复 sweep 不全的元层 challenger
- **影响**:本条不立独立 decision file(留痕型,继承 P0.9.3 第二个 trial decision §教训留痕节);meta-review pattern 价值实证 — challenger 3 抓出的 F3.1+F3.2 通过任务级 review(spec compliance + code quality)+ final code reviewer **全部漏检**,只有混合式元过程 challenger 抓住;用户原则 `feedback_spec_gap_masking` 实战 6 次重现,模式高频
- **decision file**:暂无(留痕型;并入 [2026-04-30-d-class-tech-debt-batch.md §教训留痕](decisions/2026-04-30-d-class-tech-debt-batch.md))

---

## 2026-04-29 — session-search skill 保留(用户拍板)

- **抉择**:保留 `session-search` skill;harness/CLAUDE.md skill 表 session-search 行 git checkout 恢复
- **替代**:删 skill + 走 M0 范式 trial 清理(被否决)
- **触发**:老版本生图项目 retrospective(`D:\项目\智能体-生图\docs\active\harness-retrospective-2026-04-29.md`)显示 5 session 累计 1 次调用 + 用户 2026-04-29 之前 linter/手动删 harness/CLAUDE.md 一行;讨论是否走 M0 范式 trial 删除
- **影响**:无代码改动(状态保留 + 1 条 decision-trail 留痕);决定不主动删 — 设计目的合理(/clear 后跨 session 知识检索),实战用得少不等于有害;真删等 P0.9.2 实战观察期数据(`feedback_judgment_basis`:数据少不主动改);decision-trail.md 已部分覆盖其用例(自动 append + handoff 可读),但不构成废弃理由
- **decision file**:暂无(状态保留型,不立 decision file;若 P0.9.2 数据驱动删除再建 decision)

---

## 2026-04-29 — P0.9.3 第一个 trial:governance 漂移检测兜底 batch

- **抉择**:做 (vii) M3 hook 不可见 + cross-file 互引 hook 检测(2 项 batch);不做 (i)(ii) 占位等数据 / (iv)(vi) spec 已 accept / B 方案弱需求;scope=meta(B 组 hooks + A 组 settings)
- **替代**:B 加 B 方案(主仓库↔下游版本漂移)/ C 全 5 项强行 batch — 都违反 `feedback_judgment_basis`(无实战数据不预防)
- **触发**:用户(2026-04-29)指示"如果没有新任务的话,进行 P0.9.3 candidates";brainstorming Q1 阶段按 fix-9 历史决策 + 当下可做性重排 5 候选,识别"可做" vs "占位等数据" vs "已 accept 关闭"
- **影响**:7 commits;5 文件改动(2 改 check-meta-review/commit.sh + 2 新建 cross-ref + cross-ref-commit + 1 settings.json);2 处实施过程修补(R1 stderr warning 缺失 + §5 early-exit guard latent bug — plan/spec 漏);新发现 1 secondary bug(M3/M4 路径混淆,推 P0.9.4);**P0.9.3 第一条 meta-L4 数据点** — P0.9.1 治理流程对 hook 改动 trial 仍有效;ROADMAP 副产物修正(把 (iv)(vi) 标已 accept 不再列候选 + (i)(ii) 标占位);spec §9.4 加 1 条新缺口(路径混淆)
- **decision file**:[2026-04-29-p0-9-3-governance-drift-detection-batch.md](decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md);audit:[meta-review-2026-04-29-150902-p0-9-3-governance-drift-batch.md](audits/meta-review-2026-04-29-150902-p0-9-3-governance-drift-batch.md)(verdict=pass-after-revision,4+2 挑战者扁平 fork,第 1 轮 26 finding → 第 2 轮 D4 pass + D2 部分 → 第 3 轮调度者补完)

## 2026-04-29 — M1+M2+M4:治理改动 batch(P0.9.1.5 第二个 trial)

- **抉择**:batch 1 个 trial(M1 封死简化收尾 + M2 RUBRIC 不作跳过依据 + M4 轻量级判定收紧 + spec §0 偏离规则);M3 drop(报告 #1 已解决 + #2 超 scope 推 P0.9.2);scope=meta(A 组 + D 组 DESIGN_TEMPLATE.md)
- **替代**:separate 4 个 trial(meta-L4 数据点 ×4 但边际收益递减,M0 已产 1 个数据点)
- **触发**:用户(2026-04-28)指示":启动 M1-M4"(2026-04-17 起草的 M0-M4 治理修改批次第二项起);跨日继续(meta-review 实际 fork 跑于 2026-04-29 09:58:21)
- **影响**:`finishing-rules.md` 反模式段加 M1+M2 两条;`design-rules.md` 规模判断表加第 4 列前置硬条件 + 加新段 spec §0 偏离规则 + 默认升级原则 + 互引 M2;`DESIGN_TEMPLATE.md` L14 同步;ROADMAP P0.9.1.5 段 M1/M2/M4 🟢 已完成 + M3 ⚪ drop;**P0.9.1.5 整体闭合**;meta-review 4 挑战者第 1 轮 needs-revision → 13 处修订(spec 7 + finishing 3 + design 2 + DESIGN_TEMPLATE 1)→ 第 2 轮 N=2(D2+D4)pass → final verdict=pass after revision;**P0.9.1.5 第二个 meta-L4 数据点**(P0.9.1 治理流程对 batch trial 仍有效);spec §9.4 加 5 条新缺口(harness self-trial 局限 / cross-file 互引脆弱 / 下游 retrospective 不可见 / 反模式段膨胀 / 挑战者有效性)
- **decision file**:[2026-04-28-m1-m2-m4-governance-batch.md](decisions/2026-04-28-m1-m2-m4-governance-batch.md);audit:[meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md](audits/meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md)

## 2026-04-28 — M0:删 block-dangerous hook(P0.9.1.5 第一个 trial)

- **抉择**:删 PreToolUse 危险命令拦截 hook;基础防御责任移交下游用户 + 上游 Claude Code permission 兜底;harness 范畴是治理不是安全
- **替代**:B 改 advisory(exit 0 + 警告) / C 缩 patterns / D 模板留默认空 — 三者维持"hook 维护负担 + 误拦风险",不如直接删
- **触发**:用户(2026-04-28)启动 M0 — 2026-04-17 起草的 M0-M4 治理修改批次第一项
- **影响**:首次跑通 P0.9.1 完整治理流程(brainstorming → meta-review → finishing) → meta-L4 第一条数据点;识别 `.gitignore .claude/` 让 hook 改动无 git audit trail(推 P0.9.2/3);decision file 完整附 hook 源码作 git 不留 history 唯一保留位置
- **decision file**:[2026-04-28-m0-delete-block-dangerous.md](decisions/2026-04-28-m0-delete-block-dangerous.md);audit:[meta-review-2026-04-28-215638-m0-delete-block-dangerous.md](audits/meta-review-2026-04-28-215638-m0-delete-block-dangerous.md)

## 2026-04-28 — 用户原则:边做边提升,ROADMAP 不预设固化阶段

- **抉择**:删除 ROADMAP 中"P1 真实项目迁移阶段"/"P2 L4 回归层"/"建议不做"段中纯远期反案 / "排期逻辑"大段;只保留当前在做 + 已识别下一步
- **替代**:保留预设阶段(原 ROADMAP 形态)— 但等于把未来需求假装当成已知
- **触发**:用户(2026-04-28)指示"将迁移和测试都移除计划中,我们这个是边做边提升的"
- **影响**:ROADMAP 大幅精简(~270 行 → ~80 行);新建 memory `feedback_iterative_progression.md`;handoff "下一步建议"段去 P1 迁移选项;新需求出现时再开 brainstorming + 立 decision
- **decision file**:[2026-04-28-iterative-progression-no-fixed-roadmap-stages.md](decisions/2026-04-28-iterative-progression-no-fixed-roadmap-stages.md)

## 2026-04-28 — glassbox 角色 reframe(用户级工具,harness 推荐不分发)

- **抉择**:P2 空间维度 glassbox 不做 submodule / 不做 setup.sh 自动 clone;harness 仅"推荐 + 链接记录,防找错"
- **替代**:1A submodule(harness 内嵌)/ 1B submodule(目标项目内嵌)/ 4 setup.sh 询问 + clone — 三者均把 glassbox 绑到项目层,与"用户级工具"本质不符
- **触发**:用户(2026-04-28)指出 glassbox 是个人工具不归项目管,harness 仅需"提示安装 + 记录链接"
- **影响**:新建 `docs/references/recommended-tools.md`(scope=none)+ setup.sh 末尾加推荐段(scope=meta)+ ROADMAP P2 空间维度描述 reframe + harness 仓库零依赖管理负担
- **decision file**:[2026-04-28-glassbox-recommendation-not-integration.md](decisions/2026-04-28-glassbox-recommendation-not-integration.md)

## 2026-04-28 — 引入 decision-trail(本条,自指)

- **抉择**:P2 可观测性拆双层 — glassbox(session 空间) + decision-trail(跨 session 时间)
- **替代**:B 扩展 PROGRESS 加抉择列;C audit 趋势统计;扩 glassbox 跨 session(不可行,per-session)
- **触发**:用户指出 glassbox 看不到跨 session 抉择,需文档载体
- **影响**:本文件落地(scope=none);M5 + M1 双路径加 append step(scope=meta);ROADMAP P2 双层重写;4 挑战者 meta-review 共识发现 M1 同步缺失,initial needs-revision → 修补 → pass
- **decision file**:[2026-04-28-decision-trail-introduction.md](decisions/2026-04-28-decision-trail-introduction.md);audit:[meta-review-2026-04-28-174615-decision-trail-introduction.md](audits/meta-review-2026-04-28-174615-decision-trail-introduction.md)

## 2026-04-28 — 用户原则:skill 不跨项目

- **抉择**:skill-extract 产出仅 project-local,禁止持久化 user-global / 跨项目 registry
- **替代**:原 ROADMAP P2 "重复工作 skill 化持久化"
- **触发**:用户否决 — 跨项目假设"模式相同"实际差异污染上下文
- **影响**:删 ROADMAP P2 该条;memory `feedback_skill_no_cross_project.md`;skill-extract SKILL 措辞改"仅 project-local"
- **decision file**:暂无(轻,memory feedback 即生效)

## 2026-04-28 — 用户原则:实战在其他项目跑,不阻塞 harness 开发

- **抉择**:harness 自仓库不补 artificial trial,meta-L4 / 实战留痕 / mixed scope 成本观察推 P1 真实项目
- **替代**:harness 自仓库手工补假数据
- **触发**:P0.9.1 finishing 阶段用户原则确立
- **影响**:planning-rules.md + finishing-rules.md 反模式约束节硬编码;memory `feedback_realworld_testing_in_other_projects.md`
- **decision file**:暂无(原则性,memory 即生效)

## 2026-04-28 — P0.9.1 meta-review 修订(D9 根源承认型,5 子项)

- **抉择**:initial needs-revision → P0+P1+P2 修补 → pass(after revision)
- **5 子项**:D-fix-T4-4 / D-templates-README / D-scope-conf-B-glob / M18 follow-on / M3 hook 不可见 acceptance
- **替代**:推翻 P0.9.1 全部重做;全部子项推 P0.9.2
- **触发**:4 挑战者共识发现 M3 hook 不可见缺口(3/4 交叉)
- **影响**:scope.conf F 组 glob 修(`34129ae`);M3 不可见推 P0.9.3;首条 P0.9.2 诊断数据点
- **decision file**:[2026-04-28-p0-9-1-meta-review-revision.md](decisions/2026-04-28-p0-9-1-meta-review-revision.md)

## 2026-04-26 — P0.9.1.5 触发条件:用户决定型(D20 = B)

- **抉择**:M0-M4 治理修改之一启动前由用户决定,无机械触发
- **替代**:A 时间触发;C git diff 累积触发
- **触发**:P0.9.1 spec 设计阶段第 7 轮自检识别
- **影响**:P0.9.1.5 不进 ROADMAP 排期,handoff "下一步建议"列用户选
- **decision file**:[2026-04-26-p0-9-1-5-trigger-condition.md](decisions/2026-04-26-p0-9-1-5-trigger-condition.md)

## 2026-04-26 — P0.9.1 自审触发条件

- **抉择**:P0.9.1 落地后立即触发 meta-review 自审(首批 meta scope 改动)
- **替代**:推到下一次 meta 改动累积时再审
- **触发**:bootstrap 验证需求 — P0.9.1 自身需先经过其建立的 meta-review 流程
- **影响**:产首条 meta-review audit;首条 P0.9.2 诊断输入数据点
- **decision file**:[2026-04-26-p0-9-1-self-review-trigger.md](decisions/2026-04-26-p0-9-1-self-review-trigger.md)

## 2026-04-26 — bypass paths 处理方式

- **抉择**:scope.conf 用 `!` 前缀排除 audits/meta-review-* + audits/archive/**
- **替代**:hook 内硬编码排除;不排除(允许自循环)
- **触发**:meta-review 自身产出物若进 scope 会自循环
- **影响**:scope.conf 排除组形成,M17 落地
- **decision file**:[2026-04-26-bypass-paths-handling.md](decisions/2026-04-26-bypass-paths-handling.md)

## 2026-04-17 — 承认 harness self-governance 缺口,新增 P0.9

- **抉择**:harness 反复打补丁根源 = 三条结构性缺陷(治理无执法 / bootstrap 缺陷 / 马鞍定位错位),P0.9 加塞先于 P1
- **替代**:继续 ad-hoc 修补;直接进 P1 真实项目验证
- **触发**:接收 `D:\项目\智能体-生图` 老版本审查 + M0-M4 起草 4 挑战者扁平 fork 元审查
- **影响**:M0-M4 推迟首批使用;P0.9.1 / P0.9.1.5 / P0.9.2 / P0.9.3 全部由此衍生;P1 依赖 P0.9 就绪
- **decision file**:[2026-04-17-harness-self-governance-gap.md](decisions/2026-04-17-harness-self-governance-gap.md)

## 2026-04-16 — fork 嵌套扁平化改造(P0.5)

- **抉择**:5 skill + 5 agent 改扁平 fork,主对话直接并行 fork N 个挑战者
- **替代**:保留两级嵌套(领审员再 fork 子对抗者)
- **触发**:P1 验证发现 — 被 fork 的领审员无 Agent 工具权限,两级失效
- **影响**:P0.5 应急前置 P1;后续 meta-review 流程沿用扁平 fork
- **decision file**:[2026-04-16-fork-flat-refactor.md](decisions/2026-04-16-fork-flat-refactor.md)

## 2026-04-15 — 测试覆盖进 scope(P0)

- **抉择**:harness 增测试治理(L1 + L2 + L3 串行);L4 条件触发
- **替代**:推 P2;一次性做 L1-L4
- **触发**:5 对抗者审查 — RUBRIC 无独立"测试充分性"维度,治理散落但非真空
- **影响**:P0 序列 L2 → L1 → L3;Evidence Depth 概念引入;testing-rules.md / testing-standard.md 落地
- **decision file**:[2026-04-15-testing-scope-expansion.md](decisions/2026-04-15-testing-scope-expansion.md)

---

> 维护规则与自动化触发详见本文件顶部"已知缺口 + 维护规则"段 + `docs/decisions/2026-04-28-decision-trail-introduction.md`

# 上下文层(工作台/书架/交接)现行版设计

> **性质**:现行版整合性重述(2026-06-12)——只述已拍板、已落地的现状,不含新决策;每个断言可在实物(decision/audit/已落地文件)核到。
> **取代关系**:整体取代 `docs/superpowers/specs/2026-06-10-context-layer-design.md`(874 行设计稿;用户拍板「新 spec 整体取代」,decision 追记④,原话: "这个更好")。旧 spec 顶部加 ⚠️ 取代横幅后转**考古层**(设计论证/接口伪码/边界 B1-B20/测试策略/专项 A-K 的完整推理住那里,本文件不复述)。
> **考古指针**:旧 spec + `docs/decisions/2026-06-10-preferences-scope-membership.md`(D11)+ `docs/decisions/2026-06-11-session-chain-reconciliation.md`(C 案,含追记①-④——现行执法哲学权威)+ 三份批级 audit `docs/audits/meta-review-2026-06-11-{135802,182559,222130}-*.md` + plan `docs/superpowers/plans/2026-06-11-context-layer.md`(23 任务)。
> **锁定性质**:沿既有 spec 惯例**单件 immutable**(与九格表格 2「spec 单件 immutable」一致)——笔误级微修正走本状态头留痕;再有方向级变化 → 新 decision + 新版 spec 整体取代本文件(与本文件取代 2026-06-10 版同一模式)。
> 微修正 ×1(2026-06-12,批审 P1/P4):§10 表 row3 去已撤案的"先修 F1"旧语改指 §7;§7 追记③引录改逐字(AI 释义移出引号)。
> **路径约定**:文内 `docs/...`、`.claude/...` 以 `harness/` 为基准(与台账锚点写法同形);仓库根文件写「根 CLAUDE.md」「根 AGENTS.md」。

## §1 目标与第一性事实

**目标**:模型无关的上下文/知识/交接层——知识的组织让人和 AI 都能用、不腐烂、可机械治理;工作台(handoff)与书架(知识库)两层分开立硬制度:**工作台上有价值的东西必须上架登记后才许覆写**;防遗忘靠设计出来的机制,不靠 AI 自觉。模型无关 = 跨运行时/厂商:地基是纯文件 + 开放约定 + 可手工跑的 POSIX 脚本 + git;hook 仅为 Claude Code 增强层。

**七条不可约事实**(机制全部锚在这些结构性事实上,不锚在"怕模型不听话"——C 案 decision: "凡只靠'怕模型不听话'撑着的机制都在贬值,凡靠结构性事实(会话必死/自评乐观/内省无效)撑着的不贬值"):

| # | 事实 | 锚 |
|---|------|----|
| 1 | **会话必死**:过程随会话死,凭证替过程说话 | C 案 decision 用户认可方案原话(2026-06-11 "ok" 锚点) |
| 2 | **自评乐观**(Pathological Optimist):AI 评估自己的产出系统性乐观 | 公设 1,根 CLAUDE.md §1 |
| 3 | **内省无效**:窗口内"再想想"不改变信息状态,必须外部动作 | 公设 2,根 CLAUDE.md §1 |
| 4 | **注意力稀缺**:上下文是预算(台账 ≤80 行/渐进披露/只指不抄) | C 案 decision 用户原话: "我们有一个重点不是珍惜上下文吗?" |
| 5 | **人类判断稀缺**:蒸馏是判断活——AI 列选项,人拍板;不做自动晋升 | 旧 spec §1.3 不做清单;SKILL 松紧梯度段 |
| 6 | **模型在变强**:规则遵守可由指令层+验收承载 | C 案 decision 用户原话: "目前模型的能力已经很强了……" |
| 7 | **压力时刻存在**:收口是"乐观×压力"的重合点 | C 案 decision 第一性推演段 |

**四个代谢时刻**(C 案 decision 逐字: "工作循环只有四个代谢时刻"):**开场装载 → 干活 → 验收 → 收口**。机制只挂这四个时刻 + 落库当刻/覆写前两个动作时点,不新增步骤或层级。

## §2 两层结构

**工作台**(台账):`docs/active/handoff.md`(路径不动,D2)——只放**状态 + 指针**,≤80 行,只指不抄,知识住书架。字段骨架(状态头/目标/进度/下一步/**待晋升暂存**/**指针**/关键上下文/已知问题/**晋升声明 promotion:**/Evidence Depth/CI 阻断/context-chain 行)的**权威单源 = skill 捆绑模板** `.claude/skills/structured-handoff/handoff-template.md`(D3;`templates/handoff.md` 已删)。所有声明字段有显式初值(`promotion: 未核` / `- 无` / `[待填]`)——「空白即未做」判定集 = {缺失, 空白, [待填], 未核},不存在"没写=默认通过"的字段。覆写只走晋升门禁(§3),其固定序第①步把旧版归档至 `docs/completed/handoff-*.md`(snapshot 型,版本化兜底)。

**书架**(九格):愿景/需求/系统真相/决策史/标尺/干活规矩/行业认知/用户偏好/地图——**逻辑格映射现有住址,组件本体不动不迁移**(D1 零搬家)。两剖面住址表的权威 = AGENTS.md 九格住址表(根 AGENTS.md = 自仓库剖面带 harness/ 前缀;`templates/AGENTS.md` = 下游剖面)。

**生命周期三型**(每格在 AGENTS.md 表内标型):snapshot(覆写式,留版本化历史——台账)/ evolving(原地修订,owner 保鲜——governance/RUBRIC/preferences/目录卡/地图)/ immutable(只追加,**过时加横幅不删改**——decisions/、references/ 日期留痕、audits/、completed/)。

## §3 晋升门禁(工作台 → 书架的唯一通道)

权威全文 = `.claude/skills/structured-handoff/SKILL.md`(覆写台账的唯一正路)。**固定序不可换**:

1. **① 归档**:无条件 `cp` 旧台账到 `docs/completed/handoff-<时间戳>.md`(归档即"覆写信号";完成后不回滚)。
2. **② 清账**:对「待晋升暂存」区逐条**四裁决**——**上架**(写书架对应格 + 同批登记 + 台账指针区加行)/ **弃置**(随归档件保全,书架零污染)/ **顺延**(promotion 写 skipped,回收点 = 归档件路径,下会话回收再裁决)/ **阻塞**(中止覆写,promotion 当场写 阻塞(理由),其余原状)。含兜底一问("本会话有无该暂存未暂存的内容?")。晋升路由表(决策→decisions/、调研→references/、规矩级经验→governance(走 meta-review,允许顺延跨覆写)、项目事实→ARCHITECTURE/模块 README、偏好→preferences.md)住 SKILL 清账节。
3. **③ 覆写**:按模板单源重写台账;promotion 按文法写终态;暂存归零 `- 无`。
4. **④ 自查**:`wc -l` ≤80(超限砍序 = 先砍散文,**指针与声明字段不砍**;砍尽仍超→允许超限并声明);正文无 `[待填]` 残留;路径真实;无敏感信息。

**promotion 凭证文法**(一行声明,四态:未核 / 已核(上架: 路径...; 弃置: N 条) / skipped(理由; 回收) / 阻塞(理由),+ 空账合法形 `已核(上架: 无; 弃置: 0 条)`):**权威三处同文法同名无别名**——SKILL「promotion 声明文法」节(整行 ERE 在此)= handoff-template.md `promotion:` 行 = check-handoff.sh `GRAMMAR` 变量。锚点凭证设计:已核必带可 `test -f && test -s` 的上架路径(空话格式无路径段被文法拒);references/ 锚点再交叉核目录卡登记行;token 全半角(全角=不命中=未做)。「阻塞」是合法中间态(非终态),解除后重走门禁。

**两道闸分开命名分开落地**:

- **「空白即未做」**(形式闸,机器核):初值制度 + check-handoff 的文法/锚点/空账/回收点机械校验(Stop 模式与 --reconcile 对账模式共用同一 GRAMMAR,见 §6/§7)。
- **「没讨论清楚不放行」**(实质闸,AI 核,凭证制度+对抗审查兜底):清账逐条四问——关键问题是什么 / 讨论到什么程度 / 有无影响下游的未决点 / 下游能否照此干活。松紧梯度:探索期顺延合法;收口与治理/方向类从严,方向/原则级条目列选项请用户拍板。

**蒸馏判据**(上架前一问):「下个功能还需要它吗?」——否 → 弃置。**预算枯竭不逼回写**:走 skipped+回收点,书架零仓促污染。

**防遗忘四层谱**(强度排序,论证住旧 spec):①同批耦合 > ②机器闸 > ③凭证制度 > ④版本化兜底——**纯纪律不算保障**(日后改机制时的承重判据)。

## §4 书架登记

- **落库即登记**(通用规矩,权威全文住目录卡头部 `docs/references/README.md`):凡向 references/ 写入**带日期前缀**(`YYYY-MM-DD-<slug>.md/.html`)留痕件,**同一批动作**(同一回复/同一 commit)在目录卡条目表加一行;行文法与过时横幅文法均住目录卡头部(一行引用: `| 日期 | 文件 | 一句话 | 核验等级 |`;`> ⚠️ 过时(YYYY-MM-DD): 原因,替代 -> 路径`)。执行端耦合:research-scout 产出整形红线含此条(`.claude/agents/research-scout.md:60`)。
- **无前缀标准件豁免**(文件名约定即类型声明,住目录卡「命名约定」节):带日期前缀 = 调研留痕(immutable,须登记);无前缀(如 DESIGN_TEMPLATE.md)= 标准件(evolving,owner 保鲜,豁免登记,发现链走地图行)——setup.sh 分发的 5 个标准件即此类,下游装机零告警。
- **decisions/ 文件名即卡**(D13):`ls docs/decisions/` 的日期+slug 即索引,零额外登记动作;判断拐点另 append `docs/decision-trail.md`(既有义务)。
- **执法两道时点分明**:每 Stop 软扫(check-shelf-registry.sh,未登记 stderr 点名,**永不阻断**;目录卡缺失时 stderr 内嵌最小模板——下游首次落库自建目录卡的格式权威)+ 交叉核(check-handoff 内,references/ 锚点查登记行——Stop 模式覆写信号窗内为**硬核 exit 2**;--reconcile 对账为**全时核,点名不阻断**)。

## §5 入口地图与开场规程

**AGENTS.md ×2**(D10/D14,入 A 组):运行时中立的第 0 步地图——两层结构声明 / 接手顺序(本文件→台账→顺指针→目录卡/决策目录→CLAUDE.md)/ 九格住址表(+生命周期型)/ 硬规矩一行引用 / 手工校验命令。**共享核同批改**(双写义务,与 M3↔M17 同款);剖面差异:

- **根 AGENTS.md**(自仓库):住址带 `harness/` 前缀;加 meta 治理指向行(根 CLAUDE.md scope 分流)与导航行("实物在 harness/ 下");对账行含第三条命令 `check-meta-review.sh --reconcile`;格 8 = `harness/docs/preferences.md`。
- **templates/AGENTS.md**(下游分发):单层 `docs/...` 住址;格 8 写"不随 harness 分发——使用者个人层;可自建"并内嵌最小条目文法句;对账行只引两条手工校验命令(meta 件不分发)。

**M3 会话开场规程**(根 CLAUDE.md「会话开场规程」节,权威全文住那里)——两步:① **装载**(读台账,按需顺指针补读本体);② **对账**(三条命令核上次收口凭证 + 欠账处置,见 §6)。另有 M3「上下文层地图行」节:指向根 AGENTS.md(含双写义务声明)与 preferences.md(含 D11 口径)。

**M4**(`harness/CLAUDE.md` 下游模板):核心规则 11 = "会话开场先装载再对账……欠账先补再开新工作(会话链自执法)";文档索引表含 AGENTS.md 行与交接行注"覆写经晋升门禁";Skill 表 structured-handoff 行注门禁四步。

**scope 治理触点**(自仓库;M17 `.claude/hooks/meta-scope.conf` ↔ 根 CLAUDE.md §3/§5 人读表双写同步):上下文层件全部入 meta scope——A 组含 `AGENTS.md` / `docs/preferences.md`(D14/D11),C 组 glob `.claude/skills/*/*.md`(D15,捆绑模板=契约本体),F 组含 `templates/*.md`;改这些件机械触发 meta-review(批 1 audit 实证:受控触碰 handoff-template.md+templates/AGENTS.md → check-meta-review exit 2 双点名)。

## §6 会话链自执法(C 案——现行执法哲学)

权威 = `docs/decisions/2026-06-11-session-chain-reconciliation.md`(三案并排,用户拍板 C 案)。核心:**下一个会话是必然发生、不可绕、天然独立上下文、看得见全部已提交历史的卡点——会话链自己当执法链**,取代常驻守门人接线(A 案落空、B 案不取)。指令层(CLAUDE.md/AGENTS.md,每会话必在场、跨运行时)扛"知道做什么";编排+验收扛"做对"(实证:批 1 全程 hook 未通电、纯软承载,批级三挑战者审查 0 Critical)。**对账只读凭证不读流水**(promotion 一行/目录卡一行一件/audit covers 头/git log oneline;干净时增量 <10 行上下文)——凭证制度本就按"一眼可核"设计,对账就是那个下游。C6 执法时点错位被对账**吸收**(对账读已提交历史,天然 commit 感知;吸收非消失,残余见 §10)。

**三条对账命令**(M3 规程内联;改命令形态时注意三处拷贝同改,见 §10):

1. `bash .claude/hooks/check-handoff.sh --reconcile` — 台账凭证全时核(文法/锚点/登记交叉核/空账判定 + 状态判据)
2. `echo '{}' | bash .claude/hooks/check-shelf-registry.sh` — 落库登记扫
3. `bash .claude/hooks/check-meta-review.sh --reconcile` — 已提交 scope 改动的 audit 覆盖核(自仓库专属,meta 件不分发)

欠账处置:缺 audit → 按 M2 补 meta-review;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账。**欠账先补再开新工作**。

**check-handoff --reconcile**(追记③落地):**纯状态判据,零时钟**(不看 mtime/时钟/窗口)——
- `未核 × 归档件存在` → 状态告警"上次覆写可能未走门禁";`未核 × 无归档件` → 新台账合法;
- `已核 × 无归档件` → 状态告警"凭证不自洽"(已核蕴含归档已发生——对偶判据);
- 已核 → 锚点抽查+登记交叉核+空账判定全时执行;skipped → 回收点 test -f;阻塞 → 提示先解除;
- 归档件选取按**文件名字典序**(名内含时间戳,真零时钟;fresh clone 后 mtime 同刻不可靠);
- 无台账 → 一行提示 exit 0(Stop 模式既有「无台账+活跃 plan → exit 2 先建台账」行为不变;权威=脚本);
- 恒输出一行状态结论 + **恒 exit 0**(工具箱:输出给 AI 读,处置靠 AI,不阻断)。

**check-meta-review --reconcile**:扫已提交历史(git log)中命中 scope.conf glob 的文件,对照有效 audit covers 并集;**失效锚 = audit 自身最后 commit time**(未提交/未跟踪 audit 才 mtime 兜底;covered 文件最新 commit time ≤ audit commit time → 有效,同 commit 打包判有效);窗口:显式天数参数 → `--since`,缺省 → 仓库最新**已提交** audit 的 commit time(无已提交 audit → 30 天前);handoff 的 skip 字段**不豁免**已提交欠账;账齐带计数/欠账逐文件点名;恒 exit 0。根级文件(根 CLAUDE.md/AGENTS.md)经 `<root>/` sentinel 进对账(复用 §5.5 逻辑形态)。

## §7 hook = 工具箱(定位)

**手工模式为正身**:全部脚本以 stdin JSON + exit code 为唯一界面,`echo '{}' | bash .claude/hooks/check-X.sh` 即手工核账(空 stdin 不静默跳过,全部检查照跑;降级 exit 0 仅限工具缺失);`--reconcile` 两件直跑不读 stdin。换运行时丢的只是"自动触发",不丢"可校验性"(AGENTS.md 手工校验节即此声明)。

**自仓库无接线**(追记①,2026-06-12 撤除):`harness/.claude/settings.json` 已删——理由 ①"cd harness 增强路径"会把 M4 分发模板当会话指令加载(独立于 hook 的缺陷),增强收益名存实亡;②撤后自仓库单一体制(永远工具箱模式),少一条双轨困惑与受审面(用户原话: "不撤现有 hook 和 settings 接线,不一定。")。hook 脚本与下游分发**完全不受影响**;自仓库的 Stop 自动执法不存在,执法走 §6 开场对账 + finishing 流程 + meta-review。

**下游经接线自动触发**(增强层):`templates/settings.json` 是下游 settings 唯一来源——SessionStart=session-init.sh(注入入口地图行+台账全文,≤80 行超限照注+stderr 提示;SETUP_NEEDED 提示不中断;其余既有注入段不变);Stop=check-handoff.sh / check-shelf-registry.sh / check-evidence-depth.sh / check-context-chain.sh;PostToolUse=prettier+check-module-docs.sh。

**60 分钟窗 = 自动 Stop 模式限噪器**(仅此定位,追记③):Stop 每会话末必触发,无窗会对历史归档反复索债;窗内 = 覆写信号在场 → 硬核 promotion(exit 2 带修法引导);超窗不硬核——由 --reconcile 开场对账(全时核)兜。**F1 假点燃重定性为良性**(追记③):git clone/worktree 刷新归档件 mtime 误燃覆写信号,但台账 v2 后 clone 拿到的必是已提交状态、必带合法 promotion,检查空转通过;"git 时间锚"修法撤案(用户判定与 mtime 同为时间邻近代理,原话: "其实一个性质,有点不上不下")。

其余工具箱成员现状:check-evidence-depth(feature 收口闸,双层探测已补)/ check-context-chain(下游活链校验,自仓库无 docs/context/ 即静默——dogfood 边界不动)/ check-module-docs / session-init(双层探测+例外形不退出)/ check-meta-review、check-meta-cross-ref(meta 件,前缀过滤不分发)。所有脚本自含双层探测样板不抽公共件(D17:单文件可独跑是跨运行时硬前提)。

## §8 偏好层(D11)

`docs/preferences.md` = 用户协作偏好的**仓内权威住址**(九格之"用户偏好");AI 个人记忆(memory/)是缓存镜像,冲突以仓内为准;过时条目标注不删。权威 = `docs/decisions/2026-06-10-preferences-scope-membership.md`(✅ A,2026-06-11 用户拍板):

- **入 A 组 meta scope**:改动机械触发 meta-review(偏好治理上当规范同等对待);
- **审查口径 = 忠实性**:对照用户原话锚点核转述不走样,**不评判偏好本身**(feedback_read_dont_judge_user 红线);用户原话直录可走 skip 字段轻路径;
- **不分发下游**(个人层跟人;下游可自建,templates/AGENTS.md 格 8 给最小文法句);
- **条目文法**(住 preferences.md 头部注释):`- [YYYY-MM-DD] <偏好一句话>(原话: "<逐字引录>"[; 来源: <feedback 文件名>])`——日期+原话引录是硬字段(忠实性审查的锚点);
- **[日期不详] 升格规则**(2026-06-11 用户拍板,文法注释内):有原话但考证不出日期者以 `[日期不详]` 升格入「条目」。

现状:4 条已入仓(用户挨个审查拍板,含条 4 例外补回)+ 6 条「待补原话」候选(补上逐字引录后升格)。

## §9 分发(setup.sh 清单要点)

权威 = `setup.sh` 本体。要点:

- **活文件守卫**(已存在不覆盖):`docs/active/handoff.md`(初始台账从模板单源复制)/ `AGENTS.md` / `docs/product-specs/index.md` / `docs/context/{README,L1-vision,L2-INDEX}.md`(批 0 audit F1 扩展);`CLAUDE.md` 已存在需交互确认才覆盖。
- **前缀过滤**(旧 spec §8.3 所称 D12 = M14 命名前缀过滤;与 §11 决策表的 D12「任务出生证预留」**撞号**,信源原编号如此,两处不同义):`meta-*` / `check-meta-*` hooks 与 `meta-*` governance 不分发(meta 治理仅自仓库)。
- **AGENTS.md**:分发 `templates/AGENTS.md`(根 AGENTS.md 是自仓库剖面,不分发);**M3(根 CLAUDE.md)不分发**,分发的是 M4 `harness/CLAUDE.md`。
- **偏好不分发**:preferences.md 不在 cp 清单(D11)。
- **目录卡不分发**:references/README.md 不在 cp 清单——下游首次落库时同批自建,格式权威由 check-shelf-registry.sh stderr 内嵌最小模板承载(消除自举循环);分发的 5 个 references/ 标准件(MODULE_DOC_TEMPLATE/DESIGN_TEMPLATE/multi-agent-review-guide/testing-standard/challenger-orientation)无日期前缀,豁免登记,装机零告警。
- **settings**:`templates/settings.json` 是下游唯一来源(自仓库无接线,§7);`templates/handoff.md` 已删(D3 单源化)。

## §10 残余风险与 known gaps(诚实清单)

> 信源:C 案 decision「残余风险」节(+追记修正后的形态)、旧 spec 六处显式机器测不到缺口、ROADMAP「上下文层重构」节「批 1 留痕待办」块(**活信源,evolving**——本节是快照,以 ROADMAP 为准跟进)。

**设计已接受的边界**(decision 残余风险节):

| # | 缺口 | 兜底/触发器 |
|---|------|------------|
| 1 | 无痕跳过(什么都不写不归档)任何检查测不出 | 归档前置 + git 兜底(接受的边界) |
| 2 | 连入口文件都不加载的运行时,指令层失效 | 该环境 hook 同样不存在;文件本身可考古 |
| 3 | 对账本身是指令,依赖下一会话遵从 | 多级兜底:finishing 也核、meta-review 也核、git 永远在;C 案不烧接电的桥(接电随时可补;F1 已重定性良性,详 §7) |
| 4 | audit 对账窗口是 C6 时间窗变体:欠账滑出窗且连续多会话不对账 → 机器不再点名 | finishing/meta-review/git 考古兜(注:台账侧对账已是纯状态判据无窗口,追记③;本条余 check-meta-review 侧) |

**机器测不到的覆写/登记缺口**(旧 spec B1/B2/B6/B18/B19/B20,显式声明非已解决):漏记(没写的东西测不出,SKILL 兜底一问+归档考古兜)/ 锚点非空但低质(hook 不判内容,对抗审查兜)/ 不归档直接覆写(git 兜)/ stale-已核(照抄上轮声明,审查抽查 git log 兜)/ 留痕件漏日期前缀(research-scout 红线+目录卡盘点兜)。B19(超窗静默)改形:Stop 模式仍超窗不硬核,但 --reconcile 全时核接住"下一会话有对账"的链路;残余 = 既不触发 Stop 也不跑对账的窗口。

**留痕待办**(ROADMAP「批 1 留痕待办」逐条压缩;触发器以 ROADMAP 原文为准):

- SETUP_NEEDED 自仓库恒命中且建议有害(照跑 /project-setup 会污染分发源)+ stderr 可见性未实证——真实使用观察后裁决,候选自仓库剖面豁免
- check-context-chain 把 templates/context/README.md 内 code-fence 示例当真节点 → 下游假断链(前置问题)
- M4「架构」段指向 `docs/decisions/2026-04-16-fork-flat-refactor.md` 未分发 → 下游悬空引用(前置问题)
- check-handoff 锚点核 `-f`→`-e` 收紧候选;I5 软扫 maxdepth 1 与 I4 硬核含子目录的深度不对称(硬严于软,方向安全)
- preferences:6 条待补原话候选未升格(注:ROADMAP 该行部分已过时——条 4 例外与升格规则已随挨个审查落地)
- --reconcile 优化候选:「有效 audit M 份」全史计数与近窗 N 并列易误读;性能 O(audit×covers) 线性涨(现 ~35s/次);窗口起点输出裸 epoch
- M3 规程内联命令 × 根 AGENTS.md × templates/AGENTS.md 构成第三份拷贝,无显式双写声明——改 hook 路径/调用形态时三处同改
- 开场对账无机器可判"干净/欠账"信号(恒 exit 0,by design;若实践出现"读了不补"再议升级)
- M1/M2 内「缺 audit 由 Stop hook 检出/兜底」表述未注 C 案条件性(撤接线后自仓库无自动 Stop)——touch M1/M2 时顺带补注
- check-handoff 对账/Stop 分支 body 解析约 130 行近重复(文法 ERE/空账判定已单源,字段抽取未)——改抽取逻辑两处同改;拼错参数落 Stop 模式会挂 stdin
- QUICKREF/README 全树导航重构维持缓刑(事实性错误部分已修)
- F1 假点燃观察期:开场对账真实使用留痕(meta-L4);若实战观察到假点燃反例再议(重定性详 §7)

**既有声明缺口**(根 CLAUDE.md §5):全新建未 git add 的根级文件(根 CLAUDE.md/AGENTS.md 同款)走 untracked 漏检,入库后消失。

## §11 决策索引(只列结论与住址,不复述论证)

旧 spec §7.1 D1-D17(论证住旧 spec)——现行有效性逐条:

| # | 结论(一行) | 现状 |
|---|------------|------|
| D1 | 九格 = 逻辑格映射现有住址,零搬家 | ✅ 有效 |
| D2 | handoff 路径不动(`docs/active/handoff.md`) | ✅ 有效(引用 129 处零断链,批 1 audit 实核) |
| D3 | 台账模板单源化到 skill 捆绑资源;templates/handoff.md 删 | ✅ 有效 |
| D4 | 门禁挂 SKILL 覆写流程(正路)+ Stop 覆写信号硬核 | ✅ 有效(Stop 侧自仓库无自动触发,见 §7) |
| D5 | 覆写信号 = 最新归档件 mtime 60 分钟窗 | ✅ 有效,定位收窄为自动模式限噪器(追记③) |
| D6 | meta 路执法与 evaluation-result 解耦 | ✅ 有效 |
| D7 | 登记执法 = 每 Stop 软扫 + 覆写信号硬交叉核 | ✅ 有效(Stop 侧自仓库无自动触发,见 §7) |
| D8 | 10 分钟硬闸废除 → 24h 软提醒 | ✅ 有效 |
| D9 | hook 上岗 A/B 两案兼容(双层探测) | ⚠️ 接线分叉被 C 案**取代/消解**;双层探测交付物保留(手工模式从根 cwd 跑通的前提) |
| D10 | AGENTS.md 两份(自仓库根 + templates) | ✅ 有效 |
| D11 | preferences.md 入 A 组(忠实性口径/不分发) | ✅ 有效(详 §8) |
| D12 | 任务出生证接口预留 = 单源模板 + D15 机械触发 | ✅ 有效(口子 B 未启动) |
| D13 | decisions/ 文件名即卡 | ✅ 有效 |
| D14 | AGENTS.md 入 A 组 scope | ✅ 有效 |
| D15 | C 组 glob 覆盖 skill 捆绑资源(`.claude/skills/*/*.md`) | ✅ 有效(批 1 audit 实证 exit 2 双点名) |
| D16 | 规矩级暂存条目允许顺延跨覆写 | ✅ 有效 |
| D17 | 双层探测样板逐脚本自含,不抽公共件 | ✅ 有效 |

C 案 decision(`docs/decisions/2026-06-11-session-chain-reconciliation.md`,2026-06-11 用户拍板):

- **C 案主体**:会话链自执法(开场对账)取代常驻守门人接线;hook 降级工具箱——取代旧 spec §8.4「hook 上岗接线」行与 plan 原任务 20-23(原文见 git 258b96e)
- **追记①**(2026-06-12):撤自仓库 `harness/.claude/settings.json` 接线(decision 正文「不做」第 1 条作废)——自仓库单一工具箱体制;下游分发不受影响
- **追记②**:任务级审查结论立「登记簿」规矩——批级 audit「挑战者执行记录」节逐任务一行;规矩落 M2 §7.5.1
- **追记③**:F1 重定性(误燃良性)+ 时间锚修法撤案 + 60 分钟窗仅作限噪器 + check-handoff 增 --reconcile 纯状态对账
- **追记④**:spec 取代方式 = 新 spec 整体取代(本文件即其落地);旧 spec 加横幅转考古层,活指针切本文件

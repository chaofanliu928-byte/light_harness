# Roadmap

> **工作哲学**:harness 是**边做边提升**的工具 — 不预设固化的"未来阶段"作为计划。具体做什么由实际需求 / 用户原则确立 / 当前发现拉动。已完成的 P-1 / P0 / P0.5 / P0.9.1 都不是预设的,都是边做边发现下一步。
>
> 依据:`memory/feedback_iterative_progression.md`(2026-04-28 用户原则确立)+ `docs/decisions/2026-04-28-iterative-progression-no-fixed-roadmap-stages.md`

> 与 PROGRESS.md 的区别:PROGRESS.md 是已完成里程碑(只追加),ROADMAP.md 是当前在做 + 已识别下一步(会重写)。
> 与 decisions/ 的区别:decisions 记录"为什么这么决定 + 替代方案",ROADMAP 记录"当前在做什么"。scope 级变更先写 decision 再改 ROADMAP。

---

## 已完成阶段(概要,详情推 PROGRESS / decisions/)

- **P-1**:Handoff residual 字段清晰化(独立小改)
- **P0**:测试覆盖纳入 harness(L1 + L2 + L3 串行;L4 不做 — 见 `decisions/2026-04-15-testing-scope-expansion.md`)
- **P0.5**:fork 嵌套扁平化改造(P1 验证暴露的应急前置 — 见 `decisions/2026-04-16-fork-flat-refactor.md`)
- **P0.9.1**:meta-review 流程 + scope 识别 + hook 执法(2026-04-28 — 见 `PROGRESS.md` + `meta-review-2026-04-28-102359-p0-9-1-self-review.md`)
- **活上下文链(L1-L6 脊柱)**:分发下游的分层活上下文文档系统 + 同会话质量批(审查 bug 修复 + 孤悬剪枝)(2026-06-05 — 见 `decision-trail.md` 顶部 + audit `meta-review-2026-06-05-204125-living-context-chain-spine.md`)
- **上下文层重构(档位二)**:工作台/书架两层 + 晋升门禁 + 书架登记 + 入口地图 AGENTS.md×2 + 偏好层 + 会话链自执法(开场对账,hook 降级工具箱)(2026-06-11,23 任务 — 见下方「上下文层重构」节 + decisions/2026-06-11-session-chain-reconciliation.md + 三份批级 audit)

---

## 当前在做

### P0.9:harness self-governance(根源级)

**背景**:2026-04-17 起草 5 条治理修改 M0-M4 时识别 harness 反复打补丁的根源 — 三条结构性缺陷(治理文本缺执法层 / bootstrap 缺陷 / 马鞍定位错位)。详见 `docs/decisions/2026-04-17-harness-self-governance-gap.md`。

**已完成**:
- 🟢 **P0.9.1**(2026-04-28):meta-review 流程 + scope 识别 + hook 执法。29 commits。audit verdict=pass after revision。

**已识别下一步**(由 P0.9.1 落地暴露,非预设):

- **P0.9.1.5 — M0-M4 启动**(用户决定型,D20 fix-7 = B):**整体闭合**(2026-04-29)
  - 🟢 **M0**(2026-04-28 完成):删 block-dangerous hook — 首个 trial,验证 P0.9.1 治理流程从 brainstorming → meta-review → finishing 跑通(audit `meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`)
  - 🟢 **M1+M2+M4**(2026-04-28 brainstorming / 2026-04-29 meta-review fork 完成):治理改动 batch — 第二个 trial(audit `meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md`,decision `2026-04-28-m1-m2-m4-governance-batch.md`);finishing-rules.md 加 M1 封死简化收尾 + M2 RUBRIC 不作跳过依据;design-rules.md 加 M4 轻量级判定第 4 列前置硬条件 + spec §0 偏离规则段 + 默认升级原则 + M2 互引;DESIGN_TEMPLATE.md L14 同步;13 处 meta-review 修订;P0.9.1.5 第二个 meta-L4 数据点
  - ⚪ **M3 drop**(2026-04-28):报告 #1 已解决(security-scan-result.md §方向评估第 7 项检查 + §通过 Step 9 删除,职责不同) + #2 超 scope(structured-handoff skill 分工属 C 组,推 P0.9.2 实战观察)
- **P0.9.2 — 诊断流程**:实战观察期累积数据后启动
  - 反审字段重置 enforcement(C2 P-4)
  - D5 / D.2 字节软上限 enforcement(C2 P-3)
  - mixed scope 双 finishing 成本量化
  - decision-trail meta-L4 验证(append 频率 / 提取质量 / 调度者忽略率)
  - **harness self-trial 验证局限**(2026-04-29 audit §9.4 #5):下游真实项目首次使用 finishing-rules.md 时采集
  - **反模式段膨胀分类治理**(2026-04-29 audit §9.4 #8):2→4 条扩张后是否需要数量门槛
  - **挑战者有效性元疑问 D5 场景频率**(2026-04-29 audit §9.4 #9):first-pass 全 pass 无 finding 时是否需 D5 元验证
  - **M3 #2 若重现** — structured-handoff skill 分工(scope=C 组)
- **P0.9.3 — governance 漂移检测兜底**:
  - 🟢 **第一个 trial 闭合**(2026-04-29):**(vii) M3 hook 不可见 + cross-file 互引 hook 检测**(audit `meta-review-2026-04-29-150902-p0-9-3-governance-drift-batch.md` verdict=pass-after-revision 4+2 挑战者,decision `2026-04-29-p0-9-3-governance-drift-detection-batch.md`);7 commits;5 文件改动(2 改 + 2 新建 + 1 settings)
  - 🟢 **第二个 trial 闭合**(2026-04-30 ~ 2026-05-06):**D 类技术债 batch — D1(M3/M4 路径混淆)+ D4(PAIRS 覆盖度 2/4 → 6/4 全覆盖)**(audit `meta-review-2026-05-06-143426-d-class-tech-debt-batch.md` verdict=pass-after-revision 4 挑战者 3 Important + 9 Minor,decision `2026-04-30-d-class-tech-debt-batch.md`);13 commits;~36 行 hook + governance 改动 + sentinel 协议 documented(M2 §7.3 第 5 条)。**额外**:D5(`.gitignore` 精确化 + 11 historical untracked 治理文件入仓)单独 commit `0e8283d`
  - ⏸ 现有 fix-9 (i)(ii) 占位等 P0.9.2 实战数据(`feedback_judgment_basis`)
  - ❌ ~~现有 fix-9 (iv)(vi)~~:已 accept 关闭(spec §5 B18 + decision `2026-04-26-bypass-paths-handling.md`),ROADMAP 误登
  - decision-trail hook 校验(若 P0.9.2 显示频繁忽略)
  - 🟡 **主仓库 ↔ 下游版本漂移检测**(B 方案):用户接受现状,主动需求弱;留候选不做
  - ❌ ~~M3/M4 路径混淆~~ 已闭合(第二个 trial,2026-04-30)
  - 🟡 **D 类残留**(D2 untracked / D3 anchor 写死 / D6 case 子串包含):YAGNI 接受不修(详 decision `2026-04-30-d-class-tech-debt-batch.md` §不做)

### 上下文层重构(✅ 2026-06-11 全部完成:批 0 + 批 1 + 会话链自执法批,23 任务;2026-06-12 挨个审查驱动 C 案补完批)

> **现行版 spec:`specs/2026-06-12-context-layer-design.md`**(2026-06-12 整体取代 2026-06-10 版,追记④;旧版带 ⚠️ 横幅转考古层)

**背景**:方向讨论(随模型变强减脚手架)→ 文献地图×3 + 脚手架对照 + handoff×知识库三案对抗分析(见 `docs/references/2026-06-10-*` 系列)。用户已定:模型无关(跨运行时)、档位二(工作台/书架两层+晋升门禁)、防遗忘靠机制不靠纪律、落库当场登记通用规矩、建 AGENTS.md、偏好层入仓。

**进展**:设计锁定(2026-06-11,`specs/2026-06-10-context-layer-design.md`,四轮审查;锁定后微修正 ×2)→ 实现计划入库(`plans/2026-06-11-context-layer.md`,23 任务/6 批组)→ 🟢 **批 0 完成**(2026-06-11:bugfix 三件,commits a34290e/8333e39,audit `meta-review-2026-06-11-135802-context-layer-batch0.md` verdict=pass-after-revision;known-gap F1 由计划任务 18 接住)→ 🟢 **批 1 完成**(2026-06-11:任务 4-18,工作台门禁(模板单源/SKILL v2/check-handoff v2)+书架登记(目录卡回填 8 件/check-shelf-registry/research-scout 红线)+入口与偏好(AGENTS.md×2/preferences.md 用户拍板 4 条+6 待补/CLAUDE.md 地图行)+分发与 scope(conf 四 glob/settings 双轨(双轨后撤,2026-06-12 追记①)/setup 分发清单+删 templates/handoff.md);每任务两段审查,批级 audit `meta-review-2026-06-11-182559-context-layer-batch1.md` verdict=pass-after-revision,3 挑战者)。→ 🟢 **会话链自执法批完成**(2026-06-11:C 案——用户第一性重审取代 hook 上岗 A/B,详 docs/decisions/2026-06-11-session-chain-reconciliation.md;--reconcile 对账模式 54996f8+e7fe564、开场规程四处 6f5f0a6、留痕 86cca24+4385330;批级 audit `meta-review-2026-06-11-222130-session-chain-reconciliation.md` verdict=pass)。**后续观察期**:开场对账真实使用留痕(meta-L4)、上表留痕待办按触发器逐件处置。

**批 1 留痕待办(会话链自执法批与后续,来源=批 0/1 audit 与任务级审查):**
- F1 假点燃重定性(2026-06-12,decision 追记③):台账 v2 后误燃为**良性**(clone 拿到的必是已提交状态,必带合法 promotion,检查空转通过);60 分钟窗仅作自动 Stop 模式限噪器保留;时间锚修法**撤案**(用户判定:与 mtime 一个性质,不上不下);手工对账已走纯状态判据(check-handoff --reconcile,未核×归档件=覆写未走门禁/已核×无归档件=凭证不自洽);若实战观察到反例再议
- SETUP_NEEDED 自仓库恒命中且建议有害(照跑 /project-setup 会污染分发源占位符)+ 提示走 stderr 的可见性未实证——会话链自执法批后真实使用观察;候选自仓库剖面豁免
- check-context-chain 把 `templates/context/README.md` 内 code-fence 示例 upstream 当真节点 → 下游日 0 假断链告警(前置问题,任务18 审查发现)
- M4「架构」段指向 `docs/decisions/2026-04-16-fork-flat-refactor.md` 未分发 → 下游悬空引用(前置问题)
- check-handoff 锚点核 `-f`→`-e` 收紧候选(批0 audit 观察①,维持 Minor);I5 软扫 maxdepth 1 vs I4 case 含子目录的深度不对称(references/ 现无子目录,硬严于软方向安全)
- preferences.md:✅ 两 Minor 已处理(2026-06-12 用户挨个审查拍板:条 4 例外补回 + [日期不详] 升格规则入文法注,commit af45787);余 6 条待补原话(用户随时口述即升格)
- QUICKREF/README 导航缓刑部分解除:hook 行/skill 行/关键文件行已随批 1 finishing 同批修正(事实性错误部分);全树/导航重构仍按未触及备忘缓刑
- --reconcile 后续优化候选(任务 20 审查 I2/I3/N2):「有效 audit M 份」计数是全史口径与近窗 N 并列易误读;性能 O(audit×covers) 随 audit 数线性涨(现 ~35s/次,可合并为单次 git log 遍历);窗口起点输出裸 epoch 人读不友好
- M3「会话开场规程」内联的两条手工校验命令与根 AGENTS.md「手工校验」节构成第三份拷贝,无声明的同步义务(任务 21 审查 Minor)——改 hook 路径/调用形态时记得三处同改;后续可补显式双写声明
- 开场对账无机器可判的"干净/欠账"信号(--reconcile 恒 exit 0,by design:hook=工具箱,处置靠 AI 读输出)——若实践中出现"读了不补"再议升级
- ✅ M2 Stop hook 兜底表述已补 C 案条件注(2026-06-12,§3.2 两处);M1 §4.2 示例为 spec fix-4 锁定逐字件**不动**——其语义在接线环境(下游)仍真,自仓库口径由 M2 注 + 现行版 spec §7 承载
- check-handoff --reconcile 观察项(补完批件 4 审查):对账与 Stop 分支的 body 解析约 130 行近重复(文法 ERE/空账判定已单源,字段抽取未)——将来改抽取逻辑记得两处;拼错参数(如 --reconcil)落 Stop 模式会挂 stdin(与 check-audit-coverage 同族继承,交互场景注意)

**本轮重审范围**(系统已变 → 逐件三问裁决:问题还在吗/新机制承载吗/什么形态;不预设"修复上岗"):
- 8 个 hook + settings 接线(对抗审查实证:自仓库根启动会话从未加载 hook——"天然无 hook 实验"数据见 `references/2026-06-10-handoff-kb-integration-analysis.md` 地基事实 1)
- structured-handoff SKILL(新设计重写对象)、project-setup SKILL
- 治理文件中交接/收口相关节(finishing-rules 收口硬核链、meta-finishing Step D 等)
- 纯 bugfix 不待裁决照修:setup.sh 覆盖活 handoff、SKILL `[待更新]` 死条件、模板双写分叉

**未触及组件备忘(本轮不动,后续可能重审)**:
- skills/agents:design-review、evaluate、security-scan、process-audit、system-design/designer、research-scout
- 治理:brainstorming/design/planning/implementation/testing/review-rules、meta-review/meta-finishing(除交接触点)、synthesis-rules
- 标准件:RUBRIC、DESIGN_TEMPLATE、testing-standard;分发:setup.sh 清单机制(除 bugfix)、M4 模板、QUICKREF/README 导航
- 重审触发候选:ultracode 让渡决策(材料已备:`references/2026-06-10-scaffold-vs-ultracode-map.md`)、下次模型/运行时大变化、上下文层落地后的连带触点

**外部参考输入**:用户提供的 16 步交付技能(外部项目 `_参考规则/skills/sixteen-step-delivery`)的机制库——读取凭证(证据锚点,"只写已阅读不算证据")/ 状态初值制度(空白=not-started 不得当通过)/ 三态准入(proceed/blocked/assumption-ready)/ 分流留痕(UGR/SCP/DCR+传播记录)/ 过程记录同步门禁。借机制模式不借官僚密度,逐个过简洁性反问。

### 治理同层化(✅ 2026-06-13 批 1-5 完成)

> **现行版 spec/decision:`specs/2026-06-13-governance-single-layer.md` + `decisions/2026-06-13-governance-single-layer.md`**

**进展**:治理同层化批 1-5 完成(取代 P0.9.1 双轨结构——scope 分流机器拆除,凭证参数化 credentials.conf/credentials-rules 取代 meta-* 体系;"治理改动必须被审查留凭证"不变量保留)。

**观察项(spec §10.2-i / decision 2026-06-13 追记三;2026-06-13 收口用户拍板处置)**:
- 治理批暂无机器安全扫——hook 脚本危险操作面 / AI 指令文本注入面在治理批暂无机器扫(安全扫描/流程审计维持 feature 侧,decision 2026-06-13 追记三);触发器:实战出险或用户重启。**收口审查曾建议给核心 hook 逻辑改动加"手动挂一次 security-scan"硬兜底 → 2026-06-13 用户拍板「不加」**(维持现状,触发器照旧)
- cross-ref 删除后互引断链单防线(审查触点完整性维)——**2026-06-13 用户认可:头几个治理批显式记录"三件套互引(finishing↔review↔credentials)核了没",攒几次实证再确认单防线够用**(收口审查方向评估/触点维建议,用户拍板纳入)

### review-scout 动态审查侦察(✅ 2026-06-15 实现 + 收口完成)

> **spec/decision:`specs/2026-06-13-dynamic-review-scout-design.md`(已锁,3 轮 design-review 收敛)+ `decisions/2026-06-13-review-scout-workflows-dir.md`(🟢 用户拍板保 A + Y)**

**进展**:给 design-review 增一条 **ultracode 专属**动态审查侦察路(ADD 并排,**不替换**现有固定 4 维 design-review;ultracode 不在场走现有路活备份)。scout agent 读上下文现推维(地板 2 维 方向盘对齐+自洽性 + 动态加 + skipped 强制留痕)→ workflow `parallel()` 一维一挑战者扇出 → 调度者综合。新引入 `.claude/workflows/` 目录(随 setup.sh 分发 + 纳 credentials.conf 凭证)。10 任务(wiring 4-10 逐任务 implementer+reviewer 两段审查)+ 收口治理审查 5 维(逮 A1🔴/A2🟡 workflow 读盘路径断链,修复 commit 36b7296)+ 方向评估 4/4 不推翻。audit `audit-2026-06-15-112342-review-scout.md` verdict=pass-after-revision,对账账齐。

**reframe 批(2026-06-15,用户指令)**:① **指令3 表述调整**——review-scout 作主推先讲、固定 4 维显式标"仅 ultracode/Workflow 不在场时执行的回落路"(framing-only,不退役老路/不重建 X/运行逻辑零改,守 Y);② **指令2 文档上游双写**——FloorTable(workflow.js 机读)↔ review-rules 地板维表注登记 credentials-rules §8 第 6 条(文档上游/代码派生)。audit `audit-2026-06-15-134910-review-scout-reframe.md` pass-after-revision(副作用维 needs-revision→术语桥 commit 2d97a11)。

**指令1 批(code-review-scout,✅ 2026-06-15 实现+收口完成)**:给 review-scout 扩展**代码审查**(reviewType='code'),fork-N 同形于设计审。新建 harness 侧 **code-review SKILL**(镜像 design-review 运行时分支:ultracode→review-scout 传 reviewType=code+diffRef / 不在场→回落 Superpowers requesting-code-review,**either-or 不叠加、不改包**);workflow.js 加 code 常量(`FloorTable.code` 3 维=方向盘对齐+简洁性+spec忠实性 / `CodeCandidateMenu` / `FLOOR_FOCUS_CODE`)+ 两 prompt 函数 reviewType 分支(**design else 逐字保留=行为零变**)。决策 D-C1=A(类型契约入候选)/D-C2(spec忠实性入地板、either-or)/D-C3=B(无门)/D-C4=A(接通-usable),`decisions/2026-06-15-code-review-scout-decisions.md`。10 任务 subagent-driven(workflow.js 契约优先 commit + 6 独立文件并行,各 implementer+reviewer)+ 收口 9 挑战者(5 治理审查 + 4 方向评估)**全 pass、零🔴零🟡**。**design 路逐字零变 node 双版本渲染 byte-identical 实证**;守 Y 三处零改(design-reviewer.md/synthesis L153 维序/design-rules.md);双写逐字同序 + CLAUDE×2 字节一致 + 新 skill 五处登记。audit `audit-2026-06-15-192631-code-review-scout.md` verdict=pass,对账账齐。

**观察项(收口 audit 副作用维 + 方向评估收敛;非阻断,接线/后续批处置)**:
- **FloorTable code/governance 两行预填**:"覆盖三类"只需 reviewType 参数化 + design 一行真数据,留口 ≠ 必须预填两行维名;且 floor 维不带 challenger_focus → **接线 code/governance 时一并裁:两行维名是否预填 + 同步补 FLOOR_FOCUS 对应 focus**(否则 `challengerPrompt` 对其传 undefined focus)。spec §7.3 已接受当前 3 行形态,本轮不动。
- ✅ **地板维表机读镜像显性化(2026-06-15 reframe 批 指令2 已解)**:FloorTable↔review-rules 地板维表注登记为 credentials-rules §8 第 6 条双写对,两处加"文档上游/代码派生"注。
- ✅ **全量「活备份」→「回落」术语统一(2026-06-15 backlog 批 实质完成)**:活治理文档(review-rules/synthesis/CLAUDE)reframe 批已统一无残留;剩余"活备份"全在锁定 spec(2026-06-13,术语桥 D13 兜)+ 记录文件(audits/completed/PROGRESS/ROADMAP/decision-trail/plans/2026-06-13)——按 R12 不追溯,零 churn 即正确收尾。audit `audit-2026-06-15-215413-review-scout-backlog.md`。
- **诚实认知上提**:"非 ultracode 路痛点未解 / ultracode 普及前主流路径净增益≈0 / 自仓库 dogfood 审不到自己主打痛点"——spec §7.3 已散见,建议作一句话结论上提 decision/handoff 可见处,免误判"review-scout 已解决固定 4 维痛点"。
- **退化失败模式 meta-L4 实战观察**(spec §6):scout 是否退化成"只加固定维集(按类:design/code 地板/候选)同集"(换汤不换药)/ 加维是否真带 `why_this_time` 原文锚点——落地(ultracode 在场)实战观察。**code 路同样适用**(指令1 批 B-8 诚实标注已泛化两路)。
- ✅ **credentials-rules §8 候选菜单类双写收紧(2026-06-15 backlog 批 已解)**:§8 加第 7 条登记 DesignCandidateMenu/CodeCandidateMenu↔review-rules 候选注双写对;workflow.js 两常量派生注 + review-rules 两候选权威注两侧对称;review-rules L33 code 双写注 §8 指针拆为第 6 条[FloorTable]+第 7 条[CodeCandidateMenu]。audit `audit-2026-06-15-215413`。
- ✅ **code-review-scout spec 3 勘误(2026-06-15 backlog 批 已解)**:§4.1(3) focus 伪码对齐等价实现 / §3.1 menu 2-way→只留 3-way 权威终态 / §5.1 ARCHITECTURE.md "无"→"存在但模板占位";连带 workflow.js `FLOOR_FOCUS_CODE['架构合规']` focus 同步(模板占位也跳过=修运行时噪音,spec↔workflow.js 复字节一致)。audit `audit-2026-06-15-215413`。
- **(指令1 批观察)README L150 代码审查行未提 ultracode scout 路** = spec §8.2 已声明有据豁免(README 不分发下游 + 与设计审查行对称缺席 + 分发模板 CLAUDE×2 已同步);cleanup 候选。
- 低优先:奖励项"活备份不丢能力"措辞可降为边界澄清(避免把"没动现状"记成正收益);spec 内"design-reviewer.md 零关系"重复 7+ 处可收敛单一权威段 + 指针。

### 已识别但搁置

> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本段保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。

- **codex 接入**(11 swap 角色 — `model-route.md` §4):
  - 实现链路 4:designer / planner / implementer / testing
  - 审查链路 7:silent-failure-hunter / 设计自检 / design-review 4 挑战者 / code-reviewer / evaluate 非关键 / security-scan 危险 / security-scan 注入
  - 不 swap 6:调度者 / evaluate 关键 / security-scan 凭证 / meta-review / process-audit / 综合阶段
  - 现状:0% 落地(实施层 swap 配置未进 `.claude/{agents,skills,hooks}/`);plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝(实证)
  - 保留作日后基线:`model-route.md` / `synthesis-rules.md` P2 段 / `planning/implementation/testing-rules.md` 顶部引用 / `p0-9-4-self-check.md` §C/§G3/§G4/§F2
  - **不预设重启时间 / 启动条件 / 触发信号**(`feedback_iterative_progression` 硬约束)

### P2:可观测性 — 双层(2026-04-28 立 + 同日 reframe glassbox 角色)

让 harness 治理过程可见、可审计、可回溯。**空间 + 时间双层**,两层归属不同:

**空间维度(session 内)— glassbox(用户级外部工具,harness 推荐不分发)**
- 现状:外部仓库 https://github.com/chaofanliu928-byte/glassbox(7 类 HTML 页面 + lint 工具)
- **harness 角色**:仅推荐 + 链接记录(`docs/references/recommended-tools.md`)+ setup.sh 末尾 echo 提示;**不**做 submodule / 不 clone / 不锁版本 / 不集成 API
- **用户角色**:自行决定装哪、装啥版本、装在哪(建议 `~/tools/glassbox/` 等全局位置)
- **harness 治理流程不依赖 glassbox 在场**(不装也能正常工作)
- decision:`docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md`

**时间维度(跨 session)— decision-trail(项目内置)**
- 已落地:`docs/decision-trail.md`(2026-04-28 引入)
- 自动化:M5 + M1 双路径 finishing 时 append
- decision:`docs/decisions/2026-04-28-decision-trail-introduction.md`

**当前状态**:已落地基础形态,边用边迭代。后续提升由实际使用反馈拉动,不预设。

---

## ROADMAP 自身的生命周期(元规则)

- **完成的 P 项** → 概要保留 + 详情推 `PROGRESS.md`(只追加)
- **决策记录** → 存在 `docs/decisions/`(不和 ROADMAP 混写)
- **ROADMAP 自身保持滚动**:scope 级变更**先写 decision 再改 ROADMAP**,不得反向
- **不预设未实现的"未来阶段"**:不写"P1 真实项目迁移"/"L4 回归层"/"测试 surface 扩张"等(违反"边做边提升"原则);具体动作由"做的过程"暴露后再加

---

## 与 Superpowers 的耦合边界(事实层,不是计划)

- L1 tests 档位的实际执行依赖 `superpowers:test-driven-development`
- L2 治理规则与 Superpowers TDD 流程互补,不替代
- **耦合风险**:Superpowers 升级若改 TDD skill 接口,L1 判定可能失效;若出现不兼容,短期 fallback 是 evaluator 手动判断不依赖 Superpowers 接口

## 术语与定义归属(事实层)

- Evidence Depth L1-L4 + CI 阻断 语义在 `docs/references/testing-standard.md` 中定义(**术语 SSoT**)
- 其他引用该术语的文件(RUBRIC / finishing-rules / handoff 模板 / evaluator 提示词)**只引用不重复定义**
- 术语变更必须先改 testing-standard.md,再同步下游(F3 文档先行)

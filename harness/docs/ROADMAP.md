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

### 上下文层重构(2026-06-11 批 1 完成,当前会话链自执法批 任务 20-23)

**背景**:方向讨论(随模型变强减脚手架)→ 文献地图×3 + 脚手架对照 + handoff×知识库三案对抗分析(见 `docs/references/2026-06-10-*` 系列)。用户已定:模型无关(跨运行时)、档位二(工作台/书架两层+晋升门禁)、防遗忘靠机制不靠纪律、落库当场登记通用规矩、建 AGENTS.md、偏好层入仓。

**进展**:设计锁定(2026-06-11,`specs/2026-06-10-context-layer-design.md`,四轮审查;锁定后微修正 ×2)→ 实现计划入库(`plans/2026-06-11-context-layer.md`,23 任务/6 批组)→ 🟢 **批 0 完成**(2026-06-11:bugfix 三件,commits a34290e/8333e39,audit `meta-review-2026-06-11-135802-context-layer-batch0.md` verdict=pass-after-revision;known-gap F1 由计划任务 18 接住)→ 🟢 **批 1 完成**(2026-06-11:任务 4-18,工作台门禁(模板单源/SKILL v2/check-handoff v2)+书架登记(目录卡回填 8 件/check-shelf-registry/research-scout 红线)+入口与偏好(AGENTS.md×2/preferences.md 用户拍板 4 条+6 待补/CLAUDE.md 地图行)+分发与 scope(conf 四 glob/settings 双轨/setup 分发清单+删 templates/handoff.md);每任务两段审查,批级 audit `meta-review-2026-06-11-182559-context-layer-batch1.md` verdict=pass-after-revision,3 挑战者)。当前:会话链自执法批(任务 20-23,C 案——2026-06-11 用户第一性重审取代 hook 上岗 A/B,详 docs/decisions/2026-06-11-session-chain-reconciliation.md;任务 20/21 已落:--reconcile 对账模式 54996f8+e7fe564、开场规程四处 6f5f0a6)。

**批 1 留痕待办(会话链自执法批与后续,来源=批 0/1 audit 与任务级审查):**
- F1 假点燃已降级(C 案):自动触发不在场;手工对账会跑到 check-handoff,误触发=误报不阻断;加固候选保留,若未来接电先修(decision「不做」节口径)
- SETUP_NEEDED 自仓库恒命中且建议有害(照跑 /project-setup 会污染分发源占位符)+ 提示走 stderr 的可见性未实证——会话链自执法批后真实使用观察;候选自仓库剖面豁免
- check-context-chain 把 `templates/context/README.md` 内 code-fence 示例 upstream 当真节点 → 下游日 0 假断链告警(前置问题,任务18 审查发现)
- M4「架构」段指向 `docs/decisions/2026-04-16-fork-flat-refactor.md` 未分发 → 下游悬空引用(前置问题)
- check-handoff 锚点核 `-f`→`-e` 收紧候选(批0 audit 观察①,维持 Minor);I5 软扫 maxdepth 1 vs I4 case 含子目录的深度不对称(references/ 现无子目录,硬严于软方向安全)
- preferences.md:条 4 压缩掉「除非他明确要我挑错」例外待补;「有原话无日期」升格路径未定义——**用户挨个审查偏好条目时一并处理**(批1 任务14 审查 Minor)
- QUICKREF/README 导航缓刑部分解除:hook 行/skill 行/关键文件行已随批 1 finishing 同批修正(事实性错误部分);全树/导航重构仍按未触及备忘缓刑
- --reconcile 后续优化候选(任务 20 审查 I2/I3/N2):「有效 audit M 份」计数是全史口径与近窗 N 并列易误读;性能 O(audit×covers) 随 audit 数线性涨(现 ~35s/次,可合并为单次 git log 遍历);窗口起点输出裸 epoch 人读不友好
- M3「会话开场规程」内联的两条手工校验命令与根 AGENTS.md「手工校验」节构成第三份拷贝,无声明的同步义务(任务 21 审查 Minor)——改 hook 路径/调用形态时记得三处同改;后续可补显式双写声明
- 开场对账无机器可判的"干净/欠账"信号(--reconcile 恒 exit 0,by design:hook=工具箱,处置靠 AI 读输出)——若实践中出现"读了不补"再议升级

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

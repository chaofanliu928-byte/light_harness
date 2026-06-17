# 已知坑索引(按场景可查)
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->

> 这是什么:harness 散在 ROADMAP / decision-trail / audit / handoff / spec 各处的"已知坑 / 技术债 / 观察项 / 搁置项",汇编成一份**按场景/区域可查**的索引。解决"坑散四处,写码·调试时拿不到'这块已知有坑没'"的发现性问题。
>
> 怎么用:**进某场景前先查对应分组**(改 setup.sh → 查「分发」组;改治理文件 → 查「治理」组;调 hook → 查「hook 跨运行时」组……)。每条给一句话 + 生命周期 + 是否影响自仓库开发 + 来源指针 + 严重度;**细节看来源,本索引只指不抄**。
>
> 维护:① 发现新坑 → 加一行(必带真实来源指针,读源实证,不臆造);② 坑解了 → 在**来源文档**改正,本索引**同批**把生命周期改 `✅已关闭`(留行便对照,不删);③ `affects_harness_dev` = 这条坑是否影响开发 harness 自身(很多坑只在下游分发后才咬,自仓库 dogfood 碰不到)。本索引是活文档,用 Step 1 freshness 机制(frontmatter owner/last-reviewed)保鲜。
>
> 生命周期取值:**待办**(已识别该修、未排期或未做)/ **搁置**(主动决定暂不做、留基线)/ **观察期**(机制已上线、等实战数据判断)/ **✅已关闭**(已解,留索引便对照)。
> 严重度:🔴高 / 🟡中 / ⚪低。

---

## 场景:改 setup.sh / 分发链(上下游)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| 主仓库 ↔ 下游版本漂移检测(B 方案)未做:下游 clone 后无法机器检测自己落后主仓库多少 | 搁置 | 否 | ROADMAP.md「P0.9.3」节(🟡 用户接受现状,主动需求弱,留候选不做) | 🟡 |
| setup.sh 漏发新文件 = 下游断链的常发模式:历史已两次咬(research-scout.md 漏发 / freshness-scout.md 漏发);改 setup.sh 加新 agent·workflow 时必须同步加 cp 行 | ✅已关闭(各自批已修) | 是 | decision-trail.md 2026-05-29「push 前核查」(KG-F)+ audit-2026-06-16-183410-health-fixes.md §3(freshness-scout 已补 cp) | 🔴(模式仍需警惕) |
| check-context-chain 把 `templates/context/README.md` 内 code-fence 示例 upstream 当真节点 → 下游日 0 假断链告警 | 待办 | 否 | ROADMAP.md「批 1 留痕待办」段(任务 18 审查发现,前置问题) | 🟡 |

## 场景:改 governance 治理文件 / 凭证·对账

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| 治理批暂无机器安全扫:hook 脚本危险操作面 / AI 指令文本注入面在治理批无机器扫(安全扫描·流程审计维持 feature 侧);收口审查曾建议给核心 hook 改动加"手动挂一次 security-scan"硬兜底,**用户 2026-06-13 拍板「不加」** | 搁置(用户拍板接受现状) | 是 | ROADMAP.md「治理同层化」观察项 + decision-trail.md 2026-06-13 拐点 | 🟡 |
| cross-ref 删除后互引断链单防线:三件套互引(finishing↔review↔credentials)漏改只靠"审查触点完整性维"兜,无机器闸 | 观察期(攒几次实证再确认单防线够用) | 是 | ROADMAP.md「治理同层化」观察项(用户 2026-06-13 认可:头几批显式记录"互引核了没") | 🟡 |
| credentials §8 各拷贝组 / 对账三命令(check-handoff/check-shelf-registry/check-audit-coverage)散落多处:改 hook 路径·调用形态时须多处同改,无声明的同步义务点易漏 | 待办(可补显式双写声明) | 是 | ROADMAP.md「批 1 留痕待办」段(任务 21 审查 Minor:M3 开场规程内联命令与根 AGENTS「手工校验」节构成第三份拷贝) | 🟡 |
| D 类技术债残留:D2 untracked / D3 anchor 写死 / D6 case 子串包含 —— YAGNI 接受不修(实战暴露面接近 0) | 搁置(YAGNI 接受) | 是 | ROADMAP.md「P0.9.3」节 + decision-trail.md 2026-05-06「D 类技术债 batch」(decision `2026-04-30-d-class-tech-debt-batch.md §不做`) | ⚪ |
| 反审字段重置 enforcement(C2 P-4)/ D5·D.2 字节软上限 enforcement(C2 P-3):四项 P0.9.2 enforcement 待实战观察期数据后才启动 | 搁置(等 P0.9.2 实战数据) | 是 | ROADMAP.md「P0.9.2」节 | ⚪ |
| 反模式段膨胀分类治理:finishing-rules 反模式段 2→4 条扩张后是否需数量门槛,待数据 | 搁置(等 P0.9.2 数据) | 是 | ROADMAP.md「P0.9.2」节(2026-04-29 audit §9.4 #8) | ⚪ |
| 挑战者有效性元疑问 D5 场景频率:first-pass 全 pass 无 finding 时是否需 D5 元验证,待数据 | 搁置(等 P0.9.2 数据) | 是 | ROADMAP.md「P0.9.2」节(2026-04-29 audit §9.4 #9) | ⚪ |
| harness self-trial 验证局限:自仓库 dogfood 审不到下游真实使用面;finishing-rules 等的下游首用数据须在真实项目采集 | 搁置(等下游真实项目数据) | 是(=自仓库验证不到的盲区) | ROADMAP.md「P0.9.2」节(2026-04-29 audit §9.4 #5)+ memory `feedback_realworld_testing_in_other_projects.md` | 🟡 |
| FloorTable↔review-rules 地板维表注双写漏改风险(文档上游/代码派生):曾因 reframe 显性登记为 credentials §8 第 6 条而关闭 | ✅已关闭(2026-06-15 reframe 批) | 是 | ROADMAP.md「review-scout 动态审查」观察项(已解条)+ audit-2026-06-15-134910-review-scout-reframe.md | ⚪ |

## 场景:hook / 跨运行时(awk·bash 可移植性)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| **check-audit-coverage.sh `extract_covers` 用 gawk 三参数 match 扩展语法 → 非 gawk 环境(mawk/busybox/BSD awk)解析失败 → 该 audit 视为不贡献 covers(注:旧 handoff 抄成"死锁",已纠正,实为解析失败)** | 待办(历史遗留,独立待办,本文件不修不扩散) | 是 | `.claude/hooks/check-audit-coverage.sh` 头注 L39-41 + handoff.md「已知问题」段 | 🟡 |
| `--reconcile` 后续优化候选:全史「有效 audit M 份」计数与近窗 N 并列易误读;性能 O(audit×covers) 随 audit 数线性涨(~35s/次);窗口起点输出裸 epoch 人读不友好 | 待办(优化候选,非阻断) | 是 | ROADMAP.md「批 1 留痕待办」段(任务 20 审查 I2/I3/N2) | ⚪ |
| 对账与 Stop 分支 body 解析约 130 行近重复(字段抽取未单源):将来改抽取逻辑须两处同改 | 待办(将来改时注意) | 是 | ROADMAP.md「批 1 留痕待办」段(补完批件 4 审查) | ⚪ |
| 拼错参数(如 `--reconcil`)落 Stop 模式会挂 stdin(check-audit-coverage / check-handoff 同族继承):交互场景注意 | 待办(交互场景注意) | 是 | ROADMAP.md「批 1 留痕待办」段(补完批件 4 审查) | ⚪ |
| check-handoff 锚点核 `-f`→`-e` 收紧候选;I5 软扫 maxdepth 1 vs I4 case 含子目录深度不对称(references 现无子目录,硬严于软方向安全) | 待办(收紧候选,Minor) | 是 | ROADMAP.md「批 1 留痕待办」段(批 0 audit 观察①) | ⚪ |

## 场景:workflow / agent(review-scout·审查)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| review-scout 退化失败模式 meta-L4:scout 是否退化成"只加固定维集(换汤不换药)"/ 加维是否真带 `why_this_time` 原文锚点 —— 须 ultracode 在场实战观察(design 路 + code 路同适用) | 观察期(等 ultracode 在场实战数据) | 否(自仓库 dogfood 审不到自己主打痛点) | ROADMAP.md「review-scout 动态审查」观察项(spec §6) | 🟡 |
| 非 ultracode 路原始痛点未解:动态推维仅 ultracode 路兑现;ultracode 普及前主流路径净增益≈0;自仓库 dogfood 审不到自己主打痛点(建议作一句话结论上提 decision/handoff,免误判"已解决固定 4 维痛点") | 搁置(诚实承认的边界,非 bug)+ 建议上提 | 是(自仓库默认走回落 4 维) | ROADMAP.md「review-scout 动态审查」观察项 + decision-trail.md 2026-06-15「动态审查侦察」缺口承认段 | 🟡 |
| FloorTable code/governance 两行预填 vs 留口:接线 code/governance 时须一并裁"两行维名是否预填 + 同步补 FLOOR_FOCUS 对应 focus"(否则 `challengerPrompt` 对其传 undefined focus);spec §7.3 已接受当前 3 行形态 | 待办(接线 code/governance 时裁) | 是 | ROADMAP.md「review-scout 动态审查」观察项 + audit-2026-06-15-112342-review-scout.md §4(副作用丙 F1) | 🟡 |
| review-scout meta-L4 已有**正向**数据点:freshness 批 design-review dogfood 中 scout 现推维未退化(保留地板 2 + 跳过 2 候选 + 现推 2 专属维,后者抓出真 🔴)——记录便后续趋势对照 | 观察期(正向样本,持续累计) | 否 | ROADMAP.md「知识系统 backlog Step 1」节 + audit-2026-06-16-163954-freshness-mechanism.md §4 | ⚪ |
| workflow.js fork 读盘路径前缀断链(scout 读 review-scout.md / FLOOR_FOCUS RUBRIC / challengerPrompt orientation 硬编码裸 docs/):产出方传 targets ↔ 消费方实际 Read 字节级不一致 | ✅已关闭(36b7296 已修) | 是 | audit-2026-06-15-112342-review-scout.md §5(A1🔴+A2🟡 收口修复)+ decision-trail.md 2026-06-15 | ⚪ |
| README L150 代码审查行未提 ultracode scout 路 = 有据豁免(README 不分发 + 与设计审查行对称缺席),cleanup 候选 | 待办(cleanup 候选,有据豁免) | 否 | ROADMAP.md「review-scout 动态审查」观察项(指令1 批) | ⚪ |

## 场景:上下文层 / 交接·台账(handoff)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| SETUP_NEEDED 自仓库恒命中且建议有害(照跑 /project-setup 会污染分发源占位符)+ 提示走 stderr 可见性未实证 | 待办(候选自仓库剖面豁免) | 是 | ROADMAP.md「批 1 留痕待办」段 | 🟡 |
| M4「架构」段指向 `docs/decisions/2026-04-16-fork-flat-refactor.md` 未分发 → 下游悬空引用 | 待办(前置问题) | 否 | ROADMAP.md「批 1 留痕待办」段 | 🟡 |
| 开场对账无机器可判的"干净/欠账"信号(`--reconcile` 恒 exit 0,by design:hook=工具箱,处置靠 AI 读输出)——若实践出现"读了不补"再议升级 | 观察期(by design,出现"读了不补"再议) | 是 | ROADMAP.md「批 1 留痕待办」段 | ⚪ |
| preferences.md 余 6 条待补原话(用户随时口述即升格)| 待办(等用户口述) | 是 | ROADMAP.md「批 1 留痕待办」段(2026-06-12 用户挨个审查后) | ⚪ |
| QUICKREF/README 全树/导航重构仍按未触及备忘缓刑(事实性错误部分已随批 1 修正) | 待办(导航重构缓刑) | 是 | ROADMAP.md「批 1 留痕待办」段 | ⚪ |

## 场景:文档健康 / 反腐烂(freshness·漂移)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| **漂移腐(文档↔代码不一致)检测留 Step 2**:freshness Step 1 只做时间腐+孤儿腐轻组合,强检测(挂文档↔代码)是 ★ 设计层到手边的活,现无 hook 机械查双写对/漂移点,全靠人工"触点完整性维" | 待办(知识系统 ③b,进行中方向) | 是 | ROADMAP.md「知识系统 backlog Step 2」节 + decision-trail.md 2026-06-16 + handoff.md「关键上下文/下一步」 | 🟡 |
| **ARCHITECTURE.md 自仓库仍空模板**(已加 owner=调度者 frontmatter 标签,待用户填或标"故意留空") | 待办(待用户填) | 是 | ROADMAP.md「知识系统 backlog Step 1 观察项」+ `docs/ARCHITECTURE.md`(L9 仍为"根据你的项目自定义"示例占位) | 🟡 |
| freshness 90 天阈值实战标定:误报/漏报/刷屏感未经实战;初值待调 | 观察期(等实战标定) | 是 | ROADMAP.md「知识系统 backlog Step 1 观察项」+ decision-trail.md 2026-06-16(D-1~D-9) | 🟡 |
| 子智能体每次开场 fork 的成本未实战观察;`.claude/agents`·`.claude/skills` 增量采纳推进中 | 观察期(等实战观察) | 是 | ROADMAP.md「知识系统 backlog Step 1 观察项」 | ⚪ |
| 知识/偏好/规则三者边界糊(偏好硬化成规则 / 决策隐含规则 / memory 拍平三者),边界厘清随 Step 2 真案例解,不单独前置 | 待办(随 ★ 真案例解) | 是 | ROADMAP.md「知识系统 backlog Step 2」+ `references/2026-06-16-knowledge-system-what-to-preserve.md §C` | ⚪ |
| drift-scout.md 硬编码「13 触点」计数(L2/L24/L48/L146)随注册表增行变 stale:C「设计层到手边」加 TP-14/15 后注册表 15 行;drift-scout 检测 count-agnostic(L85-87 不依赖 13)功能不受影响,但 illustrative 计数过时。用户 2026-06-17 拍板**单独一批**改 count-agnostic 措辞(那批触 drift-scout 自走 covers,C 本批按 spec §10.1「零改」不动 drift-scout) | 待办(单独一批,count-agnostic 化) | 是 | `docs/superpowers/plans/2026-06-17-design-context-delivery.md` T7 + `.claude/agents/drift-scout.md` L2/L24/L48/L146 + 用户 2026-06-17 拍板 | ⚪ |

## 场景:decision-trail / 记录维护

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| decision-trail 修剪到期:不淘汰旧条目,1 年累积 30-50 条后头部信息密度衰减;**6 月后旧条目移 `docs/audits/archive/decision-trail/YYYY-HN.md`**(P0.9.1 仅声明策略,首次归档待后续触发) | 待办(归档策略已声明,首次未触发) | 是 | decision-trail.md「已知缺口」段(修剪策略) | ⚪ |
| decision-trail meta-L4 验证(append 频率/提取质量/调度者忽略率)+ 若调度者频繁忽略则考虑加 hook 校验 | 搁置/观察期(等 P0.9.2 数据) | 是 | ROADMAP.md「P0.9.2」节 + decision-trail.md「已知缺口」段(meta-L4 验证延后)| ⚪ |

## 场景:codex / 模型路由(搁置基线)

| 坑(一句话) | 生命周期 | affects_harness_dev | 来源指针 | 严重度 |
|---|---|---|---|---|
| codex 接入 0% 落地:11 swap 角色实施层 swap 配置未进 `.claude/{agents,skills,hooks}/`;fork 子任务维持全 Claude;plugin-cc + codex 0.133.0 + ChatGPT 账户对 gpt-5.5 上游拒绝(实证);**不预设重启时间/条件/信号** | 搁置(留基线,feedback_iterative_progression 硬约束) | 否 | ROADMAP.md「已识别但搁置」节(`model-route.md` §4)+ decision-trail.md 2026-05-24「codex 接入搁置」 | ⚪ |

---

## 与其他书架的关系(本索引是导航/镜像,不是权威)

- 本索引**只指不抄**:每条坑的权威细节仍住**源文档**——
  - 抉择/搁置/否决方案 → `docs/decision-trail.md`(+ `docs/decisions/` 单条文件看完整推理)
  - 观察项/已识别下一步/留痕待办 → `docs/ROADMAP.md`(散在 P0.9.x / 上下文层批 1 留痕待办 / 治理同层化 / review-scout / 知识系统 backlog ≥4 段)
  - 审查发现的观察项/已知问题 → `docs/audits/<近几份>`
  - 当前会话级已知问题 → `docs/active/handoff.md`「已知问题」段
  - hook 自身的已知问题 → 该 hook 脚本头注(如 `check-audit-coverage.sh` L39-41)
- **避免双写腐**:坑解了 → 在**源文档**改正,本索引**同批**把生命周期改 `✅已关闭`(不删行,留作对照)。本索引不复制源文档的完整推理,只做发现性入口。
- **本文件类型**:references **标准件**(无日期前缀、evolving、owner=调度者 保鲜)→ 按 `references/README.md` 命名约定**豁免目录卡登记**(目录卡只登带日期前缀的留痕件);发现链走本索引导言 + freshness 机制,不进目录卡表。

# 触点机读注册表(touchpoint-registry)
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->

> 本表是 `credentials-rules.md` §8 双写同步义务清单的**机读派生形**——把散在 §8 散文的双写对 + 体检摸到的散落触点,结构化成一份机读表,给知识系统 Step2 ③b 漂移检测当喂料地基。③b(不管走 hook 还是 scout)从本表读"该查哪些端点、按什么判据判"。

## 这是什么 + 和 §8 的关系

- **是什么**:§8 是人读义务清单(谁和谁要同批改);本表是同一批触点的**机读镜像**——每条触点拆成 `端点 / 判据 / 来源 / 现状`,让 ③b 漂移检测无须解析散文即可消费。
- **§8 上游、本表派生**:`credentials-rules.md` §8 是**权威源**,本表是它的机读派生。**改触点先改 §8(若是双写义务)或改触点的源文件,再同步本表**——顺序不能反(防本表与 §8 各说各话)。
- **权威住源不抄(反双写腐)**:本表只登记"端点在哪、判据是什么",**不复制端点文件的内容**。判据细节、维名全文、glob 枚举的权威仍住各自源文件(§8 / review-rules / freshness-rules / credentials.conf)。本表是索引,不是副本。
- **MVP 边界**:本轮只建数据(注册表行),**不建检测**。所有行「现状」列统一标 `待③b查`;③b 跑起来后才回填 `✅一致` / `🔴漂移`。

## 注册表主表

> 列义:`id`=行标识 / `类型`=触点种类 / `端点`=参与同步的文件:锚(多端点分号或换行分隔) / `判据`=怎么判一致 / `来源`=§8 第N条或体检 / `现状`=③b 检测结论(本轮全待查)。
>
> **类型取值**:双写对 / 同核拷贝组 / 分发链 / 漂移点(spec↔代码)。
> **判据取值**:逐字一致 / 结构等价(允许路径前缀差异) / glob覆盖 / 存在性 / 单源派生一致。

| id | 类型 | 端点(文件:锚) | 判据 | 来源 | 现状 |
|---|---|---|---|---|---|
| TP-01 | 双写对 | `docs/governance/credentials-rules.md` §2 人读凭证要求表;`.claude/hooks/credentials.conf` 全部 glob 行 | 逐字一致(行序同序,glob 逐行一致) | §8 第1条 | 待③b查 |
| TP-02 | 双写对 | `docs/governance/review-rules.md`「审查维度选择表」治理行判定语;`.claude/hooks/credentials.conf` include glob | 单源派生一致(治理行判定语 = "命中 credentials.conf include glob",conf 为机器判据源) | §8 第2条 | 待③b查 |
| TP-03 | 双写对 | `<root>/CLAUDE.md`「凭证义务一句话」(blockquote 锚文本,勿用行号锚);`docs/governance/credentials-rules.md`(单入口存在性) | 存在性(根 CLAUDE.md 不复制类目枚举,只写"命中 credentials.conf 任一 include glob"+ 本件指针) | §8 第3条 | 待③b查 |
| TP-04 | 双写对 | `.claude/skills/design-review/SKILL.md` A/B/C 三段对抗式模板;`.claude/skills/evaluate/SKILL.md` A/B/C 三段 | 结构等价(A/B/C 三段同构,同批改) | §8 第4条 | 待③b查 |
| TP-05 | 同核拷贝组 | `<root>/CLAUDE.md` 会话开场规程对账三命令;`<root>/AGENTS.md`「手工校验」;`harness/templates/AGENTS.md`「手工校验」;`docs/governance/credentials-rules.md` §6 | 结构等价(四处同改对账三命令;允许路径前缀差异:自仓库带 `harness/`、下游去前缀) | §8 第5条 | 待③b查 |
| TP-06 | 双写对 | `docs/governance/review-rules.md` 设计行地板维表注(design/code/governance 三类维名);`.claude/workflows/review-scout.workflow.js` `FloorTable` 常量 | 逐字一致(三类维名逐类逐维一致;文档上游、代码派生) | §8 第6条 | 待③b查 |
| TP-07 | 双写对 | `docs/governance/review-rules.md` 设计/代码行候选菜单注(design:完整性/过度工程化;code:类型契约合规/架构合规/模块文档一致性);`.claude/workflows/review-scout.workflow.js` `DesignCandidateMenu` / `CodeCandidateMenu` 常量 | 逐字一致(菜单项逐字一致;文档上游、代码派生) | §8 第7条 | 待③b查 |
| TP-08 | 同核拷贝组 | `<root>/CLAUDE.md` 会话开场规程「开场新鲜度侦察」步;`<root>/AGENTS.md`「开场新鲜度侦察」节;`harness/templates/AGENTS.md`「开场新鲜度侦察」节 | 结构等价(三处同核步骤:fork freshness-scout / 三类问题 / owner 二分+routeTo / 全干净静默 / 推 last-reviewed / 需 agent 运行时降级;允许路径前缀差异) | §8 第8条 | 待③b查 |
| TP-09 | 分发链 | `setup.sh` cp 段(.claude/agents/* · workflows/* · skills/*/* · hooks/* · governance/*.md 复制行);命中 credentials.conf include glob 的对应工件文件 | glob覆盖(命中凭证 glob 的可分发工件都在 setup.sh 有对应 cp;体检逮到漏 freshness-scout 即此触点) | 体检2026-06-16 | 待③b查 |
| TP-10 | 同核拷贝组 | `<root>/AGENTS.md` 整体共享核(接手顺序/硬规矩引用/九格表结构);`harness/templates/AGENTS.md` 整体共享核 | 结构等价(共享核同批改;允许路径前缀差异:根版带 `harness/`、模板版下游裸路径) | 体检2026-06-16 | 待③b查 |
| TP-11 | 同核拷贝组 | `<root>/CLAUDE.md`(M3 自治理入口);`harness/CLAUDE.md`(M4 分发模板) | 结构等价(同被 `CLAUDE.md` 凭证 glob 覆盖;角色分离/二公设/治理表结构共享,M3 治理入口与 M4 模板各有侧重不逐字一致) | 体检2026-06-16 | 待③b查 |
| TP-12 | 漂移点(spec↔代码) | `docs/governance/freshness-rules.md`(范围清单/字段→kind 映射/owner→routeTo 单源权威);`.claude/agents/freshness-scout.md`(扫描判据/范围/取值域/出参) | 单源派生一致(freshness-rules 为权威上游,freshness-scout 各处重述均派生;改判据先改 freshness-rules) | 体检2026-06-16 | 待③b查 |
| TP-13 | 双写对 | `docs/governance/credentials-rules.md` §8 人读双写义务清单;`docs/governance/touchpoint-registry.md`(本表,机读派生) | 单源派生一致(§8 上游、本表派生;§8 增触点条须同步本表新增行,反之亦然) | §8 第9条 | 待③b查 |
| TP-14 | 漂移点(spec↔代码) | `docs/governance/design-context-map.md` 各业务模块行的设计背景住址指针列(接口契约/数据模型/模块边界/取舍决策/不变量约束/既知坑/业务规则索引/并发约束);各指针指向的设计文档/README/ARCHITECTURE/decisions/坑索引实际锚 | 存在性(地图住址指针指向的锚还在不在;指针失效=漂移) | 体检2026-06-17 | 待③b查 |
| TP-15 | 漂移点(spec↔代码) | `docs/governance/design-context-map.md` 各行成员文件 glob;被指向的实际业务模块代码文件成员 | 单源派生一致(地图 memberGlob 还覆盖不覆盖实际模块成员;成员漂移=地图边界腐化) | 体检2026-06-17 | 待③b查 |

## 维护

- **新触点登记顺序**:新触点先登 `credentials-rules.md` §8(若属双写义务)或确认其源文件,**再**同步本表新增一行。顺序不可反(§8/源为上游,本表为派生镜像)。
- **§8 ↔ 本表的一致兜底**:由 TP-13(本表自登记行)兜——③b 查**每条 §8 条目都映射到本表唯一一行**(覆盖/子集判据:§8 ⊆ 本表;本表另有体检来源行 TP-09~12 无 §8 对应,**不要求计数相等**)+ 逐条端点是否对齐。§8 新增条目而本表漏登 = TP-13 报漂移。
- **现状列回填**:本轮 MVP 全标 `待③b查`(只建数据,不建检测)。③b 漂移检测跑起来后,逐行回填 `✅一致`(端点同步)/ `🔴漂移`(端点失配,附差异指针)。

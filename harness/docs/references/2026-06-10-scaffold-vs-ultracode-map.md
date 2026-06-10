# 脚手架 vs ultracode 对照地图(2026-06-10)

> **性质**:事实地图(证据,非决定)。背景:用户提出方向"随模型变强减脚手架 — ultracode 已可实现部分脚手架功能,但更凸显逻辑和流程的重要性",本图为该方向决策提供逐组件事实基础。
> **产出方式**:25 agent 工作流 — 5 个分析员各读一组脚手架文件逐组件判覆盖度,每组 3 个视角反驳者(触发确定性/下游分发/流程知识)对抗审查,完整性挑刺员查漏后补充 1 轮(6 个遗漏组件)。反驳者修正已采纳并在表中标注。
> **判定口径**:"如果删掉该组件,只靠 ultracode 运行时(Workflow 工具:agent()/parallel()/pipeline()/JSON Schema 强制/对抗验证/评审团/loop-until-dry/worktree 隔离)+ 主 AI 即兴编排,功能是否还在" → full / partial / none。
> **姊妹文档**:[2026-06-10-literature-map-context-loops-docs-harness.md](2026-06-10-literature-map-context-loops-docs-harness.md)(外部文献地图,时间线张力与本图交叉印证)/ [2026-06-10-literature-map-llm-wiki-knowledge-org.md](2026-06-10-literature-map-llm-wiki-knowledge-org.md)(llm-wiki/知识组织文献地图)。

---

## 总结论(三层)

**约 60 个组件,无一判 full。**

1. **ultracode 真正覆盖(且更可靠)的:执行机器段落。** skills / agent 文件 / 治理文档里"怎么并行 fork N 个隔离挑战者、材料怎么嵌、格式不符重试、共识怎么裁决"的描述 — 其中相当部分本是给旧运行时打的补丁(扁平 fork 架构声明防嵌套失效、"单 turn 并行"约束防串行下发、"挑战者看不到你的上下文所以完整嵌入"类指令、"格式不符重试一次"),在确定性脚本编排下直接作废或被原生化做得更强。**已有目标形态样本**:`agents/research-scout.md` 已把执行让渡给运行时 deep-research,只留判断层(触发判据/问题界定/产出整形红线)。

2. **ultracode 完全不碰的四类剩余物**(全部 none/partial 结论稳定落在此):
   - **触发保障** — 事件自动触发、exit 2 阻断、零 token 常驻 vs ultracode 逐回合 opt-in、即兴、高成本。hooks 层与 ultracode 零交集,是互补不是替代。
   - **流程知识** — 审什么维度、什么算 critical、评分标尺、回退表、scope 路由、安全 pattern 库、迭代上限。运行时一概不带:"删文件后有机器没图纸"。
   - **跨会话状态** — handoff/audit 台账/评估分数趋势/decision-trail/活上下文链。workflow 结果一结束就蒸发。
   - **下游分发** — setup.sh 的全部意义是让不开 ultracode(或不用 Claude Code)的环境拿到这套约束。
   - 另一类贯穿性剩余物:**防绕过条款与认知公设**(反模式约束、spec §0 不得免审、凭证扫描永不可绕、prompt 中性化、"已对照用户原话") — 这些约束的对象恰是即兴编排的主 AI 自身,即兴在结构上不可能自带"约束即兴"的东西。

3. **一处方向性冲突**:ultracode 原生"多数票裁决"恰是 synthesis-rules 事后规则 3 明文禁止的从众判法(synthesis-rules.md:143)。"删治理只剩运行时"不只丢知识,部分默认机器行为与现有治理标准**相反**。

---

## 逐组件对照表

格式:`[machinery/logic/mixed | full/partial/none]`;"剩余物"列只写 ultracode 不覆盖部分的性质与要点。

### hooks 组(9 件 — 全部 none,与 ultracode 零交集)

| 组件 | 判定 | 剩余物(全部不覆盖) |
|---|---|---|
| session-init.sh | mixed/none | 会话启动必然注入(触发保障)+ handoff/评估/活跃设计的跨会话状态续接 + "起点上下文清单/占位符判据/阶段→治理映射"知识 |
| check-handoff.sh | mixed/none | Stop 必检+阻断;"活跃开发收尾交接 ≤10 分钟新鲜"规则 |
| check-module-docs.sh | mixed/none | 改代码文件必触发提醒;"文档第一公民"的机器执行点(提醒不阻断的剂量决策) |
| check-meta-review.sh | mixed/none | "meta 改动须有审查覆盖"核算+阻断;covers 失效账本(audit mtime vs commit time)是跨会话审查台账 |
| check-evidence-depth.sh | mixed/none | finishing 时 handoff 字段兜底执法(无论 handoff 怎么产生,缺字段就拦) |
| check-meta-cross-ref.sh | mixed/none | design↔finishing 6 条互引锚点契约的唯一机器执行点 |
| check-context-chain.sh | mixed/none | 软提醒(探索期)+硬收口(finishing)双道时机;"待定合法/静默断链非法"章法 |
| meta-scope.conf | logic/none | scope 边界机读权威源;删掉则 check-meta-review 静默降级、整条 meta 执法链失效 |
| settings.json(接线) | machinery/none | 事件→脚本确定性绑定本体;删掉则 7 个脚本全成死文件 |

### skills + agents 组(13 件 — 两层结构:SKILL 薄壳 + agent 厚知识)

| 组件 | 判定 | 被覆盖 / 剩余物 |
|---|---|---|
| system-design SKILL | mixed/partial | fork+自检+迭代循环被覆盖 / 10 条自洽检查项、停机规则(连续 2 次不过→人介入)、触发时机、落盘约定 |
| design-review SKILL | mixed/partial | 4 路并行扇出被覆盖 / 4 维选定、综合方法与通过标准、触发位置、结果持久化、M2 嵌入契约 |
| evaluate SKILL | mixed/partial | 评审团形态被覆盖 / 4 维+方向/代码分工、scope→evidence 路由、**分数趋势依赖跨会话持久化**、auto 触发 |
| security-scan SKILL | mixed/partial | 3 路扇出被覆盖 / 三领域划分、Critical 阻断政策、**凭证扫描永不可绕**(即兴无机制强制)、触发位置 |
| process-audit SKILL | mixed/partial | fork 1 审计员被覆盖 / 触发位置、"记录不修复"边界、**audits 历史对比的模式识别**(跨会话) |
| project-setup SKILL | logic/none | 无扇出机器 / 配置面契约、探测→确认顺序、lint hook 命令模板、"AI 推荐用户决定"角色边界 |
| structured-handoff SKILL | logic/none | 无扇出机器 / 交接模板 schema、归档约定、与 SessionStart 注入构成的跨会话闭环 — **删掉则跨会话连续性机制不存在** |
| agents/designer.md | logic/partial | 独立上下文出草稿被覆盖;扁平 fork 声明作废 / 规模分级设计深度、7 项交付自查(P-4 审计教训)、决策升级边界 |
| agents/design-reviewer.md | mixed/partial | 并行隔离+格式强制被覆盖更优 / 4 维约 30 条检查点、bootstrap 4 维禁删、对抗 persona、"已对照用户原话"防 spec_gap_masking |
| agents/evaluator.md | mixed/partial | 扇出+对抗-决策分离结构被覆盖 / 评分推导表/权重/阈值(定标可比性)、6 条人工介入信号、slop 检查清单 |
| agents/security-reviewer.md | mixed/partial | 扇出+工具扫描被覆盖 / 精选正则 pattern 库、分级政策、误报排除清单、AI 工作流威胁建模 |
| agents/process-auditor.md | mixed/partial | fork 形态被覆盖 / 10 项遵从检查、JSONL 路径考古知识、"记录不修复"防自循环 |
| agents/research-scout.md | mixed/partial | **目标形态样本**:执行已让渡 deep-research / 触发判据(可逆性×熟悉度,调度者判)、问题界定四要素、产出整形红线(不排名/流行度不当依据) |

### feature 治理组(7 文件 8 条 — 约九成内容是流程知识)

| 组件 | 判定 | 被覆盖 / 剩余物 |
|---|---|---|
| brainstorming-rules | mixed/partial | 调研执行侧(deep-research 委托)被覆盖 / 5 探查方向、需求确认清单模板、3 轮收敛保障、调研触发两轴判据、回退入口表(被反向引用,删了回退坐标系断) |
| design-rules | mixed/partial | fork designer+4 审查者扇出被覆盖 / 规模判断表+4 硬条件、逐节自检与 10 条全局自洽清单、4 审查维定义、迭代上限、**防绕过**(spec §0 偏离不得免审) |
| planning-rules | logic/none | 几乎无机器描述 / 契约任务先行排序、指令式/问题式分界、约束来源与粒度表 |
| implementation-rules | logic/partial | 最小变更等与模型默认行为重叠(覆盖来自模型基线非 ultracode) / **文档先行顺序(与模型默认"代码优先"相反)**、契约强制 import、回退判别表、"架构决策请用户定"越权防线 |
| testing-rules | logic/none | 无 / Evidence Depth 决策表、**双向校准**(防堆测试讨好评分)、SSoT 纪律 |
| review-rules | logic/partial | 简洁性维与默认 review 本能重叠 / RUBRIC 逐项+惩罚=critical、架构分层对照、类型契约三问、模块 README 一致性=critical |
| finishing-rules·scope 分流入口 | logic/none | 无 / meta/feature 双路由知识;"mixed 也走 meta"裁决 |
| finishing-rules·主流程 | mixed/partial | 3+4+1 三个 fork 团扇出+顺序编排被覆盖 / 门禁逻辑(Critical 阻断、audit 不影响分流)、三路分流处置差异、**反模式约束整段(专门对抗 AI 自我豁免,即兴恰是其对立面)**、decision-trail 写入边界 |

### meta 治理 + 跨阶段 + 两份 CLAUDE.md 组(21 条 — 16 none / 5 partial,反驳者修正后计数)

| 组件 | 判定 | 要点 |
|---|---|---|
| meta-review-rules §2 触发条件 | logic/none | scope 分类+与 scope.conf 双源同步契约+防自循环排除 |
| meta-review-rules §3 流程 | mixed/partial | 单 turn 并行/重试约束被原生化更强 / 模态分型选维逻辑、N 弹性判据、"audit 必产"硬约束 |
| meta-review-rules §4 调用契约 | mixed/partial | Schema 强制+token 预算覆盖格式/字节面 / prompt 内容构成知识(角色从哪取、维度从 §6 取) |
| meta-review-rules §5 运行时嵌入契约 | logic/none→**反驳者修正 partial**(字节软上限机器面被覆盖) | 主体不变:防下游污染分发卫生约束,边界 4 之外 |
| meta-review-rules §6 审查维度 | logic/none | 三段 pattern、bootstrap 4 维禁删、触点完整性维 — **整个 meta-review 的"审什么"内核** |
| meta-review-rules §7 audit 产物规范 | logic/none | 跨会话状态+M15 hook 机读契约(frontmatter/covers 字面比对) |
| meta-review-rules §8 audit 失效规则 | logic/none | 跨会话审查记录的时效核算语义 |
| meta-review-rules §9 handoff 字段 | logic/none | skip 必留痕、理由必非空的逃生通道纪律 |
| meta-finishing-rules §2-3 四步 | logic/none | 流程顺序+decision/ROADMAP/decision-trail 持久化义务+skip 权限边界 |
| meta-finishing-rules §4 meta evidence depth | logic/none | meta-L1~L4 档位评判知识 |
| meta-finishing-rules §5 字段汇总 | logic/none | 跨会话契约聚合视图(与 M2 §9 双写导航) |
| synthesis-rules 事前规则 | logic/none | prompt 中性化 4 条+fork 前意图识别 — 防的是**编排者自身**带倾向,运行时无机制约束 |
| synthesis-rules 事后规则 | mixed/partial(反驳者补:**亦是下游分发件**,下游无 ultracode 时覆盖为 none) | 评审团聚合形态被覆盖 / 综合标准本身;**多数票裁决与事后规则 3 直接冲突** |
| synthesis-rules 表达准则 | logic/none | 用户校准沉淀的沟通规范(feedback_talk_plainly 等) |
| model-route | mixed/none | codex 路由政策+回退预案(搁置中基线) |
| /CLAUDE.md(M3)§1 公设 | logic/partial | 对抗/评审团模式天然实现公设 1 的分离形态 / 公设作为**常驻**认知约束+默认拒绝反向规则+"没有东西要求主 AI 想起来用对抗模式" |
| /CLAUDE.md(M3)§2-5 路由 | logic/none | 治理路由总线 — 正是"主 AI 上下文里必须有的东西";删掉则连"存在 meta 治理"都不知道 |
| /CLAUDE.md(M3)dogfood 边界 | logic/none | 防误用边界决策留痕 — "约束即兴"的东西即兴无法替代 |
| harness/CLAUDE.md(M4)角色表+公设 | logic/partial | 同 M3 §1 / **下游可用性是本体**:随 setup.sh 进任意项目、每会话自动加载 |
| harness/CLAUDE.md(M4)索引+地图 | logic/none | 何时触发哪个审查、finishing 内三 skill 顺序 — 边界 1+2 不提供 |
| harness/CLAUDE.md(M4)核心规则+回退 | logic/none | 阶段门禁、回退判据、**用户授权边界(规则 3/7,即兴最易越过的线)** |

### 分发与标准件组(17 条;反驳者修正 3 处 partial→none)

| 组件 | 判定 | 要点 |
|---|---|---|
| setup.sh | mixed/partial→**修正 none(3 票一致)** | Bash 复制是 Claude Code 基础能力非 ultracode;安装发生在下游 shell,正是边界 4 场景 / 分发清单+分发边界规则(meta-* 不下发等) |
| docs/RUBRIC.md | logic/none | 评什么/档位/项目特定惩罚奖励项(人工持久工件)+权重哲学 |
| DESIGN_TEMPLATE.md | logic/partial→**修正 none**(与 RUBRIC 同标准:机制可承载内容≠内容被覆盖) | 9 节结构、40+ 自检问题、10 条交叉验证 — Schema 的"填什么" |
| multi-agent-review-guide.md | mixed/partial | 操作模式半边(并行/对抗/二轮验证/格式强制)被覆盖更强 / 维度切分框架、共识/分歧/**盲区登记**(多数票不覆盖)、对抗-决策分离边界、适用性判断(流程审计不适用对抗) |
| challenger-orientation.md | mixed/partial | 隔离+必填 section 强制被覆盖 / 各角色审查方法论、证据/严重度判定标准、JSONL 路径知识、**自取用户原话对抗调度者 framing 程序** |
| templates/settings.json(M19) | machinery/none | 下游事件执法:装完即生效,不依赖开 ultracode |
| templates/README.md | logic/none | 分发边界不变量维护知识;**发现漂移:写 Stop hooks 应为 2 个,实际注册 3 个** |
| templates/PROGRESS.md | logic/none | 跨会话历史账本+记录时机约定 |
| templates/product-specs-index.md | logic/none | 功能粒度项目地图(跨会话) |
| templates/handoff.md | logic/none | 会话间传递载体;字段与 hook 硬核耦合 — 没有它"会话内结论再多,下个会话归零" |
| templates/context/(L1/L2/README) | mixed/none | 机读依赖图(跨会话)+六层章法+软硬双道配合 |
| references/README.md | logic/none | 目录契约 |
| MODULE_DOC_TEMPLATE.md | logic/none | 模块文档标准+与 hook/evaluator 链路耦合 |
| testing-standard.md | logic/none | Evidence Depth 术语 SSoT — 删掉则多方对"L3"失去公共定义 |
| recommended-tools.md | logic/none | 工具立场+swap 边界(搜不出来的仓库立场) |
| 2026-05-22 self-check | logic/partial→**修正 none**(同标准问题) | 检查项清单+日历式触发+持久化要求;**发现:§J 引用的 retrospective-guide.md 全仓库不存在** |
| README.md(dist 组条目,经补充组澄清对应两份) | mixed/partial | 见补充组两条 |

### 补充组(查漏后补析 6 件)

| 组件 | 判定 | 要点 |
|---|---|---|
| harness/docs/ARCHITECTURE.md | logic/partial | 通用分层常识可即兴口述 / 项目特定规则(跨会话)、evaluate 评分链锚点、分发件 |
| docs/decisions/_TEMPLATE.md | logic/partial | A/B 并排生产被评审团覆盖更强 / **"AI 列选项、人拍板"角色边界(评审团默认自动出结论,方向相反)**、决策落盘供未来 grep、分发件 |
| harness/QUICKREF.md | logic/none | 流程知识浓缩导航(派生文档,知识本体在原始件,损失的是检索效率) |
| 根 README.md | logic/none | 二公设理论根、5 条反模式(源自用户亲自校准的 feedback memory,模型即兴生成不出)、七层 Why 链 |
| harness/README.md | logic/none | 与 Superpowers 职责切分表、十条原则;**反驳者修正:"finishing 自动触发"时机知识非独有,冗余存在于至少 4 处(SKILL frontmatter/M4/QUICKREF)** |
| .gitattributes | machinery/none | 运行环境前提(LF 保证,没它 CRLF 破坏全部 hook);与 ultracode 能力轴正交 |

---

## 查漏发现的文档漂移(顺带修复项)

1. `templates/README.md` 自检判据写 M19 Stop hooks 应为 2 个,`templates/settings.json` 实际注册 3 个(check-context-chain.sh 未同步进判据)。
2. `2026-05-22-p0-9-4-self-check.md` §J 引用 `retrospective-guide.md`,全仓库不存在(悬空引用)。
3. M3 B 组声明 `harness/.claude/settings.local.json`,实际不存在(文档与现实偏差)。

## 本分析框架自身的缺口(挑刺员结论,用图时注意)

- **缺"Superpowers 提供 / harness 自建 / 运行时原生"三分归因轴** — brainstorming/writing-plans/TDD/code-review 实际由 Superpowers 驱动,本图只对照了 ultracode,覆盖归因可能偏。
- 缺逐组件的"自用 / 分发 / 双轨"标记 — 同一组件在 harness 自仓库与下游项目两个语境下可替代性不同。
- 缺组件间同步/契约耦合维度 — 替换/废弃单组件需评估其同步对象(M3§3↔scope.conf 双写、handoff 字段↔hook 解析等)。
- 缺运行时外部依赖轴(hooks 依赖 jq/bash/git/LF;原生能力零外部依赖)。

---

## 与外部文献的交叉印证(事实层)

外部时间线(见姊妹文档)与本图指向同一切分:Anthropic 实测拆掉的是执行结构(context resets、sprint 分块),留下的是判断角色(planner、evaluator);OpenAI 把文档治理做得更机械化而非更少;Cognition 从反方走到"审查 agent 与编码 agent 不共享上下文效果最好"。本图量化了 harness 内对应的"承重墙"位置:触发保障、流程知识、跨会话状态、下游分发四类 + 防绕过条款。

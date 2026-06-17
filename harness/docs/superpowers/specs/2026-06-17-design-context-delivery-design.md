# C「设计层到手边」(design-context delivery)系统设计

> 知识系统 Step2 的 ★ 主项(`references/2026-06-16-knowledge-system-what-to-preserve.md` §E)。在 Step1 反腐烂(freshness)+ Step2 ③a/③b(touchpoint-registry + drift-scout)地基之上,补 B 表三个缺口(写代码 / 调试 / 重构)——让"代码答不出的那层设计背景"(契约 / 边界 / 数据 / 业务规则 / 坑 / 残留 why)按场景**自动到手边**,而不是靠 AI 读全代码(漏)或清掉不懂的 guard(回归)。
>
> 机制 = 一份**机读·设计背景地图**(一行一业务模块,套 ③a touchpoint-registry 机读表范式,只指不抄)+ 一个**设计背景侦察员**(`.claude/agents/design-context-scout.md`,克隆 ③b drift-scout 形态:pull 主动 fork / 读地图两跳 / 消化成 briefing / 只读不写 / 全干净静默 / 软降级 / ⚠️不硬判 / 需 agent 运行时诚实降级)。
>
> brainstorming 拍板日期:2026-06-16(`references/2026-06-16-knowledge-system-what-to-preserve.md` 收敛 + 用户锁定需求清单,见 §1.5)。

> **路径前缀约定**(双层仓,侦察员 mapPointer / 端点解析据此,无歧义 — 与 `drift-detection-design.md` / `freshness-mechanism-design.md` 同约定):
> - `docs/...` 一律指 harness 自仓库的 `harness/docs/...`;
> - `.claude/...` 一律指 `harness/.claude/...`;
> - 根级 `/CLAUDE.md` · `/AGENTS.md` = **仓库根两份**;`harness/CLAUDE.md` = M4 分发模板;
> - 分发下游同形**去 `harness/` 前缀**。
> 侦察员路径解析复用 ③b 三前缀解析范式(§4.4),不另立第二套。

---

## 0. 偏离说明(结构差异)

- 无结构偏离。沿用 `DESIGN_TEMPLATE.md` 全部 9 节标题与编号,新增 §0(本节)+ §10(守住段 / 不做清单),与 harness 历来 harness-meta spec(`2026-06-16-drift-detection-design.md` / `2026-06-16-freshness-mechanism-design.md`)惯例一致。§0 只记结构差异,**不**用作 design-review 豁免依据(design-rules §spec §0 偏离规则)。
- **技术栈映射(harness-meta 机制,非产品 feature)**:本功能产物 = **一份机读地图(`design-context-map.md`)+ 一个 fork 子智能体行为契约(`design-context-scout.md`)+ 治理接线(finishing-rules / setup.sh / 保鲜触点 / credentials)**,**无运行时代码、无 HTTP API、无数据库**。模板中 TypeScript / API 契约 / 数据库字段等示例按"项目实际技术栈 = Markdown 文档 + Claude Code fork agent"映射:
  - **接口节(§3)** = 侦察员入参 / 出参契约 + 地图行 schema(消费契约),非函数签名 / API。
  - **数据模型节(§4)** = 地图机读表行结构 + briefing 结构 + 两跳数据流,非数据库实体。
  - **§3.3 前后端类型契约** = **不适用——harness-meta 机制无 API 端点**(替代物 = 侦察员↔地图消费契约,§4.1)。
- 本设计判**标准级偏重**(判定依据见 §0 注),须过 `/design-review`。

> **规模判定理由(标准级偏重)**:新建 3 个工件(机读地图 `design-context-map.md` + 侦察员契约 `design-context-scout.md` + 只读迁移指南 `design-context-migration.md`)+ 改 finishing-rules(加场景入口步)+ 改 setup.sh(分发三件:scout 逐 cp / 地图守卫 cp / migration 循环 cp + echo 指引)+ 保鲜触点登记 + 可能加 DESIGN_TEMPLATE/MODULE_DOC 节,涉及 ≥4 个文件 + 跨"地图↔侦察员"消费契约 + 跨"侦察员↔三场景片选取"接口。按 design-rules §规模判断:涉新模块 + 接口变更,>3 文件偏向重量,但单文件改动量与 drift-detection(标准级)同量级、无跨系统运行时交互 → 取**标准级偏重**,所有节必填、过 design-review;任一节有疑义按 design-rules"不确定升标准级"原则保守处理。

---

## 1. 需求摘要

> 直接流转自用户已锁定的需求清单(§1.5 列原文锚点),字段结构与 brainstorming 一致,不偷换不漏。

### 1.1 用户目标

AI 没有持久记忆,项目里又有大量 tacit 知识不在代码里(为什么这么划、守住什么、踩过什么坑)。结果:AI 要么读全代码(读不全就**漏**),要么把看着多余的 guard 顺手清掉(瞎删承重墙就**回归**)。

我想要的是:**让"该懂的设计层背景"在我写代码 / 调试 / 重构的那一刻,自动到手边**——省得 AI 临场去重建那层抽象。完整覆盖 = 代码(WHAT,代码自己是 SSoT)+ 外化"代码答不出的"那层(why / 结构 / 约束 / 坑),**按场景**送到手边(不是一次塞全部知识进窗,大部分场景只要一小块)。

一句话:**进写代码 / 调试 / 重构场景时,fork 一个侦察员,读地图、按场景拉对应的设计背景片、消化成一小段 briefing 递到手边;软,只读不写,料不全就空手而归,不替项目产料。**

### 1.2 核心场景(按优先级排序)

> 三场景**统一一层组织**(一份地图 + 一个侦察员),侦察员**按场景取片**(scenario 决定拉哪几类设计背景)。片的取法来自 B 表(`references/2026-06-16-knowledge-system-what-to-preserve.md` §B)。

1. **[P0] 写代码场景 → fork 侦察员拉「契约 + 边界 + 数据 + 业务规则」片**:谁(写码前的调度者/实现者)→ 主动 fork `design-context-scout` 注入 `{scenario:'write', touchedFiles:[正在动的文件], mapPointer, repoRoot, today}` → 侦察员第一跳"正在动的文件 → 业务模块"(读地图成员 glob 列匹配,对不上标 ⚠️ 不硬猜)→ 第二跳"模块 → 各设计背景住址",照地图住址指针 Read 源(接口契约 / 模块边界 / 数据模型 / 业务规则索引)→ 消化成一小段 briefing → 看到:一段"这块的契约/边界/数据/业务规则在哪、要点是什么"的提要(指针 + 摘要,不抄代码)。
2. **[P0] 调试场景 → 拉「坑 + 已知问题 + 决定这块的业务/数据/接口」片**:谁(排错前)→ fork 侦察员注入 `scenario:'debug'` → 同两跳 → 照住址拉 known-pitfalls-index 按场景索引 + 模块 README 已知问题 + 决定这块的业务规则/数据/接口住址 → briefing → 看到:"这块已知有哪些坑 / 已知问题 / 哪些决定约束它"的提要(让 AI 别重犯、别误清)。
3. **[P0] 重构场景 → 拉「系统结构 + 边界 + 为什么这么划(+ 过度抽象护栏)」片**:谁(清理/重构前)→ fork 侦察员注入 `scenario:'refactor'` → 同两跳 → 照住址拉 ARCHITECTURE/模块 README 职责 + 模块边界 + decisions/设计文档§7 取舍 + 残留 why(代码就近 `// WHY:` 注释 + known-pitfalls-index 对照)→ briefing → 看到:"这段为什么在、碰了破不破哪条不变量、有没有过度抽象护栏"的提要(防瞎删承重墙 + 防越改越抽象)。
4. **[P0] 报告分层不刷屏 + 全干净静默**:侦察员消化的 briefing 是**一小段**(指针 + 要点,非长篇);第一跳全对得上模块、第二跳料齐 → 正常 briefing;**模块边界对不上 / 住址料缺(下游没写设计文档/README)→ 标 ⚠️ 而非硬编**;**完全无料可递(地图空 / 都没写)→ 返回"空手"信号**,调度者一句话提示,不刷屏(沿 ③b drift-scout / freshness-scout"全干净静默"惯例)。
5. **[P1] pull + 软降级 + 只读不写**:侦察员是**pull 主动 fork**(非 push hook,无强制力,赌注②);fork 失败 / 无 agent 运行时 → 软提醒 + 跳过(诚实降级,同 ③b/freshness);侦察员**只读地图 + 端点 + 报 briefing,不写、不改地图、不产料**(只读不写,守 ③b drift-scout 边界)。

### 1.3 边界与约束

- **做什么**:建 **`design-context-map.md`**(机读·设计背景地图,套 ③a touchpoint-registry 机读表范式,一行一业务模块,**只指不抄**;它**就是业务模块的权威清单**;**模板自带格式 = 列头 + 一行示意样板行 + "怎么填"内联注**,§8.4 B2)+ **`design-context-scout.md`**(说明型子智能体契约,克隆 ③b drift-scout 形态)+ **finishing-rules 写代码/调试/重构入口加「fork 设计背景侦察员」一步(pull)+ 保鲜触点登记** + **setup.sh 分发(scout 逐 cp + 地图活文件守卫 cp + migration 只读循环 cp)+ 安装末尾 echo 指向迁移指南** + **新建 `docs/governance/design-context-migration.md`「下游迁移指南」只读文档**(必备内容清单 + 一个已有项目怎么搬进格式,§8.4 B1/B2;住 governance 随分发,**不住根 README**——根 README 不分发下游)+ 可能给 **DESIGN_TEMPLATE/MODULE_DOC 加节**(业务规则索引体裁 / 残留 why 注释体裁)。
- **迁移格式 + 必备内容清单(赌注① 落地抓手)**:本机制赌"下游真写了设计文档/README"——光赌不行,**给下游一份必备内容清单(11 类设计层内容,§8.4 B1)+ 迁移格式(地图模板自带样板行 + `docs/governance/design-context-migration.md` 迁移指南 + setup.sh echo,§8.4 B2)**,把赌注① 从"赌他写"变"给了可勾清单 + 可填模板"。关键认知:**11 类里 9 类 harness 现成模板已给位置**(DESIGN_TEMPLATE/MODULE_DOC/decisions/坑索引),**真要新加约定的只有 2 条**(业务规则段 + `// WHY:` 注释 = 本设计两个洞)。
- **不做什么**(详 §10):
  - **不替项目产料**:侦察员只递**已有的**设计背景;下游若没真写设计文档/README → 侦察员**空手而归**(料缺标 ⚠️,不编造)。这是诚实赌注①。
  - **不抄代码**:代码 = SSoT,地图/侦察员只给指针 + 要点,不复述代码(防"逐字镜像代码的散文"腐烂,§A 表"别存什么")。
  - **不新建要保鲜的独立 wiki**:业务规则权威留**设计文档**(单源),地图只把锚点**聚成索引行**(只指不抄);残留 why 权威**复用 known-pitfalls-index**,不给每个 guard 开新文件。
  - **不升格 business-module-map 旧件**:`references/2026-06-10-business-module-map.md` 继续当**留痕**(immutable 草案视图,不动);新地图 `design-context-map.md` 才是业务模块**权威清单**。
  - **不 push、不硬阻断**:pull 主动 fork(无 hook 强制),软;不挡写码/收口。
  - **不自仓库 dogfood 验稳定性**:自仓库不建 `design-context-map.md` 数据(dogfood 边界,§10.2 + 赌注);仅下游分发,误报/漏报/刷屏感等稳定性靠真实项目验。
- **性能/成本**:一次 fork(同 ③b drift-scout / freshness-scout 量级),侦察员读地图(一行一模块,模块数级)+ 第一跳匹配 + 第二跳照住址 Read 若干源文件。无网络、无写。成本与退化风险评估见 §7 D5 + §6.3。
- **兼容性**:双层 harness 自仓库 + 单层下游都要能跑(侦察员据注入的 `repoRoot` + ③b 三前缀解析范式定位)。半角/全角护栏:读地图住址 / 端点锚时疑似全角符号在 briefing 附提示(同 ③b/freshness 全角护栏)。

### 1.4 关联需求

- **依赖的已有功能**:
  - ③a `touchpoint-registry.md`(被**克隆的机读表范式**:id/类型/端点/判据/来源/现状 → 本地图镜像为 模块/成员glob/各设计背景住址)。
  - ③b `drift-scout.md`(被**克隆的侦察员形态**:入参出参二态 / 只读不写 / 全干净静默 / 软降级 / ⚠️不硬判 / 需 agent 降级 / 三前缀解析)。
  - Step1 freshness(`freshness-rules.md` + `freshness-scout.md`):地图是**活文档**(带 freshness frontmatter,owner=调度者),纳 freshness 范围保鲜。
  - 现有"设计背景的家"6-7 类:设计文档(§3/§4/§5/§7)、模块 README(对外接口/职责/约束/已知问题段)、ARCHITECTURE、decisions/、known-pitfalls-index。地图**指向**它们,不复制。
- **被哪些未来功能依赖**:Step2 边界厘清(知识/偏好/规则,§C 糊地带)——等本 ★ 往书架加新层(业务规则索引 / 残留 why 体裁)时拿真案例解(对齐「边做边提升」)。
- **保鲜闭环依赖 ③b**:地图登记成触点 → 改码后"地图指针失效 / 模块成员漂移"由 ③b drift-scout 在收口凭证批自动逮 + 人工触点完整性维兜(§4.5 + §8.1)。

### 1.5 已确认的决策(从需求对接阶段带入 — 用户锁定原文锚点)

- **目标**(锁定):AI 无持久记忆 + tacit 知识不在代码 → 让"该懂的设计层背景"在写代码/调试/重构自动到手边(省得读全代码=漏 / 瞎删承重墙=回归)。完整覆盖 = 代码(WHAT)+ 外化"代码答不出的"那层(why/结构/约束/坑),按场景送到手边。
- **三场景统一一层,侦察员按场景取片**(锁定):写代码取 契约+边界+数据+业务规则;调试取 坑+已知问题+决定这块的业务/数据/接口;重构取 系统结构+边界+为什么这么划(+过度抽象护栏)。
- **两个新工件**(锁定):① 设计背景地图(新·机读·独立工件,套 ③a 机读表范式,一行一业务模块,只指不抄,就是业务模块权威清单);② 设计背景侦察员(新·`.claude/agents/` 契约,克隆 ③b drift-scout 形态,pull 主动 fork,读地图两跳,消化成 briefing)。
- **内容模型**(锁定,6-7 类复用现有家 + 2 洞补法):
  - 复用现有家:接口契约→设计§3+模块README对外接口;数据模型→设计§4;模块边界→ARCHITECTURE+模块README职责;取舍/决策→decisions/+设计§7;不变量约束→ARCHITECTURE+模块README约束段;既知坑/已知问题→known-pitfalls-index 按场景索引+模块README已知问题段;并发/同步/排序约束→设计§5边界条件加一列理由(现有加节)。
  - **洞①业务规则**(补法已定):权威留设计文档(单源),地图按业务模块把锚点**聚成索引行**(只指不抄),**不新建要保鲜的独立 wiki**。
  - **洞②残留 why / Chesterton 栅栏**(补法**方向**已定,`// WHY:` 增量**必要性** writing-plans 复核):**方向**=权威住址**复用 known-pitfalls-index**(留"已关闭"行对照)+ 代码就近 grep 注释 `// WHY: 防[X],见[路径]` 双轨;**不给每个 guard 开新文件**。残留 why 来源含 bug修复/历史兼容/外部库 quirk。**注**:双轨里 `// WHY:` 注释约定是否**必需**(仅靠 known-pitfalls-index 能否覆盖承重墙留痕)留 writing-plans 显式复核(§8.1 A6),不默认落约定——与 §8.1 口径统一(方向定、必要性待复核),非"锁定不可动"。
- **保鲜闭环**(锁定):地图活文档(freshness frontmatter,owner=调度者)→ 登记成触点 → ③b drift-scout 收口凭证批自动逮地图指针失效/模块成员漂移 + 人工触点完整性维兜。
- **边界/不做**(锁定):只递已有料、不替项目产料;不抄代码;不新建要保鲜的独立 wiki;自仓库 dogfood 边界——仅下游分发、自仓库不建、真实项目才能验稳定性。
- **诚实赌注**(锁定,写进 §7 + §6.3,过 spec_gap_masking):① 赌下游真写了设计文档/README(没写→空手);② 赌 pull 够(AI 得记得 fork,无 push 强制力,同"读不全就漏"残留风险);③ 赌业务模块边界清楚(file→module 维护得住,糊则第一跳标 ⚠️)。

### 1.6 RUBRIC 风险标记

> harness 自仓库 RUBRIC 是空模板,真方向盘 = `CLAUDE.md` 核心原则 + 二公设代偿(沿 ③b / review-scout `rubric_mode='template'` 回落目标)。

- 涉及的惩罚项 / 红线:
  - **最小变更(核心规则 5)**:新地图 + 新侦察员只读 + 报 briefing;finishing-rules 只加一步;setup.sh 只加分发行(scout cp + 地图守卫 cp + migration 循环)+ 一句 echo 指引;迁移指南正文住一份新建只读 governance 文档(`design-context-migration.md`,随分发);复用现有家不新建**要保鲜的**独立 wiki、不另存(业务规则/残留 why 挂现有家)。每行 diff 可追溯。
  - **简洁性 / 过度工程化(RUBRIC 通用基线 + feedback 戒条)**:**关键风险**——"按场景索引 + pull 拉" vs "大 wiki 全塞窗"。反向追问见 §7 RUBRIC 应对(不用本方式,三个缺口怎么解)。两洞补法均"复用现有家不新建保鲜件",防扩散。
  - **spec_gap_masking(feedback 戒条)**:**关键风险**——三个诚实赌注(下游真写没 / pull 够不够 / 模块边界清不清)是真缺口。须**显式标"已知缺口"+ 技术原因 + 补救方向**(§7 🟡 + §6.3),不假装侦察员万无一失。
  - **二公设(做事/判断分离)**:侦察员是"做事"工具(读地图拉料消化 briefing),**不替代"判断"**——拉来的料怎么用、信不信、要不要据此改,归调度者/实现者;侦察员只读不写守边界(公设 1)。侦察员不确定时执行外部动作(Read 端点)而非内省,符合公设 2。
  - **凭证义务(credentials.conf)**:新 `design-context-scout.md` 命中 `.claude/agents/*.md`;新 `design-context-map.md` + 新 `design-context-migration.md` 均命中 `docs/governance/*.md`;finishing-rules 改动命中 `docs/governance/*.md`;setup.sh 改动命中 `setup.sh`;可能 DESIGN_TEMPLATE 命中 `docs/references/DESIGN_TEMPLATE.md`。**迁移指南改住 governance 文档(非根 README)后,本 spec 不改根 README → 无 README 凭证悬空问题**(§8.3 covers 第 8 项 = migration 文档进 audit)。收口须 audit(§8.3)。
- 涉及的奖励项:把 B 表三个缺口(写代码/调试/重构)用"按场景索引 + 按需拉"一锅端;只指不抄守住"代码=SSoT、上面那层抽象文档化"的 A 表判据;复用现有家不新建保鲜件守简洁。

**自检**:
- [x] 每个核心场景有完整"谁→做什么→系统做什么→看到什么"?(§1.2 五个 P0/P1 场景齐)
- [x] "不做什么"列了用户可能误以为在范围内的事?(误以为"侦察员会替项目产料"→ §1.3 明确否定;误以为"新建 wiki"→ §1.3/§10 否定;误以为"business-module-map 升格"→ §1.3 否定)
- [x] 和 brainstorming 锁定清单对得上?(§1.5 逐条落:目标/三场景/两工件/内容模型/保鲜/边界/赌注)
- [x] 优先级反映用户确认?(P0=三场景片 + 报告分层,P1=pull/降级/只读不写)

---

## 2. 模块划分

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动 | 所在层 |
|------|--------------|----------|--------|
| `docs/governance/design-context-map.md` | 机读·设计背景地图:一行一业务模块,列=成员 glob + 各类设计背景住址指针(只指不抄);**业务模块权威清单** | 新建 | `docs/governance/`(机读注册表层,镜像 touchpoint-registry) |
| `.claude/agents/design-context-scout.md` | 被 fork 出来,读地图两跳(file→模块→住址)、照住址拉设计背景片、消化成 briefing(只读不写) | 新建 | `.claude/agents/`(子智能体契约层,说明型非 custom-agent) |
| `docs/governance/finishing-rules.md` 写码/调试/重构入口步 | 收口/入口工序指明何时 fork 侦察员(pull)、怎么消费 briefing、降级回落;**保鲜触点登记** | 改动 | `docs/governance/`(治理规则层) |
| `setup.sh` 分发段 | 加 cp 行分发 `design-context-scout.md`(agents 逐 cp 行类)+ **地图 `design-context-map.md` 排除出 governance 无条件循环、改活文件守卫 cp(I7,同 handoff.md)** + 确认 `design-context-migration.md` 随 governance `*.md` 循环分发(只读指南,无条件覆盖正确)+ 安装末尾 echo 指向迁移指南 | 改动 | repo 根(分发脚本) |
| `docs/governance/design-context-migration.md` | 新建·只读迁移指南:必备内容清单 11 类(B1)+ 已有项目搬进地图格式三步(B2);随 governance `*.md` 循环**无条件覆盖**分发(只读指南,总刷新正确);**命中 `docs/governance/*.md`** → 进 audit covers(§8.4) | 新建 | `docs/governance/`(只读迁移指南) |
| `docs/references/DESIGN_TEMPLATE.md` / `MODULE_DOC_TEMPLATE.md`(可能) | 加节:设计文档「业务规则」索引锚体裁(洞①)/ 残留 why 注释体裁约定(洞②);MODULE_DOC「对外接口/已知问题」段强化为侦察员可定位锚 | 改动(按需) | `docs/references/`(模板层) |
| `docs/governance/freshness-rules.md` 范围清单(可能) | 把 `design-context-map.md` 纳入 freshness 核心集(governance/*.md 已在核心集,自动纳入;若需显式则一行) | 改动(可能自动) | `docs/governance/`(保鲜权威) |
| `references/2026-06-10-business-module-map.md` | **不动**:继续当留痕草案视图,不升格 | **不在本 spec 改** | `docs/references/`(留痕) |

> **地图住址抉择(§7 D6)**:`design-context-map.md` 落 `docs/governance/`(同 touchpoint-registry),理由:① 它是机读注册表 + 业务模块权威清单,与 touchpoint-registry 同性质同住址;② 自动进 freshness 核心集(范围清单)+ 自动命中 credentials.conf `docs/governance/*.md` 凭证 glob——freshness/credentials/drift 三机制零额外接线。**分发例外**:地图是下游逐模块填的**可写活文档**,故 setup.sh **不**走 governance 无条件循环 cp(L104,会覆盖下游成果),改**活文件守卫 cp**(I7,同 handoff.md/index.md;§8.1)——这是地图分发上唯一的接线(住址仍 governance,只 cp 方式特殊)。备选(落 `docs/references/`)被否:references 标准件豁免目录卡但 freshness 仅增量采纳、且非"业务模块权威清单"语义。

> **形态说明(镜像 ③b drift-scout / freshness-scout)**:`design-context-scout.md` 是说明型子智能体契约,**非带 YAML `---` frontmatter tools 块的 custom agent type**。首行带 HTML 注释新鲜度标签 `<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->`(HTML 注释 ≠ YAML `---`,不被解析成 custom agent type,同 drift-scout.md / freshness-scout.md L4-L6 已消解张力)。

### 2.2 模块依赖图

```
finishing-rules.md「设计背景到手边」入口步
        │ (写码/调试/重构入口指引调度者 pull fork)
        ▼
调度者 fork  design-context-scout（独立 context, Read/Grep 工具）
        │ 注入 {scenario, touchedFiles, mapPointer, repoRoot, today}
        ▼
design-context-scout ──第一跳读──► design-context-map.md(一行一模块,成员 glob 列)
        │                               │ touchedFiles 匹配 glob → 业务模块(对不上 → ⚠️)
        │                               │ 模块行 → 各设计背景住址指针列
        ├──第二跳照住址 Read──► 设计文档(§3 契约/§4 数据/§5 边界/§7 取舍)
        ├──第二跳照住址 Read──► 模块 README(对外接口/职责/约束/已知问题段)
        ├──第二跳照住址 Read──► ARCHITECTURE(分层/边界)
        ├──第二跳照住址 Read──► decisions/(取舍/否决备选)
        ├──第二跳照住址 Read──► known-pitfalls-index(按场景坑 + 残留 why 对照)
        └──第二跳 grep──► 代码就近 `// WHY:` 注释(残留 why,洞②)
        │ 按 scenario 取片(write/debug/refactor 决定拉哪几类)
        ▼
briefing(一小段:指针 + 要点,不抄代码)──►  调度者/实现者据 briefing 写码/调试/重构

保鲜闭环(复用 ③b):
design-context-map.md ──登记成触点──► touchpoint-registry.md 新增行
        │ 改码后地图指针失效/模块成员漂移
        ▼
③b drift-scout 收口凭证批自动逮 🔴 + 人工触点完整性维兜

setup.sh: cp design-context-scout.md(agents 逐 cp 行) + design-context-map.md 活文件守卫 cp(防覆盖下游活地图) + design-context-migration.md 随 governance/*.md 循环分发(只读)
```

- 依赖方向:治理规则(finishing-rules)→ 子智能体(design-context-scout)→ 数据(地图 + 设计背景端点)。单向,无环。
- 与 ③b drift-scout **同形态、互补不互调**:drift-scout 管"触点漂没漂"(收口逮漂移),design-context-scout 管"设计背景拉到手边"(场景入口递 briefing);两者都消费机读表(touchpoint-registry / design-context-map),但**各读各的表、各干各的活**,无依赖。**唯一交点 = 保鲜**:design-context-map 登记进 touchpoint-registry 后,被 drift-scout 当触点查漂移(§4.5)。
- 与 freshness-scout / review-scout / research-scout **同形态、不互调**:复用其形态范式(HTML 注释标签 / 入参出参二态 / fork 失败降级 / 全干净静默),独立文件。

**自检**:
- [x] 每个模块单一职责?(地图=存模块→住址索引;scout=读地图两跳拉料消化 briefing;finishing 步=指引何时 pull fork + 消费 + 降级 + 保鲜登记;setup.sh=分发;三者不混)
- [x] 依赖方向符合分层?(规则→子智能体→数据,单向)
- [x] 无循环依赖?(地图不反向依赖 scout;scout 只读不写)
- [x] 改动局限职责内?(finishing 加入口步;setup.sh 加分发;DESIGN_TEMPLATE 加节;business-module-map 不动)
- [x] 每个核心场景有实现路径?(写码/调试/重构片=scout §4.3 按 scenario 取片;报告分层=scout §3.1+§5.3;pull/降级/只读不写=§7 D1/D4/D5)
- [x] 粒度合理?(一地图 + 一 scout 契约,不拆碎;两洞补法挂现有家不新建模块)

---

## 3. 接口定义

> 本功能的"接口"= 侦察员被 fork 时的**入参契约**(调度者注入)+ 侦察员返回的 **briefing 出参契约** + 侦察员读地图的**行消费契约**(§4.1)。无前后端 API(§3.3 不适用)。镜像 ③b drift-scout.md / freshness-scout.md 的"入参契约 / 出参契约"段。

### 3.1 模块间接口

**调度者 → design-context-scout(fork 入参契约)**

```text
入参 = {
  scenario:      "write" | "debug" | "refactor"   // 场景:决定取哪几片设计背景(§4.3 片选取表)
  touchedFiles:  ["<正在动/排错/重构的文件路径>", ...]  // 第一跳 file→模块匹配的输入(可空:空则只能整图概览,§5.1)
  mapPointer:    "docs/governance/design-context-map.md"  // 地图住址(scout 自 Read,指针不是内容)
  repoRoot:      "<仓库根绝对/相对路径>"            // 路径前缀解析锚(双层仓 vs 下游单层;复用 ③b §4.4 三前缀解析)
  today:         "YYYY-MM-DD"                       // 调度者注入(全角护栏 briefing 用;不自取系统时钟避环境漂移,同 ③b/freshness)
}
```

**design-context-scout → 调度者(出参契约 = briefing 对象,二态)**

```text
出参 = Briefing | EmptyHanded

EmptyHanded: { delivered: false, reason: "<一句话>", missingKinds: ["<本场景缺哪类可递片>", ...], seeGuide: "docs/governance/design-context-migration.md 下游迁移指南(§8.4)" }
            // 空手态 = 地图无对应模块行 / 住址料全缺(下游没写设计文档/README)/ 地图读不到
            //   → 调度者一句话提示(如"本块设计背景暂无料,下游未写设计文档/README" 或 "正在动的文件未匹配到业务模块,模块边界待厘清")
            //   → reason 不只说"没料":带 missingKinds(本次该场景缺的可递片,§4.3 该 scenario 取片域)+ seeGuide(指向迁移指南"去哪补"),B3 闭环
            //   missingKinds ≠ B1 全 11 类:missingKinds = 本场景该取却缺的片(write/debug/refactor 各取片子集,§4.3);
            //     B1 11 类 = seeGuide 指向的 migration 文档里"下游必备内容"全清单(更广,含意图/非功能等本 scout 不拉的);两者非同集(详 §8.4 B3)
            //   不刷屏(沿 ③b/freshness 全干净静默惯例),不阻断写码

Briefing:   { delivered: true,
              scenario: "write" | "debug" | "refactor",
              modules:  [ ModuleBrief, ... ],   // 第一跳命中的业务模块(可多个:touchedFiles 跨模块)
              unsure:   [ "<file 未匹配到模块 / 住址料缺>", ... ],  // ⚠️ 逐条(不硬猜)
              summary:  "<一行:N 模块 briefed / M ⚠️>" }
            // **概览态复用 Briefing**(touchedFiles 空,§5.1):delivered:true,modules[] 装"有哪些业务模块"(各 ModuleBrief.matchedFiles 空、slices 空——无具体片可取),
            //   summary 注"未传 touchedFiles,仅概览,无具体片";不另立第三态(消 §3.1↔§5.1 不一致)

ModuleBrief = {
  module:        "<业务模块名>"                     // 第一跳命中的模块(地图行)
  matchedFiles:  ["<touchedFiles 中落本模块 glob 的>", ...]
  slices:        [ ContextSlice, ... ]              // 按 scenario 取的片(§4.3)
  endpointsRead: ["<scout 第二跳实际 Read/grep 的 文件:锚>", ...]  // 读源留痕(镜像 drift-scout TouchpointVerdict.endpointsChecked,防判松无据/可复核;§4.4 解析后实际命中的端点)
}

ContextSlice = {
  kind:     "接口契约" | "模块边界" | "数据模型" | "业务规则索引" | "取舍决策"
            | "不变量约束" | "并发/同步/排序约束" | "既知坑/已知问题" | "残留 why"
            // kind 字面 = §4.1 地图列头字面(精确对照表见 §4.3);8 个 kind 字面=列头字面、照地图住址列 Read。
            // **「残留 why」是唯一特例**:无地图列 → 不照住址列 Read,而是 grep 代码就近 `// WHY:`(限本命中模块 memberGlob 覆盖的代码文件内,非全仓)+ 对照 known-pitfalls-index(§4.3 对照表残留 why 行)
  pointer:  "<住址指针:文件:锚>"                   // 照地图住址列,只指不抄(代码=SSoT);残留 why 特例:pointer = grep 命中的 `代码文件:行` + known-pitfalls 对照锚
  gist:     "<一两句要点>"                          // scout 读源消化的提要(非复制原文/代码)
  note:     "<可空:料缺/全角/定位不准 → ⚠️ 说明>"
}
```

- scout 两跳完成后**一次性返回**(不流式、不中途刷主对话,同 ③b/freshness)。
- **报告分层**(§5.3):正常模块 briefing 进 `modules[]`;⚠️(file 未匹配模块 / 住址料缺 / 定位不准)进 `unsure[]` 逐条,**不硬猜不静默漏**;完全无料 → `EmptyHanded`。

**调用契约(写码/调试/重构入口,调度者执行)**:

```text
# 进写代码 / 调试 / 重构场景时,调度者按 finishing-rules 入口步 pull fork:
1. 需 agent 运行时 → fork design-context-scout,注入 {scenario, touchedFiles, mapPointer, repoRoot, today}
2. 无 agent 运行时 / fork 失败 → 跳过 + 软提醒"本次设计背景未拉(无 agent / fork 失败)"(诚实降级,不阻断;§5.2 / §7 D5)
3. 收到 briefing → 据 slices 指针/要点写码/调试/重构;⚠️ 提示模块边界/料缺(调度者复核或推下游补)
4. EmptyHanded → 一句话提示(料缺/未匹配),继续(不阻断;赌注①暴露面)
```

### 3.2 外部接口

无外部 API。唯一"外部"交互 = scout 用 Read/Grep 读文件系统(地图 + 各设计背景端点:设计文档/README/ARCHITECTURE/decisions/known-pitfalls-index + 代码 `// WHY:` 注释)。scout 无网络、无写操作。

### 3.3 前后端类型契约

**不适用——harness-meta 机制,本功能不涉及任何 API 端点。**

> 替代:本 scout 与地图之间有**消费契约**(scout 怎么读地图行的列、第一跳怎么 file→模块匹配 glob、第二跳怎么照住址列 Read 源、按 scenario 怎么取片),详见 §4.1 + §4.3。这是本设计的"契约"等价物(同 ③b drift-scout 的注册表消费契约)。

**自检**:
- [x] 接口双方都定义?(调用方=调度者/finishing 入口步;实现方=design-context-scout;§3.1 两侧齐)
- [x] 参数/返回类型存在?(入参对象字段 + 出参二态 briefing 对象,均结构化文本,在 fork agent schema 内)
- [x] 每个接口有错误处理约定?(§3.1 调用契约第 2 条降级 + EmptyHanded + §5 边界/错误)
- [x] 入参/出参与需求数据对得上?(入参=scenario+touchedFiles+地图指针;出参=按场景的设计背景片 briefing + ⚠️,= §1.2 三场景"看到什么")
- [x] 接口简洁?(入参 5 字段均必要;出参二态;ContextSlice 字段 kind/pointer/gist 必要,note 兜 ⚠️;ModuleBrief.endpointsRead 是留痕字段,镜像 drift-scout endpointsChecked,非冗余)
- [x] 字段命名统一?(scenario/touchedFiles/mapPointer/slices/gist/endpointsRead 全程一致;残留 why 全 spec 统一带空格;沿 ③b/freshness 命名风格)

---

## 4. 数据模型

> 本功能"数据" = scout 消费的**地图行结构**(读,§4.1)+ scout 产出的 **briefing 结构**(§3.1 已定)+ scout 两跳数据流(§4.2)+ **按 scenario 的片选取映射**(最关键,§4.3)+ 端点三前缀解析(§4.4,复用 ③b)+ **保鲜触点登记**(§4.5)。

### 4.1 地图行结构(scout 消费契约;镜像 ③a touchpoint-registry 机读表范式)

`design-context-map.md` 主表行格式(套 ③a touchpoint-registry 范式:id/类型/端点/判据/来源/现状 → 镜像为 模块/成员glob/各设计背景住址,**只指不抄**):

```
| 业务模块 | 成员文件 glob | 接口契约 | 数据模型 | 模块边界 | 取舍决策 | 不变量约束 | 既知坑/已知问题 | 业务规则索引 | 并发/同步/排序约束 |
```

> **范式映射差异(为何不照搬 touchpoint-registry 的判据/来源/现状列)**:本地图只取 ③a 范式的"端点"语义(拆成 成员glob + 各设计背景住址列),**不单列判据/来源/现状**——理由:① 判据/现状是"漂移**检测**语义"(touchpoint-registry 给 ③b drift-scout 判端点漂没漂用),本地图是"设计背景**索引**"、不自带检测语义(地图的漂移检测由 §4.5 登进 touchpoint-registry 后由 drift-scout 兜,不在地图行内重复);② 来源**由住址指针文件名隐含**(`design/order.md:§3` 自带来源),不单列;③ 类型对本地图恒为"住址指针",无须列。故本地图行 = 模块标识 + 成员glob(第一跳键)+ 设计背景住址列(第二跳照拉),比 touchpoint-registry 行更瘦。

> 列设计(内容模型 6-7 类复用现有家 + 2 洞,§1.5):每个"设计背景"列填**住址指针**(`文件:锚`),不填内容(只指不抄)。复用现有家见下表;空缺填 `—`(该模块该类暂无料 → scout 拉时 EmptyHanded/⚠️)。

| 地图列 | 住址(复用现有家) | 对应 §1.5 内容模型 |
|---|---|---|
| 接口契约 | 设计文档§3 + 模块 README 对外接口段 | 复用 |
| 数据模型 | 设计文档§4 | 复用 |
| 模块边界 | ARCHITECTURE + 模块 README 职责段 | 复用 |
| 取舍决策 | decisions/ + 设计文档§7 | 复用 |
| 不变量约束 | ARCHITECTURE + 模块 README 约束段 | 复用 |
| 既知坑/已知问题 | known-pitfalls-index 按场景索引 + 模块 README 已知问题段 | 复用 |
| 业务规则索引 | 设计文档(单源)锚点**聚成索引**(只指不抄) | **洞①** |
| 并发/同步/排序约束 | 设计文档§5 边界条件加一列理由(现有加节) | 复用(现有加节) |
| (残留 why,不单列地图列) | 代码就近 `// WHY:` 注释 + known-pitfalls-index 对照 | **洞②**(scout grep 拉,不进地图列) |

scout 把每条数据行(AI 读,**非 awk 切**,对散文住址宽容)理解为:

```text
ModuleRow {
  module:       "<业务模块名>"          // 行标识;briefing 定位用
  memberGlob:   "<成员文件 glob>"       // 第一跳 file→模块匹配键(可多 glob 分号分隔)
  contracts:    { 各列名 → (住址指针 | "—") }
                // 列名(8 列,引号包以消歧——列名内含 `/` 不是分隔符):
                //   "接口契约";"数据模型";"模块边界";"取舍决策";"不变量约束";"既知坑/已知问题";"业务规则索引";"并发/同步/排序约束"
                //   (= §4.1 主表 8 个设计背景列字面,与 §4.3 kind↔列名 对照表一致;memberGlob/业务模块 不在 contracts 内)
                // 第二跳照住址列 Read;"—" = 该类无料(EmptyHanded/⚠️)
}
```

- scout 跳过表头行(`| 业务模块 |`)、分隔行(`|---|`)、表外散文——AI 读表自然识别,无需机械正则(比 hook 宽容,同 ③b)。
- **业务模块按业务能力切,不按材料切**(memory `feedback_module_cut_by_business.md`:材料属性=模块内部的面,顶层切法是业务能力)——参考 business-module-map 八模块的业务切法(留痕),但本地图是**权威清单**、可独立演进。

### 4.2 数据流(两跳)

```
[进写码/调试/重构场景]
   → [调度者 pull fork design-context-scout,注入 {scenario, touchedFiles, mapPointer, repoRoot, today}]
   → [scout Read 地图 §主表,取全部模块行]
   → [第一跳:touchedFiles 逐个 → 匹配 memberGlob 列 → 命中业务模块]:
        匹配上            → 命中模块(可多个,touchedFiles 跨模块)
        匹配不上          → ⚠️ "<file> 未匹配到业务模块,模块边界待厘清"(不硬猜,赌注③)
        touchedFiles 空   → 整图概览模式(只能给"有哪些模块",不给具体片;§5.1)
   → [第二跳:对每个命中模块,按 scenario 取片(§4.3)]:
        照该模块行的对应住址列 → 解析路径(§4.4)→ Read/grep 源 → 消化成 gist
        住址列="—" 或源料缺  → 该片 ⚠️/skip(下游没写 → 赌注①暴露,不编造)
        残留 why(洞②)      → grep 代码就近 `// WHY:` **限在本命中模块 memberGlob 覆盖的代码文件内**(非全仓 grep)+ 对照 known-pitfalls-index
   → [scout 汇总:briefing 分层(正常 modules[] / ⚠️ unsure[] 逐条 / 全缺 EmptyHanded)]
   → [返回 Briefing 或 EmptyHanded(§3.1)]
   → [调度者消费]:据 slices 写码/调试/重构;⚠️ 复核模块边界/推下游补料;EmptyHanded 一句话继续
```

### 4.3 按 scenario 的片选取映射(最关键 — 侦察员按场景取哪几片)

> scout 第二跳对每个命中模块,先看入参 `scenario`,再按下表取该场景对应的几片设计背景(片来源 = §1.5 B 表三场景取法)。**这是"统一一层 + 按场景取片"的核心机制**。

> **片 kind ↔ 地图列名 精确对照表(消第二跳模糊匹配,A3)**:下表左列 = B 表的概念名(本节片选取表沿用,口语好读),右列 = §4.1 地图列头**字面**。**scout 第二跳"按 kind 找列"以右列字面为准直查**(不做模糊匹配);**ContextSlice.kind 出参字面也取右列**(§3.1 已统一,kind 字面 = 列头字面,故 briefing 与地图无漂移)。两列差异只在两处历史命名:**业务规则 → 业务规则索引**(地图把分散锚点聚成索引,列头带"索引")、**并发同步排序约束 → 并发/同步/排序约束**(列头含半角 `/`)——本表把这两处一次对死,scout 不再自行猜匹配。
>
> | 片概念名(B 表 / 本节口语) | §4.1 地图列头字面(= ContextSlice.kind 出参) | 残留 why 特例 |
> |---|---|---|
> | 接口契约 | 接口契约 | — |
> | 模块边界 | 模块边界 | — |
> | 数据模型 | 数据模型 | — |
> | 业务规则 | **业务规则索引** | — |
> | 取舍决策 | 取舍决策 | — |
> | 不变量约束 | 不变量约束 | — |
> | 并发同步排序约束 | **并发/同步/排序约束** | — |
> | 既知坑/已知问题 | 既知坑/已知问题 | — |
> | 残留 why | (无地图列)| grep 代码 `// WHY:`(**限本模块 memberGlob 覆盖的代码文件内**,非全仓)+ 对照 known-pitfalls-index |

| scenario | 取哪几片(片 kind) | 对应地图住址列 / 来源 | 依据(§1.5 B 表) |
|---|---|---|---|
| **write**(写代码) | 接口契约 + 模块边界 + 数据模型 + 业务规则 + 并发/同步/排序约束 | 接口契约列 + 模块边界列 + 数据模型列 + 业务规则索引列 + 并发/同步/排序约束列 | "写代码取 契约+边界+数据+业务规则"(并发约束并入:写并发代码要先知排序/同步约束,防新写竞态) |
| **debug**(调试) | 既知坑/已知问题 + 决定这块的业务规则/数据/接口 + 并发/同步/排序约束 | 既知坑列 + 业务规则索引列 + 数据模型列 + 接口契约列 + 并发/同步/排序约束列(+ 残留 why grep,限本模块代码) | "调试取 坑+已知问题+决定这块的业务/数据/接口"(并发约束并入:查竞态/时序 bug 要先知约束) |
| **refactor**(重构) | 系统结构(模块边界)+ 为什么这么划(取舍决策)+ 不变量约束 + 残留 why(过度抽象护栏) | 模块边界列 + 取舍决策列 + 不变量约束列 + 残留 why(grep 限本模块代码 + known-pitfalls 对照) | "重构取 系统结构+边界+为什么这么划(+过度抽象护栏)" |

> **片选取诚实声明**:三场景片**有交集**(如数据模型 write/debug 都取、并发约束 write/debug 都取)——这是 B 表设计,非冗余。scout 按 scenario 取片是**过滤**(不是每次拉全部 9 类),省得"大 wiki 全塞窗"(§D 镜头1:大部分场景只要一小块)。**过度抽象护栏(refactor 专属)**= 残留 why + 取舍决策一起看,让 AI 重构前先问"这层抽象为什么在、是不是当年某决定/某坑逼出来的",防越改越抽象 / 防瞎删承重墙。
>
> **并发/同步/排序约束消费路径(死列收口,A2)**:该列在 write + debug 两场景有取(写并发代码需排序/同步约束、查竞态/时序 bug 需约束),非"地图有列但无人取"的死列;refactor 取不变量约束已隐含部分约束语义,不重复取本列。

### 4.4 端点路径三前缀解析(复用 ③b drift-scout §4.4)

> scout 读地图住址列 / 端点文件时,路径混三类前缀(裸相对 `docs/...`·`.claude/...` / `<root>/` sentinel / `harness/...`)。**解析规则 + 产物 + 判定顺序 + `<root>/` 不加 `harness/` 护栏完全复用 `drift-scout.md`「§端点路径三前缀解析(操作指引)」,不另立第二套**(不在此自抄三条缩写副本,防双写漂移):

- **复用范围**(指针,不重述):三类前缀各自的解析产物(挂 repoRoot 根 / 加 `harness/` 前缀)、**判定顺序**(先判 `<root>/` 前缀、再判 `harness/` 前缀,**先于**裸相对路径的双层仓补 `harness/` 逻辑——避免 `<root>/` / `harness/` 被裸相对分支误加前缀)、`<root>/` sentinel 剥前缀后**不**再加 `harness/` 的护栏——均以 drift-scout 该节为单源权威。
- 解析后**读不到** → 标 ⚠️ + `endpointsRead` 留痕(§3.1 ModuleBrief 字段,镜像 drift-scout `endpointsChecked`;不假装料缺,可能解析错前缀,让调度者复核)。
- **全角护栏**(沿 freshness/drift-scout 实证):读住址锚疑似全角 `｜：，「」` 致定位不到 → briefing 附"疑似全角符号,住址锚约定半角",标 ⚠️。

### 4.5 保鲜触点登记(复用 ③b drift-scout 闭环)

> 地图是活文档,会腐(指针失效 / 模块成员漂移)。**复用 ③b drift-scout 保鲜闭环**:把地图登记成触点,改码后由 drift-scout 在收口凭证批自动逮 + 人工触点完整性维兜。

- **地图自身保鲜**:`design-context-map.md` 落 `docs/governance/*.md` → 自动进 freshness 核心集(`freshness-rules.md` 范围清单),带 frontmatter(owner=调度者,last-reviewed),freshness-scout 开场扫时间腐。
- **地图↔实现漂移触点登记**:在 `touchpoint-registry.md` **新增触点行**(类型=漂移点 spec↔代码),端点 = `design-context-map.md` 住址指针列 ↔ 被指向的设计文档/README/代码实际内容;判据 = 存在性(住址指向的锚还在不在)+ 单源派生一致(地图成员 glob 还覆盖不覆盖实际模块成员)。drift-scout 收口凭证批查此触点 → 地图指针失效 / 模块成员漂移 → 🔴。
- **登记顺序**(沿 touchpoint-registry §维护 + credentials §8 第 9 条):新触点先确认源(本 spec / 地图),再同步 touchpoint-registry 新增行(顺序不可反)。**注**:此登记是**本 spec 落地时的一次性动作**(在 touchpoint-registry 加 1-2 行),命中 `docs/governance/*.md` 凭证义务,与本批 audit 同批(§8.3)。

**自检**:
- [x] 数据流每步类型一致?(地图行→ModuleRow→第一跳 file→模块→第二跳按 scenario 取片→ContextSlice→briefing 对象,贯通)
- [x] 实体字段覆盖接口用的数据?(module/memberGlob/contracts 都用上;scenario 决定取片;⚠️ 兜 file 未匹配/料缺)
- [x] 状态机无死状态?(每 file 必落 命中模块 / ⚠️未匹配;每片必落 gist / ⚠️料缺;整体必落 Briefing / EmptyHanded;无悬空)
- [x] 字段命名规范明确?(地图列名 = 内容模型类目;briefing 字段沿 §3.1;住址指针 `文件:锚` 格式)
- [x] 数据校验在哪做明确?(scout 读表识别数据行=§4.1;第一跳 glob 匹配=§4.2;路径解析=§4.4 复用 ③b;片选取=§4.3)

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 场景 | 输入条件 | 期望行为 |
|------|---------|---------|
| 地图读不到 | `design-context-map.md` 不在 / scout Read 失败 | scout 返回 `EmptyHanded{reason:"地图读不到"}` → 调度者软提醒,不阻断写码 |
| 地图空表 / 无模块行 | 文件在但无业务模块数据行(自仓库 dogfood 边界:自仓库不建数据) | scout 返回 `EmptyHanded{reason:"地图无模块行(自仓库 dogfood 边界 / 下游未填)"}` → 不报错 |
| touchedFiles 空 | 调度者未传正在动的文件 | scout 整图概览模式:只回"有哪些业务模块"(不给具体片);briefing 注"未传 touchedFiles,仅概览" |
| 第一跳匹配不上(赌注③) | touchedFiles 不落任何 memberGlob | 该 file 进 `unsure[]` ⚠️ "未匹配到业务模块,模块边界待厘清";**不硬猜模块**(file→module 糊时不编造) |
| 第二跳住址料缺(赌注①) | 地图住址列="—" 或指向的设计文档/README 下游没写 | 该片 ⚠️/skip,detail "下游未写<该类>设计背景,见 `docs/governance/design-context-migration.md` 迁移指南(§8.4)该类住哪/怎么补";**不编造内容**(只递已有料;EmptyHanded 闭环 B3:不只说"没料",指明缺哪类 + 去哪补) |
| 住址指针失效 | 地图住址锚指向的内容已被改名/删除 | 该片 ⚠️ "住址指针失效,见 drift-scout 收口检测";briefing 提示(漂移由 ③b 收口逮,§4.5) |
| 描述性住址锚定位不到 | 住址锚是描述非字面,scout 读不出指哪段 | 该片 ⚠️ "住址锚为描述性,未定位到实际内容,需人核"(同 ③b 死结一处理,不误判料缺) |
| 全角符号污染住址锚 | 住址锚含全角 `｜：，「」` 致定位失败 | 该片 ⚠️ "疑似全角符号,住址锚约定半角"(§4.4 全角护栏) |
| touchedFiles 跨多模块 | 正在动的文件落在多个业务模块 | briefing `modules[]` 多条,各模块各自取片(不合并,让调度者看清跨模块) |
| 全无料 | 地图无对应模块行 ∧ 住址料全缺 | scout 返回 `EmptyHanded{missingKinds, seeGuide}` → 调度者一句话提示(带缺哪类 + 指迁移指南去哪补,B3 闭环),不刷屏(全干净静默惯例) |
| fork 失败 | 超时/上下文溢出/工具不可用 | 调度者捕获 → 软提醒"本次设计背景未拉(fork 失败)" → 不阻断写码、不算欠账(软强度) |
| 无 agent 运行时 | 纯人工模式 | 跳过 design-context-scout,软提醒(诚实降级,同 ③b/freshness);AI 回落自己读代码(原状,本机制只增量不退化);**不阻断写码/收口、不算欠账**(软强度,对称 fork 失败行) |

### 5.2 错误传播路径

```
[地图读不到/无料]      → [scout 返回 EmptyHanded] → [调度者软提醒] → [不阻断写码]
[fork 失败/无 agent]   → [调度者捕获] → [软提醒 + 回落 AI 自读代码(原状)] → [不阻断、不算欠账]
[单 file 未匹配模块]    → [该 file ⚠️ 进 unsure[]] → [收集进 briefing] → [不中断其余 file]
[单片住址料缺/失效]     → [该片 ⚠️ + detail] → [收集进 briefing] → [其余片照拉]
[正常模块片]           → [ContextSlice gist + pointer] → [进 modules[]] → [调度者据此写码/调试/重构]
```

无吞错路径:致命错(地图无料/fork 失败)走 EmptyHanded + 软提醒(显式可见);单 file/单片错走 ⚠️ 入 briefing(显式可见,带住址留痕),**没有静默丢弃**(除"全无料 → EmptyHanded"——那是设计要的安静,非吞错)。**关键诚实**:fork 失败/无 agent 时 AI 回落"自己读代码"= **本机制上线前的原状**——本机制是**增量**(读不全的风险残留,赌注②),不引入新退化。

### 5.3 报告分层 vs 全干净静默(明确判据)

- **全干净静默(EmptyHanded)**:**无任何模块可 brief**(第一跳全不命中 = 地图无对应模块行 ∨ 地图空表/读不到)→ scout 返回 `EmptyHanded{reason}` → 调度者只输出一句话(如"本块暂无设计背景料,下游未写设计文档/README")(沿 ③b/freshness"全干净静默"惯例,不刷长报告)。**注**:某模块命中但住址料全缺 → 走 Briefing(该模块 slices 全 ⚠️),非 EmptyHanded(对齐 §5.1「全无料」∧ 判据;『匹配到但没写』与『没匹配到』是不同信号)。
- **报告分层(Briefing)**:有料 → scout 返回 `Briefing`,调度者据分层展示:
  - **正常 briefing 逐模块**:每模块列取的片(kind + pointer + gist),调度者据此写码/调试/重构。
  - **⚠️ 逐条**:file 未匹配模块 / 住址料缺 / 定位不准 → `unsure[]` 逐条,调度者复核模块边界 / 推下游补料 / 人核。
  - **briefing 一小段**:gist 是**一两句要点 + 指针**,不抄原文/代码(§D 镜头1:大部分场景只要一小块;不塞全部知识进窗)。

**自检**:
- [x] 每个接口错误情况有边界处理?(§5.1 覆盖地图无料/touchedFiles空/未匹配/料缺/指针失效/描述性锚/全角/跨模块/fork失败/无agent)
- [x] 错误传播完整无吞错?(§5.2 五条路径,显式可见 + 住址留痕)
- [x] 用户看到有意义错误?(⚠️ 附 file/片 + 原因;EmptyHanded 附 reason;不给技术堆栈)
- [x] 核心场景异常路径都有边界?(写码/调试/重构片→料缺/未匹配/失效边界;报告分层→§5.3;pull/降级→fork失败/无agent边界)

---

## 6. 测试策略

> harness-meta 验证:scout 是 fork 子智能体,验它 = **造有料地图看 scout 递对 briefing / 造无料看 EmptyHanded / 造模块边界糊看 ⚠️ 不硬猜**。LLM 推理过程不可单测,只测**输入→输出契约符合**。

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | mock 策略 |
|---------|---------|---------|----------|
| §1.2 场景1(write 片) | 造一份有料地图(1-2 模块,住址指向真设计文档/README)+ touchedFiles 落某模块 → scout 递"接口契约+边界+数据+业务规则"片,gist 是要点非抄代码 | 集成(fixture 地图) | 造 fixture 地图 + fixture 设计文档/README,fork scout |
| §1.2 场景2(debug 片) | 同 fixture,scenario=debug → scout 递"坑+已知问题+决定这块的业务/数据/接口"片(含 known-pitfalls 拉 + `// WHY:` grep) | 集成(fixture) | fixture 地图 + fixture 代码带 `// WHY:` 注释 |
| §1.2 场景3(refactor 片) | 同 fixture,scenario=refactor → scout 递"结构+边界+为什么这么划+残留 why"片(过度抽象护栏) | 集成(fixture) | fixture 地图 + fixture decisions/ |
| §5.1 赌注①·住址料缺 | 地图住址列="—" 或指向不存在的设计文档 → scout 该片 ⚠️ "下游未写",**不编造内容** | 集成(fixture) | fixture 地图留"—"/指空 |
| §5.1 赌注③·模块边界糊 | touchedFiles 不落任何 memberGlob → scout ⚠️ "未匹配,模块边界待厘清",**不硬猜** | 集成(fixture) | fixture 地图 + 不匹配的 touchedFiles |
| §5.1 全无料(EmptyHanded) | 空地图 / 无模块行(自仓库 dogfood 边界)→ scout 返回 EmptyHanded → 调度者一句话 | 集成 | 跑自仓库真地图(无数据行)或空 fixture |
| §4.4 三前缀解析 | scout 对 `<root>/...` / `harness/...` / 裸 `docs/...` 三类住址各能定位(复用 ③b) | 集成 | fixture 地图含三类住址 |
| §4.5 保鲜触点 | 在 touchpoint-registry 加地图漂移触点行 → drift-scout 能查到该触点(改地图指针 → 🔴) | 集成(与 ③b 联测) | 改 fixture 地图指针 + 跑 drift-scout |
| §5.1 fork 失败/无 agent | 模拟 fork 失败 → 调度者软提醒 + 回落 AI 自读代码,不阻断 | 集成 | 模拟 fork 不可用 |

### 6.2 测试边界

- **不测**:scout 内部 LLM 推理过程(不可单测 LLM 判断);只测 **scout 输入→输出契约符合**(造有料看 briefing、造无料看 EmptyHanded、造边界糊看 ⚠️)。
- **不测**:下游真实项目的稳定性(误报/漏报/刷屏感)——**自仓库 dogfood 审不到**(自仓库不建地图数据,§10.2);推真实项目实战验(赌注 + memory `feedback_realworld_testing_in_other_projects.md`)。
- **harness-meta 静态核**:除 fork 测试,收口时按 harness 惯例做静态核——确认 `design-context-scout.md` 形态正确(HTML 注释非 YAML frontmatter)+ setup.sh 已加 scout cp 行(否则 drift-scout 自指报 🔴 漏分发,§8.1)+ **setup.sh 地图走活文件守卫 cp(`if [ ! -f ... ]`)且已排除出 governance 无条件循环、migration 留在循环段**(否则下游重装覆盖活地图 / 或地图漏分发,§8.1)+ 地图模板形态正确(机读表 + frontmatter)+ touchpoint-registry 已加保鲜触点行。
- **有料 briefing 红线测的意义**:验 scout **真能把已有设计背景拉到手边**(不是"scout 跑了不报错"就算过)。**至少跑两个红线**:(a) 有料地图 → scout 递对应 scenario 的片且 gist 不抄代码;(b) 料缺/边界糊 → scout ⚠️ 不编造不硬猜(验赌注①③暴露面被诚实标出,而非被掩盖)。

### 6.3 scout 退化的观察(不是测试,是诚实声明 — 过 spec_gap_masking 戒条)

> scout 与 ③b drift-scout / review-scout / freshness-scout 同族,**有退化风险**,且 LLM 判断**无法单测穷尽**。本节诚实声明,挂 meta-L4 实战观察(承认 + 不假装根除)。

- **退化模式**:scout 可能(a) 把 file 误匹配到错模块(第一跳判错,briefing 拉错块的料 — 最危险,误导写码);(b) gist 把代码逐字抄进来(违"只指不抄",制造会腐的镜像);(c) 料缺时编造"看似合理"的设计背景(违"不替项目产料"、违 spec_gap_masking);(d) 全角/描述性住址锚定位错对象。
- **本设计降低退化的措施**(降低非根除):① 地图住址列明确(scout 有拉法依据,§4.1);② briefing 带 pointer 留痕(调度者能复核 scout 拉了哪个住址,判错可查);③ ⚠️ 兜底(scout 没把握/料缺标 ⚠️ 而非硬编/编造,交人核);④ 红线测(§6.1)验 scout 对有料真递对、对料缺真 ⚠️ 不编造;⑤ 保鲜闭环(④.5)由 ③b drift-scout 逮地图指针失效,降"拉到失效住址"概率。
- **三个诚实赌注的兜底**(§7 🟡 + §1.5):① **赌下游真写了设计文档/README**(没写→空手)——兜底:EmptyHanded 显式提示"下游未写",不掩盖;推真实项目验下游写作率。② **赌 pull 够**(AI 得记得 fork,无 push 强制力)——残留"读不全就漏"风险,与本机制上线前同;兜底:finishing 入口步明写"进场景 fork",但无 hook 强制(push 形态留 §7 🟡-2 反馈)。③ **赌业务模块边界清楚**(file→module 维护得住)——兜底:糊则第一跳 ⚠️ 不硬猜,推下游厘清 + drift-scout 逮模块成员漂移。
- **终兜**:scout 是**软**机制,所有退化的最终兜底仍是**AI 自己读代码 + 治理审查触点完整性维**(本机制上线前的原状;scout 是给它加"按场景拉到手边"的辅助,不取代)。meta-L4 观察 scout 实际误匹配率 / 编造率 / 下游写作率,据实战调整。**本设计不声称 scout 根除"读不全就漏 / 瞎删承重墙"**——降低概率,不等于零。

**自检**:
- [x] 每个核心场景有对应测试?(write/debug/refactor 片各有行 + 赌注①③ + EmptyHanded + 三前缀 + 保鲜 + 降级)
- [x] 每个边界条件有对应测试?(§5.1 地图无料/未匹配/料缺/三前缀 → §6.1 覆盖;描述性锚/判不准 → §6.3 声明不可单测)
- [x] 测试层级合理?(scout 是 fork,主要集成;有料/料缺用 fixture 地图 + fixture 设计文档红线)

---

## 7. 设计决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| D1 组织形态 | A: 大 wiki 全塞窗 / B: 按场景索引 + pull 拉一小块 | **B(按场景索引 + pull)** | §D 镜头1:大部分场景只要一小块,不要全知识;§D 镜头2:harness 做得好的(✅)共同点 = "进这个场景就自动读对应的东西"。B 把知识挂在它服务的场景上(写码/调试/重构),侦察员按 scenario 取片(§4.3),不塞全部进窗。反向追问(RUBRIC 应对):不按场景索引,三个缺口怎么解?→ 只能 AI 读全代码(漏)或大 wiki 全塞窗(腐 + 刷屏),都是原痛点 → B 是必要复杂度 |
| D2 是否新建独立 wiki 存业务规则/残留 why | A: 各开新文件(独立 wiki)/ B: 复用现有家,地图只聚索引 | **B(复用现有家)** | 业务规则权威留**设计文档单源**(地图聚锚点索引,只指不抄);残留 why 复用 **known-pitfalls-index** + 代码就近 `// WHY:` 注释。A 新建保鲜件 = 多一处会腐的双写(§A 表"别存逐字镜像散文")+ 违最小变更。B 不新建要保鲜的独立 wiki(§1.5 锁定) |
| D3 侦察员触发 | A: push hook 强制 / B: pull 主动 fork | **B(pull)** | 写码/调试/重构场景由 AI 临场进入,无干净的 push 触发点(不像收口有 finishing 闸);pull 贴"进场景 fork"语义,降级回落 AI 自读(同 ③b/freshness 软形态)。**诚实缺口**:pull 无强制力(赌注②,AI 得记得 fork)→ push 形态留 🟡-2 反馈,不在本轮做 |
| D4 侦察员只读不写 | A: scout 自动回写地图 / B: 只读地图 + 端点,只报 briefing | **B(只读)** | scout 自动改机读地图风险高(写坏 `\|` 格式 → 解析崩,自伤,同 ③b D4);"只读不写"守 scout 安全边界。地图维护由调度者/下游手工 + freshness/drift-scout 保鲜 |
| D5 退化与赌注怎么兜 | A: 声称 scout 准、不兜 / B: 住址列明确 + briefing 留痕 + ⚠️ 兜底 + EmptyHanded 不编造 + meta-L4 观察 | **B(诚实兜底)** | scout 同族有退化风险且 LLM 判断不可单测穷尽(§6.3);A 违 spec_gap_masking 戒条。B:住址列给拉法依据 + pointer 留痕可复核 + ⚠️ 不硬猜/料缺不编造 + 三赌注显式标缺口 + meta-L4 观实战。**不声称根除**"读不全就漏" |
| D6 地图住址 | A: docs/governance/ / B: docs/references/ | **A(governance)** | 地图是机读注册表 + 业务模块权威清单(同 touchpoint-registry 性质同住址);落 governance 被三机制自动纳管:freshness 核心集 + credentials `docs/governance/*.md` 凭证 glob + drift-scout 触点保鲜,均按"住 governance"自动接线(§2.1 注)。**分发方式例外**:地图是下游逐模块填的**可写活文档**,故 setup.sh **不**走 governance 无条件循环 cp(会覆盖下游成果),改**活文件守卫 cp**(I7,同 handoff.md/index.md;§8.1)——住址仍 governance、freshness/credentials/drift 三机制不变,**只 cp 方式从无条件循环改守卫**。B(references)freshness 仅增量采纳、非权威清单语义,否 |
| D7 business-module-map 旧件 | A: 升格为权威清单 / B: 留痕不动,新建 design-context-map | **B(新建,旧件留痕)** | §1.5 锁定:business-module-map 继续当留痕(immutable 草案视图);新地图才是权威清单。旧件升格 = 改 immutable 留痕件(违留痕约定)+ 它无"各设计背景住址列"(用途不同)。新建独立工件、可独立演进 |

> **D8 refactor 场景纳入范围的决策溯源(留痕)**:refactor 场景**保留在 [P0]**(三场景片之一,§1.2/§4.3)是**用户 2026-06-17 两次确认**的结果,但这一决定有过反复,留痕如下,防"看着一直在范围里"的失真:重构场景**初由用户押后**(2026-06-16 15:18 用户:"先做写代码和调试…复用/抽象/系统结构后面讨论");AI 以"重构所需的料(系统结构/边界/为什么这么划/残留 why)随写代码场景已共享同一份地图 + 同一个侦察员,押后 refactor 不省工、是'伪选择'"论证折回;**用户 2026-06-17 两次确认纳入 P0**(范围保留三场景:系统结构 + 边界 + 为什么这么划 + 过度抽象护栏,§4.3 refactor 行)。本溯源不改 scope(refactor 仍 [P0]),只补"为什么它在范围里"的决策路径,供 design-review / 后续复核对账。

### RUBRIC 应对方式

- **最小变更(规则5)**:新地图 + 新 scout 单一职责;finishing 只加入口步;setup.sh 只加分发;两洞复用现有家不新建 wiki(D2)。每行 diff 可追溯。
- **简洁性 / 过度工程化(戒条 — 反向追问)**:"不用'按场景索引 + pull 侦察员'怎么解 B 表三缺口(写码/调试/重构)?"→ 只能 AI 读全代码(漏,原痛点)或大 wiki 全塞窗(腐 + 刷屏 + §D 镜头1 否定)→ 找不到更简替代解法 → **是必要复杂度,非过度工程**。两洞补法选"复用现有家"正是简洁侧的克制(不新建保鲜件)。
- **spec_gap_masking(戒条)**:三个诚实赌注(§1.5/§6.3)+ 🟡-1/🟡-2/🟡-3(下游写作率不可控 / pull 无强制 / 模块边界清不清)显式标"已知缺口"+ 技术原因(无 push 触发点 / 下游自治 / file→module 维护靠下游)+ 补救方向(EmptyHanded 不编造且回指迁移指南 / push 形态留后 / 第一跳 ⚠️ 不硬猜 + drift-scout 逮成员漂移 + 迁移指南帮厘清边界)。§6.3 诚实声明 scout 退化、不假装根除。正是戒条要的"承认 + 技术原因 + 补救方向"。
- **二公设(做事/判断分离)**:scout 做事(拉料消化 briefing),不替判断(料怎么用、信不信归调度者/实现者);只读不写守边界(公设1);不确定时 Read 端点不内省(公设2)。
- **bootstrap 不可证(戒条)**:本机制"是否真降低漏改/回归率"在下游真实项目落地前**不可证**(自仓库 dogfood 审不到)——声明 + 推真实项目实战验(§10.2),不算缺陷(memory `feedback_unprovable_in_bootstrap.md`)。

### 待用户决定的 🟡

- **🟡-1(下游写作率不可控,赌注①)**:本机制赌"下游真写了设计文档/README"。下游若不写 → 侦察员**空手而归**(EmptyHanded,不编造)。这是**机制有效性的外部依赖**,非本 spec 可闭合。**补救方向**:EmptyHanded 显式提示"下游未写<该类>",可考虑后续在 finishing 加"侦察员长期空手 → 提醒下游补设计文档"的软统计(留后,不在本轮)。需用户拍板是否接受"下游不写则本机制空转"为已知边界。
- **🟡-2(pull 无 push 强制,赌注②)**:侦察员是 pull 主动 fork,无 hook 强制力 → AI 若忘记 fork,残留"读不全就漏"风险(与上线前同)。**补救方向**:未来若实战发现"AI 常忘 fork",考虑 push 形态(如进 implementation 阶段的 hook 软提醒"要不要拉设计背景")。本轮采纳 D3=pull(无干净 push 触发点),push 形态作反馈交回。需用户拍板是否接受 pull 残留风险为本轮边界。
- **🟡-3(业务模块边界清不清,赌注③)**:本机制赌"业务模块边界清楚 + file→module 映射维护得住"(第一跳 touchedFiles → memberGlob 匹配靠它)。**对称 🟡-1/🟡-2 的外部依赖**:边界糊则第一跳**系统性 ⚠️ 误匹配 / 漏匹配**——这是**三赌注里最危险的退化**(误匹配会把别块的料拉来误导写码,见 §6.3 退化模式 a;漏匹配则全模块空手)。**补救方向(三重兜底)**:① 第一跳不硬猜(对不上标 ⚠️,§5.1 赌注③行),不编造模块归属;② drift-scout 收口凭证批逮"模块成员漂移"(地图 memberGlob ↔ 实际模块成员派生不一致,§4.5),帮发现边界腐化;③ **迁移指南(§8.4 / B2)按业务能力切模块**帮下游一开始就把边界划清(memory `feedback_module_cut_by_business.md`:按业务能力切不按材料切)。需用户拍板是否接受"边界糊则第一跳 ⚠️ 退化"为已知边界。

> 决策不确定项已记入本节 🟡-1/🟡-2/🟡-3(均为**外部依赖 / 形态增强**方向,**不阻塞**本机制落地——scout pull + 第一跳 ⚠️ 不硬猜 + EmptyHanded 已自洽闭合)。无阻塞接口/数据/架构的待决策。**注**:🟡-1/🟡-2/🟡-3 是否另立 `docs/decisions/` 文件由调度者收口时按 finishing-rules decision 立档规则判(本 spec 已在此显式留痕)。

**自检**:
- [x] 每个决策原因具体可验证?(D1-D7 均指 §D 镜头/§A 表/§1.5 锁定/③b 范式/memory feedback,无"更好"空话)
- [x] 有决策与架构冲突?(无;scout 形态与 ③b/freshness/review-scout 同族,守扁平 fork;地图与 touchpoint-registry 同住址同范式)
- [x] 有决策与 RUBRIC 惩罚项冲突?(无;D1/D2 正面应对简洁性/过度工程,D5 应对 spec_gap_masking)
- [x] 不确定决策写入并标 🟡?(🟡-1/🟡-2/🟡-3 已标,对应赌注①/②/③,均不阻塞)
- [x] §1.6 每个 RUBRIC 惩罚项有应对?(最小变更/简洁性/spec_gap_masking/二公设/bootstrap 逐条应对)

---

## 8. 与既有系统的影响

### 8.1 需要改动的已有文件

| 文件 | 改什么 | 为什么 | 影响范围 |
|------|-------|--------|---------|
| `docs/governance/finishing-rules.md` | 在「触点漂移检测」节附近**新增一节**「设计背景到手边(写码/调试/重构入口)」:指明进写代码/调试/重构场景时 **pull fork** `design-context-scout`(注入 `{scenario, touchedFiles, mapPointer, repoRoot, today}`),消费 briefing(据 slices 写码 / ⚠️ 复核模块边界 / EmptyHanded 一句话继续);明确**软、不阻断、只读不写**;**无 agent / fork 失败 → 回落 AI 自读代码**(诚实降级)。**另**:本节同时记 **保鲜触点登记**(地图登进 touchpoint-registry,§4.5) | 写码/调试/重构场景无干净 push 触发点,靠 finishing 入口步指引 pull;否则没人 fork 它(赌注②) | 收口/入口流程(调度者);不动既有步,只追加一节 |
| `setup.sh` | ① agents **逐 cp 行区**加一行 `cp "$SCRIPT_DIR/.claude/agents/design-context-scout.md" "$TARGET_DIR/.claude/agents/"`(像 drift-scout/freshness-scout 那行);② **地图 `design-context-map.md` 排除出 governance 无条件循环 + 加活文件守卫 cp**(I7,同 handoff.md/index.md:`if [ ! -f "$TARGET_DIR/docs/governance/design-context-map.md" ]; then cp 模板...; fi`);③ 只读的 `design-context-migration.md` **随 governance `*.md` 无条件循环分发**(不加守卫);④ **安装末尾 echo 段加一句**指向迁移指南(§8.4 B2,"已有项目搬进地图格式见 `docs/governance/design-context-migration.md`") | scout 属**逐 cp 行**分发模型(§4.5 ③b 同理),**不加则 drift-scout 自指报 🔴 漏分发**(scout 自己落 `.claude/agents/*.md`,被 ③b TP-09 查);**地图是下游逐模块填的可写活文档**,无条件循环 cp 会覆盖下游成果 → 须活文件守卫(同 handoff.md);**migration 是只读指南**,无条件循环 cp 总刷新正确;echo 指引让下游安装后知道"怎么搬进格式"(赌注① 抓手) | 下游分发范围(多分发 1 个 agent + 1 个 governance 只读指南 + 1 个守卫式地图模板)+ 安装末尾提示 |
| `docs/governance/design-context-migration.md` | **新建·只读迁移指南**(原 README 迁移指南正文搬此):必备内容清单 11 类(B1)+ 一个已有项目搬进地图格式三步(按业务能力切模块 → 一模块一行填地图 → 照清单确保住址有料,§8.4 B2)。**随 governance `*.md` 无条件循环分发到下游**(只读指南总刷新正确) | 赌注① 落地抓手——光赌"下游写了"不行,给可勾清单 + 可填模板;**住 governance(随分发 + 命中 `docs/governance/*.md` 凭证),不住根 README**(根 README **不分发下游**,setup.sh 无 cp 根 README 行 → 放 README 则下游拿不到指南、EmptyHanded.seeGuide 悬空、抓手对下游失效;known-pitfalls-index L56 已记 README 不分发) | 下游(随 governance 分发,EmptyHanded.seeGuide 指它);**命中 `docs/governance/*.md`** → 进 audit covers(§8.3 第 8 项) |
| `docs/governance/touchpoint-registry.md` | **新增 1-2 行触点**:地图住址漂移点(`design-context-map.md` 住址列 ↔ 被指向的设计文档/README/代码)+ 地图成员 glob 漂移点(成员 glob ↔ 实际模块成员)。类型=漂移点(spec↔代码)/ 判据=存在性+单源派生一致 | 地图是活文档会腐,复用 ③b drift-scout 保鲜闭环逮指针失效/成员漂移(§4.5);先确认源再同步注册表(顺序不可反) | drift-scout 收口检测范围(多查 1-2 触点);TP-13 §8↔注册表派生一致须同步(若涉 §8 则同改) |
| `docs/references/DESIGN_TEMPLATE.md`(可能) | 加节:设计文档「业务规则」段约定(洞①:业务规则权威住设计文档,供地图聚索引)+ 「并发/同步/排序约束」在 §5 边界条件加一列理由(现有加节,§1.5) | 洞①业务规则单源住设计文档,模板须给"业务规则段"体裁,否则下游不知往哪写、地图无锚可聚 | 下游设计文档体裁(加节);命中 `docs/references/DESIGN_TEMPLATE.md` 凭证 glob |
| `docs/references/MODULE_DOC_TEMPLATE.md`(可能) | 强化「对外接口」「约束和规则」「已知问题和技术债」段为侦察员可定位的稳定锚(已有这些段,可能只需注明"侦察员据此拉";洞②残留 why 注释体裁可在此或 implementation-rules 提一句 `// WHY:` 约定) | 侦察员第二跳照住址 Read 模块 README 这几段,锚需稳定;洞②代码注释体裁需有约定处 | 下游模块 README 体裁(可能仅注明);MODULE_DOC 不在 credentials 凭证 glob(`docs/references/*` 仅 DESIGN_TEMPLATE 命中),改它无 audit 义务但仍随 setup.sh 分发 |

> **新建文件**(不算"改动既有"):`docs/governance/design-context-map.md`(机读地图,模板/占位形态)+ `.claude/agents/design-context-scout.md`(说明型子智能体契约,§2.1 形态说明)。
>
> **DESIGN_TEMPLATE/MODULE_DOC 加节的"可能"判定**:洞①业务规则需 DESIGN_TEMPLATE 有"业务规则段"体裁是**较确定**的(否则地图无锚可聚);洞②残留 why 注释体裁挂哪(MODULE_DOC / implementation-rules / 仅约定)**待 implementation 阶段定**——本 spec 标"可能加节",writing-plans 时按"洞补法落地需不需要体裁支撑"拍。**保守**:若加,命中对应凭证 glob,纳本批 audit(§8.3)。
>
> **洞② `// WHY:` 必要性复核(防默认加约定未复核,A6)**:writing-plans 落地 `// WHY: 防[X],见[路径]` 注释约定**前**,须**显式回答一个问题:不加 `// WHY:` 注释、仅靠 known-pitfalls-index(留"已关闭"行对照)能否覆盖洞②(残留 why / Chesterton 栅栏)?** 若 known-pitfalls-index 已能让 scout 在 refactor/debug 场景拉到"这段为什么在"(承重墙留痕),则 `// WHY:` 注释约定**可能冗余**,不默认加。仅当复核确认"代码就近注释比集中索引更能防瞎删承重墙"(如索引覆盖不到的零散 guard)时才落约定。**理由**:洞②补法定的是"复用 known-pitfalls-index + 代码就近注释"双轨(§1.5),但双轨是否都必需未复核——不复核就默认加注释约定 = 多一处会腐的双写(违 D2 简洁侧克制),须 writing-plans 显式判后再落。

### 8.2 不改动但需要验证兼容的

| 文件/模块 | 验证什么 |
|----------|---------|
| ③b `drift-scout.md` + `touchpoint-registry.md` | design-context-scout 与 drift-scout **同形态、互补不互调**;design-context-map 登进 touchpoint-registry 后被 drift-scout 查漂移(§4.5)——验证新增触点行格式合 ③a 注册表 schema,drift-scout 能消费 |
| freshness-scout / review-scout / research-scout | design-context-scout 与它们同形态(说明型子智能体)、**不互调**;验证新增 scout 不影响它们;复用其形态范式(HTML 注释标签 / 入参出参契约 / fork 失败降级) |
| 现有 6 个 `check-*` hook | design-context-scout 不是 hook、不 import/不被它们调用,**零改**;不进 settings.json hook 注册(pull fork 子智能体,非 Stop/PostToolUse 自动 hook) |
| `references/2026-06-10-business-module-map.md` | **不动**(留痕草案视图);验证新地图 design-context-map 是独立权威清单,不迁移/不删旧件(§7 D7) |
| `freshness-rules.md` 范围清单 | `design-context-map.md` 落 `docs/governance/*.md` 已在 freshness 核心集(范围清单),**自动纳保鲜**——验证无需显式加行(若审查认为需显式,则加一行,命中 governance 凭证 glob)。**注**:地图走活文件守卫 cp(非无条件循环),不改其 freshness/credentials/drift 归属——三机制仍按"住 governance"自动纳管,只是分发 cp 方式从无条件循环改守卫(§7 D6) |
| `setup.sh` 其余分发段 | agents 逐 cp 段加一行 scout cp;**governance 循环段须排除地图 `design-context-map.md`**(改走活文件守卫 cp)、`design-context-migration.md` 留在循环段(只读无条件刷);**不动** hooks 循环段、不动其余 agents/governance cp 行,验证落点正确 |

### 8.3 凭证义务(收口前必做)

- 本 spec 落地改动命中 `credentials.conf`:
  - `.claude/agents/*.md`(新 `design-context-scout.md`)
  - `docs/governance/*.md`(新 `design-context-map.md` + 新 `design-context-migration.md` + 改 `finishing-rules.md` + 改 `touchpoint-registry.md`)
  - `setup.sh`(加 scout cp 行 + 地图守卫 cp + migration 循环 + echo 指引)
  - `docs/references/DESIGN_TEMPLATE.md`(若加节)
- **注**:迁移指南正文搬出根 README、改住 `docs/governance/design-context-migration.md`(🔴-A 修正)后,**本 spec 不再改根 README**(README 不分发下游,放它则下游拿不到指南);故 covers 不含 README。
- 收口前须按 finishing-rules「凭证义务核对」step 15-18 产 **audit 凭证**(对抗审查,covers 列出:`.claude/agents/design-context-scout.md` + `docs/governance/design-context-map.md` + `docs/governance/design-context-migration.md` + `docs/governance/finishing-rules.md` + `docs/governance/touchpoint-registry.md` + `setup.sh` [+ `docs/references/DESIGN_TEMPLATE.md` 若改])。非 typo,**不走 exempt**。
- **covers 候选清单(显式列)**:
  1. `.claude/agents/design-context-scout.md`(新建,命中 `.claude/agents/*.md`)
  2. `docs/governance/design-context-map.md`(新建,命中 `docs/governance/*.md`)
  3. `docs/governance/finishing-rules.md`(改动,命中 `docs/governance/*.md`)
  4. `docs/governance/touchpoint-registry.md`(改动:加保鲜触点行,命中 `docs/governance/*.md`)
  5. `setup.sh`(改动,命中 `setup.sh`)
  6. `docs/references/DESIGN_TEMPLATE.md`(命中 `docs/references/DESIGN_TEMPLATE.md`)——**conditional 升格**:洞①业务规则段自评"较确定需要"(§8.1 注:否则地图无锚可聚)。**若 design-review / writing-plans 判洞①落地必须加 DESIGN_TEMPLATE 业务规则段,则本项从「可能」升「必含」**(保守纳本批 audit);若届时判洞①不需新模板段(如复用现有 §1 场景段即可),则降为不改、出 covers。**默认保守**:倾向"较确定需要"→ 预置在 covers,落地若确不改再剔。
  7. (`docs/references/MODULE_DOC_TEMPLATE.md` 若改 — **不命中** credentials.conf,无 audit 义务,但随分发)
  8. `docs/governance/design-context-migration.md`(新建:迁移指南正文,§8.4 / B2)——**命中 `docs/governance/*.md` 凭证 glob → 进本批 audit covers**。(🔴-A 修正:迁移指南正文从根 README 搬到此只读 governance 文档;**本 spec 不再改根 README**——根 README 不分发下游,放它则 EmptyHanded.seeGuide 在下游悬空、抓手失效,known-pitfalls-index L56 已记 README 不分发。故 covers 不含 README,README 凭证义务问题随之消解。)
  9. `setup.sh` echo 段(已含在第 5 项 `setup.sh` 内:加迁移指南指引 echo,§8.4 / B2)——同 setup.sh 凭证 glob,已纳。
- **双写同步检查**:若本批在 `touchpoint-registry.md` 加触点行,且该触点源自 §8 双写义务 → 须同步 credentials-rules §8(TP-13 单源派生一致,credentials §8 第 9 条)。本 spec 加的是**体检/新机制来源**触点(地图保鲜),非 §8 双写义务派生 → 比照 TP-09~12(体检来源行,无 §8 对应),**只加注册表行,不动 §8**(注册表 §维护:体检来源行不要求 §8 计数相等)。
- 🟡-1/🟡-2/🟡-3 若另立 decision 文件 → `docs/decisions/*.md` **不命中** credentials.conf(decisions 非凭证 glob),无 audit 义务。

### 8.4 下游迁移指南(必备内容清单 + 迁移格式 — 赌注① 落地抓手)

> **动机**:本机制赌"下游真写了设计文档/README"(赌注①)。光赌不行——给下游一份**必备内容清单(B1)+ 迁移格式(B2)**,把赌注① 从"赌他写"变"给了可勾清单 + 可填模板"。本节是 spec 权威源;**迁移指南正文落 `docs/governance/design-context-migration.md`(只读 governance 文档,随 governance `*.md` 循环分发)+ setup.sh 安装末尾 echo 指过去**(住址形态:格式样板住地图模板,迁移步骤住 migration 文档 + setup.sh echo 一句)。
>
> **🔴-A 修正(迁移指南为何不住根 README)**:根 README **不分发下游**(setup.sh 无 cp 根 README 行,known-pitfalls-index L56 已记)。若迁移指南住根 README → 下游 clone/setup 后**拿不到指南**、EmptyHanded.seeGuide 指向的住址在下游**悬空**、赌注① 抓手对下游**失效**。故迁移指南正文改住随分发的只读文档 `docs/governance/design-context-migration.md`(命中 `docs/governance/*.md` 凭证 → 进 audit covers,§8.3 第 8 项)。下文 B2-2 / seeGuide 一律指此文档,不再涉 README。

#### B1. 必备内容清单(11 类设计层内容,完整覆盖 — 下游须外化的"代码答不出的那层")

> 每类标"住哪 / 哪个 harness 模板"。下游照模板写齐 → 侦察员第二跳照地图住址即能拉到;**11 类里 9 类 harness 现成模板已给位置,真要新加约定的只有 2 条(业务规则段 + `// WHY:` 注释 = 本设计两个洞)**。

| 必备内容 | 住哪 / 模板 | 现成 / 新约定 |
|---|---|---|
| 意图 / 真问题 | 设计文档 §1 | 现成(DESIGN_TEMPLATE) |
| 数据库 / 数据模型(实体 / schema / 状态) | 设计文档 §4 | 现成(DESIGN_TEMPLATE) |
| 接口契约 | 设计文档 §3 + 模块 README 对外接口 | 现成(DESIGN_TEMPLATE + MODULE_DOC) |
| 业务流程 / 业务规则 | 设计文档 §1 场景 + **业务规则段(洞①·新约定)** | **新约定(洞①)** |
| 模块边界 / 职责 / 依赖 | ARCHITECTURE + 模块 README 职责 | 现成(ARCHITECTURE + MODULE_DOC) |
| 设计决策 / 取舍 | decisions/ + 设计文档 §7 | 现成(decisions/ + DESIGN_TEMPLATE) |
| 不变量 / 硬约束 | ARCHITECTURE + 模块 README 约束段 | 现成(ARCHITECTURE + MODULE_DOC) |
| 非功能约束(性能 / 安全 / 合规) | 设计文档 §1.3 / §7 | 现成(DESIGN_TEMPLATE) |
| 并发 / 同步 / 排序约束 | 设计文档 §5 | 现成(DESIGN_TEMPLATE §5,洞①并发列加一列理由) |
| 已知坑 / 技术债 | 坑索引 + 模块 README 已知问题 | 现成(known-pitfalls-index + MODULE_DOC) |
| 残留 why(承重墙) | 代码 **`// WHY:` 注释(洞②·新约定)** | **新约定(洞②;必要性 writing-plans 复核,§8.1)** |

> **关键认知(写进 spec)**:11 类 = 设计层"代码答不出的那层"的完整外化清单。**9 类靠现成模板**(DESIGN_TEMPLATE / MODULE_DOC / decisions/ / 坑索引)下游照填即有;**2 类是本设计的两个洞**(业务规则段 + `// WHY:` 注释)——洞①较确定要加 DESIGN_TEMPLATE 段(§8.1),洞②必要性 writing-plans 显式复核后再落(§8.1 A6)。这印证 D2"复用现有家不新建 wiki":绝大多数内容现成有家,本设计只补 2 个洞 + 1 张索引地图。

#### B2. 迁移格式三件(给下游"怎么搬进格式")

**B2-1. 地图模板自带格式**(`design-context-map.md` 模板,随 governance `*.md` 分发):
- = **列头(§4.1 主表行)+ 一行示意样板行 + "怎么填"内联注**。样板行演示"模块名 | 成员 glob | 各设计背景住址"格式:

```
| 业务模块 | 成员文件 glob | 接口契约 | 数据模型 | 模块边界 | 取舍决策 | 不变量约束 | 既知坑/已知问题 | 业务规则索引 | 并发/同步/排序约束 |
|---|---|---|---|---|---|---|---|---|---|
<!-- 示意样板行(填法演示,非真实数据;下游按此格式逐模块填,自仓库不填——dogfood 边界 §10.2): -->
| 订单 | src/order/**;src/checkout/** | design/order.md:§3 | design/order.md:§4 | ARCHITECTURE.md:订单层 + src/order/README.md:职责 | decisions/2025-xx-order-split.md | ARCHITECTURE.md:订单不变量 | known-pitfalls-index.md:订单 + src/order/README.md:已知问题 | design/order.md:业务规则段 | design/order.md:§5 |
<!-- 怎么填:① 一模块一行;② 成员 glob 指本模块代码文件;③ 各列填"文件:锚"住址指针(只指不抄),无料填 —;④ 照 B1 清单确保住址真有料 -->
```

> 样板行**通用 / 示意**(订单模块演示),**非真实 harness 数据**——守 dogfood 边界(§10.2:自仓库不建数据,模板只给填法示意)。下游照样板行格式逐模块填,把各列指向自己的设计文档 / README / ARCHITECTURE / decisions / 坑索引。

**B2-2. 迁移指南**(住 `docs/governance/design-context-migration.md` + setup.sh 安装末尾 echo 指过去)——"一个已有项目怎么搬进格式"三步:
1. **按业务能力切业务模块**(不按材料切,memory `feedback_module_cut_by_business.md`:材料属性=模块内部的面,顶层切法是业务能力)→ 每模块定成员文件 glob;
2. **一模块一行填地图**:各列指向你的设计文档 / 模块 README / ARCHITECTURE / decisions / 坑索引(住址指针,只指不抄);
3. **照 B1 清单确保那些住址真有料**:侦察员只递**已写的**——契约写进 README 对外接口、业务规则写进设计文档业务规则段(洞①)、承重墙加 `// WHY:` 注释(洞②,若 writing-plans 判需要);缺哪类对照 B1 去补。

**B2-3. EmptyHanded 闭环**(回指 §3.1 / §5.1):侦察员空手时 reason **不只说"没料"**——带 `missingKinds` + `seeGuide`(指向 `docs/governance/design-context-migration.md` 迁移指南"去哪补")。让下游空手时知道"缺哪类、去哪补",而非只知"侦察员没拉到东西"。
> **`missingKinds` vs B1 11 类(消同名歧义,🟡-5)**:`missingKinds` = **本次该 scenario 该取却缺的可递片**(write/debug/refactor 各取片子集,§4.3:write 取 ≤5 类、debug 取 ≤5 类含残留 why grep、refactor 取 ≤4 类)——**不是 B1 全 11 类**;B1 11 类 = `seeGuide` 指向的 migration 文档里"下游必备内容"**更广全清单**(含意图 / 非功能约束等本 scout 各 scenario 都不拉的内容)。**两者非同集**:missingKinds 告诉"本次这个场景缺哪几片、能不能补上就立刻可递",B1 告诉"下游整体还该补哪些设计层内容";空手时 scout 报 missingKinds(本场景视角),用户/下游按 seeGuide 跳 migration 看 B1 全清单(全局视角)补料。

> **住址形态**:迁移格式拆三处住址——**格式样板住地图模板**(B2-1,随地图守卫 cp 分发)、**迁移步骤住 `docs/governance/design-context-migration.md`**(B2-2,只读 governance 文档,随 governance `*.md` 无条件循环分发)、**setup.sh 安装末尾 echo 一句指过去**(B2-2)。三者均随分发到下游。migration 文档命中 `docs/governance/*.md` 凭证 → 进 audit covers(§8.3 第 8 项);setup.sh echo 改动已纳 setup.sh 凭证(§8.3 第 5/9 项)。**不住根 README**(根 README 不分发,§8.4 🔴-A 修正)。

**自检**:
- [x] 改动已有文件时调用方都考虑?(finishing 调用方=调度者收口/入口;setup.sh 调用方=下游安装 + drift-scout 自查;touchpoint-registry 调用方=drift-scout 消费;DESIGN_TEMPLATE 调用方=下游写设计文档;migration 文档调用方=下游迁移者读指南 + scout EmptyHanded.seeGuide 指它;均点明影响)
- [x] 新旧模块交互无不兼容?(scout 与 ③b/freshness/review-scout + 6 hook 零耦合/不互调;地图与 touchpoint-registry 同 schema;不进 settings.json,§8.2)
- [x] §2 标"改动/新建"的模块都在此列出?(改动:finishing-rules + setup.sh + touchpoint-registry + DESIGN_TEMPLATE/MODULE_DOC;新建:design-context-map + design-context-scout + design-context-migration 均在 8.1/§8.4;business-module-map 标"不改"→ §8.2 验证;根 README 不改)
- [~] DESIGN_TEMPLATE 业务规则段(洞①)/ MODULE_DOC 强化(可能)/ `// WHY:` 注释约定(洞②必要性)**待 design-review·writing-plans 复核后定**(§8.1 注 + A6 + §8.3 covers 第 6 项 conditional),非本节闭合——故不打 `[x]`,留 `[~]` + 指针。

---

## 9. 全局自洽性检查

- [x] **需求 ↔ 模块**:写码场景→scout §4.3 write 片;调试→debug 片;重构→refactor 片;报告分层→scout §3.1+§5.3;pull/降级/只读不写→§7 D3/D4/D5。每场景有路径(地图 + scout + finishing 步)。
- [x] **模块 ↔ 接口**:地图职责通过 §4.1 行消费契约体现;scout 通过 §3.1 入参/出参契约体现;finishing 步通过"何时 pull fork + 消费 + 降级 + 保鲜登记"体现;setup.sh 通过"分发"体现。无孤岛。
- [x] **接口 ↔ 数据**:§3.1 出参(briefing:按场景的 ContextSlice + ⚠️)= §4.2 数据流末态;入参 scenario/touchedFiles/mapPointer 支撑 §4.2 两跳 + §4.3 片选取 + §4.1 读表。
- [x] **数据 ↔ 边界**:§4.1/§4.2 每要素(memberGlob 匹配 / 住址列 / scenario 片选取 / 三前缀)的异常在 §5.1 有处理(未匹配/料缺/指针失效/描述性锚/全角/跨模块/空表)。
- [x] **依赖 ↔ 架构**:规则→子智能体→数据单向(§2.2),符合扁平 fork 架构;与 ③b/freshness/review-scout + 6 hook 零耦合/不互调;地图与 touchpoint-registry 同住址同范式。
- [x] **决策 ↔ 需求**:D1-D7 不偏离锁定输入(按场景索引+pull / 复用现有家不新建 wiki / 只读不写 / 旧件留痕);D1 落实"按场景取片"、D5 落实"诚实兜赌注"。
- [x] **决策 ↔ 架构**:D3 pull fork 守扁平 fork(同 ③b/freshness);D4 只读不写守 scout 安全边界;D6 地图落 governance 守注册表同住址。
- [x] **影响 ↔ 模块**:§8.1 改动文件(finishing-rules + setup.sh + touchpoint-registry + DESIGN_TEMPLATE/MODULE_DOC)= §2.1 标"改动"模块;business-module-map 标"不改"→ §8.2 验证;新建 design-context-map + design-context-scout + design-context-migration → §2.1/§8.4 新建;§8.4 迁移指南正文住 `docs/governance/design-context-migration.md`(B2,**不住根 README**——🔴-A 修正);根 README 不改。
- [x] **RUBRIC ↔ 设计**:§1.6 每惩罚项(最小变更/简洁性/spec_gap_masking/二公设/bootstrap)在 §7 RUBRIC 应对方式逐条对应。
- [x] **契约 ↔ 接口**:无 API 端点(§3.3 不适用——harness-meta 机制);等价物 = §3.1 入参/出参契约 + §4.1 地图消费契约,覆盖 scout 读地图 + briefing 的全部字段。

---

## 10. 守住段 + 不做清单

### 10.1 守住(不破坏现有,显式声明)

- ③b `drift-scout.md` + `touchpoint-registry.md` 判据/类型 enum **零改**——design-context-map 登进注册表用现有"漂移点(spec↔代码)"类型 + 现有判据 enum(存在性/单源派生一致),不新增 enum。
- 现有 6 个 `check-*` hook **零改**——design-context-scout 是新增 pull fork 子智能体(非 hook),不动既有 hook、不进 settings.json 自动注册。
- freshness-scout / review-scout / research-scout / drift-scout 既有契约 **零改**——design-context-scout 复用其形态范式但独立文件,不改它们。
- `references/2026-06-10-business-module-map.md` **零改**——继续当留痕草案视图,不升格/不迁移/不删(§7 D7)。
- finishing 收口工序既有步 **零改**——只**新增**「设计背景到手边」一节 + 保鲜触点登记,不动既有步序。
- `credentials.conf` **不擅改**——新 `design-context-scout.md` 自动被 `.claude/agents/*.md audit` glob 纳管,新 `design-context-map.md` 自动被 `docs/governance/*.md audit` 纳管,无需新增 conf 行。
- `setup.sh` 既有 hooks 循环段 / 其余 agents·governance cp 行 **零改**——本 spec 对 setup.sh 的改动限于:① agents 逐 cp 段追加一行 scout cp;② **governance `*.md` 循环段排除地图 `design-context-map.md`**(改活文件守卫 cp,新增一段 `if [ ! -f ... ]; then cp 模板; fi`,同 handoff.md/index.md 既有守卫写法)——`design-context-migration.md` 等其余 governance `*.md` 仍走无条件循环;③ 安装末尾 echo 段追加一句指向 `docs/governance/design-context-migration.md`(§8.4 B2)。**守住声明同步**:循环段不再无条件覆盖地图(防覆盖下游填好的活地图),migration 只读指南仍随循环无条件刷新——两者分清,与 §8.1 改法一致。

### 10.2 不做清单(MVP 边界 + dogfood 边界)

- **不替项目产料**:侦察员只递已有料;下游没写设计文档/README → EmptyHanded 空手而归,不编造(赌注①)。
- **不抄代码**:gist 是要点 + 指针,代码 = SSoT;不复述代码(防镜像散文腐烂,§A 表)。
- **不新建要保鲜的独立 wiki**:业务规则留设计文档单源 + 地图聚索引;残留 why 复用 known-pitfalls-index + 代码 `// WHY:` 注释(D2)。
- **不升格 business-module-map 旧件**:旧件留痕不动,新建 design-context-map 当权威清单(D7)。
- **不 push、不硬阻断**:pull 主动 fork(无 hook 强制,赌注②);软,不挡写码/收口;push 形态留 🟡-2 反馈。
- **不让 scout 自动回写地图**:scout 只读不写,地图维护由调度者/下游手工 + freshness/drift-scout 保鲜(D4)。
- **不自仓库 dogfood 验稳定性**:**自仓库不建 `design-context-map.md` 数据**(dogfood 边界 — 自仓库用 README/现有 specs/decisions 当背景,不套产品式地图;同 living-context-chain 自仓库不建 docs/context/ 的 dogfood 边界)。仅下游分发模板/占位 + 侦察员契约;误报/漏报/刷屏感/下游写作率等稳定性靠**真实项目实战验**(memory `feedback_realworld_testing_in_other_projects.md` + bootstrap 不可证声明 §7)。
- **不声称根除"读不全就漏 / 瞎删承重墙"**:scout 降低概率,有退化风险(§6.3)+ 三诚实赌注(§7 🟡);终兜仍是 AI 自读代码 + 治理审查触点完整性维 + meta-L4 观察。

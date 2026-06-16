# ③b 漂移检测机制(drift-scout 收口子智能体)系统设计

> 知识系统 Step2 最后一步。在 ③a `touchpoint-registry.md`(13 触点机读表)地基之上,**收口时 fork 一个 `drift-scout` 子智能体**,读注册表、逐触点判端点是否对齐、报漂移(✅/🔴/⚠️),不阻断收口。
>
> brainstorming 拍板日期:2026-06-16(用户锁定输入,形态由上一版 **hook** 改为 **scout 子智能体**)。
>
> **本 spec 覆写历史**:上一版(同路径)是「收口 hook MVP」设计,**被自检否决**——根因:bash 在当前注册表"散文端点"上机械查不了有意义的判据(详 §1.7 + §4.3)。本版换 **scout 形态** 重写,保留 ③a 注册表零改、软、不阻断、收口触发等锁定输入,仅**形态**从 hook 换成 scout,并因此**取消上一版的 ⏭️ 机械盲区**(scout 能判散文端点,故覆盖全部 5 类判据)。

> **路径前缀约定**(双层仓,子智能体 scopeList / 端点解析据此,无歧义 — 与 `freshness-mechanism-design.md` 同约定):
> - `docs/...` 一律指 harness 自仓库的 `harness/docs/...`;
> - `.claude/...` 一律指 `harness/.claude/...`;
> - 根级 `/CLAUDE.md` · `/AGENTS.md` = **仓库根两份**(`<root>/CLAUDE.md` · `<root>/AGENTS.md`,M3 自治理入口),**区别于** `harness/CLAUDE.md`(M4 分发模板);
> - 从 repo 根写的 `harness/templates/AGENTS.md` = M4 分发版模板(注册表端点列里直接出现,scout 须识别这第三类写法);
> - 分发下游同形**去 `harness/` 前缀**。
> 三前缀解析的 scout 操作指引详 §4.4。

---

## 0. 偏离说明(结构差异)

- 无结构偏离。沿用 `DESIGN_TEMPLATE.md` 全部 9 节标题与编号,新增 §0(本节)+ §1.7(为何 scout 不 hook 的设计动机,挂在需求摘要内)+ §10(守住段 / 不做清单),与 harness 历来 spec(如 `2026-06-16-freshness-mechanism-design.md`)惯例一致。§0 只记结构差异,**不**用作 design-review 豁免依据(design-rules §spec §0 偏离规则)。
- **技术栈映射**:本功能产物 = **一个 fork 子智能体的行为契约(`drift-scout.md`)+ 收口工序接线 + setup.sh 一行分发**,无运行时代码、无 API、无数据库。模板中 TypeScript / API 契约 / 数据库字段等示例,按"项目实际技术栈 = Markdown 文档 + Claude Code fork agent"映射:接口 = 子智能体的入参/出参契约(§3);数据模型 = scout 消费的注册表行结构 + 报告结构(§4)。
- 本设计为**标准级**(新建 1 个 agent 说明文件 `drift-scout.md` + 改 1 个治理文件 finishing-rules 加收口步 + 改 setup.sh 加 1 行 cp 分发;涉及 scout↔注册表消费契约 + 收口工序接线),须过 `/design-review`。

---

## 1. 需求摘要

### 1.1 用户目标

收口前,我改完一批东西,想让系统**自动帮我查"我碰过的那些会互相牵连的点(触点)有没有漂"**——比如改了 `review-rules` 的某个维名却忘了同步 `workflow.js` 的 `FloorTable`,或者新增了一个工件却忘了在 `setup.sh` 加分发行(体检刚逮到的 freshness-scout 漏分发就是这类)。现在这件事靠"治理审查触点完整性维"人肉查,容易漏。

上一版想用 bash hook 机械化,但**注册表端点是散文式的,bash 机械查不出有意义的判据**——所以这一版换成 **fork 一个聪明的子智能体(drift-scout)**:它收口时读注册表、逐触点读两端的实际内容、按判据判断有没有漂、只把有问题的报出来。AI 读散文比 bash 宽容,能区分描述性锚 vs 字面锚、能按分发模型(循环 vs 逐 cp)判分发链漏改——绕开 bash 的两个死结(§1.7)。

一句话:**收口时派一个子智能体读触点注册表、逐触点判端点对没对齐、报漂移;软,不阻断,只读不写。**

### 1.2 核心场景(按优先级排序)

1. **[P0] 收口·凭证批·audit 内 fork drift-scout 逐触点判漂移**:**门控 = 本批改动命中 `credentials.conf`(收口须产 audit)**——凭证批的 audit 内,drift-scout 作**机械触点漂移预检自动跑**:调度者 fork `drift-scout` 子智能体,注入 `{registryPointer, scope, repoRoot, today}` → scout 在自己上下文里读 `touchpoint-registry.md`、逐触点读两端点实际内容、按该行 `判据` 判一致性 → 返回每触点 `✅一致 / 🔴漂移[附差异指针:哪端点、差在哪] / ⚠️不确定[读不到/判不准]` → 调度者读报告:🔴 当场修或登记、⚠️ 并入治理审查触点完整性维人核、据报告**手工**回填注册表现状列。**门控不依赖审查者是否选了「触点完整性维」**:drift-scout 是触点完整性的**机械预检**,凭证批端点高密度,每凭证批自动跑一次;人工「触点完整性维」保持 review-rules 条件必选不变,作**更深判断的互补**(机械预检 + 人工深审,不互斥、不替代)。**非凭证批**(不产 audit)**不 fork drift-scout**(论证:非凭证批罕碰触点端点;门控理由 §4.2 注 + §8.1)。
2. **[P0] 报告分层不刷屏**:scout 返回的报告**🔴 突出逐条列、✅/⚠️ 折叠计数**(像 freshness-scout 的"全干净静默 / 有问题才报")。13 触点若全 ✅ → scout 返回"全一致"信号,调度者据此不向用户输出冗长报告(只一句"触点全一致")。
3. **[P0] 覆盖全部 5 类判据(无机械盲区)**:scout 能读散文端点判断,故**逐字一致 / 结构等价(前缀归一)/ glob覆盖 / 存在性 / 单源派生一致** 五类判据**全覆盖**,不留上一版 hook 的 ⏭️ 机械盲区。每触点 scout 读两端点实际内容判(§4.3)。
4. **[P1] fork 失败 / 无 agent 运行时降级**:fork 失败(超时/上下文溢出/工具不可用)→ 调度者软提醒"本会话漂移检测未执行",**回落人工触点完整性维**(治理审查那个维本就在查),不阻断收口;**无 agent 运行时**(纯人工)→ 跳过 drift-scout,同样回落人工触点维(诚实降级,同 freshness-scout)。
5. **[P1] 只读不写,回填由调度者手工**:scout **只读注册表 + 报告**,**不写、不改注册表**(防写坏机读表 `|` 格式自伤,同 freshness-scout 只读边界)。现状列 `待③b查` → `✅一致`/`🔴漂移` 的回填由**调度者据 scout 报告手工做**(§7 D4)。

### 1.3 边界与约束

- **做什么**:建 **`drift-scout.md`**(说明型子智能体契约,镜像 freshness-scout / review-scout 形态)+ **finishing-rules 收口工序加「触点漂移检测」一步** + **setup.sh 加一行 cp 分发 drift-scout.md**(逐 cp 行类,§1.7 / §8)。scout 消费 ③a 注册表,逐触点判 5 类判据,报漂移;软,不阻断收口;只读不写。
- **不做什么**(详 §10):
  - 不改注册表 `判据`/`类型` enum、不改 13 行数据(scout 是**消费方**;若结论"需加抽取列/改 schema"→ 标 🟡 反馈给 ③a,不在本 spec 擅改)。
  - 不建额外 hook(本轮形态 = scout,不是第 7 个 `check-*` hook;也不新增开场对账命令)。
  - 不让 scout 自动回填注册表现状列(只读不写,回填调度者手工)。
  - 不阻断收口(软;像 freshness-scout 报告/提醒那道,不是硬闸)。
  - 不改现有 6 个 `check-*` hook、不改对账三命令、不改 finishing 既有步(只新增一步)。
- **性能/成本要求**:13 触点表,scout 一次 fork 读注册表 + 逐触点读端点(每端点行级 grep/Read);**仅凭证批 fork(命中 credentials.conf 即在该批 audit 内自动跑一次,不依赖审查者是否选触点完整性维),非每收口都跑**(门控 §4.2 注);成本 = 一次 fork(同 freshness-scout 量级,毫秒级网络无,Read/Grep 工具调用若干)。成本与退化风险评估见 §7 D5 + §6.3。
- **兼容性要求**:双层 harness 自仓库(`PROJECT_DIR/harness/`)+ 单层下游分发都要能跑(scout 据注入的 `repoRoot` + 路径前缀约定解析,§4.4)。scout 是 AI 读文档,不依赖特定 awk/gawk,不受上一版 hook 的 mawk/busybox 静默失败约束(本版无 bash 机械解析)。半角/全角护栏:scout 读端点锚时若疑似全角符号,在报告里附提示(同 freshness-scout 全角护栏)。

### 1.4 关联需求

- **依赖的已有功能**:③a `touchpoint-registry.md`(13 触点机读表,本 scout 唯一喂料源)+ `credentials.conf`(INCLUDE_GLOBS,TP-09 glob 覆盖判据的凭证 glob 源)+ `setup.sh`(TP-09 分发链端点 + drift-scout 自身分发)+ `credentials-rules.md` §8(触点权威上游,scout 判 TP-13 时对照)。
- **被哪些未来功能依赖**:后续若 ③a 给注册表加结构化抽取列,本 scout 的"逐触点读两端判判据"行为契约是升级基线(从"AI 读散文判"演进为"AI 读结构化端点判",判据语义不变)。

### 1.5 已确认的决策(从需求对接阶段带入)

- 形态 = **drift-scout 收口子智能体**(MVP;**非 hook、非纯 bash**)。上一版 hook 形态被自检否决,本版换 scout(根因 §1.7)。
- 触发 = **收口·凭证批·audit 内自动跑 fork**(drift-scout 作触点完整性的机械预检——凭证批 audit 内自动跑,**不依赖审查者是否选了「触点完整性维」**;人工触点完整性维保持 review-rules 条件必选作互补深审;门控:本批命中 credentials.conf 即 fork,非凭证批不空跑;接 finishing-rules 收口工序;门控四处统一见 §4.2 注)。
- 强度 = **软**(报漂移,不阻断收口);需 agent 运行时,无则跳过/回落人工触点维(诚实降级,同 freshness)。
- **覆盖全部 5 类判据**(scout 能判散文端点,不留 ⏭️ 机械盲区):逐字一致 / 结构等价(前缀归一)/ glob覆盖(按分发模型分:循环分发 vs 逐 cp 行)/ 存在性 / 单源派生一致。
- 出参 = 每触点 ✅一致 / 🔴漂移(附差异指针)/ ⚠️不确定;**报告分层**(🔴 突出、✅/⚠️ 折叠计数)。
- **只读不写**:回填 registry 现状列由调度者据报告手工写。
- 入参 = registry 指针 + 范围(全 13 触点;**范围裁定见 §7 D3**)。
- MVP 边界:只建 drift-scout + 收口接线 + setup.sh 分发;不改注册表判据 enum/数据;不建额外 hook。

### 1.6 RUBRIC 风险标记

> harness 自仓库 RUBRIC 是空模板,真方向盘 = `CLAUDE.md` 核心原则 + 二公设代偿(沿 review-scout `rubric_mode='template'` 回落目标)。

- 涉及的惩罚项 / 红线:
  - **最小变更(核心规则 5)**:新 scout 只读注册表 + 报告;finishing-rules 只加一步;setup.sh 只加一行 cp;不改注册表、不改既有 hook。每行 diff 可追溯。
  - **spec_gap_masking(feedback 戒条)**:**关键风险**——上一版 hook 在散文端点上机械查不出逐字一致是真缺口。本版用 scout 解决,但须**诚实声明 scout 也会退化**(判松/漏判,同 review-scout 退化风险),给兜底(§6.3 + §7 D5),不假装 scout 万无一失。
  - **二公设(做事/判断分离)**:scout 是"做事"工具(读端点判漂移),**不替代"判断"**——回填决策、🔴 修不修仍归调度者/用户;scout 只读不写守边界。符合公设 1。scout 不确定时执行外部动作(Read/Grep 端点)而非内省,符合公设 2。
  - **凭证义务(credentials.conf)**:新 `drift-scout.md` 命中 `.claude/agents/*.md audit`;finishing-rules 改动命中 `docs/governance/*.md audit`;setup.sh 改动命中 `setup.sh audit`。收口须 audit 凭证(§8.3)。
- 涉及的奖励项:把"触点完整性维"用 AI 机械化(scout 能判散文端点,覆盖全 5 类判据,比上一版 hook 的 ⏭️ 盲区更全);只读不写守住机械/判断边界。

### 1.7 设计动机:为何 scout 不 hook(本版形态选择的根因)

> 上一版 hook 设计被自检否决。**否决根因 = bash 在当前注册表"散文端点"上机械查不出有意义的判据**——具体两个死结。本节写明,作为本版选 scout 的依据(design-rules:识别的缺口要显式标 + 给技术原因 + 给补救方向,不包装成"已处理")。

**死结一:端点锚混了字面锚与描述性锚,bash 没信号区分。**
注册表「端点列」是散文式。有些锚是**字面锚**(如 TP-05「手工校验」——这五个字在 AGENTS.md 里真实出现,`grep -F「手工校验」` 命中);有些锚是**描述性锚**(如 TP-06「设计行地板维表注」——这串**不是文件里的字面标题**:review-rules 真实标题措辞不同,是「设计行 scout 注 / 地板维表(权威住此)」「地板维表(三类,权威住本注 — 钉死,非住别处)」之类,描述串与真实标题**逐字不一致**)。bash 用**字面 grep 整串**对这两类**没有可靠信号区分**:对描述性锚整串 `grep -F「设计行地板维表注」` 不命中(尽管子串「地板维表」碰巧能命中),bash 易据此误判"端点锚缺失 🔴",其实端点在、只是锚是描述不是字面 — 而子串是否碰巧命中又不可作判据(不同描述锚子串命中情况不一)。**AI scout 读「设计行地板维表注」能理解这是指"review-rules 里讲三类地板维的那张表",再去文件里定位那张表的实际内容**——这是 bash 字面 grep 做不到、AI 能做的。

**死结二:TP-09 分发链两种分发模型,bash 一刀切会满屏误报。**
`setup.sh` 有两种分发写法(§4.5 实证):
- **循环分发**:hooks(`for hook in "$SCRIPT_DIR/.claude/hooks/"*.sh`)、governance(`for gov in "$SCRIPT_DIR/docs/governance/"*.md`)—— 一个通配段覆盖整类,**没有逐文件 cp 行**。
- **逐 cp 行**:agents(`cp ".../evaluator.md" ...` 一个文件一行)、workflows、skills、docs/references —— **每文件一行 cp**。

bash 若用"grep 每个工件有没有 cp 行"判分发链,会对**循环分发类**(hooks/governance)满屏误报"漏 cp"(它们本就没有逐文件 cp 行,靠通配)。**AI scout 能先判这个工件属哪种分发模型**(看它落在 `.claude/hooks/*.sh` / `docs/governance/*.md` → 循环分发类,查"通配段是否覆盖该 glob";落在 `.claude/agents/*.md` / `workflows/` → 逐 cp 行类,查"每文件有 cp 行")——按分发模型分别判,绕开 bash 的一刀切误报。

**结论**:这两个死结都需要"读懂散文端点的意思 + 按上下文分类判断",是 AI 的强项、bash 的死角。故本版换 scout。**补救方向**(给 ③a):若未来要把这两类判断也降成纯机械,需 ③a 给注册表加"抽取命令列 / 分发模型标记列"(标 🟡-1 反馈,§7);本 spec 不擅改 ③a,scout 形态先把这两类判断交给 AI。

**自检**:
- [x] 每个核心场景都有完整的"谁→做什么→系统做什么→看到什么"?(§1.2 五个 P0/P1 场景齐)
- [x] "不做什么"列了用户可能误以为在范围内的事?(误以为"scout 会自动回填注册表"→ §1.3 + §5 明确否定;误以为"上一版 ⏭️ 盲区还在"→ §1.5 明确 scout 全覆盖)
- [x] 和 brainstorming 需求确认清单对得上?(§1.5 锁定输入逐条落;形态由 hook 改 scout 已反映)
- [x] 优先级反映用户确认?(P0=逐触点判+报告分层+全判据覆盖,P1=降级+只读不写)

---

## 2. 模块划分

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动 | 所在层 |
|------|--------------|----------|--------|
| `.claude/agents/drift-scout.md` | 收口时被 fork 出来,读注册表逐触点判 5 类判据并报漂移(只读不写) | 新建 | `.claude/agents/`(子智能体契约层,说明型非 custom-agent) |
| `docs/governance/finishing-rules.md`「触点漂移检测」步 | 收口工序里指明何时 fork drift-scout、怎么消费报告、降级回落 | 改动 | `docs/governance/`(治理规则层) |
| `setup.sh` agents 段加 `cp drift-scout.md` 行 | 把 drift-scout.md 分发下游(逐 cp 行类,§1.7 死结二同款 — 不加则 scout 逮到自己漏分发) | 改动 | repo 根(分发脚本) |
| `touchpoint-registry.md`(可能)加结构化抽取/分发模型列 | 若结论走"加列把 AI 判降成纯机械"→ 给注册表加列 | **不在本 spec 改**(标 🟡-1 反馈 ③a) | `docs/governance/` |

> 第四行**故意不动**:scout 是注册表消费方,改注册表 schema 是 ③a 的职责。本 spec 把"是否需要加抽取/分发模型列"作为 🟡-1 反馈交回(§1.7 补救方向 + §7 D2 + §8.3)。

> **形态说明(镜像 freshness-scout / review-scout)**:`drift-scout.md` 是"子智能体被 fork 后做什么、守什么"的**说明文件**(与 `freshness-scout.md` / `review-scout.md` / `research-scout.md` 同类),**不是带 YAML `---` frontmatter tools 块的 custom agent type**。文件首行带 HTML 注释新鲜度标签 `<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->`(owner=调度者,因这是 AI 日常维护的契约,非用户方向件)——HTML 注释 **≠ YAML `---`**,不被 Claude Code 解析成 custom agent type,不破坏「非 custom agent type」形态约定(同 freshness-scout.md L4-L6 已消解的张力)。

### 2.2 模块依赖图

```
finishing-rules.md「触点漂移检测」步
        │ (收口工序指引调度者 fork)
        ▼
调度者 fork  drift-scout（独立 context, Read/Grep 工具）
        │ 注入 {registryPointer, scope, repoRoot, today}
        ▼
drift-scout  ──读──►  touchpoint-registry.md(13 行机读表,只读)
        │                      │端点列指向
        ├──读──►  各触点两端点文件(逐字/结构/存在性判据,Read/Grep 实际内容)
        ├──读──►  credentials.conf(INCLUDE_GLOBS,TP-09 glob 覆盖判据)
        ├──读──►  setup.sh(TP-09 分发链端点,按分发模型分类判)
        └──读──►  credentials-rules.md §8(TP-13 单源派生一致对照上游)
        │
        ▼
报告(每触点 ✅/🔴/⚠️ + 报告分层)──►  调度者据报告手工回填注册表现状列

setup.sh agents 段:cp drift-scout.md(分发,逐 cp 行)
```

- 依赖方向:治理规则(finishing-rules)→ 子智能体(drift-scout)→ 数据(注册表 + 端点文件)。单向,无环。
- 与现有 6 个 `check-*` hook **零耦合**:scout 不是 hook、不 import、不被它们调用(§8.2 验证兼容)。
- 与 freshness-scout / review-scout **同形态、不互调**:三者都是收/开场 fork 的说明型子智能体,各管各的(freshness 管文档时间腐 / review 管审查推维 / drift 管触点漂移),无依赖。

**自检**:
- [x] 每个模块单一职责?(scout=读端点判漂移并报;finishing-rules 步=指引何时 fork + 怎么消费;setup.sh 行=分发;三者不混)
- [x] 依赖方向符合分层?(规则→子智能体→数据,单向)
- [x] 无循环依赖?(注册表不反向依赖 scout;scout 只读不写)
- [x] 改动局限职责内?(finishing-rules 只加一步;setup.sh 只加一行 cp;不动既有步/既有 cp)
- [x] 每个核心场景有实现路径?(P0 逐触点判=scout §4.3;P0 报告分层=scout §3.1 出参+§5.3;P0 全判据覆盖=§4.3;P1 降级=§5+§7 D1;P1 只读不写=§7 D4)
- [x] 粒度合理?(一个 scout 契约文件,不拆碎)

---

## 3. 接口定义

> 本功能的"接口"= drift-scout 被 fork 时的**入参契约**(调度者注入)+ scout 返回的**出参契约**(报告对象)。无前后端 API。镜像 freshness-scout.md 的"入参契约 / 出参契约"段。

### 3.1 模块间接口

**调度者 → drift-scout(fork 入参契约)**

```text
入参 = {
  registryPointer: "docs/governance/touchpoint-registry.md"  // 注册表住址(scout 自 Read,指针不是内容 D9)
  scope:           "all"                                       // 范围:MVP 固定 "all"(全 13 触点);理由 §7 D3
                                                              //   预留 "changed:<file>,<file>" 形态(未来按本批 git diff 碰过的端点文件筛触点)
  repoRoot:        "<仓库根绝对/相对路径>"                      // 路径前缀解析锚(双层仓 vs 下游单层;§4.4)
  today:           "YYYY-MM-DD"                                // 调度者注入(全角护栏报告用;不自取系统时钟避环境漂移,同 freshness-scout)
  credentialsConf: ".claude/hooks/credentials.conf"           // TP-09 glob 覆盖判据的凭证 glob 源(scout 自 Read)
  rulesPointer:    "docs/governance/credentials-rules.md"     // TP-13 单源派生一致对照上游(§8 权威源)
}
```

**drift-scout → 调度者(出参契约 = 报告对象,二态)**

```text
出参 = AllAligned | DriftReport

AllAligned: { aligned: true, checked: <本次扫描的触点行数> }
            // 全一致态 = aligned:true,不依赖 checked==13:checked 是"本次扫了几行"动态计数
            //   (scope=all 时通常 13;scope=changed 时 <13,§4.1;空表 checked:0 也算 aligned,§5.1)
            // 无 🔴/⚠️ → 调度者据此只输出一句"触点全一致",不刷长报告(§5.3)

DriftReport: { aligned: false,
               drifts:   [ TouchpointVerdict(verdict='🔴'), ... ],   // 🔴 逐条突出(非空才进 DriftReport)
               unsure:   [ TouchpointVerdict(verdict='⚠️'), ... ],   // ⚠️ 逐条(读不到/判不准)
               alignedCount: <整数>,                                  // ✅ 折叠计数(不逐条)
               summary:  "<一行:N 触点 🔴 / M ⚠️ / K ✅>" }

TouchpointVerdict = {
  id:        "TP-06"                                  // 触点行标识
  criterion: "逐字一致"                                // 该行判据(enum,§4.1)
  verdict:   "✅" | "🔴" | "⚠️"                         // 三态
  detail:    "<一句话>"                                // 🔴: 差异指针(哪端点、差在哪);⚠️: 读不到/判不准原因;✅: 可空
  endpointsChecked: ["<端点路径1>", "<端点路径2>"]      // scout 实际读了哪两(几)端,留痕供调度者复核(防 scout 判松无据)
}
```

- scout 扫完全部触点后**一次性返回**(不流式、不中途刷主对话,同 freshness-scout)。
- **报告分层**(§5.3):🔴 进 `drifts[]` 逐条突出;⚠️ 进 `unsure[]` 逐条;✅ 只进 `alignedCount` 折叠计数,不逐条(避免 13 行 ✅ 刷屏)。

**调用契约(收口时,调度者执行)**:

```text
# 收口时,调度者按 finishing-rules:凭证批的 audit 内自动跑 drift-scout(机械触点漂移预检):
0. 门控:本批命中 credentials.conf(须产 audit)?
        否(非凭证批)→ 不 fork drift-scout(门控理由 §4.2 注 + §8.1)
        是 ↓ (不依赖审查者是否选了「触点完整性维」——机械预检每凭证批自动跑)
1. 需 agent 运行时 → fork drift-scout,注入上述入参
2. 无 agent 运行时 / fork 失败 → 跳过 scout,软提醒 + 回落人工触点完整性维(§5.2 / §7 D1)
3. 收到报告 → 🔴 当场修或登记;⚠️ 并入治理审查触点完整性维人核;据报告手工回填注册表现状列
```

### 3.2 外部接口

无外部 API。唯一"外部"交互 = scout 用 Read/Grep 读文件系统(注册表 + 各端点文件 + credentials.conf + setup.sh + §8)。scout 无网络、无写操作。

### 3.3 前后端类型契约

不适用——本功能不涉及任何 API 端点。

> 替代:本 scout 与注册表之间有**消费契约**(scout 怎么读注册表行的 6 列、怎么按 `判据` 列分派判法),详见 §4.1 + §4.3。这是本设计的"契约"等价物。

**自检**:
- [x] 接口双方都定义?(调用方=调度者/finishing-rules 步;实现方=drift-scout;§3.1 两侧齐)
- [x] 参数/返回类型存在?(入参对象字段 + 出参二态报告对象,均文本/结构化,在 fork agent schema 内)
- [x] 每个接口有错误处理约定?(§3.1 调用契约第 2 条降级 + §5 边界/错误)
- [x] 入参/出参与需求数据对得上?(入参=registry 指针+范围+repoRoot;出参=每触点 ✅/🔴/⚠️ + 差异指针 + 报告分层,= §1.2 场景产出)
- [x] 接口简洁?(入参 6 字段均必要;出参二态;scope 预留 changed 不过度)
- [x] 字段命名统一?(registryPointer/scope/verdict/detail 全程一致;沿 freshness-scout 命名风格)

---

## 4. 数据模型

> 本功能"数据" = scout 消费的注册表行结构(读)+ scout 产出的报告结构(§3.1 已定)+ scout 逐触点判 5 类判据的判法映射(最关键,§4.3)+ 端点三前缀解析(§4.4)+ TP-09 分发模型分类(§4.5)。

### 4.1 注册表行结构(scout 消费契约)

注册表主表行格式(`touchpoint-registry.md` §注册表主表,scout 只读不解析破坏):

```
| id | 类型 | 端点(文件:锚) | 判据 | 来源 | 现状 |
```

scout 把每条数据行理解为(AI 读,非 awk 切;故对散文端点宽容):

```
TouchpointRow {
  id:        "TP-NN"   // 行标识;报告定位用
  type:      enum      // 双写对 / 同核拷贝组 / 分发链 / 漂移点(spec↔代码)
  endpoints: 散文      // 端点列原文(文件:锚,多端点分号/换行分隔);scout 读懂其意,定位实际内容(§4.4)
  criterion: enum      // 逐字一致 / 结构等价(允许路径前缀差异) / glob覆盖 / 存在性 / 单源派生一致
  source:    string    // §8 第N条 / 体检YYYY-MM-DD(scout 判 TP-13 时对照,其余透传报告)
  status:    string    // 待③b查 / ✅一致 / 🔴漂移(scout 只读不据此判,也不回写;§7 D4)
}
```

- scout 跳过表头行(`| id |`)、分隔行(`|---|`)、表外散文——AI 读表自然识别,无需机械正则(比 hook 宽容)。
- scope='all' 时 scout 读全部 13 行;scope='changed:...' 时(预留)只读端点列命中给定文件的触点行。

### 4.2 数据流

```
[finishing 收口]
   → [门控:本批命中 credentials.conf(须产 audit)?]
        否(非凭证批)→ 不 fork drift-scout(门控理由见下注)→ 收口继续
        是 ↓ (凭证批的 audit 内自动跑;不依赖审查者是否选了「触点完整性维」)
   → [调度者在凭证批 audit 内自动跑 drift-scout(机械触点漂移预检):需 agent 运行时?]
        否 → 跳过 scout + 软提醒 + 回落人工触点维(§5.2)→ 收口继续
        是 ↓
   → [调度者 fork drift-scout,注入 {registryPointer, scope, repoRoot, today, credentialsConf, rulesPointer}]
   → [scout Read 注册表 §主表,取 scope 内触点行(默认全 13)]
   → [逐触点:按 criterion 分派判法(§4.3),Read/Grep 两端点实际内容]:
        存在性          → 解析端点路径(§4.4)→ test 存在 → ✅ / 🔴端点缺失
        glob覆盖(TP-09) → 按分发模型分类(§4.5)→ ✅ / 🔴分发链漏改
        逐字一致         → 读两端定位实际内容 → byte 比 → ✅ / 🔴差异指针 / ⚠️定位不准
        结构等价         → 读两端,前缀归一后结构比 → ✅ / 🔴 / ⚠️
        单源派生一致      → 读上游+派生端,判派生是否忠于上游 → ✅ / 🔴 / ⚠️
        端点读不到/判不准  → ⚠️不确定(不假装 ✅,不误判 🔴)
   → [scout 汇总:报告分层(🔴 逐条 / ⚠️ 逐条 / ✅ 折叠计数)]
   → [返回 AllAligned 或 DriftReport(§3.1)]
   → [调度者消费]:🔴 当场修/登记;⚠️ 并入治理审查触点完整性维人核;据报告手工回填现状列
```

> **门控理由(为何 drift-scout 只 gate 在「凭证批」、不依赖审查者是否选了「触点完整性维」)**:drift-scout 是触点完整性的**机械预检**——把"碰过的触点有没有漂"用 AI 机械化扫一遍。它**绑在「凭证批」这件事上**,而**不**绑在"审查者有没有选触点完整性维"上,理由有三:① **关掉门控缝隙**:触点完整性维在 review-rules 里是**条件必选维**(L54:改动涉及机制契约/跨文件计数枚举/分发链时优先选,孤立单文件 typo 可不选)——若把 fork 也绑在"选了该维",会出现"凭证批 ∧ 审查者未选该维 → drift-scout 不 fork + 人工触点维也不跑"的双兜底同时落空档,该批若碰了触点端点(governance/config 正是端点高密度落点)漂移被静默跳过;且"跑不跑机械检测"反过来依赖"人有没有选该维"这个人肉判断,与本机制立项动机"用机械化降低人肉漏判"自指矛盾。只 gate 在凭证批,无此缝隙。② **成本廉价**:凭证批端点高密度,每凭证批自动跑一次预检 = 一 fork、scope 全 13、读 13 端点,成本同 freshness-scout 扫核心集量级(§7 D5 / §6.3),不必再靠选维省成本。③ **与人工维互补不替代**:机械预检每凭证批自动跑(降人肉漏判);人工「触点完整性维」保持 review-rules 条件必选不变,作**更深判断**(语义、副作用、scope)——两者不互斥、不替代,机械预检 + 人工深审双层。**非凭证批不 fork**(论证保留:注册表 13 触点端点大多落在凭证-hit 的 `docs/governance/*.md` · `.claude/hooks/*` · `setup.sh` 等 governance/config 文件上,非凭证批改的多是非治理面文件、罕碰触点端点,真漏由人工触点维终兜)。**门控四处表述统一**:§1.2 P0 场景1 / §3.1 调用契约第 0 步 / 本注 / §8.1 finishing-rules 接线 同口径(门控判据 = 仅"本批命中 credentials.conf",凭证批 audit 内自动跑,不依赖选维)。

### 4.3 判据→判法映射(最关键 — scout 怎么逐触点读两端判 5 类)

> scout 对每个触点,先看该行 `判据` 列,再按下表选判法读两端点。**5 类判据全覆盖,无 ⏭️ 机械盲区**(scout 能读散文端点,这是 scout 相对上一版 hook 的核心增益)。

| 判据(enum) | 适用触点 | scout 怎么读两端判 | 三态产出 |
|---|---|---|---|
| **存在性** | TP-03 + 各行端点的"文件:锚"成分 | 解析端点路径(§4.4)→ Read/`test -f` 端点文件在不在;字面锚(grep 命中类)→ `grep -F` 查锚文本在不在 | 文件/锚都在 → ✅;文件缺 → 🔴端点文件缺失:<path>;锚缺 → 🔴端点锚缺失:<文件>内未见<锚> |
| **glob覆盖** | TP-09 | 按分发模型分类(§4.5):循环分发类查"通配段覆盖该 glob";逐 cp 行类查"每命中凭证 glob 的工件有 cp 行" | 都覆盖 → ✅;某工件漏分发 → 🔴分发链漏改:<工件>(指明哪类、缺什么) |
| **逐字一致** | TP-01, TP-06, TP-07 | 读懂两端点散文锚指的实际内容(描述性锚 → 定位真实标题/表/常量,§4.4 死结一),抽出两端可比内容(如三类维名 vs `FloorTable` 键),逐字比 | 逐字同 → ✅;有差异 → 🔴附差异指针(哪端、哪项不一致);定位不到内容 → ⚠️定位不准 |
| **结构等价(允许路径前缀差异)** | TP-04, TP-05, TP-08, TP-10, TP-11 | 读两端,**前缀归一**(自仓库 `harness/` 前缀 vs 下游裸路径 vs `<root>/` 视作同一)后比结构(A/B/C 三段同构 / 同核步骤齐不齐) | 结构等价 → ✅;某段/步缺失或不同构 → 🔴附差异指针;判不准 → ⚠️ |
| **单源派生一致** | TP-02, TP-12, TP-13 | 读上游权威端(如 credentials.conf / freshness-rules / §8)+ 派生端,判派生是否忠于上游(派生端有没有漏/改上游的项;TP-13:§8 每条是否都映射到注册表唯一行) | 派生忠实 → ✅;派生漏/改上游 → 🔴附差异指针(漏了哪条/改了什么);判不准 → ⚠️ |

> **TP-13 单源派生判法护栏(防双向 1:1 误报)**:TP-13 判 `§8 ↔ 本表` 时,判据是**单向覆盖/子集**,不是双向逐行 1:1 比对。复述 registry §维护已定的护栏:**`§8 ⊆ 本表`**——§8 每条双写义务都须映射到本表唯一一行(§8 新增条目而本表漏登 → 🔴 TP-13 漂移);但**本表另有体检来源行 TP-09~12(来源=「体检YYYY-MM-DD」)无 §8 对应,不要求计数相等**。scout 判 TP-13 时**只查"§8 的每条都有本表行覆盖",不可反向拿本表行数 == §8 条数当判据**对 TP-09~12 误报 🔴(它们本就无 §8 对应,是体检摸到的散落触点)。

**关键澄清(防误读,对照上一版 hook 的 ⏭️)**:
- 上一版 hook 把 `逐字一致 / 结构等价 / 单源派生一致` 全标 ⏭️需人核(bash 机械查不了散文端点)。**本版 scout 全判**——因为 AI 能读懂散文锚、定位实际内容、前缀归一、判派生忠实。**这正是选 scout 的核心增益**。
- scout 判不准的个例(端点读不到 / 锚太模糊定位不到 / 语义判断没把握)→ 标 **⚠️不确定**(不是上一版的"整类 ⏭️",而是"这一个触点 scout 没把握")。⚠️ 并入治理审查触点完整性维人核,**不静默漏**。
- **诚实声明(过 spec_gap_masking 戒条)**:scout 全覆盖 5 类判据 ≠ scout 永不判错。scout 会退化(判松/漏判,§6.3 + §7 D5),⚠️ 是 scout 自报"我没把握",但 scout 也可能**误报 ✅(判松)**——这是落地后实战观察的失败模式,本设计**不声称已根除**,靠注册表判据明确 + 报告留痕(`endpointsChecked`)+ meta-L4 观察兜(§6.3)。

### 4.4 端点路径三前缀解析(scout 操作指引)

> 注册表端点列路径混三类写法,scout 须能定位实际文件。AI 读比 bash 宽容,但本节给明确解析指引(防 scout 各凭直觉)。

注册表端点路径出现三类前缀:

1. **裸相对**(如 `docs/governance/review-rules.md`、`.claude/workflows/review-scout.workflow.js`):**自仓库视角加 `harness/` 前缀**定位实际文件(`repoRoot/harness/docs/...`);下游单层则裸路径即实际(`repoRoot/docs/...`)。scout 据注入的 `repoRoot` + "是否双层(`repoRoot/harness/` 存在)"判。
2. **`<root>/` sentinel**(如 `<root>/CLAUDE.md`、`<root>/AGENTS.md`):指 **repo 根级文件**(`repoRoot/CLAUDE.md`),**不**加 `harness/` 前缀。`<root>/` 是 7 字节字面 sentinel(沿 credentials-rules §3.4 协议),scout 见此前缀剥掉 `<root>/` 后直接挂 repoRoot 根。
3. **`harness/templates/...`**(如 `harness/templates/AGENTS.md`):**从 repo 根写的 M4 分发模板**,scout 直接挂 repoRoot 根定位(`repoRoot/harness/templates/AGENTS.md`);下游分发版去 `harness/` 前缀(`repoRoot/templates/AGENTS.md`)。这类**已含 `harness/` 前缀**,不再二次加。

**解析判定顺序**(scout 逐端点路径走):
- 路径以 `<root>/` 开头 → 剥 sentinel,挂 repoRoot 根(第 2 类)。
- 路径以 `harness/` 开头 → 直接挂 repoRoot 根(第 3 类,已含前缀)。
- 其余裸相对路径 → 双层仓(`repoRoot/harness/` 存在)则加 `harness/` 前缀(第 1 类);下游单层则裸路径挂根。
- 解析后文件**读不到** → 标 ⚠️(不假装 🔴 端点缺失,因可能是 scout 解析错前缀,留痕 `endpointsChecked` 让调度者复核);**多端点解析有的成有的不成** → 成的判、不成的在 detail 标"该端点解析不到"。

> **全角护栏**(沿 freshness-scout / check-context-chain 实证):scout 读端点锚时若锚文本疑似含全角 `｜ ： ， 「 」` 且因此定位不到,在该触点 detail 附"疑似全角符号,端点锚约定半角",标 ⚠️,不静默漏。

### 4.5 TP-09 分发模型分类(scout 判分发链漏改的指引)

> 死结二(§1.7):setup.sh 两种分发模型,scout 须分类判,否则对循环分发类满屏误报。

scout 判 TP-09(分发链 glob覆盖)时,对每个"命中 credentials.conf include glob 的可分发工件",先判它属哪种分发模型。**主判据 = 分发模式判断**(scout 在 setup.sh 里识别该 glob 是被**循环分发段**(`for ... in ".../*.sh"|".../*.md"; do cp`)覆盖,还是该工件须有自己的**逐文件 cp 行**),**不依赖行号**;下表行号仅作**参考定位**(本设计要在 agents 段加 cp drift-scout.md,行号会下移,故行号不可当判据,只帮人快速翻到大致位置):

| 分发模型 | 哪些工件 | setup.sh 写法(实证;行号仅参考定位) | scout 怎么判漂移 |
|---|---|---|---|
| **循环分发**(通配段覆盖整类) | `.claude/hooks/*.sh`(参考 L78 附近)、`docs/governance/*.md`(参考 L103 附近) | `for hook in "$SCRIPT_DIR/.claude/hooks/"*.sh; do cp ...` | 按**模式**查"setup.sh 有覆盖该 glob 的通配 for 循环段"——有 → ✅(新工件自动被通配分发);通配段被删/改 glob → 🔴 |
| **逐 cp 行**(每文件一行) | `.claude/agents/*.md`(参考 L41 附近)、`.claude/workflows/*`(参考 L55 附近)、`.claude/skills/*/*`(参考 L66 附近)、`docs/references/DESIGN_TEMPLATE.md`(参考 L126 附近;**`docs/references` 被 setup.sh 分发多个文件**——实证逐 cp 了 5 个:MODULE_DOC_TEMPLATE / DESIGN_TEMPLATE / multi-agent-review-guide / testing-standard / challenger-orientation;**其中仅 DESIGN_TEMPLATE.md 命中凭证 glob**:credentials.conf 第 30 行 `docs/references/DESIGN_TEMPLATE.md audit`,非整个 `docs/references/*`。**TP-09 判据只覆盖命中凭证 glob 的工件**,故此处只判 DESIGN_TEMPLATE 这一个,不判其余 4 个 references 文件——切分"分发了几个"与"命中 glob 几个") | `cp "$SCRIPT_DIR/.claude/agents/evaluator.md" ...` 一文件一行 | 按**模式**查"每个命中凭证 glob 的工件**都有自己的 cp 行**"——某工件无 cp 行 → 🔴分发链漏改:<工件>(体检逮到 freshness-scout 漏分发即此类) |

**关键:drift-scout.md 自己 = 逐 cp 行类**。`drift-scout.md` 落 `.claude/agents/*.md`,属**逐 cp 行**分发模型(agents 段是逐文件 cp,**不是**循环 — 按模式判,参考 L41 附近)。**故实现 drift-scout 时必须在 setup.sh agents 段加一行 `cp "$SCRIPT_DIR/.claude/agents/drift-scout.md" ...`**(像 freshness-scout 那行,参考 L51 附近),**否则 drift-scout 跑起来会逮到自己漏分发(🔴 TP-09)**——这是本设计的自指影响,§8.1 点明、§6.1 测它。

**自检**:
- [x] 数据流每步类型一致?(行→TouchpointRow→按 criterion 分派→TouchpointVerdict→报告对象,贯通)
- [x] 实体字段覆盖接口用的数据?(id/type/criterion/endpoints 都用上;source 判 TP-13 用 + 透传;status 只读不写)
- [x] 状态机无死状态?(每触点必落 ✅/🔴/⚠️ 三态之一,无悬空;读不到/判不准 → ⚠️ 兜底)
- [x] 字段命名规范明确?(注册表列名沿 ③a 原文;报告字段沿 §3.1)
- [x] 数据校验在哪做明确?(scout 读表识别数据行 = §4.1;端点路径解析 = §4.4;分发模型分类 = §4.5)

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 场景 | 输入条件 | 期望行为 |
|------|---------|---------|
| 注册表读不到 | `touchpoint-registry.md` 不在 / scout Read 失败 | scout 返回 `⚠️ 注册表读不到,漂移检测无料` 信号 → 调度者软提醒 + 回落人工触点维(不阻断收口) |
| 注册表空表/无 TP 行 | 文件在但无 `TP-NN` 数据行 | scout 返回 `{aligned:true, checked:0}` + note"注册表无触点行" → 调度者不报错 |
| 端点文件解析不到 | §4.4 三前缀解析后 `test -f` 失败 | 该触点标 ⚠️(可能 scout 解析错前缀)+ detail"端点解析不到:<尝试路径>" + `endpointsChecked` 留痕;**不直接判 🔴**(防解析错误误报) |
| 端点文件真缺(存在性判据 + 路径明确) | 存在性触点端点路径解析清晰但文件确不在 | 该触点 🔴端点文件缺失:<path>(这是真漂移信号) |
| 描述性锚定位不到 | 锚是描述非字面,scout 读不出指哪段实际内容 | 该触点标 ⚠️ + detail"锚为描述性,未定位到实际内容,需人核";**不误判 🔴**(死结一,scout 尽力但留 ⚠️ 不假装) |
| 语义判断没把握 | 结构等价/单源派生类,scout 读了两端但拿不准是否漂 | 该触点标 ⚠️ + detail"语义一致性 scout 判不准,需人核" |
| 全角符号污染端点锚 | 端点锚含全角 `｜：，「」` 导致定位失败 | 该触点 ⚠️ + detail"疑似全角符号,端点锚约定半角" |
| TP-09 工件属循环分发类 | 工件落 hooks/governance(通配段覆盖) | 查通配段覆盖该 glob → ✅;**不**因"没有逐文件 cp 行"误报 🔴(死结二) |
| drift-scout 自己漏分发 | setup.sh agents 段无 `cp drift-scout.md` 行 | scout 判 TP-09 时 🔴分发链漏改:drift-scout.md(逐 cp 行类缺 cp;§4.5 自指)→ 提醒补 cp |
| fork 失败 | 超时/上下文溢出/工具不可用 | 调度者捕获 → 软提醒"本会话漂移检测未执行(fork 失败)" → 回落人工触点维,**不阻断收口、不算欠账**(软强度) |
| 无 agent 运行时 | 纯人工模式 | 跳过 drift-scout,回落人工触点完整性维(诚实降级,同 freshness;对账三命令不受影响) |
| 全一致 | 13 触点全 ✅ 无 🔴/⚠️ | scout 返回 `AllAligned` → 调度者只输出一句"触点全一致",不刷长报告(§5.3) |

### 5.2 错误传播路径

```
[注册表读不到/无料]   → [scout 返回 ⚠️ 无料信号] → [调度者软提醒 + 回落人工触点维] → [收口继续]
[fork 失败/无 agent] → [调度者捕获] → [软提醒 + 回落人工触点维] → [不阻断、不算欠账]
[单触点端点解析不到]  → [该触点 ⚠️ + endpointsChecked 留痕] → [收集进报告] → [不中断其余触点]
[单触点判不准]        → [该触点 ⚠️ + detail 原因] → [收集进报告] → [其余触点照判]
[单触点真漂移]        → [该触点 🔴 + 差异指针] → [收集进 drifts[]] → [调度者读 🔴 决定修/登记]
```

无吞错路径:致命错(注册表无料/fork 失败)走软提醒 + 回落人工维(显式可见);单触点错走 ⚠️/🔴 入报告(显式可见,带 `endpointsChecked` 留痕),**没有静默丢弃**(除"全一致 → AllAligned"——那是设计要的安静,非吞错)。

### 5.3 报告分层 vs 全一致静默(明确判据)

- **全一致(AllAligned)**:本次扫描的触点**全 ✅** **且** 无任何 🔴/⚠️ → scout 返回 `{aligned:true, checked:<本次扫描行数>}`(scope=all 通常 13,空表 0)→ 调度者只输出一句"触点全一致"(沿 freshness-scout"全干净静默"惯例,不刷长报告)。
- **报告分层(DriftReport)**:出现任一 🔴/⚠️ → scout 返回 `DriftReport`,调度者据分层展示:
  - **🔴 突出逐条**:每条列 `id + criterion + detail(差异指针)+ endpointsChecked`,调度者据此当场修或登记。
  - **⚠️ 逐条**:每条列 `id + detail(读不到/判不准原因)`,调度者并入治理审查触点完整性维人核。
  - **✅ 折叠计数**:只报 `alignedCount`(如"另 9 触点 ✅ 一致"),**不逐条**列 ✅(避免 13 行 ✅ 刷屏)。
- **与上一版对比**:上一版 hook 因把 3 类判据全标 ⏭️,"几乎总有 ⏭️"是常态噪音;本版 scout 全判,**全一致(AllAligned)是真实可达态**(scout 判完 13 触点都 ✅ 就静默),报告分层只在真有 🔴/⚠️ 时出现——噪音更低。

**自检**:
- [x] 每个接口错误情况有边界处理?(§5.1 覆盖注册表无料/解析不到/锚定位/判不准/全角/分发模型/自指漏分发/fork失败/无agent)
- [x] 错误传播完整无吞错?(§5.2 五条路径,显式可见 + endpointsChecked 留痕)
- [x] 用户看到有意义错误?(🔴 附差异指针;⚠️ 附原因 + 留痕;不给技术堆栈)
- [x] 核心场景异常路径都有边界?(P0 逐触点判→解析/锚/判不准边界;P0 报告分层→§5.3 判据;P1 降级→fork失败/无agent边界)

---

## 6. 测试策略

> harness meta 验证:scout 是 fork 子智能体,验它 = **造真漂移看 scout 报 🔴 / 造干净看 scout AllAligned**。

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | mock 策略 |
|---------|---------|---------|----------|
| §1.2 场景1(逐触点判) | 干净仓库 fork scout,13 触点判完,无真漂移 → 多数 ✅,个别难判 ⚠️ | 集成(对真 registry fork) | 不 mock,跑真注册表 |
| §1.2 场景1 红线·分发链 | **造真漂移**:setup.sh 删 `cp drift-scout.md`(或删 freshness-scout cp 行)→ scout 应报 `🔴 TP-09 分发链漏改:<工件>`(逐 cp 行类) | 集成(fixture) | git stash / 临时副本改 setup.sh + 还原 |
| §1.2 场景1 红线·逐字 | **造真漂移**:review-rules 改一个地板维名、**不同步** workflow.js `FloorTable` → scout 应报 `🔴 TP-06 逐字漂移`(指明哪维不一致) | 集成(fixture) | 临时改 review-rules 维名 + 还原 |
| §4.5 死结二·不误报 | 循环分发类(hooks/governance)正常 → scout **不**因"没有逐文件 cp 行"误报 🔴(查通配段 → ✅) | 集成 | 跑真 setup.sh 的 hooks/governance `for ... do cp` 循环段(参考 L78 / L103 附近) |
| §4.4 死结一·描述性锚 | TP-06「设计行地板维表注」描述性锚 → scout 定位到 review-rules 真实那张表(不因 `grep`=0 误判端点缺失) | 集成 | 跑真 review-rules |
| §1.2 场景2(全一致) | 干净仓库无真漂移、scout 全判 ✅ → 返回 `AllAligned` → 调度者一句话 | 集成 | 跑真注册表(确保本批未引入漂移) |
| §5.1 注册表读不到 | 临时 mv 注册表 → scout 返回 ⚠️ 无料 → 调度者回落人工维 | 集成(fixture) | mv + 还原 |
| §5.1 端点解析不到 | 临时 mv 某端点文件 → scout 标 ⚠️/🔴 + endpointsChecked 留痕,不崩其余触点 | 集成(fixture) | mv + 还原 |
| §4.4 三前缀解析 | scout 对 `<root>/CLAUDE.md` / `harness/templates/AGENTS.md` / 裸 `docs/...` 三类各能定位 | 集成 | 跑真三类端点(注册表 TP-03/TP-05/TP-10 已含三类) |

### 6.2 测试边界

- **不测**:scout 内部 LLM 推理过程(不可单测 LLM 判断);只测 **scout 输入→输出的契约符合**(造已知漂移看是否报 🔴、造干净看是否 AllAligned、造读不到看是否 ⚠️ 不崩)。
- **不测**:`/design-review` 等下游流程(本 scout 不触发它们)。
- **harness meta 静态核**:除上述 fork 测试,收口时按 harness 惯例做静态核——确认 `drift-scout.md` 形态正确(HTML 注释非 YAML frontmatter)+ setup.sh 已加 drift-scout cp 行(否则 scout 自指报 🔴)+ 在真仓库 fork 一次看报告合理。
- **造漂移红线测的意义**:这是验 scout **真能逮漂移**的核心证据(不是"scout 跑了不报错"就算过)。**至少跑两个红线**:(a) setup.sh 删 cp 行 → scout 报 🔴 分发链漏改;(b) review-rules 维名改不同步 workflow.js → scout 报 🔴 逐字漂移。两者覆盖 §1.7 两个死结对应的判据(glob覆盖 + 逐字一致)。

### 6.3 scout 退化的观察(不是测试,是诚实声明)

> scout 与 review-scout / freshness-scout 同族,**有退化风险**(判松/漏判),且 LLM 判断**无法单测穷尽**。本节诚实声明,挂 meta-L4 实战观察(过 spec_gap_masking 戒条:承认 + 不假装根除)。

- **退化模式**:scout 可能(a) 把真漂移误判 ✅(判松,最危险——漏报);(b) 把对齐的误判 🔴(误报,噪音);(c) 描述性锚定位错端点(判错对象)。
- **本设计降低退化的措施**(降低非根除):① 注册表 `判据` 列明确(scout 有判法依据,§4.3);② 报告带 `endpointsChecked` 留痕(调度者能复核 scout 读了哪两端,判松无据可查);③ 红线测(§6.1)验 scout 对已知漂移真报 🔴;④ ⚠️ 兜底(scout 没把握标 ⚠️ 而非硬判,交人核)。
- **兜底**:scout 是**软**机制,漏报(判松)的最终兜底仍是**治理审查触点完整性维人核**(那个维本就在查;scout 是给它加机械化辅助,不是取代)。meta-L4 观察 scout 实际漏报率,据实战调整。**本设计不声称 scout 已根除漏改**——scout 降低人肉漏查概率,不等于零漏。

**自检**:
- [x] 每个核心场景有对应测试?(场景1逐触点判+两红线 / 场景2全一致 / 降级 各有行)
- [x] 每个边界条件有对应测试?(§5.1 注册表无料/解析不到/三前缀 → §6.1 覆盖;锚定位/判不准 → §6.3 声明不可单测)
- [x] 测试层级合理?(scout 是 fork,主要集成;造漂移红线用真 setup.sh/review-rules fixture)

---

## 7. 设计决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| D1 触发形态 | A: Stop hook 自动跑 / B: 收口工序 fork scout / C: 第 7 个 check-* hook | **B(收口 fork scout)** | 用户锁定形态由 hook 改 scout;§1.7 两死结证明 bash 机械查散文端点不可行。收口 fork(像 freshness-scout 开场 fork)贴软提醒语义,降级回落人工触点维(同 freshness) |
| D2 散文端点判据怎么覆盖 | a: 给注册表加抽取列让 bash 机械化 / b: scout 读散文端点 AI 判,加列作 🟡 反馈 | **b(scout AI 判)** | (a)越界改 ③a schema(守住段禁);(b)scout 能读懂描述性锚 + 按分发模型分类,**全覆盖 5 类判据无 ⏭️ 盲区**;"是否加结构化列降成纯机械"作 🟡-1 反馈 ③a(§1.7 补救方向) |
| D3 扫描范围 | A: 全 13 触点 / B: 只扫本批 git diff 碰过的端点相关触点 | **A(全量)** | "本批碰过哪些触点"需把 git diff 文件**反查映射到散文端点**(同样要 scout 读散文判),反查本身有成本且易漏；全 13 触点 scout 一次 fork 读完成本可控(同 freshness-scout 扫核心集量级),MVP 全量更简单且不漏。`scope='changed:...'` 形态**预留**(§3.1),未来若 13 触点涨到很多再按本批筛 |
| D4 现状列回填 | A: scout 自动写注册表 / B: 调度者据报告手工回填 | **B(手工)** | scout 自动改机读表风险高(写坏 `\|` 格式 → 后续解析崩,自伤);"只读不写"守住 scout 安全边界(同 freshness-scout 只读)。调度者读报告手工把对应行 `待③b查`→`✅/🔴`,收口工序一句话约定(§8.1) |
| D5 退化怎么兜 | A: 声称 scout 准、不兜 / B: 注册表判据明确 + 报告留痕 + ⚠️ 兜底 + meta-L4 观察 | **B(诚实兜底)** | scout 同 review-scout 有退化风险且 LLM 判断不可单测穷尽(§6.3);A 违 spec_gap_masking 戒条。B:判据列给依据 + endpointsChecked 留痕可复核 + ⚠️ 不硬判 + 人核维终兜 + meta-L4 观实战漏报率。**不声称根除** |

### RUBRIC 应对方式

- **最小变更(规则5)**:新 scout 单一职责(读端点判漂移);finishing-rules 只加一步;setup.sh 只加一行 cp;不改注册表(D2)、不改既有 hook。每行 diff 可追溯。
- **spec_gap_masking(戒条)**:§1.7 显式声明上一版 hook 缺口(两死结)+ 技术原因(散文端点)+ 补救方向(scout / 🟡 加列);§4.3 + §6.3 诚实声明 scout 全覆盖判据但有退化、不假装根除。正是戒条要的"承认缺口 + 技术原因 + 补救方向"。
- **凭证义务**:新 `drift-scout.md` 命中 `.claude/agents/*.md`、finishing-rules 命中 `docs/governance/*.md`、setup.sh 命中 `setup.sh` → 收口产 audit 凭证(§8.3)。
- **过度工程化判断(戒条)**:反向追问"不用 scout 怎么解决散文端点判据?"→ bash 机械查不了(§1.7 两死结实证),人肉触点维又易漏 → scout 是必要复杂度,非过度工程。D3 全量扫反向追问"不全量怎么办?"→ 反查映射同样要 scout 读散文,全量更简单不漏。

### 待用户决定的 🟡

- **🟡-1(交回 ③a)**:是否给 `touchpoint-registry.md` 加结构化列(抽取命令列 / 分发模型标记列),把 scout 现在用 AI 判的逐字一致 / 结构等价 / 分发模型分类**降成纯机械可查**(未来若想去 LLM 依赖)。本 spec 采纳 D2=(b) 不在本轮做,作为 ③a 的下一步反馈交回。**理由**:改注册表 schema 是 ③a 职责 + 凭证义务(`docs/governance/*.md`),不在本 scout spec 擅改。需用户/③a 拍板是否做、何时做。**注**:这是**增强方向**,不阻塞本 scout 落地(scout AI 判已自洽闭合)。

> 决策不确定项已记入本节 🟡-1;无阻塞接口/数据/架构的待决策(MVP 范围 D2=(b) 已自洽闭合)。

**自检**:
- [x] 每个决策原因具体可验证?(D1-D5 均指事实/§1.7 死结/范式/守住段,无"更好"空话)
- [x] 有决策与架构冲突?(无;scout 形态与 freshness/review-scout 同族,守扁平 fork)
- [x] 有决策与 RUBRIC 惩罚项冲突?(无;D2/D5 正面应对 spec_gap_masking)
- [x] 不确定决策写入并标 🟡?(🟡-1 已标,交回 ③a)
- [x] §1.6 每个 RUBRIC 惩罚项有应对?(最小变更/spec_gap_masking/凭证/过度工程 逐条应对)

---

## 8. 与既有系统的影响

### 8.1 需要改动的已有文件

| 文件 | 改什么 | 为什么 | 影响范围 |
|------|-------|--------|---------|
| `docs/governance/finishing-rules.md` | 在「凭证义务核对」节附近**新增一步**「触点漂移检测」,**门控接线**:仅当**本批命中 `credentials.conf`(收口须产 audit)**时,在该凭证批 audit 内 drift-scout 作机械触点漂移预检**自动跑**——**需 agent 运行时** fork `drift-scout`(注入 registry 指针 + 范围 + repoRoot),消费报告(🔴 当场修/登记、⚠️ 并入触点完整性维人核、据报告**手工回填**现状列);明确**软、不阻断**;**门控不依赖审查者是否选了「触点完整性维」**(机械预检每凭证批自动跑,人工触点完整性维保持 review-rules 条件必选作互补深审);**非凭证批 → 不 fork**;**无 agent / fork 失败 → 回落人工触点完整性维**(诚实降级,同 freshness)。门控理由见 §4.2 注 | 凭证批端点高密度,每批自动跑机械预检关掉"凭证批∧未选维→无人查"缝隙;非凭证批不空跑;否则没人 fork 它 | 收口流程(调度者);不动既有步,只追加一步 |
| `setup.sh` | agents **逐 cp 行区**(参考 L41-51 附近,行号仅参考定位 — 主判据 = 找到 agents 那一组逐文件 `cp ".../agents/*.md"` 行)**加一行** `cp "$SCRIPT_DIR/.claude/agents/drift-scout.md" "$TARGET_DIR/.claude/agents/"`(像 freshness-scout 那行,参考 L51 附近) | drift-scout.md 属**逐 cp 行**分发模型(§4.5),**不加则 scout 自指报 🔴 漏分发**(死结二同款);且下游拿不到 drift-scout 就没法跑 | 下游分发范围(多分发一个 agent 文件);收口时 scout 自查必绿 |

> **新建文件**(不算"改动既有"):`.claude/agents/drift-scout.md`(说明型子智能体契约,§2.1 形态说明)。
>
> **为什么 setup.sh 这次必须改(与上一版 hook 的关键差异)**:上一版 hook 落 `.claude/hooks/*.sh`,被 setup.sh **循环分发段**(`for hook in ".../hooks/"*.sh`,参考 L78 附近)自动覆盖,无需加 cp。**本版 drift-scout.md 落 `.claude/agents/*.md`,而 agents 段是逐 cp 行(参考 L41 附近,无循环)**——必须显式加一行 cp,否则 §4.5 自指:scout 判 TP-09 会逮到自己漏分发(🔴)。这正是 §1.7 死结二在本设计上的自指落点。(行号仅参考定位,加 cp 后下移;判据按分发模式,§4.5)

### 8.2 不改动但需要验证兼容的

| 文件/模块 | 验证什么 |
|----------|---------|
| 现有 6 个 `check-*` hook | drift-scout 不是 hook、不 import/不被它们调用,**零改**;不进 settings.json hook 注册(scout 是收口 fork 的子智能体,不是 Stop/PostToolUse 自动 hook) |
| `touchpoint-registry.md` | scout **只读**;验证不写入、不改其 13 行/判据 enum(守住段);现状列由调度者手工回填,scout 不碰 |
| 对账三命令(check-handoff / check-shelf-registry / check-audit-coverage) | 不新增第 4 条对账命令(drift-scout 是收口工序步,**不是**开场对账命令);验证开场对账规程零改 |
| freshness-scout / review-scout / research-scout | drift-scout 与它们同形态(说明型子智能体)、**不互调**;验证新增 scout 不影响它们;复用其形态范式(HTML 注释新鲜度标签 / 入参出参契约 / fork 失败降级) |
| `setup.sh` 其余分发段 | 只在 agents 逐 cp 段加一行,**不动** hooks/governance 循环段、不动其余 agents cp 行;验证 drift-scout cp 行落在 agents 段内、形如 freshness-scout 那行(参考 L51 附近) |

### 8.3 凭证义务(收口前必做)

- 本 spec 落地改动命中 `credentials.conf`:`.claude/agents/*.md`(新 `drift-scout.md`)+ `docs/governance/*.md`(finishing-rules)+ `setup.sh`(加 cp 行)。
- 收口前须按 finishing-rules「凭证义务核对」step 15-18 产 **audit 凭证**(对抗审查,covers 列出:`.claude/agents/drift-scout.md` + `docs/governance/finishing-rules.md` + `setup.sh`)。非 typo,**不走 exempt**。
- 🟡-1 若后续采纳(加结构化列改注册表)→ 那是**另一批**改动,届时单独产 audit 凭证(覆盖 `docs/governance/touchpoint-registry.md`),不并入本批。
- **注**:`drift-scout.md` 自身随 agents 分发下游(§8.1 加 cp),但"凭证义务路径" ≠ "分发范围"(同 research-scout.md 在 setup.sh agents 段那条注的逻辑,参考 L46 附近)——它命中 agents 凭证 glob 须 audit,同时是下游可用工件须分发,两件事不冲突。

**自检**:
- [x] 改动已有文件时调用方都考虑?(finishing-rules 调用方=调度者收口;setup.sh 调用方=下游安装 + scout 自查;两改动都点明影响)
- [x] 新旧模块交互无不兼容?(scout 与现有 6 hook + 3 scout 零耦合/不互调;不进 settings.json 自动注册,§8.2)
- [x] §2 标"改动"的模块都在此列出?(§2.1 标"改动"= finishing-rules + setup.sh,均在 8.1 ✅;注册表标"不改"→ §8.2 验证)

---

## 9. 全局自洽性检查

- [x] **需求 ↔ 模块**:场景1逐触点判→scout §4.3;场景2报告分层→scout §3.1+§5.3;场景3全判据覆盖→§4.3;场景4降级→finishing-rules 步+§5.2;场景5只读不写→§7 D4。每场景有路径。
- [x] **模块 ↔ 接口**:scout 职责通过 §3.1 入参/出参契约体现;finishing-rules 步通过"指引何时 fork + 消费 + 降级"体现;setup.sh 行通过"分发"体现。无孤岛。
- [x] **接口 ↔ 数据**:§3.1 出参(每触点 ✅/🔴/⚠️ + 报告分层)= §4.2 数据流末态;入参 registryPointer/scope/repoRoot 支撑 §4.1 读表 + §4.4 解析。
- [x] **数据 ↔ 边界**:§4.1 每要素(端点散文/criterion/路径前缀)的异常在 §5.1 有处理(解析不到/描述性锚/判不准/全角/分发模型/自指漏分发)。
- [x] **依赖 ↔ 架构**:规则→子智能体→数据单向(§2.2),符合扁平 fork 架构、与现有 hook + scout 零耦合/不互调。
- [x] **决策 ↔ 需求**:D1-D5 不偏离锁定输入(scout/软/不阻断/不改注册表/只读不写);D2 落实"scout 全覆盖判据"、D5 落实"诚实兜退化"。
- [x] **决策 ↔ 架构**:D1 scout 形态守扁平 fork(同 freshness/review-scout);D4 只读不写守 scout 安全边界。
- [x] **影响 ↔ 模块**:§8.1 两改动文件(finishing-rules + setup.sh)= §2.1 标"改动"模块;注册表标"不改"→ §8.2 验证;新建 drift-scout.md → §2.1 新建。
- [x] **RUBRIC ↔ 设计**:§1.6 每惩罚项(最小变更/spec_gap_masking/二公设/凭证)在 §7 RUBRIC 应对方式逐条对应。
- [x] **契约 ↔ 接口**:无 API 端点(§3.3 不适用);等价物 = §3.1 入参/出参契约 + §4.1 注册表消费契约,覆盖 scout 读注册表 + 报告的全部字段。

---

## 10. 守住段 + 不做清单

### 10.1 守住(不破坏现有,显式声明)

- 现有 6 个 `check-*` hook(check-handoff / check-shelf-registry / check-audit-coverage / check-context-chain / check-module-docs / check-evidence-depth)**零改**——drift-scout 是新增子智能体(非 hook),不动既有 hook。
- `touchpoint-registry.md` 判据/类型 enum + 13 行数据 **零改**——scout 是消费方;"需加结构化列"结论标 🟡-1 反馈,**不在本 spec 擅改 ③a**。
- 对账三命令 / finishing 收口工序既有步 **零改**——只**新增**「触点漂移检测」一步,不动既有步序。
- `credentials.conf` / `credentials-rules.md` **不擅改**——新 `drift-scout.md` 自动被现有 `.claude/agents/*.md audit` glob 纳管,无需新增 conf 行。
- freshness-scout / review-scout / research-scout 既有契约 **零改**——drift-scout 复用其形态范式但独立文件,不改它们。
- `setup.sh` 既有 cp 行 / 循环段 **零改**——只在 agents 逐 cp 段**追加一行** drift-scout cp,不动其余。

### 10.2 不做清单(MVP 边界)

- **不建额外 hook**:本轮形态 = scout 子智能体,不建第 7 个 `check-*` hook、不新增开场对账命令。
- **不改判据 enum**:5 类判据原样消费(scout 全判),不增不删。
- **不阻断收口**:软提醒;fork 失败/无 agent 回落人工触点维,不阻断、不算欠账。
- **不让 scout 自动回填注册表现状列**:scout 只读不写,回填由调度者据报告手工(D4)。
- **不给注册表加结构化抽取/分发模型列**:scout 用 AI 判散文端点;"降成纯机械"标 🟡-1 反馈 ③a,本轮不做。
- **不按本批 git diff 筛触点**:MVP 全量扫 13 触点(D3);`scope='changed:...'` 形态预留未来,不在本轮实现。
- **不声称 scout 根除漏改**:scout 降低人肉漏查概率,有退化风险(§6.3),终兜仍是治理审查触点完整性维人核 + meta-L4 观察。

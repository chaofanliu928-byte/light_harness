---
status: brainstorming-approved
date: 2026-05-29
purpose: 给 harness 加"主动搜寻 / 联网调研外部方案"能力 — 规划多智能体方案时先界定领域+问题,按需 fork 联网调研员;薄纪律层 + 默认编排 Claude Code 自带的 deep-research workflow(WebSearch 工程兜底)
scope: meta
batch_name: solution-research-scout
---

# 方案调研员(research-scout)设计文档(2026-05-29)

> 本 batch 落地用户原诉求:**遇到不了解的地方要主动搜寻 + 规划多智能体方案时先界定"什么领域什么问题",再分一个智能体联网调研业界现有方案**。
>
> 核心:harness **不造调研引擎**(重复造轮子 = 犯本 batch 要防的"别瞎抄"红线),只加一层"**何时该调研 + 调研结果怎么用**"的纪律,引擎**默认用 Claude Code 自带的 `deep-research` workflow**(万一某环境调不到,fork 轻量调研员用内置 WebSearch 兜底)。

---

## 0. 摘要

| 字段 | 内容 |
|---|---|
| **本 batch 名** | solution-research-scout |
| **改动 scope** | meta(新 agent 文件 + governance + references + README) |
| **涉及文件** | 6 个(1 新建 + 5 改):新建 `research-scout.md`;改 `brainstorming-rules.md` / `challenger-orientation.md` / `README.md` / `CLAUDE.md`(M3 根)/ `harness/CLAUDE.md`(M4)|
| **工程量** | 2-3 天落地 + meta-finishing + meta-review |
| **Evidence Depth** | meta-L2(规则文档 + agent 文件 + 实战 fork 1 次验证) |
| **finishing 路径** | M1 meta-finishing + M2 meta-review(对抗式 D2) |
| **不在 scope 内** | 不造调研引擎(默认用 Claude Code 自带的 deep-research)/ 不改 model-route(claude subagent 自带联网)/ 不进 recommended-tools(deep-research 是自带工作流,非外部推荐工具)/ "重视模型的输入"(用户明确推迟,记未来工作)/ 不预设触发阈值(实战调) |

---

## 1. 背景 / 触发原因

### 1.1 用户原诉求(2026-05-29 会话)

用户原话:
> "遇到不了解的地方需要主动去搜寻,我发现这个问题没有体现。另外重视模型的输入,这个也没有体现。我觉得这些至少有一个体现点:在规划的多智能体讨论方案的时候,需要先明确这是一个什么领域的什么问题,然后分出一个智能体联网去搜寻解决问题的方案有哪些。"

后续澄清(同会话):
- "重视模型的输入" = **独立的另一件事**,用户明确"暂时记录下来,不用现在就做"(本 batch 不做,记未来工作)。
- 接入形态:用户选**方案 B**(独立 research-scout agent 文件)。
- 底座:用户引导"复用现成的"(claude 自带 / deep-research),否定从零造引擎。
- 触发松紧:用户选**中道(可逆性主轴 + 不熟次轴)**。

**本 batch 落地范围**:"主动搜寻 / 联网调研外部方案"的第一个体现点(规划方案时按需 fork 联网调研员)。"重视模型的输入"推迟。

### 1.2 三轮调研追溯(本设计的依据 — dogfood 留痕)

本设计本身**用了**用户要的能力(主动搜寻 + 联网调研),三轮调研:

**第一轮 — 缺口核查**(Workflow,4 reader 并行):确认现有体系对三诉求的覆盖。结论(4 reader 共识):
- 主动搜寻 = **partial**(公设 2 授权 WebFetch 但流程全内向:搜本仓库 + 问用户,无"主动外部搜寻"SOP)
- 联网调研 = **no**(完全没有;且反向排斥 — `feedback_judgment_basis` 禁市场判断 + challenger-orientation §2.4"跨项目不查")
- 重视输入 = **yes 但语义错位**(现重"中性/留痕",用户要"外部丰富度")
- **统一为同一缺口**:harness 缺"从仓库外获取新信息作为决策输入"的链路。

**第二轮 — 业界做法调研**(Workflow,4 子问题 research + verify 对抗复核,8 agent 全联网):

| 子问题 | 关键结论 | 强来源(verify holds) |
|---|---|---|
| research agent 设计 | 按需 fork(不常驻)/ framing 前置(四要素委派:目标/格式/工具/边界)/ 浓缩 findings + source-track / artifact 交接 / 按复杂度决定规模 | Anthropic multi-agent-research-system(逐字核实)/ GPT Researcher / Claude Agent SDK |
| 防幻觉 | 强制 source / 多源交叉(但频次≠正确)/ claim 级 confidence / 给"承认无法定论"出口 / 做研究与核查 fork 分离 | Anthropic demystifying-evals(groundedness/coverage/source-quality 三 grader)/ 2412.18004(correctness≠faithfulness) |
| prior-art 方法论 | Cynefin 判域(只 clear 域能套 best practice)/ Trade Study(准则先于候选 + time-box)/ RFC 把"prior art"与"alternatives"分两段 | Rust RFC 2333(逐字)/ Fowler ADR / Microsoft Playbook |
| **cargo-cult 边界(红线核心)** | **调研结果只能当"证据/选项",绝不当"判断依据"**;UNPHAT 六步无"多少公司用"格;EBSE:调研=证据(step2)非决策(step4);Choose Boring Tech:把"不引入新东西"作必列候选 | UNPHAT / EBSE(Dybå/Kitchenham)/ Rust RFC / Choose Boring Technology(逐字) |

**第三轮 — 触发判据**(现成 deep-research workflow,102 agent / 2.8M token / 17 分钟;每条 claim 3 票对抗验证):

| finding | confidence | 来源 |
|---|---|---|
| 无条件检索浪费且**主动降质**(不只变慢) | high | arXiv 2505.07596 IKEA / 2508.04057 PAIRS / 2511.09803 TARG |
| 正确做法:门控在知识边界/不确定性(confident 用内部,uncertain 才查)— Pareto 改进 | high | IKEA(检索 -50.81% 同时准确率 +5.05%) |
| **门控信号(模型自评"我懂不懂")不可靠(~20% 误判 + 系统过度自信)= 公设 1 同构 → 触发判断应由独立信号/fork 给** | high | 2503.11256 / OpenAI 2025-09 |
| 按**可逆性**分级(Bezos 一道门/两道门):不可逆 → 重流程(值得调研);可逆 → 快速决断跳过 | high | Bezos 2015 股东信 / fs.blog |
| 过度前置调研有"延迟成本"(YAGNI opportunity cost)+ agentic overthinking 与降质相关("Analysis Paralysis"是 overthinking 模式) | high | Fowler YAGNI / arXiv 2502.08235 |

**openQuestion(对抗核验诚实划界)**:论文的**具体触发公式**(双答案收敛 / utility 打分公式)**全被对抗核验否决(证据不足)** → 只采纳**原则**(可逆性 + 知识边界 + 独立判断),**阈值实战调,不照搬论文**。这本身践行红线。

### 1.3 dogfood 元观察

本设计过程本身是这个 feature 的活样本:
- **用了"先界定领域+问题 → fork 联网调研"** 来设计这个功能(自指验证可行)。
- **deep-research 实测成本**:102 agent / 2.8M token / 17 分钟 — 印证"联网调研很贵,必须按需触发"(用户核心诉求的实证)。
- **对抗核验当场抓出 cargo-cult 实例**:用 Moz SEO 域名权威度当可信度 / 引用已废弃的 Gemini API / 把 2026 二手修辞当 2017 经典原话 — 证明"调研 + 独立核查"机制有效。

---

## 2. 设计目标 + scope 边界

### 2.1 设计目标

| 目标 | 落地形式 |
|---|---|
| **G1**:规划方案时能按需 fork 联网调研员 | 新建 `research-scout.md`(调研编排说明)+ brainstorming-rules 加触发+framing 步骤 |
| **G2**:不造引擎,默认用 Claude Code 自带的 deep-research | research-scout 底座:默认 `Workflow({name:"deep-research"})`(Claude Code 自带工作流);WebSearch fork 仅工程健壮性兜底 |
| **G3**:按需触发,默认 skip(省成本) | 触发规则:可逆性主轴 + 不熟次轴,默认不调研,独立判断(非待调研 agent 自评),阈值实战调 |
| **G4**:红线 — 调研结果只当证据/选项不当判断依据 | research-scout prompt 契约:UNPHAT 字段 + 不给推荐排名 + "别人这么做不单独构成理由" + 原始 context 匹配性 + 元自警 |
| **G5**:跟"判断基于事实逻辑"红线划清界 | challenger-orientation §2 加外部调研数据源 + 显式区分(禁:别人数据撑判断 / 允:技术方案当证据) |
| **G6**:不引入硬依赖 / 不改代码 | 纯文档 + agent 文件;不改 model-route(claude subagent 自带联网);deep-research 是 Claude Code 自带,直接用 |

### 2.2 Scope 边界

**在 scope 内**:
- 新建 `harness/.claude/agents/research-scout.md`(调研编排说明 + 红线契约)
- 改 `harness/docs/governance/brainstorming-rules.md`(需求深挖后、方案讨论前加"领域+问题界定 → 触发判断 → 调研"步骤)
- 改 `harness/docs/references/challenger-orientation.md` §2(修正红线误读 + 加"外部联网调研"数据源)
- 改 `README.md`(原理段加方案调研能力)
- 改 `CLAUDE.md`(M3)+ `harness/CLAUDE.md`(M4)角色分离表加 research-scout 行

**不在 scope 内**:
- **造调研引擎**(用现成 deep-research;无则轻量 WebSearch fork)
- **把 deep-research 当外部推荐工具放 recommended-tools**(它是 Claude Code 自带工作流,直接用;WebSearch fork 仅工程兜底)
- **改 model-route.md**(那是 codex networkAccess;claude subagent 联网不受其限,dogfood 已证)
- **"重视模型的输入"**(用户明确推迟 → §7.3 未来工作)
- **预设触发阈值公式**(论文公式未过对抗核验;实战调)
- **把 research-scout 做成带 frontmatter tools 的 custom agent type**(沿用 harness 扁平 fork 架构:说明文件 + 调度者 fork,与 design-reviewer 一致)

---

## 3. 详细设计

### 3.1 research-scout.md(新 agent 文件 — 调研编排说明)

**形态**:与 `design-reviewer.md` 同类 — 不是带 frontmatter tools 的 custom agent type,而是"调度者怎么编排调研 + 调研员必须守什么"的说明文件(沿用扁平 fork 架构)。遵循上 batch challenger-orientation 的 include 范式(引用路径不抄实文)。

**结构**:

#### §1 角色定位
- 你是方案调研的**编排者**(调度者)。规划多智能体方案时,在"需求确定后、方案讨论前",按需 fork 一个**联网调研员**搜业界现有方案。
- **核心边界(做事/判断分开)**:调研员只**找证据/列选项**(做事),判断选哪个由后续方案讨论 + 挑战者做(判断)。调研产出绝不是判断依据。

#### §2 何时触发(可逆性主轴 + 不熟次轴 — G3)
- **默认不调研**。两根轴都指向"值得"才触发:
  - **主轴 — 可逆性**:这决定不可逆 / 影响大(改了难回头)→ 值得调研;可逆 / 小事 → 跳过,快速决断(Bezos 一道门 vs 两道门)。
  - **次轴 — 熟悉度**:当前对这块领域确实不熟 → 才有联网价值;已熟悉 → 内部知识够,联网反而引噪声降质(adaptive-RAG)。
- **触发判断由调度者(独立方)做,不交给"要去调研的那个 agent 自评"**(防自评偏差 — 公设 1;deep-research 第三轮 finding 3:模型自评知识边界 ~20% 误判)。
- **深度档**:轻量(几次搜索 / WebSearch fork)/ 完整(deep-research 跑满)。按问题复杂度选,避免每次烧 2.8M token。
- **阈值不写死**:本节给方向,具体松紧实战调(论文公式未过对抗核验,不照搬)。
- 提供 ✅/❌ 触发判断对照例。

#### §3 怎么 framing(界定领域+问题 — 用户落地点第一步)
- fork 调研员前,调度者先界定:**这是什么领域的什么问题类型**(Cynefin 判域辅助:clear/complicated → 有成熟方案值得调研;complex → 没人做过,调研也调不到,转原型/实验)。
- 把方案设计问题**转成一个明确的 research question**(四要素委派:目标 / 产出格式 / 用什么源 / 边界 — Anthropic 共识)。
- framing 段是任务边界,遵守 synthesis-rules 中性化(不暗示结论)。

#### §4 底座(默认用 Claude Code 自带的 deep-research — G2)
- **默认**:`Workflow({name: "deep-research", args: "<research question>"})` — **deep-research 是 Claude Code 自带的工作流**(5 角度 → fetch 15 源 → 每条 claim 3 票对抗验证 → 带引用综合)。规划方案调研直接用它。
- 说明文件**注明 deep-research 是 Claude Code 自带工作流**,调度者直接 `Workflow({name:"deep-research"})` 调用,无需另装。
- **健壮性兜底**(仅工程稳健,非因怀疑可得性 — 任何外部调用都该有兜底):万一某环境调不到,fork 1 个 general-purpose subagent 用 claude 自带 WebSearch/WebFetch 做轻量调研(prompt 契约见 §5)。

#### §5 调研员产出的红线契约(G4 — 本设计核心)
不论底座是 deep-research 还是 WebSearch fork,调研产出**必须整形成**:
- **选项清单 + 每个选项的"适用前提 / trade-off / 原始 context"** — **绝不给推荐排名**(给排名 = 用流行度替决策)。
- **硬规则**(近乎照抄 Rust RFC 2333):"别人 / 别的项目这么做,只是**部分参考,本身不构成采纳理由**。"
- 每个外部方案附:**它原本的背景**(为谁、什么规模、什么约束下设计的)+ **跟本项目情况是否匹配**(context 不匹配则不进候选)。
- 每条带 **source(来源 URL)+ confidence**;承认信息不足时标"无法定论"(合法出口,非失败)。
- **UNPHAT 字段**(调研每个方案走:理解问题 U / 列多候选含"不引入新"N / 读原始资料 P / 历史背景 H / 利弊代价 A / 冷静评估契合 T)。
- **元自警**:UNPHAT 等框架是"提问清单",不是"填了就合规"的免死金牌(别用一种盲从换另一种 — 对抗核验自指警示)。
- 产出**写 artifact 文件**(`docs/active/solution-research-<topic>.md` 或类似),交方案讨论;不长篇回传污染调度者上下文。

#### §6 调研 / 核查分离
- deep-research 已内建 3 票对抗验证(source-quality / 矛盾证据 / 时效 / 营销)。
- WebSearch fork fallback 时,调研员产出后调度者按需独立核查关键 claim(可复用挑战者机制)。

### 3.2 brainstorming-rules.md(加触发 + framing 步骤)

在"需求深挖(阶段二)完成、方案讨论(阶段四)开始前",加一个**可选步骤**:
```
### 阶段 X:方案调研(按需,默认 skip)
需求确定后、提出方案前,调度者判断是否值得联网调研业界现有方案:
- 触发判据:可逆性(主)× 熟悉度(次)— 详见 `.claude/agents/research-scout.md` §2
- 触发判断由调度者做(非待调研 agent 自评 — 公设 1)
- 值得 → 按 research-scout.md framing + 底座选择,fork 调研员;产出写 artifact,作为方案讨论的"选项输入"(非判断依据)
- 不值得(可逆/熟悉)→ 跳过,直接进方案讨论
```
引用 research-scout.md 路径,不抄实文(include 范式)。

### 3.3 challenger-orientation.md §2(修正红线误读 + 加外部调研数据源)

**先修正一处反复误读的红线**(用户 2026-05-29,`[[feedback_judgment_basis]]` 已同步澄清):上 batch §2.4 写"跨项目模式 → **不查**",是把红线误读成"不许看别人项目"。**红线本意 = "不照搬,要经自己思考",不是"不查"**。

改动:
- §2.4 表那行"跨项目模式 → 不查" **改为**:`| 业界 / 别的项目的技术方案 | **可调研参考**(走 research-scout)— 但不照搬,看完要基于事实和逻辑自己判断"对我们是否适用";别人的数据 / 流行度不能直接当判断依据 |`
- §2 数据来源向导**加一行**:`| 业界现有技术方案(规划方案时) | 外部联网调研(research-scout,按需) |`
- 加小节"外部调研与红线"(简短):
  - 红线 = **不照搬要思考**(不是不许看)。调研业界方案**允许且鼓励**(尤其为下游项目开发时用 — 用户 2026-05-29:"调研业界技术方案更多是为下游使用")。
  - 调研结果是**证据 / 选项**,不是**判断依据**(EBSE:证据要过"对我是否适用"这道闸才进决策)。
  - 唯一禁止:把别人的**数据 / 流行度**("X% 项目这么做")不经思考直接当结论。

### 3.4 deep-research 是 Claude Code 自带(无需改 recommended-tools)

deep-research 是 Claude Code **自带**工作流(用户 2026-05-29 确认 + 本会话实测可 `Workflow({name:"deep-research"})` 调用),research-scout 默认直接用它,**不进 recommended-tools**(那是"用户级外部工具推荐清单",自带工作流不属于此)。"自带"的说明落在 research-scout §4 + README 原理段 + CLAUDE 角色表三处,不新增 recommended-tools 改动。

### 3.5 CLAUDE.md(M3)+ harness/CLAUDE.md(M4)角色表

角色分离表加一行:
`| **方案调研** | 调度者按需 fork research-scout(联网调研员)| 规划方案时界定领域+问题 → 联网搜业界方案 → 产出选项(非判断依据)|`

### 3.6 README.md 原理段

加"主动调研 / 重视外部输入"一节:harness 默认内向(搜本仓库 + 问用户),本能力补上"从仓库外获取新信息作决策输入"的链路;按需触发(可逆性×熟悉度,默认 skip);调研=证据不是判断(红线)。

---

## 4. 涉及文件 + 改动清单

| 文件 | 性质 | 改动 |
|---|---|---|
| `harness/.claude/agents/research-scout.md` | 新建 | 调研编排说明 6 节(角色/触发/framing/底座/红线契约/核查分离) |
| `harness/docs/governance/brainstorming-rules.md` | 改 | 加"方案调研(按需)"步骤,引用 research-scout 路径 |
| `harness/docs/references/challenger-orientation.md` | 改 | §2.4 修正红线误读(可调研不照搬)+ 加外部调研数据源 |
| `README.md`(根)+ `harness/README.md` | 改 | 原理段加 4.6 主动调研;**meta-review 后修订补登**:双轴对照表补 4.5/4.6、目录树 agents 清单补 research-scout、标题去掉写死的"18 个"计数(KG-D drift 顺手清) |
| `CLAUDE.md`(M3)+ `harness/CLAUDE.md`(M4) | 改 | 角色表加 research-scout 行 |
| `harness/setup.sh` | 改(**meta-review 后修订补登**)| agents 白名单加 `research-scout.md` 复制行 — 下游断链修复(brainstorming-rules / challenger-orientation / M4 CLAUDE 引用它却没分发);属下游可用 feature 工件 |

---

## 5. Scope 判定 + finishing 路径

- **scope = meta**(命中 C 组 agent / A 组 governance+CLAUDE.md / D 组 references / **F 组 setup.sh** — 后者为 meta-review 后修订补登)。
- **改动 scope ≠ 工件分发范围**(易混淆,本 batch 一度漏 setup.sh → 下游断链):scope=meta 决定"改动走 M1/M2 meta-review 审查路径",**不**决定"产出文件是否分发下游"。research-scout.md 是下游规划方案要用的 feature 侧工件(同 design-reviewer.md / challenger-orientation.md — 都在 meta 批次被改却照样分发),随 setup.sh 分发;D13"meta 不分发"管的是 M1/M2 治理规则、M3 根 CLAUDE.md、meta-* hook,**不含** C 组 agent 文件。
- finishing:M1 meta-finishing + M2 meta-review(对抗式 D2,bootstrap 4 维 + 1-2 定制专项)。
- 定制专项建议:**红线自洽专项**(联网调研 vs feedback_judgment_basis 是否真划清界,会不会反而打开"用别人数据撑判断"的口子)+ **健壮性兜底专项**(deep-research 调不到时 WebSearch fork 兜底是否真 work)。

---

## 6. 测试 / 验收 / Evidence Depth

- **目标 Evidence Depth**:meta-L2(规则文档 + agent 文件 + 实战 fork 1 次验证)。
- **meta-L2 实战验证**:本 batch finishing 后,下次真正"规划方案"时跑一次 research-scout(或本 batch 设计过程本身的三轮调研已是活样本)。
- 不追求 meta-L4(触发判据真带来质量提升 / 红线真防住跟风)→ 推 P1 实战(`[[feedback_realworld_testing_in_other_projects]]`)。

### 6.2 验收清单(meta-L1)
- [ ] research-scout.md 6 节齐全,红线契约含 UNPHAT/不给推荐/Rust RFC 硬规则/原始context/元自警
- [ ] 触发判据=可逆性主轴+熟悉度次轴+独立判断+默认skip,阈值不写死
- [ ] 底座写明:默认用 Claude Code 自带的 deep-research + WebSearch fork 工程兜底
- [ ] brainstorming-rules 加"方案调研(按需)"步骤,引用路径不抄实文
- [ ] challenger-orientation §2 加外部调研数据源 + 红线划界,§2.4 更新
- [ ] research-scout §4 + README 注明 deep-research 是 Claude Code 自带(CLAUDE 角色表只列"方案调研"角色,不重复"自带";不进 recommended-tools)
- [ ] CLAUDE.md M3+M4 角色表加 research-scout 行
- [ ] README 原理段更新
- [ ] **(修订补登)** setup.sh agents 白名单含 research-scout.md — 下游可拿到文件,brainstorming-rules / challenger-orientation / M4 CLAUDE 引用无断链
- [ ] **(修订补登)** 根 + harness 两 README:双轴对照表含 4.5/4.6、agents 目录清单含 research-scout、标题不写死原理计数
- [ ] §7.3 未来工作记"重视模型的输入"

---

## 7. 风险 / 反向追问 / 已知边界

### 7.1 反向追问(`[[feedback_dimension_addition_judgment]]`)
**Q**:不加 research-scout,主动搜寻/联网调研怎么解?
- 替代:靠公设 2(WebFetch 授权)+ 调度者自觉 → 但缺口核查证实流程全内向、从没激活过 WebFetch(空挂口子),自觉不够。
- 替代:每次方案讨论都联网 → adaptive-RAG 证实无差别检索浪费且降质,违用户"别每次都联网"。
**结论**:按需触发 + 红线契约的 research-scout 无更便宜替代。反向追问通过。

### 7.2 风险
- **R1 红线反被打开**:加"联网调研"可能被误用为"用别人数据撑判断"(违 feedback_judgment_basis)。**缓解**:§3.5 红线划界 + UNPHAT 无"流行度"格 + 不给推荐 + EBSE"证据≠判断"+ meta-review 红线自洽专项审。
- **R2 成本失控**:deep-research 102 agent/2.8M token。**缓解**:默认 skip + 深度档(轻量优先)+ 触发判断独立把关。
- **R3 触发判据流于形式**:可逆性/熟悉度判断主观。**缓解**:✅/❌ 对照例 + 独立判断(非自评)+ 阈值实战调。
- **R4 cargo-cult 框架本身**:UNPHAT 等可能变"填了就合规"新教条。**缓解**:§3.1 §5 元自警明写"提问清单非免死金牌"。
- **R5 调研结果不准/幻觉**:**缓解**:deep-research 内建 3 票对抗验证 + source-track;fallback 时调度者独立核查。

### 7.3 已知边界 / 未来工作
- **未来工作 — "重视模型的输入"**(用户 2026-05-29 明确推迟):独立诉求,含义候选(输入充分性 / 一手性 / 质量核查 / 跨模型差异),待用户启动时澄清。
- **deep-research = Claude Code 自带工作流**(用户 2026-05-29 确认 + 本会话实测 `Workflow({name:"deep-research"})` 可调)。诚实标注:调度者核查时本地未找到其定义文件(可能 CLI 内嵌),按"自带默认可用"落地;WebSearch fork 仅工程兜底,非因怀疑可得性。
- **KG — 触发阈值未定量**:论文公式未过对抗核验,实战调。
- **KG — 方案设计领域知识边界难量化**:非事实型 QA,无客观 ground truth;故可逆性为主轴、熟悉度为次轴。

---

## 8. 与现有架构的关系

- **与扁平 fork**:research-scout 沿用"调度者 fork + 嵌 prompt"(说明文件,非 custom agent type),与 design-reviewer 一致。
- **与公设 1**:触发判断由独立方做(非待调研 agent 自评)— deep-research finding 3(模型自评知识边界不可靠)是"**做事 / 判断分离**"的外部印证(公设 1 的延伸:自评不可靠不限于已有产出,也含自评知识边界)。
- **与公设 2**:本能力把"行动公设"的 WebFetch 从"空挂口子"激活成真实流程链路。
- **与 challenger-orientation(上 batch)**:数据来源向导扩展(加外部调研),红线划界。
- **与 feedback_judgment_basis**:§3.3 显式划界(技术方案当证据 ✅ / 别人数据撑判断 ❌)。
- **与 deep-research**:harness 不重新实现(像不重新实现 brainstorming,只用 brainstorming-rules 治理);编排 + 加红线纪律。

---

## 9. Commit 策略(2 commits)

- **Commit 1**:新建 research-scout.md + brainstorming-rules 触发步骤(核心机制)
- **Commit 2**:challenger-orientation §2(修正红线误读)+ README + CLAUDE.md M3/M4 角色表(配套)

---

## 10. 验收 Checklist
- Spec 验收:§1 用户原诉求 + 三轮调研依据对齐;§2 G1-G6 有 §3 对应;§3 红线契约完整;§7 风险 5 条 + 反向追问通过
- 落地:§6.2 meta-L1 清单逐条
- Finishing:M1+M2,meta-review verdict ≥ pass-after-revision,push 前停等用户确认

---

## 11. 关联文件
- 三轮调研产物:本会话(缺口核查 / 业界调研 / deep-research 触发判据 — 详 §1.2;挑战者完整输出在 JSONL,process-audit 可提取)
- 上 batch:`challenger-orientation.md`(数据来源向导,本 batch 扩展) + audit `meta-review-2026-05-29-081645-challenger-orientation.md`
- 红线来源:`[[feedback_judgment_basis]]`(2026-04-15 用户校准)
- 推迟项:重视模型的输入(用户 2026-05-29 明确推迟;task 30 记录;未来 batch 启动时澄清含义)
- 关键外部来源(调研引用,落地时 research-scout 可附):Anthropic multi-agent-research-system / Rust RFC 2333 / EBSE(Dybå-Kitchenham)/ UNPHAT(You Are Not Google)/ arXiv 2505.07596(IKEA)/ 2502.08235(overthinking)/ Bezos 2015 股东信

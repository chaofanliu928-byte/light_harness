---
status: brainstorming-approved
date: 2026-05-26
purpose: 建立挑战者侧导览体系 — 解决挑战者方法论缺失 / 数据来源向导缺失 / 输入策略缺失 / KG3 4 agent 文件 176 行重复 4 个同根问题
scope: meta
batch_name: challenger-orientation-system
---

# 挑战者导览体系 设计文档(2026-05-26)

> 本 batch 落地用户原诉求:**挑战者(fork 出来的子智能体)需要"导览体系" — 像主智能体有 CLAUDE.md / Skill 地图一样,挑战者要知道:怎么审 / 去哪找信息 / 怎么用调度者给的输入 / 避哪些陷阱**。
>
> 一个文件 `harness/docs/references/challenger-orientation.md` 集成 4 块内容 + 4 agent 文件改 include 模式顺手解 KG3。

---

## 0. 摘要

| 字段 | 内容 |
|---|---|
| **本 batch 名** | challenger-orientation-system |
| **改动 scope** | meta(references 新文件 + 4 agent 文件 + governance / 引用 + README) |
| **涉及文件** | 8 个(新建 `challenger-orientation.md` + 4 agent 文件 + `multi-agent-review-guide.md` + `synthesis-rules.md` + README) |
| **改动数** | ~18 处(1 新文件 + 4 agent 文件各 2-3 处删改 + 3 governance / 引用文件各 1-2 处 + setup.sh 加 1 行复制 + meta-review 修订裸 docs/ 前缀对齐) |
| **工程量** | 2-3 天落地 + meta-finishing + meta-review 半天 |
| **Evidence Depth** | meta-L2(规则文档 + agent 文件 + 实战 fork 1 次验证) |
| **finishing 路径** | meta-finishing-rules.md(M1)+ meta-review-rules.md(M2 模态:对抗式 D2,4 挑战者 + 1 定制) |
| **不在 scope 内** | 不建独立 skill / 不动 hook / 不预留"方向挑战 第 5 维"接口 / 不改 designer.md(designer 不 fork 挑战者) / 不改 brainstorming-rules.md(brainstorming 不涉及挑战者 fork) |

---

## 1. 背景 / 触发原因

### 1.1 用户原诉求(2026-05-26 会话)

用户在上 batch(fork-intent-and-report-clarity)meta-finishing 阶段后,从议题 C 出发,逐步暴露了"挑战者侧基础设施缺失"这个根问题。原话节选(JSONL 2026-05-26 06:00-07:24 时段):

> "议题 C:挑战者拿什么输入?这个我很感兴趣。"(message #28)

> "我们的流程有sop和skills,那么挑战者有方法论吗?"(message #29 — 暴露发现 1)

> "其实还有一个重要的是数据来源,我们的主智能体有一个向导,知道遇到什么问题可以做什么,但是子智能体没有向导,不知道从哪些文件找哪些内容。"(message #30 — 暴露发现 2)

> "不要使用用户原话提取 skill,跑了不一定有人读 — 调度者不读相当于白跑,那怎么办?"(message #34 — 否决 skill 路径)

> "直接开 brainstorming 收尾 → 写 spec,并形成一个交接的一段话给我。"(message #35 — 收尾指令)

**用户实际要求两件事**:
1. **挑战者要有方法论 + 数据来源向导**(主智能体对称物)
2. **不建独立 skill**(跑了不读相当于白跑)— 改用"挑战者侧自取"(挑战者用自带 Read/Grep 工具直接读)

### 1.2 走过的弯路(决策追溯)

**起点**:议题 C(挑战者拿什么输入)。

**议题 C 内部讨论**(2026-05-26T05:53 AI 输出):
- 列出 5 类信息源 + 4 条设计原则
- 推荐"给挑战者:用户原话 / brainstorming 弯路 / 替代方案 / 待审对象 / 维度焦点 + ✅/❌ 例;不给:其他挑战者结论 / 用户'OK'反馈 / audit verdict / spec §2 设计目标"
- dogfooding:模拟本 batch 这个挑战者会找到的 3 个 🟡 finding

**议题 C → 发现 1**(用户 #29):挑战者拿到输入不知道怎么用 — 没方法论,只有 freestyle prompt。
- brainstorming / system-design 有 SOP,挑战者只有"找问题附证据"一句话
- 实际 freestyle → 严重程度判定 / 证据深度 / 跨挑战者一致性靠运气
- 本 batch C3 62% 🔴 vs C4 0% 🔴 就是证据

**议题 C → 发现 2**(用户 #30):挑战者不知道去哪找信息 — 没数据来源向导。
- 主智能体有 CLAUDE.md 文档索引 / Skill 地图
- 挑战者啥都没有,调度者每次 fork 临场列路径
- dogfooding:调度者必须显式告诉挑战者 "memory 在 `C:\Users\刘超凡\...`",否则挑战者完全发现不了 memory 系统

**议题 C → 发现 3**:回看 KG3(4 agent 文件 176 行重复) — 同根。
- 挑战者在独立 context 跑,看不到 governance
- 要让挑战者用 governance,只能 inline 抄进 prompt → 重复 176 行
- 跟本 batch 自加 fix-2 静态约束自相矛盾

**4 个发现的共同模式**:挑战者跟 governance 之间没有标准的"知识传递"机制 — 每次 fork 调度者手把手喂,手动 + 易漏 + 不一致。

**候选解法 1**(2026-05-26T06:29):路径 1 — 新建 challenger-orientation.md 一个文件,4 块整合方法论 / 数据来源向导 / 输入策略 / 常见陷阱。

**候选解法 2**(2026-05-26T07:09):配套用户原话提取 skill — 让调度者每次 fork 前预提取用户原话存中间产物。

**用户否决候选解法 2**(message #34):"不要用户原话提取 skill,跑了不一定有人读 — 调度者不读相当于白跑"。

**收敛方案**(2026-05-26T07:22):挑战者侧自取 — 不让调度者预提取,让挑战者自己用 Read/Grep 工具读会话 JSONL。技术上完全可行(挑战者 general-purpose subagent 有 Read/Grep/Bash 工具)。

**最终方向**:候选解法 1(挑战者导览体系一个文件 4 块)+ 挑战者侧自取(导览 §2 数据来源向导含 JSONL 路径 + §3 输入策略含"自取用户原话"动作)+ KG3 顺手解(4 agent 改 include 模式)。

---

## 2. 设计目标 + scope 边界

### 2.1 设计目标

| 目标 | 落地形式 |
|---|---|
| **G1**:挑战者有统一方法论(替代 freestyle) | `challenger-orientation.md` §1(通用自检清单 §1.1 + 4 agent 各自专属技巧 §1.2-1.5 + 实操技巧 §1.6) |
| **G2**:挑战者有数据来源向导(替代调度者手把手喂) | `challenger-orientation.md` §2(全局架构 + 文档索引 + 跨平台路径 + 命令模板) |
| **G3**:挑战者能批判看调度者输入(防 framing) | `challenger-orientation.md` §3(输入策略 — 自取用户原话校验主线 + 输出必填 `### 已对照用户原话` section) |
| **G4**:挑战者避公设 1 / spec_gap_masking / 反对反对 陷阱 | `challenger-orientation.md` §4(常见陷阱 — 公设 1 应用 / spec_gap_masking 检测 / framing 警惕 / 反对反对 / 越权设计) |
| **G5**:KG3 顺手解(4 agent ~176 行重复消除,恢复 fix-2 静态约束) | 4 agent 文件 prompt 删原意图识别 + 综合输出准则段(~44 行/agent),换 ~8 行 include 引用 |
| **G6**:不引入新 skill / agent / hook / 代码 | 纯文档新增 + agent 文件改 prompt;`.claude/hooks/` / `.claude/skills/` 不动 |

### 2.2 Scope 边界

**在 scope 内**:
- 新建 `harness/docs/references/challenger-orientation.md`(主文件)
- 改 `harness/.claude/agents/design-reviewer.md`(删意图识别 + 综合输出节实文,改 include 引用)
- 改 `harness/.claude/agents/evaluator.md`(同上)
- 改 `harness/.claude/agents/process-auditor.md`(同上)
- 改 `harness/.claude/agents/security-reviewer.md`(同上)
- 改 `harness/docs/references/multi-agent-review-guide.md`(加 1 段引用 `challenger-orientation.md` — 区分"领审员视角(本指南)" vs "挑战者视角(challenger-orientation)")
- 改 `harness/docs/governance/synthesis-rules.md`(事后规则节加 1 条:"综合时校验挑战者输出含 `### 已对照用户原话` section,缺失或空 reject")
- 改 `harness/setup.sh`(加 1 行复制 challenger-orientation.md 到下游 references/ — meta-review 共识 1 修订:导览要分发下游)
- challenger-orientation.md + 4 agent + multi-agent-review-guide.md 内项目路径用裸 `docs/` 前缀(下游视角;harness 自仓库内 = harness/docs/,导览 §2 顶部说明)
- 改 `README.md`(原理段加挑战者导览体系简述,标"不分发下游"语义)
- decision-trail.md / handoff.md 同步(meta-finishing 必产)

**不在 scope 内**:
- **独立 skill**(用户 #34 否决 — 跑了不读相当于白跑)
- **hook / settings 改动**(`.claude/hooks/` 不动)
- **designer.md 改动**(designer 是产生设计文档的 agent,不 fork 挑战者,不属"综合阶段")
- **brainstorming-rules.md 改动**(brainstorming 阶段不涉及挑战者 fork)
- **"方向挑战 第 5 维"接口预留**(独立 batch,本 batch 完成后第 5 维启动时自然复用导览体系,不需提前 framing)
- **meta-review-rules.md 模态定义变动**(模态不变,只在 fork 流程引用导览路径)
- **新挑战者类型**(本 batch 不加新挑战者)

---

## 3. 详细设计

### 3.1 `challenger-orientation.md` 文件结构

总长度预估:400-600 行(参考 `multi-agent-review-guide.md` 130 行 + 4 块内容 + 跨平台路径详细)。

#### 3.1.1 顶部 frontmatter + 文件导读

```markdown
---
audience: 挑战者(fork 出的 subagent)
purpose: 给挑战者(子智能体)提供方法论 / 数据来源 / 输入策略 / 陷阱避坑的"入门必读"
when_to_read: fork 你的时候,prompt 内含 "先 Read `docs/references/challenger-orientation.md`" — 这是必读第一步
distribution: 本文件分发到下游(setup.sh 复制 references/)
---

# 挑战者导览(Challenger Orientation)

> 你是 fork 出来的挑战者(子智能体)。本文件告诉你 4 件事:
> 1. **怎么找问题**(§1 方法论)
> 2. **去哪找信息**(§2 数据来源向导)
> 3. **怎么看调度者给你的输入**(§3 输入策略)
> 4. **避哪些陷阱**(§4 常见陷阱)
>
> 不读本文件就开始审查 = 你处于 freestyle 状态,你的输出会被调度者综合时退回。
```

#### 3.1.2 §1 方法论

**§1.1 通用(13 挑战者全适用)** — 约 50 行
- 对抗-决策分离原则(引用 `multi-agent-review-guide.md` 核心一段)
- 4 个原则(独立视角 / 对抗不验证 / 可验证输出 / 结论可争议)
- **通用自检清单**(每次审查前默走):
  - [ ] 真读了调度者给的待审对象原文?
  - [ ] 对照过用户原话原文(从会话 JSONL 自取,不依赖调度者"主线"字段)?
  - [ ] 每个发现指向 file:line 或文档:章节?
  - [ ] 严重程度判定有客观标准?
  - [ ] 是否做假设(应改用客观证据)?
  - [ ] 是否提了替代方案(应只找问题,不写新方案)?

**§1.2 design-review 4 挑战者专属** — 约 40 行
- 挑战者 1(自洽性) — 矛盾追踪法
- 挑战者 2(完整性) — 场景遍历法
- 挑战者 3(过度工程化) — **反向追问法**(参 [[feedback_dimension_addition_judgment]] — 不用这个方式,之前的问题怎么解?有清晰替代解法 → 标过度;无 → 标必要)
- 挑战者 4(RUBRIC 对齐) — 条款对照法

**§1.3 evaluator 4 挑战者专属** — 约 40 行
- 挑战者 1(RUBRIC 合规)— 条款对照 + 测试充分性专项(按 scope 引 evidence depth 文件)
- 挑战者 2(架构一致性)— 路径追踪法
- 挑战者 3(文档健康)— README 对照法
- 挑战者 4(Slop 检测)— 模式扫描法

**§1.4 process-audit 2 挑战者专属** — 约 30 行
- 挑战者 1(流程遵从度)— 治理对照法
- 挑战者 2(效果满意度)— 情绪信号识别法 + 关键词与语境区分

**§1.5 security-scan 3 挑战者专属** — 约 30 行
- 3 挑战者(凭证 / 危险操作 / 注入混淆)— 模式扫描法 + 场景判定不可绕

**§1.6 实操技巧(通用)** — 约 30 行
- 证据深度等级(🟢 弱 / 🟡 中 / 🔴 强;追求 🔴)
- 严重程度判定(🔴 必修 / 🟡 建议 / 🟢 轻微 — 客观判定标准而非"感觉")

#### 3.1.3 §2 数据来源向导

**§2.1 harness 全局架构**(text 树形描述) — 约 30 行

**§2.2 文档索引(找 X 去哪)** — 约 30 行(主要表格)

| 找什么 | 去哪看 |
|---|---|
| 项目核心原则 / 公设 1+2 | `CLAUDE.md` |
| 治理规则 | `harness/docs/governance/*.md` |
| 评分标准 | `harness/docs/RUBRIC.md` |
| 多挑战者审查指南(领审员视角) | `harness/docs/references/multi-agent-review-guide.md` |
| 当前批 spec / plan | `harness/docs/superpowers/specs/` / `plans/`(取最新) |
| 当前批交接状态 | `harness/docs/active/handoff.md` |
| 历史 audit | `harness/docs/audits/meta-review-*.md` |
| 历史决策 | `harness/docs/decision-trail.md` + `harness/docs/decisions/*.md` |
| **用户校准 memory**(跨平台!) | 见 §2.3 |
| **用户原话(会话 JSONL,跨平台!)** | 见 §2.3 |

**§2.3 跨平台路径(关键!)** — 约 30 行

memory 位置:
- Windows: `C:\Users\<user>\.claude\projects\<project-slug>\memory\`
- Linux/Mac: `~/.claude/projects/<project-slug>/memory/`
- **不在 harness 仓库内**,在用户 home dir 的 .claude

会话 JSONL 位置:
- Windows: `C:\Users\<user>\.claude\projects\<project-slug>\*.jsonl`
- Linux/Mac: `~/.claude/projects/<project-slug>/*.jsonl`
- 多个 JSONL(每次会话一个),按 mtime 排序找最新

**`<project-slug>` 推断规则**:Claude Code 把项目路径特殊字符(中文、空格、冒号、反斜杠)替换为连字符;不要 basename 猜,用 process-auditor.md §2.1 的 Node.js 健康检测脚本定位(逐目录读首条 cwd 字段比对当前 cwd)。

**§2.4 常见审查问题对应的数据源** — 约 20 行

| 你要审什么 | 优先查 |
|---|---|
| spec 是否对齐用户原话 | 会话 JSONL(本 batch 所有 user message,按时间序) |
| 调度者主线段是否 framing | 1. 调度者注入的"主线-支线-关系"段 vs 2. JSONL 用户原话 |
| 历史类似决策怎么做的 | `decision-trail.md` 时间序 + `decisions/*.md` |
| 治理规则真实约束 | `governance/<阶段>-rules.md` 原文(不是 spec 引用版) |
| 上 batch known-gap 未解决 | 最新 `meta-review-*.md` audit §6 KG 表 |

**§2.5 实操命令模板** — 约 30 行
- 找当前会话 JSONL 命令
- grep user message 的 Node.js 单行命令(复用 process-auditor.md §2.2 脚本逻辑)
- 找历史 audit 命令

#### 3.1.4 §3 输入策略

**§3.1 调度者给你什么(预期清单)** — 约 20 行
- "主线-支线-关系"段(synthesis-rules 事前规则 5)
- 维度推荐(A/B/C 三段或 N/G 段)
- 待审对象(spec / agent 文件 / 代码 diff)
- 配套资料(RUBRIC.md / ARCHITECTURE.md / evidence depth 文件)

**§3.2 你要批判看调度者给的输入** — 约 30 行
- 核心警惕:调度者也是 AI,公设 1 适用
- ✅/❌ 对照表(主线写法 vs 你怎么看)

| 调度者写 | ❌ 直接采信 | ✅ 批判看 |
|---|---|---|
| "主线:本会话整体在做 X(落地路径选方向「Y」)" | 接受"路径 Y 已定" | "方向「Y」"是结论引导,我应从 JSONL 看用户原话怎么提的 |
| "主线:用户需要 GateGuard 完整设计" | 接受"用户要 GateGuard" | "GateGuard"是调度者命名,用户可能没用这词 — 从 JSONL grep |
| "支线:审 X spec 的自洽性,重点关注 Y" | 把 Y 当焦点 | "重点关注 Y"违反 synthesis-rules 事前规则 3,我独立判 |

**§3.3 必做动作 — 自取用户原话** — 约 30 行

fork 你的时候,你**必须做的事**:
1. 找当前会话 JSONL(§2.5 命令)
2. grep 本 batch 所有 user message,按时间序输出
3. 关注两类:用户**原诉求**句(本 batch 起点)+ 用户**关键决策**句(选项题选择 / 否决某方案)
4. 用这些原话**校验调度者主线-支线-关系段**:
   - 主线是否覆盖用户原诉求?
   - 主线是否扩展了用户没说的内容(framing)?
   - 关系字段是否反映用户的关注点?

**§3.4 输出必填:`### 已对照用户原话` section** — 约 40 行

挑战者输出**最末**必填一个 section(放在所有 finding 之后):

```markdown
### 已对照用户原话

**从 JSONL 抽取的用户原话**(N 条,按时间序;snippet 完整 quote 不解读):
1. [timestamp] "原话片段 1"
2. [timestamp] "原话片段 2"
...

**主线-支线-关系校验结论**:
- 主线对应用户原诉求:✅ 一致 / 🟡 部分覆盖 / 🔴 偏离(理由:...)
- 支线对应调度者意图:✅ 任务边界 / 🟡 含选择性
- 关系字段是任务边界:✅ 中性 / 🟡 含倾向引导

**(如发现偏离)主线偏离 finding**:
- 位置:[主线段哪一行]
- 偏离描述:[调度者写什么 vs 用户原话什么]
- 原话证据:[timestamp + 完整 quote]
- 影响:[挑战者后续审查会被怎么 anchor]
- 严重程度:🟡 / 🔴
```

**调度者综合阶段处理**(由 synthesis-rules 事后规则 5 新增条款定义):
- 缺失本 section → reject 该挑战者输出,要求重审
- section 内容空泛(无具体 timestamp + quote)→ reject
- section 显示主线偏离 🔴 → 升级为 finding 进综合,可能触发主线段重写

#### 3.1.5 §4 常见陷阱

**§4.1 公设 1 应用(挑战者乐观偏差)** — 约 20 行
- 挑战者也是 AI,也有"自评乐观"偏差
- 自检:我真努力找问题,还是看不出就停?
- 产出 0 个 finding 时必须说明"检查了什么、为什么认为没问题"

**§4.2 spec_gap_masking 检测(便利答案掩盖缺口)** — 约 30 行
- 参 [[feedback_spec_gap_masking]](用户 2026-04-17 三次纠正)
- 信号 A:spec 写"我们在 X 节加了 Y 占位符 / 警告,所以问题解决了" — 标 finding "缺口未承认"
- 信号 B:挑战者自身,信息不足时不要写 "✅ 已确认",而写 "⚠️ 信息不足无法判断"

**§4.3 framing 警惕(措辞引导)** — 约 20 行
- 警惕引导词:"显然 / 实际上 / 重点是 / 关键问题是 / 应该 / 需要严查"
- 调度者 prompt 出现这些词 → 违反 synthesis-rules 事前规则 3,标 finding 独立判断

**§4.4 反对而反对(挑战者过度否定)** — 约 20 行
- 挑战者带"对抗者"立场,可能为反对而反对
- 自检:这个 finding 有事实和逻辑,还是只是"听起来不对"?
- 充分证据反驳时会撤回吗?(应该会)
- 不写"应该重构 / 应该用别的方案" — 你只找问题附证据,不提替代方案

**§4.5 越权设计(挑战者超出找问题边界)** — 约 15 行
- 你只做:找问题 + 附证据 + 标严重程度
- 你不做:提替代方案 / 给整体打分 / 决定是否通过 / 修改 spec 或代码

---

### 3.2 4 agent 文件改造(include 模式)

#### 3.2.1 改动模式

**当前**(每个 agent 在 4-2 挑战者 prompt 前后约 44 行 governance 实文):
```markdown
### 第一步前 — fork 前意图识别(synthesis-rules 事前规则 5)
[~20 行 — 引用 synthesis-rules 路径 + 抽取来源说明 + 注入格式说明 + 注意事项]

[... 挑战者 prompt 主体 ...]

### 第 N 步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)
[~24 行 — 4 段格式说明 + 通俗化原则]
```

**改造后**(替换为 ~8 行 include 引用):
```markdown
### Fork 流程协议(synthesis-rules + challenger-orientation 引用)

本 agent fork 4(或 2 / 3)个挑战者时遵守:
- **事前**:synthesis-rules.md 事前规则 5(fork 前意图识别 — prompt 注入"主线-支线-关系"段)
- **挑战者侧**:挑战者 prompt 必含 1 行 "**先 Read `harness/docs/references/challenger-orientation.md`**,然后再开始审查;输出格式必填末尾 section `### 已对照用户原话`"
- **事后**:synthesis-rules.md 综合输出表达准则 + 综合时校验挑战者"已对照用户原话" section(缺失 reject)

[... 挑战者 prompt 主体不变(A/B/C 三段或 N/G 段保留) ...]
```

#### 3.2.2 每文件具体改动

**`design-reviewer.md`**(336 行 → 预估 ~265 行):
- 删 §"第一步前 — fork 前意图识别"段(~25 行)
- 删 §"第五步 — 综合后给用户的口语报告"段(~24 行)
- 加 §"Fork 流程协议"段(~8 行)
- 4 挑战者 prompt 头部加 1 行 include 提示(4 处)
- 4 挑战者 prompt 输出格式段加"必填末尾 section `### 已对照用户原话`"(4 处)
- 第二步综合段加"reject 逻辑:挑战者输出缺该 section 视为未完成,要求重审"(~3 行)

**`evaluator.md`**(480 行 → 预估 ~410 行):
- 同 design-reviewer 改动模式(4 挑战者 + scope 参数处理段保留 / 不删)

**`process-auditor.md`**(446 行 → 预估 ~385 行):
- 同上,2 挑战者(N1 流程遵从度 + N2 效果满意度)

**`security-reviewer.md`**(298 行 → 预估 ~245 行):
- 同上,3 挑战者(凭证 / 危险操作 / 注入混淆)

**改造净减少**:约 4 × 44 = 176 行 → 4 × 8 = 32 行,净减少 ~144 行(略低于 KG3 报的 176 行,因为本批次保留挑战者 prompt 主体的 A/B/C 段)

---

### 3.3 synthesis-rules.md 事后规则扩展

加 1 条事后规则(在现有 4 条事后规则之后):

```markdown
### 5. 校验挑战者"已对照用户原话"section

调度者综合每个挑战者输出时,**必须校验末尾 `### 已对照用户原话` section**:

**reject 条件**(任一命中 → 要求挑战者重审):
- section 缺失
- section 内容空泛(无 timestamp + 完整 quote)
- "用户原话" 列出 < 1 条
- 主线-支线-关系校验结论全部 ✅ 但 finding 中含主线偏离问题(自相矛盾)

**升级条件**:section 显示主线偏离 🔴 → 升为综合阶段 finding,可能触发主线段重写。

**适用范围**:design-review / evaluate / process-audit / security-scan / meta-review 所有 fork 场景 — 与事前规则 5 同步生效。

**与挑战者侧导览的关系**:本规则的挑战者侧动作落入 `harness/docs/references/challenger-orientation.md` §3.3 / §3.4(自取用户原话 + 输出必填 section)。本规则是调度者综合阶段的校验落地。
```

---

### 3.4 multi-agent-review-guide.md 引用 challenger-orientation.md

**位置**:文件顶部"> 所有审查类 agent 设计时参照本文件" 之后,加一段:

```markdown
> **本指南面向"领审员"视角**(谁来设计审查 agent / 怎么切分维度 / 怎么综合)。
>
> **挑战者(fork 出来的子智能体)视角的导览**另见 `harness/docs/references/challenger-orientation.md`(方法论 / 数据来源向导 / 输入策略 / 常见陷阱)。
>
> 两者对称:本指南管"调度者侧",challenger-orientation.md 管"挑战者侧"。
```

---

### 3.5 README.md 原理段同步

**位置**:`README.md` §4(原理 / 核心机制)末尾,加一小节:

```markdown
### 4.X 挑战者导览体系(挑战者侧基础设施)

主智能体(调度者)进项目时读 CLAUDE.md 知道项目结构 / Skill 地图 / 文档索引。挑战者(fork 出的子智能体)对称地需要一份"挑战者侧导览" — 知道:

- 怎么找问题(方法论 — 通用自检清单 + 角色专属技巧)
- 去哪找信息(数据来源向导 — 跨平台路径 + 命令模板)
- 怎么看调度者输入(批判性看 + 自取用户原话校验主线 framing)
- 哪些陷阱要避(公设 1 / spec_gap_masking / 反对反对)

实现在 `harness/docs/references/challenger-orientation.md`,fork 挑战者时 prompt 内含"先 Read 此文件";挑战者输出格式末尾必填"已对照用户原话"section,调度者综合时校验。

**与下游的关系**:本文件属 references/,setup.sh 复制下游 — 下游项目的挑战者也用同一份导览。
```

---

## 4. 涉及文件 + 改动清单(逐文件)

### 4.1 `harness/docs/references/challenger-orientation.md`(新建)

- 全文新建,~400-600 行
- 4 节(§1 方法论 / §2 数据来源向导 / §3 输入策略 / §4 常见陷阱)
- 顶部 frontmatter + 导读段

### 4.2 `harness/.claude/agents/design-reviewer.md`(改动)

- 删 §"第一步前 — fork 前意图识别"段(~25 行)
- 删 §"第五步 — 综合后给用户的口语报告"段(~24 行)
- 加 §"Fork 流程协议"段(~8 行)
- 4 挑战者 prompt 头部加 1 行 include(4 处)
- 4 挑战者输出格式段加"必填末尾 section"(4 处)
- 综合阶段段加"reject 缺 section 逻辑"(~3 行)

### 4.3 `harness/.claude/agents/evaluator.md`(改动)

- 同 4.2 模式

### 4.4 `harness/.claude/agents/process-auditor.md`(改动)

- 同 4.2 模式,2 挑战者
- 注意:本 agent 已有"预处理会话 JSONL 提取摘要"段(~120 行 Node.js 脚本)— **保留**,因为是 process-audit 专用,不与 challenger-orientation §2.5 命令模板重复(2.5 是给所有挑战者一般用法)

### 4.5 `harness/.claude/agents/security-reviewer.md`(改动)

- 同 4.2 模式,3 挑战者

### 4.6 `harness/docs/governance/synthesis-rules.md`(改动)

- 事后规则节加 1 条(规则 5 — 校验挑战者"已对照用户原话"section)
- 引用本 spec 路径在新规则末尾
- 估 +30 行

### 4.7 `harness/docs/references/multi-agent-review-guide.md`(改动)

- 文件顶部加 1 段引用 challenger-orientation.md 的"对称对照"说明
- 估 +6 行

### 4.8 `harness/setup.sh`(改动 — meta-review 修订)

- testing-standard.md 复制行之后加 1 行 `cp .../challenger-orientation.md` 到下游 `references/`
- 估 +1 行

### 4.9 `README.md`(改动)

- §4(原理)末尾加 §4.X 挑战者导览体系一节
- 估 +20 行

### 改动汇总

| 文件 | 性质 | 行数变化 |
|---|---|---|
| `challenger-orientation.md` | 新建 | +400~600 |
| `design-reviewer.md` | 改 | -50/+15(净减 ~35) |
| `evaluator.md` | 改 | -50/+15 |
| `process-auditor.md` | 改 | -50/+15 |
| `security-reviewer.md` | 改 | -50/+15 |
| `synthesis-rules.md` | 改 | +30 |
| `multi-agent-review-guide.md` | 改 | +6 |
| `setup.sh` | 改(meta-review 修订) | +1(复制 challenger-orientation.md 到下游) |
| `README.md` | 改 | +20 |
| `decision-trail.md` | 改(meta-finishing) | +5 |
| `handoff.md` | 改(meta-finishing) | +10 |
| **合计** | 8 个改 + 1 新 + 2 finishing | 约 +470~670 |

---

## 5. Scope 判定 + finishing 路径

### 5.1 Scope 判定

按 CLAUDE.md §3 scope.conf glob 对照:

| 改动 | 命中组 | 推导 scope |
|---|---|---|
| 新建 `challenger-orientation.md` | D 组(`docs/references/`) | meta |
| 改 4 个 agent 文件 | C 组(`.claude/agents/*.md`) | meta |
| 改 `synthesis-rules.md` | A 组(`docs/governance/*.md`) | meta |
| 改 `multi-agent-review-guide.md` | D 组 | meta |
| 改 `README.md`(根级) | A 组(`CLAUDE.md` glob 也覆盖根级 .md)/ 实际命中规则 | meta(根级 README 现有规则覆盖) |

**结论**:scope = **meta**(命中多组,任一即 meta)。

### 5.2 Finishing 路径

scope=meta → 走 M1 meta-finishing(`harness/docs/governance/meta-finishing-rules.md`)+ M2 meta-review(`harness/docs/governance/meta-review-rules.md`)。

具体路径:
1. spec 写好(本文件)+ 自检 → 用户 review → approve
2. writing-plans → 写 plan(`docs/superpowers/plans/2026-05-26-challenger-orientation-system.md`)
3. subagent-driven-development → implementer 逐 task 落地 + spec-compliance review + code-quality review
4. M1 meta-finishing → 调度者按 step A-D 走流程(Step B 必跑 meta-review,scope=meta 重大改动不可 skip)
5. M2 meta-review → fork 4 挑战者(对抗式 D2 模态,bootstrap 4 维基线 + 1-2 定制)
6. revision → 综合 finding → 修订
7. push origin/main + decision-trail append + handoff 更新

### 5.3 Meta-review 模态选择

按 M2 §6 模态分类,本 batch 属:**对抗式 D2 模态**(bootstrap 4 维基线 + 定制专项)。

**bootstrap 4 维基线**(必含):
- 核心原则合规(挑战者是否违反公设 1+2 / 角色分离)
- 目的达成度(G1-G6 是否全部落地)
- 副作用(本 batch 引入的新规则是否制造新问题)
- scope 漂移(改动是否超出 §2.2 在 scope 内清单)

**定制专项**(本 batch 主题特定):
- **挑战者侧自取的可执行性专项**:用 dogfooding 验证 — 本次 meta-review fork 的 4 挑战者,是否真按导览 §3.3 自取了用户原话 + 输出含 `### 已对照用户原话` section?如果挑战者自己都没做,本 batch 是 spec 层面写了规则但落地无效

**fork 数量**:4 个挑战者(基线 4 维分两挑战者覆盖 + 1 定制专项 + 1 包举余维)。

---

## 6. 测试 / 验收 / Evidence Depth

### 6.1 Evidence Depth

本 batch 属 meta scope,evidence depth 按 meta-finishing-rules.md meta-L1~meta-L4。

**目标 Evidence Depth**:**meta-L2**(规则文档 + agent 文件 + 实战 fork 1 次验证)。

不追求 meta-L3(自动化验证)— 因为:
- 挑战者导览是文档,自动化测试不适用
- "挑战者真按导览做事"只能 fork 跑一次实战验证(meta-L2)

不追求 meta-L4(用户原始数据点)— 因为:
- meta-L4 数据点(挑战者方法论真带来质量提升、数据来源向导真减少手把手喂)推 P1 实战项目验证([[feedback_realworld_testing_in_other_projects]])

### 6.2 验收清单(meta-L1 + L2)

**meta-L1 自检**(本批 implementer 必跑):
- [ ] challenger-orientation.md 4 节齐全(§1 / §2 / §3 / §4)
- [ ] §1 通用自检清单含至少 6 条
- [ ] §2.3 跨平台路径含 Windows + Linux/Mac 双版本
- [ ] §2.5 命令模板可执行(grep user message 命令能在当前会话跑出结果)
- [ ] §3.4 必填 section 格式范例 + reject 条件全列
- [ ] 4 个 agent 文件 governance 实文段(意图识别 + 综合输出)已删
- [ ] 4 个 agent 文件加了 include 引用 + 挑战者 prompt 必填段提示
- [ ] synthesis-rules.md 加事后规则 5
- [ ] multi-agent-review-guide.md 加挑战者侧引用说明
- [ ] README.md §4.X 挑战者导览体系一节
- [ ] grep 4 agent 文件,KG3 报的"意图识别节 + 综合输出准则节"实文 0 条命中(确认 fix-2 静态约束恢复)

**meta-L2 实战验证**:
- 跑 1 次 meta-review fork,4 挑战者真按 challenger-orientation.md §3.3 自取了用户原话
- 4 挑战者输出都含 `### 已对照用户原话` section,内容非空泛
- 调度者综合时按 synthesis-rules 事后规则 5 校验,无 reject

### 6.3 已知缺口(本 spec 不解,推后续)

- **KG-A**:挑战者真按导览做事还是 "spec_gap_masking 包装"(读了但没改变行为) — 用 dogfooding 一次验证可能不足,需多次 batch 积累
- **KG-B**:导览 §1.2-1.5 各角色专属方法的"方法精度" — 本 spec 只提"矛盾追踪法 / 场景遍历法"等命名,具体怎么做要 implementer 写时拍 + 后续 batch 调
- **KG-C**:跨平台路径(Windows + Linux/Mac)的 `<project-slug>` 推断在新机器首次跑可能失败 — 用 process-auditor 现有 Node.js 健康检测脚本兜底
- **KG-D**:多 batch 在同一个 session 跑时,挑战者怎么区分"本 batch 的 user message" vs "上 batch 的 user message" — 用 timestamp + handoff 切分点

---

## 7. 风险 / 反向追问 / 已知边界

### 7.1 反向追问([[feedback_dimension_addition_judgment]])

**Q**:如果不建挑战者导览体系,4 个同根问题怎么解?

**逐发现 反向追问**:

| 发现 | 不建导览的替代解 | 替代解的代价 |
|---|---|---|
| 发现 1 挑战者没方法论 | 每个 agent prompt 各自加方法论段 | 膨胀 + 漂移(KG3 同病)+ 无统一基线 |
| 发现 2 挑战者不知道去哪找 | 调度者每次手把手喂 | 漏 + 不一致 + 跨 fork 重复劳动 |
| 发现 3 主线 framing 风险 | 调度者写主线时自检(KG1) | 公设 1 适用,自检不够硬 — 上次审查已判 |
| 发现 4 KG3 4 agent 重复 | 直接从 agent 抽到 synthesis-rules | synthesis-rules 是调度者侧;挑战者侧没有对应载体 — 还是要建一个 |

**结论**:不建导览体系,4 个发现没有更便宜的替代解。反向追问通过。

### 7.2 风险

**R1 — spec_gap_masking 风险**:挑战者读了导览但不真按导览做事,只是输出格式合规("已对照用户原话"section 贴占位符)。

**缓解**:
- 调度者综合时校验 section 内容质量(非空泛)
- meta-review §5.3 定制专项审"是否真按导览做"
- 多次 batch 实战验证(L2 → 累积 L4 数据点)

**R2 — 导览膨胀**:本 spec 列了 4 节,实际写时可能滑动到"什么都加" → 文件 800+ 行,挑战者读不完。

**缓解**:
- 每节限定行数预算(§3.1.2 已列)
- meta-review 第 1 维"目的达成度"加子项"导览长度 ≤ 600 行;超过即过度工程化 finding"
- §1.6 实操技巧节是 nice-to-have,内容不足时可留占位"待 batch 实战发现后补"

**R3 — 跨平台路径硬编码**:导览 §2.3 列具体 `刘超凡` 路径,下游用户不是这个名字时失效。

**缓解**:
- §2.3 用 `<user>` / `<project-slug>` 占位符 + Node.js 脚本兜底(参 process-auditor.md §2.1 推断)
- 实际命令模板里给"how to find your project slug" 指导,不写死

**R4 — synthesis-rules 事后规则 5 与现有规则的耦合**:加 1 条事后规则可能与现有 4 条互相影响。

**缓解**:
- 新规则定位"挑战者输出校验",与现有规则(综合时怎么读)正交
- 在新规则段明确"适用范围:仅校验挑战者输出,不干预综合判断"

**R5 — KG3 改造后挑战者 prompt 信息密度下降**:原 ~44 行 governance 实文嵌入 prompt 提供了"完整指引";改 include 后挑战者必须 Read 才知道。如果挑战者不 Read,信息密度反而更差。

**缓解**:
- agent prompt 头部"Fork 流程协议"段必含 1 行"先 Read 此文件"
- challenger-orientation.md 顶部导读明示"不读 → 你处于 freestyle 状态,输出会被退回"
- 综合阶段 reject 逻辑(synthesis-rules 事后规则 5)兜底

### 7.3 已知边界(不在本 spec 范围内)

- 不解决"挑战者按导览做事但效果差"的元问题(meta-L4 数据)— 推 P1 实战
- 不解决"导览维护成本"(harness 演化时导览同步)— 用引用模式 + DRY,但实际同步还是需要审查
- 不解决"挑战者侧 Read 工具失败"(挑战者跑时 Read 出错)— 现有挑战者 Read 已有错误处理逻辑,本 spec 不重复
- 不预留"方向挑战 第 5 维"接口 — 独立 batch
- 不改 designer.md(designer 不 fork 挑战者)
- 不改 brainstorming-rules.md(brainstorming 不涉及挑战者 fork)

---

## 8. 与现有架构的关系

### 8.1 与 multi-agent-review-guide.md

multi-agent-review-guide.md 现有内容是面向"领审员"的(谁来设计 agent / 怎么切分维度 / 怎么综合)。本 spec 新建 challenger-orientation.md **不重复其内容**,改为:

- multi-agent-review-guide.md 加 1 段引用本文件(§3.4)
- challenger-orientation.md §1.1 通用部分**可引用**(不重抄)multi-agent-review-guide.md 的对抗-决策分离 + 4 原则

两者对称:领审员侧 + 挑战者侧。

### 8.2 与 synthesis-rules.md

synthesis-rules.md 事前规则 5(fork 前意图识别)+ 综合输出表达准则,是上 batch(fork-intent-and-report-clarity)落地的。本 batch:

- **事前规则 5 不动** — 但挑战者侧动作(自取用户原话校验主线)落入 challenger-orientation.md §3.3
- **加事后规则 5** — 校验挑战者输出"已对照用户原话" section

这是 fork-intent batch 的**自然延伸**:上 batch 让调度者注入主线,本 batch 让挑战者校验主线 — 形成闭环。

### 8.3 与 ECC-analysis-snapshot.md §11.12 GateGuard

GateGuard 是纸面设计(P1 未实现)。本 batch 不动 GateGuard,但**挑战者自取用户原话** 是 GateGuard"意图溯源链"的一个**轻量替代** — 调度者意图机制不在,挑战者侧自己做。

未来如果 GateGuard 实现,本 batch 的"挑战者自取"可作为 fallback / cross-check。

### 8.4 与 KG3(上 batch 已知缺口)

上 batch audit §6 KG3 报"4 agent 文件 ~176 行重复,与 fix-2 静态约束冲突"。本 batch 通过 include 模式直接解 KG3,fix-2 静态约束恢复。

### 8.5 与 "方向挑战 第 5 维" batch(未来)

本 batch 完成后,"方向挑战 第 5 维" batch 启动时:
- 新加的方向挑战 挑战者(第 5 维)**自动复用** challenger-orientation.md 通用方法论 + 数据源向导 + 输入策略 + 陷阱
- challenger-orientation.md §1 方法论加 §1.7(meta-review 方向挑战专属技巧)— 自然扩展,不需提前 framing

### 8.6 与 process-auditor.md §2.1-2.2 JSONL 处理脚本

process-auditor 已有"预处理会话 JSONL 提取摘要"的 Node.js 脚本(~120 行)。本 batch:
- process-auditor 内部脚本**保留**(它是 process-audit 专用,处理整 session 摘要)
- challenger-orientation.md §2.5 命令模板**更轻量**(给所有挑战者用,只取最近 N 条 user message)
- 两者各自服务不同场景,不重叠

---

## 9. Commit 策略

### 9.1 分 commit 推荐(3 commits)

**Commit 1 — challenger-orientation.md 新建**:
- 文件:`harness/docs/references/challenger-orientation.md`(新)
- 提交点:文件主体 4 节齐全,内部自检通过

**Commit 2 — 4 agent 文件改 include 模式**:
- 文件:`design-reviewer.md` / `evaluator.md` / `process-auditor.md` / `security-reviewer.md`
- 提交点:KG3 fix 完成,grep 验证 governance 实文 0 命中

**Commit 3 — governance 同步 + README + finishing**:
- 文件:`synthesis-rules.md`(事后规则 5)+ `multi-agent-review-guide.md`(引用段)+ `README.md` 原理段
- 提交点:全部引用对齐,准备 meta-review

### 9.2 也可合 1 commit

如果实施过程中 commit 1 + 2 之间发现 challenger-orientation.md 内容要调(因为写 agent 改动时发现导览节漏 X),可合并 1+2 为单 commit;commit 3 单独跑(governance 与主体改动可分开)。

---

## 10. 验收 Checklist

### Spec 验收(本节自检 + 用户 review)

- [ ] §1 用户原诉求 + 走过的弯路与 JSONL 实际对话对齐
- [ ] §2.1 G1-G6 6 个目标全部有 §3 详细设计对应
- [ ] §2.2 不在 scope 内清单与 §1 用户否决 / 用户未提对得上
- [ ] §3.1 challenger-orientation.md 4 节结构齐全
- [ ] §3.2 4 agent 改造每文件具体改动可执行
- [ ] §3.3 synthesis-rules 事后规则 5 文字定稿
- [ ] §3.4 multi-agent-review-guide 引用段定稿
- [ ] §5 scope 判定 + finishing 路径明确
- [ ] §6 验收清单可逐条对照
- [ ] §7 风险 5 条 + 反向追问通过
- [ ] §8 与现有架构关系 6 节齐全
- [ ] §9 commit 策略可执行

### 落地(implementer)

- [ ] challenger-orientation.md 全部 4 节写完,行数 400-600
- [ ] 4 agent 文件改 include 模式,grep 验证 governance 实文 0 命中
- [ ] synthesis-rules.md 加事后规则 5
- [ ] multi-agent-review-guide.md / README.md 同步
- [ ] decision-trail.md 加 2026-05-26 拐点

### Finishing

- [ ] M1 meta-finishing Step A-D 全跑
- [ ] M2 meta-review fork 4 挑战者(对抗式 D2,bootstrap 4 + 1 定制)
- [ ] meta-review verdict ≥ pass-after-revision
- [ ] decision-trail / handoff 同步
- [ ] push origin/main

### 实战验证(meta-L2 关键)

- [ ] meta-review 那次 fork,4 挑战者全部:
  - [ ] 在审查前 Read 了 challenger-orientation.md
  - [ ] 用导览 §2.5 命令找了用户原话
  - [ ] 输出含 `### 已对照用户原话` section,内容非空泛
  - [ ] section 内有至少 1 条 user message snippet + timestamp
- [ ] 调度者综合时按 synthesis-rules 事后规则 5 校验,无 reject

---

## 11. 关联文件

- 上 batch audit:`harness/docs/audits/meta-review-2026-05-26-094034-fork-intent.md`(KG3 / KG1 起源)
- 上 batch spec:`harness/docs/superpowers/specs/2026-05-25-fork-intent-and-report-clarity-design.md`(事前规则 5 + 综合输出准则的起源)
- 上 batch handoff:`harness/docs/active/handoff.md`(本 batch 接续起点)
- 治理引用:
  - `harness/docs/governance/synthesis-rules.md`(本 spec 扩展事后规则)
  - `harness/docs/governance/meta-review-rules.md`(本 batch 走 M2 模态 D2)
  - `harness/docs/governance/meta-finishing-rules.md`(本 batch 走 M1 finishing)
- 现有挑战者文档:
  - `harness/docs/references/multi-agent-review-guide.md`(本 spec 加引用段)
  - `harness/.claude/agents/{design-reviewer,evaluator,process-auditor,security-reviewer}.md`(本 spec 改造对象)
- 用户校准(memory):
  - `[[feedback_spec_gap_masking]]`(§4.2 spec_gap_masking 检测的起源)
  - `[[feedback_dimension_addition_judgment]]`(§7.1 反向追问 + §1.2 过度工程化方法的起源)
  - `[[feedback_realworld_testing_in_other_projects]]`(§6.1 不追求 meta-L4 的依据)
  - `[[feedback_talk_plainly]]`(2026-05-26 本会话新加;§4 常见陷阱 + 输出格式适用)
  - `[[feedback_iterative_progression]]`(本 spec 不预留第 5 维接口的依据)
  - `[[project_codex_claude_orchestration]]`(§8.3 未来 codex 编排时挑战者侧导览仍适用)

---

## 12. Meta-review 修订记录(2026-05-29)

meta-review(audit `meta-review-2026-05-29-081645-challenger-orientation.md`)verdict=pass-after-revision。修订:

- **共识 1(下游分发,用户决策 A 扩 scope)**:setup.sh 加复制 challenger-orientation.md;全文路径前缀统一裸 `docs/`(下游正确)+ §2 顶部加"路径前缀约定"说明(harness 自仓库 = harness/docs/);4 agent + multi-agent-review-guide 同步
- **共识 2(跨 shell)**:导览 §2.3/§2.5 加"用 Bash 工具(git-bash)不要 PowerShell"说明
- **共识 3 + KG-D(reject 不对称)**:§3.4 补例外项 + synthesis-rules 事后规则 5 补"🔴 无证据支撑 → reject 要求补证据"
- **C2 系统噪声**:§2.5 grep 加 `<command-`/`<local-command` 过滤
- 接受 known-gap:KG-C(batch 切分锚点)/ KG-D 深层(是否真比对推 P1)/ KG-E(调度者 fork 纪律)

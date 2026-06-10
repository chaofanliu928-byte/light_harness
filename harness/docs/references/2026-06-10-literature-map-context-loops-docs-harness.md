# 文献地图:上下文管理 / agent loops / 文档治理 / harness 设计(2026-06-10)

> **性质**:调研留痕(证据,非判断依据 — 参 research-scout 产出整形红线)。
> **产出方式**:deep-research 工作流(105 agent:5 检索角度并行 → 抓取 23 源 → 提取 115 条主张 → 25 条做 3 票对抗核验,22 存活 3 否决)+ 2 个补充全文精读(Anthropic 2026-03 续篇、Cognition 反方两篇)。
> **读法**:每条"核心主张"均经逐字引文核对;"与 harness 关联点"是结构类比标注,不是采纳建议 — 采纳与否的判断留给人。
> **姊妹文档**:[2026-06-10-scaffold-vs-ultracode-map.md](2026-06-10-scaffold-vs-ultracode-map.md)(仓库内部脚手架对照地图,与本图交叉印证)/ [2026-06-10-literature-map-llm-wiki-knowledge-org.md](2026-06-10-literature-map-llm-wiki-knowledge-org.md)(llm-wiki/知识组织文献地图)。

---

## 主题 1:上下文管理 / context engineering

### [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)(Anthropic, 2025-09-29)

- **compaction**:对话临近上下文上限 → 总结内容 → 用摘要重启新窗口("Compaction is the practice of taking a conversation nearing the context window limit, summarizing its contents, and reinitiating a new context window with the summary")。已产品化进 Claude Agent SDK(自动触发)。
- **structured note-taking / agentic memory**:agent 定期把笔记持久化到上下文窗口之外,跨数小时任务保持状态(例:Claude 玩 Pokemon 跨上下文重置续打)。
- **sub-agent 隔离上下文**:专职 sub-agent 用干净窗口处理聚焦任务,只回传 1,000–2,000 token 蒸馏摘要给编排者。
- **续篇时间性论述**:"smarter models require less prescriptive engineering, allowing agents to operate with more autonomy"(模型越聪明,需要的规定性工程越少)。
- 关联点:compaction 三步与 structured-handoff(快满 → 模板写 handoff.md → SessionStart 注入新会话)结构一一映射,差异在自动 in-loop 压缩 vs 手动文件交接;sub-agent 隔离与"调度者+扁平 fork"同构,**但动机不同** — Anthropic 重上下文经济性,harness fork 另有判断独立性(公设 1)这一层。

### [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)(Anthropic, 2025-06-13)

- lead agent 把 plan 写入外部 Memory 持久化(防 200K token 截断丢失);agent 换阶段前总结已完成工作存外部记忆;经精细 handoff 派生干净上下文的新 subagent 维持连续性。
- **成本一手数据**:agent ≈ chat 的 4 倍 token;多 agent 系统 ≈ 15 倍;内部 BrowseComp 评测中 token 用量单变量解释 80% 性能方差(限定:2025-06、Sonnet 3.7/4 时代、单一内部评测,非普适规律)。
- 关联点:文件化外部记忆+handoff 与活上下文链/交接闭环同构;4×/15× 是"加 fork 挑战者 vs 成本"权衡的唯一一手量化锚点。

### [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)(Anthropic, 2025-11-26)

- 实验结论:让模型"git 提交(描述性 message)+ 写 claude-progress.txt 进度摘要"是新上下文窗口快速恢复工作状态的最优方式;每实例只做增量进展并留干净环境。
- 关联点:与"handoff + git 留痕"做法相同;独立旁证有 Addy Osmani、arXiv Git Context Controller 论文。

---

## 主题 2:agent loops / 长时运行

### [Building agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)(Anthropic, 2025-09-29)

- agent 核心循环 = **gather context → take action → verify work → repeat**;设计原则"give your agents a computer"(通用工具,不做任务专用接口)。
- 关联点:verify work 是"做与判分开"在单 agent loop 内的最小版本;Claude Code 即按此 loop 运行。

### 同 2025-11 文(Effective harnesses…)

- **"仅靠 compaction 不够"**:即使 Opus 4.5 在 SDK 上跨窗口循环,只给高层 prompt 也造不出生产级 web 应用 — harness 结构必要。该文无任何"未来模型不需要脚手架"的表述。
- 架构:initializer agent(首轮搭环境:init.sh、JSON feature 列表、progress 文件、初始 commit)+ coding agent(每会话增量推进一个 feature、留干净状态)。按职能拆分,非评审者-执行者分离。
- **核验注**:此条投票 2-1,分歧在时效 — 必须与下面 2026-03 续篇配对读。

### [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)(Anthropic, 2026-03-24;上文直接续篇,作者 Prithvi Rajasekaran)

对"随模型变强减脚手架"**最直接的一手材料** — 实测拆脚手架全过程:

| 组件 | 命运 | 原文依据 |
|---|---|---|
| context resets | **因 Opus 4.5 移除** | "Opus 4.5 largely removed that behavior [context anxiety] on its own, so I was able to drop context resets from this harness entirely" |
| sprint 任务分块 | **因 Opus 4.6 移除** | "I started by removing the sprint construct entirely";4.6 无分块连贯跑 2 小时+ |
| planner(规划者) | **保留** | "Without the planner, the generator under-scoped"(没有规划者,生成者把范围做小) |
| evaluator(评估者) | **保留,条件性值钱** | "the evaluator is not a fixed yes-or-no decision. It is worth the cost when the task sits beyond what the current model does reliably solo";模型变强只是把这条边界外移("the boundary moved outward") |

- 方法论:"**when a new model lands, it is generally good practice to re-examine a harness, stripping away pieces that are no longer load-bearing**"(新模型落地即重审 harness,剥掉不再承重的部分)。
- 双向对冲(完整原文):"As models continue to improve… In some cases, that will mean the scaffold surrounding the model matters less over time… On the other hand, the better the models get, the more space there is to develop harnesses that can achieve complex tasks beyond what the model can do at baseline."
- 结论句:"**the space of interesting harness combinations doesn't shrink as models improve. Instead, it moves**"。
- 成本数据:retro game 任务 solo 20 分钟/$9 vs 全 harness 6 小时/$200(≈20 倍);DAW 应用全程 3h50m/$124.70。
- 配套代码:github.com/anthropics/cwc-long-running-agents。

### [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents)(Anthropic, 2026-04-08)

- **"Harnesses encode assumptions that go stale as models improve"**(harness 编码的假设随模型变强而过时)。实例:为 Sonnet 4.5 的 context anxiety 加的 context resets,到 Opus 4.5 行为消失、变成死重("The resets had become dead weight")。Cognition《Rebuilding Devin for Claude Sonnet 4.5》独立记录过同一现象。
- 架构:agent 拆为 session(只追加事件日志,**存活于上下文窗口之外的 context object**,经 getEvents() 按位置切片查询)/ harness(循环)/ sandbox(执行环境)三组件,稳定接口解耦;"脑"与"手"解耦后支持多 agent 编排。
- 关联点:"脚手架假设过时"的正面主张+实例;session 当窗口外持久层与活上下文链"机读 upstream + 按需加载"思路同向。

---

## 主题 3:文档治理 / spec 驱动开发

### [Harness engineering](https://openai.com/index/harness-engineering/)(OpenAI, 2026-02-11;本次 OpenAI 侧唯一全量核验入图的一手文)

- **AGENTS.md 只留约 100 行、当"地图"用**,指向更深的 truth 来源;知识库放结构化 docs/ 目录作 system of record;实现渐进披露(progressive disclosure)。
- **反对巨型指令文件的四条理由**(逐字核实):挤占任务/代码/相关文档的上下文;"When everything is 'important,' nothing is";立刻腐烂(变成过期规则的坟场);无法机械验证(单一 blob 不支持覆盖率/新鲜度/归属/交叉链接检查)。
- **计划是 first-class 工件**:执行计划连同进度与决策日志一起 check 进仓库。
- **文档腐烂的机械化对抗**:专用 linter + CI 校验新鲜度/交叉链接/结构;周期运行的 **doc-gardening agent** 扫描与真实代码行为不符的过期文档、自动开修复 PR。
- 理由:"From the agent's point of view, anything it can't access in-context while running effectively doesn't exist."
- 关联点:与"CLAUDE.md 治理入口 + docs/governance/ 分文件"结构高度对应;plans-as-artifacts 对应 specs/decisions 留痕;文档腐烂他们用机械化对抗,harness 当前靠 meta-review 触点完整性维人审兜底 — 同一问题两种解法。
- 访问注:直连 403,经代理+镜像双路验证;逐字引用前建议自行再访问原文。

### 扫到但本次未逐条核验(参考价值自判)

- GitHub spec-kit 发布文(spec-driven development 开源工具):github.blog
- Martin Fowler《exploring-gen-ai: SDD tools》:martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- Addy Osmani《good-spec》:addyosmani.com/blog/good-spec/

---

## 主题 4:harness / 脚手架设计(含反方)

### [Building effective agents](https://www.anthropic.com/news/building-effective-agents)(Anthropic, 2024-12-19)

- 基于与数十团队合作经验:"the most successful implementations use simple, composable patterns rather than complex frameworks";默认从简单 prompt 起步,**仅当可论证改善结果时加复杂度**。
- **workflows vs agents 二分**:workflows = LLM 和工具按预定义代码路径编排;agents = LLM 动态指挥自身流程。业界沿用为标准分类。
- **evaluator-optimizer 模式**:一个 LLM 调用生成、另一个评估反馈成环;适用条件 = 有清晰评估标准且迭代精炼有可测价值。
- **核验者要求随附的限定**:(1) 2024 原文理由是可调试性/透明性,**不是**"模型会变强" — 时间性论证出自 2025-09 续篇,二者须分开引用;(2) 原文是条件式,非反脚手架绝对论;(3) 厂商利益:开发者直连 API 对 Anthropic 有利。
- 关联点:evaluator-optimizer 与 fork 挑战者审查同构(差异:原文单评估者成环、未显式强调评估者上下文隔离;harness 是并行多维挑战者);workflows/agents 二分可作"减脚手架"方向在光谱上移动的标尺。

### Cognition 反方两篇(补充全文精读)

**[Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents)(2025-06-12)**

- 两条原则:共享上下文且共享完整 agent 轨迹("Share context, and share full agent traces, not just individual messages");"Actions carry implicit decisions, and conflicting decisions carry bad results"。
- 失败机制(Flappy Bird 例):任务拆两半并行,产出风格完全不一致 — 子任务的行动基于事先未规定的冲突假设。
- 当时总判断:"running multiple agents in collaboration only results in fragile systems";首选**单线程线性 agent**,超长任务用专职上下文压缩模型(自承"hard to get right")。

**[Multi-Agents: What's Actually Working](https://cognition.ai/blog/multi-agents-working)(2026-04-22)**

- 立场收窄而非放弃:"A lot has changed since then…we've begun to deploy multi-agent systems that actually work in practice"。
- **仍否定**:并行写入者集群、无结构 agent 网络("mostly a distraction")。
- **承认可行**:多 agent 出智能、**写入保持单线程**;read-only 子 agent 是主流形态;Manager Devin 委派(父拆任务、子各跑独立 VM)。
- **关键例外**(与第一篇"尽量共享"方向相反):编码 agent + 独立审查 agent 循环,"**we found this technique to work best when the coding and review agents do not share any context beforehand**"(事前不共享任何上下文效果最好);生产数据:平均每 PR 抓 2 个 bug,约 58% 严重。
- 遗留开放问题"全是通信问题":弱模型何时该升级求助 / 子 agent 的发现如何传给兄弟 / 如何传上下文不淹没接收者;跨 agent 通信默认不发生,因为模型没在需要它的环境里训练过。
- 关联点:审查场景"不共享上下文最好"是反方阵营给出的、与公设 1(做与判分开、独立上下文)方向一致的独立佐证。

---

## 时间线张力(摊事实,供方向判断)

```
2024-12  Anthropic:简单可组合优先,可论证时才加复杂度(理由=可调试性)
2025-06  Cognition:别建多 agent(写入冲突);Anthropic:多 agent research 系统(成本 15×)
2025-09  Anthropic:模型越聪明,需要的规定性工程越少(时间性论证首次出现)
2025-11  Anthropic:仅 compaction 不够,harness 结构必要(Sonnet/Opus 4.5 时点)
2026-02  OpenAI:文档治理更机械化(linter/CI/doc-gardening),不是更少
2026-03  Anthropic:实测剥脚手架 — resets/sprint 拆掉,planner/evaluator 留下;
         "新模型落地即重审、剥不承重的";"组合空间不缩小、只是移动"
2026-04  Anthropic:"harness 假设随模型变强而过时"(dead weight 实例);
         Cognition:多 agent 收窄立场 — 写入单线程可行,审查不共享上下文最好
```

横切观察(事实层面):被拆/可拆的均为**执行结构**(resets、sprint 分块);存留/加强的是**判断角色**(planner、evaluator)与**文档治理**(更机械化)。

---

## 核验警告(转引前必读)

1. **三条业界流行说法 0-3 否决,本图不背书**:"多 agent 比单 agent Opus 4 高 90.2%"数字、"context rot 现象"那套表述、"orchestrator-workers 模式定义"。引用前自行回源。
2. 本图"其他高质量个人/公司博客"维度**覆盖不全**(Manus、LangChain、philschmid、Simon Willison、rlancemartin bitter-lesson 等只作旁证),不能当领域全景。
3. 全部一手文章为 Anthropic/OpenAI 自述实践,效果无第三方验证;Anthropic"简单优先"与其商业利益方向一致。
4. 4×/15×/80% 成本数据基于 2025-06 老模型单一评测,2026 年模型与价格下是否仍是合理锚点,无更新数据。

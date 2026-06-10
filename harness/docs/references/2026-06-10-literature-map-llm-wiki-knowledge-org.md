# 文献地图:llm-wiki / 知识管理 / 资料组织方式(2026-06-10)

> **性质**:调研留痕(证据,非判断依据)。核心问题:**知识怎么组织才能同时供人和 agent 消费、不腐烂、可机械治理**。
> **产出方式**:deep-research 工作流(106 agent:5 检索角度 → 24 源 → 提取 119 条主张 → 25 条做 3 票对抗核验,24 存活 1 否决)+ 3 个补充精读(11 篇:PKM 实践 4 + 文档治理 4 + 知识供给对比 3 — 主工作流核验预算未覆盖子主题 3/4,补读填齐)。
> **核验等级标注**:【3-0】= 过对抗核验团全票;【补读】= 补充 agent 直接精读原文逐字摘引,未过核验团。
> **姊妹文档**:[文献地图·上下文/loops/文档治理/harness](2026-06-10-literature-map-context-loops-docs-harness.md) / [脚手架 vs ultracode 对照](2026-06-10-scaffold-vs-ultracode-map.md)。

---

## 主题 1:llm-wiki / LLM 友好的知识库形态

### llms.txt 标准提案【3-0】

- 出处:[Answer.AI / Jeremy Howard](https://www.answer.ai/posts/2024-09-03-llmstxt.html)(2024-09-03)、[llmstxt.org](https://llmstxt.org/)
- 做法:网站根放 `/llms.txt`,由**作者策展** LLM 应使用的内容清单(立场:作者策展优于自动爬取)。格式固定:H1 站点名(唯一必需)→ blockquote 摘要 → 详细信息 → H2 链接清单。
- **Optional 节 = 机读渐进披露**:"the URLs provided there can be skipped if a shorter context is needed" — 上下文预算受限时可跳过的层。
- 伴生约定:网页原 URL 后加 `.md` 提供干净 markdown 版(**同一知识双形态供人和 agent**);配套工具从 llms.txt 生成 llms-ctx / llms-ctx-full 上下文文件。
- **争议侧**(线索,未独立核验):Google 的 John Mueller 公开怀疑用处;"llms.txt is a dud"类批评;ppc.land 报道主流 AI 平台未消费该标准 — 争议集中在**消费侧采用率**,不在提案内容。供给侧采用已证实(Mintlify 等平台自动生成)。

### AGENTS.md 地图式入口【3-0】

- 出处:[agents.md](https://agents.md/)、[Linux Foundation 新闻稿](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)(2025-12-09)
- 定位:"Think of AGENTS.md as a README for agents";"README.md files are for humans" — 人机分工明确。官方自报 6 万+ 开源项目采用,20+ 工具支持。
- 治理路径:2025-12 起交 Linux Foundation 旗下 Agentic AI Foundation 中立托管(与 Anthropic MCP 同批)— 与 llms.txt 纯个人提案形成标准化路径对照。
- 争议侧(线索):Cline 的 pashmerepat 批"半成品样板 README"、缺 scoping/glob 规则;Upsun 主张 README 比 AI 配置文件更重要。

### DeepWiki:代码库自动 wiki + 机读引导 + MCP 化【3-0】

- 出处:[Devin 文档](https://docs.devin.ai/work-with-devin/deepwiki)、[Cognition 博客](https://cognition.ai/blog/deepwiki-mcp-server)(2025-05-22)
- 接入仓库时自动生成 wiki(架构图/文档/源码链接/摘要);**仓库根 `.devin/wiki.json` 机读配置控制生成**:repo_notes(每条 ≤10,000 字符)引导上下文,pages 数组显式指定页面与父子层级("Only the pages you define in the JSON will be generated, no more, no less")。
- MCP server 三工具:`read_wiki_structure`(读结构)→ `read_wiki_contents`(读内容)→ `ask_question`(问答)— 先地图、再内容、或直接问答的分层访问;公开仓库免费无鉴权。

### Mintlify:文档平台双轨供给【3-0】

- 出处:[Mintlify 博客](https://www.mintlify.com/blog/generate-mcp-servers-for-your-docs)(2025-03-06 起)
- 同时供给:`/llms.txt`("acts as a sitemap for AI",地图)+ `/llms-full.txt`(整站合成单一引用,一次性静态加载)+ 自动生成的 MCP server(生成过程中实时 tool call 查最新文档)。
- 明确摊出对比立场:**MCP 实时查询 vs 静态快照装窗,互补而非替代**。

### Context7:文档即 MCP 服务 + 反腐烂定位【3-0】

- 出处:[github.com/upstash/context7](https://github.com/upstash/context7)
- 把"最新的、特定版本的"库文档与代码示例直接注入 prompt,自我定位为解决 LLM 文档知识腐烂(训练数据过时 → 代码示例陈旧/API 幻觉/按旧版本泛化回答)。
- 库作者经仓库根 `context7.json` 控制解析(官方自比 robots.txt):projectTitle/branch/folders/excludeFolders/rules(给编码 agent 的最佳实践)/previousVersions 等九字段。

### Karpathy 的 LLM Wiki 模式【补读】

- 出处:[Karpathy gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)(约 2026 春;模式提案,非长期使用复盘)
- 核心主张:用 LLM 维护的 wiki 替代 RAG — LLM "incrementally builds and maintains a persistent wiki — a structured, interlinked collection of markdown files";知识合成一次持续维护,"The cross-references are already there. The contradictions have already been flagged."
- **三层架构**:① Raw sources(不可变原料,LLM 只读)② The wiki(LLM 完全所有的生成层:摘要页/实体页/概念页/交叉引用)③ The schema(类 CLAUDE.md 配置,"tells the LLM how the wiki is structured…makes the LLM a disciplined wiki maintainer rather than a generic chatbot")。
- **三操作**:Ingest(读源→讨论→写摘要页→更新索引和相关实体/概念页,一个源触及 10-15 页)/ Query(搜 wiki 合成,好答案**回灌**成新页)/ **Lint(定期体检:矛盾、过期断言、孤儿页、缺失交叉引用)**。
- 入口约定:`index.md`(按类别的内容目录)+ `log.md`(append-only 时间序,可解析时间戳)。
- 论点:"The tedious part of maintaining a knowledge base is not the reading or the thinking — it's the bookkeeping." — 人弃坑 wiki 的原因恰是 LLM 擅长的簿记。

---

## 主题 2:agent 记忆与知识管理系统

### Anthropic memory tool:纯文件系统路线【3-0】

- 出处:[claude.com/blog/context-management](https://claude.com/blog/context-management)(2025-09-29;原 anthropic.com URL 已 308 重定向)
- 设计:Claude 在开发者基础设施的专用 /memories 目录里创建/读/写/删**文件**,跨会话持久化 — 官方记忆机制选了**文件系统+目录,而非向量库/embedding/知识图谱**(工具仅暴露 view/create/str_replace/insert/delete/rename 文件语义)。
- 用途定位:"build up knowledge bases over time, maintain project state across sessions, and reference previous learnings"。
- 第三方分析(shloked.com,线索):确认"无 embedding、无向量库、就是文件",并讨论文件增长/记忆消退代价。

### MemGPT:OS 式分层换页路线【3-0】

- 出处:[arXiv 2310.08560](https://arxiv.org/abs/2310.08560)(UC Berkeley, 2023-10;后演化为 Letta)
- "virtual context management":借鉴操作系统分层内存,快/慢两级存储间换页,在有限窗口内提供扩展上下文假象。文档分析能处理远超窗口的大文档(迭代检索式,准确率受 retriever 封顶);多会话上构建"remember, reflect, and evolve dynamically"的 agent,记忆编辑与检索完全自主。
- 时效注:2023 年主张,相对今日 1M 级长窗模型偏旧,定位为路线对比的历史一手材料。

### Zep / Graphiti:时序知识图谱路线【3-0,数字带厂商自评标签】

- 出处:[arXiv 2501.13956](https://arxiv.org/abs/2501.13956)(2025-01,Zep 团队自撰)
- Graphiti = 时序感知知识图谱引擎,保持历史关系的同时动态融合对话数据与业务数据。LongMemEval 上 vs full-context 基线(约 115k token 全塞):仅用约 1.6k token,准确率最高 +18.5%,延迟 -90%(28.9s→2.58s)— **厂商自测**。
- **核验警告**:同论文摘要的 DMR 对比数字(94.8% vs MemGPT 93.4%)被 0-3 否决(Letta 团队曾质疑评测方法),引用该论文勿带此对比。

### A-MEM:Zettelkasten 进 agent 记忆(衔接主题 3)【补读】

- 出处:[arXiv 2502.12110](https://arxiv.org/abs/2502.12110)(Rutgers 等,2025-02 起修订至 v11)
- 批评现有记忆系统:"fixed operations and structures limit their adaptability";A-MEM "enables dynamic memory structuring without relying on static, predetermined memory operations"。
- **显式借鉴 Zettelkasten**("atomic note-taking and flexible organization"),三机制:① Note Construction — 每条记忆 =(内容,时间戳,LLM 生成的关键词/标签/上下文描述,链接集,embedding)元组;② Link Generation — embedding 余弦取 top-k 候选,再由 LLM 判断是否真正建链(向量召回+LLM 决策两段式);③ **Memory Evolution — 新记忆进入后回头更新老记忆的上下文/关键词/标签**("trigger updates to the contextual representations and attributes of existing historical memories")。
- 实验:LoCoMo + DialSim,六个基础模型;多跳推理上"at least two times better"于基线。

### 知识供给方式对比:agentic search vs RAG vs 长上下文【补读】

**Claude Code 不建索引的一手依据**([vadim.blog](https://vadim.blog/claude-code-no-indexing/) 2026-03-03,外部分析;内嵌 Boris Cherny 的 Hacker News 一手发言):

- Boris Cherny(Claude Code 作者):"Early versions of Claude Code used RAG + a local vector db, but we found pretty quickly that **agentic search generally works better**…It is also simpler and doesn't have the same issues around **security, privacy, staleness, and reliability**." 同事补充:"agentic search outperformed [it] by a lot, and this was surprising."
- 作者归纳的不建索引论点:实时性("an index built at session start is stale as soon as the first file changes")/ 安全(索引是攻击目标)/ 隐私(embedding 反演可部分还原文本)/ 可靠性(每多一个系统多一个故障点)/ 代码检索精确性("Grep finds exact matches…createD1HttpClient either appears in a file or it does not")。
- **代价不回避**:token burn(常见词返回几百匹配烧上下文;超大 monorepo 上迭代探索比一次语义查询费)+ semantic miss(改名后 grep 找不到)。
- 对照 Cursor 索引路线:Merkle 树增量 + 云端 embedding + Turbopuffer 向量检索,只存掩码路径/行号/向量。
- 适用分界(作者归纳):agentic search 赢在精确符号查找/活跃编辑/命名良好的中型库;索引 RAG 赢在超大 monorepo/概念搜索/陌生库;1M 长窗会模糊区分但有精度代价(转引第三方测评:Opus 4.6 在 1M 满窗时 MRCR 检索准确率掉 17 点,93%→76%)。

**RAG vs 长上下文的量化边界**([Anthropic Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval) 2024-09-19,官方):

- 边界逐字:"**If your knowledge base is smaller than 200,000 tokens (about 500 pages of material), you can just include the entire knowledge base in the prompt**, with no need for RAG or similar methods."(配 prompt caching 更快更省)
- 超过规模拐点才上 RAG,且传统 RAG 的缺陷是"remove context when encoding information" — 解法:embedding/BM25 索引前用 LLM 给每个 chunk 前置定位上下文。检索失败率:基线 5.7% → contextual embeddings 3.7%(-35%)→ +contextual BM25 2.9%(-49%)→ +reranking 1.9%(-67%);一次性成本 $1.02/百万文档 token。

---

## 主题 3:人类知识管理方法的 AI 适配【补读】

四个实践者来源,**唯一四源一致的做法:vault/仓库根放 CLAUDE.md(或同类 schema 文件)当 agent 的导航说明书**。组织骨架分三派:

| 实践者 | 出处/时间 | 方法 | 骨架 | 对双链的立场 |
|---|---|---|---|---|
| Stefan Imhoff(亲测) | [stefanimhoff.de](https://www.stefanimhoff.de/agentic-note-taking-obsidian-claude-code/) 2026-03 | Zettelkasten(fleeting/permanent/literature 三类笔记)+ PARA | 数字前缀分层目录(00-MOC…99-Meta),`/init` 生成 CLAUDE.md 教 Claude vault 结构 | 目录为骨架+backlinks 补充;用 agent 批量补 frontmatter 元数据、给 daily notes 回填双链 |
| JP Narowski(亲测) | [jpuncompiled.com](https://jpuncompiled.com/articles/tactical-guide-obsidian-second-brain) 2026-04 | 非 Zettelkasten 非 PARA,按角色/领域分目录(people/…、processes/…) | "Folders group related content; Claude Code navigates via a CLAUDE.md file describing vault structure **rather than relying on backlinks**" — 立场最鲜明 | 明确不依赖双链 |
| Karpathy / Wyndo(模式+落地) | gist + [aimaker.substack](https://aimaker.substack.com/p/llm-wiki-obsidian-knowledge-base-andrej-karphaty) 2026-04 | 三层(源/wiki/schema) | index.md 目录 + wiki 内交叉链接;"Obsidian is the IDE, the LLM is the programmer, the wiki is the codebase" | 交叉引用由 LLM 生成维护 |

- 选 Obsidian/文件系统的理由(Narowski):"A coding agent like Claude Code can read, write, search, and operate on every file without an API, a database, or any special integration."
- 工作流样本:Narowski 的定时 skill(`/daily-recap` 每晚拉会议转录+任务汇总、`/weekly-recap` 算对照季度优先级的 focus score)+ 自建插件自动管 frontmatter;Wyndo 的 `/ingest-url`(一次触及 5-15 页)、`/process-inbox`、`/lint-wiki`(查断链/孤儿页/矛盾/内容缺口)。
- **对传统 PKM 的批判**(Wyndo 亲历):"The theory is beautiful; in practice, **the maintenance kills it**…Because it took so much effort, I didn't actually do it as often as I expected." — 解法是把维护簿记整个交给 LLM。
- 反方/局限(Narowski 自承):Obsidian 学习曲线陡、协作差、本地化("Great for you, useless for your team");防过度工程:"That's how you end up with a beautifully organized vault you never actually use."
- 注:四源均未系统展开"目录 vs 双链 vs 标签 vs 索引"的对照实验 — 立场都体现在各自结构选择里,无实证对比数据。

---

## 主题 4:工程文档组织与治理【补读】

### Google《Software Engineering at Google》ch10 Documentation([abseil.io 全文](https://abseil.io/resources/swe-book/html/ch10.html))

- **docs-as-code 六件套**(原文列举):有规则可循 / 入版本控制 / 有明确 owner / 变更走审查**且随代码一起变** / 问题像 bug 一样追踪 / 定期评估("tested, in some respect")。
- **freshness 机制**:文档头部 `freshness: { owner: 'username' reviewed: '2019-02-27' }` 元数据;"metadata in the documentation set will send email reminders when the document hasn't been touched in, for example, three months" — 三个月未碰自动提醒 owner;把 owner 写进可见署名行"led to increased adoption"。
- **GooWiki 失败教训**:早期内部 wiki 因"no true owners for documents, many became obsolete"而失败 → 转向文档随代码住进 source tree、复用代码审查流程、错误进 bug 系统。
- 组织:g3doc(Markdown 与源码同库同目录,"update the code and its associated documentation **in the same change**")+ go/ 短链(单一权威位置,SSoT 落地)+ 文档分型(reference/design/tutorial/conceptual/landing,每类单一目的)。
- 类比逐字:"**If comments are the unit tests of documentation, conceptual documents are the integration tests.**"

### Anthropic Agent Skills([工程博客](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) 2025-10-16;2025-12-18 成开放标准 agentskills.io)

- Skill = "organized folders of instructions, scripts, and resources that agents can discover and load dynamically";比喻"like putting together an onboarding guide for a new hire"。
- **渐进披露三级**("the core design principle"):L1 启动只载每个 skill 的 name+description 进系统提示("just enough…to know when each skill should be used")→ L2 触发时读完整 SKILL.md → L3+ 按需导航捆绑文件("which Claude can choose to navigate and discover only as needed")。手册类比:目录→章节→附录。
- 容量论断:靠文件系统+代码执行,"the amount of context that can be bundled into a skill is **effectively unbounded**"(脚本可不入窗执行)。
- 作者实践:从评估找能力缺口起步;互斥上下文分文件省 token;name/description 决定触发;**让 Claude 把成功经验和常见错误沉淀回 skill**(知识回灌)。

### fiberplane drift:文档漂移 linter([博客](https://fiberplane.com/blog/drift-documentation-linter/) 2026-03-25)

- 反 LLM 路线(纯静态分析):**frontmatter anchor 把 spec 绑定到代码符号+基线 commit**:`src/auth/provider.ts#AuthConfig@a1b2c3d`(路径+可选符号+出处 sha)。
- 检测:"For each anchor, drift asks: has the bound code changed since the provenance commit?" 用 tree-sitter 做归一化 AST 指纹(语法感知,"Reformatting a file won't trigger a false positive"),CI 跑 `drift check` 检出陈旧即 exit 1("The CI gate makes drift hard to ignore")。
- 自承缺口:不阻止"只 relink 不改 spec" — 这步靠流程纪律不靠工具。

### Medusa:agent 自动更新文档([博客](https://medusajs.com/blog/up-to-date-docs-with-agentic-automation/) 2026-04-09)

- 双管线:开源 monorepo 在变更 **merge 时**触发 GitHub Action 分析文档相关变更;Cloud 私库在**部署时**触发,Claude Code 把代码变更翻译成自然语言跨仓库协调。
- 工具栈:Claude Code + 自研 docs-automator + 自定义 `/writing-docs` skill(内含文档结构/规范/约束,"avoiding AI slop")。
- 闭环:**agent 自动开 PR,人审人合**("Our documentation team reviews the pull request and can merge it")。无量化效果数据。

---

## 横向模式(跨来源事实归纳,采纳判断留给人)

1. **"根路径机读配置声明知识组织方式"已收敛为通行约定**:llms.txt(站点根)、AGENTS.md(仓库根,6万+)、`.devin/wiki.json`、`context7.json`(自比 robots.txt)、四个 PKM 实践者全部用 vault 根 CLAUDE.md、Karpathy 的 schema 层。harness 的 frontmatter 机读 upstream 编码与此同构且粒度更细(**文件级 vs 仓库/站点级**)。
2. **渐进披露被多家独立实现**:llms.txt Optional 节(按预算跳过)/ DeepWiki 结构→内容→问答三工具 / Mintlify 地图 vs 全量双形态 / **Anthropic Skills 元数据→全文→捆绑文件三级**。与 CLAUDE.md 地图 + L1-L6 分层是同一思路的不同切法。
3. **agent 记忆载体三条路线对照**:Anthropic 纯文件+目录(无向量库)/ MemGPT OS 式分层换页 / Zep 时序知识图谱;另有 A-MEM 把 Zettelkasten 原子笔记+链接+**记忆演化**(新知识回头改旧记忆)做进机制。Anthropic 的文件选择 + Claude Code 的 agentic search(弃 RAG,Boris Cherny 一手陈述)与"docs/ 分文件 + 让 agent 自己找"路线最近。
4. **反腐烂机制谱系**(从轻到重):freshness 元数据+到期提醒(Google,三个月邮件)→ AST anchor linter+CI 门禁(fiberplane)→ agent 检测变更自动开 PR 人审(Medusa;OpenAI doc-gardening 同族,见姊妹文档)→ LLM wiki 定期 lint(Karpathy:矛盾/孤儿页/过期断言)→ 拉最新源替代陈旧训练数据(Context7)。共同前提是 Google 的教训:**无 owner 的 wiki 必然腐烂**(GooWiki)。
5. **知识供给方式光谱**:静态策展文件(llms.txt 系)— 实时 MCP 查询(Mintlify/DeepWiki/Context7)— 文件式 agent 记忆(Anthropic)— 分层换页(MemGPT)— 时序图谱(Zep);量化边界:≤200K token 直接塞窗(Anthropic 官方),1M 满窗有精度代价(第三方测 17 点下降)。

---

## 核验警告(转引前必读)

1. 【3-0】条目过了三票对抗核验;【补读】条目为补充 agent 直读原文逐字摘引,**未过核验团**,逐字引用前建议自访原文。
2. **被否决**:Zep 论文的 DMR 对比数字(94.8% vs MemGPT 93.4%)0-3 否决,勿转引;其 LongMemEval 数字为厂商自测。
3. 厂商来源占比高(Cognition/Mintlify/Upstash/Anthropic/Zep 均自述),存活主张已框定为"官方定位/功能描述",非独立效果验证。
4. llms.txt 的消费侧证据缺口未补:主流 LLM 爬虫是否实际消费 /llms.txt,正反双方均无实测数据入图。
5. PKM 主题四源全部是顺风局记录或模式提案,无失败复盘、无"目录 vs 双链 vs 标签"对照实验数据。
6. 时效:agents.md 60k+ 为自报下界;所有"当前仍如此"核验时点为 2026-06-10。

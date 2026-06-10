# 开源「工作记忆 × 知识库」方案分档对照(2026-06-10)

> **性质**:调研留痕(证据,非判断依据)。背景:档位二(两层分离+晋升门禁)vs 档位三(状态与知识统一系统)的方案决策参照。
> **产出方式**:deep-research 工作流(105 agent,25 条主张三票对抗核验,24 存活 1 否决)。**覆盖警告:13 个候选只有 6 个产出过核验结论**,未覆盖的(MemGPT/Letta、Mem0、Zep、A-MEM、Aider、OpenHands、Basic Memory、LangGraph、second-brain 实现)本图不下结论;其中 MemGPT/Zep/A-MEM 的形态判断可参照[llm-wiki 文献地图](2026-06-10-literature-map-llm-wiki-knowledge-org.md)的已核验条目(标注来源)。
> **判档标准**:档位二判据 = 状态与知识是两个独立工件 + 有显式"沉淀后才覆写"门禁;档位三判据 = 状态只是统一索引/图谱/清单系统内的一个节点。

---

## 总发现(三票核验)

1. **已核验方案中,没有任何一个实现档位二定义的"先把工作记忆沉淀进知识库、快照才允许覆写"的显式门禁。** 唯一的晋升机制出现在 claude-flow 统一系统内部(episodic→semantic consolidation)——属档位三系统内的层间晋升,不是两工件间的交接门禁。
2. **现成的档位三全部离开了纯 markdown 文件**:ConPort 是 SQLite、MCP memory server 是 JSONL 图谱、claude-flow 是 AgentDB——消费它们需要跑服务/数据库,与"纯文件+开放约定"的模型无关地基有结构性张力。
3. **文件约定式家族(形态最接近本仓)有一手弃用证据**:Kilo Code 官方弃用 memory bank 模式,收敛为单一写保护的 AGENTS.md 静态指令文件("deprecated in favor of AGENTS.md"),弃用动机无一手陈述。

## 分档对照表

### 混合/光谱中间(文件分离但无门禁、无统一索引)

| 方案 | 组织方式 | 判档依据 | 活跃度 |
|---|---|---|---|
| **Cline Memory Bank** | memory-bank/ 下 6 个必需 md 按层级依赖:projectbrief(根基)→ product/system/tech Context → **activeContext.md(工作记忆:当前焦点/最近变更/下一步,"更新最频繁")** → progress | 状态与知识是分离工件(似档位二)但**无晋升门禁**(更新=手动 "update memory bank" 全量复查 + 随手同步,promote/distill/gate 类词全文零命中);也无统一索引(似档位三的层级图但靠"每任务强制全量重读"维系) | 规范文件 2025-07 定稿,2026-01 仍在 main |
| **Roo Code Memory Bank** | 同目录并列固定文件:activeContext(状态)+ decisionLog/productContext/systemPatterns/progress(知识) | 同 Cline;UMB 命令是"聊天历史→文件"的同步兜底,不是"工作记忆→知识库"的晋升 | ~1.7k stars,最后 release 2025-02,偏休眠 |

设计前提(家族原型表述,Roo/Kilo 逐字继承):"My memory resets completely between sessions... I rely ENTIRELY on my Memory Bank";强制规则 = 每任务开始全量重读所有文件(prompt 级指令,非代码强制)。

### 档位三(状态是统一系统内的节点)

| 方案 | 组织方式 | 判档依据 | 活跃度 |
|---|---|---|---|
| **ConPort(context-portal)** — 本批最清晰案例 | 单一 SQLite(每 workspace 一个 context.db),七类实体平级:ProductContext / **ActiveContext(当前焦点/最近变更/未决问题)** / Decisions / Progress / SystemPatterns / CustomData / ContextLinks(类型化关系) | 会话状态 = 统一数据模型中的一个实体,直接命中档位三判据;**无晋升门禁**(ActiveContext 与 ProductContext 各自独立读写);工作记忆覆写式但每次变更入 active_context_history 带版本号 | 765 stars,v0.3.13,push 2026-01-27 |
| **MCP 官方 memory server** | 单一 JSONL 知识图谱:实体+关系+原子观察,唯一存储通道 | 凡写入皆图谱节点(档位三形态),**但不承担会话交接职能**(9 个工具无任何 handoff/下一步字段约定) | 官方仓库活跃维护 |
| **claude-flow(已更名 ruflo)**(2-1 票,降置信) | 统一记忆系统(AgentDB)三层 TTL:working(agent 状态,1h)/ episodic(任务结果/决策,7d)/ semantic(模式/规则,永久) | 状态只是统一系统的一个层;**含已核验方案中唯一显式晋升:"Promoted from episodic via consolidation"**(系统内层间晋升;触发条件与实现质量未在代码层核实) | wiki v3.10.1,更名过渡期文档分散 |

### 不适用

| 方案 | 原因 |
|---|---|
| **Kilo Code** | 官方弃用 memory bank("deprecated in favor of AGENTS.md"),迁移 = 把多文件内容合并进根部单一 AGENTS.md(写保护、静态、无可覆写状态层),弃用公告未给替代的会话状态机制。注:营销页仍宣传该功能,与文档矛盾 |

### 未覆盖(本轮无核验结论;形态参照旧图)

MemGPT/Letta(OS 式分层换页统一系统)、Zep/Graphiti(时序知识图谱)、A-MEM(Zettelkasten 笔记图谱+记忆演化)——按旧文献地图的已核验条目,三者都是"统一记忆系统"形态(档位三族),但**均为程序化/数据库型**,且本轮未按判档标准核验,引用注意。Mem0/Aider/OpenHands/Basic Memory/LangGraph/second-brain 实现:零结论。

## 可借鉴机制(逐项一手核验)

1. **Roo 的 decisionLog append-only 纪律**:"Use insert_content to *append*. Never overwrite existing entries" — 决策只增不改,与本仓 decisions/ 留痕型生命周期一致。
2. **ConPort 的"覆写式工作记忆 + 强制版本化历史"**:每次覆写自动留版本可回查 — 与本仓 completed/ 归档同构,但粒度更细且自动。
3. **Cline 的 "update memory bank" 强制全量复查**:触发时必须审查全部文件(即使无需更新)— 一种防腐手段,代价是 token(社区有膨胀批评,未经三票核验,降级引用)。
4. **claude-flow 的 consolidation**:唯一显式晋升先例,值得看实现(open question:代码层未核)。

## 对档位决策的事实含义(摊事实,不下判断)

- **选档位二 = 发明,不是采用**:晋升门禁没有开源先例。但其零件全部有先例:文件分离(Cline 家族)、append-only 决策日志(Roo)、晋升概念(PKM fleeting→permanent / Karpathy lint / claude-flow consolidation)、版本化历史(ConPort)。
- **选档位三 = 现成形态都要离开纯文件**(数据库/图谱/服务),与已拍板的"跨运行时纯文件地基"冲突;纯文件版档位三(统一清单/编号)的本仓尝试(丙案 SUPPLY)已被对抗审查击穿。
- **反方向信号**:Kilo 从多文件快照库退到单一静态 AGENTS.md——比"贴墙纸"还保守;动机未公开(open question)。

## 核验警告

被否决 1 条(ConPort 的 links 机制单独作为档位三直接证据的强表述,1-2);活跃度数据仅部分核验(Cline 主仓/MCP 仓/ruflo star 数未验);失败教训覆盖薄弱(仅 Kilo 弃用是一手确证);文件约定式方案随时可被上游改写,实查时点 2026-06-10。

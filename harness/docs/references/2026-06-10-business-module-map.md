# harness 业务模块地图(2026-06-10,草案视图)

> **性质**:派生视图,不是权威源 — 把现有约 60 个脚手架组件按**业务能力**重新挂一遍,组件本体不动、不迁移。切法依据用户 2026-06-10 指示:"以业务和模块作为切法",不按材料/机制属性切。
> **用途**:① 对照 — 新技术(如 ultracode)来时逐模块问"它替代本模块的哪个面";② 局部修改 — 新功能/新技术的改动单元是业务模块,改一个模块先核对它的"对外契约"行,避免断暗线。
> **数据来源**:成员清单与覆盖度判定来自 [脚手架 vs ultracode 对照](2026-06-10-scaffold-vs-ultracode-map.md)(60 组件逐项分析);组织形态的业界对照见 [llm-wiki/知识组织文献地图](2026-06-10-literature-map-llm-wiki-knowledge-org.md)。
> **注意**:本文不引入新的 M-编号(仓库已有 M1-M20 机制编号,避免冲突),模块只用中文名。

---

## 总则:主线 × 模块 × 面

- **主线(业务流程脊柱)**:需求对接 → 系统设计 → 计划 → 实现/测试 → 审查 → 收口裁决。治理规则表(CLAUDE.md §2)本来就按它索引;阶段→模块的对应见下表。
- **业务模块**:挂在主线上的能力单元,每个模块**跨机制**收齐自己的 skill / agent / 治理文档 / hook / 模板。
- **面(原材料属性,降级进模块内部)**:每个模块内部再分四个面 — **机器面**(扇出/并行/格式强制等执行形态,ultracode 可替代的部分)、**知识面**(维度/标准/顺序/边界,不可替代)、**触发面**(hook/auto 保障)、**状态面**(跨会话持久化)。对照和裁剪都发生在"模块 × 面"的格子里,不动模块边界。

```
主线:  需求对接 ──→ 系统设计 ──→ 计划 ──→ 实现/测试 ──→ 审查 ──→ 收口裁决
模块:  [需求与调研]  [设计]      [─── 实现(含计划/测试) ───]      [收口裁决]
公共:  [对抗审查(被设计/收口/自治理调用)] [知识与上下文(全程)] [入口地图(会话起点)]
自身:  [自治理(改 harness 自己时)] [分发(交付下游时)] [运行环境(基础设施)]
```

---

## 模块一:需求与调研

**业务职责**:把模糊意图变成用户确认的需求清单;规划期界定问题、联网调研产出证据。

| 成员 | 机制 |
|---|---|
| brainstorming-rules.md | 治理文档 |
| agents/research-scout.md | agent(执行已让渡运行时 deep-research,只留判断层) |

**对外契约**:需求确认清单字段与 DESIGN_TEMPLATE 对齐(流向设计模块);回退入口表被设计/实现模块反向引用(回退坐标系)。
**新东西对照入口**:调研执行机器已让渡运行时(本仓库目标形态样本);知识面 = 收敛标准、确认清单模板、调研触发判据(可逆性×熟悉度)。

## 模块二:设计

**业务职责**:需求锁定后产出**过审的**设计文档(含设计审查这一质量环)。

| 成员 | 机制 |
|---|---|
| system-design SKILL + agents/designer.md | skill + agent |
| design-review SKILL + agents/design-reviewer.md | skill + agent(4 维并行挑战者) |
| design-rules.md | 治理文档 |
| references/DESIGN_TEMPLATE.md | 模板(9 节结构 + 自检 + 交叉验证) |
| docs/ARCHITECTURE.md | 架构规范锚点(分发件) |

**对外契约**:调用「对抗审查公共规程」(synthesis-rules 中性化/综合);RUBRIC 对齐维引用收口裁决模块的 RUBRIC;design-rules ↔ finishing-rules 6 条互引锚点由自治理模块的 check-meta-cross-ref 执法;审查结果落 docs/active/(状态面)。
**新东西对照入口**:机器面(fork designer + 4 挑战者扇出)ultracode 已原生覆盖且更强;知识面(规模判断表、10 条自洽清单、4 维定义、迭代上限、spec §0 防绕过)全部保留。

## 模块三:实现(含计划与测试)

**业务职责**:把过审设计变成符合契约的代码 + 同步的模块文档(开发执行由 Superpowers 驱动,本模块是叠加约束)。

| 成员 | 机制 |
|---|---|
| planning-rules.md / implementation-rules.md / testing-rules.md | 治理文档 |
| references/testing-standard.md | Evidence Depth 术语 SSoT |
| references/MODULE_DOC_TEMPLATE.md | 模板(文档随码) |
| check-module-docs.sh | hook(改代码提醒文档,触发面) |
| settings.json 内联 prettier | hook(格式化) |

**对外契约**:**前置依赖 Superpowers 插件**(brainstorming/writing-plans/TDD/code-review 由它驱动 — 对照分析挑刺员点名的缺失归因轴);Evidence Depth 字段被收口裁决模块的 check-evidence-depth hook 逐字解析;契约任务先行排序与设计文档 1.2/5 节挂钩。
**新东西对照入口**:行为约束部分与模型默认重叠;知识面(文档先行 — 与模型默认"代码优先"**相反**、回退判别表、双向测试校准)保留。

## 模块四:收口裁决

**业务职责**:分支收尾时做安全扫描 → 方向评估 → 流程审计 → 三路分流(合并/精磨/推翻),并把裁决留痕。

| 成员 | 机制 |
|---|---|
| finishing-rules.md(主流程 + scope 分流入口) | 治理文档 |
| security-scan SKILL + agents/security-reviewer.md | skill + agent(3 路) |
| evaluate SKILL + agents/evaluator.md | skill + agent(4 维) |
| process-audit SKILL + agents/process-auditor.md | skill + agent(1 审计员) |
| docs/RUBRIC.md | 评分标准(本模块核心标准件) |
| check-evidence-depth.sh | hook(字段兜底,触发面) |

**对外契约**:RUBRIC 被设计模块(对齐维)和实现模块(测试维)引用;scope 分流入口指向自治理模块(meta 路径);evaluate 分数趋势依赖 docs/active/evaluation-result.md 跨会话留存(状态面);audit 落 docs/audits/(被自治理 hook 核算)。
**新东西对照入口**:机器面(3+4+1 三个 fork 团扇出、顺序编排)ultracode 原生覆盖;知识面(分级政策、凭证扫描永不可绕、反模式约束/防自我豁免、三路分流处置)保留 — 反模式约束的对象恰是即兴编排者自身。

## 模块五:对抗审查(公共能力)

**业务职责**:被设计/收口/自治理三个模块调用的"多挑战者独立审查"公共规程 — 怎么构造中性 prompt、怎么综合、挑战者怎么自取证据。

| 成员 | 机制 |
|---|---|
| synthesis-rules.md(事前中性化 + 事后综合 + 表达准则) | 治理文档(跨阶段) |
| references/multi-agent-review-guide.md | 指南(领审员视角) |
| references/challenger-orientation.md | 指南(挑战者视角) |
| 二公设 + 角色分离表(载体在两份 CLAUDE.md) | 认知约束(寄宿入口地图模块) |
| model-route.md | 路由政策(codex 搁置基线) |

**对外契约**:所有 fork 场景必读;**已知方向性冲突**:ultracode 原生多数票裁决被事后规则 3 明文禁止 — 让渡机器面时此条必须显式带上。
**新东西对照入口**:扇出机器(并行/隔离/格式强制/对抗验证)是全仓库被 ultracode 覆盖最彻底的部分;知识面(中性化纪律、防锚定阅读顺序、盲区登记、综合标准)全部保留且约束对象是编排者自身。

## 模块六:知识与上下文(用户重点方向)

**业务职责**:跨会话连续性 + 知识组织不腐烂 — 交接、活上下文链、留痕区组织、调研留痕。

| 成员 | 机制 |
|---|---|
| structured-handoff SKILL + templates/handoff.md | skill + 模板(交接闭环) |
| templates/context/(L1/L2/README)+ check-context-chain.sh | 模板 + hook(活上下文链,分发下游) |
| session-init.sh + check-handoff.sh | hook(注入端 + 执法端) |
| templates/PROGRESS.md + templates/product-specs-index.md | 模板(历史账本/功能索引) |
| docs/decisions/_TEMPLATE.md | 模板(决策留痕,"AI 列选项人拍板") |
| references/README.md + recommended-tools.md + 调研文献地图三份 | 目录契约 + 立场知识 + 留痕 |

**对外契约**:handoff 字段被 check-handoff / check-evidence-depth / check-meta-review(skip 字段)三个 hook 逐字解析 — **字段名即契约**;session-init 注入的内容清单决定每个会话的起点;活上下文链是分发件、harness 自仓库不建 docs/context/(dogfood 边界)。
**新东西对照入口**:这是与业界收敛形态(根配置入口/渐进披露/文件式记忆/反腐烂谱系)对照最密的模块,文献地图横向五模式全部砸在这里;ultracode 对本模块覆盖为零(无跨会话状态)。

## 模块七:自治理

**业务职责**:改 harness 自身(治理文件/hooks/skills/模板)时的更严审查路径 — scope 判定、meta-review、审查台账核算。

| 成员 | 机制 |
|---|---|
| 根 CLAUDE.md(M3:scope 对照表 + 治理路由 + dogfood 边界) | 入口(自治理节) |
| meta-review-rules.md + meta-finishing-rules.md | 治理文档 |
| meta-scope.conf + check-meta-review.sh + check-meta-cross-ref.sh | 机读配置 + hook(执法) |
| references/2026-05-22-p0-9-4-self-check.md | trial 自查清单 |

**对外契约**:M3 §3 人读表 ↔ meta-scope.conf 机读表**双写同步约束**(改一处必改另一处);audit 产物(docs/audits/)的 frontmatter/covers 格式被 hook 逐字核算;meta 件不分发(分发模块过滤规则)。
**新东西对照入口**:机器面只有 fork 扇出形态(M2 §3/§4)被覆盖;触发/台账/scope 知识全部保留 — 21 条组件 16 条判"零覆盖"。

## 模块八:分发

**业务职责**:把各模块的下游形态一键安装进目标项目,并守住"meta 件不下发"等边界。

| 成员 | 机制 |
|---|---|
| setup.sh | 安装脚本(清单 + 过滤规则) |
| harness/CLAUDE.md(M4) | 下游入口模板 |
| templates/settings.json(M19)+ templates/README.md | 下游 hook 注册 + 维护规约 |

**对外契约**:setup.sh 的 cp 清单引用各模块的分发件(成员属地在各业务模块,本模块只管清单与边界)— 各模块增删分发件需同步清单;M19 双轨与自治理模块的过滤规则配套。
**新东西对照入口**:ultracode 对本模块覆盖为零(安装发生在下游 shell,会话之外);下游环境是否有 ultracode 是其他模块"机器面让渡"决策的边界条件。

## 公共层:入口地图 + 运行环境

- **入口地图**:两份 CLAUDE.md(地图/路由/公设)、两份 README(vision/完整说明)、QUICKREF(派生速查)。职责:每会话第一眼;对应业界"约 100 行地图式入口"收敛约定。
- **运行环境**:.gitattributes(LF 保证,hooks 可执行的前提)、settings.json 接线(事件→脚本绑定,服务所有模块的触发面)、jq/bash/git 外部依赖。

---

## 用法示例(对照怎么做)

新技术 X 到来 → 逐模块两问:① X 替代本模块**机器面**的哪部分?(如 ultracode:设计/收口/对抗审查三模块的扇出机器可让渡)② 本模块知识面/触发面/状态面是否被触碰?(通常不被,反而更重要)。改动落点 = 单个模块内,动手前核对该模块"对外契约"行。

## 已知待决(本图只标注不裁决)

1. RUBRIC 归收口裁决还是升公共标准件 — 它被三个模块引用。
2. session-init 归知识与上下文(注入端)还是运行环境(接线)— 现按业务归前者。
3. 文献地图等调研留痕归知识模块还是单设"调研留痕区" — 现挂知识模块下。
4. 本图自身的维护:确认后是否升级为常驻导航(进 README/CLAUDE.md 索引)、由谁保新鲜 — 升级会新增一处双写同步点,参照 Google "无 owner 的 wiki 必然腐烂" 教训,需先定 owner 与更新时机再升级。

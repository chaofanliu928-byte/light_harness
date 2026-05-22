---
status: parked
date: 2026-05-12
purpose: ECC (everything-claude-code) 项目分析与吸收建议的快照 — 未决策,留待将来按需落地
---

# ECC 项目分析快照(2026-05-12)

> 本会话讨论了 P2 codex 接入相关的三个外部项目分析,以及 harness 下个版本的吸收建议。
> 用户决定"先保存下来,以后再说"。本文件是分析快照,**未决策落地**,留待后续按优先级取用。

---

## 1. 外部项目 vendor 路径

| 项目 | 路径 | 用途 |
|---|---|---|
| openai/codex-plugin-cc | `D:\个人\harness\vendor\codex-plugin-cc\` | OpenAI 官方 CC 插件,通过 commands/agents/skills 调 codex CLI |
| ching-kuo/claude-codex | `D:\个人\harness\vendor\claude-codex\` | 社区 MCP 包装,plan/implement/review 跨模型 |
| affaan-m/everything-claude-code | `D:\个人\harness\vendor\everything-claude-code\` | 生态级项目,50 agents / 188 skills / 68 commands |

`/vendor/` 已加入 `.gitignore`,不入仓库。

## 2. ECC 项目本身的总体判断(挑战者结论)

来自反向校验 agent 的量化估算:**ECC 整体对 harness 是工具箱,不是模板**。

| 类别 | 估算占比 |
|---|---|
| 可参考(idea 层面) | ~15% |
| 与 harness 哲学冲突 | ~45% |
| 噪音 / 口号化 | ~25% |
| 强 vendor 耦合无法提取 | ~15% |

ECC 自陈数据(README / SOUL / AGENTS / EVALUATION)数字三套打架,触发 `feedback_judgment_basis` — **不能用 ECC 自陈数据做判断依据**。

---

## 3. 23 条吸收建议清单(按优先级四档)

> **实证档位(2026-05-13 新增)** — 取用时必看:
> - **概念档** — ECC 只有 SKILL.md 散文(信任度低,可能文档腔)
> - **协议档** — 有 hooks.json / JSON schema(中等信任)
> - **实现档** — 有 hook 脚本 + test 覆盖(高信任)
>
> 23 条整体偏概念档(fork 1 反向找漏发现 ECC 188 个 skills 多为散文)。取用某条前先实证 ECC 对应文件是否有可执行代码,避免吸收文档腔概念却无可用代码。


### 🥇 必做 4 条(原 5 条 — 脚手架主动拆原则 2026-05-13 剔除)

| # | 名字 | 性质 |
|---|---|---|
| 1 | Pathological Optimist 公设 | 补理论锚点(实践已有) |
| 2 | 行动公设(GateGuard 思想 + 方法 — **设计哲学 = 查意图 D+C 合体**,见 §11) | 补理论锚点 + **当真实 hook 需求出现时作为参考蓝本**(不预设 P1 启动 — 2026-05-13 修订) |
| 3 | ECC 故障 pattern 表 + 反模式编码 | 嫁接到 P3 步骤 5b/3,见 P3 框架文件 — **不嫁接强制模板字段到步骤 1**(用户原话已覆盖,见 2026-05-13 决定) |
| ~~4~~ | ~~脚手架主动拆~~ | **2026-05-13 剔除** — finishing 阶段已经够多事,加一条主观提问让流程变重;`feedback_iterative_progression` 已覆盖 |
| 5 | **model-route 自定义**(P2 核心) | 直接决定哪些 fork 角色 swap Codex。**实现参考 `vendor/codex-plugin-cc/plugins/codex/scripts/`,或直接复用 codex-plugin-cc 作为工具**(两个路径都可,落地时定 — 2026-05-13 修订);见 §11 |

### 🥈 短期推荐 2 条(原 5 条,3 条已剔除 — 见 §6)

| # | 名字 | 说明 |
|---|---|---|
| ~~5~~ | ~~Council anti-anchoring~~ | **已剔除** — 见 §6 |
| ~~6~~ | ~~De-Sloppify Pattern~~ | **已剔除** — harness 本来就是扁平 fork 架构,"用 fork 不用 prompt 约束"是默认做法,起名是包装 |
| ~~7~~ | ~~pass@k vs pass^k~~ | **已剔除** — harness 现行 meta-review/普通 review 已隐式区分,起名不改行为 |
| 8 | silent-failure-hunter | **5 类静默失败检测点写成 `review-rules.md` 挑战者 prompt 模板**(2026-05-13 修订 — 不新建 skill,挂到现有 review 流程):空 catch / 不充分日志 / 危险 fallback / 错误传播丢失 / 缺 timeout |
| 9 | feature-dev code-explorer phase | brainstorming 之前插一步"先扫现有代码",强制分析现有 pattern / 执行路径 / 集成点 |

### 🥉 P2 PoC 分类已撤销 — P2 改为极简方案不做 PoC

| # | 名字 | 处置 |
|---|---|---|
| ~~10~~ | ~~agent-eval CLI 框架~~ | **完全剔除** — P2 改为"扩范围 + git 兜底"(见 §11),不做 PoC 不需测量层 |
| ~~11~~ | ~~GAN evaluator 评分校准表~~ | **降到 ⚪ 不急** — 作为日常 review 锚点,与 P2 脱钩 |
| ~~12~~ | ~~model-route 路由表~~ | **升到 🥇 必做 #5** — 因 P2 极简方案直接需要 |

### ⚪ 不急但有意义 12 条

| # | 名字 | 一句话 |
|---|---|---|
| ~~11~~ | ~~GAN evaluator 评分校准表~~ | **2026-05-13 剔除** — 锚点描述太模糊;违反 `feedback_judgment_basis`(无 harness 自己样本前不能用别人项目锚点定标) |
| 13 | Ralphinho DAG 模式 | writing-plans 强制画 DAG + 每 step 列上游/下游契约 |
| 14 | post:edit:accumulator | Edit 累积,Stop 时批量验证(跨文件一致性) |
| 15 | pre:config-protection hook | 阻止 AI 通过改配置绕过 quality gate |
| 16 | verification-loop 6 phase | 修完代码后 Build/Type/Lint/Test/Sec/Diff 按序跑 |
| 17 | checkpoint 创建+回退 | debug 前锁状态,失败可对比 delta |
| 18 | feedback-NNN.md 累积 | 多轮 debug 反馈追溯模板(单文件用,不绑 GAN 协议) |
| 19 | /aside 命令 | 任务中插问不污染上下文 |
| 20 | Tool 返回 4 字段标准 | status/summary/next_actions/artifacts |
| ~~21~~ | ~~Skill provenance~~ | **2026-05-13 剔除** — `.provenance.json` 的 scope/confidence 字段隐含跨项目流通设计,违反 `feedback_skill_no_cross_project` |
| 22 | Two-Instance Kickoff | brainstorming 并行 fork reference 收集 — **约束**(2026-05-13):reference fork 仅事实陈列,不作论据,不直接进 brainstorming 候选(防违反 `feedback_judgment_basis`) |
| 23 | 15-Minute Unit Rule | writing-plans 每 step 加 checklist:独立可验证/单一主风险/清晰完成条件 |

---

## 4. 二公设(harness 治理认知约束)

待加进 `CLAUDE.md §1` 角色分离表上面:

```markdown
> **二条公设**(harness 治理的认知约束):
>
> 1. **Pathological Optimist**:AI 评估自己的产出存在系统性乐观偏差
>    (Anthropic 2026-03 观察)— 所以做事和判断必须分开。
>
> 2. **行动公设**:AI 在自己的窗口内"再想想"不能消除盲区
>    (信息状态不变)— 不确定时必须执行一个改变上下文的外部动作
>    (Grep / Read / WebFetch),不能放任内省。
```

**应用场景**:
| 场景 | 公设 1 | 公设 2 |
|---|---|---|
| design 完成 | fork 独立 evaluator | designer 不确定时 Grep 现有 pattern |
| 实现完成 | fork code-review | implementer 不确定时读相关代码 / 跑测试 |
| 本会话第 8 次 spec_gap_masking | — | 应 fetch URL 而不是"再想想搜索结果" |

---

## 5. Prompt 构造中性化规则(Council 轻量替代)

调度者构造给挑战者的 prompt 时,这个 prompt 本身不能带有调度者倾向。

### 4 条具体做法

| # | 规则 | 一句话 |
|---|---|---|
| 1 | 材料 selection 中性 | 不主动塞支持自己结论的证据 |
| 2 | 材料 ordering 中性 | 按客观顺序(文件路径 / 时间戳 / RUBRIC 维度)排,不按"调度者认为重要的"排 |
| 3 | 措辞中性 | 不用"显然 / 实际上 / 重点是 / 关键是"这类引导词 |
| 4 | prompt 独立审核 | 挑战者 prompt 由另一个独立 fork 审核,不能调度者自审 |

### Bad / Good 对照

**例 1 — 材料 selection**:
- ❌ "这是设计文档。这是 RUBRIC。**这是另一个项目用类似方法成功的案例**。请审查。"
- ✅ "这是设计文档。这是 RUBRIC。请审查。"

**例 2 — 材料 ordering**:
- ❌ "请审查这份设计。**关键问题包括 X、Y、Z**。完整文档如下..."
- ✅ "请审查这份设计。完整文档如下。按 RUBRIC 4 维度独立评分。"

**例 3 — 措辞引导**:
- ❌ "**显然**核心方案是 A 路径。请审查 A 路径的实施细节。"
- ✅ "方案候选 A 和 B 在文档中,请审查每个方案的可行性。"

**例 4 — 权威施压**:
- ❌ "**调度者认为**这个 hook 设计很关键,需要严格检查是否正常工作。"
- ✅ "审查 hook 设计是否符合 [一组明确的客观标准]。"

### 落地位置

- `harness/docs/governance/design-rules.md` 第 6 节(挑战者 prompt 构造)
- `harness/docs/governance/meta-review-rules.md` (meta 路同适用)

---

## 6. Council 完整机制 — 已剔除

ECC 提到的 Council 完整机制(调度者先表态 + fork 三个 voice + 综合对比)**已经剔除**,理由:

- harness 扁平 fork 已做 prompt 层隔离 — 挑战者看不到调度者上下文
- "先表态再对照" 是综合阶段工具,**不是 anti-anchoring 的必要机制**
- 引入完整机制增加复杂度,边际价值小

但 Council **核心担心(prompt 构造层偏向)是真实问题**,所以保留了"prompt 构造中性化规则"作为轻量替代(见 §5)。

---

## 7. 黑名单 — 高度共识不该吸收

| # | 黑名单项 | 拒绝理由 |
|---|---|---|
| 1 | continuous-learning v2 + /evolve + instinct-cli.py | 违反 feedback_iterative_progression + feedback_skill_no_cross_project + confidence 数字无统计基础。半个月内 v1 deprecate |
| 2 | GAN 三件套整体(含 spec.md/feedback-NNN.md/generator-state.md 文件协议) | 嵌套+文件协议冲突 harness 扁平 fork 决策(2026-04-16) |
| 3 | harness-optimizer + /harness-audit 自动改 harness | 单 agent 自动改 harness 配置,绕过 meta-review 闸门 — 触发 feedback_design_philosophy |
| 4 | agentic-engineering / ai-first-engineering 类口号 skill | 内容是 LLM-101 通识,SOUL.md 已写过 — 噪音 |
| 5 | autonomous-agent-harness skill | 强依赖 mcp-scheduled-tasks / mcp-memory / mcp-computer-use 4+ MCP 服务器 |
| 6 | 188 skills 中的语言/业务长尾 | 垂直业务 skill 不该跨项目复用 |
| 7 | ECC 自陈数据 | 数字打架,触发 feedback_judgment_basis |

---

## 8. 落地位置建议(真实需求出现时按需取用,不预设触发阶段)

> 2026-05-13 措辞修订:之前"等 P1/P2/P3 落地时按需吸收"违反 `feedback_iterative_progression`(预设阶段)。改为**真实需求出现时再 brainstorming 取用**,不预设触发阶段。



| 吸收项 | 落地位置 |
|---|---|
| 二公设 | `/CLAUDE.md §1`(M3 已加)+ `harness/CLAUDE.md` §角色分离表之后(M4 已加) |
| Prompt 构造中性化规则 + 综合阶段规则(合并版) | `harness/docs/governance/synthesis-rules.md`(2026-05-13 已建,事前 + 事后双段);各 governance 文件 link 引用 |
| 脚手架主动拆 | ~~`finishing-rules.md`~~ **已剔除**(2026-05-13)— 冗余 |
| P3 故障 pattern + 反模式(不含强制模板) | 嫁接到 P3 spec(见 `2026-05-12-p3-debug-sop-original-framework.md`) |
| GateGuard 方法层 | 当真实 hook 需求出现时作为参考蓝本 |
| 15-Min Unit Rule | `harness/docs/governance/planning-rules.md` step checklist |
| 经验库(a+c 混合) | `_TEMPLATE.md` 加 3 段(已落)+ `harness/docs/experience-index.md`(已建 — setup.sh 已加 cp) |
| 其他 ⚪ 档 11 条 | **真实需求出现时再 brainstorming 取用**,不预设触发阶段 |

---

## 9. 未决事项(下次再讨论)

- 二公设是否现在就加进 CLAUDE.md(改 4 行,5 分钟)
- 中性化规则是否现在就加进 design-rules.md(改 1 节,10 分钟)
- P3 spec 何时启动(基础已存档)
- **P2 swap 范围最终确认** — 明确不 swap 清单:调度者 / process-audit / security-scan 凭证档 / meta-review;其他是否都 swap?
- **P2 codex 接入项目选定** — codex-plugin-cc 官方插件 vs claude-codex MCP 包装,初步推荐前者
- **P2 swap commit 粒度** — 整体一次性 vs 逐角色独立 commit(影响精确 revert 能力)
- 23 条 ⚪ 档其他条目,是否在某次会话集中讨论筛选

---

## 10. 检索本快照的索引词

`ECC` / `everything-claude-code` / `P2 codex 接入` / `二公设` / `Pathological Optimist` / `行动公设` / `Council` / `GateGuard` / `中性化规则` / `黑名单` / `agent-introspection-debugging`

---

## 11. P2 实施路径(2026-05-12 大幅简化决定)

P2 codex 接入经过多轮简化,最终方案如下:

### 简化路径回顾

| 阶段 | 方案 | 试探强度 |
|---|---|---|
| 最初 | 阶段化 PoC + 完整 CLI | 强(写工具 + 跑实验) |
| 中间 | 1-2 角色试 + 观察期 | 中(小步试探) |
| **最终(2026-05-12)** | **直接扩范围 + git 兜底** | 极弱(全押 + 失败 git 回退) |

### 简化驱动逻辑

1. **目的修正**:跨模型对抗不是主要目的,**成本节省**是核心目的
2. **成本节省是已知事实**(Claude 同等能力 > Codex 价格),不需实验验证
3. **质量影响**实际跑就看得出,不需对照实验
4. **git 是已有基础设施**,零额外成本提供回退能力

### 极简实施路径(2026-05-13 终版 — 一次性扩范围 + git 兜底)

```
1. 接入前:git tag 标记当前状态(如 pre-codex-swap)
2. swap 所有可 swap 角色(按 model-route 自定义结果)
   - silent-failure-hunter / designer / security-scan 危险操作 + 注入
   - design-review 4 挑战者 / evaluate 非关键评分维度
3. 逐角色独立 commit(便于精确 revert)
4. 综合阶段全部保 Claude + 遵守"综合阶段规则"4 条
5. 实际跑一段时间
6. 出问题 → git revert 单 commit 或回到 tag
```

### 论文调整(2026-05-13)— 基于滑铁卢多 Agent 旁观者效应(arXiv:2605.10698)

**论文关键发现**:
- **GPT-5.4(codex 同族)社交压力阈值 = 2** — 加 2 个 agent 就崩(SWE-bench 100% → 23%)
- **Claude Sonnet 4.6 阈值 = ∞** — 唯一抗污染
- Gemini 受发言顺序影响

**对 harness 的核心警示**:codex 在多 Agent 协作场景下容易从众。但 harness 扁平 fork **理论上规避了大部分风险**(prompt 隔离 + 已废嵌套 + 综合阶段保 Claude)。

**实际调整(2 处)**:

1. **综合阶段全部保 Claude + 加规则提示词**(见下文"综合阶段规则 4 条")
2. **swap 范围明确化(社交压力暴露维度)**

**剔除的调整**:
- ~~分两波 swap~~ — 不需要,git 兜底足够
- ~~监控同质化信号~~ — 主观判断,执行困难,不引入

**swap 范围细化(社交压力暴露维度)**:

| 角色 | 社交压力暴露 | swap 判定 |
|---|---|---|
| 调度者(含综合阶段) | 高 | 不 swap |
| 单 agent / 单挑战者 | 无 | swap |
| 并行多挑战者扁平 fork | 理论无(prompt 隔离) | swap |
| evaluate 关键评分维度 | 高(关键决策) | 不 swap |
| meta-review / process-audit / security-scan 凭证 | 高(独立性 / 闭环) | 不 swap |

### 落地前必做:规则合并审查(2026-05-13 新增)

中性化规则 4 条(挑战者 prompt 构造)+ 综合阶段规则 4 条(调度者综合多份输出)落地前必须做一次"边界声明",明确:
- **中性化规则** 管"调度者构造给挑战者的 prompt 怎么写"
- **综合阶段规则** 管"调度者读多份挑战者输出怎么综合"

防止 process-audit 把两类问题混在一起查,避免规则重叠误用。

### 综合阶段规则 4 条(新增 — 待加入 synthesis-rules.md;5 个 governance 文件引用)

调度者综合多个挑战者结论时必须遵守:

1. **基于上下文意图综合** — 回到本任务最初的意图(GateGuard 查意图机制提取的),判断每个挑战者结论是否真正服务于这个意图。**不要让挑战者的具体观点替代你对意图的理解。**

2. **基于上下文决策综合** — 综合时回顾本会话已经做过的决策(设计选择 / 角色分配 / 排除项),判断挑战者结论是否与已有决策一致或合理偏离。

3. **基于客观角度综合** — 用 RUBRIC 维度对照每个挑战者结论,**不按"哪个挑战者听起来对"评判**。

4. **避免先入为主** — 读完所有挑战者结论后再下判断。综合时按 **RUBRIC 维度固定顺序**(自洽 → 完整 → 合理 → 对齐),**不按 fork ID / 时间戳 / 完成顺序**。

**逻辑链**:1 + 2 回归任务根本(意图 + 历史决策)/ 3 用客观维度评判 / 4 行为层防 anchoring。

### 12 GateGuard 设计哲学(查意图 D+C 合体)

`必做 #2 行动公设` 落地到 P1 hook 时的设计:

| 形态 | 适用 |
|---|---|
| **D 意图溯源链(主)** | 所有任务 — 追上游 / 本任务 / 下游意图链,结构性约束 |
| **C 用户确认回环(关键节点补强)** | 不可逆动作(meta 改动 / 部署 / 删数据 / D 中意图链有断点) |

**不单独用 A / B**:它们是 AI 自评意图,违反 Pathological Optimist 公设。可作为 D 中"本任务意图"那一栏的格式工具。

### Push back 角度(保留以备未来重审)

极简方案的隐藏假设:
1. 质量退化能被"明显"察觉 — silent failure 风险
2. git revert 是无成本回退 — 沉没决策成本
3. 全量 swap 优于小步试探 — 角色归因困难

**当前判定**:这些风险用 process-audit 闭环覆盖,可接受。若实际接入后出现 silent failure / 归因困难,**应回到中间方案(逐角色独立 commit + 观察期)**。

---

## 12. 项目经验库(2026-05-13 新增)

### 用途澄清

**经验库 ≠ debug pattern 表**(那是 ECC 外来形式)。

**经验库 = 项目层面经验沉淀**,用于:
- **技术选型经验复用** — 试过 X 方案,踩 Y 坑,放弃
- **能力边界记录** — 用 Z 思路实现 W,在某条件下失效
- **决策时借鉴** — brainstorming / system-design 时 grep 过往经验

### 落地形式:a + c 混合

**a — 强化已有 `docs/decisions/` 文件结构**

decision 文件模板加固定段:
```markdown
## 考虑过的备选(为什么排除)
- 方案 X — 排除原因:...

## 实现时发现的能力边界
- 当 [条件 A] 时,本方案在 [Z] 维度失效

## 踩过的坑(留给未来类似决策)
- 坑 1:...
```
每次做决策时**顺手记下来**,经验沉淀进 decision 文件。

**c — 经验索引文件 `docs/experience-index.md`**

索引所有"踩过的坑 / 能力边界"出现的位置,指向 decision / case / handoff 文件。**不规定固定形式,但能检索**。

### 与 P3 step 5b 的关系

**不嫁接** — 经验库和 debug 是两件事。P3 step 5b 不需要"故障 pattern 表"嫁接,改为依赖 GateGuard 查意图 + 多视角根因。

### 落地位置

- a:改 `docs/decisions/` 模板(future decision 文件按新模板写)
- c:新建 `harness/docs/experience-index.md`(初版索引)

---

## 关联文件

- P3 完整框架(用户原创):`harness/docs/decisions/2026-05-12-p3-debug-sop-original-framework.md`
- vendor 项目说明(不入仓库):`harness/docs/references/recommended-tools.md`(若需要可加 vendor 索引段)

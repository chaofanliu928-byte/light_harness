# Roadmap

下一阶段的工作方向。每项都是开放方向,具体需求和验收标准待进一步 brainstorming 收敛。

> 与 PROGRESS.md 的区别:PROGRESS.md 是已完成里程碑(只追加),ROADMAP.md 是未完成规划(会重写)。
> 与 decisions/ 的区别:decisions 记录"为什么这么决定 + 替代方案",ROADMAP 记录"下一阶段做什么"。scope 级变更先写 decision,再改 ROADMAP。

> 2026-04-15 重排:测试覆盖进入 scope(详见 `docs/decisions/2026-04-15-testing-scope-expansion.md`),原 ROADMAP 1/2/3 的顺序调整。本次重排经过 5 对抗者审查 + 领审员综合(见 decision 文档)。

---

## P-1:Handoff residual 字段清晰化(独立小改,可即刻合入)

现有 `docs/active/handoff.md` 的"已知问题"字段易被理解成 bug 列表。扩展内涵为 residual:bug / 故意暂缓的优化 / 待外部决策 / 测试文档缺口。

- 改动:字段加一行注释说明,或改名为"已知问题 / Residual"
- 代价:极小(1 行),零依赖
- 依据:structured-handoff 是跨 session 交接的核心;residual 显性化让下一轮 agent 更快接上

---

## P0:测试覆盖纳入 harness(L1 + L2 + L3)

对齐 `docs/decisions/2026-04-15-testing-scope-expansion.md` 方案 B。

### 现状(事实层,已核查)

测试治理**散落但非真空**:
- `docs/governance/design-rules.md` 有"第 6 节:测试策略"(验收条目)
- `docs/governance/planning-rules.md` 有"测试计划"节(层级 + mock 策略)
- `docs/RUBRIC.md` "代码质量"维度的 10 分档提了"测试覆盖"
- CLAUDE.md 核心规则 6 要求 lint/类型检查 hook
- TDD 委托给 `superpowers:test-driven-development`

**缺口**:
- RUBRIC 无独立"测试充分性"维度
- 无专用 testing-rules / testing-standard 聚合治理
- 无测试相关 skill / hook(lint hook 不算测试)
- Evidence Depth 概念缺失——无法在 finishing 时显式回答"验证到第几层"

scope 是**整合 + 升级**,不是**从零起步**。

### 内部执行顺序:L2 → L1 → L3(严格串行)

#### L2 先做:治理层(定义 Evidence Depth 语言的场所)

- 新增 `docs/governance/testing-rules.md`:什么时候必须写测试、颗粒度、契约任务 vs 实现任务的区别
- 新增 `docs/references/testing-standard.md`:定义 Evidence Depth L1-L4 + CI 阻断 的语义(**术语提案,待用户确认**;草案参考 `D:/个人/coding-agent-harness/references/regression-system.md`,但最终语义由用户定)
- CLAUDE.md "治理规则"表加一行:`implementation 阶段 → 先读 testing-rules.md`
- `implementation-rules.md` / `review-rules.md` 引用新文件
- `setup.sh` 复制新文件到目标项目

**为什么先做 L2**:L1 的评分档位用"L1 tests / L2 local_smoke..."语言,定义在 L2 的 testing-standard.md 里;不先做 L2,L1 的档位指向空值。

#### L1 再做:评估层

- RUBRIC.md 增加"测试充分性"独立维度
- **前置**:RUBRIC 的权重表(当前 6 维度 100%)需结构升级,允许维度变长 + 档位非分数制
- 档位用 L2 已定义的 Evidence Depth 语言
- evaluator agent 对抗者池增加"测试充分性挑战者",负责内容质量判断

**为什么在 L2 之后**:档位语言依赖 L2 的术语定义;RUBRIC 结构升级是隐藏前置,不能绕开

#### L3 最后做:声明层(子决策 B1-b 最小版)

- `finishing-rules.md` 加"Evidence Depth 声明"步骤
- `structured-handoff` 模板加显性字段 `## Evidence Depth`
- **新增 hook**:finishing 前检查 handoff 里 `## Evidence Depth` 字段非空,字段为空阻断(**只检字段存在,不检内容质量**——内容质量归 L1 的 evaluator)
- 声明不符证据时 evaluator 报告给用户,由用户决定是否打回(**不单方面打回**,符合 F2 不越权)

**为什么在 L1 之后**:判断"声明是否符证据"依赖 L1 的档位规则

### 不做 L4

L4(Regression SSoT + Cadence Ledger 进模板)价值依赖"≥3 个 surface"场景,当前无事实支撑。L2 治理文件里写一句引导语即可:"项目到多 surface 时考虑引入 Regression SSoT,参考...(当前不做)"。

### 验收信号

- 一次真实 finishing 的 handoff 能显式回答"验证到第几层、证据是什么"
- hook 能在字段缺失时阻断
- evaluator 能针对测试维度给出内容质量判断(不是自动打回,是报告给用户)
- L1-L4 + CI 阻断 语义已由用户确认(或由用户基于草案修订)

---

## P1:现有项目迁移到 harness(原 ROADMAP 2)

P0 完成后启动。把已有真实项目套上 harness,跑完整 brainstorming → design → plan → implement → finishing 闭环。

- 待定:目标项目
- 验收信号:完整闭环跑通,process-audit 产出报告,Evidence Depth 在 handoff 里显式出现
- 预期产出:暴露不适配点反哺 P2 的 ROADMAP 1 / 3 / L4

### P0 → P1 的依赖说明(补充)

P0 先于 P1 的理由**只成立一半**:P0 产物(testing-rules / Evidence Depth 字段)本身也需要 P1 真实验证才知道是否有效。单向依赖是假命题。

折中方案:**P0 完成 L2 + L1 的最小切片**(testing-rules 骨架 + RUBRIC 加维度但档位先粗略) → 启动 P1 一轮 finishing → 回来细化 L3 和 L1 档位。若 P1 暴露 L1 档位不合理,回到 P0 修订。

---

## P2:等 P1 产出真实数据后再定

### 可观测性(原 ROADMAP 1)

让 harness 治理过程可见、可审计、可回溯。

- 待定:观测对象(agent 决策过程?fork 执行历史?RUBRIC 演变?audit 趋势?)
- 待定:呈现形式(静态报告?hook 输出?CLI 暂不考虑,除非 P1 暴露"非 Claude 用户也要审计"的需求)
- 验收信号:能回答"上一次 design-review 为什么打这个分"
- **就绪信号**:P1 一次 finishing 就能产出足够数据

### 重复工作 skill 化持久化(原 ROADMAP 3)

把反复出现的手动步骤归纳为 skill 并跨项目复用。

- 现状:`skill-extract` 产出只落在当前项目
- 待定:持久化载体、触发条件
- 验收信号:一次识别的模式下一次/下一项目自动可用
- **就绪信号**:需 ≥2 个真实项目,P1 单项目无法触发

### L4 回归层(条件启用)

如果 P1 或后续项目出现 ≥3 个 surface 的场景,再考虑引入 Regression SSoT + Cadence Ledger。默认不做。

- **就绪信号**:多 surface 项目出现,P1 单项目可能完全不触发
- 触发时同步决策:是否补 surface 清单(子决策 B3 暂不做的那部分)

---

## 建议不做(可讨论,非既定)

以下四项经 5 对抗者审查后保留"不做"倾向,但 AI 不越权划死边界——每条都有反方论据,列出来供未来翻案判断:

| 事项 | 不做理由 | 反方论据(领审员综合) | 翻案信号 |
|---|---|---|---|
| 双轨 SSoT 参考文档 | 等 L4 触发再补,避免空中楼阁 | "循环依赖":没文档用户不知道何时该建 SSoT | 首次 L4 真实项目出现时重评 |
| 完整 11 Phase Onboarding Audit | 已有 `project-setup` 部分等价 | project-setup 实际只覆盖 Phase 1-4 一部分,Phase 7(关键 surface)/8/9/10/11 完全缺失 | L4 触发时 surface 清单需求出现时 |
| Task-Type Reading Matrix 进 harness 模板 | 流程轴 Matrix 已足够 | 现有 planning-rules 已暗中按"契约/实现"二分,任务类型差异已存在只是没抽出 | 发现治理文件多处重复按任务类型分支时 |
| Planning 三件套(task_plan/findings/progress)进模板 | 和 structured-handoff 同类型,当前单任务模式够用 | findings.md 当前无对应物,research 产物一 `/clear` 就丢(P0 的 B2-b 部分补了 handoff 的 `## 研究发现` 字段,作为最小补丁) | 跨 ≥3 session 任务或多并行子任务出现时 |

---

## ROADMAP 自身的生命周期(元规则)

- **完成的 P 项** → 迁移到 `PROGRESS.md`(只追加)
- **决策记录** → 存在 `docs/decisions/`(不和 ROADMAP 混写)
- **ROADMAP 自身保持滚动**:P 项完成、抛弃、合并都会让 ROADMAP 重写,每次重写前先写对应 decision
- 每次 scope 级变更(比如本次"测试进 scope"),**先写 decision 再改 ROADMAP**,不得反向

---

## 排期逻辑

- P-1 是独立小改,无依赖可即刻合入
- P0 两项是 scope 定义层面的缺口,内部严格串行 L2 → L1 → L3
- P1 是真实验证,允许 P0 做到最小切片后启动,P1 反哺 P0 细化
- P2 三项的就绪信号不同源(可观测性 P1 一轮即可,skill 持久化需 ≥2 项目,L4 需多 surface)

所有"做或不做"的判断,只依据两类输入:
1. 已确认的事实(文件状态、scope 定义、设计哲学)
2. 纯逻辑推导(重复建设反模式、依赖链、价值随维度非线性变化)

**不接受**"多少百分比的项目需要"这种市场判断——harness 未在外部业务项目跑过,没有数据支持任何比例。

## 与 Superpowers 的耦合边界(盲区补救)

- L1 tests 档位的实际执行依赖 `superpowers:test-driven-development`
- L2 治理规则与 Superpowers TDD 流程互补,不替代
- **耦合风险**:Superpowers 升级若改 TDD skill 接口,L1 判定可能失效——P1 启动前,verify 兼容性
- 若出现不兼容,短期 fallback:evaluator 手动判断 tests 通过,不依赖 Superpowers 接口

## 术语与定义归属

- Evidence Depth L1-L4 + CI 阻断 语义在 `docs/references/testing-standard.md` 中定义(**术语 SSoT**)
- 其他引用该术语的文件(RUBRIC / finishing-rules / handoff 模板 / evaluator 提示词)**只引用不重复定义**
- 术语变更必须先改 testing-standard.md,再同步下游(F3 文档先行)

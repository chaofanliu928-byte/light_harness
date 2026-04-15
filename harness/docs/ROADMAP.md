# Roadmap

下一阶段的工作方向。每项都是开放方向，具体需求和验收标准待进一步 brainstorming 收敛。

> 与 PROGRESS.md 的区别：PROGRESS.md 是已完成里程碑（只追加），ROADMAP.md 是未完成规划（会重写）。

> 2026-04-15 重排：测试覆盖进入 scope 后，原 ROADMAP 1/2/3 的顺序已调整。

---

## P0：测试覆盖进入 harness（L1 + L2 + L3）

把"测试"从极浅覆盖提升到完整闭环。现状是只在 RUBRIC"代码质量"里提了一句"测试覆盖"，没有治理文件、没有 RUBRIC 独立维度、没有 skill / hook，TDD 完全委托给 Superpowers。

### L1 评估层
- RUBRIC.md 增加"测试充分性"独立维度，评分档位用 Evidence Depth 语言（L1 tests / L2 local_smoke / L3 live / L4 browser_human_proxy / L5 hard_gate）
- evaluator agent 的对抗者池增加"测试充分性挑战者"

### L2 治理层
- 新增 `docs/governance/testing-rules.md`：规定什么时候必须写测试、颗粒度、契约任务 vs 实现任务的区别
- 新增 `docs/references/testing-standard.md`：定义单元/集成/冒烟/端到端的选型和覆盖率要求
- CLAUDE.md "治理规则"表加 `implementation 阶段 → 先读 testing-rules.md`
- implementation-rules 和 review-rules 引用新文件
- setup.sh 复制新文件到目标项目

### L3 确定性执行层（声明式，不强制执行命令）
- finishing-rules 加"Evidence Depth 声明"步骤
- structured-handoff 模板加显性字段 `## Evidence Depth`
- 声明不符证据时 evaluator 触发降级打回

### 不做
- L4（Regression SSoT + Cadence Ledger 进模板）：价值随 surface 数量非线性增长，还没有真实项目数据支持需要这个量级。L2 治理文件里写一句引导语即可："项目长到 N 个 surface 时考虑引入"。

### 验收信号
- 一次 finishing 产出 handoff 能显式回答"验证到第几层、证据是什么"
- evaluator 能针对测试维度打分并给出降级建议

---

## P0：Handoff 的 residual 字段清晰化

现有 `docs/active/handoff.md` 有"已知问题"字段，但易被理解成 bug 列表。扩展内涵为 residual：bug / 故意暂缓的优化 / 待外部决策 / 测试文档缺口。

- 改动极小：字段改名或加一行注释
- 依据：structured-handoff 是跨 session 交接的核心，residual 显性化让下一轮 agent 更快接上

---

## P1：现有项目迁移到 harness（原 ROADMAP 2）

P0 完成后再做。把已有真实项目套上 harness，跑完整 brainstorming → design → plan → implement → finishing 闭环。

- 待定：目标项目
- 验收信号：完整闭环跑通，process-audit 产出报告，Evidence Depth 在 handoff 里显式出现
- 预期产出：暴露不适配点反哺 P2 的 ROADMAP 1 / 3 / L4
- 为什么 P0 先于 P1：测试覆盖进 scope 后，如果先做 P1，真实项目会暴露"测试这块 harness 没东西可用"——等于让 P1 替 P0 做验证，但 harness 里还没东西可验证

---

## P2：等 P1 产出真实数据后再定

### 可观测性（原 ROADMAP 1）
让 harness 治理过程可见、可审计、可回溯。

- 待定：观测对象（agent 决策过程？fork 执行历史？RUBRIC 演变？audit 趋势？）
- 待定：呈现形式（静态报告？hook 输出？CLI **暂不考虑**，除非 P1 暴露"非 Claude 用户也要审计"的需求）
- 验收信号：能回答"上一次 design-review 为什么打这个分"

### 重复工作 skill 化持久化（原 ROADMAP 3）
把反复出现的手动步骤归纳为 skill 并跨项目复用。

- 现状：`skill-extract` 产出只落在当前项目
- 待定：持久化载体、触发条件
- 验收信号：一次识别的模式下一次/下一项目自动可用

### L4 回归层（条件启用）
如果 P1 或后续项目出现 ≥3 个 surface 的场景，再考虑引入 Regression SSoT + Cadence Ledger。默认不做，靠 L2 治理文件的引导语触发。

---

## 明确不做

| 事项 | 原因 |
|---|---|
| 双轨 SSoT 参考文档 | 文档需要读者有真实需要。harness 未跑过任何项目，写了是空中楼阁。等 L4 被真实项目触发再补 |
| 完整 11 Phase Onboarding Audit | 已有 `project-setup` 对话式等价物，重复建设违反"不过度叠加" |
| Task-Type Reading Matrix 进 harness 模板 | 我们的"治理规则"表是流程轴 Matrix 已足够。加任务类型轴需要具体项目的技术栈分区证据，是项目级补充不是模板级 |
| Planning 三件套（task_plan / findings / progress）进模板 | 与 structured-handoff 同类型（都是跨 session 交接）。没有事实证明需要更细粒度。等 P1 暴露真实不足再定 |

---

## 排期逻辑

P0 两项是 **scope 定义层面**的缺口（测试必须覆盖 + residual 必须清晰），不跑 P1 也能做。
P1 是 **真实验证**，没做过就无法判断 P2 的对错。
P2 三项都是 **基础设施类**，在 P1 出数据前做等于盲飞。

所有"做或不做"的判断，只依据两类输入：
1. 已确认的事实（文件状态、scope 定义、设计哲学）
2. 纯逻辑推导（重复建设反模式、价值随维度非线性变化）

**不接受**"多少百分比的项目需要"这种市场判断——harness 未跑过任何项目，没有数据支持任何比例。

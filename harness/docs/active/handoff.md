# 工作交接文档

> 只保留当前状态，给"下一个 AI"看。SessionStart hook 自动注入。
> 详细设计在 docs/superpowers/specs/，实现计划在 docs/superpowers/plans/。
> 里程碑历史在 docs/PROGRESS.md。

更新时间：2026-04-16

## 目标

harness 自身开发：完成 P0(测试覆盖 L1+L2+L3) 和应急修复 P0.5(扁平 fork 改造)。下一步等待目标项目 `D:\项目\智能体-生图` 的审查报告反哺 harness。

## 进度

### 已完成

- **P-1**:handoff.md 的 residual 字段清晰化(commit `6ef3e90`)
- **P0 L2 术语 SSoT**:`docs/references/testing-standard.md`(4 层 Evidence Depth + CI 阻断独立字段)
- **P0 L2 决策治理**:`docs/governance/testing-rules.md`(变更类型 → 最低 Evidence Depth 决策表)
- **P0 L2 全链路**:RUBRIC 加测试充分性维度、CLAUDE.md 治理表、handoff 新字段、setup.sh 分发(commit `a57c12a`)
- **P0 L1**:evaluator 子智能体 1 加测试充分性专项检查(磁盘 .claude/,gitignore)
- **P0 L3**:finishing-rules 加 Evidence Depth 声明步骤、新 hook `check-evidence-depth.sh`、settings.json 注册(commit `361f6d1` + 磁盘)
- **P0.5 扁平 fork 改造**:5 agents + 5 skills 全部改为"调度者并行 fork N 个挑战者"(磁盘)、decision `2026-04-16-fork-flat-refactor.md`、CLAUDE.md 角色表(commit `48881f0` + `06693ec`)
- **block-dangerous.sh 正则 bug 修复**:原 `curl.*|.*sh` 误拦 git show 等,改为 `curl[^|]*\|[[:space:]]*(ba)?sh\b`(磁盘)

### 进行中

- 等待目标项目(`D:\项目\智能体-生图`)同步改动 + 跑老版本审查报告

### 阻塞

- P1 未启动:需先拿到目标项目审查报告,判断是否以该项目作为 P1 目标

## 关键决策

- `docs/decisions/2026-04-15-testing-scope-expansion.md`(测试覆盖纳入 scope,4 层 + CI 阻断独立字段)
- `docs/decisions/2026-04-16-fork-flat-refactor.md`(扁平 fork 改造,P0.5)

## 涉及文件

### 可提交层(git 追踪)
- `docs/ROADMAP.md`
- `docs/RUBRIC.md`
- `docs/references/testing-standard.md`(新)
- `docs/governance/testing-rules.md`(新)
- `docs/governance/finishing-rules.md`
- `docs/active/handoff.md`
- `docs/decisions/2026-04-15-testing-scope-expansion.md`(新)
- `docs/decisions/2026-04-16-fork-flat-refactor.md`(新)
- `CLAUDE.md`
- `setup.sh`

### 磁盘层(.claude/ 被 gitignore,靠 setup.sh 分发)
- `.claude/agents/{evaluator,designer,design-reviewer,security-reviewer,process-auditor}.md`
- `.claude/skills/{evaluate,design-review,security-scan,process-audit,system-design}/SKILL.md`
- `.claude/hooks/{block-dangerous,check-evidence-depth}.sh`
- `.claude/settings.json`

## 下一步

1. **等待**:用户在 `D:\项目\智能体-生图` 同步 .claude/ 改动(手动 diff 或重跑 setup.sh),然后跑老版本三段审查提示词
2. **收到报告后**:带回 harness,反哺改进(可能影响 P1 目标选择、可能产生新的 P0.x 修复项)
3. **若审查顺利**:启动 P1(目标项目或新项目作为真实验证)
4. **若审查暴露新缺陷**:先补修复,再进 P1

## 研究发现

> 存放当前任务的 research 产物(技术调研、方案对比、外部资料)。归档时随 handoff 一起归入 docs/completed/。
> 如果任务跨 ≥3 session 或涉及多并行子任务,考虑拆到 docs/09-PLANNING/TASKS/ 独立目录。

### P0.5 fork 嵌套失效的根因
- Claude Code 的 subagent 默认没有 Agent 工具权限,两级 fork 失效
- 来源:目标项目 `D:\项目\智能体-生图` 的 P1 验证中用户亲自发现
- 修复方案:扁平化 fork,主对话(调度者)直接 fork N 个独立挑战者
- 本会话的 5 对抗者并行审查是该模式的可行性验证

### 老版本两级 fork 的降级行为
- 目标项目的 harness 是老版本,evaluator/design-reviewer/security-reviewer/process-auditor/designer 都靠嵌套 fork
- 实际发生:领审员 fork 失败 → 按 "Fork 失败降级" 规则在主 context 分角色推演
- 影响:对抗式审查退化为单 context 自问自答
- 相关证据待审查报告中的"session 记录深挖"部分核实

## 关键上下文

### 5 对抗者方案评审(本会话中间节点)
对 2026-04-15 首次 ROADMAP 修订做过一轮 5 角度对抗审查(事实基础 / 不做清单反方 / 优先级 / 设计哲学 / 盲区),找出多个问题并修订。修订后的 ROADMAP 和 decision 是当前版本。

### 用户反馈的设计哲学(memory 已记)
- 不过度简化、不越权决策、变更先改文档
- 判断必须基于事实和逻辑,禁止市场判断(如"90% 项目")

## 当前阶段

**等待外部输入**:目标项目审查报告。harness 自身开发阶段完成 P-1/P0/P0.5。

## 当前分支

`main`,领先 origin/main 8 个提交(未推送)

## 已知问题 / Residual

> 包含 4 类：bug / 故意暂缓的优化 / 待外部决策 / 测试或文档缺口。不是只记 bug。无则显式写"无 residual"。

- **待外部决策**:目标项目审查报告拿到后,是否以该项目作为 P1 / 是否需要新一轮 P0.x 修复
- **故意暂缓**:L4 回归层(Regression SSoT + Cadence Ledger)——等多 surface 真实项目出现再启用
- **故意暂缓**:双轨 SSoT 参考文档、完整 11 Phase Onboarding Audit、Task-Type Reading Matrix 入模板、Planning 三件套进模板——等 P1 真实不足暴露再议
- **测试文档缺口**:harness 自身的开发没走完整 finishing 闭环(self-dogfood 缺失)
- **测试文档缺口**:目标项目还未同步 P0/P0.5 改动,老版本审查前不能判断新版本真实效果

## Evidence Depth

> 格式规则见 `docs/references/testing-standard.md`。finishing 阶段必须填写,hook 会检查非空。

- L1 单元测试: ❌ 未跑(harness 自身无代码需要单测,以文档治理为主)
- L2 冒烟测试: ⚠️ 部分 — 本会话多次 git status/log/diff 验证提交正确,但无端到端流程验证
- L3 自动化 API 测试: ❌ 不适用(harness 不是 API 项目)
- L4 用户行为模拟: ❌ 未跑(P1 才做,当前等审查)

## CI 阻断

❌ 无 CI 阻断机制(harness 是治理框架仓库,未配 CI)

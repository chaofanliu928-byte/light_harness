# 决策演化轨迹

> P2 可观测性的**时间维度**(空间维度由 glassbox 覆盖,session 内可视化)。
> 跨 session 关键抉择的连续记录,链到 `decisions/` 单条文件看完整推理。

> 与 `PROGRESS.md` 区别:PROGRESS = 里程碑(功能维度,粗);本文件 = 抉择(判断维度,细)
> 与 `decisions/` 区别:decisions = 单条决策完整推理;本文件 = 决策之间的因果链 + 索引
> 与 memory(`feedback_*.md`)区别:memory = 用户跨项目原则(私域);本文件 = 项目内可见 artifact

## 已知缺口(2026-04-28 引入时显式承认)

- **meta-L4 验证延后**:append 是否真发生 / 提取质量如何,1-2 月观察期才能验证(推 P1 真实项目阶段)
- **hook 不校验 append**:M15 / M16 不增加 append 校验项(光谱 B+ 最小硬 hook 原则);调度者忽略 append 无 enforcement
- **若调度者频繁忽略** → P0.9.3 议题考虑加 hook 校验(decision file §后续段已注明)
- **修剪策略**:本文件不淘汰旧条目。1 年累积 30-50 条后头部信息密度衰减;参 `decisions/` 半年归档惯例,**6 月后旧条目移 `docs/audits/archive/decision-trail/YYYY-HN.md`**(P0.9.1 仅声明策略,首次归档由后续阶段触发)
- **元条目自指**:首条"引入 decision-trail(本条,自指)"是 artifact 进自身索引的元条目。后续若做趋势统计需特判此类条目

## 维护规则

- **追加位置**:最新在上(时间倒序)
- **触发**:milestone commit / scope 级抉择 / 用户原则确立 / decision 文件创建时(**不限于 milestone commit**)
- **粒度**:抉择 = 判断拐点(不是任务完成);单条 ≤ 6 行
- **link**:有 decision file 必须链;无 file 标"暂无 + 原因"
- **不写**:任务进度(→ PROGRESS.md);技术细节(→ decisions/ 单 file);用户偏好(→ memory)

时间倒序。最新在上。

---

## 2026-04-28 — glassbox 角色 reframe(用户级工具,harness 推荐不分发)

- **抉择**:P2 空间维度 glassbox 不做 submodule / 不做 setup.sh 自动 clone;harness 仅"推荐 + 链接记录,防找错"
- **替代**:1A submodule(harness 内嵌)/ 1B submodule(目标项目内嵌)/ 4 setup.sh 询问 + clone — 三者均把 glassbox 绑到项目层,与"用户级工具"本质不符
- **触发**:用户(2026-04-28)指出 glassbox 是个人工具不归项目管,harness 仅需"提示安装 + 记录链接"
- **影响**:新建 `docs/references/recommended-tools.md`(scope=none)+ setup.sh 末尾加推荐段(scope=meta)+ ROADMAP P2 空间维度描述 reframe + harness 仓库零依赖管理负担
- **decision file**:[2026-04-28-glassbox-recommendation-not-integration.md](decisions/2026-04-28-glassbox-recommendation-not-integration.md)

## 2026-04-28 — 引入 decision-trail(本条,自指)

- **抉择**:P2 可观测性拆双层 — glassbox(session 空间) + decision-trail(跨 session 时间)
- **替代**:B 扩展 PROGRESS 加抉择列;C audit 趋势统计;扩 glassbox 跨 session(不可行,per-session)
- **触发**:用户指出 glassbox 看不到跨 session 抉择,需文档载体
- **影响**:本文件落地(scope=none);M5 + M1 双路径加 append step(scope=meta);ROADMAP P2 双层重写;4 挑战者 meta-review 共识发现 M1 同步缺失,initial needs-revision → 修补 → pass
- **decision file**:[2026-04-28-decision-trail-introduction.md](decisions/2026-04-28-decision-trail-introduction.md);audit:[meta-review-2026-04-28-174615-decision-trail-introduction.md](audits/meta-review-2026-04-28-174615-decision-trail-introduction.md)

## 2026-04-28 — 用户原则:skill 不跨项目

- **抉择**:skill-extract 产出仅 project-local,禁止持久化 user-global / 跨项目 registry
- **替代**:原 ROADMAP P2 "重复工作 skill 化持久化"
- **触发**:用户否决 — 跨项目假设"模式相同"实际差异污染上下文
- **影响**:删 ROADMAP P2 该条;memory `feedback_skill_no_cross_project.md`;skill-extract SKILL 措辞改"仅 project-local"
- **decision file**:暂无(轻,memory feedback 即生效)

## 2026-04-28 — 用户原则:实战在其他项目跑,不阻塞 harness 开发

- **抉择**:harness 自仓库不补 artificial trial,meta-L4 / 实战留痕 / mixed scope 成本观察推 P1 真实项目
- **替代**:harness 自仓库手工补假数据
- **触发**:P0.9.1 finishing 阶段用户原则确立
- **影响**:planning-rules.md + finishing-rules.md 反模式约束节硬编码;memory `feedback_realworld_testing_in_other_projects.md`
- **decision file**:暂无(原则性,memory 即生效)

## 2026-04-28 — P0.9.1 meta-review 修订(D9 根源承认型,5 子项)

- **抉择**:initial needs-revision → P0+P1+P2 修补 → pass(after revision)
- **5 子项**:D-fix-T4-4 / D-templates-README / D-scope-conf-B-glob / M18 follow-on / M3 hook 不可见 acceptance
- **替代**:推翻 P0.9.1 全部重做;全部子项推 P0.9.2
- **触发**:4 挑战者共识发现 M3 hook 不可见缺口(3/4 交叉)
- **影响**:scope.conf F 组 glob 修(`34129ae`);M3 不可见推 P0.9.3;首条 P0.9.2 诊断数据点
- **decision file**:[2026-04-28-p0-9-1-meta-review-revision.md](decisions/2026-04-28-p0-9-1-meta-review-revision.md)

## 2026-04-26 — P0.9.1.5 触发条件:用户决定型(D20 = B)

- **抉择**:M0-M4 治理修改之一启动前由用户决定,无机械触发
- **替代**:A 时间触发;C git diff 累积触发
- **触发**:P0.9.1 spec 设计阶段第 7 轮自检识别
- **影响**:P0.9.1.5 不进 ROADMAP 排期,handoff "下一步建议"列用户选
- **decision file**:[2026-04-26-p0-9-1-5-trigger-condition.md](decisions/2026-04-26-p0-9-1-5-trigger-condition.md)

## 2026-04-26 — P0.9.1 自审触发条件

- **抉择**:P0.9.1 落地后立即触发 meta-review 自审(首批 meta scope 改动)
- **替代**:推到下一次 meta 改动累积时再审
- **触发**:bootstrap 验证需求 — P0.9.1 自身需先经过其建立的 meta-review 流程
- **影响**:产首条 meta-review audit;首条 P0.9.2 诊断输入数据点
- **decision file**:[2026-04-26-p0-9-1-self-review-trigger.md](decisions/2026-04-26-p0-9-1-self-review-trigger.md)

## 2026-04-26 — bypass paths 处理方式

- **抉择**:scope.conf 用 `!` 前缀排除 audits/meta-review-* + audits/archive/**
- **替代**:hook 内硬编码排除;不排除(允许自循环)
- **触发**:meta-review 自身产出物若进 scope 会自循环
- **影响**:scope.conf 排除组形成,M17 落地
- **decision file**:[2026-04-26-bypass-paths-handling.md](decisions/2026-04-26-bypass-paths-handling.md)

## 2026-04-17 — 承认 harness self-governance 缺口,新增 P0.9

- **抉择**:harness 反复打补丁根源 = 三条结构性缺陷(治理无执法 / bootstrap 缺陷 / 马鞍定位错位),P0.9 加塞先于 P1
- **替代**:继续 ad-hoc 修补;直接进 P1 真实项目验证
- **触发**:接收 `D:\项目\智能体-生图` 老版本审查 + M0-M4 起草 4 挑战者扁平 fork 元审查
- **影响**:M0-M4 推迟首批使用;P0.9.1 / P0.9.1.5 / P0.9.2 / P0.9.3 全部由此衍生;P1 依赖 P0.9 就绪
- **decision file**:[2026-04-17-harness-self-governance-gap.md](decisions/2026-04-17-harness-self-governance-gap.md)

## 2026-04-16 — fork 嵌套扁平化改造(P0.5)

- **抉择**:5 skill + 5 agent 改扁平 fork,主对话直接并行 fork N 个挑战者
- **替代**:保留两级嵌套(领审员再 fork 子对抗者)
- **触发**:P1 验证发现 — 被 fork 的领审员无 Agent 工具权限,两级失效
- **影响**:P0.5 应急前置 P1;后续 meta-review 流程沿用扁平 fork
- **decision file**:[2026-04-16-fork-flat-refactor.md](decisions/2026-04-16-fork-flat-refactor.md)

## 2026-04-15 — 测试覆盖进 scope(P0)

- **抉择**:harness 增测试治理(L1 + L2 + L3 串行);L4 条件触发
- **替代**:推 P2;一次性做 L1-L4
- **触发**:5 对抗者审查 — RUBRIC 无独立"测试充分性"维度,治理散落但非真空
- **影响**:P0 序列 L2 → L1 → L3;Evidence Depth 概念引入;testing-rules.md / testing-standard.md 落地
- **decision file**:[2026-04-15-testing-scope-expansion.md](decisions/2026-04-15-testing-scope-expansion.md)

---

> 维护规则与自动化触发详见本文件顶部"已知缺口 + 维护规则"段 + `docs/decisions/2026-04-28-decision-trail-introduction.md`

# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-11 18:31
当前阶段: subagent-driven-development(hook 上岗批,任务 20-23)
当前分支: main(文档批直接提交,沿惯例)

## 目标

「模型无关的上下文/知识/交接层」:工作台/书架两层+晋升门禁(档位二)。批 0+批 1(任务 1-18 及批级 checkpoint)已闭合;余 hook 上岗批(任务 20-23)。

## 进度

### 已完成
- 批 0(bugfix 三件)+ 批 1(任务 4-18,14 主 commit:工作台门禁/书架登记/入口与偏好/分发与 scope)——每任务两段审查;批级 audit verdict=pass-after-revision,revision R1-R3 已随 finishing 同批落地。详 ROADMAP「上下文层重构」节

### 进行中
- hook 上岗批(任务 20:手工预演+用户实测,A/B 两案并排拍板)

### 阻塞
无。

## 下一步

1. **全部完成后提醒用户挨个审查**(用户 2026-06-11 原话:"同意,但是后面记得全部完成之后提醒我挨个审查")——对象:preferences.md 4 条正式条目+6 条待补原话(含条 4 例外补回、无日期升格路径两 Minor)+批 1 全部产出
2. 任务 20:用户从仓库根开新会话观察 session-init 是否注入;A/B 两案并排呈现拍板;立档 `docs/decisions/2026-06-<日>-hook-onboarding-route.md`(并裁决 F1 假点燃加固形态)
3. 按拍板走任务 21(A 案)或 22(B 案),再任务 23 收尾 checkpoint

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/superpowers/plans/2026-06-11-context-layer.md — 执行中计划,任务 20-23 全文与停点
- -> docs/audits/meta-review-2026-06-11-182559-context-layer-batch1.md — 批 1 批级审查(三挑战者;R1-R3;F1 假点燃定性)
- -> docs/ROADMAP.md — 上下文层节「批 1 留痕待办」= hook 上岗批要带的事项清单
- -> docs/preferences.md — 用户偏好(4 正式+6 待补),用户挨个审查对象

## 关键上下文

- 本会话 hook 不在场(根启动,地基事实 1)——门禁硬核全程手工跑:`echo '{}' | bash harness/.claude/hooks/check-handoff.sh`
- F1 假点燃:clone/worktree/checkout 刷新归档件 mtime → 60 分钟覆写信号误触发(audit 实测复现;任务 20 实测后裁决加固)
- 台账内指针写 docs/... 相对路径,基准 = harness/(根 AGENTS.md 接手顺序注)

## 已知问题

- check-meta-review.sh gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- meta-L1: ✅ 任务级实现者自验+fixture 先红后绿(check-handoff 27 例/shelf-registry 8 例/setup 9 项)
- meta-L2: ✅ 每任务两段独立审查(spec 合规复跑+质量),审查者独立重跑 fixture
- meta-L3: ✅ docs/audits/meta-review-2026-06-11-182559-context-layer-batch1.md verdict=pass-after-revision(3 挑战者)
- meta-L4: ⏳ 本次覆写=晋升门禁首次实战留痕;hook 上岗批继续积累

## CI 阻断
❌ 无 CI 阻断(meta 规则文本+bash hook,无可运行 CI;阻断由 check-* Stop hook 承担,自仓库自动接线待任务 20)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

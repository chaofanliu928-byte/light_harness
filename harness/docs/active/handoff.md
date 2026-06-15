# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-15
当前阶段: review-scout reframe(指令3 表述调整 + 指令2 文档上游双写)收口完成;指令1(审代码)待单开一轮;本批合并入 main;观察期
当前分支: main

## 目标

review-scout = ultracode 专属动态审查侦察路(scout 现推维 + workflow 扇出)。本批据用户三指令:**指令3** scout 作主推、固定 4 维显式回落;**指令2** FloorTable↔review-rules 文档上游双写;**指令1** 审代码接 scout(本批未做,单开一轮)。

## 进度

### 已完成
- **review-scout 实现 + 收口(2026-06-15)**:10 任务 wiring + 治理审查(A1🔴/A2🟡 路径修复 36b7296)+ 方向评估 4/4。audit `audit-2026-06-15-112342-review-scout.md`。
- **reframe 批(2026-06-15)**:指令3——review-scout 主推/老 4 维显式回落(framing-only,不退役/不重建 X,守 Y);指令2——FloorTable↔review-rules 地板维表注登记 credentials-rules §8 第 6 条双写对(文档上游/代码派生)。共 9 文件 + 术语桥 fix(2d97a11)。audit `audit-2026-06-15-134910-review-scout-reframe.md` pass-after-revision,对账账齐。

### 进行中
- 观察期:每会话照根 CLAUDE.md「会话开场规程」装载+对账。

### 阻塞
无。

## 下一步

1. **指令1(审代码接 scout)单开一轮走设计**:核心抉择 = scout 当"维度推荐器"喂 Superpowers 内嵌两段审查 vs 代码审整体改 fork-N;+ 触发宿主(代码审现走 Superpowers requesting-code-review 包,harness 无自有入口);+ code 地板/候选/focus/scout-vs-地板门(spec §1.3 留到扩展定)。详 ROADMAP「review-scout」节 + 本会话分析。
2. review-scout 观察项(ROADMAP「review-scout」节):全量「活备份」→「回落」术语统一(历史文件 R12 不追溯)/ FloorTable code/governance 接线时裁 + 补 FLOOR_FOCUS / 退化失败模式 meta-L4 实战观察。
3. 治理收口观察期:开场对账真实使用。

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/audits/audit-2026-06-15-134910-review-scout-reframe.md — reframe 批治理审查(5 维;pass-after-revision;covers 6 文件)
- -> docs/audits/audit-2026-06-15-112342-review-scout.md — review-scout 实现批治理审查
- -> docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md — review-scout 设计(D13 主次定调 + 术语桥)
- -> docs/decisions/2026-06-13-review-scout-workflows-dir.md — 用户拍板保 A + Y(后续影响段含 reframe)
- -> docs/ROADMAP.md「review-scout」节 — 进展 + reframe 批 + 观察项 + 指令1 待办

## 关键上下文

- review-scout = **ultracode 专属**主推路;ultracode 不在场走固定 4 维 design-review **显式回落路**(完整保留、不退役、不标降级)。scout 路 prompt 与 design-reviewer.md 零关系。
- **守 Y 零改三处**(本批全程保持):`design-reviewer.md` / `synthesis-rules.md` L113·L151 维序 / `design-rules.md`。
- 术语:spec/记录文件后文「活备份」= 此「回落路」旧称(术语桥 D13;主次以 D13 为准)。
- 开场对账三命令(根 CLAUDE.md):check-handoff --reconcile / check-shelf-registry / check-audit-coverage --reconcile。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 9 文件逐文件结构核(workflow `rs-reframe-impl` 16 agent,各文件独立 reviewer compliant)+ workflow.js 禁用项零
- L2: ✅ 守 Y 全仓 git diff(design-reviewer/synthesis 维序/design-rules 零改)+ 双写对核(CMD5 CLAUDE×2 空 / FloorTable↔review-rules 维名逐字一致)+ 对账账齐
- L3: ✅ 治理审查 audit verdict=pass-after-revision(audit-2026-06-15-134910;5 维 bootstrap-4+触点完整性)
- L4: ➖ 不适用(framing + 双写规则,无运行时行为可实战;review-scout 推维退化观察归实现批 meta-L4)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown 治理 + workflow 注释,无可运行 CI;验证 = 静态核 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

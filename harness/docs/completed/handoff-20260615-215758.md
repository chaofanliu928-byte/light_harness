# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-15
当前阶段: code-review-scout(指令1:review-scout 扩代码审查)实现 + 治理批收口完成;本批合并入 main;观察期
当前分支: main

## 目标

指令1(审代码接 scout):给 review-scout 扩展**代码审查**(reviewType='code'),fork-N 同形于设计审。ADD 一条 code scout 路并排于 Superpowers requesting-code-review 回落路(either-or,不替换/不退役);design 路逐字零变(守 Y)。

## 进度

### 已完成
- **code-review-scout 实现 + 收口(2026-06-15)**:10 任务 subagent-driven(workflow.js 契约优先 commit + 6 独立文件并行,各 implementer+reviewer 全 pass)。新建 code-review SKILL(ultracode→scout reviewType=code / 否则回落 Superpowers,不改包);workflow.js 加 code 常量 + 两 prompt reviewType 分支。治理批收口 9 挑战者(5 治理审查 + 4 方向评估)全 pass、零🔴零🟡。audit `audit-2026-06-15-192631-code-review-scout.md` verdict=pass,对账账齐。B-8 措辞 drift 收口修订。
- 前序:review-scout 实现批(`audit-...-112342`)+ reframe 批(`audit-...-134910`)。

### 进行中
- 观察期:每会话照根 CLAUDE.md「会话开场规程」装载+对账。

### 阻塞
无。

## 下一步

1. **ROADMAP「review-scout」节观察项**(全非阻断,触发器处置):退化失败模式 meta-L4 实战观察(ultracode 在场实跑,design+code 两路)/ credentials §8 候选菜单类双写收紧(CodeCandidateMenu+DesignCandidateMenu 一并补)/ spec 勘误候选 / README L150 cleanup(已声明豁免)/ 全量「活备份」→「回落」术语统一(R12 不追溯)。
2. 治理收口观察期:开场对账真实使用。

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/audits/audit-2026-06-15-192631-code-review-scout.md — 指令1批治理审查(9挑战者 5治理+4方向全 pass;covers 8文件;design 路零变 node 实证)
- -> docs/superpowers/specs/2026-06-15-code-review-scout-design.md — code-review-scout 设计(reviewType 分支 + 三层 design 路零变验证 + §8.3 自核命令组)
- -> docs/decisions/2026-06-15-code-review-scout-decisions.md — D-C1~D-C4 用户拍板锚
- -> docs/ROADMAP.md「review-scout」节 — 指令1批进展 + 观察项总索引

## 关键上下文

- code-review-scout = review-scout 的 reviewType='code' 扩展;**design 路(reviewType='design')行为逐字零变**(design else 分支=改前文本,node 双版本渲染 byte-identical 实证)。code focus 住 workflow.js `FLOOR_FOCUS_CODE` 自有常量,不读/不抄 design-reviewer.md。
- **守 Y 零改三处**(全程保持):`design-reviewer.md` / `synthesis-rules.md` L153 维序 / `design-rules.md`。
- 触发宿主 = 新 code-review SKILL(镜像 design-review 运行时分支);either-or:ultracode 走 scout 不跑 Superpowers / 非 ultracode 走 Superpowers requesting-code-review。
- 开场对账三命令(根 CLAUDE.md):check-handoff --reconcile / check-shelf-registry / check-audit-coverage --reconcile。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 实现期逐文件独立 reviewer(workflow `code-review-scout-impl`,15 agent;workflow.js spec+quality + 6 独立文件 review 全 pass)+ design 路 node byte-identical
- L2: ✅ §8.3 全组自核(全仓 diff 只含 §8.1 文件 / 双写逐字同序 FloorTable.code↔review-rules / CLAUDE×2 开发行字节一致 / 守 Y 三处零改)+ 凭证对账账齐(covers 8 文件完整)
- L3: ✅ 治理审查 audit verdict=pass(audit-2026-06-15-192631;9 挑战者 5 治理审查 bootstrap-4+触点完整性 + 4 方向评估 RUBRIC/架构/文档/Slop 全 pass)
- L4: ➖ 不适用(meta:scout 推维退化是 ultracode 在场实战观察项,归 ROADMAP meta-L4;本批无运行时行为可即时实战)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown 治理 + workflow JS 注释/字符串,无可运行 CI;验证 = 静态核 + node 渲染 byte-identity + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

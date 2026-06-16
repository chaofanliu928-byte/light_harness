# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-15
当前阶段: review-scout backlog 清理收口完成;合并入 main;下一步 = llm-wiki/知识组织(用户定「做3再做1」)
当前分支: main

## 目标

review-scout 线收尾(backlog 小观察项清理)后,转入用户标「非常关注」的大方向 **llm-wiki/知识组织**(harness/docs/references/ 有 6 份 2026-06-10 调研地图打底)。

## 进度

### 已完成
- **review-scout backlog 清理 + 收口(2026-06-15)**:子项1 credentials §8 加第7条候选菜单双写对(DesignCandidateMenu/CodeCandidateMenu↔review-rules 候选注,两侧权威注/派生注对称)+ 子项2 code-review-scout spec 3 勘误(focus 伪码对齐实现 / menu 2-way冗余 / ARCHITECTURE 措辞)+ 架构 focus 同步(workflow.js↔spec 复字节一致,模板占位也跳过)。子项3 术语统一 = 实质已完成(活治理文档无残留,R12 覆盖记录)。治理审查 5 挑战者 4pass+1🟡(§8 指针陈旧引用)收口修订。audit `audit-2026-06-15-215413-review-scout-backlog.md` verdict=pass-after-revision,对账账齐。
- 前序:code-review-scout 实现(`audit-...-192631`)+ reframe(`audit-...-134910`)+ review-scout 实现(`audit-...-112342`)。

### 进行中
- 无(等开 llm-wiki 方向)。

### 阻塞
无。

## 下一步

1. **llm-wiki/知识组织(option 1)走 brainstorming**:用户标「非常关注」。先界定要解决的具体问题/范围(知识组织是大题,需收敛成一个可做的子项),再设计。打底材料:`harness/docs/references/2026-06-10-literature-map-llm-wiki-knowledge-org.md` + 同日 5 份相关地图(context-loops / 开源 memory 方案 / 业务模块切分 / scaffold-vs-ultracode / handoff-kb-integration)。
2. review-scout 剩余观察项(均非阻断/被动):README L150(spec §8.2 已声明豁免)/ 退化失败模式 meta-L4 实战观察(ultracode 在场真实用 review-scout 时收)。

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/references/2026-06-10-literature-map-llm-wiki-knowledge-org.md — llm-wiki/知识组织 调研地图(option 1 打底)
- -> docs/audits/audit-2026-06-15-215413-review-scout-backlog.md — backlog 清理治理审查(5 挑战者;pass-after-revision)
- -> docs/audits/audit-2026-06-15-192631-code-review-scout.md — 指令1 批治理审查(design 路零变 node 实证)
- -> docs/ROADMAP.md「review-scout」节 — 三批进展 + 观察项(已解/剩余)总索引

## 关键上下文

- review-scout 线(设计 / reframe / code 扩展 / backlog 清理)已全部合并入 main,到完成点;剩余仅被动观察项。
- **守 Y 零改三处**(若再碰 review-scout):`design-reviewer.md` / `synthesis-rules.md` L153 维序 / `design-rules.md`;reviewType='design' 路行为逐字零变。
- llm-wiki 是大题:开 brainstorming 时先界定可做子项(别一上来铺大计划——对齐 feedback_iterative_progression「边做边提升,不预设大计划」);模块划分按业务切非材料切(feedback_module_cut_by_business)。
- 开场对账三命令(根 CLAUDE.md):check-handoff --reconcile / check-shelf-registry / check-audit-coverage --reconcile。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ implementer 做 + 独立 Explore 侦察scope + 编辑后机械核(双写逐字一致 / §8 指针 / node --check / spec↔workflow.js 架构 focus 字节一致)
- L2: ✅ 守 Y design 路 node 双版本渲染 byte-identical + 重建等式 reconstructed===main(workflow.js 仅 2 处改、design 路零变)+ 凭证对账账齐(covers 3 文件)
- L3: ✅ 治理审查 audit verdict=pass-after-revision(audit-2026-06-15-215413;5 挑战者 bootstrap-4+触点完整性;1🟡 §8 指针收口修订)
- L4: ➖ 不适用(纯收尾批,无运行时新行为;review-scout 推维退化 meta-L4 归 ultracode 在场实战观察)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown 治理 + workflow JS 注释/字符串,无可运行 CI;验证 = 静态核 + node 渲染 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

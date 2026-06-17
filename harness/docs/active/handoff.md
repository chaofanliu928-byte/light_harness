# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-17
当前阶段: 知识系统 Step2 ★ 主项 **C「设计层到手边」实现完成 + 收口 audit pass**(verdict=pass,8 covers,对账账齐);分支 merge-ready,**待用户授权合并 main**。
当前分支: design-context-delivery

## 目标

C = 让"代码答不出的"设计层背景(契约/数据/边界/业务规则/坑/why)在**写代码/调试/重构**按场景**自动到手边**(AI 无持久记忆 + tacit 知识不在代码 → 省得读全代码=漏 / 瞎删承重墙=回归)。机制 = 机读·设计背景地图 + fork 侦察员(克隆 ③b drift-scout 形态),复用 ①②③a③b 地基。

## 进度

### 已完成
- **C 全相位完成**(2026-06-17):writing-plans(plan 锁定 + 规划决策 P-1/P-2 据实读裁洞①②)→ subagent-driven 实现(8 任务全 spec-compliant + 跨文件一致性审 consistent)→ **fixture 红线验收**(5 案全 pass,2 红线✓:有料递对/料缺⚠️不编造)→ **finishing**(凭证 audit verdict=pass 8 covers + 方向评估 4 维 pass + drift-scout 15 触点全✅ + decision-trail 登记)。8 任务 commit + 收口 2🟡 fix。
- 前序:设计锁定(commit 566d85f)+ ①②③a③b(Step2 上游段,已并入 main)。

### 进行中
- 无(merge-ready)。

### 阻塞
无。

## 下一步(新窗口照此续作)

1. **合并 design-context-delivery → main**(待用户授权;audit pass、对账账齐、merge-ready)。
2. 合并后 Step2 后续:**边界厘清(知识/偏好/规则糊地带)随真案例解** + **meta-L4 实战观察**(scout 误匹配率/编造率/下游写作率;drift-scout 13 计数 count-agnostic 化单独一批)。稳定性推真实项目验(自仓库 dogfood 审不到)。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/audits/audit-2026-06-17-230642-design-context-delivery.md — 收口凭证(verdict=pass;8 covers;2🟡 处置)
- -> docs/superpowers/specs/2026-06-17-design-context-delivery-design.md — 锁定 spec(唯一权威源)
- -> docs/superpowers/plans/2026-06-17-design-context-delivery.md — 实现计划(规划决策 P-1/P-2)
- -> docs/decision-trail.md 2026-06-17 条 — C 抉择/替代/赌注/裁决索引
- -> docs/references/known-pitfalls-index.md「文档健康/反腐烂」组 — drift-scout 13 计数 stale(单独批,用户拍板)
- -> docs/ROADMAP.md「知识系统 backlog」Step 2 节 — backlog + meta-L4

## 关键上下文

- **C 机制(已落地)**:进写码/调试/重构 → 调度者 pull fork `design-context-scout` 注入 `{scenario, touchedFiles, mapPointer, repoRoot, today}` → 读 `design-context-map.md` 两跳(file→业务模块 glob→各设计背景住址)→ 照住址 Read 消化 briefing。只读不写 / 全干净静默(EmptyHanded=无任何模块可 brief)/ 软降级 / ⚠️不硬判;按 scenario 取片(write/debug/refactor)。
- **3 诚实赌注(用户确认接受为已知边界)**:①下游真写设计文档/README(没写→EmptyHanded 指 migration 补)②pull 够(无 push 强制)③模块边界清(糊则第一跳⚠️不硬猜 + drift-scout 逮成员漂移)。dogfood:自仓库不建地图数据(主表仅注释样板行),仅下游分发。
- **守住(零改,经审验)**:③a/③b drift-scout + 4 既有 scout / 6 hook / 对账三命令 / credentials.conf / 根 README / business-module-map 留痕不升格。

## 已知问题

- drift-scout.md 硬编「13 触点」计数随 TP-14/15 增至 15 行变 stale(检测 count-agnostic,功能不受影响);用户拍板单独一批 count-agnostic 化(已登 known-pitfalls-index)。
- check-audit-coverage.sh extract_covers gawk 三参数 match 是 gawk 扩展语法,非 gawk 环境解析失败(既有独立待办,详 known-pitfalls-index)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 静态/结构核(scout HTML 注释非 YAML / 地图列头↔scout kind↔取片表↔migration↔DESIGN_TEMPLATE 锚一致 / setup.sh skip↔守卫成对 + bash -n clean)
- L2: ✅ fixture 红线 5 案验收(write/debug/refactor 有料递对 + 料缺/边界糊⚠️ + EmptyHanded),独立 verifier overall=pass,2 红线✓
- L3: ✅ 凭证 audit 5 维 + 方向评估 4 维(独立 fork,做审分离)+ drift-scout 15 触点全✅;0🔴
- L4: ➖ meta-L4 实战观察待真实项目(dogfood 自仓库审不到)
- 注:harness-meta 无运行时单测,验证 = 静态核 + fork fixture 红线 + 对抗审查。

## CI 阻断
❌ 无 CI 阻断(harness meta;验证 = 静态核 + fixture 红线 + audit 对账,均已过)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

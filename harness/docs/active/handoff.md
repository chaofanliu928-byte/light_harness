# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-13(批 1 收尾,增量更新非覆写)
当前阶段: 治理同层化执行中(子代理驱动,20 任务/5 批;批 1 完成,批 2 待开)
当前分支: main

## 目标

「模型无关的上下文/知识/交接层」**全部完成并经用户挨个审查修订**。现状权威 = `docs/superpowers/specs/2026-06-12-context-layer-design.md`(现行版,整体取代 2026-06-10 版)。

## 进度

### 已完成
- 批 0+批 1+会话链自执法批(23 任务)+ **C 案补完批**(2026-06-12 挨个审查驱动:撤自仓库接线/登记簿规矩 M2 §7.5.1/F1 重定性+check-handoff --reconcile 纯状态对账/新 spec 整体取代)。四份批级 audit 全 pass(-after-revision);最终批 audit `meta-review-2026-06-12-230048-c-plan-completion-batch.md`

### 进行中
- **治理同层化批 1 完成**(2026-06-13):基线留痕(4805a4c)+ credentials-rules.md 新件(1a60329,八节,审查 Approved)。旧工具/旧 conf 全程在岗,执法真空窗归零。
- 批 2 待开(最重批):工具改名 check-audit-coverage.sh + conf 改名 credentials.conf + 21 件字段迁移 + 命令行三处 + cross-ref 删除——**原子同 commit**;setup.sh 单独 commit。开场对账自批 2 起带显式全窗 `--reconcile 99999`(G3)。

### 阻塞
无。

## 下一步

1. 治理同层化批 2-5 顺 plan `docs/superpowers/plans/2026-06-13-governance-single-layer.md` 执行(实现者+两段审查;批 1-4 小 checkpoint 过渡态不走旧 M1 四步,欠账批 5 V8 audit 统一销 = G6)
2. **凭证欠账登记(G6)**:批 1-4 改动的凭证欠账暂挂,批 5 V8 audit(covers=批 1-5 全 commit name-only 并集机械汇编)统一销账
3. 上下文层观察期项(SETUP_NEEDED/F1/偏好 6 条待补原话)不受本批影响,触发器照旧

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/superpowers/specs/2026-06-12-context-layer-design.md — **现行版 spec**(现状权威;旧版带横幅转考古)
- -> docs/decisions/2026-06-11-session-chain-reconciliation.md — C 案+追记①-④(执法哲学与挨个审查修订的全记录)
- -> docs/audits/meta-review-2026-06-12-230048-c-plan-completion-batch.md — 补完批 audit(登记簿首次自适用)
- -> docs/ROADMAP.md — 上下文层节:全批进展+留痕待办(后续处置总索引)
- -> docs/preferences.md — 用户偏好(4 正式+6 待补)

## 关键上下文

- 开场对账三命令(M3「会话开场规程」权威):check-handoff --reconcile / check-shelf-registry(echo '{}')/ check-meta-review --reconcile;欠账先补再干活
- 自仓库无接线(追记①):hook=纯工具箱;执法=会话链对账+finishing+meta-review
- check-handoff --reconcile = 纯状态判据零时钟;check-meta-review --reconcile = commit time 锚

## 已知问题

- check-meta-review.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- meta-L1: ✅ 各件实现者自验+fixture 先红后绿(--reconcile 两件 38+34 断言等)
- meta-L2: ✅ 每件两段独立审查+聚焦复核+spec 忠实性审查(Needs fixes 全采纳)
- meta-L3: ✅ 四份批级 audit(batch0/batch1/session-chain/c-plan-completion,末件 verdict=pass-after-revision、revision 全落)
- meta-L4: ⏳ 观察期:开场对账真实使用留痕(本台账即对账制度下首份常态台账)

## CI 阻断
❌ 无 CI 阻断(meta 规则文本+bash hook,无可运行 CI;C 案:会话链对账+工具箱手工模式)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

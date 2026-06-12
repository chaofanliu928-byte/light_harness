# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-11 22:24
当前阶段: 上下文层重构已收口;观察期(开场对账真实使用留痕)+ 等用户挨个审查
当前分支: main

## 目标

「模型无关的上下文/知识/交接层」**全部完成**(23 任务,2026-06-11):工作台/书架两层+晋升门禁(批 0/1)+ 会话链自执法(C 案:开场对账,hook 降级工具箱)。

## 进度

### 已完成
- 批 0(bugfix)+ 批 1(任务 4-18:门禁/登记/入口/分发)+ 会话链自执法批(任务 20-22:--reconcile 对账工具、开场规程四处、留痕)。三份批级 audit 全 pass(-after-revision);最终批 audit `meta-review-2026-06-11-222130-session-chain-reconciliation.md` verdict=pass

### 进行中
- 用户挨个审查(用户 2026-06-11 拍板偏好时约定"全部完成之后提醒我挨个审查"——收口时已当面提醒,清单见下一步 1)

### 阻塞
无。

## 下一步

1. **用户挨个审查**:①preferences.md 4 条正式条目+6 条待补原话(含条 4 例外补回、「有原话无日期」升格路径两 Minor)②会话链自执法 decision 与开场规程(M3/AGENTS×2/M4)③ROADMAP「留痕待办」清单逐条确认处置取向
2. 观察期:每会话照 M3「会话开场规程」走装载+对账(开场对账真实使用留痕 = meta-L4 数据)
3. ROADMAP 留痕待办按各自触发器逐件处置(F1 接电前必修/SETUP_NEEDED 真实观察/--reconcile 优化候选等)

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/superpowers/specs/2026-06-12-context-layer-design.md — 上下文层**现行版 spec**(整体取代 2026-06-10 版;现状权威)
- -> docs/decisions/2026-06-11-session-chain-reconciliation.md — C 案:会话链自执法,hook=工具箱(三案并排+用户原话锚点+追记①-④)
- -> docs/audits/meta-review-2026-06-11-222130-session-chain-reconciliation.md — 最终批 audit(销 --reconcile 五件欠账)
- -> docs/ROADMAP.md — 上下文层节:全批进展 +「留痕待办」清单(后续处置的总索引)
- -> docs/preferences.md — 用户偏好(4 正式+6 待补),用户挨个审查对象
- -> docs/superpowers/plans/2026-06-11-context-layer.md — 23 任务全记录(含被取代的原任务 20-23 指针)

## 关键上下文

- 开场对账三命令(M3「会话开场规程」):check-handoff / check-shelf-registry 手工模式 + check-meta-review --reconcile;欠账先补再干活
- --reconcile 锚点=audit 文件 commit time(同 commit 打包→相等→有效);窗口默认锚最新已提交 audit
- 本会话 hook 全程不在场(根启动)——C 案下这是常态而非缺陷,凭证链+对账即执法

## 已知问题

- check-meta-review.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- meta-L1: ✅ 任务级实现者自验+fixture 先红后绿(--reconcile 21+10 断言/批 1 各件 27+8+9)
- meta-L2: ✅ 每任务两段独立审查+方向变更独立审查(Needs fixes 全采纳)
- meta-L3: ✅ 三份批级 audit(batch0 / batch1 / session-chain-reconciliation,最终 verdict=pass)
- meta-L4: ⏳ 开场对账真实使用留痕(观察期起点=本次收口;--reconcile 销账实证见 finishing 记录)

## CI 阻断
❌ 无 CI 阻断(meta 规则文本+bash hook,无可运行 CI;C 案:会话链对账+工具箱手工模式,详 decisions/2026-06-11-session-chain-reconciliation.md)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

## meta-review: skipped(理由: 偏好条目忠实性微修两行——条4补回用户既有例外+文法注加[日期不详]升格规则,2026-06-11 用户挨个审查当场拍板,原话直录轻路径(SKILL 路由表偏好行))

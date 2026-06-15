# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-15
当前阶段: review-scout 收口完成(audit pass-after-revision + 方向评估通过);本批合并入 main;观察期
当前分支: main

## 目标

给 design-review 增一条 **ultracode 专属**动态审查侦察路(review-scout):scout 现推维 + workflow `parallel()` 扇出,ADD 并排**不替换**现有固定 4 维 design-review(活备份)。用户 2026-06-13 拍板 Y(ADD 不替换)+ 保 A(workflow 载体 + 分发 + 纳凭证)。

## 进度

### 已完成
- **review-scout 实现 + 收口(2026-06-15)**:10 任务(契约骨架/编排/scout agent + wiring 4-10 逐任务 implementer+reviewer 两段审查)+ 收口治理审查 5 维(bootstrap-4 + 触点完整性,逮 A1🔴/A2🟡 workflow 读盘路径断链,修复 36b72964 + 独立重审)+ 方向评估 4/4 不推翻。audit `audit-2026-06-15-112342-review-scout.md` verdict=pass-after-revision,对账账齐。新引入 `.claude/workflows/` 目录(分发 + 纳凭证)。守 Y 全程保持(design-reviewer.md / synthesis L113·L151 维序 / design-rules 零改)。
- 前序:治理同层化批 1-5(2026-06-13);上下文层重构 + 会话链自执法(2026-06-11~12)。见 ROADMAP/PROGRESS。

### 进行中
- 观察期:每会话照根 CLAUDE.md「会话开场规程」装载+对账。

### 阻塞
无。

## 下一步

1. review-scout 观察项(详 ROADMAP「review-scout」节):FloorTable code/governance 两行预填(接线时裁 + 补 FLOOR_FOCUS focus)/ 地板维表机读镜像显性化(review-rules 注)/ 诚实认知上提 / 退化失败模式 meta-L4 实战观察(ultracode 在场用它审下一个 feature)。
2. 治理收口观察期:开场对账真实使用;治理同层化观察项(安全扫硬兜底[用户拍板不加]/ 三件套互引单防线盯几批)。
3. 细节交接(工作底稿/任务出生证)= 用户既定"先治理后交接"的后半,另案待启。

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/audits/audit-2026-06-15-112342-review-scout.md — review-scout 收口治理审查(5 维;verdict=pass-after-revision;covers 10 文件)
- -> docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md — review-scout 设计(已锁;§3 接口 / §4 数据 / §7.3 诚实边界)
- -> docs/decisions/2026-06-13-review-scout-workflows-dir.md — 用户拍板保 A + Y(ADD 不替换)
- -> docs/ROADMAP.md「review-scout」节 — 进展 + 5 观察项
- -> docs/governance/credentials-rules.md — 凭证与对账单入口(`.claude/workflows/*` 新 glob)
- -> docs/governance/finishing-rules.md — 唯一收口(治理批工序:凭证审查 + 方向评估全批适用)

## 关键上下文

- review-scout = **ultracode 专属**;ultracode 关时走现有固定 4 维 design-review(活备份,零改)。scout 路挑战者 prompt 与 design-reviewer.md 零关系(floor/已知维 focus 住 `workflow.js` FLOOR_FOCUS 常量;动态维 focus = scout 的 challenger_focus)。
- 守 Y 零改三处(本批全程保持,收口全仓 diff 已核):`design-reviewer.md` / `synthesis-rules.md` L113·L151 维序段 / `design-rules.md`。
- 开场对账三命令(根 CLAUDE.md「会话开场规程」):check-handoff --reconcile / check-shelf-registry(echo '{}')/ check-audit-coverage --reconcile。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ workflow.js 结构静态核(`export const meta`/phase/agent/parallel 用法 + 禁用项实际调用零)+ 各 wiring 文件 grep 落点核
- L2: ✅ 守 Y 全仓 git diff(现有 4 维路文件零改)+ 双写对核(conf↔§2 / 根↔harness CLAUDE 设计审查行)+ 对账账齐
- L3: ✅ 治理审查 audit verdict=pass-after-revision(docs/audits/audit-2026-06-15-112342-review-scout.md;5 维)+ 方向评估通过(4/4 不推翻)
- L4: ⏳ 观察期:review-scout 退化失败模式实战观察(ultracode 在场用它审下一个 feature spec;spec §6 meta-L4)

## CI 阻断
❌ 无 CI 阻断(harness meta:workflow 脚本 + markdown 治理,无可运行 CI;验证 = 静态核 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-17
当前阶段: 知识系统 Step2 ★ 主项 **C「设计层到手边」(下游)—— 设计锁定**(spec committed,2 轮 design-review 0🔴);下一步 writing-plans。
当前分支: design-context-delivery

## 目标

C = 让"代码答不出的"设计层背景(契约/数据/边界/业务规则/坑/why)在**写代码/调试/重构**按场景**自动到手边**(AI 无持久记忆 + 项目大量 tacit 知识不在代码 → 省得读全代码=漏 / 瞎删承重墙=回归)。机制 = **机读·设计背景地图 + fork 侦察员**(克隆 ③b drift-scout 形态),复用 ①②③a③b 地基。

## 进度

### 已完成
- **C 设计锁定**(2026-06-17,commit 566d85f):brainstorming(完整覆盖=代码 SSoT+外化 tacit 层 / 按内容切 / 复用现有家不新建 wiki / 3 诚实赌注)→ designer 写 spec → 3 自检 → design-review(review-scout dogfood 第 4 次,2🔴+8🟡)→ 2 轮 designer 修 → round-2 复审 **0🔴**。spec `docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`(566+ 行,§1-§10 锁定)。
- 前序:①②③a③b(Step2 上游段,已并入 main)。详见 ROADMAP「知识系统 backlog」。

### 进行中
- C writing-plans 待启(设计已锁,下一相位)。

### 阻塞
无。

## 下一步(= 预期完整执行的内容;新窗口照此续作)

1. **writing-plans(契约前置)**:读锁定 spec,写实现计划。改动物:① 新建 `.claude/agents/design-context-scout.md`(侦察员契约,克隆 drift-scout 形态:入参/出参二态 Briefing|EmptyHanded/两跳/按 scenario 取片/只读不写/降级)② 新建 `docs/governance/design-context-map.md`(机读地图模板,带样板行,活文件守卫分发)③ 新建 `docs/governance/design-context-migration.md`(迁移指南:11 类必备清单+三步)④ 改 `finishing-rules.md`(写码/调试/重构入口 pull fork 步 + 保鲜触点登记)⑤ 改 `setup.sh`(scout 逐 cp 行 + **地图 `basename skip`+活文件守卫 cp 成对** + migration 随循环 + echo 指引)⑥ 改 `touchpoint-registry.md`(加 1-2 行地图保鲜触点)⑦ 可能改 `DESIGN_TEMPLATE.md`(洞①业务规则段)。
2. **subagent 实现** → **finishing**:治理审查 audit(命中凭证;covers 候选见下指针)+ 合并。
3. **carry-forward 🟡(必须钉死)**:setup.sh 地图排除出 governance 无条件循环的 `basename skip` 须与活文件守卫 cp(`if [ ! -f ]`)**成对**(漏 skip=重装覆盖下游已填地图 / 漏守卫=地图不分发空转);spec §6.2 已列收口红线双查。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/superpowers/specs/2026-06-17-design-context-delivery-design.md — C 锁定 spec(唯一权威源;writing-plans 读它)
- -> docs/governance/touchpoint-registry.md(③a)+ .claude/agents/drift-scout.md(③b)— 被克隆的地图范式 + 侦察员形态
- -> .claude/agents/freshness-scout.md — scout 形态范本(HTML 注释 frontmatter 非 YAML)
- -> docs/ROADMAP.md「知识系统 backlog」Step 2 节 — C 设计记录 + carry-forward 🟡 + meta-L4

## 关键上下文

- **C 机制**:进写代码/调试/重构场景 → 调度者 pull fork `design-context-scout` 注入 `{scenario, touchedFiles, mapPointer, repoRoot, today}` → 读地图两跳(file→业务模块 glob→各设计背景住址)→ 照住址 Read 源消化成 briefing → 反馈。只读不写、全干净静默、软降级、⚠️不硬判。3 场景共用一层,按 scenario 取片(§4.3)。
- **3 诚实赌注(已与用户确认接受为已知边界)**:① 下游真写了设计文档/README(没写→EmptyHanded 空手不编造,指 migration 指南去哪补)② pull 够(AI 得记得 fork,无 push 强制力)③ 业务模块边界清楚(糊则第一跳 ⚠️ 不硬猜 + drift-scout 逮成员漂移)。
- **凭证 covers 候选**:scout/map/migration/finishing-rules/touchpoint-registry/setup.sh[+DESIGN_TEMPLATE 若改]。**dogfood 边界**:自仓库不建地图数据,仅下游分发,稳定性靠真实项目验。
- **守住**(零改):③a 注册表判据/类型 enum / ③b drift-scout + 既有 4 scout 契约 / 6 check-* hook / 对账三命令 / credentials.conf / finishing 既有步 / 根 README 不改 / business-module-map 留痕不升格。
- 开场对账三命令 + 第 3 步新鲜度侦察(根 CLAUDE.md 会话开场规程)。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 是 gawk 扩展语法,非 gawk 环境**解析失败 → 该 audit 不贡献 covers**(非死锁;已纠;独立待办)。详见 known-pitfalls-index。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ designer 逐节写 spec + 每节自检 + 独立 3 自检挑战者(系统设计阶段)
- L2: ✅ round-2 复审 0🔴,round-1 的 2🔴+8🟡 逐项对源实核闭合(分发链/自洽/spec_gap_masking 三维)
- L3: ✅ design-review(review-scout dogfood)2 轮 + system-design 自检——做审分离逮到自检漏的 🔴
- L4: ➖ 待实现(设计锁定;红线测/audit 对账在 writing-plans→实现→finishing 落)
- 注:本相位 = 设计锁定,以上为**设计审查**证据;代码级 Evidence Depth 待实现期补。

## CI 阻断
❌ 无 CI 阻断(harness meta:子智能体契约 + 机读地图 + 治理接线;验证 = 设计审查 + 实现期静态核/红线测/audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

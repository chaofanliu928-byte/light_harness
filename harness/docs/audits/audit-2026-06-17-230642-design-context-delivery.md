---
audit: true
covers:
  - .claude/agents/design-context-scout.md
  - docs/governance/design-context-map.md
  - docs/governance/design-context-migration.md
  - docs/governance/finishing-rules.md
  - docs/governance/touchpoint-registry.md
  - docs/governance/implementation-rules.md
  - setup.sh
  - docs/references/DESIGN_TEMPLATE.md
---

# audit:C「设计层到手边」(design-context delivery)(知识系统 Step2 ★ 主项 — 治理面收口凭证)

> 本批 = 知识系统 Step2「★ 设计层到手边」主项 C:让"代码答不出的"设计层背景(契约/边界/数据/业务规则/坑/残留 why)在写码/调试/重构按场景 **fork 侦察员自动到手边**。机制 = 机读·设计背景地图(`design-context-map.md`,套 ③a touchpoint-registry 范式,只指不抄)+ fork 侦察员(`design-context-scout.md`,克隆 ③b drift-scout 形态:pull 主动 fork / 读地图两跳 / 按 scenario 取片 / 消化成 briefing / 只读不写 / 软降级)+ 治理接线(finishing 入口步 + 保鲜触点登记 + setup.sh 分发 + 两洞模板支撑)。covers = 命中凭证的 8 文件;spec/plan(`docs/superpowers/*`)+ known-pitfalls-index(`docs/references/*` 仅 DESIGN_TEMPLATE 命中)非凭证,不入 covers。

## 1. 元信息

- 批次:C「设计层到手边」(design-context delivery);分支 `design-context-delivery`
- commit 范围:`43f2df1`(plan 锁定)→ `040d411`(收口 fix);8 任务 commit(`e5ab879`..`7ca9734`)+ `991044e`(TP-14 polish)+ `040d411`(收口 2🟡+💭 fix)
- 锁定 spec:`docs/superpowers/specs/2026-06-17-design-context-delivery-design.md`(§1-§10)
- 计划:`docs/superpowers/plans/2026-06-17-design-context-delivery.md`(9 任务 + 规划决策 P-1/P-2)
- 改动类别:**治理批**(governance)——全 harness-meta 文档/契约/分发,无运行时代码、无 API、无数据库;故 security-scan + process-audit 不纳入(finishing-rules step 93 治理批约定)
- covers 8 文件(见 frontmatter):新建 scout/map/migration + 改 finishing-rules/touchpoint-registry/implementation-rules/setup.sh/DESIGN_TEMPLATE

## 2. 维度选取

治理批 → `review-rules.md` 维度选择表治理行:

- **bootstrap 4 维强制基线**:核心原则合规 / 目的达成度 / 副作用 / scope 漂移。
- **+ 触点完整性维(条件必选)**:本批命中三触发(scout↔map 消费契约 + 跨文件列/字段计数枚举 + 分发链 setup.sh)→ 必选。
- N = 5(凭证 audit)。
- **+ 方向评估(全批适用含治理批,finishing-rules step 92)**:RUBRIC 合规 / 架构一致 / 文档健康 / Slop(4 维)。
- **+ 触点漂移机械预检**:drift-scout scope=all(15 触点,含新 TP-14/15)。

挑战者 10(5 凭证 + 4 方向)+ drift-scout 1,独立 fork(扁平架构,做审分离),synthesis-rules 事前/事后遵守。

## 3. 挑战者执行记录

**任务级结论登记(subagent-driven 批,§3.7)**:

- 任务 1(设计背景地图模板 = 数据契约 + 业务模块权威清单):verdict=approved;关键发现 收口 🟡 示意行(主表活数据行矛盾 §6.1 dogfood + TP-14 false-🔴 风险);修复 commit `e5ab879` + `040d411`
- 任务 2(设计背景侦察员契约,克隆 drift-scout 形态):verdict=approved;关键发现 收口 💭 EmptyHanded ∨/∧ 判据不一致;修复 commit `4c5f80e` + `040d411`
- 任务 3(下游迁移指南,B1 11类 + B2 三步):verdict=approved;关键发现 无;修复 commit `2ff5234`
- 任务 4(DESIGN_TEMPLATE 洞① §1.7 业务规则 + §5.1 理由列):verdict=approved;关键发现 无;修复 commit `2e1019c`
- 任务 5(implementation-rules 洞② 有界 // WHY:):verdict=approved;关键发现 无(洞② 必要性据实读 known-pitfalls-index 复核 = scattered-only,守 D2);修复 commit `fb5ff80` + `040d411`(freshness)
- 任务 6(finishing-rules 写码/调试/重构入口步 + 保鲜登记):verdict=approved;关键发现 收口 💭 公设1 消费侧加固;修复 commit `bd85332` + `040d411`
- 任务 7(touchpoint-registry TP-14/15 地图保鲜触点):verdict=approved;关键发现 TP-14 端点列名缩写;修复 commit `c99fe9e` + `991044e`
- 任务 8(setup.sh 分发:scout cp + 地图 skip↔守卫 cp 成对 + echo):verdict=approved;关键发现 无(skip↔守卫成对验证 + `bash -n` clean + 仅地图被 skip);修复 commit `7ca9734`

**凭证 audit 5 维结论**:

- 核心原则合规:**pass**(2💭:公设1 消费侧可加固[已修];洞② 落 implementation-rules+scattered-only 是规则5/反向追问的正面落实)
- 目的达成度:**pass**(2💭:EmptyHanded ∨/∧[已修];洞② 闭合度 = "通路就位"非"料必达",与 spec §6.3 诚实声明一致,非 claimed-but-not-delivered)
- 副作用:**pass**(4💭:洞② 与坑索引非重叠分区[无新双写腐];drift-scout 13 计数 stale[已登记单独批];finishing placement[spec 刻意];setup.sh `set -e` errexit[验证安全])
- scope 漂移:**pass**(covers 8 = plan P-1/P-2 对 spec 两 conditional 的合法收口;守住段零改[③b/freshness/review-scout/6 hook/business-module-map/根 CLAUDE+AGENTS/settings]经 drift-scout + diff 验)
- 触点完整性:**concern → resolved**(🟡 示意行[已修入注释];2💭:TP-13 护栏 TP-09~12 枚举未含 14/15[随单独批]、spec §8.4 样板与出货地图差异[随 🟡 修])

**方向评估 4 维结论**:RUBRIC 合规 **pass**(3💭 均正向/已登记)/ 架构一致 **pass**(6💭:scout 同形态逐轴验、地图同范式有据差异、单向无环、enum 复用、freshness 推日期[已修])/ 文档健康 **pass**(4💭)/ Slop **concern → accepted**(🟡 missingKinds 四写[见综合 accept-with-rationale];2💭 正向:赌注充分露出、洞② 真复核非便利答案)

**触点漂移(drift-scout scope=all)**:`aligned=true`,15 触点全 **✅** / 0 🔴 / 0 ⚠️。TP-14/15(新)✅——dogfood:示意行已收口移入注释,主表无真实住址可漂;TP-01~13 全对齐。

## 4. 综合

**0 🔴 阻断。2 🟡 + 多 💭,处置如下**(synthesis-rules:基于上下文意图/决策/客观):

- **🟡-1 触点完整性·示意行**(自仓库地图 订单 示意行是活数据行 → 矛盾 spec §6.1「无数据行」+ drift-scout TP-14 存在性 false-🔴 风险)→ **已修**(`040d411`:订单示意行移入 HTML 注释块,主表真『无数据行』)。注:drift-scout 本批实跑 TP-14 = ✅(读懂「非真实数据」标记),故是 robustness 加固非 bug;修后 robustly ✅,且 §6.1 EmptyHanded 前提成立。
- **🟡-2 Slop·missingKinds 四写**(`missingKinds vs B1 11类` 消歧出现在 spec §3.1 + spec §8.4 B2-3 + scout + migration)→ **accept-with-rationale**:scout 出参注是 brief(『≠ B1 全 11 类』,非逐字)、migration B2-3 是下游真读的 authority(distinct-audience justified)、2 份在 spec 是设计 record。operative 双写面已分化(scout 简注 + migration 权威),非真实腐化面;spec 内部冗余 churn 锁定设计文档价值低。架构维 💭 自承「fork agent 自包含是既定范式」佐证。**未 churn**(诚实判断非掩盖:技术原因 = 自包含 + distinct audience)。
- **💭 EmptyHanded ∨/∧**(scout L109 ∨ vs L123 ∧ 自相矛盾,继承 spec §5.3 vs §5.1)→ **已修**(scout 4 处 + spec §5.3 统一为「无任何模块可 brief」;模块命中但料全缺 → Briefing+全 ⚠️ 非 EmptyHanded,验收 TC4 已证此行为正确)。
- **💭 公设1 消费侧** → **已修**(finishing step 23 加「gist 是待核的料非结论」闭合生产/消费两端)。
- **💭 freshness 搭便车** → **已修**(touchpoint-registry/finishing-rules/implementation-rules last-reviewed 推 2026-06-17,本批动过的活文档)。
- **💭 drift-scout 13 计数 stale** → 已登 `known-pitfalls-index`「文档健康/反腐烂」组 + 用户 2026-06-17 拍板单独一批 count-agnostic 化(本批按 spec §10.1「drift-scout 零改」不动)。
- **其余 💭**(finishing placement / setup.sh `set -e` / AGENTS 发现性 / TP-13 护栏枚举 等)→ 验证安全 / spec 刻意 / 可选增益 / 随单独批,**不动**。

**三诚实赌注**(①下游写作率不可控 ②pull 无 push 强制 ③模块边界清不清)在 scout/migration/finishing/spec §7 🟡 显式露出,过 spec_gap_masking 戒条(承认+技术原因+补救方向);handoff 已与用户确认接受为已知边界。

**设计行为验收(fixture 红线,spec §6.2)**:5 案全 pass,2 红线 ✓——(a) 有料 → scout 递对 write/debug/refactor 各 scenario 片、gist 不抄代码;(b) 料缺/边界糊 → ⚠️ 不编造不硬猜;EmptyHanded 带 missingKinds(场景子集)+ seeGuide。独立 verifier 判 overall=pass。

## 5. 判定

**verdict: pass**

收口准予合并。0 🔴;2 🟡 中 🟡-1 已修、🟡-2 accept-with-rationale(技术原因充分);💭 中 4 项已修(∨∧/公设1/freshness/示意行)、其余登记或接受。设计行为经 fixture 红线 5 案验收(2 红线 ✓)+ drift-scout 15 触点全 ✅。covers 8 文件凭证义务履行。守住段零改、做审分离(designer/implementer ≠ 独立审查者)、三赌注显式露出。

**dogfood 边界声明**:本机制稳定性(下游写作率 / 误报率 / 刷屏感)自仓库审不到(自仓库不建地图数据,§10.2),挂 meta-L4 实战观察,推真实项目验。

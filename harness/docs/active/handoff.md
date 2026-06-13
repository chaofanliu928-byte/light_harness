# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-13 13:38
当前阶段: 治理同层化全部收口;观察期
当前分支: main

## 目标

harness 治理从 meta/feature 双轨**收敛为单层凭证制度**(治理同层化)——已全部完成并经 V8 制度自证。当前权威 = 三件套(finishing/review/credentials-rules)+ credentials.conf + check-audit-coverage.sh。

## 进度

### 已完成
- **治理同层化批 1-5(20 任务,2026-06-13)**:三件套单一化 + credentials.conf(原 meta-scope.conf 降格)+ check-audit-coverage.sh(原 check-meta-review)+ 21 件凭证字段迁移 audit:true + skip→exempt 微 audit + cross-ref 删 + **M1/M2 git rm 退役**。每件两段审查;收口总审 4 挑战者(方向评估通过 + 治理审查三维);V8 制度自证 audit `audit-2026-06-13-133256-governance-single-layer.md` 账齐(新工具核出本批自己的新命名凭证)。
- 前序:上下文层重构 + 会话链自执法(2026-06-11~12,见 ROADMAP)。

### 进行中
- 观察期:每会话照根 CLAUDE.md「会话开场规程」装载+对账(真实使用留痕)。

### 阻塞
无。

## 下一步

1. 观察期:开场三命令真实使用;治理批用新单层流程(finishing 凭证义务核对 + review 维度表治理行 + 方向评估全批)真实跑几次,验制度可运转
2. ROADMAP 观察项按触发器处置:治理批安全扫硬兜底候选(核心 hook 逻辑改动手动挂 security-scan)/ cross-ref 删后互引单防线实战盯几批 / SETUP_NEEDED 自仓库豁免 / 偏好 6 条待补原话
3. 细节交接(工作底稿/任务出生证)= 用户既定"先治理后交接"的后半,另案待启

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- -> docs/governance/credentials-rules.md — 凭证与对账单入口(谁欠凭证/audit 文法/exempt/失效/对账/档位/双写)
- -> docs/governance/review-rules.md — 唯一审查:维度选择表(代码|设计|治理);治理行 bootstrap 4 维+触点完整性维
- -> docs/governance/finishing-rules.md — 唯一收口:凭证义务核对节(step15-18)+ decision 立档(D9)
- -> docs/decisions/2026-06-13-governance-single-layer.md — 同层化决策(三追记;三案并排+第一性重推四件)
- -> docs/audits/audit-2026-06-13-133256-governance-single-layer.md — V8 收口总审(4 挑战者;批 1-5 covers)
- -> docs/ROADMAP.md — 治理同层化收口节 + 观察项总索引

## 关键上下文

- 开场对账三命令(根 CLAUDE.md「会话开场规程」):check-handoff --reconcile / check-shelf-registry(echo '{}')/ **check-audit-coverage --reconcile**(原 check-meta-review)
- 凭证义务:改动命中 credentials.conf include glob → 收口前必有 audit(对抗审查 audit 或 exempt 微 audit);全文住 credentials-rules
- audit 新命名 `audit-YYYY-MM-DD-HHMMSS-[主题].md` + frontmatter `audit: true`;历史 meta-review-*.md 文件名不换(双前缀 glob 兼容)

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 在 mawk/BSD awk 死锁(历史遗留,独立待办)

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ V1 fixture 先红后绿(check-audit-coverage 10 例,任务 5)+ 各契约件结构核
- L2: ✅ V3 装机断言(全树零 meta-*)+ V5 双写比对一致(任务 18)
- L3: ✅ V8 制度自证 audit verdict=pass-after-revision(docs/audits/audit-2026-06-13-133256-governance-single-layer.md;4 挑战者)
- L4: ⏳ 观察期:治理批用新单层流程真实跑(开场对账真实使用留痕)

## CI 阻断
❌ 无 CI 阻断(meta 规则文本+bash hook,无可运行 CI;凭证制度由 check-audit-coverage 对账承担)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

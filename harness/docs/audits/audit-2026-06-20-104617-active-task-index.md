---
audit: true
covers:
  - .claude/hooks/check-handoff.sh
  - .claude/skills/structured-handoff/SKILL.md
  - .claude/skills/structured-handoff/handoff-template.md
  - docs/governance/credentials-rules.md
  - docs/governance/touchpoint-registry.md
---

# 凭证 audit — 活跃任务索引(active-task-index)

## 1. 元信息

- 日期:2026-06-20 10:46:17
- 主题:handoff 台账升格出「活跃任务索引」(机读表头 + 二态表)
- 被审范围:分支 `feat/active-task-index`,实现 diff `dbcafaf..245a879`(8 commits)
- 锁定 spec:`docs/superpowers/specs/2026-06-19-active-task-index-design.md`(经 brainstorm→system-design→自检→design-review×2→修订→code-review)
- 凭证义务来源:改动命中 credentials.conf `.claude/hooks/*`(L18)+ `.claude/skills/*/*.md`(L24)+ `docs/governance/*.md`(L9);语义变更非 typo → 必走对抗审查 audit、不可 exempt(credentials-rules §4.4)
- 架构:扁平 fork,9 挑战者(凭证 audit 5 维 + 方向评估 4 维并行;security-scan/process-audit 治理批暂不纳入,decision 2026-06-13 追记三)

## 2. 维度选取

凭证审查(review-rules 治理行):**bootstrap-4 强制基线**(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)**+ 触点完整性维(条件必选)**——本批是跨文件契约(T1↔T2↔T3 + §8 + TP-16 + live)改动,触点完整性维必选。

### 本次定制
- 启用的推荐维度:bootstrap-4 + 触点完整性(共 5)
- 禁用的推荐维度 + 理由:无
- 新增的定制维度 + 理由:无(触点完整性已是 review-rules 条件必选维)

## 3. 挑战者执行记录

### 凭证 audit 5 维(对抗审查)

- **核心原则合规**:verdict=needs-revision 后修复;关键发现 = SKILL ④自查/③覆写落地把 spec §10.2 限度#2 诚实留痕(自答/非独立闸/不构成质量兜底)删了(spec_gap_masking 消费侧复发,SKILL 是 AI 真读工件);修复 commit 245a879(补回 AI 语义自核 + 公设1 留痕 + 注释对齐)。最小变更/文档第一公民/回退/机器核诚实(stderr 点名、恒 exit 0、不声称保证)均守住。
- **目的达成度**:verdict=pass;关键发现 = 无;四锁定目标(保活/可数/方案B/强度中)逐条真落地,挑战者实跑 7 条 fixture 红线全过(3 逮畸形 + 2 不越界 + 2 边界)。
- **副作用**:verdict=pass;关键发现 = 核② 两个 `next` 跳过分支属可读性显式化(非语义必需),无害自文档,注释已对齐(245a879);机器核确最窄(不核计数/指针/占位文本),零新文件/零新旋钮/无未要求抽象。
- **scope 漂移**:verdict=pass;关键发现 = 无;6 改动文件全可追溯 spec §2.1/§8.1 或强制 governance 义务(TP-16 = §8 第9条/TP-13 强制后果),无 collateral 优化。
- **触点完整性**:verdict=pass;关键发现 = 无;T1 模板表头版式+section标题 ↔ T3 ERE/awk 字符级匹配,§8 第10条 + TP-16 如实登记,live handoff 已迁移对齐(实跑 exit 0 无误报),covers 锁定全 5 命中文件(live handoff.md 不命中 conf glob 正确豁免)。

### 子代理驱动实现批 — 任务级登记(§3.7)

- 任务 1(T1 模板升格):verdict=approved;关键发现 无;修复 commit 无(eb2039c)
- 任务 2(T3 check-handoff --reconcile 结构核 TDD):verdict=approved;关键发现 无(5 fixture 先红后绿+恒exit0);修复 commit 无(e204e42)
- 任务 3(T2 SKILL ③覆写+④自查步):verdict=needs-fixes 后修复;关键发现 落地漏 §10.2 诚实留痕;修复 commit 245a879(6ade82d→245a879)
- 任务 4(credentials §8 双写条目):verdict=approved;关键发现 无;修复 commit 无(38a0b69)
- 任务 5(验证 gate):verdict=approved;调度者独立跑 fixture 红线全绿 + T1↔T3 token 逐字核
- code-review(review-scout reviewType=code):1🔴(live未迁移)+简洁性🟡(占位行冗余)→ 修复 commit 5c95f14;表 schema 消费契约全🟢(awk/ERE 零 bug)
- 触点补全:TP-16 镜像 §8 第10条(Task 4 漏,收口补)→ commit 04bb2df

## 4. 综合

按 synthesis-rules 事后规则综合(回意图/决策/客观/避免先入为主 + 各挑战者「已对照用户原话」section 校验,无主线 🔴 偏离)。9 维:**无 🔴、无 overturn**。唯一 needs-revision(核心原则合规:SKILL 落地漏诚实留痕)已修复(245a879)并复核(SKILL 现含「自答=公设1击穿点、非独立闸、不构成质量兜底」)。其余 8 维 pass。🟢 微缺(注释滞后/dead guard/awk section 前缀/可追溯性)均非阻断,部分已顺手修。

方向评估 4 维(RUBRIC合规/架构一致/文档健康/Slop)全 pass:方向成立(挂起线蒸馏+开场不可数是真痛点,升格是最小机制)、架构一致(纯追加 --reconcile 不碰 Stop、恒 exit 0、不动 promotion)、文档链连贯、几乎无 slop。详 `docs/active/evaluation-result.md`。

## 5. 判定

**verdict=pass**

needs-revision(核心原则合规)已修复并复核;无 🔴/overturn;触点完整性确认 covers 全。本批合规达标,进分流(通过)。

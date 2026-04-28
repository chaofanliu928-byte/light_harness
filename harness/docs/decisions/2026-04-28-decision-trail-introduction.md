# 引入 decision-trail.md(P2 可观测性时间维度)

**类型**:方案选择型
**日期**:2026-04-28
**触发**:用户(2026-04-28)指出 glassbox 看不到跨 session 抉择,需文档载体
**关联**:
- 用户原则 `feedback_skill_no_cross_project.md`(同日确立 — 触发 ROADMAP P2 "skill 持久化"删除)
- glassbox 仓库:https://github.com/chaofanliu928-byte/glassbox(P2 可观测性空间维度的样板)

---

## 问题

ROADMAP P2 可观测性原描述为"待定观测对象 / 呈现形式"。glassbox 项目(独立仓库)已实现 AI 工作 session 内可视化(7 类 HTML 页面 + lint 工具),其概念直接覆盖"AI 工作过程透明化"诉求 — **空间维度不需要 harness 重新发明**。

但 glassbox 是 per-session 产出,看不到:
- 上一个 session 做了什么决策
- 多个 session 累积起来的演化轨迹
- 当前抉择"为什么这样做"的历史背景

harness 现有载体覆盖度评估:

| 载体 | 装的是什么 | 缺什么 |
|---|---|---|
| `decisions/*.md` | 单条架构决策 + 替代方案 | 决策之间的因果链(A 引发 B 引发 C)无索引 |
| `audits/meta-review-*.md` | 单次审查 verdict | 多次 audit 间的演化趋势(同类问题反复出现?)无汇总 |
| `handoff.md` + `completed/` | 当前状态 + 归档 | 历史散落,抉择粒度不显(milestone 级粗) |
| `PROGRESS.md` | 里程碑表 | 太粗,只有"已完成",不含"为什么这么走" |
| memory `feedback_*.md` | 用户跨项目原则 | 私域,**不是项目内可见 artifact** |

**缺口**:抉择路径的连续记录 — 作为项目内可见 artifact,索引决策因果链。

## 方案

**A. 决策图谱** `docs/decision-trail.md`
- 时间倒序,每条 5 字段(抉择 / 替代 / 触发 / 影响 / link)
- 单条 ≤6 行,链到 `decisions/` 看完整推理
- finishing 阶段 milestone commit 后由调度者 append

**B. PROGRESS 升级**
- 现 PROGRESS 只追加里程碑表,加一列"关键抉择"
- 每个 milestone 列 2-3 条核心抉择 + decision link
- 最低成本,但粒度只到 milestone

**C. audit 趋势报告**
- 每次 meta-review audit 末尾加"历史回看"段
- 把过往 audit verdict / 共识发现做趋势统计
- 散在各 audit,不可索引

## 决定

**采用 A**。

理由:
- **粒度独立**:不被 milestone 节奏绑架(用户原则确立 / 缺口承认 等不一定对应 milestone)
- **语义清分**:与 decisions/(单条完整) / PROGRESS(milestone) / audits(单次审查)各司其职,不冲突
- **glassbox 互补**:空间维度由 glassbox 覆盖,本文件只做时间维度,不重新发明
- **用户已确认形态**:2026-04-28 对话中用户对 A/B/C 三选一明示选 A
- B 太粗(无法装载非 milestone 级抉择如用户原则);C 散在各 audit(无索引,不能回答"决策 X 之前的抉择路径是什么")

## 自动化(双路径触发)

**meta 路径与 feature 路径都需 append decision-trail** — meta 改动(治理 / 缺口承认 / 用户原则)恰是 decision-trail 最主要的数据源,故 M1 必加;feature 改动也可能含架构抉择,故 M5 同步加。两路径提取规则同源。

- **M1 `docs/governance/meta-finishing-rules.md`** Step D 通用同步项:meta scope 改动落地后必做 append(本机制对应 meta 拐点 = 主要供给源)
- **M5 `docs/governance/finishing-rules.md`** "通过" Step 2:feature scope 改动 milestone commit 后做 append

**触发不限于 milestone commit**:用户原则确立 / 缺口承认 等关键时点也可即时 append,不必等到下次 finishing(避免错过非 milestone 时点的抉择)。

提取规则(M1 / M5 共用):
- **判断拐点 = 抉择**:架构选择 / 用户原则确立 / 缺口承认 / 替代方案否决
- **不写**:任务进度(归 PROGRESS) / 技术细节(归 decisions/ 单 file) / 用户偏好(归 memory)
- **link**:有 decisions/ 文件必须链;无 file 标"暂无 + 原因"
- **跳过**:本次 commit 无任何架构 / 原则级抉择 → 跳过 append,在 commit message 简记
- **与 M5 step 9 区别**:step 9 是 decisions/ 文件标 commit hash(反向链:decision → commit);本机制是 commit 提取抉择 append(前向链:commit → 抉择 → decision link)。两者不冲突

## 不做(防 scope 扩散)

- **不持久化跨项目**:decision-trail 留 project-local,不进 user-global memory(同 `feedback_skill_no_cross_project.md` 原则)
- **不替代** PROGRESS / decisions / audits:本文件是抉择索引,各原文件继续按原职责
- **不强制 hook 校验**:append 由调度者执行,M15 / M16 hook 不增加新校验项(避免 P0.9 过度执法化)
- **不反向同步**:decisions/ 增删时 decision-trail 由 finishing 触发同步,不实时双向

## 后续

- **meta-L4 验证**:1-2 月观察 finishing 阶段 append 是否真发生 / 提取质量
- **若调度者频繁忽略 append** → 考虑加 hook 校验(P0.9.3 议题)
- **glassbox + decision-trail 闭环验证**:P1 真实项目迁移时验证空间 + 时间双层是否真覆盖"AI 工作可观测性"

## ROADMAP 同步动作(本 decision 触发)

1. P2 可观测性描述重写为双层结构(glassbox 空间 + decision-trail 时间)
2. 删除 P2 "重复工作 skill 化持久化"整段(用户 2026-04-28 否决,原则同 `feedback_skill_no_cross_project.md`)

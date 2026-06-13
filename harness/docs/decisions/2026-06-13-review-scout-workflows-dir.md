# 决策: review-scout 新引入 `.claude/workflows/` 目录的分发与凭证义务归属

> 由 designer 在系统设计阶段创建,遇到影响分发架构方向的不确定选择,请求用户决定。

**状态**：🟢 已决定(用户 2026-06-13 拍板"保 A")

**日期**：2026-06-13

**关联功能**：动态审查侦察(review-scout) — `docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md`(D-A4 + §8.4)

## 问题

review-scout 用 Workflow 脚本(D6 = A 方案)做载体,脚本住 `.claude/workflows/review-scout.workflow.js`。`.claude/workflows/` 是 harness **此前从未有过**的新工件目录,引出两个相互关联的架构方向问题:

1. **分发**:这个新目录(及其中的 workflow 脚本)要不要随 setup.sh 分发到下游目标项目?
2. **凭证义务归属**:`.claude/workflows/*.js` 改动要不要纳入 credentials.conf 凭证义务(即改 workflow 脚本收口前须 audit)?现 credentials.conf 的 include glob 无 `.claude/workflows/`(`.claude/skills/*/*.md` / `.claude/agents/*.md` 等都不含 `.js`)。

两问关联:若分发,则下游也有此目录,凭证义务口径影响下游;若不分发(仅自仓库用),则只在自仓库语境定凭证义务。

## 方案

### 方案 A：分发 + 纳入凭证义务

- **做法**:setup.sh 加 `mkdir -p .claude/workflows` + `cp review-scout.workflow.js`;credentials.conf 加 `.claude/workflows/*` include glob(audit 类型),credentials-rules §2 人读表同步加行(双写,行序同步)。
- **优点**:① 下游也能用 scout 驱动的设计审查(本功能价值随分发落地);② workflow 是编排审查的承重件,改它影响审查行为 → 纳凭证义务与 skills/agents 同档,口径一致;③ 一步到位,不留"以后再补凭证"的洞。
- **缺点**:① 引入新分发目录,扩大 harness 工件面;② 下游若运行时无 Workflow 工具,拿到脚本也只能走降级(D-A4),分发了用不上的文件(但降级链已设计,不致出错)。

### 方案 B：分发,不纳入凭证义务

- **做法**:setup.sh 分发;credentials.conf 不动。
- **优点**:分发面扩了但治理面不扩,改 workflow 脚本不强制 audit,迭代轻。
- **缺点**:**与制度自洽冲突** — workflow 脚本是审查编排的承重件(决定 fork 几个挑战者、怎么扇出),其改动若不留凭证,等于审查机制的核心件无对账保护,违背"治理面改动留凭证"初衷。不推荐。

### 方案 C：不分发(仅自仓库),凭证义务在自仓库语境定

- **做法**:setup.sh 不复制 workflow;review-scout 仅 harness 自仓库用;credentials.conf 在自仓库加 glob。
- **优点**:分发面零扩;先在自仓库 dogfood 验证,成熟后再议分发(对齐 feedback_iterative_progression 边做边提升)。
- **缺点**:① 本功能 §1.1 动机含"机制设计成三类通用",下游用不上则价值打折;② 但 §1.3 本轮只接线设计审查 + scout 推维质量 bootstrap 不可证(§6.2),先自仓库验证再分发也符合"不预设大计划"。

## 决定

选择：**方案 A(分发 + 纳入凭证义务)** — 用户 2026-06-13 拍板"保 A"。**方向 Y(取代早前 X/诚实双路)**:实现成 **ADD review-scout 并排,不替换现有 design-review**——ultracode 开走 scout,ultracode 关走**现有固定 4 维 design-review(原样不动,活备份)**。

原因：workflow 是审查编排承重件,纳凭证义务与 skills/agents 同档口径一致;分发让 ultracode 下游也能用 scout 驱动审查;一步到位不留"以后补凭证"的洞。Y(ADD 不替换)相比 X(双路都 scout 驱动)改动更小、不碰现有路、触点风险更低。

## 后续影响

<!-- 决定之后由执行者补充 -->

- **setup.sh**:新增 `mkdir -p "$TARGET_DIR/.claude/workflows"` + `cp review-scout.workflow.js`(对齐现 agents/skills/hooks 复制段)。
- **credentials.conf**:新增 include glob `.claude/workflows/*`(audit 类型),行序与 credentials-rules §2 人读表同步。
- **credentials-rules.md §2**:人读表加对应行(双写同步,行序同 conf)— 命中 §8 双写同步义务清单第 1 条。
- **Y:ADD 不替换(用户附加要求)**:design-review SKILL 执行开头加运行时分支(ultracode 开→review-scout workflow / 关→走下面**现有固定 4 维流程,原样不动**)。现有 design-review 路、design-reviewer.md、synthesis-rules L113/L151 **零改动**(活备份)。详 spec §2.2 / D-A4 / D13。
- **下游兼容**:ultracode 关的下游拿到 workflow 脚本走不了 scout,但走现有固定 4 维 design-review(已存在),设计审查不缺失。scout 动态推维 = ultracode 专属取舍。

## 考虑过的备选(为什么排除) — 项目经验库

- 方案 B(分发不纳凭证)— 排除倾向:workflow 是审查编排承重件,不纳凭证义务与"治理面改动留凭证"制度自洽冲突;designer 倾向不选 B,但最终由用户裁决。

## 实现时发现的能力边界 — 项目经验库

- 暂无(待落地补充)。

## 踩过的坑(留给未来类似决策) — 项目经验库

- 暂无(待落地补充)。

# AI Dev Harness — 自治理入口

> 本文件是 harness 仓库根的治理入口(M3)。开发 harness 时,调度者每次会话开头读本文件识别 scope + 找对应治理规则。
>
> 注:本文件**不分发下游**(setup.sh 复制的是 `harness/CLAUDE.md` = M4 分发模板,不复制本文件)。
>
> 仓库结构导航见末尾"## 仓库结构 + 快速开始"段。

---

## 1. 角色分离原则(harness 自治理 + 分发)

你是**调度者**。你不亲自做设计、写代码、做审查 —— 这些由独立的 agent 执行。
你负责:需求对接、流程编排、用户沟通、决策传达。

| 角色 | 谁做 | 说明 |
|------|------|------|
| **调度** | 你(主 AI) | 需求对接、编排流程、与用户沟通 |
| **设计** | 调度者 fork designer → 调度者再 fork 自检挑战者 | 逐节写设计文档 + 独立自检 |
| **设计审查** | 调度者并行 fork 4 个挑战者 | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐 |
| **meta-review**(harness 自治理) | 调度者按 M2 流程 fork N 挑战者(模态分型) | scope=meta 改动审查 — 详见 `harness/docs/governance/meta-review-rules.md` |
| **开发** | Superpowers subagent | 写代码(TDD + code review) |
| **安全扫描** | 调度者并行 fork 3 个挑战者 | 凭证数据 / 危险操作 / 注入混淆 |
| **方向评估** | 调度者并行 fork 4 个挑战者 | RUBRIC 合规 / 架构一致 / 文档健康 / Slop 检测 |

做事的和判断的分开,设计的和审查的分开。每个角色只看到自己需要的输入,不受其他角色的上下文影响。

**架构**:扁平 fork(2026-04-16 改造)。调度者(主对话)直接 fork N 个独立挑战者,不做两级嵌套 fork。详见 `harness/docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 2. 治理规则表(meta + feature 双路)

| 路径 | 阶段 | 治理文件(harness 仓库内路径) |
|------|------|------------------------------|
| **meta** | finishing | `harness/docs/governance/meta-finishing-rules.md`(M1) |
| **meta** | review 流程 | `harness/docs/governance/meta-review-rules.md`(M2) |
| **feature** | brainstorming | `harness/docs/governance/brainstorming-rules.md` |
| **feature** | system-design | `harness/docs/governance/design-rules.md` |
| **feature** | writing-plans | `harness/docs/governance/planning-rules.md` |
| **feature** | implementation + testing | `harness/docs/governance/implementation-rules.md` + `testing-rules.md` |
| **feature** | requesting-code-review | `harness/docs/governance/review-rules.md` |
| **feature** | finishing | `harness/docs/governance/finishing-rules.md`(M5,顶部含 scope 分流入口) |
| **feature** | process-audit(finishing 内) | `harness/docs/governance/finishing-rules.md`(M5) |

> **路径前缀注**:meta 路径治理文件在 harness 自身仓库内,完整路径含 `harness/` 前缀;feature 路径治理文件分发下游后无前缀(下游为单层结构,setup.sh 复制 `harness/docs/governance/*.md` 到目标项目 `docs/governance/`)。

## 3. scope 触发判定(人类可读对照 — 与 M17 scope.conf 同步)

| 组 | 文件类别 | glob(M17 `harness/.claude/hooks/meta-scope.conf`) |
|----|----------|----------------------------------------------------|
| **A 组** | governance + 核心规则 | `docs/governance/*.md` / `CLAUDE.md` |
| **B 组** | hooks + settings | `.claude/hooks/*` / `.claude/settings.json` / `.claude/settings.local.json` |
| **C 组** | skills + agents | `.claude/skills/*/SKILL.md` / `.claude/agents/*.md` |
| **D 组** | RUBRIC + DESIGN_TEMPLATE | `docs/RUBRIC.md` / `docs/references/DESIGN_TEMPLATE.md` |
| **F 组** | setup.sh + 分发模板 | `setup.sh` / `templates/*.json`(实际匹配 `harness/setup.sh` / `harness/templates/*.json`;M4 `harness/CLAUDE.md` 由 A 组 `CLAUDE.md` glob 覆盖) |
| **排除** | 流程产出物(避免自循环) | `!docs/audits/meta-review-*.md` / `!docs/audits/archive/**` |
| **E + G 组** | scope 外 | 不命中 include glob 即 scope 外(无需显式列) |

> **同步约束**:本表与 M17 `harness/.claude/hooks/meta-scope.conf` 必须对照同步;改一处需同步另一处(M2 §2 触发条件节有此约束声明)。审查时可 grep 两处比对一致性。

## 4. meta vs feature 分流引导

调度者每次会话开头读本文件后:

1. 按 §3 对照表识别本次改动的 scope。若 git diff 命中**多个组**,按"任一命中即 meta(mixed 也走 meta)"规则(详见 spec §3.1.1)。
2. **scope = meta 或 mixed** → 走 M1 finishing(`harness/docs/governance/meta-finishing-rules.md`)+ M2 review(`harness/docs/governance/meta-review-rules.md`)
3. **scope = feature** → 走 M5 finishing(`harness/docs/governance/finishing-rules.md`)+ 其他 feature governance(见 §2)
4. **scope = none**(改动**完全不命中** include glob) → 无治理文件,直接 finishing(M5 顶部分流入口会引导至此分支)

## 5. scope 内对照表(A+B+C+D+F 文件类别详)

> §3 给 glob 抽象,本节给当前实际命中文件清单(便于审查 + 调度判断)。

**A 组**(governance + 核心规则):
- `harness/docs/governance/{brainstorming,design,planning,implementation,testing,review,finishing}-rules.md`(feature 路径治理 — 7 个)
- `harness/docs/governance/meta-{review,finishing}-rules.md`(meta 路径治理 — M1/M2)
- `/CLAUDE.md`(M3,本文件;**不分发下游**;**hook 不可见 — 已知缺口**:hook cwd=harness/ 时 git diff --relative 不含 repo 根文件,M3 改动不触发 meta-review;后续若需补,需让 hook 加扫 repo 根 git diff)
- `harness/CLAUDE.md`(M4 分发模板)— 由 A 组 `CLAUDE.md` glob 匹配(从 hook cwd=harness/ 视角,git diff --relative 输出 `CLAUDE.md`)

**B 组**(hooks + settings):
- `harness/.claude/hooks/*`(check-* / block-* / notify-* / session-init / **meta-scope.conf 自身**)
- `harness/.claude/settings.json` / `harness/.claude/settings.local.json`

**C 组**(skills + agents):
- `harness/.claude/skills/*/SKILL.md`(brainstorming / design-review / evaluate / process-audit / 等)
- `harness/.claude/agents/*.md`(若有 agent 定义文件)

**D 组**(RUBRIC + DESIGN_TEMPLATE):
- `harness/docs/RUBRIC.md`(评分标准)
- `harness/docs/references/DESIGN_TEMPLATE.md`(系统设计模板)

**F 组**(setup.sh + 分发模板 — **概念归类**;M4 实际经 A 组 glob 匹配):
- `harness/setup.sh`(安装脚本)
- `harness/CLAUDE.md`(M4 分发模板)— 实际匹配走 A 组 `CLAUDE.md` glob,本组保留概念归属
- `harness/templates/*.json`(若有模板文件)

**排除**(scope.conf `!` 前缀):
- `docs/audits/meta-review-*.md`(meta-review 自身产出物,避免自循环)
- `docs/audits/archive/**`(归档审查,不再入 scope)

---

## 仓库结构 + 快速开始(导航)

> 本节保留原 M3 的子目录导航语义,便于路过的人定位 harness/ 子目录。

```
harness/              ← 框架源码,setup.sh 从这里复制文件到目标项目
  CLAUDE.md           ← (M4)安装到目标项目的 CLAUDE.md 模板
  QUICKREF.md         ← 速查卡
  README.md           ← 完整说明
  setup.sh            ← 安装脚本
  .claude/            ← skills, hooks, agents, settings
  docs/               ← 治理规则, 文档模板
```

**快速开始**:

```bash
cd harness
./setup.sh /path/to/your-project
```

详见 `harness/README.md`。

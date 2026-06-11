# AI Dev Harness — 自治理入口

> 本文件是 harness 仓库根的治理入口(M3)。开发 harness 时,调度者每次会话开头读本文件识别 scope + 找对应治理规则。
>
> 注:本文件**不分发下游**(setup.sh 复制的是 `harness/CLAUDE.md` = M4 分发模板,不复制本文件)。
>
> 仓库结构导航见末尾"## 仓库结构 + 快速开始"段。

---

## 1. 角色分离原则(harness 自治理 + 分发)

> **二条公设**(harness 治理的认知约束 — 2026-05-13 加入):
>
> 1. **Pathological Optimist**:AI 评估自己的产出存在系统性乐观偏差 — 这是 harness 扁平 fork 架构(2026-04-16 改造)的认知前提,所以做事和判断必须分开,不是经验,是结构性的认知约束。
>
> 2. **行动公设**:AI 在自己的窗口内"再想想"不能消除盲区(信息状态不变) — 不确定时必须执行一个改变上下文的外部动作(Grep / Read / WebFetch),不能放任内省。
>
> **应用**:design 完成 fork 独立 evaluator(公设 1)/ designer 不确定时强制 Grep 现有 pattern(公设 2)/ implementer 不确定时读相关代码或跑测试(公设 2)。
>
> **反向规则**:任何主张"让同一 agent 同时执行做与审 / 设计与审查"的提议,违反公设 1,**默认拒绝**;主张"内省思考可代替外部动作"的提议,违反公设 2,**默认拒绝**。除非有新事实推翻公设来源依据,**否则不进入辩论**。

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
| **方案调研** | 调度者按需 fork research-scout(联网调研员) | 规划方案时界定领域+问题 → 联网搜业界方案 → 产出选项(证据,非判断依据) |

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

> **跨阶段治理规则**(不绑定单一阶段):`harness/docs/governance/synthesis-rules.md`(调度者综合多挑战者结论时必读;涉及 design-review / evaluate / process-audit / security-scan)。`harness/docs/governance/model-route.md`(模型路由,[2026-05-24] P2 codex 接入搁置、当前全 Claude)。两者均命中 A 组 glob `docs/governance/*.md`,属 meta scope。

## 3. scope 触发判定(人类可读对照 — 与 M17 scope.conf 同步)

| 组 | 文件类别 | glob(M17 `harness/.claude/hooks/meta-scope.conf`) |
|----|----------|----------------------------------------------------|
| **A 组** | governance + 核心规则 | `docs/governance/*.md` / `CLAUDE.md` / `AGENTS.md` / `docs/preferences.md` |
| **B 组** | hooks + settings | `.claude/hooks/*` / `.claude/settings.json` / `.claude/settings.local.json` |
| **C 组** | skills + agents | `.claude/skills/*/*.md`(D15:SKILL.md + 捆绑资源)/ `.claude/agents/*.md` |
| **D 组** | RUBRIC + DESIGN_TEMPLATE | `docs/RUBRIC.md` / `docs/references/DESIGN_TEMPLATE.md` |
| **F 组** | setup.sh + 分发模板 | `setup.sh` / `templates/*.json` / `templates/*.md`(实际匹配 `harness/setup.sh` / `harness/templates/*.json` / `harness/templates/*.md`;M4 `harness/CLAUDE.md` 由 A 组 `CLAUDE.md` glob 覆盖) |
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
- `/CLAUDE.md`(M3,本文件;**不分发下游**;**hook §5.5 可见**(P0.9.3 第一个 trial 引入 repo 根扫描段;P0.9.3 第二个 trial 加 `<root>/` sentinel 前缀)— 改动 audit covers 字段写 `<root>/CLAUDE.md`;详见 `harness/docs/governance/meta-review-rules.md` §7.3 第 5 条;**残留缺口**:全新建未 git add 的根级文件走 untracked 漏检,详 `harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md` §9.4 #11)
- `harness/CLAUDE.md`(M4 分发模板)— 由 A 组 `CLAUDE.md` glob 匹配(从 hook cwd=harness/ 视角,git diff --relative 输出 `CLAUDE.md`)
- `harness/docs/governance/synthesis-rules.md`(跨阶段综合规则 — 命中 A 组 glob,属 meta scope)
- `harness/docs/governance/model-route.md`(模型路由 — P2 codex 接入搁置,命中 A 组 glob)
- `/AGENTS.md`(根,自仓库剖面入口地图;D14 — hook §5.5 root 扫描命中,audit covers 写 `<root>/AGENTS.md`;全新建未 git add 漏检缺口与根 CLAUDE.md 同款,入库后消失)
- `harness/docs/preferences.md`(偏好层权威住址;D11 ✅ A,审查口径 = 忠实性对照用户原话锚点,不评判偏好本身)

**B 组**(hooks + settings):
- `harness/.claude/hooks/*`(check-* / session-init / **meta-scope.conf 自身**)
- ~~harness/.claude/settings.json~~(已撤,2026-06-12 — C 案追记①:自仓库单一工具箱体制;glob 保留备未来)
- `harness/.claude/settings.local.json`:该路径文件不存在(实存的是仓库根 `.claude/settings.local.json`,本地未跟踪不入 git diff);glob 保留备未来

**C 组**(skills + agents):
- `harness/.claude/skills/*/*.md`(SKILL.md + 捆绑资源,如 structured-handoff/handoff-template.md — D15;brainstorming / design-review / evaluate / process-audit / 等)
- `harness/.claude/agents/*.md`(若有 agent 定义文件)

**D 组**(RUBRIC + DESIGN_TEMPLATE):
- `harness/docs/RUBRIC.md`(评分标准)
- `harness/docs/references/DESIGN_TEMPLATE.md`(系统设计模板)

**F 组**(setup.sh + 分发模板 — **概念归类**;M4 实际经 A 组 glob 匹配):
- `harness/setup.sh`(安装脚本)
- `harness/CLAUDE.md`(M4 分发模板)— 实际匹配走 A 组 `CLAUDE.md` glob,本组保留概念归属
- `harness/templates/*.json`(若有模板文件)
- `harness/templates/AGENTS.md`(下游入口地图模板,经 F 组 `templates/*.md` glob)
- 注:`templates/handoff.md` 已删(D3 单源化,住址迁移至 skill 捆绑资源 `harness/.claude/skills/structured-handoff/handoff-template.md`)

**排除**(scope.conf `!` 前缀):
- `docs/audits/meta-review-*.md`(meta-review 自身产出物,避免自循环)
- `docs/audits/archive/**`(归档审查,不再入 scope)

---

## 活上下文链 dogfood 边界

> 分层活上下文链(`docs/context/` L1-L6 + 编码 + 机读 `upstream` + `check-context-chain.sh` 软 + finishing 硬核)是**分发下游**的工件。harness 自仓库**不建** `docs/context/`(现有 product-specs / ARCHITECTURE / specs / decisions 不动不迁移;自仓库用 README 当 vision,不重复)。`check-context-chain.sh` 在自仓库无 `docs/context/` 即 exit 0 静默。自仓库 meta 图的"漏改"靠 meta-review「触点完整性」维(`harness/docs/governance/meta-review-rules.md` §6)兜,不套这条产品式纵向链。详见 `harness/docs/decisions/2026-06-05-living-context-chain.md`。

## 上下文层地图行

- **agent 第 0 步地图(跨运行时)**:`/AGENTS.md`(仓库根;下游分发版 `harness/templates/AGENTS.md`——两份共享核(接手顺序/硬规矩引用/九格表结构)**同批改**,spec §4.1.5 双写同步义务,与 M3↔M17 双写约束同款)
- **用户偏好(协作方式)**:`harness/docs/preferences.md`(仓内权威住址,memory 为缓存镜像;改动命中 A 组 → meta-review,审查口径 = 忠实性对照用户原话锚点 — D11)

## 会话开场规程(会话链自执法 — 下一会话是上一会话的验收者)

1. **装载**:读 `harness/docs/active/handoff.md`(台账:状态+指针),按需顺指针补读本体
2. **对账**(核上次收口的凭证——只读账本不读流水;欠账先补再开新工作):
   - `bash harness/.claude/hooks/check-handoff.sh --reconcile`(全时核台账凭证:文法/锚点/登记/状态判据)
   - `echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh`(落库登记)
   - `bash harness/.claude/hooks/check-meta-review.sh --reconcile`(已提交 scope 改动的 audit 覆盖)
   - 欠账处置:缺 audit → 按 M2 补 meta-review;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账

依据:`harness/docs/decisions/2026-06-11-session-chain-reconciliation.md`(C 案;hook=工具箱,手工模式为正身)

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

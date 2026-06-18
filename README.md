# light_harness（AI Dev Harness）

> 仓库名 `light_harness`，项目自称 **AI Dev Harness**，下文统称「harness」。

**Claude Code 的开发治理框架。** 配合 [Superpowers](https://github.com/obra/superpowers) 插件使用：Superpowers 管「怎么写好代码」，harness 管「按什么标准写、方向对不对、文档怎么流转、人在哪里介入」。**harness 本身不写代码**——代码交给 Superpowers / 子智能体。

> **核心立场**:不赌 AI 写得更快，而是用结构性约束补 AI「自评乐观」的盲点 —— **让弱者高于平均线、让强者突破内省天花板**。

它通过 `setup.sh` 把一套 agent / skill / hook / 治理文档安装进你自己的项目，把一套软件工程纪律——文档先行、角色分离、对抗式审查、机械执法、结构化交接——固化成 Claude Code 在每个开发阶段自动遵守的规则。框架本身用中文写，面向中文使用者。

---

## 它解决什么问题

放手让 AI 写代码（vibe coding）跑得快，但缺工程质量保障。具体有几个结构性问题：

- **AI 评估自己的产出有系统性乐观偏差**（项目把这条立为公设）。让同一个 AI 自己设计、自己审查，它发现不了自己的盲区——「再想想」不改变它的信息状态。
- **跨会话上下文会丢失，文档会腐烂**。代码只有 What，没有 Why、约束、坑、残留 why；AI 读不全代码就会漏，甚至清掉它看不懂的 guard。
- **纯文字的治理规则靠不住**。只靠「希望模型听话」撑着的规则，会随模型状态漂移。

harness 的对策：把「做事的」和「判断的」拆成不同上下文的独立 agent（扁平 fork 多个挑战者做对抗式审查），把关键规则落成 hook 机械执法（不靠 AI 自觉），把方向标准（**RUBRIC**——项目的评分标准 / 方向盘，配置时定）和文档生命周期（handoff / 归档 / 对账）制度化。

价值主张：**让弱者高于平均线，让强者更强**——新手照着强制流程走就能超过自己单干，老手用这套约束突破内省盲点、跨项目复用经验。

### 诚实的成熟度边界（不夸大）

- harness 目前主要在**自己的仓库上 dogfood**（用这套规则开发它自己）。按其自身明确原则，自仓库定位是「**治理测试床，不是 feature 测试床**」。
- **真实项目迁移验证被刻意推迟、尚未完成**。「让弱者高于平均线」是设计意图，不是实测结论；效果数据要等下游真实项目首次使用时才采集（ROADMAP 中标注为待办）。
- 它**不是**自动写代码的工具（代码由 Superpowers / 子智能体写），不是通用 IDE 插件，不预设固化路线图（边做边提升）。
- codex 多模型接入是**可选**且当前搁置（2026-05-24 起），不接入完全可用。

---

## 核心思想

整套设计不围着「让 AI 更快写代码」转，而围着几条**结构性事实**转：AI 自评乐观、会话必死、内省无效、代码只有 What。下面几条都是从这些事实推出来的**承重设计**（删一条整套就塌），不是并列口号——每条的 Why 都挂回某条事实：

1. **二公设是地基**（`CLAUDE.md` §1）。① *Pathological Optimist*：AI 自评有系统性乐观偏差，所以「做事」和「判断」必须分开——这是结构性认知约束，不是经验。② *行动公设*：窗口内「再想想」不改变信息状态，不确定时必须做一个改变上下文的外部动作（Grep / Read / 查文档），不能放任内省。配套反向规则：主张「同一 agent 既做又审」或「内省可代替外部动作」的提议，默认拒绝、不进入辩论。

2. **做审分离，用扁平 fork 制造真对抗**。调度者直接 fork N 个独立上下文的挑战者并行审查，而不是自问自答。两级嵌套 fork 在 Claude Code 平台失效（子智能体无 Agent 工具权限，无法再 fork），所以承认「决策者独立不可得」、但保住「对抗者独立可得」。详见 `harness/docs/decisions/2026-04-16-fork-flat-refactor.md`。

3. **文档是第一公民**。新建先有文档再写代码，变更先改文档再改代码（设计文档 / 类型契约 / 模块 README / ARCHITECTURE）。Why：代码只有 What，AI 读不全就漏、就出错。

4. **工作台·书架两层 + 晋升门禁**。工作台（`handoff`）只放状态和指针，知识住书架；覆写工作台的唯一正路是「先清账后覆写」（归档 → 逐条裁决上架/弃置/顺延/阻塞 → 单源覆写 → 自查），防止有价值内容被无声覆灭。蒸馏判据 =「下个功能还需要它吗？」

5. **防遗忘靠机制不靠纪律**。凡只靠「怕模型不听话」撑着的机制都在贬值；凡靠结构性事实（会话必死、自评乐观、内省无效）撑着的不贬值。所以凭证义务 + 开场对账让「下一个会话当上一个会话的验收者」——下一个会话是必然发生、不可绕、天然独立上下文、看得见全部已提交历史的卡点。

6. **诚实降级，不假装**。fork 失败 / 无 agent 运行时（纯人工），相关步骤软提醒、标 ⚠️ 降级、不阻断，下次会话由独立 agent 重新验证——不绕过、不假装做过。

---

## 主线：开发流程

harness 寄生在 Superpowers 之上。Superpowers 提供一条自动开发流水（brainstorming → 系统设计 → writing-plans → TDD 开发 → code review → finishing），harness 通过 `CLAUDE.md` 里「治理规则优先级高于 Superpowers 默认行为」的规则注入，在每个阶段插约束、在两端加对抗审查。

### 脊柱：阶段化「意图 → 设计 → 计划 → 实现 → 收口」

每切到一个阶段，先读对应的治理文件（`CLAUDE.md` §2 治理规则表）。这条线上有一道**松转严的分界**：

- **前期可探索**（brainstorming / design 允许「待定」）→ **中间放手** Superpowers 跑实现提效 → **最后验收守底线**。力气刻意放在两端。
- 「做审分离」就是这条松紧线上「严」的那一侧：凡涉及评判（设计审查 / 安全 / 方向评估 / 流程审计 / 治理凭证审查），调度者都不自己评，而是 fork 独立挑战者来评。这个「严」侧约束源于公设 ① Pathological Optimist。

### 角色：调度者是唯一不可 fork 的角色

调度者（主 AI）做需求对接、流程编排、用户沟通、决策传达，**不亲自写设计 / 代码 / 审查**。

| 角色 | 谁做 |
|------|------|
| 调度 | 你（主 AI）——只编排不执行 |
| 设计 | fork `designer` 写 → 再 fork 独立挑战者自检 |
| 设计审查 | 并行 fork 4 个独立挑战者（自洽性 / 完整性 / 合理性 / RUBRIC 对齐） |
| 开发 | Superpowers 子智能体（TDD + code review） |
| 安全扫描 | 并行 fork 3 挑战者 |
| 方向评估 | 并行 fork 4 挑战者 |

扁平 fork 要求：一条消息内一次性并行发起 N 个挑战者（不得串行）。

### 流程图

```
Superpowers（插件，自动编排开发流程）
  brainstorming ───── 需求深挖（模糊 / 缺失 / 冲突 / 隐含假设 + 需求确认清单）
    → 系统设计 ────── 逐节写 + 自检 + 全局自洽性交叉验证 → design-review（对抗审查）
      → writing-plans ── 基于设计文档，遵守 ARCHITECTURE.md
        → 实现 ──────── TDD + 最小变更 + 文档先行 + code-review
          → finishing-a-development-branch
                          │
                          ▼
AI Dev Harness（项目治理层，finishing 是唯一收口）
            ├── /security-scan ──── fork 3 挑战者扫 git diff（Critical 阻塞）
            ├── /evaluate ───────── 方向评估（对抗式，verdict = 通过 / 精磨 / 推翻）
            ├── /process-audit ──── 流程审计（记 docs/audits/，不影响分流）
            ├── 凭证义务核对 ────── 命中 credentials.conf → 产 audit 凭证
            ├── /structured-handoff ─ 交接归档（晋升门禁）
            └── 按 verdict 分流:
                  通过 → milestone commit + handoff 归档 + 合并 → 下一功能
                  精磨 → 回 implementation 迭代
                  推翻 → 停下找用户
```

### 三条线把各环节串起来

1. **治理文件**：每阶段一份 rules，进阶段先读（见 `CLAUDE.md` §2 表）。
2. **凭证与对账**：改动命中 `harness/.claude/hooks/credentials.conf` 任一 glob → 收口前必有 audit 凭证（对抗审查，或豁免边界内的微 audit）；下一会话开场用 `check-*.sh`（`check-handoff.sh` / `check-shelf-registry.sh` / `check-audit-coverage.sh`）只读账本核上次的账，欠账先补再开新工作。
3. **handoff 台账**：对话变长或表现下降 → `/structured-handoff` 覆写 `handoff.md`（经晋升门禁）→ `/clear` → 新会话 `SessionStart` hook（`session-init.sh`）自动注入历史装载，实现跨会话续接。

### 回退原则 + 人介入点

- **回退**贯穿全程：发现问题回到该问题应解决的阶段，不在下游打补丁（需求遗漏回 brainstorming，设计不自洽回 system-design，纯代码 bug 当前阶段修）。回退保留产物（设计文档标「待修订」，代码留分支）。
- **人只在四处介入**：配置阶段定 RUBRIC、brainstorming 需求确认、design 阻塞性待决策、finishing 推翻 verdict 时停下找用户。其余自动（自动程度依赖 fork 成功 + agent 运行时在场；缺失则诚实降级）。

---

## 快速开始

### 前置依赖：Superpowers 插件

```
/plugin install superpowers@claude-plugins-official
```

### 安装

```bash
git clone https://github.com/chaofanliu928-byte/light_harness.git
cd light_harness/harness
./setup.sh /path/to/your-project
```

`setup.sh` 把 agents / skills / hooks / 治理文档复制进目标项目的 `.claude/` 与 `docs/`。

### 首次配置

```bash
cd /path/to/your-project
claude
# AI 检测到配置未完成，自动提示运行 /project-setup
# 通过对话式向导（AI 能推断的不问、只问必须你定的），生成 CLAUDE.md、RUBRIC.md、ARCHITECTURE.md
```

之后正常开发即可——治理规则会在每个阶段自动生效。

---

## 仓库结构导航

```
light_harness/
├── README.md          ← 你在这里（landing：是什么 / 给谁 / 怎么跑）
├── CLAUDE.md          ← harness 自治理入口（开发 harness 本身时读，不分发下游）
├── AGENTS.md          ← agent 第 0 步上下文地图（跨运行时）
└── harness/           ← 框架源码，setup.sh 从这里复制到目标项目
    ├── CLAUDE.md      ← 安装到目标项目的 CLAUDE.md 模板（分发版）
    ├── README.md      ← 框架手册：架构图、组件清单、设计原则全文、下游目录结构
    ├── QUICKREF.md    ← 速查卡
    ├── setup.sh       ← 安装脚本
    ├── .claude/       ← agents（10 个：5 核心领审员 designer/design-reviewer/
    │                    evaluator/process-auditor/security-reviewer + 若干 scout
    │                    侦察员 research/review/freshness/drift/design-context）、
    │                    skills（8 个）、hooks（7 个，机械执法与对账）、settings
    └── docs/
        ├── governance/  ← 14 份治理规则（各阶段 rules + credentials / synthesis / review / model-route 等）
        ├── decisions/   ← 关键架构决策记录（如扁平 fork、会话链自执法）
        └── references/  ← 调研地图、多智能体审查指南等参考料
```

**根 README vs `harness/README.md` 的分工**：根 README 只做 landing（是什么 / 给谁 / 怎么跑）；`harness/README.md` 是框架手册（架构图、组件清单、设计原则全文、下游安装后的完整目录结构）。设计理念详解在手册里，根这里只给摘要。

---

## 深入了解

- [框架手册](harness/README.md) — 架构、组件清单、设计原则
- [多智能体审查指南](harness/docs/references/multi-agent-review-guide.md) — 对抗-决策分离模式
- [综合阶段规则](harness/docs/governance/synthesis-rules.md) — 调度者面对挑战者的事前中性化 / 事后防锚定规则
- [扁平 fork 决策](harness/docs/decisions/2026-04-16-fork-flat-refactor.md) — 为什么是扁平 fork
- [Model-Route 治理规则](harness/docs/governance/model-route.md) — codex 接入（可选，当前搁置）的角色 swap 决策表
- [Roadmap](harness/docs/ROADMAP.md) — 边做边提升的下一阶段方向（含真实项目迁移验证待办）

## 许可证

MIT

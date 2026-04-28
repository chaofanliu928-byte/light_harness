# AI Dev Harness

Superpowers 管"怎么写好代码"。AI Dev Harness 管"按什么标准写、方向对不对、文档怎么流转、人在哪里介入"。

## 前置依赖

安装 [Superpowers](https://github.com/obra/superpowers) 插件：

```
/plugin install superpowers@claude-plugins-official
```

## 安装

```bash
./setup.sh /path/to/your-project
```

然后启动 Claude Code，配置向导会自动引导你完成项目配置：

```bash
cd /path/to/your-project
claude
# AI 检测到配置未完成，自动提示运行 /project-setup
# 通过 5 个问题的对话，自动生成 CLAUDE.md、RUBRIC.md、ARCHITECTURE.md
```

## 架构

```
Superpowers（插件，自动编排开发流程）
    brainstorming ← 需求深挖 + session-search 历史检索
        → 系统设计 ← 逐节自检 + design-review 多智能体审查
            → writing-plans ← 基于设计文档 + 遵守 ARCHITECTURE.md
                → subagent-driven-development ← TDD + code-review
                    → finishing-a-development-branch
                        │
                        ▼
AI Dev Harness（项目治理层）
                        ├── /security-scan → 安全扫描
                        ├── /evaluate → 方向评估（对抗式，通过/精磨/推翻）
                        ├── /process-audit → 流程审计（记录到 docs/audits/）
                        ├── /skill-extract → 经验提取
                        ├── /structured-handoff → 交接归档
                        ├── milestone commit + PROGRESS.md
                        └── 下一个功能 → Superpowers 继续
```

CLAUDE.md 中的治理规则优先级高于 Superpowers 的默认行为。
Superpowers 自动编排开发流程，我们通过规则注入来约束每个阶段的行为。

## 我们做什么，Superpowers 做什么

| 职责 | 谁做 |
|------|------|
| 需求讨论 | Superpowers brainstorming |
| 生成实现计划 | Superpowers writing-plans |
| 写代码 | Superpowers subagent-driven-development |
| TDD | Superpowers test-driven-development |
| 代码审查 | Superpowers requesting-code-review |
| Git 分支管理 | Superpowers using-git-worktrees |
| **项目评分标准** | **AI Dev Harness — RUBRIC.md** |
| **架构约束** | **AI Dev Harness — ARCHITECTURE.md** |
| **方向评估（精磨/推翻）** | **AI Dev Harness — evaluate（自动触发）** |
| **提交前安全扫描** | **AI Dev Harness — security-scan** |
| **经验沉淀（skill/参考文档）** | **AI Dev Harness — skill-extract** |
| **结构化交接 + 归档** | **AI Dev Harness — structured-handoff** |
| **跨会话知识检索** | **AI Dev Harness — session-search** |
| **文档生命周期** | **AI Dev Harness — handoff, PROGRESS, 归档** |
| **上下文重置** | **AI Dev Harness — handoff + SessionStart hook** |
| **模块文档维护** | **AI Dev Harness — MODULE_DOC_TEMPLATE** |
| **漂移检测** | **AI Dev Harness — evaluator slop 检测** |
| **流程审计** | **AI Dev Harness — process-audit（自动触发）** |
| **人的介入点** | **AI Dev Harness — 推翻/架构/标准决策** |

## 目录结构

```
项目/
├── CLAUDE.md                            # 纯索引（≤50 行）
├── .claude/
│   ├── settings.json                    # Hooks 配置
│   ├── agents/
│   │   ├── designer.md                  # 系统设计师（含自检子智能体）
│   │   ├── design-reviewer.md           # 设计审查领审员（4 并行子智能体）
│   │   ├── evaluator.md                 # 方向评估领审员（对抗式，3+1 并行子智能体）
│   │   ├── security-reviewer.md         # 安全扫描领审员（3 并行子智能体）
│   │   └── process-auditor.md           # 流程审计领审员（2 并行子智能体）
│   ├── skills/
│   │   ├── project-setup/SKILL.md        # 对话式项目配置向导
│   │   ├── system-design/SKILL.md       # 系统设计（fork designer）
│   │   ├── design-review/SKILL.md       # 设计审查（fork reviewer team）
│   │   ├── evaluate/SKILL.md            # 方向评估（auto fork evaluator team）
│   │   ├── security-scan/SKILL.md       # 提交前安全扫描
│   │   ├── skill-extract/SKILL.md       # 经验提取为新 skill
│   │   ├── structured-handoff/SKILL.md  # 结构化交接 + 归档
│   │   ├── session-search/SKILL.md      # 跨会话知识检索
│   │   └── process-audit/SKILL.md       # 流程审计（auto fork auditor）
│   └── hooks/
│       ├── check-module-docs.sh         # 代码改了就提醒更新模块 README
│       ├── session-init.sh              # 新会话注入上下文
│       ├── check-handoff.sh             # 停止前检查交接时效
│       ├── check-finishing-skills.sh    # 停止前检查 finishing skill 是否执行
│       └── notify-done.sh              # 完成通知（可选）
├── docs/
│   ├── RUBRIC.md                        # ⭐ 评分标准（方向盘）
│   ├── ARCHITECTURE.md                  # 分层规则
│   ├── PROGRESS.md                      # 里程碑时间线
│   ├── governance/                      # 治理规则（按阶段拆分）
│   │   ├── brainstorming-rules.md       # 需求对接时读
│   │   ├── design-rules.md              # 系统设计时读
│   │   ├── planning-rules.md            # writing-plans 时读
│   │   ├── implementation-rules.md      # 子代理执行时读
│   │   ├── review-rules.md              # code-review 时读
│   │   └── finishing-rules.md           # 分支收尾时读
│   ├── active/
│   │   ├── handoff.md                   # 交接文档
│   │   └── evaluation-result.md         # 方向评估结果
│   ├── product-specs/index.md           # 功能索引
│   ├── decisions/                       # 架构决策
│   ├── references/                      # 内部知识（含多智能体审查指南）
│   ├── audits/                          # 流程审计报告（自动积累）
│   └── completed/                       # 归档
└── (Superpowers 作为插件自动加载，产出到 docs/superpowers/)
```

## 工作流程

1. 描述你想做的东西 → brainstorming（session-search 搜索历史上下文，受 RUBRIC 约束）
2. 确认设计 → writing-plans（遵守 ARCHITECTURE）
3. 确认计划 → subagent-driven-development（TDD + review）
4. 功能完成 → finishing-a-development-branch
5. **security-scan** → 扫描代码安全问题（Critical 阻塞，High/Medium 警告）
6. **evaluate 自动触发** → 对抗式方向评估（挑战者找问题 → 领审员做决策）
7. **process-audit 自动触发** → 流程审计（遵从度 + 满意度 → 记录到 docs/audits/）
8. 通过 → milestone commit + skill-extract 提取经验 + structured-handoff 归档 → 合并 → 下一个功能
9. 精磨 → structured-handoff 记录进度 → 返回迭代 → 重新 finishing
10. 推翻 → structured-handoff 记录状态 → 停下来找用户 → 重新 brainstorming

**整个流程全自动。** 用户只在需求确认和推翻决策时介入。

上下文快满时 → 更新 handoff.md → `/clear` → 新会话自动加载

## 十条设计原则

### 一、根基性原则

**1. 文档第一公民** — 新建时先有文档再写代码，变更时先改文档再改代码。适用于设计文档、类型契约、模块 README、ARCHITECTURE。区别只在文档的厚度，不在有没有。

**2. 角色分离** — 做事的和判断的分开，设计的和审查的分开。调度者只编排不执行，设计/审查/扫描/评估各由独立 agent（context: fork）执行。一个角色可以是单个 agent 或一个 agent team。

**3. RUBRIC 驱动方向** — RUBRIC.md 是方向盘，不只是评判工具。它指导 brainstorming 的方案讨论、设计的决策取舍、实现的代码风格、code review 的检查标准、evaluate 的评分依据。标准在开发中从用户反馈持续积累。

**4. 确定性优先** — hooks 强制执行关键规则，不靠 AI 自觉。能机械验证的不靠文字指令，能阻断的不靠提醒。

**5. 人做 AI 做不好的事** — 定标准（RUBRIC）、做推翻决策、做架构决策、确认需求清单。AI 提供分析和推荐方案，人做最终选择。

### 二、需求层原则

**6. 需求深挖与收敛** — 不在用户说完第一句话后就开始设计。四维识别（模糊/缺失/冲突/隐含假设）逐个向用户确认。收敛标准：每个场景能写出"谁→做什么→系统做什么→看到什么"。3 轮确认上限防止无限循环。

### 三、设计层原则

**7. 设计自洽与逐节自检** — 设计文档逐节推进，每节写完立即自检，不通过原地修。全局 10 条交叉验证确保需求↔模块↔接口↔数据↔边界↔架构↔决策↔契约全部对齐。前后端共享同一份类型契约，先改契约再改代码。

### 四、审查层原则

**8. 对抗-决策分离审查** — 子智能体是对抗者（找问题附证据），领审员是决策者（从问题清单推导评分和决策）。找问题的和做判断的分开。同一问题被多个子智能体独立发现则严重性升级，子智能体间矛盾标注为分歧待判。参照 `docs/references/multi-agent-review-guide.md`。

### 五、知识层原则

**9. 文档有生有死** — active/ 放当前状态，完成就归档到 completed/。设计文档完成标注 ARCHIVED，取消标注 CANCELLED。交接文档具体优于概括（用函数名定位，不用行号），80 行上限。经验提取须满足三标准（项目特定+可复用+可操作），无模式时不强行提取。

### 六、回退原则

**10. 回退到问题该解决的阶段** — 需求缺陷回 brainstorming，设计缺陷回系统设计，代码 bug 原地修。回退保留产物（设计文档标注待修订，代码保留在分支）。fork 失败时调度者降级执行但标注"未经独立 agent 验证"，下次会话须由独立 agent 重新验证。

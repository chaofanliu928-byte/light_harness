# AI Dev Harness — 自治理入口

> 本文件是 harness 仓库根的治理入口(M3)。开发 harness 时,调度者每次会话开头读本文件走治理规则表与会话开场规程。
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
| **设计审查** | 调度者并行 fork 4 个挑战者 | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐(ultracode 下走 review-scout:scout 现推维) |
| **治理审查** | 调度者按 review-rules 维度选择表 fork N 挑战者 | 治理面改动审查(凭证义务详 credentials-rules) |
| **开发** | Superpowers subagent | 写代码(TDD + code review) |
| **安全扫描** | 调度者并行 fork 3 个挑战者 | 凭证数据 / 危险操作 / 注入混淆 |
| **方向评估** | 调度者并行 fork 4 个挑战者 | RUBRIC 合规 / 架构一致 / 文档健康 / Slop 检测 |
| **方案调研** | 调度者按需 fork research-scout(联网调研员) | 规划方案时界定领域+问题 → 联网搜业界方案 → 产出选项(证据,非判断依据) |

做事的和判断的分开,设计的和审查的分开。每个角色只看到自己需要的输入,不受其他角色的上下文影响。

**架构**:扁平 fork(2026-04-16 改造)。调度者(主对话)直接 fork N 个独立挑战者,不做两级嵌套 fork。详见 `harness/docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 2. 治理规则表(单层 — 治理同层化 2026-06-13)

| 阶段 | 治理文件 |
|------|----------|
| brainstorming | `harness/docs/governance/brainstorming-rules.md` |
| system-design | `harness/docs/governance/design-rules.md` |
| writing-plans | `harness/docs/governance/planning-rules.md` |
| implementation + testing | `harness/docs/governance/implementation-rules.md` + `testing-rules.md` |
| 审查(代码/设计/治理) | `harness/docs/governance/review-rules.md`(维度选择表) |
| finishing(唯一收口) | `harness/docs/governance/finishing-rules.md` |
| **凭证与对账(跨阶段)** | **`harness/docs/governance/credentials-rules.md`(单入口)+ `harness/.claude/hooks/credentials.conf`(机器版,双写同步)** |
| 跨阶段综合 | `harness/docs/governance/synthesis-rules.md`(fork 多挑战者前后必读) |
| 模型路由(跨阶段) | `harness/docs/governance/model-route.md`([2026-05-24] P2 codex 接入搁置,当前全 Claude) |

> 凭证义务一句话:改动命中 credentials.conf 任一 include glob → 收口前必有 audit 凭证(对抗审查 audit 或 exempt 微 audit);类目与 glob 详 credentials-rules.md §2,制度全文住 credentials-rules.md,本文件不重复(防散文拷贝,§2.3-§8)。

---

## 活上下文链 dogfood 边界

> 分层活上下文链(`docs/context/` L1-L6 + 编码 + 机读 `upstream` + `check-context-chain.sh` 软 + finishing 硬核)是**分发下游**的工件。harness 自仓库**不建** `docs/context/`(现有 product-specs / ARCHITECTURE / specs / decisions 不动不迁移;自仓库用 README 当 vision,不重复)。`check-context-chain.sh` 在自仓库无 `docs/context/` 即 exit 0 静默。自仓库 meta 图的"漏改"靠治理审查「触点完整性」维(`harness/docs/governance/review-rules.md`)兜,不套这条产品式纵向链。详见 `harness/docs/decisions/2026-06-05-living-context-chain.md`。

## 上下文层地图行

- **agent 第 0 步地图(跨运行时)**:`/AGENTS.md`(仓库根;下游分发版 `harness/templates/AGENTS.md`——两份共享核(接手顺序/硬规矩引用/九格表结构)**同批改**,spec §4.1.5 双写同步义务;同类双写对见 credentials-rules §8)
- **用户偏好(协作方式)**:`harness/docs/preferences.md`(仓内权威住址,memory 为缓存镜像;改动命中 credentials.conf → 须 audit 凭证(治理审查),审查口径 = 忠实性对照用户原话锚点 — D11)

## 会话开场规程(会话链自执法 — 下一会话是上一会话的验收者)

1. **装载**:读 `harness/docs/active/handoff.md`(台账:状态+指针),按需顺指针补读本体
2. **对账**(核上次收口的凭证——只读账本不读流水;欠账先补再开新工作):
   - `bash harness/.claude/hooks/check-handoff.sh --reconcile`(全时核台账凭证:文法/锚点/登记/状态判据)
   - `echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh`(落库登记)
   - `bash harness/.claude/hooks/check-audit-coverage.sh --reconcile`(已提交凭证义务改动的 audit 覆盖)
   - 欠账处置:缺凭证 → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账

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

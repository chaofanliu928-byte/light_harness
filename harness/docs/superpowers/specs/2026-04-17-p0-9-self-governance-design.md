# P0.9 harness self-governance 系统设计

> **阶段状态**(2026-04-26 更新):brainstorming 阶段二深挖 ✅ 完成,**阶段三需求清单整合中**。3 条缺口拍板:
> 1. **根源 1 执法层** — 选 Q1-B+C 组合:P0.9.1 加最小硬 hook(Stop + pre-commit,光谱 B+),完整执法留 P0.9.3
> 2. **根源 3 马鞍定位** — 选 Q2-B:不强行定可量化指标(避免编数据),spec 明示 4 条已实现 leverage 事实,具体指标推 P0.9.2 诊断阶段
> 3. **根源 2 bootstrap** — 选 Q3-B:P0.9.1 内明示"写前流程"缺口,具体设计留 P0.9.1.5(吃自己狗粮:用 P0.9.1 产出的 meta-review 流程做)
>
> spec §1 整合 Q1-Q3 中。整合完毕后从 §1 重走自检流程,§2-8 受影响部分(hook 入 scope 影响模块表/接口/数据/边界/影响)由 designer 复核或重 fork。
>
> **历史**:
> - 2026-04-17 brainstorming 第一轮收敛(scope/光谱 B/分批/混合结构等已确认)
> - 2026-04-24 design 阶段被 /design-review 4 挑战者审查**不通过(D1 核心原则 ❌ / D2 目的达成 ❌ / D3 副作用 ❌ / D4 scope ✅)**,触发回退
> - 2026-04-26 brainstorming 阶段二深挖完成
>
> **规模级别**:重量级(整合后复核 — Q1 加 hook 模块,scope 实际扩大)。
>
> **Bootstrap 状态**:本 spec 是 meta 改动的元审查。bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)是 ad-hoc 临时审查,P0.9.1 落地后用新流程反向审本 spec 验证 4 维合理性。不追溯推翻本 spec。

---

## 1. 需求摘要

### 1.1 用户目标

harness 作为治理框架需要**治理自己的改动**。具体实现三件事：

1. harness 改动有明确 finishing 路径（不再 ad-hoc）
2. rule-negotiation 无便利路径（流程清晰到可事后 grep 验证）
3. harness 的 leverage 定位（比 feature 高一个量级的稳定性）显式化

**背景**：见 `docs/decisions/2026-04-17-harness-self-governance-gap.md` 承认的三条根源。

### 1.2 核心场景（按优先级排序）

#### 场景 1 [P0.9.1 主体] meta 改动走流程化对抗审查

- **谁**：调度者（主对话 AI）+ 用户
- **做什么**：准备改 harness scope 内文件（A + B + C + D + F，见 1.3 边界）
- **系统做什么**：
  - 触发 meta-review 流程（扁平 fork 挑战者）
  - 挑战者维度由调度者按主题定制（推荐清单 + 最低必选 + 定制理由留痕）
  - 领审员综合共识/分歧/盲区
  - audit trail 归档到 `docs/audits/meta-review-YYYY-MM-DD-[主题].md`
- **看到什么**：改动附带对应 audit 产物，grep audit 目录可检出是否"走过流程"

#### 场景 2 [P0.9.1 主体] meta finishing 路径明确

- **谁**：调度者 + 用户
- **做什么**：完成一次 meta 改动后收尾
- **系统做什么**：按 `docs/governance/meta-finishing-rules.md`（新文件）指引完成 decision 立档 / ROADMAP 更新 / PROGRESS 迁移 / memory 同步
- **看到什么**：meta 改动不再临时编动作（即本会话 2026-04-17 反复踩的坑的系统化修复）

#### 场景 3 [P0.9.1 主体] 4 个现有审查 agent 维度可定制化

- **谁**：调度者
- **做什么**：准备用 design-review / evaluate / security-scan / process-audit
- **系统做什么**：每个 agent 支持"推荐清单 + 最低必选维度 + 定制理由留痕"混合结构；调度者按主题选维度，理由写入 audit trail
- **看到什么**：同类主题的审查维度一致可复现，跨主题则允许按实际定制。维度选择事后可追溯

#### 场景 4 [P0.9.2 诊断] leverage 定位复盘

- **谁**：用户或调度者
- **做什么**：P0.9.1 跑了 N 轮后复盘
- **系统做什么**：回顾 meta 改动 audit trail，判断稳定性标准是否比 feature 高一个量级
- **看到什么**：有数据支撑的 leverage 诊断报告。若已隐含满足则写一段原则说明；若不足则补强

#### 场景 5 [P0.9.3 兜底] 最小硬 hook 补强（可能不触发）

- **谁**：调度者
- **做什么**：如 P0.9.1 流程被绕
- **系统做什么**：加最小硬 hook（pre-commit 检测 scope 内文件改动 + audit 产物存在）
- **看到什么**：违规 commit 被拦

### 1.3 边界与约束

**做什么(scope 内 A+B+C+D+F + 新增 hook 触点)**:
- A `governance/*.md`, `CLAUDE.md` 核心规则
- B `.claude/hooks/*.sh`, `settings.json` 注册 — **本次新增 2 个最小硬 hook**(Stop + pre-commit)实现"光谱 B+"执法触点
- C `.claude/skills/*/SKILL.md`, `.claude/agents/*.md`
- D `docs/RUBRIC.md`, `docs/references/DESIGN_TEMPLATE.md`
- F `setup.sh`, 分发给下游项目的模板 `harness/CLAUDE.md` 和 `harness/templates/*.json`(改 M19 = 改下游 settings,必须入 scope 触发 meta-review;下游不分发 meta hook,见兼容性要求)

**不做什么**:
- E `docs/ROADMAP.md`, `docs/PROGRESS.md`, `docs/active/handoff.md` 不走对抗审查(改动频率过高会反效应;走轻量一致性检查即可)
- G `README.md`, `QUICKREF.md`, 用户文档 不走对抗审查(文档追随)
- **写前流程不在 P0.9.1 scope** — 留 **P0.9.1.5**(P0.9.1 落地后用新 meta-review 流程做,吃自己狗粮)。**第八轮 fix-7 用户拍板触发条件 = B(灵活)**:P0.9.1 落地后不强制启动 P0.9.1.5,**M0-M4 启动前用户决定**是否先做 P0.9.1.5。理由:无 P0.9.1 实战数据时不应预先锁死触发条件(`feedback_judgment_basis` 原则)。详见 `docs/decisions/2026-04-26-p0-9-1-5-trigger-condition.md`
- 不在 P0.9 内为 harness 自身填"项目特定 RUBRIC"(挪后续条目)
- 不追溯审查 P-1/P0/P0.5 已完成项
- P0.9.2 诊断不在 P0.9.1 scope 内 — 具体可量化"高一量级"指标推到此阶段定(需真实运行数据)
- P0.9.3 兜底视实战数据启动(若 P0.9.1 的 Stop+pre-commit 在实战中被绕,P0.9.3 加更严执法)
- M0-M4 批次内容(block-dangerous 删除 / 封死简化收尾 / 简洁性维度降级 / finishing 冲突修复 / 轻量级判定收紧)作为 P0.9.1 落地后**首个使用批次**,不在本 spec 实施
- **第八轮 fix-9 已识别绕过路径处理**(详见 `docs/decisions/2026-04-26-bypass-paths-handling.md`):
  - **(i) `--no-verify` 绕 pre-commit** — **推 P0.9.3**:AI 调度者默认不主动用此 flag,无实战数据不预防(`feedback_judgment_basis`)
  - **(ii) 长 session 不 stop 漏 Stop hook** — **接受 + 推 P0.9.3**:光谱 B+ 最小集设计代价(D17:Stop + pre-commit 是 2 hook 最小集);视实战数据 P0.9.3 再决定
  - **(iv) 理由质量自律** — **接受**:语义判断不是 hook 适合做,治理层(M2 / M9)负责;落地后 process-audit 反向审 audit covers + skip 理由质量
  - **(vi) 下游改 harness 副本** — **接受**:§1.3 兼容性假设 + D19 a 方案"零污染"前提;不试图技术封堵,声明 + 留痕(setup.sh 末尾打印消息提示)
  - (iii)(v) 已修(详见 §3.1.9 hook 逻辑改造 + §3.1.1 + §4.1.2 排除规则改造,本文件)

**性能要求**:meta finishing 额外成本估算每月 2.5-10 小时(每月 5-10 次触发 × 30-60 分钟/次),作为"马鞍 leverage"合理代价。Stop / pre-commit hook 触发开销小(~ms 级 git status 扫描 + grep)。

**安全要求**:audit 产物为 markdown,无敏感信息。hook 仅读 git/handoff/audit 文件,不写入。

**兼容性要求**:
- 现有 design-review / evaluate / security-scan / process-audit skill 的用户调用接口**保持不变**(向后兼容);prompt 结构变化(A/B/C 三段)对调用接口透明
- **下游项目不受 meta 治理污染**:setup.sh 不分发 meta-finishing-rules / meta-review-rules / meta hook / meta-scope.conf 等 meta 专属文件;分发模板 `harness/CLAUDE.md` 内容仅含 feature 层规则,不含 meta 层
- **Evidence Depth 双标隔离**:meta-L1~meta-L4(meta 改动用)与 feature 侧 L1-L4(feature 改动用)各自指明适用域,handoff 字段格式区分
- **第八轮 fix-9 (vi) 兼容性声明**:**下游不应改 harness 副本(设计假设)**,如有改动需求请回 harness 仓库 PR。setup.sh 末尾打印消息提示此约定(具体文案在实施 M14 时定)。这是设计假设,不是技术约束;下游若改 harness 副本,自负其责
- **第八轮 fix-9 (v) bootstrap 循环可接受声明**:**meta 治理文件改动也走 meta-review**,bootstrap 循环视为可接受(类似编译器自举 — 改 meta-review-rules.md 会触发 meta-review 用旧规则审新规则)。详见 §3.1.1 排除规则 + §4.1.2 M17 scope.conf 排除规则改造
- **第九轮 fix-9 (vii) M3 hook 不可见缺口接受**(2026-04-28 P0.9.1 落地反审 audit `meta-review-2026-04-28-102359-p0-9-1-self-review.md` 4 维交叉共识):**M3(repo 根 `/CLAUDE.md`,自治理入口)改动 hook 不可见**,因 hook cwd=harness/ 时 `git diff --relative` 不输出 repo 根文件 → M15 / M16 hook 完全检不出 M3 改动。后续要补需让 hook 加扫 repo 根 `git diff`(无 --relative + harness/ 前缀过滤)。**P0.9.1 不补,推 P0.9.3 兜底**(类比 (i)(ii)(iv)(vi) 已识别绕过路径处理思路)。M3 改动频率极低 + 改动语义清晰("自治理入口"),实战风险可控;落地后 P0.9.3 governance 漂移检测可识别此类绕过

### 1.4 关联需求

**依赖的已有功能**:
- 2026-04-17 本会话 4 挑战者扁平 fork 元审查模式(原型)
- P0.5 扁平 fork 基础设施(`docs/decisions/2026-04-16-fork-flat-refactor.md`)
- `docs/decisions/` 归档结构
- `docs/audits/` 目录(process-audit 已在用)
- `docs/references/multi-agent-review-guide.md`(对抗-决策分离 + 共识/分歧/盲区)
- 现有 Stop hook / SessionStart hook 机制(harness 已用,本次扩展 Stop + 新增 pre-commit + 扩展 SessionStart 反审检测段 — 第八轮 fix-8 A 部分,M20)

**被哪些未来功能依赖**:
- **P0.9.1.5 写前流程**:P0.9.1 落地后用新 meta-review 流程做(吃自己狗粮)。P0.9.1.5 在 M0-M4 批次之前
- **P0.9.2 诊断**:复盘 leverage 定位 + 定具体可量化指标(需 N 次实战数据)
- **P0.9.3 兜底**:Stop+pre-commit 被绕时补强(可能完全不触发)
- **M0-M4 治理改动批次**:享受 P0.9.1 + P0.9.1.5 流程
- **P1 真实项目验证**阻塞于 P0.9.1 完成
- 后续任何 harness meta 改动

### 1.5 已确认的决策

#### 第一轮 brainstorming(2026-04-17)

| 问题 | 回答 | 来源 |
|---|---|---|
| scope 纳入哪些修改类型 | A+B+C+D+F 纳入,E+G 排除 | 第一轮 Q1 |
| ~~强制层级~~ | ~~光谱 B(对抗审查流程化,不加主强制 hook)~~ **被第二轮 Q1 推翻 → 光谱 B+** | 第一轮 Q2 |
| audit trail 机制 | 每次 meta 改动必须产出 audit,无产物视为未走流程 | 第一轮 Q2 补 |
| 分批次序 | P0.9.1 主体 / P0.9.2 诊断 / P0.9.3 兜底 | 第一轮 Q3 |
| 审查维度策略 | 每次按主题定制,不固定 4 维。扩展到现有 design-review / evaluate / security-scan / process-audit 也采用"具体情况具体分析" | 第一轮 Q2 后续 |
| 混合结构 | 推荐清单 + 最低必选维度 + 定制理由留痕 | 第一轮 Q3 补 |
| audit 归档路径 | `docs/audits/meta-review-YYYY-MM-DD-[主题].md` | 第一轮第二轮补问 |
| 前置已确认待 P0.9 落实 | block-dangerous 删除 / bypass decision 模式放弃 / 简洁性维度降级为 CLAUDE.md 行为准则 | 前述会话 |
| scope 选 X1 | P0.9.1 既做 meta finishing 又改 4 审查 agent | 第一轮 Q2 后续补问 |

#### 第二轮 brainstorming(2026-04-26,/design-review 不通过后回退深挖)

| 问题 | 回答 | 来源 |
|---|---|---|
| **Q1 根源 1 执法层 — 光谱 B 是否足够** | **B+C 组合:P0.9.1 加最小硬 hook(光谱 B+)+ 明示完整执法留 P0.9.3**。理由:光谱 B 与老版本(0 次调用)结构同构,需硬 hook 触点打破"沉默跳过" | 第二轮 Q1 |
| Q1 最小硬 hook 数 | **2 个**(组合 β):Stop + pre-commit 两扇门叠加覆盖 session 末 + commit 前 | 第二轮 Q1 追问 |
| Q1 scope 文件清单位置 | `.claude/hooks/meta-scope.conf` 单独文件,hook 读取(未来扩 scope 不改代码) | 第二轮 Q1 细节 1 |
| Q1 audit 对应机制 | YAML frontmatter `covers:` 文件清单。hook 扫 git 改动,扫所有 audit 的 covers 并集,改动 ⊆ 并集放行 | 第二轮 Q1 细节 2 |
| Q1 audit 失效规则 | audit 产出后,covers 文件**有新 commit → 对该文件失效**(按 git log 比对,非时间窗口) | 第二轮 Q1 细节 3 |
| Q1 跳过留痕格式 | handoff `## meta-review: skipped(理由: ...)` **理由必填**(grep 可检空 reason) | 第二轮 Q1 细节 4 |
| Q1 Stop hook 拦截门槛 | **无门槛,每次 Stop 都检测**;`stop_hook_active=true` 防死循环已足够。"门槛"反而允许沉默违规 | 第二轮 Q1 追问 |
| **Q2 根源 3 高一量级 — 是否定可量化指标** | **B + 明示已实现机制 leverage 4 事实**:不强行定指标(避免编数据违反 `feedback_judgment_basis`)。具体指标推 P0.9.2 诊断阶段(需真实数据) | 第二轮 Q2 |
| Q2 已实现的 leverage 4 事实 | (1) 比 feature 多 2 个硬 hook;(2) audit 必走(YAML covers + 失效规则);(3) meta 审查不通过回 brainstorming(feature 只回 design);(4) 跳过必须留痕(理由必填) | 第二轮 Q2 |
| **Q3 根源 2 写前流程 — 缺失在哪做** | **B:P0.9.1 内明示缺口 + ROADMAP 加 P0.9.1.5,具体设计留 P0.9.1.5**(用 P0.9.1 产出的 meta-review 流程做,吃自己狗粮) | 第二轮 Q3 |
| Q3 P0.9.1.5 vs M0-M4 时序 | P0.9.1 落地 → Self 反审 → P0.9.1.5(写前流程)→ M0-M4(享受新写前 + 新 meta-review)→ P0.9.2/P0.9.3(视实战数据) | 第二轮 Q3 延伸 |

**注**:第二轮 Q1 推翻第一轮 Q2 的"光谱 B"原共识 → "光谱 B+"。这是 scope 级变更,brainstorming 收敛后 + design 通过后立 decision(`docs/decisions/2026-04-26-meta-review-enforcement-spectrum-b-plus.md` 待建)。

### 1.6 RUBRIC 风险标记

基于 `docs/RUBRIC.md` 通用基线(harness 自身**项目特定标准为空**,是 self-governance 缺口的具体面之一,挪后续处理):

**涉及的惩罚项(主动规避)**:
- **简洁性**:P0.9 要防 over-engineering — meta finishing 流程不能变成比 feature finishing 更大的怪物。新增治理文件和 pattern 必须最小够用。Q1 加 2 个 hook 已是最小集(单 hook 漏 commit 路径,3 hook 含跨 session 但复杂度过高)
- **一致性**:meta-review 流程与现有 4 个审查 agent 改造必须共享同一个"混合结构" pattern(推荐 + 最低必选 + 理由),避免各处一套。**注:第一轮 design-review 挑战者指出 process-audit / security-scan 按 multi-agent-review-guide 不是对抗模式,统一 pattern 有模态错配风险 → §7 决策需 4 agent 分型设计**
- **测试充分性**:meta 改动的 Evidence Depth 语义需重定义(feature 的 L1-L4 不完全适用 meta 场景)→ meta-L1~meta-L4
- **代码质量**:audit 产物模板需设计清晰(YAML frontmatter `covers:` + 字段 + 维度清单 + 综合结构 + 用户决策位)

**涉及的奖励项(主动争取)**:
- **已实现的"高一量级"机制 leverage 4 事实**(Q2 拍板,作为可数事实而非凭空指标):
  1. 比 feature 多 2 个硬 hook(Stop + pre-commit 拦 scope 改动无 audit)
  2. audit 必走(YAML `covers:` + 失效规则,git log 比对)
  3. meta 审查不通过 → 回 brainstorming(feature 只回 design,本次正在执行)
  4. 跳过必须留痕(handoff `## meta-review: skipped(理由)` 必填,可 grep)

**元警告**:
- harness 项目特定 RUBRIC 空白本身是 self-governance 缺口的具体面。P0.9.1 的 design 阶段不能依赖项目特定惩罚项作参考 — 限制了 RUBRIC 应对方式的完整性
- 具体可量化指标(如"维度数 ≥ feature 的 N 倍")**不在 P0.9.1 内定**,推 P0.9.2 诊断阶段(需真实数据)。Q2 已论证:无数据强行定指标会编数据,违反 `feedback_judgment_basis`
- bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)是 ad-hoc 临时审查,P0.9.1 落地后必须**反向审本 spec**验证 4 维合理性

---

## 2. 模块划分

> **Bootstrap 例外说明**(见任务指令例外 1):ARCHITECTURE.md 的 UI / Services / Repository 分层对 harness 框架自身不适用。下表"组件类别"列使用 harness 实际组件类型:`governance`(治理文本) / `hook`(shell 强制) / `hook-conf`(hook 读取的配置数据) / `skill`(SKILL.md) / `agent`(agent 定义) / `template`(模板) / `CLAUDE-rule`(CLAUDE.md 核心规则) / `settings`(.claude/settings.json)。

### 2.1 模块清单

| 模块 | 职责(一句话) | 新建/改动 | 组件类别 | 所属场景 |
|---|---|---|---|---|
| **M1. `docs/governance/meta-finishing-rules.md`** | 定义 meta 改动的 finishing 四步(判 meta-review 必要 / decision 立档 / ROADMAP/PROGRESS/memory 同步)+ 内含 meta-L1 ~ meta-L4 evidence depth 定义节 | 新建 | governance | 场景 2 主体 |
| **M2. `docs/governance/meta-review-rules.md`** | 定义 meta-review 流程契约(触发条件 / 挑战者数量弹性 / audit 产物规范 / audit 失效规则)+ 内含**审查维度三段 pattern 定义节**(供对抗式 agent 引用) | 新建 | governance | 场景 1 主体 + 场景 3 一致性锚点 |
| **M3. `CLAUDE.md`(仓库根,升级为 harness 自治理入口)** | 当前仅 5 行导航,**升级为 harness 自身的治理入口**:加角色分离表 / 治理规则表 / scope 触发判定 / meta vs feature 分流。与下游分发模板 `harness/CLAUDE.md`(M4)路径区分 | 改动(升级) | CLAUDE-rule | 场景 1 入口 / 场景 2 入口(harness 自身) |
| **M4. `harness/CLAUDE.md`(分发模板)** | 不含 meta 治理段落。下游项目用 harness 但不改 harness 自身,M4 仅含 feature 层规则(角色分离 / 文档索引 / 治理表 feature 部分) | 改动(无 meta 增项) | CLAUDE-rule | 下游分发,不在 P0.9.1 主流程触发 |
| **M5. `docs/governance/finishing-rules.md`** | 文件头部加 scope 分流判定入口(判 meta → 走 M1;判 feature → 走现有流程) | 改动 | governance | 场景 2 分流 |
| **M6. `.claude/agents/design-reviewer.md`** | 4 挑战者 prompt **对抗式** A/B/C 三段改造(推荐 + 最低必选 + 定制理由),引 M2 的 pattern 定义节 | 改动 | agent | 场景 3 |
| **M7. `.claude/agents/evaluator.md`** | 4 挑战者 prompt **对抗式** A/B/C 三段改造,4 维度结构同 M6 | 改动 | agent | 场景 3 |
| **M8. `.claude/agents/security-reviewer.md`** | 3 挑战者 prompt **模式匹配 + 对抗混合**改造:凭证/数据扫描部分硬编码 pattern 不动;**对抗维度部分**(凭证泄露场景判定 / 危险操作判定 / 注入混淆判定)采用 A/B/C 三段 | 改动 | agent | 场景 3 |
| **M9. `.claude/agents/process-auditor.md`** | 2 挑战者 prompt **事实统计式**改造,**保留分工 N 维**(流程遵从度 / 效果满意度),不强加 A/B/C;允许调度者按主题"细化统计粒度",该细化点登记到 audit | 改动 | agent | 场景 3 |
| **M10. `.claude/skills/design-review/SKILL.md`** | "执行"节引 M2 维度选取步骤(调度者读 M2 的 pattern 节,按主题构造 C 段定制理由) | 改动 | skill | 场景 3 |
| **M11. `.claude/skills/evaluate/SKILL.md`** | 同 M10 | 改动 | skill | 场景 3 |
| **M12. `.claude/skills/security-scan/SKILL.md`** | 引 M2 pattern 节(仅对抗维度部分);硬编码扫描部分输入注入不变 | 改动 | skill | 场景 3 |
| **M13. `.claude/skills/process-audit/SKILL.md`** | 引 M2 关于"事实统计式按主题细化粒度"的子节(不引 A/B/C pattern) | 改动 | skill | 场景 3 |
| **M14. `setup.sh`** | **加命名前缀过滤**:`meta-*` 文件不被分发到下游(M1 / M2 / M17 / 新 hook M15-M16);M3 `/CLAUDE.md`(harness 根)不分发(分发的是 M4 `harness/CLAUDE.md`);其他正常分发 | 改动 | template | 分发隔离(B3 处理) |
| **M15. `.claude/hooks/check-meta-review.sh`** | **新建 Stop hook**。每次 Stop 触发(无门槛,`stop_hook_active=true` 防死循环):扫 git 改动 vs M17 scope.conf glob → 比对 `docs/audits/meta-review-*.md` 的 YAML `covers:` 并集 → 不覆盖时引导 audit 或检 handoff `## meta-review: skipped(理由)` | 新建 | hook | 场景 1 执法触点 1(光谱 B+) |
| **M16. `.claude/hooks/check-meta-commit.sh`** | **新建 pre-commit hook**(Git PreCommit,非 Claude Code hook)。扫 staged 改动同 M15 逻辑,缺 audit/skip 理由则拦 `git commit`。两扇门叠加:M15 守 session 末未 commit 路径,M16 守 commit 入 git 历史路径 | 新建 | hook | 场景 1 执法触点 2(光谱 B+) |
| **M17. `.claude/hooks/meta-scope.conf`** | **新建配置数据**。glob 列表(对应 §1.3 scope A+B+C+D+F + 排除 E+G + 排除 meta-* 文件本身)。M15/M16 hook 读此文件,scope 扩展不改 hook 代码 | 新建 | hook-conf | 场景 1 配置层(B+ 弹性) |
| **M18. `.claude/settings.json`** | 在 `Stop` hook 数组追加 M15;不注册 M16(M16 是 git hook,通过 `.git/hooks/pre-commit` 链接而非 settings.json) | 改动 | settings | M15 注册 |
| **M19. `harness/templates/settings.json`(新建分发模板)** | **新建分发模板**(D19 a 方案,第四轮新增):继承 harness 自身 `.claude/settings.json` 结构,但**移除 M15 在 Stop hook 数组的注册条目**(以及未来任何 meta hook 注册);M14 setup.sh line 71 改 source 指向此文件,使下游零 meta hook 注册行。**第七轮 fix-1 修:M19 入 §1.3 F 组 scope + M17 scope.conf** — 改 M19 直接影响所有下游 settings,必须触发 meta-review,不能成为治理后门 | 新建 | template | 下游分发(零污染,直接实现 §1.3 兼容性) |
| **M20. `.claude/hooks/session-init.sh`(扩展现有反审检测段)** | **扩展现有 hook**(第八轮 fix-8 A 部分):在 SessionStart 注入 PROGRESS / handoff 之外,加反审检测段 — 检测 git log 主分支含 P0.9.1 落地 commit + audit covers 不含本 spec 路径,两条件成立则注入 system-reminder 提醒反审。**graceful degrade**:git log 失败 / audit YAML 损坏不阻断 session | 改动(扩展) | hook | 场景 1 反审触发(SessionStart) |

**候选清单调整说明**(本轮 fork 决策):

- **B1 决策(模块过剩)→ M3 review-dimension-pattern 合并入 M2** :pattern 定义只服务 meta-review 流程 + agent 改造;两类用途共用一个文件不构成"动词+名词"职责违反。M2 内含 `## 审查维度三段 pattern(供对抗式 agent 引用)` 子节即可,无需独立 reference。**省 1 个新文件**
- **B1 决策(模块过剩)→ M4 meta-evidence-depth 合并入 M1**:meta-L1 ~ meta-L4 是 meta finishing 的"证据形态",与 finishing 流程绑定,不独立。M1 内含 `## meta evidence depth 定义节`。**省 1 个新文件**
- **B11 决策(撤回第 5 维"过度工程化"加维)→ bootstrap 沿用 4 维**:第七轮按"meta 系统在自己落地前不可证 = bootstrap 悖论"原则,撤回过度工程化作为独立第 5 维加维(无可证基础,且 4 维"副作用 / scope 漂移"已能承担过度复杂度异常的检出)。详见 §6.4
- **A1 决策(2 hook 模块)→ M15(Stop)+ M16(pre-commit)新增**:无门槛、`stop_hook_active=true` 防死循环、两扇门叠加
- **A2 决策(scope.conf)→ M17 单独配置文件**:hook 代码不写 glob;scope 扩展只改 M17,不改 M15/M16
- **B3 决策(下游污染)→ M14 setup.sh 加 `meta-*` 命名前缀过滤**:`cp` 通配符不再无脑展开,先过滤 `meta-*`,再 cp。M1 / M2 / M15 / M16 / M17 文件名都以 `meta-` 开头,自然命中过滤。CLAUDE.md 双 path 区分:`/CLAUDE.md`(M3,自治理入口)不分发,`/harness/CLAUDE.md`(M4,模板)分发
- **B4 决策(M3 vs M4 身份)→ M3 升级 `/CLAUDE.md`(harness 根),M4 仅改 `/harness/CLAUDE.md`(模板)**:仓库实际两文件,M3 自身从 5 行导航升级为治理入口,加角色分离 / 治理表 / scope 判定;M4 不含 meta 段落
- **B5 决策(`!` 注入限定)→ 不用 `!` 注入访问 meta-* 文件**:改用调度者运行时读 + 嵌入 prompt(条件化:只在 harness 自身仓库)。理由:`!` 注入在下游 skill 也会执行;命名前缀 `meta-*` 在下游不存在(M14 已过滤),`!`cat docs/governance/meta-*` 注入会失败但不会 erro out,但下游不需要这种污染。**调度者读法**:在 §3.1.7 新增"runtime 嵌入契约"
- **占位删除 → M17/M18 旧编号(P0.9.2/P0.9.3 占位)合并入 §1.3 边界声明**:不在模块表内登记。理由:占位无交付物,登记在 §1.3 已足够;§2.1 模块表只列实交付物。**简洁性 RUBRIC 主动应对**
- **D19 a 方案(第四轮)→ 新增 M19 `harness/templates/settings.json`**:用户拍板 a 方案(零污染优于软污染);M14 setup.sh line 71 改 source 指向 M19;下游零 meta hook 注册行,直接实现 §1.3 兼容性

**模块数量对比**:
- 第一轮草稿:18 模块(其中 M17/M18 占位)
- 本轮锁定:**20 模块**(M3 / M4 合并到 M1 / M2 节内,M17 / M18 占位删除;新增 M15-M18 hook + 配置 + settings;**第四轮 D19 a 方案再加 M19 templates/settings.json**;**第八轮 fix-8 A 部分加 M20 session-init.sh 扩展**)
- 净变化:+2(M19 第四轮 D19 a 方案;M20 第八轮 fix-8 A 部分),**新模块价值密度更高**(无占位无重复)

### 2.2 模块依赖图

harness 无运行时依赖关系(非代码执行系统),本图表达的是**读取/嵌入依赖**(模块 A 在执行期或静态读取期引用 B 的内容):

```
                  ┌─────────────────────────────────┐
                  │  M3 /CLAUDE.md (harness 自治理入口) │
                  │  (升级版:角色分离 + 治理表 + scope) │
                  └──────────────┬──────────────────┘
                                 │ 调度者每次阶段切换读
            ┌────────────────────┼─────────────────────────┐
            ▼                    ▼                         ▼
   ┌─────────────────┐  ┌──────────────────────┐   ┌─────────────────┐
   │ M5 finishing-   │  │ M2 meta-review-rules │   │ 现有 design-    │
   │    rules (分流) │  │  (含 pattern 定义节) │   │    rules / ...  │
   └────┬─────────┬──┘  └────┬──────┬──────────┘   └─────────────────┘
        │         │          │      │
 scope=feature    │     scope=meta  │
   (走现有)       │          │      │
                  ▼          ▼      │
           ┌──────────────────────┐ │
           │ M1 meta-finishing-   │ │
           │   rules (含 evidence │◀┘  引 audit 产物归档位置
           │   depth 定义节)      │
           └──────┬───────────────┘
                  │ 触发
                  ▼
   ┌──────────────────────────────────────────────┐
   │ M6-M9 四审查 agent + M10-M13 skill         │
   │  对抗式 (M6 design-reviewer, M7 evaluator)  │
   │   ← A/B/C 三段(引 M2 pattern 节)           │
   │  混合 (M8 security-reviewer)                │
   │   ← 硬编码扫描 + A/B/C 对抗维度部分          │
   │  事实统计式 (M9 process-auditor)            │
   │   ← N 维分工(不强加 A/B/C),粒度可定制      │
   └────────┬─────────────────────────────────────┘
            │ 产 audit
            ▼
   ┌──────────────────────────────────────────────┐
   │ docs/audits/meta-review-YYYY-MM-DD-          │
   │   HHMMSS-[主题].md                            │
   │ (YAML frontmatter `covers:` 字段)             │
   └──────────────────────────────────────────────┘
            ▲
            │ M15/M16 hook 比对 git diff
            │ vs YAML covers 并集
            │
   ┌────────┴─────────────────────────────────────┐
   │ M15 check-meta-review.sh (Stop hook)         │
   │ M16 check-meta-commit.sh (Git pre-commit)    │
   └────────┬─────────────────────────────────────┘
            │ 读
            ▼
   ┌──────────────────────────────────────────────┐
   │ M17 .claude/hooks/meta-scope.conf            │
   │  (glob 列表,A+B+C+D+F)                       │
   └──────────────────────────────────────────────┘

   ┌────────────────────────────────────────────────────────┐
   │ M14 setup.sh (分发,加 meta-* 前缀过滤,line 71 改源到 M19) │
   │ M4 harness/CLAUDE.md (分发模板,不含 meta)              │
   │ M19 harness/templates/settings.json (D19 a:无 meta hook)│
   │   ──────────────────────────────────────────────▶     │
   │   目标项目(下游,不被 meta 污染)                      │
   └────────────────────────────────────────────────────────┘

   ┌──────────────────────────────────────────────┐
   │ M18 .claude/settings.json (harness 自身用,    │
   │   注册 M15/M16,与 M19 双轨)                  │
   └──────────────────────────────────────────────┘

   ┌──────────────────────────────────────────────┐
   │ M20 .claude/hooks/session-init.sh            │
   │  (扩展:反审检测段 — 第八轮 fix-8 A 部分)    │
   │  读 git log 主分支 + docs/audits/ YAML covers│
   │  注入 system-reminder(graceful degrade)    │
   └──────────────────────────────────────────────┘
```

**依赖方向**:

- M3 `/CLAUDE.md`(harness 自治理入口)是顶层,只引下层 governance 文件路径,不被任一其他模块引(被读)。**调度者每次阶段切换 + session-init 读**
- M2 内含 pattern 定义节,被 M6/M7(对抗式)/ M8(混合的对抗维度部分)直接引;M9(事实统计式)只引 M2 的"按主题细化粒度"子节
- M1 内含 evidence depth 定义节,被 M2 / M5 / M9 / 未来 meta 改动 handoff 字段引
- M15 / M16 hook 读 M17 scope.conf;读 git diff;读 docs/audits/ YAML covers — **只读不写**
- M14 setup.sh 单向输出到目标项目,不依赖运行时
- M18 settings.json 注册 M15(M16 是 git hook,装在 `.git/hooks/pre-commit` 链接,M14 setup.sh 不分发它)
- **M20 session-init.sh 扩展**(第八轮 fix-8 A 部分)与 hook 体系并列,SessionStart 触发,读 git log + audit YAML covers,注入 SessionStart system-reminder — **只读不写**;不被任一其他模块引(session 级输出)

**循环依赖检查**:

- M3 → M5 → M1 → M2 → M6-M13(单向链),无循环
- M15/M16 → M17(单向),M15/M16 不被任一其他模块引,无循环
- M2 内的 pattern 节被 M6-M13 引但 M6-M13 不反向写 M2(单向),无循环
- M20 → git log + docs/audits/ YAML covers(单向只读),M20 不被任一其他模块引,无循环

**每个场景到模块的实现路径**:

| 场景 | 实现路径 |
|---|---|
| 场景 1(meta-review 流程化)| M3 `/CLAUDE.md` 入口 → M2 定义流程 + pattern → M10-M13 skill 调用 M6-M9 agent → 产 audit 含 YAML `covers:` 字段;**反审触发(fix-8 A 部分)**:§3.1.10 → M20 SessionStart hook 反审检测段 |
| 场景 2(meta finishing 明确)| M3 → M5 finishing-rules 分流 → M1 引导四步(meta-review / decision / ROADMAP/PROGRESS/memory 同步) |
| 场景 3(4 agent 维度定制化)| M2 pattern 节 → M6/M7 全 A/B/C / M8 混合 / M9 事实统计 N 维 |
| 场景 1+2 执法层(光谱 B+)| M17 scope.conf → M15 Stop hook + M16 pre-commit hook,两扇门叠加。无 audit 时拦截或要求 `## meta-review: skipped(理由)`。**下游隔离**(D19 a 方案):M14 setup.sh line 71 改 source 指向 M19 `templates/settings.json`(无 meta hook 注册),配合 M14 命名前缀过滤(D12),下游零 meta hook 痕迹 |
| 场景 4(P0.9.2 诊断)| 不在 P0.9.1 实施,§1.3 边界已声明。M1 audit trail 累积是场景 4 数据基础 |
| 场景 5(P0.9.3 兜底)| 不在 P0.9.1 实施,§1.3 边界已声明。若 M15/M16 实战中被绕,P0.9.3 加更严执法(如 `exit 2` 全量阻断) |

---

**第 2 节自检**:

- [x] 每个模块单一职责:M1(finishing 引导)/ M2(review 流程 + pattern)/ M3(自治理入口)/ M4(分发模板)/ M5(分流)/ M6-M9(agent 改造按 multi-agent-review-guide 适用性分型)/ M10-M13(skill)/ M14(分发隔离)/ M15-M17(执法触点 + 配置)/ M18(注册)/ **M19(分发模板)/ M20(session-init.sh 扩展反审检测)**分开
- [x] 依赖方向:Bootstrap 例外 1 已声明 ARCHITECTURE.md 对 harness 不适用。读取依赖单向,无循环
- [x] 无循环依赖:M3 → M5 → M1 → M2 → M6-M13 单向;M15/M16 → M17 单向;M20 → git log + audit covers 单向只读
- [x] 改动模块改动范围:M3 升级而非重写,M5 只加分流入口,M6-M9 按各自模态改造(M6/M7 全 A/B/C,M8 混合,M9 事实统计),M10-M13 只改输入注入和执行步骤;M14 加前缀过滤不重写;M18 仅追加一行;**M20 仅扩展现有 session-init.sh 加反审检测段(graceful degrade)**
- [x] 每个场景(含执法层 + 占位场景 4/5 边界声明)都能找到实现路径
- [x] 粒度合理:无空占位,每个 M 都有明确文件交付。**模块数 20**(第一轮 18,第四轮 D19 a 方案 +1 = M19 templates/settings.json,**第八轮 fix-8 A 部分 +1 = M20 session-init.sh 扩展**),价值密度更高(M3/M4 合并节内,M17/M18 占位删除,新增 M15-M19 hook 体系 + 分发模板,M20 反审检测段)

---

## 3. 接口定义

> harness 不是运行时应用,"接口"定义为**流程契约**(谁在什么时机触发什么,谁产出什么给谁)+ **执法触点**(hook 与 git/audit 的读写关系)。本节用"谁 → 触发条件 → 输入 → 输出 → 错误处理"格式描述。

### 3.1 模块间接口(流程契约)

#### 3.1.1 `scope 识别` 契约(M3 → M5 / M15 / M16)

**触发者**:
- (a) 调度者(主对话 AI),在用户描述改动需求后(软触发)
- (b) M15 Stop hook 自动扫,M16 pre-commit hook 自动扫(硬触发)

**触发条件**:用户的改动意图涉及任一文件(软),或 git diff/staged 非空(硬)

**契约**:

```text
输入(调度者自查 OR hook 扫):
  - 改动涉及的文件路径列表(调度者从对话上下文 / hook 从 git diff)
  - scope 配置数据来源:
    · 软触发:M3 `/CLAUDE.md` 的"scope 触发判定"段落(人类可读对照表)
    · 硬触发:M17 `.claude/hooks/meta-scope.conf`(glob 列表,机器可读)
    · 两者保持同步(M3 段落 + M17 文件,任一变更触发 meta-review)

  对照规则(scope 内 A+B+C+D+F + scope 外 E+G,见 §1.3):
    · scope 内:`docs/governance/*.md`(**含 meta-*.md 治理文件 — 第八轮 fix-9 (v) 修**)、
      `CLAUDE.md` 核心规则、
      `.claude/hooks/*.sh`(**含 meta-*.sh 治理 hook — 第八轮 fix-9 (v) 修**)、
      `.claude/hooks/meta-scope.conf`(**M17 自身入 scope — 第八轮 fix-9 (v) 修**)、
      `.claude/skills/*/SKILL.md`、`.claude/agents/*.md`、
      `docs/RUBRIC.md`、`docs/references/DESIGN_TEMPLATE.md`、
      `setup.sh`、`harness/CLAUDE.md`(M4 模板)、
      `harness/templates/*.json`(M19 分发模板 — 改它直接影响下游 settings)
    · scope 外:`docs/ROADMAP.md`、`docs/PROGRESS.md`、`docs/active/handoff.md`、
      `README.md`、`QUICKREF.md`、用户文档
    · **排除规则(第八轮 fix-9 (v) 修)**:**只排除流程产出物**(audit 文件本身):
      - `docs/audits/meta-review-*.md`(audit 文件本身 — 排除自循环,避免改 audit 触发审 audit)
      - `docs/audits/archive/`(归档 audit — 同上)
      **不再排除治理文件**(`meta-*.sh` / `meta-*.md` / `meta-scope.conf`)— 改它们
      等同改 governance,**必须走 meta-review**(bootstrap 循环可接受 — 改 meta-review-rules.md
      会触发 meta-review 用旧规则审新规则,类似编译器自举)
    · **关键区分**:
      - **流程产出物(audit 文件本身)**:必须排除自循环(audit 文件改动也要 audit → 无穷递归)
      - **治理文件(scope.conf / meta-finishing-rules.md / meta-review-rules.md / meta-*.sh)**:
        **入 scope** — 改它们直接改变治理规则,等同改 governance,必须走 meta-review

输出:
  - scope 标签: "meta" | "feature" | "mixed" | "none"
    · 全部命中 A+B+C+D+F → "meta"
    · 全部命中 E+G → "none"(走现有 finishing,不入 M1)
    · 任一命中 A+B+C+D+F → "mixed"(按 meta 处理 — 任意一个 scope 内文件即触发)
    · 改动是 feature 业务代码(harness 仓库内罕见) → "feature"

错误处理:
  - 调度者判错(把 meta 识别为 feature 或反之):软触发兜底由 M15 Stop hook 在
    session 末检出 git diff 命中 scope 但无 audit → 引导补 audit/补 skip 理由
  - hook 扫的文件路径在 M17 配置中无规则:保守判为 "meta",hook 输出引导消息
  - M17 配置文件缺失或损坏:hook 退化为 exit 0(不阻断,但 stderr 输出
    "⚠️ meta-scope.conf 不可读,本次 meta 检测降级为软提醒")
```

---

#### 3.1.2 `meta finishing 触发` 契约(M5 → M1)

**触发者**:调度者,进入 finishing 阶段时

**触发条件**:§3.1.1 的 scope 标签为 "meta" 或 "mixed"

**契约**:

```text
输入(M5 finishing-rules.md 分流出口):
  - scope 标签
  - 本次改动的文件清单
  - 本次改动关联的需求描述 / decision 引用

输出(进入 M1 meta-finishing-rules.md 引导的流程):
  - 对话流进入 M1 定义的四步(后续 §3.1.3 展开)
  - 若 scope 为 "feature"/"none" → 继续现有 finishing-rules.md 的原流程,不进入 M1

错误处理:
  - M1 文件缺失或损坏:调度者标注 "⚠️ meta-finishing-rules 不可读,
    降级手工走完 meta 流程,记录降级位置",不阻断(软强制)
```

---

#### 3.1.3 `meta finishing 四步` 契约(M1 内部步骤序列)

**触发者**:调度者

**触发条件**:§3.1.2 触发

**契约**(按顺序,每一步有独立子契约):

```text
Step A. 判本改动有无 meta-review 必要
  输入:
    - scope 标签
    - 改动深度(重大 / 小修)
    - 本次是否为"连续第 N 次同主题 meta 改动"(从 audit trail 检索)
  输出:
    - 走 meta-review: true/false
    - 若 false,理由(登记到 handoff `## meta-review: skipped(理由: ...)`,
      理由必填,可 grep 检空 reason — A5 决策)
  规则:
    - scope=meta 且重大 → 必须走 meta-review
    - scope=meta 且小修(仅 typo / 链接 / 注释等) → 可跳过,handoff 写理由
    - scope=mixed → 仅对 meta 部分走 meta-review

Step B. 触发 meta-review(若 Step A 走)→ §3.1.4 子契约

Step C. decision 立档(meta 改动必做)
  输入:
    - 本次改动的设计选择
    - Step B 的 audit trail(若走了)
  输出:
    - `docs/decisions/YYYY-MM-DD-[主题].md`
  规则:
    - 使用现有 decision 模板;若是 meta-level decision(无 A/B 方案只有承认型)
      采用 `2026-04-17-harness-self-governance-gap.md` 范式
      (标明 "Bootstrap 声明"或"根源承认型")

Step D. ROADMAP / PROGRESS / memory 同步
  输入:
    - 本次 meta 改动的完成状态
  输出:
    - `docs/ROADMAP.md` 对应条目状态更新
    - `docs/PROGRESS.md` 里程碑或阶段表格更新
    - `memory/project_harness_overview.md` 若有结构性变化则同步

错误处理:
  - Step A 判"跳过"但后续 Step C 发现需要 decision:回 Step A,
    标"判错"事件到本次 audit
  - Step B 失败:见 §3.1.4 兜底
  - Step C 立档完成后发现本次改动破坏了现有 decision:新建 superseding decision,
    旧的标 🔴 已废弃
```

---

#### 3.1.4 `meta-review 流程` 契约(M2 + M10-M13 协同)

**触发者**:调度者

**触发条件**:§3.1.3 Step B 决定走 meta-review

**契约**:

```text
输入:
  - 本次改动主题描述(如 "M0 删除 block-dangerous")
  - 改动涉及的文件 diff / 设计文档(若有)
  - M2 内 pattern 定义节(对抗式 / 混合式 / 事实统计式各自模板)

步骤(M2 meta-review-rules.md 定义):
  1. 调度者按 agent 模态 + 主题选维度:
     a. 对抗式(M6/M7) — A/B/C 三段:
        A 推荐清单:M2 提供按 agent 默认维度
        B 最低必选维度:任何 meta 改动必须包含 — bootstrap 4 维基线(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)
        C 定制扩展:调度者按主题增补,每条必须附"定制理由"字段
     b. 混合式(M8 security-reviewer) — 部分 A/B/C:
        硬编码扫描部分(凭证 / 数据 / 危险模式 grep)不变
        对抗维度部分(场景判定 / 注入混淆判定)用 A/B/C
     c. 事实统计式(M9 process-auditor) — N 维分工:
        保留(流程遵从度 / 效果满意度)2 维
        允许调度者细化粒度(如"仅审本批次 / 全 session"),细化点登记到 audit
  2. 调度者在一条消息中并行 fork N 个挑战者(N 由主题 + 模态决定,不固定 4)
     每个挑战者 prompt 按 §3.1.5 挑战者调用契约构造
  3. 挑战者返回问题清单
  4. 调度者综合为"共识 / 分歧 / 盲区"(参考 multi-agent-review-guide.md)
  5. 调度者产 audit trail 到
     `docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md` (B8 决策:加 HHMMSS)
     格式见 §4.1 数据实体 audit_trail
     **YAML frontmatter 必含 `covers:` 字段**(A3 决策),列出本 audit 覆盖的
     scope 内文件路径(供 M15 / M16 hook 读)

输出:
  - audit trail 文件(必产,缺失等价于未走流程)
  - 审查判定:通过 / 待修 / 推翻

返回结构变更明示(B6 兼容性声明):
  - 调用接口参数不变(向后兼容):skill 调用语法不变,agent prompt 入参不变
  - 返回结构变更:
    · 对抗式 agent(M6/M7):返回结构新增 A/B/C 三段元信息(`recommended_enabled`/
      `recommended_disabled`/`minimum_required`/`customized_added`)
    · 混合式 agent(M8):返回结构在硬编码扫描部分**不变**;
      对抗维度部分新增 A/B/C 三段元信息(仅对抗维度部分)
    · 事实统计式 agent(M9):返回结构**不强加 A/B/C**;
      新增 `granularity_customization` 字段(可选,记录调度者本次细化粒度)

错误处理:
  - fork 失败:调度者按 M2 定义的"降级执行"走单 context 分角色审查,
    audit trail 标 "⚠️ 降级执行,独立性未达"
  - 调度者漏选最低必选维度:agent prompt 内 B 段静态嵌入 + 调度者 Step 1 自检
    若漏检,由 audit trail 中 minimum_required 字段空白检出
  - audit trail 未产出:违反 scope 规则,M15 Stop hook 在 session 末检出
    git diff 命中 scope 但无 audit covers → 引导补 audit/补 skip 理由
```

---

#### 3.1.5 `挑战者调用` 契约(M10-M13 skill → M6-M9 agent prompt 构造)

**触发者**:调度者(通过 skill 的执行节)

**触发条件**:§3.1.4 Step 2

**契约**:

```text
输入(由调度者拼接,嵌入挑战者 prompt):
  - 挑战者角色定义(从对应 agent 文件 §挑战者 N 段落取)
  - 该挑战者的维度关注焦点(从 M2 pattern 节 + 当次选取结果)
  - 待审查对象(设计文档 / 代码 diff / governance 文件改动)
  - 关键的治理参考文件(RUBRIC.md / ARCHITECTURE.md 若适用 / 相关 decision)
  - 输出格式约束(问题清单格式,见 agent 文件现有 prompt 末尾)

按 agent 模态分输入差异:
  - M6/M7 对抗式:嵌入 A 推荐 / B 最低必选 / C 定制理由三段
  - M8 混合式:对抗维度部分嵌入 A/B/C;硬编码部分嵌入凭证/危险/注入 pattern 列表
  - M9 事实统计式:嵌入 2 维分工 + 当次细化粒度(若调度者填写)

输出:
  - 挑战者的独立问题清单,含位置 + 证据 + 严重性
  - 对抗式 + 混合式对抗部分:含 A/B/C 三段元信息
  - 事实统计式:含 granularity_customization(可选)

错误处理:
  - 挑战者返回空或格式不符:调度者重试一次;仍失败则该维度标 "未完成"
  - 挑战者 prompt 超上下文:由 M2 规则限制单 prompt 最大字节,超限时调度者拆分维度
```

---

#### 3.1.6 `审查维度三段结构` 契约(M2 pattern 节 → M6-M9 agent prompt 结构)

**触发者**:agent prompt 改造时(静态契约,不是运行时)

**契约**(按 agent 模态分):

```text
对抗式 agent(M6 design-reviewer / M7 evaluator)— A/B/C 三段全采用:

  A. 推荐维度清单(markdown 列表)
     格式: `- [维度名]: [关注焦点] [默认启用: 是/否]`
     来自 M2 pattern 节的当次 agent 定制

  B. 最低必选维度(markdown 列表,禁止删减)
     格式: `- [维度名]: [不可省略理由]`
     注:bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)作为基线最低必选

  C. 定制理由字段(结构化)
     格式:
       ```
       ### 本次定制
       - 启用的推荐维度: [列表]
       - 禁用的推荐维度 + 理由: [列表](禁用 minimum 项需用户确认)
       - 新增的定制维度 + 理由: [列表]
       ```

混合式 agent(M8 security-reviewer)— 部分 A/B/C:

  X. 凭证 / 数据扫描 pattern(硬编码,不变)
     格式同现 security-reviewer.md(pattern grep 列表 + Critical/High/Medium 标级)

  A. 推荐对抗维度(markdown 列表)
     仅在"扫描后场景判定"维度采用 — 例如"凭证泄露的风险等级判定"、
     "危险操作的副作用范围"等需要语境判断的维度

  B. 最低必选对抗维度
     凭证泄露场景判定固定为最低必选(凭证扫描永远不可绕)

  C. 定制理由字段
     格式同对抗式

事实统计式 agent(M9 process-auditor)— 不强加 A/B/C,N 维分工:

  N1. 流程遵从度(固定维度,可细化粒度)
  N2. 效果满意度(固定维度,可细化粒度)
  G.  调度者按主题细化粒度(可选)
      格式:
        ```
        ### 本次粒度细化
        - 范围: [全 session / 本批次 / 时间窗口]
        - 维度细化: [每维度内的子项,如"流程遵从度只看 brainstorming 转 design 路径"]
        ```

evidence depth 文件 scope 分流(第七轮 fix-6 — evaluator/对抗式 agent 双标处理):

  - 对抗式 agent(M6/M7) prompt 接收 `scope` 参数(meta / feature / mixed),按 scope 分流引相应 evidence depth 文件:
    · scope=feature → 引 `docs/references/testing-standard.md`(L1-L4 定义,现行)
    · scope=meta    → 引 `docs/governance/meta-finishing-rules.md` 内含的 evidence depth 节(meta-L1~meta-L4,§4.1.4)
    · scope=mixed   → 同时引两份(meta + feature 双套档位值,§4.1.4 mixed 8 行示例)
  - 调度者在 fork 挑战者前确定本次 scope,把对应 evidence depth 路径嵌入挑战者 prompt
  - M7 evaluator 改造时,prompt 内"测试充分性专项检查"段落改为按 scope 引相应文件(原硬编码 testing-standard.md → 改为 scope 分流引用)
  - M8/M9 不强加此约束(M8 凭证扫描不依赖 evidence depth;M9 process-audit 用 RUBRIC + handoff 评分,不直接读 evidence depth 标准)
  - mixed 改动场景:挑战者收到两套 evidence depth 标准,按 handoff 内"meta-L + L 各列出"判定证据完备性

agent 运行时:
  - 调度者在 fork 挑战者前,按模态填写 C 段(对抗式 / 混合式)或 G 段(事实统计式)
  - 嵌入到挑战者 prompt
  - 挑战者据嵌入内容工作

agent 文件静态约束(第七轮 fix-2 — 防下游污染):
  - M6 / M7 / M8 / M9 agent 文件的 prompt 段落**只放结构占位 + 引用 M2 路径**,
    禁止把 M2 实际治理文本(meta-review 流程描述 / scope 规则 / meta-scope.conf glob 等)
    抄进 agent prompt
  - 理由:agent 文件由 M14 setup.sh 分发到下游(下游也获得 design-review / evaluate /
    security-scan / process-audit agent),若 M2 实文嵌入 agent prompt,则下游 agent 文件
    自带 meta 治理语境,违反 §1.3 兼容性"下游项目不受 meta 治理污染"
  - 实现方式:
    · agent prompt 静态嵌入"在 harness 自身仓库时,调度者按 §3.1.7 runtime 嵌入契约
      Read M2 / M1 必要节并嵌入挑战者 prompt"指引(只引路径不引内容)
    · agent prompt B 段(最低必选维度)只列维度名(如 "核心原则合规"),不展开
      M2 中关于何时强制的具体规则文本
    · meta 专属语义(如 "meta-review covers 字段失效规则"、"光谱 B+ hook 拦截逻辑")
      不出现在 agent 文件中,仅由调度者运行时从 M2 读取后嵌入
  - 落地于 §8.1 M6-M9 改造说明强约束(命名约束:"prompt 改造时只引 M2 路径,不抄 M2 实文")

错误:
  - 对抗式 / 混合式 A/B/C 任一段落缺失: agent prompt 结构违规,
    audit trail 的"定制理由留痕"字段空白即检出(§5.1 边界 B3)
  - 事实统计式 G 段未填:不报错(G 是可选);默认全 session 全维度
  - agent 文件 prompt 抄 M2 实文(违反第七轮 fix-2 约束):由 M2 改动属 scope=meta
    自然触发 meta-review,审查时 design-reviewer / evaluator agent 自身被审 — 通过
    自审检出"agent prompt 含 meta 治理实文" → needs-revision
```

---

#### 3.1.7 `meta 文件 runtime 嵌入` 契约(B5 — 调度者 vs `!` 注入)

**触发者**:调度者(在 harness 自身仓库工作时)

**触发条件**:`/design-review` / `/evaluate` / `/security-scan` / `/process-audit` 调用,且调度者识别本次改动 scope=meta(§3.1.1)

**契约**:

```text
不用 `!` 注入访问 meta-* 文件(B5 决策):
  理由:
  - `!` 注入在 SKILL.md 内运行 = 下游目标项目也会执行该 skill
  - meta-* 文件被 M14 setup.sh 过滤掉(命名前缀过滤,见 §3.1.8),
    下游不存在这些文件
  - `!`cat docs/governance/meta-*` 在下游执行时返回空,不会 error 但语义模糊
  - 调度者运行时读取 + 嵌入更清晰

实现方式:
  调度者识别 scope=meta 后,**手工** Read M2 / M1 必要节 + 嵌入挑战者 prompt
  这是 meta-review 流程的一部分(§3.1.4 Step 1),
  不依赖 SKILL.md 的 `!` 注入机制

  第七轮 fix-2 配套约束:
  - agent 文件(M6-M9)本身的静态 prompt **只放结构占位 + 引用 M2 路径**,
    不抄 M2 实文(详见 §3.1.6 agent 文件静态约束节)
  - meta 治理实文仅由调度者在 fork 时运行时嵌入,与 agent 文件分离
  - 这样 setup.sh 把 agent 文件分发到下游时,下游 agent 文件不含 meta 语境

向后兼容性:
  - 现有 4 个 skill 的 `!` 注入(RUBRIC / ARCHITECTURE / 设计文档)保留不变
  - 仅新增 M2 pattern 节内容由调度者运行时嵌入,不在 SKILL.md 内 `!` 注入
  - 下游项目使用 `/design-review` 时,行为完全不变(无 meta 文件干扰)

错误处理:
  - 调度者忘读 M2 → audit trail 中 `dimensions.recommended_enabled` 为空 →
    下次 meta 改动时由 M15 Stop hook 检出 audit 内容缺失
  - 调度者不在 harness 仓库(误以为是):识别 scope=feature,自然不触发本契约
```

---

#### 3.1.8 `setup.sh 分发隔离` 契约(M14)

**触发者**:用户在 harness 仓库执行 `./setup.sh /path/to/target`

**触发条件**:用户运行安装

**契约**:

```text
分发规则(B3 决策 — 命名前缀过滤):
  排除清单(不分发到下游):
  - `docs/governance/meta-*.md`(M1 meta-finishing-rules + M2 meta-review-rules)
  - `.claude/hooks/meta-*.sh`(M15 check-meta-review.sh + M16 check-meta-commit.sh)
  - `.claude/hooks/meta-scope.conf`(M17)
  - `/CLAUDE.md`(M3 — harness 自治理入口,只在 harness 仓库根)

  分发清单(下游需要的):
  - `harness/CLAUDE.md`(M4 — 下游模板,不含 meta 段落)
  - 其他现有 governance / skills / agents / hooks(原样)

实现方式(setup.sh 改造):
  现状(setup.sh:86):`cp $SCRIPT_DIR/docs/governance/*.md $TARGET_DIR/docs/governance/`
  改造:替换 `*.md` 通配符为白名单 / 反向排除:
    cd $SCRIPT_DIR/docs/governance
    for f in *.md; do
      case "$f" in
        meta-*) continue ;;  # 排除 meta-*
        *) cp "$f" $TARGET_DIR/docs/governance/ ;;
      esac
    done

  现状(setup.sh:69):`cp $SCRIPT_DIR/.claude/hooks/*.sh $TARGET_DIR/.claude/hooks/`
  改造同上,排除 meta-*.sh 和 meta-scope.conf

  现状(setup.sh:71):`cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"`
  改造(D19 a 方案,第四轮新增 — 改 source 指向 M19 模板):
    改为:`cp "$SCRIPT_DIR/templates/settings.json" "$TARGET_DIR/.claude/"`
    理由:
      - harness 自身 `.claude/settings.json`(M18)含 M15 在 Stop hook 数组的注册条目
      - 直接拷贝会让下游 settings.json 也含 meta hook 注册,产生软污染
      - M19 `harness/templates/settings.json`(新建)结构同 M18 但移除 meta hook 注册段
      - 改 line 71 source 后,下游获得无 meta hook 注册的 settings.json,零污染
      - 与 fix-4 D19 a 方案配套:下游一个 meta-* hook 文件(命名前缀过滤)+ 一条 meta hook 注册(改 source)都看不到

  现状(setup.sh:96):`cp $SCRIPT_DIR/CLAUDE.md $TARGET_DIR/`
  改造:**无需改 — 现状已合规**(此处仅讨论 CLAUDE.md;line 71 settings.json 改造见上)。
    路径事实(经 Read 验证):
      - setup.sh 实际位于 `harness/setup.sh`,即 `$SCRIPT_DIR = <repo-root>/harness/`
      - setup.sh:96 现状 `cp "$SCRIPT_DIR/CLAUDE.md"` 实指 `harness/CLAUDE.md`(= **M4 分发模板**,不是 M3)
      - M3(harness 仓库根 `/CLAUDE.md`)实际路径是 `$SCRIPT_DIR/../CLAUDE.md`(`<repo-root>/CLAUDE.md`)
      - 因此 setup.sh 现状 cp 的就是 M4 模板,**已不分发 M3**(因 cp 命令源就指向 M4)
    结论:此行 CLAUDE.md 不需改动,M3/M4 路径区分天然由 $SCRIPT_DIR 落点保证;不要混淆第四轮的 CLAUDE.md 路径修补(fix-CLAUDE)与 settings.json 双轨修补(fix-settings,= D19 a 方案),两件事在本节都涉及但相互独立(注:第七轮另起 fix-1~fix-9 编号体系,与第四轮编号无关 — 本节"fix"专指第四轮路径/settings 修补)

输出:
  - 目标项目获得 feature 层完整治理 + skill / agent / hook
  - 目标项目不被 meta 治理污染
  - 安装完成消息

错误处理:
  - 通配符 `*` 未匹配到文件(目录为空):cp 报错 → 已有 `2>/dev/null || true` 忽略
  - 排除规则误伤 feature 文件(误以为是 meta-):由命名规范保证 — 本 spec 锁定
    所有 meta 文件以 `meta-` 开头,feature 文件不能以 `meta-` 开头
```

---

#### 3.1.9 `hook 执法` 契约(M15 / M16 + M17)

**触发者**:
- (a) Claude Code Stop hook 自动触发(M15)— 来自 `.claude/settings.json` 的 Stop 数组
- (b) Git pre-commit hook 自动触发(M16)— 来自 `.git/hooks/pre-commit` 软链接

**触发条件**:每次 Stop / 每次 git commit。**无门槛,每次都检测**(A1 决策)

**契约**:

```text
M15 check-meta-review.sh(Stop hook):

  输入(从 stdin / git):
    - JSON: { "stop_hook_active": bool, ... } (Claude Code 协议)
    - git diff(unstaged + staged)文件列表

  防死循环(参考 check-handoff.sh 现有模式):
    if stop_hook_active == true: exit 0

  **D19 a 方案(第四轮)— 不在 hook 内加 marker / 条件 exit 0**:
    a 方案下,下游根本无此 hook 文件(D12 命名前缀过滤)+ 无此 hook 注册(M14 setup.sh
    line 71 改 source 指向 M19 不含 meta hook 注册的模板),hook 不会在下游被触发,
    无需自防 marker 检查。详见 §7 D19 + §8.1 D19 a 方案落地总结。
    (如未来出于其他原因需识别 harness 仓库,可基于 grep `^# AI Dev Harness` 头部 marker,
    但 a 方案不要求此防御)

  逻辑:
    1. 读 M17 .claude/hooks/meta-scope.conf,得 glob 列表
    2. 扫 git diff 文件,过滤命中 scope 内 glob 的文件集 changed_meta_files
    3. 按 M17 排除规则过滤:**只排除流程产出物**(`docs/audits/meta-review-*.md` /
       `docs/audits/archive/`),**不排除治理文件**(`meta-*.sh` / `meta-*.md` /
       `meta-scope.conf`)— **第八轮 fix-9 (v) 修**:治理文件入 scope 走 meta-review,
       bootstrap 循环可接受(类似编译器自举,详见 §1.3 + §3.1.1)
    4. 若 changed_meta_files 为空: exit 0
    5. 若非空:
       a. 扫 docs/audits/meta-review-*.md 的 YAML frontmatter `covers:` 字段并集,
          得 covered_files (A3 决策);
          **第八轮 fix-9 (iii) 修 — covered_files 是 audit covers 字段中实际列出的
          文件路径**(不是"audit 存在 + 主题相关"即视为覆盖)。即:
          covered_files = ⋃ {audit.yaml_frontmatter.covers : audit ∈ 有效 audit 集}
          且按 A4 决策检失效:
          对每个 audit,比较 audit 文件 mtime vs 每个 covers 文件最新 commit time;
          若 covers 文件有新 commit(在 audit 文件 mtime 之后) → 该文件对此 audit 失效
       b. **第八轮 fix-9 (iii) 修** — uncovered = changed_meta_files - covered_files(失效后)
          即:若 changed_meta_files 中有文件**不在任何有效 audit 的 covers 字段中** → uncovered
          (这一步是 (iii) 修的核心:filling covers 错误 / 漏列改动文件 / 列错路径
          均会被识别为未覆盖,触发引导,而非"audit 存在即放行")
       c. 若 uncovered 为空: exit 0(已有有效 audit 覆盖,且 covers 字段实际包含所有改动文件)
       d. 若 uncovered 非空:
          扫 docs/active/handoff.md 是否有 `## meta-review: skipped(理由: ...)`
          且理由非空(可 grep 检 `理由:\s*[^)]+`)
          - 有 → exit 0(已声明跳过)
          - 无 → echo 引导消息到 stderr 并 exit 2:
            "检测到 meta scope 改动但无对应 audit 或跳过理由。
             改动文件: <列表>
             未被任何 audit covers 覆盖的文件: <uncovered 列表>
             请触发 /design-review meta-mode 或在 handoff.md 写
             '## meta-review: skipped(理由: <非空理由>)'"

  输出:
    - exit 0(放行) / exit 2(阻断 stop)
    - 阻断时 stderr 引导消息

M16 check-meta-commit.sh(git pre-commit hook):

  输入(git):
    - git diff --cached 文件列表(staged)

  逻辑(同 M15,但不需 stop_hook_active 判断):
    1-5. 同上,但用 git diff --cached(staged)代替 git diff
    检 audit covers + handoff skip 理由
    无 → exit 1(git pre-commit 协议;非 0 即阻断 commit)
       并 stderr 输出引导消息

  输出:
    - exit 0(放行 commit) / exit 1(阻断 git commit)

输入数据规范:
  - YAML frontmatter `covers:` 字段格式(A3 决策):
    ```
    ---
    meta-review: true
    covers:
      - docs/governance/design-rules.md
      - .claude/hooks/some-hook.sh
    ---
    ```
  - hook 解析:用 awk/sed 在 frontmatter 块(`---` 之间)内提取 `covers:` 数组
    实现细节由 implementation 阶段定;spec 仅定义数据契约

错误处理:
  - M17 配置缺失 → echo "⚠️ meta-scope.conf 不可读" + exit 0(降级软提醒)
  - audit YAML 解析失败 → echo "⚠️ audit YAML 损坏: <文件>" + exit 0
  - git diff 调用失败(非 git 仓库) → exit 0
  - jq / awk / sed 缺失 → echo "⚠️ jq 缺失,hook 降级跳过" + exit 0
    (依现有 check-handoff.sh 范式)

下游分发:
  - M14 setup.sh 不分发 M15 / M16 / M17,下游不受 meta 治理污染
  - 下游 .claude/settings.json(M14 拷贝的)不含 M15 注册行
  - M16 是 git hook,本来就不通过 setup.sh 分发(git hook 是仓库本地)
```

---

#### 3.1.10 `SessionStart hook 反审检测` 契约(M20:扩展现有 session-init.sh)

> **第八轮 fix-8 用户拍板** — 反审本 spec 触发 = 方案 A + 方案 C 组合。本节定义 A 部分(SessionStart hook 主动推);C 部分(handoff 反审待办字段)在 §4.1.7 定义。详见 `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`。

**触发者**:Claude Code SessionStart hook 自动触发(每次 session 启动)

**触发条件**:每次 SessionStart 触发时,检测以下两个**条件同时成立**:

1. `git log` 主分支历史中存在 P0.9.1 落地 commit(commit message 主题含 "P0.9.1 self-governance" 或类似实施完成标识 — 如 "feat(P0.9.1)" / "P0.9.1 落地" / "P0.9.1 implementation")
2. `docs/audits/` 中**不存在** covers 字段含本 spec 路径(`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`)的 audit

**契约**:

```text
M20 session-init.sh 反审检测段(扩展现有 session-init.sh):

  输入(从 git + 文件系统):
    - git log --format="%s" main(主分支 commit message 列表)
    - docs/audits/meta-review-*.md 文件列表 + 各 YAML frontmatter `covers:` 字段
    - 本 spec 路径常量:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`

  逻辑:
    1. 检测条件 1:grep "P0.9.1.*self-governance\|P0.9.1.*实施\|P0.9.1.*落地\|P0\.9\.1.*implementation"
       于 git log main 主题输出
       - 无命中: 不注入(P0.9.1 尚未落地,反审尚不触发) → 跳到下一段(handoff 注入等)
       - 有命中: 进入条件 2
    2. 检测条件 2:扫 docs/audits/meta-review-*.md(及 archive/INDEX.md 缓存的 covers)
       的 YAML `covers:` 字段并集,grep 本 spec 路径
       - 命中(已有 audit 反审): 不注入(反审已完成) → 跳到下一段
       - 未命中: 进入注入

  注入消息(system-reminder):
    "P0.9.1 已落地但未反审本 spec(`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`)。
     建议用 M2 pattern 节走 meta-review 流程审 spec(参 §6.4 bootstrap 自洽验证)。
     反审完成后会自动停止此提醒(audit covers 含本 spec 路径)。"

  行为:
    - **不阻断**:仅注入 system-reminder,用户可选择忽略
    - **可被覆盖**:与现有 session-init.sh 注入(PROGRESS / handoff)并列,不互相覆盖

输入数据规范:
  - git log 主题匹配规则用 grep -E(POSIX 扩展正则);具体关键词 pattern 由实施时定
    (建议:同时匹配中英文 — "P0.9.1.*落地|P0.9.1.*实施|P0\.9\.1.*self-governance|P0\.9\.1.*implementation")
  - audit covers 解析复用 §3.1.9 M15/M16 的 YAML 解析逻辑(awk/sed 提取 frontmatter)

错误处理:
  - git log 调用失败(非 git 仓库) → 跳过本段,exit 0(不阻断 SessionStart 其他段)
  - audit YAML 解析失败 → 视该 audit 不存在(不参与 covers 并集),继续判定
  - 关键词 pattern 误判(如 commit message 写"撤回 P0.9.1 实施") → 容忍假阳性
    (用户可见提醒后判断,无业务损失)

下游分发:
  - 反审检测段是 harness 自身需要的 — 仅 harness 仓库的 session-init.sh 含此段
  - **下游 session-init.sh 不含此段**(M14 setup.sh 在拷贝 session-init.sh 时,
    需要把反审检测段排除在分发版本外;实施阶段定具体方式 — 候选:用 marker 标记
    `# === harness self-governance ===` 包裹此段,setup.sh sed 删除 marker 段;
    或拆分为两文件 session-init.sh + meta-self-review-detect.sh,后者不分发)
  - **配合 D19 a 方案**(零污染):下游 session-init.sh 完全不含反审检测,与下游
    无 meta-* 文件 + 无 meta hook 注册一致

实施位置:
  - 文件:`.claude/hooks/session-init.sh`(已存在,本节是扩展)
  - 注册:已注册于 `.claude/settings.json` SessionStart 数组,无需新增注册行
  - 分发隔离方式:实施阶段定(参 D19 a 方案命名/标记策略)
```

---

### 3.2 外部接口

**不适用** —— 本功能不涉及 API 接口(非运行时应用)。分发侧 `setup.sh` 拷贝文件到下游是文件操作,不是 API 调用;hook 调用 git / awk 是本地系统调用,不是网络 API。

### 3.3 前后端类型契约

**不适用 — 本功能不涉及 API 接口**。

---

**第 3 节自检**:

- [x] 每个接口的双方都定义了:§3.1.1 到 §3.1.10 每个契约都有触发方 → 被调用方;3.1.7 调度者 vs `!` 注入明示;3.1.8 setup.sh → 下游路径明示;3.1.9 hook → git/audit/conf 三方明示;3.1.10 SessionStart hook → git log/audit covers/system-reminder 三方明示(第八轮 fix-8 A 部分)
- [x] 参数类型和返回类型在数据模型中定义:audit_trail YAML frontmatter / scope.conf glob / handoff skip 字段 / handoff 反审待办字段(§4.1.7,fix-8 C 部分)在 §4.1 定义
- [x] 每个接口都有错误处理约定:每个契约均末尾列出错误处理分支,且按现有 hook 范式(check-handoff.sh)降级
- [x] 接口的入参和出参与需求摘要中的数据对得上:§1.2 场景 1-3 + §1.3 scope 边界对应 §3.1.1-3.1.6;§1.5 第二轮 Q1 拍板对应 §3.1.9 hook 执法;§1.5 兼容性要求对应 §3.1.8 分发隔离;§6.4 bootstrap 自洽验证对应 §3.1.10 反审触发(fix-8)
- [x] 接口是否简洁:10 个契约对应 3 个核心场景 + 执法层 + 分发层 + 嵌入约束 + 反审触发,粒度合理(每个契约职责清晰不重叠)
- [x] 字段命名统一:audit_trail / covers / scope.conf / meta-* / 反审待办字段在 §3 / §4 用同一名称
- [ ] 前后端共享类型: **不适用**(无 API)
- [ ] 共享类型命名统一: **不适用**(无 API)

---

## 4. 数据模型

> harness 无数据库或运行时数据流,"数据模型"在此定义为:
> (a) **文档结构**:audit trail 的 YAML frontmatter + markdown 字段
> (b) **配置数据结构**:M17 scope.conf 格式
> (c) **handoff 字段格式**:meta-review skip / Evidence Depth 双标
> (d) **agent prompt 结构片段**:A/B/C 三段的 markdown 形状

### 4.1 数据实体

#### 4.1.1 实体 `audit_trail`

**位置**:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md`(B8 决策:加 HHMMSS,避免单日同主题冲突)

**归档策略**(B9 决策):
- 默认存放 `docs/audits/`
- **每 6 月迁移**(基于文件 mtime 阈值)到 `docs/audits/archive/YYYY-HN/`(YYYY=年,HN=H1/H2 半年)
- 主目录保留近 6 月 audit + `archive/` 索引文件 `archive/INDEX.md`(列出归档文件路径)
- M15 / M16 hook 扫 audit covers 时,**只扫主目录 + archive/INDEX.md 中列出的近 12 个月**;archive 旧条目不参与失效计算(因为 covers 失效规则按 commit time 判,过老 audit 的 covers 几乎肯定都已失效)
- 归档操作不在 P0.9.1 实施(P0.9.1 仅声明策略),首次归档触发由后续 audit 数量到阈值时执行

**INDEX.md schema 定义**(第七轮 fix-3 — 补漏):

格式:markdown 文件,顶部一段说明 + 一张归档表(每行 1 条 audit)。

```markdown
# meta-review audit 归档索引

> 由半年归档触发自动维护。M15 / M16 hook 扫 audit covers 时读取近 12 个月条目。

| audit 文件 | 归档日期 | 主题 | covers(缓存,逗号分隔) |
|---|---|---|---|
| archive/2026-H1/meta-review-2026-04-25-143022-M0-block-dangerous.md | 2026-07-01 | M0 删除 block-dangerous | docs/governance/finishing-rules.md, .claude/hooks/block-dangerous.sh |
| archive/2026-H1/meta-review-2026-05-12-091533-M2-pattern-update.md | 2026-07-01 | M2 pattern 节扩 | docs/governance/meta-review-rules.md |
```

字段定义:

| 字段 | 类型 | 必填 | 含义 |
|---|---|---|---|
| audit 文件 | 仓库相对路径 string | ✅ | 归档后的 audit 文件路径(相对仓库根) |
| 归档日期 | "YYYY-MM-DD" | ✅ | 本次归档批量操作日期(同批 audit 共享同一日期) |
| 主题 | string | ✅ | 与 audit 文件名内"主题"段一致 |
| covers(缓存) | 仓库相对路径数组,逗号分隔 string | ✅ | 从 audit YAML frontmatter `covers:` 字段直接拷贝(缓存避免归档后 hook 重新解析每个 audit YAML) |

生成机制:

- **触发**:首次归档时(audit 主目录半年 mtime 阈值触发)由实施层脚本生成;后续每次归档追加新条目
- **覆盖**:覆盖性写(每次归档生成完整 INDEX,不增量),避免历史条目和当前归档不同步
- **依据**:每条 INDEX 条目的来源是单个 audit 的 YAML frontmatter `covers:` 字段(§4.1.1 yaml_frontmatter.covers)
- **hook 读取**:M15 / M16 按 `archive/INDEX.md` 表格行解析(awk/sed 提取第 1 / 4 列),得到"audit 文件 + covers 文件"二元组,与主目录 audit 合并参与覆盖判定
- **不在 P0.9.1 实施**(P0.9.1 仅声明 schema);首次半年归档触发时由实施层脚本按本 schema 生成

错误处理:

- INDEX.md 缺失(尚未触发首次归档)→ hook 仅扫主目录,跳过 archive(exit 0 不阻断)
- INDEX.md 格式损坏(表格列数不对)→ hook 输出 stderr "⚠️ archive INDEX 损坏" + exit 0(降级,沿用现有 hook 范式)
- INDEX 中 audit 文件实际不存在(归档表与文件系统不一致)→ 跳过该条目,继续处理其他

**格式**:markdown 文件,固定结构(YAML frontmatter + 5 节正文)。下面用 TypeScript 伪类型表达字段语义,实际存储为 markdown:

```typescript
interface AuditTrail {
  // 0. YAML frontmatter(A3 决策)— 供 hook 读
  yaml_frontmatter: {
    "meta-review": true;     // 标识本文件是 meta-review audit
    covers: string[];        // 本 audit 覆盖的 scope 内文件路径(仓库相对)
                             // 例:["docs/governance/design-rules.md", ".claude/hooks/some-hook.sh"]
                             // 必填,非空数组(空则等价于未走流程)
  };

  // 1. 元信息头(markdown 正文)
  meta: {
    date: string;              // "YYYY-MM-DD"
    timestamp: string;         // "HH:MM:SS"(B8 — 文件名内含,正文亦记)
    theme: string;             // 主题(填入文件名)
    triggered_by: "调度者" | "用户" | "M15-stop-hook" | "M16-precommit-hook";
    scope_label: "meta" | "mixed";
    changed_files: string[];   // 本次改动文件路径(应是 covers 的子集或等同)
    related_decision?: string;
    related_spec?: string;
    agent_modes_used: ("adversarial" | "hybrid" | "fact-statistical")[];
                             // 本次用了哪些 agent 模态
  };

  // 2. 维度选取(按 agent 模态分,B2 决策)
  dimensions: {
    adversarial?: {            // 对抗式 agent 维度(M6/M7),A/B/C 三段
      recommended_enabled: DimensionSpec[];
      recommended_disabled: { dim: DimensionSpec; reason: string }[];
                              // reason 必填(可 grep 检空)
      minimum_required: DimensionSpec[];   // bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)
      customized_added: { dim: DimensionSpec; reason: string }[];
                              // reason 必填
    };
    hybrid?: {                 // 混合式 agent 维度(M8 security-reviewer)
      hardcoded_patterns: string[];  // 凭证 / 危险 / 注入 pattern 列表(不变)
      adversarial_part: {            // 对抗维度部分用 A/B/C
        recommended_enabled: DimensionSpec[];
        recommended_disabled: { dim: DimensionSpec; reason: string }[];
        minimum_required: DimensionSpec[];
        customized_added: { dim: DimensionSpec; reason: string }[];
      };
    };
    fact_statistical?: {       // 事实统计式 agent 维度(M9 process-auditor)
      fixed_dims: ["流程遵从度", "效果满意度"];  // 固定 N 维分工
      granularity_customization?: {
        scope: "全 session" | "本批次" | string;  // 细化范围
        per_dim_focus: { [dim: string]: string };  // 每维度的细化焦点
      };
    };
  };

  // 3. 挑战者执行记录
  execution: {
    challenger_count: number;
    fork_mode: "parallel" | "degraded-single-context";
    degraded_reason?: string;
    per_challenger: {
      dim: string;
      mode: "adversarial" | "hybrid" | "fact-statistical";
      status: "completed" | "failed" | "partial";
      findings_count: { critical: number; major: number; minor: number };
    }[];
  };

  // 4. 综合结果
  synthesis: {
    consensus: Finding[];
    divergence: { finding_a: Finding; finding_b: Finding; arbitration?: string }[];
    blindspots: string[];
  };

  // 5. 判定 + 用户决策
  verdict: {
    result: "pass" | "needs-revision" | "overturn" | "abandoned";
    user_decision?: string;
    followup_items: string[];
  };
}

interface DimensionSpec {
  name: string;
  focus: string;
  default_enabled: boolean;
  source: "M2-recommended" | "M2-minimum" | "customized";  // 引用 M2 的 pattern 节
}

interface Finding {
  location: string;
  issue: string;
  evidence: string;
  impact: string;
  severity: "critical" | "major" | "minor";
  discovered_by: string[];
}
```

**markdown 存储示例**(简化):

```markdown
---
meta-review: true
covers:
  - docs/governance/design-rules.md
  - .claude/hooks/some-hook.sh
---

# meta-review audit — [主题]

## 1. 元信息
- 日期:2026-04-25
- 时间:14:30:22
- 主题:M0 删除 block-dangerous
- 触发者:调度者
- scope 标签:meta
- 改动文件:.claude/hooks/block-dangerous.sh, .claude/settings.json
- agent 模态:[adversarial, hybrid]
- 关联 decision:(TBD)

## 2. 维度选取
### Adversarial(M6 design-reviewer)
#### 启用的推荐维度
- 副作用:block-dangerous 删除后其他路径是否被依赖
- 核心原则合规:删除是否违反"宁可误报也不漏报"

#### 禁用的推荐维度(+ 理由)
- (无)

#### 最低必选维度(bootstrap 4 维)
- 核心原则合规
- 目的达成度
- 副作用
- scope 漂移

#### 定制维度(+ 理由)
- 历史上游信号
  理由:M0 删除是 retrospective 驱动,需要确认不是误解

### Hybrid(M8 security-reviewer)
#### 硬编码 pattern(不变)
- 凭证泄露 / 危险操作 / 注入混淆

#### 对抗维度部分
##### 启用的推荐维度
- 凭证泄露场景判定

##### 最低必选维度
- 凭证泄露场景判定(M8 永远不可绕)

## 3. 挑战者执行记录
- 挑战者数:5(adversarial 4 + hybrid 1)
- 模式:parallel
- 降级:否
...

## 4. 综合
### 共识
### 分歧
### 盲区

## 5. 判定
- 结果:pass
- 用户决定:采纳
- 带入 planning:(无)
```

---

#### 4.1.2 实体 `meta_scope_config`(M17 .claude/hooks/meta-scope.conf)

**位置**:`.claude/hooks/meta-scope.conf`

**格式**:每行一条 glob 规则,`#` 开头为注释,`!` 开头为排除。**A2 决策**:hook 读此文件,scope 扩展不改 hook 代码。

```
# meta-scope.conf - hook 读取的 scope 配置
# 每行一条 glob 规则,! 前缀为排除
# 由 M15 check-meta-review.sh 和 M16 check-meta-commit.sh 读

# === A 组:governance + 核心规则 ===
docs/governance/*.md
CLAUDE.md

# === B 组:.claude/hooks/* + settings ===
.claude/hooks/*.sh
.claude/settings.json
.claude/settings.local.json

# === C 组:skills + agents ===
.claude/skills/*/SKILL.md
.claude/agents/*.md

# === D 组:RUBRIC + DESIGN_TEMPLATE ===
docs/RUBRIC.md
docs/references/DESIGN_TEMPLATE.md

# === F 组:setup.sh + 分发模板 ===
setup.sh
harness/CLAUDE.md
harness/templates/*.json

# === 排除规则(第八轮 fix-9 (v) 修)===
# 只排除流程产出物(audit 文件本身,避免自循环 — audit 改动也要 audit 无穷递归)
# 不排除治理文件(meta-*.sh / meta-*.md / meta-scope.conf)— 治理文件入 scope,
# 改它们走 meta-review,bootstrap 循环可接受(类似编译器自举)
!docs/audits/meta-review-*.md
!docs/audits/archive/**

# === E + G 组(scope 外,显式声明)===
# E: 不需列(不命中 scope 内 glob 即等同 scope 外)
# G: 不需列
```

**TypeScript 伪类型**(语义层):

```typescript
interface MetaScopeConfig {
  include_globs: string[];  // 命中即 scope=meta(或 mixed) — 含治理文件 meta-*
  exclude_globs: string[];  // ! 前缀,**仅排除流程产出物**(audit 自身,避免自循环)
                            // 第八轮 fix-9 (v) 修:不排除治理文件
  // 解析规则:
  // for f in changed_files:
  //   if any(match(f, g) for g in exclude_globs): skip(f)
  //   elif any(match(f, g) for g in include_globs): mark f as scope-internal
  //   else: scope-external(scope=feature/none)
}
```

**第八轮 fix-9 (v) 修 — 排除规则改造说明**:
- **修改前**(原)`!meta-*` 排除把"治理文件"和"流程产出物"混为一类 → 改 scope.conf 自身 / 改 meta-review-rules.md 不触发 hook(self-reference 漏洞)
- **修改后**(本次)**只排除流程产出物**(`!docs/audits/meta-review-*.md` + `!docs/audits/archive/**`)— 改 audit 不触发审 audit(避免无穷递归);**治理文件入 scope** — 改 scope.conf / meta-*.sh / meta-*.md 走 meta-review
- **bootstrap 循环可接受**:改 meta-review-rules.md 会触发 meta-review 用旧规则审新规则,类似编译器自举。已在 §1.3 边界声明此可接受性

**兼容性 / 扩展性**(对应 §1.3 兼容性要求):
- 下游不分发此文件(M14 setup.sh 排除)
- harness 自身扩 scope 时只编辑此文件,不改 M15 / M16 hook 代码
- 文件不可读时 hook 降级 exit 0(见 §3.1.9 错误处理)

---

#### 4.1.3 实体 `handoff_meta_review_skip`(M1 引导写 handoff)

**位置**:`docs/active/handoff.md` 内字段

**格式**(A5 决策 — 理由必填,可 grep 检空 reason):

```markdown
## meta-review: skipped(理由: <非空理由>)
```

**字段语义**:

```typescript
interface HandoffMetaReviewSkip {
  marker: "## meta-review: skipped";
  reason: string;              // 必填,非空
  // 写入时机:
  // §3.1.3 Step A 决定不走 meta-review 时,M1 引导调度者写入 handoff
  // 写入示例:
  //   "## meta-review: skipped(理由: 仅修改 typo 注释,无语义变更)"
}
```

**hook 读取规则**(M15 / M16):
- grep handoff `## meta-review: skipped\(理由: ([^)]+)\)`
- reason 部分非空(`\S` 至少一个非空白字符)→ skip 有效,exit 0
- reason 为空(`## meta-review: skipped(理由: )`)→ skip 无效,继续要求 audit

**清理时机**:
- 每次新 meta 改动开始时,调度者覆盖此字段(不累积旧 skip 记录)
- 字段不归档(handoff 本来就 mutable)

---

#### 4.1.4 实体 `meta_evidence_depth`(并入 M1 内含定义节)

**位置**:`docs/governance/meta-finishing-rules.md` 的"## meta evidence depth 定义"节(B1 决策合并)

**重定义**(feature 的 L1-L4 对 meta 不适用):

```typescript
interface MetaEvidenceDepth {
  metaL1_node_selfcheck: {
    meaning: "design 阶段每节末尾的自检清单全通过";
    evidence_form: "设计文档中 [x] 勾选";
    coverage: "改动前置自洽";
  };
  metaL2_global_selfcheck: {
    meaning: "designer 返回草稿后独立自检挑战者全局检查";
    evidence_form: "design-rules.md 定义的 10 项全局自洽检查结果";
    coverage: "草稿内部一致";
  };
  metaL3_meta_review: {
    meaning: "对抗式 / 混合式 / 事实统计式 meta-review(§3.1.4)";
    evidence_form: "audit trail YAML covers 列出 + verdict=pass";
    coverage: "多视角对抗 / 模式 / 统计验证";
  };
  metaL4_real_use_verification: {
    meaning: "实际使用场景验证 — 下一个 meta 改动或 feature 使用时该规则是否发挥作用";
    evidence_form: "后续 meta 改动 audit trail 是否引用本规则";
    coverage: "落地有效性(需要时间)";
  };
}
```

**handoff 字段格式**(B7 决策 — 选 (a) 同字段不同档位值,hook 不改):

```typescript
interface EvidenceDepthHandoff {
  // 现有 hook (check-evidence-depth.sh) 字段名 `## Evidence Depth` 不变
  // 字段下档位值按改动类型选(meta-L 或 L)

  field_name: "## Evidence Depth";   // 字段名不变,hook 已检
  // 见下方各 scope 类型的具体 markdown 示例
}
```

**markdown 实例 — 三种 scope 各自填法**(第七轮 fix-4 — 补漏):

(1) scope=feature 改动(纯 feature,典型 4 行):

```markdown
## Evidence Depth
- L1: ✅ src/foo/bar.test.ts 单元测试通过
- L2: ✅ scripts/integration-test.sh 集成测试输出
- L3: ✅ scripts/api-smoke.sh 自动化 API 验证
- L4: ✅ docs/decisions/2026-04-25-foo-bar.md 真实场景验证记录
```

(2) scope=meta 改动(纯 meta,典型 4 行):

```markdown
## Evidence Depth
- meta-L1: ✅ 设计文档每节末尾 [x] 勾选(本 spec §2-§9 自检全勾选)
- meta-L2: ✅ design-rules 10 项全局自洽通过(详见 §9 自检)
- meta-L3: ✅ docs/audits/meta-review-2026-04-25-143022-M0.md verdict=pass
- meta-L4: ⏳ 待观察(下一次 meta 改动 audit 是否引用本规则)
```

(3) scope=mixed 改动(典型 8 行 — meta + feature 各 4 行,**第七轮 fix-4 必给示例**):

```markdown
## Evidence Depth
- meta-L1: ✅ docs/governance/meta-finishing-rules.md 节内自检勾选
- meta-L2: ✅ design-rules 10 项全局自洽通过
- meta-L3: ✅ docs/audits/meta-review-2026-05-12-091533-M2-pattern.md verdict=pass
- meta-L4: ⏳ 待观察(meta 部分 — P0.9.1.5 启动时反审)
- L1: ✅ scripts/feature-foo-unit.test.ts 单元测试通过
- L2: ✅ scripts/feature-foo-integration.sh 集成测试输出
- L3: ✅ scripts/feature-foo-smoke.sh 自动化 API 验证
- L4: ✅ docs/decisions/2026-05-12-feature-foo.md 真实场景验证
```

格式规则:
- 每行 `<档位标识>: <状态> <证据位置>` 三段
- meta 档位用 `meta-L1` ~ `meta-L4`,feature 用 `L1` ~ `L4`
- mixed 改动**两套并列**(8 行典型上限);可少不可漏 — 至少各 1 行才算填写
- `<状态>` 用 ✅(完成)/ ⏳(待观察)/ ❌(不通过 — 需补)/ ➖(不适用)
- `<证据位置>` 必须含具体路径或 audit 文件名,不能用"已完成"这类无指向词

hook 解析:check-evidence-depth.sh 仅检字段非空 + 非 `[待填]`,不解析档位值;mixed 8 行同样通过。

**B7 决策依据**:
- 选 (a) 同字段不同档位值:hook(check-evidence-depth.sh)只检字段名 `## Evidence Depth` 非空 + 非 `[待填]`,不解析档位值;新增 meta-L1~meta-L4 档位值不破坏现有 hook 行为
- 不选 (b) 不同字段名(`## Evidence Depth (Meta)`):需改 hook 检测字段名;增加 hook 复杂度,与"光谱 B+ 最小硬 hook"原则冲突
- mixed 改动场景:同字段内同时列 meta-L 和 L 档位值,hook 只要字段非空即通过

---

#### 4.1.5 实体 `audit_covers_validity`(audit 失效规则)

**位置**:运行时计算,M15 / M16 hook 内逻辑

**格式**(A4 决策):

```typescript
interface AuditCoverEntry {
  audit_file: string;          // audit 文件路径
  audit_mtime: number;         // audit 文件 mtime(unix epoch)
  covers: string[];            // YAML frontmatter 列出的文件
}

interface AuditCoverValidity {
  // 对每个 audit 的每个 covers 文件,判该文件对此 audit 是否失效:
  // failed_for_audit(audit, covered_file):
  //   covered_latest_commit_time = git log -1 --format=%ct -- covered_file
  //   if covered_latest_commit_time > audit.audit_mtime: return TRUE  // 失效
  //   else: return FALSE  // 仍有效
  //
  // 即:audit 产出后,如果 covers 中某文件有新 commit(git 历史时间 > audit 文件 mtime)
  //   → 该文件对此 audit 失效;hook 视该文件未被任何 audit 覆盖
}
```

**A4 决策依据**:
- 按 git log 比对 commit time(权威 git 历史),非时间窗口
- mtime 用 audit 文件本身(不用 ctime,避免 git checkout 改 ctime 误判)
- 单文件可能在多个 audit 的 covers 中:任一未失效的 audit 即覆盖,hook 视该文件已 cover

**实现细节**:
- M15 / M16 hook 用 `git log -1 --format=%ct -- <file>` 取最新 commit time
- audit 文件 mtime 用 `stat`(GNU 用 `stat -c %Y`,BSD 用 `stat -f %m`,与 check-handoff.sh 兼容)

---

#### 4.1.6 实体 `distribution_settings_template`(M19 `harness/templates/settings.json`)

**位置**:`harness/templates/settings.json`(新建,**第四轮 D19 a 方案**)

**格式**:JSON,结构同 harness 自身 `.claude/settings.json`(M18),但**移除 M15 在 Stop hook 数组的注册条目**(以及未来任何 meta hook 的注册条目)。

```typescript
interface DistributionSettingsTemplate {
  // 与 M18 .claude/settings.json 同结构(hooks 对象)
  // 但 Stop 数组只含 feature 层 hook,无 meta hook 注册
  // 例:Stop 数组保留 check-handoff.sh / check-finishing-skills.sh / check-evidence-depth.sh
  // 移除:M15 check-meta-review.sh 注册条目
  // 未来加 meta hook 时,只在 M18 加,不在 M19 加(双轨各自独立维护)
}
```

**JSON 示例**(M19 模板,删 meta hook 注册段):

```json
{
  "hooks": {
    "PostToolUse": [/* 同 M18 */],
    "PreToolUse": [/* 同 M18 */],
    "SessionStart": [/* 同 M18 */],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-handoff.sh" },
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-finishing-skills.sh" },
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-evidence-depth.sh" }
          /* 不含 M15 check-meta-review.sh — 这是 M18 vs M19 唯一差异 */
        ]
      }
    ]
  }
}
```

**D19 a 方案依据**(零污染优于软污染):
- 选 a:下游不接收 meta hook 注册(零污染);新增 1 文件 + 改 setup.sh 1 行,实施最简单
- 不选 b(分发 + hook 内 marker 条件 exit 0):下游 settings.json 仍含 meta hook 注册行,软污染;每 hook 都要写 marker 检查代码,认知与维护负担翻倍
- 不选 c(隐式空运行,读不到 scope.conf 自然 exit 0):同 b 的软污染;且依赖副作用(conf 缺失)而非显式机制,语义模糊

**与 D12 配合**:
- D12 命名前缀过滤 `meta-*` 已确保下游无 meta hook 文件 / 治理文件
- 但 settings.json 不以 `meta-` 命名,无法被 D12 过滤,所以 D19 a 需独立机制(双轨模板)
- 结果:下游一个 meta-* 文件 + 一条 meta hook 注册都看不到,完全实现 §1.3 兼容性"下游项目不受 meta 治理污染"

**双轨维护负担**:
- harness 自身扩 meta hook(P0.9.2/P0.9.3)时只需改 M18 `.claude/settings.json`,M19 不需更新(M19 永远不含 meta hook 注册段)
- harness 自身扩 feature hook(罕见)时需同步改 M18 + M19(两处),需在 §1.3 边界声明此维护点
- 实施层备注:可用 jq diff 自动校对 M18/M19 除 meta hook 段外结构一致(实施阶段定具体方式)

---

#### 4.1.7 实体 `handoff_self_review_pending`(C 部分 — 第八轮 fix-8 反审待办字段)

> **第八轮 fix-8 用户拍板** — 反审本 spec 触发 = 方案 A + 方案 C 组合。本节定义 C 部分(handoff 反审待办字段);A 部分(SessionStart hook)在 §3.1.10。详见 `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`。

**位置**:`docs/active/handoff.md` 内字段(与 §4.1.3 `handoff_meta_review_skip` 同文件,不同字段)

**格式**(初始值 + 完成后值):

```markdown
## 反审待办

P0.9.1 落地反审 — 未完成
```

完成后(P0.9.1 落地反审 audit 产出后)改为:

```markdown
## 反审待办

P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`
```

**TypeScript 伪类型**:

```typescript
interface HandoffSelfReviewPending {
  marker: "## 反审待办";
  status: "P0.9.1 落地反审 — 未完成" | "P0.9.1 落地反审 — 已完成 — audit:" + AuditFilePath;
  // 写入时机(初始):
  //   P0.9.1 落地的最后一次 finishing(commit 进 main 前)由 M1 meta-finishing-rules 引导调度者写入
  // 更新时机(完成):
  //   反审 audit 产出后,调度者(或 M1 finishing 流程)更新 status 为"已完成"+ audit 路径
  // 字段语义:
  //   被 §3.1.10 SessionStart hook 与 audit covers 检测互补 — hook 主动推 + 字段被动留痕
}
```

**写入引导规则**(M1 meta-finishing-rules):
- **触发**:P0.9.1 实施阶段最后一次 finishing(对应 P0.9.1 commit 进 main),M1 引导调度者在 handoff 加此字段(初始值"未完成")
- **更新**:反审走完(M2 pattern 节 + audit 产出 + verdict=pass)后,M1 引导更新字段为"已完成 — audit:<path>"

**hook 读取规则**(可选 — 与 §3.1.10 SessionStart hook 互补):
- §3.1.10 SessionStart hook 主要按 audit covers 判定(权威依据 — covers 含本 spec 路径即视为反审完成)
- 本字段是被动留痕辅助 — 调度者读 handoff 见此字段判断反审是否待办;不强制 hook 解析(避免双源冲突)
- 若未来扩展 hook 读此字段,需与 covers 检测保持优先级:**covers 是权威**,字段失同步以 covers 为准

**清理时机**:
- 反审完成后,字段保留(不清理)— 作为 P0.9.1 闭环留痕
- 若反审 audit 失效(P0.9.1 重大改动后需重新反审),字段重置为"未完成"+ 触发 SessionStart 提醒

**与 §4.1.3 `handoff_meta_review_skip` 区别**:
- §4.1.3 是"普通 meta 改动跳过 meta-review 的留痕"(短期,每次 meta 改动可覆盖)
- §4.1.7 是"P0.9.1 落地后反审本 spec 的待办留痕"(长期,直到反审完成)
- 两字段共存于 handoff,marker 不同(`## meta-review: skipped` vs `## 反审待办`),互不影响

---

### 4.2 数据流

```
调度者识别 scope (§3.1.1)
  │
  │ scope 标签: "meta" | "mixed"
  ▼
M5 finishing-rules 分流出口 (§3.1.2)
  │
  ▼
M1 meta-finishing-rules 引导四步 (§3.1.3)
  │
  ├─ Step A. 判 meta-review 必要 ──┐
  │                                 │ 走/不走
  │                                 │ 不走 → 写 handoff `## meta-review: skipped(理由)`
  │                                 ▼      ↓ 实体: handoff_meta_review_skip
  ├─ Step B. 触发 meta-review ─→ M2 + M10-M13 + M6-M9 (§3.1.4-§3.1.6)
  │                                 │
  │                                 │ 产 audit_trail 实体 (§4.1.1)
  │                                 │ 含 YAML frontmatter `covers:` (A3)
  │                                 ▼
  │                       docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md
  │                                 ↑ M15/M16 hook 扫
  │                                 │ + covers 失效检 (§4.1.5)
  │                                 │ + scope.conf glob 比对 (§4.1.2)
  │                                 │
  ├─ Step C. decision 立档 ───→ docs/decisions/YYYY-MM-DD-[主题].md
  │
  └─ Step D. ROADMAP/PROGRESS/memory 同步

执法层(并行,无门槛):
  M15 Stop hook ──读──→ git diff
                ──读──→ M17 scope.conf
                ──读──→ docs/audits/meta-review-*.md (YAML covers)
                ──读──→ docs/active/handoff.md (skip 字段)
                ──判定──→ exit 0/2

  M16 git pre-commit hook ──读──→ git diff --cached
                          (其余同 M15)
                          ──判定──→ exit 0/1
```

### 4.3 状态变更

| 实体 | 从状态 | 触发事件 | 到状态 | 副作用 |
|---|---|---|---|---|
| audit_trail | 不存在 | §3.1.4 Step 5 调度者写入 | 存在 + verdict=pass/needs-revision/overturn | 后续 hook 扫 covers 可检测 |
| audit_trail | verdict=needs-revision | 调度者修改后重审 | verdict=pass(或仍 needs-revision,二次迭代) | 连续 2 次 needs-revision → 用户介入 |
| audit_trail.cover_validity | 全有效 | covers 中某文件有新 commit | 该文件对此 audit 失效 | hook 视该文件未 cover,触发新 audit 要求 |
| audit_trail | 主目录 | 6 个月后 | 归档到 `docs/audits/archive/YYYY-HN/` | hook 仅扫主目录 + INDEX(B9 决策) |
| meta_scope_config | 不存在 | P0.9.1 实施 M17 | 存在 | M15/M16 hook 读取 |
| handoff_skip 字段 | 不存在 | 调度者跳过 meta-review 时 M1 引导写入 | 存在(理由必填) | hook grep 检 reason 非空 |
| decision(meta 型) | 不存在 | Step C 立档 | 🟢 已决定 | ROADMAP 引用 |
| decision(meta 型) | 🟢 已决定 | 被新 decision superseded | 🔴 已废弃 | superseding decision 标注关联 |

---

**第 4 节自检**:

- [x] 数据流中每一步的输入 / 输出类型与接口定义一致:§3 契约(尤其 §3.1.4 / §3.1.9)与 §4.2 流图对齐
- [x] 实体字段覆盖所有接口使用的数据:audit_trail 的 YAML covers + 5 段字段映射到 §3.1.4 / §3.1.9 的所有输出;scope.conf 字段映射 §3.1.1 / §3.1.9;handoff skip 字段映射 §3.1.3 Step A
- [x] 状态变更完整无死状态:audit_trail verdict 3 种终态;needs-revision 有连续 2 次上限;cover_validity 由 git commit time 单调推进无循环
- [x] 命名规范明确:audit 文件 `meta-review-YYYY-MM-DD-HHMMSS-[主题].md`(B8 加 HHMMSS),与 feature 侧 `audit-YYYY-MM-DD-HHMMSS.md` 前缀不冲突
- [x] 数据校验位置明确:YAML covers 由 hook 解析;非空 reason 由 hook grep 检;Evidence Depth 字段由现有 hook 检(B7 同字段不同档位值不破坏 hook)

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 编号 | 场景 | 输入条件 | 期望行为 |
|---|---|---|---|
| **B1** | scope 判错(将 meta 识别为 feature) | 调度者判 feature 跳过 M1 | **软+硬两层兜底**:(软)下次 meta 改动 §3.1.1 检最近 N 次 finishing 改动 vs audit covers,登记缺口;(硬)M15 Stop hook 在 session 末扫 git diff 命中 scope 但无 audit → 引导补 audit/补 skip 理由(光谱 B+) |
| **B2** | scope 判错(将 feature 识别为 meta) | 把 feature 文件判 meta | **容忍浪费**:meta 路径不破坏系统。调度者 §3.1.3 Step A 发现"改动文件无 scope 内命中"早期跳过 meta-review,保留 decision 立档作为额外审慎记录 |
| **B3** | 定制维度漏最低必选 | 调度者选维度漏 minimum_required(对抗式 / 混合式) | **三重检出**:(1) agent prompt 内 B 段静态嵌入(对抗式 / 混合式对抗维度部分);(2) 调度者 §3.1.4 Step 1 自检 C 段未禁 minimum;(3) audit trail 的 minimum_required 字段空白由 hook 后续检出 |
| **B4** | audit 产物缺失(应产未产) | meta 改动完成但无 `meta-review-*.md` | **硬拦**:M15 Stop hook 在 session 末检出 git diff 命中 scope 无 audit covers 且 handoff 无 skip 理由 → exit 2 阻断 stop;M16 git pre-commit hook 同样硬拦 commit。两扇门叠加(光谱 B+) |
| **B5** | meta-review fork 失败 | fork 返回错误 / 超时 / 空结果 | **降级执行**:调度者按 M2 定义的降级路径在单 context 分角色推演,audit trail 标 `fork_mode: "degraded-single-context"` + `degraded_reason`。不阻断 audit 产出,但 audit 内标 ⚠️ 独立性未达 |
| **B6** | 挑战者 prompt 超上下文 | 设计文档过大 / 引用过多 | 调度者拆分维度分多轮 fork,汇总时合并。M2 规定单 prompt 字节软上限(见 §7 决策 D5) |
| **B7** | 连续 N 次 meta-review 未通过(单项)| 同主题 needs-revision 连续 ≥ 2 次 | **停下让用户介入**(参考 design-rules 规则)。登记"反复未通过"到 audit trail,作 P0.9.2 数据点。**第七轮 fix-5 明示**:这是单项反复(单一 M 主题反复未通过)→ 走 B7 用户介入分支 |
| **B8** | decision 立档与现有 decision 冲突 | 新 decision 推翻早期 decision | 新 decision 标 "supersedes [旧 decision]";旧 decision 文件顶部标 "🔴 已废弃" |
| **B9** | ROADMAP/PROGRESS/memory 同步遗漏 | Step D 只更一处 | M1 meta-finishing-rules 以 checklist 列三处引导;不在本 spec 边界硬设 hook |
| **B10** | setup.sh 分发后下游未同步 | 下游用旧版 harness | 不在 P0.9.1 scope(下游升级机制是后续条目)。M14 只保证新安装项目拿到新文件 |
| **B11** | M2 pattern 节与 M6-M9 agent prompt 不同步 | M2 pattern 更新但 agent 未跟进 | **静态一致性**问题:M2 改动属 scope=meta(B 组),自然触发新 meta-review,审查维度含"影响传导"。不需额外检查 |
| **B12** | mixed scope 识别遗漏 | 改动涉及 A+B+C+D+F 和 E+G | §3.1.1 规定"任意一个 scope 内即触发 meta",mixed 按 meta 处理。漏识由 B1 兜底 |
| **B13** | M0-M4 首次 meta-review 不通过 — 多项命中相同流程缺陷 | M0-M4 是 P0.9.1 落地后**首个使用批次**(§1.3 不做什么),首次执行可能命中 P0.9.1 自身设计缺陷 | **接受 + 视情况修订**:不阻塞 M0-M4 推进;**第七轮 fix-5 明示分流**:不同于 B7(单项反复),B13 处理"多项命中相同的 P0.9.1 流程缺陷"(≥ 2 项不同 M 主题暴露同一缺陷)→ 触发 P0.9.1 修订评估,登记"修订需求"到 docs/decisions/,推入 P0.9.1.5 或 P0.9.2 阶段处理;**接受推进语义**:M0-M4 改动方向重审(M-by-M 评估方向是否需调整),但不延后批次启动(P0.9.1 闭环不延后,M-by-M 推进继续);**不允许追溯推翻 P0.9.1 实施**(避免闭环被破坏) |
| **B14** | hook 配置文件不可读 | M17 scope.conf 损坏 / 缺失 | M15 / M16 输出 stderr "⚠️ meta-scope.conf 不可读" + exit 0(降级软提醒,与 check-handoff.sh 现有降级范式一致) |
| **B15** | audit YAML frontmatter 损坏 | covers 字段缺失 / 无效 YAML | hook 输出 stderr "⚠️ audit YAML 损坏: <文件>" + exit 0;视该 audit 为不存在(不参与 covers 并集)|
| **B16** | git pre-commit hook 在非 git 环境运行 | 用户未初始化 git 或 .git 损坏 | M16 检测 `git diff --cached` 失败 → exit 0(无 commit 也就无需拦)|
| **B17** | covers 失效误伤 | covers 中文件有合理改动(如修 typo)但触发失效,要求新 audit | 这是**预期行为**。任何 scope 内文件改动都需 audit 或 skip 理由。若典型小修(typo)频繁触发 → 调度者用 handoff skip 字段(理由必填)记录"仅 typo 不走 meta-review",hook 通过。**不调整 hook 灵敏度,在使用层用 skip 处理** |
| **B18(第八轮 fix-9 — 已识别绕过路径推 P0.9.3 / 接受)** | 已识别但 P0.9.1 不防 / 部分修的绕过路径 | 4 条绕路:(i) `--no-verify` 绕 pre-commit / (ii) 长 session 不 stop 漏 Stop hook / (iv) 理由质量自律 grep 仅检非空 / (vi) 下游改 harness 副本不拦 | **分类处理**(详见 `docs/decisions/2026-04-26-bypass-paths-handling.md`):**(i) 推 P0.9.3**(`feedback_judgment_basis`:无实战数据不预防);**(ii) 接受 + 推 P0.9.3**(D17 光谱 B+ 最小集设计代价,不加第三 hook);**(iv) 接受**(治理层 M2/M9 负责理由质量,落地后 process-audit 反向审);**(vi) 接受**(§1.3 兼容性假设 + D19 a 方案"零污染",setup.sh 末尾打印提示);**(iii)(v) 已修**(分别在 §3.1.9 hook 逻辑 + §3.1.1 / §4.1.2 排除规则)。**落地后由 process-audit 反向追踪绕路实战数据 → 反馈 P0.9.3 防御层设计** |

### 5.2 错误传播路径

```
错误源
  │
  ├─→ 调度者自查(§3.1.1 scope 识别)
  │       ↓ 误判
  │   B1/B2/B12 ━━ M15 Stop hook 兜底(光谱 B+)━━━━━━━━━━━━━━━━┓
  │                                                              │
  ├─→ §3.1.3 Step A 判断 ━━ B2 早期兜底 ━━━━━━━━━━━━━━━━━━━━━━┫
  │                                                              │
  ├─→ §3.1.4 fork 环节 ━━ B5/B6 降级 / 拆分 ━━━━━━━━━━━━━━━━━━┫
  │                                                              │
  ├─→ §3.1.4 挑战者维度 ━━ B3 三重检出 ━━━━━━━━━━━━━━━━━━━━━━┫
  │                                                              │
  ├─→ §3.1.4 Step 5 audit 产出 ━━ B4 M15+M16 硬拦(光谱 B+)━━━━┫
  │                                                              │
  ├─→ §3.1.3 Step C decision 冲突 ━━ B8 superseding ━━━━━━━━━━━┫
  │                                                              │
  ├─→ 连续迭代 ━━ B7 用户介入 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
  │                                                              │
  ├─→ Step D 三处同步 ━━ B9 checklist 引导 ━━━━━━━━━━━━━━━━━━━┫
  │                                                              │
  ├─→ M0-M4 反复 needs-revision ━━ B13 P0.9.1 修订评估 ━━━━━━━━┫
  │                                                              │
  ├─→ M17/M18 hook 数据失效 ━━ B14/B15/B16 hook 降级 exit 0 ━━━┫
  │                                                              │
  └─→ Covers 失效误伤 ━━ B17 用 handoff skip 理由处理 ━━━━━━━━━┛
                                                                 │
                                                                 ▼
                              ┌──────────────────────────────────────┐
                              │ audit_trail YAML covers + handoff     │
                              │ skip 字段记录所有异常路径             │
                              │ + M15/M16 Stop+pre-commit 硬拦兜底    │
                              │ (光谱 B+ 闭环反馈)                    │
                              └──────────────────────────────────────┘
```

错误传播**不静默吞掉**:
- 调度者层面错误(B1-B3, B12)由 audit trail / handoff skip 字段留痕
- fork 失败(B5/B6)由 audit trail `fork_mode` + `degraded_reason` 字段留痕
- audit 缺失(B4)由 M15+M16 双 hook 硬拦,无声违规不再可能(光谱 B+)
- M0-M4 流程缺陷(B13)由 docs/decisions/ 修订需求记录,不破闭环
- hook 数据异常(B14/B15/B16)按现有 check-handoff.sh 降级范式处理

---

**第 5 节自检**:

- [x] 每个接口的错误情况都有对应的边界条件:§3.1.1 ↔ B1/B2/B12;§3.1.2 ↔ M1 缺失降级;§3.1.4 ↔ B3/B4/B5/B6;§3.1.3 ↔ B8/B9;§3.1.7 ↔ B11;§3.1.8 ↔ B10;§3.1.9 ↔ B4/B14/B15/B16/B17/B18(第八轮 fix-9 已识别绕过路径);§3.1.10 ↔ 反审检测 graceful degrade(git log 失败 / audit YAML 损坏)
- [x] 错误传播路径完整无吞掉:5.2 流图显示所有 B 编号均回到 audit_trail / handoff skip / hook 留痕
- [x] 用户能看到有意义的错误信息:audit_trail YAML 解析错误 stderr 文本明示;hook exit 2 阻断时 stderr 引导消息明示文件清单 + 处理方式
- [x] 每个核心场景的异常路径有边界:场景 1 异常(B3-B6, B14-B17)/ 场景 2 异常(B1, B2, B7-B9, B13)/ 场景 3 异常(B3, B11)均有覆盖
- [x] 场景 4/5 占位的异常:B10 标 P0.9.1 scope 外;P0.9.2 / P0.9.3 阶段不在 P0.9.1 scope 内,与 §1.3 边界声明一致
- [x] M0-M4 循环依赖处理(B10 任务决策):B13 边界已明示"接受 + 修订评估,不破闭环"

---

## 6. 测试策略

### 6.1 Evidence Depth 重定义(M1 内含定义节)

feature 层的 L1-L4 不适用 meta(见 §4.1.4),本 P0.9.1 采用 **meta-L1 ~ meta-L4**(`meta-` 前缀 + L 层级;避免与 feature 侧 L1-L4 + 本 spec 模块编号 M1-M4 歧义):

- **meta-L1 节内自检**:设计文档每节末尾 `[x]` 勾选(本 spec 每节末尾即实例)
- **meta-L2 全局自洽检查**:design-rules 10 项全局自洽清单
- **meta-L3 meta-review 对抗审查**:§3.1.4 流程 + audit_trail verdict=pass + YAML covers 字段非空
- **meta-L4 真实使用验证**:后续 meta 改动 / feature 使用时该规则是否被引用并发挥作用

每层独立评估,可跳跃(参考 testing-standard.md "独立评级规则"精神)。

handoff 字段格式(B7 决策):同字段名 `## Evidence Depth`,档位值用 meta-L1~meta-L4(meta 改动)/ L1~L4(feature 改动)。详见 §4.1.4。

### 6.2 关键测试场景

| 场景来源 | 测试内容 | 证据层级 | 验证方式 |
|---|---|---|---|
| §1.2 场景 1 | meta-review fork N 挑战者返回独立问题清单,合成共识/分歧/盲区 | meta-L3 | 对本 spec 做 `/design-review`(bootstrap 4 维,§6.4) + audit YAML covers + verdict=pass |
| §1.2 场景 2 | meta 改动完整走完 §3.1.3 四步,产 decision + ROADMAP/memory 同步 + handoff Evidence Depth 填写 | meta-L3 + meta-L4 | P0.9.1 落地后首个 meta 改动(M0-M4 批次之一)做实战 case |
| §1.2 场景 3 | 4 个 agent 改造按模态分型(M6/M7 全 A/B/C / M8 混合 / M9 N 维),触发任一时维度可定制 | meta-L2 + meta-L3 | bootstrap 4 维审本 spec + 落地后第一个 feature 使用时维度定制记录 |
| §3.1.7 runtime 嵌入 | 调度者识别 scope=meta 时手工读 M2 + 嵌入挑战者 prompt | meta-L3 | bootstrap 审查时调度者执行该流程,audit 内 dimensions 字段非空 |
| §3.1.8 setup.sh 分发 | meta-* 文件不分发到下游 | meta-L1 | 实施 M14 后,在临时目录 `./setup.sh /tmp/test-target` 验证目标项目无 `meta-*` 文件 |
| §3.1.9 hook 执法 | M15/M16 在 git diff 命中 scope 但无 audit 时阻断 | meta-L3 | 实施 M15-M18 后,故意改 `docs/governance/test-rule.md` + 不写 audit + try Stop / try git commit,验证两扇门都拦 |
| §3.1.9 hook 失效规则 | covers 文件有新 commit 后该 audit 失效 | meta-L3 | 实施后,产一个 audit 含 covers `[X.md]`;改 X.md 加新 commit;再 try Stop,验证 hook 视该文件未 cover 触发引导 |
| §1.2 场景 4(P0.9.2)| audit_trail 累积 N 次后 leverage 诊断有数据可用 | meta-L4 | 不在 P0.9.1 测试 scope |
| §1.2 场景 5(P0.9.3)| 更严硬 hook 在流程被绕时拦截 | meta-L3 + meta-L4 | 不在 P0.9.1 测试 scope |
| §5 边界 B1/B4 | 缺口检测机制在 hook 触发时引导补 audit | meta-L3 | 落地后刻意跳过一次 audit,验证 M15 Stop hook 引导消息出现 |
| §5 边界 B5(降级)| fork 失败时单 context 降级可跑完 | meta-L3 | 本 spec 审查可能即实例(若 fork 失败) |
| §5 边界 B7(连续未通过)| 连续 2 次 needs-revision → 用户介入 | 规则层 | 由 design-rules 承接 |
| §5 边界 B13(M0-M4 闭环)| M0-M4 不通过的处理 | meta-L4 | 落地后 M0-M4 批次执行验证;若反复 ≥ 2 次同缺陷 → 触发 P0.9.1 修订评估 |
| §5 边界 B14-B17(hook 异常)| hook 在配置缺失/YAML 损坏/非 git 环境降级 exit 0 | meta-L3 | 实施后单元测试式验证:删除 scope.conf / 写损坏 YAML / 在非 git 目录 → 验证 exit 0 |

### 6.3 测试边界

**不测什么**:

- **不测 P0.9.2 诊断流程本身**(§1.3 边界 — P0.9.2 启动时再设计测试)
- **不测 P0.9.3 兜底**(§1.3 边界 — P0.9.3 触发时才实现)
- **不对已完成 P-1/P0/P0.5 条目追溯测试**(§1.3 边界 + 风险警示 5)
- **不做负载 / 性能测试**(audit_trail 和 hook 是文本/git 操作,无性能瓶颈;§1.3 已估算成本)
- **不定具体可量化指标**(A7 决策 + Q2 拍板 — 见 §6.6 Q2 论证)
- **不强制单元测试 hook 脚本逻辑**(hook 是声明式 shell 检测,bug 由实战暴露;参考 check-handoff.sh / check-evidence-depth.sh 现有范式)
- **不测 D5 / D.2 字节软上限 enforcement**(D5 = 64 kB 单 prompt / D.2 = 8 KB M2 嵌入;光谱 B+ 最小硬 hook 原则下不加 hook 校验;P0.9.1 调度者 / 实施者自律,P0.9.2 诊断阶段实战观察是否需要补 enforcement)

**外部依赖的 mock 策略**:

- **fork 行为**:Claude Code 平台 Agent 工具不由 harness 控制,无法 mock。测试依赖实际 fork 调用(bootstrap 审查即真实测试)
- **git**:hook 测试用真实 git 仓库 + 临时分支 + 实际 commit 操作,无 mock 必要
- **文件系统**:markdown / conf / shell 都用真实 fs

### 6.4 Bootstrap 自洽验证(B11 决策 — 撤回第 5 维加维,沿用 4 维)

**self-reference 悖论**:本 spec 产出 meta-review 机制,但本 spec 自身 design-review 需要 meta-review 才能严格审查。权宜方案(brainstorming 末尾已定):

1. **本 spec design-review 用 4 挑战者**(沿用 brainstorming 期已原型验证的 4 维):
   - 核心原则合规
   - 目的达成度
   - 副作用
   - scope 漂移

2. **B11 决策依据(第七轮撤回过度工程化加维)**:
   - 第七轮按"meta 系统在自己落地前不可证 = bootstrap 悖论"原则,不再以"风险警示提到简洁性"为由把过度工程化升为独立第 5 维 — 该升维属于 meta 流程未落地前的 self-reference 论证,无可证基础
   - 4 维基线已能承担过度复杂度异常的检出:"副作用"维度可挑战"新增模块/接口对既有系统的额外负担","scope 漂移"维度可挑战"超出 §1.3 边界的扩展"
   - 简洁性作为 RUBRIC 结果指标(evaluate 阶段验证最小)与 bootstrap 设计阶段维度分工:bootstrap 4 维不必为每个 RUBRIC 惩罚项配独立挑战者

3. **P0.9.1 落地后**,用新机制(M2 pattern 节)反向审查这 4 维,检查是否符合 A/B/C 三段结构(对抗式)

4. 反向审查结果作为 meta-L4 真实使用验证第 1 数据点,写入本 spec 的 audit trail

5. **第八轮 fix-8 用户拍板 — 反审触发 = A + C 组合**(详见 `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`):
   - **A 部分(SessionStart hook 主动推)**:M20 扩展 session-init.sh 加反审检测段(§3.1.10);检测条件:`git log` 主分支历史含 P0.9.1 落地 commit + `docs/audits/` 中无 covers 含本 spec 路径的 audit;两条件同时成立 → 注入 system-reminder 提醒反审。**不阻断**,仅注入。
   - **C 部分(handoff 反审待办字段被动留痕)**:M1 meta-finishing-rules 在 P0.9.1 落地最后一次 finishing(commit 进 main 前)引导调度者在 handoff 加 `## 反审待办: P0.9.1 落地反审 — 未完成` 字段(§4.1.7);反审 audit 产出后更新为"已完成 — audit:<path>"。
   - **A+C 互补**:A 主动推(每次 session 启动检测),C 被动留痕(handoff 字段供调度者参考);单 A 易被忽视(SessionStart 注入消息多了反而被忽视);单 C 弱约束(依赖调度者自律读 handoff,与根源 1 自律问题同根)。组合最稳。
   - **权威依据**:audit covers 是反审完成的权威依据(SessionStart hook 按 covers 判定);handoff 字段是辅助留痕。两者失同步以 covers 为准。
   - **失效重审**:若 P0.9.1 重大改动(commit 进 main)后,§4.1.5 covers 失效规则触发反审 audit 失效 → SessionStart hook 重新注入提醒,handoff 字段重置为"未完成"。

### 6.5 P0.9.1.5 spec 兼容验证(A6 决策 + 第八轮 fix-7 触发条件 B)

**A6 任务要求**:meta-review 流程必须能审 P0.9.1.5 自己的 spec(吃自己狗粮)。

**第八轮 fix-7 拍板 — 触发条件 = B(灵活)**:
- **P0.9.1 落地后不强制启动 P0.9.1.5**;由用户在 M0-M4 启动前评估"P0.9.1.5 是否先做"
- 若用户决定先做 → 启 P0.9.1.5 brainstorming,产出后实施阶段触发 meta-review(scope=meta)
- 若用户决定先跑 M0(用 P0.9.1 流程,不经 P0.9.1.5)→ M0 实战回流可能反过来定义 P0.9.1.5 真实需求
- 详见 `docs/decisions/2026-04-26-p0-9-1-5-trigger-condition.md`

**验证内容**:
- P0.9.1 落地后,**若用户决定启动** P0.9.1.5(写前流程)的 spec 设计 → 走 P0.9.1 产出的 meta-review 流程审查
- 该 spec 走完 §3.1.4 流程后产 audit;audit YAML covers 含 P0.9.1.5 spec 涉及的 governance 文件路径
- 验证 P0.9.1 流程不因审查"自己的下一阶段"而失效(无循环依赖死锁)

**P0.9.1 内部验证项(本 spec 阶段先做)**:
- 检查 §3.1.1 scope 识别:写新 governance 文件(P0.9.1.5 产出物)是否被识别为 meta scope?
  → §1.3 + M17 scope.conf 已含 `docs/governance/*.md`,识别为 meta;通过
- 检查 §3.1.4 流程是否有"针对 design 阶段 spec"的特殊路径?
  → 无特殊路径(meta-review 通用),不存在死锁

**A6 + fix-7 B 兼容性接受标准**:
- **触发节奏**:P0.9.1 落地 → (用户评估)→ 若启动 P0.9.1.5 → P0.9.1.5 brainstorming → P0.9.1.5 design → P0.9.1.5 实施(走 meta-review)→ M0-M4 享受新写前 + 新 meta-review;若不先启动 P0.9.1.5 → 直接 M0-M4 用 P0.9.1 流程
- P0.9.1.5 brainstorming 启动时,§1.3 scope 不需扩展(brainstorming 阶段产出 spec 是 design 阶段事,不是 governance 改动 → scope=feature/none,不触发 meta-review)
- 但 P0.9.1.5 的实施(写新 governance 文件 / 改 CLAUDE.md)→ scope=meta,触发 meta-review
- 即:P0.9.1.5 的 design 阶段不走 meta-review,实施阶段走 meta-review。这是吃自己狗粮的正确节奏
- **B 触发的实施层引导**:M0-M4 启动前(brainstorming 阶段对接 M0)由 brainstorming-rules / handoff 引导用户评估"P0.9.1.5 是否先做"(具体引导文案在 P0.9.1.5 自身实施或 P0.9.3 阶段定)

### 6.6 Q2 不定可量化指标论证(A7 决策)

**A7 任务要求**:§7 加 D11+ 论证为什么 P0.9.1 不定可量化指标。呼应 §1.6 已实现 leverage 4 事实。

**Q2-B 拍板回顾(§1.5)**:
- P0.9.1 不强行定可量化指标(避免编数据违反 `feedback_judgment_basis`)
- 具体指标推 P0.9.2 诊断阶段(需真实运行数据)
- §1.6 列了已实现的 leverage 4 事实(可数事实而非凭空指标)

**论证(本节展开)**:
- 当前 harness 没有 N 次 meta 改动的实际数据,无法**事实地**回答"meta 改动比 feature 改动稳定 N 倍"等指标
- 若强行定指标(如"维度数 ≥ feature 的 2 倍"、"audit 字段 ≥ M 项"),数字来源只能是 designer 主观估算,违反 `feedback_judgment_basis`(禁止凭空数字)
- §1.6 leverage 4 事实是**结构性比对**(可数事实):
  1. 比 feature 多 2 个硬 hook(Stop M15 + pre-commit M16)
  2. audit 必走(YAML covers + 失效规则,git log 比对)
  3. meta 审查不通过 → 回 brainstorming(feature 只回 design)
  4. 跳过必须留痕(handoff skip 理由必填)
- 这 4 条不是指标,是**机制差异**。指标(数字阈值)推 P0.9.2

**§7 应对**:见 D11(新增决策)。

### 6.7 测试策略汇总表

| 测试项 | 证据层级 | P0.9.1 内可完成 | 落地后可完成 |
|---|---|---|---|
| 本 spec 各节自检 | meta-L1 | ✅ | — |
| 本 spec 全局自洽 | meta-L2 | ✅(调度者 fork 自检挑战者,§9 由独立挑战者做) | — |
| 本 spec bootstrap 4 维 design-review | meta-L3 | ✅(调度者 fork 4 挑战者) | — |
| §3.1.8 setup.sh 分发隔离 | meta-L1 | ⚠️ 静态可验证(代码 review)/ 实战需 ./setup.sh | ✅ |
| §3.1.9 hook 执法 | meta-L3 | ❌ | ✅ |
| 首个 meta 改动实战(M0-M4 之一)| meta-L3 + meta-L4 | ❌ | ✅(首次使用批次) |
| 新机制反审 bootstrap 4 维 | meta-L4 | ❌ | ✅ |
| §3.1.10 SessionStart hook 反审检测(M20 扩展,fix-8 A 部分)| meta-L3 | ⚠️ 静态可验证(代码 review M20 反审检测段)/ 实战需 P0.9.1 落地 commit | ✅(检测条件:`git log` 主分支含 P0.9.1 落地 commit + `docs/audits/` 中无 covers 含本 spec 路径的 audit → 注入 system-reminder;graceful degrade:git log 失败 / audit YAML 损坏不阻断 session) |
| §4.1.7 handoff 反审待办字段(C 部分,fix-8 C 部分)| meta-L1 | ✅(模板 / 流转静态可验证 — handoff.md 模板加字段示例 + M1 meta-finishing-rules 引导填写)| ✅(P0.9.1 落地最后一次 finishing 写入"未完成";反审 audit 产出后改"已完成 — audit:<path>";失同步以 covers 为准)|
| P0.9.1.5 兼容验证(A6) | meta-L4 | ❌ | ✅(P0.9.1.5 实施时) |
| 缺口检测机制(B1/B4)| meta-L3 | ❌ | ✅ |
| hook 异常降级(B14-B17)| meta-L3 | ❌ | ✅ |
| Q2 leverage 4 事实 | meta-L1 | ✅(结构性可证)| — |
| 不定可量化指标(A7) | 无 | ✅(论证已写)| Q2 阶段定 |
| P0.9.2 诊断 | meta-L4 | ❌ | 不在 P0.9.1 scope |
| P0.9.3 兜底 | meta-L3 + meta-L4 | ❌ | 不在 P0.9.1 scope |

---

**第 6 节自检**:

- [x] 每个核心场景(1/2/3)有对应测试 + §3.1.7-§3.1.9 新接口都有测试覆盖
- [x] 场景 4/5 占位诚实标"不在 P0.9.1 scope"
- [x] 每个边界条件(B1-B17)有对应测试或规则层承接:B1/B4 有 hook 实战测试;B5 fork 降级在 bootstrap 即可能命中;B7 由 design-rules 承接;B10 标 scope 外;B13 落地后验证;B14-B17 实施后单元式验证
- [x] 测试层级选择合理:meta-L1 ~ meta-L4 重定义并给出依据;每层 P0.9.1 内/落地后可验证边界清晰
- [x] Bootstrap 自洽验证明确(B11 决策):沿用 4 维;第七轮撤回过度工程化第 5 维加维(不可证不讨论)
- [x] A6 P0.9.1.5 兼容验证 + A7 Q2 论证已纳入(§6.5 / §6.6)

---

## 7. 设计决策记录

### 7.1 确定的决策

| 编号 | 决策 | 选项 | 选择 | 原因 |
|---|---|---|---|---|
| **D1** | 是否新建独立 meta-review skill | A: 新建 `.claude/skills/meta-review/` 独立 skill;B: 不新建,meta-review 作为 §3.1.4 流程嵌入 M1,调用现有 4 个 skill 之一或多个 | **B** | (1) 简洁性:新 skill 会与现有 4 个审查 skill 职责重叠(都是 fork N 挑战者);(2) M2 内含 pattern 节后,现有 4 个 skill 经改造已支持维度定制(对抗式 / 混合式 / 事实统计式),meta-review 直接复用;(3) M2 作为流程规约足够承接"何时触发 / 如何选 skill / 如何产 audit",不需执行载体独立 |
| **D2(本轮重写)** | 4 agent 改造的 prompt 结构(B2 决策) | A: 全部统一 A/B/C 三段;B: 全部不统一各自保留现风格;**C: 按 multi-agent-review-guide 模态分型 — 对抗式全 A/B/C / 混合式部分 A/B/C / 事实统计式 N 维分工** | **C** | (1) `multi-agent-review-guide.md` 末"适用性判断"明确:对抗模式不适用所有审查类型(凭证扫描部分硬编码不动 / 流程审计基于事实统计不存在"立场"问题);(2) 第一轮 design-review 挑战者 D3 副作用问题点出"统一 A/B/C 有模态错配风险"— **本轮按模态分型回应**;(3) 一致性 RUBRIC 不要求"机械相同",而要求"同模态内一致":对抗式 M6/M7 共享同 pattern,混合式 M8 内对抗维度部分共享同 pattern,事实统计式 M9 N 维共享同结构;(4) **影响**:§2 M6-M9 改造按模态分,§3.1.6 三段契约按模态分,§4.1.1 audit dimensions 按模态分,§7 应对方式更精准 |
| **D3** | M2 pattern 节如何被 agent 运行时访问(原 M3 改为 M2 节内,B5 决策) | A: skill 用 `!` 注入读 M2;B: 调度者运行时手工读 + 嵌入 prompt(条件化:仅 harness 仓库) | **B** | (1) `!` 注入在下游目标项目也会执行 — 但 M14 setup.sh 过滤 meta-* 文件,下游不存在 M2,`!`cat docs/governance/meta-*` 注入会返回空;(2) 下游不需要这种污染,语义模糊;(3) 调度者识别 scope=meta(§3.1.1)后手工读 M2 + 嵌入挑战者 prompt 更清晰,且现有 4 个 skill 的现 `!` 注入机制(RUBRIC / ARCHITECTURE / 设计文档)保留不变 — 影响最小 |
| **D4** | 最低必选维度如何强制 | A: agent prompt 静态文字;B: 调度者层面检查;C: audit 产出 post-check | **A + B + C 三层组合** | (1) A 段 agent prompt 内含 minimum_required 列表,挑战者直读;(2) B 调度者 §3.1.4 Step 1 自检 C 段未禁 minimum;(3) C audit YAML covers 字段空白由 M15 / M16 hook 后续检 — **三层为光谱 B+ 的执法配套**;参考 §5 边界 B3 三重检出 |
| **D5** | 挑战者单 prompt 字节上限 | A: 不设上限;B: 硬上限拒绝;C: 软上限 + 拆分策略 | **C** | 硬上限(B)过死;无上限(A)遇 §5 边界 B6 上下文溢出。软上限+拆分(C)是常用做法,N 值由 M2 实施时定(建议 ~64 kB) |
| **D6(本轮重写)** | 占位模块 M17/M18(原编号)处理 | A: 建空文件带 TODO 头部;B: 仅模块表登记;**C: 占位完全不登记,在 §1.3 边界声明即可** | **C** | (1) §1.3 边界已锁 P0.9.2/P0.9.3 不在 scope,占位无独立交付物;(2) 模块表登记会被 RUBRIC 简洁性扣分(空字段 / 占位文件均是过度);(3) 删除占位编号 → 释放 M17/M18 给本轮新增的 hook 配置(M17 scope.conf)和 settings.json(M18) — 编号复用是简洁性的具体表现 |
| **D7(第七轮重写)** | bootstrap 维度数(B11 决策 — 撤回第 5 维加维) | A: 沿用 4 维;B: 加第 5 维"过度工程化";C: 内嵌某维度;D: 不审 + §6 反审补 | **A**(第七轮从 B 撤回到 A) | (1) 第七轮按"meta 系统在自己落地前不可证 = bootstrap 悖论"原则,撤回 B 选项 — 把过度工程化升为独立第 5 维属于 meta 流程未落地前的 self-reference 论证,无可证基础;(2) 4 维基线已能承担过度复杂度异常的检出:"副作用"维度可挑战"新增模块/接口对既有系统的额外负担","scope 漂移"维度可挑战"超出 §1.3 边界的扩展";(3) 简洁性作为 RUBRIC 结果指标(evaluate 阶段验证最小)与 bootstrap 设计阶段维度分工:bootstrap 4 维不必为每个 RUBRIC 惩罚项配独立挑战者;(4) 不延后 D 仍成立:bootstrap 当下尽力是治理原则,§6 反审是落地后做不能替代当下;(5) 详见 §6.4 重写依据 |
| **D8** | meta evidence depth 档位命名 | A: 沿用 L1-L4 但重赋义;B: 原方案 M1-M4(meta 前缀);C: `meta-L1 ~ meta-L4` | **C** | 同第一轮原 D8 理由:(1) 沿用 L1-L4(A)与 feature 侧 testing-standard.md 冲突;(2) M1-M4(B)与本 spec §2 模块编号同前缀歧义;(3) `meta-L1 ~ meta-L4`(C)同时避免两个冲突 |
| **D9** | meta decision 模板子类型 | A: 新建 meta-level decision 模板;B: 沿用 + 加 Bootstrap 声明节 | **B** | `2026-04-17-harness-self-governance-gap.md` 已示范"根源承认型";由 M1 说明"meta-level decision 可加 Bootstrap 声明 / 不做节",保持模板库简洁 |
| **D10(新增 — B7 决策)** | Evidence Depth 字段格式(meta vs feature 双标) | a: 同字段名不同档位值;b: 不同字段名 | **a** | (1) check-evidence-depth.sh 现仅检字段名 `## Evidence Depth` 非空 + 非 `[待填]`,不解析档位值 — 选 a 字段名不变,hook 不需改;(2) 选 b 改 hook 增加复杂度,与"光谱 B+ 最小硬 hook"原则冲突;(3) mixed 改动场景:同字段内同时列 meta-L 和 L 档位值,hook 仅检字段非空即通过;(4) 详见 §4.1.4 + §6.1 |
| **D11(新增 — A7 决策)** | P0.9.1 是否定可量化指标 | A: 强行定数字阈值;B: 不定,论证 + 列已实现 leverage 4 事实 | **B** | (1) 当前无 N 次 meta 改动实际数据,凭空数字违反 `feedback_judgment_basis`(禁止用市场判断或别人项目数据支撑决策);(2) §1.6 leverage 4 事实是结构性比对(可数事实):比 feature 多 2 hook / audit 必走 / 不通过回 brainstorming / 跳过留痕 — 不是指标是机制差异;(3) 具体指标(数字阈值)推 P0.9.2 诊断阶段(需真实运行数据);(4) 详见 §6.6 论证 |
| **D12(新增 — B3 决策)** | setup.sh 下游分发隔离 | A: 显式枚举每个不分发文件;B: 命名前缀过滤 `meta-*`;C: 黑名单文件配置 | **B** | (1) 命名前缀(B)是约定优于配置:本 spec 锁定所有 meta 治理文件以 `meta-` 开头,setup.sh 改造一行 `case "$f" in meta-*) continue` 即可;(2) 显式枚举(A)随 P0.9.1.5 / P0.9.2 / P0.9.3 新增文件需同步改 setup.sh,易遗漏;(3) 黑名单文件(C)增加配置文件维护成本;(4) 详见 §3.1.8 |
| **D13(新增 — B4 决策)** | M3 vs M4 路径区分 — `/CLAUDE.md`(harness 根)vs `harness/CLAUDE.md`(分发模板) | A: 仅模板加 meta 段落,根不变(5 行导航);B: 根升级为 harness 自治理入口,模板不含 meta 段落;C: 双向同步 | **B** | (1) 仓库实际两文件分工不同:`/CLAUDE.md` 当前仅 5 行导航,`/harness/CLAUDE.md` 是下游模板。**升级根**(M3)使其成为 harness 自治理入口(角色分离 / 治理表 / scope 判定),与下游模板**完全分离**;(2) 选 A 让根保持空导航而模板含 meta 段落 → 下游被 meta 治理污染;(3) 选 C 双向同步 → 根和模板内容一样,语义混乱;(4) 选 B 是最清晰路径区分;(5) 详见 §2.1 M3/M4 + §3.1.8 |
| **D14(新增 — B8 决策)** | audit 文件名是否加时间戳 | A: 单日同主题用单文件 `meta-review-YYYY-MM-DD-[主题].md`(若冲突附加 -2 / -3);B: 加 HHMMSS 全时间戳 `meta-review-YYYY-MM-DD-HHMMSS-[主题].md` | **B** | (1) 单日同主题冲突更常见(同日多次审查或修订重审);(2) 序号 -2 / -3 需要文件读取 + 排序逻辑,hook 复杂化;(3) HHMMSS 与 process-audit 现行 `audit-YYYY-MM-DD-HHMMSS.md` 命名同结构,一致性 RUBRIC 加分;(4) 详见 §4.1.1 |
| **D15(新增 — B9 决策)** | audit 归档策略 | A: 不归档,主目录持续累积;B: 每 6 月迁 `archive/YYYY-HN/` + 索引;C: 每月迁 / 每年迁等其他周期 | **B** | (1) 360 个 audit/年(每月 30 个估算)累积导致 hook grep 成本上升;(2) 6 月周期是 audit 失效规则的实际范围 — covers 失效按 git commit time 判,过老 audit covers 几乎都已失效,不参与执法逻辑;(3) `archive/INDEX.md` 索引保留可追溯性;(4) 选 A 不归档将拖慢 hook;选 C 月周期太频繁;(5) 详见 §4.1.1 归档策略 |
| **D16(新增 — B10 决策,第七轮 fix-5 增分流)** | M0-M4 首次 meta-review 不通过的处理 | A: 阻塞 M0-M4 推进;B: 接受 + 视情况修订 P0.9.1 / P0.9.1.5 | **B(并明示 B7 vs B13 分流)** | (1) M0-M4 是 P0.9.1 落地后**首个使用批次**,首次执行可能命中 P0.9.1 自身设计缺陷 — 阻塞会让闭环死锁;(2) 接受推进 + 修订评估;(3) **第七轮 fix-5 明示**:**单项 M0-M4 反复 needs-revision(连续 2 次)→ B7 用户介入**(同主题反复 = design-rules 标准的反复未通过);**多项 M0-M4 命中相同流程缺陷(≥ 2 项)→ B13 P0.9.1 修订评估**(暴露 P0.9.1 设计层缺陷,非单 M 反复);(4) "接受"语义 = M0-M4 改动方向 M-by-M 重审,但不延后批次启动;(5) **不允许追溯推翻 P0.9.1 实施**(§5 边界 B13 已锁);(6) 详见 §5.1 B7 + B13 |
| **D17(新增 — A1 决策)** | hook 模块数与拦截策略 | A: 仅 1 hook(Stop 或 pre-commit 任一);B: 2 hook 两扇门叠加;C: 多个 hook 跨 session 含 SessionStart 等 | **B** | (1) 单 hook 覆盖不全:仅 Stop hook 漏 commit-only 路径(用户手动 commit);仅 pre-commit hook 漏 session 末未 commit 路径(对话停止 git 状态保留);(2) C 多 hook 复杂度过高,违反"光谱 B+ 最小硬 hook";(3) B 两扇门叠加是最小集 — Stop 守 session 末,pre-commit 守 commit 入 git 历史;(4) 无门槛(每次都检测) + `stop_hook_active=true` 防死循环已足够,详见 §3.1.9 |
| **D18(新增 — A2 决策)** | scope 文件清单存放方式 | A: 硬编码在 hook 脚本;B: 单独 conf 文件 hook 读 | **B** | (1) scope 扩展不改 hook 代码 — 解耦数据与逻辑;(2) conf 文件机器可读 + 人类可读(每行一条 glob,`#` 注释,`!` 排除),不需要新格式语言;(3) hook 代码保持简洁(读 conf + 比对 git diff + 检 audit covers);(4) 详见 §4.1.2 |
| **D19(§8 自检发现 — 用户拍板 a,**第四轮重写**)** | M15/M16 hook + M18 settings.json 在下游目标项目的行为 | **a: 不分发 meta hook 注册(零污染)— 新建 M19 模板 settings.json,M14 setup.sh 改 source 指向 M19**;b: 分发 + hook 内 marker 条件 exit 0(软污染);c: 隐式空运行(读不到 scope.conf 自然 exit 0,软污染) | **a** | (1) **用户拍板 a**(第四轮第三轮 c → a 升级):零污染优于软污染。a 下游一个 meta-* 文件 + 一条 meta hook 注册都看不到,直接实现 §1.3 兼容性"下游项目不受 meta 治理污染";b/c 下游 settings.json 仍含 meta hook 注册行,下游用户见 hook 但 disabled(b)或啥也不做(c),需读条件代码或被误为 bug;(2) **实施成本对比**:a 新增 1 文件(M19 `harness/templates/settings.json`)+ 改 setup.sh 1 行(line 71 改 source);b 每 hook marker 检查(2×5 行)+ marker 机制设计;c 类似 b。a 反而最简单;(3) **维护负担**:a 双轨 settings.json(harness 自身用 `.claude/settings.json` 含 meta hook 注册;下游用 `templates/settings.json` 不含)— 每加 meta hook 改两处 vs b/c 单轨 + 每加 meta hook 都要 marker;权衡后双轨更彻底;(4) **不在 hook 内加 marker / 条件 exit 0**(那是 b 方案);a 方案下,下游根本没有 meta hook 文件 + 注册,无需自防;(5) 配合 D12(命名前缀过滤 hooks/governance),下游零 meta-* 痕迹;(6) 详见 §2 M19 + §3.1.8 setup.sh line 71 改造 + §4 M19 文件结构说明 + §8.1 M19 改动 |
| **D20(第八轮 fix-7 用户拍板)** | P0.9.1.5 写前流程触发条件 | A: P0.9.1 落地后立即启动(最严);**B: M0-M4 启动前用户决定(灵活)**;C1: 反审本 spec 后再判 P0.9.1.5 启动(与 fix-8 串链);C2: M0 brainstorming 阶段强制启动 | **B(M0-M4 启动前用户决定,灵活)** | (1) §1.3 已锁 P0.9.1.5 不在 P0.9.1 scope,P0.9.1 spec 责任是声明缺口 + 留占位,不预定 P0.9.1.5 时序;(2) brainstorming Q3-B 拍板"用 P0.9.1 产出的 meta-review 流程做 P0.9.1.5"已隐含"视实际节奏推进";(3) **`feedback_judgment_basis` 原则**:无 P0.9.1 实战数据时不应预先把 P0.9.1.5 触发条件锁死,由 M0-M4 实战反向定义 P0.9.1.5 真实需求;(4) 与 fix-8 反审触发解耦(B 让用户分别决策更清晰);(5) 详见 `docs/decisions/2026-04-26-p0-9-1-5-trigger-condition.md`;(6) 后续影响落地 §1.3 / §6.5 / §8.3 |
| **D21(第八轮 fix-8 用户拍板)** | P0.9.1 落地后反审本 spec 触发机制 | A: SessionStart hook 检测 + 注入提示;B: ROADMAP 硬卡口(brainstorming-rules 拒启 P0.9.1.5);C: handoff 加"反审待办"字段;D1/D2: 弱替代;**A+C 组合** | **A + C 组合**(SessionStart hook 主动推 + handoff 反审待办字段被动留痕) | (1) **A+C 互补**:A 提供 session 级提醒(每次 session 启动检测 git log P0.9.1 落地 commit + audit covers 不含本 spec → 注入 system-reminder),C 提供文档级登记(P0.9.1 落地最后一次 finishing 写入 `## 反审待办`);(2) 单 A 易被忽视(SessionStart 注入消息多了反而被忽视);单 C 弱约束(依赖调度者自律读 handoff,与根源 1 自律问题同根);组合最稳;(3) 不选 B:与 fix-7 耦合(若 fix-7 选灵活方案 B,本方案 B 强卡口冲突);brainstorming-rules 加 audit 检测增加治理层复杂度;(4) **`feedback_spec_gap_masking` 原则**:留痕 + 提醒比"硬卡 + 阻塞"更符合"承认而非掩盖";(5) **权威依据**:audit covers 为准,handoff 字段辅助留痕;两者失同步以 covers 判定;(6) 详见 `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`;(7) 后续影响落地 §3.1.10(A 部分 M20 扩展)+ §4.1.7(C 部分 handoff 字段)+ §6.4(A+C 描述)+ §8.1(M20 + handoff 模板改动)|
| **D22(第八轮 fix-9 用户拍板,6 子决策)** | 6 项执法绕过路径处理 | (i) `--no-verify` 绕 pre-commit;(ii) 长 session 不 stop 漏 Stop hook;(iii) covers 填错;(iv) 理由质量自律;(v) M17 scope.conf + audit 自身排除区;(vi) 下游用户改 harness scope 文件无拦 | **(i)(ii)(iv)(vi) 接受 / 推 P0.9.3;(iii)(v) 修设计**(6 子决策见 decision 文件)| (1) **(i) 推 P0.9.3**:AI 调度者默认不主动用 `--no-verify`,无实战数据不预防(`feedback_judgment_basis`);(2) **(ii) 接受 + 推 P0.9.3**:光谱 B+ 最小集设计代价(D17 锁 Stop + pre-commit 是 2 hook 最小集),加第三 hook 违反最小集原则;(3) **(iii) 修 §3.1.9 hook 逻辑**:设计层漏洞(非用户绕),covered_files 计算用 audit covers 字段实际列出的文件路径(不是"audit 存在 + 主题相关");不修则 covers 字段沦为形式,违反 §1.5"audit 必走"实质语义;(4) **(iv) 接受**:语义判断不是 hook 适合做的(检长度水文照样过),治理层(M2 meta-review-rules + M9 process-auditor)负责理由质量;(5) **(v) 修 §3.1.1 + §4.1.2 + §3.1.9 + §1.3**:self-reference 漏洞 — `!meta-*` 把"治理文件"和"流程产出物"混为一类;**治理文件入 scope**(改它们走 meta-review),**只排除流程产出物**(audit / archive — 自审无穷递归);bootstrap 循环可接受(类似编译器自举);(6) **(vi) 接受**:§1.3 兼容性假设"下游不应改 harness 副本"+ D19 a 方案"零污染"前提;不试图技术封堵,声明 + 留痕(setup.sh 末尾打印消息提示);(7) 详见 `docs/decisions/2026-04-26-bypass-paths-handling.md`(6 子决策完整论证);(8) 后续影响落地 §1.3(B18 / 兼容性声明 / bootstrap 循环可接受)+ §3.1.1(排除规则改造)+ §3.1.9(covers 比对明示)+ §4.1.2(scope.conf 排除规则)+ §5.1(B18)|

### 7.2 待决策项(🟡 需用户决定)

**当前无 🟡 待决策项**:第七轮新增 3 项(fix-7 / fix-8 / fix-9)已由用户在第八轮拍板,落入 §7.1 D20 / D21 / D22(🟢 已决定)。第七轮以前 18 项问题(A1-A7 + B1-B11 + C1)在 D1-D19 解决。

**第七轮以前 18 项问题**(A1-A7 + B1-B11 + C1)仍在 D1-D19 解决,不破需求边界。

- A 组(brainstorming Q1-Q3 拍板)→ D17 / D18 实施 + D7(B11)+ D11(A7)+ A3-A6 数据格式与 §4.1.1 / §4.1.5 / §6.5 / §4.1.3 关联
- B 组(/design-review 必改)→ D2 / D3 / D6 / D7 / D10 / D12 / D13 / D14 / D15 / D16 + D17 hook 关联
- C 组(§1 整合带来)→ D18 + §4.1.2 scope.conf 数据规范

唯一接近升级为待决策项的是 **D2 4 agent 模态分型**,但 multi-agent-review-guide.md 末"适用性判断"已提供权威依据(对抗模式不适用所有审查),不需用户拍板,直接采纳。

D19(§8 自检发现的 hook 下游空运行)虽是新决策,但选项 c 与 D3 / D7 同思路(条件化),不破需求边界,不升级为待决策。

### 7.3 RUBRIC 应对方式

> 按 RUBRIC 通用基线 5 个惩罚项(功能完整性/代码质量/测试充分性/一致性/简洁性)+ 风险警示 1-5 + spec 1.6 已标记的惩罚项设计。bootstrap design-review 维度沿用 4 维(§6.4),不与 RUBRIC 5 个惩罚项混淆。

**RUBRIC 通用基线 5 个惩罚项应对**:

#### 功能完整性(通用基线)

- **风险**:场景 4/5 占位不实施,可能被误读为"功能不完整"
- **应对**:
  - §1.3 边界"不做什么"已锁定 P0.9.2/P0.9.3 不在 P0.9.1 scope
  - §2 模块表 D6 决策完全不登记占位(简洁性收益)
  - §6.2 测试表诚实标"不在 P0.9.1 测试 scope",不假装覆盖
  - P0.9.1 主体的 3 个场景(1/2/3)+ 执法层(场景 1/2 hook 触点)完整覆盖模块 / 接口 / 数据 / 边界 / 测试

#### 代码质量(通用基线)

- **风险**:audit 产物字段不清晰 / hook 边界条件不明
- **应对**:
  - §4.1.1 用 TypeScript 伪类型精确定义 audit_trail YAML covers + 5 段字段(按 agent 模态分)
  - §4.1.2 scope.conf 格式规范 + 解析规则
  - §4.1.3 handoff skip 字段规范 + grep 检测规则
  - §4.1.4 evidence depth 档位语义
  - §4.1.5 audit 失效规则(git commit time 判)
  - §3.1.9 hook 错误处理按现有 check-handoff.sh 范式降级
  - 每字段说明"必填 / 可选",如 `customization_rationale.reason` 必填

#### 测试充分性(通用基线 + 1.6 重点)

- **风险**:meta 场景 Evidence Depth 语义需重定义(spec 1.6 已标)+ hook 测试在 P0.9.1 内难做
- **应对**:
  - §4.1.4 + §6.1 重定义 meta-L1 ~ meta-L4,给出依据
  - §6.2 每个测试场景映射 meta-L1 ~ meta-L4,可验证性具体到"命令/文件/grep"
  - §6.4 bootstrap 4 维(B11 第七轮撤回过度工程化加维),审本 spec
  - §6.5 P0.9.1.5 兼容验证(A6)— 吃自己狗粮节奏
  - §6.6 不定可量化指标论证(A7)— 避免编数据违反 `feedback_judgment_basis`
  - §6.7 P0.9.1 内 vs 落地后的测试边界明确

#### 一致性(通用基线 + 1.6 重点 + 风险警示 3)

- **风险**:meta-review 流程与 4 个现有审查 agent 改造模态错配(spec 1.6 + 风险警示 3 已标)
- **应对**:
  - **D2 决策按模态分型**:对抗式 M6/M7 共享 A/B/C / 混合式 M8 部分 A/B/C / 事实统计式 M9 N 维 — 每模态内一致而非全局机械相同
  - M2 pattern 节作为唯一定义源(D3),不在 4 agent 文件重复拷贝
  - meta-review 流程(§3.1.4)与现有 fork 调用机制保持一致
  - audit_trail 命名(`meta-review-YYYY-MM-DD-HHMMSS-`)与 process-audit 现 `audit-YYYY-MM-DD-HHMMSS-` 同结构(D14)
  - meta-evidence-depth 档位命名 `meta-L1 ~ meta-L4`(D8)避免双重歧义
  - hook 错误处理范式(§3.1.9)与 check-handoff.sh 一致(降级 exit 0 + stderr)

#### 简洁性(通用基线 + 1.6 重点 + 风险警示 2)

- **风险**:meta finishing 流程不能变成比 feature finishing 更大的怪物
- **应对**:
  - **D1**:拒建独立 meta-review skill(复用现有 4 个)
  - **D6**:占位模块完全不登记(B1 决策合并 M3/M4 入 M1/M2)
  - **D9**:拒建 meta decision 独立模板(沿用 + 加节)
  - **D17**:hook 数最小集 2 个(Stop + pre-commit),不加 SessionStart / 跨 session
  - **D18**:scope.conf 单独配置,hook 代码不写 glob
  - **D12**:setup.sh 命名前缀过滤一行,不需新文件维护黑名单
  - **§2.1 候选清单调整说明**:每模块"为什么不能由现有组件承担":
    - M1 理由:scope 分流入口 + meta evidence depth 必须有引导文件,现有 finishing-rules 是 feature 侧,不能承担
    - M2 理由:meta-review 流程契约 + pattern 节,现有 SKILL.md 只管执行步骤,不管"何时触发"和"维度规则"
    - M15/M16/M17/M18 hook 体系:光谱 B+ 执法触点,无替代
  - **新增文件统计**:M1 / M2 governance + M15 / M16 hook + M17 conf + M19 templates/settings.json = 6 个新文件;M3 / M5 / M14 / M18 改动 + M6-M13 模式改造 + **M20 session-init.sh 扩展** = 13 个文件改动。**净 6 文件 + 13 改动,与第一轮草稿(4 新 + 12 改)对比 +2 个新文件(M17 conf + M19 模板,后者来自第四轮 D19 a 方案)+1 改动(M20 来自第八轮 fix-8 A 部分);模块数 20(第四轮 +1,第八轮 +1),价值密度提升**

### 7.4 项目特定 RUBRIC 应对(3 维)

⚠️ **bootstrap 例外保留**:harness 自身项目特定 RUBRIC(设计方向/技术方向/产品方向)空白,本次 design 不填应对方式。理由:

- §1.6 元警告:harness 项目特定 RUBRIC 空白本身是 self-governance 缺口具体面之一,挪后续条目
- 本任务指令例外 2:RUBRIC 项目特定 3 维留痕,§7 应对只对 RUBRIC 通用基线 5 个惩罚项(B11 第七轮已撤回 bootstrap 第 5 维加维)

依据 §1.6 + 任务指令,本节仅留痕,不强填。

---

**第 7 节自检**:

- [x] 每个决策的"原因"具体可验证:D1 引简洁性 + 现有 4 skill 复用;D2 引 multi-agent-review-guide 适用性表;D3 引 setup.sh 过滤后下游无 meta 文件;D17/D18 详解 hook 模块数 + scope.conf 解耦;D12-D16 + D11/D7 各引 brainstorming 拍板或必读文件;均不空话
- [x] 没有决策与 ARCHITECTURE.md 冲突:Bootstrap 例外 1 已声明 ARCHITECTURE.md 对 harness 自身不适用;hook 是文件操作,不是分层架构问题
- [x] 没有决策与 RUBRIC 惩罚项冲突:D1/D6/D9/D17 主动避简洁性;D2/D3/D8/D14 主动避一致性;D11 / §6.6 主动避凭空数据
- [x] 待决策项都已结清:§7.2 当前无 🟡;前轮 18 项问题在 D1-D19,第七轮新增 3 项 fix-7 / fix-8 / fix-9 已在第八轮拍板落入 D20 / D21 / D22(🟢 已决定)
- [x] 每个 RUBRIC 惩罚项都有应对方式:§7.3 RUBRIC 通用基线 5 个惩罚项(功能完整性/代码质量/测试充分性/一致性/简洁性)全列;项目特定 3 维按 Bootstrap 例外 2 留痕(B11 第七轮已撤回 bootstrap 第 5 维加维,不再混淆"维度"与 RUBRIC 惩罚项)

---

## 8. 与既有系统的影响

### 8.1 需要改动的已有文件 / 新建文件

(对齐 §2.1 模块表中所有"新建"和"改动"项;无占位文件,见 D6 决策)

| 文件 | 改什么 | 为什么 | 影响范围 |
|---|---|---|---|
| **M1** `docs/governance/meta-finishing-rules.md` | 新建 | 场景 2 主体 — 定义 meta 改动的 finishing 四步 + 内含 meta-L1~meta-L4 evidence depth 定义节(B1 决策合并原 M4) | 被 M3 / M5 引用;影响所有未来 meta 改动;**不分发下游**(meta-* 命名前缀过滤) |
| **M2** `docs/governance/meta-review-rules.md` | 新建 | 场景 1 主体 — 定义 meta-review 流程契约 + 内含**审查维度三段 pattern 定义节**(B1 决策合并原 M3,按 D2 模态分型 — 对抗式 / 混合式 / 事实统计式各自模板) | 被 M1 / M6-M9 / M10-M13 引用;影响所有 meta-review 执行;**不分发下游** |
| **M3** `/CLAUDE.md`(harness 仓库根) | **升级**(B4 决策 D13):从当前 5 行导航升级为 harness 自治理入口 — 加角色分离表 / 治理规则表 / scope 触发判定段落 / meta vs feature 分流 / scope 内对照表(A+B+C+D+F) / 链接到 M1 / M2 | 调度者每次阶段切换时读 — 没有这个入口,场景 1/2 无法自然触发;且 M3 与 M4 路径区分明示(D13)避免下游污染 | 调度者每次会话开头读;**不分发下游**(D12 命名分发规则) |
| **M4** `harness/CLAUDE.md`(分发模板) | **轻改动**:不加 meta 段落(明确不变),仅校对现有内容仍准确;若有"治理表"中 feature 流程描述需与 M3 对齐则同步 | 下游目标项目用 harness 但不改 harness 自身,M4 仅含 feature 层规则 — 不被 meta 治理污染 | 下游所有项目;新安装的下游拿 M4(D12) |
| **M5** `docs/governance/finishing-rules.md` | 头部加 scope 分流判定入口:判 meta → 引向 M1;判 feature → 继续现有流程 | 场景 2 分流点。不改头部则 meta 改动无法被 finishing 流程识别 | 影响所有进入 finishing 的改动(feature + meta 双路);**分发下游**(scope 分流不影响 feature 路径) |
| **M6** `.claude/agents/design-reviewer.md` | **对抗式 A/B/C 三段改造**(D2 决策):4 挑战者 prompt 段落改为 A(推荐)+B(最低必选,bootstrap 4 维:核心原则合规 / 目的达成度 / 副作用 / scope 漂移)+C(定制理由)三段格式。**第七轮 fix-2 约束**:prompt 只放结构占位 + 引 M2 路径,**禁止抄 M2 实文**(meta-review 流程描述 / scope 规则 / scope.conf glob 等);meta 实文由调度者运行时按 §3.1.7 嵌入 | 场景 3 — 对抗式维度可定制化 | 影响所有用 `/design-review` 的项目;**分发下游**(下游也获得维度定制能力,但 meta 段落的 minimum 不存在;agent 文件不含 meta 语境 — fix-2 防污染) |
| **M7** `.claude/agents/evaluator.md` | **对抗式 A/B/C 三段改造**(D2),4 维度(RUBRIC 合规/架构一致性/文档健康/Slop)改造。**第七轮 fix-2 + fix-6 约束**:fix-2 同 M6(只引 M2 路径不抄实文);fix-6 — agent prompt 接收 `scope` 参数(meta/feature/mixed),按 scope 分流引相应 evidence depth 文件:scope=feature → testing-standard.md(L1-L4),scope=meta → meta-finishing-rules.md 内含 evidence depth 节(meta-L1~meta-L4),scope=mixed → 同时引两份 | 场景 3 | 同 M6 |
| **M8** `.claude/agents/security-reviewer.md` | **混合式部分 A/B/C 改造**(D2):凭证 / 数据 / 危险操作 / 注入混淆硬编码 pattern 列表**不变**;对抗维度部分(场景判定 / 风险等级判定)采用 A/B/C 三段;凭证泄露场景判定固定为最低必选(不可绕,重要安全保证)。**第七轮 fix-2 约束**:同 M6 — 对抗维度部分 prompt 只引 M2 路径,不抄实文 | 场景 3 + 安全不降级 | 同 M6 |
| **M9** `.claude/agents/process-auditor.md` | **事实统计式 N 维分工保留**(D2):流程遵从度 / 效果满意度 2 维不强加 A/B/C;允许调度者按主题细化粒度,该细化点登记到 audit。**第七轮 fix-2 约束**:同 M6 — 粒度细化引 M2 路径,不抄 M2 实文 | 场景 3 | 同 M6 |
| **M10** `.claude/skills/design-review/SKILL.md` | "执行"节引 M2 维度选取步骤;**不**新增 `!` 注入(B5 决策 D3);调度者运行时手工读 M2 + 嵌入 prompt | 让 M2 pattern 在 skill 执行时可获取(条件化:仅 harness 仓库) | 影响 skill 运行时上下文;**分发下游**(下游执行时调度者识别 scope=feature,不触发 meta 嵌入) |
| **M11** `.claude/skills/evaluate/SKILL.md` | 同 M10 | 同上 | 同上 |
| **M12** `.claude/skills/security-scan/SKILL.md` | 同 M10(仅引 M2 对抗维度部分) | 同上 | 同上 |
| **M13** `.claude/skills/process-audit/SKILL.md` | 同 M10(引 M2 关于"事实统计式按主题细化粒度"的子节) | 同上 | 同上 |
| **M14** `setup.sh` | **加 meta-* 命名前缀过滤**(B3 决策 D12)+ **改 line 71 settings.json source 指向 M19 模板**(D19 a 方案,第四轮新增):`docs/governance/*.md` / `.claude/hooks/*.sh` 拷贝改为 case 语句过滤 meta-*;line 71 `cp "$SCRIPT_DIR/.claude/settings.json"` 改为 `cp "$SCRIPT_DIR/templates/settings.json"`(指向 M19 不含 meta hook 注册的模板);`CLAUDE.md` 拷贝(line 96)**现状已合规无需改**(`$SCRIPT_DIR/CLAUDE.md` 落在 `harness/CLAUDE.md` = M4 模板,M3 实际在 `$SCRIPT_DIR/../CLAUDE.md` 不在 cp 路径) | 下游不被 meta 治理污染 — meta-* 文件不分发,M3 因路径区分天然不分发,settings.json 走 M19 模板分发(零 meta hook 注册) | 影响所有未来安装下游;**已修改 setup.sh 自身就是 meta scope,需经 meta-review** |
| **M15** `.claude/hooks/check-meta-review.sh`(新建) | **新建 Stop hook**(A1 决策 D17):每次 Stop 触发,扫 git diff 比对 M17 scope.conf glob → 比对 audit YAML covers 并集(覆盖失效规则)→ 检 handoff skip 理由 → exit 0 / exit 2。**注**(D19 a 方案第四轮)**hook 内不加 marker 检查 / 条件 exit 0**(那是 b 方案);a 方案下下游根本无此 hook 文件 + 注册,无需自防 | 场景 1 执法触点 1(光谱 B+) | harness 自身仓库;**不分发下游**(meta-* 命名过滤) |
| **M16** `.claude/hooks/check-meta-commit.sh`(新建) | **新建 Git pre-commit hook**(A1 决策 D17):同 M15 逻辑,用 `git diff --cached`,exit 0 / exit 1 拦截 git commit。**注**(D19 a 方案):同 M15,hook 内不加 marker 条件 | 场景 1 执法触点 2(光谱 B+) | harness 自身仓库;**不分发下游**;且 git hook 本来就不通过 setup.sh 分发(git hook 本地,需通过 `.git/hooks/pre-commit` 软链接安装,实施阶段定具体安装方式) |
| **M17** `.claude/hooks/meta-scope.conf`(新建) | **新建配置数据**(A2 决策 D18):glob 列表 + ! 排除规则 + 注释 | M15 / M16 hook 读;scope 扩展不改 hook 代码 | harness 自身仓库;**不分发下游** |
| **M18** `.claude/settings.json` | 在 `Stop` hook 数组追加 M15 注册行;不注册 M16(M16 是 git hook,通过 `.git/hooks/pre-commit` 链接) | 让 Claude Code 平台触发 M15 | harness 自身仓库;**不分发下游**(D19 a 方案,第四轮 — 改由 M14 setup.sh line 71 cp M19 模板而非 M18,下游获得无 meta hook 注册的 settings.json) |
| **M19** `harness/templates/settings.json`(新建分发模板) | **新建**(D19 a 方案,第四轮新增):结构同 M18 但**移除 M15 在 Stop hook 数组的注册条目**;由 M14 setup.sh line 71 改造后的 source 拷贝到下游。**第七轮 fix-1 修:M19 入 §1.3 F 组 scope + M17 scope.conf `harness/templates/*.json` glob** | 下游零 meta hook 注册行,直接实现 §1.3 兼容性"下游项目不受 meta 治理污染";同时改 M19 必须走 meta-review(无后门) | 影响所有未来安装下游;harness 自身不使用此模板(自身用 M18) |
| **M20** `.claude/hooks/session-init.sh`(扩展现有) | **扩展**(第八轮 fix-8 A 部分):加反审检测段(§3.1.10)— 检测条件 `git log` 主分支含 P0.9.1 落地 commit + `docs/audits/` 中无 covers 含本 spec 路径的 audit;两条件同时成立 → 注入 system-reminder。**下游分发隔离**:反审检测段需排除在分发版本外(实施阶段定具体方式 — 候选:marker 包裹 setup.sh sed 删除,或拆分为独立文件不分发) | 场景 1 反审触发(第八轮 fix-8 A 部分;C 部分由 §4.1.7 handoff 字段承接) | harness 自身仓库;**反审检测段不分发下游**(分发隔离方式实施阶段定) |
| **`docs/active/handoff.md` 模板加反审待办字段示例**(第八轮 fix-8 C 部分) | **轻改动**:在合适位置加 `## 反审待办` 字段示例(初始值 + 完成后值);引导 P0.9.1 落地最后一次 finishing 时填写 | 场景 1 反审 C 部分留痕(与 M20 A 部分主动推互补) | 所有未来 handoff 填写(P0.9.1 落地最后一次 finishing 起) |

**D19 a 方案落地总结**(第四轮 — 替代第三轮 c 方案):

第三轮自检发现 D19(M18 settings.json 分发到下游后 M15/M16 hook 空运行问题),原选项 a/b/c:
- a: 不分发 meta hook 注册(零污染) ← **第四轮用户拍板选 a**
- b: 分发 + hook 内 marker 条件 exit 0(软污染)
- c: 隐式空运行(读不到 scope.conf 自然 exit 0,软污染) ← 第三轮原选

第四轮升级 a 的实施方式:
1. 新增 M19 `harness/templates/settings.json`(分发模板,无 meta hook 注册)
2. 改 M14 setup.sh line 71 source: `.claude/settings.json` → `templates/settings.json`
3. M18 标记为"不分发下游"(harness 自身用)
4. **不**在 M15/M16 hook 内加条件检查或 marker(那是 b 方案,a 方案不需要)
5. 配合 D12 命名前缀过滤,下游一个 meta-* 文件 + 一条 meta hook 注册都看不到

a 方案优于 b/c:
- 下游污染:**零**(a) vs 软污染(b/c)
- 下游用户认知:看不到 meta hook,零困惑(a) vs 见 hook 但 disabled / 啥也不做(b/c,需读条件代码或可能误为 bug)
- 实施成本:**新增 1 文件 + 改 setup.sh 1 行**(a) vs 每 hook marker 检查(2×5 行)+ marker 机制设计(b/c)
- 维护负担:双轨 settings.json(a — harness 加 meta hook 时只改 M18 不动 M19)vs 单轨 + 每加 meta hook 都要 marker(b/c)

### 8.2 不改动但需要验证兼容的

| 文件 / 模块 | 验证什么 |
|---|---|
| `docs/governance/brainstorming-rules.md` | meta finishing 不冲突(brainstorming 阶段不涉及 meta 特殊处理)。需验证:brainstorming 阶段识别 scope=meta 时是否能平滑引向 M1(应能 — brainstorming 阶段产出 spec,实施阶段才触发 meta-review,见 §6.5 A6 兼容验证) |
| `docs/governance/design-rules.md` | 设计阶段是否兼容 meta 改动 — 本 spec 自身正用 design-rules,若本 spec 通过则证明兼容。M2 引 design-rules 10 项全局自洽检查,**不改** design-rules |
| `docs/governance/planning-rules.md` | meta 改动进入 planning 是否兼容 — 现有 planning-rules 不区分 feature / meta,meta 沿用 |
| `docs/governance/implementation-rules.md` | meta 改动的"实现"是编辑 markdown / 写 hook / 改 setup.sh — implementation-rules 核心规则(最小变更 / 文档先行 / lint)均适用。lint 对 markdown / shell 退化为 prettier(已配置)+ shellcheck(实施时定),不阻断 |
| `docs/governance/review-rules.md` | code-review 对 meta 改动的 markdown / shell 适用性。现有 review-rules 针对代码,但 meta 改动审查主要由 meta-review(M2)承担,review-rules 不冲突 |
| `docs/governance/testing-rules.md` + `docs/references/testing-standard.md` | meta 改动 Evidence Depth 走 M1 meta evidence depth 节(B1 决策合并),不走 testing-standard.md L1-L4。两个语义需要**互不引用**,各自指明适用域(feature vs meta)。具体:testing-standard.md 顶部加一句"本文档适用于 feature 改动;meta 改动证据语义见 docs/governance/meta-finishing-rules.md 的 evidence depth 节"(此句改动属 testing-standard.md 改动,**应进 §8.1**)— **本节移到 §8.1 补充** |
| **`docs/references/testing-standard.md`(实际需轻改动)** | (从 §8.2 提到 §8.1)顶部加适用域声明 1 行 | 与 M1 的 evidence depth 定义节互不引用,语义清晰 | feature 测试评审 |
| 现有 `docs/decisions/*.md`(所有历史 decision) | 按 §1.3 + 风险警示 5"不追溯审查 P-1/P0/P0.5 已完成项";本 spec 不反向审查已有 decision |
| `docs/RUBRIC.md`(通用基线 5 个惩罚项 + 项目特定 3 维空) | M2 pattern 节的"推荐维度"引用 RUBRIC 维度名时与 RUBRIC.md 一致(无覆写权重)。不改 RUBRIC.md |
| `docs/ARCHITECTURE.md` | Bootstrap 例外 1 已声明对 harness 自身不适用。本 spec 未引入新架构要求。下游项目若定制 ARCHITECTURE.md,不受 M3 改动影响(M3 是 harness 自身根 CLAUDE,M4 才分发) |
| `docs/references/multi-agent-review-guide.md` | meta-review 流程遵循对抗-决策分离 + 共识/分歧/盲区 + 适用性表(对抗 / 模式匹配 / 事实统计)。**不改** |
| `.claude/hooks/check-handoff.sh`(现有 Stop hook) | 与 M15 共同在 Stop 数组运行,执行顺序问题:check-handoff.sh 检 handoff 是否更新,M15 检 audit。**两 hook 独立,无依赖**,顺序无所谓。但 stderr 输出顺序对用户体验有影响 — M18 settings.json 注册顺序可由实施时定 |
| `.claude/hooks/check-finishing-skills.sh` + `.claude/hooks/check-evidence-depth.sh`(现有 Stop hook) | 同上,与 M15 共在 Stop 数组,无依赖。**check-evidence-depth.sh 仅检字段名 `## Evidence Depth` 非空 + 非 `[待填]`,不解析档位值** — meta-L1~meta-L4 档位值通过(B7 决策 D10 选 a) |
| `.claude/hooks/block-dangerous.sh` + `.claude/hooks/check-module-docs.sh`(其他现有 hook) | M15 / M16 不与之冲突;hook 之间独立 |
| **`.claude/hooks/session-init.sh`(已存在,M20 扩展 — 第八轮 fix-8 A 部分)** | M20 加反审检测段(§3.1.10),与现有 PROGRESS / handoff 注入并列,不互相覆盖。下游分发版本不含反审检测段(分发隔离方式实施阶段定) — 与 D19 a 方案"零污染"一致 |
| `.claude/skills/system-design/SKILL.md` | designer 工作流是否能处理 meta 改动 — 本 spec 正被 system-design skill 处理的 meta 改动,流程跑完即证明兼容 |
| `.claude/skills/structured-handoff/SKILL.md` | handoff Evidence Depth 字段在 meta vs feature 两种档位值下归档是否兼容。**字段结构同(B7 a 方案)**,structured-handoff 按字段名归档 — 兼容 |
| `.claude/skills/skill-extract/SKILL.md` | meta 改动是否触发 skill-extract — 现有 skill-extract 在 evaluate 通过后无模式可跳过,meta 改动若无新模式同样跳过 |
| `.claude/skills/session-search/SKILL.md` | session-search 检索 meta-review audit — audit 是 markdown 在 `docs/audits/`,session-search 以 JSONL 为源,二者不同源 — 不冲突,但 audit 不被 search 默认覆盖,需单独 grep `docs/audits/` |
| `docs/active/handoff.md` 现有模板 | meta 改动收尾时填写 — 由 M1 引导;Evidence Depth 按 D10 同字段(B7 a),meta-L 档位值;新增 `## meta-review: skipped(理由)` 字段(可选,仅 skip 场景需要)— 模板可选地加该字段示例 |
| **`docs/active/handoff.md` 模板(实际需轻改动)**| (从 §8.2 提到 §8.1)在 Evidence Depth 字段下加"档位说明"提示 + 在合适位置加 `## meta-review: skipped(理由)` 字段示例 | 引导调度者写正确格式 | 所有未来 handoff 填写 |
| `.claude/agents/designer.md` | designer 在 fork 时是否要处理 meta 模式?— 本轮 designer 处理 meta 改动设计 spec(本 spec 即实例),designer 文件**不需改**(designer 不区分 meta vs feature 设计) |
| **M18 vs M19 双轨兼容验证**(D19 a 方案,第四轮新增) | (1) harness 自身仍用根目录 `.claude/settings.json`(M18,含 M15 在 Stop hook 数组的注册条目),M15 hook 在 harness 自身正常触发,不受 a 方案影响;(2) 模板 `harness/templates/settings.json`(M19)结构与 M18 同(hooks 对象内 PostToolUse / PreToolUse / SessionStart / Stop 四数组),只删 meta hook 段(目前是 M15 这一条);(3) 兼容性验证方式:实施后 jq diff 比较 M18 vs M19 仅 Stop 数组内"check-meta-review.sh"一行差异(实施阶段定具体校对方式);(4) 下游获得 M19(via M14 setup.sh line 71)— 下游 settings.json 完全无 meta hook 注册行,符合 §1.3 兼容性"零污染" |

### 8.3 P0.9.1.5 兼容验证(A6 决策 + 第八轮 fix-7 触发条件 B)

P0.9.1 流程必须能审 P0.9.1.5 自己的 spec(吃自己狗粮)。详见 §6.5。**本节列出 P0.9.1.5 启动时的接口验证项**:

**触发节奏**(第八轮 fix-7 B):P0.9.1 落地后不强制启动 P0.9.1.5,**M0-M4 启动前由用户评估**是否先做。下表"P0.9.1.5 brainstorming 启动"前置条件即"用户在 M0-M4 启动前决定先做 P0.9.1.5"。

| 验证项 | 期望行为 |
|---|---|
| **(前置)M0-M4 启动前用户评估** | brainstorming-rules / handoff 引导用户评估 P0.9.1.5 是否先做(实施层在 P0.9.1.5 自身或 P0.9.3 落地) |
| P0.9.1.5 brainstorming 启动(若用户决定先做) | 不触发 meta-review(brainstorming 阶段产出 spec 不属 governance 改动) |
| P0.9.1.5 design 阶段 | 不触发 meta-review(design 阶段产出 spec 不属 governance 改动) |
| P0.9.1.5 实施阶段(写新 governance 文件 + 改 CLAUDE.md) | 触发 meta-review(scope=meta);走 §3.1.4 流程产 audit |
| audit YAML covers 字段 | 含 P0.9.1.5 涉及的 governance 文件路径 |
| 不存在死锁 | meta-review 流程不依赖 P0.9.1.5 产出物(P0.9.1 是 P0.9.1.5 之前的阶段),无循环依赖 |
| **(可选)用户决定不先做 P0.9.1.5** | 直接 M0-M4 用 P0.9.1 流程,M0 实战回流可能反向定义 P0.9.1.5 真实需求 |

### 8.4 改动文件与模块清单对齐验证

所有 §2.1 标"新建"或"改动"的模块,在本 §8.1 都有对应条目:

| §2.1 编号 | §8.1 有无对应 | 备注 |
|---|---|---|
| M1 新建 | ✅ | governance(含 evidence depth 定义节) |
| M2 新建 | ✅ | governance(含 pattern 定义节) |
| M3 改动(升级) | ✅ | `/CLAUDE.md`(harness 根) |
| M4 改动(轻) | ✅ | `harness/CLAUDE.md`(分发模板) |
| M5 改动 | ✅ | finishing-rules 加分流入口 |
| M6-M9 改动 | ✅ | 4 agent 按模态分型改造 |
| M10-M13 改动 | ✅ | 4 skill 引 M2 |
| M14 改动 | ✅ | setup.sh 命名前缀过滤 + line 71 改 source 指向 M19(D19 a 方案) |
| M15 新建 | ✅ | check-meta-review.sh Stop hook(hook 内不加 marker — D19 a 方案) |
| M16 新建 | ✅ | check-meta-commit.sh Git pre-commit(同上) |
| M17 新建 | ✅ | meta-scope.conf 配置数据 |
| M18 改动 | ✅ | settings.json 注册 M15;**不分发下游**(D19 a 方案) |
| **M19 新建** | ✅ | **`harness/templates/settings.json` 分发模板,无 meta hook 注册(D19 a 方案,第四轮新增)** |
| **M20 扩展** | ✅ | **`.claude/hooks/session-init.sh` 加反审检测段(§3.1.10,第八轮 fix-8 A 部分)** |
| (P0.9.2/P0.9.3 占位) | ❌(D6 决策 — 不登记) | §1.3 边界声明已锁定 scope 外 |

**新增的次要文件改动**(本节扫描出来):
- `docs/references/testing-standard.md` 顶部加适用域声明 1 行(与 M1 evidence depth 节呼应,语义清晰)
- `docs/active/handoff.md` 模板加 Evidence Depth 档位说明 + skipped 字段示例 + **反审待办字段示例(第八轮 fix-8 C 部分)**

这三项**应纳入 P0.9.1 实施 scope**(轻改动,与 M1 / M5 同批落地)。

---

**第 8 节自检**:

- [x] 改动已有文件时,所有调用方都考虑到了:M3 升级影响调度者每次会话开头读;M4 模板影响下游所有项目;M5 finishing-rules 分流影响 feature + meta 双路;M14 setup.sh 影响下游分发;M18 settings.json 影响 hook 注册(已发现并处理 M15 在下游空运行问题,见 §8.1 末)
- [x] 新模块与已有模块交互没引入不兼容:§8.2 逐一列出验证;特别处理 check-evidence-depth.sh 与 D10 a 方案的兼容性(同字段名)+ structured-handoff / skill-extract / session-search 的兼容性;**第八轮 M20 session-init.sh 扩展**已在 §8.2 加项,反审检测段与现有 PROGRESS / handoff 注入并列不互覆盖
- [x] §2 标"改动"的模块在 §8.1 有具体改动文件:§8.4 对齐表已映射(第八轮加 M20)
- [x] 占位模块按 D6 决策处理:不登记于 §8.1,符合 D6
- [x] 新发现的次要改动(testing-standard.md + handoff.md 模板)已纳入 §8.4 P0.9.1 实施 scope;**第八轮 fix-8 C 部分** handoff 模板加反审待办字段示例已纳入
- [x] P0.9.1.5 兼容验证(A6)已在 §8.3 列出接口验证项;**第八轮 fix-7 触发条件 B(灵活)** 已在 §8.3 表加 "M0-M4 启动前用户评估" 前置项
- [x] 设计变更引发的新决策 D19(下游 hook 空运行)在 §8.1 末发现并已同步到 §7 决策表(D19),**第四轮用户拍板从 c 升级为 a 方案**(零污染优于软污染):新增 M19 `harness/templates/settings.json` 模板 + M14 setup.sh line 71 改 source,下游零 meta hook 注册,直接实现 §1.3 兼容性
- [x] **第八轮 fix-7 / fix-8 / fix-9 用户拍板落地**:fix-7 P0.9.1.5 触发 = B(灵活),§1.3 / §6.5 / §8.3 同步;fix-8 反审触发 = A+C 组合,§3.1.10 + §4.1.7 + §6.4 + §8.1 (M20) 四处呼应;fix-9 (iii) 修 §3.1.9 covers 比对 + (v) 修 §3.1.1 + §4.1.2 治理文件入 scope / 只排产出物 + (i)(ii)(iv)(vi) 登记 §1.3 + §5 B18

---

## 9. 全局自洽性检查

> design 第三轮修订 + 第四轮 4 项最小修补 + 第七轮 9 项 fact 漏洞修补 + 第八轮 3 项 decision 落地完成,逐项核对结论(bootstrap 例外项标"不适用"):

- [x] 需求 ↔ 模块:§2.1 末场景→模块映射表,§1.2 五场景每场景对应到 M1-M20 实现路径(第八轮新增 M20 `.claude/hooks/session-init.sh` 反审检测段对应 fix-8 A 部分)
- [x] 模块 ↔ 接口:§3.1.1 - §3.1.10 十个流程契约覆盖 §2.1 模块表中所有"新建/改动"模块的职责(M19 由 §3.1.8 承接;第八轮 §3.1.10 新增,M20 反审检测;§3.1.9 hook 逻辑第八轮 fix-9 (iii) 修 covers 比对明示;§3.1.1 排除规则第八轮 fix-9 (v) 修治理文件入 scope / 只排产出物)
- [x] 接口 ↔ 数据:§4.1.1 - §4.1.7 七个数据实体定义对应 §3.1 各契约的输入/输出字段(audit_trail / scope.conf / handoff skip / evidence depth / 失效规则 / distribution_settings_template / **第八轮新增 §4.1.7 handoff_self_review_pending — fix-8 C 部分**);§4.1.2 scope.conf 排除规则第八轮 fix-9 (v) 修对齐
- [x] 数据 ↔ 边界:§5.1 边界条件 B1-B18 对每个数据字段的空值/异常/失效场景有处理(第八轮新增 B18 已识别绕过路径处理 — fix-9 (i)(ii)(iv)(vi))
- [-] 依赖 ↔ 架构:**不适用**(Bootstrap 例外 1:ARCHITECTURE.md 对 harness 自身不适用,见 §1.6)
- [x] 决策 ↔ 需求:§7.1 D1-D19 每条决策"原因"列引用 §1 需求约束或 brainstorming 拍板,均不破需求边界;第八轮 fix-7 / fix-8 / fix-9 已由用户拍板,decision 文件状态 🟢,后续影响落地 §1.3 / §3.1.x / §4.1.x / §5.1 / §6.4 / §6.5 / §8.x / §9
- [-] 决策 ↔ 架构:**不适用**(同上 Bootstrap 例外 1)
- [x] 影响 ↔ 模块:§8.4 对齐表逐项映射 §2.1 模块编号 ↔ §8.1 改动条目,M1-M20 全覆盖(第八轮加 M20),占位项按 D6 不登记
- [x] RUBRIC ↔ 设计:§7.3 RUBRIC 通用基线 5 个惩罚项全列应对方式(B11 第七轮撤回 bootstrap 第 5 维加维,不再混淆"维度"与"惩罚项");§7.4 项目特定 3 维按 Bootstrap 例外 2 留痕
- [-] 契约 ↔ 接口:**不适用**(§3.3 已声明本功能不涉及 API 接口)
- [x] **第八轮 fix-9 (v) bootstrap 循环可接受性一致**:§1.3 边界声明 + §3.1.1 排除规则 + §4.1.2 M17 scope.conf 排除规则 + §3.1.9 hook 逻辑均同步"治理文件入 scope / 只排除产出物 / bootstrap 循环可接受"
- [x] **第八轮 fix-8 反审 A+C 触发四处呼应**:§3.1.10 SessionStart hook(A 部分) / §4.1.7 handoff 反审待办字段(C 部分) / §6.4 bootstrap 自洽验证(A+C 描述) / §8.1 影响表(M20 + handoff 模板改动)

---

## Brainstorming → Design 切换检查

按 `docs/governance/brainstorming-rules.md` 收敛判断：

- ✅ 每个核心场景都能写出"谁 → 做什么 → 系统做什么 → 看到什么"的完整描述（1.2 五个场景均完成）
- ✅ 需求确认清单覆盖用户说过的所有要点
- ✅ "不做什么"列了多项明确排除
- ✅ 前置已确认的判断作为"前置已确认"标记
- ✅ RUBRIC 惩罚项已基于通用基线标记（项目特定空白已元警告）

**Brainstorming 阶段可收敛**。下一步：design 阶段由调度者 fork designer agent 填写第 2-8 节，再过 `/design-review` **4 挑战者**审查(bootstrap 4 维 — 见 §6.4 / §7 D7;B11 第七轮已撤回过度工程化第 5 维加维)。

**Design 阶段的特殊注意**：
1. designer agent 填写时，需**明确判定**本 spec 属标准级还是重量级（我初判重量级，待 designer 复核）
2. ARCHITECTURE.md 对 harness 自身不适用 —— designer 遇到"依赖 ↔ 架构"自检项时需要判"不适用"或先定义 harness 自身的层级概念
3. design-review 阶段会用到"每次按主题定制"维度的新机制 —— 但该机制正是 P0.9.1 要产出的，**存在 self-reference 悖论**。权宜：本 spec 的 design-review 使用本会话已原型验证的 **4 挑战者 / 4 维**(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)作 bootstrap 维度(B11 决策 D7 第七轮按"meta 系统在自己落地前不可证 = bootstrap 悖论"原则撤回过度工程化第 5 维加维,详见 §6.4 / §7 D7)，P0.9.1 落地后反向验证这 4 维是否符合新机制的"推荐清单"

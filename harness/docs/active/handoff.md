# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-16
当前阶段: 知识系统 Step 2「★ 设计层到手边」上游段(①体检→②B坑索引→③a注册表→③b漂移检测)全部收口、合并入 main;**做3再做1 完成**。C(下游设计层导航)押后,待用户定下一方向。
当前分支: main

## 目标

知识系统 Step 2「★ 设计层到手边」落 harness = 漂移检测 + 触点完整性。用户执行序:**①体检漏改修复 ✅ → ②B 已知坑索引 ✅ → ③a 触点机读注册表(地基)✅ → ③b 漂移检测机制 ✅**。A+B 上游(harness 自身),C(下游设计层导航)押后。

## 进度

### 已完成
- **③b 漂移检测机制 drift-scout**(2026-06-16):新建 `.claude/agents/drift-scout.md`(收口·凭证批·audit 内 fork,读 ③a 注册表逐触点判 5 类判据、报告分层、只读不写、软降级;镜像 freshness-scout 形态)+ setup.sh 自指 cp + finishing-rules step 19-21(门控=仅凭证批自动跑、不依赖选维)。设计全链(brainstorming 选 scout B→spec→自检→design-review dogfood 两轮→4 任务 subagent-driven→收口)。**红线测前置实证**:baseline 干净仓库 13✅ 不误报 + 注入两真漂移精确逮 TP-09 分发链/TP-06 逐字。audit `audit-2026-06-16-220000-drift-detection.md` verdict=pass(5 挑战者 4pass+1concern,0🔴 2🟡登记),对账账齐(covers 3 文件)。
- **①②③a**(2026-06-16,已并入 main):①体检漏改修复(audit-183410)/ ②B known-pitfalls-index(31 坑,非凭证)/ ③a 触点机读注册表 13 触点(audit-192154 pass-after-revision)。详见 ROADMAP「知识系统 backlog」Step 2 节。

### 进行中
- 无(Step 2 上游段收尾)。观察期沿用:开场规程第 3 步新鲜度侦察 + 凭证批 audit 内 drift-scout 漂移检测。

### 阻塞
无。

## 下一步

1. **C 下游设计层导航(押后)**:上游(harness 自身漂移检测/触点完整性)已理清,下游产品侧"设计层到手边"导航待用户拍板启动(走一整轮 brainstorming→设计→实现→收口)。
2. 或用户新方向。**Step 2 观察项**(③b 语义判类判松率未实证 / drift-scout↔registry 派生未登 TP 行 / ③a 抽取列 / 门控 3 边沿)住 ROADMAP,非阻断。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> .claude/agents/drift-scout.md — ③b 漂移侦察员契约(读注册表逐触点判 5 判据)
- -> docs/audits/audit-2026-06-16-220000-drift-detection.md — ③b 治理审查(5 挑战者 pass;红线测实证)
- -> docs/governance/touchpoint-registry.md — ③a 触点机读注册表(13 触点;drift-scout 喂料地基)
- -> docs/ROADMAP.md「知识系统 backlog」Step 2 节 — 上游段 ①②③a③b 全记录 + 观察项

## 关键上下文

- **Step 2 上游段执行序(用户拍板)**:①✅→②B✅→③a✅→③b✅;C 下游导航押后。做3再做1 完成。
- **drift-scout 门控**:仅凭证批(本批命中 credentials.conf 须产 audit)在 audit 内自动 fork,**不依赖审查者选触点完整性维**;人工触点完整性维(review-rules 条件必选)互补深审。软不阻断、无 agent 运行时/fork 失败回落人工维。scout 只读不写,现状列调度者手工回填。
- **守住**(若再碰):注册表 13 行 + 类型 enum{双写对/同核拷贝组/分发链/漂移点}/ 判据 enum{逐字一致/结构等价/glob覆盖/存在性/单源派生一致}零改;对账三命令 / credentials §8(含第9条 §8↔registry)/ finishing 既有 step / 既有 4 scout 契约 / preferences 零改。
- 开场对账三命令 + 第 3 步开场新鲜度侦察(根 CLAUDE.md 会话开场规程)。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 是 gawk 扩展语法,非 gawk 环境(mawk/busybox/BSD awk)**解析失败 → 该 audit 不贡献 covers**(非"死锁";已纠;独立待办)。详见 known-pitfalls-index。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ ③b implementer 建 drift-scout.md 契约 + 3 任务各独立 reviewer pass(0🔴0🟡);静态核契约一致/形态镜像/守住零改
- L2: ✅ 红线测前置实证 scout 真能逮漂移(baseline 13✅ 不误报 + 注入两漂移精确逮 TP-09/TP-06)+ 守住 8 项 git diff 零改实证 + 对账账齐(covers 3 文件)
- L3: ✅ 治理审查 audit pass(audit-2026-06-16-220000;5 挑战者 4pass+1concern,0🔴 2🟡登记观察)
- L4: ✅ meta-L4 正向数据点(design-review review-scout dogfood 第 3 次未退化 + 收口当场 drift-scout 自跑红线测自验,自举闭环)

## CI 阻断
❌ 无 CI 阻断(harness meta:子智能体契约 + setup.sh cp + finishing 工序;验证 = 静态核 + 红线测 fork 真 scout + 端点对源 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

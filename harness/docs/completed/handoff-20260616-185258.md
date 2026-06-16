# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-16
当前阶段: 知识系统 Step 2(★ 设计层到手边)进行中;①体检漏改修复 收口完成、合并入 main;下一步 ②B known-pitfalls-index
当前分支: main

## 目标

知识系统 Step 2「★ 设计层到手边」落到 harness = 漂移检测 + 触点完整性(自仓库真痛点;漂移腐 Step1 留此)。用户把它拆为执行序:**①体检漏改修复 ✅ → ②B 已知坑可索引层 → ③a 触点机读注册表(地基)→ ③b 漂移检测机制(注册表之上,scout/混合)**。C(下游设计层导航)押后(上游理清再设计)。

## 进度

### 已完成
- **设计层健康体检(2026-06-16,两阶段侦察)**:recon 摸 territory + 5-detector 实查。结论:**大体健康**(28🟢:§8 拷贝组/review-rules↔workflow.js 常量双写/对账三命令/新鲜度三处同核 大多一致),抓到 **2🔴+1🟡**。
- **①体检漏改修复(2026-06-16)**:🔴 setup.sh 补 cp freshness-scout.md(下游开场会 fork 不存在 agent)+ 🟡 review-rules L14 括号补类目+标"以 conf 为准" + 🔴 gawk 坑描述纠正(死锁→扩展语法非 gawk 环境解析失败,对齐 hook 头注)。治理审查 3/3 pass 零🔴🟡。audit `audit-2026-06-16-183410-health-fixes.md`,对账账齐。
- 前序(本会话):freshness 反腐烂(Step1)+ code-review-scout + review-scout backlog 清理。

### 进行中
- 知识系统 Step 2:②B 待启。
- 观察期:开场规程含第 3 步开场新鲜度侦察(freshness 已上线)。

### 阻塞
无。

## 下一步

1. **②B known-pitfalls-index**(料已齐):把 5-detector I-5 摸到的 **15 类坑**(待办5/搁置4/观察3/关闭3:codex搁置/P0.9.2四项/D类残留/review-scout退化meta-L4/非ultracode痛点/漂移腐留Step2/治理批无安全扫/批级观察项簇散ROADMAP4段…)理成按场景可索引的 `known-pitfalls-index` + frontmatter 标"是否影响自仓库开发"。**注:体检 scan 可重跑**(只读现状),细节在本会话 scan task `wooowlm6y` 输出 / 重跑即得。
2. **③a 触点机读注册表(地基)**:把 §8 散文 + 体检 类1 的 **11 双写对/触点** 结构化成机读注册表(每条:文件A:锚 ↔ 文件B:锚 + 判据),让 hook/scout 有据。
3. **③b 漂移检测机制**:注册表之上建可复用漂移检测(scout 驱动 / 混合;收口时跑;机械化现有人工"触点完整性维")。
4. C(下游设计层导航):③ 完后再设计(上游理清后)。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/audits/audit-2026-06-16-183410-health-fixes.md — ①体检漏改修复治理审查(3/3 pass)
- -> docs/references/2026-06-16-knowledge-system-what-to-preserve.md — 知识系统收敛留痕(Step1/2 排序 + 该保留什么/按场景/边界)
- -> docs/ROADMAP.md「知识系统 backlog」节 — 方向进展(Step1✅ + Step2 进行中)

## 关键上下文

- **Step 2 执行序(用户拍板)**:①修复✅→②B索引→③a触点机读注册表→③b漂移检测机制;C 押后。
- **体检证明了 ★ 价值**:漂移检测 dogfood 抓到 2 个真漏改(setup.sh 漏分发 + 自己抄了 7 遍的 gawk 坑描述错误)。**现状无 hook 机械查双写对/漂移点,全靠人工触点完整性维**(③b 要机械化它)。
- **守住**(若再碰):对账三命令 / credentials §8 各拷贝组 / references 过时横幅 / audit 失效 / preferences 格式 零改。
- 开场对账三命令 + 第 3 步开场新鲜度侦察(根 CLAUDE.md 会话开场规程)。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 是 gawk 扩展语法,在非 gawk 环境(mawk/busybox/BSD awk)**解析失败 → 该 audit 视为不贡献 covers**(**非"死锁"**——旧 handoff 抄错,已纠;对齐 hook 头注 L39-41;历史遗留,独立待办)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 5-detector 体检(独立实查 territory + 抓 2🔴1🟡)+ ①修复 3 挑战者审 pass
- L2: ✅ ①修复守住零改实证(setup.sh 分发链/review-rules 判定语 byte-identical)+ 触点修复后一致(freshness-scout 分发闭/13类目↔conf/gawk↔头注)+ 对账账齐
- L3: ✅ 治理审查 audit verdict=pass(audit-2026-06-16-183410;3 挑战者)
- L4: ➖ 不适用(纯触点修复;漂移检测可复用机制[③b]落地后才有运行时 meta-L4)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown + bash + 子智能体契约;验证 = 静态核 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

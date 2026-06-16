# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-16
当前阶段: 知识系统 Step 2 进行中;①体检漏改修复 + ②B known-pitfalls-index 收口完成、合并入 main;下一步 ③a 触点机读注册表
当前分支: main

## 目标

知识系统 Step 2「★ 设计层到手边」落 harness = 漂移检测 + 触点完整性(自仓库真痛点)。用户执行序:**①体检漏改修复 ✅ → ②B 已知坑可索引层 ✅ → ③a 触点机读注册表(地基)→ ③b 漂移检测机制(scout/混合)**。C(下游设计层导航)押后。

## 进度

### 已完成
- **设计层健康体检(2026-06-16)**:recon + 5-detector。大体健康(28🟢),抓 2🔴+1🟡。
- **①体检漏改修复(2026-06-16)**:setup.sh 补 freshness-scout 分发 + gawk 坑描述纠正(死锁→解析失败)+ review-rules 括号补类目。治理审查 3/3 pass。audit `audit-2026-06-16-183410-health-fixes.md`。
- **②B known-pitfalls-index(2026-06-16)**:31 条坑(4✅+27活)按 8 场景可查索引,freshness frontmatter 自保鲜,坑权威住源文档、只指不抄(反双写腐)。implementer 汇编 + 独立 reviewer 验真(无臆造/指针准/gawk纠正版)。references 标准件,**非凭证、无 audit**。
- 前序(本会话):freshness 反腐烂(Step1)+ code-review-scout + review-scout backlog。

### 进行中
- 知识系统 Step 2:③a 待启。观察期:开场规程含第 3 步新鲜度侦察。

### 阻塞
无。

## 下一步

1. **③a 触点机读注册表(地基)**:把 credentials §8 散文 + 体检类1 的 **11 双写对/触点** 结构化成机读注册表(每条:文件A:锚 ↔ 文件B:锚 + 判据 + 是否逐字/结构等价),让 hook/scout 有据可依、可机械 diff。这是 ③b 漂移检测机制的地基。
2. **③b 漂移检测机制**:注册表之上建可复用漂移检测(scout 驱动/混合;收口时跑;机械化人工"触点完整性维")。
3. C(下游设计层导航):③ 完后再设计。
4. **小观察项**:known-pitfalls-index 现经 references/README + handoff 指针发现;若要更广 agent 发现性,补 CLAUDE.md 文档索引地图行(命中凭证,小 follow-up)。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/references/known-pitfalls-index.md — 已知坑按场景索引(②B;写码/调试前查)
- -> docs/audits/audit-2026-06-16-183410-health-fixes.md — ①体检漏改修复治理审查
- -> docs/references/2026-06-16-knowledge-system-what-to-preserve.md — 知识系统收敛留痕(Step1/2 排序)
- -> docs/ROADMAP.md「知识系统 backlog」节 — 方向进展

## 关键上下文

- **Step 2 执行序(用户拍板)**:①✅→②B✅→③a 触点机读注册表→③b 漂移检测机制;C 押后。
- **③a 输入**:体检类1 摸的 11 双写对/触点(§8 已登记 8 条 + 散落 AGENTS×2/CLAUDE×2/spec↔workflow.js 等)。**现状无 hook 机械查双写对/漂移点,全靠人工触点完整性维**(③b 机械化它)。体检 scan 可重跑(只读现状)。
- **守住**(若再碰):对账三命令 / credentials §8 各拷贝组 / references 过时横幅 / audit 失效 / preferences 格式 零改。
- 开场对账三命令 + 第 3 步开场新鲜度侦察(根 CLAUDE.md 会话开场规程)。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 是 gawk 扩展语法,在非 gawk 环境(mawk/busybox/BSD awk)**解析失败 → 该 audit 不贡献 covers**(非"死锁";已纠;对齐 hook 头注 L39-41;独立待办)。详见 known-pitfalls-index。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ ②B implementer 汇编 + 独立 reviewer 验真(13抽样+全4已关闭,零臆造)；①修复 3 挑战者 pass
- L2: ✅ ②B 非凭证(references 标准件,git diff 仅 references)；①守住零改实证 + 对账账齐
- L3: ✅ ①治理审查 audit pass(audit-2026-06-16-183410);②B 无凭证义务(references,无 audit 必要)
- L4: ➖ 不适用(索引/修复无运行时;漂移检测机制 ③b 落地后才有 meta-L4)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown + bash + 子智能体契约;验证 = 静态核 + 来源验真 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

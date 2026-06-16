# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-16
当前阶段: 知识系统 Step 2 进行中;①体检漏改修复 + ②B 坑索引 + ③a 触点机读注册表 收口完成、合并入 main;下一步 ③b 漂移检测机制
当前分支: main

## 目标

知识系统 Step 2「★ 设计层到手边」落 harness = 漂移检测 + 触点完整性。用户执行序:**①体检漏改修复 ✅ → ②B 已知坑索引 ✅ → ③a 触点机读注册表(地基)✅ → ③b 漂移检测机制(注册表之上,scout/混合)**。C(下游设计层导航)押后。

## 进度

### 已完成
- **①体检漏改修复**(2026-06-16):setup.sh 补 freshness-scout 分发 + gawk 坑描述纠正 + review-rules 括号。audit `audit-2026-06-16-183410-health-fixes.md`。
- **②B known-pitfalls-index**(2026-06-16):31 条坑按 8 场景可查,坑权威住源只指不抄,freshness frontmatter 自保鲜。references 标准件,非凭证。
- **③a 触点机读注册表**(2026-06-16):新建 `docs/governance/touchpoint-registry.md`(13 触点机读表 = §8 机读派生形 + 体检散落触点;id/类型/端点/判据/来源/现状)+ credentials §8 加第9条(§8↔registry 派生双写)+ 指针;§8 1-8 逐字零改;MVP 只建数据现状全"待③b查"。治理审查 4 挑战者 2pass+2concern→2🟡修订(L39 覆盖判据 / TP-12 类型 enum)。audit `audit-2026-06-16-192154-touchpoint-registry.md` verdict=pass-after-revision,对账账齐。
- 前序(本会话):freshness 反腐烂(Step1)+ code-review-scout + review-scout backlog。

### 进行中
- 知识系统 Step 2:③b 待启。观察期:开场规程含第 3 步新鲜度侦察。

### 阻塞
无。

## 下一步

1. **③b 漂移检测机制(序里最后、最大;走一整轮 brainstorming→设计→实现→收口)**:在 touchpoint-registry(③a 地基,13 触点)之上建**可复用漂移检测**——读注册表逐触点查"端点是否对齐",报漂移、回填 registry 现状列。形态待 brainstorming 定(scout 驱动 / hook / 混合;触点完整性维既有人工的机械化)。触发待定(收口时跑最对——触点完整性维本就是收口审查维)。
2. C(下游设计层导航):③ 完后再设计(上游理清后)。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/governance/touchpoint-registry.md — 触点机读注册表(③a;③b 的喂料地基,13 触点)
- -> docs/audits/audit-2026-06-16-192154-touchpoint-registry.md — ③a 治理审查(4 挑战者;pass-after-revision)
- -> docs/references/known-pitfalls-index.md — 已知坑按场景索引(②B)
- -> docs/ROADMAP.md「知识系统 backlog」节 — 方向进展(Step2 进行中)

## 关键上下文

- **Step 2 执行序(用户拍板)**:①✅→②B✅→③a✅→③b 漂移检测机制;C 押后。
- **③b 输入 = touchpoint-registry(13 触点)**:它是 §8 机读派生形,每触点带端点+判据+现状(全"待③b查")。③b 读它逐触点查端点对齐、回填现状。**现状无 hook 机械查触点/漂移,全靠人工触点完整性维**——③b 机械化它。**registry 格式 = 结构化 markdown 表**(scout 直读、hook 可 awk 行)。
- **守住**(若再碰):对账三命令 / credentials §8 各拷贝组(含第9条 §8↔registry)/ references 过时横幅 / audit 失效 / preferences 格式 零改。registry 类型 enum{双写对/同核拷贝组/分发链/漂移点}、判据 enum{逐字一致/结构等价/glob覆盖/存在性/单源派生一致}。
- 开场对账三命令 + 第 3 步开场新鲜度侦察(根 CLAUDE.md 会话开场规程)。

## 已知问题

- check-audit-coverage.sh extract_covers 的 gawk 三参数 match 是 gawk 扩展语法,非 gawk 环境(mawk/busybox/BSD awk)**解析失败 → 该 audit 不贡献 covers**(非"死锁";已纠;独立待办)。详见 known-pitfalls-index。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ ③a implementer 建表 + 4 挑战者审(2🟡 内部契约修订)；机械核 §8 1-8 字节零改 + 13 触点端点真实
- L2: ✅ ③a 守住零改实证(§8 1-8 + 12 端点文件 UNCHANGED + 对账三命令 + preferences)+ 对账账齐(covers 2 文件)
- L3: ✅ 治理审查 audit pass-after-revision(audit-2026-06-16-192154;4 挑战者 bootstrap+触点完整性)
- L4: ➖ 不适用(③a 是数据地基无运行时;漂移检测 ③b 落地后才有 meta-L4)

## CI 阻断
❌ 无 CI 阻断(harness meta:markdown 注册表 + 子智能体契约;验证 = 静态核 + 端点对源 + audit 对账)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

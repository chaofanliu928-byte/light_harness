# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-18
当前阶段: **本轮开发完成 + 已推 GitHub**。知识系统 Step2 ★ 主项「设计层到手边」上下游闭合;收尾(#2 drift-scout count-agnostic / #3 边界留痕)+ README 多智能体梳理,全部合并 main 并 `push origin`(`light_harness`,origin/main 同步)。
当前分支: main

## 目标

harness 知识系统(llm-wiki 方向):让"代码答不出的"设计层背景按场景到手边 + 反腐烂 + 漂移检测。Step2 ★ 主项本轮闭合,机制建完待真实项目验。

## 进度

### 已完成
- **C「设计层到手边」**(2026-06-17,merged):机读地图 + fork 侦察员(克隆 ③b)+ 两洞补法 + 治理接线。audit verdict=pass(8 covers)/ drift-scout 15 触点✅ / fixture 红线 5 案 2 红线✓。
- **#2 drift-scout count-agnostic**(2026-06-18,merged):7 处「13 触点」→ 动态措辞 + TP-13 护栏泛化;exempt audit;行为零改。known-pitfalls 已闭。
- **#3 知识/偏好/规则边界厘清**(2026-06-18,merged):思考留痕 `references/2026-06-18-knowledge-preference-rule-boundary.md`(接续 §C「没定论」:两轴+流动 reframe / 三升格判据 / 执法连续谱 / 4 真缺口),真案例反推、不造机制。目录卡已登。
- **README 梳理**(2026-06-18,merged+pushed):多智能体重写根 README(主旨/核心思想/主线流程)+ harness/README 计数修;组件计数纠正实测(10 agents/8 skills/7 hooks/14 governance)。

### 进行中 / 阻塞
无。

## 下一步(新窗口照此续作)

1. **推真实项目验**(最有价值):整套机制(反腐烂 + 漂移检测 + 设计层到手边)在真实下游项目首用,采 **meta-L4** 数据(scout 误匹配率/编造率、下游写作率、误报/刷屏感)—— 自仓库 dogfood 审不到的盲区。
2. 边界厘清(知识/偏好/规则)随真案例解(照 #3 留痕 §1-§4 判据);#3 缺口 4(乐观偏差「判 0 不做」无兜底)是唯一可机制化候选,留后。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/references/2026-06-18-knowledge-preference-rule-boundary.md — #3 边界 heuristic + 4 真缺口(真案例来了照它判)
- -> docs/audits/audit-2026-06-17-230642-design-context-delivery.md — C 收口凭证(verdict=pass,8 covers)
- -> docs/superpowers/specs/2026-06-17-design-context-delivery-design.md — C 锁定 spec
- -> docs/decision-trail.md 2026-06-17 条 — C 抉择/赌注/裁决索引
- -> docs/ROADMAP.md「知识系统 backlog」Step 2 节 — backlog + meta-L4 待办

## 关键上下文

- **GitHub**:repo = `light_harness`(origin = https://github.com/chaofanliu928-byte/light_harness.git);本轮已 push,local main 与 origin/main 同步。
- **C 机制(已落地分发)**:进写码/调试/重构 → 调度者 pull fork `design-context-scout` → 读 `design-context-map.md` 两跳 → 按 scenario 取片 briefing。只读不写/软降级/⚠️不硬判。自仓库 dogfood 不建地图数据。
- **3 诚实赌注(用户接受为已知边界)**:①下游真写设计文档/README ②pull 够(无 push 强制)③模块边界清。稳定性推真实项目验。

## 已知问题

- check-audit-coverage.sh extract_covers gawk 三参数 match 是 gawk 扩展语法,非 gawk 环境解析失败(既有独立待办,详 known-pitfalls-index「hook 跨运行时」组)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 静态/结构核(各批形态/字段一致/接线成对,均过)
- L2: ✅ C fixture 红线 5 案验收(独立 verifier overall=pass,2 红线✓);README 多智能体 3 对抗审(0🔴 收口)
- L3: ✅ C 凭证 audit 5 维 + 方向评估 4 维 + drift-scout 15 触点✅;#2 exempt;对账账齐(26 凭证)
- L4: ➖ meta-L4 实战观察待真实项目(dogfood 自仓库审不到)
- 注:harness-meta 无运行时单测;验证 = 静态核 + fork fixture 红线 + 对抗审查 + 对账。

## CI 阻断
❌ 无 CI 阻断(harness meta;静态核 + fixture 红线 + audit 对账均已过)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: 2026-06-20
当前阶段: **活跃任务索引(active-task-index)实现完成 + 收口**。handoff 升格出「活跃任务索引」全链跑通(brainstorm→design→自检→design-review×2→修订→code-review→凭证 audit verdict=pass→方向评估通过),待合并 main。
当前分支: feat/active-task-index

## 目标

harness 知识系统(llm-wiki 方向)+ 台账机制。本批:让挂起任务线不被覆写蒸馏、让 AI 开场一眼知道有几条活 —— handoff 升格出「活跃任务索引」(方案B + 强度中,用户锁定)。

## 活跃任务索引

活跃任务: 0(进行中 0 / 挂起 0)

<!-- 一行一条人声明的任务线(方案B:不锚 git,含未开分支探索线)。状态枚举仅 进行中|挂起(与 promotion「阻塞(理由)」正交,不混)。 -->
<!-- 挂起行「复活触发器」列必填非空(何条件下重新捡起);进行中行填 —。指针 = -> docs/相对路径 — 为什么读 / — / 未沉淀线 [未沉淀]。 -->
<!-- 机读表头半角纪律:活跃任务: N(进行中 X / 挂起 Y);空账写 0 不写「无」。覆写时逐行重声明「这条还活着吗」(SKILL ③覆写步)。 -->
| 状态 | 任务 | 复活触发器 | 指针 |
|---|---|---|---|
| (无活跃任务) | | | |

## 进度

### 已完成
- **活跃任务索引**(2026-06-20,本批待并):`### 进行中/阻塞` 跨节升格为 `## 活跃任务索引`(T1 模板 + T2 check-handoff `--reconcile` 结构核 + T3 SKILL 覆写/自查 + §8 第10条/TP-16 双写 + live 迁移)。8 commits;凭证 audit verdict=pass(9 挑战者,无🔴)。

## 下一步(新窗口照此续作)

1. **推真实项目验**(最有价值):活跃任务索引 + 整套机制在真实下游首用,采 meta-L4(挂起线真实腐烂率/僵尸线实证/误报感)—— 自仓库 dogfood 审不到。
2. 知识系统 backlog 续(ROADMAP Step 2 节)。

## 待晋升暂存

<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

- -> docs/superpowers/specs/2026-06-19-active-task-index-design.md — 活跃任务索引锁定 spec(机制/4旋钮/3诚实限度)
- -> docs/decisions/2026-06-20-active-task-index.md — 方案B+中抉择/4旋钮/升级触发器
- -> docs/audits/audit-2026-06-20-104617-active-task-index.md — 凭证 audit verdict=pass(covers 5)
- -> docs/active/evaluation-result.md — 方向评估通过(4维)
- -> docs/ROADMAP.md「知识系统 backlog」Step 2 — backlog + meta-L4 待办

## 关键上下文

- **活跃任务索引机制**:开场读 handoff 顶部 `活跃任务: N(...)` 一眼计数;挂起行必填复活触发器;`check-handoff --reconcile` 机器核最窄(只表头文法+触发器非空,恒 exit 0);覆写时 SKILL ③逐行重建+④自查。
- **3 诚实限度(spec §10.2,强度中前提下接受为残余)**:①③在场性同源 / 僵尸线判断撞公设1(做事者自答,留「重」升级)/ 只部分规避 kb 击穿点5。

## 已知问题

- 无(本批);僵尸线实证/挂起线腐烂率待真实项目(meta-L4)。
- (既有)check-audit-coverage.sh extract_covers gawk 三参数 match 非 gawk 环境解析失败(详 known-pitfalls-index「hook 跨运行时」)。

## 晋升声明

promotion: 已核(上架: 无; 弃置: 0 条)

## Evidence Depth
- L1: ✅ 静态/结构核(T1 升格 / T2 段 / T3 步 / §8+TP-16 / live 迁移,形态对齐 + T1↔T3 token 逐字核)
- L2: ✅ check-handoff fixture 红线先红后绿(全角头/缺头/触发器空逮到 + 计数/措辞不越界 + section 边界,恒 exit 0;调度者独立复跑)
- L3: ✅ 凭证 audit verdict=pass(audit-2026-06-20-104617)+ code-review(review-scout)+ 方向评估通过
- L4: ➖ meta-L4 待真实项目(挂起线腐烂率/僵尸线实证,dogfood 审不到)

## CI 阻断
❌ 无 CI 阻断(harness meta;静态核 + fixture 红线 + audit 对账均过)

## context-chain: skipped(理由: harness 自仓库按 dogfood 边界不建 docs/context/,本仓无活链可核)

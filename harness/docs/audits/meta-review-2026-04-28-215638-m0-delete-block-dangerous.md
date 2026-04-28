---
meta-review: true
covers:
  - .claude/settings.json
  - templates/settings.json
---

# meta-review:M0 — 删除 block-dangerous hook(P0.9.1.5 第一个 trial)

## 1. 元信息

- **审查日期**:2026-04-28
- **审查触发**:scope=meta(B 组 `.claude/settings.json` + F 组 `templates/settings.json`);其他改动 scope=none(README / QUICKREF / templates/README + decision file + 本 audit)
- **流程归属**:M1 §3 Step B → M2 §3 流程
- **流程架构**:扁平 fork(M2 §3.1 工具层并行 — 单 turn 一次 4 调用)
- **挑战者数量**:4(D7 bootstrap 4 维基线)
- **agent 模态**:对抗式(M2 §6 子节 1)
- **改动主题**:M0 — 删除 `block-dangerous` PreToolUse hook(2026-04-17 起草的 M0-M4 第一项;P0.9.1.5 第一个 trial,目的之一是验证 P0.9.1 治理流程跑通)
- **背景**:用户启动 M0(2026-04-28),brainstorming 阶段拍板 Q1 D / Q2 X / Q3 α / Q4 不加迁移提示

## 2. 维度选取

### A. 推荐维度清单(全启用)

- 核心原则合规:F 系列 / 用户 feedback memory(9 条)/ 设计哲学
- 目的达成度:删除是否真消除"hard-block 违反原则"问题?M0 trial 是否验证 P0.9.1 流程?
- 副作用:下游影响 / 维护负担 / git 可见性 / 文档一致性
- scope 漂移:本次改动是否扩散 / 是否触及 scope.conf / 主题是否与实改动匹配

### B. 最低必选维度(bootstrap 4 维基线 — 强制)

- 核心原则合规 / 目的达成度 / 副作用 / scope 漂移

### C. 本次定制

- 启用的推荐维度:全 4 维(=B 段最低必选)
- 禁用的推荐维度 + 理由:无
- 新增的定制维度 + 理由:无

## 3. 挑战者执行记录

### 挑战者 1:核心原则合规(verdict: 待修)

**问题清单**:
- [Medium] 删除决策 judgment_basis 合规但理由表述偏移:Q1 D "光谱 B+ 违反"在 spec 找不到精确对应。spec §"光谱 B+" 是 meta-review **执法机制**(Stop + pre-commit 拦无 audit),不直接断言"通用危险命令 hook 不该 hard-block"。block-dangerous 是 PreToolUse hook,与 meta-review 执法是**不同语义层** — 概念错位
- [Low] 历史合规:spec L142 + decision L19 明示"M0 删除 block-dangerous"是 2026-04-17 已拍板,Q1 选项不是事后合理化(无偷换动机)
- [High] dimension_addition_judgment 反向追问:不删 block-dangerous(改 advisory / 缩 patterns)是否就化解"hard-block 越权"?**brainstorming 似未明确穷举此对照**,Q3 α 直接删跳过"降级 advisory"中间选项
- [High] spec_gap_masking:删后下游失去基础保护,**Q4 不加迁移提示等于不承认这个缺口**;违反 spec_gap_masking — 删 hook 包装成"哲学冲突解决",未承认"下游用户从此失去基础预警"
- [Low] realworld_testing:无误拦数据驱动符合 iterative_progression,realworld_testing 边界模糊但可接受
- [Medium] 设计哲学不越权:删除一个**用户安装时已默认存在的防御 hook**对所有现存 / 未来下游用户是单边决策

**verdict**:待修 — 措辞概念错位 + spec_gap_masking 缺口未承认

### 挑战者 2:目的达成度(verdict: pass)

**问题清单**:
- [中] 删后保护层级:M15(Stop hook)+ M16(pre-commit)拦的是 audit/commit 缺失,**不**拦危险 bash 命令本身。删后 PreToolUse 阶段无任何拦截(裸跑) — 文档需明示用户接受此前提
- [中] 真覆盖验证:spec §3.1.9 / §4.1.2 hook 体系无一覆盖"危险 bash 命令"语义。删 block-dangerous 后 PreToolUse 类硬门完全为零
- [低] 动机偏移检查:2026-04-17 decision L142 + spec L91/L1163 明示 P0.9.1 落地后首批,Q1 D 与原始 retrospective 一致,无偷换
- [低] M0 trial 目的达成:删 block-dangerous + 跑 brainstorming/meta-review/finishing 确实产出"P0.9.1 流程跑通"的 meta-L4 数据点
- [中] 替代方案验证:Q3 α 跳过 β/γ 中间选项,但 trial 性质决定"直接删"对验证流程数据最纯净 — 用户拍板可接受
- [低] 上游 built-in:Claude Code 上游本身有 permission/工具调用授权机制,删后回到 baseline 防御非"零防御"
- [信息] trial 价值匹配:trial 的"验证治理流程"目标 > "删 block-dangerous 是否正确"目标 — 后者是载体

**verdict**:pass — 删除真消除"hard-block 违反 B+"具体冲突点,trial 产出 meta-L4 数据;裸跑风险有上游 permission 兜底

### 挑战者 3:副作用(verdict: 待修)

**问题清单**:
- [轻微] setup.sh L70-78 hook 复制循环用 `*.sh` glob,无 block-dangerous 特殊提及,删后无需改 setup.sh
- [轻微] PreToolUse key 整段删除(不是空数组),JSON 仍 valid,Claude Code 缺 key 等价无 hook,不影响其他 hook 加载
- [轻微] templates/README.md 差异表 PreToolUse 整行删除,M18 vs M19 二元对照结构完整(都无 PreToolUse),改后比改前更自洽
- [严重] 下游已装项目:Q4 不加迁移提示,已装下游本地仍有 stale block-dangerous.sh 副本(setup.sh 重跑覆盖 settings 但不删 hook 文件),behavior:不激活但文件存在 — 接受代价
- [轻微] 下游新装项目:删后失去 PreToolUse 防护,但 hook 拦的 9 类 false-negative 高,可接受
- **[严重] [git tracking 全局问题 — 非 M0 引入]**:根 `.gitignore` L2 `.claude/` 让 `harness/.claude/` 全部 hook 被 ignore,只 `meta-*` / `check-meta-*` 被 force-add。**block-dangerous.sh 删除根本未触动 git**(本来就没在仓库),git status 不显示其删除。M0 trial 的"删 hook"本应在 git 留 deletion record 但未留 — 应作 P0.9.2/3 候选处理
- [严重] 维护负担/decision file:decision file 应完整保留 hook 内容供未来参考(因 git 不留 history)
- [轻微] meta-review-rules.md L82 "主题示例"用 block-dangerous,改后新人读 governance 文件不再误以为 block-dangerous 还存在

**verdict**:待修 — 下游 stale 文件 + decision file 缺源码 + meta-review-rules.md L82 stale 示例 + git ignore 让 deletion 不留 audit trail

### 挑战者 4:scope 漂移(verdict: 待修)

**问题清单**:
- [中] task list / 主题描述:`block-dangerous.sh` 文件**实际在 git status 不显示删除**(因 .gitignore .claude/ 全 ignore),"删除 hook"主题与实改动不匹配 — 实际只删了 settings.json 注册 + 文档引用 + worktree 物理文件(无 git audit trail)
- [低] README / QUICKREF / templates/README scope=none 清理 = 跟随注销的描述同步,属"防止文档说谎"。Q2 X "极简范围"原文是 hook + 2 settings,顺手清 stale 用户文档引用是 reasonable 最小附属;不算 scope 扩散,但 audit 应明列"scope=meta 改 2 文件 + scope=none 顺手清 3 文件"区分
- [低] audit covers 列表:scope=meta 实改动 = 2 个 settings.json(B + F 组)。原议 covers 含已删 hook — 实际 git 不知道,covers 只列 2 个 settings.json
- [低] scope.conf 不需更新(动态扫描)
- [中] F 组 templates/settings.json 下游影响:改动立即影响所有未来 setup.sh 跑出来的下游项目 — audit / decision 应明示"下游影响"
- [低] stale 引用残存合理性:historical(spec / plan / completed handoff / decision)保留合理;mutable(handoff / ROADMAP / meta-review-rules.md L82)需复核 — meta-review-rules.md L82 已修

**verdict**:待修 — scope 边界本身合理(无漂移),但"删除 hook"主题与实改动失配 + handoff/ROADMAP 仍说 M0 未启动

## 4. 综合

### 共识发现(高一致性)

| 共识点 | 挑战者交叉 | 严重性 |
|---|---|---|
| **`.gitignore .claude/` 让 hook 改动无 git audit trail** | 3 + 4(直接发现) | High(底层缺陷,推 P0.9.2/3) |
| **decision file 必须附完整 hook 源码备份** | 3(因 git 不留 history) | High(本次 trial 唯一保留位置) |
| **删除理由表述偏移**(光谱 B+ 概念错位) | 1 | High(应改为"基础防御责任移交") |
| **spec_gap_masking 缺口未承认**(下游失去基础保护) | 1 + 3 | High(audit / decision 必须显式承认) |
| **dimension_addition_judgment 反向追问未明示** | 1 | Medium(decision file 应留痕) |
| **meta-review-rules.md L82 stale 示例** | 3 | Medium(已修) |
| **handoff / ROADMAP 同步**(M0 已完成) | 4 | Low(P29 任务已计划) |

### 分歧

挑战者 2 verdict=pass,其他 3 个 verdict=待修。但 verdict 差异源于关注点不同 — 挑战者 2 关注 trial 价值(达成验证 P0.9.1 流程目的)而 verdict pass;其他 3 个关注修补点应记录(措辞 / 备份 / 缺口承认)— 不冲突。整体 verdict=needs-revision。

### 盲区

- **下游用户实际反馈**:删除后 N 月内是否遇到"想要 block-dangerous 拦截"的场景 — 推 P0.9.2 实战观察
- **上游 Claude Code permission 实际兜底强度**:挑战者 2 提"Bash 调用默认需用户授权",但 allowlist 配置后多大范围裸跑?未验证 — 推 P1 实战时观察

## 5. 判定

### 初判:needs-revision

**理由**:措辞概念错位(光谱 B+ 不裁通用 hook)+ spec_gap_masking 缺口未显式承认(下游失去基础预警)+ dimension_addition_judgment 反向追问留痕缺失 + decision file 缺 hook 源码备份(git 不留 history 唯一位置)

### 修订动作(P0+P1+P2)

**P0(必修 — 共识 high severity)**:
- ✅ decision file 重述删除理由(不用"光谱 B+",改"基础防御责任移交 + 上游 permission 兜底 + harness 范畴是治理不是安全")
- ✅ decision file 显式承认 4 条已知缺口(下游失去预警 / git 不留 history / .gitignore 全局问题 / 下游 stale 文件)
- ✅ decision file §备份段附完整 hook 源码(git 不留 history 唯一位置)
- ✅ decision file 加 dimension_addition_judgment 反向追问段(对比 advisory / 缩 patterns)

**P1(必修 — Medium)**:
- ✅ meta-review-rules.md L82 stale 示例改为 "M2 §3.1 加并行约束声明"
- ✅ audit covers 只列 2 个 settings.json(实存 + git 可见)

**P2(选修 — 推后续)**:
- ⏳ `.gitignore .claude/` 全局问题(hook 改动无 git audit trail)— 推 P0.9.2 / P0.9.3 评估
- ⏳ 下游 stale 文件清理路径(setup.sh 是否加反向同步删除选项)— 推 P0.9.2 实战观察
- ⏳ handoff / ROADMAP M0 完成同步 — 在 P29 任务执行(本 audit 后)

### 终判:pass(after revision)

修订后 P0+P1 落地。decision file 完整(理由清晰 + 缺口承认 + 反向追问留痕 + 源码备份);audit covers 准确;stale 示例修复。P2 项已识别推后续阶段。

### 后续

- **P0.9.1.5 第一条数据点完成**:M0 trial 验证 P0.9.1 治理流程从 brainstorming → meta-review → finishing 跑通,产出 meta-L4 第一条真实数据
- **`.gitignore .claude/` 全局问题**:推 P0.9.2 / P0.9.3 评估 — 是否需要 force-add 关键 hook 让 git 留 audit trail
- **下游用户反馈**:N 月内观察是否真有"想要 block-dangerous 回来"的需求(P0.9.2 数据点)

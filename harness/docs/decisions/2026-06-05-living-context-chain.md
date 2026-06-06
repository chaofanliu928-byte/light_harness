# 决策: 分层活上下文文档系统(L1-L6 脊柱版 / 编码 + 机读 upstream / 软收尾硬收口 / 下游为主)

**状态**:🟢 方向已定(用户拍板脊柱 + 薄版 L5/L6,2026-06-05);待设计者出逐文件方案 → meta-review → 签字 → 实现

**日期**:2026-06-05

**关联功能**:harness 文档系统 / 上下文治理(架构级)

**类型**:新增机制型 decision(建设性)

---

## 演进留痕(三版)

1. **grep 版**(初版):四层链 + `> 上游:` blockquote + 下游 grep 算。meta-review 判**又坏又肥**(grep 在真实仓库全角冒号漏/路径前缀漏/散文假阳),否决。
2. **4 层编码版**(修正):编码进文件名 + frontmatter `upstream: [编码]`(机读非 grep)+ 校验 hook。meta-review pass-after-revision(逮出 gawk/全角/grep 窗口等实现坑)。
3. **L1-L6 脊柱版**(本版,用户推进):把"层"从抽象的 4 类升级为**对应 harness 既有 workflow 阶段的 6 层脊柱**,松紧梯度,L5/L6 也进链(薄版)。本版取代前两版。

**痛是真的**(不再辩):上下文跨会话半死 + 依赖图隐式,是 harness 公设2 / 原理 4.1 的立身痛点(不是愿景)。坏的是 grep 实现,本版用编码 + 机读 upstream + 阶段映射解决。

## 决定:L1-L6 脊柱(层 = harness 既有阶段)

| 层 | 装什么 | 对应阶段 | 松/严 |
|---|---|---|---|
| **L1** | 愿景/意图 | 用户意图确认 | 松(可探索,`待定` 合法) |
| **L2** | 需求/功能 | 用户意图确认 | 松 |
| (方法带) | 方法的探索与讨论 | brainstorming | 松 — **不单独编码**,折进 L3 的 upstream 理由 |
| **L3** | 架构 | system-design | **转严 ← 对抗审查上场** |
| **L4** | 设计·拆解(计划) | design + 对抗审查 / planning | 严 |
| **L5** | 实现·验证 | implementation + 验证 | 严 |
| **L6** | TDD/测试 | testing | 最严 |

### 1. 松紧梯度(核心原则)
**方向可探索、实现严谨,分层即松紧梯度。** 上三层(L1/L2/方法带)探索方向/方法、可随便推翻;下层(L3-L6)落实现、必须忠实一致。**对抗审查上场 = 松转严的分界**(对齐公设1 做审分离)。

### 2. 链不许骗人(探索期的章法)
每个 context 文档声明自己的层 + upstream(`待定` 合法)。改上游(推翻/改名)必须**当场**把下游 repoint 或标 `待定`。**`待定`(明着欠)是章法,静默断链(暗着烂)是垃圾。** 方向永不反(低层不定义高层)。

### 3. 上游改 → 严谨蔓延下游
方向(上层)一动,挂在它下面的实现(下层)必须严谨重对齐,不留孤儿。这是用户从一开始要的"从上游向下游蔓延"。

### 4. 固定位置 + 编码 + 机读 upstream
```
docs/context/
  L1-vision.md
  L2-spec/   L2-INDEX.md(默认单表) 或 L2-F1-*.md
  L3-arch/   L3-ARCH.md / L3-D1-*.md
  L4-design/ L4-F1-design.md / L4-F1-plan.md
  L5-impl/   L5-F1-*.md(薄:实现决策/坑 + 验证证据 Evidence Depth + upstream)
  L6-test/   L6-F1-*.md(薄:测试策略/覆盖 + upstream) — 或并入 L5,设计者定
```
- 编码进文件名(`L<层>-<类型><序号>`),编码即稳定 ID,**不建 registry**。
- frontmatter `upstream: [编码]`(指编码不指路径、不 grep)。下游靠**解析 frontmatter** 算。
- **L5/L6 薄版**:记代码表达不了的(为什么这么实现/怎么验证/测什么)+ upstream;**不抄代码、不上 16 步规格**。L5/L6 也可由真实代码/测试 + 一个薄节挂链(设计者定形态)。

### 5. 校验 hook:软收尾 + 硬收口
- **平时收尾(Stop):软** — 发现断链 / 编码冲突 / 疑似全角只 stderr 警告、放行(探索期随便推翻,只早提醒)。**方向校验移到硬收口**(守软 hook 瘦身,meta-review 修正)。
- **收口(finishing):硬** — 一个功能算"做完",链必须通、方向合法、`待定` 该补的补上;**由 AI 按治理规则当场核**(不靠脆弱脚本),核完在 handoff 写 `## context-chain: 已核(...)` 或 `skipped(理由: ...)`;**check-context-chain.sh 在收口(evaluation-result.md 存在)时机械逼这条声明存在(无则 exit 2)**——给硬收口真牙齿,不靠纯自觉(meta-review 修正:软+硬都不机械拦 = 违 harness 立身原则)。
- **审查给的"别重蹈"清单**(本会话两轮审查实证):POSIX awk(不用 gawk 三参数 match)/ 字节精确(躲全角/grep -A 窗口)/ LF / 带 stop_hook_active 安全带。软 Stop hook 即便降级也只丢提醒,真保证在 finishing 那道 AI 核。

### 6. 下游为主 + 零迁移 + 剂量轻
- setup.sh 给新下游搭好 `docs/context/`(剂量轻:默认 L1 + L2 单表,L3-L6 随真实开发长)。
- harness 自仓库**轻 dogfood**(不推倒现有 product-specs/ARCHITECTURE/specs/decisions);自仓库 meta 图用**最小解**(把"触点完整性"加成 meta-review 标准必查维)。
- 吸收现有 `关联功能`/`关联需求`(context/ 内统一 upstream;context/ 外旧字段保留)。

### 7. 落地footprint(用户点名:README/说明/配置)
- 新增 `docs/context/` 结构 + 各层编码模板 + `check-context-chain.sh`(软 Stop)。
- setup.sh 脚手架 + project-setup 起步填 L1+L2。
- README(根+harness 两份)4.1 原理加"分层活上下文链"节;QUICKREF 速查;CLAUDE.md(M3+M4)索引 + 核心规则。
- finishing-rules 加"收口硬核链"步;meta-review-rules 加"触点完整性"维(最小解)。

## 设计硬前提(把教训写死)
- 机读 by 编码,**不用 grep 散文 / 路径字符串**;
- 轻,**不要 16 步逐层规格 / 内部契约 / 逐行台账**(L5/L6 也是薄版);
- 分层方向 + 收口硬核由治理强制(软 Stop 仅提醒);
- hook **POSIX 安全 / 字节精确 / LF / 带安全带**(本会话审查实证教训);
- vision 仅下游模板,自仓库用 README、不重复;下游全新搭、零迁移;吸收旧字段不并行。

## 不做
- 不做 16 步式逐层产物规格 / registry 台账。
- L5/L6 不抄代码(只记 why/验证/测试策略)。
- upstream 不用 grep/路径实现。
- 不在自仓库落与 README 重复的 vision、不迁移现有 harness 文档进新结构。

## 后续
fork 独立设计者出脊柱版逐文件方案(docs/context 结构+编码+upstream 格式+软/硬 hook+setup 脚手架+project-setup+README/QUICKREF/CLAUDE/配置+自仓库 dogfood+最小解)→ fork 挑战者 meta-review → 调度者综合签字 → 实现 → finishing。

## 关联
- 本会话:对照 16 步 → propagation 真假需求 → 又坏又肥 meta-review → 4 层编码版 → L1-L6 脊柱版;两轮全仓审查(给 hook 列"别重蹈")。
- harness 原理 4.1 + 公设2;`decisions/2026-06-04-prune-*`;memory `harness_explore_rigor_gradient`。

**签署**:用户 + Claude(调度者)

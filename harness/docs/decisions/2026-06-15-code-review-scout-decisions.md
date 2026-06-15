# 决策: code-review-scout 待用户裁决项(地板大小 / 代码质量·spec忠实性落点 / scout-vs-地板门 / 范围时机)

> 由 designer 在系统设计阶段创建,用户 2026-06-15 拍板 4 项。下列项影响接口/架构/「审什么」。
> 关联设计:`docs/superpowers/specs/2026-06-15-code-review-scout-design.md`(D-C1~D-C4 + §9.2 张力收敛)。
> 功能:给 review-scout 扩代码审查(`reviewType='code'`)+ 新建 harness 侧 code-review skill。

**状态**:🟢 已决定(用户 2026-06-15 拍板 4 项;either-or 真空张力据此收敛)

**日期**:2026-06-15

---

## D-C1 — code 地板大小 / 类型契约落点 ✅

**问题**:scout 路 code 地板(固定必跑维)放几维?影响 `FloorTable.code` 值 + `CodeCandidateMenu` 内容 + FLOOR_FOCUS 扩几个 code 键(影响接口)。

> **✅ 用户拍板 = A(类型契约入候选)**。注:本轮 code 地板第 3 维由 D-C2 定为 **spec忠实性**(非类型契约);D-C1 决定的是"类型契约去候选"。最终 `FloorTable.code = [方向盘对齐, 简洁性, spec忠实性]`、`CodeCandidateMenu = [类型契约合规, 架构合规, 模块文档一致性]`。

| 选项 | 类型契约落点 | 候选 |
|---|---|---|
| **A(✅ 用户拍板)** | 候选(diff 驱动) | 类型契约合规 + 架构合规 + 模块文档一致性 |
| B | 地板(渐进起步) | 架构合规 + 模块文档一致性 |

> 维名「简洁性」= review-rules L11/L19 + workflow.js 占位的双写源 token(节标题 L66 写「简洁性审查」,同一维);本 spec/决策据双写源用「简洁性」。

**裁决 = A(类型契约入候选)**,理由:
- 与 design 路地板严格同形(2 维),一致性最强,不为 code 特殊化。
- 类型契约合规是**条件相关**(只有改 API/共享类型才有审查对象——维度分类结论);放地板会让纯逻辑改动/无 API bugfix 每次空跑一个类型契约挑战者(过度)。放候选 + scout 按 diff 信号选 = 精准+省(用户核心价值"动态选维")。
- 漏维风险由 `skipped_candidates` 强制留痕兜:scout 不选类型契约须解释为何;若 diff 真改了 API 却 skip,调度者综合质疑 → 2 维+候选 ≥ 3 维安全性,且更省。

**未选 B(渐进入地板)的考量**:类型契约改 API 漏检是 critical,但候选机制(scout 每次必考虑 + 不加须 skipped 留痕)已挡静默漏,无须入地板每次空跑;入地板会让无 API 的纯逻辑改动也空跑类型契约挑战者(过度)。

**✅ 用户拍板 = A(类型契约入候选)。**

---

## D-C2 — 代码质量 / spec 忠实性 落点 ✅(用户拍板:spec忠实性入 code 地板,either-or 不叠加)

**问题**:scout 路 code 地板/候选/动态维 是否包含「代码质量」「spec 忠实性」?

**背景**:
- 输入 D2:维度分类 agent 倾向把它们也算 scout 地板;权衡 agent 倾向让它们沿 Superpowers 两段恒跑、scout 不碰。
- 输入 A3:"Superpowers 内嵌两段(spec 忠实性 + 代码质量)沿 Superpowers 流程恒跑、scout 不碰;scout 路在代码 diff 上做按 diff 现推的对抗维扇出。"

**关键事实(自检揪出的真空)**:本功能两路是 **either-or**——**ultracode 开走 scout 路时不并跑 Superpowers `requesting-code-review`**。故"Superpowers 两段恒跑"在 ultracode 路**不成立**;designer 初裁"scout 不碰 spec 忠实性"会在 ultracode 路留**真空**(没人审实现是否忠于 spec)。自检揪出后,用户据此拍板修正。

**✅ 用户拍板裁决**:
1. **spec 忠实性入 code 地板(第 3 维)**:`FloorTable.code = [方向盘对齐, 简洁性, spec忠实性]`(3 维)。scout 路每次必跑 spec忠实性挑战者(**scout 照抄地板,非自己发明**),**填上 either-or 下的真空**——ultracode 路 spec 忠实性由 scout 地板维保证(不再"靠综合间接覆盖、不保证等价")。新增 code 版 `FLOOR_FOCUS_CODE['spec忠实性']`(scout 路自有、**不镜像 design-reviewer.md**;code 语境:审实现代码是否忠于本次任务的 spec/需求——该做的做了没?做歪/跑题没?对照 `targets.spec`,缺则回落任务描述/diff 自身意图、**不把 sessionIntent 当评分锚**[F 簇],引 diff 锚点)。与 design 路「自洽性」「完整性」**区分**(对象=代码 vs 设计文档)。
2. **代码质量不单设地板维**:已被 **`FLOOR_FOCUS_CODE['方向盘对齐']` 的 code 通用基线段**(功能正确/真实代码质量/测试/一致性/简洁性)覆盖。**注(D 簇修订)**:code 版方向盘对齐 focus 是**独立文字**(不与 design 版共用——design「审查设计」/ code「审查 diff + code 基线」语境不同),focus 按 reviewType 选;基线段同结构,故代码质量被覆盖,无须另立专名维。
3. **仍 either-or 不叠加**:Superpowers `requesting-code-review` **仅作非 ultracode 回落**;ultracode 路只走 scout(地板已含 spec 忠实性 + 代码质量由基线覆盖,**无真空**)。不改成"scout + Superpowers 叠加跑"(ultracode 路本已无真空,叠加只增复杂度 + 冗余 fork)。

**理由**:① **填真空**:either-or 下 ultracode 路不跑 Superpowers,spec 忠实性入地板是该路覆盖它的唯一可靠途径;② **避免重复 fork**:仍 either-or(不叠加)→ scout 地板 spec忠实性 与 Superpowers 内嵌段不会同时跑(两路互斥),无冗余;③ **代码质量不另立**有据:design 版方向盘对齐 focus 已含代码质量基线段(workflow.js L46 实证),code 版 focus 同结构含基线即覆盖。

> 此裁决取代 designer 初裁("scout 不碰"——初裁误以为 Superpowers 两段在 ultracode 路恒跑,实为 either-or 下不跑)。spec §9.2 张力据此**收敛**:ultracode 路 spec 忠实性由地板维保证,无须用户在 (i)/(ii) 间二选——直接采纳"spec忠实性入地板 + either-or 不叠加"。

---

## D-C3 — scout-vs-地板门 ✅(影响「审什么/扇出多少」)

**问题**:code 路要不要一个 if-then 门控制 scout 何时能加维(如"diff 太小只跑地板")?(review-scout 主 spec §1.3 把"代码审查的 scout-vs-地板门"留到扩展时定,本轮兑现。)

| 选项 | 做法 |
|---|---|
| A | 有 if-then 判据门(如 diff 行数 < X / 纯文档改 → 只跑地板,不让 scout 加维) |
| **B(✅ 用户拍板)** | 无门——scout 每次读 diff 自由推动态维 + 候选必考虑(不加须 skipped 留痕) |

**裁决 = B(无门)**,理由:
- 与 design 路一致(design 路无 scout-vs-地板硬门)。
- 有门 = 又一个静态规则表,与"动态选维"动机相悖;diff 大小 ≠ 该不该加维(小 diff 也可能碰 migration/并发 critical)。
- 轻量跳过已由上游"是否走 code-review 审查"门控,不必在 scout 内再设门。
- 无门 + skipped 留痕已足够透明;scout `why_this_time` 须引 diff 证据,小 diff 无信号则 added 自然为空(不会无证据硬加)。

**✅ 用户拍板 = B(无门 + 留痕)。**

---

## D-C4 — 范围 / 时机:本轮接通-usable vs 先补契约骨架 ✅

**问题**:本轮交付到哪一步?

| 选项 | 交付 |
|---|---|
| **A(✅ 用户拍板)** | 接通-usable:新建 code-review skill + workflow code 接线(FloorTable.code 真数据 3 维 + CodeCandidateMenu + code FLOOR_FOCUS[含 spec忠实性] + scoutPrompt 菜单分支 + diffRef)+ review-rules code scout 注 + 地图/凭证,调用真跑 |
| B | 先补契约骨架(reviewType='code' 常量/agent 语境就绪),先不建 skill、调用留下轮 |

**裁决 = A(接通-usable)**,理由:
- workflow.js 已 reviewType 参数化、FloorTable.code 已有占位,"补常量 + 建 skill"工作量小,一步到位避免"骨架就绪但没入口、下轮重新捡上下文"。
- design 路已是接通-usable 完整形态,code 路同形一次接通保持一致。
- 用户输入 A2 明确要"新建 code-review skill"作触发宿主 → 只补骨架不建 skill 不满足 A2。
- 诚实边界:接通-usable ≠ 实战验证过;推维质量仍 bootstrap 不可证,落地后实战观察(spec §6.2)。

**✅ 用户拍板 = A(接通-usable)。**

---

## 决定

用户 2026-06-15 拍板:

- **D-C1 = A**:类型契约合规 → **候选**(diff 驱动,scout 按 diff 选,不加须 skipped 留痕),不入地板。
- **D-C2 = spec忠实性入 code 地板(either-or 不叠加)**:code 地板 = 方向盘对齐 + 简洁性 + **spec忠实性**(3 维);scout 地板兜住 either-or 下 ultracode 路不跑 Superpowers 的 spec 忠实性真空;**代码质量**靠 code 版方向盘对齐 focus 的通用基线段覆盖(D 簇:code focus 独立文字、按 reviewType 选,非与 design 共用),不单设维;Superpowers `requesting-code-review` **仅作非 ultracode 回落、不与 scout 叠加跑**。
- **D-C3 = B**:无门——scout 每次读 diff 自由推 + 候选必考虑(skipped 留痕)。
- **D-C4 = A**:本轮接通-usable(新建 code-review skill + workflow code 接线 + 调用真跑)。

**综合结果**:
- `FloorTable.code = ['方向盘对齐', '简洁性', 'spec忠实性']`(地板 3 维)
- `CodeCandidateMenu = ['类型契约合规', '架构合规', '模块文档一致性']`(候选)
- 发明维(scout 清单外按 diff 信号现推):迁移安全 / 触点完整性 / 并发安全 / 安全边界 / 向后兼容 等(双闸:不与地板/候选重叠 + why_this_time 引 diff 锚点)

## 后续影响

> 影响落点见 spec §8.1;以下据已拍板裁决。

- **D-C1=A** → `CodeCandidateMenu` 含类型契约合规;`FLOOR_FOCUS_CODE` 含类型契约候选键;review-rules code 候选注列三候选(workflow.js↔review-rules 双写)。
- **D-C2(spec忠实性入地板)** → `FloorTable.code` 3 维(双写 review-rules code 地板维表注);新增 `FLOOR_FOCUS_CODE`(含 code 版方向盘对齐 + `spec忠实性`,code 语境,不镜像 design-reviewer.md);review-scout.md code 语境注明 spec忠实性是地板维(照抄)、代码质量不另立;code-review skill ultracode 分支保持 either-or(不叠加 Superpowers)。
- **A 簇(审查后)** → `scoutPrompt`/`challengerPrompt` 加 reviewType 分支(design else 逐字保留),非"零改函数体";design 行为零变靠 prompt 文本快照核(spec §3.3/§7.2 D-C5/§8.3 CMD2)。
- **C 簇(审查后)** → synthesis 主表/L101「地板 2」为 code ADD 注"design 2 / code 3"(spec §8.1)。
- **D-C3=B(无门)** → review-scout.md / scoutPrompt 不加门判据(沿 design 路无门)。
- **D-C4=A(接通-usable)** → 本轮建 code-review skill + 真接线 + 分发(setup.sh)+ 凭证(自动入 glob)。

> **凭证义务**:命中 credentials.conf 的改动(新 skill / review-rules / synthesis-rules / workflow.js / review-scout.md / CLAUDE×2)收口须 audit;本 decisions 文件命中 `docs/decisions/` —— 不在 credentials.conf include glob(decisions 非凭证义务类),无 audit 义务。

## 考虑过的备选(为什么排除) — 项目经验库

- **D-C2 初裁"scout 不碰两段"**——排除:自检揪出 either-or 下 ultracode 路不跑 Superpowers,留 spec 忠实性真空;用户拍板改为 spec忠实性入地板。教训:"沿 X 流程恒跑"措辞须先核 X 在目标运行时是否真跑(either-or 分支下"恒跑"可能不成立)。
- **"零改函数体 / 100% 复用 challengerPrompt"措辞(A 簇审查揪出)**——排除:两 prompt 函数现写死 design 串,"零改"与"code 须给 diffRef/code 语境"不可兼得;改为 reviewType 分支(design else 逐字保留)+ prompt 文本等价核。教训:跨类型复用编排件,"复用结构"≠"零改函数体",行为流经被改函数须文本级验证等价,不能只看常量 diff。
- **D-C2 (ii) 叠加方案(scout + Superpowers 并跑)**——排除:spec忠实性入地板后 ultracode 路已无真空,叠加只增复杂度 + 冗余 fork(两路本互斥)。
- **D-C1 (B) 类型契约入地板**——排除:类型契约条件相关(改 API 才有对象),候选 + skipped 留痕已挡静默漏,入地板会让无 API 改动空跑。

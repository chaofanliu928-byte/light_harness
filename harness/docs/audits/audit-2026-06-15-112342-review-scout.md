---
audit: true
covers:
  - <root>/CLAUDE.md
  - CLAUDE.md
  - setup.sh
  - docs/governance/review-rules.md
  - docs/governance/synthesis-rules.md
  - docs/governance/credentials-rules.md
  - .claude/hooks/credentials.conf
  - .claude/skills/design-review/SKILL.md
  - .claude/agents/review-scout.md
  - .claude/workflows/review-scout.workflow.js
---

# audit:review-scout 动态审查侦察(ADD 并排路 — 治理面改动收口凭证)

> review-scout = 给 design-review 增一条 ultracode 专属的动态审查侦察路(scout 现推维 + 一维一挑战者扇出),并排现有固定 4 维 design-review、**不替换**(用户 2026-06-13 拍板 Y + 保 A)。covers = 本分支(`main..HEAD`)命中 credentials.conf 的 10 个治理面文件(QUICKREF 改但无 glob → 不进 covers;spec/plan/decision 在 docs/superpowers · docs/decisions 不命中 governance glob → 不进 covers;design-reviewer.md 零改零关系 → 不进 covers)。根级 CLAUDE.md 经 `<root>/` sentinel。

## 1. 元信息

- 批次:review-scout 动态审查侦察(plan `docs/superpowers/plans/2026-06-13-review-scout.md` 10 任务;spec `docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md` 已锁,3 轮 design-review 收敛)
- 审查对象:本分支 `review-scout-design`(`main..HEAD`)实现 commit — 契约骨架(73bd9e3)/ 编排(54f0caa)/ scout agent(7490f83)/ wiring 任务 4-9(3670fba/4bcb984/1cc026f/0bdc4cf/327e4e7/083e181)/ 收口审计修复(36b7296)
- 凭证类型:对抗审查 audit(治理面改动 — 改动命中 credentials.conf 的 skills/agents/workflows/governance/hooks/setup/CLAUDE 多 glob)
- 模态:对抗式;N=5(bootstrap-4 + 触点完整性);synthesis-rules 事前中性化注入(主线-支线-关系 + 中性约束)+ 事后按证据综合
- **过程诚实标注**:5 挑战者分 2 批 fork(2+3),非理想的单 turn 一次性 5(review-rules 多 fork 约束);各批内并行、独立 context,无 2026-04-28 P-3 式跨分钟串行。登记为本批过程观察,不影响各挑战者独立性。
- 时间:2026-06-15 11:23

## 2. 维度选取

- B(bootstrap 4 维,治理行强制基线,未删减):核心原则合规 / 目的达成度 / 副作用 / scope 漂移
- A(条件必选):**触点完整性维**(本批命中 跨文件计数/枚举 + 分发链 + 双写对 三触发 → 必选;review-rules 触点行"优先于过度工程化选用")
- 禁用:安全扫描 / 流程审计(治理批暂不纳入 — finishing-rules §治理批收口工序适用,decision 2026-06-13 追记三;连带风险记 ROADMAP 观察项)
- 跨前提:**方向评估**(治理批适用,decision 追记三"方向评估重要")—— 在本 audit 落账后单独 fork evaluator(finishing 步序),问"方向本身对不对/该不该推翻"

## 3. 挑战者执行记录

五挑战者独立 fork(`git diff main...HEAD` / Read / grep / find 实跑,公设 1 不采信实现者自报)。

**核心原则合规(甲)**:verdict=**pass-after-revision**。文档先行(spec/plan/decision commit 序先于 wiring)、最小变更(改动集 = §8.1 ADD 清单精确一致;现有 4 维路三文件 git diff 零)、角色分离 + 二公设(scout 独立 fork 纯推维 / 综合留调度者 / 自读盘合行动公设;scout 路 prompt 与 design-reviewer.md 零关系经 FLOOR_FOCUS 常量实证)全合规。1 finding 🟡 → workflow.js `scoutPrompt` 让 scout 读 `docs/.claude/agents/review-scout.md`,而 setup.sh 落点 = `.claude/agents/`(`docs/.claude/` 两语境皆不存在)。

**目的达成度(乙)**:verdict=**pass-after-revision**。P0 核心场景逐一有实现路径(ultracode 走 scout 全链 / A-3 方向盘自适应 / 非 ultracode 走现有 4 维零改 / 代码·治理留口),wiring 字段级闭合(SKILL targets ↔ workflow 入参 ↔ SCOUT_SCHEMA ↔ challengerPrompt focus ↔ FINDING_SCHEMA),诚实边界守住(§7.3「动态推维仅 ultracode 兑现、非 ultracode 路痛点未解」无 over-claim)。F1 🟡 SKILL/scout RUBRIC 等 targets 在自仓库需 `harness/` 前缀(dogfood 场景);F2 🟢 FLOOR_FOCUS RUBRIC 同源(回落 CLAUDE.md 分支路径正确,后果轻)。

**副作用(丙)**:verdict=**needs-fixes(轻量)**。反向追问全做:scout/workflow 拆两模块(做事 vs 编排,违公设 1 隔离前提则不可合)非过度;workflow 单消费者经 §7.3 诚实标注(用户拍板保 A 接受,非粉饰);retry-once 可达有意义;字段全锚已确认决策。F1 🟡 → `FloorTable` code/governance 两行是当前不可达预填数据;独立判 spec §7.3 自辩**部分成立但有漏洞**:满足"覆盖三类"只需 reviewType 参数化 + design 一行真数据,**留口 ≠ 必须预填两行维名**。F2 🟢 `DesignCandidateMenu` 只 design 一类、未预填三类,佐证 F1(留口下限是 design 行 + 参数化)。

**scope 漂移(丁)**:verdict=**通过/无漂移**。守 Y 全过 —— `git diff --name-only main...HEAD` 14 文件无任一"必须零改"现有路文件(design-reviewer.md / synthesis L113·L151 维序 / design-rules / model-route / references / README / ROADMAP / AGENTS),synthesis 维序串 diff 零命中(仅四处 ADD scout 行)。改动集 ⊆ §8.1,逐文件 diff 限于该任务职责(SKILL 仅执行开头加分支、现有第 1-4 步 + A/B/C 逐字未动;synthesis 四处恰各 +1 token)。无功能蔓延(未实接 code/governance 审查、未动 D7/bootstrap-4、"4 维→2 维全仓同步"在 diff 不存在)。

**触点完整性(戊)**:verdict=**needs-revision**。分发链(setup.sh 复制 review-scout.md + 新目录 workflows + workflow.js;challenger-orientation 早已分发)/ 双写对(conf↔§2 行序字节一致、glob `.claude/workflows/*` 覆盖 .js;根 CLAUDE.md↔harness/CLAUDE.md 设计审查行字节一致)/ 引用枚举(synthesis 四处 + Skill 地图 + QUICKREF + 角色表全同步,维序段未碰)—— F3~F6 全 🟢。F1 🔴 + F2 🟡 = workflow 注入 fork prompt 的读盘路径前缀漏改:scout.md 自身已正确全程串 `targets`,但 `scoutPrompt`(review-scout.md 路径,F1 两语境皆错)与 `FLOOR_FOCUS`/`challengerPrompt`(RUBRIC + orientation 硬编码裸 docs/,自仓库断链)未同步采用 targets/双层范式 → 产出方(SKILL 传 targets)↔ 消费方(fork 实际 Read)字节级不一致。

**任务级结论登记簿(子代理驱动批,逐任务一行;来源 = 实现者报告 + 两段审查)**:
- 任务 4(SKILL 运行时分支 + scout 综合维序):verdict=approved;关键发现 无(5 语义点全 + 守 Y);修复 commit 无(3670fba)
- 任务 5(review-rules scout 注 + 地板维表权威):verdict=approved;无;无(4bcb984)
- 任务 6(synthesis 四处 ADD,维序零改):verdict=approved;维序零改经 word-diff 独立确认;无(1cc026f)
- 任务 7(setup.sh 分发 workflows + review-scout.md):verdict=approved;`bash -n` 通过、两源文件实存;无(0bdc4cf)
- 任务 8(credentials.conf + §2 双写):verdict=approved;双写行序同步、conf LF 保住(od -c 确认);无(327e4e7)
- 任务 9(CLAUDE×2 + QUICKREF 注):verdict=approved;双写对核 diff 空、纯行尾追加(byte-diff 确认);无(083e181)
- 任务 10(收口验证):verdict=approved;§8.3 CMD1-7 全组 + 守 Y 全仓 diff + 禁用项实际调用零 全过;无 commit
- 收口审计修复(workflow 读盘路径 A1🔴+A2🟡):verdict=approved-after-fix;治理审查戊 F1🔴 + 甲 finding + 乙 F1 撞同处,确凿;修复 commit 36b7296(重审确认两语境皆有效、node --check OK、逻辑/常量/schema 未动、禁用项零)

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:五方独立一致 —— wiring 任务 4-10 实质正确、质量高;守 Y 严格(现有固定 4 维 design-review 活备份真零改,非"声称不改";synthesis 严格区分"适用范围 ADD"与"维序零改");分发链/双写/枚举三类触点全同步;模块拆分与 reviewType 留口非过度工程。
- **真 revision(戊 F1🔴 + 甲 + 乙 F1 三方独立撞同一处,确凿)**:workflow.js fork 读盘路径前缀 —— scout 读 review-scout.md 的 `docs/.claude/` 前缀两语境皆错(下游断链,与用户"保 A 分发"决策冲突)+ FLOOR_FOCUS RUBRIC / challengerPrompt orientation 硬编码裸 docs/ 自仓库断链(spec §6 dogfood 首验场景)。**已随收口修复 commit 36b7296 落地**(A1 去 `docs/` 前缀 → `.claude/agents/review-scout.md`;A2 补 `(自仓库为 harness/docs/...)` 双层注,下游裸路径保留),独立重审确认:`docs/.claude` 零命中、三路径两语境皆有效、`node --check` 语法 OK、逻辑/常量/schema 未动、禁用项零。
- **副作用丙 F1(FloorTable code/governance 两行预填)→ ROADMAP 观察项(非阻断)**:spec §7.3 已反向追问并接受 3 行(reviewType 参数化覆盖三类的载体,纯数据行成本近零);3 行系已锁 spec 决策,本轮不动(重议 = 重开锁定设计,违"设计已锁")。但丙独立指出的"留口 ≠ 预填两行维名数据"自辩漏洞有据 —— 登记 ROADMAP:**未来给 code/governance 接线时一并裁两行维名是否预填 + 同步补 FLOOR_FOCUS 对应 focus**(整体审查发现:floor 维不带 challenger_focus,接线时 `challengerPrompt` 会对 code/governance floor 维传 undefined focus,须接线时补)。
- **A2 仅 🟡**:下游裸 docs/ 本就正确;自仓库前缀注已补,workflow.js 内部读盘范式一致化。
- **exempt / 公设 1 张力**:N/A(本批走正式对抗 audit,非 exempt)。
- **Step C 决策拐点**:无新拐点(decision `2026-06-13-review-scout-workflows-dir.md` 即本功能拐点,已 🟢 在位)。

## 5. 判定

**verdict: pass-after-revision**。revision(workflow fork 读盘路径前缀 A1🔴 + A2🟡)随收口修复 commit 36b7296 落地并经独立重审确认有效;本 audit covers 含 `.claude/workflows/review-scout.workflow.js`(已含修复)。守 Y 全程保持(design-reviewer.md / synthesis L113·L151 维序 / design-rules 收口 git diff 零)。1 项 ROADMAP 观察项(FloorTable code/governance 留口预填 + 接线时补 FLOOR_FOCUS,副作用丙 + 整体审查提示,spec §7.3 已接受当前形态,留接线时裁)。wiring 任务 4-10 闭合;review-scout 路 ADD 并排落地,现有固定 4 维 design-review 活备份零改。方向评估(治理批适用)在本 audit 后单独 fork。

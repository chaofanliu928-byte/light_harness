# 方案调研员(research-scout)Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 给 harness 加"主动搜寻 / 联网调研外部方案"能力——规划方案时按需 fork 联网调研员,薄纪律层(何时调研 + 调研结果怎么用)+ 默认编排 Claude Code 自带的 deep-research workflow。

**Architecture:** 纯 documentation + governance 改动,无代码 / 无 hook / 无 skill 新增 / 不改 model-route。harness 不造调研引擎(用现成 deep-research),只定义"调研员该守什么"。按 spec §9 切 2 commits。

**Tech Stack:** Markdown / Bash grep 验证 / git。research-scout 路径前缀用裸 `docs/`(下游视角;harness 自仓库内调度者自加 `harness/`),沿用上 batch challenger-orientation 范式。

**Spec 来源:** `harness/docs/superpowers/specs/2026-05-29-solution-research-scout-design.md`(commit b508457;每 task 按 spec 节号引用)

---

## File Structure

**新建** 1 个:
- `harness/.claude/agents/research-scout.md` — 方案调研编排说明(调度者读),含红线契约。分发下游。

**改动** 5 个:
- `harness/docs/governance/brainstorming-rules.md` — 阶段四前加"方案调研(按需)"节
- `harness/docs/references/challenger-orientation.md` — §2.4 修正红线误读 + 加外部调研数据源 + 红线小节
- `README.md` — 层 4 加"主动调研 / 重视外部输入"一节
- `CLAUDE.md`(根级 M3) — 角色分离表加 research-scout 行
- `harness/CLAUDE.md`(M4 分发模板) — 角色分离表加 research-scout 行

**Finishing(后续 meta-finishing 阶段产,不在本 plan):** decision-trail.md / handoff.md 同步

---

## Commit 策略(spec §9)

| Commit | Task | 内容 |
|---|---|---|
| **Commit 1** | Task 1-2 | research-scout.md 新建 + brainstorming-rules 触发节(核心机制) |
| **Commit 2** | Task 3-5 | challenger-orientation §2.4 + README + CLAUDE M3/M4 角色表(配套 + 红线修正) |

---

## Task 1: 新建 research-scout.md

**Files:**
- Create: `harness/.claude/agents/research-scout.md`

**Spec 来源:** §3.1(research-scout 6 节)+ §3.3(红线)

- [ ] **Step 1: 创建文件,完整写入以下内容**

```markdown
你是**方案调研的编排者**(调度者 / 主对话)。规划多智能体方案时,在"需求确定后、方案讨论前",**按需** fork 一个联网调研员,搜业界现有方案,作为方案讨论的"选项输入"。

> **形态说明**:本文件是"调度者怎么编排调研 + 调研员要守什么"的说明(与 design-reviewer.md 同类),不是带 frontmatter tools 的 custom agent type。调度者读本文件后按扁平 fork 架构操作。
>
> **路径前缀**:本文件路径用下游视角(裸 `docs/...`);在 harness 自仓库内,`docs/` 实际是 `harness/docs/`。

## 核心边界(做事 / 判断分开)

- 调研员只**找证据 / 列选项**(做事);判断选哪个由后续方案讨论 + 挑战者做(判断)。
- 调研产出是**证据 / 选项**,**绝不是判断依据**。
- 沿用 harness 扁平 fork 架构 + 公设 1(做事和判断分开)。

## 与红线的关系(必读 — `feedback_judgment_basis`)

- 红线 = **"不照搬,要经自己思考"**,**不是**"不许看 / 不许查"。
- 调研业界**技术方案**(有哪些做法、各自原理、适用前提)当**证据**是**允许且鼓励**的(尤其为下游项目开发时用)。
- 禁止的是:把别人的**数据 / 流行度**("X% 项目这么做")不经思考直接当判断依据 / 结论。
- 区分(EBSE):调研结果是"证据",要过"对我是否适用"这道闸才进决策。

## 第一步:判断要不要调研(默认不调研)

两根轴**都指向"值得"**才触发:

- **可逆性(主轴)**:这决定不可逆 / 影响大(改了难回头)→ 值得调研;可逆 / 小事 → 跳过,快速决断(Bezos 一道门 vs 两道门)。
- **熟悉度(次轴)**:当前对这块领域确实不熟 → 才有联网价值;已熟 → 内部知识够,联网反而引噪声降质(adaptive-RAG 研究证实无差别检索降质)。

**触发判断由你(调度者)做,不交给"要去调研的调研员自评"**(防自评偏差 — 公设 1;研究证实模型自评知识边界约 20% 误判)。

阈值不写死:本节给方向,具体松紧实战调(论文公式未过对抗核验,不照搬)。

**✅ / ❌ 对照**:
- ✅ 换核心架构 / 选长期依赖库 / 设计对外协议(不可逆 + 可能不熟)→ 调研
- ❌ 改文案 / 调参数 / 加内部小函数(可逆 + 熟)→ 跳过,直接进方案讨论

## 第二步:界定领域 + 问题,转成调研问题

fork 调研员前,你先界定:

- **这是什么领域、什么类型的问题**(常规问题 → 有成熟方案值得调研;没人做过的新问题 → 调研也调不到,转原型 / 实验)。
- 把方案设计问题**转成一个明确的调研问题**,给调研员四要素:**目标 / 产出格式 / 用什么源 / 边界**(模糊委派 → 调研发散)。
- framing 段是任务边界,遵守 `synthesis-rules.md` 中性化(不暗示结论)。

## 第三步:跑调研

- **默认**:`Workflow({name: "deep-research", args: "<你的调研问题>"})` — **deep-research 是 Claude Code 自带的工作流**(5 角度 → fetch 15 源 → 每条 claim 3 票对抗验证 → 带引用综合)。直接调,无需另装。
- **深度档**:简单问题用轻量档;复杂问题用完整档(deep-research 跑满)。按复杂度选,避免每次烧大量 token(一次完整 deep-research 可达百级 agent / 百万级 token)。
- **健壮性兜底**(仅工程稳健,非因怀疑可得性):万一某环境调不到 deep-research,fork 1 个 general-purpose subagent 用 claude 自带 WebSearch / WebFetch 做轻量调研(契约同第四步)。

## 第四步:产出整形(红线 — 核心)

不论底座是 deep-research 还是 WebSearch fork,调研产出**必须整形成**:

- **选项清单 + 每个选项的"适用前提 / 原始背景 / 跟我们是否匹配"** — **绝不给推荐排名**(给排名 = 用流行度替决策)。
- **硬规则**(照抄 Rust RFC):"别人 / 别的项目这么做,只是**部分参考,本身不构成采纳理由**。"
- 每个外部方案附:**它原本的背景**(为谁、什么规模、什么约束下设计)+ **跟本项目是否匹配**(context 不匹配 → 不进候选)。
- 每条带 **来源(URL)+ 可信度**;信息不足时标"无法定论"(合法出口,不是失败)。
- **UNPHAT 自检**(每个方案走一遍):理解问题 / 列多候选(含"不引入新东西")/ 读原始资料 / 历史背景 / 利弊代价 / 冷静评估契合度。
- **元自警**:UNPHAT 等框架是"提问清单",不是"填了就合规"的免死金牌(别用一种盲从换另一种)。
- 产出**写成 artifact 文件**(如 `docs/active/solution-research-<topic>.md`),交方案讨论;不长篇回传污染你的上下文。

## 第五步:交接

- 把产出文件路径交给方案讨论(brainstorming 阶段四),作为"选项输入"。
- 判断选哪个方案 → 仍由方案讨论 + 后续挑战者做。你在调研阶段不下结论。

## 调研 / 核查分离

- deep-research 已内建 3 票对抗验证(来源质量 / 矛盾证据 / 时效 / 营销话术过滤)。
- WebSearch fork 兜底时,调研员产出后你按需独立核查关键 claim(可复用挑战者机制)。

## 触发起源 + 设计依据

本能力 2026-05-29 加入。设计经三轮调研(缺口核查 / 业界做法 / 触发判据),依据见 spec `docs/superpowers/specs/2026-05-29-solution-research-scout-design.md` §1.2。关键外部依据:Anthropic multi-agent-research-system / Rust RFC 2333 / EBSE / UNPHAT / adaptive-RAG(IKEA 等)。
```

- [ ] **Step 2: 验证文件创建 + 关键内容**

Run from `D:/个人/harness`:
```bash
wc -l harness/.claude/agents/research-scout.md
# Expected: 60-90 行
grep -c "不照搬\|不构成采纳理由\|默认不调研\|deep-research\|不给推荐排名" harness/.claude/agents/research-scout.md
# Expected: ≥ 5(红线 + 触发 + 底座 + 整形 关键点都在)
grep -c "harness/docs/" harness/.claude/agents/research-scout.md
# Expected: 0(路径用裸 docs/,下游正确)
```

- [ ] **Step 3: Do NOT commit**(Commit 1 在 Task 2 末)

---

## Task 2: 改 brainstorming-rules.md(加"方案调研(按需)"节)+ Commit 1

**Files:**
- Modify: `harness/docs/governance/brainstorming-rules.md`

**Spec 来源:** §3.2

- [ ] **Step 1: 在"## 阶段四:方案讨论"之前插入新节**

定位 `## 阶段四：方案讨论`(brainstorming-rules.md 现有标题,全角冒号)。在它**之前**插入:

```markdown
## 阶段四前：方案调研(按需,默认跳过)

> 需求确认清单锁定后、提出方案前,判断是否值得**联网调研业界现有方案**。详细编排 + 红线契约见 `.claude/agents/research-scout.md`。

- **默认跳过**。两轴都指向"值得"才触发(详 research-scout.md 第一步):
  - **可逆性(主轴)**:不可逆 / 影响大 → 值得;可逆 / 小事 → 跳过
  - **熟悉度(次轴)**:不熟 → 有价值;已熟 → 内部知识够
- **触发判断由调度者做**,不交给待调研的调研员自评(公设 1)。
- 值得 → 按 research-scout.md:界定领域 + 问题 → 默认 `Workflow({name:"deep-research"})`(Claude Code 自带)→ 产出整形成"选项 + 适用前提"(不给推荐)→ 写 artifact,作为阶段四方案讨论的**选项输入**。
- 不值得 → 直接进阶段四。

> **与上方反模式约束的关系**:本节"调研业界技术方案"**不违反** `feedback_judgment_basis` 红线。红线 = "不照搬要思考",禁的是"用别人数据 / 流行度不经思考撑决策";调研技术方案当**证据 / 选项**(经思考判断是否适用)是允许的。区分:证据 ≠ 判断依据。
```

- [ ] **Step 2: 验证改动**

```bash
grep -c "阶段四前：方案调研" harness/docs/governance/brainstorming-rules.md
# Expected: 1
grep -c "research-scout.md" harness/docs/governance/brainstorming-rules.md
# Expected: ≥ 2
grep -n "## 阶段四前\|## 阶段四：方案讨论" harness/docs/governance/brainstorming-rules.md
# Expected: 阶段四前 在 阶段四：方案讨论 之前(行号小)
```

- [ ] **Step 3: Commit 1**

```bash
cd "D:/个人/harness"
git add harness/.claude/agents/research-scout.md harness/docs/governance/brainstorming-rules.md
git commit -F - <<'EOF'
docs(solution-research-scout): research-scout.md 新建 + brainstorming 加方案调研节

Commit 1(核心机制):
- 新建 harness/.claude/agents/research-scout.md — 方案调研编排说明(调度者读)。
  5 步:判断要不要调研(可逆性主轴+熟悉度次轴,默认skip,独立判断)→ 界定领域+问题
  → 跑调研(默认 deep-research,Claude Code 自带;WebSearch fork 兜底)→ 产出整形
  (选项+适用前提,不给推荐,UNPHAT,元自警)→ 交接。核心边界:调研=证据不是判断依据。
- brainstorming-rules.md 阶段四前加"方案调研(按需,默认跳过)"节,引用 research-scout
  路径;含与 feedback_judgment_basis 红线的关系说明(调研技术方案当证据 ≠ 用别人数据撑决策)。

spec: harness/docs/superpowers/specs/2026-05-29-solution-research-scout-design.md

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
git log --stat -1 | head -8
```
Expected: 2 files changed(1 新建 + 1 改)

---

## Task 3: 改 challenger-orientation.md §2.4(修正红线误读 + 加外部调研数据源)

**Files:**
- Modify: `harness/docs/references/challenger-orientation.md`

**Spec 来源:** §3.3

- [ ] **Step 1: 修正 §2.4 表里"跨项目→不查"那行 + 加外部调研数据源行**

定位 §2.4 表(现有最后两行):
```
| 用户在本会话的关键决策 | grep `type=user` in 当前 JSONL,按时间序 |
| 跨项目模式(其他项目类似设计) | **不查** — 用户校准 `[[feedback_judgment_basis]]` 禁止用别人项目数据支撑决策 |
```
**替换**最后一行 + 在其后加一行,变成:
```
| 用户在本会话的关键决策 | grep `type=user` in 当前 JSONL,按时间序 |
| 业界 / 别的项目的技术方案 | **可调研参考**(走 research-scout)— 但不照搬,看完基于事实和逻辑自己判断"对我们是否适用";别人的数据 / 流行度不能直接当判断依据 |
| 规划方案时的业界现有方案 | 外部联网调研(`.claude/agents/research-scout.md`,按需) |
```

- [ ] **Step 2: 在 §2.4 表之后加"外部调研与红线"小节**

在 §2.4 表后(下一个 `###` 标题之前,或 §2 末尾)插入:
```markdown
> **外部调研与红线**(2026-05-29 修正反复误读):
> - 红线(`[[feedback_judgment_basis]]`)= **不照搬要思考**,**不是**不许看。调研业界方案**允许且鼓励**(尤其为下游项目开发用)。
> - 调研结果是**证据 / 选项**,不是**判断依据**(EBSE:证据要过"对我是否适用"闸才进决策)。
> - 唯一禁止:把别人的**数据 / 流行度**("X% 项目这么做")不经思考直接当结论。
```

- [ ] **Step 3: 验证改动**

```bash
grep -c "不查.*禁止用别人项目数据" harness/docs/references/challenger-orientation.md
# Expected: 0(旧"不查"误读行已删)
grep -c "可调研参考\|外部调研与红线\|research-scout" harness/docs/references/challenger-orientation.md
# Expected: ≥ 3
grep -c "不照搬" harness/docs/references/challenger-orientation.md
# Expected: ≥ 2
```

- [ ] **Step 4: Do NOT commit**(Commit 2 在 Task 5 末)

---

## Task 4: 改 README.md(层 4 加"主动调研 / 重视外部输入"节)

**Files:**
- Modify: `README.md`(根级)

**Spec 来源:** §3.6

- [ ] **Step 1: 在 README 层 4 的 4.5(挑战者导览体系)之后加 4.6**

定位 `#### 层 5：反模式警示`(README 现有标题)。在它**之前**(即层 4 末尾、4.5 之后)插入:
```markdown
- **4.6 主动调研 / 重视外部输入** — harness 默认"内向"(搜本仓库 + 问用户);本能力补上"从仓库外获取新信息作决策输入"的链路。规划方案时,需求定了、讨论方案前,**按需**(可逆性主轴 × 熟悉度次轴,默认跳过)fork 联网调研员,默认用 Claude Code 自带的 deep-research 调研业界方案。**Why**:别让 AI 闭门造车;但联网有成本且无差别检索会降质,所以按需触发。**红线**:调研结果只当**证据 / 选项**(经自己思考判断是否适用),不当判断依据——"别人这么做不单独构成理由"。**实现**:`harness/.claude/agents/research-scout.md`(调研编排 + 红线契约)+ `brainstorming-rules.md` 阶段四前触发节。
```

> 注:README 是 harness 仓库级文档(不分发下游),路径用 `harness/` 前缀与其全文一致。

- [ ] **Step 2: 验证改动**

```bash
grep -c "主动调研 / 重视外部输入\|research-scout" README.md
# Expected: ≥ 2
grep -n "4.6 主动调研\|层 5：反模式" README.md
# Expected: 4.6 在 层 5 之前
```

- [ ] **Step 3: Do NOT commit**(Commit 2 在 Task 5 末)

---

## Task 5: 改 CLAUDE.md(M3 根)+ harness/CLAUDE.md(M4)角色表 + Commit 2

**Files:**
- Modify: `CLAUDE.md`(根级 M3)
- Modify: `harness/CLAUDE.md`(M4 分发模板)

**Spec 来源:** §3.5

- [ ] **Step 1: 改根 CLAUDE.md(M3)角色分离表**

定位根 `CLAUDE.md` §1 角色分离表里 `**方向评估**` 那行(`| **方向评估** | 调度者并行 fork 4 个挑战者 | RUBRIC 合规 / 架构一致 / 文档健康 / Slop 检测 |`)。在它**之后**加一行:
```
| **方案调研** | 调度者按需 fork research-scout(联网调研员) | 规划方案时界定领域+问题 → 联网搜业界方案 → 产出选项(证据,非判断依据) |
```

- [ ] **Step 2: 改 harness/CLAUDE.md(M4)角色分离表**

定位 `harness/CLAUDE.md`(M4 分发模板)§角色分离原则表里同样的 `**方向评估**` 行。在它**之后**加同一行:
```
| **方案调研** | 调度者按需 fork research-scout(联网调研员) | 规划方案时界定领域+问题 → 联网搜业界方案 → 产出选项(证据,非判断依据) |
```

- [ ] **Step 3: 验证两个角色表都加了**

```bash
grep -c "方案调研.*research-scout" CLAUDE.md
# Expected: 1
grep -c "方案调研.*research-scout" harness/CLAUDE.md
# Expected: 1
```

- [ ] **Step 4: Commit 2**

```bash
cd "D:/个人/harness"
git add harness/docs/references/challenger-orientation.md README.md CLAUDE.md harness/CLAUDE.md
git commit -F - <<'EOF'
docs(solution-research-scout): challenger-orientation 红线修正 + README + 角色表(配套)

Commit 2(配套 + 红线修正):
- challenger-orientation.md §2.4:修正反复误读的红线 — 上 batch 写的"跨项目→不查"
  改为"可调研参考,但不照搬、看完自己判断是否适用";加外部调研数据源行 + "外部调研
  与红线"小节(红线=不照搬要思考,不是不许看;调研=证据非判断依据)
- README.md 层 4 加 4.6"主动调研 / 重视外部输入"
- CLAUDE.md(M3 根)+ harness/CLAUDE.md(M4)角色分离表各加"方案调研"行

红线说法纠正源于 user review(feedback_judgment_basis 误读多次);memory 已同步钉死。

spec: harness/docs/superpowers/specs/2026-05-29-solution-research-scout-design.md

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
git log --stat -1 | head -8
```
Expected: 4 files changed

---

## Task 6: 全局自检(meta-finishing 前置)

**Files:** Read-only verification

**Spec 来源:** §6.2 验收清单

- [ ] **Step 1: G1-G6 spec 目标核对**

```bash
cd "D:/个人/harness"
# G1 research-scout 5 步
grep -c "第一步\|第二步\|第三步\|第四步\|第五步" harness/.claude/agents/research-scout.md
# Expected: ≥ 5
# G3 触发判据(可逆性主轴+熟悉度次轴+默认skip+独立判断)
grep -c "可逆性(主轴)\|熟悉度(次轴)\|默认不调研\|不交给.*自评" harness/.claude/agents/research-scout.md
# Expected: ≥ 4
# G4 红线契约(不给推荐 + Rust RFC + 元自警)
grep -c "不给推荐排名\|不构成采纳理由\|免死金牌" harness/.claude/agents/research-scout.md
# Expected: ≥ 3
# G2 deep-research 默认 + 自带
grep -c "deep-research.*Claude Code 自带\|默认.*Workflow({name:\"deep-research\"})" harness/.claude/agents/research-scout.md
# Expected: ≥ 1
# G5 红线修正(challenger-orientation 旧"不查"误读已清)
grep -c "不查.*禁止用别人项目数据" harness/docs/references/challenger-orientation.md
# Expected: 0
# G6 不新增 skill/hook/不改 model-route
git diff --stat 1ddd5ec~1..HEAD -- harness/.claude/skills/ harness/.claude/hooks/ harness/docs/governance/model-route.md
# Expected: 空(这三处无改动)
```

- [ ] **Step 2: 改动文件清单核对(6 文件)**

```bash
# 实施 2 commits 共改 6 文件;逐个确认(避免把 spec/plan commit 混入):
test -f harness/.claude/agents/research-scout.md && echo "✓ research-scout.md(新建)"
for f in harness/docs/governance/brainstorming-rules.md harness/docs/references/challenger-orientation.md README.md CLAUDE.md harness/CLAUDE.md; do
  git log --oneline -3 -- "$f" | grep -q "solution-research-scout): " && echo "✓ $f" || echo "✗ $f"
done
# Expected: 6 行 ✓
```

- [ ] **Step 3: commit 历史核对**

```bash
git log --oneline -4
# Expected(top 2 是本 batch 实施):
# <commit2> docs(solution-research-scout): challenger-orientation 红线修正 + README + 角色表
# <commit1> docs(solution-research-scout): research-scout.md 新建 + brainstorming 加方案调研节
# b508457 docs(solution-research-scout): spec 修订(user review 反馈)
# 1ddd5ec docs(solution-research-scout): spec 立
```

- [ ] **Step 4: 准备 meta-finishing 输入**

确认就绪(meta-finishing 阶段用):
```text
## meta-finishing 准备
- batch_name: solution-research-scout
- scope: meta(C 组 agent + A 组 governance/CLAUDE + D 组 references)
- commits: 1ddd5ec..HEAD(spec 立 + spec 修订 + 实施 2 commits)
- 涉及文件: 6(1 新建 + 5 改)
- finishing 路径: M1 meta-finishing + M2 meta-review(对抗式 D2)
- Evidence Depth 目标: meta-L2
- Meta-review 模态: 对抗式 D2,bootstrap 4 维 + 2 定制专项(红线自洽 + 健壮性兜底,spec §5)
- 已知预期 finding: spec §7.2 风险 R1-R5 + §7.3 KG(deep-research 可得性 / 触发阈值未定量 / 知识边界难量化)
```

- [ ] **Step 5: 闭环通知** — 实施完成,下一步进 M1 meta-finishing(scope=meta;Step B 必跑 meta-review;push 前停等用户确认)。

---

## 后置 — 不在本 plan 范围

- decision-trail.md / handoff.md 更新:meta-finishing Step D 同步,不在本 plan
- meta-review 本身:M1+M2 流程,finishing 阶段触发
- push origin/main:meta-review pass + 用户确认后

---

## Spec ↔ Plan 对照(self-review)

| Spec 节 | 对应 Task |
|---|---|
| §3.1 research-scout 6 节 | Task 1 |
| §3.2 brainstorming-rules 触发节 | Task 2 |
| §3.3 challenger-orientation §2.4 红线修正 + 数据源 | Task 3 |
| §3.4 deep-research 自带(无需 recommended-tools)| Task 1 §3(写明自带)+ Task 4 README + Task 5 角色表 |
| §3.5 CLAUDE M3/M4 角色表 | Task 5 |
| §3.6 README 原理段 | Task 4 |
| §9 commit 策略(2 commits)| Task 2 / Task 5 commit 步 |
| §6.2 验收清单 | Task 6 自检 |

**Spec 全覆盖** ✅(§3.4 deep-research 自带说明分散在 research-scout §3 + README + 角色表三处,符合 spec §3.4"三处说明"约定)

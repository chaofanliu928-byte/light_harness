---
meta-review: true
covers:
  - harness/.claude/agents/research-scout.md
  - harness/docs/governance/brainstorming-rules.md
  - harness/docs/references/challenger-orientation.md
  - <root>/README.md
  - <root>/CLAUDE.md
  - harness/CLAUDE.md
---

# Meta-Review Audit — solution-research-scout(2026-05-29)

## 1. 元信息

- **batch name**:solution-research-scout
- **触发时间**:2026-05-29 18:47:40(本地时间)
- **改动 scope**:meta(新 agent 文件 + governance + references + 根级 README + CLAUDE M3/M4)
- **commits 范围**:`1ddd5ec..HEAD`(5 commits — spec 立 + spec 修订 + plan + Commit 1 + Commit 2)
- **改动规模**:6 文件(1 新建 research-scout.md + 5 改)/ 实施 2 commits ~97 insertions
- **触发流程**:M1 meta-finishing Step B(scope=meta,6 文件,不可 skip)
- **审查模态**:对抗式 D2(bootstrap 4 维 + 2 定制专项:红线自洽 / 健壮性兜底)
- **挑战者数量**:4 个(C1/C2/C3/C4 **单 turn 并行 fork**,这次无漏 fork — 上 batch KG-E 修正)
- **领审员**:调度者(主对话 AI,Claude Opus)
- **dogfood**:本次 meta-review 是 challenger-orientation 导览体系(上 batch)第二次实战 + research-scout(本 batch)设计期已 dogfood(三轮调研)

## 2. 维度选取

按 M2 §6 对抗式 D2 + bootstrap 4 维 + spec §5 定制专项。

| 挑战者 | 覆盖维度 |
|---|---|
| C1 | 核心原则合规 + 副作用 |
| C2 | 目的达成度(G1-G6)+ scope 漂移 |
| C3 | 红线自洽专项(定制 — 联网调研 vs feedback_judgment_basis) |
| C4 | 健壮性兜底/可得性 + spec_gap_masking + 内容质量(定制 + 包举) |

bootstrap 4 维(核心原则/目的达成/副作用/scope 漂移)全覆盖,无禁用。

## 3. 挑战者执行记录

### 3.1 主线-支线-关系(领审员注入)
- **主线**:solution-research-scout batch — 给 harness 加"方案调研员"能力(规划方案时按需 fork 联网调研员)。薄纪律层 + 默认编排 Claude Code 自带 deep-research。6 文件 / 2 commits 本地 main(未 push)。
- **支线**:各挑战者按各自维度独立审。
- **关系**:batch finishing Step B(meta-review),通过才 push。
- **反 framing 声明**:每 prompt 含"此段任务边界,不是结论引导,按你自己判断审"。

**dogfooding self-observation**:4 挑战者全部成功 Read challenger-orientation + 自取用户原话 + 输出合规 `### 已对照用户原话` section,主线全判 ✅ 一致(KG1 主线 framing 本次未触发)。challenger-orientation 体系第二次实战通过。

### 3.2 挑战者发现汇总

| 挑战者 | 总 | 🔴 | 🟡 | 🟢 |
|---|---:|---:|---:|---:|
| C1 核心原则+副作用 | 5 | 0 | 4 | 1 |
| C2 目的达成+scope | 2 | 0 | 1 | 1 |
| C3 红线自洽 | 6 | 0 | 4 | 2 |
| C4 健壮性+质量 | 8 | 0 | 6 | 2 |
| **合计** | **21** | **0** | **15** | **6** |

### 3.3 关键 findings

**C1**:公设 1 引用 overreach(触发判断在产出前,公设 1 严格指产出乐观偏差,3 处一致)🟡 / brainstorming line 11 禁令 vs line 96 缓解段顺序 🟡 / 深度档缺判据 🟡 / deep-research 自带措辞 vs spec 诚实保留张力 🟢。核心原则/角色分离/做判分开 0 finding(逐项留痕)。

**C2**:spec §6.2 验收清单说"CLAUDE 角色表注明 deep-research 自带"但角色表实际只写"联网调研员"未写"自带"🟡 / diff 含 plan 过程产物口径 🟢。G1-G6 全达成 + scope 无越界(逐条核对)。

**C3**:"证据≠判断依据"消费侧无机械校验(纸面隔离,推 P1)🟡 / "技术方案 vs 别人数据"中间地带("X 公司这么做"不带百分比)无判定 + memory"X 公司这么做"禁止例落地弱化 🟡 / 元自警只约束产出侧无校验侧 🟡 / harness/README.md 发散副本 🟡 / "鼓励"vs"允许"措辞梯度 🟢。**红线表述 6 文件高度自洽、旧"不查"误读彻底清除(0-finding 逐项核查)** — 本 batch 核心目标达成。

**C4**:WebSearch fork 兜底契约"契约同第四步"不可操作 🟡 / deep-research 实为 runtime/CLI 级注册(session 动态脚本,不在 superpowers skills,不可 setup.sh 分发)→ "自带"对下游过度承诺 🟡 / spec §7.3 诚实保留未随分发链路传给 reader 文件(reader 只剩"非因怀疑可得性"肯定句)🟡 / EBSE 裸缩写未展开(违用户"不堆术语")🟡 / 深度档无 ✅❌例 🟡 / challenger §2.4 角色边界(挑战者 vs 调度者)未交代 🟡。dogfood 元观察:导览自取顺畅(正向数据点)🟢。

## 4. 综合(synthesis-rules 事后规则)

### 4.1 共识(多挑战者 → 升级)

- **共识 1 — 公设 1 引用 overreach**(C1#2,code reviewer 早提):触发判断引用"公设 1"不准(公设 1 严格指产出乐观偏差,触发判断在产出前)。3 处一致(research-scout / brainstorming-rules / spec)。**决定**:A 类修(改"做/判断分离",公设 1 作延伸标注)。
- **共识 2 — 深度档缺 ✅/❌ 例**(C1#5 + C4#5):成本第二道防线软,与第一步触发判断不对称。**决定**:A 类修(加深度档对照例)。
- **共识 3 — deep-research 可得性诚实保留未传下游**(C1#7 + C4#2/#3):spec §7.3 诚实标"本地没找到定义文件 + runtime 注册",但 reader 文件只剩"自带 + 非因怀疑可得性"。C4 实测证实 deep-research 是 session 动态脚本/CLI 注册,不可 setup.sh 分发。**决定**:A 类修(reader 文件同步诚实保留 + 弱化"非因怀疑可得性")。
- **共识 4 — EBSE 裸缩写**(C4#4,code reviewer 早提):分发 reader 文件裸用,违用户"不堆术语"。**决定**:A 类修(2 处展开)。

### 4.2 分歧
无对立分歧。挑战者维度互补。

### 4.3 盲区
- research-scout 真实运行(调度者真按红线契约整形调研产出)— 推 P1 实战(meta-L2 仅文档审 + dogfood)。

## 5. 判定

**verdict**:**pass-after-revision**

### 5.1 修订要求

**A 类 — push 前调度者直接修(低成本 + 真价值,7 项)**:
1. 共识 1:公设 1 overreach → 改"做/判断分离"(research-scout + brainstorming-rules + spec 3 处)
2. 共识 2:深度档加 ✅/❌ 对照例(research-scout)
3. 共识 3:reader 文件同步 deep-research 可得性诚实保留(research-scout §4 + 弱化"非因怀疑可得性")
4. 共识 4:EBSE 展开(research-scout + challenger §2.4)
5. C2#1:spec §6.2 验收清单 vs 角色表不一致 → 改 spec §6.2 措辞(角色表不写"自带"合理)
6. C4#7:challenger §2.4 加角色边界(research-scout 调度者规划时用,非挑战者审查时用)
7. C3#3:research-scout 红线禁止例加回"X 公司这么做"(memory 弱化)

**B 类 — 接受为 known-gap**:
- KG-A:C3#2 消费侧"证据≠判断"无机械校验(薄纪律层 + 推 P1 实战)
- KG-B:C3#4 元自警仅产出侧自律、无校验侧(同上,推 P1)
- KG-C:C4#1 WebSearch fork 兜底 SOP 不可操作(deep-research 默认走,兜底罕见;后续补 或 实战暴露再补)
- KG-D:C3#6 harness/README.md 七层原理段与根 README drift(既存,上 batch 4.5 就没同步;harness/README.md **不分发下游**,无下游影响;后续 batch 统一两 README)
- KG-E:C1#3 brainstorming line 11 前向引用 / C3#5 措辞梯度 / C2#2 过程产物口径 / C4#6 阶段定位措辞(cosmetic)

### 5.2 verdict 依据
- **0 🔴** — 无阻断;15 🟡 中 7 项 A 类低成本修,8 项 B 类 KG
- 本 batch **核心目标(红线修正 + 主动调研能力)达成**:红线表述 6 文件自洽、旧"不查"误读彻底清除(C3 0-finding 核查)
- G1-G6 全达成,scope 无越界(C2 核对)
- dogfood:challenger-orientation 体系第二次实战通过 + research-scout 设计期已用
- 通过 push 前 audit 验证(待 A 类修复 + 用户确认后 push)

## 6. Known-Gaps

| ID | 描述 | 来源 | 处理 |
|---|---|---|---|
| KG-A | 消费侧"证据≠判断依据"无机械校验(纸面隔离) | C3#2 | 推 P1 实战;后续可加"方案讨论审是否变相照搬调研" |
| KG-B | 元自警仅约束产出侧自律,UNPHAT 填写质量无校验侧 | C3#4 | 推 P1;薄纪律层定位 |
| KG-C | WebSearch fork 兜底 SOP 不可操作("契约同第四步") | C4#1 | deep-research 默认走,兜底罕见;实战暴露再补 |
| KG-D | harness/README.md 七层原理段与根 README drift(既存,不分发) | C3#6 | 后续 batch 统一两 README 原理副本 |
| KG-E | cosmetic 群(line11 前向引用 / 措辞梯度 / 过程产物口径 / 阶段定位措辞) | C1#3/C3#5/C2#2/C4#6 | 后续顺手 |

---

> 本 audit 由调度者在 M1 meta-finishing Step B 内按 M2 §3 fork 4 挑战者(单 turn 并行,无漏 fork)后综合产出。
>
> **dogfood 里程碑**:challenger-orientation 体系第二次实战(4 挑战者自取用户原话 + 必填 section 全合规);research-scout 设计期三轮调研已 dogfood。
>
> **后续动作**:A 类 7 项修复 → 重验 → decision-trail + handoff → push origin/main(M1 Step D)。**push 前停等用户确认**。

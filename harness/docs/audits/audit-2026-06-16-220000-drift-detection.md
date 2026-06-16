---
audit: true
covers:
  - .claude/agents/drift-scout.md
  - setup.sh
  - docs/governance/finishing-rules.md
---

# audit:触点漂移检测机制(drift-scout)(知识系统 Step2 ③b — 治理面收口凭证)

> 本批 = 知识系统 Step2「★ 设计层到手边」的 **③b 漂移检测机制(drift-scout 收口子智能体)**——序里最后一块。改动物:新建 `.claude/agents/drift-scout.md`(162 行契约:收口·凭证批·audit 内 fork,读 ③a touchpoint-registry 13 触点逐触点读两端点、按 5 类判据判漂移、报告分层、只读不写、软降级)+ `setup.sh` agents 段 +1 行 cp(自指分发)+ `finishing-rules.md` 凭证义务核对节加 step 19-21「触点漂移检测」(门控=仅凭证批 audit 内自动跑)。covers = 命中凭证的 3 文件(`.claude/agents/*.md` / `setup.sh` / `docs/governance/*.md`)。spec/plan(`docs/superpowers/*`)非凭证,不入 covers。

## 1. 元信息

- 批次:触点漂移检测机制(③b);分支 `drift-detection`
- 审查对象:drift-scout.md 新建(162 行)+ setup.sh(+1 行自指 cp)+ finishing-rules.md(+step 19-21)
- 凭证类型:对抗审查 audit(命中 credentials.conf:`.claude/agents/*.md` + `setup.sh` + `docs/governance/*.md`)
- 模态:对抗式;治理审查 N=5(核心原则合规 / 目的达成度 / 副作用守住 / scope 漂移 / **触点完整性**[条件必选——本批涉及机制产出/消费契约 + 分发链,必选]);单 turn 并行 fork(workflow `drift-finishing-audit`);synthesis-rules 事前中性 + 事后按证据综合
- **红线测前置证据**(收口前调度者亲跑,验"scout 真能逮漂移"非"跑了不报错"):fork 真 drift-scout 两次——(a) **baseline 干净仓库** → 出参 `AllAligned`,13 触点全 ✅,**0🔴/0⚠️**(验不误报);(b) **注入两真漂移**(setup.sh 删 drift-scout cp 行 + review-rules design 维名加 DRIFT 后缀不同步 workflow.js)→ 出参 `DriftReport`,精确逮 **TP-09 🔴**(分发链漏改 drift-scout.md)+ **TP-06 🔴**(design 维名逐字失配,并交叉验证 DRIFT 为上游游离 token、给正确修向)+ 其余 11 ✅。注入已 revert,树干净。两条死结(散文端点判逐字 + 分发模型 glob覆盖)实证可逮。
- **方向评估站位**:③b 是用户已拍板执行序(①修复→②B→③a→③b)中的最后一步;形态(scout B)+ 门控(凭证批)在 brainstorming/设计阶段已用户批准、design-review(review-scout dogfood)两轮修订过。无新方向。故不另跑方向评估,治理审查核"实现忠于锁定 spec + 守住不退化 + 机制契约自洽可跑通 + 触点同步改全"。
- 时间:2026-06-16 22:00

## 2. 维度选取

- B(bootstrap)取 核心原则合规 / 目的达成度 / 副作用守住 / scope 漂移(4 维强制基线全取——本批是机制落地,目的达成度=机制真能跑通须实核)。
- A 取 **触点完整性维**(条件必选触发:本批是"机制的产出/消费契约 + 分发链"——drift-scout.md 产出契约 ↔ registry 消费 / setup.sh 自指分发 / finishing 引契约 / 门控与 review-rules 触点维互补,逐触点核同步必选)。
- 禁用:安全扫描 / 流程审计(治理批暂不纳入,沿 finishing-rules 治理批适用注);方向评估(③b 是已拍板序末步,形态/门控已批,无新方向,见 §1 站位)。

## 3. 挑战者执行记录(5 独立 fork;git diff main..drift-detection + 端点对源 + 红线逻辑复核)

- **核心原则合规**:verdict=**pass**(7🟢)。做事/判断分离(scout 只读判漂移=做事;🔴 修不修/回填=判断归调度者,契约 L13-17 + finishing step 20 + spec D4 三处一致)、二公设(机制=把人肉触点维 codify 成 Read/Grep 外部动作,判不准标 ⚠️ 不硬猜;退化诚实声明过 spec_gap_masking 戒条)、最小变更(仅 3 文件无溢出)、文档第一(spec 56065ec 先于实现三 commit)、门控措辞与 spec §4.2 四处口径一致且与既有治理同层互补不冲突。
- **目的达成度**:verdict=**pass**(7🟢+1🟡)。5 类判据→13 触点全覆盖零 ⏭️ 盲区(逐 TP 对 registry 判据列核:存在性=TP-03/glob覆盖=TP-09/逐字=TP-01·06·07/结构等价=TP-04·05·08·10·11/单源派生=TP-02·12·13,1+1+3+5+3=13);出参二态+报告分层自洽可消费(与 finishing step 19-21 消费动作一一对接);两条红线判法逻辑独立复核成立(TP-09 逐 cp 行类判法 / TP-06 散文端点定位逐字比);TP-13 单源派生护栏防双向 1:1 误报。**1🟡(观察项,不阻断)**:红线只实证了 glob覆盖+逐字一致两类判法;**结构等价/单源派生类(LLM 语义判)的判松漏报率未实证**——spec §6.3 已诚实声明此退化风险(承认会误报✅+给人核终兜+不假装根除),符合 spec_gap_masking 戒条,故不阻断;建议 meta-L4 观实战判松率,必要时补红线。
- **副作用守住**:verdict=**pass**(10🟢)。**教科书级纯 ADD**:三文件 numstat = drift-scout.md(162/0)+ finishing-rules.md(8/0)+ setup.sh(1/0),171 增/0 删,全分支 diff 无真实删除行。守住零改 8 项 git diff 实证:③a 注册表(随 93f40ec 入 main,本批 diff 空)/ 6 个 check-* hook(含对账三命令,name-status 空)/ finishing 既有 step 1-18(单 hunk 纯插入,两侧上下文字节相同)/ credentials.conf(空 diff,不新增 glob)/ 既有 3 scout + 全部其余 agent(仅 `A drift-scout.md`)/ preferences frontmatter(空)/ setup.sh 既有 cp 行 + 循环段(仅 +1)/ 外围治理配置(settings/QUICKREF/README/AGENTS/templates/workflow.js/review-rules/CLAUDE 全 name-only 空)。新契约 HTML 注释形态不引入 agent 注册副作用。
- **scope 漂移**:verdict=**pass**(6🟢)。分支只碰 5 文件(3 改动物 + spec + plan,后者是文档先行规则要求的权威源工件非顺手);registry schema 零 diff 实核(scout 纯消费方,"是否加结构化列"正确作 🟡-1 反馈交回 ③a 未擅改);credentials.conf 零新增 glob(drift-scout.md 被既有 `.claude/agents/*.md` 纳管);未建第 7 个 check-* hook、无运行时代码、无开场对账第 4 命令;门控严格限凭证批未擅扩到非凭证批/全收口;自指分发是必需非镀金(红线 b 实证不加则 scout 自查 🔴)。
- **触点完整性**:verdict=**concern**(4🟢+1🟡)。三处契约字节对齐:入参 6 字段(drift-scout.md ↔ spec §3.1 ↔ finishing step 19 注入)/ 出参二态+TouchpointVerdict 5 字段+三前缀+TP-09 分类+TP-13 护栏(契约 ↔ spec §3.1/§4.3/§4.4/§4.5)/ 5 判据 enum(契约 ↔ registry L18 取值域 + 各行判据列,集合同);setup.sh 自指 cp 到位(scout 自查 TP-09 不逮自己);门控互补不矛盾不重复(finishing 机械预检 + review-rules 条件必选人工深审,双层不互斥,降级口径一致)。**1🟡(后续跟进项,不阻断)**:drift-scout.md(L8/L162)声明其判据语义/触点清单/判据 enum 派生自 registry 判据列+spec——这与 **TP-12**(freshness-rules 上游↔freshness-scout 派生)**同构**,即新增了一个触点(registry 判据列[上游]↔drift-scout 判据→判法映射表[派生]),改 registry 判据 enum 而漏同步 drift-scout 映射表即静默漂移,但本批未登此 TP 行。挑战者判:spec §10.1 守住段+§2.1 一致地把 registry 划为本批不改(scout 是消费方)、registry 维护规则示体检-来源行在独立批补登,故**非本批内漏改(red),而是应作后续 ③a 跟进登记的非对称缺口(yellow)**。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:4 维 pass + 触点完整性 concern;副作用守住(教科书纯 ADD 171/0,8 项零改 git diff 实证)+ scope(只碰 5 文件,registry/conf 零 diff)+ 核心原则(做事判断分离/最小变更/文档第一/门控同层)三维零瑕;目的达成度由**红线测前置证据**(baseline AllAligned 13✅ 不误报 + 注入两漂移精确逮 TP-09/TP-06)实证"scout 真能逮漂移"——这是 ③b 价值的核心证据,非纸面契约。
- **2🟡 处置(均非 🔴、均 ③b 之外、均不阻断收口)**:
  - ① 目的达成度 🟡(语义判类判松率未实证)→ **ROADMAP 观察项**(meta-L4 观实战;结构等价/单源派生类必要时补红线)。spec §6.3 已诚实声明,本就是承认的残余风险,非新缺口。
  - ② 触点完整性 🟡(drift-scout↔registry 派生关系同 TP-12 同构未登 TP 行)→ **③a 跟进项**(handoff 待晋升/ROADMAP)。是否加该 TP 行值得小决策:(a) drift-scout 自查自己契约 vs registry 有**递归性**(checker 查自身),边际价值待判;(b) drift-scout.md L10 散文已声明派生关系 + "改判据先改 registry 引指针不另立第二权威",改 registry 判据 enum 是凭证改动 → 触发 audit → 人工触点完整性维兜;(c) 不在收口仓促加(加 registry 行=改 registry=须自己的 audit + � spec §10.1 边界)。故登记交 ③a 触批裁。
- **meta-L4(dogfood 正向数据)**:③b 是 harness 首个"机械化触点完整性维"的机制,且收口当场用**它自己**(fork 真 drift-scout)跑红线测验证自己——自举闭环成立(baseline 不误报 + 注入精确逮)。同时审查暴露的两 🟡 恰是机制的诚实边界(语义判类未实证 / 自身派生未登记),非掩盖——契约 spec §6.3 事前已声明,审查事后确认,无 spec_gap_masking。
- 无新决策拐点(③b 是已拍板序末步;两 🟡 是登记/观察非方向推翻)。

## 5. 判定

**verdict: pass**(5 挑战者:核心原则/目的达成/副作用守住/scope 4 维 pass;触点完整性 concern;**0🔴**;2🟡 均非本批漏改、均 ③b 之外、均不阻断——登记 ROADMAP 观察项[语义判类判松率]+ ③a 跟进项[drift-scout↔registry TP 行])。本 audit covers 命中凭证 3 文件(drift-scout.md / setup.sh / finishing-rules.md)。守住:8 项零改 git diff 实证(注册表 13 行+判据 enum / 6 check-* hook / 对账三命令 / finishing 既有 step 1-18 / credentials.conf / 既有 3 scout / preferences / setup.sh 既有行)。红线测前置实证 scout 真能逮漂移(TP-09 分发链 + TP-06 逐字)且不误报(baseline 13✅)。知识系统 Step2 ③b 可收口——**完成 ③b、完成 Step2「★ 设计层到手边」上游段(①②③a③b)、完成"做3再做1"**;C(下游设计层导航)押后。

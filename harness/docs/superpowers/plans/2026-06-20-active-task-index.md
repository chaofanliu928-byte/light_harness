# 活跃任务索引(active-task-index)Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 handoff 单一台账里升格出一张「活跃任务索引」机读表,让挂起的任务线不被覆写蒸馏掉、让 AI 开场一眼知道有几条活。

**Architecture:** harness-meta 机制,**无运行时代码 / 无 API / 无 DB**。产物 = 改 3 文件(T1 字段集单源模板 / T2 structured-handoff SKILL 覆写·自查工序 / T3 check-handoff.sh `--reconcile` 结构核段)+ credentials-rules.md §8 双写条目。唯一有可测行为的是 T3 的机器结构核(bash grep/awk),TDD = check-handoff fixture 先红后绿(造畸形 handoff fixture → `bash check-handoff.sh --reconcile` → 看 stderr 点名 + 恒 exit 0);其余为文档编辑,验证靠静态核 + 触点逐字核。

**Tech Stack:** Bash(check-handoff.sh,POSIX/grep/awk)+ Markdown(模板/SKILL/治理文档)。无测试框架——验证 = 临时 handoff fixture 跑 `--reconcile` 观察。

**权威 spec:** `docs/superpowers/specs/2026-06-19-active-task-index-design.md`(锁定;经 brainstorm→system-design→自检✅→design-review ×2→修订→验证)。**计划须对齐 spec §2/§3/§4;如需偏离须先回系统设计改 spec,不在计划里静默偏离(planning-rules)。**

## Global Constraints(每个任务隐含包含;值逐字抄自 spec)

- **强度=中 / 方案B(人声明任务线,不锚 git)**:已锁定,不重新设计(spec §1.5)。
- **机器核最窄(旋钮①)**:T3 只核两条与措辞无关的结构事实 ——(1) 机读表头存在性 + 半角文法 ERE;(2) 挂起行复活触发器列非空。**不核**计数自洽(N==X+Y 落 ④自查)、**不核**指针 test-f、**不 grep 任何模板内部占位文本**(`[待填]`/`[待更新]` 类,防 kb 事实3 死条件漂移)。
- **恒 exit 0、无 exit 2**:`--reconcile` 工具箱契约(check-handoff.sh:139);全软提醒走 stderr 点名。**不进 Stop 模式**(自仓库 hook 不在场,加了白加)。
- **机读表头文法 ERE(严格半角)**:`^活跃任务: [0-9]+\(进行中 [0-9]+ / 挂起 [0-9]+\)$`;空账写 `活跃任务: 0(进行中 0 / 挂起 0)` 不写「无」。半角纪律沿既有全角检测(check-handoff.sh:173 `grep -F -e '（' -e '）' ...` 列举范式,**不用管道**)。
- **落点**:`## 活跃任务索引` 精确落在 `## 目标` 之后、`## 进度`(抽离后只剩 `### 已完成`)之前;**必在 `## 待晋升暂存` 之前**(规避 archive_staging awk 窗,check-handoff.sh:123-131)。
- **状态二态 {进行中, 挂起}**;4 列 `| 状态 | 任务 | 复活触发器 | 指针 |`;挂起行复活触发器**必填非空**,进行中行填 `—`。
- **3 条诚实限度保留不删**(spec §10.2:①③在场性同源 / 僵尸线撞公设1 / 只部分规避 kb 击穿点5)。
- **awk 列映射**:Markdown 表行 `| 挂起 | ... |` 用 `awk -F'|'` 切 → 行首 `|` 致 `$1` 空,**状态=`$2`、触发器=`$4`**(均 trim);section 在 `^## 活跃任务索引` 开窗、遇下一个 `^## ` 关窗(镜像 archive_staging)。
- **凭证义务**:改 T1/T2/T3 命中 credentials.conf(`.claude/skills/*/*.md` L24 + `.claude/hooks/*` L18)+ Task 4 改 `docs/governance/*.md`(L9)→ 语义变更非 typo → **收口必走对抗审查 audit(verdict=pass),不可 exempt**(credentials-rules §4.4)。

---

## File Structure(决策锁定)

| 文件 | 责任 | 任务 |
|------|------|------|
| `harness/.claude/skills/structured-handoff/handoff-template.md` | 字段集单源:升格结构骨架(契约) | Task 1 |
| `harness/.claude/hooks/check-handoff.sh` | `--reconcile` 机器结构核段(唯一可测代码) | Task 2(TDD) |
| `harness/.claude/skills/structured-handoff/SKILL.md` | ③覆写步 + ④自查步工序 | Task 3 |
| `harness/docs/governance/credentials-rules.md` | §8 表头 token + section 标题双写条目 | Task 4 |
| (验证)`harness/docs/active/handoff.md`(live) | 收口 `/structured-handoff` 用新模板覆写时自动对齐;无需独立实现任务 | 收口自动 |

**live handoff 对齐**:T1 模板改后,本批收口的 `/structured-handoff` 覆写即用新模板把 live 对齐到新结构——窗口期≈0(同批收口闭合),**不单列实现任务**;Task 5 验证时核 live↔template 一致。

---

## Task 1: T1 升格 handoff-template.md(契约——字段集单源)

**Files:**
- Modify: `harness/.claude/skills/structured-handoff/handoff-template.md`(现 `### 进行中` L19-20 / `### 阻塞` L22-23 在 `## 进度` 下;`## 待晋升暂存` L29)

**Interfaces:**
- Produces:「活跃任务索引」段结构骨架(机读表头 `活跃任务: N(进行中 X / 挂起 Y)` + 4 列二态表 + 空表占位行 + HTML 注释),T2 `!cat` 运行时注入消费、T3 ERE/awk 据此核。

- [ ] **Step 1:读现状定位**。Read `handoff-template.md`,确认 `## 目标` / `## 进度`(含 `### 已完成` / `### 进行中` / `### 阻塞`)/ `## 待晋升暂存` 的实际行号(spec §8.1 标 L14/L16/L19/L22/L29,以实读为准)。
- [ ] **Step 2:抽离 + 升格**。把 `### 进行中` / `### 阻塞` 两子节从 `## 进度` 抽出,在 `## 目标` 之后、`## 进度` 之前新增顶层段(`## 进度` 抽离后只剩 `### 已完成`):

```markdown
## 活跃任务索引

活跃任务: 0(进行中 0 / 挂起 0)

<!-- 一行一条人声明的任务线(方案B:不锚 git,含未开分支探索线)。状态枚举仅 进行中|挂起(与 promotion「阻塞(理由)」正交,不混)。 -->
<!-- 挂起行「复活触发器」列必填非空(何条件下重新捡起);进行中行填 —。指针 = -> docs/相对路径 — 为什么读 / — / 未沉淀线 [未沉淀]。 -->
<!-- 机读表头半角纪律:活跃任务: N(进行中 X / 挂起 Y);空账写 0 不写「无」。覆写时逐行重声明「这条还活着吗」(SKILL ③覆写步)。 -->
| 状态 | 任务 | 复活触发器 | 指针 |
|---|---|---|---|
| (无活跃任务) | | | |
```

- [ ] **Step 3:静态核版式**。Read 改后文件,确认:① 机读表头行匹配 ERE `^活跃任务: 0\(进行中 0 / 挂起 0\)$`(全半角,空格/斜杠/括号逐字符对);② 段落在 `## 目标` 后、`## 待晋升暂存` 前;③ `## 进度` 只剩 `### 已完成`。
- [ ] **Step 4:Commit**。

```bash
git add harness/.claude/skills/structured-handoff/handoff-template.md
git commit -m "feat(handoff): 升格 进行中/阻塞 为 活跃任务索引 模板骨架"
```

---

## Task 2: T3 check-handoff.sh `--reconcile` 结构核段(TDD——唯一可测代码)

**Files:**
- Modify: `harness/.claude/hooks/check-handoff.sh`(`--reconcile` 分支内,promotion 核之后**追加**;不动既有 promotion 分支 / 不动 Stop 模式 L321 起)

**Interfaces:**
- Consumes: live handoff 的「活跃任务索引」段(Task 1 模板结构)。
- Produces: 开场对账时对 live handoff 的两条机器结构核(表头文法 / 挂起触发器非空),stderr 点名 + 恒 exit 0。

> **TDD 形态(harness fixture)**:无测试框架。每条"测试"= 写一个临时 handoff fixture → 跑 `bash harness/.claude/hooks/check-handoff.sh --reconcile`(注意 `--reconcile` 读 `docs/active/handoff.md`,fixture 用临时文件 + 还原,或在临时目录构造)→ 观察 stderr 点名 + `echo $?`==0。**先红(畸形 fixture 当前不被点名)→ 实现 → 后绿(被点名且 exit 0)。** 红线至少覆盖:全角表头 / 表头缺失 / 挂起触发器空 / 旋钮①不越界 / 恒 exit 0(spec §6.1)。

- [ ] **Step 1:落实现位置 + 读既有范式**。Read check-handoff.sh,定位 `--reconcile` 分支(`if [ "$RECONCILE" -eq 1 ]`,spec 标 L141 起)与既有 promotion 核结尾、既有全角检测(L173 `grep -F -e '（' -e '）' ...`)、archive_staging awk(L123-131 `/^## 待晋升暂存/{f=1} /^## /{f=0}`)。新段**追加在 promotion 核之后、`--reconcile` 分支内**,确保不落进某个提前 `exit 0` 的 case(design-review 验证者提示:落点精度)。
- [ ] **Step 2(红):写全角表头 fixture**。造一个临时 handoff,`## 活跃任务索引` 段机读头写全角 `活跃任务：3（进行中 2 / 挂起 1）`。跑 `--reconcile`。

Run(示例,实现者按实际 fixture 方式):构造临时 handoff → `bash harness/.claude/hooks/check-handoff.sh --reconcile`
Expected(红):当前**无**活跃任务索引核 → 全角头不被点名(stderr 无「检查全角/机读表头」相关)。

- [ ] **Step 3(实现表头核)**。在新段实现:在 handoff 内定位 `## 活跃任务索引` 段、取标题下一非空行做表头;`grep -E` 核严格半角 ERE `^活跃任务: [0-9]+\(进行中 [0-9]+ / 挂起 [0-9]+\)$`;命中→过;行存在但不命中→走既有全角检测(`grep -F -e '（' -e '）' -e '：' -e '/'` 等,**多 `-e` 列举,不用管道**)命中则 stderr「检测到全角…机读表头 token 必须半角」、否则 stderr「机读表头文法不合 — 现行: <行>」;段/表头缺失→ stderr「活跃任务索引机读表头缺失」。全部恒 exit 0。
- [ ] **Step 4(绿)**。复跑 Step 2 fixture → Expected:stderr 点名「检测到全角」;`echo $?`==0。再造合法表头 fixture → Expected:不点名。再造删表头 fixture → Expected:点名「机读表头缺失」。
- [ ] **Step 5(红):写挂起触发器空 fixture**。造合法表头 + 一条挂起行触发器列为空(`| 挂起 | 某任务 | | -> 某路径 |`)。跑 `--reconcile`。
Expected(红):触发器空不被点名(尚未实现核②)。
- [ ] **Step 6(实现触发器非空核②)**。`awk -F'|'`:section 在 `^## 活跃任务索引` 开窗、遇下一个 `^## ` 关窗;窗内跳过表头行(`| 状态 |`)/分隔行(`|---|`)/占位行(`(无活跃任务)`);**状态列=`$2` trim**==`挂起` 者,核**触发器列=`$4` trim** 非空且非字面 `—`;空→ stderr「挂起行触发器为空: <`$3`任务列摘要>」。恒 exit 0。**不核**计数 / 不核指针 test-f / 不引模板占位文本。
- [ ] **Step 7(绿)**。复跑 Step 5 fixture → Expected:点名「挂起行触发器为空」;exit 0。造触发器非空的挂起行 fixture → Expected:不点名。
- [ ] **Step 8(旋钮①不越界红线)**。造 `活跃任务: 9(进行中 9 / 挂起 0)` 配空表体(N 与行数不符)但表头文法合法 → 跑 `--reconcile`。
Expected:**不**点名计数不符(计数自洽核不在 hook,落 ④自查);仅表头文法过。验机器核范围最窄。
- [ ] **Step 9(恒 exit 0 总核)**。上述所有畸形 fixture 逐个 `echo $?`==0(无 exit 2)。
- [ ] **Step 10:Commit**。

```bash
git add harness/.claude/hooks/check-handoff.sh
git commit -m "feat(check-handoff): --reconcile 加活跃任务索引结构核(表头文法+挂起触发器非空,恒 exit 0)"
```

---

## Task 3: T2 SKILL.md ③覆写步 + ④自查步

**Files:**
- Modify: `harness/.claude/skills/structured-handoff/SKILL.md`(③覆写步 / ④自查步;不动既有 ①归档→②清账→③覆写→④自查 序)

**Interfaces:**
- Consumes: Task 1 模板结构。
- Produces: 覆写工序的「活跃任务索引逐行重建 + 计数自查 + 位置自查 + 软上限」指令(AI 覆写时执行)。

- [ ] **Step 1:③覆写步追加「逐行重建」**(防腐第①件)。在 ③覆写步加:活跃任务索引不保留旧表整块,**逐行重声明「这条还活着吗」**——活的重写;挂起行当场重写复活触发器(禁 copy 旧占位/旧触发器);完成→删行(成果进 `## 待晋升暂存` 走晋升门禁 + 一句话梗概进 `## 进度 > ### 已完成`);放弃→删行(理由随归档件保全);回填机读表头 N/X/Y 据新表行数。
- [ ] **Step 2:④自查步追加计数/位置/软上限**。在 ④自查加四条:① 表头 N==表体活跃任务行数(不含表头/分隔/占位行)且 X+Y==N、X==进行中行数、Y==挂起行数;② 每挂起行触发器非空(与 T3 同判据,自查为主责)+ 进行中行触发器==`—`(防挂起→进行中漏改残留);③ 位置自查:`## 活跃任务索引` 在 `## 目标` 后、`## 待晋升暂存` 前;④ 挂起行数 > 5 → 提醒「挂起线积压,考虑收编/弃置」(软上限初值=5,标"非实证最优、实战标定")。
- [ ] **Step 3:静态核**。Read 改后 SKILL,确认 ③/④ 步追加内容齐、既有步序未动、无引入对模板占位文本的机器依赖。
- [ ] **Step 4:Commit**。

```bash
git add harness/.claude/skills/structured-handoff/SKILL.md
git commit -m "feat(structured-handoff): 覆写步加活跃任务索引逐行重建+自查计数/位置/软上限"
```

---

## Task 4: credentials-rules.md §8 双写条目(治理——对齐 promotion 先例)

**Files:**
- Modify: `harness/docs/governance/credentials-rules.md`(§8 双写清单)

**Interfaces:**
- Produces: 表头 token + section 标题字面的 T1↔T3 双写登记条目(改一处必同批改另一处,触点完整性维比对逐字一致)。

- [ ] **Step 1:读 §8 现有条目体例**。Read credentials-rules.md §8(尤其 promotion 那条 / review-rules FloorTable 那条 第6/7条),仿其「文档上游、代码派生 / 改一处先改 X 再改 Y / 逐字一致」格式。
- [ ] **Step 2:追加条目**。按 spec §8.4 的表述追加一条:活跃任务索引机读表头 token(T1 `handoff-template.md` 机读头 `活跃任务: N(进行中 X / 挂起 Y)` 整条版式逐字符,含空格/斜杠/括号)**+ section 标题字面 `## 活跃任务索引`**(T1 模板标题 ↔ T3 `check-handoff.sh` `--reconcile` ERE/awk 硬编码副本);改一处必同批改另一处,审查时触点完整性维比对逐字一致;同 promotion 三处同名同文法先例。
- [ ] **Step 3:静态核**。确认条目格式与既有 §8 条目一致、指向的 T1/T3 锚点准确。
- [ ] **Step 4:Commit**。

```bash
git add harness/docs/governance/credentials-rules.md
git commit -m "docs(credentials): §8 登记活跃任务索引表头+section标题 T1↔T3 双写(对齐 promotion)"
```

---

## Task 5: 全量验证 + 触点逐字核(最终 gate)

**Files:** 无改动(只读核)。

- [ ] **Step 1:fixture 红线全量复跑**。按 spec §6.1 把 Task 2 的红线(全角头/缺头/触发器空/旋钮①不越界/恒 exit 0)再跑一遍确认绿,留 fixture 命中证据(收口 Evidence Depth L2)。
- [ ] **Step 2:触点逐字核(T1↔T3)**。比对 T1 模板机读表头 token + section 标题字面 与 T3 check-handoff ERE/awk 硬编码副本**逐字符一致**(含空格/斜杠/括号);核 credentials-rules §8 新条目已覆盖二者。
- [ ] **Step 3:静态结构核(T1/T2/T3 同批改全)**。确认三文件同批改:T1 升格结构 / T2 ③④步加齐 / T3 --reconcile 结构核段加齐;无一处漏改致"新结构下次覆写被旧措辞静默抹回"。
- [ ] **Step 4:live↔template 一致核**(收口后)。本批收口 `/structured-handoff` 用新模板覆写 live handoff 后,核 live 与 template 同为新结构(消除既有 live↔template 漂移)。

---

## Self-Review(规划者自核 — 对照 spec)

- **Spec coverage**:§2 模块(T1/T2/T3)→ Task 1/2/3;§3 接口(check-handoff 核②/SKILL 覆写自查/表 schema)→ Task 2/3 + Task 1 模板;§4 数据模型(表行/表头 ERE/生命周期)→ Task 1 模板 + Task 3 覆写步;§5 边界(空账/全角/表头缺/触发器空/段位置)→ Task 2 fixture 红线 + Task 3 ④自查;§6 测试 → Task 2 + Task 5;§8 触点/凭证 → Task 4 + Task 5 + 收口 audit。生命周期"加行/切状态/关闭"是 AI 会话内文档编辑(spec §4.5 规则4),非机器实现,落 T2 ③覆写步指引。
- **Placeholder scan**:无 TBD/TODO;T3 核逻辑给了 grep -E ERE / awk -F'|' 列映射 / 既有全角范式;fixture 红线给了具体畸形输入与 Expected。
- **Type consistency**:表头 token / 状态枚举 {进行中,挂起} / 列名(状态/任务/复活触发器/指针)/ ERE 全程一致;awk 列映射($2状态/$4触发器)与 §4.1 一致。
- **诚实标注**:Task 4 §8 条目 + T3 不引模板占位文本(防死条件漂移)= 对齐 design-review M2/旋钮① 锁定;T3 不核计数/指针 = 旋钮① 最窄。

# 治理同层化(凭证参数化)实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 meta/feature 双轨治理收敛为单层凭证制度——三件套落地(finishing-rules 唯一收口 / review-rules 唯一审查 / credentials-rules.md 凭证与对账新件)+ credentials.conf(机器版,原 meta-scope.conf 改名降格),工具改名 check-audit-coverage.sh(原 check-meta-review.sh)+ 21 件历史凭证 frontmatter 字段迁移 `audit: true`(R13)+ skip 字段消亡(豁免=exempt 微 audit,R7)+ check-meta-cross-ref.sh 删除(R14)+ 地图五处发现链(R9)+ M1/M2 退役 git rm,一步到位不做渐进过渡(R12)。

**Architecture:** 凭证制度单入口 = `docs/governance/credentials-rules.md`(谁欠凭证/凭证文法/exempt/失效/对账/档位),机器判据 = `.claude/hooks/credentials.conf`(双写同步一对,取代原 M3 三表↔M17 双写面),唯一消费者 = `check-audit-coverage.sh`(双模式:Stop 执法=增强层无接线 + `--reconcile` 开场对账=主用形态)。收口动作序住 finishing-rules「凭证义务核对」节(step 15-18),维度选择住 review-rules「审查维度选择表」(代码|设计|治理),三段挑战者模板下放四审查 SKILL 自带(R6)。历史 21 份 meta-review-*.md 文件名不换(收集 glob 双前缀兼容),frontmatter 一行格式迁移(immutable 保护内容,纯格式迁移不算改——用户拍板)。A 彻底同层:同文分发/同凭证义务/对账工具分发(R11)。

**Tech Stack:** bash(POSIX,禁 gawk 扩展;LC_ALL=C.UTF-8)+ markdown 纯文件约定 + git(基线/对照/凭证锚全靠 commit time)+ Claude Code hooks/skills(增强层;地基纯文件+可手工跑脚本+git)

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-13-governance-single-layer-design.md`(767 行,已锁定 2026-06-13,用户审阅"没意见";§9 五批草案=本计划批次骨架,§7.1=36 件改法清单,§8.3=V1-V9 验证)
**拍板锚:** `harness/docs/decisions/2026-06-13-governance-single-layer.md`(c8e4b4a;追记 ffc4b3a=R13 字段全换+R14 cross-ref 删除;2ebc7b7=收口工序适用)

---

## 待回设计清单(0 条)

> 规则:计划不静默偏离 spec;若执行中发现 spec 不可执行点,回设计裁决后对应任务才能继续。本计划写作时点未发现阻塞性不可执行点;两处非阻塞观察项见下方「计划内裁量」末尾「spec 残留观察」,不改动,留调度者裁决。

## 计划内裁量(非偏离,留痕备审)

1. **基线留痕载体**:spec §4.1-10 要求基线全窗对账留痕与预期 delta 显式登记,未指定载体。定为 `harness/docs/active/2026-06-13-single-layer-baseline.md`(工作文件,批 1 入库使其跨会话可考;docs/active 不命中 conf 无凭证义务;含旧工具名属预期,批 5 任务 20 在 V4 断链核**之前** git rm,内容由 V8 audit 与覆写后台账吸收)。
2. **批 2 原子 commit 与逐任务 commit 惯例的调和**:spec §9 批 2 要求"工具改名/conf 改名/字段迁移/命令行三处必须同批同 commit"。任务 4-7 各自完成+验证但**暂存不 commit**,任务 7 末统一原子落账;setup.sh(任务 8)不在同 commit 清单内,单独 commit(中间态:工具已分发而 conf 未入 cp 清单 → 下游 conf 缺失 graceful degrade,I7 兜底,批 2 末 V3 消窗)。
3. **根 AGENTS.md ①两行整体改写归批 2**:spec §5.1 ① 定义为"两行整体改写"(凭证义务行+开场对账行),§9 批 2 又定"对账行与「手工校验」节成对不可拆半"。拆半改写会制造 spec 未定义的中间态,故 ① 两行 + ② 三命令全归批 2 任务 7(凭证义务行指向的 credentials-rules 批 1 已立、credentials.conf 同 commit 落地,无悬空);③ 硬规矩行归批 4 任务 16(纯地图增行)。
4. **根 CLAUDE.md 开场规程「欠账处置句」随第 3 条命令同批 2 改**(spec §5.2"欠账处置句同步"):处置句内"review-rules 维度选择表治理行"指针前置半批(维度表批 3 落)——与 spec 批 1"credentials-rules §2 的 conf 指针悬空一批可接受"同性质,批 3 即接上。
5. **「治理批收口工序适用」三条的插入位置**:spec §2.1.3 只说"随本节落稿"。定为「凭证义务核对」节内 step 18 之后、「decision 立档」小节之前插入小段;另在「安全扫描」「流程审计」两节标题下各加一行括注(治理批暂不纳入指针)——读到该节的人当场可知适用性。
6. **review-rules 既有五节加统领标题** `## 代码类维度集`:维度选择表代码行引用"本文件「代码类维度集」五节",现文件无此统领锚,加一个结构性标题(无语义变更)。
7. **M3 头注一句措辞收尾**:M3 顶部头注"调度者每次会话开头读本文件识别 scope + 找对应治理规则"中"识别 scope"随 §3/§4 删除而悬空,按 spec §5.2"分流机器拆除"的意图改为"走治理规则表与会话开场规程"(任务 15;属分流机器的措辞残端,非新增语义)。
8. **M4 两行落点取治理规则表**:spec §5.3"文档索引/治理规则表加同款两行"中 requesting-code-review 行实存于治理规则表,两行均落治理规则表(文档索引不加重复行,防散文拷贝——与 §2.3-§8"不复制类目枚举"同向)。

**spec 残留观察(不改,如实报告调度者)**:
- a. 根 CLAUDE.md「上下文层地图行」节 preferences 行含"改动命中 A 组 → meta-review"措辞,spec §5.2 明示该节零改(仅 dogfood 边界节一处提法改)。该措辞不在 §7.4 九术语清单内(V4 不红),属活层残留旧词。按 spec 不动,报告调度者(可走 spec 状态头微修正通道另裁)。
- b. spec §5 头部"五处同批改"与 §9 修订后批序(三处命令行挪批 2、其余挪批 4)字面有张力;按任务下发明示"五批照 spec §9 修订后批序"执行,§9 为准。

## 批次与凭证义务表

> 单层制度下无 scope 标签;本表按 credentials.conf(批 2 起)视角列各批命中的凭证义务面。**过渡期治理**见全局契约 G6:批 1-4 各批末小 checkpoint 只做"本批验证绿+commit 齐+台账增量",凭证欠账统一由批 5 V8 audit 销账(spec §9 已定此模式)。

| 批 | 任务 | 触碰凭证义务面(conf glob 视角) | 收尾模式 |
|---|---|---|---|
| 批 1 基线留痕+新件先立 | 任务 1-3 | `docs/governance/*.md`(credentials-rules 新件) | 小 checkpoint(任务 3) |
| 批 2 机器面同批换轨(最重批) | 任务 4-9 | `.claude/hooks/*`(工具+conf+cross-ref 删)/ `CLAUDE.md` / `AGENTS.md` / `templates/*.md` / `setup.sh`;21 件 docs/audits 迁移命中**排除行**,不新增义务 | 小 checkpoint(任务 9,含 V2/V7 对照归因) |
| 批 3 文本合并 | 任务 10-14 | `docs/governance/*.md` ×2 / `.claude/skills/*/*.md` ×4;contracts-locked 注记(plans/ 不命中) | 小 checkpoint(任务 14,V9) |
| 批 4 地图清扫+退役件删除 | 任务 15-18 | `CLAUDE.md` ×2 / `AGENTS.md` ×2 / `docs/governance`(git rm M1/M2)/ `.claude/hooks/*` 注释 / `.claude/agents/*.md` ×5 / `.claude/skills/*/*.md` ×1 / `templates/*.md` / references(不命中) | 小 checkpoint(任务 18,V3 复跑+V5+V6) |
| 批 5 收尾自证+断链核 | 任务 19-20 | ROADMAP/trail/PROGRESS/handoff 均不命中 conf | **总 checkpoint**(任务 20:M5+新制度首跑——方向评估+V8 audit+/structured-handoff 覆写+V4+账齐实证+完成报告) |

## 文件结构总图(Create / Modify / Delete / Rename,对齐 spec §7.1-§7.2)

**Create:**

| 文件 | 任务 | 说明 |
|---|---|---|
| `harness/docs/active/2026-06-13-single-layer-baseline.md` | 1 | 基线留痕+预期 delta 登记簿(工作文件,批 5 任务 20 git rm) |
| `harness/docs/governance/credentials-rules.md` | 2 | 凭证与对账单入口(R3,八节) |
| `harness/docs/audits/audit-<时刻>-governance-single-layer.md` | 20 | V8 制度自证凭证(新命名首件) |

**Rename(git mv,保 git 史):**

| 旧 | 新 | 任务 |
|---|---|---|
| `harness/.claude/hooks/meta-scope.conf` | `harness/.claude/hooks/credentials.conf` | 4 |
| `harness/.claude/hooks/check-meta-review.sh` | `harness/.claude/hooks/check-audit-coverage.sh` | 5 |

**Modify(主要件;§7.1 全清单 36 件逐件落在任务 5-8/10-17/19-20):**

| 文件 | 任务 |
|---|---|
| `harness/docs/audits/meta-review-*.md` ×21(仅 frontmatter 一行) | 6 |
| 根 `AGENTS.md` + `harness/templates/AGENTS.md` + 根 `CLAUDE.md`(命令行三处) | 7(批 2)/ 15-16(批 4 其余) |
| `harness/setup.sh` | 8 |
| `harness/docs/governance/finishing-rules.md` / `review-rules.md` | 10 / 11 |
| 四审查 SKILL(design-review/evaluate/security-scan/process-audit) | 12 |
| `harness/docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md`(仅顶部注记) | 13 |
| `harness/CLAUDE.md`(M4)/ `harness/QUICKREF.md` / `README.md` ×2 / `harness/docs/superpowers/specs/2026-06-12-context-layer-design.md`(仅状态头) | 15-16 |
| hooks 注释 ×3 / agents ×5 / synthesis-rules / structured-handoff SKILL / planning-rules / references ×3(testing-standard/challenger-orientation/recommended-tools)/ templates/README.md | 17 |
| `harness/docs/ROADMAP.md` / `decision-trail.md` / `PROGRESS.md` / `docs/active/handoff.md`(经覆写) | 19-20 |

**Delete:**

| 文件 | 任务 | 说明 |
|---|---|---|
| `harness/.claude/hooks/check-meta-cross-ref.sh` | 7 | git rm(R14 用户拍板"删除";第三 skip 字段随灭) |
| `harness/docs/governance/meta-finishing-rules.md`(M1) | 18 | git rm,批 4 末位(先改全部指针后删本体) |
| `harness/docs/governance/meta-review-rules.md`(M2) | 18 | 同上 |
| `harness/docs/active/2026-06-13-single-layer-baseline.md` | 20 | git rm(V8 吸收后、V4 之前) |

**不动(spec §7.3 考古层 63 件)**:audits 22 全目录 / completed 5 / decisions 15 / 旧 plans 8 / 旧 specs 9 / references 日期件 4 / decision-trail / PROGRESS 历史行 / design-review-result——R12 不追溯,任何任务不得触碰(V4 排除口径与此同源)。

---

## 全局契约(G1-G7,后续任务逐字引用,不得变体)

### G1 逐字×换名通则(spec §2.3 通则,逐字转录——适用一切「逐字沿用/逐字迁入」承诺)

凡『逐字沿用/迁入』= 规则**语义**逐字;**机械名**按以下映射统一替换:

| 旧机械名 | 新机械名 |
|---|---|
| `meta-review: true` | `audit: true` |
| check-meta-review.sh | check-audit-coverage.sh |
| meta-scope.conf / scope.conf | credentials.conf |
| M15(hook 编号指代) | check-audit-coverage.sh |
| "meta 改动"·"meta scope" | "治理面改动"·"凭证义务" |
| M1·M2 指针 | 新住址(finishing-rules / review-rules / credentials-rules 对应节) |

此为 R13『格式≠内容』的延伸:语义=内容,机械名=格式。保真核 = V9(任务 14)。

### G2 B 簇迁移协议(spec §4.1-10,可执行全文)

- **基线定义(写死)**:迁移基线 = **批 1 动任何东西之前**,旧工具 `check-meta-review.sh --reconcile 99999` 全窗跑一次留痕(批 1 第一动作,任务 1)。
- **对照**:批 2 迁移落账后,新工具 `check-audit-coverage.sh --reconcile 99999` 再跑全窗,与基线 diff **欠账名单**(两工具输出文法不相交,不比字面,比名单——V7 同此协议)。
- **判据**:欠账**缩小必然发生**(迁移刷新全部凭证 commit time,把"曾被 covers、后因新提交失效"的既存欠账洗活;spec 演练实证 25→18 缩 7 件)。处置:缩小集合**逐件列出逐件归因**,确认均属"迁移时刻已失效的既存欠账"→ 转入手工欠账留痕(基线登记簿+handoff),由批 5 V8 audit covers 吸收或补审;出现**无法归因**的缩小 = **abort 停批查因**,不得进批 3。
- **sed 锚定形**:`s/^meta-review: true$/audit: true/`,逐件断言锚行计数=1(已迁件=0 且必有 `audit: true`,幂等可重跑);covers 与正文零碰。
- **预期 delta 登记**:基线后、迁移前的一切治理面提交登记于基线登记簿(批 1 预登记:`docs/governance/credentials-rules.md` 一件;批 2 自身的治理面提交在任务 9 对照前 append)。对照判读 = 欠账名单对照 **modulo 显式声明的预期 delta**(= 洗活集合 + 批内新增欠账)。

### G3 C 簇对账纪律

- **窗口锚竞选排除**(工具实现点,任务 5 第 3/11 点):process-audit 报告(无 frontmatter)与 `verdict: exempt` 凭证均不参选默认窗锚——正式 audit 才有资格定默认窗(exempt 仍算有效覆盖,覆盖判定不受影响)。
- **批 2 原子 commit 起至批 5 V8 audit 落账前,一切开场对账带显式全窗参数 `--reconcile 99999`**——字段迁移刷新全部凭证 commit time,默认窗(最新 audit 锚)语义失真;V8 落账后默认窗恢复。执行各批的会话开场都受此纪律约束。

### G4 fixture 通用跑法(沿 2026-06-11 plan C7 惯例)

- fixture 脚本先写、对当前(旧)实现/不存在的新名跑一遍确认红(记录失败数),再实现,再跑全绿;临时位置(/tmp),跑完即弃**不入仓**。
- fixture 树自带 `git init`(git 不 mock);commit time 拨弄用 `GIT_COMMITTER_DATE`/`GIT_AUTHOR_DATE` 环境变量,mtime 用 `touch -d`。
- 断言:exit code 为硬断言;stderr/stdout 子串为辅助断言。全程 `export LC_ALL=C.UTF-8`。

### G5 commit 规范(仓库惯例)

中文,`type(scope): 描述(批N)` 前缀;结尾固定行:

```
Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

### G6 过渡期治理(spec §9 已定模式,逐字落实)

- 批 1-4 期间旧制度(M1/M2/conf 旧名或新名)处于混合拆除态,各批末 checkpoint **不走旧 M1 四步全程**,只做:①本批验证全绿;②本批 commit 齐(对照任务清单);③`docs/active/handoff.md` 台账**增量更新**(进行中/下一步小节直接编辑——增量编辑非覆写,覆写唯批 5 /structured-handoff 走晋升门禁);④基线登记簿按需 append。
- 本计划各批改动的凭证欠账**统一由批 5 V8 audit 销账**(covers = 批 1-5 全部 commit `git log --name-only` 并集机械汇编)——制度自证即收尾验证(decision「后续」节明令)。
- 方向评估/安全扫描/流程审计不在批 1-4 单独跑;批 5 总 checkpoint 跑方向评估(治理批适用,decision 追记三),安全扫描/流程审计治理批暂不纳入(同追记三;连带风险 ROADMAP 观察项任务 19 登记)。

### G7 模块 README 义务声明

本计划触碰件均为治理/hook/skill/agent/模板/文档件,无 src 代码模块,无 MODULE_DOC_TEMPLATE 义务(与 2026-06-11 plan 同声明)。

### 执行前置(批 1 第一动作之前,调度者完成)

- [ ] 本计划文件自查后入库(调度者 commit)。
- [ ] 工作树收口:`git status --porcelain` 干净——上一会话残留改动(handoff/ROADMAP/decision-trail/specs 等)先按其归属收口入库。**基线必须打在已提交全量上**;不净则不得开跑任务 1。

---

# 批 1:基线留痕 + 新件先立(spec §9 批 1;旧工具+meta-scope.conf 全程在岗,执法真空窗归零)

## 任务 1:迁移基线留痕(第一动作)+ 预期 delta 登记簿

**类型:** 流程任务(基线协议执行,G2 第一条;由调度者或 implementer 照步执行,无裁量)
**Files:**
- Create: `harness/docs/active/2026-06-13-single-layer-baseline.md`(计划内裁量 1)

**步骤:**

- [ ] 前置复核:`git status --porcelain` 干净(执行前置已做;不净 → 停,报告调度者)
- [ ] 记录基线锚:`git rev-parse HEAD` → 登记簿「基线 commit」字段
- [ ] **第一动作(逐字命令,在动任何其他东西之前跑):**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
bash .claude/hooks/check-meta-review.sh --reconcile 99999 2>&1 | tee /tmp/baseline-reconcile.txt
```

- [ ] 创建登记簿,结构(四节):

```markdown
# 治理同层化迁移基线留痕(工作文件,批 5 任务 20 git rm)

> 协议:plan 全局契约 G2(spec §4.1-10)。本件含旧工具名/旧术语属预期——批 5 在 V4 断链核前删除。

## 基线 commit
- 基线 HEAD: <git rev-parse HEAD 输出>
- 批 1 首个实施 commit: <任务 2 commit 后回填——V8 covers 汇编起点>

## 基线全窗对账输出(旧工具 check-meta-review.sh --reconcile 99999,逐字粘贴)
<全文粘贴 /tmp/baseline-reconcile.txt>

## 预期 delta 登记(基线后、迁移对照前的治理面提交)
- docs/governance/credentials-rules.md(批 1 任务 2,批内新增欠账——预登记)
<执行中新增的治理面提交随手 append;批 2 提交集合由任务 9 在对照前 append>

## 洗活欠账归因(批 2 任务 9 填写)
<缩小集合逐件:文件 | 覆盖它的凭证 | 失效时点证据(git log -1 --format=%ci)| 归因结论>
```

- [ ] 断言:登记簿「基线全窗对账输出」节非空(含旧工具的账齐/欠账输出行)
- [ ] commit:

```
docs(active): 治理同层化迁移基线留痕——旧工具全窗对账快照+预期delta登记簿(批1第一动作)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 2:契约 —— credentials-rules.md 新件成文(R3)

**类型:** 契约任务(指令式;后续一切指针的目标件,必须先立)
**Files:**
- Create: `harness/docs/governance/credentials-rules.md`

**操作:** 按 spec §2.3 八节骨架成文。节标题与节序固定如下(逐字),各节内容义务与逐字块见后:

```markdown
# 凭证与对账规则(credentials)
## §1 定位与读法
## §2 凭证要求表(人读版)
## §3 audit 产物规范
## §4 exempt 微 audit(豁免文法)
## §5 audit 失效规则
## §6 开场对账规程
## §7 证据档位表(代码|设计|治理)
## §8 双写同步义务清单
```

**§1 定位与读法**(成文要点,沿 spec §2.3 §1):一段话定位(本文件 = 凭证制度单入口;治理同层 decision `docs/decisions/2026-06-13-governance-single-layer.md` 指针);三个进入时刻(finishing「凭证义务核对」节跳来=收口 / 开场对账欠账时跳来=补账 / 写 audit 前跳来=查文法);与 finishing-rules / review-rules 的分工一句话(收口动作序住 finishing,维度选择住 review,凭证文法与对账住本件)。

**§2 凭证要求表(人读版)**——与 credentials.conf 双写同步(改一处必同改另一处,审查时 grep 比对;双写面从原 M3 三表↔M17 收敛为本表↔conf 一对)。**表格式契约(V5 双写比对的人读端,一行一 glob,conf 行序同序)**,逐字:

```markdown
| 文件类别 | glob | 凭证类型 |
|---|---|---|
| 治理规则 | `docs/governance/*.md` | audit |
| 核心入口(M4 分发模板与根 CLAUDE.md 同 glob) | `CLAUDE.md` | audit |
| 入口地图(根级经 root 扫描段,covers 写 `<root>/AGENTS.md`) | `AGENTS.md` | audit |
| 偏好层(D11;审查口径=忠实性对照用户原话锚点) | `docs/preferences.md` | audit |
| hooks(含 credentials.conf 自身) | `.claude/hooks/*` | audit |
| settings | `.claude/settings.json` | audit |
| settings(local) | `.claude/settings.local.json` | audit |
| skills(SKILL.md+捆绑资源,D15) | `.claude/skills/*/*.md` | audit |
| agents | `.claude/agents/*.md` | audit |
| RUBRIC | `docs/RUBRIC.md` | audit |
| 设计模板 | `docs/references/DESIGN_TEMPLATE.md` | audit |
| setup 脚本 | `setup.sh` | audit |
| 分发模板(json) | `templates/*.json` | audit |
| 分发模板(md) | `templates/*.md` | audit |
| 排除:审查凭证(新名,防自循环) | `!docs/audits/audit-*.md` | — |
| 排除:审查凭证(历史名) | `!docs/audits/meta-review-*.md` | — |
| 排除:归档审查 | `!docs/audits/archive/**` | — |
```

+ 兜底句(逐字):`不命中任何 include glob = 无凭证义务。`
+ 凭证类型说明:当前全部行 = audit;`design-review` / `test` 为参数位预留(工具现阶段只消费 audit 行;下游可自加如 `src/payments/** test`)。
+ **附注**(原 M3 §5 实存文件注记精简迁居,spec §2.3 §2):①自仓库 settings.json 已撤(2026-06-12 追记①,glob 保留备未来);②templates/handoff.md 已删(D3 单源化);③**活缺口注记**(逐字承接):`全新建未 git add 的根级文件走 untracked 漏检(缺口本体详 docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md §9.4 #11,入库后消失)`。

**§3 audit 产物规范**——逐字沿 M2 §7(G1 映射;源件本批仍在盘 `docs/governance/meta-review-rules.md`,从实物复制),含:
- 位置 `docs/audits/`;命名 `audit-YYYY-MM-DD-HHMMSS-[主题].md`(新);**双前缀兼容**声明(工具收集 glob = `audit-*.md` + `meta-review-*.md`,历史 21 份零改名继续有效);半年归档策略沿 D15(`docs/audits/archive/YYYY-HN/` + INDEX.md)。
- 与 process-audit 报告(`audit-YYYY-MM-DD-HHMMSS.md`,无主题段无 frontmatter)的命名空间共存规则:**机器区分靠 frontmatter 不靠文件名**(审查凭证必有 `audit: true` + 非空 covers;process-audit 报告被 is_audit_credential 自然滤除)。
- frontmatter 文法:**`audit: true`** + `covers:` 字符串数组(R13 单一解析路径,无双字段兼容);**文件名不换**理由一句(被 immutable 文档大量引用);迁移防护指针(`迁移协议详 spec §4.1-10`)。
- covers 路径规则逐字沿 M2 §7.3 五条(仓库相对/正斜杠/实存/无去重要求/`<root>/` sentinel 协议全文)。
- 5 段正文标题逐字沿(`## 1. 元信息` ~ `## 5. 判定`);任务级结论登记簿逐字沿 M2 §7.5.1(行文法 `任务 <N>(<主题>):verdict=...;关键发现 ...;修复 commit ...`,多 commit 用 + 连写)。
- 写侧契约逐字沿 M2 §7.4(实际覆盖文件,不是主题相关;不漏列不误列)。
- 读侧错误处理表逐字沿 M2 §7.6(YAML 损坏/covers 缺失/空数组/标识缺失四情形)。

**§4 exempt 微 audit**——逐字块(spec §2.4,模板+文法规则全文照搬):

````markdown
**逐字模板**:

```
---
audit: true
verdict: exempt
covers:
  - <仓库相对路径 1>
---

# audit(exempt):<一句话主题>

豁免理由:<一行,非空——为何无需对抗审查(仅限 typo / 链接 / 注释等无语义变更)>
```

**文法规则**:

1. 文件名同正式 audit:`audit-YYYY-MM-DD-HHMMSS-[主题].md`,位置 `docs/audits/`。
2. frontmatter 三键:`audit: true`(§3 文法,凭证标识)/ `verdict: exempt`(固定小写字面)/ `covers:`(非空数组,路径规则同正式 audit 含 `<root>/` sentinel)。键序固定如模板(verdict 在 covers 之前)。
3. 正文两行起步:标题行 + 豁免理由行(非空非全空白)。无 5 段结构义务。
4. 豁免边界:仅 typo / 链接修复 / 注释措辞等**无语义变更**;语义变更一律走对抗审查。**例外两类**(同走 exempt,理由行写明类别):① D11 偏好条目用户原话直录;② 初装/升级 scaffold(内容=上游分发原样,上游已审)。exempt 理由质量由 process-audit 按需/周期回看反向抽查(不绑每批);**covers 超 5 件的 exempt 必抽**。
5. 失效规则与正式 audit 完全一致(§5):covered 文件在 exempt 之后有新 commit → exempt 失效,需重新豁免或补审。**豁免不是永久免检**。
6. 成本对照:3-5 行文件 ≈ 一行 skip 字段,但走凭证正道——`--reconcile` 对账天然认(skip 字段对账从来不认,这正是被消除的制度洞)。
````

**§5 audit 失效规则**——逐字沿 M2 §8 四小节(G1 映射):单 audit 单文件失效判定(covered 最新 commit time vs audit mtime)/ 多 audit 跨覆盖并集 / 实现细节(GNU/BSD stat 兼容、不用 ctime)/ 归档 audit 处理。节末声明对账模式差异锚(audit 自身最后 commit time;同 commit 打包 ≤ 判有效——沿 check-audit-coverage.sh §4.6 现状)。

**§6 开场对账规程**——三条命令+欠账处置(逐字,自仓库形态;下游去 `harness/` 前缀同形):

```markdown
1. `bash .claude/hooks/check-handoff.sh --reconcile`(台账凭证)
2. `echo '{}' | bash .claude/hooks/check-shelf-registry.sh`(落库登记)
3. `bash .claude/hooks/check-audit-coverage.sh --reconcile`(凭证覆盖——本件主角;A 彻底同层后下游同跑三条)

欠账处置:缺 audit → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)补 exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账。欠账先补再开新工作。
```

+ 一句:本节与根 CLAUDE.md「会话开场规程」/ AGENTS×2 对账行互为指针(权威动作序住本节,入口行只一句引)。

**§7 证据档位表**——逐字块(spec §2.3 §7):

```markdown
| 档位 | 代码改动 | 设计改动 | 治理改动 |
|---|---|---|---|
| L1 | 单元测试通过 | 设计文档节内自检 [x] 全勾选 | 节内自检 / hook fixture 先红后绿 |
| L2 | 集成测试输出 | 全局自检(design-rules 10 项) | 全局一致性核(双写比对 / 装机验证) |
| L3 | 自动化验证脚本 | design-review 4 维审查通过 | 对抗审查 audit verdict=pass(凭证在 docs/audits/) |
| L4 | 真实场景验证记录 | 落地后实战回看 | 实战留痕(后续改动的 audit / 对账引用本规则) |
```

+ 声明:handoff `## Evidence Depth` / `## CI 阻断` **字段名与行格式不动**(check-evidence-depth.sh 零改,R12);每行 `- L<n>: <状态> <证据位置>` 三段,状态 ✅/⏳/❌/➖;一批含多类改动按类各填行。
+ 逐字沿 M1 §4.3 第 5 条:`证据位置必须含具体路径或 audit 文件名,不能用"已完成"类无指向词`。
+ 三示例成文:"代码批 / 治理批 / 混合批"(原 M1 §4.2 三 scope 示例改写,实施时成文;`meta-L` 前缀名不得出现)。

**§8 双写同步义务清单**——逐对列出(spec §2.3 §8)+ "改一处同批改另一处" + 审查触点完整性维优先选用声明:
1. 本件 §2 人读表 ↔ `.claude/hooks/credentials.conf`;
2. review-rules 维度表治理行判定语 ↔ conf;
3. 根 CLAUDE.md 治理表凭证行 ↔ 本件存在性(根 CLAUDE.md 治理表「凭证义务一句话」**不复制类目枚举**,只写"命中 credentials.conf 任一 include glob"+ 本件指针);
4. 对抗式模板 design-review SKILL ↔ evaluate SKILL(A/B/C 三段同构,同批改);
5. 对账命令拷贝组**四处同改**:根 CLAUDE.md 开场规程 / 根 AGENTS.md「手工校验」/ templates/AGENTS.md「手工校验」/ 本件 §6。

**步骤:**

- [ ] 按上述八节成文(逐字块照搬;「逐字沿 M2/M1」段从盘上实物复制+G1 映射,不凭记忆转写)
- [ ] 结构核:

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
F=docs/governance/credentials-rules.md
for m in "§1 定位与读法" "§2 凭证要求表" "§3 audit 产物规范" "§4 exempt 微 audit" "§5 audit 失效规则" "§6 开场对账规程" "§7 证据档位表" "§8 双写同步义务清单"; do grep -qF "$m" "$F" && echo "OK $m" || echo "MISSING $m"; done
grep -qF 'verdict: exempt' "$F" && echo OK-exempt文法
grep -qF '<root>/' "$F" && echo OK-sentinel协议
grep -qF 'audit-YYYY-MM-DD-HHMMSS-[主题].md' "$F" && echo OK-新命名
grep -qF 'meta-review-*.md' "$F" && echo OK-双前缀声明
grep -qF '不命中任何 include glob = 无凭证义务' "$F" && echo OK-兜底句
grep -qF '§9.4 #11' "$F" && echo OK-活缺口注记
grep -cE '^\| L[1-4] \|' "$F"    # 期望 4(档位表四行)
grep -qF '已完成"类无指向词' "$F" && echo OK-M1§4.3第5条
grep -cE '`meta-L|meta-L[1-4]' "$F"   # 期望 0(前缀名退役)
```

- [ ] 逐字沿用段对源比读(M2 §7.3/§7.4/§7.5.1/§7.6/§8、M1 §4.3 第 5 条——源件在盘,逐段 diff 式比读,仅 G1 机械名差异;此为 V9 的前半,批 3 任务 14 终核)
- [ ] 通读自检:三个进入时刻各走一遍(收口/补账/查文法),每个时刻所需信息本件内 1 步可达
- [ ] commit(并将 commit hash 回填登记簿「批 1 首个实施 commit」字段):

```
feat(governance): credentials-rules.md 新件——凭证与对账单入口(要求表/audit文法/exempt/失效/对账/档位/双写清单)(批1)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

> ⚠️ 已知悬空(spec 批 1 耦合注,可接受):本件 §2/§6/§8 指向的 credentials.conf 与 check-audit-coverage.sh 批 2 才落地;此时无任何入口指向本件(地图行批 2/4 才接),悬空一批不构成断链面。

## 任务 3:批 1 收尾小 checkpoint(过渡态,G6)

**类型:** 流程 checkpoint(调度者执行)
**Files:**
- Modify: `harness/docs/active/handoff.md`(增量)、`harness/docs/active/2026-06-13-single-layer-baseline.md`(按需 append)

**步骤:**

- [ ] 本批验证绿:任务 1 登记簿在案非空、任务 2 结构核全 OK
- [ ] commit 齐:批 1 = 2 个 commit(任务 1 登记簿 + 任务 2 新件),`git log --oneline -3` 对照
- [ ] 基线登记簿核:预期 delta 节如实(批 1 治理面提交 = credentials-rules.md 一件;若实施中多出治理面提交 → append)
- [ ] handoff 台账增量更新(进行中:批 1 完成、批 2 待开;**不覆写**)
- [ ] 凭证欠账声明留痕(handoff 已知问题或进行中一行):批 1-4 欠账统一批 5 V8 销(G6)

---

# 批 2:机器面同批换轨(spec §9 批 2 —— 最重批)

> ⚠️ **同批不可拆项(spec §9 批 2 耦合注,原子纪律)**:工具改名 / conf 改名 / 21 件字段迁移 / 对账命令行三处 **必须同批同 commit**(任务 4-7 暂存不 commit,任务 7 末原子落账);根 AGENTS 的对账行与「手工校验」节是成对最小单位,不可拆半;开场规程指旧名一刻都不许跨会话。setup.sh(任务 8)单独 commit(不在同 commit 清单内,计划内裁量 2)。
> ⚠️ 本批落账起,开场对账带显式全窗参数(G3 第二条)。

## 任务 4:契约 —— meta-scope.conf → credentials.conf(git mv + §3.2 逐字重写)

**类型:** 契约任务(指令式)
**Files:**
- Rename+Modify: `harness/.claude/hooks/meta-scope.conf` → `harness/.claude/hooks/credentials.conf`

**操作:**

- [ ] `git mv .claude/hooks/meta-scope.conf .claude/hooks/credentials.conf`(保 git 史;住址不迁,沿单一住址惯例)
- [ ] 全文替换为以下内容(**逐字沿 spec §3.2 草案**):

```
# credentials.conf - 凭证要求表(机器版)
# 行格式:<glob> <凭证类型>;! 前缀为排除(排除行无类型字段)
# 凭证类型:audit(对抗审查凭证)| design-review | test(参数位预留,当前工具只消费 audit)
# 由 check-audit-coverage.sh 读;人读版 = docs/governance/credentials-rules.md §2(双写同步,改一处同改另一处)
# 文件编码: UTF-8;行尾: LF
# 沿革:原 meta-scope.conf(M17)改名降格 — 治理同层化(decisions/2026-06-13-governance-single-layer.md)

# === 治理规则 + 核心入口 ===
docs/governance/*.md audit
CLAUDE.md audit
# 入口地图 = 治理面,与 CLAUDE.md 对称;根级文件经 root 扫描段命中,audit covers 写 <root>/AGENTS.md
AGENTS.md audit
# 偏好层:治理上当规范同等对待(D11 ✅ A;审查口径 = 忠实性对照用户原话锚点)
docs/preferences.md audit

# === hooks + settings ===
# glob 用 * 统一覆盖 .sh / .conf / 未来 hook 配置类型,也使本文件自身入凭证义务
.claude/hooks/* audit
.claude/settings.json audit
.claude/settings.local.json audit

# === skills + agents ===
# skill 捆绑资源 = 契约本体(D15):glob */*.md 覆盖 SKILL.md + 捆绑模板(如 structured-handoff/handoff-template.md)
.claude/skills/*/*.md audit
.claude/agents/*.md audit

# === RUBRIC + 设计模板 ===
docs/RUBRIC.md audit
docs/references/DESIGN_TEMPLATE.md audit

# === setup + 分发模板 ===
# 下游单层仓库无 setup.sh / templates/,以下行不命中即无义务(同一份 conf 双层通用)
setup.sh audit
templates/*.json audit
templates/*.md audit

# === 排除规则(流程产出物,避免自循环)===
# 审查凭证自身不欠凭证;双前缀(audit-* 新名 / meta-review-* 历史名)+ 归档全排除
!docs/audits/audit-*.md
!docs/audits/meta-review-*.md
!docs/audits/archive/**
```

**验证(不 commit,暂存态核):**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
test -f .claude/hooks/credentials.conf && test ! -e .claude/hooks/meta-scope.conf && echo OK-改名
grep -cE '^[^#!].* audit$' .claude/hooks/credentials.conf    # 期望 14(include 行全带类型)
grep -cE '^!' .claude/hooks/credentials.conf                 # 期望 3(排除行,无类型字段)
head -c 3 .claude/hooks/credentials.conf | od -An -tx1 | grep -q 'ef bb bf' && echo FAIL-BOM || echo OK-无BOM
file .claude/hooks/credentials.conf | grep -qiv CRLF && echo OK-LF
```

- [ ] **不 commit**(任务 7 原子落账)

## 任务 5:check-meta-review.sh → check-audit-coverage.sh(改名 + 十一点改造,V1 fixture)

**类型:** 实现任务(问题式;约束清单 = spec §4.1 十一点逐点,违反任一条即返工)
**Files:**
- Rename+Modify: `harness/.claude/hooks/check-meta-review.sh` → `harness/.claude/hooks/check-audit-coverage.sh`

**问题:** 工具要从"meta scope 分流执法"降格为"凭证覆盖核对":读新 conf 两字段行格式、双前缀收集凭证、单一 frontmatter 文法(`audit: true`)、认 exempt 微 audit、skip 字段制度拆除、窗口锚竞选补漏。

**约束清单(spec §4.1 逐点;未列段 = 零改):**

1. **头注重写**:身份="凭证覆盖核对(audit coverage)——双模式:Stop 执法(增强层,当前无任何仓库接线)+ `--reconcile` 开场对账(工具箱,主用形态)";术语全换(meta-review → 审查凭证 / meta scope → 凭证义务);命名约定段(D12 前缀过滤)删除,改写"无前缀,随 setup.sh hooks 循环分发下游(A 彻底同层)";spec 锚点行改指 `docs/superpowers/specs/2026-06-13-governance-single-layer-design.md` + decision。
2. **conf 读取**:`SCOPE_CONF=".claude/hooks/credentials.conf"`(变量名可顺改 CRED_CONF,实施层自决);解析循环改两字段行格式——非排除行按第一个空白切 `glob` + `type`:`type=audit` → 入 INCLUDE_GLOBS;`type` ∈ {design-review, test} → 跳过;`type` 为空(单字段行)→ stderr 一行 warning(逐字:`⚠️ credentials.conf 行缺凭证类型字段,按 audit 处理: <行>`)+ 按 audit 处理;`type` 为其他未知值 → **warning + 按 audit 处理(fail-closed,与缺类型同路径)**。排除行 `!` 解析不变。"无任何 include glob 视为损坏降级"逻辑不变,提示文案改名。
3. **audit 收集双前缀**(`collect_audit_files` + 窗口锚竞选两处 find):`-name "audit-*.md" -o -name "meta-review-*.md"`;archive INDEX.md 表格行过滤的 `case` 同步加 `audit-*.md` 分支。**窗口锚竞选处补 `is_audit_credential` 过滤**(现脚本竞选段不过滤——process-audit 报告的 commit time 可能错当窗口锚,这是**必修真缺口**,非锦上添花)。
4. **frontmatter 解析**:`extract_covers` **零改**;`is_meta_review_audit` **改名 `is_audit_credential` 且匹配行换 `audit: true`**(单一文法,无双字段兼容);新增 `extract_verdict`(awk,frontmatter 内匹配 `^[[:space:]]*verdict[[:space:]]*:[[:space:]]*exempt[[:space:]]*$` → 输出 exempt,否则空)。
5. **覆盖判定零改**:exempt 与正式 audit 同算有效覆盖(verdict 不参与判定);失效规则两套锚(Stop=mtime / reconcile=commit time)零改。
6. **对账输出**:`VALID_AUDIT_COUNT` 旁新增 `EXEMPT_COUNT`;账齐/欠账行改为 `账齐:近窗 N 件凭证义务改动,有效凭证 M 份(其中 exempt K 份)` 同形;标题行 `—— meta-review 对账(--reconcile)——` → `—— 凭证覆盖对账(--reconcile)——`。
7. **skip 字段解析路径删除**(R7):脚本 §8 整段(读 handoff `## meta-review: skipped`)删除;§4.6 头注三差异点中"忽略 skip"句改为"skip 字段制度已消亡(豁免走 exempt 微 audit,对账天然认)";欠账输出末行"注:对账不认 skip 字段"删除,处理指引改(逐字三行):
   - `处理:对上述文件补审查凭证(二选一),文法住 docs/governance/credentials-rules.md:`
   - `  1. 对抗审查 audit:docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md(frontmatter audit: true + covers 逐项列出;root 级文件写 <root>/<path>)`
   - `  2. exempt 微 audit(仅 typo/链接/注释等无语义变更):同 frontmatter + verdict: exempt + 一行理由(credentials-rules §4)`
8. **Stop 模式 stderr 引导**(脚本 §9):"触发 /design-review meta-mode" 改"按 review-rules 维度选择表治理行 fork 审查";"写 skip 理由"选项删除,替换为 exempt 微 audit 选项;`<root>/` sentinel 协议段保留;"不扫 untracked"已知注保留。
9. **双层探测段零改**(WORK_DIR 探测/root 扫描段/`<root>/` sentinel/`git -C` 健康检查);gawk 三参数 match 已知问题注保留(独立待办,本批不修不扩散)。
10. (字段迁移挪任务 6,同原子 commit。)
11. **窗口锚竞选排除 exempt**:锚竞选循环对候选凭证过 `extract_verdict`,verdict=exempt 跳过不参选(一行;理由 = exempt 高频窄豁免会把默认窗锚拉到当下遮蔽窗外漏账;正式 audit 才有资格定默认窗)。

执行纪律:先 `git mv .claude/hooks/check-meta-review.sh .claude/hooks/check-audit-coverage.sh` 再逐点编辑;POSIX(禁 gawk 三参数 match 扩散);LC_ALL=C.UTF-8;无关四 hook 零碰(I3)。

**验证标准 = V1 fixture 全绿(先红后绿,G4;治理改动 L1):**

- [ ] fixture 写入临时位置(如 `/tmp/fixture-cac.sh`)并先跑红(改造前 HOOK 路径不存在/行为缺失,记录失败数):

```bash
#!/bin/bash
# fixture-check-audit-coverage.sh — V1 场景手测(临时,跑完即弃)
set -u
export LC_ALL=C.UTF-8
HOOK="/d/个人/harness/harness/.claude/hooks/check-audit-coverage.sh"
PASS=0; FAIL=0
mk_repo() {  # $1=conf 内容 → 单层树(docs/ 直挂树根),git init
  T=$(mktemp -d); mkdir -p "$T/.claude/hooks" "$T/docs/governance" "$T/docs/audits" "$T/docs/active"
  printf '%s\n' "$1" > "$T/.claude/hooks/credentials.conf"; echo "$T"
}
commit_at() { (cd "$1" && git add -A >/dev/null && GIT_COMMITTER_DATE="$2" GIT_AUTHOR_DATE="$2" git -c user.email=t@t -c user.name=t commit -q -m "$3" --allow-empty); }
init_git() { (cd "$1" && git init -q); }
run_rec() { ERR=$(mktemp); (cd "$1" && bash "$HOOK" --reconcile ${2:-}) >/dev/null 2>"$ERR"; RC=$?; }
chk() { if [ "$2" = 1 ]; then PASS=$((PASS+1)); echo "PASS: $1"; else FAIL=$((FAIL+1)); echo "FAIL: $1"; sed 's/^/    /' "${ERR:-/dev/null}" 2>/dev/null; fi; }
mk_audit() {  # $1=路径 $2=covers路径 [$3=exempt]
  { echo '---'; echo 'audit: true'; [ "${3:-}" = exempt ] && echo 'verdict: exempt'
    echo 'covers:'; echo "  - $2"; echo '---'; echo '# audit'; [ "${3:-}" = exempt ] && echo '豁免理由:测试豁免'; } > "$1"
}
CONF_STD='docs/governance/*.md audit
!docs/audits/audit-*.md
!docs/audits/meta-review-*.md'

# F1 双前缀收集:历史名+新名凭证都入账
T=$(mk_repo "$CONF_STD"); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
mk_audit "$T/docs/audits/meta-review-2026-06-01-110000-x.md" docs/governance/a-rules.md; commit_at "$T" "2026-06-01T11:00:00" c2
echo r2 > "$T/docs/governance/b-rules.md"; commit_at "$T" "2026-06-02T10:00:00" c3
mk_audit "$T/docs/audits/audit-2026-06-02-110000-y.md" docs/governance/b-rules.md; commit_at "$T" "2026-06-02T11:00:00" c4
run_rec "$T" 99999; grep -q "有效凭证 2 份" "$ERR" && [ "$RC" = 0 ] && chk "F1 双前缀两凭证入账+账齐" 1 || chk "F1 双前缀两凭证入账+账齐" 0; rm -rf "$T"

# F2 exempt 入账+计数行
T=$(mk_repo "$CONF_STD"); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
mk_audit "$T/docs/audits/audit-2026-06-01-110000-e.md" docs/governance/a-rules.md exempt; commit_at "$T" "2026-06-01T11:00:00" c2
run_rec "$T" 99999; grep -q "其中 exempt 1 份" "$ERR" && [ "$RC" = 0 ] && chk "F2 exempt 算有效覆盖+计数" 1 || chk "F2 exempt 算有效覆盖+计数" 0; rm -rf "$T"

# F3 conf 行缺类型字段 → warning + 按 audit 处理(欠账仍点名)
T=$(mk_repo 'docs/governance/*.md'); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
run_rec "$T" 99999; grep -q "缺凭证类型字段" "$ERR" && grep -q "a-rules.md" "$ERR" && chk "F3 缺类型 warning+fail-closed" 1 || chk "F3 缺类型 warning+fail-closed" 0; rm -rf "$T"

# F4 conf 行未知类型 → warning + 按 audit 处理
T=$(mk_repo 'docs/governance/*.md bogus'); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
run_rec "$T" 99999; grep -q "a-rules.md" "$ERR" && chk "F4 未知类型 fail-closed 按 audit" 1 || chk "F4 未知类型 fail-closed 按 audit" 0; rm -rf "$T"

# F5 design-review 类型行 → 本工具跳过(不产生 audit 义务)
T=$(mk_repo 'docs/governance/*.md design-review'); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
run_rec "$T" 99999; grep -q "a-rules.md" "$ERR" && chk "F5 预留类型跳过" 0 || chk "F5 预留类型跳过" 1; rm -rf "$T"

# F6 exclude 行误带类型字段 → 该排除失效(fail-closed 噪声:audits 件按 include 命中点名)
T=$(mk_repo 'docs/audits/* audit
!docs/audits/audit-*.md audit'); init_git "$T"
echo x > "$T/docs/audits/audit-2026-06-01-100000-z.md"; commit_at "$T" "2026-06-01T10:00:00" c1
run_rec "$T" 99999; grep -q "audit-2026-06-01-100000-z.md" "$ERR" && chk "F6 排除行误带类型=排除失效" 1 || chk "F6 排除行误带类型=排除失效" 0; rm -rf "$T"

# F7 窗口锚竞选排除 process-audit 报告(无 frontmatter;默认窗锚必须=正式 audit)
T=$(mk_repo "$CONF_STD"); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
mk_audit "$T/docs/audits/meta-review-2026-06-01-110000-x.md" docs/governance/a-rules.md; commit_at "$T" "2026-06-01T11:00:00" c2
echo r1b > "$T/docs/governance/b-rules.md"; commit_at "$T" "2026-06-02T10:00:00" c3   # 窗内欠账件
printf '# 流程审计报告\n无 frontmatter\n' > "$T/docs/audits/audit-2026-06-03-100000.md"; commit_at "$T" "2026-06-03T10:00:00" c4
run_rec "$T"; grep -q "b-rules.md" "$ERR" && chk "F7 锚竞选排除 process-audit 报告(默认窗不被拉到当下)" 1 || chk "F7 锚竞选排除 process-audit 报告(默认窗不被拉到当下)" 0; rm -rf "$T"

# F8 窗口锚竞选排除 exempt(同构:exempt 晚于欠账件提交,锚仍=正式 audit)
T=$(mk_repo "$CONF_STD"); init_git "$T"
echo r1 > "$T/docs/governance/a-rules.md"; commit_at "$T" "2026-06-01T10:00:00" c1
mk_audit "$T/docs/audits/meta-review-2026-06-01-110000-x.md" docs/governance/a-rules.md; commit_at "$T" "2026-06-01T11:00:00" c2
echo r1b > "$T/docs/governance/b-rules.md"; commit_at "$T" "2026-06-02T10:00:00" c3
mk_audit "$T/docs/audits/audit-2026-06-03-100000-e.md" docs/governance/a-rules.md exempt; commit_at "$T" "2026-06-03T10:00:00" c4
run_rec "$T"; grep -q "b-rules.md" "$ERR" && chk "F8 锚竞选排除 exempt" 1 || chk "F8 锚竞选排除 exempt" 0; rm -rf "$T"

# F9 Stop 模式回归:未提交治理面 diff → exit 2;stderr 含 exempt 选项,无 skip 选项
T=$(mk_repo "$CONF_STD"); init_git "$T"; commit_at "$T" "2026-06-01T10:00:00" c0
echo dirty > "$T/docs/governance/a-rules.md"; (cd "$T" && git add -A)
ERR=$(mktemp); (cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash '$HOOK'") >/dev/null 2>"$ERR"; RC=$?
[ "$RC" = 2 ] && grep -q "exempt" "$ERR" && ! grep -q "skip" "$ERR" && chk "F9 Stop 回归+exempt 引导+无 skip" 1 || chk "F9 Stop 回归+exempt 引导+无 skip" 0; rm -rf "$T"

# F10 skip 字段死亡:handoff 写 skipped 仍 exit 2
T=$(mk_repo "$CONF_STD"); init_git "$T"; commit_at "$T" "2026-06-01T10:00:00" c0
printf '## meta-review: skipped(理由: 测试)\n' > "$T/docs/active/handoff.md"
echo dirty > "$T/docs/governance/a-rules.md"; (cd "$T" && git add -A)
ERR=$(mktemp); (cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash '$HOOK'") >/dev/null 2>"$ERR"; RC=$?
[ "$RC" = 2 ] && chk "F10 skip 字段不再被认" 1 || chk "F10 skip 字段不再被认" 0; rm -rf "$T"

echo "----"; echo "PASS=$PASS FAIL=$FAIL"
```

(fixture 为契约级骨架:exit code 与上列 stderr 子串为硬断言;实施中可按脚本实际输出微调辅助断言措辞,**不得**为变绿改松判定。)

- [ ] 实施十一点改造,跑 fixture 全绿:期望末行 `PASS=10 FAIL=0`
- [ ] 无关 hook 零碰断言(I3):`git diff --name-only -- .claude/hooks/ | grep -vE 'check-audit-coverage.sh|check-meta-review.sh|credentials.conf|meta-scope.conf'` → 空
- [ ] **不 commit**(任务 7 原子落账)

## 任务 6:21 件历史凭证字段迁移(R13,锚定 sed)

**类型:** 实现任务(机械迁移,G2 协议)
**Files:**
- Modify: `harness/docs/audits/meta-review-*.md` ×21(每件仅 frontmatter 一行)

**操作(逐字执行):**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
for f in docs/audits/meta-review-*.md; do
  n=$(grep -c '^meta-review: true$' "$f")
  case "$n" in
    1) sed -i 's/^meta-review: true$/audit: true/' "$f" ;;
    0) grep -q '^audit: true$' "$f" || { echo "ABORT: $f 无锚行且无已迁字段,停批查因"; exit 1; } ;;  # 幂等重跑分支
    *) echo "ABORT: $f 锚行计数=$n ≠1,停批查因"; exit 1 ;;
  esac
done
```

**验证断言(spec §4.1-10 ①②;③对照协议在任务 9):**

```bash
grep -l '^audit: true$' docs/audits/meta-review-*.md | wc -l        # 断言 = 21
grep -rl 'meta-review: true' docs/audits/ | wc -l                    # 断言 = 0
git diff --numstat docs/audits/ | awk '{i+=$1;d+=$2;f++} END{print f,i,d}'   # 断言 = "21 21 21"(21 件,各 +1/-1 行)
git diff docs/audits/ | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vcE '^\+audit: true$|^-meta-review: true$'   # 断言 = 0(covers 与正文零碰)
```

- [ ] **不 commit**(任务 7 原子落账;git 史保原貌——迁移是一个新 commit,不改写历史)

## 任务 7:契约 —— 对账命令行三处 + cross-ref 删除 + 批 2 原子 commit

**类型:** 契约任务(指令式,逐字)
**Files:**
- Delete: `harness/.claude/hooks/check-meta-cross-ref.sh`(R14)
- Modify: `AGENTS.md`(仓库根)、`harness/templates/AGENTS.md`、`CLAUDE.md`(仓库根,仅会话开场规程小节)

**操作:**

- [ ] `git rm .claude/hooks/check-meta-cross-ref.sh`(不改名不保留,git 史即考古;`## meta-cross-ref: skipped` 字段随灭——唯一消费者即本件)
- [ ] 根 AGENTS.md ①:接手顺序步 4 下的两行(现 L16-17:`- meta 治理(自仓库专属)…` 与 `- 开场对账…check-meta-review…`)**整体改写**为(逐字沿 spec §5.1 ①):

```markdown
- 凭证义务(治理面改动须 audit 凭证): 权威单入口 harness/docs/governance/credentials-rules.md(机器版 harness/.claude/hooks/credentials.conf)
- 开场对账(步 1 读完台账后):跑下方「手工校验」三命令;欠账先补再干活(会话链自执法,详 harness/docs/decisions/2026-06-11-session-chain-reconciliation.md + 2026-06-13-governance-single-layer.md)
```

- [ ] 根 AGENTS.md ②:「手工校验」节两命令扩为三命令(逐字沿 spec §5.1 ②):

```markdown
- bash harness/.claude/hooks/check-handoff.sh --reconcile
- echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh
- bash harness/.claude/hooks/check-audit-coverage.sh --reconcile
```

- [ ] templates/AGENTS.md ①:「手工校验」节扩为三命令(逐字沿 spec §5.1 下游①):

```markdown
- bash .claude/hooks/check-handoff.sh --reconcile
- echo '{}' | bash .claude/hooks/check-shelf-registry.sh
- bash .claude/hooks/check-audit-coverage.sh --reconcile
```

- [ ] templates/AGENTS.md 开场对账行(现 L15):`跑下方「手工校验」两命令` 改 `跑下方「手工校验」三命令`(其余字不动)
- [ ] 根 CLAUDE.md「会话开场规程」:对账第 3 条命令行与欠账处置句替换为(逐字沿 spec §5.2):

```markdown
   - `bash harness/.claude/hooks/check-audit-coverage.sh --reconcile`(已提交凭证义务改动的 audit 覆盖)
   - 欠账处置:缺凭证 → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账
```

(前两条命令行与「装载」步零改;依据行零改。处置句内 review-rules 维度表指针前置半批 = 计划内裁量 4。)

- [ ] 验证:

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
grep -c 'check-audit-coverage' AGENTS.md harness/templates/AGENTS.md CLAUDE.md      # 各 ≥1
grep -c 'check-meta-review\|check-meta-cross-ref' AGENTS.md harness/templates/AGENTS.md CLAUDE.md   # 注:根 CLAUDE.md 此时 §3-§5 表仍在(批 4 拆),只断言开场规程小节内零命中:
sed -n '/## 会话开场规程/,/^## /p' CLAUDE.md | grep -c 'check-meta-review'           # 期望 0
grep -c 'check-meta' AGENTS.md harness/templates/AGENTS.md                           # 各期望 0
grep -c '手工校验」三命令\|「手工校验」三命令' AGENTS.md harness/templates/AGENTS.md  # 各 1(成对最小单位齐)
test ! -e harness/.claude/hooks/check-meta-cross-ref.sh && echo OK-crossref已删
```

- [ ] **批 2 原子 commit(任务 4+5+6+7 全部暂存一次落账)**——pre-commit 断言:`git status --porcelain` 恰含:credentials.conf(R+M)/ check-audit-coverage.sh(R+M)/ docs/audits/meta-review-*.md ×21(M)/ check-meta-cross-ref.sh(D)/ AGENTS.md(M)/ harness/templates/AGENTS.md(M)/ CLAUDE.md(M),**无其他**:

```
feat(governance): 机器面同批换轨——check-audit-coverage.sh(原check-meta-review)+credentials.conf(原meta-scope.conf)+21件凭证字段迁移audit:true+cross-ref hook删除+对账命令行三处(批2 原子commit)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 8:setup.sh 改造 + V3 装机 fixture 首跑

**类型:** 实现任务(问题式;关键行给实物)
**Files:**
- Modify: `harness/setup.sh`

**问题:** 下游要拿到对账工具与 conf(R11"对账工具分发"),前缀过滤机制(D12)随 meta-* 消亡而退役。

**约束与精确改动(spec §4.3 四点):**

1. hooks 循环:删除 `meta-*) continue` / `check-meta-*) continue` 两分支(整个 `case…esac` 段随之可删——**无任何点名排除**,R14 后无需任何排除机制)。净效果:hooks 目录所有 .sh 全量分发。
2. conf 显式分发(hooks 循环只拷 `*.sh`):在 `cp "$SCRIPT_DIR/templates/settings.json"` 行前加(逐字):

```bash
# 凭证要求表(机器版;与 docs/governance/credentials-rules.md 人读版双写同步)
cp "$SCRIPT_DIR/.claude/hooks/credentials.conf" "$TARGET_DIR/.claude/hooks/"
```

3. governance 循环:删除 `meta-*) continue` 分支 → 退化为无条件拷贝(保留循环形或改直拷,实施层自决)。credentials-rules.md 作为 `docs/governance/*.md` 一员自然拷入,无需新行。
4. 注释清理(口径=同层化、全量分发、无排除;措辞实施层可微调):hooks 段 `# 命名前缀过滤(D12)…` → `# .claude/hooks:全量分发(治理同层 2026-06-13;对账工具 check-audit-coverage.sh 随分发)`;settings 行注释去"下游零 meta hook 注册痕迹"尾注;governance 段注释 → `# governance:全量分发(治理同层;credentials-rules.md 随 *.md 自然拷入)`。
5. `templates/settings.json` **零改**(spec §4.1.7/§4.4 裁决:对账是开场手工命令非 Stop 执法,不加 check-audit-coverage 注册行;Stop 数组维持实有四件)。

**验证 = V3 装机 fixture 首跑(先红:改造前 conf 分发/新件落位必 FAIL):**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
T=$(mktemp -d); ./setup.sh "$T" > /dev/null
test -f "$T/.claude/hooks/credentials.conf" && echo OK-conf分发
test -f "$T/docs/governance/credentials-rules.md" && echo OK-新件分发
test -f "$T/.claude/hooks/check-audit-coverage.sh" && bash -n "$T/.claude/hooks/check-audit-coverage.sh" && echo OK-工具分发可解析
test ! -e "$T/.claude/hooks/check-meta-cross-ref.sh" && test ! -e "$T/.claude/hooks/check-meta-review.sh" && echo OK-无旧名件
jq -r '.hooks.Stop[0].hooks[].command' "$T/.claude/settings.json" | grep -c 'check-audit-coverage'   # 期望 0(模板零改,不接线)
ls "$T/docs/governance/" | grep -c '^meta-'   # 过渡窗实情留痕:期望 2(M1/M2 届时仍在,批 4 git rm 后 V3 复跑必须 0)
rm -rf "$T"
```

(全树零 `meta-*`/`check-meta-*` 文件名两断言**待批 4 任务 18 复跑补齐**——spec V3 时点裁决。)

- [ ] commit:

```
feat(setup): 分发改造——hooks/governance 无排除全量分发+credentials.conf 显式 cp+注释同层化口径(批2)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 9:批 2 收尾小 checkpoint —— V2/V7 全窗对照与归因(G2 协议,含 abort 条款)

**类型:** 流程 checkpoint(调度者执行;本任务含**停批条款**)
**Files:**
- Modify: `harness/docs/active/2026-06-13-single-layer-baseline.md`(归因留痕)、`harness/docs/active/handoff.md`(增量)

**步骤:**

- [ ] V2 静态断言复核(commit 后重跑任务 6 的四条断言,数值不变)
- [ ] 预期 delta 登记:把批 2 两个 commit 的治理面命中件 append 登记簿「预期 delta」节(机械收集:`git log --name-only --format= <批2首commit>^..HEAD` 过 conf include glob;预期 = check-audit-coverage.sh / credentials.conf / check-meta-cross-ref.sh(删)/ <root>/AGENTS.md / <root>/CLAUDE.md / templates/AGENTS.md / setup.sh;21 件 docs/audits 命中排除行不入)
- [ ] **全窗对照(V2 后半 + V7,同一协议)**:

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
bash .claude/hooks/check-audit-coverage.sh --reconcile 99999 2>&1 | tee /tmp/post-migration-reconcile.txt
```

- [ ] 欠账名单对照(不比字面,比名单):新名单 = 基线名单 −「缩小集合」+「预期 delta」。**缩小集合逐件归因**填入登记簿「洗活欠账归因」节(每件:被哪份凭证 covers、该文件在凭证之后的新 commit 证据 `git log -1 --format=%ci -- <file>`、归因结论="迁移时刻已失效的既存欠账,迁移刷新凭证 commit time 洗活")
- [ ] **abort 条款**:任一缩小项无法按上述归因 → **停批查因,报告调度者,不得进批 3**(G2 判据)
- [ ] V7 账齐语义核:输出标题为 `—— 凭证覆盖对账(--reconcile)——`;含 `有效凭证 M 份(其中 exempt 0 份)` 同形计数行(M 值留痕登记簿——迁移把 21 份凭证 commit time 刷新到批 2 原子 commit 时刻,历史凭证应全数被收集参与覆盖);欠账清单 = 预期 delta + 洗活转手工件,无意外件
- [ ] 窗口锚核:默认窗(无参数跑一次)的窗口起点 = 最新正式 audit 的 commit time(= 批 2 原子 commit 时刻)——这正是 G3 全窗纪律存在的原因,留痕确认
- [ ] handoff 台账增量更新(批 2 完成;G3 纪律提示写入「下一步」:开场对账用 `--reconcile 99999` 直至批 5 V8 落账)
- [ ] commit 齐核:批 2 = 2 个 commit(原子 + setup);登记簿留痕 commit:

```
docs(active): 批2 对照归因留痕——洗活欠账逐件归因+预期delta核+V7 账面快照(批2 checkpoint)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 批 3:文本合并(spec §9 批 3;M1/M2 本体保留,git rm 挪批 4 末——先改全部指针后删本体)

> ⚠️ 批 3 末 M1/M2 成"无收口入口但仍被 M3/agents/synthesis 指针引用"的过渡件(指针批 4 改),**不得提前删除**(spec 批 3 耦合注)。

## 任务 10:finishing-rules.md 改造(R1 唯一收口,spec §2.1 全套)

**类型:** 契约+实现任务(指令式逐字块 + 迁移段从 M1 实物复制)
**Files:**
- Modify: `harness/docs/governance/finishing-rules.md`

**操作:**

- [ ] **删顶部分流段并替换开头**:文件开头到「## 反模式约束」节标题之前的全部内容(含「scope 分流入口」整节与既有 H1/引语)替换为(逐字沿 spec §2.1.1):

```markdown
# Finishing 阶段治理规则

> 当 Superpowers 的 finishing-a-development-branch skill 激活时,读取本文件。
> 以下步骤在 Superpowers 的合并/PR/清理**之前**执行。
> **治理同层**(2026-06-13):本文件是唯一收口流程,不分流不分轨(原 meta-finishing-rules(M1)已并入)。
> 改动命中凭证义务(`.claude/hooks/credentials.conf` glob)时多走一节「凭证义务核对」,其余步骤(含「方向评估」,治理批照走)全员同一条路。

> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入) — 涉及阶段:evaluate / process-audit / security-scan / 治理审查。
```

- [ ] **新增「凭证义务核对」节**:插入位置 = 「流程审计」节之后、「根据评估结果分流」之前;编号续接现文件 step 14(实施时以落地文件实际编号为准)。节文(逐字沿 spec §2.1.3,**其中方括号段替换为 M1 §3 Step C 全文逐字迁入**——从盘上 `docs/governance/meta-finishing-rules.md` §3 Step C 复制:触发条件两条 / 范式选择表(普通方案选择型 / 根源承认型 D9 范式)/ D9 应用规则四条 / 范式参考文件指针 / superseding decision 错误处理,按 G1 映射机械名):

```markdown
## 凭证义务核对(改动命中 credentials.conf 时)

> 凭证制度全文(audit 文法 / exempt 豁免 / 失效规则 / 对账)住 `docs/governance/credentials-rules.md`,本节只给收口时刻的动作序,不重复文法。

15. 对照 `.claude/hooks/credentials.conf`(凭证要求表机器版)核对本批改动:任一文件命中 include glob → 本批负有 audit 凭证义务
16. 凭证义务的履行(二选一,均产凭证文件,无第三条路):
    - **对抗审查 audit**:按 `docs/governance/review-rules.md`「审查维度选择表」治理行 fork N 个挑战者审查本批改动 → 产 `docs/audits/audit-YYYY-MM-DD-HHMMSS-[主题].md`(文法见 credentials-rules §3;covers 列出本批全部命中文件)
    - **exempt 微 audit**(仅限 typo / 链接 / 注释等无语义变更):按 credentials-rules §4 文法产微 audit(`verdict: exempt` + 一行理由)
17. verdict 处置:`needs-revision` → 按 audit 所列问题修改后重审(可产新 audit);`overturn` → 撤回本批改动,记录到 ROADMAP / handoff,不进分流
18. fork 失败降级:沿「反模式约束」fork-fail-degradation 条款 — 调度者按 review-rules 维度自审,audit 标 `⚠️ 降级执行,独立性未达`

**治理批收口工序适用**(2026-06-13 decision 追记三,用户拍板):
- 凭证审查:按本节 step 15-18(命中 credentials.conf 即负义务)。
- **方向评估 = 全批适用,含治理批**(用户原话:"方向评估重要")。分工:治理审查核"这批合规达标"(以 decision/spec 为前提),方向评估问"方向本身对不对/该不该推翻"(连前提一起审)——verdict 三路同构但站位不同,非重复。
- **安全扫描与流程审计 = 维持 feature 侧,治理批暂不纳入**(用户原话:"其他的我觉得可以暂时不用担心了";连带风险登记 ROADMAP 观察项)。

### decision 立档(若有架构决策)

[实施时:此处逐字迁入 M1 §3 Step C 全文,G1 映射;含 D9 范式——承重内容(R12 不动),本就适用一切架构决策]
```

- [ ] 「安全扫描」与「流程审计」两节标题行下各加一行括注(计划内裁量 5,逐字):

```markdown
>(治理批暂不纳入,见「凭证义务核对」节治理批收口工序适用——decision 2026-06-13 追记三)
```

- [ ] **Step D 合并去重**(spec §2.1.2):
  1. 「通过」step 2 末尾依据行中括注 `(meta scope 改动同步走 M1 \`meta-finishing-rules.md\` Step D 的对应项)` 删除(保留依据指针本体);
  2. 「通过」清单末尾追加两条(M1 Step D 独有增量,逐字):

```markdown
9. 更新 `docs/ROADMAP.md`:本批状态/进展行推进(原 M1 Step D 独有义务并入)
10. 结构性变化(角色/流程/凭证制度类)同步 `memory/project_harness_overview.md`(原 M1 Step D 独有义务并入)
```

- [ ] **残余术语清扫**(spec §2.1.4):「反模式约束」内历史 audit 引语(D3-F8/D2-F1/D2-F3 等)**不动**;step 12 process-audit 产物命名 `audit-YYYY-MM-DD-HHMMSS.md` **不动**;fork-fail-degradation 条款的适用点枚举由三处(安全扫描/方向评估/流程审计)扩为**四处**(追加「凭证义务核对 step 18」,措辞与既有三处同形)
- [ ] 不迁项核(spec §2.1.2):Step A 消亡(豁免边界已住 credentials-rules §4)/ M1 §4 档位已参数化迁 credentials-rules §7(任务 2 已做)/ M1 §5 skip 汇总消亡 / Step D 特例(反审待办)转考古不迁——本文件**不得**出现这些内容的残骸
- [ ] 验证:

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
F=docs/governance/finishing-rules.md
grep -c 'scope 分流\|scope=meta\|meta-finishing-rules\|meta-scope.conf' "$F"   # 期望 0
grep -qF '## 凭证义务核对(改动命中 credentials.conf 时)' "$F" && echo OK-新节
grep -qF '治理批收口工序适用' "$F" && echo OK-工序适用
grep -qF '### decision 立档(若有架构决策)' "$F" && echo OK-StepC迁入
grep -qF 'D9' "$F" && echo OK-D9范式在场
grep -cE '^1[5-8]\. ' "$F"          # 期望 4(step 15-18)
grep -qF 'memory/project_harness_overview.md' "$F" && echo OK-StepD增量
grep -c '治理批暂不纳入' "$F"        # 期望 ≥3(工序适用段+两节括注)
grep -c 'meta-review' "$F"           # 期望仅历史 audit 引语命中(逐处人工判读:引考古凭证名属合法)
```

- [ ] commit:

```
feat(governance): finishing-rules 唯一收口——分流段拆除+凭证义务核对节(step15-18)+M1 StepC逐字迁入/StepD合并+治理批工序适用(批3)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 11:review-rules.md 改造(R2 唯一审查,spec §2.2)

**类型:** 契约任务(指令式逐字 + 触点完整性维从 M2 实物逐字迁)
**Files:**
- Modify: `harness/docs/governance/review-rules.md`

**操作:**

- [ ] **头注改写**(文件顶部 H1+引语替换,逐字沿 spec §2.2.1):

```markdown
# 审查阶段治理规则(唯一审查规则 — 治理同层)

> 一切审查(代码 / 设计 / 治理)的维度选择从本文件「审查维度选择表」出发;各模态的挑战者 prompt 模板由对应 skill 自带(design-review / evaluate / security-scan / process-audit 的 SKILL.md),本文件不载模板全文。
> Superpowers 的 requesting-code-review skill 激活时,读本文件「代码类维度集」各节(在 Superpowers 默认审查维度之上追加)。
> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入)。
```

- [ ] **新增「审查维度选择表」节**(头注后,逐字沿 spec §2.2.2 全文):

```markdown
## 审查维度选择表

| 改动类别 | 判定(人读;机器判据 = `.claude/hooks/credentials.conf`) | 维度集 | 力度 / N 弹性 |
|---|---|---|---|
| **代码** | 业务代码 / 测试 / 构建脚本(不命中 credentials.conf) | Superpowers 默认维度 + 本文件「代码类维度集」五节(RUBRIC / 架构合规 / 类型契约 / 简洁性 / 模块文档一致性) | 实现内嵌两段审查(spec 忠实性 + 代码质量);重大改动可加 fork |
| **设计** | `docs/superpowers/specs/` 设计文档 | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐(4 维;模板住 design-review SKILL) | 并行 fork 4 挑战者(design-review skill 定义) |
| **治理** | 命中 credentials.conf include glob(治理规则 / 入口地图 / hooks / skills / agents / RUBRIC / 设计模板 / setup / 分发模板) | **bootstrap 4 维强制基线(禁止删减;禁用需用户确认)**:核心原则合规 / 目的达成度 / 副作用 / scope 漂移。**+ 触点完整性维(条件必选)**:改动涉及机制的产出/消费契约、跨文件计数/枚举、或分发链时必选;孤立单文件 typo 可不选(定制理由段记录) | N 弹性 2-5+(由主题复杂度定,不机械按 skill 数;上限受单 prompt 64 kB 软上限约束,超限拆多轮 fork)。审查产物 = audit 凭证(文法住 credentials-rules §3) |

- 一批含多类改动:按类各取维度集,审查可同批 fork、凭证按 credentials-rules 归账(audit covers 列治理面文件即可)。
- 模态与模板的住址:对抗式模板住 design-review / evaluate SKILL;混合式(凭证扫描 + 对抗判定)住 security-scan SKILL;事实统计式住 process-audit SKILL。本表只定"选哪些维度、多大力度",模板细节去 skill 家读。
- 多 fork 并行约束(逐字迁自 M2 §3.1,适用一切多 fork 审查):必须在单一 assistant turn 内一次性发起 N 个 Agent 调用,不得串行下发(依据 2026-04-28 process-audit P-3 实证:曾致 4 挑战者跨 12 分钟串行)。
- 挑战者错误处理(迁自 M2 §4.4):挑战者空返回 → 重试一次 → 仍败标"未完成",不得静默当通过。
```

- [ ] 表下加 D7 沿革注一行(spec §2.2.3,逐字):`- bootstrap 4 维沿 D7:不加第 5 维;禁用 minimum 项需用户确认。`
- [ ] **新增小节「### 触点完整性维(治理行条件必选维)」**:从盘上 M2(`docs/governance/meta-review-rules.md`)§6 触点完整性维**全文逐字迁入**(G1 映射),必含四块:与 D7 撤回维的正交区分留痕 / 实证段(剪枝三批、2026-06-05 A/B/E 簇)/ 怎么查 / 何时优先选——实证内容是防"被当 scope 漂移咬回"的留痕,**不可摘**
- [ ] 既有 40 行 code review 细则五节保留为「代码类维度集」:五节之前插入统领标题 `## 代码类维度集(requesting-code-review 激活时读)`(计划内裁量 6,结构性标题无语义变更;五节正文零碰)
- [ ] 验证:

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
F=docs/governance/review-rules.md
grep -qF '## 审查维度选择表' "$F" && echo OK-维度表
grep -qF '### 触点完整性维(治理行条件必选维)' "$F" && echo OK-触点维
for d in 核心原则合规 目的达成度 副作用 'scope 漂移'; do grep -qF "$d" "$F" && echo "OK 4维-$d"; done
grep -qF '单一 assistant turn' "$F" && echo OK-并行约束
grep -qF '重试一次' "$F" && echo OK-错误处理
grep -qF '## 代码类维度集' "$F" && echo OK-统领标题
grep -c 'meta-review-rules\|meta-finishing-rules\|scope=meta' "$F"   # 期望 0
git diff "$F" | grep -c '^-.*RUBRIC 对齐的检查'   # 期望 0(五节正文零碰的抽查;实施时以 git diff 人工核五节无删改行)
```

- [ ] commit:

```
feat(governance): review-rules 唯一审查——维度选择表(代码|设计|治理)+bootstrap4维基线+触点完整性维逐字迁入(批3)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 12:四审查 SKILL 内嵌挑战者模板(R6,spec §2.2.4)

**类型:** 契约任务(指令式;模板正文从 M2 §6 对应子节逐字迁,G1 映射)
**Files:**
- Modify: `harness/.claude/skills/design-review/SKILL.md`(现 L33-42)
- Modify: `harness/.claude/skills/evaluate/SKILL.md`(现 L52-66)
- Modify: `harness/.claude/skills/security-scan/SKILL.md`(现 L32-43)
- Modify: `harness/.claude/skills/process-audit/SKILL.md`(现 L56-68)

(行号为 spec 2026-06-13 实物行号,实施时以内容锚定位:各 SKILL 内「scope=meta 时的 §3.1.7 runtime 嵌入引导」段/等价段。)

**操作(每 SKILL 同构,逐件):**

| SKILL | 替换段 → 内嵌模板(从 M2 §6 对应子节逐字迁入) | 件内特有改动 |
|---|---|---|
| design-review | 对抗式 A/B/C 三段(A 推荐维度 / B 最低必选 = bootstrap 4 维基线 / C 定制理由) | 下游兼容注(B6)删除(同层后无条件分支) |
| evaluate | 对抗式 A/B/C 三段(同上) | evidence depth 档位指针改 `credentials-rules §7` |
| security-scan | 混合式(X 硬编码扫描 pattern 引用 + A/B/C 对抗部分) | — |
| process-audit | 事实统计式(N1 流程遵从度 + G 粒度细化) | — |

- 每件:原"scope=meta 时…"整段(指 M1/M2 路径的 runtime 嵌入引导)**整段替换**为内嵌模板 + 一行权威指针(逐字):`维度选择权威 = docs/governance/review-rules.md「审查维度选择表」;治理面改动审查产 audit 凭证(credentials-rules)`
- **B 段维度名单源**:SKILL 模板 B 段列 4 维名并标"权威 = review-rules 维度选择表"(与现状"静态列名 + 引 M2"同构,只换权威地址)。
- M2 §5 runtime 嵌入契约随之消亡(模板就在 SKILL 里,skill 激活即在场,无需二跳);8 KB 嵌入上限不再声明(64 kB 软上限已入维度选择表 N 弹性栏,任务 11)。
- 对抗式模板 design-review ↔ evaluate 为双写对(credentials-rules §8 第 4 条):A/B/C 三段同构,**同 commit 改**。

**验证:**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
for s in design-review evaluate security-scan process-audit; do
  F=.claude/skills/$s/SKILL.md
  echo "== $s"
  grep -c 'scope=meta\|meta-review-rules\|meta-finishing-rules' "$F"    # 各期望 0
  grep -qF '维度选择权威 = docs/governance/review-rules.md' "$F" && echo OK-权威行
done
grep -qF 'credentials-rules §7' .claude/skills/evaluate/SKILL.md && echo OK-档位指针
# V9 正向在场断言(模板本体在场,非只删旧段):
grep -cE 'A 段|B 段|C 段' .claude/skills/design-review/SKILL.md     # ≥3
grep -cE 'A 段|B 段|C 段' .claude/skills/evaluate/SKILL.md          # ≥3
grep -qE '硬编码|扫描 pattern' .claude/skills/security-scan/SKILL.md && echo OK-混合式
grep -qE 'N1|流程遵从度' .claude/skills/process-audit/SKILL.md && echo OK-事实统计式
for d in 核心原则合规 目的达成度 副作用 'scope 漂移'; do grep -l "$d" .claude/skills/*/SKILL.md | wc -l; done   # 各 ≥2(B 段维度名在场)
```

- [ ] commit(四件同 commit,落实对抗式双写对同批):

```
feat(skills): 四审查 SKILL 自带挑战者模板——M2 三段 pattern 逐字下放+权威指针 review-rules 维度表(R6)(批3)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 13:contracts-locked.md 退役注记(R5,spec §6.1)

**类型:** 契约任务(指令式,仅顶部插入;正文一字不动转考古)
**Files:**
- Modify: `harness/docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md`(仅顶部)

**操作:** 文件顶部(H1 之后第一空行处)插入(逐字沿 spec §6.1):

```markdown
> ⚠️ **已退役(2026-06-13,治理同层化)** — 本文件转考古层。
> 契约锁防的是"批次实施期多 agent 拷贝漂移";单源 + 引用体制已消灭拷贝,锁无对象(decision `docs/decisions/2026-06-13-governance-single-layer.md` 第一性重推 1:退役非"迁锁")。
> C1(scope.conf)→ 后继 `.claude/hooks/credentials.conf` + `docs/governance/credentials-rules.md` §2;C2(audit 文法)→ credentials-rules §3(文法语义逐字沿用;标识字段名按 R13 统一为 `audit: true`,21 份历史件同批格式迁移;文件名不换);C3(handoff skip/反审字段)→ skip 制度消亡(豁免=exempt 微 audit,credentials-rules §4),反审字段为已闭环历史;C4(三段 pattern)→ 各审查 skill SKILL.md 自带;C5(settings 双轨)→ 自仓库 settings 已撤(2026-06-12 追记①),templates/settings.json 为下游唯一来源。
> 残余真双端(规则文本 ↔ hook 正则)清单与守法住 spec `docs/superpowers/specs/2026-06-13-governance-single-layer-design.md` §6.2。
```

**验证:** `git diff docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md` 仅一个顶部插入 hunk,零删除行(`git diff --numstat` 删除列 = 0)。

- [ ] commit:

```
docs(plans): contracts-locked 退役注记——契约锁机制转考古,C1-C5 后继逐契约指明(R5)(批3)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 14:批 3 收尾小 checkpoint —— V9 逐字迁移保真核 + 三件套互引核

**类型:** 流程 checkpoint(调度者执行;V9 = 排批 3 验证列,spec §8.3)
**Files:**
- Modify: `harness/docs/active/handoff.md`(增量)、登记簿(按需 append)

**步骤:**

- [ ] **V9 逐字迁移保真核**(源件 M1/M2 本批仍在盘,逐对 diff;合法差异**仅** G1 映射表内机械名替换,语义零漂;发现漂移 → 修正后重核):

| # | 源(退役件实物段) | 新居所 |
|---|---|---|
| 1 | M1 §3 Step C 全文(含 D9 范式) | finishing-rules「decision 立档」小节 |
| 2 | M1 §4.3 第 5 条(证据位置具体路径) | credentials-rules §7 |
| 3 | M2 §6 B 段(bootstrap 4 维+禁用约束) | review-rules 维度表治理行 |
| 4 | M2 §6 触点完整性维全文(正交区分/实证/怎么查/何时选) | review-rules 独立小节 |
| 5 | M2 §6 对抗式 A/B/C | design-review + evaluate SKILL |
| 6 | M2 §6 混合式 | security-scan SKILL |
| 7 | M2 §6 事实统计式 | process-audit SKILL |
| 8 | M2 §3.1 多 fork 并行约束 | review-rules 表 bullet |
| 9 | M2 §4.4 挑战者错误处理 | review-rules 表 bullet |
| 10 | M2 §7(§7.3 covers 五条/§7.4 写侧/§7.5.1 登记簿/§7.6 读侧) | credentials-rules §3 |
| 11 | M2 §8(失效规则四小节) | credentials-rules §5 |

- [ ] 四 SKILL 模板正向在场断言复核(任务 12 验证块重跑)
- [ ] **三件套互引人工核**(spec §6.2 行 6——cross-ref 件已删无机器核,触点完整性维人工走):

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
grep -qF 'credentials-rules' docs/governance/finishing-rules.md && echo OK-finishing→credentials
grep -qF '## 凭证义务核对' docs/governance/finishing-rules.md && echo OK-节锚在场
grep -qF '## 审查维度选择表' docs/governance/review-rules.md && echo OK-维度表锚
grep -qF 'credentials-rules' docs/governance/review-rules.md && echo OK-review→credentials
grep -qF 'review-rules' docs/governance/credentials-rules.md && echo OK-credentials→review
grep -qF 'finishing' docs/governance/credentials-rules.md && echo OK-credentials→finishing
```

- [ ] 本批验证绿 + commit 齐(批 3 = 4 个 commit:任务 10/11/12/13)+ handoff 增量更新(批 3 完成)

---

# 批 4:地图清扫 + 退役件删除(spec §9 批 4;末位 git rm M1/M2——消费者先于生产者退役)

## 任务 15:契约 —— 根 CLAUDE.md(M3)分流机器拆除 + harness/CLAUDE.md(M4)治理表同步

**类型:** 契约任务(指令式,spec §5.2/§5.3 + §7.1 件 1/件 5)
**Files:**
- Modify: `CLAUDE.md`(仓库根,M3)
- Modify: `harness/CLAUDE.md`(M4 分发模板)

**操作(M3):**

- [ ] **删三节**:§3「scope 触发判定」(含表与「同步约束」blockquote)/ §4「meta vs feature 分流引导」/ §5「scope 内对照表」三节**整体删除**
- [ ] **§2 治理规则表节整体替换**(含原表与两条 blockquote 注——synthesis/model-route 信息已并入新表行)为(逐字沿 spec §5.2):

```markdown
## 2. 治理规则表(单层 — 治理同层化 2026-06-13)

| 阶段 | 治理文件 |
|------|----------|
| brainstorming | `harness/docs/governance/brainstorming-rules.md` |
| system-design | `harness/docs/governance/design-rules.md` |
| writing-plans | `harness/docs/governance/planning-rules.md` |
| implementation + testing | `harness/docs/governance/implementation-rules.md` + `testing-rules.md` |
| 审查(代码/设计/治理) | `harness/docs/governance/review-rules.md`(维度选择表) |
| finishing(唯一收口) | `harness/docs/governance/finishing-rules.md` |
| **凭证与对账(跨阶段)** | **`harness/docs/governance/credentials-rules.md`(单入口)+ `harness/.claude/hooks/credentials.conf`(机器版,双写同步)** |
| 跨阶段综合 | `harness/docs/governance/synthesis-rules.md`(fork 多挑战者前后必读) |
| 模型路由(跨阶段) | `harness/docs/governance/model-route.md`([2026-05-24] P2 codex 接入搁置,当前全 Claude) |

> 凭证义务一句话:改动命中 credentials.conf 任一 include glob → 收口前必有 audit 凭证(对抗审查 audit 或 exempt 微 audit);类目与 glob 详 credentials-rules.md §2,制度全文住 credentials-rules.md,本文件不重复(防散文拷贝,§2.3-§8)。
```

- [ ] §1 角色表「meta-review(harness 自治理)」行替换为(逐字):`| **治理审查** | 调度者按 review-rules 维度选择表 fork N 挑战者 | 治理面改动审查(凭证义务详 credentials-rules) |`
- [ ] 「活上下文链 dogfood 边界」节一处提法改:`meta-review「触点完整性」维(\`harness/docs/governance/meta-review-rules.md\` §6)` → `治理审查「触点完整性」维(\`harness/docs/governance/review-rules.md\`)`(节内其余零改)
- [ ] 头注一句措辞收尾(计划内裁量 7):`调度者每次会话开头读本文件识别 scope + 找对应治理规则` → `调度者每次会话开头读本文件走治理规则表与会话开场规程`
- [ ] **零改核**:二公设/反向规则/角色分离正文(§1 除一行)/「上下文层地图行」/「会话开场规程」(批 2 已改)/「仓库结构 + 快速开始」零碰(spec §5.2;地图行节内"A 组 → meta-review"残留按 spec 不动——计划内裁量「spec 残留观察 a」)

**操作(M4 harness/CLAUDE.md):**

- [ ] 治理规则表:「requesting-code-review | docs/governance/review-rules.md」行替换为 `| 审查(代码/设计/治理) | docs/governance/review-rules.md(维度选择表) |`;其后新增一行 `| **凭证与对账(跨阶段)** | **docs/governance/credentials-rules.md(单入口)+ .claude/hooks/credentials.conf(机器版,双写同步)** |`(两行均落治理规则表,计划内裁量 8)
- [ ] 角色表下 D13 注(「本表是分发到下游项目的角色清单…不分发下游」)整段删除,替换一行(逐字):`> 注:治理同层(2026-06-13)——上下游同一套治理与凭证义务,无另册。`
- [ ] 核心规则 11(开场对账)**零改**(命令住 AGENTS.md)

**验证:**

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
grep -c 'scope 触发判定\|分流引导\|scope 内对照表\|M3↔M17' CLAUDE.md          # 期望 0
grep -qF '治理规则表(单层 — 治理同层化 2026-06-13)' CLAUDE.md && echo OK-单表
grep -c 'meta-scope.conf\|check-meta-review\|check-meta-cross-ref\|meta-review-rules\|meta-finishing-rules\|scope=meta\|meta-L[1-4]' CLAUDE.md   # 期望 0
grep -qF '治理审查「触点完整性」维' CLAUDE.md && echo OK-提法改
grep -qF '二条公设' CLAUDE.md && grep -qF '反向规则' CLAUDE.md && echo OK-承重件在场
grep -qF '治理同层(2026-06-13)——上下游同一套治理与凭证义务' harness/CLAUDE.md && echo OK-M4同层注
grep -c 'scope=meta\|meta-review' harness/CLAUDE.md                            # 期望 0(D13 注已删)
grep -qF 'credentials-rules' harness/CLAUDE.md && echo OK-M4凭证行
grep -qF '会话开场先装载再对账' harness/CLAUDE.md && echo OK-核心规则11零改
```

- [ ] commit:

```
docs(map): M3 分流机器拆除(三节删除+治理表单表化+角色行)/ M4 治理表同层两行+D13注退役(批4)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 16:契约 —— QUICKREF + README×2 + AGENTS×2 硬规矩行 + 上下文层 spec 状态头注记

**类型:** 契约任务(指令式,spec §5.1③/§5.4/§5.5 + §7.1 件 2/3/4/6/7/33)
**Files:**
- Modify: `harness/QUICKREF.md`、`README.md`(仓库根)、`harness/README.md`、`AGENTS.md`(仓库根)、`harness/templates/AGENTS.md`、`harness/docs/superpowers/specs/2026-06-12-context-layer-design.md`(仅状态头)

**操作:**

- [ ] QUICKREF.md 三表各加一行(逐字沿 spec §5.4):
  - 「治理规则」表:`| **凭证与对账(跨阶段)** | **docs/governance/credentials-rules.md** |`
  - 「Hook」表:`| check-audit-coverage | 凭证覆盖对账(--reconcile 开场用;治理面改动的 audit 凭证核) |`
  - 「关键文件」表:`| docs/audits/ | 审查凭证(audit-*;频次低但生死攸关) |`
- [ ] README ×2(根 README.md 与 harness/README.md 两份独立维护,三处改法各自适用;以内容锚定位):
  - 原则 3.1 行:将行尾段 "`security-scan` / `meta-review`" 改为 "`security-scan` / 治理审查(同层,见 credentials-rules)"(行内其余字不动)
  - 原则 4.3 行整行替换(逐字):`- **4.3 改动范围自动识别** — 治理面改动按凭证要求表机械负担 audit 凭证义务,开场对账核账。**Why**:不靠 AI 自觉,机械判据不可被自我说服绕过。**实现**:docs/governance/credentials-rules.md + .claude/hooks/credentials.conf + check-audit-coverage.sh --reconcile`
  - 模型路由「不 Swap」行:`meta-review` → `治理审查`
- [ ] 根 AGENTS.md ③:硬规矩节追加一行(逐字沿 spec §5.1 ③,与既有三行同形):

```markdown
- 治理面改动留凭证: 命中 credentials.conf 的改动收口前必有 audit(或 exempt 微 audit) → 全文住 harness/docs/governance/credentials-rules.md
```

- [ ] templates/AGENTS.md ②:硬规矩节追加一行(逐字,下游单层路径;与根版同 commit——共享核同批改义务):

```markdown
- 治理面改动留凭证: 命中 credentials.conf 的改动收口前必有 audit(或 exempt 微 audit) → 全文住 docs/governance/credentials-rules.md
```

(templates/AGENTS.md 九格表零改——格 6 干活规矩 `docs/governance/` 已含新件,spec §5.1。)

- [ ] 上下文层现行版 spec 状态头注记(件 33):`docs/superpowers/specs/2026-06-12-context-layer-design.md` 状态头(与"微修正 ×1"行同位同形)追加一行(逐字沿 spec §5.5):

```markdown
> 受波及注记(2026-06-13,治理同层化):§5「scope 治理触点」、§6 对账命令 3 与欠账处置句、§7 工具箱成员行中的 meta-review / check-meta-review / check-meta-cross-ref / meta-scope.conf 表述,自治理同层化落地起以 `2026-06-13-governance-single-layer-design.md` 为准(对应物:治理审查凭证 / check-audit-coverage.sh / check-meta-cross-ref 已删除(互引守法归审查触点完整性维)/ credentials.conf;skip 字段制度消亡,豁免走 exempt 微 audit)。本文正文按 immutable 惯例不追改。
```

**验证:**

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
grep -c 'credentials' harness/QUICKREF.md            # ≥1
grep -qF 'check-audit-coverage' harness/QUICKREF.md && echo OK-Hook行
for f in README.md harness/README.md; do
  grep -c 'meta-review\|meta-scope.conf\|check-meta' "$f"    # 各期望 0
  grep -qF '4.3 改动范围自动识别' "$f" && grep -qF 'check-audit-coverage.sh --reconcile' "$f" && echo "OK-4.3 $f"
done
grep -c '治理面改动留凭证' AGENTS.md harness/templates/AGENTS.md   # 各 1
grep -cE '^- ' <(sed -n '/## 硬规矩/,/^## /p' AGENTS.md)            # 期望 4(原 3+1)
grep -qF '受波及注记(2026-06-13,治理同层化)' harness/docs/superpowers/specs/2026-06-12-context-layer-design.md && echo OK-注记
git diff --numstat harness/docs/superpowers/specs/2026-06-12-context-layer-design.md   # 删除列 = 0(正文 immutable 零碰)
```

- [ ] commit:

```
docs(map): QUICKREF/README×2 凭证行+AGENTS×2 硬规矩行+上下文层spec受波及注记——发现链五处收齐(批4)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 17:残余消费点清扫(spec §7.1 件 8/13-15/18/19-23/28/29-32,15 件逐件)

**类型:** 实现任务(逐件指令,改法 = spec §7.1 逐字裁决;行号以实物为准,内容锚定位)
**Files:** 下表 15 件

| # | 文件 | 改法(spec §7.1 原文要义) |
|---|---|---|
| 件 13 | `harness/.claude/hooks/check-handoff.sh` | **仅注释**:L39 教训出处 `meta-finishing-rules.md:116` 改 `(半角纪律,权威住 structured-handoff SKILL;沿 2026-04-28 C3 Y3 教训)`;L52/L138 `check-meta-review` 改 `check-audit-coverage`。**逻辑零碰** |
| 件 14 | `harness/.claude/hooks/check-context-chain.sh` | **仅注释**:L10 `与 meta-review 必须有 audit 同套路` → `与治理审查必须有 audit 凭证同套路`;L23-24 命名/scope 注 → `无点名排除 → 分发下游;落 .claude/hooks/ → credentials.conf 自动纳凭证义务` |
| 件 15 | `harness/.claude/hooks/check-shelf-registry.sh` | **仅注释**:L25-26 同件 14 口径 |
| 件 18 | `harness/docs/governance/synthesis-rules.md` | 流程名 meta-review → 治理审查(L3,17,103,169 场景清单);L34 `由 meta-review/process-audit 抽检` → `由治理审查/process-audit 抽检`;L201-205 术语示例行:`scope=meta` 示例替换为现行术语示例(如 `凭证义务(改动命中 credentials.conf,须 audit 凭证)`);L227 audit 路径示例改 `docs/audits/audit-YYYY-MM-DD-HHMMSS-...md`;L276 引用行改 `docs/governance/review-rules.md + credentials-rules.md(上下游同文分发)` 并去"仅 harness 自仓库"警示 |
| 件 19 | `harness/.claude/agents/design-reviewer.md` | L67 runtime 嵌入引导段删除(嵌入契约消亡),换一行 `维度选择权威 = docs/governance/review-rules.md 维度选择表;治理面改动审查产 audit 凭证(credentials-rules)`;L95/164/230/293 四处 `B 段维度名引用自 M2` → `引用自 review-rules 维度选择表` |
| 件 20 | `harness/.claude/agents/evaluator.md` | 同件 19 口径;L85/93/96 evidence depth 三 scope 分流表删,改单行 `档位解释按改动类别 → credentials-rules §7`;L148 档位话术改 `治理改动用 L1-L4 治理列解释` |
| 件 21 | `harness/.claude/agents/security-reviewer.md` | 同件 19 口径(L71,115,187,256;模板住 security-scan SKILL) |
| 件 22 | `harness/.claude/agents/process-auditor.md` | 同件 19 口径(L214,231;模板住 process-audit SKILL;L231 G 段示例路径改 credentials-rules) |
| 件 23 | `harness/.claude/agents/designer.md` | L53 `对应 spec evidence depth meta-L1 / feature L1` → `对应证据档位 L1(节内自检,credentials-rules §7)` |
| 件 28 | `harness/.claude/skills/structured-handoff/SKILL.md` | L83/85 晋升路由表:`走 meta-review` → `须 audit 凭证(credentials-rules)`;L85 `可走 skip 字段轻路径` → `可走 exempt 微 audit 轻路径(credentials-rules §4)`;L117-118 教训出处改与件 13 同口径 |
| 件 29 | `harness/docs/governance/planning-rules.md` | L11:`实战留痕 / 真实场景验证 / meta-L4` → `实战留痕 / 真实场景验证 / 治理改动 L4(credentials-rules §7)` |
| 件 30 | `harness/docs/references/testing-standard.md` | L3 适用域注改:`**适用域**:本文档定义 feature/代码改动的 L1-L4 细则;治理/设计改动的档位解释列见 \`docs/governance/credentials-rules.md\` §7(同名 L1-L4,按改动类别参数化;Evidence Depth 字段按类各填行)` |
| 件 31 | `harness/docs/references/challenger-orientation.md` | L77 档位分流改 `治理改动 → 引 credentials-rules §7 治理列`;L166 目录树行 `meta-review-rules.md / meta-finishing-rules.md` → `review-rules.md / credentials-rules.md / finishing-rules.md` |
| 件 32 | `harness/docs/references/recommended-tools.md` | L29 不 Swap 行同 §5.4 口径(meta-review → 治理审查);L63 改 `新增推荐工具:append 即可(不命中凭证义务);若要改 setup.sh 提示,setup.sh 命中 credentials.conf → 须 audit 凭证` |
| 件 8 | `harness/templates/README.md` | L8 改 `hooks 全量分发(check-meta-cross-ref 已删除,R14)`;L13 改 `确认脚本随 hooks 循环分发(无排除机制)`;L24 改 `入凭证义务(credentials.conf templates/*.json 行)— 改模板必触发审查凭证` |

**验证:**

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
# 逐件九术语零命中(改件清单全量):
for f in .claude/hooks/check-handoff.sh .claude/hooks/check-context-chain.sh .claude/hooks/check-shelf-registry.sh \
         docs/governance/synthesis-rules.md .claude/agents/design-reviewer.md .claude/agents/evaluator.md \
         .claude/agents/security-reviewer.md .claude/agents/process-auditor.md .claude/agents/designer.md \
         .claude/skills/structured-handoff/SKILL.md docs/governance/planning-rules.md docs/references/testing-standard.md \
         docs/references/challenger-orientation.md docs/references/recommended-tools.md templates/README.md; do
  n=$(grep -cE 'meta-finishing-rules|meta-review-rules|meta-scope\.conf|check-meta-review|check-meta-cross-ref|meta-review: skipped|meta-cross-ref: skipped|scope=meta|meta-L[1-4]' "$f")
  echo "$n $f"   # 全部期望 0
done
# 件 13-15 逻辑零碰(I3):git diff 逐 hook 人工核——hunk 全为注释行;冒烟:
echo '{}' | bash .claude/hooks/check-shelf-registry.sh; echo "exit=$?"        # 期望 0
bash .claude/hooks/check-handoff.sh --reconcile >/dev/null 2>&1; echo "exit=$?"  # 期望 0(现台账合规态)
```

- [ ] commit:

```
docs(sweep): 消费点清扫 15 件——hooks注释×3/agents×5/synthesis/structured-handoff SKILL/planning-rules/references×3(含testing-standard)/templates README(批4)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 18:末位 git rm M1/M2 + 批 4 收尾小 checkpoint(V3 复跑 + V5 + V6)

**类型:** 实现+流程 checkpoint(调度者执行;**本任务必须是批 4 最后一个动作**——消费者先于生产者退役)
**Files:**
- Delete: `harness/docs/governance/meta-finishing-rules.md`、`harness/docs/governance/meta-review-rules.md`
- Modify: `harness/docs/active/handoff.md`(增量)

**步骤:**

- [ ] **删除前指针清查**(活层对 M1/M2 的引用必须已全数归一;docs/active 待批 5 覆写故排除):

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
git grep -l -E 'meta-finishing-rules|meta-review-rules' -- . \
  ':!harness/docs/audits' ':!harness/docs/completed' ':!harness/docs/decisions' \
  ':!harness/docs/decision-trail.md' ':!harness/docs/PROGRESS.md' ':!harness/docs/ROADMAP.md' \
  ':!harness/docs/superpowers/plans' ':!harness/docs/superpowers/specs' \
  ':!harness/docs/references/2026-*' ':!harness/docs/active'
# 期望输出仅两件:harness/docs/governance/meta-finishing-rules.md / meta-review-rules.md(自身)
# 出现第三件 = 漏改指针 → 回任务 15-17 补,不得 git rm
```

- [ ] `git rm harness/docs/governance/meta-finishing-rules.md harness/docs/governance/meta-review-rules.md`(git 史即考古)
- [ ] governance 目录断言:`ls harness/docs/governance/ | grep -c '^meta-'` → 0;`ls harness/docs/governance/ | grep -cE '^(review|finishing|credentials)-rules.md'` → 3
- [ ] commit:

```
feat(governance): M1/M2 退役 git rm——全部指针已归一,消费者先于生产者退役(批4 末位)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

- [ ] **V3 复跑(全断言版,补齐批 2 缓发的两断言)**:

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
T=$(mktemp -d); ./setup.sh "$T" > /dev/null
test -f "$T/.claude/hooks/credentials.conf" && echo OK-conf
test -f "$T/docs/governance/credentials-rules.md" && echo OK-新件
test -f "$T/.claude/hooks/check-audit-coverage.sh" && bash -n "$T/.claude/hooks/check-audit-coverage.sh" && echo OK-工具
test ! -e "$T/.claude/hooks/check-meta-cross-ref.sh" && echo OK-无crossref
find "$T" \( -name 'meta-*' -o -name 'check-meta-*' \) | wc -l        # 期望 0(全树零 meta-* 文件名)
ls "$T/docs/governance/" | grep -c '^meta-'                            # 期望 0
ls "$T/docs/governance/" | grep -cE '^(review|finishing|credentials)-rules.md'   # 期望 3
rm -rf "$T"
```

- [ ] **V5 双写比对核**(conf ↔ credentials-rules §2 人读表,逐行一致):

```bash
cd /d/个人/harness/harness && export LC_ALL=C.UTF-8
diff <(grep -vE '^#|^$|^!' .claude/hooks/credentials.conf | awk '{print $1}') \
     <(sed -n '/## §2/,/## §3/p' docs/governance/credentials-rules.md | grep -E '\| audit \|$' | grep -oE '`[^`]+`' | tr -d '\`')
diff <(grep -E '^!' .claude/hooks/credentials.conf) \
     <(sed -n '/## §2/,/## §3/p' docs/governance/credentials-rules.md | grep -E '^\| 排除' | grep -oE '`[^`]+`' | tr -d '\`')
# 两个 diff 均期望空输出(include 14 行 + 排除 3 行逐行同序一致)
```

- [ ] **V6 地图链走查**(spec §5.6 七入口逐条人工走,每条 ≤3 步到 credentials-rules;实测全部 1 步,留痕 handoff):

| 入口 | 路径 | 期望步数 |
|---|---|---|
| 跨运行时 agent(根 AGENTS.md) | 凭证义务行 / 硬规矩行 → credentials-rules.md | 1 |
| Claude Code 自仓库(根 CLAUDE.md) | §2 治理表「凭证与对账」行 → credentials-rules.md | 1 |
| 下游(harness/CLAUDE.md=M4 / templates/AGENTS.md) | 治理表行 或 硬规矩行 → credentials-rules.md | 1 |
| 工作流内(finishing 收口) | finishing-rules「凭证义务核对」节 → credentials-rules.md | 1 |
| 工作流内(审查) | review-rules 维度表治理行 → credentials-rules.md | 1 |
| 对账报错现场 | check-audit-coverage stderr 指引 → credentials-rules.md | 1 |
| 冷读者(README) | 原则 4.3 行 → credentials-rules.md | 1 |

- [ ] handoff 增量更新(批 4 完成;V4 断链核**不在本批**——件 35 handoff 未覆写跑必红,挪批 5,spec 批 4 耦合注)+ commit 齐核(批 4 = 4 个 commit:任务 15/16/17/18)

---

# 批 5:收尾自证 + 断链核(spec §9 批 5 —— 总 checkpoint:M5 + 新制度首跑)

## 任务 19:留痕收口(ROADMAP / decision-trail / PROGRESS)

**类型:** 留痕任务(指令式;件 36 + §10.2-i 观察项登记)
**Files:**
- Modify: `harness/docs/ROADMAP.md`、`harness/docs/decision-trail.md`、`harness/docs/PROGRESS.md`

**操作:**

- [ ] ROADMAP 件 36(**仅活条目改**):L77 活观察项内 `check-meta-review` 提及改 `check-audit-coverage`(该条目描述的是仍在跟踪的工具行为);L36/42/63 历史进展行**不动**(引历史 audit 文件名/当时术语,改了失真)
- [ ] ROADMAP 新增观察项(spec §10.2-i / decision 追记三,要点逐字):`治理批暂无机器安全扫——hook 脚本危险操作面 / AI 指令文本注入面在治理批暂无机器扫(安全扫描/流程审计维持 feature 侧,decision 2026-06-13 追记三);触发器:实战出险或用户重启`
- [ ] ROADMAP 本批进展行:治理同层化批 1-5 完成(取代 P0.9.1 双轨结构;凭证不变量保留)
- [ ] decision-trail append 判断拐点(1-2 条,候选;link decision 2026-06-13):
  - `双轨治理收敛单层:scope 分流机器拆除,凭证参数化(credentials.conf/credentials-rules)取代 meta-* 体系——"治理改动必须被审查留凭证"不变量保留,解法结构整体取代(decisions/2026-06-13-governance-single-layer.md)`
  - `skip 字段退役:豁免改走 exempt 微 audit 凭证正道——对账天然认,消除"reconcile 不认 skip"制度洞`
- [ ] PROGRESS 里程碑行(若表结构适配则加;不适配则跳过并在 handoff 声明)
- [ ] 验证:`grep -c check-meta-review harness/docs/ROADMAP.md` → 仅历史行命中(逐处人工判读:剩余命中均在已完成批次叙述行;活观察项零命中)
- [ ] commit:

```
docs(roadmap+trail): 治理同层化收口留痕——活观察项改名+治理批安全扫观察项登记+拐点append(批5)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 20:总 checkpoint —— M5 + 新制度首跑(方向评估 + V8 制度自证 + 覆写 + V4 + 账齐实证 + 完成报告)

**类型:** 流程 checkpoint(调度者执行;**步序为硬序,不得调换**——audit 落账先于基线件删除先于覆写先于 V4)
**Files:**
- Create: `harness/docs/audits/audit-<YYYY-MM-DD-HHMMSS>-governance-single-layer.md`(V8,新命名新文法首件)
- Delete: `harness/docs/active/2026-06-13-single-layer-baseline.md`(audit 吸收后)
- Modify: `harness/docs/active/handoff.md`(经 /structured-handoff 覆写——件 35,新术语)

**步骤(硬序):**

- [ ] **1. Evidence Depth 声明**(handoff 治理列填法,credentials-rules §7;证据位置带具体路径):
  - L1 ✅ V1 fixture 先红后绿(任务 5,PASS=10)
  - L2 ✅ V3 装机断言(任务 8/18)+ V5 双写比对(任务 18)
  - L3 ⏳ 本任务步 4 产 audit 后改 ✅(audit 文件名)
  - L4 ✅ V2/V7 全窗对照归因(任务 9,登记簿)——实战留痕起点
- [ ] **2. 安全扫描 / 流程审计**:治理批暂不纳入,留痕一行(引 finishing-rules「治理批收口工序适用」+ decision 追记三)——不跑,不算欠
- [ ] **3. 方向评估(治理批适用)**:运行 /evaluate(并行 fork 4 挑战者;synthesis-rules 事前/事后);verdict 按 finishing-rules 分流——`推翻` → 停,走「推翻」路径与用户讨论;`精磨`/`通过` → 继续
- [ ] **4. 治理审查 fork + V8 audit 落账(新制度首跑——decision「后续」节明令的制度自证)**:
  - 按 review-rules「审查维度选择表」治理行:bootstrap 4 维(核心原则合规/目的达成度/副作用/scope 漂移,禁删减)+ **触点完整性维必选**(本批命中产出/消费契约+跨文件计数+分发链三触发);N 建议 3-4(主题复杂度高;单 prompt 64 kB 软上限,超限拆多轮 fork);模板用 design-review SKILL 自带对抗式 A/B/C(批 3 已内嵌)
  - audit 文件:`docs/audits/audit-<时刻>-governance-single-layer.md`,frontmatter `audit: true` + covers;**covers = 批 1-5 全部 commit 的 name-only 并集机械汇编(不靠记忆)**,逐字命令:

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
BASE=<登记簿「批 1 首个实施 commit」hash>
git log --name-only --format= ${BASE}^..HEAD | sort -u | grep -v '^$' \
  | sed -e 's#^harness/##' -e 's#^AGENTS\.md$#<root>/AGENTS.md#' -e 's#^CLAUDE\.md$#<root>/CLAUDE.md#'
# 输出逐行进 covers(含被删件与 21 件迁移凭证——写侧契约"实际覆盖文件";根级件经 <root>/ sentinel)
```

  - 批 2 对照转入手工留痕的**洗活欠账**(登记簿「洗活欠账归因」节):逐件并入本 audit covers(吸收)或按维度表补审——audit「## 1. 元信息」写明吸收声明
  - 正文 5 段结构(credentials-rules §3);「## 3. 挑战者执行记录」按任务级结论登记簿行文法逐任务一行
  - verdict 处置:needs-revision → 修后重审(可产新 audit);overturn → 撤回本批,记录 ROADMAP/handoff,停
  - audit commit(此后默认对账窗恢复,G3 纪律解除):

```
docs(audits): 治理同层化批1-5审查凭证——新命名audit-*新文法audit:true首件,covers机械汇编(V8制度自证)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

- [ ] **5. 基线登记簿收尾**:`git rm harness/docs/active/2026-06-13-single-layer-baseline.md`(内容已被 V8 audit 与归因记录吸收;**必须在 V4 之前**——本件含旧工具名,不删则 V4 必红)+ commit
- [ ] **6. M5「通过」分流既有步骤**:milestone commit(`milestone: 治理同层化(凭证参数化) 验收通过`)/ decision-trail 已 append(任务 19)/ PROGRESS 已更(任务 19)/ ROADMAP 已更(任务 19,新增 step 9 义务即此)/ memory/project_harness_overview.md 结构性变化同步(新增 step 10 义务:双轨→单层、meta-review 角色行→治理审查)/ decisions/2026-06-13 文件标注关联 commit hash
- [ ] **7. /structured-handoff 覆写台账(件 35)**:走晋升门禁四步(归档→清账→覆写→自查);覆写后的台账用**新术语**(对账命令第 3 条 = check-audit-coverage;Evidence Depth 治理列话术;九术语零残留);promotion 按文法落
- [ ] **8. V4 断链核(必须在覆写之后跑,逐字命令 = spec §7.4):**

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
git grep -l -E "meta-finishing-rules|meta-review-rules|meta-scope\.conf|check-meta-review|check-meta-cross-ref|meta-review: skipped|meta-cross-ref: skipped|scope=meta|meta-L[1-4]" -- . \
  ':!harness/docs/audits' ':!harness/docs/completed' ':!harness/docs/decisions' \
  ':!harness/docs/decision-trail.md' ':!harness/docs/PROGRESS.md' ':!harness/docs/ROADMAP.md' \
  ':!harness/docs/superpowers/plans' ':!harness/docs/superpowers/specs' \
  ':!harness/docs/references/2026-*' ':!harness/docs/active/design-review-result.md'
```

  预期输出:**空**(活层零命中)。非空 → 逐件处置:活层漏改 → 回对应批任务补改 + 修订 audit(或 exempt);考古误入活层目录 → 报告调度者裁决。排除口径与 spec §7.3 考古清单同源(膨胀风险已登记 spec §10.2-e)
- [ ] **9. 对账账齐实证(开场三命令默认窗,下一会话验收者视角预演):**

```bash
cd /d/个人/harness && export LC_ALL=C.UTF-8
bash harness/.claude/hooks/check-handoff.sh --reconcile; echo "exit=$?"          # 期望 0
echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh; echo "exit=$?"   # 期望 0
bash harness/.claude/hooks/check-audit-coverage.sh --reconcile; echo "exit=$?"   # 期望 0 + 账齐行(窗锚=V8 audit)
```

  账齐输出即制度运转的第一个实证,留痕 handoff
- [ ] **10. 完成报告 + 挨个审查邀请(用户既有偏好,沿 2026-06-11 批同款义务)**:向用户提交完成报告与逐件审查清单——三件套(finishing/review/credentials)/ credentials.conf / check-audit-coverage.sh / V8 audit / 地图五处(AGENTS×2/M3/M4/QUICKREF+README)/ 四 SKILL 模板 / 21 件迁移对照归因记录(V8 audit 内)/ ROADMAP 观察项——邀请用户挨个审查

---

# 执行顺序总览

```
前置:   计划入库 + 工作树收口(调度者)
批 1:   任务 1(基线,第一动作) → 2(契约:credentials-rules) → 3(小checkpoint)
批 2:   任务 4(契约:conf,暂存) → 5(工具改造+V1,暂存) → 6(21件迁移,暂存)
        → 7(契约:命令行三处+cross-ref删除 → 原子commit) → 8(setup.sh+V3首跑) → 9(小checkpoint:V2/V7对照归因,含abort条款)
批 3:   任务 10(finishing-rules) → 11(review-rules) → 12(四SKILL) → 13(contracts-locked注记) → 14(小checkpoint:V9+互引核)
批 4:   任务 15(M3+M4) → 16(QUICKREF/README×2/AGENTS硬规矩/spec注记) → 17(清扫15件) → 18(末位git rm M1/M2 + 小checkpoint:V3复跑+V5+V6)
批 5:   任务 19(ROADMAP/trail/PROGRESS) → 20(总checkpoint:Evidence Depth → 方向评估 → V8 audit → 基线件git rm → M5通过步 → /structured-handoff覆写 → V4 → 账齐实证 → 完成报告+挨个审查邀请)
```

任务总数 20(契约 8:任务 2/4/7/11/12/13/15/16;实现 5:任务 5/6/8/10/17;流程(基线+checkpoint)6:任务 1/3/9/14/18/20;留痕 1:任务 19)。批内顺序与批间顺序均为硬序(spec §9 修订后批序,不得自行变更;若合批执行,验证项不得合并省略)。

## V 系九项验证落位表(spec §8.3 逐项)

| V | 验证 | 落位任务 | 形式 |
|---|---|---|---|
| V1 | 工具 fixture(双前缀/exempt/conf 两字段/锚竞选排除) | 任务 5 | 先红后绿(治理 L1) |
| V2 | 字段迁移核 + 全窗对照(modulo 预期 delta,abort 条款) | 任务 6(静态)+ 9(对照) | 脚本断言 + 实跑留痕 |
| V3 | 装机 fixture | 任务 8(首跑)+ 18(复跑全断言) | 脚本断言(治理 L2) |
| V4 | 断链核 grep(活层零命中) | 任务 20 步 8(覆写后) | grep 断言 |
| V5 | 双写比对(conf ↔ §2 人读表) | 任务 18 | diff 断言 |
| V6 | 地图链走查(七入口 ≤3 步) | 任务 18 | 人工核 + handoff 声明 |
| V7 | 真仓库对账账齐实证(与 V2 同协议) | 任务 9 | 实跑留痕 |
| V8 | 制度自证(新工具核出本批自己的新命名 audit) | 任务 20 步 4/9 | 实跑留痕(治理 L3+L4 起点) |
| V9 | 逐字迁移保真核(11 对 diff + SKILL 模板正向在场) | 任务 14 | diff + grep 断言 |

## 计划自查(planning-rules 义务)

**1. spec 覆盖核(§2-§9 每节有任务落点):**

| spec 节 | 落点 |
|---|---|
| §2.1 finishing-rules 改造 | 任务 10 |
| §2.2 / §2.2.2 / §2.2.3 review-rules + 维度表 + 触点维 | 任务 11 |
| §2.2.4 四 SKILL 模板 | 任务 12 |
| §2.3 credentials-rules 八节骨架 | 任务 2 |
| §2.4 exempt 文法 + 解析器兼容 | 任务 2(§4 节)+ 任务 5(extract_verdict/F2/F8) |
| §3 credentials.conf 设计/草案/对照/消费者 | 任务 4(草案逐字)+ 5(消费者) |
| §4.1 工具十一点改造 + §4.1-10 迁移协议 | 任务 5 + 6 + 9(G2/G3) |
| §4.1.7 分发与接线裁决 | 任务 8(settings 模板零改断言) |
| §4.2 cross-ref 删除 | 任务 7 |
| §4.3 setup.sh 四点 | 任务 8 |
| §4.4 settings/无关 hook 零改 | 任务 5(I3 断言)+ 8(jq 断言)+ 17(注释例外) |
| §5.1 AGENTS×2 | 任务 7(①②命令行成对)+ 16(③硬规矩) |
| §5.2 M3 | 任务 7(开场规程)+ 15(三节删除/单表/角色行/提法) |
| §5.3 M4 | 任务 15 |
| §5.4 QUICKREF+README×2 | 任务 16 |
| §5.5 上下文层 spec 注记 | 任务 16 |
| §5.6 走查表 | 任务 18(V6) |
| §6.1 退役注记 | 任务 13 |
| §6.2 残余双端守法 | 任务 5(对 2/3/4 的 fixture)+ 14(对 6 互引核)+ 对 1/5/7/8 零碰声明(I2/I3/I5) |
| §6.3 C1-C5 后继 | 任务 13(注记内逐契约) |
| §7.1 改 36 件 | 件 1(任务 7/15)件 2(7/16)件 3-4(16)件 5(15)件 6(16)件 7(7/16)件 8(17)件 9(8)件 10(5)件 11(7)件 12(4)件 13-15(17)件 16(10)件 17(11)件 18-23(17,其中 19-23 agents)件 24-27(12)件 28(17)件 29-32(17)件 33(16)件 34(13)件 35(20 覆写)件 36(19) |
| §7.2 删 2 件 | 任务 18 |
| §7.3 不动 63 件 | 全计划禁触声明(文件结构总图末行)+ V4 排除口径同源 |
| §7.4 断链核 | 任务 20 步 8(命令逐字) |
| §8.1 不变量 I1-I8 | I1(任务 5/6)I2(17 件 13/15 注释例外+逻辑零碰)I3(任务 5/17 断言)I4(任务 2 §7 声明)I5(任务 2/5 零改)I6(任务 10/11 逐字迁移+件 29 仅一词)I7(任务 8 graceful)I8(任务 5 第 9 点零改) |
| §8.2 错误处理 8 情形 | 任务 5(F3/F4/F6/F9)+ 6(半途中断=幂等重跑)+ 8(conf 缺失=老下游 I7)+ G3(改名过渡=批序耦合) |
| §8.3 V1-V9 | 上方落位表逐项 |
| §9 五批批序/同批不可拆/过渡窗 | 批结构 + G6 + 各批耦合注 |
| §10 残余风险 | G6(h)+ 任务 19(i 观察项)+ V4 排除注(e)+ 计划内裁量(a-g 各处如实声明) |

**2. 无占位符声明:** 全计划无 `[待填]`/`[TODO]`/TBD;方括号留白仅两类——audit 时间戳 `<YYYY-MM-DD-HHMMSS>`(执行时刻生成)与 `<登记簿字段>` 回填指代(执行期实值),均非占位符。

**3. 类型一致:** 任务类型 ∈ {契约任务(指令式逐字),实现任务(问题+约束+fixture+先红后绿),流程 checkpoint,留痕任务};契约任务先于其消费实现任务(任务 2 先于全部指针、任务 4 先于任务 5 fixture、任务 11 先于任务 12 权威指针);逐字块均标注 spec 出处;G1-G7 被引用处不变体。

**4. 架构合规:** 本计划不触 src 分层(无代码模块);文件路径全部符合仓库现行布局(governance/hooks/skills/agents/templates/docs 既有目录,无新目录);模块 README 义务 G7 声明。

**5. 反模式约束(planning-rules 硬编码)遵守:** 不造 artificial trial——V8/V4/账齐均为真实仓库实跑留痕,exempt 抽查/治理批安全扫等实战项推 ROADMAP 观察项(任务 19),不阻塞本批。


# 上下文层 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地模型无关的上下文/知识/交接层——工作台(handoff v2 + 晋升门禁)与书架(目录卡登记)两层分开、覆写前必清账,按 spec §8.4 批 0 / 1a-1d / 会话链自执法批(原 hook 上岗批,2026-06-11 C 案取代)逐批实施。

**Architecture:** 两层结构:工作台台账(`docs/active/handoff.md`,路径不动)只放状态+指针,知识住书架九格(逻辑映射现有住址,零搬家)。覆写台账唯一正路是 structured-handoff SKILL v2 固定序(归档→清账→覆写→自查);check-handoff.sh v2 在覆写信号(最新归档件 mtime 60 分钟窗)硬核 promotion 凭证+锚点抽查+登记交叉核;check-shelf-registry.sh 每 Stop 软扫落库登记。批次:批 0(3 件 bugfix)→ 批 1a 工作台与门禁 → 1b 书架登记 → 1c 入口与偏好 → 1d 分发与 scope → 会话链自执法批(开场对账;原 hook 上岗 A/B 分支被 C 案取代,见 `docs/decisions/2026-06-11-session-chain-reconciliation.md`);每批收尾 meta finishing(M1 四步 + meta-review)。

**Tech Stack:** bash(POSIX,禁 gawk 扩展)+ markdown 纯文件约定 + Claude Code hooks/skills(增强层;地基纯文件+可手工跑脚本+git)

**锁定 spec(唯一权威源):** `harness/docs/superpowers/specs/2026-06-10-context-layer-design.md`(872 行,已锁定 2026-06-11)
**审查留痕:** `harness/docs/active/design-review-result.md`(R1-R7 全修复;计划中对曾出问题的点给对应验证,见各任务「审查回归点」)

---

## 待回设计清单(1 条,已清零)

> 规则:计划不静默偏离 spec;下列点必须回设计裁决后,对应任务才能继续。

1. **已回设计修正(2026-06-11):SETUP_NEEDED 改提示不中断,见 spec 头部微修正留痕与 §8.0 #1。**
   - 发现过程留痕(planner 实测 grep 核对):自仓库 `harness/docs/RUBRIC.md:64` / `harness/docs/ARCHITECTURE.md:69-73` 含模板占位符(spec §1.6 已声明事实),`session-init.sh:13-29` 的 SETUP_NEEDED 检测命中任一即打印提示后 `exit 0`,台账段永不注入——自仓库剖面恒命中(场景 1 P0 失效),下游未配置期同病;spec §8.0 #1 原「其余注入行为不动」未枚举此交互。
   - 落地:任务 8 约束与 fixture 已同步(改"提示不中断");任务 20 的该项硬停点已移除(其 A/B 用户拍板停点于 2026-06-11 随 C 案取消,见 decisions/2026-06-11-session-chain-reconciliation.md)。

## 计划内裁量(非偏离,留痕备审)

1. **SKILL v2 的 `!cat` 模板注入行带双层 fallback**(`cat A 2>/dev/null || cat harness/A`):spec D9 定「全部相关脚本双层探测」,SKILL preamble 命令与 hook 同处运行时路径问题,同理适用;不加则根启动(手工/工具箱模式,C 案常态)下模板注入失效。
2. **references/README.md「当前留痕索引」节并入目录卡条目表后删除该节**:同文件同信息两份 = 双写,违反 SSoT(spec §4.4 规则 3);目录卡是登记的唯一载体(§4.1.7)。「维护」节措辞同步对齐 immutable 规则(过时加横幅不删改,§4.3.3/§4.4 规则 1)。
3. **M3(根 CLAUDE.md)无既有「文档索引」表**:spec §8.1「文档索引加 AGENTS.md/preferences 地图行」的落点定为 M3 新增一个两行小节(任务 15 给精确内容),不新建大表。
4. **session-init.sh + check-evidence-depth.sh 的小改归入批 1a 任务分组**:spec §8.4 批 1 内序未逐件分配这两件,按"hook 类聚合、双层 fixture 同款"归 1a。
5. **settings 双轨接线(§8.0 #9)落在批 1d**(任务 17),满足 B10「目录卡回填(1b)先于接线」顺序;批 1b 的 check-shelf-registry.sh 创建后先以手工模式测试,不接线。
6. **owner 头取舍**:spec §4.4 规则 4 要求新建 evolving 文件落 `<!-- owner: ...; last-reviewed: ... -->` 头,但 §4.1.5 AGENTS.md 骨架(更具体的内容定义)不含 owner 行——按骨架逐字执行(AGENTS.md ×2 不加),preferences.md 按 §4.1.6 含 owner 行;owner 头本批无机器消费方(到期提醒机器化推后),meta-review 若判须补,加一行注释即可且不触共享核。

## 批次与 scope 表

| 批 | 任务 | 触碰组别(M17 对照) | scope 判定 | 审查收尾 |
|---|---|---|---|---|
| 批 0(bugfix) | 任务 1-2 | F(setup.sh)+ C(SKILL.md) | **meta** | 任务 3 checkpoint(M1 四步 + meta-review) |
| 批 1a 工作台与门禁 | 任务 4-8 | C(SKILL+捆绑模板)+ B(hooks)+ A(governance 触点) | meta | 并入任务 19(批 1 整批收尾,spec §8.4:1a-1d 是批内顺序非独立批) |
| 批 1b 书架登记 | 任务 9-11 | B(新 hook)+ C(agents)+ 文档(references/README) | meta(任一命中即 meta) | 并入任务 19 |
| 批 1c 入口与偏好 | 任务 12-15 | A(AGENTS.md / preferences / CLAUDE.md ×2) | meta | 并入任务 19 |
| 批 1d 分发与 scope | 任务 16-18 | B(conf/settings)+ F(setup.sh/templates)+ A(M3 同步) | meta | 任务 19 checkpoint(M1 四步 + meta-review) |
| 会话链自执法批(C 案,取代原 hook 上岗 A/B) | 任务 20-22 | A(CLAUDE.md×2 + AGENTS.md)+ B(check-meta-review.sh)+ F(templates/AGENTS.md) | meta | 任务 23 checkpoint(M1 四步 + meta-review) |

> 批 2(口子 B 任务出生证)/ 批 3(口子 C)**不在本计划**(另案;spec §8.4 行仅声明依赖关系)。

## 文件结构总图(全部 Create / Modify / Delete,对齐 spec §8.0 / §8.1)

**Create:**

| 文件 | 任务 | 说明 |
|---|---|---|
| `harness/.claude/skills/structured-handoff/handoff-template.md` | 4 | 台账模板 v2 单源(D3,skill 捆绑资源) |
| `harness/.claude/hooks/check-shelf-registry.sh` | 10 | 书架登记软扫(I5) |
| `harness/templates/AGENTS.md` | 12 | 下游入口地图模板(I7 分发) |
| `AGENTS.md`(仓库根) | 13 | 自仓库剖面入口地图(§4.1.5 根版差异 ①-⑤) |
| `harness/docs/preferences.md` | 14 | 偏好层(D11:不分发下游;用户逐条拍板) |
| ~~`.claude/settings.json`(仓库根,A 案条件件)~~ | ~~21~~ | **已取消**(2026-06-11 C 案取代 A/B,不做根级接线) |

**Modify:**

| 文件 | 任务 | 说明 |
|---|---|---|
| `harness/setup.sh` | 1, 18 | 批 0:活 handoff 守卫;批 1d:cp 清单 + 初始台账改源(I7) |
| `harness/.claude/skills/structured-handoff/SKILL.md` | 2, 5 | 批 0:死条件+分叉文本;批 1a:重写为晋升门禁 v2 |
| `harness/.claude/hooks/check-handoff.sh` | 6 | 重写:工作台闸 I4(§8.0 #2 职责挪) |
| `harness/docs/governance/finishing-rules.md` | 7 | 三处 /structured-handoff 调用点加一句引用 |
| `harness/docs/governance/meta-finishing-rules.md` | 7 | Step D 加一句引用 |
| `harness/.claude/hooks/session-init.sh` | 8 | 双层探测 + 入口地图行(§8.0 #1) |
| `harness/.claude/hooks/check-evidence-depth.sh` | 8 | 仅补双层探测(§8.0 #3) |
| `harness/docs/references/README.md` | 9 | 升级目录卡:规矩头 + 条目表 + 存量回填 8 件(§4.1.7) |
| `harness/.claude/agents/research-scout.md` | 11 | 产出整形红线追加同批登记行(I6 层①) |
| `harness/templates/AGENTS.md` 与根 `AGENTS.md` 双写核 | 12,13,21 | 共享核(接手顺序/硬规矩引用/九格表结构)同批改义务(§4.1.5);任务 21 加开场对账行 |
| `CLAUDE.md`(仓库根 M3) | 15, 16, 21 | 批 1c:地图行小节;批 1d:§3/§5 scope 表随 conf 同步(M3↔M17);任务 21:会话开场规程小节 |
| `harness/CLAUDE.md`(M4) | 15, 21 | 文档索引加 AGENTS.md 行;交接行注门禁(preferences 行**不加**,D11);任务 21:核心规则第 11 条 |
| `harness/.claude/hooks/meta-scope.conf` | 16 | 补 glob 四处(§8.0 #8) |
| `harness/.claude/settings.json` | 17 | Stop 数组 + check-shelf-registry.sh |
| `harness/templates/settings.json` | 17 | 同上(M19 下游双轨同批) |
| `harness/docs/ROADMAP.md` | 3, 19, 22, 23 | checkpoint 内 M1 Step D 义务;任务 22 方向变更留痕 |
| ~~`.gitignore`(仓库根,A 案条件件)~~ | ~~21~~ | **已取消**(2026-06-11 C 案,同上) |
| `harness/.claude/hooks/check-meta-review.sh` | 20 | 对账模式 `--reconcile`(C 案,审计覆盖核可执行化) |
| `harness/docs/superpowers/specs/2026-06-10-context-layer-design.md`(仅状态头) | 22 | 方向变更注记(C 案取代 §8.4 接线行与 D9 分叉) |

**Delete:**

| 文件 | 任务 | 说明 |
|---|---|---|
| `harness/templates/handoff.md` | 18 | D3 单源化;setup.sh 同批改引用(消费方已清点:setup.sh:106 + SKILL:33,前者本任务改、后者批 1a 已重写) |

**不动但验证兼容(spec §8.2,验证步分布在任务 4/5/6/19):** `check-context-chain.sh` / `check-meta-cross-ref.sh` / `check-module-docs.sh`(`check-meta-review.sh` 原列此处,2026-06-11 改为任务 20 Modify 对象——对账模式)、`docs/active/handoff.md` 的 95 处引用(2026-06-11 grep 实数;spec 写 85 处为当时计数)、`docs/completed/` 归档文件名惯例、evaluate / process-audit / security-scan skills。

## 全局契约(C1-C7,后续任务逐字引用,不得变体)

> 来源:spec §4.1.x / §3.1 / D17。**半角纪律**:所有 marker 与文法 token(`[ ] : ; , ( ) ->`)一律半角;全角 = 文法不命中 = 按未做处理。

### C1 promotion 声明文法(spec §4.1.4 逐字)

```
promotion: 未核
promotion: 已核(上架: <路径>[, <路径>]... ; 弃置: <N> 条)        # 上架段可为字面 "无"
promotion: 已核(上架: 无; 弃置: 0 条)                            # 空账合法形:当且仅当暂存区为 "- 无"(空账=清白,非顺延)
promotion: skipped(理由: <非空>; 回收: <归档件路径>)              # 仅用于暂存有条目且顺延(回收点必填);空账不用 skipped
promotion: 阻塞(理由: <非空>)                                    # 合法中间态,非终态
```

hook 整行校验(POSIX ERE,逐字):

```
^promotion: (未核|已核\(上架: [^;]+; 弃置: [0-9]+ 条\)|skipped\(理由: [^;]+; 回收: [^)]+\)|阻塞\(理由: [^)]+\))$
```

锚点抽查规则(已核):上架段按 `, ` 切分;每路径 `test -f && test -s`;路径前缀含 `references/` → 再 `grep -F 文件名` 于目录卡(路径为无日期前缀标准件 → 不要求目录卡行,豁免见 C3);上架段为字面 `无` 时跳过锚点抽查;空账形 `已核(上架: 无; 弃置: 0 条)` 当且仅当最新归档件暂存区为 `- 无` 才合法,否则 exit 2「暂存有条目却记零账」;弃置 ≥1 = 全弃置,合法;归档件无 `## 待晋升暂存` 节(旧格式,B9)→ 视同 `- 无`(向后兼容)。skipped:理由空白或回收点路径不存在 → exit 2。阻塞:理由非空 → exit 0 + stderr「清账阻塞/待拍板中」(60 分钟窗内合法中间态);理由空白 → exit 2。

### C2 暂存条目与指针行文法(spec §4.1.2 / §4.1.1)

```
暂存行: - [<类型>] <一句话说明>(<细节锚点:文件/会话位置,可省>)
        类型 ∈ {决策, 经验, 调研, 参考, 偏好}(路由键,§4.1.3;机器不解析类型,暂存区内容 ≠ "- 无" 即"有账")
指针行: - -> 路径 — 为什么读
路径基准: 台账内锚点/指针统一写 docs/... 相对路径(两剖面同形,hook cd 进 WORK_DIR 后解析,§8.3)
```

### C3 目录卡(表头 + 行文法 + 最小模板,spec §4.1.7 / I5 / I6 同形)

规矩头一行(目录卡节标题,**与 I5 stderr 内嵌模板逐字同形**):

```
## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)
```

表头(逐字):

```
| 日期 | 文件 | 一句话 | 核验等级 |
|---|---|---|---|
```

行文法:`| <日期 YYYY-MM-DD> | <文件> | <一句话> | <核验等级或"—"> |`

类型声明约定:文件名带日期前缀(`YYYY-MM-DD-*.md` / `*.html`)= 调研留痕(immutable,须登记);无日期前缀 = 标准件(evolving,owner 保鲜,**豁免登记**,发现链走地图行)。README 自身不算留痕件。

### C4 preferences 条目文法(spec §4.1.6)

```
- [YYYY-MM-DD] <偏好一句话>(原话: "<用户原话引录>"[; 来源: <feedback 文件名>])
```

日期 + 用户原话引录**必填**(忠实性审查锚点,D11 精确化①)。

### C5 双层探测样板(M15 范式,D17:每脚本自含不抽象,约 6 行)

```bash
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
if   [ -d "$PROJECT_DIR/harness/docs" ]; then WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/docs" ];         then WORK_DIR="$PROJECT_DIR"
else exit 0; fi   # 两层都无 docs/ → 不在场,放行(check-* 语义)
cd "$WORK_DIR" 2>/dev/null || exit 0
```

session-init 例外:无 docs/ 不退出(它对空项目也注入引导),`else WORK_DIR="$PROJECT_DIR"; fi` 继续。

### C6 手工模式契约(spec §3.2,场景 4 不空转)

stdin 为空对象 `{}` 或解析失败 → hook **不得静默 exit 0**,继续执行全部检查。降级协议(stderr 一行 + exit 0)**仅**适用于环境工具缺失(jq/grep 不在场)。手工命令形态全文统一:`echo '{}' | bash .claude/hooks/check-X.sh`。`stop_hook_active=true` 安全带照旧(防死循环,先于一切)。

### C7 fixture 通用跑法(沿仓库 9 场景 fixture 先例:bash 临时脚本 + 模拟文件树,跑完即弃不入仓)

- 每个 hook 任务:**fixture 脚本先写、对当前(旧)实现跑一遍确认红**(新场景失败),再实现,再跑全绿。
- fixture 树自带 `git init`(spec §6.2:git 不 mock);mtime 用 `touch -d "<N> minutes/hours ago"` 拨。
- 断言:exit code 为硬断言;stderr 子串为辅助断言(spec 要求 stderr = 哪条不合+怎么修)。

**commit 规范(仓库惯例):** 中文,`type(scope): 描述` 前缀,正文可省;结尾固定行:

```
Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

**模块 README 义务说明:** 本计划触碰件均为治理/skill/hook/模板/文档件,无 src 代码模块,无 MODULE_DOC_TEMPLATE 义务;`references/README.md` 与 `AGENTS.md` 本身就是改动对象。涉及模块标注用 spec §2.1 的 M-A…M-H。

---

# 批 0:纯 bugfix(3 件,照修不待裁决;spec §8.4 批 0)

## 任务 1:setup.sh 活 handoff 覆盖守卫(批 0 ①)

**类型:** 实现任务(单点 bugfix,修法明确)
**模块:** M-H(分发与同步)
**Files:**
- Modify: `harness/setup.sh`(:106)

**问题:** `setup.sh:106` 无条件 `cp templates/handoff.md → <target>/docs/active/`,重跑安装会覆灭目标项目的活交接文档(I7 指认的 bug)。

**约束:**
- 仅加存在性守卫,**不**在本批改源(初始台账改源自 handoff-template.md 是批 1d 任务 18 的事,spec §8.4 批次切分)。
- 沿用 setup.sh 既有 `|| true` 风格(I7:活文件必须存在性守卫)。

**步骤:**

- [ ] 写 fixture 并跑红(当前行为 = 覆盖):

```bash
cd /d/个人/harness/harness
T=$(mktemp -d)
./setup.sh "$T" > /dev/null
echo "LIVE-MARKER" >> "$T/docs/active/handoff.md"
echo y | ./setup.sh "$T" > /dev/null
grep -q "LIVE-MARKER" "$T/docs/active/handoff.md" && echo "PASS 守卫生效" || echo "FAIL 活 handoff 被覆盖"
rm -rf "$T"
```

期望(修复前):`FAIL 活 handoff 被覆盖`

- [ ] 把 `harness/setup.sh:106` 这一行:

```bash
cp "$SCRIPT_DIR/templates/handoff.md" "$TARGET_DIR/docs/active/" 2>/dev/null || true
```

替换为:

```bash
# 活文件守卫(I7):已有交接文档不覆盖 — 重跑安装不得覆灭活 handoff
if [ ! -f "$TARGET_DIR/docs/active/handoff.md" ]; then
    cp "$SCRIPT_DIR/templates/handoff.md" "$TARGET_DIR/docs/active/handoff.md" 2>/dev/null || true
fi
```

- [ ] 重跑上述 fixture,期望:`PASS 守卫生效`;另确认全新安装仍产出 handoff(`T2=$(mktemp -d); ./setup.sh "$T2" >/dev/null; test -f "$T2/docs/active/handoff.md" && echo OK; rm -rf "$T2"` → `OK`)
- [ ] commit:

```
fix(setup): 活 handoff 存在性守卫 — 重跑安装不再覆盖交接文档(批0①)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 2:structured-handoff SKILL 死条件 + context-chain 行分叉对齐(批 0 ②③)

**类型:** 实现任务(两处单点 bugfix)
**模块:** M-B(晋升门禁,当前为旧版 SKILL)
**Files:**
- Modify: `harness/.claude/skills/structured-handoff/SKILL.md`(:33 与 :125)

**问题:**
- ② SKILL.md:33 归档条件写「包含"[待更新]"则视为初始模板」,但模板(templates/handoff.md)实际占位符是 `[待填]` —— 条件永不命中(死条件),初始模板会被误归档。
- ③ SKILL.md:125 的 context-chain 行与 templates/handoff.md:61 文本分叉(SKILL 版缺尾注「,见 finishing-rules 收口硬核链」)—— 双写分叉收敛(终态单源在批 1a,本批先对齐止血)。

**步骤:**

- [ ] 跑红(确认现状):`grep -c "待更新" harness/.claude/skills/structured-handoff/SKILL.md` → 期望 `1`(死条件在);`grep -F '见 finishing-rules 收口硬核链' harness/.claude/skills/structured-handoff/SKILL.md` → 期望无输出(分叉在)
- [ ] 修 ②:SKILL.md:33 的

```
如果 `docs/active/handoff.md` 内容不是初始模板（包含"[待更新]"则视为初始模板），将其归档：
```

改为:

```
如果 `docs/active/handoff.md` 内容不是初始模板（包含"[待填]"则视为初始模板），将其归档：
```

- [ ] 修 ③:SKILL.md:125 的

```
## context-chain: 待填(仅当项目用 docs/context/ 链;收口核完改 "已核(结论)" 或 "skipped(理由: ...)")
```

改为(与 templates/handoff.md:61 逐字一致):

```
## context-chain: 待填(仅当项目用 docs/context/ 链;收口核完改 "已核(结论)" 或 "skipped(理由: ...)",见 finishing-rules 收口硬核链)
```

- [ ] 验证:`grep -c "待更新" harness/.claude/skills/structured-handoff/SKILL.md` → `0`;提取两行比对一致:`diff <(sed -n '125p' harness/.claude/skills/structured-handoff/SKILL.md) <(sed -n '61p' harness/templates/handoff.md)` → 无输出
- [ ] commit:

```
fix(skills): structured-handoff 死条件[待更新]→[待填] + context-chain 行分叉对齐(批0②③)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 3:批 0 收尾 checkpoint —— M1 四步 + meta-review

**类型:** 流程 checkpoint(由调度者执行,不 fork 给 implementer;这是任务不是注脚)
**模块:** 治理流程(M1/M2)
**Files:**
- Modify: `harness/docs/ROADMAP.md`(状态推进)、`harness/docs/active/handoff.md`(流程产物)
- Create: `harness/docs/audits/meta-review-<timestamp>-context-layer-batch0.md`(meta-review 产物)

**步骤:**

- [ ] Step A(scope 判断):本批 diff = `setup.sh`(F 组)+ `.claude/skills/structured-handoff/SKILL.md`(C 组)→ **meta**,无分流争议
- [ ] Step B(meta-review):按 `harness/docs/governance/meta-review-rules.md`(M2)fork 挑战者审查本批改动;audit 文件 covers 字段列全:`setup.sh`、`.claude/skills/structured-handoff/SKILL.md`
- [ ] Step C(decision 立档):本批为照修 bugfix,预期无新增不确定决策;若审查中出新拐点按 M1 Step C 立档
- [ ] Step D(同步):ROADMAP「上下文层重构」节推进(批 0 完成);decision-trail 若有判断拐点则 append(无则跳过,M1 规则)
- [ ] 运行 `/structured-handoff` 更新台账(本批仍是旧版 SKILL,照旧流程)
- [ ] 确认 Stop 不被 check-meta-review.sh 阻断(audit covers 齐)后 commit:

```
docs(meta): 批0 finishing — bugfix 三件 meta-review 留痕 + ROADMAP 推进

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 批 1a:工作台与门禁(spec §8.4 批 1 内序第一段)

## 任务 4:契约 —— 台账模板 v2 单源(handoff-template.md)

**类型:** 契约任务(指令式;本批所有后续任务的字段权威源,必须先行)
**模块:** M-A(工作台台账)
**Files:**
- Create: `harness/.claude/skills/structured-handoff/handoff-template.md`

**操作:** 按 spec §4.1.1 逐字创建以下文件(全文,一字不改;skill 捆绑资源 = 模板单源,D3):

```markdown
# 工作台台账(handoff)

> 工作台只放状态和指针,知识住书架(找书:先指针,后目录卡 references/README.md)。
> 覆写本文件只走 /structured-handoff(晋升门禁);入口地图:AGENTS.md / CLAUDE.md。

更新时间: [待填]
当前阶段: [待填]
当前分支: [待填]

## 目标

[待填]

## 进度

### 已完成
- 无

### 进行中
- 无

### 阻塞
无

## 下一步

1. [待填]

## 待晋升暂存

<!-- 本会话出生、还没上架的有价值内容;一行一条,文法见行内示例;覆写前必须清账 -->
<!-- 文法: - [决策|经验|调研|参考|偏好] 一句话(细节在哪) -->
- 无

## 指针

<!-- 接手要读的书;只指不抄。文法: - -> 路径 — 为什么读 -->
- 无

## 关键上下文

<!-- 只放"不记就丢"的具体值(错误信息/端口/版本/环境变量名);能指书架就写指针 -->
[待填]

## 已知问题

无

## 晋升声明

promotion: 未核

## Evidence Depth
- L1 单元测试: [待填]
- L2 冒烟测试: [待填]
- L3 自动化 API 测试: [待填]
- L4 用户行为模拟: [待填]

## CI 阻断
[待填]

## context-chain: 待填(仅当项目用 docs/context/ 链;收口核完改 "已核(结论)" 或 "skipped(理由: ...)",见 finishing-rules 收口硬核链)
```

**依据:** spec §4.1.1(模板全文)+ §3.3(字段契约表)+ 初值规则「空白即未做」(`promotion: 未核` / `- 无` / `[待填]` 全部显式初值,不存在"没写=默认通过")。

**步骤:**

- [ ] 创建上述文件(逐字)
- [ ] 验证字段齐全(hook 契约字段一律在场,spec §3.3 / §8.2 兼容):

```bash
cd /d/个人/harness/harness
F=.claude/skills/structured-handoff/handoff-template.md
for m in "## 待晋升暂存" "## 指针" "promotion: 未核" "## Evidence Depth" "## CI 阻断" "## context-chain:" "更新时间:" "当前阶段:" "当前分支:"; do
  grep -qF "$m" "$F" && echo "OK $m" || echo "MISSING $m"
done
wc -l < "$F"   # 期望 ≤ 80
```

期望:9 行 `OK`,行数 ≤ 80

- [ ] 验证半角纪律:`grep -nE '[（）：；]' "$F"` 仅允许命中纯散文注释行(机读 marker 行 — promotion/context-chain/表头 — 不得含全角 token);期望 promotion 行与 context-chain 行无命中
- [ ] 验证已删字段(spec §4.1.1 字段 diff:`## 关键决策` 与 `## 涉及文件` 被吸收/删除):`grep -cE '^## (关键决策|涉及文件)' "$F"` → `0`
- [ ] commit:

```
feat(skills): handoff 模板 v2 单源(skill 捆绑资源)— 台账字段契约落地(批1a)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 5:structured-handoff SKILL v2 重写(晋升门禁本体)

**类型:** 实现任务(问题式)
**模块:** M-B(晋升门禁)
**Files:**
- Modify: `harness/.claude/skills/structured-handoff/SKILL.md`(重写)

**问题:** 旧 SKILL 是"自由收集→按内嵌模板覆写",存在双写烂账(内嵌模板 :60-126 与 templates/handoff.md 两份);且覆写前没有清账动作——工作台上有价值的东西可以被无声覆灭。重写为**晋升门禁**:覆写工作台的唯一正路,先清账后覆写。

**约束(全部来自锁定 spec,违反任一条即返工):**

1. **执行流程 = I3 固定序,逐步不可换序**(spec §3.1 I3):
   - ① 归档:`mkdir -p docs/completed && cp docs/active/handoff.md "docs/completed/handoff-$(date +%Y%m%d-%H%M%S).md"`(文件名格式与旧版**逐字同形**——`handoff-YYYYmmdd-HHMMSS.md`,spec §8.2 归档惯例兼容;completed/ 不存在则 mkdir -p,B4)。归档即"覆写信号",被 check-handoff.sh 消费——SKILL 文本须向执行者声明这点。
   - ② 清账:对台账「待晋升暂存」区逐条裁决,四种:**上架 / 弃置 / 顺延 / 阻塞**(I2 + §4.3.1)。上架 → 写书架对应格(按下方路由表)+ 同批登记(references/ → 目录卡加行;decisions/ → 文件名即登记)+ 台账指针区加 `- -> 路径 — 一句话`。弃置 → 条目留在已归档的旧台账中,理由随归档件保全。顺延 → 整体走 skipped 态(理由 + 回收点 = 归档件路径)。阻塞 → 中止覆写,**当场**把台账 promotion 行写为 `阻塞(理由: <非空>)`、其余原状(归档已完成不回滚——固定序①已点燃覆写信号)。书架写入失败 → 同阻塞路径,理由写 `写入失败待重试`(I2 错误处理)。
   - ③ 覆写:以 `!cat` 注入的模板单源(任务 4 文件)重写台账;promotion 字段按 C1 文法写为 `已核(...)` 或 `skipped(...)`;暂存区归零(`- 无`);空账(清账时暂存本来就是 `- 无`)写空账形 `已核(上架: 无; 弃置: 0 条)`。
   - ④ 自查:`wc -l ≤ 80`;超限砍序 = **先砍散文(关键上下文),指针与声明字段不砍**;砍尽散文仍超 → 允许超限 + stderr 声明超限原因(B8);正文无 `[待填]` 残留(新建台账除外)——spec §3.3「状态字段 SKILL 自查」的执行点即此。
2. **清账裁决依据写进 SKILL 文本**(执行 agent 可能不回读 spec):
   - 实质闸判定基准(§4.3.1 逐字):关键问题是什么 / 讨论到什么程度 / 有无影响下游的未决点 / 下游能否照此干活。松紧梯度:探索期(非收口覆写)倾向顺延合法;收口与高风险(治理/方向类条目)从严——方向/原则级列选项给用户拍板。
   - 蒸馏判据(§4.1.3):上架前一问「**下个功能还需要它吗?**」——否 → 弃置。事实/留痕级 AI 即办,方向/原则级用户拍板(不做自动晋升)。
   - B1 兜底一问(清账步必含):「本会话有无该暂存未暂存的内容?」
   - B3:预算枯竭(/clear 前上下文将满)**不逼回写**——走 skipped(理由+回收点),暂存随归档保全,下会话回收再裁决。
   - 晋升路由表(§4.1.3,SKILL 内须含此表):

   | 条目类型 | 书架格 | 上架住址 | 同批登记动作 |
   |---|---|---|---|
   | 决策 | 决策史 | `docs/decisions/YYYY-MM-DD-<slug>.md` | 文件名即卡;判断拐点另 append decision-trail(既有义务) |
   | 调研 / 参考 | 行业认知 | `docs/references/YYYY-MM-DD-<slug>.md` | 目录卡加行(I6) |
   | 经验(干活规矩级) | 干活规矩 | 对应 `docs/governance/*.md` | 命中 A 组 → 走 meta-review,**不得收口顺手直插**;允许「顺延」跨覆写(D16/B17) |
   | 经验(项目事实) | 系统真相 | ARCHITECTURE.md / 模块 README | 文档随码既有规矩 |
   | 偏好 | 用户偏好 | `docs/preferences.md` | 条目带日期+原话引录(C4);命中 A 组 → meta-review,用户原话直录可走 skip 字段轻路径(D11) |

   - 类型不在路由表(B14,如 `- [疑问]`):按实质闸归并到最近格或问用户,无硬故障。
3. **promotion 文法块(C1)写进 SKILL**(执行者照抄不凭记忆;与任务 4 模板、任务 6 hook 三处同名同文法——全链 `promotion:` 无别名)。
4. **模板注入单源化**(D3):删除旧 SKILL 内嵌模板(:60-126),改为 `!cat` 注入;带双层 fallback(计划内裁量 1),注入行精确形态:

```
!`cat .claude/skills/structured-handoff/handoff-template.md 2>/dev/null || cat harness/.claude/skills/structured-handoff/handoff-template.md 2>/dev/null || echo "(模板缺失: .claude/skills/structured-handoff/handoff-template.md)"`
```

   现有「当前交接文档」`!cat docs/active/handoff.md` 行同样补 `|| cat harness/docs/active/handoff.md` fallback。
5. **保留不动**:触发时机三条(finishing 三路 / 上下文快满 /clear 前 / 手动调用)、写入规则要点(具体优于概括 / 保留关键值 / 不写废话 / 不含敏感信息)、重跑幂等声明(再归档一份无害,I3 错误处理)。
6. frontmatter 精确内容:

```
---
name: structured-handoff
description: "结构化交接+晋升门禁。上下文快满或 finishing 阶段触发。覆写 handoff.md 的唯一正路:归档→清账(待晋升暂存逐条裁决:上架/弃置/顺延/阻塞)→按模板单源覆写→自查。"
---
```

7. 现有活台账(`harness/docs/active/handoff.md`)**不手工改造**——下次真实覆写经本 SKILL 自然迁移到 v2 结构(B9 同理)。

**验证标准(结构核,SKILL 流程的实质有效性按 spec §6.1 推人工演练/实战留痕,不造 artificial trial):**

- [ ] 重写 SKILL.md(满足上述全部约束)
- [ ] 结构核(全部按期望输出):

```bash
cd /d/个人/harness/harness
S=.claude/skills/structured-handoff/SKILL.md
grep -c "# 工作交接文档" "$S"                          # 期望 0(内嵌模板已删)
grep -cF "handoff-template.md" "$S"                    # 期望 ≥2(!cat 注入行含双层 fallback)
for w in 归档 清账 覆写 自查 上架 弃置 顺延 阻塞; do grep -qF "$w" "$S" && echo "OK $w"; done
grep -qF "下个功能还需要它吗" "$S" && echo OK-蒸馏判据
grep -qF "本会话有无该暂存未暂存的内容" "$S" && echo OK-B1
grep -qF 'handoff-$(date +%Y%m%d-%H%M%S).md' "$S" && echo OK-归档文件名
grep -qF "promotion: 未核" "$S" && echo OK-文法块
grep -cE '^## (关键决策|涉及文件)' "$S"                 # 期望 0(被删字段不再出现)
```

- [ ] 8.2 兼容核(被删字段无下游消费):`grep -n "关键决策\|涉及文件" .claude/skills/evaluate/SKILL.md .claude/skills/process-audit/SKILL.md .claude/skills/security-scan/SKILL.md` → 期望无字段级依赖(若命中,人工判读是否依赖 handoff 的这两个节;有则停,报告调度者——这是 spec §8.2 承诺的验证)
- [ ] 审查回归点(design-review 共识 2/3:空暂存死状态、阻塞态生命周期曾是 🔴):确认 SKILL 文本含空账形 `已核(上架: 无; 弃置: 0 条)` 写法与「阻塞→当场写阻塞行、归档不回滚」段落:`grep -qF '已核(上架: 无; 弃置: 0 条)' "$S" && echo OK-空账形; grep -qF "阻塞(理由:" "$S" && echo OK-阻塞态`
- [ ] commit:

```
feat(skills): structured-handoff SKILL v2 — 晋升门禁(归档→清账→覆写→自查,模板单源注入)(批1a)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 6:check-handoff.sh v2 重写(工作台闸 I4)

**类型:** 实现任务(问题式)
**模块:** M-C(工作台闸)
**Files:**
- Modify: `harness/.claude/hooks/check-handoff.sh`(重写,§8.0 #2 职责挪)

**问题:** 旧 hook 只查存在性 + 10 分钟新鲜度(后者从未运行过、上岗后将高频误扰)。重写为工作台闸:**覆写信号在场时机械核 promotion 凭证**(文法 + 锚点抽查 + 登记交叉核),平时不索债;10 分钟硬闸改 24h 软提醒(D8)。

**约束:**

- 判定逻辑以 spec §3.1 I4 伪码为准(执行前完整读 spec :187-219),要点:
  - `stop_hook_active=true` → exit 0(安全带,先于一切;沿既有范式)。
  - **手工模式契约(C6)**:stdin `{}` 或解析失败不得静默 exit 0,全部检查照跑;降级 exit 0 仅限 jq/grep 等工具缺失(stderr 一行痕迹,沿 check-context-chain.sh:5-10 协议)。
  - **双层探测(C5,本任务显式约束)**:定位 WORK_DIR 后 `cd` 进去,锚点/指针按 `docs/...` 相对路径解析(C2 路径基准)。
  - 存在性检查保留:handoff 不存在 且 `docs/superpowers/plans/*.md` 存在 → exit 2「先建台账」;两者都无 → exit 0。
  - 覆写信号 := 最新 `docs/completed/handoff-*.md` 的 mtime 在 60 分钟内(D5;超窗不再硬核 = B19 显式残留缺口,行为本身有窗界 fixture)。
  - 覆写信号在场 → 按 C1 整行 ERE 校验 promotion 行 + 锚点抽查 + 登记交叉核 + 空账判定 + skipped 回收点核 + 阻塞中间态放行(C1 规则全文,逐字执行)。
  - 无覆写信号 → 24h 软提醒(D8 可机判定义):台账 mtime > 24h **且** `git log -1 --since="<台账 mtime>"` 非空(存在晚于台账的 commit)**且** `docs/superpowers/plans/` 有 mtime 7 天内的 plan 文件 → stderr 软提醒(exit 0);其余情形 exit 0(暂存有条目平时不索债)。
  - 全角 token → 文法不命中按未做处理(exit 2),stderr 提示「检查全角」(B13)。
  - 所有 exit 2 的 stderr = 哪条不合 + 怎么修(动作引导,非技术堆栈;§5.2 不吞错误)。
  - POSIX:禁 gawk 三参数 match;stat 跨平台用既有 GNU/BSD 兼容写法(旧脚本 :31-37 先例);LF 行尾(.gitattributes 已覆盖)。
- 目录卡交叉核口径与 C3 一致:上架路径在 `references/` 下且文件名带日期前缀 → `grep -F 文件名` 于 `docs/references/README.md`,未命中 → exit 2「落库未登记」;无日期前缀标准件豁免。

**验证标准 = 以下 fixture 脚本全绿**(spec §6.1 场景 3 + I4 行逐条 + B16 + 交叉核 + 双层 + 复核遗留备忘 skipped 正例;先写先跑红——对旧实现至少 A 组场景全败):

- [ ] 把以下 fixture 写到临时位置(如 `/tmp/fixture-check-handoff.sh`)并对**旧实现**跑一遍,确认 A 组场景大面积 FAIL(红基线,记录失败数):

```bash
#!/bin/bash
# fixture-check-handoff.sh — I4 场景手测(临时脚本,跑完即弃,不入仓)
set -u
HOOK="/d/个人/harness/harness/.claude/hooks/check-handoff.sh"
PASS=0; FAIL=0

new_tree() {  # $1=single|double → echo 树根($T);建目录 + git init + 初始 commit(mtime=now)
  local T D; T=$(mktemp -d); D="$T"
  [ "$1" = double ] && D="$T/harness"
  mkdir -p "$D/docs/active" "$D/docs/completed" "$D/docs/references" "$D/docs/superpowers/plans" "$D/docs/decisions"
  (cd "$T" && git init -q && git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init)
  echo "$T"
}
docroot() { if [ -d "$1/harness/docs" ]; then echo "$1/harness"; else echo "$1"; fi; }

mk_handoff() {  # $1=docroot $2=promotion整行(空串=不写) $3=暂存(empty|items)
  { echo "# 工作台台账(handoff)"
    echo "更新时间: 2026-06-11"
    echo "## 待晋升暂存"
    if [ "$3" = items ]; then echo "- [决策] 测试条目甲(本会话)"; else echo "- 无"; fi
    echo "## 指针"; echo "- 无"
    echo "## 晋升声明"
    [ -n "$2" ] && printf '%s\n' "$2"
  } > "$1/docs/active/handoff.md"
}
mk_archive() {  # $1=docroot $2=暂存(none=旧格式无节|empty=- 无|items=两条) $3=fresh|stale
  local F="$1/docs/completed/handoff-20260611-090000.md"
  { echo "# 工作台台账(handoff)"
    case "$2" in
      empty) echo "## 待晋升暂存"; echo "- 无" ;;
      items) echo "## 待晋升暂存"; echo "- [决策] 测试条目甲(本会话)"; echo "- [调研] 测试条目乙(本会话)" ;;
    esac
    echo "## 指针"
  } > "$F"
  [ "$3" = stale ] && touch -d "61 minutes ago" "$F"
}
mk_card() {  # $1=docroot $2=可选登记文件名
  { echo "## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)"
    echo "| 日期 | 文件 | 一句话 | 核验等级 |"
    echo "|---|---|---|---|"
    [ -n "${2:-}" ] && echo "| 2026-06-11 | $2 | 测试 | — |"
  } > "$1/docs/references/README.md"
}

run_case() {  # $1=名 $2=期望exit $3=树根 [$4=stderr须含子串|__EMPTY__=须为空]
  local name="$1" want="$2" T="$3" sub="${4:-}" err got ok=1
  err=$(mktemp)
  ( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash '$HOOK'" ) >/dev/null 2>"$err"
  got=$?
  [ "$got" = "$want" ] || ok=0
  if [ "$sub" = "__EMPTY__" ]; then [ -s "$err" ] && ok=0
  elif [ -n "$sub" ]; then grep -q "$sub" "$err" || ok=0; fi
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); echo "PASS: $name"
  else FAIL=$((FAIL+1)); echo "FAIL: $name (want exit $want${sub:+ / stderr:$sub} got $got)"; sed 's/^/    /' "$err"; fi
  rm -f "$err"; rm -rf "$T"
}

# ===== A 组:覆写信号在场(新鲜归档件) =====
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh; mk_handoff "$D" "" empty
run_case "A1 promotion 行缺失" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh; mk_handoff "$D" "promotion: 未核" empty
run_case "A2 promotion 未核" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh; mk_handoff "$D" "promotion: 已核(全部完成)" empty
run_case "A2b 空话已核(无路径段,文法拒)" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
echo "决策内容" > "$D/docs/decisions/2026-06-11-test.md"
mk_handoff "$D" "promotion: 已核(上架: docs/decisions/2026-06-11-test.md; 弃置: 1 条)" empty
run_case "A3 已核合法锚点" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
: > "$D/docs/decisions/2026-06-11-test.md"
mk_handoff "$D" "promotion: 已核(上架: docs/decisions/2026-06-11-test.md; 弃置: 1 条)" empty
run_case "A4 已核空壳锚点(test -s 拦)" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: 已核(上架: docs/decisions/2026-06-11-nonexist.md; 弃置: 1 条)" empty
run_case "A5 已核锚点不存在(test -f 拦)" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: skipped(理由: ; 回收: docs/completed/handoff-20260611-090000.md)" empty
run_case "A6 skipped 理由空白(文法拒)" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: skipped(理由: 预算不足顺延; 回收: docs/completed/handoff-20260611-090000.md)" empty
run_case "A7 skipped 正例(理由非空+回收点存在)" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: skipped(理由: 预算不足顺延; 回收: docs/completed/handoff-19990101-000000.md)" empty
run_case "A8 skipped 回收点不存在" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" empty fresh
mk_handoff "$D" "promotion: 已核（上架: 无; 弃置: 0 条）" empty
run_case "A9 全角括号" 2 "$T" "全角"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" empty fresh
mk_handoff "$D" "promotion: 已核(上架: 无; 弃置: 0 条)" empty
run_case "A10 空账形+归档暂存为无" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: 已核(上架: 无; 弃置: 0 条)" empty
run_case "A11 空账形但归档暂存有条目" 2 "$T" "零账"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" none fresh
mk_handoff "$D" "promotion: 已核(上架: 无; 弃置: 0 条)" empty
run_case "A12 旧格式归档件(无暂存节,B9)+空账形" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: 阻塞(理由: 写入失败待重试)" items
run_case "A13 阻塞理由非空(合法中间态)" 0 "$T" "阻塞"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: 阻塞(理由: )" items
run_case "A14 阻塞理由空白" 2 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
echo "留痕内容" > "$D/docs/references/2026-06-11-test-note.md"; mk_card "$D"
mk_handoff "$D" "promotion: 已核(上架: docs/references/2026-06-11-test-note.md; 弃置: 0 条)" empty
run_case "A15 references 锚点未登记(交叉核拦)" 2 "$T" "登记"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
echo "留痕内容" > "$D/docs/references/2026-06-11-test-note.md"; mk_card "$D" "2026-06-11-test-note.md"
mk_handoff "$D" "promotion: 已核(上架: docs/references/2026-06-11-test-note.md; 弃置: 0 条)" empty
run_case "A16 references 锚点已登记" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
echo "标准件内容" > "$D/docs/references/standard-note.md"; mk_card "$D"
mk_handoff "$D" "promotion: 已核(上架: docs/references/standard-note.md; 弃置: 0 条)" empty
run_case "A17 无日期前缀标准件豁免目录卡行" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh
mk_handoff "$D" "promotion: 已核(上架: 无; 弃置: 2 条)" empty
run_case "A18 全弃置(弃置≥1 合法)" 0 "$T"

# ===== B 组:窗界 / 无覆写信号 =====
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items stale; mk_handoff "$D" "promotion: 未核" empty
run_case "B1 窗界:归档 61 分钟前不再硬核(B19)" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); echo plan > "$D/docs/superpowers/plans/2026-06-11-x.md"
run_case "B2 无台账+有活跃 plan(既有行为)" 2 "$T"
T=$(new_tree single)
run_case "B3 无台账+无 plan" 0 "$T"
T=$(new_tree single); D=$(docroot "$T"); mk_handoff "$D" "promotion: 未核" items
run_case "B4 无覆写信号+暂存有条目(不索债)" 0 "$T" "__EMPTY__"
T=$(new_tree single); D=$(docroot "$T"); mk_handoff "$D" "promotion: 未核" empty
touch -d "25 hours ago" "$D/docs/active/handoff.md"
echo plan > "$D/docs/superpowers/plans/2026-06-11-x.md"
run_case "B5 台账停更24h+其后有commit+近7天plan → 软提醒" 0 "$T" "24"
T=$(new_tree single); D=$(docroot "$T"); mk_archive "$D" items fresh; mk_handoff "$D" "promotion: 未核" empty
err=$(mktemp); ( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{\"stop_hook_active\": true}' | bash '$HOOK'" ) 2>"$err"
if [ $? = 0 ]; then PASS=$((PASS+1)); echo "PASS: B6 stop_hook_active 安全带"; else FAIL=$((FAIL+1)); echo "FAIL: B6"; fi
rm -f "$err"; rm -rf "$T"

# ===== C 组:双层探测(M15 范式) =====
T=$(new_tree double); D=$(docroot "$T"); mk_archive "$D" items fresh
echo "决策内容" > "$D/docs/decisions/2026-06-11-test.md"
mk_handoff "$D" "promotion: 已核(上架: docs/decisions/2026-06-11-test.md; 弃置: 1 条)" empty
run_case "C1 双层树(harness/docs)同判定" 0 "$T"
T=$(new_tree double); D=$(docroot "$T"); mk_archive "$D" items fresh; mk_handoff "$D" "promotion: 未核" empty
run_case "C2 双层树 promotion 未核拦截" 2 "$T"

echo "----"; echo "PASS=$PASS FAIL=$FAIL"
```

- [ ] 重写 `check-handoff.sh`(满足约束)
- [ ] 跑 fixture 全绿:期望末行 `PASS=27 FAIL=0`(A 组 19 + B 组 6 + C 组 2)(注:全部 case 经 `echo '{}'` 输入 = 手工模式契约 C6 顺带全覆盖;全部 case 不创建 `docs/active/evaluation-result.md` = B16「meta 路无 eval 文件时全部成立」顺带全覆盖,spec §6.1 第二行)
- [ ] 真仓库冒烟(双层实地):`cd /d/个人/harness && echo '{}' | bash harness/.claude/hooks/check-handoff.sh; echo "exit=$?"` → 期望 exit=0(现有活台账无覆写信号,不被误拦;若有 stderr 输出逐条人工判读)
- [ ] 审查回归点(design-review 共识 2/3/6 曾是 🔴):A10/A11/A12 = 空账死状态修复的行为核;A13/A14/B1 = 阻塞态+窗界生命周期核;全部 `echo '{}'` = 手工模式契约核——三组必须全绿才算回归关闭
- [ ] commit:

```
feat(hooks): check-handoff v2 — 覆写信号 promotion 硬核+锚点抽查+登记交叉核,10min 闸改 24h 软提醒(批1a)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 7:收口治理触点行(finishing-rules ×3 + meta-finishing Step D)

**类型:** 契约任务(指令式,逐字插入;机制只挂现有节点,不改流程结构)
**模块:** 治理触点(M-B 的调用方声明)
**Files:**
- Modify: `harness/docs/governance/finishing-rules.md`(:107 / :117 / :125 三处)
- Modify: `harness/docs/governance/meta-finishing-rules.md`(Step D 通用同步列表)

**操作(逐字):**

- [ ] finishing-rules.md:107(「通过」步骤 5):

原:`5. 运行 \`/structured-handoff\`（归档旧版本到 \`docs/completed/\`）`
改:`5. 运行 \`/structured-handoff\`（归档旧版本到 \`docs/completed/\`;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）`

- [ ] finishing-rules.md:117(「精磨」步骤 1):

原:`1. 运行 \`/structured-handoff\`（记录进度和评估器指出的问题）`
改:`1. 运行 \`/structured-handoff\`（记录进度和评估器指出的问题;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）`

- [ ] finishing-rules.md:125(「推翻」步骤 1):

原:`1. 运行 \`/structured-handoff\`（记录状态和推翻原因）`
改:`1. 运行 \`/structured-handoff\`（记录状态和推翻原因;覆写前晋升门禁——待晋升暂存清账——见 structured-handoff SKILL）`

- [ ] meta-finishing-rules.md Step D「调度者动作 — 通用同步」列表(:188-192 的 bullet 块)末尾追加一条:

```
  - 覆写 handoff(走 `/structured-handoff`)前:先过晋升门禁(待晋升暂存逐条裁决:上架/弃置/顺延/阻塞,见 structured-handoff SKILL)— 机制挂现有节点,不新增步骤
```

- [ ] 验证:`grep -c "晋升门禁" harness/docs/governance/finishing-rules.md` → `3`;`grep -c "晋升门禁" harness/docs/governance/meta-finishing-rules.md` → `1`
- [ ] commit:

```
docs(governance): finishing 三路与 meta Step D 挂晋升门禁触点(一句引用,不改流程结构)(批1a)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 8:session-init.sh + check-evidence-depth.sh 在场性小改

**类型:** 实现任务(问题式)
**模块:** M-G(注入端)+ 既有 evidence 闸(§8.0 #1/#3)
**Files:**
- Modify: `harness/.claude/hooks/session-init.sh`
- Modify: `harness/.claude/hooks/check-evidence-depth.sh`

**问题:** 两脚本用单层 `PROJECT_DIR` 路径,从仓库根启动看不到 `harness/docs`(地基事实 1)——hook 上岗后在自仓库剖面失明。session-init 另需在注入头加入口地图行(I1 注入序第 1 级)。

**约束:**

- 双层探测(C5)是本任务显式约束;session-init 用 C5 的例外形(无 docs/ 不退出,`WORK_DIR=PROJECT_DIR` 继续注入)。
- session-init 注入序遵 I1:状态头后加一行(逐字):`入口地图: AGENTS.md(跨运行时约定) / CLAUDE.md(治理路由)`;台账段照注**全文**;台账 >80 行 → 照注全文 + stderr 提示超限(B8/I1);**不注入目录卡**(渐进披露第 3 级按需 Read,I1);其余注入段(evaluation-result / 最新 spec 头 / 最新 plan 头 / git 状态 / 治理提醒)不动;脚本任何失败 exit 0 不阻断会话。
- **SETUP_NEEDED 配置检测段(:13-29)改"提示不中断"**(spec §8.0 #1 微修正,2026-06-11):命中 → 打印 project-setup 提醒(stderr,与 B8 超限提示同道)后**继续执行后续注入段**,不再 exit 0 短路;检测路径基于双层探测后的 WORK_DIR(与注入段同基准)。原列待回设计 #1,已回设计修正,见计划头部留痕。
- check-evidence-depth.sh:**仅**补双层探测,检查逻辑与触发条件(evaluation-result 存在才核)一字不动(§8.0 #3 裁决:留+小改)。

**验证标准:**

- [ ] fixture(临时,跑完即弃):

```bash
# session-init 双层 + 入口行 + 超限提示
T=$(mktemp -d); mkdir -p "$T/harness/docs/active"
printf '台账测试行\n%.0s' $(seq 1 85) > "$T/harness/docs/active/handoff.md"
OUT=$(mktemp); ERR=$(mktemp)
CLAUDE_PROJECT_DIR="$T" bash /d/个人/harness/harness/.claude/hooks/session-init.sh >"$OUT" 2>"$ERR"
grep -q "入口地图: AGENTS.md(跨运行时约定) / CLAUDE.md(治理路由)" "$OUT" && echo OK-入口行
grep -q "台账测试行" "$OUT" && echo OK-双层台账注入
grep -q "80" "$ERR" && echo OK-超限stderr

# SETUP_NEEDED 命中仍注入(提示不中断,spec §8.0 #1 微修正)
printf '[用 2-3 句话描述这个项目的核心价值]\n' > "$T/harness/docs/RUBRIC.md"
CLAUDE_PROJECT_DIR="$T" bash /d/个人/harness/harness/.claude/hooks/session-init.sh >"$OUT" 2>"$ERR"
grep -q "台账测试行" "$OUT" && echo OK-占位符在场仍注入
grep -q "project-setup" "$ERR" && echo OK-配置提醒stderr
rm -rf "$T" "$OUT" "$ERR"

# check-evidence-depth 双层
T=$(mktemp -d); mkdir -p "$T/harness/docs/active"
echo eval > "$T/harness/docs/active/evaluation-result.md"
printf '## Evidence Depth\n- L1 单元测试: [待填]\n## CI 阻断\n[待填]\n' > "$T/harness/docs/active/handoff.md"
( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash /d/个人/harness/harness/.claude/hooks/check-evidence-depth.sh" ); echo "exit=$?"   # 期望 exit=2(双层下找到 [待填] 并拦截)
printf '## Evidence Depth\n- L1 单元测试: 12 passed\n## CI 阻断\n无\n' > "$T/harness/docs/active/handoff.md"
( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash /d/个人/harness/harness/.claude/hooks/check-evidence-depth.sh" ); echo "exit=$?"   # 期望 exit=0
rm -rf "$T"
```

期望:5 行 OK + `exit=2` + `exit=0`(红基线:改前跑,session-init 双层注入/占位符在场仍注入+stderr 提醒/evidence 双层拦截均失败)

- [ ] 实现两脚本小改,重跑 fixture 全绿
- [ ] commit:

```
feat(hooks): session-init/check-evidence-depth 双层探测;入口地图行;SETUP_NEEDED 提示不中断(批1a)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 批 1b:书架登记(spec §8.4:目录卡回填**先于** check-shelf-registry 接线,B10——接线在批 1d 任务 17)

## 任务 9:契约 —— references/README.md 升级为目录卡(含存量回填 8 件)

**类型:** 契约任务(指令式;I5/I4 的 grep 对象,格式即契约)
**模块:** M-D(书架登记,载体)
**Files:**
- Modify: `harness/docs/references/README.md`

**操作:** 将文件改写为以下全文(保留原目录契约三节,替换「当前留痕索引」与「维护」两节——裁量 #2:索引并入目录卡避免同文件双写;维护措辞对齐 immutable 规则):

```markdown
# References（参考资料）

> 存放 AI 搜不到的内部知识。
> 执行者在开发时会按需读取这里的文件。

## 什么该放在这里

- 内部 API 文档（不在公网上的）
- 私有库的使用说明
- 公司/团队的编码规范（如果不在公开文档里）
- 第三方服务的配置说明（内部账号、环境变量含义等，**不含密钥**）
- 设计稿的文字描述或交互规范

## 什么不该放在这里

- ❌ 密钥、token、密码（用 .env，不要提交到仓库）
- ❌ 公开的第三方库文档（AI 可以自己搜到）
- ❌ 项目决策记录（放 docs/decisions/）
- ❌ 产品需求（放 docs/product-specs/）

## 命名约定(文件名约定即类型声明,spec §4.1.7)

- `YYYY-MM-DD-<slug>.md` / `.html` = **调研留痕**(immutable:只追加;过时加横幅不删改;**须登记目录卡**)
- 无日期前缀(如 `DESIGN_TEMPLATE.md`)= **标准件**(evolving:owner 保鲜;**豁免登记**,发现链走地图行)

## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)

> 规矩(I6 权威全文):凡向本目录写入新的**带日期前缀**留痕件,**同一批动作**(同一回复/同一 commit)内在下表加一行;漏登会被 Stop hook 软提醒、覆写台账时被硬交叉核。
> 行文法: `| <日期 YYYY-MM-DD> | <文件> | <一句话> | <核验等级或"—"> |`(token 全半角)
> 过时横幅文法: `> ⚠️ 过时(YYYY-MM-DD): 原因,替代 -> 路径`(加在留痕件头部,不删改正文)

| 日期 | 文件 | 一句话 | 核验等级 |
|---|---|---|---|
| 2026-05-22 | 2026-05-22-p0-9-4-self-check.md | P0.9.4 trial 自查清单 | — |
| 2026-06-10 | 2026-06-10-business-module-map.md | 业务模块地图(草案视图:主线+八模块) | — |
| 2026-06-10 | 2026-06-10-direction-overview.html | 方向梳理总览(入口,串起同批四份地图) | — |
| 2026-06-10 | 2026-06-10-handoff-kb-integration-analysis.md | handoff×知识库三案深度分析(钢人+对抗审查综合;四个地基事实) | — |
| 2026-06-10 | 2026-06-10-literature-map-context-loops-docs-harness.md | 文献地图:上下文管理/loops/文档治理/harness 设计 | — |
| 2026-06-10 | 2026-06-10-literature-map-llm-wiki-knowledge-org.md | llm-wiki/知识组织文献地图 | 3-0/补读 混合 |
| 2026-06-10 | 2026-06-10-opensource-memory-solutions-map.md | 开源「工作记忆×知识库」方案分档对照(档位二/三决策参照) | — |
| 2026-06-10 | 2026-06-10-scaffold-vs-ultracode-map.md | 脚手架 60 组件 × ultracode 覆盖度对照 | — |

## 维护

- 留痕件(带日期前缀)immutable:过时**加横幅标注,不删改**(横幅文法见上)。
- 标准件(无日期前缀)evolving:owner 保鲜,过时原地修订。
```

**依据:** spec §4.1.7(规矩头+表头+示例行逐字)+ §8.3 目录卡行(存量回填 8 件:7 md + 1 html,2026-06-11 `ls` 实数核对一致)+ C3。

**步骤:**

- [ ] 写入上述全文
- [ ] 逐件打开 8 个留痕件头部,查「性质/产出方式/核验等级」标注块——**有标注则把对应行的 `—` 替换为照录值(照录不造;无标注保持 `—`)**;`2026-06-10-literature-map-llm-wiki-knowledge-org.md` 行按 spec §4.1.7 示例已定 `3-0/补读 混合`
- [ ] 回填完备核(I5 上线即零警告基线,B10):

```bash
cd /d/个人/harness/harness/docs/references
ls | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-' | while read f; do grep -qF "$f" README.md && echo "OK $f" || echo "MISSING $f"; done
```

期望:8 行 OK,0 行 MISSING

- [ ] C3 同形核(表头与规矩头一行逐字,供 I5 内嵌模板对照):`grep -qF '## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)' README.md && grep -qF '| 日期 | 文件 | 一句话 | 核验等级 |' README.md && echo OK-同形`
- [ ] commit:

```
docs(references): README 升级目录卡 — 规矩头+条目表+存量回填 8 件(批1b,B10 先回填后接线)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 10:check-shelf-registry.sh 新建(书架登记软扫 I5)

**类型:** 实现任务(问题式)
**模块:** M-D(书架登记,机器扫)
**Files:**
- Create: `harness/.claude/hooks/check-shelf-registry.sh`

**问题:** 落库不登记只能 git 考古发现(C6-③ 实证)。建 Stop 软闸:每次 Stop 扫 references/ 的带日期前缀留痕件与目录卡比对,未登记的 stderr 点名提醒;**永不阻断**(硬兜底在 I4 覆写交叉核,软硬两道时点分明,避免告警疲劳——本 hook 不得加任何 exit 2 路径)。

**约束:**

- 扫描口径(C3/I5):`references/` 下 `YYYY-MM-DD-` 前缀的 `.md` 与 `.html`(非 README);无前缀标准件豁免(setup.sh 分发的 5 个标准件即此类,下游装机零告警)。
- 比对:逐文件 `grep -F 文件名` 于 `docs/references/README.md`;未命中 → stderr 一行提醒列出未登记文件,exit 0。
- 目录卡缺失:**仅当存在日期前缀留痕件时**,stderr 提示「建目录卡」并内嵌最小模板(I6 首次落库同批自建的格式权威;**逐字** = C3 规矩头一行 + 表头两行):

```
## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)
| 日期 | 文件 | 一句话 | 核验等级 |
|---|---|---|---|
```

  无留痕件(或 references/ 不存在)→ 静默 exit 0。
- 双层探测(C5,显式约束)、手工模式契约(C6)、`stop_hook_active` 安全带、依赖缺失降级 exit 0 + stderr 一行(check-context-chain.sh:5-10 协议)。
- 文件名无 `meta-`/`check-meta-` 前缀 → setup.sh 既有 hooks 循环自动分发下游(脚本头注释声明这点,沿 check-context-chain.sh:23-24 注释先例)。

**验证标准 = 以下 fixture 全绿(先写先跑红——hook 未建时全 FAIL/exit 127):**

- [ ] fixture 写入临时位置并跑红:

```bash
#!/bin/bash
# fixture-check-shelf-registry.sh — I5 场景手测(临时,不入仓)
set -u
HOOK="/d/个人/harness/harness/.claude/hooks/check-shelf-registry.sh"
PASS=0; FAIL=0
new_tree() { local T D; T=$(mktemp -d); D="$T"; [ "$1" = double ] && D="$T/harness"; mkdir -p "$D/docs/references"; echo "$T"; }
docroot() { if [ -d "$1/harness/docs" ]; then echo "$1/harness"; else echo "$1"; fi; }
mk_card() {
  { echo "## 目录卡(落库即登记:写入本目录的同一批动作里在下表加一行)"
    echo "| 日期 | 文件 | 一句话 | 核验等级 |"; echo "|---|---|---|---|"
    [ -n "${2:-}" ] && echo "| 2026-06-11 | $2 | 测试 | — |"
    [ -n "${3:-}" ] && echo "| 2026-06-11 | $3 | 测试 | — |"
  } > "$1/docs/references/README.md"
}
run_case() {  # $1=名 $2=期望exit $3=树根 [$4=stderr须含|__EMPTY__] [$5=stderr另须含]
  local name="$1" want="$2" T="$3" s1="${4:-}" s2="${5:-}" err got ok=1
  err=$(mktemp)
  ( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash '$HOOK'" ) >/dev/null 2>"$err"
  got=$?
  [ "$got" = "$want" ] || ok=0
  if [ "$s1" = "__EMPTY__" ]; then [ -s "$err" ] && ok=0
  else
    [ -n "$s1" ] && { grep -q "$s1" "$err" || ok=0; }
    [ -n "$s2" ] && { grep -q "$s2" "$err" || ok=0; }
  fi
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); echo "PASS: $name"
  else FAIL=$((FAIL+1)); echo "FAIL: $name (want exit $want got $got)"; sed 's/^/    /' "$err"; fi
  rm -f "$err"; rm -rf "$T"
}

T=$(new_tree single); D=$(docroot "$T")
echo x > "$D/docs/references/2026-06-11-a.md"; echo x > "$D/docs/references/2026-06-11-b.html"; mk_card "$D"
run_case "R1 未登记 md+html 双点名" 0 "$T" "2026-06-11-a.md" "2026-06-11-b.html"
T=$(new_tree single); D=$(docroot "$T")
echo x > "$D/docs/references/2026-06-11-a.md"; echo x > "$D/docs/references/2026-06-11-b.html"
mk_card "$D" "2026-06-11-a.md" "2026-06-11-b.html"
run_case "R2 已登记静默" 0 "$T" "__EMPTY__"
T=$(new_tree single); D=$(docroot "$T")
echo x > "$D/docs/references/standard-note.md"; mk_card "$D"
run_case "R3 无前缀标准件豁免静默" 0 "$T" "__EMPTY__"
T=$(new_tree single); D=$(docroot "$T")
echo x > "$D/docs/references/2026-06-11-a.md"
run_case "R4 目录卡缺失+有留痕 → 提示建卡含内嵌模板" 0 "$T" "目录卡" "| 日期 | 文件 | 一句话 | 核验等级 |"
T=$(new_tree single); D=$(docroot "$T")
echo x > "$D/docs/references/standard-note.md"
run_case "R5 目录卡缺失+仅标准件 → 静默" 0 "$T" "__EMPTY__"
T=$(new_tree double); D=$(docroot "$T")
echo x > "$D/docs/references/2026-06-11-a.md"; mk_card "$D"
run_case "R6 双层树未登记点名" 0 "$T" "2026-06-11-a.md"
T=$(mktemp -d); mkdir -p "$T/docs"
run_case "R7 references 目录不存在 → 静默" 0 "$T" "__EMPTY__"
T=$(new_tree single); D=$(docroot "$T"); echo x > "$D/docs/references/2026-06-11-a.md"; mk_card "$D"
( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{\"stop_hook_active\": true}' | bash '$HOOK'" ) 2>/dev/null
if [ $? = 0 ]; then PASS=$((PASS+1)); echo "PASS: R8 stop_hook_active 安全带"; else FAIL=$((FAIL+1)); echo "FAIL: R8"; fi
rm -rf "$T"

echo "----"; echo "PASS=$PASS FAIL=$FAIL"
```

- [ ] 实现 hook,跑 fixture 全绿:期望末行 `PASS=8 FAIL=0`
- [ ] 真仓库冒烟(任务 9 回填后零警告基线):`cd /d/个人/harness && echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh; echo "exit=$?"` → 期望 `exit=0` 且 stderr 无未登记点名
- [ ] `chmod +x harness/.claude/hooks/check-shelf-registry.sh`(与既有 hooks 一致;LF 行尾由 .gitattributes 覆盖)
- [ ] 审查回归点(design-review 建议项「下游装机即告警」/「目录卡自举循环」):R3/R4/R5 即对应行为核
- [ ] commit:

```
feat(hooks): check-shelf-registry — 落库登记每 Stop 软扫,未登记点名不阻断(批1b)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 11:research-scout 产出整形红线追加同批登记行

**类型:** 契约任务(指令式,一行追加;I6 同批耦合层①的执行端)
**模块:** M-D(登记规矩的产出方耦合)
**Files:**
- Modify: `harness/.claude/agents/research-scout.md`(「第四步:产出整形(红线 — 核心)」bullet 列表)

**操作:**

- [ ] 在「## 第四步:产出整形(红线 — 核心)」列表末尾(:59 `产出**写成 artifact 文件**...` 之后)追加一条(逐字):

```
- **留痕落库必须同批登目录卡行**(I6 登记通用规矩):产出写进 `docs/references/`(带日期前缀)时,**同一批动作**(同一回复/同一 commit)在 `docs/references/README.md` 目录卡表加一行(行文法住目录卡头部;无前缀标准件豁免)。
```

- [ ] 验证:`grep -c "同批登目录卡" harness/.claude/agents/research-scout.md` → `1`
- [ ] commit:

```
docs(agents): research-scout 红线追加「留痕落库同批登目录卡行」(I6 耦合层①)(批1b)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 批 1c:入口与偏好(spec §8.4 批 1 内序第三段)

## 任务 12:契约 —— templates/AGENTS.md(下游入口地图)

**类型:** 契约任务(指令式)
**模块:** M-E(入口地图)
**Files:**
- Create: `harness/templates/AGENTS.md`

**操作:** 按 spec §4.1.5 骨架创建以下全文(九格住址 = §4.4「权威住址(下游)」列;第 8 格按骨架指定写法;硬规矩三行逐字):

```markdown
# AGENTS.md — agent 第 0 步地图

> 运行时中立:任何 agent 工具或纯人工都按本文件接手。Claude Code 专属治理见 CLAUDE.md(自动加载)。

## 这个仓库的上下文分两层

- 工作台: docs/active/handoff.md(状态+指针,覆写经晋升门禁 /structured-handoff)
- 书架: 九格(愿景/需求/系统真相/决策史/标尺/干活规矩/行业认知/用户偏好/地图)→ 见下方住址表

## 接手顺序(任何 agent / 人)

0. 本文件 → 1. 读 docs/active/handoff.md(台账:状态+指针)→ 2. 顺指针 Read 本体
→ 3. 找没有指针的东西: docs/references/README.md(目录卡)/ ls docs/decisions/(文件名即卡)
→ 4. 治理与角色规则: CLAUDE.md(Claude Code 自动加载;其他运行时手动读)

## 九格住址表(+ 各格生命周期型)

| # | 格 | 住址 | 生命周期 |
|---|---|---|---|
| 1 | 愿景 | docs/context/L1-vision.md | evolving |
| 2 | 需求 | docs/context/(L2+)+ docs/superpowers/specs/(spec §1) | spec 单件 immutable |
| 3 | 系统真相 | docs/ARCHITECTURE.md + 各模块 README | evolving |
| 4 | 决策史 | docs/decisions/ + docs/decision-trail.md | immutable(只追加) |
| 5 | 标尺 | docs/RUBRIC.md | evolving |
| 6 | 干活规矩 | docs/governance/ | evolving |
| 7 | 行业认知 | docs/references/(日期前缀留痕) | immutable(只追加) |
| 8 | 用户偏好 | 不随 harness 分发——使用者个人层;可自建 docs/preferences.md,条目文法一行示例: - [YYYY-MM-DD] <偏好一句话>(原话: "<用户原话引录>") | evolving |
| 9 | 地图 | AGENTS.md + CLAUDE.md + docs/references/README.md(目录卡) | evolving |

## 硬规矩(一行引用,不重复全文;权威全文住各自住址)

- 落库即登记: 写 references/ 带日期前缀留痕件同批登目录卡行(无前缀标准件豁免) → 全文与行文法住 references/README.md 目录卡头部
- 覆写台账先清账: promotion 声明带锚点 → 全文住台账模板头 + structured-handoff SKILL(晋升门禁)
- 过时标注不删改(immutable 格;本行即全文)

## 手工校验(无 hook 运行时 / 纯人工)

- echo '{}' | bash .claude/hooks/check-handoff.sh
- echo '{}' | bash .claude/hooks/check-shelf-registry.sh

(hook 是 Claude Code 增强层;换运行时丢自动触发,不丢可校验性)
```

**步骤:**

- [ ] 创建上述文件(逐字)
- [ ] 验证:`wc -l < harness/templates/AGENTS.md` ≤ 60(约 1 页,spec §3.4);`grep -c '^| [1-9] |' harness/templates/AGENTS.md` → `9`(九格全);`grep -qF "echo '{}' | bash .claude/hooks/check-handoff.sh" harness/templates/AGENTS.md && echo OK-命令形态`(与 C6 统一形态)
- [ ] commit(与任务 13 可同 commit,见任务 13 末步——双写共享核同批改的实操体现)

## 任务 13:契约 —— 根 AGENTS.md(自仓库剖面,§4.1.5 根版差异 ①-⑤)

**类型:** 契约任务(指令式)
**模块:** M-E(入口地图)
**Files:**
- Create: `AGENTS.md`(仓库根 `D:/个人/harness/AGENTS.md`)

**操作:** 创建以下全文(差异①九格 harness/ 前缀;②meta 治理行;③「实物在 harness/ 下」导航行;④校验命令 harness/ 路径;⑤工作台住址 harness/ 前缀;其余与 templates 版共享核同构):

```markdown
# AGENTS.md — agent 第 0 步地图(harness 自仓库)

> 运行时中立:任何 agent 工具或纯人工都按本文件接手。Claude Code 专属治理见根 CLAUDE.md(自动加载)。
> 实物在 harness/ 下(双层结构:仓库根 = 治理入口,harness/ = 框架源码与文档)。

## 这个仓库的上下文分两层

- 工作台: harness/docs/active/handoff.md(状态+指针,覆写经晋升门禁 /structured-handoff)
- 书架: 九格(愿景/需求/系统真相/决策史/标尺/干活规矩/行业认知/用户偏好/地图)→ 见下方住址表

## 接手顺序(任何 agent / 人)

0. 本文件(实物在 harness/ 下)→ 1. 读 harness/docs/active/handoff.md(台账:状态+指针;台账内指针写 docs/... 相对路径,基准 = harness/)→ 2. 顺指针 Read 本体
→ 3. 找没有指针的东西: harness/docs/references/README.md(目录卡)/ ls harness/docs/decisions/(文件名即卡)
→ 4. 治理与角色规则: 根 CLAUDE.md(Claude Code 自动加载;其他运行时手动读)
- meta 治理(自仓库专属): 根 CLAUDE.md(M3)scope 分流

## 九格住址表(+ 各格生命周期型)

| # | 格 | 住址 | 生命周期 |
|---|---|---|---|
| 1 | 愿景 | README.md(仓库根;dogfood 边界:自仓库不建 docs/context/) | evolving |
| 2 | 需求 | harness/docs/superpowers/specs/(spec §1)+ harness/docs/ROADMAP.md | spec 单件 immutable;ROADMAP evolving |
| 3 | 系统真相 | harness/docs/ARCHITECTURE.md + 各模块 README | evolving |
| 4 | 决策史 | harness/docs/decisions/ + harness/docs/decision-trail.md | immutable(只追加) |
| 5 | 标尺 | harness/docs/RUBRIC.md | evolving |
| 6 | 干活规矩 | harness/docs/governance/ | evolving |
| 7 | 行业认知 | harness/docs/references/(日期前缀留痕) | immutable(只追加) |
| 8 | 用户偏好 | harness/docs/preferences.md(仓内权威住址;memory 为缓存镜像;不分发下游) | evolving |
| 9 | 地图 | AGENTS.md(根)+ CLAUDE.md(根)+ harness/docs/references/README.md(目录卡) | evolving |

## 硬规矩(一行引用,不重复全文;权威全文住各自住址)

- 落库即登记: 写 references/ 带日期前缀留痕件同批登目录卡行(无前缀标准件豁免) → 全文与行文法住 harness/docs/references/README.md 目录卡头部
- 覆写台账先清账: promotion 声明带锚点 → 全文住台账模板头 + structured-handoff SKILL(晋升门禁)
- 过时标注不删改(immutable 格;本行即全文)

## 手工校验(无 hook 运行时 / 纯人工)

- echo '{}' | bash harness/.claude/hooks/check-handoff.sh
- echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh

(hook 是 Claude Code 增强层;换运行时丢自动触发,不丢可校验性)
```

**步骤:**

- [ ] 创建上述文件(逐字)
- [ ] 双写共享核一致性核(§4.1.5 同批改义务的基线快照——两份的接手顺序结构 0→1→2→3→4、硬规矩三条主题、九格表 9 行结构必须同构):

```bash
cd /d/个人/harness
for f in AGENTS.md harness/templates/AGENTS.md; do
  echo "== $f"; grep -c '^| [1-9] |' "$f"; grep -c '^- 落库即登记\|^- 覆写台账先清账\|^- 过时标注不删改' "$f"
done
```

期望:两文件各输出 `9` 与 `3`

- [ ] 手工演练(spec §6.1 场景 4 的可走通性预核,完整 checklist 在 hook 上岗后实战):照根 AGENTS.md 接手顺序 0→4 逐步走一遍(读台账→顺指针开一个本体→目录卡找一份留痕→读 M3),每步可达;手工跑两条校验命令,exit 0(check-shelf-registry 已建;check-handoff v2 已上线)
- [ ] `git add AGENTS.md`(根级新文件不 add 不入 scope 扫描——D14 已知缺口,入库即消失)
- [ ] commit(两份 AGENTS.md 同 commit,落实「共享核同批改」):

```
feat(map): AGENTS.md 入口地图 ×2 — 根(自仓库剖面)+ templates(下游分发版),共享核同批(批1c)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 14:preferences.md 偏好层入仓(用户逐条拍板门)

**类型:** 实现任务(问题式;**含用户在场硬门——不可由执行 agent 自行入仓**)
**模块:** M-F(偏好层)
**Files:**
- Create: `harness/docs/preferences.md`

**问题:** 用户协作偏好只活在 Claude 私有 memory,换运行时即丢(违反模型无关目标)。建仓内权威住址,初版从 memory feedback 条目蒸馏——**蒸馏是判断活,AI 列草稿、用户逐条拍板后才入仓**(spec §4.1.6/§8.4 批 1c 硬规则,不做自动晋升)。

**约束:**

- 文件骨架逐字(spec §4.1.6;last-reviewed 填实施当日):

```markdown
# 用户偏好(协作方式)
<!-- owner: 用户; last-reviewed: YYYY-MM-DD; 生命周期: evolving -->
> 本文件是用户协作偏好的仓内权威住址(SSoT)。AI 个人记忆(memory/)是它的缓存镜像:
> 新偏好先落本文件,memory 可随后镜像;两边冲突以本文件为准。过时条目标注不删。

## 条目
<!-- 条目文法(硬字段): 日期 + 用户原话引录必填(忠实性审查的锚点,D11 精确化①);feedback 文件名可附 -->
```

- 条目文法 = C4 逐字;**每条必须带用户原话引录**(从 memory 文件照录,不转写不润色——忠实性是 D11 审查口径;无原话可引的候选列为「待用户补原话」,不得编造引录)。
- 草稿候选来源(memory 目录 `C:/Users/刘超凡/.claude/projects/D-----harness/memory/`):`user_preferences.md`、`feedback_design_philosophy.md`、`feedback_judgment_basis.md`、`feedback_spec_gap_masking.md`、`feedback_choice_visualization.md`、`feedback_unprovable_in_bootstrap.md`、`feedback_dimension_addition_judgment.md`、`feedback_realworld_testing_in_other_projects.md`、`feedback_skill_no_cross_project.md`、`feedback_iterative_progression.md`、`feedback_talk_plainly.md`、`feedback_read_dont_judge_user.md`、`feedback_module_cut_by_business.md`、`harness_explore_rigor_gradient.md`。注意区分:**协作偏好**(怎么沟通/怎么对待用户判断)入此文件;**项目原则**(治理/架构判断)不入(住 governance/decisions)——草稿阶段分栏列出,边界条目交用户裁。

**步骤:**

- [ ] 创建文件骨架(上述逐字,日期填当日)
- [ ] AI 读 memory 候选文件,产出草稿清单(每条:偏好一句话 + 原话引录 + 来源文件;按"协作偏好/项目原则/待补原话"三栏分列)——草稿放对话中,**不写入文件**
- [ ] **停:呈给用户逐条拍板**(通过 / 改写 / 不入)。用户不在场则本任务挂起,后续任务 15 可先行(其 M3 行指向骨架文件已存在)
- [ ] 拍板通过的条目按 C4 文法写入 `## 条目` 下
- [ ] 忠实性自核:每条 `grep -cE '^- \[20[0-9]{2}-[0-9]{2}-[0-9]{2}\] .+\(原话: ".+"' harness/docs/preferences.md` 计数 = 条目总数(日期+原话引录无一缺失)
- [ ] 确认 setup.sh **不含** preferences 分发(D11):`grep -c preferences harness/setup.sh` → `0`
- [ ] commit:

```
feat(docs): preferences.md 偏好层入仓 — 用户逐条拍板条目,仓内权威 memory 镜像(D11)(批1c)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 15:CLAUDE.md 地图行(M3 新增小节 + M4 文档索引行)

**类型:** 契约任务(指令式,逐字插入)
**模块:** M-E(入口地图,Claude Code 侧)
**Files:**
- Modify: `CLAUDE.md`(仓库根,M3)
- Modify: `harness/CLAUDE.md`(M4 分发模板)

**操作:**

- [ ] M3:在「## 活上下文链 dogfood 边界」节之后、「## 仓库结构 + 快速开始(导航)」节之前插入(逐字;裁量 #3:M3 无既有文档索引表,落点为新增两行小节):

```markdown
## 上下文层地图行

- **agent 第 0 步地图(跨运行时)**:`/AGENTS.md`(仓库根;下游分发版 `harness/templates/AGENTS.md`——两份共享核(接手顺序/硬规矩引用/九格表结构)**同批改**,spec §4.1.5 双写同步义务,与 M3↔M17 双写约束同款)
- **用户偏好(协作方式)**:`harness/docs/preferences.md`(仓内权威住址,memory 为缓存镜像;改动命中 A 组 → meta-review,审查口径 = 忠实性对照用户原话锚点 — D11)
```

- [ ] M4:文档索引表(「## 文档索引」)中:
  1. 「交接状态」行改为(加门禁注,spec §8.1):

```
| 交接状态 | docs/active/handoff.md(覆写经晋升门禁 /structured-handoff) |
```

  2. 其后新增一行:

```
| **agent 第 0 步地图(跨运行时)** | **AGENTS.md(仓库根)** |
```

  3. **不加** preferences 行(D11:不分发,下游无此文件)。
- [ ] 验证:`grep -c "AGENTS.md" CLAUDE.md` ≥ 1 且 `grep -c "preferences" CLAUDE.md` ≥ 1(M3 两行都在);`grep -c "AGENTS.md" harness/CLAUDE.md` → `1`;`grep -c "preferences" harness/CLAUDE.md` → `0`(D11 核);`grep -c "晋升门禁" harness/CLAUDE.md` → `1`
- [ ] commit:

```
docs(claude-md): M3 上下文层地图行小节 + M4 索引加 AGENTS.md 行/交接行注门禁(批1c)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 批 1d:分发与 scope(spec §8.4 批 1 内序第四段)

## 任务 16:契约 —— meta-scope.conf 补 glob 四处 + M3 §3/§5 同步(同 commit,M3↔M17 双写约束)

**类型:** 契约任务(指令式)
**模块:** M-H(分发与同步,scope 治理)
**Files:**
- Modify: `harness/.claude/hooks/meta-scope.conf`
- Modify: `CLAUDE.md`(仓库根 M3,§3 对照表 + §5 清单)

**操作(conf 四处,逐字;§8.0 #8):**

- [ ] A 组块(`CLAUDE.md` 行之后)追加:

```
# 入口地图 = 治理面,与 CLAUDE.md 对称(D14);根级文件经 §5.5 root 扫描段命中,audit covers 写 <root>/AGENTS.md
AGENTS.md
# 偏好层:偏好治理上当规范同等对待(D11 ✅ A;审查口径 = 忠实性对照用户原话锚点)
docs/preferences.md
```

- [ ] C 组块:`.claude/skills/*/SKILL.md` 一行改为(D15):

```
# D15:模板单源化后 skill 捆绑资源 = 契约本体;glob 扩为 */*.md 覆盖 SKILL.md + 捆绑模板(如 structured-handoff/handoff-template.md)
.claude/skills/*/*.md
```

- [ ] F 组块(`templates/*.json` 行之后)追加:

```
# templates/*.md:模板 = 分发契约(事实 3 治理洞:改模板曾永不触发审查);现命中 templates/AGENTS.md(templates/handoff.md 由任务 18 删除)
templates/*.md
```

**操作(M3 同步,逐字;改 conf 必同批改 M3 —— §3/§5 是同一事实的人读版):**

- [ ] M3 §3 表 A 组行的 glob 列改为:`\`docs/governance/*.md\` / \`CLAUDE.md\` / \`AGENTS.md\` / \`docs/preferences.md\``
- [ ] M3 §3 表 C 组行的 glob 列改为:`\`.claude/skills/*/*.md\`(D15:SKILL.md + 捆绑资源)/ \`.claude/agents/*.md\``
- [ ] M3 §3 表 F 组行的 glob 列:`templates/*.json` 后追加 ` / \`templates/*.md\``(原括号注保留)
- [ ] M3 §5 A 组清单追加两条:

```markdown
- `/AGENTS.md`(根,自仓库剖面入口地图;D14 — hook §5.5 root 扫描命中,audit covers 写 `<root>/AGENTS.md`;全新建未 git add 漏检缺口与根 CLAUDE.md 同款,入库后消失)
- `harness/docs/preferences.md`(偏好层权威住址;D11 ✅ A,审查口径 = 忠实性对照用户原话锚点,不评判偏好本身)
```

- [ ] M3 §5 C 组首行改为:`\`harness/.claude/skills/*/*.md\`(SKILL.md + 捆绑资源,如 structured-handoff/handoff-template.md — D15;brainstorming / design-review / evaluate / process-audit / 等)`
- [ ] M3 §5 F 组清单追加:`\`harness/templates/AGENTS.md\`(下游入口地图模板,经 F 组 \`templates/*.md\` glob)`;并在 F 组段注一句:`templates/handoff.md 已删(D3 单源化,住址迁移至 skill 捆绑资源)`(本句在任务 18 删除动作的同批生效——若任务 16/18 不同 commit,此句随任务 18 补)
- [ ] 对照验证(两处一致性,M2 §2 同步约束):

```bash
cd /d/个人/harness
for g in 'AGENTS.md' 'docs/preferences.md' '.claude/skills/*/*.md' 'templates/*.md'; do
  grep -qF "$g" harness/.claude/hooks/meta-scope.conf && grep -qF "$g" CLAUDE.md && echo "OK 同步 $g" || echo "FAIL 失同步 $g"
done
```

期望:4 行 OK

- [ ] commit:

```
feat(scope): meta-scope.conf 补 glob 四处(AGENTS/preferences/skills资源/templates.md)+ M3 表同批同步(批1d)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 17:settings 双轨接线 check-shelf-registry(§8.0 #9;B10 顺序:目录卡已于任务 9 回填)

**类型:** 契约任务(指令式)
**模块:** M-H(接线)
**Files:**
- Modify: `harness/.claude/settings.json`
- Modify: `harness/templates/settings.json`

**操作:** 两文件的 `hooks.Stop[0].hooks` 数组中,`check-handoff.sh` 条目之后插入(逐字,M19 双轨同批):

```json
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-shelf-registry.sh"
          },
```

**步骤:**

- [ ] 两文件插入上述条目
- [ ] JSON 合法性 + 双轨核:

```bash
cd /d/个人/harness/harness
jq -r '.hooks.Stop[0].hooks[].command' .claude/settings.json | grep -c check-shelf-registry    # 期望 1
jq -r '.hooks.Stop[0].hooks[].command' templates/settings.json | grep -c check-shelf-registry  # 期望 1
jq -r '.hooks.Stop[0].hooks[].command' templates/settings.json | grep -c check-meta            # 期望 0(下游零 meta hook 痕迹,M19 既有约束不破坏)
```

- [ ] commit:

```
feat(settings): Stop 数组接线 check-shelf-registry — 自仓库+下游模板双轨同批(批1d)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 18:setup.sh 分发清单(I7)+ 删除 templates/handoff.md(D3)

**类型:** 实现任务(问题式,但关键 cp 块给实物)
**模块:** M-H(分发与同步)
**Files:**
- Modify: `harness/setup.sh`
- Delete: `harness/templates/handoff.md`

**问题:** 下游要拿到新件(AGENTS.md / skill 捆绑模板 / check-shelf-registry 接线后的 settings),初始台账要换单源,活文件不被重跑覆灭;`templates/handoff.md` 单源化后删除(消费方已清点:setup.sh 本任务改,SKILL 引用任务 5 已重写)。

**约束与精确改动:**

1. skills 段(`cp ... structured-handoff/SKILL.md ...` 行后)加一行:

```bash
cp "$SCRIPT_DIR/.claude/skills/structured-handoff/handoff-template.md" "$TARGET_DIR/.claude/skills/structured-handoff/"
```

2. 初始台账块(任务 1 已加守卫)改源为模板单源:

```bash
# 初始台账:从模板单源(skill 捆绑资源)复制;活文件守卫(I7)— 已存在不覆盖
if [ ! -f "$TARGET_DIR/docs/active/handoff.md" ]; then
    cp "$SCRIPT_DIR/.claude/skills/structured-handoff/handoff-template.md" "$TARGET_DIR/docs/active/handoff.md" 2>/dev/null || true
fi
```

2.5. **活文件守卫扩展(批 0 audit F1,2026-06-11)**:`docs/product-specs/index.md` 与 `docs/context/{README,L1-vision,L2-INDEX}.md` 的 cp 行同样加存在性守卫(形态同 handoff 守卫:`if [ ! -f ... ]`)——spec I7 原则"活文件杜绝重跑覆盖"的完整枚举;fixture 补一例:改写下游 L1-vision 后重跑安装,内容不被覆盖。

3. CLAUDE.md 复制段旁新增 AGENTS.md 段:

```bash
# AGENTS.md(入口地图;活文件守卫 — 已存在不覆盖,I7)
if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
    cp "$SCRIPT_DIR/templates/AGENTS.md" "$TARGET_DIR/AGENTS.md"
fi
```

4. `git rm harness/templates/handoff.md`(同批;M3 §5 F 组注释句若任务 16 未带上,此处补)
5. check-shelf-registry.sh **无需**显式 cp——hooks 循环(非 meta 前缀)自动覆盖(验证步确认);preferences.md **不得**出现在任何 cp 行(D11)。

**验证标准(集成 fixture,spec §6.1 I7/B9 行):**

- [ ] fixture(先跑红:改动前 AGENTS.md/skill 资源/接线三项必 FAIL):

```bash
cd /d/个人/harness/harness
T=$(mktemp -d)
./setup.sh "$T" > /dev/null
test -f "$T/AGENTS.md" && echo OK-agents
grep -q "工作台台账" "$T/docs/active/handoff.md" && echo OK-初始台账v2
test -f "$T/.claude/skills/structured-handoff/handoff-template.md" && echo OK-skill资源
test -f "$T/.claude/hooks/check-shelf-registry.sh" && echo OK-hook分发
grep -q "check-shelf-registry" "$T/.claude/settings.json" && echo OK-下游接线
test ! -f "$T/docs/preferences.md" && echo OK-偏好不分发
ERR=$(mktemp); ( cd "$T" && CLAUDE_PROJECT_DIR="$T" bash -c "echo '{}' | bash .claude/hooks/check-shelf-registry.sh" ) 2>"$ERR"
[ $? = 0 ] && [ ! -s "$ERR" ] && echo OK-装机零告警   # 分发的 5 个标准件无日期前缀,豁免(I5)
echo "LIVE" >> "$T/docs/active/handoff.md"; echo "AGENTS-LIVE" >> "$T/AGENTS.md"
echo y | ./setup.sh "$T" > /dev/null
grep -q "LIVE" "$T/docs/active/handoff.md" && echo OK-台账守卫
grep -q "AGENTS-LIVE" "$T/AGENTS.md" && echo OK-AGENTS守卫
rm -rf "$T" "$ERR"
```

期望:9 行 OK

- [ ] 引用断链核:`grep -rn "templates/handoff.md" harness/setup.sh harness/.claude/ harness/CLAUDE.md CLAUDE.md` → 期望仅 M3 §5 的「已删」注释句命中(活引用 0;docs/ 下历史 spec/plan/audit 留痕不算)
- [ ] commit:

```
feat(setup): 分发清单更新 — AGENTS/skill 模板资源/初始台账改源+守卫;删 templates/handoff.md(D3)(批1d)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 19:批 1 收尾 checkpoint —— M1 四步 + meta-review(整批)

**类型:** 流程 checkpoint(由调度者执行;spec §8.4:1a-1d 为批内顺序,批 1 整批一次 finishing)
**模块:** 治理流程(M1/M2)
**Files:**
- Modify: `harness/docs/ROADMAP.md`、`harness/docs/PROGRESS.md`(若跨阶段)、`harness/docs/decision-trail.md`、`harness/docs/active/handoff.md`
- Create: `harness/docs/audits/meta-review-<timestamp>-context-layer-batch1.md`

**步骤:**

- [ ] Step A(scope 判断):批 1 diff 命中 A+B+C+F 组 → **meta**(任一命中即 meta)
- [ ] 8.2 兼容性收尾核(spec 承诺的最后三项,前两项已在任务 4/5 做):
  - check-meta-review skip 字段兼容:`cp harness/.claude/skills/structured-handoff/handoff-template.md /tmp/t.md && printf '\n## meta-review: skipped(理由: 测试)\n' >> /tmp/t.md && grep -E '^[[:space:]]*##[[:space:]]+meta-review:[[:space:]]+skipped\(理由:[[:space:]]*[^)]*\)' /tmp/t.md && rm /tmp/t.md` → 命中一行(v2 台账上追加 skip 字段,M15 grep 行为不变)
  - check-context-chain 兼容:`grep -c '^## context-chain:' harness/.claude/skills/structured-handoff/handoff-template.md` → `1`
  - 85 处引用零断链(spec 计数,2026-06-11 实数 95):`grep -rn "docs/active/handoff" --include="*.md" --include="*.sh" --include="*.json" harness/ CLAUDE.md | wc -l` ≥ 90,路径全程未动(D2)
- [ ] Step B(meta-review):按 M2 fork 审查整批;audit covers 字段列全(机读 glob 视角):`CLAUDE.md`(M4)、`<root>/CLAUDE.md`(M3)、`<root>/AGENTS.md`、`docs/preferences.md`、`docs/governance/finishing-rules.md`、`docs/governance/meta-finishing-rules.md`、`.claude/skills/structured-handoff/SKILL.md`、`.claude/skills/structured-handoff/handoff-template.md`、`.claude/agents/research-scout.md`、`.claude/hooks/check-handoff.sh`、`.claude/hooks/check-shelf-registry.sh`、`.claude/hooks/session-init.sh`、`.claude/hooks/check-evidence-depth.sh`、`.claude/hooks/meta-scope.conf`、`.claude/settings.json`、`setup.sh`、`templates/settings.json`、`templates/AGENTS.md`、`templates/handoff.md`(删除)。**新 glob 生效实证**:audit 写齐前,check-meta-review 的 uncovered 列表应包含 `handoff-template.md` 与 `templates/AGENTS.md`(任务 16 conf 改动被机器消费的证据,留痕进 audit)
- [ ] Step C:实施中若出新判断拐点 → decisions/ 立档(预期:无;D1-D17 已在 spec)
- [ ] Step D:ROADMAP「上下文层重构」节推进(批 1 完成,余 hook 上岗);decision-trail append(候选拐点:晋升门禁上线 = 防遗忘从纪律转机制);PROGRESS 若需
- [ ] 运行 `/structured-handoff` —— **首次走 v2 晋升门禁**(归档→清账:本批暂存条目逐条裁决→覆写:promotion 按 C1 写→自查 ≤80 行)。覆写后的 Stop 即 I4 首次实战硬核;若被 exit 2 拦,按 stderr 引导补——这是机制 dogfood,问题如实留痕(meta-L4 实战证据,不绕)
- [ ] commit:

```
docs(meta): 批1 finishing — 上下文层改造主体 meta-review 留痕 + 首次晋升门禁 dogfood

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 会话链自执法批(2026-06-11 方向变更:取代原「hook 上岗 A/B 实测分支」)

> 变更依据:`docs/decisions/2026-06-11-session-chain-reconciliation.md`(用户第一性重审,拍板 C 案)。原任务 20-23 文本见 git 历史(258b96e 版本),本节整体重写。
> 核心:开场两步(读台账+对账上次收口)写进入口文件;hook 降级为工具箱(手工模式=正身,自动触发=从 harness/ 启动时的增强);A/B 接线题消解,条件任务取消。

## 任务 20:check-meta-review 对账模式(--reconcile,audit 覆盖核可执行化)

**类型:** 实现任务(问题式)
**模块:** M-H(工具箱)
**Files:**
- Modify: `harness/.claude/hooks/check-meta-review.sh`

**问题:** 现 hook 只扫未提交 diff(执法时点错位 C6)——"已提交历史中命中 scope 的文件有没有有效 audit 覆盖"目前只能人肉考古。开场对账需要一条可执行命令回答它。

**约束:**

- 新增手工对账模式:`bash check-meta-review.sh --reconcile [天数]`。参数即模式开关,不读 stdin;**参数判定必须插在脚本现有 `INPUT=$(cat)`(约 :37)之前**,`set -u` 下用 `${1:-}` 取参——否则交互终端跑 `--reconcile` 会在 cat 上挂死(M3 开场规程那条命令就是调用方)。**无参数时既有 Stop 行为逐字不变**(回归必证)
- 对账逻辑:`git log --since=<起点> --name-only --relative` 收集已提交改动文件清单——**必须 `--relative`**(cwd=harness/ 与既有 `git diff --relative` 同基准;不加则输出仓库根相对路径,所有 glob 永不命中=永远假"账齐");root 级文件段用 `git -C "$ROOT_DIR" log`(根级路径天然根相对,复用 §5.5 sentinel 前缀逻辑)→ 复用既有 conf 解析(:109-126)与 `match_glob`/`is_in_scope`(:141-186)过滤 scope 文件 → 对照有效 audit covers 并集 → stderr 输出;**exit 0**(对账输出给 AI 读,处置由开场规程引导,不阻断)
- **失效锚点(对账模式专用,区别于既有 Stop 规则)**:audit 新鲜度用 **audit 文件自身的最后 commit time**(`git log -1 --format=%ct -- <audit>`;未提交的 audit 才用 mtime 兜底)。理由:finishing 惯例 audit 与同批修订**同 commit 打包**(实例:258b96e 同含批 1 audit 与 M4 修订),covered 文件 commit time = audit commit time,`≤` 判有效;若沿用纯 mtime 锚,每批收口都假欠账(covered commit time > audit 写盘 mtime)且 fresh clone 后 mtime 全刷新普遍偏松——**不得为让验证变绿而改松判定**
- **窗口语义**:无天数参数时,窗口起点 = 仓库最新 audit 文件的最后 commit time(无任何 audit → 30 天前);显式传天数则按天数。低频项目(隔 8+ 天再开会话)不滑窗漏账
- 「账齐」输出**带计数**:`账齐:近窗 <N> 件 scope 改动,有效 audit <M> 份`——空转(N=0)与实核可区分,防"glob 全不命中假账齐"
- 对账模式**忽略 handoff 的 `## meta-review: skipped` 字段**(skip 是 Stop 执法的豁免,不豁免已提交欠账;报原始欠账,处置权给 AI/用户)
- 头注释身份更新:本脚本两种模式(Stop 执法=增强层 / --reconcile=对账工具箱);LC_ALL 纪律、依赖缺失降级协议沿既有;`extract_covers` 的 gawk 三参数 match 已知问题(mawk/BSD 死锁)维持独立待办,本任务不修不扩散
- fixture(临时不入仓,先红后绿):①近窗 scope commit 无 audit → 点名;②有有效 audit 覆盖(audit 与修订同 commit)→ 账齐且计数非零;③audit 失效(covered 文件在 audit 提交**之后**又有新提交)→ 点名;④无参数模式回归(改前改后行为一致);⑤非 git 仓库 → 降级 exit 0;⑥**双层结构例**(fixture 仓库含 harness/ 子层,验证 --relative 基准与 root 段)

**验证:** fixture 六例全绿 + 真仓库 `--reconcile` 实跑——预期推导:批 1 audit 与其 covers 修订同 commit(258b96e),commit time 锚下全部有效 → 期望 `账齐:近窗 N 件 scope 改动,有效 audit M 份`(N、M 非零)+ 无参数回归证据。

**commit:**

```
feat(hooks): check-meta-review 对账模式 --reconcile — 已提交历史 audit 覆盖核(会话链自执法批)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 21:契约 —— 入口指令「开场两步」落四处(M3/根 AGENTS/M4/templates AGENTS,共享核同批)

**类型:** 契约任务(指令式)
**模块:** M-E(入口地图)
**Files:**
- Modify: `CLAUDE.md`(仓库根 M3)、`AGENTS.md`(仓库根)、`harness/CLAUDE.md`(M4)、`harness/templates/AGENTS.md`

**操作(四处同 commit):**

1. M3:「上下文层地图行」节之后、「仓库结构 + 快速开始(导航)」之前插入小节(逐字):

```markdown
## 会话开场规程(会话链自执法 — 下一会话是上一会话的验收者)

1. **装载**:读 `harness/docs/active/handoff.md`(台账:状态+指针),按需顺指针补读本体
2. **对账**(核上次收口的凭证——只读账本不读流水;欠账先补再开新工作):
   - `echo '{}' | bash harness/.claude/hooks/check-handoff.sh`(promotion 文法/锚点/登记交叉核)
   - `echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh`(落库登记)
   - `bash harness/.claude/hooks/check-meta-review.sh --reconcile`(已提交 scope 改动的 audit 覆盖)
   - 欠账处置:缺 audit → 按 M2 补 meta-review;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账

依据:`harness/docs/decisions/2026-06-11-session-chain-reconciliation.md`(C 案;hook=工具箱,手工模式为正身)
```

2. 根 AGENTS.md:「接手顺序」块末尾(`- meta 治理(自仓库专属)...` 行之后)追加一行(逐字):

```
- 开场对账(步 1 读完台账后):跑下方「手工校验」两命令 + `bash harness/.claude/hooks/check-meta-review.sh --reconcile`;欠账先补再干活(会话链自执法,详 harness/docs/decisions/2026-06-11-session-chain-reconciliation.md)
```

3. templates/AGENTS.md:「接手顺序」块末尾(`→ 4. ...` 行之后)追加一行(下游版,共享核结构同批改;逐字):

```
- 开场对账(步 1 读完台账后):跑下方「手工校验」两命令;欠账先补再干活(下一会话是上一会话的验收者)
```

4. M4(harness/CLAUDE.md):「核心规则」编号清单末尾追加一条(逐字):

```
11. **会话开场先装载再对账**:读 docs/active/handoff.md(台账)→ 跑 AGENTS.md「手工校验」命令核上次收口凭证;欠账先补再开新工作(会话链自执法)
```

**验证:** `grep -c "会话开场规程" CLAUDE.md` → 1;`grep -c "开场对账" AGENTS.md harness/templates/AGENTS.md` 各 → 1;`grep -c "先装载再对账" harness/CLAUDE.md` → 1;AGENTS 双写共享核结构核(两文件接手顺序均含对账行,九格/硬规矩不动)。

**commit:**

```
feat(map): 会话开场规程(装载+对账)落 M3/AGENTS×2/M4 — 会话链自执法(C 案)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 22:留痕同步(ROADMAP + spec 状态头)

**类型:** 契约任务(指令式)
**模块:** 治理留痕
**Files:**
- Modify: `harness/docs/ROADMAP.md`、`harness/docs/superpowers/specs/2026-06-10-context-layer-design.md`(仅状态头)

**操作:**

- ROADMAP「上下文层重构」节:标题括注与进展行推进(批 1 完成 → 会话链自执法批);「批 1 留痕待办」中 F1 条改为 decision「不做」节口径(自动触发不在场;手工对账会跑到 check-handoff,误触发=误报不阻断;加固候选保留,若未来接电先修);SETUP_NEEDED 条的"任务 20 观察"挂锚改"会话链自执法批后真实使用观察;候选自仓库剖面豁免"(原锚随 A/B 实测取消而悬空);hook 上岗段表述改 C 案
- spec 状态头追加一行(不动正文,锁定后注记有先例):`2026-06-11 方向变更:§8.4「hook 上岗接线」行与 §7.1 D9 接线分叉由 docs/decisions/2026-06-11-session-chain-reconciliation.md(C 案 会话链自执法)取代/消解;D9 的双层探测交付物保留(它是手工模式从根 cwd 跑通的前提)`

**commit:**

```
docs(roadmap+spec): 会话链自执法方向变更留痕 — F1 降级 + spec 状态头注记(C 案)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

## 任务 23:收尾 checkpoint —— M1 四步 + meta-review + 兑现「挨个审查」提醒

**类型:** 流程 checkpoint(由调度者执行)
**模块:** 治理流程(M1/M2)
**Files:**
- Modify: `harness/docs/ROADMAP.md`、`harness/docs/decision-trail.md`、`harness/docs/active/handoff.md`
- Create: `harness/docs/audits/meta-review-<timestamp>-session-chain-reconciliation.md`

**步骤:**

- [ ] Step A(scope 判断):A 组(CLAUDE.md×2、AGENTS.md)+ B 组(check-meta-review.sh)+ F 组(templates/AGENTS.md 经 `templates/*.md`)→ meta
- [ ] Step B(meta-review):按 M2 fork 审查本批;audit covers:`<root>/CLAUDE.md`、`CLAUDE.md`、`<root>/AGENTS.md`、`templates/AGENTS.md`、`.claude/hooks/check-meta-review.sh`
- [ ] Step C:decision 已立档(本批起点),audit 内回填关联 commit hash
- [ ] Step D:decision-trail append(拐点:常驻守门人→会话链自执法,hook 降级工具箱);ROADMAP 收口(上下文层重构全批完成;场景留痕起点=真实使用,不造 artificial trial)
- [ ] 运行 `/structured-handoff`(走 v2 门禁)
- [ ] **兑现用户义务(2026-06-11 原话"全部完成之后提醒我挨个审查")**:向用户提出挨个审查清单——preferences.md(4 正式条目+6 待补原话,含条 4 例外补回与无日期升格路径两 Minor)+ 批 0/批 1/会话链自执法批全部产出索引
- [ ] commit:

```
docs(meta): 会话链自执法批收尾 — meta-review 留痕 + ROADMAP 收口 + 挨个审查提醒兑现

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
```

---

# 执行顺序总览

```
批 0:   任务 1 → 2 → 3(checkpoint)
批 1a:  任务 4(契约) → 5 → 6 → 7 → 8
批 1b:  任务 9(契约,回填先于接线 B10) → 10 → 11
批 1c:  任务 12(契约) → 13(契约) → 14(用户拍板门) → 15
批 1d:  任务 16(契约) → 17 → 18 → 19(checkpoint,批 1 整批)
会话链自执法批: 任务 20(工具) → 21(契约,入口四处) → 22(留痕) → 23(checkpoint,含挨个审查提醒)
```

任务总数 23(原任务 20-23 于 2026-06-11 被 C 案整体重写,原 A/B 条件任务取消;原文见 git 历史 258b96e 版本)。

# 凭证与对账规则(credentials)
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->

> **治理同层化**(2026-06-13)。本文件是凭证制度的**单入口**——谁欠凭证(§2)、凭证文法(§3/§4)、何时失效(§5)、怎么对账(§6)、证据档位怎么填(§7)、双写义务(§8)。
> 需求源:`docs/decisions/2026-06-13-governance-single-layer.md`(乙案三件套:收口住 finishing-rules / 审查维度住 review-rules / 凭证与对账住本件)。

## §1 定位与读法

本文件 = 凭证制度的单一权威入口。治理同层化拍板见 `docs/decisions/2026-06-13-governance-single-layer.md`(meta/feature 双轨收敛为单层,凭证义务参数化)。

**三个进入时刻**(分别从哪来、到本件读什么):

1. **收口**:finishing-rules.md「凭证义务核对」节(收口动作序)跳来 → 读 §2 我这批欠不欠凭证、§3/§4 凭证怎么写。
2. **补账**:开场对账(§6 三命令)报欠账时跳来 → 读 §2 该件该补什么凭证、§3/§4 怎么补。
3. **查文法**:写 audit 前跳来 → 读 §3(正式 audit)或 §4(exempt 微 audit)。

**与三件套其余两件的分工**(一句话):收口动作序住 `finishing-rules.md`;审查维度选择住 `review-rules.md`「审查维度选择表」;凭证文法与对账规程住本件。

## §2 凭证要求表(人读版)

> 与机器版 `.claude/hooks/credentials.conf` **双写同步**:改一处必同改另一处,审查时 grep 比对(V5 双写比对的人读端;双写面从原 M3 三表↔M17 收敛为本表↔conf 一对)。**表格式契约**:一行一 glob,行序与 conf 同序。

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
| workflows(review-scout 等 ultracode 编排脚本) | `.claude/workflows/*` | audit |
| RUBRIC | `docs/RUBRIC.md` | audit |
| 设计模板 | `docs/references/DESIGN_TEMPLATE.md` | audit |
| setup 脚本 | `setup.sh` | audit |
| 分发模板(json) | `templates/*.json` | audit |
| 分发模板(md) | `templates/*.md` | audit |
| 排除:审查凭证(新名,防自循环) | `!docs/audits/audit-*.md` | — |
| 排除:审查凭证(历史名) | `!docs/audits/meta-review-*.md` | — |
| 排除:归档审查 | `!docs/audits/archive/**` | — |

不命中任何 include glob = 无凭证义务。

**凭证类型说明**:当前全部 include 行 = audit;`design-review` / `test` 为参数位预留(工具现阶段只消费 audit 行;下游可自加如 `src/payments/** test` 表"支付模块改动须测试凭证")。

**附注**(原 M3 §5 实存文件注记精简迁居):
- ① 自仓库 `.claude/settings.json` 已撤(2026-06-12 追记①;glob 保留备未来)。
- ② `templates/handoff.md` 已删(D3 单源化,住址迁至 skill 捆绑资源 structured-handoff/handoff-template.md)。
- ③ 活缺口注记:全新建未 git add 的根级文件走 untracked 漏检(缺口本体详 `docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md` §9.4 #11,入库后消失)。

## §3 audit 产物规范

> 凭证文法的权威全文。本节为治理面改动留凭证(对抗审查 audit)的产物规范。

### 3.1 位置 + 命名

- **位置**:`docs/audits/`
- **命名**:`audit-YYYY-MM-DD-HHMMSS-[主题].md`(新命名;HHMMSS 用本地时间,与 process-audit 报告命名同结构)
- **双前缀兼容**:工具收集 glob = `audit-*.md` + `meta-review-*.md`——历史 21 份 `meta-review-*.md` 文件名**不换**(被 decisions/ROADMAP/decision-trail/归档台账大量引用,改名即迫改 immutable 内容),frontmatter 已统一格式迁移(见 3.3),零改名继续有效。
- **归档**:每 6 月迁 `docs/audits/archive/YYYY-HN/`(D15;P0.9.1 仅声明策略,首次半年归档由后续阶段触发)。

### 3.2 与 process-audit 报告的命名空间共存

`audit-YYYY-MM-DD-HHMMSS.md`(process-audit 报告,无主题段、无 frontmatter)与 `audit-YYYY-MM-DD-HHMMSS-[主题].md`(审查凭证)同前缀同目录。**机器区分靠 frontmatter,不靠文件名**:审查凭证必有 `audit: true` + 非空 `covers`;process-audit 报告无 frontmatter,被 `is_audit_credential` 自然滤除。

### 3.3 YAML frontmatter(必填)

```markdown
---
audit: true
covers:
  - <仓库相对路径 1>
  - <仓库相对路径 2>
  ...
---
```

字段语义:

| 字段 | 类型 | 必填 | 缺省/合法值 | 含义 |
|---|---|---|---|---|
| `audit` | boolean | ✅ | 固定 `true` | 标识本文件是审查凭证;hook grep 识别用 |
| `covers` | string 数组(仓库相对路径) | ✅ | **非空数组**(空 = 等价于未走流程) | 本 audit 覆盖的凭证义务内文件路径 |

> **字段名 `audit`(R13 单一解析路径,无双字段兼容)**:2026-06-13 用户拍板全换(原 `meta-review: true`→`audit: true`,含 21 份历史件同批格式迁移——「immutable 保护内容,纯格式迁移不算改」)。**文件名不换**理由见 3.1。历史件迁移协议详 `docs/superpowers/specs/2026-06-13-governance-single-layer-design.md` §4.1-10。

### 3.4 covers 数组路径规则

1. **仓库相对路径**:从仓库根算起,无 `./` 前缀,无尾 `/`(如 `docs/governance/review-rules.md`)
2. **正斜杠分隔**:Windows 仓库也用 `/`(YAML 跨平台一致)
3. **路径必须实存**:写 audit 时调度者列入的路径必须在仓库内实存(允许扩展提交后实存)
4. **无去重要求**:数组内允许重复,hook 处理时按集合并集计算
5. **`<root>/` sentinel 前缀** — 区分 repo 根级文件(根 CLAUDE.md = `/CLAUDE.md`)与 harness/ 内部相对路径(M4 = `harness/CLAUDE.md`,在 hook `git diff --relative` 视角输出 `CLAUDE.md`):
   - **写 audit covers 时**:根级改动写 `<root>/CLAUDE.md` / `<root>/AGENTS.md`;harness 内部改动写 `CLAUDE.md`(与第 1-4 条规则一致)
   - **hook 输出**:`check-audit-coverage.sh` 在 repo 根扫描发现 root 级文件后,push CHANGED 列表前对该文件加 `<root>/` 前缀
   - **比对语义**:hook 用 `grep -Fxq` 字面比对 covers 与 CHANGED;`<root>/CLAUDE.md` ≠ `CLAUDE.md`(独立项)
   - **历史 audit 兼容**:现有 audit covers 多用 harness 内部相对路径(无前缀),自动命中 M4 语义;唯 P0.9.1 audit covers 用仓库相对(`harness/...`)作为孤例不 backfill
   - **字面独占性**:`<root>/` 7 字节 ASCII 字面与所有现实文件路径不冲突(`<` 字符在 git 实际路径中罕见 + 跨平台兼容性问题保证不出现);若用户真创建以 `<root>/` 字面开头的文件,与本协议冲突(接受边缘 case)

### 3.5 写侧契约

- **触发者**:调度者(在审查产 audit 时写入)
- **必须列入 covers 的内容**:本 audit **实际覆盖的、凭证义务内的、本次改动的所有文件路径**
  - **不是**"audit 主题相关"即列入;必须是 audit 实际审查的具体文件
  - **不能漏列**(漏列文件会被对账视为未 cover,触发引导)
  - **不能误列**不属本次改动的(误列会导致下次相同文件改动时失效计算偏差)

### 3.6 5 段正文标题(精确)

```markdown
## 1. 元信息
## 2. 维度选取
## 3. 挑战者执行记录
## 4. 综合
## 5. 判定
```

本节锁定 frontmatter + 5 段节标题(确保 hook 可识别 + 写入一致)。

### 3.7 任务级结论登记簿(2026-06-12 加,decision 2026-06-11-session-chain-reconciliation.md 追记②)

子代理驱动开发批的批级 audit,「## 3. 挑战者执行记录」节内**逐任务留一行**结论(任务级审查的过程细节随会话死,结论必须落账):

格式:`任务 <N>(<一句话主题>):verdict=<approved|needs-fixes 后修复|...>;关键发现 <无|一句话>;修复 commit <无|短 SHA[+短 SHA...]>`(多修复 commit 用 + 连写)

- 来源 = 该任务的实现者报告 + 两段审查结论(调度者在写 audit 时汇总)
- 只登结论不抄过程("为下游使用设计内容":下游要的是"这件审过了、审出过什么、修在哪",不是审查对话)
- 非子代理驱动批(如纯流程 checkpoint)无任务粒度,免登

### 3.8 错误处理(读侧 hook)

| 错误情形 | 处理 |
|---|---|
| audit YAML frontmatter 损坏 | stderr `⚠️ audit YAML 损坏: <文件>` + 视该 audit 不存在(不参与 covers 并集);hook 继续处理其他 audit;exit 0 不阻断 |
| `covers:` 字段缺失 | 同上,视该文件非审查凭证 |
| `covers:` 为空数组 | 视为未走流程,该 audit 不贡献任何 covered_files |
| `audit: true` 缺失或值为 false | 视该文件非审查凭证,跳过 |

## §4 exempt 微 audit(豁免文法)

> 豁免不走对抗审查,但仍走凭证正道——`--reconcile` 对账天然认(被消除的旧 skip 字段对账从不认)。

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
4. 豁免边界:仅 typo / 链接修复 / 注释措辞等**无语义变更**;语义变更一律走对抗审查。**例外两类**(同走 exempt,理由行写明类别):① D11 偏好条目用户原话直录(忠实性由逐字引录自保证);② 初装/升级 scaffold(内容=上游分发原样,上游已审)。exempt 理由质量由 process-audit 按需/周期回看反向抽查(不绑每批);**covers 超 5 件的 exempt 必抽**。
5. 失效规则与正式 audit 完全一致(§5):covered 文件在 exempt 之后有新 commit → exempt 失效,需重新豁免或补审。**豁免不是永久免检**。
6. 成本对照:3-5 行文件 ≈ 一行 skip 字段,但走凭证正道——`--reconcile` 对账天然认(skip 字段对账从来不认,这正是被消除的制度洞)。

## §5 audit 失效规则

### 5.1 单 audit 单文件失效判定

```text
对每个 audit 的每个 covers 文件:
  covered_latest_commit_time = git log -1 --format=%ct -- <covered_file>
  audit_mtime                = stat <audit_file> 取 mtime
  if covered_latest_commit_time > audit_mtime:
    return TRUE   # 失效:文件有新 commit 在 audit 之后
  else:
    return FALSE  # 仍有效
```

### 5.2 多 audit 跨覆盖

- **单文件可能在多个 audit 的 covers 中**:任一未失效的 audit 即视为该文件已 cover
- 计算 `covered_files` 时按所有有效 audit 的 covers 字段并集:
  ```
  covered_files = ⋃ {audit.yaml_frontmatter.covers : audit ∈ 有效 audit 集}
                 其中 "有效 audit" 按上述失效规则筛后
  uncovered     = changed_files - covered_files
  ```
- `changed_files` = git diff/log 命中 credentials.conf include glob 后过滤的集合

### 5.3 实现细节(供 check-audit-coverage.sh 参考)

- `git log -1 --format=%ct -- <file>` 取最新 commit time
- audit 文件 mtime 用 `stat`(GNU 用 `stat -c %Y`,BSD 用 `stat -f %m`,与 `check-handoff.sh` 兼容)
- 不用 ctime(避免 git checkout 改 ctime 误判)

### 5.4 归档 audit 处理

- 主目录(`docs/audits/`)+ `archive/INDEX.md` 缓存的近 12 个月条目参与失效计算
- 归档表外的旧条目不参与(过老 audit covers 几乎肯定都已失效)

### 5.5 对账模式差异锚

对账模式(`--reconcile`)的 audit 新鲜度锚 = **audit 自身的最后 commit time**(`git log -1 --format=%ct -- <audit>`;未提交/未跟踪 audit 才用 mtime 兜底):covered 文件最新 commit time ≤ audit commit time → 有效。理由:finishing 惯例 audit 与同批修订**同 commit 打包**,两者 commit time 相等,`≤` 判有效;纯 mtime 锚会"每批收口假欠账+clone 后普遍偏松"。

## §6 开场对账规程

三条命令(自仓库形态;下游去 `harness/` 前缀同形):

```markdown
1. `bash .claude/hooks/check-handoff.sh --reconcile`(台账凭证)
2. `echo '{}' | bash .claude/hooks/check-shelf-registry.sh`(落库登记)
3. `bash .claude/hooks/check-audit-coverage.sh --reconcile`(凭证覆盖——本件主角;A 彻底同层后下游同跑三条)

欠账处置:缺 audit → 按 review-rules 维度选择表治理行补审产 audit,或(豁免边界内)补 exempt 微 audit;漏登记 → 补目录卡行;promotion 不合形 → 走 /structured-handoff 重新清账。欠账先补再开新工作。
```

本节与根 CLAUDE.md「会话开场规程」/ AGENTS×2 对账行互为指针(权威动作序住本节,入口行只一句引)。

## §7 证据档位表(代码|设计|治理)

```markdown
| 档位 | 代码改动 | 设计改动 | 治理改动 |
|---|---|---|---|
| L1 | 单元测试通过 | 设计文档节内自检 [x] 全勾选 | 节内自检 / hook fixture 先红后绿 |
| L2 | 集成测试输出 | 全局自检(design-rules 10 项) | 全局一致性核(双写比对 / 装机验证) |
| L3 | 自动化验证脚本 | design-review 4 维审查通过 | 对抗审查 audit verdict=pass(凭证在 docs/audits/) |
| L4 | 真实场景验证记录 | 落地后实战回看 | 实战留痕(后续改动的 audit / 对账引用本规则) |
```

- handoff `## Evidence Depth` / `## CI 阻断` **字段名与行格式不动**(check-evidence-depth.sh 零改,R12);每行 `- L<n>: <状态> <证据位置>` 三段,状态 ✅(完成)/ ⏳(待观察)/ ❌(不通过 — 需补)/ ➖(不适用);一批含多类改动按类各填行(统一 L1-L4 名,`meta-L` 前缀退役)。
- `<证据位置>` 必须含具体路径或 audit 文件名,不能用"已完成"这类无指向词。
- 三示例:
  - **代码批**:`- L1: ✅ src/foo/bar.test.ts 单元测试通过` / `- L3: ✅ scripts/api-smoke.sh 自动化验证`
  - **治理批**:`- L1: ✅ hook fixture 先红后绿(check-X 10 例)` / `- L3: ✅ docs/audits/audit-2026-06-13-HHMMSS-主题.md verdict=pass`
  - **混合批**:代码类 L 行 + 治理类 L 行按类各填(无 scope 标签,按改动类别分行)

## §8 双写同步义务清单

> 改一处同批改另一处;审查时触点完整性维优先选用核对。
>
> (机读派生形 = `docs/governance/touchpoint-registry.md`,供知识系统 Step2 ③b 漂移检测消费;改触点先改本清单/源,再同步该表——见第 9 条。)

1. 本件 §2 人读表 ↔ `.claude/hooks/credentials.conf`(行序同序,glob 逐行一致)。
2. review-rules 维度表治理行判定语 ↔ conf。
3. 根 CLAUDE.md 治理表凭证行 ↔ 本件存在性(根 CLAUDE.md 治理表「凭证义务一句话」**不复制类目枚举**,只写"命中 credentials.conf 任一 include glob"+ 本件指针)。
4. 对抗式模板 design-review SKILL ↔ evaluate SKILL(A/B/C 三段同构,同批改)。
5. 对账命令拷贝组**四处同改**:根 CLAUDE.md 开场规程 / 根 AGENTS.md「手工校验」/ templates/AGENTS.md「手工校验」/ 本件 §6。
6. review-rules 设计行地板维表注(三类维名:design / code / governance)↔ `.claude/workflows/review-scout.workflow.js` 的 `FloorTable` 常量(三类维名逐类逐维一致)。**文档上游、代码派生**:改维名先改 review-rules 地板维表注(权威源),再改 workflow.js FloorTable(机读派生镜像);改一处必同改另一处,审查时触点完整性维比对三类维名逐字一致。
7. review-rules 设计/代码行候选菜单注(design:完整性 / 过度工程化;code:类型契约合规 / 架构合规 / 模块文档一致性)↔ `.claude/workflows/review-scout.workflow.js` 的 `DesignCandidateMenu` / `CodeCandidateMenu` 常量(菜单项逐字一致)。**文档上游、代码派生**:改菜单项先改 review-rules 候选注(权威源),再改 workflow.js 常量;审查时触点完整性维比对菜单项逐字一致。
8. 新鲜度开场步拷贝组**三处同改**:根 CLAUDE.md 会话开场规程「第 3 步 开场新鲜度侦察」/ 根 AGENTS.md「开场新鲜度侦察」节 / templates/AGENTS.md「开场新鲜度侦察」节(同核步骤:fork freshness-scout / 三类问题 / owner 二分 + routeTo / 全干净静默 / 推 last-reviewed / 需 agent 运行时降级)。**与第 5 条对账命令拷贝组独立**:第 5 条只锚对账三命令,本条只锚新鲜度开场步,两条各管各的同核面,不并入。新鲜度机制权威住 `docs/governance/freshness-rules.md`(不写入本件 §6 对账正文)。
9. 本 §8 人读双写义务清单 ↔ `docs/governance/touchpoint-registry.md`(机读派生形)。**本清单上游、该表派生**:该表是 §8 + 体检散落触点的机读镜像(每条拆 端点/判据/来源/现状,供 ③b 漂移检测消费);改触点先改 §8/源、再同步该表。**与第 5 条对账拷贝组等独立**:本条只锚 §8↔注册表的派生一致,不并入其他拷贝组。

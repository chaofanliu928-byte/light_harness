# P0.9.1 Self-Governance Implementation Plan

**关联 spec**:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`
**关联 ROADMAP**:P0.9.1
**关联 brainstorming**:见 spec §1(2026-04-17 第一轮 + 2026-04-26 第二轮深挖)
**关联 decisions**:D1-D22(spec §7.1)+ 三项独立 decision 文件
- `docs/decisions/2026-04-26-p0-9-1-5-trigger-condition.md`(D20)
- `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`(D21)
- `docs/decisions/2026-04-26-bypass-paths-handling.md`(D22)
**生成日期**:2026-04-26
**Plan 作者**:planner agent(独立 fork,不参与 design)

---

## 1. 总览

### 1.1 spec 锚点

| 维度 | 数值 / 引用 |
|---|---|
| 模块数 | 20(M1-M20,见 spec §2.1) |
| 决策数 | 22(D1-D22,见 spec §7.1) |
| 核心场景 | 5 个(spec §1.2),P0.9.1 实施场景 1/2/3 主体 + 场景 1/2 执法触点;场景 4/5 不在本阶段实施(spec §1.3 边界声明) |
| 流程契约 | 10 个(spec §3.1.1 - §3.1.10) |
| 数据实体 | 7 个(spec §4.1.1 - §4.1.7) |
| 边界条件 | B1-B18(spec §5.1) |
| Bootstrap 维度 | 4(核心原则合规 / 目的达成度 / 副作用 / scope 漂移,spec §6.4 + D7) |

### 1.2 任务统计

| 任务类型 | 数量 |
|---|---|
| 契约任务(C 系列) | 5 |
| 实现任务(I 系列) | 18 |
| 测试任务(T 系列) | 11 |
| **总计** | **34** |

### 1.3 关键约束(贯穿所有任务)

来自 spec 的硬约束:

1. **bootstrap 例外 1(spec §2.1)**:ARCHITECTURE.md 的 UI/Service/Repository 分层对 harness 自身**不适用**。组件类别用 `governance` / `hook` / `hook-conf` / `skill` / `agent` / `template` / `CLAUDE-rule` / `settings`
2. **bootstrap 例外 2(spec §7.4)**:harness 项目特定 RUBRIC 空白,本阶段不强填
3. **不分发污染(spec §1.3 兼容性)**:meta-* 文件不分发下游;agent prompt 不抄 M2 实文(spec §3.1.6 fix-2)
4. **最小变更(M3 升级 / M5 加分流入口 / M14 加过滤 / M18 追加一行 / M20 扩展)**:已改文件不重写
5. **fix-9 (v) 治理文件入 scope**:scope.conf 排除规则只排流程产出物(audit / archive),不排治理文件
6. **fix-9 (iii) covers 比对**:hook 校验的是"audit covers 字段实际列出的文件"vs git diff 改动文件,不是"audit 存在 + 主题相关"

---

## 2. 任务依赖图

> 8 批次依次执行。同批次内任务可并行(若实现 agent 支持)。

```
批次 1:契约任务(全部前置)
  ├─ C1 meta-scope.conf 配置内容定义
  ├─ C2 audit YAML frontmatter covers 字段格式
  ├─ C3 handoff 字段格式(skip / 反审待办)
  ├─ C4 M2 审查维度三段 pattern 节内容
  └─ C5 M19 templates/settings.json 与 M18 差异规约

批次 2:数据层(C1 → I)
  └─ I2.1 实现 M17 meta-scope.conf

批次 3:治理基础(C2 + C4 → I)
  ├─ I3.1 实现 M2 meta-review-rules.md(含 pattern 节)
  └─ I3.2 实现 M1 meta-finishing-rules.md(含 evidence depth 节)

批次 4:入口治理(I3.x → I)
  ├─ I4.1 升级 M3 /CLAUDE.md(harness 自治理入口)
  ├─ I4.2 改造 M5 finishing-rules.md(加 scope 分流入口)
  └─ I4.3 调整 M4 harness/CLAUDE.md(确认无 meta 段落 + feature 部分与 M3 对齐)

批次 5:agent / skill 改造(I3.x → I)
  ├─ I5.1 改造 M6 design-reviewer.md(对抗式 A/B/C)
  ├─ I5.2 改造 M7 evaluator.md(对抗式 A/B/C + scope 分流引 evidence depth)
  ├─ I5.3 改造 M8 security-reviewer.md(混合式 部分 A/B/C)
  ├─ I5.4 改造 M9 process-auditor.md(事实统计式 N 维分工)
  ├─ I5.5 改造 M10 design-review SKILL.md(执行节引 M2)
  ├─ I5.6 改造 M11 evaluate SKILL.md(同上)
  ├─ I5.7 改造 M12 security-scan SKILL.md(同上,仅对抗维度部分)
  └─ I5.8 改造 M13 process-audit SKILL.md(引 M2 粒度细化子节)

批次 6:hook 层(C1 + C2 + I2.1 → I)
  ├─ I6.1 实现 M15 check-meta-review.sh(Stop hook)
  ├─ I6.2 实现 M16 check-meta-commit.sh(git pre-commit hook)
  └─ I6.3 扩展 M20 session-init.sh(反审检测段)

批次 7:settings 注册 + 分发模板(C5 + I6.1 → I)
  ├─ I7.1 改动 M18 .claude/settings.json(注册 M15)
  └─ I7.2 新建 M19 harness/templates/settings.json(分发模板)

批次 8:setup.sh 分发过滤 + handoff 模板 + testing-standard(I 全部 → I)
  ├─ I8.1 改动 M14 setup.sh(meta-* 过滤 + line 71 改 source + 末尾提示)
  ├─ I8.2 改动 docs/active/handoff.md 模板(加 skip 字段示例 + 反审待办字段示例)
  └─ I8.3 改动 docs/references/testing-standard.md(顶部加适用域声明)

测试任务(T 系列):
  ├─ T1-T3 单元测试(hook 内部逻辑)— 与 I6.x 同批
  ├─ T4-T8 集成测试(hook + scope.conf + audit + handoff 联动)— 批次 8 后
  ├─ T9 E2E 测试(完整 meta 改动 commit 路径)— 全 I 完成后
  ├─ T10 setup.sh 分发隔离测试 — I8.1 后
  └─ T11 bootstrap 自洽反审本 spec 测试 — 全部完成后(meta-L4 留痕)
```

**依赖原则总结**:
- M2 必须在 M6-M13 之前(prompt 引 M2 pattern 节)
- M17 必须在 M15/M16 之前(hook 读 scope.conf)
- M18 必须在 M15 之后(注册 M15 hook)
- M19 必须在 M18 之后(模板需先看 M18 结构)
- M14 必须在所有需分发的文件之后(M14 改 setup.sh 加过滤逻辑)
- M3 升级独立于 M4 调整(不同物理文件,但二者在 batch 4 内同步以保 feature 部分对齐)
- M20 反审检测段独立于 M15/M16(不同 hook 类型,但读取相同 audit covers 数据,因此 C2 是共同前置)

---

## 3. 契约任务(C 系列 — 必须先做,精确定义)

> 契约任务规定的是跨模块/跨角色共享的精确格式。这些是后续实现任务的"合同",不能被实现 agent 自由解释。

### 任务 C1:定义 M17 meta-scope.conf 配置内容

**类型**:契约任务(配置数据格式)
**关联模块**:M17
**依据**:spec §3.1.1 / §4.1.2 / D18 / D22 fix-9 (v)

**操作**:按 spec §4.1.2 锁定 meta-scope.conf 的完整内容(每行一条 glob,`#` 注释,`!` 排除前缀)。

**精确内容**(第八轮 fix-9 (v) 修后版本):

```
# meta-scope.conf - hook 读取的 scope 配置
# 每行一条 glob 规则,! 前缀为排除
# 由 M15 check-meta-review.sh 和 M16 check-meta-commit.sh 读

# === A 组:governance + 核心规则 ===
docs/governance/*.md
CLAUDE.md

# === B 组:.claude/hooks/* + settings ===
.claude/hooks/*.sh
.claude/settings.json
.claude/settings.local.json

# === C 组:skills + agents ===
.claude/skills/*/SKILL.md
.claude/agents/*.md

# === D 组:RUBRIC + DESIGN_TEMPLATE ===
docs/RUBRIC.md
docs/references/DESIGN_TEMPLATE.md

# === F 组:setup.sh + 分发模板 ===
setup.sh
harness/CLAUDE.md
harness/templates/*.json

# === 排除规则(第八轮 fix-9 (v) 修)===
# 只排除流程产出物(audit 文件本身,避免自循环)
# 不排除治理文件(meta-*.sh / meta-*.md / meta-scope.conf)— 治理文件入 scope
!docs/audits/meta-review-*.md
!docs/audits/archive/**
```

**关键点**(实现时不可偏离):
- 治理文件(`meta-*.sh` / `meta-*.md` / `meta-scope.conf`)**不在排除规则**(D22 fix-9 (v) 修)
- 流程产出物(`docs/audits/meta-review-*.md` / `docs/audits/archive/**`)**必须排除**(避免自循环)
- F 组 `harness/templates/*.json` 是 fix-1 修补,M19 入 scope 必须触发 meta-review
- E + G 组(ROADMAP / PROGRESS / handoff / README / QUICKREF / 用户文档)**不需列**(不命中 scope 内 glob 即等同 scope 外)

---

### 任务 C2:定义 audit YAML frontmatter `covers` 字段格式

**类型**:契约任务(数据结构)
**关联模块**:M2(写入)/ M15 / M16 / M20(读取)
**依据**:spec §3.1.4 Step 5 / §3.1.9 / §4.1.1 / D22 fix-9 (iii)

**操作**:按 spec §4.1.1 锁定 audit 文件 YAML frontmatter 的精确格式。

**精确格式**:

```markdown
---
meta-review: true
covers:
  - <仓库相对路径 1>
  - <仓库相对路径 2>
  ...
---

# meta-review audit — [主题]

## 1. 元信息
## 2. 维度选取
## 3. 挑战者执行记录
## 4. 综合
## 5. 判定
```

**字段语义**(契约层,spec §4.1.1 AuditTrail 接口):

| 字段 | 类型 | 必填 | 含义 |
|---|---|---|---|
| `meta-review` | boolean,固定 `true` | ✅ | 标识本文件是 meta-review audit(供 hook grep 识别) |
| `covers` | string 数组(仓库相对路径) | ✅,**非空数组** | 本 audit 覆盖的 scope 内文件路径;空 = 等价于未走流程 |

**fix-9 (iii) 修补关键点**(M15/M16/M20 hook 实现必须遵守):
- `covered_files` 计算 = `⋃ {audit.yaml_frontmatter.covers : audit ∈ 有效 audit 集}`(不是"audit 存在 + 主题相关"即视为覆盖)
- `uncovered = changed_meta_files - covered_files`(失效后)
- 若 `changed_meta_files` 中有文件不在任何有效 audit 的 `covers` 字段 → 视为未覆盖,触发引导/拦截

**audit 失效规则**(spec §4.1.5 / D14):
- 对每个 audit 的每个 covers 文件,比较 `audit_mtime` vs `git log -1 --format=%ct -- <covered_file>`
- 若 covered 文件最新 commit time > audit_mtime → 该文件对此 audit 失效
- 单文件可能在多个 audit covers 中:任一未失效的 audit 即覆盖

---

### 任务 C3:定义 handoff 两个字段格式(skip + 反审待办)

**类型**:契约任务(handoff 字段格式)
**关联模块**:M1(引导写入)/ M15 / M16(读取 skip)/ M20(读取反审待办,可选)
**依据**:spec §4.1.3(skip)+ §4.1.7(反审待办)+ D21 fix-8 C 部分

**操作**:按 spec §4.1.3 / §4.1.7 锁定 handoff.md 内两个独立字段的精确格式。

**字段 1:`handoff_meta_review_skip`**(每次 meta 改动可覆盖,短期)

```markdown
## meta-review: skipped(理由: <非空理由>)
```

**hook 读取规则**(M15 / M16):
- grep 匹配:`## meta-review: skipped\(理由: ([^)]+)\)`
- reason 非空(至少一个非空白字符)→ skip 有效,exit 0
- reason 空 → skip 无效,继续要求 audit

**字段 2:`handoff_self_review_pending`**(P0.9.1 落地后长期,直到反审完成)

初始值(P0.9.1 落地最后一次 finishing 写入):

```markdown
## 反审待办

P0.9.1 落地反审 — 未完成
```

完成后(反审 audit 产出后):

```markdown
## 反审待办

P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`
```

**关键点**:
- 两字段 marker 不同(`## meta-review: skipped` vs `## 反审待办`),共存于同一 handoff
- skip 字段每次 meta 改动可覆盖;反审待办字段保留至反审完成
- **权威依据**:M20 SessionStart hook 按 audit covers 判定反审是否完成,handoff 反审待办字段是辅助留痕(失同步以 covers 为准)

---

### 任务 C4:定义 M2 审查维度三段 pattern 节内容(模态分型)

**类型**:契约任务(prompt 结构契约)
**关联模块**:M2(定义)/ M6-M9(消费)
**依据**:spec §3.1.4 / §3.1.6 / D2(模态分型)/ D7(bootstrap 4 维)

**操作**:在 M2 `docs/governance/meta-review-rules.md` 内含一节"审查维度三段 pattern(供对抗式 agent 引用)",按 D2 决策按 agent 模态分型给出三套精确模板。

**精确节标题**:`## 审查维度三段 pattern(供对抗式 agent 引用)`

**精确子结构**(三套模板,实现时不可省略任一):

#### 子节 1:对抗式 agent(M6 design-reviewer / M7 evaluator)— A/B/C 三段全采用

```markdown
### 对抗式 agent prompt 模板

A. 推荐维度清单(按 agent 默认填,markdown 列表)
   格式:`- [维度名]: [关注焦点] [默认启用: 是/否]`

B. 最低必选维度(禁止删减,markdown 列表)
   格式:`- [维度名]: [不可省略理由]`
   bootstrap 4 维基线(任何 meta 改动必须包含):
     - 核心原则合规
     - 目的达成度
     - 副作用
     - scope 漂移

C. 定制理由字段(结构化)
   ### 本次定制
   - 启用的推荐维度: [列表]
   - 禁用的推荐维度 + 理由: [列表](禁用 minimum 项需用户确认)
   - 新增的定制维度 + 理由: [列表]
```

#### 子节 2:混合式 agent(M8 security-reviewer)— 部分 A/B/C

```markdown
### 混合式 agent prompt 模板

X. 凭证 / 数据扫描 pattern(硬编码,不变)
   格式同现 security-reviewer.md(pattern grep 列表 + Critical/High/Medium 标级)

A. 推荐对抗维度(仅在"扫描后场景判定"维度采用)
   例:凭证泄露的风险等级判定 / 危险操作的副作用范围

B. 最低必选对抗维度
   - 凭证泄露场景判定(M8 永远不可绕)

C. 定制理由字段(格式同对抗式 C 段)
```

#### 子节 3:事实统计式 agent(M9 process-auditor)— 不强加 A/B/C,N 维分工

```markdown
### 事实统计式 agent prompt 模板

N1. 流程遵从度(固定维度,可细化粒度)
N2. 效果满意度(固定维度,可细化粒度)
G.  调度者按主题细化粒度(可选)
    ### 本次粒度细化
    - 范围: [全 session / 本批次 / 时间窗口]
    - 维度细化: [每维度内的子项]
```

**fix-2 配套约束**(实现 M6-M9 时必须遵守):
- agent 文件 prompt **只放结构占位 + 引用 M2 路径**
- **禁止抄 M2 实文**(meta-review 流程描述 / scope 规则 / scope.conf glob 等)
- meta 治理实文仅由调度者运行时(§3.1.7)读 + 嵌入 — 这样 setup.sh 把 agent 分发到下游时,下游 agent 文件不含 meta 语境

---

### 任务 C5:定义 M19 templates/settings.json 与 M18 的差异规约

**类型**:契约任务(双轨模板差异点)
**关联模块**:M18(harness 自身)/ M19(分发模板)
**依据**:spec §4.1.6 / §3.1.8 / D19 a 方案

**操作**:精确锁定 M19 与 M18 的唯一差异点 — Stop hook 数组中是否含 M15 注册条目。

**精确差异规约**:

| 字段 | M18(harness 自身用) | M19(分发模板) |
|---|---|---|
| `hooks.PostToolUse` | 现状不变 | 同 M18 |
| `hooks.PreToolUse` | 现状不变 | 同 M18 |
| `hooks.SessionStart` | 现状不变(含 session-init.sh)| **同 M18(注:session-init.sh 反审检测段需在分发版本内 sed 删除,见 I8.1)** |
| `hooks.Stop` | **追加** M15 `check-meta-review.sh` 注册条目 | **不含** M15 注册条目;其余条目同 M18 |

**M19 Stop 数组示例**(按 D19 a 方案):

```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-handoff.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-finishing-skills.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-evidence-depth.sh" }
      /* 不含 M15 check-meta-review.sh — 这是 M18 vs M19 唯一差异 */
    ]
  }
]
```

**关键点**:
- M19 是新建文件(分发模板),M18 是 harness 自身用文件,二者**双轨独立维护**
- 加 meta hook 时只改 M18,不动 M19(M19 永远不含 meta hook 注册段)
- 加 feature hook(罕见)时需同步改 M18 + M19
- 实施层备注:可用 jq diff 自动校对 M18/M19 除 meta hook 段外结构一致(实施阶段定具体方式)

---

## 4. 实现任务(I 系列,按批次,问题式)

> 实现任务描述"要解决的问题和约束",不规定具体实现路径。实现 agent 比 planner 更接近代码状态,由它决定具体实现方式。

### 批次 1:契约前置(无 I 任务,见 §3 C1-C5)

### 批次 2:数据层

#### 任务 I2.1:实现 M17 meta-scope.conf

- **关联模块**:M17(新建)
- **关联场景**:场景 1 配置层(B+ 弹性)
- **依赖**:C1
- **问题**:harness 需要一份**外部化的 scope 配置数据**,让 hook 读这份数据决定哪些文件改动属于 meta scope,scope 扩展时不改 hook 代码
- **约束**:
  - 文件路径:`.claude/hooks/meta-scope.conf`(spec §2.1 / §4.1.2 锁定)
  - 内容**逐字遵循 C1 契约**(每行一条 glob,`#` 注释,`!` 排除)
  - **不排除治理文件**(D22 fix-9 (v) 修)
  - **必须排除流程产出物**(`!docs/audits/meta-review-*.md` / `!docs/audits/archive/**`)
  - 文件采用 UTF-8,行尾 LF;方便后续 awk/grep 解析
- **验证标准**:
  - 文件存在且按 C1 内容写入
  - 每行 glob 在 hook 解析时(`while read line` + 跳过 `#` 开头)能正确解析为 include / exclude 列表
  - 改动 `meta-scope.conf` 自身能被 M15 / M16 hook 识别为 scope=meta(因为 `meta-scope.conf` 命中 `.claude/hooks/*.sh` 的同目录但需用其他 glob — 实现层确认:**M17 自身入 scope 必须验证**;若 `.claude/hooks/*.sh` 不命中 `.conf` 后缀,需在 C1 内显式追加 `.claude/hooks/meta-scope.conf` 一行)
- **模块文档**:M17 新建,需新建 README:**否**(配置数据无独立 README;在 M2 内说明数据契约即可,见 spec §4.1.2 已定义)
  - **替代方案**:在 M17 conf 文件顶部注释块详尽说明字段语义与扩展方式(等价于内嵌 README)

**实现 agent 注意事项**:
- C1 契约中 F 组列了 `harness/templates/*.json`(M19 入 scope),但 M17 自身路径 `.claude/hooks/meta-scope.conf` 是否被 B 组 `.claude/hooks/*.sh` 命中?**答**:`.sh` 不命中 `.conf`。需在 conf 内显式追加 `.claude/hooks/meta-scope.conf` 一行(或扩 B 组为 `.claude/hooks/*`)。请实现 agent 在 I2.1 实现前先确认此 glob 覆盖问题,并在不偏离 C1 语义的前提下补漏。

---

### 批次 3:治理基础

#### 任务 I3.1:实现 M2 meta-review-rules.md

- **关联模块**:M2(新建)
- **关联场景**:场景 1 主体 + 场景 3 一致性锚点
- **依赖**:C2 / C4
- **问题**:harness 需要一份独立的"meta-review 流程契约"governance 文件,定义:
  1. meta-review 何时触发(scope=meta 或 mixed)
  2. 挑战者数量弹性(N 由主题 + 模态决定,不固定 4)
  3. audit 产物规范(YAML covers 字段 + 5 段正文,见 C2)
  4. audit 失效规则(git commit time vs audit mtime,详见 spec §4.1.5)
  5. 内含**审查维度三段 pattern 节**(逐字遵循 C4)
- **约束**:
  - 文件路径:`docs/governance/meta-review-rules.md`(spec §2.1 锁定)
  - 命名前缀 `meta-`(供 M14 setup.sh 命名前缀过滤)
  - 内容覆盖 spec §3.1.4 流程契约 + §3.1.5 挑战者调用契约 + §3.1.6 三段结构契约
  - C4 pattern 节按 agent 模态分型给出三套模板(对抗式 / 混合式 / 事实统计式)
  - 单 prompt 字节软上限(D5):建议 ~64 kB,具体数值在本任务实施时拍板(留给实现 agent)
  - **不在 M2 内重复 spec 已写过的全部内容**:M2 是 governance 文件(供运行时读),不是 spec 复制;引用 spec § 章节即可
- **验证标准**:
  - 文件存在,按 spec §3.1.4 / §3.1.6 主结构组织
  - C4 pattern 节存在且按 D2 模态分型给三套模板
  - bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)在 B 段最低必选维度明示
  - 测试:用 grep 能在文件内匹配到对抗式 / 混合式 / 事实统计式三种模态描述
- **模块文档**:M2 是 governance 文件,本身就是文档;无需另建 README

#### 任务 I3.2:实现 M1 meta-finishing-rules.md

- **关联模块**:M1(新建)
- **关联场景**:场景 2 主体
- **依赖**:I3.1(M1 引用 M2 的 audit 归档位置)
- **问题**:harness 需要一份独立的"meta 改动 finishing 引导"governance 文件,定义:
  1. meta 改动的 finishing 四步(spec §3.1.3 Step A-D)
  2. 内含 meta evidence depth 定义节(meta-L1 ~ meta-L4,spec §4.1.4)
  3. 引导调度者写 handoff `## meta-review: skipped(理由)` 字段(spec §4.1.3,逐字遵循 C3 字段 1)
  4. 引导调度者在 P0.9.1 落地最后一次 finishing 写 handoff `## 反审待办` 字段(spec §4.1.7,逐字遵循 C3 字段 2)
  5. 引导调度者在反审完成后更新反审待办字段为"已完成 — audit:<path>"
- **约束**:
  - 文件路径:`docs/governance/meta-finishing-rules.md`(spec §2.1 锁定)
  - 命名前缀 `meta-`
  - meta evidence depth 节按 spec §4.1.4 定义 meta-L1 ~ meta-L4 + handoff 三种 scope 填法示例(feature / meta / mixed)
  - decision 立档采用 `2026-04-17-harness-self-governance-gap.md` 范式(D9):标 "Bootstrap 声明" 或 "根源承认型"
  - **不重复** spec §3.1.3 的全部细节;引用 spec § 章节即可
- **验证标准**:
  - 文件存在,按 spec §3.1.3 四步结构组织
  - meta evidence depth 节存在,按 spec §4.1.4 定义 meta-L1~meta-L4
  - mixed scope 8 行示例完整(spec §4.1.4 fix-4 必给示例)
  - 反审待办字段引导(C3 字段 2)写入"P0.9.1 落地最后一次 finishing"步骤
- **模块文档**:M1 是 governance 文件,无需另建 README

---

### 批次 4:入口治理

#### 任务 I4.1:升级 M3 /CLAUDE.md(harness 仓库根)

- **关联模块**:M3(改动 — 升级)
- **关联场景**:场景 1 入口 / 场景 2 入口(harness 自身)
- **依赖**:I3.1 / I3.2(M3 链接到 M1 / M2)
- **问题**:`/CLAUDE.md`(harness 仓库根)当前仅 5 行导航,**升级为 harness 自身的治理入口**,使调度者每次会话开头读它就能识别 meta vs feature 分流
- **约束**:
  - 文件路径:`/CLAUDE.md`(harness 仓库根,**不是** `harness/CLAUDE.md`)
  - 内容必须包含:
    1. 角色分离表(可借鉴 `harness/CLAUDE.md` 现有内容)
    2. 治理规则表(meta + feature 双路)
    3. **scope 触发判定段落**(人类可读对照表,与 M17 scope.conf 保持同步)
    4. **meta vs feature 分流引导**(链接到 M1 / M2 / M5)
    5. scope 内对照表(A+B+C+D+F)
  - **保持简洁**:升级不是重写,M3 是入口非细节文档,详情链接到 M1 / M2 / 其他 governance
  - **不分发下游**(D12 命名前缀过滤天然不分发,因为 setup.sh `$SCRIPT_DIR/CLAUDE.md` 实指 `harness/CLAUDE.md` = M4)
- **验证标准**:
  - 文件升级后含 5 段(角色分离 / 治理规则 / scope 判定 / 分流引导 / scope 对照表)
  - scope 触发判定段落与 M17 scope.conf 内容**对照同步**(任一改动需同步另一,审查时能 grep 验证一致性)
  - 链接 M1 / M2 / M5 路径准确
  - 文件长度合理(估 50-150 行,具体由实现 agent 控制)
- **模块文档**:M3 自身是入口文档,无需另建 README

#### 任务 I4.2:改造 M5 finishing-rules.md(加 scope 分流入口)

- **关联模块**:M5(改动)
- **关联场景**:场景 2 分流
- **依赖**:I3.2(M5 引向 M1)
- **问题**:`docs/governance/finishing-rules.md` 是 feature 侧 finishing 规则,需要在文件**头部加 scope 分流判定入口**,使进入 finishing 阶段时能区分 meta vs feature 路径
- **约束**:
  - 文件路径:`docs/governance/finishing-rules.md`(已存在)
  - **最小变更**:仅加分流入口段落,不改其他内容
  - 分流入口位置:文件**最顶部**(读取者第一眼看到)
  - 分流逻辑:
    - 判 meta(scope 标签为 "meta" 或 "mixed")→ 引向 M1 `meta-finishing-rules.md`
    - 判 feature/none → 继续现有 finishing-rules.md 流程
  - 分流入口需要明示 scope 识别参考 `/CLAUDE.md` 的 scope 触发判定段落
  - **保持下游兼容**:M5 分发下游;feature 路径不变,meta 路径在下游不存在(meta-finishing-rules 不分发)— 引向 M1 的链接在下游显示为不存在文件,但 feature 改动不会触达此分支,无影响
- **验证标准**:
  - 文件顶部有 scope 分流段落
  - 分流条件明示("meta 改动 → M1;feature/none → 本文件")
  - 现有 finishing-rules 内容**逐字保留**(diff 应只是新增段落 + 极小调整)
- **模块文档**:M5 是 governance 文件,无需另建 README

#### 任务 I4.3:调整 M4 harness/CLAUDE.md(分发模板)

- **关联模块**:M4(改动 — 轻)
- **关联场景**:下游分发(不在 P0.9.1 主流程触发)
- **依赖**:I4.1(M4 与 M3 的 feature 部分对齐)
- **问题**:`harness/CLAUDE.md` 是分发到下游的模板,**不能含 meta 段落**;但其 feature 部分需要与 M3 升级后的 feature 部分对齐(避免 harness 自身和下游对 feature 流程描述不一致)
- **约束**:
  - 文件路径:`harness/CLAUDE.md`(已存在)
  - **明确不加 meta 段落**(scope 触发判定 / meta-finishing 引导等)
  - **轻改动**:校对现有内容仍准确;若 M3 的 feature 流程描述有更新(如治理表 feature 部分),同步到 M4
  - **保持下游清洁**:下游用 harness 但不改 harness 自身,M4 仅含 feature 层规则
- **验证标准**:
  - 文件不含 `meta-` 前缀的任何治理引用
  - 文件不含 `## scope 触发判定` 类段落
  - feature 流程描述与 M3 一致(如有同名段落)
  - diff 较小(估 < 30 行变化)
- **模块文档**:M4 是分发模板,无需另建 README

---

### 批次 5:agent / skill 改造

> 共 8 任务(I5.1-I5.8)。前 4 任务(I5.1-I5.4)改 agent prompt,后 4 任务(I5.5-I5.8)改 skill 执行节。

#### 任务 I5.1:改造 M6 design-reviewer.md(对抗式 A/B/C)

- **关联模块**:M6(改动)
- **关联场景**:场景 3
- **依赖**:I3.1(M6 引 M2 路径)
- **问题**:`design-reviewer.md` 4 挑战者 prompt 段落需要按对抗式 A/B/C 三段改造,使 meta-review 时维度可定制化
- **约束**:
  - 文件路径:`.claude/agents/design-reviewer.md`(已存在)
  - **prompt 改造按 D2 决策对抗式模态**:A 推荐 + B 最低必选 + C 定制理由
  - **fix-2 静态约束**(spec §3.1.6):
    - prompt 只放**结构占位 + 引用 M2 路径**
    - **禁止抄 M2 实文**(meta-review 流程描述 / scope 规则 / scope.conf glob 等)
    - 只引"在 harness 自身仓库时,调度者按 §3.1.7 runtime 嵌入契约 Read M2 / M1 必要节并嵌入挑战者 prompt"指引
  - B 段最低必选维度只列维度名(如 "核心原则合规"),**不展开** M2 中关于何时强制的具体规则文本
  - **保留** 4 挑战者结构(每挑战者一个段落);改造的是每挑战者 prompt 结构,不是挑战者数量
  - bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)作为 B 段基线
- **验证标准**:
  - 4 挑战者每个 prompt 含 A/B/C 三段标识
  - grep `meta-review-rules.md` 路径引用(应有);grep M2 实文(如"光谱 B+ hook 拦截逻辑")(应无)
  - bootstrap 4 维在 B 段明示
  - **下游兼容性**:agent 文件**分发下游**(不是 meta-* 前缀);确认下游获得维度定制能力但 meta 段落不存在
- **模块文档**:agent 文件本身是 prompt 文档,无需另建 README;在文件顶部注释说明 prompt 结构变更原因

#### 任务 I5.2:改造 M7 evaluator.md(对抗式 A/B/C + scope 分流引 evidence depth)

- **关联模块**:M7(改动)
- **关联场景**:场景 3
- **依赖**:I3.1 / I3.2(引 M2 路径 + M1 evidence depth 节)
- **问题**:`evaluator.md` 4 挑战者 prompt 同 I5.1 改造为对抗式 A/B/C;额外按 fix-6 接收 `scope` 参数(meta/feature/mixed)按 scope 分流引相应 evidence depth 文件
- **约束**:
  - 文件路径:`.claude/agents/evaluator.md`(已存在)
  - 同 I5.1 全部约束(D2 对抗式 A/B/C + fix-2 静态约束)
  - **fix-6 scope 分流**(spec §3.1.6):
    - prompt 接收 `scope` 参数
    - scope=feature → 引 `docs/references/testing-standard.md`(L1-L4)
    - scope=meta → 引 `docs/governance/meta-finishing-rules.md` 内含 evidence depth 节(meta-L1~meta-L4)
    - scope=mixed → 同时引两份(spec §4.1.4 mixed 8 行示例)
  - 4 维度(RUBRIC 合规 / 架构一致性 / 文档健康 / Slop)同时改造 A/B/C 三段
- **验证标准**:
  - 同 I5.1 验证标准
  - prompt 内有 `scope` 参数处理逻辑(伪代码或描述)
  - scope=meta 路径引 `meta-finishing-rules.md`(不引 testing-standard.md L1-L4)
  - mixed scope 同时引两份
- **模块文档**:同 I5.1

#### 任务 I5.3:改造 M8 security-reviewer.md(混合式 部分 A/B/C)

- **关联模块**:M8(改动)
- **关联场景**:场景 3 + 安全不降级
- **依赖**:I3.1
- **问题**:`security-reviewer.md` 3 挑战者 prompt 按 D2 决策**混合式**改造:凭证 / 数据 / 危险操作 / 注入混淆**硬编码 pattern 列表不变**;**对抗维度部分**采用 A/B/C 三段
- **约束**:
  - 文件路径:`.claude/agents/security-reviewer.md`(已存在)
  - **硬编码扫描部分 pattern 列表保留不动**(spec §3.1.6 子节 2 X 段)
  - **对抗维度部分**(场景判定 / 风险等级判定)按 A/B/C 三段
  - B 段最低必选:**凭证泄露场景判定固定为不可绕**(M8 永远不可绕,重要安全保证)
  - fix-2 静态约束同 I5.1
- **验证标准**:
  - 硬编码 pattern 列表段落 diff 为 0(完全不变)
  - 对抗维度部分含 A/B/C 三段标识
  - "凭证泄露场景判定"在 B 段明示为最低必选
- **模块文档**:同 I5.1

#### 任务 I5.4:改造 M9 process-auditor.md(事实统计式 N 维分工)

- **关联模块**:M9(改动)
- **关联场景**:场景 3
- **依赖**:I3.1
- **问题**:`process-auditor.md` 2 挑战者 prompt 按 D2 决策**事实统计式**改造:**保留分工 N 维**(流程遵从度 / 效果满意度),**不强加 A/B/C**;允许调度者按主题"细化统计粒度",该细化点登记到 audit
- **约束**:
  - 文件路径:`.claude/agents/process-auditor.md`(已存在)
  - **不引入 A/B/C 三段**(spec §3.1.6 子节 3)
  - 保留 2 维分工(N1 流程遵从度 / N2 效果满意度)
  - 加 G 段:调度者按主题细化粒度(可选)
  - granularity_customization 字段格式:`### 本次粒度细化\n- 范围: ...\n- 维度细化: ...`
  - fix-2 静态约束同 I5.1(粒度细化只引 M2 路径,不抄 M2 实文)
- **验证标准**:
  - 2 维分工保留(grep "流程遵从度" / "效果满意度" 应命中)
  - **不含** A/B/C 三段标识(grep "## A. 推荐" 应未命中,因为这是对抗式标识)
  - G 段(粒度细化)存在
- **模块文档**:同 I5.1

#### 任务 I5.5:改造 M10 design-review SKILL.md(执行节引 M2)

- **关联模块**:M10(改动)
- **关联场景**:场景 3
- **依赖**:I5.1
- **问题**:`design-review` skill 的"执行"节需要引 M2 维度选取步骤,使调度者执行 skill 时知道:scope=meta 时按 M2 pattern 节读 M2 + 嵌入挑战者 prompt
- **约束**:
  - 文件路径:`.claude/skills/design-review/SKILL.md`(已存在)
  - **执行节最小变更**:仅加 M2 引用,不改其他执行步骤
  - **不**新增 `!` 注入(D3 决策 — `!` 注入在下游也执行,M2 在下游不存在)
  - 引导:调度者识别 scope=meta(参 §3.1.1)后,**手工** Read M2 / M1 必要节 + 嵌入挑战者 prompt
  - **下游兼容**:skill 分发下游;下游执行 `/design-review` 时调度者识别 scope=feature,自然不触发 meta 嵌入,行为完全不变
- **验证标准**:
  - 执行节有"按 §3.1.7 runtime 嵌入"或类似引导
  - 现有 skill 调用接口/参数不变(向后兼容,spec §3.1.4 B6 兼容性声明)
  - 下游执行时不触发 meta 路径(条件化 scope=meta 才嵌入)
- **模块文档**:skill SKILL.md 自身是文档,无需另建 README

#### 任务 I5.6:改造 M11 evaluate SKILL.md(同 I5.5)

- **关联模块**:M11(改动)
- **关联场景**:场景 3
- **依赖**:I5.2
- **问题**:同 I5.5,但针对 evaluate skill,且配合 I5.2 的 fix-6 scope 参数传递
- **约束**:
  - 文件路径:`.claude/skills/evaluate/SKILL.md`(已存在)
  - 同 I5.5 全部约束
  - 额外:执行节需引导调度者向挑战者 prompt 传 `scope` 参数(meta/feature/mixed)
- **验证标准**:
  - 同 I5.5
  - 执行节明示 `scope` 参数传递(实现层细节由实现 agent 定)
- **模块文档**:同 I5.5

#### 任务 I5.7:改造 M12 security-scan SKILL.md(同 I5.5,仅对抗维度部分)

- **关联模块**:M12(改动)
- **关联场景**:场景 3
- **依赖**:I5.3
- **问题**:同 I5.5,但 M12 对应混合式 agent — skill 执行节仅引 M2 **对抗维度部分**,硬编码扫描部分输入注入不变
- **约束**:
  - 文件路径:`.claude/skills/security-scan/SKILL.md`(已存在)
  - 同 I5.5 全部约束
  - 额外:**仅对抗维度部分**引 M2 pattern;硬编码扫描部分(凭证 / 数据 / 危险 / 注入 pattern grep)输入不变
- **验证标准**:
  - 同 I5.5
  - 硬编码扫描部分相关执行步骤不变
  - 对抗维度部分加 M2 引用
- **模块文档**:同 I5.5

#### 任务 I5.8:改造 M13 process-audit SKILL.md(引 M2 粒度细化子节)

- **关联模块**:M13(改动)
- **关联场景**:场景 3
- **依赖**:I5.4
- **问题**:同 I5.5,但 M13 对应事实统计式 agent — skill 执行节引 M2 关于"事实统计式按主题细化粒度"的子节(**不引** A/B/C pattern)
- **约束**:
  - 文件路径:`.claude/skills/process-audit/SKILL.md`(已存在)
  - 同 I5.5 全部约束
  - 额外:**仅引 M2 G 段(粒度细化)**;**不引** A/B/C 三段
- **验证标准**:
  - 同 I5.5
  - 执行节引 M2 G 段粒度细化引导
  - 不含 A/B/C 引用
- **模块文档**:同 I5.5

---

### 批次 6:hook 层

#### 任务 I6.1:实现 M15 check-meta-review.sh(Stop hook)

- **关联模块**:M15(新建)
- **关联场景**:场景 1 执法触点 1(光谱 B+)
- **依赖**:C1 / C2 / I2.1 / I3.1
- **问题**:harness 需要一个 Stop hook,在每次 session 末扫 git diff,若改动命中 scope.conf 但无 audit covers 覆盖且无 handoff skip 理由 → 引导补 audit / 阻断 stop
- **约束**:
  - 文件路径:`.claude/hooks/check-meta-review.sh`(新建)
  - 命名前缀 `check-meta-` ,符合 setup.sh `meta-*` 命名前缀过滤(D12)
  - **协议**:Claude Code Stop hook(从 stdin 读 JSON `{"stop_hook_active": bool, ...}`)
  - **防死循环**:`if stop_hook_active == true: exit 0`(参考现有 check-handoff.sh 范式)
  - **逻辑**(spec §3.1.9 + D22 fix-9 (iii) 修补):
    1. 读 M17 scope.conf(grep 跳 `#` 注释,分 include / exclude 列表)
    2. 扫 git diff(unstaged + staged)文件列表
    3. 过滤命中 scope 内 glob → `changed_meta_files`
    4. 应用排除规则(只排除 audit / archive,**不排除治理文件** — D22 fix-9 (v) 修)
    5. 若 `changed_meta_files` 为空: exit 0
    6. 若非空:
       a. 扫 `docs/audits/meta-review-*.md` + `docs/audits/archive/INDEX.md` 近 12 个月条目的 YAML `covers:` 字段并集 → `covered_files`(有效 audit 集,即未失效;失效规则按 §4.1.5 git commit time 比对)
       b. **fix-9 (iii) 修补**:`uncovered = changed_meta_files - covered_files`(失效后);若 `changed_meta_files` 中有文件不在任何有效 audit 的 covers 字段 → uncovered
       c. 若 uncovered 为空: exit 0
       d. 若 uncovered 非空: 检 handoff `## meta-review: skipped(理由: <非空>)` 字段(grep 模式 `理由:\s*[^)]+`)
          - 有效 skip → exit 0
          - 无 → echo 引导消息(列出 uncovered 文件 + 处理方式)+ exit 2(阻断 stop)
  - **错误处理**(graceful degrade,与 check-handoff.sh 范式一致):
    - M17 配置缺失/损坏 → echo "⚠️ meta-scope.conf 不可读" + exit 0
    - audit YAML 解析失败 → echo "⚠️ audit YAML 损坏: <文件>" + exit 0;视该 audit 不存在
    - git diff 调用失败(非 git 仓库) → exit 0
    - jq / awk / sed 缺失 → echo "⚠️ jq 缺失,hook 降级跳过" + exit 0
  - **D19 a 方案**:hook 内**不加** marker 检查 / 条件 exit 0(那是 b 方案);a 方案下下游根本无此 hook 文件 + 注册,无需自防
  - **不分发下游**(命名前缀 `meta-` 由 M14 setup.sh 过滤)
- **验证标准**:
  - 单元测试:输入构造的 git diff + audit + handoff 状态,验证 exit code 0/2 正确
  - **覆盖关键路径**:
    - changed_meta_files 空 → exit 0
    - changed_meta_files 非空 + 全部覆盖 → exit 0
    - changed_meta_files 非空 + uncovered 非空 + skip 理由有效 → exit 0
    - changed_meta_files 非空 + uncovered 非空 + 无 skip 理由 → exit 2(stderr 引导消息含文件列表)
    - audit covers 失效(fix-9 (iii):covers 字段未列改动文件) → 应识别为 uncovered
    - bootstrap 循环测试:改 `meta-scope.conf` 自身或 `meta-review-rules.md` → 应被 hook 识别为 scope=meta(因 fix-9 (v))
- **模块文档**:M15 是 hook,**hook 内顶部注释**说明用途、协议、防死循环、错误处理方式;无需另建 README

#### 任务 I6.2:实现 M16 check-meta-commit.sh(git pre-commit hook)

- **关联模块**:M16(新建)
- **关联场景**:场景 1 执法触点 2(光谱 B+)
- **依赖**:C1 / C2 / I2.1 / I3.1 / I6.1(共享逻辑函数,可参考但 M16 是独立文件)
- **问题**:harness 需要一个 git pre-commit hook,扫 staged 改动同 M15 逻辑,缺 audit / skip 理由则拦 `git commit`
- **约束**:
  - 文件路径:`.claude/hooks/check-meta-commit.sh`(新建)
  - 命名前缀 `check-meta-`
  - **协议**:Git pre-commit hook(无 stdin JSON,仅退出码语义 — exit 0 放行,exit 1 阻断 commit)
  - **逻辑**:同 M15,**用 `git diff --cached` 代替 `git diff`**(scan staged 而非 unstaged + staged)
  - **不需** `stop_hook_active` 判断(git pre-commit 无此协议)
  - 错误处理同 M15(graceful degrade)
  - **安装方式**:M16 不通过 .claude/settings.json 注册(M16 是 git hook,通过 `.git/hooks/pre-commit` 软链接安装)。**实施阶段定具体安装方式**(候选:
    - 在 setup.sh 内加 `ln -sf $SCRIPT_DIR/.claude/hooks/check-meta-commit.sh $TARGET_DIR/.git/hooks/pre-commit`
    - 或在 harness 自身仓库手工创建 `.git/hooks/pre-commit` 软链接
  - 由实施阶段决定 — 但**对 harness 自身**:必须有可执行的安装路径,确保 git commit 时实际触发 M16
  - **不分发下游**(M16 通过 git hook 机制本来就不通过 setup.sh `cp` 分发;但 setup.sh 末尾若加 `ln -sf` 则是分发 — 此处需注意:M16 是 harness 自身用,下游不需要,setup.sh 不应给下游 ln M16)
- **验证标准**:
  - 单元测试:覆盖 M15 同样 4 类路径(空 / 全覆盖 / 有效 skip / 无效 skip)
  - 集成测试:在 harness 自身仓库 `git add` 一个 scope 内文件 + 不写 audit/skip → `git commit` 应被拦(exit 1 + stderr 消息)
  - 与 M15 共享逻辑(可重构为公共 shell 函数库),验证逻辑一致性
- **模块文档**:hook 内顶部注释说明;无需另建 README

#### 任务 I6.3:扩展 M20 session-init.sh(反审检测段)

- **关联模块**:M20(扩展现有)
- **关联场景**:场景 1 反审触发(fix-8 A 部分)
- **依赖**:C2 / I3.1 / I3.2(M20 读 audit covers + 与 M1 引导写的反审待办字段配合)
- **问题**:`.claude/hooks/session-init.sh` 已存在(SessionStart 时注入 PROGRESS / handoff)。需要扩展:加反审检测段 — 检测条件成立时注入 system-reminder 提醒反审本 spec
- **约束**:
  - 文件路径:`.claude/hooks/session-init.sh`(已存在,本任务是扩展)
  - **最小变更**:仅加反审检测段,不改其他注入逻辑
  - **协议**:Claude Code SessionStart hook(每次 session 启动触发)
  - **检测逻辑**(spec §3.1.10):
    1. 检测条件 1:`git log --format="%s" main`(主分支 commit message 列表),grep `"P0.9.1.*self-governance\|P0.9.1.*实施\|P0.9.1.*落地\|P0\.9\.1.*implementation"`
       - 无命中:不注入(P0.9.1 尚未落地);跳过本段
       - 有命中:进入条件 2
    2. 检测条件 2:扫 `docs/audits/meta-review-*.md`(及 `archive/INDEX.md` 缓存的 covers)的 YAML `covers:` 字段并集,grep 本 spec 路径(常量:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`)
       - 命中:不注入(反审已完成);跳过本段
       - 未命中:注入 system-reminder
  - **注入消息**(spec §3.1.10 锁定文案)
  - **不阻断**:仅注入 system-reminder,用户可选择忽略
  - **graceful degrade**(spec §3.1.10 错误处理):
    - git log 调用失败(非 git 仓库) → 跳过本段,不阻断 SessionStart 其他段
    - audit YAML 解析失败 → 视该 audit 不存在,继续判定
  - **下游分发隔离**:反审检测段不分发下游。**实施层定具体方式**(候选两选一):
    - 选项 1:用 marker 标记 `# === harness self-governance ===` 包裹此段,setup.sh sed 删除 marker 段
    - 选项 2:拆分为两文件 `session-init.sh` + `meta-self-review-detect.sh`,后者命名前缀 `meta-` 由 D12 自动过滤
  - **实现 agent 决定**:倾向选项 2(命名前缀机制更一致,与 D12 / M14 同思路);但若实现 agent 判选项 1 简单,可选 1 + 同步改 M14 sed 逻辑
- **验证标准**:
  - SessionStart 触发 → 检测段执行(可静态 review)
  - 模拟 git log 含 / 不含 P0.9.1 落地 commit → 行为正确
  - 模拟 audit covers 含 / 不含本 spec 路径 → 行为正确
  - graceful degrade:删 audit 文件 / 损坏 YAML → SessionStart 其他段仍正常注入
  - 下游分发隔离:`./setup.sh /tmp/test` 后,目标项目的 session-init.sh **不含** 反审检测段
- **模块文档**:hook 内顶部注释说明扩展原因 + 反审检测逻辑;无需另建 README

---

### 批次 7:settings 注册 + 分发模板

#### 任务 I7.1:改动 M18 .claude/settings.json(注册 M15)

- **关联模块**:M18(改动)
- **关联场景**:M15 注册
- **依赖**:I6.1(必须先有 M15 才能注册)
- **问题**:harness 自身 `.claude/settings.json` 需要在 Stop hook 数组追加 M15 注册条目,使 Claude Code 平台能在 Stop 时触发 M15
- **约束**:
  - 文件路径:`.claude/settings.json`(已存在)
  - **最小变更**:仅在 `hooks.Stop` 数组**追加**一个条目,不改其他段
  - 追加内容(精确,与现有条目同结构):

    ```json
    { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-meta-review.sh" }
    ```

  - **不注册 M16**(M16 是 git pre-commit,通过 `.git/hooks/pre-commit` 链接,非 Claude Code hook)
  - **不分发下游**(D19 a 方案 — 由 M14 setup.sh line 71 改 source 指向 M19 模板)
- **验证标准**:
  - JSON 文件结构合法(`jq . settings.json` 不报错)
  - Stop 数组含 M15 注册条目
  - 其他数组(PostToolUse / PreToolUse / SessionStart)diff 为 0
  - harness 自身 Stop 时实际触发 M15(可由 I6.1 集成测试覆盖)
- **模块文档**:M18 是配置数据,无需另建 README

#### 任务 I7.2:新建 M19 harness/templates/settings.json(分发模板)

- **关联模块**:M19(新建)
- **关联场景**:下游分发(零污染)
- **依赖**:C5 / I7.1(M19 与 M18 仅在 Stop 数组的 M15 注册条目处差异)
- **问题**:harness 需要一份分发模板 settings.json,结构同 M18 但**移除 M15 在 Stop hook 数组的注册条目**(以及未来任何 meta hook 注册);由 M14 setup.sh line 71 改造后的 source 拷贝到下游
- **约束**:
  - 文件路径:`harness/templates/settings.json`(新建,需先创建 `harness/templates/` 目录)
  - 内容**逐字遵循 C5 契约**(M19 = M18 在 Stop 数组移除 M15 注册条目)
  - **配合 fix-1 修补**(spec §1.3 + §4.1.6):M19 入 §1.3 F 组 scope + M17 scope.conf `harness/templates/*.json` glob — 改 M19 必须触发 meta-review,无后门
  - **维护规约**:加 meta hook 时只改 M18(M19 永远不含 meta hook 注册段);加 feature hook 时同步改 M18 + M19
- **验证标准**:
  - 文件存在,JSON 合法
  - jq diff M18 vs M19:**唯一差异**应是 Stop 数组中 M15 `check-meta-review.sh` 一个条目(M19 缺,M18 有)
  - 其他数组结构一致
- **模块文档**:M19 是配置模板,**模板顶部注释**说明双轨规约 + 维护方式;无需另建 README

---

### 批次 8:setup.sh 分发过滤 + handoff 模板 + testing-standard

#### 任务 I8.1:改动 M14 setup.sh(meta-* 过滤 + line 71 改 source + 末尾提示)

- **关联模块**:M14(改动)
- **关联场景**:分发隔离(B3 处理 + D22 (vi) 提示)
- **依赖**:I3.1 / I3.2 / I6.1 / I6.2 / I6.3 / I7.2(所有需过滤的文件存在)
- **问题**:`setup.sh` 现状把 `docs/governance/*.md` / `.claude/hooks/*.sh` 等通配符无脑分发,需要:
  1. **加 meta-* 命名前缀过滤**(D12):`docs/governance/*.md` / `.claude/hooks/*.sh` 拷贝改为 case 语句过滤 meta-*
  2. **改 line 71 settings.json source**(D19 a 方案):`cp "$SCRIPT_DIR/.claude/settings.json"` → `cp "$SCRIPT_DIR/templates/settings.json"`(指向 M19 模板)
  3. **末尾打印提示**(D22 fix-9 (vi)):"提示:harness 治理文件不应在下游本地修改,如有改动需求请回 harness 仓库 PR"
  4. **session-init.sh 反审检测段分发隔离**(配合 I6.3):若 I6.3 选选项 1 marker,M14 加 sed 删除逻辑;若 I6.3 选选项 2 拆分文件 + 命名前缀过滤,M14 自然命中(无需额外改 — 因为 meta-* 过滤已生效)
- **约束**:
  - 文件路径:`harness/setup.sh`(已存在)
  - **改动点 1(过滤)**:
    - 现状(setup.sh 约 line 86):`cp $SCRIPT_DIR/docs/governance/*.md $TARGET_DIR/docs/governance/`
    - 改为:case 语句逐文件检 `meta-*` 跳过(spec §3.1.8 已给改造模板)
    - 现状(setup.sh 约 line 69):`cp $SCRIPT_DIR/.claude/hooks/*.sh $TARGET_DIR/.claude/hooks/`
    - 改为:case 语句逐文件检 `meta-*` 跳过
    - 同样规则应用到其他通配符 cp(若有)
    - **同时排除** `meta-scope.conf`(M17,因为它不是 `.sh` 命名)— 实现 agent 需在 case 内显式加排除
  - **改动点 2(line 71 改 source)**:
    - 现状:`cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"`
    - 改为:`cp "$SCRIPT_DIR/templates/settings.json" "$TARGET_DIR/.claude/"`
  - **改动点 3(line 96 CLAUDE.md)**:
    - **无需改 — 现状已合规**(spec §3.1.8 路径事实:`$SCRIPT_DIR/CLAUDE.md` 实指 `harness/CLAUDE.md` = M4,不分发 M3)
    - 实现 agent **不要**误改此行
  - **改动点 4(末尾提示)**:
    - 在 setup.sh 末尾(成功消息后)加一行 echo 提示文案("提示:harness 治理文件不应在下游本地修改,如有改动需求请回 harness 仓库 PR")
  - **改动点 5(I6.3 配套)**:按 I6.3 选用方案配套
  - **错误处理**:case 语句必须 robust(无文件时 `cp` 报错处理 — 现有 `2>/dev/null || true` 范式)
  - **本次改动 setup.sh 自身**就是 meta scope(F 组),需经 meta-review;改完后:
    - 实施阶段在本任务完成前,产 audit 含 covers `setup.sh`
    - 由 M16 pre-commit hook 验证(若已 enable)
- **验证标准**:
  - 改动 1:`./setup.sh /tmp/test-target` 后,目标项目 `docs/governance/` 不含 `meta-*.md`,`.claude/hooks/` 不含 `meta-*.sh` / `meta-scope.conf`
  - 改动 2:目标项目 `.claude/settings.json` Stop 数组不含 M15 注册条目(jq 验证)
  - 改动 3:setup.sh 输出末尾含提示文案
  - 改动 4:M3 `/CLAUDE.md` 不分发(`$SCRIPT_DIR/CLAUDE.md` 已落 M4)
  - 改动 5:目标项目 `.claude/hooks/session-init.sh` 不含反审检测段
  - 边界测试:改造后 setup.sh 自身能正常执行(无语法错误)
- **模块文档**:M14 是脚本,顶部注释说明命名前缀过滤的范围 + 双轨 settings.json + 反审检测段隔离方式

#### 任务 I8.2:改动 docs/active/handoff.md 模板(加 skip 字段示例 + 反审待办字段示例)

- **关联模块**:handoff.md 模板(轻改动)
- **关联场景**:meta-review skip 留痕 + fix-8 C 部分反审待办留痕
- **依赖**:C3
- **问题**:`docs/active/handoff.md` 是 mutable 模板,需要加两段引导:
  1. 在 Evidence Depth 字段下加"档位说明"提示(指向 M1 evidence depth 节,引导 meta-L vs L 档位选择)
  2. 在合适位置加 `## meta-review: skipped(理由)` 字段示例(可选,仅 skip 场景需要)
  3. 在合适位置加 `## 反审待办` 字段示例(初始值 + 完成后值,fix-8 C 部分)
- **约束**:
  - 文件路径:`docs/active/handoff.md`(已存在)
  - **轻改动**:仅加引导段落 / 字段示例,不改其他结构
  - 字段格式**逐字遵循 C3 契约**
  - 引导文案:
    - skip 字段:见 spec §4.1.3 markdown 示例
    - 反审待办字段:见 spec §4.1.7 markdown 示例(初始值 + 完成后值)
  - **下游兼容**:handoff.md 模板分发下游(handoff 是 active 状态,scope 外),下游用模板时 skip / 反审待办字段示例对 feature 无影响(可忽略)
- **验证标准**:
  - 文件含 Evidence Depth 档位说明
  - 文件含 `## meta-review: skipped(理由)` 字段示例
  - 文件含 `## 反审待办` 字段示例(初始值 + 完成后值两版本)
  - diff 较小(估 < 30 行新增)
- **模块文档**:handoff 模板自身是模板,无需另建 README

#### 任务 I8.3:改动 docs/references/testing-standard.md(顶部加适用域声明)

- **关联模块**:testing-standard.md(轻改动)
- **关联场景**:meta vs feature evidence depth 双标隔离
- **依赖**:I3.2(M1 evidence depth 节存在)
- **问题**:`docs/references/testing-standard.md` 现是 feature 侧 L1-L4 定义,需要顶部加一句说明适用域("本文档适用于 feature 改动;meta 改动证据语义见 docs/governance/meta-finishing-rules.md 的 evidence depth 节"),与 M1 互不引用,语义清晰
- **约束**:
  - 文件路径:`docs/references/testing-standard.md`(已存在)
  - **轻改动**:仅在文件顶部加一行声明
  - 文案:逐字遵循 spec §8.2 给出的版本
  - **下游兼容**:testing-standard.md 分发下游;声明对下游 feature 改动无影响(meta 路径在下游不存在)
- **验证标准**:
  - 文件顶部含适用域声明
  - 现有 L1-L4 内容不变
  - diff < 5 行
- **模块文档**:无需改

---

## 5. 测试计划

### 5.1 单元测试(T1-T3)

> 单元测试覆盖 hook 内部逻辑函数。bash hook 单元测试方式:bats / shellspec / 自写 test runner。**实施层定具体框架**(参考 check-handoff.sh 现有 hook 是否有测试)。

#### T1:M15 check-meta-review.sh 单元测试

- **关联模块**:M15
- **依赖**:I6.1
- **测试层级**:单元
- **mock 策略**:mock git diff / mock audit YAML / mock handoff
- **测试场景**(对应 spec §6.2 关键场景 + §5 边界):
  1. changed_meta_files 为空 → exit 0
  2. changed_meta_files 非空 + 全部覆盖(audit covers 字段全包含改动文件) → exit 0
  3. changed_meta_files 非空 + 部分 uncovered + handoff 有有效 skip 理由 → exit 0
  4. changed_meta_files 非空 + 部分 uncovered + handoff 无 skip 理由 → exit 2 + stderr 含文件列表
  5. **fix-9 (iii) 修补验证**:audit 存在但 covers 字段未列改动文件 → 应识别为 uncovered(关键测试)
  6. **fix-9 (v) 修补验证**:改 `meta-scope.conf` 自身或 `meta-review-rules.md` → 应被识别为 scope=meta(因为治理文件入 scope)
  7. **B14 边界**:M17 缺失 → exit 0 + stderr "⚠️ meta-scope.conf 不可读"
  8. **B15 边界**:audit YAML 损坏 → exit 0 + stderr;视该 audit 不存在
  9. **B16 边界**:非 git 仓库 → exit 0
  10. **A1 防死循环**:`stop_hook_active=true` → exit 0(不执行检测)
  11. **A4 audit 失效规则**:audit covers 文件有新 commit(commit time > audit mtime) → 该文件视为未覆盖

#### T2:M16 check-meta-commit.sh 单元测试

- **关联模块**:M16
- **依赖**:I6.2
- **测试层级**:单元
- **mock 策略**:同 T1,但 mock `git diff --cached` 替代 `git diff`
- **测试场景**:
  1-9. 同 T1 1-9 场景(M16 共享 M15 主逻辑)
  10. **协议差异**:M16 不读 stdin(无 stop_hook_active),exit 1 阻断 commit(非 exit 2)
  11. **集成测试桥接**:在 harness 自身仓库 `git add` 一个 scope 内文件 + 不写 audit/skip → `git commit` 应失败(exit 1)

#### T3:M20 session-init.sh 反审检测段单元测试

- **关联模块**:M20
- **依赖**:I6.3
- **测试层级**:单元
- **mock 策略**:mock git log / mock audit covers
- **测试场景**:
  1. git log 不含 P0.9.1 落地 commit → 不注入(条件 1 不满足)
  2. git log 含 P0.9.1 落地 commit + audit covers 未含本 spec → 注入 system-reminder
  3. git log 含 P0.9.1 落地 commit + audit covers 含本 spec → 不注入(反审已完成)
  4. **graceful degrade**:git log 失败 → 跳过本段不阻断
  5. **graceful degrade**:audit YAML 损坏 → 视该 audit 不存在
  6. **关键词 pattern**:同时验证中英文 pattern("P0.9.1 落地" / "P0.9.1 implementation" / "feat(P0.9.1)" 等)
  7. **下游分发隔离**:`./setup.sh /tmp/test` 后目标项目 session-init.sh 不含反审检测段

### 5.2 集成测试(T4-T8)

> 集成测试验证 hook + scope.conf + audit + handoff 联动。

#### T4:scope 识别契约集成测试

- **关联场景**:spec §1.2 场景 1 + 场景 2(scope 分流)
- **关联接口**:spec §3.1.1 scope 识别
- **测试层级**:集成
- **测试内容**:
  - 改 `docs/governance/test-rule.md` → hook 识别 scope=meta
  - 改 `docs/ROADMAP.md` → hook 识别 scope=none(不在 scope 内)
  - 改 `docs/governance/test-rule.md` + `docs/PROGRESS.md` → 识别 mixed(任一 scope 内即触发)
  - 改 `harness/templates/settings.json` → 识别 scope=meta(fix-1 验证)
  - 改 `meta-scope.conf` 自身 → 识别 scope=meta(fix-9 (v) 验证)
  - 改 `docs/audits/meta-review-2026-04-25-foo.md` → 识别 scope=none(audit 排除)

#### T5:meta-review 流程化对抗审查集成测试

- **关联场景**:spec §1.2 场景 1 主体
- **关联接口**:spec §3.1.4 meta-review 流程契约
- **测试层级**:集成 + E2E(部分需实战)
- **测试内容**:
  - 模拟 meta 改动 → 触发 M15 hook → 引导 audit
  - 调度者 fork N 挑战者(对抗式 / 混合式 / 事实统计式各模态可触发)
  - audit 产物含 YAML covers 字段非空 + 5 段正文
  - audit verdict=pass / needs-revision / overturn 三种终态可设置
  - **降级路径**:模拟 fork 失败 → audit 标 `fork_mode: degraded-single-context` + degraded_reason

#### T6:meta finishing 路径集成测试

- **关联场景**:spec §1.2 场景 2 主体
- **关联接口**:spec §3.1.2 + §3.1.3 meta finishing 触发 + 四步契约
- **测试层级**:集成
- **测试内容**:
  - 进入 finishing 阶段 → M5 分流入口判 scope=meta → 引向 M1
  - 走 M1 四步:Step A 判 meta-review 必要 / Step B 触发 / Step C decision 立档 / Step D ROADMAP/PROGRESS/memory 同步
  - 验证 handoff 含 Evidence Depth(meta-L 档位值)+ skip 字段(若 Step A 判跳过)+ 反审待办字段(若 P0.9.1 落地)

#### T7:audit 一致性锚点集成测试

- **关联场景**:spec §1.2 场景 3
- **关联接口**:spec §3.1.6 三段结构契约
- **测试层级**:集成
- **测试内容**:
  - 调度者跨主题用 design-review / evaluate / security-scan / process-audit 触发 meta-review
  - 验证 4 agent 改造后维度可定制化:
    - M6/M7 对抗式 A/B/C 三段元信息(`recommended_enabled` / `recommended_disabled` / `minimum_required` / `customized_added`)
    - M8 混合式硬编码扫描部分不变 + 对抗维度部分含 A/B/C
    - M9 事实统计式不含 A/B/C 但含 `granularity_customization`(可选)
  - audit 内 dimensions 字段按模态分(adversarial / hybrid / fact_statistical)

#### T8:hook 执法两扇门集成测试

- **关联场景**:spec §1.2 场景 1+2 执法触点
- **关联接口**:spec §3.1.9 hook 执法
- **测试层级**:集成
- **测试内容**:
  - 故意改 `docs/governance/test-rule.md` + 不写 audit
  - 触发 Stop → M15 应 exit 2 引导
  - 写 audit 含 covers `[docs/governance/test-rule.md]`
  - 触发 Stop → M15 应 exit 0
  - `git add docs/governance/test-rule.md` + audit covers 中故意漏列(fix-9 (iii) 测试)
  - `git commit` → M16 应 exit 1 引导(因为 covers 未实际包含改动文件)
  - 修 audit covers 加上文件 → `git commit` 应通过

### 5.3 E2E 测试(T9)

#### T9:完整 meta 改动 commit 路径 E2E 测试

- **关联场景**:spec §1.2 场景 1 + 2 全链路
- **测试层级**:E2E
- **测试内容**(在 harness 自身仓库做端到端):
  1. 用户提需求"改 docs/governance/foo.md"
  2. 调度者识别 scope=meta(M3 入口 + M5 分流)
  3. 调度者按 M1 四步 finishing
  4. Step B 触发 meta-review:M2 pattern + 调度者 fork N 挑战者(M6-M9 改造后 prompt)→ skill 执行(M10-M13)
  5. 产 audit `docs/audits/meta-review-YYYY-MM-DD-HHMMSS-foo.md` 含 YAML covers
  6. Step C decision 立档
  7. Step D ROADMAP / PROGRESS / memory 同步
  8. handoff 写 Evidence Depth(meta-L 档位)
  9. session 末 → M15 Stop hook 检 audit covers → exit 0
  10. `git commit` → M16 pre-commit hook 检 audit covers → exit 0
  11. commit 进 main

### 5.4 setup.sh 分发隔离测试(T10)

#### T10:setup.sh 分发隔离测试

- **关联场景**:spec §3.1.8 setup.sh 分发隔离
- **测试层级**:集成
- **测试内容**:
  - `mkdir /tmp/test-target && ./setup.sh /tmp/test-target`
  - 验证目标项目:
    - `/tmp/test-target/docs/governance/` 不含 `meta-*.md`
    - `/tmp/test-target/.claude/hooks/` 不含 `meta-*.sh` / `meta-scope.conf`
    - `/tmp/test-target/.claude/settings.json` Stop 数组**不含** M15 注册条目(jq 验证)
    - `/tmp/test-target/.claude/hooks/session-init.sh` 不含反审检测段
    - `/tmp/test-target/CLAUDE.md` 是 M4 内容(不是 M3)
    - `/tmp/test-target/docs/governance/` 含 feature 层 governance 文件(`finishing-rules.md` 含 scope 分流入口但走 feature 路径)
    - setup.sh 输出末尾含 D22 fix-9 (vi) 提示文案

### 5.5 Bootstrap 反审本 spec 测试(T11,留痕到 meta-L4)

#### T11:bootstrap 自洽反审本 spec 测试

- **关联场景**:spec §6.4 bootstrap 自洽验证 + fix-8 反审触发
- **测试层级**:E2E + meta-L4(真实使用验证)
- **依赖**:全部 I 任务完成 + 一次实战 meta 改动(M0-M4 之一)
- **测试内容**:
  - P0.9.1 落地 commit 进 main
  - 下次 SessionStart → M20 反审检测段触发 → 注入 system-reminder
  - 调度者按 M2 pattern 节走 meta-review 流程审本 spec
  - fork 4 挑战者(bootstrap 4 维:核心原则合规 / 目的达成度 / 副作用 / scope 漂移)
  - 产 audit 含 covers `[docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md]` + verdict=pass
  - handoff 反审待办字段从"未完成"更新为"已完成 — audit:<path>"
  - 下次 SessionStart → M20 检测到 covers 含本 spec → 不再注入提醒(验证停止条件)

### 5.6 测试边界(对应 spec §6.3)

**不测什么**(逐字对齐 spec §6.3):
- 不测 P0.9.2 诊断流程本身
- 不测 P0.9.3 兜底
- 不对已完成 P-1/P0/P0.5 条目追溯测试
- 不做负载 / 性能测试
- 不定具体可量化指标(D11 + Q2 拍板)
- 不强制单元测试 hook 脚本逻辑(hook bug 由实战暴露;但 T1-T3 是规划测试,实施层选择是否实做)

**外部依赖 mock 策略**:
- fork 行为:Claude Code 平台 Agent 工具不由 harness 控制,无法 mock。测试依赖实际 fork 调用
- git:hook 测试用真实 git 仓库 + 临时分支 + 实际 commit 操作,无 mock 必要
- 文件系统:markdown / conf / shell 都用真实 fs

---

## 6. 验收信号

按 spec §6 + §9 全局自洽性检查列出验收信号。

### 6.1 spec §1.2 五场景 P0.9.1 实施部分全通

- [x] 场景 1(meta-review 流程化对抗审查)— I3.x + I5.x + I6.1 + I6.2 + I6.3 + I8.x 完成,T5 / T8 / T9 通过
- [x] 场景 2(meta finishing 路径明确)— I3.2 + I4.2 完成,T6 通过
- [x] 场景 3(4 审查 agent 维度定制化)— I5.1-I5.8 完成,T7 通过
- [-] 场景 4(P0.9.2 诊断)— **不在 P0.9.1 实施 scope**(spec §1.3 边界声明,T9 数据为后续基础)
- [-] 场景 5(P0.9.3 兜底)— **不在 P0.9.1 实施 scope**

### 6.2 spec §7.1 22 决策落地

- D1-D19 决策均已落入对应模块 / 任务(C / I / T 任务编号交叉对应表见 §6.5)
- D20-D22(第八轮 fix-7 / fix-8 / fix-9 用户拍板)分别落地:
  - D20 fix-7:实施层在 P0.9.1.5 自身或 P0.9.3 阶段承接 brainstorming-rules / handoff 引导(本阶段不强制实施,详见 spec §1.3 / §6.5 / §8.3)
  - D21 fix-8:I6.3(A 部分 M20 扩展)+ I3.2(C 部分 M1 引导写 handoff 反审待办)+ I8.2(handoff.md 模板加字段示例)
  - D22 fix-9:(iii) I6.1 / I6.2 covers 比对修补;(v) C1 + I2.1 排除规则修补;(i)(ii)(iv)(vi) 登记到 spec §1.3 / §5 B18,本阶段接受不防

### 6.3 bootstrap 4 维满足

- T11(留痕)是 meta-L4 真实使用验证,本阶段不强制完成(因为依赖 P0.9.1 落地后实战);完成后作为 P0.9.1 闭环留痕
- bootstrap 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移)在 C4 + I3.1 + I5.1-I5.4 中作为 B 段最低必选基线

### 6.4 跨节自洽性(对应 spec §9)

- [x] 需求 ↔ 模块:本 plan §3 + §4 任务 ↔ spec §2.1 模块表
- [x] 模块 ↔ 接口:本 plan §3 + §4 任务 ↔ spec §3.1 流程契约
- [x] 接口 ↔ 数据:C2 + C3 ↔ spec §4.1 数据实体
- [x] 数据 ↔ 边界:T1-T3 单元测试 ↔ spec §5 B1-B18
- [-] 依赖 ↔ 架构:**不适用**(spec §1.6 / §2.1 bootstrap 例外 1)
- [x] 决策 ↔ 需求:本 plan §6.2 ↔ spec §7.1 D1-D22
- [-] 决策 ↔ 架构:**不适用**(同 bootstrap 例外 1)
- [x] 影响 ↔ 模块:本 plan §3 + §4 任务 ↔ spec §8.1 / §8.4 改动文件清单

### 6.5 任务 ↔ 模块 ↔ 决策 交叉对应表

| 模块 | 主任务 | 关联决策 |
|---|---|---|
| M1 | I3.2 | D2(模态分型未直接,但 evidence depth 节模板)/ D9 / D10 / D21 fix-8 C |
| M2 | I3.1 | D1 / D2 / D5 / D7 / D11 |
| M3 | I4.1 | D13 |
| M4 | I4.3 | D13(对侧) |
| M5 | I4.2 | (无独立决策,场景 2 分流) |
| M6 | I5.1 | D2 / fix-2(spec §3.1.6) |
| M7 | I5.2 | D2 / fix-2 / fix-6 |
| M8 | I5.3 | D2 / fix-2 |
| M9 | I5.4 | D2 / fix-2 |
| M10 | I5.5 | D3 |
| M11 | I5.6 | D3 |
| M12 | I5.7 | D3 |
| M13 | I5.8 | D3 |
| M14 | I8.1 | D12 / D19 a / D22 fix-9 (vi) |
| M15 | I6.1 | D17 / D18 / D22 fix-9 (iii) / D22 fix-9 (v) |
| M16 | I6.2 | D17 / D18 / D22 fix-9 (iii) / D22 fix-9 (v) |
| M17 | I2.1 | D18 / D22 fix-9 (v) |
| M18 | I7.1 | D17 / D19 a |
| M19 | I7.2 | D19 a |
| M20 | I6.3 | D21 fix-8 A |
| handoff.md 模板 | I8.2 | D21 fix-8 C |
| testing-standard.md | I8.3 | (无独立决策,fix-6 配套) |

---

## 7. 后续依赖(P0.9.1.5 / P0.9.2 / P0.9.3)

> 列出本阶段不实施但依赖本阶段产出的后续条目。详见 spec §1.4 / §1.3。

### 7.1 P0.9.1.5 写前流程(吃自己狗粮)

- **依赖**:P0.9.1 全部任务完成
- **触发条件**:M0-M4 启动前用户评估(D20 fix-7 B 触发条件)
- **本阶段产出基础**:
  - M1 / M2 / M15-M20 hook 体系作为 P0.9.1.5 实施时的 meta-review 流程
  - C2 / C3 / C4 契约作为 P0.9.1.5 实施时的 audit / handoff / pattern 格式参考
- **本阶段不做**(spec §1.3 边界):
  - 不预定 P0.9.1.5 spec 设计
  - 不预定具体引导文案(留 P0.9.1.5 自身实施 / P0.9.3 承接)

### 7.2 P0.9.2 诊断(leverage 量化指标)

- **依赖**:P0.9.1 落地后 N 次 meta 改动累积 audit trail
- **触发条件**:N 次实战数据后由用户决定启动
- **本阶段产出基础**:
  - M1 audit trail 累积是场景 4 数据基础
  - 5 leverage 4 事实(spec §1.6)作为可数事实参考
- **本阶段不做**(spec §1.3 边界 + D11):
  - 不强行定可量化指标(避免编数据违反 `feedback_judgment_basis`)

### 7.3 P0.9.3 兜底(Stop+pre-commit 被绕时补强)

- **依赖**:P0.9.1 落地后实战数据显示绕路实际发生
- **触发条件**:可能完全不触发(spec §1.3)
- **本阶段产出基础**:
  - 已识别 4 条绕过路径推 P0.9.3:`--no-verify`(D22 (i))/ 长 session 不 stop(D22 (ii))/ 理由质量(D22 (iv))/ 下游改副本(D22 (vi))
- **本阶段不做**:
  - 不预先实现绕路防御(`feedback_judgment_basis` 原则)

### 7.4 M0-M4 治理改动批次(P0.9.1 后首批使用)

- **依赖**:P0.9.1 + 可选 P0.9.1.5
- **批次内容**(spec §1.3):
  - block-dangerous 删除
  - 封死简化收尾
  - 简洁性维度降级
  - finishing 冲突修复
  - 轻量级判定收紧
- **特殊边界**(D16 / B13):
  - M0-M4 单项反复 needs-revision → B7 用户介入
  - M0-M4 多项命中相同流程缺陷 → B13 P0.9.1 修订评估,不破闭环

### 7.5 P1 真实项目验证

- **依赖**:P0.9.1 完成(阻塞 P1)
- **本阶段不做**

---

## 8. 风险 / Trade-off / 用户应注意

> Plan 内不替用户决定,但需提示风险与 trade-off。

### 8.1 已知 trade-off(已 spec 拍板,落实需注意)

1. **D17 光谱 B+ 最小集**:Stop + pre-commit 是 2 hook 最小集,**长 session 不 stop + --no-verify 双绕** 是设计代价(D22 fix-9 (i)(ii) 接受)。落地后由 process-audit 反向追踪绕路实战数据
2. **D19 a 方案双轨 settings.json**:harness 自身扩 meta hook 时只改 M18(M19 永远不含 meta hook 注册段);扩 feature hook(罕见)时需同步改 M18 + M19 — **维护负担**:用户应注意双轨同步
3. **fix-9 (v) bootstrap 循环可接受**:改 `meta-review-rules.md` 会触发 meta-review 用旧规则审新规则(类似编译器自举)。用户应注意此循环不是 bug,是设计接受的代价
4. **fix-2 防下游污染约束**:agent 文件 prompt 静态嵌入"在 harness 自身仓库时,调度者按 §3.1.7 嵌入"。用户应注意 agent 文件本身不能含 meta 实文,否则下游被污染

### 8.2 实施层需用户决定的细节(留给实现 agent / 用户对接)

> 本 plan 不预决,实现 agent 在实施时按 spec 内已留余地决定 / 升 🟡 待用户决定。

1. **I6.2 M16 git pre-commit hook 安装方式**:候选 setup.sh 加 `ln -sf` 或 harness 自身手工创建。**实施层定**(spec §3.1.9 已留余地)
2. **I6.3 M20 反审检测段分发隔离方式**:候选 marker 包裹 + setup.sh sed,或拆分两文件 + 命名前缀过滤。**实施层定**(spec §3.1.10 已留余地)
3. **D5 单 prompt 字节软上限**:建议 ~64 kB,具体数值在 I3.1 实施时拍板(spec §7.1 D5)
4. **B7 hook 失效降级处理范式**:依现有 check-handoff.sh 范式(graceful degrade exit 0 + stderr)。实施时具体降级文案由实现 agent 写
5. **T1-T3 hook 单元测试框架选择**:bats / shellspec / 自写 test runner。**实施层定**(参考 check-handoff.sh 现有 hook 是否有测试)
6. **I6.1 M15 / I6.2 M16 共享逻辑函数库**:可选重构为 `.claude/hooks/lib/meta-helpers.sh`(命名前缀 meta-* 自动过滤);**实施层定**(spec 未指定)

### 8.3 无 spec 漏洞 / 需用户决定的实施层 🟡

经全文复核,**未发现 spec §1-9 内的实施层 🟡 待决策项漏洞**。spec 第八轮 fix-7 / fix-8 / fix-9 已全部由用户拍板(D20-D22 🟢),前 18 项问题在 D1-D19 解决。

**经过 plan 层复核新发现的提示**(非漏洞,只是实现 agent 需注意):

1. **C1 内 M17 自身的 glob 覆盖**:M17 配置内容含 B 组 `.claude/hooks/*.sh`(只命中 .sh 后缀),`.conf` 后缀的 `meta-scope.conf` 自身需在 conf 内显式追加一行 `.claude/hooks/meta-scope.conf` 才能被 hook 识别为 scope 内 — 这是 fix-9 (v) 的隐含要求,实现 agent 在 I2.1 实施时应主动补漏
2. **M14 setup.sh 改造时 setup.sh 自身是 meta scope**:本任务改完后实施阶段应产 audit 含 covers `setup.sh`(自审 — 但 P0.9.1 实施期间 hook 可能尚未 enable,实施层需把握此 boot 顺序)
3. **session-init.sh M20 扩展 + 分发隔离方式选择**:I6.3 留 2 选 1 给实现 agent。**倾向选项 2**(命名前缀机制更一致),但实现 agent 可按简单度自定。需在 plan / I8.1 中保持一致(若选选项 1 则 M14 加 sed 逻辑;若选选项 2 则 M14 自然命中)

### 8.4 用户对接节点

实施 P0.9.1 plan 时,用户应在以下节点准备介入:

1. **批次 1 契约任务确认**:C1-C5 的精确格式如有任何不清楚,用户先校对
2. **批次 6 hook 实施前**:确认 M16 git pre-commit 的安装方式(I6.2 候选)
3. **批次 6 后 hook 启用前**:M14 setup.sh 改造完成 + M15 hook 已 enable 时,**首次 commit P0.9.1 实施代码**会被 M16 拦(因为是 meta scope 改动)— 用户需配合产 audit 或写 skip 理由完成 boot 闭环
4. **批次 8 后**:T9 / T11 测试需用户参与触发(实战测试)
5. **P0.9.1 落地 commit 后**:T11 反审本 spec 测试触发(SessionStart 提醒后,用户决定何时反审)

### 8.5 boot 顺序风险(关键)

P0.9.1 实施过程中存在 **boot 顺序问题**:

- I6.1 M15 / I6.2 M16 hook **enable 后**,任何 scope 内文件改动都会被拦
- 但 I3.1 / I3.2 / I4.x / I5.x 都是 scope 内改动(M1 / M2 / M3 / M5 / M6-M13 都在 governance / agents / skills 命名空间)
- **建议 boot 顺序**:
  1. 完成 I3.1 / I3.2 / I4.x / I5.x / I6.x / I7.x / I8.x **不 commit**
  2. 改完后一次性 commit,handoff 写"P0.9.1 全部实施 + 自审 boot 阶段无 hook"理由(因为 hook 尚未 enable)
  3. 或:实施过程中 commit 时手工写 audit 覆盖本批次 P0.9.1 实施改动文件
- **实现 agent 应在 I8.1 完成前明示此 boot 路径**,用户按需选择

---

## 9. 全局自检

- [x] 任务粒度合理:契约任务 5 + 实现任务 18 + 测试任务 11 = 34 总任务,匹配 20 模块 + 关联文件改动 + 测试覆盖
- [x] 契约任务排在实现任务前:§3 C1-C5 先于 §4 批次 2-8
- [x] 每个任务标注涉及哪些已有模块(§4 各任务"关联模块"字段)
- [x] 每个任务的实现步骤包含"更新涉及模块的 README":本 plan 各任务"模块文档"段处理(governance / hook / skill 多为内嵌注释而非独立 README,符合 harness 项目特性)
- [x] 不偏离 spec:所有任务约束直接引用 spec § 章节;**未引入新模块 / 新决策**
- [x] 不替用户决定:§8.2 列出实施层需用户决定的细节,留给实现 agent 或用户介入
- [x] 不写代码:任务粒度是"做什么 + 验证什么",不写"怎么做的代码段"
- [x] 测试计划基于 spec §5 边界条件 + spec §1.2 核心场景:T1-T11 各覆盖
- [x] 测试层级标注(单元 / 集成 / E2E):每个 T 任务标"测试层级"
- [x] mock 策略明示(spec §6.3):T1-T3 mock 策略明示;T4-T11 用真实 git / fs(无 mock 必要)

---

**Plan 收敛**。下一步:plan 由调度者审核,可选另起 session 用 subagent-driven-development 执行。

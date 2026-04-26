# P0.9.1 契约 lock — 批次 1 输出(C1-C5)

**关联 spec**:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`
**关联 plan**:`docs/superpowers/plans/2026-04-26-p0-9-1-self-governance-plan.md` §3
**关联 decisions**:D1-D22(spec §7.1)+ 三独立 decision 文件
- `docs/decisions/2026-04-26-p0-9-1-5-trigger-condition.md`(D20)
- `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`(D21)
- `docs/decisions/2026-04-26-bypass-paths-handling.md`(D22)

**生成日期**:2026-04-26
**作者**:批次 1 实现 agent(独立 fork)
**输入**:plan §3 C1-C5 文本 + 用户决定 D.1 / D.2 + plan line 406 已知问题

---

## 序言(必读)

### 本文档定位

- **SSoT 锁定**:本文档是批次 2-8 实施(C 系列已完;I/T 系列将启)的**单一权威源**。所有 I-task 必须按本文档的"最终精确文本"逐字执行;不得自由解释。
- **不是 spec 替代**:本文档以 plan §3 的 C1-C5 为底,**应用了 D.1 / D.2 / line 406 三处变更后**生成最终锁版。spec 仍是上层规范,契约是 spec 在跨模块共享数据格式上的精确化。
- **契约 ≠ 实现**:本文档定义的是"格式 / 语义 / 约束",不规定具体 shell / awk / sed 实现路径。实现细节由 I-task agent 自决。

### 当前阶段 scope 警告(不要混淆)

> **harness 自身 hook 激活不在 P0.9.1 scope 内**:用户已决定本阶段不调整自己的开发环境。M15 / M16 / M20 等文件本批次会**创建**(让 I-task 产出物完整),但**不在 harness 仓库的 settings.json / git hooks 内激活**。
>
> **契约定义格式;激活是另一回事**:契约约定的"hook 读 audit covers + scope.conf + handoff skip 字段"等行为,在 harness 自身仓库本阶段不会真正运行。仅文件就位等下游/后续阶段或新仓库使用。
>
> **下游分发逻辑保留**:setup.sh 仍按 D12 命名前缀过滤 + D19 a 方案分发,确保下游不被 meta 治理污染(下游本来就不该激活,与上游本阶段不激活两回事:一个是技术封堵,一个是节奏决策)。

### 用户决定 D.1 / D.2 / line 406 解决摘要

| 编号 | 来源 | 处理 | 详见 |
|---|---|---|---|
| D.1 | 用户决定(替代 plan §3 C5 SessionStart 行原 sed 注解) | M20 拆分两文件 + meta-* 命名前缀过滤;C5 SessionStart 行注释重写 | C5 末"D.1 应用说明" |
| D.2 | 用户决定(plan / spec 未定具体软上限) | C4 增 8 KB soft cap 子条目(挑战者 prompt 嵌入字节) | C4 末"D.2 应用说明" |
| plan line 406 | plan 自标已知问题 | 选**扩 B 组为 `.claude/hooks/*`**,统一覆盖 .sh + .conf + 未来 hook 配置类型 | C1 末"line 406 解决说明" |

### 命名约定

- **C1-C5**:契约编号,按 plan §3 顺序,不变
- **M1-M20**:模块编号,按 spec §2.1,不变
- **D1-D22**:决策编号,按 spec §7.1,不变(本文档不引入新 D)
- **B1-B18**:边界条件,按 spec §5.1,不变

---

## C1:M17 meta-scope.conf 配置内容(锁定版)

**类型**:契约任务(配置数据格式)
**关联模块**:M17(承载) / M15-M16(读) / M20(读)
**spec 锚点**:§3.1.1 + §4.1.2 + D18 + D22 fix-9 (v)
**plan 锚点**:plan §3 C1(line 122-172)

### 最终精确内容

文件路径:`.claude/hooks/meta-scope.conf`

```
# meta-scope.conf - hook 读取的 scope 配置
# 每行一条 glob 规则,! 前缀为排除
# 由 M15 check-meta-review.sh 和 M16 check-meta-commit.sh 读
# 文件编码: UTF-8;行尾: LF

# === A 组:governance + 核心规则 ===
docs/governance/*.md
CLAUDE.md

# === B 组:.claude/hooks/* + settings(扩 glob 至 *,line 406 解决)===
# 原 plan/spec 列 .claude/hooks/*.sh 不命中 .conf;扩为 *
# 一并覆盖 *.sh / *.conf / 未来 hook 配置类型(JSON / YAML 等),
# 也使 M17 自身 (.claude/hooks/meta-scope.conf) 入 scope
.claude/hooks/*
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

# === 排除规则(D22 fix-9 (v))===
# 只排除流程产出物(audit 文件本身,避免自循环)
# 不排除治理文件(meta-*.sh / meta-*.md / meta-scope.conf)— 治理文件入 scope
!docs/audits/meta-review-*.md
!docs/audits/archive/**

# === E + G 组(scope 外,显式声明)===
# E: 不需列(不命中 scope 内 glob 即等同 scope 外)
# G: 不需列
```

### 字段语义

| 行类型 | 语法 | 含义 |
|---|---|---|
| 注释 | `# ...` | 不参与解析 |
| 空行 | (空) | 不参与解析 |
| include glob | `<glob>` | 命中即标记文件为 scope 内 |
| exclude glob | `!<glob>` | 命中即排除(优先级高于 include) |

### 解析规则

```
for f in changed_files:
  if any(match(f, g) for g in exclude_globs):  skip(f)         # 优先排除
  elif any(match(f, g) for g in include_globs): mark f as scope-internal
  else:                                          scope-external (feature/none)
```

### 关键不变量(I-task 不可偏离)

1. **B 组用 `*` 不用 `*.sh`**:扩 glob 至 `*` 统一覆盖 `.sh` / `.conf` / 未来 hook 配置(line 406 解决)
2. **不排除治理文件**:`meta-*.sh` / `meta-*.md` / `meta-scope.conf` 不在 `!` 排除规则(D22 fix-9 (v) 修)
3. **必须排除流程产出物**:`!docs/audits/meta-review-*.md` + `!docs/audits/archive/**`(自循环避免)
4. **F 组含 `harness/templates/*.json`**(D19 a 方案 fix-1):M19 入 scope,改 M19 必须触发 meta-review
5. **E + G 组不显式列**:不命中 scope 内 glob 即等同 scope 外
6. **文件编码 UTF-8 + LF**:awk/grep 解析需要 LF;BOM 不允许(I2.1 验证标准)

### 验证结果

| 检查项 | 结果 |
|---|---|
| vs spec §4.1.2 内容一致 | 几乎逐字一致;**唯一差异**:B 组 `.claude/hooks/*.sh` → `.claude/hooks/*`(line 406 解决,见下) |
| vs spec §3.1.1 排除规则 | 一致(只排产出物,不排治理文件) |
| vs D18(scope 配置外部化) | 一致(数据与逻辑解耦) |
| vs D22 fix-9 (v)(治理文件入 scope) | 一致 |
| vs D22 fix-9 (vi)(下游不分发) | 一致(M14 D12 命名前缀过滤覆盖) |
| 内部一致性:含 C2 涉及的所有 covers 路径 | C2 covers 是仓库相对路径,任何被 covers 列出的路径若属 scope.conf include glob 命中范围,即可被 hook 识别。glob 已含 A+B+C+D+F 全组 |
| 内部一致性:M17 自身入 scope | ✅ B 组 `.claude/hooks/*` 命中 `meta-scope.conf` |
| 完整性:E + G 组处理 | ✅ 不命中 include glob 自动 scope 外,无需 `!` 排除 |
| 完整性:M19 入 scope | ✅ F 组 `harness/templates/*.json` 命中 |
| 不歧义:每行作用唯一 | ✅(注释 / include / exclude 三类语法明确) |

### line 406 解决说明

**原问题**:plan line 406 自标 — F 组列 `harness/templates/*.json`(M19 入 scope),但 M17 自身路径 `.claude/hooks/meta-scope.conf` 是否被 B 组 `.claude/hooks/*.sh` 命中?**`.sh` 不命中 `.conf`**。需在 conf 内显式追加 `.claude/hooks/meta-scope.conf` 一行 OR 扩 B 组为 `.claude/hooks/*`。

**选择**:**扩 B 组为 `.claude/hooks/*`**(替代显式追加)。

**理由**:
1. **一行解决多类**:`*` 同时覆盖 `.sh`(M15/M16/未来 hook 脚本)+ `.conf`(M17/未来 hook 配置)+ 未来可能的 `.json` / `.yaml` hook 配置文件。
2. **避免显式追加每个新 hook 配置类型**:若选"显式追加 `.claude/hooks/meta-scope.conf` 一行",则未来加任何 `.claude/hooks/<新扩展>` 都需追加新行,违反 D18"scope 扩展不改 hook 代码"+ 类似"扩展不改 scope.conf 多行"的简洁性精神。
3. **副作用最小**:`.claude/hooks/` 目录现/未来全是 hook 相关文件,扩 `*` 不引入误命中。
4. **对齐 D22 fix-9 (v)**:治理文件(含 `meta-scope.conf`)入 scope,本扩展是 fix-9 (v) 的同向延伸。

### Notes(无 controller 待决项)

- 本契约无 controller 决策遗留;D22 fix-9 (v) 已闭环。
- I2.1 实施时:I-task agent 在 conf 文件顶部注释块详尽说明字段语义与扩展方式(等价于内嵌 README,见 plan I2.1)。

---

## C2:audit YAML frontmatter `covers` 字段格式(锁定版)

**类型**:契约任务(数据结构 — 写读双侧)
**关联模块**:M2(写)/ M15-M16(读)/ M20(读 — 反审 covers 检测)
**spec 锚点**:§3.1.4 Step 5 + §3.1.9 + §3.1.10 + §4.1.1 + §4.1.5 + D14 + D22 fix-9 (iii)
**plan 锚点**:plan §3 C2(line 174-219)

### 最终精确格式

audit 文件位置:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md`(D14:加 HHMMSS)

文件结构:

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

### 字段精确语义(YAML frontmatter)

| 字段 | 类型 | 必填 | 缺省/合法值 | 含义 |
|---|---|---|---|---|
| `meta-review` | boolean | ✅ | 固定 `true` | 标识本文件是 meta-review audit;hook grep 识别用 |
| `covers` | string 数组(仓库相对路径) | ✅ | **非空数组**(空 = 等价于未走流程) | 本 audit 覆盖的 scope 内文件路径 |

### covers 数组路径规则

1. **仓库相对路径**:从仓库根算起,无 `./` 前缀,无尾 `/`(如 `docs/governance/design-rules.md`,不是 `/docs/...` 也不是 `./docs/...`)
2. **正斜杠分隔**:Windows 仓库也用 `/`(YAML 跨平台一致)
3. **路径必须实存**:写 audit 时调度者列入的路径必须在仓库内实存(允许扩展提交后实存)
4. **无去重要求**:数组内允许重复,hook 处理时按集合并集计算(去重在 hook 内做,不在 covers 内强制)

### 写侧契约(M2 → audit 文件)

- 触发者:调度者(在 §3.1.4 Step 5 写入)
- 时机:meta-review 流程末,挑战者审查完成后
- 必须列入 covers 的内容:**本 audit 实际覆盖的、scope 内的、本次改动的所有文件路径**(D22 fix-9 (iii) 修补语义)
  - 不是"audit 主题相关"即列入;必须是 audit 实际审查的具体文件
  - 不能漏列(漏列文件会被 hook 视为未 cover,触发引导)
  - 不能误列不属本次改动的(误列会导致下次相同文件改动时失效计算偏差)

### 读侧契约(M15 / M16 / M20 → audit 文件)

#### 读取算法(M15 / M16 hook)

```
covered_files = ⋃ {audit.yaml_frontmatter.covers : audit ∈ 有效 audit 集}
              其中 "有效 audit" 按 §4.1.5 / D22 fix-9 (iii) 失效规则筛后
uncovered = changed_meta_files - covered_files
            (changed_meta_files = git diff 命中 scope.conf include glob 后过滤的集合)
若 uncovered 非空:
  扫 handoff `## meta-review: skipped(理由: ...)`,理由非空 → exit 0
  否则 → 引导消息 + exit 2 (M15) / exit 1 (M16)
```

#### 失效规则(§4.1.5 + D22 fix-9 (iii))

对每个 audit 的每个 covers 文件,判该文件对此 audit 是否失效:

```
covered_latest_commit_time = git log -1 --format=%ct -- <covered_file>
audit_mtime = stat <audit_file> 取 mtime
if covered_latest_commit_time > audit_mtime:
  return TRUE   # covers 失效:文件有新 commit 在 audit 之后
else:
  return FALSE  # 仍有效
```

**单文件可能在多个 audit 的 covers 中**:任一未失效的 audit 即视为该文件已 cover。

#### M20 反审 covers 检测(§3.1.10)

- M20 SessionStart hook 用同一 covers 解析逻辑,但**只关心一个特定路径**:本 spec 文件路径 `docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`
- 算法:扫所有 audit `covers:`,grep 该路径;命中即视为反审已完成

### 错误处理(读侧 hook)

| 错误情形 | 处理 |
|---|---|
| audit YAML frontmatter 损坏(YAML 解析失败) | stderr "⚠️ audit YAML 损坏: <文件>" + 视该 audit 不存在(不参与 covers 并集);hook 继续处理其他 audit;exit 0 不阻断 |
| `covers:` 字段缺失 | 同上,视该文件非 meta-review audit |
| `covers:` 为空数组 | 视为未走流程,该 audit 不贡献任何 covered_files |
| `meta-review: true` 缺失或值为 false | 视该文件非 meta-review audit,跳过 |

### markdown 正文 5 段结构(精确节标题)

```
## 1. 元信息
## 2. 维度选取
## 3. 挑战者执行记录
## 4. 综合
## 5. 判定
```

正文节字段细节见 spec §4.1.1 `interface AuditTrail`;**本契约只锁 frontmatter + 5 段节标题**,正文内字段格式由 M2 governance 文件 + I3.1 实施时定。

### 验证结果

| 检查项 | 结果 |
|---|---|
| vs spec §4.1.1 frontmatter 字段 | ✅ 一致(meta-review + covers,二者必填) |
| vs spec §3.1.4 Step 5 写入要求 | ✅ 一致(必产 audit + YAML frontmatter 必含 covers) |
| vs spec §3.1.9 hook 读取语义 | ✅ 一致(D22 fix-9 (iii) 修后 covered_files 是实际列出的文件) |
| vs spec §3.1.10 M20 反审检测 | ✅ 一致(本契约定义 covers 解析,§3.1.10 复用) |
| vs spec §4.1.5 失效规则 | ✅ 一致(git log commit time vs audit mtime) |
| vs D14(加 HHMMSS) | ✅ 一致(audit 文件名含 HHMMSS) |
| vs D22 fix-9 (iii)(实际列出 vs 主题相关) | ✅ 一致(写侧明示"实际覆盖" / 读侧明示 covered_files = ⋃ covers) |
| 完整性:写读双侧均覆盖 | ✅ 写 / 读 / 失效 / 错误处理四面 |
| 完整性:M20 也用 covers | ✅ §3.1.10 反审检测复用,本契约同时给出语义 |
| 不歧义:路径格式精确 | ✅ 仓库相对 / 正斜杠 / 无前缀 / 无尾斜杠 / 实存 |
| 内部一致性:与 C1 scope.conf glob 兼容 | ✅ covers 列出的路径若 glob 命中 scope,hook 可识别 |

### Notes(无 controller 待决项)

- audit 正文 5 段内具体字段(如 dimensions / execution / synthesis / verdict)由 spec §4.1.1 已定;I3.1 实施 M2 时按 spec interface 落地,本契约只锁 frontmatter + 5 段节标题(确保 hook 可识别)。
- 归档 INDEX.md schema(spec §4.1.1 第七轮 fix-3)由 P0.9.1 仅声明 schema,首次半年归档触发由实施层脚本生成。本批次 I-task 不实施归档脚本(plan §1.3 边界外)。

---

## C3:handoff 两个字段格式(skip + 反审待办)(锁定版)

**类型**:契约任务(handoff 字段格式)
**关联模块**:M1(引导写入)/ M15-M16(读 skip)/ M20 + 调度者(读反审待办,辅助)
**spec 锚点**:§4.1.3 + §4.1.7 + D21(fix-8 A+C 组合)
**plan 锚点**:plan §3 C3(line 221-263)

### 字段 1:`handoff_meta_review_skip`(短期,每次 meta 改动可覆盖)

#### 精确格式

```markdown
## meta-review: skipped(理由: <非空理由>)
```

#### 字段语义

| 字段 | 类型 | 必填 | 含义 |
|---|---|---|---|
| marker | 固定字符串 `## meta-review: skipped` | ✅ | hook grep 识别 |
| 括号字段 `(理由: <reason>)` | 整体必出现 | ✅ | 括号 + `理由:` + 内容 + 括号闭合 |
| `<reason>` | string,**非空非全空白** | ✅ | 至少 1 个非空白字符;hook 校验 |

#### 写入时机

- **触发**:§3.1.3 Step A 调度者判"不走 meta-review"时
- **执行者**:M1 meta-finishing-rules 引导调度者写入 handoff
- **覆盖语义**:每次新 meta 改动开始时,调度者覆盖此字段(不累积旧 skip 记录)

#### hook 读取规则(M15 / M16)

- grep 匹配:`## meta-review: skipped\(理由: ([^)]+)\)`(POSIX ERE)
- 提取 `\1` 即理由内容
- 校验:`\S` 至少匹配 1 个非空白字符 → skip 有效,exit 0
- 校验失败(理由为空 / 全空白):skip 无效,继续要求 audit

#### markdown 示例

合规:
```markdown
## meta-review: skipped(理由: 仅修改 typo 注释,无语义变更)
```

不合规(reason 空):
```markdown
## meta-review: skipped(理由: )
```

不合规(reason 全空白):
```markdown
## meta-review: skipped(理由:    )
```

不合规(无括号字段):
```markdown
## meta-review: skipped
```

### 字段 2:`handoff_self_review_pending`(长期,直到反审完成)

#### 精确格式 — 初始值

```markdown
## 反审待办

P0.9.1 落地反审 — 未完成
```

#### 精确格式 — 完成后

```markdown
## 反审待办

P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`
```

注意:audit 路径用反引号包裹(代码风格,与 spec §4.1.7 示例一致)。

#### 字段语义

| 字段 | 类型 | 必填 | 含义 |
|---|---|---|---|
| marker | 固定字符串 `## 反审待办` | ✅ | 字段标识 |
| status 行 | "P0.9.1 落地反审 — 未完成" 或 "P0.9.1 落地反审 — 已完成 — audit:`<path>`" | ✅ | 状态描述 |
| audit 路径(完成态) | 仓库相对路径,反引号包裹 | ✅(完成态) | 反审 audit 文件路径 |

#### 写入 / 更新时机

- **初始写入**:P0.9.1 实施阶段最后一次 finishing(对应 P0.9.1 commit 进 main),M1 引导调度者在 handoff 加此字段(初始值"未完成")
- **更新**:反审走完(M2 pattern 节 + audit 产出 + verdict=pass)后,M1 引导更新字段为"已完成 — audit:`<path>`"
- **不清理**:反审完成后字段保留(P0.9.1 闭环留痕)

#### 失效重审

- 若 P0.9.1 重大改动(commit 进 main)后,§4.1.5 covers 失效规则触发反审 audit 失效 → 字段重置为"未完成"+ M20 SessionStart hook 重新注入提醒

#### hook 读取规则(可选 — 与 M20 互补)

- **权威**:audit covers 是反审完成的权威依据(M20 按 covers 判定,见 C2)
- **被动留痕**:本字段供调度者读 handoff 见此判断反审是否待办
- **不强制 hook 解析**(避免双源冲突);若未来扩展 hook 读此字段,需与 covers 检测保持优先级:**covers 是权威**,字段失同步以 covers 为准

### 两字段共存约束

- **同一 handoff 文件**:两字段共存,marker 不同(`## meta-review: skipped` vs `## 反审待办`)
- **不互覆盖**:skip 字段每次 meta 改动可覆盖;反审待办字段保留至反审完成
- **顺序无要求**:两字段在 handoff 内出现顺序不强制(实施层在 handoff 模板中可固定一种顺序便于阅读)

### 验证结果

| 检查项 | 结果 |
|---|---|
| vs spec §4.1.3 skip 字段格式 | ✅ 一致(marker + 括号 + 理由必填) |
| vs spec §4.1.7 反审待办字段 | ✅ 一致(初始 + 完成两态;audit 路径反引号包裹) |
| vs D21 fix-8 A+C 组合 | ✅ 一致(C 部分留痕;A 部分由 C5 SessionStart 行 / M20 承接) |
| 完整性:写时机 + 更新时机 + 失效重审 | ✅ 三态全覆盖(初始 / 完成 / 失效重审) |
| 完整性:hook 读规则 | ✅ skip 强 grep / 反审待办弱辅助 |
| 不歧义:reason 非空判定 | ✅ POSIX `\S` 至少 1 字符 |
| 不歧义:audit 路径格式 | ✅ 反引号 + 仓库相对路径 |
| 内部一致性:与 C2 audit 文件名格式 | ✅ 反审待办字段引用的 audit 路径采用 C2 锁定的 `meta-review-YYYY-MM-DD-HHMMSS-[主题].md` 命名 |
| 内部一致性:与 M20 反审检测 | ✅ 反审待办字段与 M20 audit covers 检测互补 |

### Notes(无 controller 待决项)

- skip 字段的"主题"语义不在本契约定义(reason 是自由文本,不强制结构)。process-audit 反向审 reason 质量(D22 fix-9 (iv))由治理层 M9 落地,本契约不约束。
- 反审待办字段不限于"P0.9.1 落地反审"一个 case,但本契约只锁 P0.9.1 case;未来若需扩展(如 P0.9.1.5 落地反审),由当时新 case 增量补 marker(预留 marker 命名空间在 M1 governance 内定)。

---

## C4:M2 审查维度三段 pattern 节内容(模态分型)(锁定版)

**类型**:契约任务(prompt 结构契约 — 静态文件结构 + runtime 嵌入约束)
**关联模块**:M2(定义)/ M6-M9(消费 prompt 结构)/ M10-M13(skill 引)
**spec 锚点**:§3.1.4 + §3.1.5 + §3.1.6 + §3.1.7(runtime 嵌入)+ D2 + D7 + D22 fix-2(防下游污染)
**plan 锚点**:plan §3 C4(line 265-335)

### 文件位置

`docs/governance/meta-review-rules.md` 内一节,精确节标题:

```markdown
## 审查维度三段 pattern(供对抗式 agent 引用)
```

> **节标题字面**精确为 `## 审查维度三段 pattern(供对抗式 agent 引用)`;包括括号字 / 中文括号(`(`)/ 标点空格全部精确一致。grep 校验需可命中此字符串。

### 子结构(三套模板,均不可省略)

#### 子节 1:对抗式 agent(M6 design-reviewer / M7 evaluator)— A/B/C 三段全采用

精确子节标题:`### 对抗式 agent prompt 模板`

精确正文:

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

精确子节标题:`### 混合式 agent prompt 模板`

精确正文:

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

精确子节标题:`### 事实统计式 agent prompt 模板`

精确正文:

```markdown
### 事实统计式 agent prompt 模板

N1. 流程遵从度(固定维度,可细化粒度)
N2. 效果满意度(固定维度,可细化粒度)
G.  调度者按主题细化粒度(可选)
    ### 本次粒度细化
    - 范围: [全 session / 本批次 / 时间窗口]
    - 维度细化: [每维度内的子项]
```

### 配套静态约束(D22 fix-2 — 防下游污染)

实施 M6-M9 时必须遵守:

- **agent 文件 prompt 只放结构占位 + 引用 M2 路径**
- **禁止抄 M2 实文**(meta-review 流程描述 / scope 规则 / scope.conf glob 等)
- **meta 治理实文仅由调度者运行时(§3.1.7)读 + 嵌入** — 这样 setup.sh 把 agent 分发到下游时,下游 agent 文件不含 meta 语境

### Runtime 嵌入软上限(D.2 应用)

> **D.2 用户决定(2026-04-26 新增)**:挑战者 prompt 嵌入字节软上限 = **8 KB**。

#### 精确语义

- **作用域**:调度者(§3.1.7)运行时读 M2 必要节(对抗式 / 混合式 / 事实统计式三套模板之一或多)+ 嵌入挑战者 prompt 时,该**嵌入内容**(从 M2 取的字节,不含调度者额外构造的 prompt 框架)
- **软上限**:**8192 字节(8 KB,UTF-8 编码下的字节数)**
- **超限行为**:**log 警告,不阻断**
  - 警告内容:"⚠️ M2 嵌入字节超 8 KB 软上限(实际 N 字节,建议精简引用节范围)"
  - 输出位置:调度者操作日志或挑战者 prompt 内附加 system note(实施层定具体方式)
  - 不影响挑战者 fork 或 audit 产出
- **建议**:8 KB 以下;**M2 实施时(I3.1)精简三套模板正文,使任一单模板抽出嵌入后 ≤ 8 KB**(典型场景下应远低于此值)

#### 与 D5(单 prompt 字节软上限)区别

- **D5(spec §7.1)**:单 prompt 总字节软上限,~64 kB,涵盖完整挑战者 prompt(包括待审查对象 / 治理参考 / M2 嵌入 / 输出格式约束等)
- **D.2(本契约)**:仅"M2 节嵌入"那部分的字节,8 KB
- **关系**:D.2 ⊂ D5;两层软上限不冲突,D.2 是更细颗粒约束

### Runtime 嵌入步骤(D.2 + §3.1.7 配套)

```text
调度者识别 scope=meta(§3.1.1)后:
  1. Read M2 `docs/governance/meta-review-rules.md`
  2. 按 agent 模态选取相应子节内容(对抗式 / 混合式 / 事实统计式)
  3. 测量选取内容的 UTF-8 字节数
     - ≤ 8192 字节:正常嵌入
     - > 8192 字节:log 警告 + 嵌入(不阻断)
  4. 嵌入挑战者 prompt(§3.1.5 挑战者调用契约的输入字段)

agent 文件(M6-M9)本身:
  - 只放结构占位 + 引用 M2 路径(D22 fix-2)
  - 不抄 M2 实文
  - setup.sh 分发到下游时,下游 agent 文件无 meta 语境
```

### 验证结果

| 检查项 | 结果 |
|---|---|
| vs spec §3.1.6 三段结构契约 | ✅ 三套模板(对抗式 / 混合式 / 事实统计式)逐字一致 |
| vs spec §3.1.4 / §3.1.5 流程引用 | ✅ pattern 节被 §3.1.4 Step 1 / §3.1.5 挑战者 prompt 输入引 |
| vs spec §3.1.7 runtime 嵌入契约 | ✅ 配套约束(只引路径不抄实文 + 调度者运行时读)对齐 |
| vs D2(模态分型) | ✅ M6/M7 全 A/B/C / M8 混合 / M9 事实统计 N 维 |
| vs D7(bootstrap 4 维) | ✅ 对抗式 B 段嵌 4 维基线(核心原则合规 / 目的达成度 / 副作用 / scope 漂移) |
| vs D22 fix-2(防下游污染) | ✅ 配套约束节明示 |
| 完整性:三模态全覆盖 | ✅ 子节 1/2/3 均有完整模板 |
| 完整性:写侧 + 读侧 | ✅ 写侧:M2 内含三套模板 / 读侧:调度者 runtime 读 + 嵌入 |
| 完整性:D.2 8 KB 软上限 | ✅ 应用并明示 |
| 不歧义:精确节标题 | ✅ 主节标题 + 三子节标题逐字精确 |
| 不歧义:8 KB 软上限语义 | ✅ 字节单位 / UTF-8 / 软上限不阻断 |
| 内部一致性:与 C5 hook 注册关系 | ✅ M2 是 governance 文件,不直接被 hook 注册;但 M2 改动属 scope=meta(C1 A 组),改它触发 meta-review |

### D.2 应用说明

**用户决定**:挑战者 prompt 嵌入字节软上限 = 8 KB。

**应用位置**:本契约 C4 末"Runtime 嵌入软上限(D.2 应用)"小节。

**论证**:
- D5 已有"单 prompt 字节软上限 ~64 kB"(spec §7.1),但**未细分 M2 嵌入部分**;实施 M2 / 调度者运行时若把整个 M2 文件原样嵌入,会挤占其他 prompt 字段空间(待审查对象 / 治理参考 / 输出约束)
- 8 KB 软上限对单模态(对抗式 / 混合式 / 事实统计式)每套模板留出充分空间(三套模板正文当前 plan / spec 内合计 < 1 KB)
- 软上限设计:超限不阻断(避免 ad-hoc 维度增量被硬卡),仅 log 警告;8 KB 以下推荐
- I3.1 实施 M2 时按 8 KB 上限校对三套模板字节,典型场景下应远低于此值

### Notes

- **D.2 软上限不强制实施 hook 校验**:8 KB 校验在调度者 runtime 进行,不在 hook 内强制(hook 不读 M2 嵌入内容)。
- **超限警告输出位置**:实施层(I-task)选具体方式 — 候选包括(a)调度者操作日志(stderr)/(b)挑战者 prompt 内 system note 附加。本契约不锁定具体输出方式。
- **本契约无 controller 待决项**。

---

## C5:M19 templates/settings.json 与 M18 差异规约(锁定版)

**类型**:契约任务(双轨模板差异点)
**关联模块**:M18(harness 自身)/ M19(分发模板)/ M14(setup.sh 改 source)/ M20(配套 D.1 拆分)
**spec 锚点**:§3.1.8 + §4.1.6 + D19 a 方案
**plan 锚点**:plan §3 C5(line 337-374)

### 双轨身份

| 文件 | 路径 | 用途 |
|---|---|---|
| **M18** | `.claude/settings.json` | harness 自身用(自身 hook 注册 + meta hook 注册) |
| **M19** | `harness/templates/settings.json` | 分发模板(下游用,无 meta hook 注册) |

### 唯一差异点(精确)

| 字段 | M18(harness 自身) | M19(分发模板) |
|---|---|---|
| `hooks.PostToolUse` | 现状不变 | **同 M18** |
| `hooks.PreToolUse` | 现状不变 | **同 M18** |
| `hooks.SessionStart` | 数组列出 `session-init.sh` + **D.1 应用后**:同时含 `meta-self-review-detect.sh` | **数组列出 `session-init.sh`**(无 `meta-self-review-detect.sh`,因 M14 命名前缀过滤) |
| `hooks.Stop` | **追加** M15 `check-meta-review.sh` 注册条目 | **不含** M15 注册条目;其余条目同 M18 |

### M18 SessionStart 数组示例(D.1 应用后,harness 自身用)

```json
"SessionStart": [
  {
    "matcher": "",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-init.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/meta-self-review-detect.sh" }
    ]
  }
]
```

### M18 Stop 数组示例(harness 自身用)

```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-handoff.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-finishing-skills.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-evidence-depth.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-meta-review.sh" }
    ]
  }
]
```

### M19 SessionStart 数组示例(D.1 应用后,分发模板)

```json
"SessionStart": [
  {
    "matcher": "",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-init.sh" }
    ]
  }
]
```

> **D.1 关键**:M19 SessionStart 数组**不含** `meta-self-review-detect.sh`。下游获得 M19 后,即使 settings.json 内列了该路径也无该 hook 文件(M14 命名前缀过滤过滤掉),**所以 M19 直接不列**(避免下游遇到 not-found 错误)。

### M19 Stop 数组示例(分发模板)

```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-handoff.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-finishing-skills.sh" },
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-evidence-depth.sh" }
    ]
  }
]
```

### 双轨维护规则

- **加 meta hook**(P0.9.2 / P0.9.3 等)→ **只改 M18**,不动 M19(M19 永远不含 meta hook 注册段)
- **加 feature hook**(罕见)→ **同步改 M18 + M19**
- **校对**:可用 jq diff 自动校对 M18/M19 除 meta hook 段外结构一致(I-task 实施时定具体方式;不在本契约锁定)

### M14 setup.sh 改 source 配套(line 71)

- 原:`cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/"`
- 改:`cp "$SCRIPT_DIR/templates/settings.json" "$TARGET_DIR/.claude/"`(指向 M19)

> 此改动是 M14 实施任务(I8.1)范围,本契约只声明 source 关系,具体改动由 I8.1 落地。

### 本阶段(P0.9.1) harness 自身行为

> **再强调序言警告**:harness 自身 hook 激活不在 P0.9.1 scope 内。
>
> 即:
> - I7.1 创建/更新 M18 时,**确实追加 M15 + meta-self-review-detect.sh 注册行**(让 settings.json 文件内容与契约一致)
> - 但**不在 harness 仓库实际触发 hook 链**(用户决定本阶段不调整开发环境;具体不激活方式由 I7.1 / I7.2 实施时定 — 候选包括(a)文件就绪但 settings.json 不写注册行直到下个阶段 / (b)写但 hook 文件 exit 0 占位 — 由 controller 在 I-task 启前澄清)
> - **下游分发逻辑(D19 a 方案 / D12 命名前缀过滤)保留**(分发是文件层面,与本仓库激活无关)

### 验证结果

| 检查项 | 结果 |
|---|---|
| vs spec §4.1.6 distribution_settings_template | ✅ 一致(M19 结构 + 唯一差异点) |
| vs spec §3.1.8 setup.sh line 71 改造 | ✅ 一致(改 source 指向 M19) |
| vs D19 a 方案(零污染) | ✅ 一致(双轨独立维护) |
| 完整性:四个 hook 数组(Post/Pre/Session/Stop)全覆盖 | ✅ 表格四行 |
| 完整性:M18 / M19 双向举例 | ✅ Stop 数组双向举例 + SessionStart 双向举例 |
| 完整性:D.1 应用 — SessionStart 行重写 | ✅ 不再用 sed 删除,改用拆分 + 命名前缀过滤 |
| 完整性:维护规则 | ✅ 加 meta hook / 加 feature hook 两路明示 |
| 不歧义:M14 setup.sh 改 source 路径 | ✅ 精确为 `$SCRIPT_DIR/templates/settings.json` |
| 内部一致性:与 C1 scope.conf F 组 | ✅ M19 路径 `harness/templates/settings.json` 已在 C1 F 组,改 M19 触发 meta-review |
| 内部一致性:与 D.1 拆分 | ✅ M20 拆分 `session-init.sh` + `meta-self-review-detect.sh`,后者命名前缀 `meta-` 触发 D12 过滤 |

### D.1 应用说明

**用户决定**:M20 distribution-isolation 方法 = Option 2(split files + naming prefix),替代原 plan / spec 中的"sed 删除反审检测段"方案。

**精确执行**:

1. **拆分 M20 文件为两个**:
   - `.claude/hooks/session-init.sh` — 通用 SessionStart 注入(PROGRESS / handoff / git status 等),**可分发下游**
   - `.claude/hooks/meta-self-review-detect.sh` — M20 反审检测段(§3.1.10 完整逻辑),**不分发下游**

2. **触发 D12 命名前缀过滤**:`meta-self-review-detect.sh` 文件名以 `meta-` 开头,M14 setup.sh 命名前缀过滤(D12)自动排除该文件,无需 sed 编辑。

3. **M19 SessionStart 数组对应**:**不含** `meta-self-review-detect.sh`(因下游本来就没这文件,settings.json 内列也不会触发)。

4. **M18 SessionStart 数组对应**:含两文件(`session-init.sh` + `meta-self-review-detect.sh`),供 harness 自身用。

5. **C5 SessionStart 行注释重写**:删除原"注:session-init.sh 反审检测段需在分发版本内 sed 删除,见 I8.1"的 sed 注释,改为"M20 拆分两文件 + meta-* 命名前缀过滤"。

**论证**:
- **拆分文件**比 sed 删除更清晰:文件分离即语义分离;sed 是脆弱编辑(spec 改动后 sed pattern 需重定),拆分是结构性隔离
- **命名前缀过滤已实现**(D12):`meta-` 开头的 hook 文件自然不分发,与 M15 / M16 同套机制
- **M19 不列 `meta-self-review-detect.sh`**:Claude Code settings.json 内列 hook 路径但文件不存在的处理是平台相关行为(可能 silent skip 或 warning);为避免下游遇到任何 ambiguity,M19 SessionStart 数组**直接不列** meta hook
- **维护负担一致**:与 D19 a 方案双轨同向 — 加 meta hook 只改 M18 不动 M19

**对实施的影响**:
- I6.3 (扩展 M20):**改为新建** `meta-self-review-detect.sh`(承担反审检测段)+ 保持 `session-init.sh` 作为通用 hook(若现有 session-init.sh 已有 PROGRESS / handoff 注入,**保留不动**;反审检测**完全在新文件内**)
- I7.1 (M18 settings.json):SessionStart 数组追加 `meta-self-review-detect.sh` 注册行
- I7.2 (M19 templates/settings.json):SessionStart 数组**只列 `session-init.sh`**(不列 meta hook)
- I8.1 (M14 setup.sh):**删除** sed 删除反审检测段相关逻辑(若 plan 中有);仅保留命名前缀过滤(D12)即可

### Notes(potential controller 决策)

- **本阶段 harness 自身 hook 激活方式**:序言已声明"hook 激活不在 P0.9.1 scope";I7.1 实施 M18 时,具体如何让"文件就绪但 hook 实际不在 harness 自身触发"由 I-task agent 决定。**候选**:(a)settings.json 不写 meta hook 注册行,等用户决定后再写;(b)写注册行但 hook 文件本身 exit 0 占位;(c)写注册行 + 文件含完整逻辑,激活与否靠用户在 settings.local.json 注释。本契约不锁定 — 由 controller 在 I7.1 启前澄清。
  - **flagged for controller**:此项需 controller 在批次 7 开始前给出明确激活策略,否则 I7.1 / I7.2 / T 系列测试无法判断"测试 vs harness 自身行为"的预期。

---

## 综合验证总结

### 整体内部一致性矩阵

| 检查 | 结果 |
|---|---|
| C1 scope.conf glob 含 C2 covers 引用的所有路径 | ✅ A+B+C+D+F 全组覆盖;治理文件含 `meta-*.md` / `meta-*.sh` / `meta-scope.conf` |
| C2 audit 文件本身被 C1 排除 | ✅ `!docs/audits/meta-review-*.md` + `!docs/audits/archive/**` |
| C3 反审待办字段引用的 audit 路径与 C2 命名规则一致 | ✅ `meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md` 命中 D14 命名 |
| C3 skip 字段被 C5 中 hook 数组(check-meta-review.sh)读 | ✅ M15 / M16 读 skip(C3)+ covers(C2);C5 注册 M15 |
| C4 M2 文件改动属 scope=meta(C1 A 组) | ✅ `docs/governance/*.md` 命中(M2 是 governance 文件) |
| C4 M2 嵌入软上限 8 KB(D.2)与 D5 总 prompt 64 kB 不冲突 | ✅ D.2 ⊂ D5 |
| C5 D.1 拆分 `meta-self-review-detect.sh` 触发 C1 B 组 + D12 命名前缀过滤 | ✅ B 组 `.claude/hooks/*` 命中 + meta- 命名前缀触发分发过滤 |
| C5 M14 改 source 指向 M19,M19 改动属 scope=meta(C1 F 组) | ✅ `harness/templates/*.json` 命中 |
| 所有契约不引入新决策 | ✅ 仅应用 D.1 / D.2(用户已决)+ 解决 line 406(简洁选项,不破坏 spec) |

### 完整性检查(spec 字段全覆盖)

| spec 锚点 | 契约覆盖 |
|---|---|
| §3.1.1 scope 识别 | C1 |
| §3.1.4 meta-review 流程 + audit 产出 | C2(audit 格式)+ C4(pattern 节) |
| §3.1.5 挑战者调用 | C4(嵌入约束) |
| §3.1.6 三段结构契约 | C4 |
| §3.1.7 runtime 嵌入 | C4(D.2 8 KB + D22 fix-2 配套) |
| §3.1.8 setup.sh 分发隔离 | C5(M14 改 source)+ C1(F 组 M19 入 scope) |
| §3.1.9 hook 执法 | C2(读 covers + 失效)+ C3(读 skip) |
| §3.1.10 SessionStart 反审检测 | C2(覆盖 covers 检测)+ C3(反审待办字段)+ C5(D.1 拆分 meta-self-review-detect.sh) |
| §4.1.1 audit_trail | C2 |
| §4.1.2 meta_scope_config | C1 |
| §4.1.3 handoff_meta_review_skip | C3(字段 1) |
| §4.1.5 audit_covers_validity | C2 失效规则节 |
| §4.1.6 distribution_settings_template | C5 |
| §4.1.7 handoff_self_review_pending | C3(字段 2) |
| D2 模态分型 | C4 |
| D7 bootstrap 4 维 | C4(子节 1 B 段) |
| D12 命名前缀过滤 | C5(D.1 拆分配套) |
| D14 audit 文件名 HHMMSS | C2 |
| D17 hook 模块数 2(Stop + pre-commit) | C5(M18 Stop 数组追加 M15 注册;M16 是 git hook 不在 settings.json) |
| D18 scope.conf 外部化 | C1 |
| D19 a 方案 双轨模板 | C5 |
| D21 fix-8 A+C 组合 | C3(C 部分)+ C5(A 部分配套 D.1) |
| D22 fix-9 (iii) covers 比对 | C2 |
| D22 fix-9 (v) 治理文件入 scope | C1(不在 ! 排除) |

### 跨 controller 待决 flag

| 编号 | 内容 | 影响阶段 |
|---|---|---|
| **C5-1** | harness 自身 hook 激活策略(P0.9.1 scope 外) | 批次 7(I7.1 / I7.2)开始前 |

> 仅此一项 flagged。其他契约可直接进入 I-task 实施。

---

## 完成声明

- **C1-C5 锁定完成**,作为批次 2-8 实施的 SSoT
- **D.1 / D.2 已应用**(C5 SessionStart + C4 8 KB)
- **plan line 406 已解决**(扩 B 组为 `.claude/hooks/*`)
- **无 spec-level 矛盾**(所有契约可机械落地)
- **C5-1** 一项需 controller 在批次 7 启前澄清(harness 自身 hook 激活方式)

I-task agent 应严格按本文档"最终精确文本"实施;遇歧义优先回查 spec 同锚点节(本文档每契约头部已列锚点)。

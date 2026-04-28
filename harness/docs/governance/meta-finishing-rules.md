# meta-finishing-rules.md — meta scope 改动 finishing 流程治理

> **Runtime governance 文件**(M1)。当调度者识别本次改动 scope=meta 或 scope=mixed,进入 finishing 阶段时,本文件被读取以引导四步 finishing 流程。
>
> **本文件 ≠ spec**:本文件是 runtime 流程契约;详细论证、决策依据、第七/第八轮 fix 链由 spec `docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md` 承载。本文件按章节引用 spec,不重复其论证段。
>
> **职责分工**:本文件覆盖 meta 改动 finishing 四步(Step A/B/C/D);meta-review 流程本身见 M2 `meta-review-rules.md`;hook 执法见 M15 / M16;scope 配置见 M17。

---

## 1. 简介 + 治理边界

### 1.1 文件定位

- **类型**:governance(runtime 流程治理)
- **路径**:`docs/governance/meta-finishing-rules.md`(spec §2.1 锁定)
- **命名前缀**:`meta-`(M14 setup.sh 命名前缀过滤 D12 触发 — 不分发下游)
- **对应模块**:M1(spec §2.1)
- **scope 类别**:本文件改动属 scope=meta(C1 A 组 `docs/governance/*.md` glob 命中) — 改本文件本身必须走 meta-review(bootstrap 循环可接受,类似编译器自举,详见 spec §1.3 / D22 fix-9 (v))

### 1.2 治理边界

- **本文件覆盖**:meta 改动 finishing 四步(Step A scope 判断 / Step B meta-review 流程触发 / Step C decision 立档 / Step D ROADMAP / 进度同步)+ meta evidence depth 定义节(spec §4.1.4 B1 决策合并)+ handoff 字段引导(skip + 反审待办)
- **不覆盖**:
  - meta-review 流程内部(挑战者怎么 fork / 维度怎么选 / pattern 怎么嵌入 / audit 怎么产) → 见 M2 `meta-review-rules.md`(spec §3.1.4 - §3.1.7)
  - hook 执法实现(Stop hook / pre-commit hook 怎么扫 covers / 怎么读 skip 字段) → 见 M15 `check-meta-review.sh` / M16 `check-meta-commit.sh`(spec §3.1.9)
  - scope 配置数据(glob 列表) → 见 M17 `.claude/hooks/meta-scope.conf`(spec §4.1.2)
  - scope 触发判定的人类对照表(用户描述改动 → scope 标签) → 见 M3 `/CLAUDE.md`(spec §3.1.1)
  - finishing 阶段 scope 分流入口(feature / meta / mixed / none 谁走哪个 finishing) → 见 M5 `finishing-rules.md`(spec §3.1.2)

### 1.3 引用 spec 锚点(总览)

| 本文件节 | spec 锚点 | contract |
|---|---|---|
| §2 触发条件(scope 识别 → finishing 入口) | spec §3.1.1 + §3.1.2 | C1 |
| §3 meta 改动 finishing 四步 | spec §3.1.3 | C2 / C3 |
| §3 Step A skip 字段引导 | spec §4.1.3 | C3 字段 1 |
| §3 Step C decision 立档(D9 范式) | spec §3.1.3 + 决策 D9 | — |
| §3 Step D 反审待办字段引导 | spec §4.1.7 + 决策 D21 | C3 字段 2 |
| §4 meta evidence depth meta-L1~L4 | spec §4.1.4 | — |
| §4.2 三种 scope handoff 填法示例 | spec §4.1.4 fix-4 | — |
| §5 handoff 字段引导汇总 | spec §4.1.3 + §4.1.7 | C3 |

---

## 2. 触发条件(scope 识别 → finishing 入口)

### 2.1 scope 识别(引 spec §3.1.1)

scope 由调度者按 spec §3.1.1 + M17 `.claude/hooks/meta-scope.conf` + M3 `/CLAUDE.md` 对照表识别;输出标签四类:

| scope | 含义 | 进入本文件 |
|---|---|---|
| `meta` | 改动全部命中 scope.conf include glob(治理 / hook / skill / agent / setup.sh / template 等) | ✅ 走本文件四步 |
| `mixed` | 任一文件命中 include glob,其他文件未命中 | ✅ 仅 meta 部分走本文件四步;feature 部分另走 M5 finishing-rules |
| `feature` | 改动是 harness 仓库内 feature 业务代码(罕见) | ❌ 走 M5 finishing-rules,本文件不介入 |
| `none` | 全部改动命中 scope.conf 外(ROADMAP / handoff / 用户文档等) | ❌ 同 feature,不入本文件 |

### 2.2 finishing 阶段分流入口

> M5 `finishing-rules.md` 顶部分流入口(I4.2 实施)按 scope 标签将调度者引向对应 finishing:
>
> - scope ∈ {meta, mixed} → 进入本文件(M1)四步
> - scope ∈ {feature, none} → 留在 M5 现有流程

### 2.3 排除规则(spec D22 fix-9 (v))

- **只排除流程产出物**:`docs/audits/meta-review-*.md` + `docs/audits/archive/**`(避免改 audit 触发审 audit 的无穷递归)
- **不排除治理文件**:`meta-*.sh` / `meta-*.md` / `meta-scope.conf`(含本文件)入 scope — 改它们直接改变治理规则,**必须走 meta-review**
- 详见 M17 `meta-scope.conf` 顶部注释 + spec §4.1.2

---

## 3. meta 改动 finishing 四步(主体 — 引 spec §3.1.3)

> 详细 Step A-D 契约文本(输入 / 输出 / 错误处理)见 spec §3.1.3。本节列每步的关键决策点 + 调度者动作 + handoff 字段引导,不重复 spec 论证。

### Step A:scope 判断 + skip 决定

**调度者动作**:

1. 按 §2.1 完成 scope 识别(已由 M5 分流入口预定),复核改动文件清单与 scope 标签
2. 按 spec §3.1.3 Step A 规则,判本次改动是否需要走 meta-review:
   - **scope=meta 且重大** → 必须走 meta-review(进入 Step B)
   - **scope=meta 且小修(仅 typo / 链接 / 注释等)** → 可跳过 meta-review,按下方"skip 字段引导"写入 handoff
   - **scope=mixed** → 仅对 meta 部分走 meta-review(进入 Step B);feature 部分另走 M5 finishing-rules
3. 若选跳过(仅在上述限定情形,不是自由判断),**立即写入 handoff `## meta-review: skipped` 字段**(见下方"skip 字段引导")

**skip 字段引导(C3 字段 1 — 逐字按契约)**:

精确格式:

```markdown
## meta-review: skipped(理由: <非空理由>)
```

写入示例(合规):

```markdown
## meta-review: skipped(理由: 仅修改 typo 注释,无语义变更)
```

不合规示例(reason 空 / 全空白 / 无括号字段):

```markdown
## meta-review: skipped(理由: )
## meta-review: skipped(理由:    )
## meta-review: skipped
```

字段规则:

- **marker**:固定字符串 `## meta-review: skipped`(hook grep 识别)
- **括号字段**:`(理由: <reason>)` 整体必出现,括号 + `理由:` + 内容 + 括号闭合
- **`<reason>`**:string,非空非全空白,至少 1 个非空白字符
- **括号必须半角**(`(` `)` U+0028/U+0029,不是全角 `(` `)` U+FF08/U+FF09)。中文 IME 默认全角,写入时需切换为半角。hook grep 字面匹配半角,全角不命中。依据:2026-04-28 meta-review C3 Y3
- **覆盖语义**:每次新 meta 改动开始时,调度者覆盖此字段(不累积旧 skip 记录),字段不归档(handoff 本来就 mutable)
- **hook 校验**(M15 / M16):grep `## meta-review: skipped\(理由: ([^)]+)\)`(POSIX ERE),提取 `\1` 后用 `\S` 至少匹配 1 个非空白字符 → skip 有效;否则 skip 无效,继续要求 audit

详见 contracts-locked.md C3 字段 1 + spec §4.1.3。

**错误处理**(spec §3.1.3 错误处理):

- Step A 判"跳过"但后续 Step C 发现需要 decision → 回 Step A,标"判错"事件到本次 audit(若 Step B 走则补登记;若已彻底跳过 Step B,则在 decision 文件内说明)

### Step B:触发 meta-review 流程

**调度者动作**:

- Step A 判"走 meta-review"时,调用 M2 流程(见 `docs/governance/meta-review-rules.md`)
- 系统设计 / design-review / process-audit 等 skill 在 scope=meta 路径下都引 M2;调度者按 M2 §3 流程并行 fork N 个挑战者(对抗式 / 混合式 / 事实统计式按主题选模态)
- 挑战者审查完成后,调度者按 M2 §7 写 audit 文件(YAML covers + 5 段正文)

**关键引用**:

- meta-review 流程契约 → M2 §3 + spec §3.1.4
- 挑战者调用契约 → M2 §4 + spec §3.1.5
- runtime 嵌入契约(调度者 read M2 + 嵌入挑战者 prompt)→ M2 §5 + spec §3.1.7
- 三段 pattern(对抗式 / 混合式 / 事实统计式)→ M2 §6 + spec §3.1.6
- audit 产物规范 → M2 §7 + spec §4.1.1
- audit 失效规则 → M2 §8 + spec §4.1.5

**audit 归档位置**(C2 + spec §4.1.1 + D14):

- 路径:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md`
- 命名:HHMMSS 用本地时间(D14 第七轮加,与 process-audit 现行命名同结构)
- 半年归档 → `docs/audits/archive/YYYY-HN/`(D15;P0.9.1 仅声明策略,首次半年归档由后续阶段触发)

**错误处理**(spec §3.1.3 + M2 §3.2):

- Step B 失败(挑战者 fork 异常 / audit 未产 / verdict 不通过) → 见 M2 §3.2 (c) 降级执行 / 重 fork 策略
- audit 产出后 verdict=needs-revision → 调度者按 audit 列出问题修改改动,重走 Step B(可能产新 audit)
- audit 产出后 verdict=overturn → 撤回本次 meta 改动,记录到 ROADMAP / handoff,不进入 Step C

### Step C:decision 立档(若有架构决策)

**调度者动作**:

- meta 改动若涉及架构决策(如新增 / 修改一条 governance 规则 / 改 spec 边界 / 引入新 hook 等),**必做** decision 立档
- 若 meta 改动仅是工程调整(如 hook 文件内重构、注释润色)且无架构决策,可不立档,但需在 handoff 或 PROGRESS 内简记
- decision 文件位置:`docs/decisions/<YYYY-MM-DD>-<主题>.md`

**模板范式选择**:

| 决策类型 | 范式 | 模板使用 |
|---|---|---|
| 普通方案选择型(A/B/C 比较) | `docs/references/decision-template.md`(若有) | 标准 "问题 / 方案 A/B / 决定 / 后续" 节 |
| **meta-level 根源承认型** | **`docs/decisions/2026-04-17-harness-self-governance-gap.md` 范式**(D9) | 加 **"Bootstrap 声明"** 节 + **"不做"** 节防 scope 扩散 |

**D9 范式应用规则**(spec §7.1 D9):

- 当 meta 改动是"承认存在性问题 / 系统缺口 / bootstrap 限制"等无 A/B 可选的单选择型 decision → 采用 D9 范式
- 文件头部加 **"Bootstrap 声明"** 节:声明本 decision 是 ad-hoc bootstrap 动作,后续治理规范不应追溯性要求其通过流程
- 文件头部加类型标记:**"根源承认型"**(替代标准的"方案选择型"标记)
- 加 **"不做(防 scope 扩散)"** 节:明示本 decision 不解决 / 不推翻 / 不定义的内容
- 加 **"突破模板骨架的说明"** 节:说明为何本次不沿用标准模板

**范式参考文件**:`docs/decisions/2026-04-17-harness-self-governance-gap.md`

**错误处理**(spec §3.1.3 错误处理):

- Step C 立档完成后发现本次改动破坏了现有 decision → 新建 superseding decision(覆盖型),旧 decision 标 🔴 已废弃 + 在新 decision 头部 "关联" 节链回旧 decision

### Step D:ROADMAP / PROGRESS 同步 + 反审待办字段(P0.9.1 特例)

**调度者动作 — 通用同步**:

- meta 改动落地后,**必做**:
  - `docs/ROADMAP.md`:对应阶段 / 任务条目状态更新(如 `🟡 进行中` → `🟢 已完成`)
  - `docs/PROGRESS.md`:里程碑或阶段表格更新(若该改动跨阶段)
  - `docs/decision-trail.md`:从本次 commit 涉及的 `docs/decisions/` 与 `docs/audits/` 提取 1-2 条**判断拐点** append(时间倒序,最新在上)。**meta 拐点(治理改动 / 缺口承认 / 用户原则确立)恰是 decision-trail 主要数据源,本步不可省**。提取规则与 M5 `finishing-rules.md` "通过" Step 2 同源(架构选择 / 用户原则确立 / 缺口承认 / 替代方案否决);跳过条件:本次改动无任何架构 / 原则级抉择。依据:`docs/decisions/2026-04-28-decision-trail-introduction.md`。**触发不限于 milestone commit** — 用户原则确立 / 缺口承认 等时点也可即时 append(不必等到下次 finishing)
  - `memory/project_harness_overview.md`:若有结构性变化(如新增模块 / 改架构)则同步

**调度者动作 — P0.9.1 特例(D21 fix-8 C 部分)**:

> P0.9.1 实施阶段最后一次 finishing(对应 P0.9.1 commit 进 main 前)有特殊留痕动作:写入 handoff `## 反审待办` 字段,作为 P0.9.1 落地反审本 spec 的待办登记。

**反审待办字段引导(C3 字段 2 — 逐字按契约)**:

精确格式 — 初始值(P0.9.1 落地最后一次 finishing 写入):

```markdown
## 反审待办

P0.9.1 落地反审 — 未完成
```

精确格式 — 完成态(反审 audit 产出后更新):

```markdown
## 反审待办

P0.9.1 落地反审 — 已完成 — audit:`docs/audits/meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`
```

> 注意:audit 路径用反引号包裹(代码风格,与 spec §4.1.7 示例一致)。

字段规则:

- **marker**:固定字符串 `## 反审待办`(字段标识)
- **status 行**:`P0.9.1 落地反审 — 未完成` 或 `P0.9.1 落地反审 — 已完成 — audit:<path>`(两态切换)
- **audit 路径**(完成态):仓库相对路径,反引号包裹,符合 C2 命名 `meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`

写入 / 更新时机(M1 引导规则):

1. **初始写入**:**P0.9.1 实施阶段最后一次 finishing**(对应 P0.9.1 commit 进 main 前),M1 引导调度者在 handoff 加此字段(初始值 `未完成`)
2. **更新**:反审走完(M2 §6 pattern 节 + audit 产出 + verdict=pass)后,M1 引导调度者更新字段为 `已完成 — audit:<path>`,其中 `<path>` 为反审 audit 仓库相对路径
3. **不清理**:反审完成后字段保留(不清理) — 作为 P0.9.1 闭环留痕
4. **失效重审**:若 P0.9.1 重大改动(commit 进 main)后,M2 §8 covers 失效规则触发反审 audit 失效 → 字段重置为 `未完成` + M20 SessionStart hook 重新注入提醒

hook 互补关系(M20 + 字段):

- **权威**:audit covers 是反审完成的权威依据(M20 SessionStart hook 按 covers 判定 — covers 含本 spec 路径即视为反审完成)
- **被动留痕**:本字段是辅助 — 调度者读 handoff 见此字段判断反审是否待办;不强制 hook 解析
- **优先级**:**covers 是权威**,若字段失同步则以 covers 为准

详见 contracts-locked.md C3 字段 2 + spec §4.1.7 + 决策 D21(`docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`)。

---

## 4. meta evidence depth(spec §4.1.4 + fix-4)

> 本节按 spec §4.1.4 B1 决策合并:meta evidence depth 定义节并入本文件(不另建独立文件)。`check-evidence-depth.sh` 不解析档位值,本节只规范 markdown 填法。

### 4.1 定义 meta-L1 ~ meta-L4

feature 层的 L1-L4(单元 / 集成 / 自动化 / 真实场景)对 meta 改动不适用 — meta 改动改的是规则文本,而非可运行代码。本 P0.9.1 重定义 **meta-L1 ~ meta-L4**(用 `meta-` 前缀避免与 feature 侧 L1-L4 + 本 spec 模块编号 M1-M4 歧义):

| 档位 | 含义 | 证据形式 | 覆盖 |
|---|---|---|---|
| **meta-L1**:节内自检 | design 阶段每节末尾的自检清单全通过 | 设计文档中 [x] 勾选(本 spec §2-§9 自检全勾选) | 改动前置自洽 |
| **meta-L2**:全局自检 | designer 返回草稿后独立自检挑战者全局检查 | design-rules.md 定义的 10 项全局自洽检查结果 | 草稿内部一致 |
| **meta-L3**:meta-review 对抗审查 | 对抗式 / 混合式 / 事实统计式 meta-review(spec §3.1.4) | audit trail YAML covers 列出 + verdict=pass | 多视角对抗 / 模式 / 统计验证 |
| **meta-L4**:实战留痕 | 实际使用场景验证 — 下一个 meta 改动或 feature 使用时该规则是否发挥作用 | 后续 meta 改动 audit trail 是否引用本规则 / 真实数据点 | 落地有效性(需要时间) |

依据:spec §4.1.4 + §6.1 重定义。meta-L1 / meta-L2 在改动前完成,meta-L3 在 finishing 阶段完成,meta-L4 在后续真实改动累积。

### 4.2 handoff 三种 scope 填法示例(spec §4.1.4 fix-4 必给示例 — 逐字)

> handoff 字段 `## Evidence Depth` 现有 `check-evidence-depth.sh` hook 检测字段非空 + 非 `[待填]`。本节示例**逐字按 spec §4.1.4 fix-4** — meta 档位用 `meta-L1` ~ `meta-L4`,feature 档位用 `L1` ~ `L4`,mixed 改动**两套并列**(8 行典型上限,可少不可漏 — 至少各 1 行才算填写)。

#### scope=feature(纯 feature,典型 4 行)

```markdown
## Evidence Depth
- L1: ✅ src/foo/bar.test.ts 单元测试通过
- L2: ✅ scripts/integration-test.sh 集成测试输出
- L3: ✅ scripts/api-smoke.sh 自动化 API 验证
- L4: ✅ docs/decisions/2026-04-25-foo-bar.md 真实场景验证记录
```

#### scope=meta(纯 meta,典型 4 行)

```markdown
## Evidence Depth
- meta-L1: ✅ 设计文档每节末尾 [x] 勾选(本 spec §2-§9 自检全勾选)
- meta-L2: ✅ design-rules 10 项全局自洽通过(详见 §9 自检)
- meta-L3: ✅ docs/audits/meta-review-2026-04-25-143022-M0.md verdict=pass
- meta-L4: ⏳ 待观察(下一次 meta 改动 audit 是否引用本规则)
```

#### scope=mixed(典型 8 行 — meta + feature 各 4 行,**spec §4.1.4 fix-4 必给示例**)

```markdown
## Evidence Depth
- meta-L1: ✅ docs/governance/meta-finishing-rules.md 节内自检勾选
- meta-L2: ✅ design-rules 10 项全局自洽通过
- meta-L3: ✅ docs/audits/meta-review-2026-05-12-091533-M2-pattern.md verdict=pass
- meta-L4: ⏳ 待观察(meta 部分 — P0.9.1.5 启动时反审)
- L1: ✅ scripts/feature-foo-unit.test.ts 单元测试通过
- L2: ✅ scripts/feature-foo-integration.sh 集成测试输出
- L3: ✅ scripts/feature-foo-smoke.sh 自动化 API 验证
- L4: ✅ docs/decisions/2026-05-12-feature-foo.md 真实场景验证
```

### 4.3 格式规则(spec §4.1.4)

- 每行 `<档位标识>: <状态> <证据位置>` 三段
- meta 档位用 `meta-L1` ~ `meta-L4`,feature 用 `L1` ~ `L4`
- mixed 改动**两套并列**(8 行典型上限);可少不可漏 — 至少各 1 行才算填写
- `<状态>` 用 ✅(完成)/ ⏳(待观察)/ ❌(不通过 — 需补)/ ➖(不适用)
- `<证据位置>` 必须含具体路径或 audit 文件名,不能用"已完成"这类无指向词

### 4.4 hook 行为(B7 决策)

- **现有 hook 字段名 `## Evidence Depth` 不变**:`check-evidence-depth.sh` 仅检字段非空 + 非 `[待填]`,不解析档位值
- **新增 meta-L1~meta-L4 档位值不破坏现有 hook 行为**:同字段名,新档位值;mixed 8 行同样通过(字段非空)
- 不选 (b) 不同字段名(`## Evidence Depth (Meta)`):需改 hook 检测字段名,与"光谱 B+ 最小硬 hook"原则冲突

---

## 5. handoff 字段引导汇总

> 本节集中两个 handoff 字段的写入 / 更新 / 校验规则,供调度者执行 finishing 时一次性参照。两字段精确格式逐字引 contracts-locked.md C3。

### 5.1 字段 1:`## meta-review: skipped`(短期,每次 meta 改动可覆盖)

| 维度 | 内容 |
|---|---|
| 写入时机 | §3 Step A 调度者判"不走 meta-review"时,立即写入 handoff |
| 精确格式 | `## meta-review: skipped(理由: <非空理由>)` |
| marker | 固定字符串 `## meta-review: skipped` |
| 括号字段 | `(理由: <reason>)` 整体必出现 |
| reason 校验 | 非空非全空白,至少 1 个非空白字符(POSIX `\S` 匹配) |
| hook grep regex | `## meta-review: skipped\(理由: ([^)]+)\)`(POSIX ERE) |
| 覆盖语义 | 每次新 meta 改动开始时调度者覆盖,不累积 |
| 不归档 | handoff 本来就 mutable |
| spec 锚点 | §4.1.3 |
| contract | C3 字段 1 |

### 5.2 字段 2:`## 反审待办`(长期,直到反审完成)

| 维度 | 内容 |
|---|---|
| 写入时机 | **P0.9.1 实施阶段最后一次 finishing**(对应 P0.9.1 commit 进 main 前),§3 Step D 引导调度者写入(初始值 `未完成`) |
| 更新时机 | 反审走完(audit 产出 + verdict=pass)后,调度者更新字段为 `已完成 — audit:<path>` |
| 精确格式(初始) | `## 反审待办\n\nP0.9.1 落地反审 — 未完成`(两行,中间空一行) |
| 精确格式(完成) | `## 反审待办\n\nP0.9.1 落地反审 — 已完成 — audit:` `<反引号包裹的路径>`(两行,中间空一行) |
| marker | 固定字符串 `## 反审待办` |
| status 行 | 两态切换:`P0.9.1 落地反审 — 未完成` 或 `P0.9.1 落地反审 — 已完成 — audit:<path>` |
| audit 路径(完成态) | 仓库相对路径,反引号包裹,符合 C2 命名(`meta-review-YYYY-MM-DD-HHMMSS-p0-9-1-self-review.md`) |
| 不清理 | 反审完成后字段保留,作为 P0.9.1 闭环留痕 |
| 失效重审 | covers 失效规则触发字段重置为 `未完成` + M20 SessionStart hook 重新注入提醒 |
| hook 解析 | 不强制 — covers 是权威,字段失同步以 covers 为准 |
| spec 锚点 | §4.1.7 |
| contract | C3 字段 2 |
| 关联决策 | D21(`docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md`) |

### 5.3 两字段共存约束

- **同一 handoff 文件**:两字段共存,marker 不同(`## meta-review: skipped` vs `## 反审待办`),互不影响
- **不互覆盖**:skip 字段每次 meta 改动可覆盖;反审待办字段保留至反审完成
- **顺序无要求**:两字段在 handoff 内出现顺序不强制,handoff 模板可固定一种顺序便于阅读
- **grep 各自识别**:两 marker 字面不冲突,hook(M15 / M16)只解析 skip;反审待办由 M20 + 调度者读

---

## 附录 A:契约引用速查

| 本文件节 | C 编号 | 锁定文件 |
|---|---|---|
| §2 触发条件 / 排除规则 | C1 | `docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md` |
| §3 Step B audit 归档位置 / 命名 | C2 | 同上 |
| §3 Step A skip 字段 / Step D 反审待办字段 / §5 字段汇总 | C3 | 同上 |

## 附录 B:spec 锚点速查

| 本文件节 | spec 锚点 |
|---|---|
| §1.1 / §2.3 治理文件入 scope(bootstrap 循环) | §1.3 + D22 fix-9 (v) |
| §2.1 scope 四类 | §3.1.1 |
| §2.2 finishing 分流入口 | §3.1.2 |
| §3 finishing 四步主结构 | §3.1.3 |
| §3 Step A skip 字段 | §4.1.3 |
| §3 Step D 反审待办字段(P0.9.1 特例) | §4.1.7 + §3.1.10 |
| §4.1 meta-L1~L4 定义 | §4.1.4 + §6.1 |
| §4.2 三种 scope 填法示例 | §4.1.4 fix-4(第七轮补漏) |
| §4.4 hook 行为 B7 决策 | §4.1.4 B7 |

## 附录 C:决策引用速查

| 本文件涉及的决策 | spec §7.1 编号 / 独立 decision 文件 | 内容 |
|---|---|---|
| 模板范式 — Bootstrap 声明 / 根源承认型 | D9 + 范式参考 `docs/decisions/2026-04-17-harness-self-governance-gap.md` | §3 Step C |
| 反审触发 = A+C 组合(C 部分 = 本字段) | D21 + `docs/decisions/2026-04-26-p0-9-1-self-review-trigger.md` | §3 Step D / §5.2 |
| meta-L1~L4 重定义 | spec §4.1.4 + §6.1 | §4.1 |
| evidence depth 同字段名不同档位值 | B7 决策 | §4.4 |
| meta evidence depth 节并入 M1 | B1 决策合并 | §4 节存在 |
| 命名前缀过滤(不分发下游) | D12 | §1.1 命名前缀 |
| audit 文件名 HHMMSS | D14 | §3 Step B audit 归档位置 |
| audit 半年归档 | D15 | §3 Step B audit 归档位置 |
| skip 字段 reason 必填 grep 校空 | A5 | §3 Step A / §5.1 |
| 治理文件入 scope(只排产出物) | D22 fix-9 (v) | §1.1 / §2.3 |

---

**文档变更触发 meta-review**:本文件改动属 scope=meta(C1 A 组 `docs/governance/*.md` 命中) — 改本文件**必须**走 meta-review 流程(bootstrap 循环可接受,详见 spec §1.3 / D22 fix-9 (v))。

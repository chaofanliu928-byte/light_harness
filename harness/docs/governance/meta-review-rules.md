# meta-review-rules.md — meta scope 改动审查流程治理

> **Runtime governance 文件**(M2)。当调度者识别本次改动 scope=meta 或 scope=mixed,进入 meta 治理流程时,本文件被读取 + 嵌入挑战者 prompt。
>
> **本文件 ≠ spec**:本文件是 runtime 流程契约;详细论证、决策依据、第七/第八轮 fix 链由 spec `docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md` 承载。本文件按章节引用 spec,不重复其论证段。
>
> **唯一例外**:第 6 节"审查维度三段 pattern"由调度者运行时读 + 逐字嵌入挑战者 prompt(§3.1.7);为避免挑战者再去 read spec,该节的三套模板必须在本文件内逐字落地。

---

## 1. 简介 + 治理边界

### 1.1 文件定位

- **类型**:governance(runtime 流程治理)
- **路径**:`docs/governance/meta-review-rules.md`(spec §2.1 锁定)
- **命名前缀**:`meta-`(M14 setup.sh 命名前缀过滤 D12 触发 — 不分发下游)
- **对应模块**:M2(spec §2.1)
- **scope 类别**:本文件改动属 scope=meta(C1 A 组 `docs/governance/*.md` glob 命中) — 改本文件本身必须走 meta-review(bootstrap 循环可接受,类似编译器自举,详见 spec D22 fix-9 (v))

### 1.2 治理边界

- **本文件覆盖**:meta-review 流程(何时触发 / 怎么触发 / 挑战者怎么调用 / audit 怎么产 / 失效怎么判 / pattern 怎么嵌入 / handoff 字段怎么配合)
- **不覆盖**:
  - meta finishing 四步(Step A 判断 / Step B 触发本文件流程 / Step C decision 立档 / Step D ROADMAP 同步) → 见 M1 `meta-finishing-rules.md`(spec §3.1.3)
  - hook 执法实现 → 见 M15 `check-meta-review.sh` / M16 `check-meta-commit.sh`(spec §3.1.9)
  - scope 配置数据 → 见 M17 `.claude/hooks/meta-scope.conf`(spec §4.1.2)
  - scope 触发判定的人类对照表 → 见 M3 `/CLAUDE.md`(spec §3.1.1)

### 1.3 引用 spec 锚点(总览)

| 本文件节 | spec 锚点 | contract |
|---|---|---|
| §2 触发条件 | spec §3.1.1 | C1 |
| §3 meta-review 流程 | spec §3.1.4 | C2 / C4 |
| §4 挑战者调用契约 | spec §3.1.5 | C4 |
| §5 调度者运行时嵌入契约 | spec §3.1.7 | C4 |
| §6 审查维度三段 pattern(逐字) | spec §3.1.6 | C4 |
| §7 audit 产物规范 | spec §4.1.1 | C2 |
| §8 audit 失效规则 | spec §4.1.5 | C2 |
| §9 handoff 字段配合 | spec §4.1.3 + §4.1.7 | C3 |

---

## 2. 触发条件(scope 识别)

### 2.1 scope 四类定义

按 spec §3.1.1 + M17 `.claude/hooks/meta-scope.conf` 数据源:

| scope | 含义 | 进入 meta-review |
|---|---|---|
| `meta` | 改动全部命中 scope.conf include glob(治理 / hook / skill / agent / setup.sh / template 等) | ✅ 必走(除非按 §3.1.3 Step A 跳过且 handoff 写理由) |
| `mixed` | 任一文件命中 include glob,其他文件未命中 | ✅ 仅对 meta 部分走 meta-review |
| `feature` | 改动是 harness 仓库内 feature 业务代码(罕见) | ❌ 走现有 finishing,不入 M1 |
| `none` | 全部改动命中 scope.conf 外(ROADMAP / handoff / 用户文档等) | ❌ 同 feature |

### 2.2 scope 数据源

- **软触发(调度者自查)**:M3 `/CLAUDE.md` 的 scope 触发判定段落(人类可读对照表)
- **硬触发(hook 自动)**:M17 `.claude/hooks/meta-scope.conf`(glob 列表,机器可读)
- **同步要求**:两源任一变更属 scope=meta,触发 meta-review(M3 + M17 同套语义)

### 2.3 排除规则(spec D22 fix-9 (v))

- **只排除流程产出物**:`docs/audits/meta-review-*.md` + `docs/audits/archive/**`(避免改 audit 触发审 audit 的无穷递归)
- **不排除治理文件**:`meta-*.sh` / `meta-*.md` / `meta-scope.conf` 入 scope — 改它们直接改变治理规则,**必须走 meta-review**
- 详见 M17 `meta-scope.conf` 顶部注释 + spec §4.1.2

---

## 3. meta-review 流程(主体 — 引 spec §3.1.4)

> 详细 Step 1-N 见 spec §3.1.4(契约文本 + 错误处理 + 兼容性声明)。本节列关键步骤 + 决策点,不重复 spec 论证。

### 3.1 流程步骤(摘要)

```text
触发者:调度者
触发条件:M1 §3.1.3 Step B 决定走 meta-review
输入:
  - 本次改动主题描述(如 "M2 §3.1 加并行约束声明")
  - 改动涉及的文件 diff / 设计文档(若有)
  - 本文件第 6 节 pattern 模板(对抗式 / 混合式 / 事实统计式)

步骤(详 spec §3.1.4):
  1. 调度者按 agent 模态 + 主题选维度
     - 对抗式(M6/M7):本文件 §6 子节 1 模板 — A/B/C 三段
     - 混合式(M8):本文件 §6 子节 2 模板 — 部分 A/B/C
     - 事实统计式(M9):本文件 §6 子节 3 模板 — N 维分工
  2. 调度者并行 fork N 个挑战者(N 由主题 + 模态决定)
     每个挑战者 prompt 按本文件 §4 构造
     **工具层并行约束**:**必须在单一 assistant turn 内一次性发起 N 个 Agent 调用**
     (即同一条消息的 function_calls 块内并列 N 个 Agent),不得串行下发(发完
     一个等返回再发下一个)。串行下发不破坏对抗独立性但延长 review 时长 ~Nx。
     依据:2026-04-28 process-audit P-3 — 本约束的违反曾导致 4 挑战者跨 12 分钟串行
  3. 挑战者返回问题清单
  4. 调度者综合"共识 / 分歧 / 盲区"(参 multi-agent-review-guide.md)
  5. 调度者产 audit trail(必产,缺失等价于未走流程)
     位置:docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md
     YAML frontmatter 必含 covers: 字段(详本文件 §7)

输出:
  - audit trail 文件(必产)
  - 审查判定:通过 / 待修 / 推翻
```

### 3.2 关键决策点

#### (a) 挑战者数量弹性 N(D6)

- **N 不固定**:由主题 + 模态决定。简单主题 + 单模态 → N 可少至 2;复杂主题 + 跨模态 → N 可多至 5+
- 不机械按"现有 4 个 review skill 各 fork 1 个"
- 数量上限受 §4 单 prompt 字节软上限约束(超限拆分多轮 fork)

#### (b) audit 必产

- 缺 audit = 等价于未走流程,M15 Stop hook + M16 pre-commit hook 检出 git diff 命中 scope 但无 audit covers 的文件 → 引导补 audit/补 skip 理由
- audit 产物规范见本文件 §7

#### (c) 失败处理

- **fork 失败**:调度者按本文件 pattern 节内的角色定义,在单 context 内分角色审查;audit trail 标 `⚠️ 降级执行,独立性未达`
- **挑战者漏选最低必选维度**:agent prompt B 段静态嵌入(详本文件 §6) + 调度者 Step 1 自检 C 段未禁 minimum;audit trail 中 `dimensions.recommended_enabled` / `minimum_required` 字段空白由 hook 后续检
- **挑战者 prompt 超 §4 字节软上限**:调度者按 spec §3.1.5 拆分多轮 fork(每轮覆盖维度子集)
- **audit trail 未产出**:违反 scope 规则,M15 Stop hook 在 session 末检出;M16 pre-commit hook 在 git commit 前检出

---

## 4. 挑战者调用契约(引 spec §3.1.5)

### 4.1 挑战者 prompt 输入字段(由调度者拼接)

```text
挑战者 prompt 构成:
  - 挑战者角色定义(从对应 agent 文件取)
  - 该挑战者的维度关注焦点(从本文件 §6 pattern 节 + 当次选取结果)
  - 待审查对象(设计文档 / 代码 diff / governance 文件改动)
  - 关键的治理参考文件路径(RUBRIC.md / ARCHITECTURE.md 若适用 / 相关 decision)
  - 输出格式约束(问题清单格式)

按 agent 模态分输入差异:
  - M6/M7 对抗式:嵌入 §6 子节 1 的 A 推荐 / B 最低必选 / C 定制理由三段
  - M8 混合式:对抗维度部分嵌入 §6 子节 2 的 A/B/C;硬编码部分嵌入凭证/危险/注入 pattern 列表
  - M9 事实统计式:嵌入 §6 子节 3 的 2 维分工 + 当次细化粒度(若调度者填写)
```

### 4.2 挑战者输出字段(返回结构)

```text
- 挑战者的独立问题清单,含位置 + 证据 + 严重性
- 对抗式 / 混合式对抗部分:含 A/B/C 三段元信息
  (recommended_enabled / recommended_disabled / minimum_required / customized_added)
- 事实统计式:含 granularity_customization(可选)
```

### 4.3 单 prompt 字节软上限(D5)

> **D5 = 64 kB(65536 字节,UTF-8)**

- **作用域**:单个挑战者 prompt 总字节(含挑战者角色定义 + 维度焦点 + 待审查对象 + 治理参考 + 输出约束 + 本文件 §6 嵌入内容)
- **超限行为**:**log 警告 + 调度者按 spec §3.1.5 拆分多轮 fork**
  - 警告内容:`⚠️ 挑战者 prompt 超 64 kB(65536 字节)软上限(实际 N 字节,按 §3.1.5 拆分维度后再 fork)`
  - 输出位置:调度者操作日志或挑战者 prompt 内 system note(实施层定具体方式)
  - 拆分策略:按维度子集分多轮 fork — 例如对抗式 A/B/C 三段过大,拆为(A1+B 部分)/(A2+B 部分)/(C 完整)等
- **建议**:64 kB 以下;典型场景下应远低于此值
- **P0.9.1 不测 enforcement**:本字节软上限 P0.9.1 阶段无 hook 校验(光谱 B+ 最小硬 hook 原则),调度者 / 实施者自律。P0.9.2 诊断阶段实战观察是否需要补 enforcement(spec §6.3 已声明)

### 4.4 错误处理

- **挑战者返回空或格式不符**:调度者重试一次;仍失败则该维度标 `未完成`
- **挑战者 prompt 超 64 kB**:见 §4.3 拆分策略
- **挑战者超时 / fork 异常**:见 §3.2 (c) 降级执行

---

## 5. 调度者运行时嵌入契约(引 spec §3.1.7)

### 5.1 为什么调度者运行时读 + 嵌入(B5 决策)

- **不用 `!` 注入读 M2**:`!` 注入在 SKILL.md 内运行 = 下游目标项目也会执行;但 M14 setup.sh 命名前缀过滤(D12)使下游不存在 meta-* 文件,`!`cat docs/governance/meta-*` 在下游返回空,语义模糊
- **调度者手工 Read + 嵌入**:更清晰,且现有 4 个 skill 的 `!` 注入(RUBRIC / ARCHITECTURE / 设计文档)保留不变
- 详见 spec §3.1.7

### 5.2 嵌入步骤

```text
调度者识别 scope=meta 后(spec §3.1.1):
  1. Read M2(本文件)`docs/governance/meta-review-rules.md`
  2. 按 agent 模态选取相应子节内容(本文件 §6 子节 1/2/3)
  3. 测量选取内容的 UTF-8 字节数:
     - ≤ 8192 字节(8 KB):正常嵌入
     - > 8192 字节:log 警告 + 嵌入(不阻断)
  4. 嵌入挑战者 prompt(§4 输入字段)

agent 文件本身(M6-M9):
  - 只放结构占位 + 引用 M2 路径(详 §5.4 第七轮 fix-2)
  - 不抄 M2 实文
```

### 5.3 嵌入字节软上限(D.2)

> **D.2 = 8 KB(8192 字节,UTF-8)**

- **作用域**:从本文件 §6 抽出嵌入挑战者 prompt 的那部分内容(不含调度者额外构造的 prompt 框架)
- **超限行为**:**log 警告,不阻断**
  - 警告内容:`⚠️ M2 嵌入字节超 8 KB(8192 字节)软上限(实际 N 字节,建议精简引用节范围)`
  - 输出位置:同 §4.3
  - 不影响挑战者 fork 或 audit 产出
- **建议**:8 KB 以下;§6 三套模板正文当前合计 < 1 KB,典型场景下应远低于此值
- **与 D5 的关系**:D.2 ⊂ D5;两层软上限不冲突,D.2 是更细颗粒约束(只约束 M2 嵌入部分,D5 约束整个挑战者 prompt)
- **P0.9.1 不测 enforcement**:同 §4.3 D5 — P0.9.1 阶段调度者自律,P0.9.2 诊断阶段实战观察(spec §6.3)

### 5.4 第七轮 fix-2 — 防下游污染配套约束

> 实施 M6-M9 agent 文件时**必须**遵守:

- **agent 文件 prompt 只放结构占位 + 引用 M2 路径**
- **禁止抄 M2 实文**(meta-review 流程描述 / scope 规则 / scope.conf glob 等)
- **理由**:agent 文件由 M14 setup.sh 分发到下游(下游也获得 design-review / evaluate / security-scan / process-audit agent),若 M2 实文嵌入 agent prompt,则下游 agent 文件自带 meta 治理语境,违反 spec §1.3 兼容性"下游项目不受 meta 治理污染"
- **实现方式**:
  - agent prompt 静态嵌入"在 harness 自身仓库时,调度者按 §3.1.7 runtime 嵌入契约 Read M2 / M1 必要节并嵌入挑战者 prompt"指引(只引路径不引内容)
  - agent prompt B 段(最低必选维度)只列维度名(如 "核心原则合规"),不展开 M2 中关于何时强制的具体规则文本
  - meta 专属语义(如 "meta-review covers 字段失效规则"、"hook 拦截逻辑")**不出现在 agent 文件中**,仅由调度者运行时从本文件读取后嵌入
- 详见 spec §3.1.6 agent 文件静态约束节 + spec §3.1.7

---

## 6. 审查维度三段 pattern(供对抗式 agent 引用)

> **本节由 C4 锁定,**逐字一致**不变。**调度者运行时直接从本节抽取相应子节嵌入挑战者 prompt(§5)。
>
> 三套模板对应 spec D2 模态分型:对抗式(M6/M7)/ 混合式(M8)/ 事实统计式(M9)。

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

### 混合式 agent prompt 模板

X. 凭证 / 数据扫描 pattern(硬编码,不变)
   格式同现 security-reviewer.md(pattern grep 列表 + Critical/High/Medium 标级)

A. 推荐对抗维度(仅在"扫描后场景判定"维度采用)
   例:凭证泄露的风险等级判定 / 危险操作的副作用范围

B. 最低必选对抗维度
   - 凭证泄露场景判定(M8 永远不可绕)

C. 定制理由字段(格式同对抗式 C 段)

### 事实统计式 agent prompt 模板

N1. 流程遵从度(固定维度,可细化粒度)
N2. 效果满意度(固定维度,可细化粒度)
G.  调度者按主题细化粒度(可选)
    ### 本次粒度细化
    - 范围: [全 session / 本批次 / 时间窗口]
    - 维度细化: [每维度内的子项]

### bootstrap 4 维基线(D7)

> bootstrap 4 维已在上方"对抗式 agent prompt 模板"B 段嵌入。任何 meta 改动的对抗式审查**必须**包含该 4 维(核心原则合规 / 目的达成度 / 副作用 / scope 漂移),禁用 minimum 项需用户确认(C 段记录)。

依据:spec §6.4 bootstrap 自洽验证(D7 第七轮从 B 撤回到 A,沿用 4 维不加第 5 维"过度工程化")。

### evidence depth 文件 scope 分流(spec 第七轮 fix-6)

对抗式 agent(M6/M7)prompt 接收 `scope` 参数(meta / feature / mixed),按 scope 分流引相应 evidence depth 文件:
- `scope=feature` → 引 `docs/references/testing-standard.md`(L1-L4 定义,现行)
- `scope=meta`    → 引 M1 `docs/governance/meta-finishing-rules.md` 内含的 evidence depth 节(meta-L1~meta-L4,spec §4.1.4)
- `scope=mixed`   → 同时引两份(meta + feature 双套档位值,spec §4.1.4 mixed 8 行示例)

调度者在 fork 挑战者前确定本次 scope,把对应 evidence depth 路径嵌入挑战者 prompt。

---

## 7. audit 产物规范(引 C2 + spec §4.1.1)

### 7.1 audit 文件位置 + 命名

- **位置**:`docs/audits/`
- **命名**:`meta-review-YYYY-MM-DD-HHMMSS-[主题].md`(D14 加 HHMMSS,与 process-audit 现行命名同结构)
- **归档**:每 6 月迁 `docs/audits/archive/YYYY-HN/`(D15;P0.9.1 仅声明策略,首次半年归档由后续阶段触发)

### 7.2 YAML frontmatter(必填)

```markdown
---
meta-review: true
covers:
  - <仓库相对路径 1>
  - <仓库相对路径 2>
  ...
---
```

字段语义:

| 字段 | 类型 | 必填 | 缺省/合法值 | 含义 |
|---|---|---|---|---|
| `meta-review` | boolean | ✅ | 固定 `true` | 标识本文件是 meta-review audit;hook grep 识别用 |
| `covers` | string 数组(仓库相对路径) | ✅ | **非空数组**(空 = 等价于未走流程) | 本 audit 覆盖的 scope 内文件路径 |

### 7.3 covers 数组路径规则

1. **仓库相对路径**:从仓库根算起,无 `./` 前缀,无尾 `/`(如 `docs/governance/design-rules.md`)
2. **正斜杠分隔**:Windows 仓库也用 `/`(YAML 跨平台一致)
3. **路径必须实存**:写 audit 时调度者列入的路径必须在仓库内实存(允许扩展提交后实存)
4. **无去重要求**:数组内允许重复,hook 处理时按集合并集计算

### 7.4 写侧契约(D22 fix-9 (iii))

- **触发者**:调度者(在 §3 Step 5 写入)
- **必须列入 covers 的内容**:本 audit **实际覆盖的、scope 内的、本次改动的所有文件路径**
  - **不是**"audit 主题相关"即列入;必须是 audit 实际审查的具体文件
  - **不能漏列**(漏列文件会被 hook 视为未 cover,触发引导)
  - **不能误列**不属本次改动的(误列会导致下次相同文件改动时失效计算偏差)

### 7.5 5 段正文标题(精确)

```markdown
## 1. 元信息
## 2. 维度选取
## 3. 挑战者执行记录
## 4. 综合
## 5. 判定
```

字段细节(各节内字段格式):见 spec §4.1.1 `interface AuditTrail`。本文件锁定 frontmatter + 5 段节标题(确保 hook 可识别 + 写入一致)。

### 7.6 错误处理(读侧 hook)

| 错误情形 | 处理 |
|---|---|
| audit YAML frontmatter 损坏 | stderr `⚠️ audit YAML 损坏: <文件>` + 视该 audit 不存在(不参与 covers 并集);hook 继续处理其他 audit;exit 0 不阻断 |
| `covers:` 字段缺失 | 同上,视该文件非 meta-review audit |
| `covers:` 为空数组 | 视为未走流程,该 audit 不贡献任何 covered_files |
| `meta-review: true` 缺失或值为 false | 视该文件非 meta-review audit,跳过 |

详见 contracts-locked.md C2 + spec §4.1.1。

---

## 8. audit 失效规则(引 spec §4.1.5 + D22 fix-9 (iii))

### 8.1 单 audit 单文件失效判定

```text
对每个 audit 的每个 covers 文件:
  covered_latest_commit_time = git log -1 --format=%ct -- <covered_file>
  audit_mtime                = stat <audit_file> 取 mtime
  if covered_latest_commit_time > audit_mtime:
    return TRUE   # 失效:文件有新 commit 在 audit 之后
  else:
    return FALSE  # 仍有效
```

### 8.2 多 audit 跨覆盖

- **单文件可能在多个 audit 的 covers 中**:任一未失效的 audit 即视为该文件已 cover
- hook 计算 `covered_files` 时按所有有效 audit 的 covers 字段并集:
  ```
  covered_files = ⋃ {audit.yaml_frontmatter.covers : audit ∈ 有效 audit 集}
                 其中 "有效 audit" 按上述失效规则筛后
  uncovered     = changed_meta_files - covered_files
  ```
- `changed_meta_files` = git diff 命中 scope.conf include glob 后过滤的集合

### 8.3 实现细节(供 M15 / M16 参考)

- `git log -1 --format=%ct -- <file>` 取最新 commit time
- audit 文件 mtime 用 `stat`(GNU 用 `stat -c %Y`,BSD 用 `stat -f %m`,与 `check-handoff.sh` 兼容)
- 不用 ctime(避免 git checkout 改 ctime 误判)

### 8.4 归档 audit 处理

- 主目录(`docs/audits/`)+ `archive/INDEX.md` 缓存的近 12 个月条目参与失效计算
- 归档表外的旧条目不参与(过老 audit covers 几乎肯定都已失效)
- 详见 spec §4.1.1 归档策略 + INDEX.md schema

---

## 9. handoff 字段配合(引 C3 + spec §4.1.3 / §4.1.7)

### 9.1 字段 1:`## meta-review: skipped`(短期,每次 meta 改动可覆盖)

#### 精确格式

```markdown
## meta-review: skipped(理由: <非空理由>)
```

#### 写入时机

- M1 §3.1.3 Step A 调度者判"不走 meta-review"时,引导调度者在 handoff 写入此字段
- 每次新 meta 改动开始时,调度者覆盖此字段(不累积旧 skip 记录)

#### hook 读取规则(M15 / M16)

- grep 匹配:`## meta-review: skipped\(理由: ([^)]+)\)`(POSIX ERE)
- 提取 `\1` 即理由内容
- 校验:`\S` 至少匹配 1 个非空白字符 → skip 有效,exit 0
- 校验失败(理由空 / 全空白):skip 无效,继续要求 audit

> **括号字符必须半角**(`(` `)` U+0028/U+0029),不能用全角(`(` `)` U+FF08/U+FF09)。中文 IME 默认全角,写入时需切换为半角。hook grep 字面匹配半角,全角不命中 → skip 视为无效。依据:2026-04-28 meta-review C3 Y3 documented 推迟项

#### 合规示例

```markdown
## meta-review: skipped(理由: 仅修改 typo 注释,无语义变更)
```

#### 不合规示例(reason 空 / 全空白 / 无括号字段)

```markdown
## meta-review: skipped(理由: )
## meta-review: skipped(理由:    )
## meta-review: skipped
```

详见 contracts-locked.md C3 + spec §4.1.3。

### 9.2 字段 2:`## 反审待办`(长期,直到反审完成)

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

> 注意:audit 路径用反引号包裹(代码风格,与 spec §4.1.7 示例一致)。

#### 写入 / 更新时机

- **初始写入**:P0.9.1 实施阶段最后一次 finishing(对应 P0.9.1 commit 进 main),M1 引导调度者在 handoff 加此字段(初始值 `未完成`)
- **更新**:反审走完(本文件 §6 pattern 节 + audit 产出 + verdict=pass)后,M1 引导更新字段为 `已完成 — audit:<path>`
- **不清理**:反审完成后字段保留(P0.9.1 闭环留痕)

#### 失效重审

- 若 P0.9.1 重大改动(commit 进 main)后,§8 covers 失效规则触发反审 audit 失效 → 字段重置为 `未完成` + M20 SessionStart hook 重新注入提醒

#### hook 读取规则(可选 — 与 M20 互补)

- **权威**:audit covers 是反审完成的权威依据(M20 按 covers 判定,见 §7)
- **被动留痕**:本字段供调度者读 handoff 见此判断反审是否待办
- **不强制 hook 解析**(避免双源冲突);若未来扩展 hook 读此字段,需与 covers 检测保持优先级:**covers 是权威**,字段失同步以 covers 为准

详见 contracts-locked.md C3 + spec §4.1.7。

### 9.3 两字段共存约束

- **同一 handoff 文件**:两字段共存,marker 不同(`## meta-review: skipped` vs `## 反审待办`)
- **不互覆盖**:skip 字段每次 meta 改动可覆盖;反审待办字段保留至反审完成
- **顺序无要求**:两字段在 handoff 内出现顺序不强制(handoff 模板可固定一种顺序便于阅读)

---

## 附录 A:契约引用速查

| 本文件节 | C 编号 | 锁定文件 |
|---|---|---|
| §2 触发条件 / 排除规则 | C1 | `docs/superpowers/plans/2026-04-26-p0-9-1-contracts-locked.md` |
| §6 三段 pattern(逐字) + §5 嵌入约束 | C4 | 同上 |
| §7 audit 规范 + §8 失效规则 | C2 | 同上 |
| §9 handoff 字段 | C3 | 同上 |

## 附录 B:决策引用速查

| 本文件涉及的决策 | spec §7.1 编号 | 内容 |
|---|---|---|
| 模态分型(对抗式 / 混合式 / 事实统计式) | D2 | §6 三套模板分型 |
| 调度者运行时嵌入(B5) | D3 | §5 嵌入步骤 |
| 三层强制最低必选维度 | D4 | §6 B 段 + 调度者自检 + audit post-check |
| 单 prompt 字节软上限 64 kB | D5 | §4.3 |
| bootstrap 4 维基线 | D7 | §6 B 段 |
| audit 文件名 HHMMSS | D14 | §7.1 |
| audit 归档每 6 月 | D15 | §7.1 |
| 嵌入字节软上限 8 KB | D.2(用户决定 2026-04-26) | §5.3 |
| 治理文件入 scope(bootstrap 循环可接受) | D22 fix-9 (v) | §1.1 / §2.3 |
| covers 比对实际列出文件 | D22 fix-9 (iii) | §7.4 / §8 |
| 防下游污染:agent prompt 不抄 M2 实文 | 第七轮 fix-2 | §5.4 |
| audit covers 字段必填 | A3 | §7.2 |
| audit 失效规则 git commit time vs audit mtime | A4 | §8.1 |
| skip 字段理由必填 grep 校空 | A5 | §9.1 |

---

**文档变更触发 meta-review**:本文件改动属 scope=meta(C1 A 组 `docs/governance/*.md` 命中) — 改本文件**必须**走 meta-review 流程(bootstrap 循环可接受)。

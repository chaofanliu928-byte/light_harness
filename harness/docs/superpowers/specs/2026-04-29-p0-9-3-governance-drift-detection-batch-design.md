# P0.9.3 governance 漂移检测兜底 batch 系统设计(P0.9.3 第一个 trial)

> **标准级 spec**(`design-rules.md` §规模判断)— 本 trial 涉及新建 hook 模块(check-meta-cross-ref.sh)+ 改 2 个现有 hook,符合"涉及新模块"标准级条件。

> **scope**:meta(B 组 `.claude/hooks/*` + A 组 `.claude/settings.json`);走 `meta-finishing-rules.md`(M1)四步流程 + `meta-review-rules.md`(M2)fork N 挑战者审查。

---

## §0 偏离说明

不偏离 `DESIGN_TEMPLATE.md` 模板。本 spec **不引** RUBRIC 维度作 design-review 豁免依据(M2 同步约束);本 trial scope=meta,走 meta-review-rules.md(M2)而非 design-rules 的 design-review。

---

## 1. 需求摘要

### 1.1 用户目标

P0.9.3 第一个 trial — 用 P0.9.1 治理流程开发 governance 漂移检测兜底层。本 trial 为 batch 形态,与 M0(单改动)/ M1+M2+M4 batch(双改动)形成 trial 序列:验证 P0.9.1 流程在涉及新建 hook 模块场景下仍生效。

实质功能:
- 让 hook 执法层覆盖 M3 改动(repo 根 `CLAUDE.md`)— 现状 hook cwd=`harness/` 看不到根级文件(fix-9 (vii) 缺口);**精度边界**:本 trial 仅修复 modified + staged-ACMR 路径,untracked 漏检 + M3/M4 路径混淆(hook 不区分 root CLAUDE.md vs harness/CLAUDE.md)推 P0.9.4(见 §9.4 #10/#11)
- 检测 `design-rules.md` ↔ `finishing-rules.md` 互引 anchor 完整性 — 防 cross-file 互引悬空(2026-04-29 audit §9.4 #6);**精度边界**:PAIRS 4 条 anchor 仅覆盖 design ↔ finishing 实际互引中的 2 / 4 处(见 §9.4 #12;原 audit 写 5 处,经第二个 trial 重审实测 4 处,详 spec 2026-04-30 §9.4 #25),本 trial 仅证机制可行,不做覆盖度优化

### 1.2 核心场景

1. **[P0] M3 改动触发 meta-review**:用户改根 `CLAUDE.md` → check-meta-review.sh 主扫之外加 repo 根扫描段 → 命中 INCLUDE_GLOBS `CLAUDE.md` glob → 入 CHANGED_META_FILES → Stop 时引导补 audit
   - 现状缺口:M3 改动不入 hook scope,session 末不报警(fix-9 (vii))
   - **精度边界**:hook 输出 `CLAUDE.md` 字面对应 M3(repo 根)和 M4(harness/CLAUDE.md)两个文件,无法区分;audit covers 比对精度受限 — 写 covers 仅覆盖 M4 的 audit 仍能让 M3 改动 pass 检测(false negative)。推 P0.9.4 加路径前缀绝对化(见 §9.4 #10);本 trial 闭合后中间窗口期由调度者人工记忆 + handoff 显式标注规避
   - **untracked 漏检**:`git diff --name-only` + `git diff --cached --name-only` 都不输出 untracked 新文件;新仓库初始化时 M3 全新建未 git add 走漏检路径(见 §9.4 #11)。本 trial 仅修复 modified + staged-ACMR 路径

2. **[P0] design-rules ↔ finishing-rules 互引 anchor 缺失检测**:用户改 design-rules.md(如删 `## spec §0 偏离规则` 段)→ Stop 时 check-meta-cross-ref.sh grep 4 条 anchor → 缺失 → exit 2 引导补
   - 现状缺口:互引人工维护,无机器报警

### 1.3 边界与约束

**做什么**:
- 改 `harness/.claude/hooks/check-meta-review.sh`(Stop hook,加 repo 根扫描段)
- 改 `harness/.claude/hooks/check-meta-commit.sh`(pre-commit hook,加 repo 根扫描段)
- 新建 `harness/.claude/hooks/check-meta-cross-ref.sh`(Stop hook)
- 新建 `harness/.claude/hooks/check-meta-cross-ref-commit.sh`(pre-commit hook)
- 改 `harness/.claude/settings.json`(Stop 段加 cross-ref hook 注册)

**不做什么**:
- **不**改 `meta-scope.conf`(M3 路径在 hook 逻辑内单独处理,沿用现有 `CLAUDE.md` glob;cross-ref hook 自己读文件,不通过 scope.conf)
- **不**做 fix-9 (i)(ii)(iv)(vi):
  - (i) `--no-verify` 绕 pre-commit / (ii) 长 session 不 stop:推 P0.9.2 实战观察期(无数据不预防 — `feedback_judgment_basis`)
  - (iv) 理由质量自律 / (vi) 下游改 harness 副本:已 accept 关闭(spec §5 B18 + decision `2026-04-26-bypass-paths-handling.md`)
- **不**做 ROADMAP 副产物修正(把 (iv)(vi) 移出候选 + (i)(ii) 标占位)— 推为 trial 完成后独立小改(scope=none,不需 audit)
- **不**做配置化 cross-ref pairs(YAGNI — 当前实证仅 1 对,等第 2 对再扩)
- **不**改下游分发(命名前缀 `check-meta-*` 自动过滤,setup.sh 不分发)

**性能要求**:hook 执行 < 500ms(grep 2 文件 + git diff,常规规模)

**安全要求**:无新引入(继承 M15/M16 graceful degrade 范式)

**兼容性要求**:
- (vii-a) 新增段独立失败不破坏现有 path(repo 根 git diff 失败 → stderr warning + 跳过段)
- 下游已装项目本地副本不自动更新(与 P0.9.1.5 batch 一致)
- 单层下游(无 PROJECT_DIR/harness/)走单层路径,跳过 repo 根扫描段(R2)

### 1.4 关联需求

**依赖的已有功能**:
- P0.9.1 M15 `check-meta-review.sh` / M16 `check-meta-commit.sh` / M17 `meta-scope.conf`
- M19 `templates/settings.json` 双轨模板(D19 a 方案)
- D12 命名前缀过滤(`check-meta-*` 不分发下游)

**被哪些未来功能依赖**:
- P0.9.4(暂未识别)若实证更多 cross-ref pairs,可在本 hook 基础上扩 PAIRS 数组

### 1.5 已确认的决策(从 brainstorming 阶段带入)

1. **范围 = A**:仅做"当下真正可做"的 2 项((vii) M3 不可见 + 互引检测);不做 (i)(ii)(iv)(vi) + B 方案
2. **形态 = (vii-a) + (互引-a) 推荐组合**:repo 根扫描段 + 独立 cross-ref hook(写死 1 对)
3. **D1**:cross-ref Stop + pre-commit 双注册(2 hook 文件)
4. **D2**:anchor 写死 1 对(YAGNI)
5. **D3**:(vii-a) 新增段失败时跳过段,主扫继续
6. **D4**:settings 改动只动 settings.json,不动 settings.local.json
7. **D5**:anchor 缺失 exit 2 阻断(可加 handoff skip 兜底)
8. **D6**:cross-ref 用 2 文件(与 M15/M16 模式一致)

### 1.6 RUBRIC 风险标记

> 本节按 hook scope 类比适配。**澄清**:本节描述性使用 RUBRIC 术语(简洁性 / 内部一致性等)是为便于对话,**不作为**设计规模或 design-review 豁免的判定依据(M2 / M4 约束,与 P0.9.1.5 batch §1.6 一致)。

- 涉及的"产出健康性"维度:
  - 简洁性:5 处改动(2 改 + 2 新建 + 1 settings),新增 ~200~260 行
  - 内部一致性:repo 根扫描与 harness/ 主扫不冲突(过滤无 / 前缀 vs 子目录文件);cross-ref hook 与 M15 不重复(主扫=covers 比对;cross-ref=anchor 比对)
- 涉及的"治理机制"维度:不引入新流程(沿用 M15/M16 hook + handoff skip 范式)
- **本 spec 不引 RUBRIC 维度作 design-review 豁免依据**(M2 自约束)

---

## 2. 模块划分

### 2.1 模块清单

| 模块 | 职责 | 新建/改动 | 所在层 |
|------|------|---------|-------|
| `check-meta-review.sh` | Stop hook,scope+covers 检查;**新增 repo 根扫描段** | 改动 | `harness/.claude/hooks/` |
| `check-meta-commit.sh` | pre-commit hook,scope+covers 检查;**新增 repo 根扫描段** | 改动 | `harness/.claude/hooks/` |
| `check-meta-cross-ref.sh` | **新建** Stop hook,互引 anchor 完整性检查 | 新建 | `harness/.claude/hooks/` |
| `check-meta-cross-ref-commit.sh` | **新建** pre-commit hook,互引 anchor 完整性检查 | 新建 | `harness/.claude/hooks/` |
| `settings.json` | Stop 段加 cross-ref hook 注册 | 改动 | `harness/.claude/` |

### 2.2 模块依赖图

```
[Claude Code Stop event]
    ↓
[check-handoff] → [check-finishing-skills] → [check-evidence-depth]
    ↓
[check-meta-review.sh] (扩展 repo 根扫描段)
    ↓
[check-meta-cross-ref.sh] (新)
    ↓
[Stop 放行 / 阻断]

[git commit]
    ↓
.git/hooks/pre-commit (软链 — 用户/admin 手挂;harness 自身默认不挂,P0.9.1 §C5)
    ↓
[check-meta-commit.sh] (扩展 repo 根扫描段)
    ↓
[check-meta-cross-ref-commit.sh] (新)
    ↓
[commit 放行 / 阻断]
```

依赖方向:Claude Code event / git event → 顺序 hook 链;hook 之间无内部依赖(各自独立扫 git diff + 文件)。

---

## 3. 接口定义

### 3.1 模块间接口

> hook 之间不互调用,各 hook 接口契约对接 Claude Code / git。

#### check-meta-review.sh / check-meta-commit.sh — 新增 repo 根扫描段(伪码)

```bash
# 在现有 §5 "扫 git diff" 之后新增段:
# 5.5 repo 根扫描段(P0.9.3 (vii-a) 修)

ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -z "$ROOT_DIR" ] || [ ! -d "$ROOT_DIR/.git" ]; then
    : # 单层下游或 ROOT_DIR 不可用 → 跳过此段(主扫已完成),R2
else
    # M15: unstaged + staged;M16: staged --diff-filter=ACMR(沿用各自原扫描语义)
    ROOT_DIFF=$( (git -C "$ROOT_DIR" diff --name-only 2>/dev/null; \
                  git -C "$ROOT_DIR" diff --cached --name-only 2>/dev/null) | \
                awk 'NF' | sort -u )
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        # 仅取 repo 根级文件(无 / 前缀)— 子目录已在 harness/ 主扫覆盖
        case "$f" in */*) continue ;; esac
        if is_in_scope "$f"; then
            CHANGED_META_FILES+=("$f")
        fi
    done <<< "$ROOT_DIFF"
fi
```

输入:无新输入(沿用 hook 现有 stdin / cwd)
输出:`CHANGED_META_FILES` 数组追加 repo 根级 scope 文件
错误:`git -C "$ROOT_DIR"` 失败 → stderr warning + 跳过此段(主扫继续);ROOT_DIR 不存在 → 跳过(R2)

#### check-meta-cross-ref.sh(Stop hook 新建,伪码)

```bash
# 协议:Claude Code Stop hook
# 输入:stdin JSON,字段 stop_hook_active(bool)
# 输出:exit 0 = 放行;exit 2 = 阻断 + stderr 引导
# 防死循环:stop_hook_active = true → exit 0(参考 M15)
# graceful degrade:git/grep/文件不可读 → stderr warning + exit 0
# 唯一 exit 2 路径:确认 anchor 缺失 + 无 handoff skip

# 检测对(写死,YAGNI):
PAIRS=(
    "docs/governance/design-rules.md|## spec §0 偏离规则"
    "docs/governance/design-rules.md|另见 \`finishing-rules.md\`"
    "docs/governance/finishing-rules.md|跨阶段同步约束"
    "docs/governance/finishing-rules.md|见 \`design-rules.md\`"
)
# 注:anchor 字符串经 grep 验证在对应文件内字面存在(self-review 阶段验证):
#   - design-rules.md L38 `## spec §0 偏离规则`
#   - design-rules.md L45 `另见 \`finishing-rules.md\``
#   - finishing-rules.md L39 `**跨阶段同步约束**`(grep -F 字面匹配 `跨阶段同步约束`)
#   - finishing-rules.md L39 `见 \`design-rules.md\``
# 实施时 bash 字符串可改用 single-quote 避免 backtick escape:
#   PAIRS=( 'design-rules.md|另见 `finishing-rules.md`' ... )

# 仅在 design-rules / finishing-rules 改动时触发(否则 exit 0,节省开销)
DIFF_FILES=$( (git diff --name-only --relative; git diff --cached --name-only --relative) | \
              awk 'NF' | sort -u )
case "$DIFF_FILES" in
    *docs/governance/design-rules.md*|*docs/governance/finishing-rules.md*) ;;
    *) exit 0 ;;
esac

# 全 4 条 anchor 必须在对应文件内
VIOLATIONS=()
for pair in "${PAIRS[@]}"; do
    file="${pair%%|*}"; anchor="${pair#*|}"
    if ! grep -F -q -- "$anchor" "$file" 2>/dev/null; then
        VIOLATIONS+=("$file 缺失 anchor: $anchor")
    fi
done

# handoff skip 检查(沿用 M15 范式,字段名:meta-cross-ref)
# ...

[ ${#VIOLATIONS[@]} -eq 0 ] && exit 0
# 输出 stderr 清单 + exit 2
```

输入:stdin JSON(Claude Code 协议)+ cwd(WORK_DIR 解析逻辑同 M15)
输出:exit 0(放行)/ exit 2(阻断 + stderr 引导)
错误:类同 M15(graceful degrade)

#### check-meta-cross-ref-commit.sh(pre-commit hook 新建)

与 check-meta-cross-ref.sh 逻辑相同,差异:
- 无 stdin JSON;无 stop_hook_active 防死循环
- 扫 `git diff --cached --name-only --diff-filter=ACMR --relative`(仅 staged)
- exit 1 而非 exit 2(git pre-commit 协议)
- 安装路径:`.git/hooks/pre-commit` 软链(harness 自身默认不挂,P0.9.1 §C5)

### 3.2 外部接口

不适用(本 trial 不涉及 API / 网络协议)。

### 3.3 前后端类型契约

不适用(本 trial 不涉及 API 端点)。

---

## 4. 数据模型

### 4.1 数据实体

```bash
# CHANGED_META_FILES — 数组,sope 内文件清单(harness/ 主扫 + repo 根新增段合并)
CHANGED_META_FILES=("CLAUDE.md" "docs/governance/design-rules.md")

# PAIRS — 数组,(file|anchor) 配对清单(写死)
PAIRS=("docs/governance/design-rules.md|## spec §0 偏离规则" ...)

# VIOLATIONS — 数组,缺失 anchor 报告
VIOLATIONS=("docs/governance/design-rules.md 缺失 anchor: ## spec §0 偏离规则")
```

### 4.2 数据流

```
Stop event / git commit
    ↓
git diff --name-only (主扫 cwd=harness/, --relative)
git diff --name-only (新段 cwd=repo root, 过滤无 / 文件)
    ↓
合并 → CHANGED_META_FILES
    ↓
[CHANGED_META_FILES 命中 design-rules / finishing-rules?]
    ↓ 命中
触发 cross-ref 检查 → grep 4 条 anchor
    ↓
[VIOLATIONS 非空] → exit 2/1 + stderr 引导
[VIOLATIONS 空] → exit 0
```

### 4.3 状态变更

无(hook 是无状态的 — 每次 invoke 独立)。

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 编号 | 场景 | 输入条件 | 期望行为 |
|---|---|---|---|
| **R1** | repo 根 git diff 失败 | 非 git 仓库 / git 工具缺失 | stderr warning + 跳过新增段(主扫继续) |
| **R2** | ROOT_DIR 不存在(单层下游) | 下游分发场景,无 PROJECT_DIR/harness/.. | 跳过新增段;hook 整体行为不变 |
| **R3** | M3 改动 + 无 audit covers | 改根 CLAUDE.md 后未走 meta-review | hook exit 2 引导补 audit / 写 handoff skip 理由(由 (vii-a) 实现) |
| **R4** | M3 改动为 untracked 新文件 | 全新 init 仓库新建 root CLAUDE.md 未 git add | hook **漏检**(`git diff --name-only` + `git diff --cached --name-only` 都不输出 untracked);**本 trial 选 B 显式承认**(见 §9.4 #11):**§5.5 hook**(check-meta-review.sh + check-meta-commit.sh)stderr 引导加"若是新建未 git add 的根级文件,需 git add 后才会触发后续检测"(已落地);cross-ref hook 不受影响(grep 已 tracked 文件内容,与 untracked 无关);新仓库初始化场景在 harness 自仓库实战频率低 |
| **R5** | M3 vs M4 路径混淆 | 改 root CLAUDE.md 或 harness/CLAUDE.md | hook 输出字面 `CLAUDE.md` 对应两个文件,无法区分;**covers 比对精度受限**;本 trial **选 B 显式承认**(见 §9.4 #10):中间窗口期由调度者人工记忆 + handoff 显式标注规避;推 P0.9.4 加路径前缀绝对化 |
| **C1** | cross-ref 双方都未改 | git diff 不含 design-rules / finishing-rules | exit 0(快速路径) |
| **C2** | cross-ref 一方改动且 anchor 完整 | 改 design-rules.md 但 4 条 anchor 全在 | exit 0(放行) |
| **C3** | cross-ref 一方改动且 anchor 缺失 | 改 design-rules.md 删 `## spec §0 偏离规则` 段 | exit 2(Stop)/ exit 1(commit)+ stderr 列具体缺失 |
| **C4** | 两文件都改且交叉缺失 | 双方都改但 4 条 anchor 中任一缺失 | exit 2/1 + 列全部缺失 |
| **C5** | hook 工具缺失(grep / git) | OS 异常 | stderr warning + exit 0 |
| **C6** | 文件不可读(权限问题) | design-rules.md 权限错 | stderr warning + exit 0 |
| **C7** | handoff skip 兜底 | 用户在 handoff 写 `## meta-cross-ref: skipped(理由: <非空>)` | exit 0(继承 M15 skip 范式) |
| **C8** | anchor 文本含特殊字符 | grep `M2 同步约束` 中含中文 | grep -F(字面匹配)避免 regex 误解 |

### 5.2 错误传播路径

```
错误源
  │
  ├─→ repo 根扫描段失败 (R1/R2) → stderr warning → 主扫继续 → hook 整体不破坏
  │
  ├─→ cross-ref grep 失败 (C5/C6) → stderr warning → exit 0(graceful degrade)
  │
  └─→ anchor 缺失 (C3/C4) → exit 2/1 + stderr 列清单 → 用户补 anchor 或写 handoff skip
                                                              ↓
                                                         exit 0(C7 skip 路径)
```

---

## 6. 测试策略

### 6.1 关键测试场景

| 场景来源 | 测试内容 | 测试层级 | mock 策略 |
|---------|---------|---------|----------|
| §1.2 场景 1 | 改根 CLAUDE.md(M3)→ Stop event → check-meta-review.sh 应报警 | meta-L1 inline | 造改动 + invoke hook + 检 stderr |
| §1.2 场景 2 | 改 design-rules.md 删 `## spec §0 偏离规则` → Stop event → check-meta-cross-ref.sh exit 2 | meta-L1 inline | 造改动 + invoke hook + 检 stderr |
| §5 R1 | repo 根 git diff 失败 → 主扫继续 | meta-L1 inline | mock git -C 失败,验 hook exit 0 |
| §5 C7 | handoff skip 兜底 → cross-ref hook 放行 | meta-L1 inline | 写 skip 字段,验 hook exit 0 |
| §5 R2 | ROOT_DIR 不存在(单层下游模拟)| meta-L1 inline | 临时改 PROJECT_DIR / 用 fixture 仓库 |

### 6.2 测试边界

- **不测**:跨 OS git 实现差异(GNU vs BSD stat 已封装);settings.json 注册自动化(由用户/admin 手动验证);下游分发(命名前缀过滤已 P0.9.1 验证)
- **mock 策略**:hook 测试 = 造 git 工作树(echo 改 + git add)+ invoke hook + 检 exit code + 验 stderr;不引外部 framework(bash 自测)

### 6.3 meta-L 评级

- **meta-L1**:hook 改动有 inline 验证(implementation 阶段造 mis 改动 + invoke hook 验证报警/放行)
- **meta-L1 inline 验证范畴声明**(audit D1-F5 修订):本 trial 的 5 场景验证全部在 harness 自仓库 artificial 构造(临时 fixture / 模拟改 anchor / mock root git 不存在),仅证明 hook 在 harness 自仓库的 syntactic / 结构性正确(不破坏现有 hook chain / R2 graceful 工作 / handoff skip 兜底生效)。**不证明实战是否需要这两条防护**(此问题归 P0.9.2 数据)。本 inline 验证不构成 `feedback_realworld_testing_in_other_projects` 原则下的实战数据。具体:R1 stderr warning 路径在 5 场景中实际**未被触发**(dead path 状态,见 §9.4 #13);untracked 漏检场景(§9.4 #11)+ M3/M4 路径混淆 false negative(§9.4 #10)亦未实测
- **meta-L4 局限**:harness self-trial 验证局限(继承 P0.9.1.5 #5);P0.9.2 启动后下游真实使用时采集第一手数据

---

## 7. 设计决策记录

### 7.1 已确定决策(🟢)

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| **D1** | cross-ref hook 注册时机 | **Stop + pre-commit 双注册**(2 文件) | 与 M15/M16 模式一致(光谱 B+ 双 hook 防护);单 Stop 漏长 session 不 stop 场景(类 fix-9 (ii)),pre-commit 兜底 |
| **D2** | anchor 写死 vs 配置化 | **写死 1 对**(YAGNI) | 当前实证仅 1 对(audit §9.4 #6);未来若实证第 2 对再扩 PAIRS 数组(每对 +4 行,代价低) |
| **D3** | (vii-a) 新增段失败时降级 | 跳过新增段,主扫继续 | 防御性 — 新段独立失败不破坏现有 path;符合 M15/M16 graceful degrade 范式 |
| **D4** | settings 改动范围 | 只动 `settings.json`,不动 `settings.local.json` | local.json 是 user override,不应模板化;与 P0.9.1 D19 a 方案"双轨"一致 |
| **D5** | anchor 缺失时行为 | **exit 2 阻断** + handoff skip 逃生通道 | 与 M15/M16 hook 兜底语义一致;软提醒在 hook 兜底设计中无意义(违反"光谱 B+ 硬执法"原则) |
| **D6** | 单文件双 mode vs 2 文件 | **2 文件** | 与 M15/M16 一致(每 hook 协议差异由独立文件适配);简单清晰胜过 DRY 节流 |

### 7.2 待决策项(🟡)

无(D1-D6 在 brainstorming 阶段已用户拍板)。

### 7.3 RUBRIC 应对方式

- 简洁性:新增 ~200~260 行(高于 M1+M2+M4 batch 的 +25 行,因涉及新建模块);仍轻量(2 hook 文件 + 2 处加段)
- 内部一致性:repo 根扫描与 harness/ 主扫职责正交;cross-ref hook 与 M15 职责正交(主扫=covers / cross-ref=anchor)

---

## 8. 与既有系统的影响

### 8.1 改动清单

| 文件 | 改点 | 行数估计 |
|------|------|---------|
| `harness/.claude/hooks/check-meta-review.sh` | §5 后加新增段(repo 根扫描) | +18 ~ +25 行 |
| `harness/.claude/hooks/check-meta-commit.sh` | §5 后加新增段(repo 根扫描) | +18 ~ +25 行 |
| `harness/.claude/hooks/check-meta-cross-ref.sh` | 新建(Stop hook) | +80 ~ +100 行 |
| `harness/.claude/hooks/check-meta-cross-ref-commit.sh` | 新建(pre-commit hook) | +80 ~ +100 行 |
| `harness/.claude/settings.json` | Stop 段加 1 行 hook 注册 | +5 ~ +8 行 |

合计 +200 ~ +260 行,删 0 行。

### 8.2 不改动但需要验证兼容的

| 文件 | 验证什么 |
|------|---------|
| `harness/.claude/hooks/meta-scope.conf` | 现有 INCLUDE_GLOBS `CLAUDE.md` 仍能命中(repo 根新增段沿用此 glob) |
| `harness/setup.sh` | `check-meta-cross-ref*` 因命名前缀过滤(D12)不分发下游 |
| `harness/templates/settings.json` | 下游模板不应包含 cross-ref hook(下游零 meta hook 注册,D19 a 方案) — ✅ 已验证(audit revision 时 grep 无 `cross-ref` 字面;audit D4-F7) |

### 8.3 元改动同步(M1 meta-finishing 四步引导)

按 `meta-finishing-rules.md` Step D 通用同步项:
1. **decision-trail.md append**:1 条新抉择"P0.9.3 — governance 漂移检测兜底 batch(第三个 trial)"
2. **PROGRESS.md**:不更新(P0.9.3 trial 本身不算跨阶段;与 P0.9.1.5 batch 一致)
3. **ROADMAP.md**:`P0.9.3` 段标 🟢 第一个 trial 闭合;副产物修正(把 (iv)(vi) 移出候选清单 + (i)(ii) 标占位)推为 trial 完成后独立小改
4. **handoff.md**:目标段 + Evidence Depth 段更新,加 meta-L1 数据点 + meta-L4 局限承认
5. **decision file**:`docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md`(方案选择型 — 含 (vii-a)+(互引-a) 选择 + D1-D6 决策)
6. **memory**:不新建条目(本 batch 不立新原则)

---

## 9. 自洽性检查

### 9.1 改动间一致性

- [ ] **(vii-a) ↔ (互引-a)** 不冲突:(vii-a) 在 M15/M16 内加段处理 scope 文件覆盖;(互引-a) 是独立 hook 处理 anchor 完整性 — 两者职责正交
- [ ] **(vii-a) ↔ 现有 §1.3 兼容性"双层/单层"逻辑** 不破:R2(ROOT_DIR 不存在)走单层路径
- [ ] **(互引-a) ↔ §1.3 fix-9 (vi) 决议**:(vi) accept 路径"下游不应改 harness 副本"是对**下游**而言;cross-ref hook 在 **harness 自仓库**生效(check-meta-* 不分发),无冲突
- [ ] **D6 2 文件 ↔ DRY**:文字重复 ~80%,但与 M15/M16 模式一致;若未来累积更多 cross-ref hook 可重构 lib(P0.9.4 候选)

### 9.2 既有治理引用未断

- [ ] `meta-scope.conf` A 组 glob `CLAUDE.md` — 沿用,(vii-a) 通过它命中 M3
- [ ] M15/M16 graceful degrade 范式 — cross-ref hook 沿用
- [ ] D12 命名前缀过滤 — `check-meta-cross-ref*` 自动不分发
- [ ] D19 a 方案"零污染" — 下游 settings.json 模板不变

### 9.3 反向追问(`feedback_dimension_addition_judgment` 原则)

**Q1:M3 hook 不可见缺口"实战中是否有人改 M3"?无数据预防是否违反 `feedback_judgment_basis`?**
A:M3 是 harness 自治理入口,scope 判定 / 治理表 / scope 触发判定的真值在此;若它改动不入 scope,治理流程的元信息(scope 触发判定本身)就处于失同步风险下 — 这是**结构性缺口**而非频率问题(`feedback_judgment_basis` 禁止用"高频/多数"作论据,本论据是逻辑必要性)。**反向追问**:不修复 (vii),"改 M3 不触发 meta-review"问题如何解决?A:无替代解法 — hook cwd 在 harness/ 子目录是历史结构性约束(双层兼容),修复必走 (vii-a) 路径。故修复必要,不是过度工程。

**Q2:cross-ref hook 写死 1 对是否过严(YAGNI 不足)?**
A:当前实证仅 1 对(audit §9.4 #6);若立即配置化 = 凭空预防多对场景,违反 `feedback_judgment_basis`。**反向追问**:不写死,用什么替代?A:无更简方案 — 配置化(YAML / JSON)需引入 parser 层 + schema 维护成本,1 对 anchor 不值;每对 +4 行写死最简。本 spec 接受"未来扩第 2 对时改 hook 文件"的代价(每对 +4 行 PAIRS 数组),不预设配置层。故写死必要,不是过度工程。

**Q3:cross-ref pre-commit hook 是否过度?Stop 是否够?**
A:Stop hook 已覆盖 99% 场景;pre-commit 是 1% 长 session 不 stop 场景的兜底冗余,**此场景属 fix-9 (ii) 占位等 P0.9.2 数据,本 trial 在 P0.9.2 数据来前是无实证支撑的预防**(光谱 B+ 设计代价的诚实承认)。如 P0.9.2 显示 long-session 场景实战不发生,P0.9.4 可考虑撤回 pre-commit cross-ref 文件。本 trial 沿用 M15/M16 双 hook 模式,接受"代码重复 ~80%"代价换"双拦"覆盖。

**Q4(audit revision 后补):本 trial 是否真闭合 (vii-a) M3 hook 不可见?**
A:**部分闭合**。(vii-a) 修复了 hook 在 modified + staged-ACMR 路径下能扫到 repo 根 CLAUDE.md(M3),但有两个精度边界:① **untracked 漏检** — 全新 init 仓库未 git add 的 M3 改动,git diff 不输出 → hook 不报警(选 B 显式承认,见 §9.4 #11);② **M3/M4 路径混淆** — hook 输出的 `CLAUDE.md` 字面对应 M3(repo 根)和 M4(harness/CLAUDE.md)两个文件 — covers 比对精度受限(选 B 显式承认,见 §9.4 #10)。这两个边界推 P0.9.4 / 后续 trial 修;本 trial 闭合声明限于"modified + staged-ACMR 路径生效"(详 §1.1 / §1.2)。

**Q4:本 trial 自身需走 design-review?**
A:scope=meta(改 hook + settings),走 **meta-review**(M2 fork N 挑战者),与 design-review 不互替。

### 9.4 已知缺口(显式承认 — `feedback_spec_gap_masking` 原则)

1. **agent 自律依赖减弱**:hook 兜底覆盖 (vii)+互引,但其他 fix-9 (i)(ii) 仍依赖 agent / 实战数据;P0.9.2 实战观察期收集是否需 (i)(ii) 防御
2. **cross-ref hook anchor 写死的脆弱性**:若 design-rules.md 改 anchor 名(`## spec §0 偏离规则` → `## §0 偏离`),hook 永远报警直至 hook 自身改 PAIRS;这是预期行为(写死 = 显式同步要求),但可能误伤合理 anchor 重命名 — 接受,P0.9.2 观察是否真发生
3. **harness self-trial 验证局限**(继承 P0.9.1.5 #5):本 trial meta-L1 inline 验证局限于 harness 自仓库;下游真实使用时是否生效未验证;P0.9.2 启动条件
4. **bootstrap 自指多重豁免**(audit D1-F2 修订):本 trial 落地涉及三层豁免共同走 manual M2 fork:
   - ① hook 文件 commit 自身不被新 hook 拦(settings.json 注册前)
   - ② spec / plan / decision file 落地不入 hook scope(specs / plans / decisions 不在 INCLUDE_GLOBS)
   - ③ 本次 meta-review fork 是首次,无既有 audit covers 可用
   三层共同走 manual M2 fork(本 audit 即兜底)。**注**:本豁免不是 `feedback_unprovable_in_bootstrap` 原则下的 bootstrap 不可证,而是 spec 显式列出的"初次 commit 执法窗口空缺"(可证缺口 + 显式列出的执法绕过路径);接受是因为 manual M2 fork 兜底,不是因为不可证。任何 P0.9.x 第一个 trial 都受同样豁免,P0.9.2 实战观察是否需要补"首 trial 双拦截策略"(audit D1-F2 + D1-F6)
5. **互引检测对 anchor 文本相似度的容忍度**:grep -F 是字面匹配 — 若 design-rules.md 在 anchor 行附近加注释或换行格式,基本稳健;但若文档作者重新措辞 anchor 周边语境,可能漏检 — 接受
6. **single trial 仅做 2 项**(audit D1-F4 修订):本 trial 仅 2 项((vii-a) + 互引-a)。**P0.9.3 标识符不绑定预设阶段** — 后续若实战暴露新需求(如 P0.9.2 数据显示 (i)(ii) 必要),再开新 trial(可能继续用 P0.9.3 序号或开 P0.9.4),由实际需求拉动,**可能根本不再有 P0.9.3 第二个 trial**。不预设"P0.9.3 整体闭合需多 trial 累积"作为预期阶段(`feedback_iterative_progression`)
7. **下游 retrospective 引用不可见**(继承 P0.9.1.5 #7):本 spec / hook 文字引"audit §9.4 #6"等本地 audit — 该文件分发后下游不可见,溯源受限
8. **pre-commit hook 默认未挂 + 双注册防护层在 harness 实际单拦**(audit D3-F2 修订):harness 自仓库 `.git/hooks/pre-commit` 默认不软链(P0.9.1 §C5),`check-meta-cross-ref-commit.sh` / `check-meta-commit.sh` 在 harness 自仓库**实际不触发**;光谱 B+ "双拦最稳"在 harness 自仓库实际是单拦(Stop hook 漏判 long-session 不 stop + pre-commit 不挂 = 治理空窗)。**本 trial 维持此状态**(下游 setup.sh 可能挂 — 不删 commit hook);若用户希望 harness 自仓库真正落 pre-commit 防护,需手动 `ln -s ../../.claude/hooks/check-meta-cross-ref-commit.sh .git/hooks/pre-commit`(配套 chmod);P0.9.2 实战观察是否需补 install 脚本
9. **挑战者有效性元疑问**(继承 P0.9.1.5 #9):若本 trial meta-review fork 4 挑战者 first-pass 全 pass,无机制强制加 D5 元验证;接受调度者主动判断
10. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30,commit `38e0f7e`+`5eb7882` 等 13 commits 详 decision `2026-04-30-d-class-tech-debt-batch.md` §实施清单)**:hook §5.5 段对 root 级文件加 `<root>/` sentinel 前缀,audit covers 字段约定 M3 改动写 `<root>/CLAUDE.md` / M4 改动写 `CLAUDE.md`。详见 spec `docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md` §3.1 + governance `docs/governance/meta-review-rules.md` §7.3 第 5 条。原识别保留作历史记录:**M3/M4 路径混淆**(audit D2-F3 + D3-F1 + D4-F6 共识):hook §5.5 输出的 `CLAUDE.md` 字面对应 M3(repo 根 = 治理入口)和 M4(harness/CLAUDE.md = 分发模板)两个文件;hook 不区分 → audit covers 字段写 `CLAUDE.md` 时 hook 无法静态判断指 M3 还是 M4。**(vii-a) 闭合质量受限**:write covers 只覆盖 M4 的 audit 仍能让 M3 改动 pass(false negative);反向同 false negative。本 trial 不修(超 scope),推 P0.9.4 加路径前缀绝对化(`<root>/CLAUDE.md` vs `CLAUDE.md`)+ scope.conf 同步 glob。**推后窗口期接受机制**:中间任何 audit 标 `covers: [CLAUDE.md]` 时**调度者人工记忆 + handoff 显式标注**(M3 改动时在 handoff "反审待办" 段加 `CLAUDE.md = 根 M3` 注;M4 改动时加 `CLAUDE.md = harness/CLAUDE.md M4` 注),依赖人工兜底
11. **untracked 漏检**(audit D2-F1):`git diff --name-only` + `git diff --cached --name-only` 都不输出 untracked 文件;新仓库初始化时 M3 全新建未 git add 路径走 untracked,hook §5.5 漏检。本 trial 选 B 显式承认(不扩 hook):新仓库初始化场景在 harness 自仓库实战频率低(P1 项目少),P0.9.4 候选可加 `git ls-files --others --exclude-standard` 扫 untracked。**§5.5 hook stderr 引导加 untracked 提示已落地**:check-meta-review.sh / check-meta-commit.sh 阻断 stderr 段加"若是新建未 git add 的根级文件,需 git add 后才会触发后续检测"(grep 验证 2 hook 命中)。cross-ref hook 不需此提示(grep 已 tracked 文件内容,与 untracked 漏检无关)
12. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30,commit `38e0f7e`+`5eb7882` 等 13 commits 详 decision `2026-04-30-d-class-tech-debt-batch.md` §实施清单)**:cross-ref hook PAIRS 数组从 4 条扩到 6 条,新增 `finishing-rules.md|## 反模式约束`(覆盖 design L28+L45 间接引用)+ `design-rules.md|**轻量级**`(覆盖 finishing L38 间接引用),实际 4 处互引全覆盖(原 audit 误判 5 处,重审实测 4 处,详 spec 2026-04-30 §9.4 #25)。原识别保留作历史记录:**PAIRS 仅覆盖 2/5 实际互引**(audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单(grep 验证):
    - design-rules.md → finishing-rules.md:L28(规模判断表第 4 列)+ L45 — 共 2 处
    - finishing-rules.md → design-rules.md:L3 / L5(scope 分流入口)+ L14 + L38 + L39 — 共 5 处
    - PAIRS 实际覆盖:design-rules.md L38 + L45 + finishing-rules.md L39(同行 ×2 anchor)= **3 个独立检测点 / 2 处实际互引**
    - 漏检:design-rules.md L28、finishing-rules.md L3 / L5 / L14 共 4 处实际互引(若被改写脱钩,hook 不报警)
    本 trial 选 B 显式承认(不扩 PAIRS):本 trial 仅证 anchor-anchor 1 对样本机制可行;后续若实战暴露漏检场景,再扩 PAIRS。**接受 spec_gap_masking 风险**:修复声明限定"机制可行 + 当前 4 条 anchor 字面 in-place"而非"全互引覆盖"
13. **R1 stderr warning 实际 dead path**(audit D2-F2):R1 fix(commit `54190d6`)修补的是 ROOT_DIR 内 `.git` 存在但 `git rev-parse --is-inside-work-tree` 失败的真实 case(.git 损坏 / submodule 未初始化 / 权限问题);但本 trial 5 场景 fixture 是"在 harness 子目录 init,不在 repo 根",走 `[ ! -d "$ROOT_DIR/.git" ]` 分支(整个 if 块跳过)→ R1 warning 路径根本不进入 → 5 场景验证未覆盖此路径(代码 dead path 状态)。**接受**:R1 fix 仍正确(逻辑覆盖),但 inline 验证未实跑;若后续实战触发(用户 .git 损坏)首次会暴露任何 bug,P0.9.2 候选场景
14. **新 skip 字段 `meta-cross-ref` 已在 M1/M2 同步**(audit D4-F1):本 trial 创新 skip 字段 `## meta-cross-ref: skipped(理由: ...)` 已在 M1 §5 + M2 §9 治理 SSoT 同步登记(本 audit revision 完成)
15. **M3 §5 scope 内对照表处置**(audit D4-F3):决定**不细分** cross-ref hook 类(M3 §5 prefix `check-*` 已涵盖);decision file §不做段显式声明此理由
16. **M22 module 编号决策**(audit D4-F4):决定**不取** module 编号;handoff "M22-1/M22-2" 命名删除改纯文件名引用。理由:cross-ref hook 是 P0.9.3 trial 内部产出,主 spec M14-M21 是 P0.9.1 锁定的核心模块表,不为后续 trial hook 全部加新 module 编号
17. **`.gitignore` 排除 `.claude/` 引发"改 hook 不察觉"风险**(audit D3-F6 P2):root `.gitignore` 含 `.claude/` 排除,hook 文件被改后 `git status` 不报,session 末 commit 默认不会包含;本 trial 7 commit 都用 `git add -f` 强加。**接受**:写入 decision-trail.md / handoff.md 显式提醒"hook 文件改动需 `git add -f`";P0.9.4 候选改 `.gitignore` 精确化(如 `.claude/settings.local.json` only)
18. **anchor 含 §(U+00A7)非 ASCII 跨编辑器编码风险**(audit D3-F9 P2):用户用非 UTF-8 编辑器(Win Notepad ANSI / GBK)打开 design-rules.md / finishing-rules.md 编辑后保存,anchor 字节流改变 → grep -F 不命中 → hook 误报 anchor 缺失。接受,P0.9.2 观察;cross-ref hook stderr 加"若 anchor 视觉存在但 hook 报缺,检文件编码是否仍为 UTF-8"提示
19. **跨平台 sed -i 在 plan inline 验证脚本未通用**(audit D3-F8 P2):plan Task 1-6 inline 验证脚本用 GNU `sed -i` 不带后缀,在 macOS BSD sed 实测会失败。接受,plan 文档加 platform note;不影响 hook 本身(stat_mtime 已封装 GNU/BSD)
20. **cross-ref hook trigger case 子串包含匹配** (audit D2-F4 P2):case `*docs/governance/design-rules.md*` 子串匹配,`design-rules.md.bak` / `archived-design-rules.md` 等命中 trigger;无 false positive,但触发时机过宽(无谓 grep 4 文件 = 性能浪费)。接受,P0.9.4 候选改用循环逐行匹配
21. **grep -F 全文匹配 false negative**(audit D2-F5 + D3-F0 P2):hook 不约束 anchor 出现的语境,只校验字面是否存在文件任意位置;若用户把 anchor 字面拷到 changelog/注释但删了真实互引段 → false negative。接受,P0.9.2 观察是否真发生
22. **Stop hook + pre-commit hook 双触发体验**(audit D2-F6 P2):同 session 内已 commit 但 Stop event 又跑同样检查;用户已经 git commit 成功,session 末跑 Stop hook 又对同一文件做相同检查 — 增加 cognitive load 但不破坏功能。harness 自仓库 pre-commit 默认未挂(见 #8),实战不会双触发;若用户/admin 手挂后会双触发。接受,P0.9.2 观察是否构成噪声;若构成,P0.9.4 候选加 stderr 提示"已通过 pre-commit;Stop 二次防护"

---

## 关联

- **上游 spec**:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`(P0.9 主 spec,fix-9 (vii) 来源)
- **上游 decision**:`docs/decisions/2026-04-26-bypass-paths-handling.md`(fix-9 6 路径决议)
- **上游 audit**:`docs/audits/meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md` §9.4 #6(互引脆弱性识别)
- **trial 序列**:M0(2026-04-28)→ M1+M2+M4 batch(2026-04-28~29)→ 本 trial(2026-04-29)
- **下游 decision**:`docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md`(本 trial 落地后立)
- **decision-trail**:落地后 append 1 条新抉择

# D 类技术债 batch trial 系统设计(P0.9.3 第二个 trial)

> **标准级 spec**(`design-rules.md` §规模判断)— 涉及 audit covers ↔ hook 比对协议(多模块共用接口),按第 4 列前置硬条件 (3) 默认升级标准级。

> **scope**:meta(B 组 `.claude/hooks/*` + A 组 `docs/governance/*.md`);走 `meta-finishing-rules.md`(M1)四步流程 + `meta-review-rules.md`(M2)fork N 挑战者审查。

---

## §0 偏离说明

不偏离 `DESIGN_TEMPLATE.md` 模板。本 spec **不引** RUBRIC 维度作 design-review 豁免依据(M2 同步约束);本 trial scope=meta,走 meta-review-rules.md(M2)而非 design-rules 的 design-review。

---

## 1. 需求摘要

### 1.1 用户目标

P0.9.3 第二个 trial — 关闭 P0.9.3 第一个 trial 留下的两条已知缺口:
- spec §9.4 #10:**M3/M4 路径混淆**(hook 输出字面 `CLAUDE.md` 对应 M3 / M4 两文件,covers 比对精度受限)
- spec §9.4 #12:**PAIRS 覆盖度不足**(实际互引 4 处 / PAIRS 当前覆盖 2 处)

并将本 trial 的元数据点(两次审查错误判断过程)留痕作为 `feedback_spec_gap_masking` 治理实证。

### 1.2 核心场景

1. **[P0] M3 改动 audit covers 精确比对**(D1 修复):
   - 用户改根 `CLAUDE.md` → check-meta-review.sh §5.5 段命中 → CHANGED_META_FILES 数组存 `<root>/CLAUDE.md`(加 sentinel 前缀)
   - audit covers 字段写 `<root>/CLAUDE.md` → hook 比对识别为已 cover M3 改动
   - audit covers 字段写 `harness/CLAUDE.md` 或 `CLAUDE.md`(无前缀)→ hook 视为未 cover M3 改动 → 阻断 / 引导补 audit
   - **与 M4 改动区分**:M4 改 `harness/CLAUDE.md` 时主扫输出 `CLAUDE.md`(harness/ 内相对),covers 字段写 `CLAUDE.md` 命中 M4

2. **[P0] design ↔ finishing 互引完整检测**(D4 修复):
   - 用户在 design-rules.md L28 删除"M2 同步约束"引用 → check-meta-cross-ref.sh PAIRS 第 5 条 `finishing-rules.md|## 反模式约束` 仍命中(被引方文件存在);第 5 条改 anchor 选择是测被引文件 anchor,不是测引方字面
   - 用户在 finishing-rules.md L38 删除"design-rules.md \"轻量级\"判定"引用 → PAIRS 第 6 条 `design-rules.md|"轻量级"判定` 检 design 内字面;若 design 改"轻量级"概念名 → hook 报警

3. **[P0] audit covers 路径约定 documented**:
   - M2 §7.3 加 `<root>/` sentinel 协议章节(audit covers 路径规则)
   - 历史 audit 不 backfill(P0.9.1 用仓库相对是孤例,接受);后续 audit 沿用 harness 内部相对 + M3 改动 sentinel

### 1.3 边界与约束

**做什么**:
- 改 4 个 hook(check-meta-review.sh + check-meta-commit.sh + check-meta-cross-ref.sh + check-meta-cross-ref-commit.sh)
- 改 M2 governance/meta-review-rules.md §7.3(audit covers 路径规则节加 sentinel 协议)
- 改 P0.9.3 spec §9.4 #10 + #12 标 🟢 已修(本 trial 关闭)
- 改 P0.9.3 decision file §已知缺口 #10 + #12 同步标 🟢

**不做什么**:
- **不**修 D2 untracked 漏检:D5 修后(commit `0e8283d`)harness/.claude/ 不再默认 untracked,D2 实际暴露面接近 0;commit 时 pre-commit 兜底;P0.9.3 spec §9.4 #11 documented 接受
- **不**修 D3 anchor 写死:用户拍板接受 YAGNI 现状(P0.9.3 spec §1.5 D2 一致性)
- **不**修 D6 cross-ref hook trigger case 子串包含:无 false positive,纯性能微浪费,不值得动
- **不**backfill 5 个历史 audit covers(decision-trail / glassbox / M0 / M1+M2+M4 / P0.9.3):接受历史快照,P0.9.1 仓库相对路径异常作为孤例
- **不**改下游分发(命名前缀 `check-meta-*` 自动过滤,setup.sh 不分发)
- **不**改 root `.gitignore`(D5 已独立 commit `0e8283d`)

**性能要求**:hook 执行 < 500ms(grep 6 文件 anchor + git diff,常规规模)

**安全要求**:无新引入(继承 M15/M16 graceful degrade 范式)

**兼容性要求**:
- sentinel 前缀仅出现在 §5.5 段输出 + audit covers 字段;主扫输出保持原样(harness 内部相对)
- 双层 / 单层下游兼容:R1/R2 graceful degrade 沿用
- D5 修后 harness/.claude/ 全员 tracked,不影响本 trial 的 hook 改动可见性

### 1.4 关联需求

**依赖的已有功能**:
- P0.9.1 M15 / M16 / M17 / M3 治理体系
- P0.9.3 第一个 trial 加的 §5.5 repo 根扫描段 + cross-ref hooks
- P0.5 fork 扁平化(2026-04-16)— meta-review fork 范式

**关闭的已知缺口**:
- P0.9.3 spec §9.4 #10(M3/M4 路径混淆)
- P0.9.3 spec §9.4 #12(PAIRS 覆盖度 2/4)

### 1.5 已确认的决策(从 brainstorming 阶段带入)

1. **D1 形态 = B(sentinel 前缀)**:不选 A(全仓库相对路径)避免 5 个历史 audit backfill;不选 C(scope.conf 锚点 glob)因 fnmatch 不支持锚点
2. **D4 = 加 2 条 PAIRS**(基于第三次审查数据):互引 4 处,PAIRS 现覆盖 2,加 2 条达 4/4 全覆盖
3. **不修 D2 / D3 / D6**:见 §1.3 不做段
4. **不 backfill 5 历史 audit**:接受现状
5. **错判过程留痕**:spec §9.4 #25 documented 两次错误审查过程

### 1.6 RUBRIC 风险标记

> 本节按 hook scope 类比适配。**澄清**:本节描述性使用 RUBRIC 术语(简洁性 / 内部一致性等)是为便于对话,**不作为**设计规模或 design-review 豁免的判定依据(M2 / M4 约束,与 P0.9.3 第一个 trial §1.6 一致)。

- 涉及的"产出健康性"维度:
  - 简洁性:**~30 行**改动(4 hook 共 ~12 行 + M2 §7.3 +10 行 + spec/decision 修正 ~8 行)
  - 内部一致性:`<root>/` sentinel 协议 ↔ audit covers 字段约定 ↔ hook 内部数组三层语义对齐(spec §3.1 + M2 §7.3)
- 涉及的"治理机制"维度:不引入新流程(沿用 M15/M16/M2 既有协议)
- **本 spec 不引 RUBRIC 维度作 design-review 豁免依据**(M2 自约束)

---

## 2. 模块划分

### 2.1 模块清单

| 模块 | 职责 | 新建/改动 | 所在层 |
|------|------|---------|-------|
| `check-meta-review.sh` | Stop hook;§5.5 段 push CHANGED_META_FILES 前加 `<root>/` 前缀 | 改动 | `harness/.claude/hooks/` |
| `check-meta-commit.sh` | pre-commit hook;同上 | 改动 | 同上 |
| `check-meta-cross-ref.sh` | Stop hook;PAIRS 加 2 条 | 改动 | 同上 |
| `check-meta-cross-ref-commit.sh` | pre-commit hook;PAIRS 加 2 条 | 改动 | 同上 |
| `docs/governance/meta-review-rules.md` §7.3 | audit covers 路径规则节加 `<root>/` sentinel 协议章节 | 改动 | `harness/docs/governance/` |
| P0.9.3 spec §9.4 #10 + #12 | 措辞修正 + 标 🟢 已修 | 改动 | `harness/docs/superpowers/specs/` |
| P0.9.3 decision file §已知缺口 #10 + #12 | 同步措辞修正 | 改动 | `harness/docs/decisions/` |

### 2.2 模块依赖图

```
[Claude Code Stop event / git commit]
    ↓
[check-meta-{review,commit}.sh]
    ↓ §5.5 repo 根扫描
[CHANGED_META_FILES 数组] — push 前对 root 级文件加 `<root>/` 前缀
    ↓
[audit covers 比对] — 比对 audit covers 字段(harness 内部相对 + sentinel 前缀)
    ↓
[Stop / commit 放行 / 阻断]

[check-meta-cross-ref{,-commit}.sh]
    ↓
[PAIRS 6 条 anchor 检验] — 现 4 条 + 新加 2 条覆盖 design L28 + finishing L38
    ↓
[VIOLATIONS 数组] — anchor 缺失列表
    ↓
[Stop / commit 放行 / 阻断]
```

依赖方向:`<root>/` sentinel 协议被 4 个 hook + M2 §7.3 共享;PAIRS 数组仅在 cross-ref 双 hook 内部。

---

## 3. 接口定义

### 3.1 模块间接口

#### `<root>/` sentinel 协议(audit covers ↔ hook 比对共用)

```text
<root>/<path-relative-to-repo-root>
```

字面定义:
- `<root>/` 字符串(7 字节,ASCII)— 显式标识 "repo 根级文件"(从 hook cwd=harness/ 视角无法表达 repo 根的相对路径)
- `<path-relative-to-repo-root>` — 文件相对 repo 根的路径(无 `./` 前缀,无尾 `/`)
- 常用值:`<root>/CLAUDE.md`(M3 自治理入口)
- 不与现有真实路径冲突:无文件名以 `<root>/` 字面开头(`<` 字符在文件名中罕见 + 跨平台兼容性问题保证不出现)

使用位置:
1. **hook §5.5 段**:在 push CHANGED_META_FILES 前对 root 级文件加 `<root>/` 前缀
2. **audit covers 字段**:用户写 audit 时 M3 改动用 `<root>/CLAUDE.md`,M4 改动用 `harness/CLAUDE.md`(harness 内部相对,实际是 `CLAUDE.md`)
3. **hook 比对**:`covered_files = ⋃ {audit.yaml.covers}`;比对时字面相等(grep -Fxq)

#### check-meta-review.sh / check-meta-commit.sh §5.5 段(改造伪码)

```bash
# 现有 §5.5 段(P0.9.3 第一个 trial):
ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -z "$ROOT_DIR" ] || [ ! -d "$ROOT_DIR/.git" ]; then
    : # R2 跳过
else
    if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "⚠️ repo 根 git -C 调用失败,§5.5 跳过(主扫继续)" >&2
        ROOT_DIFF=""
    else
        ROOT_DIFF=$( (git -C "$ROOT_DIR" diff --name-only 2>/dev/null; \
                      git -C "$ROOT_DIR" diff --cached --name-only 2>/dev/null) | \
                    awk 'NF' | sort -u )
    fi
    if [ -n "$ROOT_DIFF" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            case "$f" in */*) continue ;; esac
            if is_in_scope "$f"; then
                # ↓ D1 改造:加 sentinel 前缀
                CHANGED_META_FILES+=("<root>/$f")   # 原: CHANGED_META_FILES+=("$f")
            fi
        done <<< "$ROOT_DIFF"
    fi
fi

# stderr 引导段(D1 改造)— 提示 sentinel 协议
echo "  - <root>/<path> 表示 repo 根级文件(M3),与 harness/ 内文件区分(M4 / 治理 / hook 等)"
echo "  - 写 audit covers 时:M3 改动用 <root>/CLAUDE.md,M4 用 CLAUDE.md(harness/ 内相对)"
```

#### check-meta-cross-ref.sh / check-meta-cross-ref-commit.sh PAIRS(改造伪码)

```bash
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'                # 现 1
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'          # 现 2
    'docs/governance/finishing-rules.md|跨阶段同步约束'                   # 现 3
    'docs/governance/finishing-rules.md|见 `design-rules.md`'            # 现 4
    # ↓ D4 修复加 2 条:
    'docs/governance/finishing-rules.md|## 反模式约束'                    # 新 5(检 finishing 内 anchor 段;design L28+L45 引用)
    'docs/governance/design-rules.md|"轻量级"判定'                        # 新 6(检 design 内字面;finishing L38 引用)
)
```

注:
- 第 5 条 anchor `## 反模式约束` 是 finishing-rules.md L24 内部段标题,被 design L28 + L45 间接引用;若 finishing 删段,hook 报警
- 第 6 条 anchor `"轻量级"判定` 是 design-rules.md L11(规模判断表)+ L26 等出现的字面;被 finishing L38 间接引用;若 design 改"轻量级"概念名,hook 报警

### 3.2 外部接口

不适用(本 trial 不涉及 API / 网络协议)。

### 3.3 前后端类型契约

不适用。

---

## 4. 数据模型

### 4.1 数据实体

```bash
# CHANGED_META_FILES — 数组,scope 内文件清单(harness/ 主扫 + repo 根 §5.5 合并)
# 改造前(P0.9.3 第一个 trial):
CHANGED_META_FILES=("CLAUDE.md" "docs/governance/design-rules.md")
# 上面 "CLAUDE.md" 既可能是主扫输出的 harness/CLAUDE.md,也可能是 §5.5 输出的 root M3 — 不可区分

# 改造后(本 trial):
CHANGED_META_FILES=("CLAUDE.md" "<root>/CLAUDE.md" "docs/governance/design-rules.md")
# 主扫 "CLAUDE.md" → 对应 harness/CLAUDE.md(M4)
# §5.5 "<root>/CLAUDE.md" → 对应 repo 根 CLAUDE.md(M3)
# audit covers 字段写 "<root>/CLAUDE.md" 命中 M3,写 "CLAUDE.md" 命中 M4

# PAIRS — 数组,(file|anchor) 配对清单
# 改造前 4 条 → 改造后 6 条(详 §3.1)
```

### 4.2 数据流

```
Stop event / git commit
    ↓
git diff --name-only (主扫 cwd=harness/, --relative)
    ↓ harness/ 内部相对路径
git -C $ROOT_DIR diff --name-only (§5.5)
    ↓ repo 根级文件名
[§5.5 段 push 前加 `<root>/` 前缀] ← D1 改造点
    ↓
合并 → CHANGED_META_FILES(混合 harness/ 内部相对 + sentinel 前缀)
    ↓
audit covers 字段比对(grep -Fxq 字面匹配)
    ↓
[未 cover 的文件] → exit 2/1 + stderr 引导(含 sentinel 协议说明)
```

### 4.3 状态变更

无(hook 是无状态的 — 每次 invoke 独立)。

---

## 5. 边界条件与错误处理

### 5.1 边界条件

| 编号 | 场景 | 输入条件 | 期望行为 |
|---|---|---|---|
| **R1** | repo 根 git diff 失败 | 非 git 仓库 / git 工具缺失 | stderr warning + 跳过 §5.5 段(主扫继续)— 沿用 P0.9.3 第一个 trial R1 |
| **R2** | ROOT_DIR 不存在(单层下游) | 下游分发场景 | 跳过 §5.5 段;hook 整体行为不变 — 沿用 P0.9.3 第一个 trial R2 |
| **R3** | M3 改动 + 无 audit covers | 改根 CLAUDE.md 后未走 meta-review | hook exit 2 引导补 audit / 写 handoff skip;**stderr 引导含 sentinel 协议说明**(本 trial 改造点) |
| **R4** | M3 改动为 untracked 新文件 | 全新 init 仓库新建 root CLAUDE.md 未 git add | hook **漏检**(继承 P0.9.3 §9.4 #11);本 trial 不修 |
| **R5** | M3 vs M4 路径混淆 | 改 root CLAUDE.md 或 harness/CLAUDE.md | **本 trial 关闭**:hook 输出区分 `<root>/CLAUDE.md`(M3) vs `CLAUDE.md`(M4) |
| **R6** | audit covers 字段写 `CLAUDE.md` 但意图 M3 | 用户误以为 `CLAUDE.md` 命中 M3 | hook 视为 `CLAUDE.md` 命中 M4(harness/CLAUDE.md)→ M3 改动**仍然**未 cover → exit 2 引导(stderr 提示用户 sentinel 协议) |
| **C9** | PAIRS 第 5 条 `## 反模式约束` 在 design 内出现 | design-rules.md 自身有 `## 反模式约束` 段 L7 | hook 检 finishing 内是否有 `## 反模式约束`,**与 design 内是否有无关**(grep -F 只看目标文件)— 第 5 条仍正常工作 |
| **C10** | PAIRS 第 6 条 `"轻量级"判定` 改名 | design 把"轻量级"改"小改动" | hook 报警 + finishing L38 引用悬空 — 预期行为(用户必须同步改 finishing 或 PAIRS) |

### 5.2 错误传播路径

```
错误源
  │
  ├─→ R1 / R2(repo 根扫描失败) → stderr warning → 主扫继续 → CHANGED_META_FILES 不含 sentinel 项
  │
  ├─→ R3(M3 未 cover) → exit 2 + stderr 引导(含 sentinel 协议)
  │
  ├─→ R6(用户写错 covers 字段) → hook 比对仍然失败 → exit 2 + stderr 提示 sentinel 协议
  │
  └─→ C5/C6(cross-ref grep 失败) → stderr warning → exit 0(继承 P0.9.3 graceful degrade)
```

---

## 6. 测试策略

### 6.1 关键测试场景(meta-L1 inline)

| 场景 | 测试内容 | 测试层级 | 预期 |
|------|---------|---------|------|
| 1 | 改 root CLAUDE.md(M3)→ §5.5 段 push `<root>/CLAUDE.md` 进数组 | meta-L1 | CHANGED_META_FILES 含 `<root>/CLAUDE.md` |
| 2 | 改 harness/CLAUDE.md(M4)→ 主扫 push `CLAUDE.md` | meta-L1 | CHANGED_META_FILES 含 `CLAUDE.md`(无前缀)|
| 3 | 同时改 M3 + M4 → 数组含 2 项区分 | meta-L1 | CHANGED_META_FILES 含 `<root>/CLAUDE.md` + `CLAUDE.md` 两项 |
| 4 | audit covers 字段写 `<root>/CLAUDE.md` → 命中 M3 改动 → 放行 | meta-L1 | hook exit 0 |
| 5 | audit covers 字段写 `CLAUDE.md` → 仅命中 M4,M3 仍未 cover → 阻断 | meta-L1 | hook exit 2 + stderr sentinel 提示 |
| 6 | cross-ref hook PAIRS 第 5 条:删 finishing-rules.md L24 `## 反模式约束` 段 → hook 报警 | meta-L1 | check-meta-cross-ref exit 2 + 列具体缺失 |
| 7 | cross-ref hook PAIRS 第 6 条:删 design-rules.md 内 `"轻量级"判定` 字面 → hook 报警 | meta-L1 | check-meta-cross-ref exit 2 + 列具体缺失 |
| 8 | R1 段 git -C 失败 fixture(模拟 .git 损坏)→ stderr warning + 主扫继续 | meta-L1 | hook exit 0 + stderr `⚠️ repo 根 git -C 调用失败` |

### 6.2 测试边界

- **不测**:跨 OS git 实现差异(GNU vs BSD stat 已封装,继承 P0.9.3);settings.json 注册自动化(本 trial 不改 settings);下游分发(命名前缀过滤 D12 已在 P0.9.1 验证)
- **mock 策略**:hook 测试 = 造 git 工作树(echo 改 + git add)+ invoke hook + 检 exit code + 验 stderr;不引外部 framework

### 6.3 meta-L 评级

- **meta-L1**:hook 改动有 inline 验证(implementation 阶段 8 场景全造 + invoke hook 验证)
- **meta-L1 inline 验证范畴声明**(继承 P0.9.3 spec §6.3):本 trial 5+ 场景全部在 harness 自仓库 artificial 构造,仅证 hook 改造的 syntactic / 结构性正确(sentinel 前缀生效 + PAIRS 加 2 条命中 + 既有 R1/R2 graceful degrade 保留)。**不证明实战是否需要这两条修复**(D1 / D4 修复必要性由 P0.9.3 spec §9.4 #10 + #12 documented 缺口驱动,不是新数据)
- **meta-L4 局限**:harness self-trial 验证局限(继承 P0.9.1.5 #5);P0.9.2 启动后下游真实使用时采集第一手数据

---

## 7. 设计决策记录

### 7.1 已确定决策(🟢)

> **命名说明**:本表 `DD#` = 设计决策(Design Decision)行 ID,**与** §1.3 / §1.5 / §9.4 中的 `D1/D2/D3/D4/D5/D6` 技术债分类项**无直接对应**;为避免视觉混淆改用 DD 前缀。

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| **DD1** | hook 输出格式(对应技术债 D1) | **B sentinel 前缀** | 0 backfill;与 5/6 现有 audit covers 约定一致;`<root>/` 字面独占不冲突 |
| **DD2** | 是否扩 PAIRS(对应技术债 D4) | **加 2 条**(基于第三次审查实证) | 实际互引 4 处覆盖 2,加 2 达 4/4 全覆盖;第 5/6 条 anchor 选择平衡"被引方 anchor 段" + "被引方关键词字面" |
| **DD3** | sentinel 字面格式 | `<root>/` (7 字节 ASCII) | 与 git 路径不冲突;字面独占;跨 OS 一致 |
| **DD4** | 不修技术债 D2 untracked | accept(继承 P0.9.3 §9.4 #11) | D5 修后实际暴露面接近 0;commit 时 pre-commit 兜底;`feedback_judgment_basis` 不预防 |
| **DD5** | 不 backfill 5 历史 audit | accept | P0.9.1 audit covers 仓库相对路径异常但孤例;后续 5 audit 沿用 harness 内部相对,符合本 trial 协议 |
| **DD6** | M2 §7.3 documented sentinel | 加 ~10 行新章节 | audit covers 路径规则首次显式 documented;支撑后续 trial 协议稳定性 |

### 7.2 待决策项(🟡)

无(D1-D6 在 brainstorming 阶段已用户拍板)。

### 7.3 RUBRIC 应对方式

- 简洁性:~30 行改动(轻量,远低于 P0.9.3 第一个 trial 200+ 行)
- 内部一致性:sentinel 协议 ↔ hook 内部数组 ↔ audit covers 字段三层语义闭环验证(§5 R6 + 测试场景 4-5)

---

## 8. 与既有系统的影响

### 8.1 改动清单

| 文件 | 改点 | 行数估计 |
|------|------|---------|
| `harness/.claude/hooks/check-meta-review.sh` | §5.5 段 push 前加 `<root>/` 前缀 + stderr 引导段加 sentinel 说明 | +3~5 行 |
| `harness/.claude/hooks/check-meta-commit.sh` | 同上 | +3~5 行 |
| `harness/.claude/hooks/check-meta-cross-ref.sh` | PAIRS 加 2 条 | +2 行 |
| `harness/.claude/hooks/check-meta-cross-ref-commit.sh` | PAIRS 加 2 条 | +2 行 |
| `harness/docs/governance/meta-review-rules.md` §7.3 | audit covers 路径规则节加 `<root>/` sentinel 协议章节 | +10~15 行 |
| `harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md` §9.4 #10/#12 | 措辞修正 + 标 🟢 已修(本 trial 关闭) | ~6 行 |
| `harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md` §已知缺口 #10/#12 | 同步措辞修正 | ~6 行 |

合计 +30~40 行,删 0 行。

### 8.2 不改动但需要验证兼容的

| 文件 | 验证什么 |
|------|---------|
| `harness/.claude/hooks/meta-scope.conf` | 现有 INCLUDE_GLOBS `CLAUDE.md` 仍能命中(§5.5 push 前过滤后再加 sentinel,glob 比对在加前缀**之前**)|
| `harness/templates/settings.json` | 下游模板不受影响(命名前缀 `check-meta-*` 自动过滤 — 已在 P0.9.3 第一个 trial 验证) |
| 历史 6 个 audit covers 字段 | 不改;P0.9.1 仓库相对路径作为孤例,5 audit 沿用 harness 内部相对符合本 trial 协议 |

### 8.3 元改动同步(M1 meta-finishing 四步引导)

按 `meta-finishing-rules.md` Step D 通用同步项:
1. **decision-trail.md append**:1 条新抉择"P0.9.3 第二个 trial — D 类技术债 batch(D1+D4 关闭 #10+#12)"
2. **PROGRESS.md**:不更新(本 trial 不算跨阶段)
3. **ROADMAP.md**:`P0.9.3` 段加第二个 trial 闭合标记
4. **handoff.md**:目标段 + Evidence Depth 段更新
5. **decision file**:`docs/decisions/2026-04-30-d-class-tech-debt-batch.md`(D9 范式 — 含 D1/D4 决策 + 两次错判过程留痕)
6. **memory**:不新建条目

---

## 9. 自洽性检查

### 9.1 改动间一致性

- [ ] **D1 sentinel 协议 ↔ hook §5.5 段 ↔ M2 §7.3 documented**:三层语义对齐(`<root>/` 字面相同 / push 前加前缀 / audit covers 字段约定)
- [ ] **D4 PAIRS 加 2 条 ↔ design ↔ finishing 实际互引**:第 5 条覆盖 design L28 + L45 间接引用;第 6 条覆盖 finishing L38 间接引用
- [ ] **本 trial 关闭 P0.9.3 #10 + #12 ↔ spec/decision 措辞同步**:本 trial 完成后 P0.9.3 spec §9.4 + decision file §已知缺口 同步标 🟢

### 9.2 既有治理引用未断

- [ ] `meta-scope.conf` A 组 glob `CLAUDE.md` — 沿用,§5.5 段过滤判定在加 sentinel 前缀**之前**(glob 比对仍命中 root CLAUDE.md)
- [ ] M15/M16 graceful degrade 范式 — sentinel 改造不破坏(R1/R2 沿用)
- [ ] D12 命名前缀过滤 — `check-meta-*` 自动不分发(本 trial 不改 setup.sh)
- [ ] D19 a 方案"零污染" — 下游 settings.json 模板不变

### 9.3 反向追问(`feedback_dimension_addition_judgment` 原则)

**Q1**:`<root>/` sentinel 协议是 hard-coded 字符串,违反"统一仓库相对路径"的纯净性?
A:接受协议代价 — 0 backfill + 与 5/6 现有 audit 约定一致;`<root>/` 字面在 audit covers 字段中独占,无文件以 `<root>/` 开头(`<` 字符跨平台不出现)。**反向追问**:不用 sentinel,用纯仓库相对路径(方案 A)如何避免 backfill 5 个历史 audit?A:无替代解法 — 历史 audit covers 已写入 git history,不 backfill 等于失效;选 sentinel 是"接受协议代价 vs 接受 backfill 代价"的二选一。

**Q2**:为什么不一并修 D2(untracked)?
A:D5 修后(commit `0e8283d`)harness/.claude/ 不再默认 untracked → D2 实际暴露面接近 0;commit 时 pre-commit 兜底;`feedback_judgment_basis` 不预防(继续接受 P0.9.3 spec §9.4 #11)。**反向追问**:D2 真完全不用修?A:仅"全新建文件 + 不 commit + 直接换会话"边缘 case 漏检;实际频率极低;若 P0.9.2 实战触发再开 trial。

**Q3**:PAIRS 加 2 条会不会再次漏检?(我已两次错判)
A:本次基于完整 grep + 逐行上下文审查 + 用户复审。但**仍可能漏间接引用**(如某天有人在 finishing-rules.md 用"系统设计文档"代替"design-rules.md"间接说同一件事)— 接受 PAIRS 是 anchor 比对工具,不是语义比对工具(P0.9.3 spec §9.4 #5 已 documented)。**反向追问**:不加 PAIRS,有什么替代方案能检测互引漂移?A:语义级比对需要 LLM 或 schema 系统,引入复杂度远超价值;每个新 anchor 加 4 行 PAIRS 是最简实现。

**Q4**:本 trial 自身需走 design-review?
A:scope=meta(改 hook + governance + spec/decision 元数据),走 **meta-review**(M2 fork N 挑战者),与 design-review 不互替。

**Q5**:trial 范围这么小(~30 行),是否值得开完整 trial 范式?
A:涉及多模块共用接口(audit covers 字段约定 + sentinel 协议)→ 按 design-rules.md 第 4 列前置硬条件 (3) 默认升级标准级。即使行数少,接口层语义需要 spec / meta-review fork 验证。否则会陷入"改造前不警告 / 改造后实战暴露"的反模式。

### 9.4 已知缺口(显式承认 — `feedback_spec_gap_masking` 原则)

> 继承 P0.9.3 spec §9.4 22 条 + 本 trial 新增 3 条:

23. **`<root>/` sentinel 跨 OS 行为**:`<` 字符在 Windows / Linux / macOS 文件名都罕见,但**不绝对禁止**(理论上 ext4 / NTFS 都支持 `<` 文件名);若用户真创建以 `<root>/` 字面开头的文件路径,与本协议冲突。接受边缘 case,P0.9.2 实战观察是否真发生
24. **PAIRS 第 5/6 条选择的局限性**:第 5 条用 anchor 段标题 `## 反模式约束`(被引方 anchor)— 若 finishing 把段标题改名(如 `## 反模式列表`),hook 报警但实际 design 引用文字未必同步改;第 6 条用关键词字面 `"轻量级"判定`,同样限制。**接受**:PAIRS 是 grep 字面比对,不是语义比对(同 P0.9.3 #5)
25. **两次审查错误判断过程留痕**(`feedback_spec_gap_masking` 元数据点):
   - **第一次错**(P0.9.3 audit revision 时):接受 audit D4-F2 finding 的"3/5 漏检"叙事,在 P0.9.3 spec §9.4 #12 写"覆盖 2/5"— **没自己 grep 验证**
   - **第二次错**(本 trial brainstorming 时):用 grep `finishing-rules\|design-rules` 命中 5 行,但视觉跳过 L38 间接引用,得出"实际只漏 1 处"— **仍未仔细看每行上下文**
   - **第三次仔细审查**(用户提示后):`grep -nE` + 逐行上下文 + 区分 meta- 前缀 → 4 处互引,漏 2 处
   - **教训**:hook 实现 trial(P0.9.3 第一个 + 本 trial)涉及大量字面 grep + anchor 比对工作,审查者(包括挑战者 + 调度者 + 自审)容易**视觉跳过间接引用**;后续 trial 涉及 anchor / PAIRS 比对时必须**逐行 with context** + 显式区分**直接引用 vs 间接引用**;留痕作为 P0.9.3 trial 序列的元数据点(hook 实现 trial 的高 finding 密度部分来自这种"视觉跳过"模式)

---

## 关联

- **上游 spec**:`docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md`(P0.9.3 第一个 trial,本 trial 关闭其 §9.4 #10 + #12)
- **上游 audit**:`docs/audits/meta-review-2026-04-29-150902-p0-9-3-governance-drift-batch.md`(D4-F2 finding 数据点 5 是错判数据,本 trial 修正)
- **上游 decision**:`docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md`(P0.9.3 第一个 trial decision file)
- **依赖 commit**:`0e8283d`(D5 .gitignore 精确化 + 11 historical untracked 入 git)
- **trial 序列**:M0(2026-04-28)→ M1+M2+M4 batch(2026-04-28~29)→ P0.9.3 第一个 trial(2026-04-29)→ **本 trial / P0.9.3 第二个 trial**(2026-04-30)
- **下游 decision**:`docs/decisions/2026-04-30-d-class-tech-debt-batch.md`(本 trial 落地后立)
- **decision-trail**:落地后 append 1 条新抉择

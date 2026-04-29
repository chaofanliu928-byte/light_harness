# P0.9.3 Governance Drift Detection Batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 落地 P0.9.3 第一个 trial — (a) M3 hook 不可见缺口修复 (fix-9 vii) + (b) design-rules ↔ finishing-rules 互引 anchor 完整性 hook 检测 (audit §9.4 #6),5 个文件改动(2 改 + 2 新建 + 1 settings)。

**Architecture:** 沿用 M15 (check-meta-review.sh) / M16 (check-meta-commit.sh) hook 模式 — graceful degrade + handoff skip 兜底 + Stop/pre-commit 双注册。新 cross-ref hook 写死 1 对 anchor pair(YAGNI);现有 M15/M16 加 repo 根扫描段(独立失败不破坏主扫,D3)。

**Tech Stack:** Bash 4+(POSIX 兼容);awk / grep / sed / git / stat;无外部依赖;Claude Code Stop hook + Git pre-commit hook 协议。

**Spec:** `docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md`

---

## File Structure

| 路径 | 类型 | 职责 |
|------|------|------|
| `harness/.claude/hooks/check-meta-cross-ref.sh` | 新建 | Stop hook,互引 anchor 完整性检查 |
| `harness/.claude/hooks/check-meta-cross-ref-commit.sh` | 新建 | pre-commit hook,互引 anchor 完整性检查 |
| `harness/.claude/hooks/check-meta-review.sh` | 改 | §5 后加 repo 根扫描段 |
| `harness/.claude/hooks/check-meta-commit.sh` | 改 | §5 后加 repo 根扫描段 |
| `harness/.claude/settings.json` | 改 | Stop 段加 cross-ref.sh 注册 |

---

## Task 1: 新建 check-meta-cross-ref.sh(Stop hook)

**Files:**
- Create: `harness/.claude/hooks/check-meta-cross-ref.sh`

- [ ] **Step 1: 写完整文件**

```bash
#!/bin/bash
# check-meta-cross-ref.sh
# P0.9.3 (互引-a) — Claude Code Stop hook:design-rules ↔ finishing-rules 互引 anchor 完整性检查
#
# 用途:
#   每次 session 末扫 git diff,若改动命中 design-rules.md 或 finishing-rules.md,
#   grep 4 条互引 anchor;任一缺失 → exit 2 + stderr 引导。
#
# 协议(Claude Code Stop hook):
#   - 输入:stdin JSON,字段 stop_hook_active(bool)
#   - 输出:exit 0 = 放行;exit 2 = 阻断 + stderr 引导
#
# 防死循环:
#   stop_hook_active == true 时直接 exit 0(参考 M15)
#
# 错误处理(graceful degrade,与 M15/M16 范式一致):
#   - 文件不可读 → stderr warning + exit 0
#   - git diff 失败 → exit 0
#   - 依赖工具缺失(grep/git)→ stderr warning + exit 0
#   - 唯一 exit 2 路径:确认 anchor 缺失 + 无 handoff skip 理由
#
# spec 锚点:§3.1(check-meta-cross-ref.sh)+ §5(R3 / C1-C8)
# anchor 字符串经 grep 验证在对应文件内字面存在(self-review 阶段验证):
#   - design-rules.md L38 `## spec §0 偏离规则`
#   - design-rules.md L45 `另见 \`finishing-rules.md\``
#   - finishing-rules.md L39 `跨阶段同步约束`
#   - finishing-rules.md L39 `见 \`design-rules.md\``
#
# 命名约定:
#   前缀 check-meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游。

set -u

INPUT=$(cat)

# ============================================================================
# 0. 防死循环
# ============================================================================

if command -v jq >/dev/null 2>&1; then
    if [ "$(echo "$INPUT" | jq -r '.stop_hook_active' 2>/dev/null)" = "true" ]; then
        exit 0
    fi
else
    echo "⚠️ jq 缺失,check-meta-cross-ref.sh 降级跳过" >&2
    exit 0
fi

# ============================================================================
# 1. 解析工作目录(双层 harness / 单层下游兼容,沿用 M15 范式)
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [ -d "$PROJECT_DIR/harness/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR"
else
    exit 0
fi

cd "$WORK_DIR" 2>/dev/null || exit 0

# ============================================================================
# 2. 依赖工具检查
# ============================================================================

for tool in grep git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,check-meta-cross-ref.sh 降级跳过" >&2
        exit 0
    fi
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# ============================================================================
# 3. 触发判定:仅 design-rules / finishing-rules 改动时进入检查
# ============================================================================

DIFF_FILES=$( (git diff --name-only --relative 2>/dev/null; \
               git diff --cached --name-only --relative 2>/dev/null) | \
              awk 'NF' | sort -u )

case "$DIFF_FILES" in
    *docs/governance/design-rules.md*|*docs/governance/finishing-rules.md*) ;;
    *) exit 0 ;;
esac

# ============================================================================
# 4. PAIRS 定义 + anchor grep
# ============================================================================

# 用 single-quote 字符串避免 backtick escape;每条格式: "file|anchor"
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
)

VIOLATIONS=()
for pair in "${PAIRS[@]}"; do
    file="${pair%%|*}"
    anchor="${pair#*|}"
    if [ ! -r "$file" ]; then
        echo "⚠️ 文件不可读,check-meta-cross-ref.sh 降级跳过: $file" >&2
        exit 0
    fi
    if ! grep -F -q -- "$anchor" "$file" 2>/dev/null; then
        VIOLATIONS+=("$file 缺失 anchor: $anchor")
    fi
done

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 5. handoff skip 兜底(沿用 M15 范式,字段名 meta-cross-ref)
# ============================================================================

HANDOFF="docs/active/handoff.md"

if [ -r "$HANDOFF" ]; then
    SKIP_LINE=$(grep -E '^[[:space:]]*##[[:space:]]+meta-cross-ref:[[:space:]]+skipped\(理由:[[:space:]]*[^)]*\)' \
                "$HANDOFF" 2>/dev/null | head -1)

    if [ -n "$SKIP_LINE" ]; then
        REASON=$(echo "$SKIP_LINE" | sed -E 's/^.*\(理由:[[:space:]]*([^)]*)\).*$/\1/')
        REASON_TRIMMED=$(echo "$REASON" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
        if [ -n "$REASON_TRIMMED" ]; then
            exit 0
        fi
    fi
fi

# ============================================================================
# 6. 阻断 stop + stderr 引导
# ============================================================================

{
    echo "检测到 design-rules / finishing-rules 互引 anchor 缺失 — Stop 已阻断。"
    echo ""
    echo "缺失 anchor:"
    for v in "${VIOLATIONS[@]}"; do
        echo "  - $v"
    done
    echo ""
    echo "处理方式(任选其一):"
    echo "  1. 在对应文件补回 anchor(参考 spec §3.1 PAIRS 列表)"
    echo "  2. 在 docs/active/handoff.md 写入(必须含非空理由):"
    echo "     ## meta-cross-ref: skipped(理由: <非空理由>)"
} >&2

exit 2
```

- [ ] **Step 2: chmod +x**

Run: `chmod +x harness/.claude/hooks/check-meta-cross-ref.sh`
Expected: 无输出,文件可执行

- [ ] **Step 3: meta-L1 inline 验证 — 缺失场景**

```bash
# 临时备份 design-rules.md
cp harness/docs/governance/design-rules.md /tmp/dr-backup.md

# 单字符替换模拟 anchor 缺失:## spec §0 偏离规则 → ##  spec §0 偏离规则(双空格)
# grep -F 字面匹配后者,不命中前者 — 模拟"anchor 不存在"场景但保持文件结构完整
sed -i 's/## spec §0 偏离规则/##  spec §0 偏离规则/' harness/docs/governance/design-rules.md

# invoke hook(模拟 Stop event)
echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-cross-ref.sh
EXIT=$?

# 还原(恢复 backup)
cp /tmp/dr-backup.md harness/docs/governance/design-rules.md
rm /tmp/dr-backup.md

echo "exit code: $EXIT"
```

Expected:
- exit code = 2
- stderr 含 "缺失 anchor: ## spec §0 偏离规则"

- [ ] **Step 4: meta-L1 inline 验证 — handoff skip 兜底**

```bash
# 同 Step 3 模拟 anchor 缺失,但加 handoff skip 字段
cp harness/docs/governance/design-rules.md /tmp/design-rules-backup.md
sed -i 's/## spec §0 偏离规则/##  spec §0 偏离规则/' harness/docs/governance/design-rules.md  # 改双空格,grep -F 不命中

# 在 handoff 写 skip
HANDOFF="harness/docs/active/handoff.md"
echo "" >> "$HANDOFF"
echo "## meta-cross-ref: skipped(理由: 临时验证 hook 跳过)" >> "$HANDOFF"

echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-cross-ref.sh
EXIT=$?

# 还原
cp /tmp/design-rules-backup.md harness/docs/governance/design-rules.md
sed -i '/## meta-cross-ref: skipped/d' "$HANDOFF"
sed -i '/^$/N;/^\n$/d' "$HANDOFF"  # 清多余空行

echo "exit code: $EXIT"
```

Expected:
- exit code = 0(skip 路径生效)
- 无 stderr 错误输出

- [ ] **Step 5: meta-L1 inline 验证 — 触发判定快速路径(无相关改动)**

```bash
# 不改 design-rules / finishing-rules,任意改其他
echo "test" >> /tmp/unrelated.txt
echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-cross-ref.sh
EXIT=$?
echo "exit code: $EXIT"
rm /tmp/unrelated.txt
```

Expected:
- exit code = 0(快速路径,触发判定 case 不命中)

- [ ] **Step 6: commit**

```bash
git add harness/.claude/hooks/check-meta-cross-ref.sh
git commit -m "$(cat <<'EOF'
feat(p0.9.3): 新建 check-meta-cross-ref.sh — Stop hook 互引 anchor 完整性检查

- design-rules.md ↔ finishing-rules.md 4 条互引 anchor 写死 PAIRS
- design-rules / finishing-rules 改动时触发 grep -F 字面匹配
- 缺失 → exit 2 + stderr 引导;handoff skip 字段(meta-cross-ref)兜底
- 沿用 M15 graceful degrade + 双层/单层 cwd 范式

P0.9.3 第一个 trial(audit §9.4 #6 cross-file 互引脆弱)
spec: docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: 新建 check-meta-cross-ref-commit.sh(pre-commit hook)

**Files:**
- Create: `harness/.claude/hooks/check-meta-cross-ref-commit.sh`

- [ ] **Step 1: 写完整文件**

```bash
#!/bin/bash
# check-meta-cross-ref-commit.sh
# P0.9.3 (互引-a) — Git pre-commit hook:design-rules ↔ finishing-rules 互引 anchor 完整性检查
#
# 用途:
#   git commit 前扫 staged 改动,若命中 design-rules.md / finishing-rules.md,
#   grep 4 条互引 anchor;任一缺失 → exit 1 + stderr 引导,阻断 commit。
#
# 与 check-meta-cross-ref.sh(Stop hook)关系:
#   - 触发时机:Stop hook = session 末;本 hook = git commit 前
#   - 协议:本 hook 无 stdin;无 stop_hook_active 防死循环
#   - 扫描:本 hook 仅扫 staged --diff-filter=ACMR
#   - 退出码:本 hook exit 1 阻断 commit
#   - 安装:.git/hooks/pre-commit 软链;harness 自身默认不挂(P0.9.1 §C5)
#
# spec 锚点:§3.1(check-meta-cross-ref-commit.sh)+ §5(C1-C8)
#
# 命名约定:
#   前缀 check-meta- 触发 setup.sh 命名前缀过滤(D12),不分发下游。

set -u

# ============================================================================
# 1. 解析工作目录(沿用 M16 范式)
# ============================================================================

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [ -d "$PROJECT_DIR/harness/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR/harness"
elif [ -d "$PROJECT_DIR/.claude/hooks" ]; then
    WORK_DIR="$PROJECT_DIR"
else
    exit 0
fi

cd "$WORK_DIR" 2>/dev/null || exit 0

# ============================================================================
# 2. 依赖检查
# ============================================================================

for tool in grep git; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "⚠️ $tool 缺失,check-meta-cross-ref-commit.sh 降级跳过" >&2
        exit 0
    fi
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# ============================================================================
# 3. 触发判定:仅 staged design-rules / finishing-rules 改动时进入
# ============================================================================

DIFF_FILES=$(git diff --cached --name-only --diff-filter=ACMR --relative 2>/dev/null | awk 'NF' | sort -u)

if [ -z "$DIFF_FILES" ]; then
    exit 0
fi

case "$DIFF_FILES" in
    *docs/governance/design-rules.md*|*docs/governance/finishing-rules.md*) ;;
    *) exit 0 ;;
esac

# ============================================================================
# 4. PAIRS + anchor grep
# ============================================================================

PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
)

VIOLATIONS=()
for pair in "${PAIRS[@]}"; do
    file="${pair%%|*}"
    anchor="${pair#*|}"
    if [ ! -r "$file" ]; then
        echo "⚠️ 文件不可读,check-meta-cross-ref-commit.sh 降级跳过: $file" >&2
        exit 0
    fi
    if ! grep -F -q -- "$anchor" "$file" 2>/dev/null; then
        VIOLATIONS+=("$file 缺失 anchor: $anchor")
    fi
done

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
    exit 0
fi

# ============================================================================
# 5. handoff skip 兜底
# ============================================================================

HANDOFF="docs/active/handoff.md"

if [ -r "$HANDOFF" ]; then
    SKIP_LINE=$(grep -E '^[[:space:]]*##[[:space:]]+meta-cross-ref:[[:space:]]+skipped\(理由:[[:space:]]*[^)]*\)' \
                "$HANDOFF" 2>/dev/null | head -1)

    if [ -n "$SKIP_LINE" ]; then
        REASON=$(echo "$SKIP_LINE" | sed -E 's/^.*\(理由:[[:space:]]*([^)]*)\).*$/\1/')
        REASON_TRIMMED=$(echo "$REASON" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
        if [ -n "$REASON_TRIMMED" ]; then
            exit 0
        fi
    fi
fi

# ============================================================================
# 6. 阻断 commit + stderr 引导
# ============================================================================

{
    echo "检测到 staged design-rules / finishing-rules 互引 anchor 缺失 — git commit 已阻断。"
    echo ""
    echo "缺失 anchor:"
    for v in "${VIOLATIONS[@]}"; do
        echo "  - $v"
    done
    echo ""
    echo "处理方式(任选其一,然后重新 git commit):"
    echo "  1. 在对应文件补回 anchor(参考 spec §3.1 PAIRS 列表)"
    echo "  2. 在 docs/active/handoff.md 写入(必须含非空理由):"
    echo "     ## meta-cross-ref: skipped(理由: <非空理由>)"
} >&2

exit 1
```

- [ ] **Step 2: chmod +x**

Run: `chmod +x harness/.claude/hooks/check-meta-cross-ref-commit.sh`

- [ ] **Step 3: meta-L1 inline 验证 — pre-commit 协议触发**

```bash
# 临时改 design-rules.md 删 anchor
cp harness/docs/governance/design-rules.md /tmp/design-rules-backup.md
sed -i 's/## spec §0 偏离规则/##  spec §0 偏离规则/' harness/docs/governance/design-rules.md

# git add(进 staged)
git add harness/docs/governance/design-rules.md

# invoke hook(模拟 pre-commit)
bash harness/.claude/hooks/check-meta-cross-ref-commit.sh
EXIT=$?

# 还原 + reset
cp /tmp/design-rules-backup.md harness/docs/governance/design-rules.md
git reset HEAD harness/docs/governance/design-rules.md

echo "exit code: $EXIT"
```

Expected:
- exit code = 1
- stderr 含 "git commit 已阻断" + "缺失 anchor: ## spec §0 偏离规则"

- [ ] **Step 4: meta-L1 inline 验证 — staged 不命中快速路径**

```bash
# 不 staged design-rules / finishing-rules
bash harness/.claude/hooks/check-meta-cross-ref-commit.sh
EXIT=$?
echo "exit code: $EXIT"
```

Expected: exit code = 0(无 staged 改动 → 快速路径)

- [ ] **Step 5: commit**

```bash
git add harness/.claude/hooks/check-meta-cross-ref-commit.sh
git commit -m "$(cat <<'EOF'
feat(p0.9.3): 新建 check-meta-cross-ref-commit.sh — pre-commit hook 互引检查

镜像 check-meta-cross-ref.sh 逻辑,差异:
- 无 stdin / 无 stop_hook_active
- 扫 git diff --cached --diff-filter=ACMR
- exit 1 阻断 commit
- 安装路径 .git/hooks/pre-commit 软链(P0.9.1 §C5,harness 自身默认不挂)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: 改 check-meta-review.sh 加 repo 根扫描段

**Files:**
- Modify: `harness/.claude/hooks/check-meta-review.sh:209` 之后(§5 末 `if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then exit 0; fi` 这段之前)

- [ ] **Step 1: 读现有 §5 段定位插入点**

Run: `grep -n "CHANGED_META_FILES" harness/.claude/hooks/check-meta-review.sh | head -10`

Expected output:
```
199:CHANGED_META_FILES=()
200:while IFS= read -r f; do
201:    [ -z "$f" ] && continue
202:    if is_in_scope "$f"; then
203:        CHANGED_META_FILES+=("$f")
204:    fi
205:done <<< "$DIFF_FILES"
206:
207:if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
208:    exit 0
209:fi
```

确认插入点:行 205(done 后)与行 207(if check)之间插入新段。

- [ ] **Step 2: Edit — 在 §5 主扫之后插入新 §5.5 repo 根扫描段**

old_string(精确匹配 done + 空行 + if):
```bash
done <<< "$DIFF_FILES"

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi
```

new_string:
```bash
done <<< "$DIFF_FILES"

# ============================================================================
# 5.5. repo 根扫描段(P0.9.3 (vii-a) 修 — M3 hook 不可见缺口)
# ============================================================================
# 主扫 cwd=harness/,git diff --relative 输出不含 repo 根级文件(如 M3 = 根 CLAUDE.md)。
# 新增段:cwd=repo 根 跑 git diff,过滤无 / 前缀的根级文件,用现有 INCLUDE_GLOBS 匹配。
# 失败降级:git -C 失败 / ROOT_DIR 不存在 → stderr warning + 跳过段(主扫继续)。

ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/.git" ]; then
    ROOT_DIFF=$( (git -C "$ROOT_DIR" diff --name-only 2>/dev/null; \
                  git -C "$ROOT_DIR" diff --cached --name-only 2>/dev/null) | \
                 awk 'NF' | sort -u )

    if [ -n "$ROOT_DIFF" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            # 仅取 repo 根级文件(无 / 前缀)— 子目录已在 harness/ 主扫覆盖
            case "$f" in
                */*) continue ;;
            esac
            if is_in_scope "$f"; then
                CHANGED_META_FILES+=("$f")
            fi
        done <<< "$ROOT_DIFF"
    fi
fi
# else: ROOT_DIR 不存在(单层下游)→ 跳过段,主扫继续(R2)

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi
```

- [ ] **Step 3: 校验 bash 语法**

Run: `bash -n harness/.claude/hooks/check-meta-review.sh && echo "OK"`
Expected: `OK`

- [ ] **Step 4: meta-L1 inline 验证 — M3 改动触发**

```bash
# 临时改根 CLAUDE.md
echo "# test marker" >> CLAUDE.md

# invoke hook 模拟 Stop event
echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-review.sh
EXIT=$?

# 还原(撤销 echo 加的行)
sed -i '$d' CLAUDE.md

echo "exit code: $EXIT"
```

Expected:
- exit code = 2(scope 内文件 `CLAUDE.md` 改动 + 无 audit covers)
- stderr 含 "检测到 meta scope 改动" + "  - CLAUDE.md"

- [ ] **Step 5: meta-L1 inline 验证 — R2 单层下游兼容(模拟 ROOT_DIR 缺失)**

```bash
# 创建临时 fixture:单层结构
TMPDIR=$(mktemp -d)
cp -r harness "$TMPDIR/.fake-single-layer"
cd "$TMPDIR/.fake-single-layer"
# 模拟单层(无 PROJECT_DIR/harness)
git init -q 2>/dev/null

CLAUDE_PROJECT_DIR="$TMPDIR/.fake-single-layer" \
    bash -c 'echo {"stop_hook_active": false} | bash .claude/hooks/check-meta-review.sh'
EXIT=$?

cd - >/dev/null
rm -rf "$TMPDIR"

echo "exit code: $EXIT"
```

Expected: exit code = 0(单层路径,无 ROOT_DIR/.git → 跳过新段;无主扫文件改动 → 整体 exit 0)

- [ ] **Step 6: commit**

```bash
git add harness/.claude/hooks/check-meta-review.sh
git commit -m "$(cat <<'EOF'
feat(p0.9.3): check-meta-review.sh 加 repo 根扫描段(vii-a)

修 fix-9 (vii) M3 hook 不可见缺口:
- 主扫 cwd=harness/,git diff --relative 看不到 repo 根级文件(根 CLAUDE.md)
- 新增 §5.5 段:cwd=repo 根 跑 git diff,过滤无 / 前缀文件,用现有 INCLUDE_GLOBS 匹配
- 失败降级(R1/R2):git -C 失败 / ROOT_DIR 不存在 → 跳过段,主扫继续

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: 改 check-meta-commit.sh 加 repo 根扫描段

**Files:**
- Modify: `harness/.claude/hooks/check-meta-commit.sh`(类似 Task 3,但适配 pre-commit 协议)

- [ ] **Step 1: 读现有 §5 段定位插入点**

Run: `grep -n "CHANGED_META_FILES" harness/.claude/hooks/check-meta-commit.sh | head -10`

Expected:
```
197:CHANGED_META_FILES=()
198:while IFS= read -r f; do
199:    [ -z "$f" ] && continue
200:    if is_in_scope "$f"; then
201:        CHANGED_META_FILES+=("$f")
202:    fi
203:done <<< "$DIFF_FILES"
204:
205:if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
206:    exit 0
207:fi
```

- [ ] **Step 2: Edit — 在 §5 主扫之后插入新 §5.5 段**

old_string:
```bash
done <<< "$DIFF_FILES"

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi
```

new_string:
```bash
done <<< "$DIFF_FILES"

# ============================================================================
# 5.5. repo 根扫描段(P0.9.3 (vii-a) 修 — M3 hook 不可见缺口)
# ============================================================================
# 主扫 cwd=harness/,git diff --cached --relative 输出不含 repo 根级文件(M3 = 根 CLAUDE.md)。
# 新增段:cwd=repo 根 跑 git diff --cached,过滤无 / 前缀的根级文件。
# 与 Stop hook 差异:仅扫 staged + diff-filter=ACMR(沿用 M16 主扫语义)。

ROOT_DIR="$(cd "$WORK_DIR/.." 2>/dev/null && pwd)"
if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/.git" ]; then
    ROOT_DIFF=$(git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMR 2>/dev/null | \
                awk 'NF' | sort -u)

    if [ -n "$ROOT_DIFF" ]; then
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            case "$f" in
                */*) continue ;;
            esac
            if is_in_scope "$f"; then
                CHANGED_META_FILES+=("$f")
            fi
        done <<< "$ROOT_DIFF"
    fi
fi
# else: ROOT_DIR 不存在(单层下游)→ 跳过段(R2)

if [ "${#CHANGED_META_FILES[@]}" -eq 0 ]; then
    exit 0
fi
```

- [ ] **Step 3: 校验 bash 语法**

Run: `bash -n harness/.claude/hooks/check-meta-commit.sh && echo "OK"`
Expected: `OK`

- [ ] **Step 4: meta-L1 inline 验证 — staged M3 改动触发**

```bash
# 改 + git add 根 CLAUDE.md
echo "# test marker" >> CLAUDE.md
git add CLAUDE.md

bash harness/.claude/hooks/check-meta-commit.sh
EXIT=$?

# 还原
git reset HEAD CLAUDE.md
sed -i '$d' CLAUDE.md

echo "exit code: $EXIT"
```

Expected:
- exit code = 1(staged scope 文件 + 无 audit covers)
- stderr 含 "Staged 的 meta 文件" + "  - CLAUDE.md"

- [ ] **Step 5: commit**

```bash
git add harness/.claude/hooks/check-meta-commit.sh
git commit -m "$(cat <<'EOF'
feat(p0.9.3): check-meta-commit.sh 加 repo 根扫描段(vii-a)

镜像 check-meta-review.sh 改造,差异:
- 仅扫 git diff --cached --diff-filter=ACMR(沿用 M16 主扫语义)
- exit 1 阻断 commit(M16 协议)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: 注册 check-meta-cross-ref.sh 到 settings.json

**Files:**
- Modify: `harness/.claude/settings.json`

- [ ] **Step 1: Edit — Stop 段加 hook 注册(在 check-meta-review 之后)**

old_string:
```json
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-meta-review.sh"
          }
        ]
      }
    ]
```

new_string:
```json
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-meta-review.sh"
          },
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-meta-cross-ref.sh"
          }
        ]
      }
    ]
```

- [ ] **Step 2: jq 校验 JSON 合法**

Run: `jq . harness/.claude/settings.json >/dev/null && echo "OK"`
Expected: `OK`

- [ ] **Step 3: 视觉校验 Stop 段共 5 个 hook**

Run: `jq '.hooks.Stop[0].hooks | length' harness/.claude/settings.json`
Expected: `5`(check-handoff / check-finishing-skills / check-evidence-depth / check-meta-review / check-meta-cross-ref)

- [ ] **Step 4: commit**

```bash
git add harness/.claude/settings.json
git commit -m "$(cat <<'EOF'
feat(p0.9.3): settings.json Stop 段注册 check-meta-cross-ref.sh

紧随 check-meta-review.sh 之后,继承同一 hook 链 — 在 covers 检查通过后再做 anchor 完整性检查(防御层叠加,光谱 B+)。

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: meta-L1 整合验证(spec §6.1 全 5 场景)

**Files:** 无新改动,纯验证

- [ ] **Step 1: 场景 1 — 改根 CLAUDE.md → check-meta-review.sh 应报警**

```bash
# 改 + 不 add(测 unstaged 路径)
echo "# integration test marker" >> CLAUDE.md

OUTPUT=$(echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-review.sh 2>&1)
EXIT=$?

# 还原
sed -i '$d' CLAUDE.md

echo "=== exit: $EXIT ==="
echo "$OUTPUT"
```

Expected:
- exit = 2
- 输出含 "CLAUDE.md"(在"改动的 meta 文件"清单中)

- [ ] **Step 2: 场景 2 — 改 design-rules.md 删 `## spec §0 偏离规则` → check-meta-cross-ref.sh exit 2**

```bash
cp harness/docs/governance/design-rules.md /tmp/design-rules-backup.md
# 把 anchor 改成 grep -F 不命中(加双空格)
sed -i 's/## spec §0 偏离规则/##  spec §0 偏离规则/' harness/docs/governance/design-rules.md

OUTPUT=$(echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-cross-ref.sh 2>&1)
EXIT=$?

cp /tmp/design-rules-backup.md harness/docs/governance/design-rules.md

echo "=== exit: $EXIT ==="
echo "$OUTPUT"
```

Expected:
- exit = 2
- 输出含 "缺失 anchor: ## spec §0 偏离规则"

- [ ] **Step 3: 场景 R1 — git -C 失败模拟**

```bash
# 用临时假 ROOT_DIR(无 .git)
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/harness/.claude/hooks"
cp harness/.claude/hooks/check-meta-review.sh "$TMPDIR/harness/.claude/hooks/"
cp harness/.claude/hooks/meta-scope.conf "$TMPDIR/harness/.claude/hooks/"
mkdir -p "$TMPDIR/harness/docs/audits" "$TMPDIR/harness/docs/active"
echo '' > "$TMPDIR/harness/docs/active/handoff.md"
git -C "$TMPDIR/harness" init -q 2>/dev/null

CLAUDE_PROJECT_DIR="$TMPDIR" \
    bash -c 'echo {"stop_hook_active": false} | bash "$TMPDIR/harness/.claude/hooks/check-meta-review.sh"'
EXIT=$?

rm -rf "$TMPDIR"

echo "=== exit: $EXIT ==="
```

Expected: exit = 0(无 git 内容,无 scope 改动 → graceful 退出;关键是不报错)

- [ ] **Step 4: 场景 C7 — handoff skip 兜底放行**

```bash
# 复用 Step 2 anchor 缺失 + 加 skip 字段
cp harness/docs/governance/design-rules.md /tmp/design-rules-backup.md
sed -i 's/## spec §0 偏离规则/##  spec §0 偏离规则/' harness/docs/governance/design-rules.md

HANDOFF="harness/docs/active/handoff.md"
echo "" >> "$HANDOFF"
echo "## meta-cross-ref: skipped(理由: 整合验证临时跳过)" >> "$HANDOFF"

OUTPUT=$(echo '{"stop_hook_active": false}' | bash harness/.claude/hooks/check-meta-cross-ref.sh 2>&1)
EXIT=$?

cp /tmp/design-rules-backup.md harness/docs/governance/design-rules.md
# 删 skip 行(并清尾随空行)
sed -i '/## meta-cross-ref: skipped/d' "$HANDOFF"

echo "=== exit: $EXIT ==="
echo "$OUTPUT"
```

Expected:
- exit = 0(skip 字段非空 → 放行)
- 无 "Stop 已阻断" 输出

- [ ] **Step 5: 场景 R2 — 单层下游模拟**

```bash
# 与 Task 3 Step 5 相同 — 创建 .fake-single-layer 模拟
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/.claude/hooks" "$TMPDIR/docs/audits" "$TMPDIR/docs/active"
cp harness/.claude/hooks/check-meta-review.sh "$TMPDIR/.claude/hooks/"
cp harness/.claude/hooks/meta-scope.conf "$TMPDIR/.claude/hooks/"
echo '' > "$TMPDIR/docs/active/handoff.md"
cd "$TMPDIR" && git init -q

CLAUDE_PROJECT_DIR="$TMPDIR" \
    bash -c 'echo {"stop_hook_active": false} | bash "$TMPDIR/.claude/hooks/check-meta-review.sh"'
EXIT=$?

cd - >/dev/null
rm -rf "$TMPDIR"

echo "=== exit: $EXIT ==="
```

Expected: exit = 0(单层路径不需 ROOT_DIR;主扫无改动 → 自然 exit 0)

- [ ] **Step 6: 整合验证总结(无 commit,如有补漏才 commit)**

把 Step 1-5 结果汇总,记录到 handoff.md 的 Evidence Depth 段:

```
meta-L1 inline 验证(2026-04-29):
- 场景 1(M3 改动触发): ✅ exit 2
- 场景 2(anchor 缺失): ✅ exit 2
- 场景 R1(git -C 失败): ✅ graceful exit 0
- 场景 C7(handoff skip 兜底): ✅ exit 0
- 场景 R2(单层下游): ✅ exit 0
```

若有验证失败 → 退回对应 Task 修补 + 重验。

---

## Self-Review

✅ **Spec coverage**:
- spec §1.2 场景 1(M3 改动)→ Task 3 + Task 4 + Task 6 Step 1
- spec §1.2 场景 2(互引 anchor)→ Task 1 + Task 2 + Task 6 Step 2
- spec §3.1 接口契约(repo 根扫描伪码)→ Task 3 Step 2 + Task 4 Step 2
- spec §3.1 接口契约(cross-ref hook 伪码)→ Task 1 Step 1 + Task 2 Step 1
- spec §5 R1/R2 → Task 3 Step 5 + Task 6 Step 3/5
- spec §5 R3(M3 + 无 audit covers)→ Task 3 Step 4
- spec §5 C1-C8 → Task 1 Step 3-5 + Task 2 Step 3-4 + Task 6 Step 1-5
- spec §6.1 5 测试场景 → Task 6 全 5 step
- spec §8.1 5 改动文件 → Task 1-5 各对应 1 文件
- spec §8.3 元改动同步(decision-trail / ROADMAP / handoff / decision file)→ **不在 plan scope**(由 finishing 阶段 meta-finishing-rules.md 接管)

✅ **Placeholder scan**:无 TBD / TODO;每 Step 给完整代码 + 实际命令 + 预期输出。

✅ **Type/signature consistency**:
- PAIRS 4 条字符串在 Task 1 / Task 2 一致(都用 single-quote 字符串避 backtick escape)
- handoff skip 字段名 `meta-cross-ref` 在 Task 1 / Task 2 / Task 6 一致
- exit code:Stop hook = exit 2,pre-commit = exit 1(全 plan 一致)
- WORK_DIR 解析 / 防死循环 / graceful degrade 范式与 M15/M16 一致

✅ **Finishing 边界**:plan 止于 implementation + meta-L1 inline 验证。后续 finishing(decision-trail append / ROADMAP / handoff / decision file / meta-review fork)由 meta-finishing-rules.md(M1)四步流程接管,不在 plan 内。

---

## 关联

- **spec**:`docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md`
- **trial 序列**:M0(2026-04-28)→ M1+M2+M4 batch(2026-04-28~29)→ 本 trial(2026-04-29)
- **finishing 接管文件**:`docs/governance/meta-finishing-rules.md`(M1)+ `docs/governance/meta-review-rules.md`(M2)

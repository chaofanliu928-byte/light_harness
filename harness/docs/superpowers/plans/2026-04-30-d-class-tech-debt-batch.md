# P0.9.3 第二个 trial — D 类技术债 batch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 闭合 P0.9.3 第一个 trial 留下的 D1(M3/M4 路径混淆)+ D4(PAIRS 覆盖度不足)两条已知缺口,以 ~30 行改动落地。

**Architecture:** 4 个 hook 改动(2 §5.5 段加 `<root>/` sentinel 前缀 + 2 PAIRS 扩到 6 条)+ 1 个 governance 章节(M2 §7.3 加 sentinel 协议规则)+ 2 个 spec/decision 措辞同步。无新模块,无新依赖。

**Tech Stack:** bash hooks(check-meta-*.sh,沿用 P0.9.3 第一个 trial 范式)+ markdown governance docs;依赖 git / grep / awk(已 P0.9.1 验证跨 GNU/BSD 兼容)。

**Spec:** `docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md`(D1+D4 closure rationale + sentinel 协议 + PAIRS 完整列表 + 8 测试场景)。

**Platform note:** plan inline 验证脚本默认 GNU sed -i 语法(Windows Git Bash / Linux 通用)。macOS BSD sed 用户需把 `sed -i 's/foo/bar/'` 改 `sed -i '' 's/foo/bar/'`(继承 P0.9.3 §9.4 #19)。hook 文件本身的 stat 兼容性已在 P0.9.1 封装(GNU `-c %Y` / BSD `-f %m`),无需 platform 区分。

---

## File Structure

| 文件 | 改动类型 | 改动点 | 行数 |
|------|---------|--------|------|
| `harness/.claude/hooks/check-meta-review.sh` | 改 | §5.5 push 前加 `<root>/` 前缀 + stderr 引导段加 sentinel 协议说明 | +5 |
| `harness/.claude/hooks/check-meta-commit.sh` | 改 | 同上(staged-only 变体) | +5 |
| `harness/.claude/hooks/check-meta-cross-ref.sh` | 改 | PAIRS 4 → 6 条 | +3 |
| `harness/.claude/hooks/check-meta-cross-ref-commit.sh` | 改 | PAIRS 4 → 6 条 | +3 |
| `harness/docs/governance/meta-review-rules.md` | 改 | §7.3 加第 5 条 sentinel 协议规则 | +12 |
| `harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md` | 改 | §9.4 #10 + #12 prepend 🟢 已修 | +4 |
| `harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md` | 改 | §已知缺口 #10 + #12 prepend 🟢 已修 | +4 |

合计 ~36 行,删 0 行。

---

## Pre-Task: handoff skip 兜底 + 治理预备

> 本 trial 改动 hooks(B 组 scope=meta)+ A 组 governance + spec/decision(F/A 组)— 实现期单 commit 都会触发 Stop hook + pre-commit hook(若挂)的 meta-review 检查。当前**无对应 audit**(audit 在 finishing 阶段产),需 handoff 字段兜底放行。

- [ ] **Step 0.1: 写 handoff 字段兜底**

编辑 `harness/docs/active/handoff.md`,在文件末尾追加(若已存在 `## meta-review: skipped` 则更新理由)。**两个字段都需要写**(本 trial 既改 §5.5 段触发 meta-review hook,又改 PAIRS 触发 cross-ref hook):

```markdown
## meta-review: skipped(理由: P0.9.3 第二个 trial 实现期 — D1+D4 hook 改动 + M2 §7.3 + spec/decision 措辞同步,audit 由 meta-finishing 阶段产)

## meta-cross-ref: skipped(理由: P0.9.3 第二个 trial 实现期 — PAIRS 加 2 条同步 design ↔ finishing 实际 4 处互引,audit 由 meta-finishing 产)
```

- [ ] **Step 0.2: 验证 handoff skip 字段格式**

```bash
grep -E '^## meta-(review|cross-ref): skipped\(理由: .+\)' harness/docs/active/handoff.md
```
预期:输出两行匹配(理由非空)。

---

## Task 1: D1 hooks §5.5 sentinel 前缀 + stderr 引导

**Files:**
- Modify: `harness/.claude/hooks/check-meta-review.sh:234`(§5.5 push 行)
- Modify: `harness/.claude/hooks/check-meta-review.sh:466-473`(stderr 引导段)
- Modify: `harness/.claude/hooks/check-meta-commit.sh:231`(§5.5 push 行)
- Modify: `harness/.claude/hooks/check-meta-commit.sh:460-468`(stderr 引导段)

**spec 引用**:`docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md` §3.1(sentinel 协议)+ §6.1 测试场景 1-5/8。

- [ ] **Step 1.1: 改 check-meta-review.sh §5.5 push 行加 sentinel 前缀**

定位行 234(§5.5 段 `is_in_scope` 块内):

旧代码:
```bash
            if is_in_scope "$f"; then
                CHANGED_META_FILES+=("$f")
            fi
```

新代码:
```bash
            if is_in_scope "$f"; then
                # D1 sentinel 前缀:repo 根级文件加 `<root>/`,与主扫输出区分(M3 vs M4)
                CHANGED_META_FILES+=("<root>/$f")
            fi
```

- [ ] **Step 1.2: 改 check-meta-review.sh stderr 引导段加 sentinel 协议说明**

定位行 472-473(stderr 引导段最后一组 echo,在 `} >&2` 之前)。在原"非 scope 改动..."行**之后**插入:

```bash
    echo ""
    echo "路径前缀约定(P0.9.3 第二个 trial 引入 — sentinel 协议):"
    echo "  - <root>/<path> 表示 repo 根级文件(M3 = repo 根 CLAUDE.md / .gitignore 等)"
    echo "  - 无前缀路径表示 harness/ 内部相对(M4 / 治理 / hook 等)"
    echo "  - 写 audit covers 字段:M3 改动用 <root>/CLAUDE.md,M4 改动用 CLAUDE.md"
```

- [ ] **Step 1.3: 改 check-meta-commit.sh §5.5 push 行加 sentinel 前缀**

定位行 231(§5.5 段 `is_in_scope` 块内,与 review.sh 同一模式):

旧代码:
```bash
            if is_in_scope "$f"; then
                CHANGED_META_FILES+=("$f")
            fi
```

新代码:
```bash
            if is_in_scope "$f"; then
                # D1 sentinel 前缀:repo 根级文件加 `<root>/`,与主扫输出区分(M3 vs M4)
                CHANGED_META_FILES+=("<root>/$f")
            fi
```

- [ ] **Step 1.4: 改 check-meta-commit.sh stderr 引导段加 sentinel 协议说明**

定位 stderr 引导段最后(行 467-468 附近,在 `} >&2` 之前)。在原"非 scope 改动..."行**之后**插入(与 Step 1.2 相同 5 行):

```bash
    echo ""
    echo "路径前缀约定(P0.9.3 第二个 trial 引入 — sentinel 协议):"
    echo "  - <root>/<path> 表示 repo 根级文件(M3 = repo 根 CLAUDE.md / .gitignore 等)"
    echo "  - 无前缀路径表示 harness/ 内部相对(M4 / 治理 / hook 等)"
    echo "  - 写 audit covers 字段:M3 改动用 <root>/CLAUDE.md,M4 改动用 CLAUDE.md"
```

- [ ] **Step 1.5: bash 语法检查**

```bash
bash -n harness/.claude/hooks/check-meta-review.sh
bash -n harness/.claude/hooks/check-meta-commit.sh
```
预期:两条均无输出(语法正确)。

- [ ] **Step 1.6: meta-L1 inline 验证场景 1 — M3 改动 → §5.5 push `<root>/CLAUDE.md`**

```bash
# fixture: 改 repo 根 CLAUDE.md(增加 1 个空行,无语义变更)
echo "" >> /d/个人/harness/CLAUDE.md
# 触发 Stop hook
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1 | tee /tmp/scenario1.out || true
# 验证 stderr 含 sentinel 前缀
grep -F '<root>/CLAUDE.md' /tmp/scenario1.out
# 清理 fixture
git -C /d/个人/harness checkout CLAUDE.md
```
预期:`grep` 命中 `- <root>/CLAUDE.md`(在"改动的 meta 文件"列表中)。

- [ ] **Step 1.7: meta-L1 inline 验证场景 2 — M4 改动 → 主扫 push 无前缀 `CLAUDE.md`**

```bash
# fixture: 改 harness/CLAUDE.md(M4 — 增加空行)
echo "" >> /d/个人/harness/harness/CLAUDE.md
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1 | tee /tmp/scenario2.out || true
# 验证 stderr 含无前缀的 CLAUDE.md(主扫输出),不含 <root>/ 前缀
grep -F '  - CLAUDE.md' /tmp/scenario2.out | grep -v '<root>'
# 清理
git -C /d/个人/harness/harness checkout CLAUDE.md
```
预期:`grep` 命中 `- CLAUDE.md`(无 `<root>/` 前缀)。

- [ ] **Step 1.8: meta-L1 inline 验证场景 3 — M3 + M4 同时改动 → 数组含 2 项**

```bash
# fixture: 同时改两文件
echo "" >> /d/个人/harness/CLAUDE.md
echo "" >> /d/个人/harness/harness/CLAUDE.md
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1 | tee /tmp/scenario3.out || true
# 验证 stderr 含两个独立项
grep -cF '<root>/CLAUDE.md' /tmp/scenario3.out  # 期望 ≥1(可能在"改动的"+"未被覆盖的"两段都出现)
grep -E '^\s+-\s+CLAUDE\.md\s*$' /tmp/scenario3.out  # 期望 ≥1
# 清理
git -C /d/个人/harness checkout CLAUDE.md
git -C /d/个人/harness/harness checkout CLAUDE.md
```
预期:两 grep 都命中(两项独立存在,不互相吞并)。

- [ ] **Step 1.9: meta-L1 inline 验证场景 8 — R1 git -C 失败 graceful degrade**

```bash
# fixture: 模拟 ROOT_DIR/.git 损坏 — 临时重命名 .git 目录
mv /d/个人/harness/.git /d/个人/harness/.git.bak
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1 | tee /tmp/scenario8.out || true
# 验证主扫继续(exit 0/2 都可,核心是不 crash)+ 无 R1 warning(因 [ -d "$ROOT_DIR/.git" ] 拦在 git -C 之前)
# 注:本 fixture 走"$ROOT_DIR/.git 不存在"分支,§5.5 整段跳过(R2 路径)
# R1 真实路径(.git 存在但 rev-parse 失败)在 P0.9.3 §9.4 #13 documented 为 dead path,不在此 fixture
# 清理
mv /d/个人/harness/.git.bak /d/个人/harness/.git
```
预期:hook 不 crash;§5.5 跳过(R2);主扫继续。

- [ ] **Step 1.10: meta-L1 inline 验证场景 4 — audit covers `<root>/CLAUDE.md` 命中 M3**

```bash
# 本场景需有 audit covers 字段含 <root>/CLAUDE.md;P0.9.3 audit 已写 covers,
# 但当前 audit 没有 sentinel 前缀(协议刚引入)。
# 临时 fixture: 在 docs/audits/ 造一个临时 audit 含 <root>/CLAUDE.md covers
cat > /d/个人/harness/harness/docs/audits/meta-review-2026-04-30-tmp-d1-test.md <<'EOF'
---
meta-review: true
covers:
  - <root>/CLAUDE.md
---

# 临时测试 audit(D1 inline 验证)— Task 1 cleanup 时删除
EOF
# 改 root CLAUDE.md
echo "" >> /d/个人/harness/CLAUDE.md
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1
EXIT_CODE=$?
echo "exit code: $EXIT_CODE"
# 清理
rm /d/个人/harness/harness/docs/audits/meta-review-2026-04-30-tmp-d1-test.md
git -C /d/个人/harness checkout CLAUDE.md
```
预期:exit code = 0(audit covers 命中,放行)。

- [ ] **Step 1.11: meta-L1 inline 验证场景 5 — audit covers 写 `CLAUDE.md`(无前缀)→ 仅命中 M4,M3 仍未 cover → 阻断**

```bash
# 同上 fixture,但 audit covers 写无前缀
cat > /d/个人/harness/harness/docs/audits/meta-review-2026-04-30-tmp-d1-test.md <<'EOF'
---
meta-review: true
covers:
  - CLAUDE.md
---

# 临时测试 audit(无前缀 covers,仅命中 M4)
EOF
# 改 root CLAUDE.md(M3,无对应 audit)
echo "" >> /d/个人/harness/CLAUDE.md
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-review.sh 2>&1 | tee /tmp/scenario5.out
EXIT_CODE=$?
echo "exit code: $EXIT_CODE"
# 验证: exit 2 + stderr 列出 <root>/CLAUDE.md 未 cover
grep -F '<root>/CLAUDE.md' /tmp/scenario5.out
# 清理
rm /d/个人/harness/harness/docs/audits/meta-review-2026-04-30-tmp-d1-test.md
git -C /d/个人/harness checkout CLAUDE.md
```
预期:exit code = 2 + stderr 含 `<root>/CLAUDE.md`(未 cover)。

- [ ] **Step 1.12: 检查没有遗留 fixture 残留**

```bash
ls /d/个人/harness/harness/docs/audits/meta-review-2026-04-30-tmp-*.md 2>/dev/null
git -C /d/个人/harness status -s CLAUDE.md
git -C /d/个人/harness/harness status -s CLAUDE.md
```
预期:无 tmp audit;无未清理的 CLAUDE.md 改动。

- [ ] **Step 1.13: Commit**

```bash
git -C /d/个人/harness add harness/.claude/hooks/check-meta-review.sh harness/.claude/hooks/check-meta-commit.sh harness/docs/active/handoff.md
git -C /d/个人/harness commit -m "$(cat <<'EOF'
fix(p0.9.3-trial2): D1 — hook §5.5 加 <root>/ sentinel 前缀

check-meta-review.sh + check-meta-commit.sh §5.5 段 push CHANGED_META_FILES
前对 root 级文件加 `<root>/` 前缀;stderr 引导段加 sentinel 协议说明。

闭合 P0.9.3 第一个 trial §9.4 #10(M3/M4 路径混淆)。

meta-L1 inline:5 场景实跑(scenario 1/2/3/4/5)+ R1 graceful degrade 验证;
8 场景全数详 spec §6.1。

handoff.md 加 ## meta-review: skipped 字段(实现期兜底,audit 在 finishing 产)。
EOF
)"
```

---

## Task 2: D4 cross-ref hooks PAIRS 加 2 条

**Files:**
- Modify: `harness/.claude/hooks/check-meta-cross-ref.sh:98-103`(PAIRS 数组)
- Modify: `harness/.claude/hooks/check-meta-cross-ref-commit.sh:73-78`(PAIRS 数组)

**spec 引用**:`docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md` §3.1 PAIRS 改造伪码 + §6.1 测试场景 6-7。

- [ ] **Step 2.1: 改 check-meta-cross-ref.sh PAIRS 加 2 条**

定位行 98-103(PAIRS 数组定义)。

旧代码:
```bash
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
)
```

新代码:
```bash
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
    # P0.9.3 第二个 trial 加(D4 修复 — 覆盖 design L28+L45 / finishing L38 间接引用):
    'docs/governance/finishing-rules.md|## 反模式约束'
    'docs/governance/design-rules.md|"轻量级"判定'
)
```

- [ ] **Step 2.2: 改 check-meta-cross-ref-commit.sh PAIRS 加 2 条**

定位行 73-78(PAIRS 数组定义),作完全相同的改动:

新代码:
```bash
PAIRS=(
    'docs/governance/design-rules.md|## spec §0 偏离规则'
    'docs/governance/design-rules.md|另见 `finishing-rules.md`'
    'docs/governance/finishing-rules.md|跨阶段同步约束'
    'docs/governance/finishing-rules.md|见 `design-rules.md`'
    # P0.9.3 第二个 trial 加(D4 修复 — 覆盖 design L28+L45 / finishing L38 间接引用):
    'docs/governance/finishing-rules.md|## 反模式约束'
    'docs/governance/design-rules.md|"轻量级"判定'
)
```

- [ ] **Step 2.3: bash 语法检查**

```bash
bash -n harness/.claude/hooks/check-meta-cross-ref.sh
bash -n harness/.claude/hooks/check-meta-cross-ref-commit.sh
```
预期:无输出。

- [ ] **Step 2.4: 现状验证 — 新 anchor 在 design / finishing 内字面存在**

```bash
grep -F '## 反模式约束' harness/docs/governance/finishing-rules.md
grep -F '"轻量级"判定' harness/docs/governance/design-rules.md
```
预期:两条 grep 各命中 ≥1 行(确认 anchor 在 baseline 状态下存在)。

- [ ] **Step 2.5: meta-L1 inline 验证场景 6 — 删 finishing-rules.md `## 反模式约束` 段标题 → hook 报警**

```bash
# fixture: 临时改 finishing-rules.md anchor(改名为 `## 反模式列表`)
sed -i 's/^## 反模式约束$/## 反模式列表/' harness/docs/governance/finishing-rules.md
# 触发 Stop hook(需要先 git diff 触发 case 分支)
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-cross-ref.sh 2>&1 | tee /tmp/scenario6.out
EXIT_CODE=$?
echo "exit code: $EXIT_CODE"
# 验证: exit 2 + stderr 列出 finishing-rules.md 缺失 ## 反模式约束
grep -F '## 反模式约束' /tmp/scenario6.out
# 清理: 还原文件
git -C /d/个人/harness/harness checkout docs/governance/finishing-rules.md
```
预期:exit code = 2(或被 handoff skip 兜回 0,但 stderr 仍列出 violation);grep 命中 anchor 缺失提示。

> **注**:若 handoff `## meta-cross-ref: skipped` 字段存在(Pre-Task Step 0 写入),hook 会 exit 0 但 stderr 仍输出 violations。验证可改用 `grep -F '## 反模式约束' /tmp/scenario6.out` 是否在"缺失 anchor"段命中,而非依赖 exit code。

- [ ] **Step 2.6: meta-L1 inline 验证场景 7 — 删 design-rules.md `"轻量级"判定` 字面 → hook 报警**

```bash
# fixture: 临时改 design-rules.md "轻量级"为 "小改动"(全文替换)
sed -i 's/"轻量级"/"小改动"/g' harness/docs/governance/design-rules.md
cd /d/个人/harness/harness
echo '{"stop_hook_active": false}' | bash .claude/hooks/check-meta-cross-ref.sh 2>&1 | tee /tmp/scenario7.out
echo "exit code: $?"
# 验证 stderr 列出 design-rules.md 缺失 "轻量级"判定
grep -F '"轻量级"判定' /tmp/scenario7.out
# 清理
git -C /d/个人/harness/harness checkout docs/governance/design-rules.md
```
预期:stderr 含 `design-rules.md 缺失 anchor: "轻量级"判定`。

- [ ] **Step 2.7: 检查无 fixture 残留**

```bash
git -C /d/个人/harness/harness status -s docs/governance/
```
预期:无未清理的 governance 改动。

- [ ] **Step 2.8: Commit**

```bash
git -C /d/个人/harness add harness/.claude/hooks/check-meta-cross-ref.sh harness/.claude/hooks/check-meta-cross-ref-commit.sh
git -C /d/个人/harness commit -m "$(cat <<'EOF'
fix(p0.9.3-trial2): D4 — cross-ref PAIRS 4 → 6 条

check-meta-cross-ref.sh + check-meta-cross-ref-commit.sh PAIRS 数组扩 2 条:
- finishing-rules.md|## 反模式约束(覆盖 design L28+L45 间接引用)
- design-rules.md|"轻量级"判定(覆盖 finishing L38 间接引用)

闭合 P0.9.3 第一个 trial §9.4 #12(PAIRS 覆盖度 2/4 → 6/4 全覆盖)。

meta-L1 inline:scenario 6/7 实跑(改 anchor + 验 stderr 报警)。
EOF
)"
```

---

## Task 3: M2 §7.3 sentinel 协议规则节

**Files:**
- Modify: `harness/docs/governance/meta-review-rules.md:320-326`(§7.3 covers 数组路径规则)

**spec 引用**:`docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md` §1.3 + §3.1 + §7.1 DD6。

- [ ] **Step 3.1: 在 §7.3 现有 4 条规则后追加第 5 条 sentinel 协议**

定位行 320-326(§7.3 现有 4 条编号规则)。

旧代码(行 320-326):
```markdown
### 7.3 covers 数组路径规则

1. **仓库相对路径**:从仓库根算起,无 `./` 前缀,无尾 `/`(如 `docs/governance/design-rules.md`)
2. **正斜杠分隔**:Windows 仓库也用 `/`(YAML 跨平台一致)
3. **路径必须实存**:写 audit 时调度者列入的路径必须在仓库内实存(允许扩展提交后实存)
4. **无去重要求**:数组内允许重复,hook 处理时按集合并集计算
```

新代码(在第 4 条后追加第 5 条):
```markdown
### 7.3 covers 数组路径规则

1. **仓库相对路径**:从仓库根算起,无 `./` 前缀,无尾 `/`(如 `docs/governance/design-rules.md`)
2. **正斜杠分隔**:Windows 仓库也用 `/`(YAML 跨平台一致)
3. **路径必须实存**:写 audit 时调度者列入的路径必须在仓库内实存(允许扩展提交后实存)
4. **无去重要求**:数组内允许重复,hook 处理时按集合并集计算
5. **`<root>/` sentinel 前缀(P0.9.3 第二个 trial 引入)** — 区分 repo 根级文件(M3 = `/CLAUDE.md`)与 harness/ 内部相对路径(M4 = `harness/CLAUDE.md`,在 hook `git diff --relative` 视角输出 `CLAUDE.md`):
   - **写 audit covers 时**:M3 改动写 `<root>/CLAUDE.md`;M4 改动写 `CLAUDE.md`(harness 内部相对,与第 1-4 条规则一致)
   - **hook §5.5 段输出**:`check-meta-review.sh` / `check-meta-commit.sh` 在 repo 根扫描发现 root 级文件后,push CHANGED_META_FILES 前对该文件加 `<root>/` 前缀
   - **比对语义**:hook 用 `grep -Fxq` 字面比对 covers 与 CHANGED_META_FILES;`<root>/CLAUDE.md` ≠ `CLAUDE.md`(独立项)
   - **历史 audit 兼容**:5/6 现有 audit covers 用 harness 内部相对路径(无前缀),自动命中 M4 语义;唯 P0.9.1 audit covers 用仓库相对(`harness/...`)作为孤例不 backfill
   - **字面独占性**:`<root>/` 7 字节 ASCII 字面与所有现实文件路径不冲突(`<` 字符在 git 实际路径中罕见 + 跨平台兼容性问题保证不出现);若用户真创建以 `<root>/` 字面开头的文件,与本协议冲突(spec 2026-04-30 §9.4 #23 接受边缘 case)
```

- [ ] **Step 3.2: 验证 markdown 渲染 — 列表层级 + 编号正确**

```bash
grep -nE '^[0-9]+\.\s|^   -\s' harness/docs/governance/meta-review-rules.md | head -20
```
预期:第 5 条编号 `5.` 在 §7.3 块内出现;子项 `   -` 缩进对齐 4 项。

- [ ] **Step 3.3: 验证 sentinel 协议章节 anchor 字面独占**

```bash
# 检查 <root>/ 字面在仓库内的出现位置
grep -rF '<root>/' harness/ --include='*.md' --include='*.sh' 2>/dev/null | head -10
```
预期:出现位置:meta-review-rules.md §7.3、spec 2026-04-30、hook 注释 / stderr — 与设计一致;不在文件实际路径中。

- [ ] **Step 3.4: Commit**

```bash
git -C /d/个人/harness add harness/docs/governance/meta-review-rules.md
git -C /d/个人/harness commit -m "$(cat <<'EOF'
docs(p0.9.3-trial2): M2 §7.3 加 sentinel 协议规则(第 5 条)

meta-review-rules.md §7.3 在现有 4 条 covers 路径规则后追加第 5 条
"<root>/ sentinel 前缀",documented:
- 写 audit covers 时 M3 用 <root>/CLAUDE.md / M4 用 CLAUDE.md
- hook §5.5 段输出语义 + 比对语义(grep -Fxq 字面)
- 历史 audit 兼容 + 字面独占性(<root>/ 与现实路径不冲突)

支持 D1 修复(本 trial Task 1)闭合 P0.9.3 §9.4 #10。

scope=meta(A 组 governance);本次实现期 audit 由 finishing 阶段产。
EOF
)"
```

---

## Task 4: P0.9.3 spec §9.4 #10 + #12 标 🟢 已修

**Files:**
- Modify: `harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md:447`(§9.4 #10)
- Modify: `harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md:449-454`(§9.4 #12)

**目的**:闭合标记 — 留原 finding 文字作历史记录,prepend 本 trial 关闭说明。

- [ ] **Step 4.1: 改 §9.4 #10 prepend 🟢 已修标注**

定位行 447 开头。

旧代码(行 447 开头):
```markdown
10. **M3/M4 路径混淆**(audit D2-F3 + D3-F1 + D4-F6 共识):...
```

新代码(prepend 🟢 标注 + 关闭说明,保留原文):
```markdown
10. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30,commit `<TBD>`)**:hook §5.5 段对 root 级文件加 `<root>/` sentinel 前缀,audit covers 字段约定 M3 改动写 `<root>/CLAUDE.md` / M4 改动写 `CLAUDE.md`。详见 spec `docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md` §3.1 + governance `docs/governance/meta-review-rules.md` §7.3 第 5 条。原识别保留作历史记录:**M3/M4 路径混淆**(audit D2-F3 + D3-F1 + D4-F6 共识):...
```

> **注**:`<TBD>` commit hash 占位 — 实现期保留,**finishing 阶段** Step C(立 decision file)时统一替换为 Task 1-5 的实际 commit hash 列表(单 commit 写 hash;多 commit 写 commit range 或主 commit + "等"标注)。本步骤不阻塞 commit。

- [ ] **Step 4.2: 改 §9.4 #12 prepend 🟢 已修标注**

定位行 449 开头。

旧代码:
```markdown
12. **PAIRS 仅覆盖 2/5 实际互引**(audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单(grep 验证):...
```

新代码:
```markdown
12. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30,commit `<TBD>`)**:cross-ref hook PAIRS 数组从 4 条扩到 6 条,新增 `finishing-rules.md|## 反模式约束`(覆盖 design L28+L45 间接引用)+ `design-rules.md|"轻量级"判定`(覆盖 finishing L38 间接引用),实际 4 处互引全覆盖(原 audit 误判 5 处,重审实测 4 处,详 spec 2026-04-30 §9.4 #25)。原识别保留作历史记录:**PAIRS 仅覆盖 2/5 实际互引**(audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单(grep 验证):...
```

- [ ] **Step 4.3: 验证 #10 + #12 标注完整**

```bash
grep -nE '^1[02]\.\s\*\*🟢 已修' harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md
```
预期:输出两行 — #10 + #12 都 prepend `🟢 已修`。

- [ ] **Step 4.4: Commit**

```bash
git -C /d/个人/harness add harness/docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md
git -C /d/个人/harness commit -m "$(cat <<'EOF'
docs(p0.9.3-trial2): spec §9.4 #10 + #12 标 🟢 已修

P0.9.3 第一个 trial spec §9.4 #10(M3/M4 路径混淆)+ #12(PAIRS 覆盖度
2/4 不足)由本 trial 关闭。原 finding 文字保留作历史记录,prepend 闭合
说明 + 引 spec 2026-04-30 / governance §7.3 / Task commit。

注:#12 原 audit "5 处" 经第三次 grep 重审为 4 处(spec 2026-04-30 §9.4 #25
留痕);本次扩 6 条 PAIRS 覆盖 4 处实际互引。
EOF
)"
```

---

## Task 5: P0.9.3 decision file §已知缺口 #10 + #12 同步措辞

**Files:**
- Modify: `harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md:159`(#10)
- Modify: `harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md:161`(#12)

- [ ] **Step 5.1: 改 §已知缺口 #10**

定位行 159。

旧代码:
```markdown
10. **M3/M4 路径混淆**(spec §9.4 #10;audit D2-F3 + D3-F1 + D4-F6 共识):hook 输出 `CLAUDE.md` 字面对应 M3 / M4 两文件;covers 比对精度受限;推 P0.9.4;**推后窗口期接受机制**:调度者人工记忆 + handoff 显式标注规避
```

新代码:
```markdown
10. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30)**:hook §5.5 加 `<root>/` sentinel 前缀;audit covers 约定 M3 用 `<root>/CLAUDE.md` / M4 用 `CLAUDE.md`;原识别保留作记录:**M3/M4 路径混淆**(spec §9.4 #10;audit D2-F3 + D3-F1 + D4-F6 共识):hook 输出 `CLAUDE.md` 字面对应 M3 / M4 两文件;covers 比对精度受限
```

- [ ] **Step 5.2: 改 §已知缺口 #12**

定位行 161。

旧代码:
```markdown
12. **PAIRS 仅覆盖 2/5 实际互引**(spec §9.4 #12;audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单 5 处(L28 / L3 / L5 / L14 / L45);PAIRS 实际只覆盖 2 处 + 同行重复;本 trial 选 B 显式承认
```

新代码:
```markdown
12. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30)**:cross-ref PAIRS 4 → 6 条,扩 finishing `## 反模式约束` + design `"轻量级"判定` anchor,实际 4 处互引全覆盖(audit 原 5 处 经重审实为 4 处;详 spec 2026-04-30 §9.4 #25 留痕);原识别保留:**PAIRS 仅覆盖 2/5 实际互引**(spec §9.4 #12;audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单 5 处;PAIRS 实际只覆盖 2 处 + 同行重复
```

- [ ] **Step 5.3: 验证标注**

```bash
grep -nE '^1[02]\.\s\*\*🟢 已修' harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md
```
预期:两行命中(#10 + #12)。

- [ ] **Step 5.4: Commit**

```bash
git -C /d/个人/harness add harness/docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md
git -C /d/个人/harness commit -m "$(cat <<'EOF'
docs(p0.9.3-trial2): decision file §已知缺口 #10 + #12 同步标 🟢

P0.9.3 第一个 trial decision file §已知缺口 #10 + #12 与 spec §9.4 同步
标 🟢 已修;闭合说明引 spec 2026-04-30 §3.1 + §9.4 #25(三次审查留痕)。
EOF
)"
```

---

## Post-Implementation: 进入 meta-finishing 阶段

> 实现期(Task 1-5)完成后,进入 `meta-finishing-rules.md` 四步:
> 1. **Step A** scope 判断 → meta(本 trial 命中 B 组 hooks + A 组 governance)
> 2. **Step B** 触发 meta-review fork(N 挑战者,按 spec §6.1 维度分配 — 评估 sentinel 协议正确性 / PAIRS 完备性 / inline 验证充分性 / spec 措辞 / RUBRIC 对齐)
> 3. **Step C** 立 decision 文件(`docs/decisions/2026-04-30-d-class-tech-debt-batch.md`)
> 4. **Step D** 通用同步(decision-trail.md append + ROADMAP 闭合 + handoff 更新 + audit 入仓 + 删 handoff `## meta-review/cross-ref: skipped` 字段)

实施完成的标志:
- [ ] Task 1-5 全部 commit 通过
- [ ] meta-L1 inline 5+ 场景全数验证(scenario 1-5/8 in Task 1, scenario 6-7 in Task 2)
- [ ] 8 测试场景全数详 spec §6.1 — 实跑 7 个(scenario 4-5 含 audit fixture 所以可跑;R1 真实路径 scenario 8 走 R2 替代)
- [ ] handoff `## meta-review/cross-ref: skipped` 字段在实现期生效,finishing 阶段 audit 写出后**移除**两字段

不在本 plan 范围(由 finishing 阶段处理):
- decision file 立档
- decision-trail.md append
- ROADMAP.md 闭合标记
- handoff.md 目标段 + Evidence Depth 段更新
- meta-review fork(audit 产出)

---

## 关联

- **spec**:`docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md`
- **依赖 commit**:`0e8283d`(D5 .gitignore 精确化)
- **上游 trial**:P0.9.3 第一个 trial(2026-04-29,commit `c0810e8`)
- **后续**:meta-finishing 阶段产 `docs/audits/meta-review-2026-04-30-...md` + `docs/decisions/2026-04-30-d-class-tech-debt-batch.md`

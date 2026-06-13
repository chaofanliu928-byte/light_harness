# 治理同层化迁移基线留痕(工作文件,批 5 任务 20 git rm)

> 协议:plan 全局契约 G2(spec §4.1-10)。本件含旧工具名/旧术语属预期——批 5 在 V4 断链核前删除。

## 基线 commit
- 基线 HEAD: 671717763041e41d2f3e449190a58f51975a155c(= plan 入库 commit 6717177)
- 批 1 首个实施 commit: 本 commit(credentials-rules.md 新件,与本登记簿回填同 commit)——V8 covers 汇编起点

## 基线全窗对账输出(旧工具 check-meta-review.sh --reconcile 99999,逐字粘贴)

```
—— meta-review 对账(--reconcile)——
窗口起点: 近 99999 天(显式参数)
欠账:近窗 58 件 scope 改动,有效 audit 16 份,未覆盖 25 件:
  - .claude/agents/design-reviewer.md
  - .claude/agents/designer.md
  - .claude/agents/evaluator.md
  - .claude/agents/process-auditor.md
  - .claude/agents/security-reviewer.md
  - .claude/hooks/check-finishing-skills.sh
  - .claude/hooks/check-meta-commit.sh
  - .claude/hooks/check-meta-cross-ref-commit.sh
  - .claude/hooks/check-module-docs.sh
  - .claude/hooks/meta-self-review-detect.sh
  - .claude/hooks/notify-done.sh
  - .claude/skills/design-review/SKILL.md
  - .claude/skills/evaluate/SKILL.md
  - .claude/skills/security-scan/SKILL.md
  - .claude/skills/session-search/SKILL.md
  - .claude/skills/skill-extract/SKILL.md
  - .claude/skills/system-design/SKILL.md
  - docs/governance/brainstorming-rules.md
  - docs/governance/implementation-rules.md
  - docs/governance/model-route.md
  - docs/governance/planning-rules.md
  - docs/governance/review-rules.md
  - docs/governance/synthesis-rules.md
  - docs/governance/testing-rules.md
  - docs/references/DESIGN_TEMPLATE.md

处理:对上述文件补 meta-review,产出
  docs/audits/meta-review-YYYY-MM-DD-HHMMSS-[主题].md
  (YAML frontmatter:meta-review: true + covers 逐项列出;root 级文件写 <root>/<path>)
注:对账不认 handoff 的 meta-review: skipped 字段(skip 只豁免 Stop 执法,不豁免已提交欠账)
```

注:未覆盖 25 件 = covers 执法上线(2026-04-28)前的存量提交(其中 6 件已被后续剪枝批物理删除,git log 全窗仍列名属预期);有效 16 份 = 21 份凭证中未被后续提交失效者。此即 G2 对照的左侧基线。

## 预期 delta 登记(基线后、迁移对照前的治理面提交)
- docs/governance/credentials-rules.md(批 1 任务 2,1a60329,批内新增欠账——预登记)
- .claude/hooks/check-audit-coverage.sh(批 2 工具改名,745c03c)
- .claude/hooks/credentials.conf(批 2 conf 改名,745c03c)
- setup.sh(批 2 分发改造,fc85321+c9b7d9c)
- <root>/AGENTS.md / <root>/CLAUDE.md / templates/AGENTS.md(批 2 命令行三处,745c03c)
- check-meta-cross-ref.sh(批 2 删除,745c03c——出欠账名单)
- 注:21 件 docs/audits/meta-review-*.md 字段迁移命中 conf **排除行**,不入凭证义务,不增欠账

## spec 漏列留痕(批 2 审查发现)
- setup.sh L48 注释残留 `meta-review(scope=meta)` 旧术语,不在 spec §4.3 四点也不在任务 17 件号清单(spec 枚举漏列)。批 2 任务 8 审查识别+给 G1 改法,顺手补于 fc85321 后小 commit;批 5 V4 断链核复验(setup.sh 属活层,九术语零命中即闭)。

## 洗活欠账归因(批 2 任务 9 填写)

对照:基线 25 件未覆盖 → 迁移后 22 件未覆盖。差集 = 缩小 7 件 − 预期 delta 新增 4 件;算术 25 − 7 + 4 = 22 ✓。

**缩小集合 7 件逐件归因**(均"曾被 audit covers、后因新提交失效、迁移刷新凭证 commit time 重新洗活";每件命中 audit covers 数已实查):

| 文件 | 被 N 份 audit covers | 归因结论 |
|---|---|---|
| .claude/hooks/check-meta-commit.sh | 4 | 既存欠账(历史删除件,git log 全窗列名),迁移洗活 |
| .claude/hooks/check-meta-cross-ref-commit.sh | 3 | 同上 |
| docs/governance/implementation-rules.md | 1 | 既存欠账,迁移洗活 |
| docs/governance/model-route.md | 2 | 同上 |
| docs/governance/planning-rules.md | 1 | 同上 |
| docs/governance/synthesis-rules.md | 5 | 同上 |
| docs/governance/testing-rules.md | 1 | 同上 |

**abort 判据:无一无法归因 → 不 abort,准进批 3。** 7 件全部命中 audit covers,洗活机制成立(迁移 commit 把 21 份凭证 commit time 刷到批 2 时刻,使"covered 文件 commit time ≤ audit commit time"重新成立)。

**V7 账面快照**:有效凭证 16(基线)→ 20(迁移后)份,exempt 0;洗活效果使 4 份原失效凭证重新生效(21 份中 20 有效,余 1 份其 covers 含批内更晚提交件如 setup.sh)。标题"凭证覆盖对账"✓。

**G3 默认窗锚留痕**:迁移后默认窗锚 = 最新正式 audit commit time = 批 2 迁移时刻(@1781322100),默认窗只见近 8 件 → 批 2-5 一切对账必带 `--reconcile 99999`(全窗纪律),V8 落账后默认窗恢复。

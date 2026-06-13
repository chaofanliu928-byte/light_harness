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
- docs/governance/credentials-rules.md(批 1 任务 2,批内新增欠账——预登记)
<执行中新增的治理面提交随手 append;批 2 提交集合由任务 9 在对照前 append>

## spec 漏列留痕(批 2 审查发现)
- setup.sh L48 注释残留 `meta-review(scope=meta)` 旧术语,不在 spec §4.3 四点也不在任务 17 件号清单(spec 枚举漏列)。批 2 任务 8 审查识别+给 G1 改法,顺手补于 fc85321 后小 commit;批 5 V4 断链核复验(setup.sh 属活层,九术语零命中即闭)。

## 洗活欠账归因(批 2 任务 9 填写)
<缩小集合逐件:文件 | 覆盖它的凭证 | 失效时点证据(git log -1 --format=%ci)| 归因结论>

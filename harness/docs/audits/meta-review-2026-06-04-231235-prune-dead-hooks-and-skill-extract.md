---
meta-review: true
covers:
  - harness/.claude/hooks/check-finishing-skills.sh
  - harness/.claude/hooks/check-meta-commit.sh
  - harness/.claude/hooks/check-meta-cross-ref-commit.sh
  - harness/.claude/hooks/check-meta-cross-ref.sh
  - harness/.claude/hooks/check-meta-review.sh
  - harness/.claude/hooks/meta-scope.conf
  - harness/.claude/hooks/meta-self-review-detect.sh
  - harness/.claude/hooks/notify-done.sh
  - harness/.claude/settings.json
  - harness/.claude/skills/skill-extract/SKILL.md
  - harness/CLAUDE.md
  - harness/QUICKREF.md
  - harness/README.md
  - harness/docs/governance/finishing-rules.md
  - harness/docs/governance/meta-finishing-rules.md
  - harness/docs/governance/meta-review-rules.md
  - harness/setup.sh
  - harness/templates/README.md
  - harness/templates/settings.json
  - <root>/README.md
---

# Meta-Review Audit — 剪枝批次:删 5 死/冗余 hook + skill-extract + 治理诚实化(2026-06-04)

## 1. 元信息

- **batch name**:prune-dead-hooks-and-skill-extract
- **触发时间**:2026-06-04 23:12:35(本地)
- **改动 scope**:meta(B 组 hooks/settings + C 组 skill + A 组 governance/CLAUDE + F 组 setup/template)
- **改动规模**:删 5 hook(962 行)+ skill-extract(123 行)+ 14 文件改 + 1 decision + 本 audit;净 +45 / −1156
- **决策依据**:`docs/decisions/2026-06-04-prune-dead-hooks-and-skill-extract.md`(用户拍板:删死代码 + 删内容/治理诚实化,Route B)
- **审查模态**:删除批 → 3 挑战者(完整性+计数 / 安全性+JSON / 治理自洽+下游)
- **领审员**:调度者(主对话,Claude Opus)
- **设计来源**:独立 designer(Plan agent)穷尽扫描;领审员不自审自己的设计(公设 1)
- **属第三批剪枝**:继 N2(满意度)+ session-search 之后;本批含**功能层**(skill-extract)+ **基础设施层**(死 hook)+ **治理诚实化**(把从没运行过的 M16/M20 执法描述改实)

## 2. 删除内容 + 为什么

| 删 | 性质 | 为什么 |
|---|---|---|
| check-meta-commit.sh / check-meta-cross-ref-commit.sh(M16 孪生,619 行) | 死孪生 | git pre-commit 但 `.git/hooks` 未装、settings 未注册、setup.sh 不 wire → 从没运行;Stop 侧 check-meta-review/check-meta-cross-ref 已覆盖 |
| meta-self-review-detect.sh(M20,258 行) | 空转 nag | 绑死 2026-04 p0-9 spec,该 spec 早被反审 → 条件永假、永远静默 |
| notify-done.sh | 孤儿 | 两份 settings 都没注册 → 从不触发 |
| check-finishing-skills.sh | 软+冗余 | 交接新鲜度 check-handoff(硬)已管;唯一独有是提醒 skill-extract(本批也删) |
| skill-extract skill(123 行) | 0 产出 | 注册表从无提取出的新 skill;自承"不强求、无模式跳过";5.5 skill 不跨项目 |

**Route B 治理诚实化**:M16(pre-commit)+ M20(SessionStart nag)在 meta-finishing-rules / meta-review-rules 里被当**现行执法机制**描述,但它们从没运行过。本批把这些描述收口为"covers 检测仅由 Stop hook(M15)承担;pre-commit 孪生 / M20 已移除;反审待办由调度者读 covers 判定"——删掉一套"描述了但不存在的执法层"。

**保留不动**:check-meta-review / check-meta-cross-ref / check-handoff / check-evidence-depth / session-init / check-module-docs / meta-scope.conf;其它 7 个 skill(含 process-audit)。

## 3. meta-review 抓到、已修的真问题(3 挑战者全 pass-after-revision)

- 🔴 **memory 误删风险**:skill-extract 在 L44(L46 是要保留的 process-audit)——改用字符串匹配删,未碰 process-audit。
- 🔴 **M20 对称盲点**:designer + 2/3 挑战者都只收口了 M16,漏了 meta-self-review-detect=M20 在治理里的 8 处现行描述(第 3 挑战者抓到)。**已补全 M20 收口**(meta-finishing-rules 5 处 + meta-review-rules 3 处)。
- 🔴 **meta-scope.conf:3** 注释引用被删 M16 → 改"由 M15 check-meta-review.sh 读"。
- 🔴 **templates/README L8/L16** 引用被删 meta-self-review-detect + M18≡M19 SessionStart 连带 → 已同步;**L33 自检计数既存 -1 drift**:删后"应为 4"恰好变正确,**未机械减**;补全 L33/L34/L36 + L17 表(补回漏列的 check-meta-cross-ref)+ 维护规约。
- 🟡 **finishing-rules 重排**:删 skill-extract step 5 后 6-9→5-8,且 L86 交叉引用"step 9"→"step 8"。

## 4. 实现后校验(grep + jq 实证)

- 5 hook 名 + skill-extract:**LIVE 零残留**(skills/agents/governance/README/CLAUDE/QUICKREF/settings 全清);残留全在历史留痕(docs/{decisions,audits,specs,plans})+ 本 decision/audit + decision-trail 历史条目 + handoff(瞬时,留 finishing 刷新)。
- **`docs/governance` 里 M16 / pre-commit / M20 / 重新注入:0 命中** → 治理收口完整收敛。
- 技能计数全仓 →7;hook 下游分发计数 6→4;templates 自检计数按删后实测(Stop 4/2、SessionStart 1/1)。
- 两份 settings.json:**jq/node 校验合法**;SessionStart 1 / Stop 4(harness)、Stop 2(templates)。
- 保留 hook check-meta-review.sh / check-meta-cross-ref.sh **未被误删**(其内注释指向孪生的死引用已清)。

## 5. 终态

hook 从 11 .sh → 6 .sh(+meta-scope.conf);skill 8→7;harness 注册 SessionStart 2→1 / Stop 5→4。治理文档不再描述任何未运行的执法层——**covers 检测的唯一现行机制 = Stop hook(M15 check-meta-review)+ check-meta-cross-ref**,文档与现实一致。

## 6. 已知缺口 / 备注

- **commit-time 执法候选**:删 pre-commit 孪生后,"turn 中间 raw commit 绕过 Stop 门"的洞仍在(本会话多次 mid-turn commit 即如此),但两个月未被咬;按"边做边提升/防过度工程",记为**候选 feature**(真被咬到再正经落地:测试 + fail-loud,不是接回死孪生)。
- **handoff.md** 仍提被删 hook 的创建留痕——瞬时工作态文件,留下次 structured-handoff 刷新覆盖,不入本剪枝 diff。
- **memory** 同步(skill/hook 计数 + 删行)在用户主目录,不入 git commit;其 block-dangerous 等既存 stale 非本批根治。

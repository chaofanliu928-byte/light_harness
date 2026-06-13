---
audit: true
covers:
  - .claude/hooks/session-init.sh
  - .claude/hooks/check-evidence-depth.sh
  - .claude/hooks/check-meta-cross-ref.sh
  - .claude/skills/project-setup/SKILL.md
  - .claude/skills/structured-handoff/SKILL.md
  - .claude/skills/process-audit/SKILL.md
  - docs/governance/meta-finishing-rules.md
  - docs/RUBRIC.md
  - setup.sh
  - CLAUDE.md
  - <root>/CLAUDE.md
  - QUICKREF.md
  - README.md
  - docs/active/handoff.md
  - templates/handoff.md
  - templates/PROGRESS.md
  - templates/product-specs-index.md
  - <root>/README.md
  - <root>/.gitattributes
---

# Meta-Review Audit — 多智能体审查发现的确认 bug 修复批(2026-06-05)

## 1. 元信息

- **batch name**:audit-bugfix-batch
- **触发时间**:2026-06-05 18:40:52(本地)
- **改动 scope**:meta(B 组 hooks + C 组 skills + A 组 governance/CLAUDE + D 组 RUBRIC + F 组 setup;另含 scope=none 的 README/QUICKREF/handoff/templates/.gitattributes)
- **决策依据**:`docs/decisions/2026-06-05-audit-bugfix-batch.md`(用户拍板"修复")
- **来源**:两轮多智能体审查(全仓审查 33 agent + 令牌契约专扫 23 agent),每条 finding 经独立对抗验证(字节级复现)
- **设计来源**:独立 designer(Plan agent)出逐文件精确改法;领审员(调度者)不自审自己的设计(公设 1)
- **审查模态**:改法 meta-review → 4 挑战者扁平 fork(A+B 字节契约/grep 窗口 / C 簇分发模板 / E 簇行号+落点+同步 / scope+开放决策)
- **gawk 提示**:本机 GNU Awk,check-meta-review.sh 的 extract_covers(三参数 match)可正常运行 → 本 audit 的 covers 会被真实执法,故 covers 已按 hook 实际 `git diff --relative`(cwd=harness/)输出的相对路径 + `<root>/` sentinel 精确填写

## 2. 修了什么 + 为什么(按簇)

| 簇 | 内容 | 落点 |
|---|---|---|
| **A** | RUBRIC 占位符令牌静默失效(一根因两落点) | session-init.sh:17 + project-setup/SKILL.md:20 的 `\[用2-3句话\]`(无空格)改 `\[用 2-3 句话`(对齐 RUBRIC.md:64 实际两半角空格) |
| **B** | Evidence Depth / CI 阻断 字段契约 | structured-handoff/SKILL.md 模板补两节 + meta-finishing-rules §4.2 三示例补 CI 阻断 + §4.4 描述改两字段 + check-evidence-depth.sh 加 stop_hook_active 防死循环守卫 |
| **C** | 分发污染(下游收 harness 私货 + 死链) | 新建 templates/{handoff,PROGRESS,product-specs-index}.md 干净模板;setup.sh 三处 cp 改指向模板(index 目标写**全路径** docs/product-specs/index.md);harness 自仓库三真实文件不动 |
| **D** | CRLF/换行 | 新建根 .gitattributes(`*.sh/*.conf/*.md/*.json` eol=lf);顺带封死 park 的 CRLF |
| **E** | drift 清理(~12 处) | README/QUICKREF hook 计数补 check-evidence-depth、governance 计数补 testing、QUICKREF/CLAUDE `||` 表格拆分 + 补 process-audit、setup.sh M16/M20 注释收口、designer 含自检陈旧注释、根 CLAUDE §2/§5 补 synthesis/model-route + 清 block-*/notify- 死引、RUBRIC 技术方向权重行、process-audit 触发顺序、check-meta-cross-ref 注释行号 L39→L41 |
| **自锁修复** | 本批 finishing 自锁 | harness 自仓库 handoff.md 补 `## CI 阻断` 实值(否则 check-evidence-depth 拦本批收尾) |

**park(本批不动)**:#2 security-reviewer look-ahead 漏扫(用户明示);#3/#5 check-meta-review gawk 三参数 + bash 3.2 空数组(自仓库潜伏、本机不咬;#6 CRLF 由 D 簇 .gitattributes 顺带覆盖)。

## 3. meta-review 抓到、已修的真问题(4 挑战者全 pass-after-revision)

- 🔴 **grep 窗口新坑(本批硬前提"别一边修一边引新坑"逮个正着)**:designer 给 handoff 补的占位用"标题/空行/[待填]"布局,但 hook 是 `grep -A 1 "## CI 阻断"`(只看后 1 行)→ 空行把 `[待填]` 挤出窗口 → **未填被静默放过**(等于换种方式复刻原 bug)。**已改:占位紧贴标题、不空行**(B 簇模板 + C 簇模板字节同款)。
- 🔴 **index 模板文件名陷阱**:模板改名 product-specs-index.md 后,setup.sh cp 目标若只写目录,下游文件名变 product-specs-index.md → CLAUDE.md 索引死链。**已改:cp 目标写全 `docs/product-specs/index.md`**。
- 🔴 **自仓库 handoff 缺 `## CI 阻断`**:本批 finishing 会被自己的 hook 拦。**已补**。
- 🔴 **covers 须同列 M3+M4 两个 CLAUDE**:`<root>/CLAUDE.md`(M3,§2/§5 改)+ `CLAUDE.md`(M4,L109 改),漏一即被 §5.5 拦。**已双列**。
- 🟡 **E10 行号**:designer 前提"L24-27 全过期"是错的——design-rules 的 L24-25(L38/L45)本就对,只 finishing-rules 的 L26-27(L39→L41)漂。**已只改 L26-27**。
- 🟡 **E1 不是改数字而是补 hook**:两份枚举真正漏的是 check-evidence-depth.sh(根 README"4 个"本就对、不动)。**已补行**。
- 🟡 **B2 ➖ 违反 SSoT**:testing-standard.md CI 阻断只允许 ✅/❌。**meta 示例改用 ❌**(不用 ➖)。
- 🟡 **E5 最小变更**:setup.sh:74-75 只改注释文字、保留 case 过滤逻辑;L75 保留现行 hook 归属(去 M16)。**已照做**。
- 🟢 顺手清根 CLAUDE §5 B 组 block-*/notify- 死引用(同文件同节,零额外 scope)。

## 4. 实现后校验(真 grep 实证)

- **A 簇**:`grep -q "\[用 2-3 句话" RUBRIC.md` 命中(exit 0,检测可工作);旧锚 `\[用2-3句话\]` 不命中(确认原 bug 已修)。
- **B/C 簇 grep 窗口**:templates/handoff.md + structured-handoff 模板,`grep -A 4 "## Evidence Depth" | grep -q "\[待填\]"` 命中、`grep -A 1 "## CI 阻断" | grep -q "\[待填\]"` 命中(去空行后占位都落进窗口、能被 hook 检到 → 种子正确强制填写)。
- **B4**:check-evidence-depth.sh 含 `INPUT=$(cat)` + `stop_hook_active` 守卫。
- **`||` 压扁**:harness/CLAUDE.md + QUICKREF.md 实测 0 残留;process-audit 已现身两表。
- **setup.sh**:三 cp 指向 templates/、index 全路径;注释 M16/M20 0 残留。
- **root CLAUDE**:synthesis-rules/model-route 各 2 处(§2 callout + §5 bullet);block-*/notify- 0 残留。
- **check-meta-cross-ref**:`finishing-rules.md L41` ×2、`L39` ×0。
- **process-audit / RUBRIC 技术方向 / harness README**(check-evidence-depth + testing-rules + designer 修正):各命中。
- **covers 格式**:已跑 hook 同款 `git diff --relative` 确认 11 个 in-scope 文件的精确相对路径 + `<root>/CLAUDE.md`,covers 逐字匹配。

## 5. 终态

两轮审查共确认的可修项全部修复;实现中由 meta-review 拦下 4 个 🔴(其中 grep 窗口、index 文件名两处是"修一引一"的新静默 bug,自锁、covers 漏列两处是流程自洽问题)→ 全部修订。新增 4 文件(3 模板 + .gitattributes)、改 14 文件。

## 6. 已知缺口 / 备注

- **三个新 .md 模板 scope=none**:F 组 glob 是 `templates/*.json`,templates/*.md 不命中 → 这三模板今后改动不受 meta 治理。本批守最小变更**不扩 glob**,记为已知治理缺口(将来若要纳入,扩 F 组 glob 为 `templates/*` 需同步 meta-scope.conf + CLAUDE §3/§5,本身又是一次 meta 改动)。
- **park 项**:#2 security-reviewer look-ahead、#3/#5 check-meta-review gawk+bash3.2 未动(用户决定 / 自仓库潜伏)。**注:#3 gawk 三参数 match 仍在 check-meta-review.sh** —— 本机 gawk 可跑,故本 audit 的 covers 执法有效;但该 hook 在 mawk/BSD awk 机器上仍会死锁,是独立的待办(非本批 scope)。
- **commit 时**:本批未提交(待用户触发)。提交时建议 `git add --renormalize .` 让 .gitattributes 生效(当前 index 已 LF,主要钉死未来 + 规整工作树 CRLF 三文件)。
- **testing-standard.md SSoT 布局**:其示例仍用"标题+空行+值"(L73-84),与本批模板"无空行"布局有细微差异;模板的无空行是为满足 hook grep 窗口,功能优先,未改 SSoT(避免扩 scope)。
- **experience-index.md**:meta-review 附带发现它也下发一条 harness 内部 decision 路径引用(轻度私货),本批 C 簇限定三文件未纳入,记为后续顺手项。

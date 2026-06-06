---
meta-review: true
covers:
  - .claude/settings.json
  - templates/settings.json
  - docs/governance/finishing-rules.md
  - docs/governance/meta-review-rules.md
  - setup.sh
  - CLAUDE.md
  - <root>/CLAUDE.md
  - .claude/skills/project-setup/SKILL.md
  - .claude/hooks/check-context-chain.sh
  - templates/context/L1-vision.md
  - templates/context/L2-INDEX.md
  - README.md
  - QUICKREF.md
  - <root>/README.md
  - <root>/.gitattributes
  - docs/active/handoff.md
  - templates/context/README.md
  - .claude/skills/structured-handoff/SKILL.md
  - .claude/hooks/session-init.sh
  - templates/handoff.md
---

# Meta-Review Audit — 分层活上下文链(L1-L6 脊柱版)(2026-06-05)

## 1. 元信息

- **batch name**:living-context-chain-spine
- **触发时间**:2026-06-05 20:41:25(本地)
- **改动 scope**:meta(B 组新 hook + settings / C 组 project-setup / A 组 finishing-rules+meta-review-rules+CLAUDE / F 组 setup+templates/settings;另含 scope=none 的 README×2/QUICKREF/templates/context、.gitattributes)
- **决策依据**:`docs/decisions/2026-06-05-living-context-chain.md`(L1-L6 脊柱版,用户拍板脊柱 + 薄版 L5/L6 + 同意 meta-review 修正)
- **设计来源**:独立 designer(Plan agent)出逐文件方案;领审员(调度者)不自审自己的设计(公设 1)
- **审查模态**:设计 meta-review → 4 挑战者扁平 fork(编码+软/硬hook 稳健 / 过度工程剂量 / 整合分发完整性 / 契约自洽别引新脆弱)
- **与 audit-bugfix 批共存**:两批均未提交,工作区共存。本 audit covers 含本批 in-scope 改动;`docs/audits/meta-review-2026-06-05-184052-audit-bugfix-batch.md` 覆盖 audit-bugfix 批。**两 audit covers 并集覆盖全部当前未提交 in-scope 文件**(已 grep -Fxq 实证)。
- **gawk 提示**:check-context-chain.sh 用 POSIX awk(match()+RSTART/RLENGTH/substr,**禁** gawk 三参数 match),已用 `gawk --posix` 代理 mawk/BSD 实测通过 — 不重蹈 check-meta-review.sh:278 的坑(该坑 park 为 audit-bugfix #3/#5)。

## 2. 建了什么(脊柱 L1-L6 活上下文链)

| # | 文件 | 内容 |
|---|---|---|
| 新 | `.claude/hooks/check-context-chain.sh` | 软收尾 + 硬收口 Stop hook(见 §3) |
| 新 | `templates/context/L1-vision.md` / `L2-INDEX.md` | 下游脚手架 2 个种子(剂量轻:默认 L1+L2,L3-L6 随开发长) |
| 改 | `.claude/settings.json` + `templates/settings.json` | Stop 数组注册 check-context-chain.sh(自仓库 + 下游双轨) |
| 改 | `setup.sh` | mkdir docs/context + cp 2 种子(L3-L6 子目录不预铺空壳) |
| 改 | `docs/governance/finishing-rules.md` | 加「收口硬核链」节(feature 路径,方向评估之前) |
| 改 | `docs/governance/meta-review-rules.md` | §6 加「触点完整性」维(A 段可选,最小解,带 D7 正交留痕) |
| 改 | `CLAUDE.md`(M4)+ `<root>/CLAUDE.md`(M3) | M4 文档索引+核心规则 10;M3 加 dogfood 边界 |
| 改 | `README.md`(根+harness)+ `QUICKREF.md` | §4.1 后另起"分层活链"bullet(不计入 5 产物)+ hook 计数 4→5 + hook 树/速查表 |
| 改 | `.claude/skills/project-setup/SKILL.md` | 阶段四起步填 L1+L2;阶段五标注 context/ 待定合法 |

**编码**:`L<层>-<类型><序号>`(进文件名,编码即稳定 ID,slug 改不断链,不建 registry)。**链接**:frontmatter `upstream: [编码]`(机读非 grep,半角)。**方法带**不单独编码,折进 L3。**L5/L6 薄版**:真实代码/测试为主体 + 薄挂链节(记 why/验证/测试策略,不抄代码)。**自仓库不建 context/**(dogfood 边界,用 README 当 vision + 最小解触点维)。

## 3. check-context-chain.sh 双道语义

- **软(常态 Stop)**:断链(upstream 编码 ∉ 已有编码)/ 编码冲突 / 疑似全角 → stderr warning + **exit 0**(不阻断发散)。
- **硬(收口)**:`docs/active/evaluation-result.md` 存在(finishing)且 docs/context/ 在场时,handoff 必须含 `## context-chain: 已核(...)` 或 `## context-chain: skipped(理由: ...)`,否则 **exit 2**。真正链核由 AI 按 finishing-rules「收口硬核链」做;hook 只机械逼"显式声明"(与 meta-review 必须有 audit 文件同套路)。
- **剂量轻**:无 docs/context/ → exit 0 静默(小探索项目零打扰);`待定`/`[]` 放行。
- **守"别重蹈"清单**:POSIX awk / 字节精确(全角告警)/ find 递归(非 ** glob)/ stop_hook_active 安全带 + 先 INPUT=$(cat) / LF(.gitattributes 覆盖)。

## 4. meta-review 抓到、已修的真问题(4 挑战者全 pass-after-revision)

- 🔴 **软+硬两道都不机械拦 → 链可被无限忽略烂成垃圾(用户点名最怕的)+ 违 harness 立身原则**。**已修**:硬收口加机械牙齿——check-context-chain.sh 在收口时逼 handoff 写 `## context-chain: 已核/skipped` 声明(无则 exit 2),真核仍由 AI 做,但"核没核"机械可查。
- 🔴 **全角符号静默漏解析(A 簇同源坑复发)**:中文 IME 全角 `［］：，｜` 让 awk 抓空 upstream → 不报断链(暗着烂)。**已修**:hook 加"疑似全角"告警 + 模板/finishing/CLAUDE 核心规则写死"只用半角"。
- 🔴 **C.4 awk 自相矛盾(承诺状态机给的是裸行匹配)+ upstream 数组解析无范式**。**已修**:hook 用真 frontmatter 状态机(`---` 起 / 第二个 `---` 止)+ 纯 bash 拆 `[a,b]` 数组,均 fixture 实测。
- 🟡 **软 hook 过度(自造 L2 表格行解析 + 层号方向校验两处脆弱契约)**。**已修**:软 hook 瘦身只留编码唯一 + 断链;表格行解析砍掉(行级精确挂靠靠拆 L2-F<n> 文件 / AI 核);方向校验移到硬收口。
- 🟡 **C.3 bash `**` glob 漏扫子目录 → 假断链**。**已修**:用 `find docs/context -type f -name '*.md'`(递归),fixture case 7 实证子目录 L5 被收集、无假断链。
- 🟡 **README 触点漏改(讽刺:它就是修"别断链"的)**:§4.1"5 产物"加第 6 个工件却不改计数 / hook 计数 4 未更新。**已修**:另起独立 bullet 显式注明"不计入 5 产物";根 README hook 计数 4→5;harness README hook 树补 check-context-chain。
- 🟢 L5 验证证据指针标"finishing 回填"、触点维选用指引、O(n) 全扫留意——已采纳措辞/留痕。

## 5. 实现后校验(fixture + 真 grep 实证)

- **hook 9 场景 fixture 全过**:① 无 context 放行 ② 净链无警告 ③ 断链软警告 ④ 待定放行 ⑤ 编码冲突警告 ⑥ 全角告警 ⑦ 子目录递归无假断链 ⑧a 硬收口无声明 exit2 / ⑧b 已核放行 / ⑧c skipped 放行 ⑨ stop_hook_active 安全带 exit0。
- **POSIX awk 实证**:`gawk --posix` 跑 extract_field 正确取 frontmatter code、忽略正文假 code;数组拆分对。`grep` 确认无 gawk 三参数 match(仅注释提及禁用模式)。
- **两份 settings jq 合法**:harness Stop 5 hook(含 check-context-chain)/ 下游 Stop 3 hook。
- **setup.sh**:mkdir docs/context + cp 2 种子(L1-vision/L2-INDEX),就位。
- **covers 并集**:跑 hook 同款 `git diff --relative` 得 15 个未提交 in-scope;本 audit + audit-bugfix audit 经 grep -Fxq 验证**全覆盖**(本批补齐 settings.json/templates/settings.json/finishing-rules/meta-review-rules 4 个新 in-scope)。

## 6. 终态 + 已知缺口

- 脊柱 L1-L6 活链落地:1 新 hook(软+硬)+ 2 种子模板 + 下游脚手架 + 治理(收口硬核链 + 触点完整性维)+ README/CLAUDE/QUICKREF 文档 + project-setup 起步。harness 自仓库不建 context/(dogfood 边界)。
- **templates/context/*.md scope=none**:F 组 glob 是 `templates/*.json`,2 个 .md 种子不命中 → 今后改不受 meta 治理。本批守最小变更**不扩 glob**,记为已知治理缺口(将来要纳管需扩 `templates/*` + 同步 meta-scope.conf + CLAUDE §3/§5)。
- **check-context-chain.sh 为新 untracked 文件**:本次 git diff 看不到 → 不入 CHANGED_META_FILES(check-meta-review 不强制 demand),但已列 covers 留痕;提交后它入库,下次改它走 meta-review。
- **新 hook 当次不生效**:settings.json 改动要下个 SessionStart 才加载,本批当次 finishing 不被 check-context-chain 影响(反而保证本批可收尾)。
- **L6 默认并入 L5**(测试策略 ≤3 行且无独立 upstream 不单建)、**触点完整性维放 A 段可选**(decision 原话"必查维",本实现为守轻降为按主题选用,已留痕)。
- 两批(audit-bugfix + spine)均未提交,待用户触发;提交时 `git add --renormalize .` 让 .gitattributes 生效。

## 7. 本批后续补全(半接线 + 孤悬剪枝,同会话)

孤悬审计(11 agent,逐条对抗证伪)后,补全脊柱的 3 个半接线 + 剪枝 2 个孤悬:

- **#1 handoff 缺 context-chain 字段**(产出方补):`templates/handoff.md` + `structured-handoff/SKILL.md` 模板加 `## context-chain: 待填(...)` 占位栏。实测占位符**不误满足** hook 的 `(已核|skipped)` grep(收口仍逼真填),真填 `已核(...)`/`skipped(理由:...)` 才放行。
- **#2 L3-L6 下游格式指南**(操作知识补):新建 `templates/context/README.md`(一页:六层目录/编码 + frontmatter + L5/L6 薄节字段 + 软/硬两道),setup.sh 加 cp 分发。端到端重跑 setup:下游 `docs/context/` = README + L1-vision + L2-INDEX。
- **#3 降级 banner 消费方缺**(消费方补):`session-init.sh` 加分支——最近设计文档 head 含 `降级执行`/`待修订` → echo 提醒重 fork(兑现 design-rules「Fork 失败降级」承诺的消费方)。
- **孤悬剪枝**:删 `experience-index.md`(空索引+白分发+冗余 decision-trail)+ `retrospective-guide.md`(复盘无流程入口);setup.sh 删 cp、_TEMPLATE 去引用。详见 `docs/decisions/2026-06-05-prune-orphans.md`。LIVE 区零残留断引。

> 补全后脊柱闭环:L1/L2 端到端通 + L3-L6 有下游格式指南(原 partial 升 wired)+ handoff 字段产出/消费对齐 + 降级 banner 两端接齐。

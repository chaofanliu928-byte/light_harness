# 决策: 修复多智能体审查发现的确认 bug(批次)

**状态**:🟢 已决定(用户拍板"修复",2026-06-05)

**日期**:2026-06-05

**关联功能**:harness 自治理质量 / 分发正确性(meta-scope 修复批)

**类型**:bug 修复批(非新增机制)

---

## 背景

用户要求"建立多智能体翻项目审查"。跑了两轮 workflow(全仓审查 33 agent + 令牌契约专扫 23 agent),每条发现都过**独立对抗验证**(字节级复现)。本决策只收**confirmed、非历史留痕、非 drop**的项,合成一个修复批。

两轮共同教训:多处机制是**脆弱的字面/编码契约,环境或文本一漂就静默失效**(grep 令牌、gawk 扩展、CRLF、产出/消费字段)——与"活上下文链"meta-review 得出的设计约束同源。

## 决定:修这些(按簇)

### A 簇 — RUBRIC 占位符令牌 bug(一根因,两落点,均下发下游)
- `session-init.sh:17` 搜 `[用2-3句话]`(无空格);`project-setup/SKILL.md:20` 同串。但 `RUBRIC.md:64` 实际是 `[用 2-3 句话`(半角空格)。grep 永远不命中。
- 后果:session-init 静默漏报"RUBRIC 未配置";project-setup 配置向导**反向假阳**——空白方向盘却输出 `✅ 已配置`。
- 两处消费者必须同步改(同一契约串)。

### B 簇 — Evidence Depth / CI 阻断 字段契约(产出方缺、消费方硬要)
- 消费方 `check-evidence-depth.sh` 收尾硬性要求 handoff 含 `## Evidence Depth` + `## CI 阻断` 两节,缺则 exit 2。
- 产出方不全:`structured-handoff/SKILL.md` 模板两节都没有(下发);`meta-finishing-rules.md` 示例+§4.4 只提 Evidence Depth、漏 CI 阻断(自仓库);下发的 handoff 种子缺 CI 阻断。
- 同时修配套缺陷:`check-evidence-depth.sh` 缺 `stop_hook_active` 防死循环安全带(四个 Stop hook 里唯一缺的,下发)。

### C 簇 — 分发污染(下游收到 harness 私货)
- `setup.sh` 把 `product-specs/index.md` / `PROGRESS.md` / `docs/active/handoff.md` 当种子下发,内容是 harness 自己的 P0.9 进度/meta-review 历史/commit hash + 死链(指向不分发的 spec)。
- 改为下发**干净空模板**(harness 自仓库保留自己的真实文件)。

### D 簇 — CRLF/换行(一个 `.gitattributes` 收口)
- `check-meta-review.sh` + `meta-scope.conf` 为 CRLF;下游 hook 存在 chmod×CRLF 潜在交叉。
- 加 `.gitattributes`(`*.sh text eol=lf` / `*.conf text eol=lf` 等)+ renormalize。**顺带修掉 park 的 CRLF 问题**。

### E 簇 — drift 清理(纯文档,不影响运行,~12 处)
两份 README hook 计数(3/4)、governance 计数(6/7 漏 testing)、QUICKREF Skill 表漏 process-audit、`setup.sh:74` 注释引用已删 M16/M20、README+QUICKREF "designer 含自检子智能体"陈旧注释、根 CLAUDE.md §2/§5 漏列 synthesis-rules/model-route、RUBRIC §三技术方向缺权重行、process-audit SKILL.md:3 触发顺序写反、`harness/CLAUDE.md:109` + `QUICKREF.md:45` 的 `||` 表格压扁、check-meta-cross-ref.sh:24-27 注释行号过期。

## 不做(park)
- **#2** `security-reviewer.md:158` 的 ripgrep look-ahead 漏扫(用户明示不管)。
- **#3/#5** `check-meta-review.sh` 的 gawk 三参数 match + bash 3.2 空数组(自仓库、潜伏、当前机器不咬;**#6 CRLF 由 D 簇 .gitattributes 顺带修**)。

## 硬前提(修复时守)
- 改令牌契约**两端必须字节一致**(改 hook 串就对齐 RUBRIC 实际字节,或改成更稳的锚;补 handoff 模板节就字节匹配 hook 的 grep)。**别一边修出另一处新错配**。
- bug 修复**最小变更**,不顺手加机制(不碰 park 项的功能改造)。
- 全 meta-scope → 走 meta-review;audit 的 covers 必须列全本批所有改动文件(否则被 check-meta-review 拦——本批正好 dogfood 它)。

## 后续
fork 独立设计者出逐文件精确改法(行号级 + 解决:A 用什么稳健锚、B 节放哪儿字节怎么写、C 干净模板装什么、E 逐条精确编辑)→ fork 挑战者 meta-review(对抗:有没有漏落点、改法会不会引新错配、行号准不准、drift 改全没)→ 调度者综合给用户签字 → 实现 → audit → finishing。

## 关联
- 审查产出:本会话两轮 workflow(全仓审查 + 令牌契约专扫,均逐条对抗验证)
- `decisions/2026-06-04-prune-*`(同类 meta 批次流程)
- `decisions/2026-06-05-living-context-chain.md`(同源教训:脆弱契约静默失效)

**签署**:用户 + Claude(调度者)

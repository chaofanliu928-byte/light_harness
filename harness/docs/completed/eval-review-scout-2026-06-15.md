# 方向评估结果:review-scout 动态审查侦察

> finishing 阶段方向评估(治理批适用 — finishing-rules §治理批收口工序适用;decision 2026-06-13 追记三"方向评估重要")。调度者按 synthesis-rules 事后规则综合 4 挑战者(RUBRIC 合规 / 架构一致 / 文档健康 / Slop 检测),按证据不数票。**方向评估问"方向本身对不对/该不该推翻"(连前提审),区别于治理审查"这批合规达标"(以 decision/spec 为前提)。**

## 结论先行

**方向通过(4/4 不推翻)**。review-scout 方向(ADD ultracode 专属动态审查侦察路 + scout 现推维 + 一维一挑战者扇出 + 非 ultracode 走现有固定 4 维活备份)是 harness 二公设的正向落地,架构干净叠加、文档生态健康、非 slop。**无推翻项**;若干精磨观察项均非阻断(评估者自标"不动方向"),记 ROADMAP。

## 四维综合

- **RUBRIC 合规(方向盘对齐)= 通过**:scout 独立 fork 现推维 = 公设 1(做事/判断分离)的结构性强化(推维/审/综合三段拆三 context);自读盘 + `why_this_time` 强制原文锚点 = 公设 2(执行外部动作取证)落地。**关键发现**:方向避开了 harness 自识别的承重墙 —— `scaffold-vs-ultracode-map.md` L18「流程知识(审什么维度)运行时一概不带,删文件后有机器没图纸」;但本设计把地板维表(保底"图纸")钉在版本控制的 `review-rules.md`(scout 照抄不增删),只"加维"一截动态化且强制 `why_this_time`/`skipped_candidates` 留痕 → 不是"溶进运行时蒸发",是"图纸保留 + 增量推理留痕"。诚实边界(§7.3)真承认局限,非粉饰。
- **架构一致 = 通过**:scout 路本身是扁平 fork 的一个实例(`parallel()` 扇出 = 一维一独立 context + 调度者综合,与 2026-04-16 扁平 fork 方案 B 同拓扑;载体从"主对话发 N fork"换成"workflow `parallel()` 屏障",拓扑未变)。scout/workflow 拆两模块服务公设 1,有 research-scout.md 同构先例。零改现有路 + scout 路 prompt 与 design-reviewer.md 零共享(FLOOR_FOCUS 自有常量),在真实工件里结构成立,无双源耦合。失败语义清晰(scout 失败显式报、不静默回落)。
- **文档健康 = 通过**:双写对(conf↔§2 / 根 CLAUDE↔harness CLAUDE)同步可维护;入口地图四处口径统一("默认 4 维 + ultracode 走 scout",无"有的说 4 维有的说动态 N"矛盾);alias 旧账(过度工程化/合理性)在 spec §1.3 据实标注 + 定了"据实用执行层名、repo-wide 统一不在本 scope"规则,边界讲清未埋深。
- **Slop 检测 = 需精磨但核心非 slop**:动态价值是"概率性提升 + 隔离推维"(非确定性差异化),spec 未 over-claim、把退化失败模式钉进 meta-L4 实战观察;诚实标注主体是真把局限说死(对照 `feedback_spec_gap_masking` 正面应答);审查非橡皮图章(对抗 audit 逮到真 🔴 已修)。

## 精磨观察项(非阻断 → ROADMAP)

1. **FloorTable code/governance 两行预填**(audit 副作用丙 F1 + 评估 Slop + 文档健康 三方收敛):"覆盖三类"只需 reviewType 参数化 + design 一行真数据,留口 ≠ 必须预填两行维名;且 floor 维不带 challenger_focus,接线时 `challengerPrompt` 会传 undefined focus。**接线 code/governance 时一并裁:两行维名是否预填 + 同步补 FLOOR_FOCUS 对应 focus**。spec §7.3 已接受当前 3 行形态,本轮不动(已锁设计)。
2. **地板维表机读镜像显性化**(文档健康):维名清单在 `workflow.js FloorTable` + `review-rules.md` 两处镜像,review-rules 声明"权威住此"但运行时真相在 workflow.js;建议 review-rules 注里点明"workflow.js FloorTable 为机读镜像,改维名须双改"(对齐 credentials-rules §8 双写同步义务惯例)。
3. **诚实认知上提**(RUBRIC + 架构 + Slop 收敛):"非 ultracode 路痛点未解 / ultracode 普及前主流路径净增益≈0 / 自仓库 dogfood 不到自己主打痛点"——spec §7.3 已散见,建议作为一句话结论上提到 decision「后续影响」或 handoff 可见处,免未来误判"review-scout 已解决固定 4 维痛点"。
4. **奖励项措辞**(Slop):"活备份不丢能力"建议从奖励项降为边界澄清(避免把"没动现状"记成正收益)。
5. **spec 重复收敛**(文档健康,低优先):"design-reviewer.md 零关系"等结论 spec 内重复 7+ 处,未来可收敛单一权威段 + 指针。

> 精磨项 2-5 多触及已锁 spec / 或会使本批 audit 对 review-rules 失效(§5.1),本轮**不就地改**,登记 ROADMAP 观察项,留后续批次或接线时处置。精磨项 1 已在 audit 凭证 ROADMAP 段登记。

## 分流建议

**通过**(方向评估无推翻、无 must-fix 阻断项;治理审查 audit verdict=pass-after-revision 已落账,🔴 已修)。下一步按 finishing-rules 通过路:milestone + decision-trail + PROGRESS + ROADMAP 观察项登记 + structured-handoff,之后由用户决定合并/PR/清理。

## 细节链接

- 治理审查 audit:`docs/audits/audit-2026-06-15-112342-review-scout.md`(verdict=pass-after-revision)
- 设计 spec:`docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md`(已锁)
- 决策锚:`docs/decisions/2026-06-13-review-scout-workflows-dir.md`(🟢 用户拍板保 A + Y)

# ✅ 偏好层 preferences.md 是否纳入 meta scope(A 组)

> 状态:✅ 已决(2026-06-11 用户拍板)
> 来源:`docs/superpowers/specs/2026-06-10-context-layer-design.md` §7.1 D11
> 类型:方案选择型
> 日期:2026-06-10(designer fork 提出)

## 问题

上下文层设计新建 `docs/preferences.md`(用户协作偏好的仓内权威住址,九格之"用户偏好")。它被 CLAUDE.md 地图行指向、会影响 AI 每会话行为。**改它要不要走 meta-review?**(= 是否在 `meta-scope.conf` 加一行 glob)

## 选项

### A:入 A 组 meta scope(设计师倾向)

- 做法:`meta-scope.conf` A 组加 `docs/preferences.md` 一行;根 CLAUDE.md §3/§5 对照表同步(双写同步约束)。
- 理由:
  1. 它是行为约束件——AI 理论上可"自我说服"弱化对自己不利的偏好条目;机械触发审查不可绕(README 原理 4.3,与 CLAUDE.md/governance 入 scope 同逻辑)。
  2. 偏好条目本质是用户校准(与 `memory/feedback_*` 同源),被改错的代价是跨会话的。
- 代价:用户口头让 AI 加一条偏好也会触发 meta-review;可走既有 skip 字段轻路径(`## meta-review: skipped(理由: 用户原话直录,无语义加工)`),成本≈一行声明。

### B:不入 scope

- 做法:不改 scope.conf。
- 理由:偏好是用户自己的话,用户改自己的偏好不需要对抗审查;治理面越小越简洁。
- 代价:AI 代笔写入时(实际常态)无机械审查触发,只剩"用户拍板"这道人闸——若 AI 在转写时夹带语义偏移,无机制兜底。

## 影响面

- `meta-scope.conf`(M17)+ 根 `CLAUDE.md` §3/§5 表(M3)——两处双写同步
- 批 1 实施顺序(若选 A,加行动作与 preferences.md 新建同批)

## 决定

**选 A(入 A 组 meta scope),且按用户表述升级了定位**。用户原话(2026-06-11):"那是不是将偏好作为项目规范更好一点,然后过审查"。

即:偏好文件保留"用户原话留痕"的身份(跟人走、判断权在用户),但**治理上与规范文件同等对待**——改动触发 meta-review。

执行精确化两条(调度者转译,随本决定生效):

1. **审查口径 = 忠实性审查,不是合理性审查**:挑战者核"该条目是否忠实于用户原话(每条带出处锚点:日期+原话引录)",**不评判偏好本身对不对**——评判用户的判断违反既有红线(`memory/feedback_read_dont_judge_user`)。AI 代笔转写的语义偏移是审查的唯一靶子。
2. **升格管道显式化**:被反复验证适用的偏好,可经正常治理流程升格写进对应规范文件(先例:3 条 feedback 已硬编码进 brainstorming-rules 反模式约束);升格后原条目标注"已升格 → 指向规范位置"。偏好文件本身**不分发下游**(个人层,跟人不跟项目;与 `feedback_skill_no_cross_project` 同族边界)。

落地动作(随设计批 1c):`meta-scope.conf` A 组加 `docs/preferences.md` + 根 CLAUDE.md §3/§5 对照表同步(双写约束);轻路径保留(用户原话直录可走 skip 字段)。

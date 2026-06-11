# AGENTS.md — agent 第 0 步地图(harness 自仓库)

> 运行时中立:任何 agent 工具或纯人工都按本文件接手。Claude Code 专属治理见根 CLAUDE.md(自动加载)。
> 实物在 harness/ 下(双层结构:仓库根 = 治理入口,harness/ = 框架源码与文档)。

## 这个仓库的上下文分两层

- 工作台: harness/docs/active/handoff.md(状态+指针,覆写经晋升门禁 /structured-handoff)
- 书架: 九格(愿景/需求/系统真相/决策史/标尺/干活规矩/行业认知/用户偏好/地图)→ 见下方住址表

## 接手顺序(任何 agent / 人)

0. 本文件(实物在 harness/ 下)→ 1. 读 harness/docs/active/handoff.md(台账:状态+指针;台账内指针写 docs/... 相对路径,基准 = harness/)→ 2. 顺指针 Read 本体
→ 3. 找没有指针的东西: harness/docs/references/README.md(目录卡)/ ls harness/docs/decisions/(文件名即卡)
→ 4. 治理与角色规则: 根 CLAUDE.md(Claude Code 自动加载;其他运行时手动读)
- meta 治理(自仓库专属): 根 CLAUDE.md(M3)scope 分流
- 开场对账(步 1 读完台账后):跑下方「手工校验」两命令 + `bash harness/.claude/hooks/check-meta-review.sh --reconcile`;欠账先补再干活(会话链自执法,详 harness/docs/decisions/2026-06-11-session-chain-reconciliation.md)

## 九格住址表(+ 各格生命周期型)

| # | 格 | 住址 | 生命周期 |
|---|---|---|---|
| 1 | 愿景 | README.md(仓库根;dogfood 边界:自仓库不建 docs/context/) | evolving |
| 2 | 需求 | harness/docs/superpowers/specs/(spec §1)+ harness/docs/ROADMAP.md | spec 单件 immutable;ROADMAP evolving |
| 3 | 系统真相 | harness/docs/ARCHITECTURE.md + 各模块 README | evolving |
| 4 | 决策史 | harness/docs/decisions/ + harness/docs/decision-trail.md | immutable(只追加) |
| 5 | 标尺 | harness/docs/RUBRIC.md | evolving |
| 6 | 干活规矩 | harness/docs/governance/ | evolving |
| 7 | 行业认知 | harness/docs/references/(日期前缀留痕) | immutable(只追加) |
| 8 | 用户偏好 | harness/docs/preferences.md(仓内权威住址;memory 为缓存镜像;不分发下游) | evolving |
| 9 | 地图 | AGENTS.md(根)+ CLAUDE.md(根)+ harness/docs/references/README.md(目录卡) | evolving |

## 硬规矩(一行引用,不重复全文;权威全文住各自住址)

- 落库即登记: 写 references/ 带日期前缀留痕件同批登目录卡行(无前缀标准件豁免) → 全文与行文法住 harness/docs/references/README.md 目录卡头部
- 覆写台账先清账: promotion 声明带锚点 → 全文住台账模板头 + structured-handoff SKILL(晋升门禁)
- 过时标注不删改(immutable 格;本行即全文)

## 手工校验(无 hook 运行时 / 纯人工)

- echo '{}' | bash harness/.claude/hooks/check-handoff.sh
- echo '{}' | bash harness/.claude/hooks/check-shelf-registry.sh

(hook 是 Claude Code 增强层;换运行时丢自动触发,不丢可校验性)

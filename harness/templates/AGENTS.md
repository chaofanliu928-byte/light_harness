# AGENTS.md — agent 第 0 步地图

> 运行时中立:任何 agent 工具或纯人工都按本文件接手。Claude Code 专属治理见 CLAUDE.md(自动加载)。

## 这个仓库的上下文分两层

- 工作台: docs/active/handoff.md(状态+指针,覆写经晋升门禁 /structured-handoff)
- 书架: 九格(愿景/需求/系统真相/决策史/标尺/干活规矩/行业认知/用户偏好/地图)→ 见下方住址表

## 接手顺序(任何 agent / 人)

0. 本文件 → 1. 读 docs/active/handoff.md(台账:状态+指针)→ 2. 顺指针 Read 本体
→ 3. 找没有指针的东西: docs/references/README.md(目录卡)/ ls docs/decisions/(文件名即卡)
→ 4. 治理与角色规则: CLAUDE.md(Claude Code 自动加载;其他运行时手动读)
- 开场对账(步 1 读完台账后):跑下方「手工校验」三命令;欠账先补再干活(下一会话是上一会话的验收者)

## 九格住址表(+ 各格生命周期型)

| # | 格 | 住址 | 生命周期 |
|---|---|---|---|
| 1 | 愿景 | docs/context/L1-vision.md | evolving |
| 2 | 需求 | docs/context/(L2+)+ docs/superpowers/specs/(spec §1) | spec 单件 immutable |
| 3 | 系统真相 | docs/ARCHITECTURE.md + 各模块 README | evolving |
| 4 | 决策史 | docs/decisions/ + docs/decision-trail.md | immutable(只追加) |
| 5 | 标尺 | docs/RUBRIC.md | evolving |
| 6 | 干活规矩 | docs/governance/ | evolving |
| 7 | 行业认知 | docs/references/(日期前缀留痕) | immutable(只追加) |
| 8 | 用户偏好 | 不随 harness 分发——使用者个人层;可自建 docs/preferences.md,条目文法一行示例: - [YYYY-MM-DD] <偏好一句话>(原话: "<用户原话引录>") | evolving |
| 9 | 地图 | AGENTS.md + CLAUDE.md + docs/references/README.md(目录卡) | evolving |

## 硬规矩(一行引用,不重复全文;权威全文住各自住址)

- 落库即登记: 写 references/ 带日期前缀留痕件同批登目录卡行(无前缀标准件豁免) → 全文与行文法住 references/README.md 目录卡头部
- 覆写台账先清账: promotion 声明带锚点 → 全文住台账模板头 + structured-handoff SKILL(晋升门禁)
- 过时标注不删改(immutable 格;本行即全文)
- 治理面改动留凭证: 命中 credentials.conf 的改动收口前必有 audit(或 exempt 微 audit) → 全文住 docs/governance/credentials-rules.md

## 手工校验(无 hook 运行时 / 纯人工)

- bash .claude/hooks/check-handoff.sh --reconcile
- echo '{}' | bash .claude/hooks/check-shelf-registry.sh
- bash .claude/hooks/check-audit-coverage.sh --reconcile

(hook 是 Claude Code 增强层;换运行时丢自动触发,不丢可校验性)

## 开场新鲜度侦察(需 agent 运行时)

- 开场对账(步 2)之后,fork 一个 `freshness-scout` 子智能体扫活文档 frontmatter,**只回有问题的、全干净静默**(软,不阻断)。
- 范围清单 / 三类问题判据(孤儿 / 时间腐 / 缺 frontmatter)/ owner 二分(用户·调度者)+ routeTo:权威住 docs/governance/freshness-rules.md;子智能体契约住 .claude/agents/freshness-scout.md。
- 复核确认还准 → 把该文档 last-reviewed 推到今天(收口时本批动过的顺手推)。

(需 agent 运行时;无 agent 运行时则跳过本步——同 hook 降级,丢自动触发不丢可校验性;对账三命令不受影响)

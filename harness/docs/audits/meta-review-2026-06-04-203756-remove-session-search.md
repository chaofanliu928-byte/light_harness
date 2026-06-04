---
meta-review: true
covers:
  - harness/.claude/skills/session-search/SKILL.md
  - harness/.claude/skills/structured-handoff/SKILL.md
  - harness/setup.sh
  - harness/docs/governance/brainstorming-rules.md
  - harness/CLAUDE.md
  - harness/QUICKREF.md
  - harness/README.md
  - <root>/README.md
---

# Meta-Review Audit — 删除 session-search skill(2026-06-04)

## 1. 元信息

- **batch name**:remove-session-search-skill
- **触发时间**:2026-06-04 20:37:56(本地)
- **改动 scope**:meta(C 组 skill + A 组 governance/CLAUDE + F 组 setup.sh + 非 scope 的 README/QUICKREF 连带)
- **改动规模**:删 1 skill 目录 + 8 文件改 + 1 decision 新建 + 本 audit;另顺带更新用户级 memory(仓库外,不入 commit)
- **决策依据**:`docs/decisions/2026-06-04-remove-session-search-skill.md`(用户拍板:只要继承①连续性,该由 session-init 提供;session-search 无人用、自动触发不可靠 → 删)
- **审查模态**:删除批 → 3 挑战者(完整性 / 安全性 / 自洽性+下游)
- **领审员**:调度者(主对话,Claude Opus)
- **设计来源**:独立 designer(Plan agent)穷尽扫描;领审员不自审自己的设计(公设 1)
- **属功能层剪枝**:继 N2(满意度)之后第二刀;本批把"反向追问"对准存量功能(session-search 这个能力),而非新增

## 2. 维度选取

| 挑战者 | 覆盖维度 |
|---|---|
| C1 完整性 | 独立重扫全树 → 查漏触点 / 错分类 / 行号 |
| C2 安全性 | 删 session-search 不得伤 继承①(session-init)/ 公设2 / 下游 / structured-handoff / 误删 session-init |
| C3 自洽性+下游 | 技能计数 9→8 全仓一致 + 技能表/树完整 + 孤儿引用 + 下游分发 |

## 3. 综合发现与处置

**verdict:3 挑战者一致 pass-after-revision**(删除方向正确,无 overturn;继承①/公设2 本体/其它 8 skill 均不受影响)。

### 🔴 必修(已落地)— meta-review 抓到的真错
1. **设计者把 harness/README 的行号错套到根 README**(C1 + C2 独立撞同一处):根 README 实际**只有 line 24 一处 session-search**(公设2);设计者 A3 声称的 root line 122/158/189/221 在根 README 里是安装命令 / Codex 段 / "保 Claude" / 无关内容——照搬会改坏根 README。**已纠正**:根 README 真实触点 = line 24(公设2 改写)+ line 41(计数 9→8)+ line 146(树计数 9→8),共 3 处。实现前用 Grep 重新核出全部真实行号,不信方案行号。
2. **漏了根 README:146 树计数**(第 5 处派生计数):已补(9→8)。

### 🟡 已修
- 派生计数共 5 处 9→8 全部落地:根 README 41 + 根 README 146 + harness README 39 + memory 37(仓库外)+(QUICKREF 技能表无计数,只删行)。
- structured-handoff SKILL.md L40 孤儿引用("供 session-search 检索")→ 改"手动 grep 深查";QUICKREF L75 同改;brainstorming-rules L20-21 自动触发 → 合并为"手动 grep docs/{completed,decisions}"一句。

### 🟢 确认 / 勿动(实证)
- **继承①不受影响**:session-init.sh(SessionStart hook,机械必跑)零 session-search 依赖,继续注入 handoff/eval → 连续性照旧。
- **公设2 本体安全**:只有两份 README 把 session-search 当公设2 实现(CLAUDE.md 公设2 块是通用措辞、不点名)→ 改写两份 README 实现行为"session-init hook + 不确定直接 Grep/Read(行动公设本体)"即可,axiom 不动。
- **下游分发**:setup.sh L55(mkdir)+ L64(cp)删除(行号实测精确);两份 settings.json 无 session-search(它是 skill 非 hook);下游不再分发,继承①照旧。
- 未误删 session-init(两名字区分);其它 8 skill 不动;历史留痕(docs/{decisions,audits,specs})不改写。

## 4. 实现后校验(grep 实证)

- session-search **skill 名**:LIVE 文件 0 命中(skills/agents/hooks/governance/README/CLAUDE/QUICKREF 全清);残留全在历史留痕 + 本 decision/audit + decision-trail 历史条目。
- "9 个 SKILL / 9 个 skill / Skills(9":0 命中(全部 →8)。
- skills 目录:实际 8 个(design-review/evaluate/process-audit/project-setup/security-scan/skill-extract/structured-handoff/system-design)。
- 误报澄清:project-setup SKILL.md:9 与 N2 decision:56 的命中是普通词"跨会话",非 session-search skill 引用,正确未动。

## 5. 终态

session-search skill 删除。**继承①(连续性)由 session-init + structured-handoff 兜底,不变**;"深挖历史归档"降为 AI 按需手动 grep `docs/{completed,decisions}`(已写进 brainstorming-rules)。公设2 实现改挂 session-init + 行动公设本体。技能数 9→8,全仓计数/表/树一致,无孤儿 LIVE 引用,下游分发链干净。

## 6. 已知缺口 / 备注

- **继承②(自动召回相关旧经验)未做**:用户明确只要①。若日后想要②,正路是加强 session-init(机械推送),不是恢复一个靠 invoke 的 skill(session-search 失败的根因正是"靠自觉调用")。
- memory `project_harness_overview.md` 同步更新(skill 数 + 删 session-search 行 + 顺带修 N2 残留 process-auditor 2→1),但 memory 在用户主目录、不入 git commit。

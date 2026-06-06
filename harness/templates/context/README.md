# docs/context/ — 分层活上下文链(怎么用)

> 把"意图 → 实现"串成一条**机读的分层链**,跨会话不丢、依赖图显式。
> 越上层越可探索(松)、越下层越严谨;`待定` 合法,**改上游必须当场把下游 repoint 或标 `待定`**。
> **frontmatter 与 upstream 只用半角 `[ ] : ,`**(全角 ［］：， 会被 check-context-chain.sh 机读静默漏)。

## 六层 + 目录 + 编码

| 层 | 装什么 | 目录 / 文件 | 编码 |
|----|--------|------------|------|
| L1 | 愿景 / 意图 | `L1-vision.md` | `L1-vision` |
| L2 | 需求 / 功能 | `L2-INDEX.md`(单表默认)或 `L2-spec/L2-F<n>-<slug>.md` | `L2-INDEX` / `L2-F<n>` |
| L3 | 架构 | `L3-arch/L3-ARCH.md` 或 `L3-arch/L3-D<n>-<slug>.md` | `L3-ARCH` / `L3-D<n>` |
| L4 | 设计 · 拆解 | `L4-design/L4-F<n>-design.md` 与 `L4-F<n>-plan.md` | `L4-F<n>` |
| L5 | 实现 · 验证 | `L5-impl/L5-F<n>-<slug>.md`(薄挂链节,指向真实代码) | `L5-F<n>` |
| L6 | 测试 / TDD | `L6-test/L6-F<n>-<slug>.md`(薄;策略 ≤3 行可并入 L5) | `L6-F<n>` |

- **编码进文件名,编码即稳定 ID**;改 slug 不断链。L4 的 `-design`/`-plan` 同属一个编码 `L4-F<n>`。
- **方法讨论(brainstorming)不单独编码**,折进 L3 正文一个"方法理由"小节(为什么选这条架构路线)。
- L1/L2 由 project-setup 起步建;**L3-L6 随真实开发到该阶段时由 AI 现建**,不预铺空壳。

## 每个节点的 frontmatter(必填,半角)

```
---
layer: L3
code: L3-ARCH
upstream: [L2-F1, L2-F2]
status: active        # active | 待定 | superseded
---
```
- `upstream` 指**上游编码**(不指路径、不 grep),**只能指更高层**(方向永不反:低层不定义高层)。
- 探索期 `upstream: [待定]` 合法;L1 写 `upstream: []`(根)。

## L5 / L6 薄节装什么(代码表达不了的,别抄代码)

- **L5**:① 实现关键决策 / 坑(一句话 + 根因)② 验证证据指针(指向测试 / handoff 的 Evidence Depth,finishing 时回填)③ 代码落点(相对路径)。
- **L6**:① 测试策略(测什么 / 不测什么 / mock)② 测试落点。策略 ≤3 行且无独立 upstream 时,直接并进 L5 的一个小节,不单建文件。

## 软提醒 + 硬收口

- **平时(每次 Stop)**:`check-context-chain.sh` 发现断链 / 编码冲突 / 全角只**警告放行**,不拦发散。
- **收口(finishing)**:功能做完,在 `docs/active/handoff.md` 写一句 `## context-chain: 已核(<结论>)`(或 `skipped(理由: <非空>)`),否则 hook 在收口拦你。核法见 `docs/governance/finishing-rules.md`「收口硬核链」。

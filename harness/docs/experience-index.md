# 项目经验索引

> **用途**:索引 harness 过往项目经验(踩过的坑 / 能力边界 / 排除的备选),便于 brainstorming / system-design 时快速 grep 借鉴。
>
> **不是**:debug pattern 表(那是 ECC 外来形式,本项目不采用)。
>
> **来源**:每个 `docs/decisions/*.md` 文件的"考虑过的备选 / 能力边界 / 踩过的坑"段。
>
> **2026-05-13 引入**(初版)— 配套 `docs/decisions/_TEMPLATE.md` 经验库段。

---

## 检索方式

- 按**主题**(技术 / 方法 / 模式)
- 按**经验类型**(备选排除 / 能力边界 / 踩坑)
- 直接 grep 本文件 + decisions/ 目录全文搜

---

## 经验条目(按时间倒序)

> 初版无条目。后续每次 decision 落地时,append 一行索引到本文件,指向 decision 文件对应段。
>
> 格式示例:
>
> ```markdown
> ### 2026-XX-XX — [主题]
> - **类型**:能力边界 / 踩坑 / 备选排除
> - **位置**:`docs/decisions/2026-XX-XX-[name].md` § [段名]
> - **一句话**:[关键经验,便于 grep 时一眼识别]
> ```

<!-- 经验条目从此处开始 append -->

---

## 索引维护

- **每次 decision 落地**:append 一行到上方"经验条目"段
- **每个季度 review**:看是否有过期 / 重复 / 应合并的条目
- **不主动整理**:避免预设固化分类,允许自由 append

---

## 与其他经验沉淀机制的关系

| 机制 | 形式 | 用途 |
|---|---|---|
| **本文件(experience-index.md)** | 索引 | 检索过往经验 |
| **decisions/*.md 经验库段** | 原文 | 完整记录决策时的考虑 |
| `decision-trail.md`(M1 自动 append) | 决策路径 | 时序追溯 |
| `docs/audits/*.md` | 审查报告 | meta-review / process-audit 结果 |

四者协同构成 harness 的经验库:索引检索 + 决策原文 + 时序路径 + 审查结论。

---

## 相关 spec / decision

- 经验库形式决策:`harness/docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §12

---
layer: L2
code: L2-INDEX
upstream: [L1-vision]
status: 待定
---
# 需求 / 功能单表

> 默认单表,一行一功能。某功能要被下游精确挂靠时,再拆成 L2-spec/L2-F<n>-<slug>.md 文件。
> 下游 upstream 默认挂 `L2-INDEX`(整表);拆成文件后挂 `L2-F<n>`(校验 hook 按 file-level 编码核,
> 不解析表格行 — 表格行编码是人读 ID,精确校验靠拆文件 / finishing AI 核)。
> frontmatter 与 upstream 只用半角 [ ] : ,(全角会被机读静默漏)。upstream/status 可填"待定"。

| 编码 | 功能 | upstream | status |
|------|------|----------|--------|
| L2-F1 | [待填] | L1-vision | 待定 |

# 设计背景地图(design-context-map)
<!-- owner: 调度者; last-reviewed: 2026-06-17; 生命周期: evolving -->

> 机读·设计背景地图:一行一**业务模块**,列 = 成员文件 glob(第一跳 file→模块匹配键)+ 各类设计背景**住址指针**(第二跳照拉,**只指不抄**)。本表**就是业务模块的权威清单**(`references/2026-06-10-business-module-map.md` 旧件留痕不升格)。
>
> 被 `.claude/agents/design-context-scout.md` 侦察员消费:进写代码/调试/重构场景 → 调度者 fork 侦察员 → 第一跳 touchedFiles 匹配成员 glob 命中模块 → 第二跳照住址列 Read 源 → 消化成 briefing 到手边。
>
> **dogfood 边界(harness 自仓库)**:自仓库**不填**业务模块数据行(下方仅留示意样板行演示填法);自仓库用 README/现有 specs/decisions 当设计背景,不套本产品式地图。本地图随 `setup.sh` **活文件守卫 cp** 分发到下游,由下游逐模块填。
>
> **怎么填见迁移指南**:`docs/governance/design-context-migration.md`(必备内容 11 类 + 搬进格式三步)。

## 主表

| 业务模块 | 成员文件 glob | 接口契约 | 数据模型 | 模块边界 | 取舍决策 | 不变量约束 | 既知坑/已知问题 | 业务规则索引 | 并发/同步/排序约束 |
|---|---|---|---|---|---|---|---|---|---|
<!-- 示意样板行(填法演示,非真实数据;下游按此格式逐模块填,自仓库不填——dogfood 边界): -->
| 订单 | src/order/**;src/checkout/** | design/order.md:§3 + src/order/README.md:对外接口 | design/order.md:§4 | ARCHITECTURE.md:订单层 + src/order/README.md:职责 | decisions/2025-xx-order-split.md + design/order.md:§7 | ARCHITECTURE.md:订单不变量 + src/order/README.md:约束和规则 | known-pitfalls-index.md:订单 + src/order/README.md:已知问题和技术债 | design/order.md:§1.7业务规则 | design/order.md:§5.1 |
<!-- 怎么填:① 一模块一行;② 成员 glob 指本模块代码文件(多 glob 分号分隔);③ 各列填"文件:锚"住址指针(只指不抄),无料填 —;④ 照 design-context-migration.md B1 清单确保住址真有料;⑤ 残留 why 不进本表列——由侦察员 grep 代码就近 // WHY: 注释拉 -->

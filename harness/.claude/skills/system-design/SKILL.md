---
name: system-design
description: "系统设计。brainstorming 完成、需求锁定后触发。扁平 fork:调度者先 fork designer 写设计,再 fork 独立自检挑战者验证,调度者控制迭代。"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Agent
---

# 系统设计

> **架构**:扁平 fork(2026-04-16 改造)。主对话(调度者)依次 fork designer 和自检挑战者,两者互相独立。详见 `docs/decisions/2026-04-16-fork-flat-refactor.md`。

## 输入(注入到 designer 的 prompt 中)

!`f=$(ls -t docs/superpowers/specs/*-design.md 2>/dev/null | head -1); [ -n "$f" ] && echo "已有设计文档: $f" && cat "$f" || echo "无设计文档(本次新建)"`

!`cat docs/RUBRIC.md 2>/dev/null || echo "无评分标准"`

!`cat docs/ARCHITECTURE.md 2>/dev/null || echo "无架构规范"`

!`cat docs/references/DESIGN_TEMPLATE.md 2>/dev/null || echo "无设计模板"`

---

## 执行

### 第一步:fork designer 写设计草稿

用 Agent 工具,subagent_type: general-purpose,fork 一个 designer,prompt 按 `.claude/agents/designer.md` 内容构造,并**嵌入**上面注入的 RUBRIC / ARCHITECTURE / DESIGN_TEMPLATE / 已有设计文档内容(designer 看不到本对话上下文)。

designer 完成后返回草稿(或写入 `docs/superpowers/specs/[功能名]-design.md` 后返回路径)。

### 第二步:fork 自检挑战者

用 Agent 工具,subagent_type: general-purpose,fork 一个独立的自检挑战者,prompt 如下:

```
你是设计文档的自洽性验证员。你没有参与设计过程,只看到最终文档。

逐条检查以下自洽性要求:
- 需求 ↔ 模块:每个需求场景都有模块实现路径?
- 模块 ↔ 接口:每个模块的职责都通过接口体现?没有孤岛模块?
- 接口 ↔ 数据:接口中的数据类型都在数据模型中定义了?
- 数据 ↔ 边界:每个数据字段的边界值都有处理?
- 依赖 ↔ 架构:模块依赖方向符合 ARCHITECTURE.md?
- 决策 ↔ 需求:设计决策没有偏离需求约束?
- 决策 ↔ 架构:设计决策中的架构选择与 ARCHITECTURE.md 一致?
- 影响 ↔ 模块:改动文件与标记为"改动"的模块对应?
- RUBRIC ↔ 设计:每个 RUBRIC 惩罚项都有应对方式?
- 契约 ↔ 接口:第 3.3 节的共享类型覆盖了所有 API 端点?字段命名一致?

同时检查每节内部的自检清单(文档中每节末尾的 checklist)是否都满足。

对每个不通过的项:指出哪里不自洽、具体内容、建议修复方向。
输出:通过的项打 ✅,不通过的项打 ❌ 并说明原因。

[附:完整设计文档 / RUBRIC.md / ARCHITECTURE.md]
```

### 第三步:调度者控制迭代

- 自检全 ✅ → 设计阶段完成
- 有 ❌ 项 → 回到第一步,fork 一轮新 designer,把"草稿 + 自检报告"一起作为输入,让它修订
- **连续 2 次自检不通过** → 停下来让用户介入,决定方向

### 第四步:待决策项

designer 或自检过程中产生的"待用户决定"项,写入 `docs/decisions/`(标记 🟡),由调度者转达给用户。

## 与旧架构的差异

| 阶段 | 旧(两级 fork,失效) | 新(扁平 fork) |
|---|---|---|
| designer 写草稿 | skill → fork designer | 主对话 → fork designer |
| designer 自检 | designer → fork 自检子 agent(失效) | 主对话 → fork 自检挑战者 |
| 迭代控制 | designer 自己控制 | 主对话控制 |
| 独立性 | designer 和自检独立(理想) | designer 和自检独立(实际) |

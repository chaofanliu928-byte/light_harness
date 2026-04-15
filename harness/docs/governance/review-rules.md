# Code Review 阶段治理规则

> 当 Superpowers 的 requesting-code-review skill 激活时，读取本文件。
> 这些规则在 Superpowers 默认审查维度之上追加。

## RUBRIC 审查

- 按 `docs/RUBRIC.md` 的项目特定标准逐项检查
- 触发任何惩罚项 → 视为 **critical issue**，阻断进度
- 体现了奖励项 → 在 review 中正面标注

## 架构合规

- 检查是否有违反 `docs/ARCHITECTURE.md` 分层规则的跨层依赖
- 新文件是否放在了正确的目录下

## 类型契约合规

- 涉及 API 的代码是否从共享类型文件 import 类型？（不存在前后端各自定义类型的情况）
- 新增/修改的 API 字段是否在共享类型文件中有对应定义？
- 共享类型文件的字段命名与数据库字段是否有一致的映射规范？
- 自行定义了应该在契约中的类型 → 视为 **critical issue**

## 简洁性审查

- 实现是否是解决问题的最短路径？如果有明显更简单的方案 → 视为 issue
- 是否存在只被使用一次的抽象（单次使用的 helper/wrapper/factory）？→ 建议内联
- diff 中是否有与任务无关的变更（格式调整、注释重写、import 排序）？→ 视为 issue
- 200 行能 50 行解决的 → 视为 **critical issue**

## 模块文档一致性

- 涉及模块的 README.md 是否存在？
- README 中的接口描述是否与代码导出一致？
- 依赖关系是否与代码的 import 一致？
- 变更历史是否更新？
- 文档与代码不一致 → 视为 **critical issue**

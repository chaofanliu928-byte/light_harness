# 审查阶段治理规则(唯一审查规则 — 治理同层)

> 一切审查(代码 / 设计 / 治理)的维度选择从本文件「审查维度选择表」出发;各模态的挑战者 prompt 模板由对应 skill 自带(design-review / evaluate / security-scan / process-audit 的 SKILL.md),本文件不载模板全文。
> Superpowers 的 requesting-code-review skill 激活时,读本文件「代码类维度集」各节(在 Superpowers 默认审查维度之上追加)。
> **调度者面对挑战者时遵守 `synthesis-rules.md` 事前/事后规则**(2026-05-13 加入)。

## 审查维度选择表

| 改动类别 | 判定(人读;机器判据 = `.claude/hooks/credentials.conf`) | 维度集 | 力度 / N 弹性 |
|---|---|---|---|
| **代码** | 业务代码 / 测试 / 构建脚本(不命中 credentials.conf) | Superpowers 默认维度 + 本文件「代码类维度集」五节(RUBRIC / 架构合规 / 类型契约 / 简洁性 / 模块文档一致性) | 实现内嵌两段审查(spec 忠实性 + 代码质量);重大改动可加 fork |
| **设计** | `docs/superpowers/specs/` 设计文档 | 自洽性 / 完整性 / 合理性 / RUBRIC 对齐(4 维;**此为 ultracode 不在场时的回落维度集**——主推路见下方 scout 注;模板住 design-review SKILL) | 并行 fork 4 挑战者(回落路;design-review skill 定义) |
| **治理** | 命中 credentials.conf include glob(治理规则 / 入口地图 / hooks / skills / agents / RUBRIC / 设计模板 / setup / 分发模板) | **bootstrap 4 维强制基线(禁止删减;禁用需用户确认)**:核心原则合规 / 目的达成度 / 副作用 / scope 漂移。**+ 触点完整性维(条件必选)**:改动涉及机制的产出/消费契约、跨文件计数/枚举、或分发链时必选;孤立单文件 typo 可不选(定制理由段记录) | N 弹性 2-5+(由主题复杂度定,不机械按 skill 数;上限受单 prompt 64 kB 软上限约束,超限拆多轮 fork)。审查产物 = audit 凭证(文法住 credentials-rules §3) |

> **【设计行 scout 注 / 地板维表(权威住此)】** **review-scout 是设计审查的主推路**:ultracode / Workflow 在场时,设计行**默认走 review-scout workflow**(主推),不走上面固定 4 维;scout 现推维 = **地板 2 维(方向盘对齐 + 自洽性)+ 动态加维**;完整性 / 过度工程化降为「必考虑候选」(不加须 skipped 留痕)。上面 L12 表格行的固定 4 维 = **仅 ultracode/Workflow 不在场时执行的回落维度集**。
>
> **地板维表(三类,权威住本注 — 钉死,非住别处)**:
> - **design** = 方向盘对齐 + 自洽性
> - **code** = 方向盘对齐 + 简洁性(留口,后续可加)
> - **governance** = 核心原则合规 + 目的达成度 + 副作用 + scope 漂移(留口;治理审查仍走现 bootstrap-4)
>
> **双写派生(文档上游、代码派生)**:`.claude/workflows/review-scout.workflow.js` 的 `FloorTable` 常量是本地板维表的**机读镜像**(运行时按它扇出);**本注为权威上游**,改维名须**先改本注、再改 workflow.js FloorTable**,两处三类维名逐字一致(双写对见 credentials-rules §8 第 6 条)。
>
> **非 ultracode 路(回落)**:仅在 ultracode/Workflow 不在场时,用上面设计行现有固定 4 维(自洽性 / 完整性 / 合理性 / RUBRIC 对齐),不变;不退役、不重建 scout(scout 为 ultracode 专属)。

- 一批含多类改动:按类各取维度集,审查可同批 fork、凭证按 credentials-rules 归账(audit covers 列治理面文件即可)。
- 模态与模板的住址:对抗式模板住 design-review / evaluate SKILL;混合式(凭证扫描 + 对抗判定)住 security-scan SKILL;事实统计式住 process-audit SKILL。本表只定"选哪些维度、多大力度",模板细节去 skill 家读。
- 多 fork 并行约束(逐字迁自 M2 §3.1,适用一切多 fork 审查):必须在单一 assistant turn 内一次性发起 N 个 Agent 调用,不得串行下发(依据 2026-04-28 process-audit P-3 实证:曾致 4 挑战者跨 12 分钟串行)。
- 挑战者错误处理(迁自 M2 §4.4):挑战者空返回 → 重试一次 → 仍败标"未完成",不得静默当通过。

- bootstrap 4 维沿 D7:不加第 5 维;禁用 minimum 项需用户确认。

### 触点完整性维(治理行条件必选维)

> **与 D7 撤回的"过度工程化"维的区分(留痕,防被当 scope 漂移咬回)**:
> D7 撤回的维查**多做的害处**(副作用:加了不该加的);本维查**少做的害处**(漏改了该改的触点)。两者正交:
> - **副作用维**(bootstrap 基线,带反向追问):防过度——加维/加抽象前先问有无替代解。
> - **触点完整性维**(本维):防遗漏——一个机制改动,所有产出/消费端、所有引用、所有计数是否同步改全。

**实证(非假设)**:剪枝三批靠穷尽扫 touchpoints 才没留孤儿;`docs/decisions/2026-06-05-audit-bugfix-batch.md` 逮到的 A 簇(RUBRIC 令牌两端字节不一致、消费方 grep 永不命中)、B 簇(Evidence Depth/CI 阻断产出方缺、消费方硬要)、E 簇(README hook 计数 3/4、governance 6/7 漏 testing)全是"少做的害处",副作用维查不出。

**怎么查(挑战者焦点)**:列出本次机制改动的全部触点——产出方↔消费方契约(字节级一致?)、引用该机制的所有文档(计数/枚举同步?)、分发链(setup.sh 复制到位?settings 注册?)、活上下文链(upstream 编码有无断链)——逐触点核"是否同步改全",漏一个即 finding。

**最小解约束(守轻)**:本维放**条件必选**(按主题选用),不进 bootstrap 4 维强制基线(避免每次治理审查跑重)。**何时优先选它**:改动涉及机制的产出/消费契约、跨文件计数/枚举、或分发链时,本维优先于"过度工程化"维选用。孤立单文件 typo 可不选(定制理由段记录)。

## 代码类维度集(requesting-code-review 激活时读)

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

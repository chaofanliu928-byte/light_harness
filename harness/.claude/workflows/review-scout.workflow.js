// review-scout.workflow.js — 动态审查侦察 workflow(ultracode/Workflow 运行时专属)
//
// 被 design-review SKILL 在「执行」开头分支调用(ultracode/Workflow 可用时);
// 不可用时 SKILL 走现有固定 4 维 design-review 流程(本脚本不参与)。
//
// 两阶段编排:
//   phase('侦察')  → review-scout.md agent fork 读上下文现推审查计划(SCOUT_SCHEMA)
//   phase('对抗')  → 按计划一维一挑战者 parallel 扇出(FINDING_SCHEMA),挑战者 prompt 100% 本脚本自有
// 返回 { plan, findings } → 调度者按 synthesis-rules 综合判定(本脚本不下判定 — D8)。
//
// 本脚本与 .claude/agents/design-reviewer.md 零关系(不读/不抄/不镜像 — spec §3.3 第 3 轮根治):
//   floor/已知维挑战者 focus = 本脚本 FLOOR_FOCUS 常量(workflow 无 FS,focus 必在脚本内);
//   动态加维 focus = scout 返回的 challenger_focus 字段。
//
// 权威 spec: docs/superpowers/specs/2026-06-13-dynamic-review-scout-design.md
// 禁用项(确定性约束): Date.now / Math.random / 无参 new Date / 文件系统 API(脚本无 FS)。

export const meta = {
  name: 'review-scout',
  description: '动态审查侦察:scout 现推维(地板+动态加)→ 一维一挑战者并行扇出 → 返回 {plan, findings}',
};

// 地板维表(仅作用 scout/ultracode 路;非 ultracode 路用现有固定 4 维,不查本表)
// 三类各一行;design 本轮接线,code/governance 留口(纯数据行,无实现代码 — spec §7.3 反向追问保 3 行)
const FloorTable = {
  design:     ['方向盘对齐', '自洽性'],                              // D1: 地板 2 维(本轮接线)
  code:       ['方向盘对齐', '简洁性'],                              // D4: 留口,本轮不接线
  governance: ['核心原则合规', '目的达成度', '副作用', 'scope 漂移'], // D4: bootstrap-4 锁死,本轮不接线
};

// 标准候选菜单(scout 路 design 类;scout 每次必考虑,不加须进 skipped_candidates — D-A2)
// 执行层实际名(design-reviewer.md L198「过度工程化」,非治理层别名"合理性");
// = 现有 4 维里地板外的 2 维,scout 路降为"必考虑候选"(降级只在 scout 路)。
const DesignCandidateMenu = ['完整性', '过度工程化'];

// floor/已知维挑战者 focus 常量库(spec §3.3 — 100% scout 路自有,不镜像 design-reviewer.md)
// workflow 无 FS → focus 必在脚本内;SCOUT_SCHEMA.inherited_floor 是 string[](只有维名、无 focus 通道),
// 故 workflow 按维名 d.name 从本常量映射 focus。
const FLOOR_FOCUS = {
  '方向盘对齐':
    '审查设计是否对齐项目方向盘。先 Read docs/RUBRIC.md 判断:' +
    '若「项目特定标准」段已填(无模板标记串「(示例,请替换)」/「你必须根据自己的项目替换」/占位 [列出...] [例如:...])→ 按 RUBRIC 项目特定标准逐项对齐;' +
    '若是空模板 → 回落对齐 CLAUDE.md 原则(文档第一公民/最小变更/角色分离/回退规则)+ 二条公设(Pathological Optimist 做审分离 / 行动公设 不确定执行外部动作),' +
    '读取范围 = Read 仓库根 /CLAUDE.md 或 harness/CLAUDE.md(均含二公设全文)。' +
    '通用基线段(功能完整性/代码质量/测试/一致性/简洁性)始终检查,template 模式只影响项目特定标准段是否回落。',
  '自洽性':
    '矛盾追踪:把设计各章节映射到「章节→关键概念→描述」,跨章节比对同一概念描述是否一致;' +
    '核接口双方对齐(调用方期望 vs 实现方签名)、数据模型一致、状态机完整(无死状态/不可达)、模块依赖无循环、错误传播连贯。',
  '完整性':
    '查需求覆盖与缺口:每个核心场景(设计文档 §1.2)是否有实现路径;边界条件/错误处理是否覆盖;' +
    '接口/数据模型字段是否被需求用到且无悬空;有无场景设计里没覆盖(漏需求)。',
  '过度工程化':
    '查多做的害处(副作用维):有无未被需求要求的抽象层、"未来可能用到"的配置/预留、不可能触发的错误处理;' +
    '对每个新增抽象做反向追问「不用这个方式,原问题怎么解?」有替代解则视过度工程。',
};

// scout fork 返回对象的 schema(agent({schema}) 校验)— spec §3.2 / §4.1(2)
const SCOUT_SCHEMA = {
  type: 'object',
  required: ['inherited_floor', 'added_dimensions', 'skipped_candidates', 'rubric_mode'],
  properties: {
    inherited_floor: {
      type: 'array',
      items: { type: 'string' }, // 地板维名(仅维名,无 focus 通道;workflow 按维名映射 FLOOR_FOCUS)
    },
    added_dimensions: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'why_this_time', 'challenger_focus'],
        properties: {
          name: { type: 'string' },            // 不得与地板/已列候选重叠
          why_this_time: { type: 'string' },   // 证据指认:引被审材料/决策/历史原文
          challenger_focus: { type: 'string' },// 该维挑战者关注焦点 1-2 行
        },
      },
    },
    skipped_candidates: {
      type: 'array',
      items: {
        type: 'object',
        required: ['name', 'why_skipped'],
        properties: {
          name: { type: 'string' },
          why_skipped: { type: 'string' },
        },
      },
    },
    rubric_mode: { type: 'string', enum: ['filled', 'template'] }, // A-3 判据结论
    notes: { type: 'string' }, // 可选:边界声明(如 "ARCHITECTURE.md 缺失,跳过架构维")
  },
};

// 每个挑战者返回对象的 schema — spec §3.4
const FINDING_SCHEMA = {
  type: 'object',
  required: ['dimension', 'findings', 'user_words_section'],
  properties: {
    dimension: { type: 'string' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['title', 'location', 'problem', 'evidence', 'impact', 'severity'],
        properties: {
          title: { type: 'string' },
          location: { type: 'string' },   // 文档节/路径
          problem: { type: 'string' },
          evidence: { type: 'string' },   // 原文引用
          impact: { type: 'string' },
          severity: { type: 'string', enum: ['🔴', '🟡', '🟢'] },
        },
      },
    },
    user_words_section: { type: 'string' }, // 「### 已对照用户原话」section 原文(synthesis 事后规则 5)
  },
};

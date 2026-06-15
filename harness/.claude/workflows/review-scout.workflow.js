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
// 派生自 review-rules 设计行地板维表注(权威上游);改维名先改 review-rules 注、再改本常量 — 双写对见 credentials-rules §8 第 6 条。
const FloorTable = {
  design:     ['方向盘对齐', '自洽性'],                              // D1: 地板 2 维(本轮接线)
  code:       ['方向盘对齐', '简洁性', 'spec忠实性'],               // D-C1=A 地板 + D-C2 spec忠实性入地板(用户拍板 2026-06-15)
  governance: ['核心原则合规', '目的达成度', '副作用', 'scope 漂移'], // D4: bootstrap-4 锁死,本轮不接线
};

// 标准候选菜单(scout 路 design 类;scout 每次必考虑,不加须进 skipped_candidates — D-A2)
// 执行层实际名(design-reviewer.md L198「过度工程化」,非治理层别名"合理性");
// = 现有 4 维里地板外的 2 维,scout 路降为"必考虑候选"(降级只在 scout 路)。
const DesignCandidateMenu = ['完整性', '过度工程化'];

// 标准候选菜单(scout 路 code 类;scout 每次必考虑,不加须进 skipped_candidates — A4 / D-C1=A)
// = review-rules 代码类五节里"非地板、且 diff 驱动条件相关"的维(B 维度分类:条件相关降候选)。
// 派生自 review-rules 代码行 code 候选注(权威上游,任务 6);改名先改 review-rules、再改本常量。
const CodeCandidateMenu = ['类型契约合规', '架构合规', '模块文档一致性'];  // D-C1=A:类型契约入候选(diff 驱动,非地板)

// floor/已知维挑战者 focus 常量库(spec §3.3 — 100% scout 路自有,不镜像 design-reviewer.md)
// workflow 无 FS → focus 必在脚本内;SCOUT_SCHEMA.inherited_floor 是 string[](只有维名、无 focus 通道),
// 故 workflow 按维名 d.name 从本常量映射 focus。
const FLOOR_FOCUS = {
  '方向盘对齐':
    '审查设计是否对齐项目方向盘。先 Read docs/RUBRIC.md(自仓库为 harness/docs/RUBRIC.md)判断:' +
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

// ★ 新增 code 维 focus 常量(scout 路自有,code 语境;与 design FLOOR_FOCUS 分开,避免污染 design 键)。
// design 版 FLOOR_FOCUS(L40-56)键全不改(F 守住);focus 取数处按 reviewType 选(challengerPrompt,任务 3)。
const FLOOR_FOCUS_CODE = {
  '方向盘对齐':   // ★ D 簇:code 独立方向盘对齐 focus(不复用 design「审查设计」语境)
    '审查本次代码改动(diff)是否对齐项目方向盘 + code 通用基线。先 Read docs/RUBRIC.md(自仓库 harness/docs/RUBRIC.md)判 rubric_mode:' +
    '「项目特定标准」段已填(无模板标记串)→ 按 RUBRIC 项目特定标准逐项对齐 diff;空模板 → 回落 CLAUDE.md 原则(文档第一公民/最小变更/角色分离/回退)+ 二条公设(读取范围 = /CLAUDE.md 或 harness/CLAUDE.md)。' +
    'code 通用基线段始终检查 = 功能正确(diff 是否真实现了功能,不只编译过)/ 真实代码质量(命名/结构/错误处理是否达项目标准)/ 测试(改动有无对应测试)/ 一致性(与既有代码风格/pattern 一致)/ 简洁性。据 targets.diffRef 读改动文件核。' +
    '⚠️ 互斥边界(E 簇):本维审"对齐项目长期标准 + 通用基线",不审"是否忠于本次任务 spec"(那是 spec忠实性维)、不审"多做的害处"(那是简洁性维)。',
  'spec忠实性':   // ★ 地板第 3 维(D-C2 用户拍板入地板);scout 路自有,不镜像 design-reviewer.md
    '审实现代码是否忠于"本次任务"的 spec/需求:① 该做的做了没(本次任务 spec 列的需求/场景是否都在 diff 中落地)?② 做歪没 / 跑题没(diff 是否偏离任务要求做了别的)?' +
    '据 targets.diffRef 读改动文件,对照 targets.spec(被实现的设计 spec)逐项核,引 diff 具体锚点。' +
    'targets.spec 缺(纯 bugfix)→ 对照"任务描述 / diff 自身意图"审"做的是否就是这次该做的"(回落不把 sessionIntent 当评分锚——F 簇,sessionIntent 只界定审什么、不当忠实度判据),notes 标无 spec。' +
    '⚠️ 互斥边界(E 簇):本维只审"实现 vs 本次任务意图的吻合度(该做的/做歪的)";不审"多做了 spec 没要求的"那一面里"过度抽象/单次 helper"(归简洁性维)、不审"是否达项目长期标准"(归方向盘对齐)。与 design 路「自洽性」(设计内部一致)/「完整性」(设计覆盖需求)对象不同——本维对象 = 代码 vs 本次任务 spec。',
  '简洁性':
    '查"多做的害处":有无明显更简方案 / 只用一次的抽象(helper/wrapper/factory 建议内联)/ diff 中与任务无关的变更(格式/注释重写/import 排序)/ 200 行能 50 行解决的(critical)。' +
    '据 targets.diffRef 读改动文件。(对齐 review-rules「简洁性审查」节 L66)' +
    '⚠️ 互斥边界(E 簇):本维只审"多做 / 过度抽象 / 无关变更";不审"该做的没做"(归 spec忠实性维)、不审"是否对齐项目长期标准"(归方向盘对齐)。',
  '类型契约合规':   // 候选维 focus(D-C1=A 入候选;scout 选加时映射本键)
    '查涉 API 的代码是否从共享类型文件 import(无前后端各自定义)、新增/改 API 字段是否在共享类型文件有对应定义、字段命名与 DB 映射是否一致;自定义应在契约中的类型 = critical。(对齐 review-rules「类型契约合规」节)',
  '架构合规':
    '查改动是否违反 ARCHITECTURE.md 分层规则(跨层依赖)、新文件是否放在正确目录。' +
    '先 Read targets.architecture;若缺失(自仓库无)→ 本维由 scout 在 notes 标跳过,不硬推。(对齐 review-rules「架构合规」节)',
  '模块文档一致性':
    '查涉及模块的 README.md 是否存在、接口描述是否与代码导出一致、依赖关系是否与 import 一致、变更历史是否更新;文档与代码不一致 = critical。(对齐 review-rules「模块文档一致性」节)',
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

// ───────────────────────────────────────────────────────────────────────────
// 编排段(任务 2):侦察 → 对抗 两阶段 + challengerPrompt 构造 + 错误处理 + 出参
// 上面契约常量(任务 1)不改;本段只加编排逻辑。
// ───────────────────────────────────────────────────────────────────────────

// scout fork 的 prompt(spec §3.2):传指针 + 会话意图 + 地板表 + 候选菜单,引导其读
// review-scout.md 推维指令(scout agentType=general-purpose,有 Read/Grep,自读盘 — D9)。
// workflow 无文件系统:指针只传路径字符串,由 scout fork 自己 Read/Grep。
function scoutPrompt(reviewType, targets, sessionIntent) {
  const floor = FloorTable[reviewType] || [];
  // 候选菜单按 reviewType 取;governance(本轮不接线)→ 空菜单 + 守卫注,不落空注入 design 菜单(spec §3.1)
  const menu = reviewType === 'code' ? CodeCandidateMenu
             : reviewType === 'design' ? DesignCandidateMenu
             : [];  // governance 留口:无调用方用 governance 调本 workflow(治理审查走现 A/B/C)
  return [
    '你是审查侦察员(review-scout)。先 Read `.claude/agents/review-scout.md`(下游分发版路径;',
    '自仓库实际为 `harness/.claude/agents/review-scout.md`)取完整推维指令(A-3 判据 + B-8 加维引导),按它操作。',
    '',
    `审查类型 reviewType = ${reviewType}。`,
    `本类地板维(照抄进 inherited_floor,不增删改): ${JSON.stringify(floor)}`,
    `标准候选菜单(每次必考虑,不加须写进 skipped_candidates 留痕): ${JSON.stringify(menu)}`,
    ...(reviewType !== 'code' && reviewType !== 'design'
        ? ['(注:本 reviewType 未接线,不应被调用——notes 标 "未接线")'] : []),
    '',
    '被审材料 / 上下文指针(用 Read / Grep 自读,不要等人喂内容):',
    ...(reviewType === 'code'
        ? [`  改动范围(必读,git diff / Read 改动文件): ${targets.diffRef}`,
           `  对照 spec(被实现的设计 spec,如有;缺则纯 bugfix,notes 标无对照 spec): ${targets.spec}`]
        : [`  被审材料(必读): ${targets.spec}`]),
    `  方向盘 RUBRIC(A-3 判据 Read 它判 rubric_mode): ${targets.rubric}`,
    `  架构(可缺;缺则 notes 标"跳过架构维"): ${targets.architecture}`,
    `  决策史目录(按需 Grep): ${targets.decisionsDir}`,
    `  审查凭证目录(按需 Grep): ${targets.auditsDir}`,
    '',
    // 会话意图按"任务边界、非结论引导"传入(synthesis 事前规则 5;workflow 不加结论倾向)
    `本会话意图(任务边界,只界定审什么,不暗示结论): ${sessionIntent}`,
    '',
    '输出严格满足 SCOUT_SCHEMA(inherited_floor / added_dimensions / skipped_candidates / rubric_mode',
    '[+ 可选 notes])。你只产审查计划,不下审查判定(judging 在调度者综合阶段 — D8)。',
  ].join('\n');
}

// 单维挑战者 prompt(spec §3.3,100% scout 路自有;不读/不抄/不镜像 design-reviewer.md)。
// 薄包装(自读盘 + 中性约束 + 通用方法论引导 + 主线-支线-关系 + 输出格式 + 已对照用户原话 section)
//   + 该维 focus(floor/已知维 → FLOOR_FOCUS[d.name];动态加维 → d.challenger_focus)。
function challengerPrompt(d, targets, sessionIntent, reviewType) {
  // focus 取数按 reviewType 选(spec §4.1(3) / §3.3):code 路优先取 FLOOR_FOCUS_CODE(含 code 版方向盘对齐),
  // design 维 / 动态维(无 code 键)回落 design FLOOR_FOCUS 或 scout 的 challenger_focus。维名两路一致(不加后缀污染 SCOUT_SCHEMA/双写)。
  const isCode = reviewType === 'code';
  const focus = (isCode && d.name in FLOOR_FOCUS_CODE) ? FLOOR_FOCUS_CODE[d.name]
              : (d.name in FLOOR_FOCUS) ? FLOOR_FOCUS[d.name]
              : d.challenger_focus;
  const locHint = reviewType === 'code' ? 'location(改动文件路径:行号)' : 'location(文档节/路径)';
  return [
    (reviewType === 'code'
      ? `你是代码审查挑战者,负责「${d.name}」这一维。审查对象 = 本次代码改动(diff),不是设计文档。你是对抗者,不是评分员(只产 findings + 证据,不打总分 — D8)。`
      : `你是设计审查挑战者,负责「${d.name}」这一维。你是对抗者,不是评分员(只产 findings + 证据,不打总分 — D8)。`),
    '',
    '先 Read `docs/references/challenger-orientation.md`(自仓库为 harness/docs/references/challenger-orientation.md)取通用方法论(方法 / 数据来源 / 陷阱)。',
    '注:其 §1.2「design-review 4 挑战者专属」的固定 4 维框定不适用本 scout 路的动态 N,不要被它误导。',
    '',
    // A-1:自读盘 + 中性约束(不主动搜罗支持某结论的旁证)
    (reviewType === 'code'
      ? `改动范围(自己 git diff / Read 改动文件): ${targets.diffRef}\n对照 spec/任务(如有,审 spec 忠实性用;缺则注"对照 sessionIntent / diff 自身意图"): ${targets.spec}`
      : `被审材料路径(自己 Read,不要等人喂全文): ${targets.spec}`),
    '中性约束:只读上面被审材料 + 与你这一维 focus 相关的 decisions/audits;',
    '不要主动搜罗支持某个预设结论的旁证(对齐 synthesis-rules 事前规则中性化)。',
    '',
    // 主线-支线-关系(synthesis 事前规则 5;从 sessionIntent 构造,只描述边界不暗示结论)
    '## 主线-支线-关系',
    `- 主线: ${sessionIntent}`,
    `- 支线: 审查被审材料的「${d.name}」维`,
    `- 关系: 本维是本次审查计划中的一维,服务于对被审材料整体质量的判断`,
    '',
    `## 本维关注焦点(${d.name})`,
    focus,
    '',
    '## 输出格式(严格满足 FINDING_SCHEMA)',
    `dimension = 本维名;findings = [{title, ${locHint}, problem, evidence(原文引用), impact, severity(🔴|🟡|🟢)}];`,
    'user_words_section = 末尾必填「### 已对照用户原话」section 原文(对照用户原话锚点核对,守 synthesis 事后规则 5)。',
  ].join('\n');
}

// workflow 默认导出:侦察 → 对抗 两阶段编排。
// 入参契约见 spec §3.1;不下通过/不通过判定(D8),只返回 {plan, findings}。
export default async function reviewScout({ phase, agent, parallel, log }, input) {
  const { reviewType, targets, sessionIntent } = input || {};

  // 入参校验(spec §3.1 / §5.1):
  // - 缺 targets 整体 → 报错返回空。
  // - design 路:缺 targets.spec(被审材料路径)→ 报错。
  // - code 路:缺 targets.diffRef 且缺 targets.spec(改动范围与对照 spec 皆无,无法审)→ 报错。
  const codeMissing = reviewType === 'code' && !targets?.diffRef && !targets?.spec;
  const designMissing = reviewType !== 'code' && (!targets || !targets.spec);
  if (!targets || codeMissing || designMissing) {
    log('review-scout: 入参缺被审材料指针(design 缺 targets.spec / code 缺 targets.diffRef+spec)→ 返回 {plan:null, findings:[]}');
    return { plan: null, findings: [] };
  }

  // ── 阶段 A 侦察:scout fork 读上下文产审查计划 ──
  // 错误处理(spec §3.2 / §5.1):scout 空返回 / schema 校验失败 → 重试一次;二次仍败 → 返回空。
  const plan = await phase('侦察', async () => {
    const prompt = scoutPrompt(reviewType, targets, sessionIntent);
    let result = await agent(prompt, { schema: SCOUT_SCHEMA, label: 'scout', agentType: 'general-purpose' });
    if (!result) {
      // 二次重试(仅一次)
      result = await agent(prompt, { schema: SCOUT_SCHEMA, label: 'scout-retry', agentType: 'general-purpose' });
    }
    return result || null;
  });

  if (!plan) {
    log('review-scout: scout 侦察重试一次仍失败 → 返回 {plan:null, findings:[]}(调度者标审查失败,不静默回落现有 4 维路)');
    return { plan: null, findings: [] };
  }

  // 算实际扇出维列表:dims = inherited_floor ∪ added_dimensions.name(spec §4.2)。
  // inherited_floor 是维名 string[];added_dimensions 是对象数组,取 name 后并集。
  const floorDims = (plan.inherited_floor || []).map((name) => ({ name }));
  const addedDims = plan.added_dimensions || [];
  const dims = [...floorDims, ...addedDims];

  // ── 阶段 B 对抗:一维一挑战者并行扇出 ──
  // 错误处理(spec §3.3 / §5.1):某挑战者空返回 → 重试一次;仍败该项为 null,filter(Boolean) 剔除。
  const findings = await phase('对抗', async () => {
    return await parallel(
      dims.map((d) => async () => {
        const prompt = challengerPrompt(d, targets, sessionIntent, reviewType);
        let r = await agent(prompt, { schema: FINDING_SCHEMA, label: d.name, agentType: 'general-purpose' });
        if (!r) {
          // 二次重试(仅一次);仍败返回 null,由下方 filter(Boolean) 剔除(该维标盲区,调度者综合处理)
          r = await agent(prompt, { schema: FINDING_SCHEMA, label: `${d.name}-retry`, agentType: 'general-purpose' });
        }
        return r || null;
      })
    );
  });

  // 出参(spec §3.5):plan(SCOUT_SCHEMA 原样)+ findings(已 filter(Boolean) 去掉失败挑战者)。
  // 不在脚本内对 findings 下"通过/不通过"判定 — 综合判定在调度者(D8)。
  return {
    plan,
    findings: (findings || []).filter(Boolean),
  };
}

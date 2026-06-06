# 决策: 剪枝两个孤悬机制(experience-index + retrospective-guide)

**状态**:🟢 已决定(用户拍板"都删",2026-06-05)

**日期**:2026-06-05

**关联功能**:harness 自治理质量(剪枝)

**类型**:剪枝(删孤悬)

---

## 背景

用户问"有没有孤悬机制",跑了一轮多智能体孤悬审计(11 agent,对每个判孤悬/半接线的逐条对抗证伪)。逮到 2 个**真孤悬**(证伪失败、维持 orphaned):

1. **`docs/experience-index.md`**:想做"经验检索索引",设计成每次 decision 落地 append 一行。但**从没 append 过一条**(文件 append 区空)、**没有任何 governance/skill/hook 触发写它**(一个 2026-05-13 旧 meta-review 早记"经验库永不启动")、**还白白分发下游**、且与 `decision-trail.md` + grep `decisions/` 全文**功能冗余**。
2. **`docs/references/retrospective-guide.md`**:一份"harness 怎么自我复盘"的手册(内容本身不差),但"复盘"这个动作在流程里**没有任何触发入口**,没人会被引导去读它。复盘本就是用户判断驱动的活儿(本会话的审查/孤悬扫就是在做复盘,凭判断随手做,不照手册)——给它硬接触发反而撞"不预设阶段/防 self-trial 通胀"原则。

## 决定:都删

- 删 `harness/docs/experience-index.md`(冗余空壳 + 白分发下游)。**注:只删索引层;decisions/ 里每条的"备选/能力边界/踩坑"经验段保留**(可 grep 的源,没删)。
- 删 `harness/docs/references/retrospective-guide.md`(无流程入口,用户复盘凭判断随手做)。

## 同步清理(LIVE 触点,防断引)
- `setup.sh`:删 `cp experience-index.md` 行(不再分发下游)。
- `decisions/_TEMPLATE.md`:去掉"配套 experience-index 索引检索"半句,改为"grep `docs/decisions/` 全文"(分发下游模板,避免下游断引)。

## 验证
- LIVE 区(setup/templates/.claude/governance/CLAUDE/README/QUICKREF/_TEMPLATE)grep 两文件名 = **零残留**(无断引)。
- 剩余引用全在历史留痕区(audits/decisions/decision-trail/completed + 带日期 trial self-check `2026-05-22-p0-9-4-self-check.md`),按剪枝惯例不动。

## scope / 提交
- setup.sh = F 组 meta-scope,已在 audit-bugfix + spine 两 audit 的 covers 内;被删文件 + _TEMPLATE = scope=none。check-meta-review 放行。
- 孤悬判定的对抗验证 = 本次孤悬审计 workflow(逐条证伪),等同 review。
- 未提交,与 audit-bugfix + spine 两批一并待用户提交。

## 已知 / 备注
- `docs/references/2026-05-22-p0-9-4-self-check.md`(P0.9.4 带日期 trial 专用 checklist)现含指向已删 retrospective-guide 的引用——它本身是 trial 历史快照、无流程入口(孤悬审计旁注),按历史留痕不动;若日后清理 trial 历史文档可一并处理。

## 关联
- 孤悬审计 workflow(本会话);`decisions/2026-06-04-prune-*`(同类剪枝);`feedback_iterative_progression`(复盘不预设阶段)。

**签署**:用户 + Claude(调度者)

# 决策: harness 自治理缺口承认

**状态**：🟢 已决定

**日期**：2026-04-17

**关联功能**：harness 自身治理（meta 层）

**类型**：根源承认型 decision（非标准"方案选择"型，突破模板骨架说明见下）

**Bootstrap 声明**：**本 decision 自身是 ad-hoc bootstrap 动作**，在 harness 没有 meta 治理规范时写成。后续建立的 self-governance 规范不应追溯性地要求本 decision 通过其流程。本 decision 的作用是**承认缺口存在**，不是 self-governance 的设计方案——设计方案由 P0.9 产出。

---

## 问题

2026-04-17 本会话中做了两件事：
1. 读取目标项目 `D:\项目\智能体-生图` 老版本审查报告（`C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`）
2. 试图按报告发现起草 5 条治理修改（M0 删除 block-dangerous / M1 封死简化收尾 / M2 元规则评分维度不得作跳过依据 / M3 修 finishing 内部冲突 / M4 轻量级判定收紧），用 4 挑战者扁平 fork 做元审查

审查暴露了几层问题，越挖越深：

- **表层**：M0-M4 仅落在治理文字层，但报告的根因本身就是"治理文字层不足以修"
- **中层**："统一更新一次"的时机建议是在掩盖"harness 没有 meta finishing 规范"
- **深层**：harness 反复打补丁的根源不是任何一条规则的漏洞

本 decision 记录对**深层**的回答。

---

## 三条根源

### 根源 1：治理文本，缺执法层

harness 现有治理由 `governance/*.md` + `CLAUDE.md` + `RUBRIC.md` + `SKILL.md` 组成。这些都是文本。真正的硬强制机制只有：

- `check-evidence-depth.sh`（只检字段非空）
- `prettier`（只做代码 format）
- `session-init.sh`（只注入 handoff，不注入 governance）

**没有任何涉及流程决策的硬强制门**：

- `check-handoff.sh` / `check-finishing-skills.sh` 是 exit 0 软提醒
- `finishing-rules.md` 写"必须做三道关"但无机制拦截 milestone commit
- `design-rules.md` 写"必须过 design-review"但无机制检查 spec 是否有 review 产物
- `CLAUDE.md` 核心规则 2"进入阶段前读治理文件"无 hook 强制

涉及"做不做 X"的判断全部落在 agent 自律。老版本项目数据（9 天 / 14 session / 142 commit / 16 spec）显示：专家 skill 调用 0 次，design-review / evaluate / security-scan / process-audit / structured-handoff / skill-extract / session-search 全部 0 触发。这不是 agent 的道德问题，是 **harness 没有执法路径**。

### 根源 2：bootstrap 缺陷——产生规则的过程没有规则

harness 的治理规范写给 feature 层（设计 → 审查 → 开发 → 测试 → 评估 → 合并）。但 harness 自身是 **meta 层**——改动的是规则本身。meta 层没有对应的治理：

- 没有"写新治理规则前的流程"
- 没有"新规则内部自洽审查"机制（本会话 M4a↔M4c 自相矛盾是明证）
- 没有"新规则影响传导"检查（本会话 M4b 需 3 处同步是明证）
- 没有"新规则落地后的效果评估"机制

P-1 / P0 / P0.5 的每次改动，都是在 **meta 无治理** 的状态下 ad-hoc 执行的。

### 根源 3：马鞍定位错位——稳定性标准反了

harness 治理项目，项目骑在 harness 上开发。harness 偏移 1 点 → 所有套它的项目继承 1 点偏移 → N 个项目就是 N 倍总偏移。反过来，harness 稳定 1 点 → N 个项目得 N 倍稳定。

| 层 | 应有稳定性要求 | 当前 harness |
|---|---|---|
| 被治理的项目 | feature 完整即可，允许迭代 | ✅ 有 finishing 流程 |
| 治理项目的 harness | 必须比项目**高一个量级** | ❌ 比 feature 级还松（不走 finishing） |

当前状态完全反了：harness 自身改动用的流程比 feature 级还弱（见 `docs/active/handoff.md` line 107 的 residual：*"harness 自身的开发没走完整 finishing 闭环（self-dogfood 缺失）"*）。这不是时间安排问题，是**没认知到 harness 的 leverage**。

---

## 三条根源的共同指向

三条看似独立，指向同一件事：**harness 缺少"harness 自己"作为被治理对象的地位**。

- 根源 1：治理文本，但不治理"文本是否执行"
- 根源 2：治理 feature 改动，但不治理"harness 自己的改动"
- 根源 3：以 feature 标准改自己，但要求下游项目达到更高标准

缺失的是 **self-referential governance**——系统对自己的约束。

这就是为什么我们反复在 harness 上打补丁：每次补丁都是新文本（根源 1），每次补丁都没有元规则（根源 2），每次补丁的稳定性没有被"高于 feature 层"的机制审查（根源 3）。

---

## 影响评估

- **P-1 / P0 / P0.5 所有已完成条目**，其稳定性**未经 meta 治理验证**——不等于它们有错，只是没有机制证明它们正确
- **本轮 M0-M4** 若继续推进，处于同一个不确定状态
- **未来任何 harness 改动**，在 self-governance 建立前都是 ad-hoc 状态

影响范围：harness 全体 meta 改动史 + 未来。

---

## 决定

1. **将 "harness self-governance" 定为下一阶段核心目标**，新 ROADMAP 条目 **P0.9**。P0.9 先于 P1 启动
2. **M0-M4 降级**，作为 P0.9 建立后执行的第一个批次（不是本轮做）
3. **本次 4 挑战者扁平 fork 元审查登记为 meta-review 原型**，供 P0.9 抽象时参考（本次是 ad-hoc，未来应流程化）
4. **当前 session 剩余动作限定为**：
   - 写本 decision
   - 更新 ROADMAP（加 P0.9，M0-M4 挂在其下为"首个使用批次"）
   - 更新 handoff（反映根源承认 + P0.9 新阶段）
   - 更新 memory `project_harness_overview.md`（加入根源三条）
   - commit + push
   - 不做任何治理规则改动

---

## 不做（防 scope 扩散）

- **不在本 decision 中给 self-governance 的设计方案**——那是 P0.9 的工作
- **不在本 decision 中推翻 P-1/P0/P0.5**——它们保持已完成状态，只是未经 meta 验证
- **不在本 decision 中执行 M0-M4**——推迟
- **不在本 decision 中定义 "meta finishing 规范"**——那是 P0.9 产出

---

## 突破模板骨架的说明

标准 `_TEMPLATE.md` 是"问题 / 方案 A/B / 决定 / 后续"的方案选择型。本 decision 是**根源承认型**——没有 A/B 可选，只有"承认与否"的单选择。故：

- 合并"方案 / 决定"为单节
- 加入 Bootstrap 声明
- 加入 "不做" 节防 scope 扩散

这是 P0.9 还未建立的状态下，对 decision 模板做的首次非规范使用。建议 P0.9 设计时考虑：decision 模板是否应该包含 meta-level decision 子类型。

---

## 后续影响

### 立即影响

- ROADMAP 增加 P0.9 条目
- M0-M4 被推迟（不纳入本轮 commit）
- handoff "下一步" 改为"等待 P0.9 brainstorming"

### 对未来的影响

- 下一会话开始 P0.9 的 brainstorming 收敛
- P0.9 的产出可能包括（非既定，待 brainstorming 决定）：
  - meta finishing 规范（feature 层 finishing 的 meta 变种）
  - hook 执法层扩充（milestone commit / SessionStart 按阶段注入 / structured-handoff 强制触发）
  - self-reference 检查机制
  - 治理一致性审计（断链检查 / 影响传导同步）
  - decision 模板的 meta-level 子类型
- P1 （真实项目验证）**依赖 P0.9 就绪**——否则 P1 的 finishing 仍套在 ad-hoc meta 规范下

---

## 关联

- `C:\Users\刘超凡\Downloads\harness-retrospective-20260417.md`（审查报告，本 decision 起源）
- `docs/decisions/2026-04-15-testing-scope-expansion.md`（上次 scope 级变更）
- `docs/decisions/2026-04-16-fork-flat-refactor.md`（P0.5 扁平 fork 改造）
- `docs/active/handoff.md` line 107（self-dogfood 缺失 residual，首次提到此问题但未上升为根源）

**签署**：用户 + Claude（调度者）

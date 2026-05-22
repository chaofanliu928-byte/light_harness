---
meta-review: true
covers:
  - <root>/CLAUDE.md
  - CLAUDE.md
  - docs/governance/design-rules.md
  - docs/governance/synthesis-rules.md
---

# meta-review:二公设 + Prompt 构造中性化规则 + 综合阶段规则 + 项目经验库

## 1. 元信息

- **日期**:2026-05-13
- **时间戳**:16:50:53(本地时间)
- **主题**:harness 治理新增 4 项 — 二公设 / Prompt 构造中性化规则 / 综合阶段规则 / 项目经验库
- **scope**:mixed(4 meta + 5 scope=none)
- **挑战者数量**:N=5(并行 fork,单 turn 内一次发起)
- **agent 模态**:对抗式
- **来源决策**:`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §4 §5 §11 §12

## 2. 维度选取

### A 段 — 推荐维度(本次启用)

1. **核心原则合规**(B 必含) — 符合 harness 自治理原则 + 用户 feedback
2. **目的达成度**(B 必含) — 4 项改动是否真正达成各自目的
3. **副作用**(B 必含) — 引入新规则后对现有流程的影响
4. **scope 漂移**(B 必含) — 改动是否在主题范围内
5. **实施可行性 + 下游兼容**(C 段定制) — 真能执行 vs 文档摆设;下游分发后合理

### B 段 — 最低必选(bootstrap 4 维基线 + 1 定制)

- 核心原则合规
- 目的达成度
- 副作用
- scope 漂移
- 实施可行性 + 下游兼容(定制必含 — 因本次改动直接为下游 codex 接入服务)

### C 段 — 本次定制

- **启用的推荐维度**:全 5 启用
- **禁用的推荐维度**:无
- **新增的定制维度**:实施可行性 + 下游兼容(理由:用户明确"接入 codex 是为了下游的,需要分发",下游兼容是本次评估重点)
- **粒度细化**:无(对抗式不细化粒度)

## 3. 挑战者执行记录

### D1 核心原则合规(5 问题:2 高 / 3 中)

- 问题 1(高):synthesis-rules.md L21 + L57 用论文 GPT-5.4 74% / Gemini 0.50/0.60 数据论证 → 违反 `feedback_judgment_basis`
- 问题 2(中):synthesis-rules.md "P2 强制约束(2026-05-13)" 预设阶段 → 违反 `feedback_iterative_progression`
- 问题 3(高):synthesis-rules.md L95-98 引用列表用 `harness/` 前缀 + 引用 meta-review-rules.md(下游不存在) → 违反 M3/M4 双层路径架构
- 问题 4(中):二公设引"Anthropic 2026-03 观察" → 轻度违反 `feedback_judgment_basis`(用别人公司观察作来源标签)
- 问题 5(中):design-rules.md 规则 4"prompt 独立审核"无落地机制 → 违反 `feedback_spec_gap_masking`

### D2 目的达成度(5 问题:1 高 / 4 中)

- 问题 1(中,改动 1 二公设):缺反向硬约束,只能提供辩论依据,无法挡住回退主张
- 问题 2(中,改动 2 中性化规则):第 4 条 prompt 独立审核无落地步骤,4 条规则中 3 条可执行
- 问题 3(高,改动 3 综合规则):自声明 5 个 governance 引用,grep 实证只有 design-rules.md 真改 — 规则只覆盖 design-review,evaluate/process-audit/security-scan/meta-review 未生效
- 问题 4(中,改动 4a decision 模板):"考虑过的备选"与上半部分"## 方案 A/B"语义重叠 — 信息分布混淆
- 问题 5(中,改动 4b experience-index):governance 0 命中 — 索引建了但 governance 不知道,经验库永不启动

### D3 副作用(5 问题:0 高 / 4 中 / 1 低)

- 问题 1(中):synthesis-rules.md 引用关系半完成 + 列表说 5 个但只列 4 个(自身计数错)
- 问题 2(中):decision 模板硬规定 3 段但本次 2 个新 decision(P3 框架 / ECC 快照)未填
- 问题 3(低):二公设引文挤在角色定义之前,稀释 §1 首段冲击力
- 问题 4(中):中性化规则放在 design-rules.md 位置错 — 实际跨阶段规则,与 synthesis-rules.md 是姊妹文件
- 问题 5(中):中性化规则与 meta-review-rules.md §6 维度 pattern 功能交叠

### D4 scope 漂移(5 问题:0 高 / 3 中 / 1 低 / 1 通过)

- 问题 1(中):synthesis-rules.md 新建未在 §8 落地位置表声明 — 第 5 项动作未声明
- 问题 2(中):§8 声明 "design-rules.md + meta-review-rules.md",实际只改了 design-rules.md
- 问题 3(中):ECC 快照文件自陈"未决策"但本会话做了 14 处 2026-05-13 决策性修订 — 定位漂移
- 问题 4(低):P3 框架文件自陈"用户原创不改写"但 line 84 含决策注释
- 问题 5(通过):scope 边界遵守通过 — 未跨 governance → hook / skill / agent / src

### D5 实施可行性 + 下游兼容(5 问题:1 高 / 1 高 / 3 中)

- 问题 1(高):synthesis-rules.md 引用未在 review-rules.md / meta-review-rules.md / finishing-rules.md 落地 — 不可执行,仅 design-review 一个场景生效
- 问题 2(高):experience-index.md 不在 setup.sh 复制清单 + _TEMPLATE.md 引用 `harness/docs/experience-index.md`(下游路径无 harness/ 前缀) → 下游分裂
- 问题 3(中):"措辞中性"清单不全(只列 4 个引导词,无识别方法)+ synthesis-rules §4"按维度顺序读"无可观测痕迹(process-audit 无法验证)
- 问题 4(中):M4 二公设应用示例"fork 独立 evaluator"是 harness 多 agent fork 专属概念,对下游普通项目不普适
- 问题 5(中):experience-index 无 hook 强制 append + _TEMPLATE.md "可写暂无"沦为装饰

## 4. 综合

按 synthesis-rules.md 4 条规则做综合(本 audit 本身遵守这些规则做交叉对比):

### 共识主题(2+ 挑战者发现)

| # | 主题 | 共证 | 严重度 |
|---|---|---|---|
| 1 | synthesis-rules.md 引用关系不全(主题核心症结) | D1#3 + D2#3 + D3#1 + D5#1 | **高** |
| 2 | decision 模板 3 段与新建 decision 不一致 | D3#2 + D4#3-4 + D2#4 | 中 |
| 3 | 经验库下游分裂(experience-index 不分发) | D2#5 + D5#2 + D5#5 | **高** |
| 4 | scope 漂移声明不一致 | D4#1-2 | 中 |
| 5 | 中性化规则第 4 条 prompt 独立审核无落地 | D1#5 + D2#2 | 中 |

### 单挑战者发现的高/红线问题

| # | 主题 | 严重度 | 触发红线 |
|---|---|---|---|
| 6 | synthesis-rules.md 用论文数据论证 | **高** | feedback_judgment_basis |
| 7 | 二公设"Anthropic 2026-03 观察"作来源标签 | 中 | feedback_judgment_basis(轻度) |
| 8 | synthesis-rules.md "P2 强制约束"预设阶段 | 中 | feedback_iterative_progression |
| 9 | synthesis-rules.md 引用路径用 `harness/` + 引用 meta-* | **高** | M3/M4 路径架构 |
| 10 | 二公设缺反向硬约束 | 中 | 目的达成度 |
| 11 | M4 二公设"fork 独立 evaluator"对下游不普适 | 中 | 下游兼容 |

### bootstrap 4 维基线检查

- **核心原则合规**:D1 发现 2 高 3 中,**有 feedback 红线违反**
- **目的达成度**:D2 发现 1 高 4 中,**目的部分达成但有显著差距**
- **副作用**:D3 发现 0 高 4 中 1 低,**有耦合 / 半完成状态**
- **scope 漂移**:D4 发现 0 高 3 中 1 低,**scope 边界遵守但声明不一致**

### 分歧

- D3#4 主张"中性化规则位置错,应抽出独立成 challenger-prompt-rules.md";D2/D5 未提及位置问题
- 评估:可保留 D3 观点作"短期可修(中性化合并进 synthesis-rules.md 作 fork 前 / fork 后双段)",但**非阻断**

### 盲区

无显著盲区(5 挑战者覆盖 24 问题,主要症结被多视角共证)。

## 5. 判定

**verdict = needs-revision**

### 必修(must-fix,5 项 high)

1. **synthesis-rules.md 引用关系补齐** — 在 review-rules.md / meta-review-rules.md / finishing-rules.md(evaluate / process-audit / security-scan 三处)各加一行引用 synthesis-rules.md
2. **synthesis-rules.md 用论文数据论证改为纯逻辑** — 删除 L21 "P2 强制约束(2026-05-13)" 中具体百分比 + L57 中"0.50/0.60"等数字,改为"扁平 fork 抗 anchoring 的结构性需要"等纯逻辑表述
3. **synthesis-rules.md 引用路径修正** — `harness/docs/governance/...` → `docs/governance/...`(无 harness/ 前缀);引用 meta-review-rules.md 加注"仅 harness 自仓库,下游无此文件"
4. **二公设"Anthropic 2026-03 观察"** — 改为纯陈述或改为 harness 扁平 fork 架构(2026-04-16)的理论锚点
5. **经验库下游分裂** — 二选一:(a)setup.sh 加 `cp docs/experience-index.md "$TARGET_DIR/docs/"` + _TEMPLATE.md 引用路径改为 `docs/experience-index.md`;或 (b)显式声明 experience-index 是 harness 自仓库限定,下游 _TEMPLATE.md 去掉 3 段经验库

### 应修(should-fix,5 项 中)

6. **decision 模板 3 段 escape hatch** — 加一行"非方案选择型(原文存档 / 分析快照)可省略;否则填'暂无' + reasoning"
7. **中性化规则第 4 条 prompt 独立审核** — 要么补落地步骤(在 design-rules.md §调度者执行步骤插入 6.0),要么承认不可执行降级("调度者按 1/2/3 自检 + meta-review 抽检")
8. **二公设缺反向硬约束** — 加一句"反向规则:任何主张同 agent 既做又审,违反公设 1,默认拒绝;主张内省思考代替外部动作,违反公设 2,默认拒绝"
9. **synthesis-rules.md "P2 强制约束"删除** — 整段删 / 改为"未来若引入跨模型 swap 时,综合阶段需要遵循本文件 4 条规则"
10. **scope 漂移声明 §8 补全** — 把 synthesis-rules.md 显式列入 §8 落地表;§8 声明 "design + meta-review" 但只改了 design — 改为"仅落 design-rules.md,meta-review-rules.md 留待后续"

### 可推后(low / nice-to-have)

11. M4 模板二公设位置(挤在角色定义之前)
12. M4 二公设应用示例改为客户端无关版本
13. P3 框架文件 line 84 决策注释加 header 声明
14. 中性化规则位置(抽出独立或合并进 synthesis-rules.md)
15. "措辞中性"清单加"等同性质引导词"识别方法

### 修订后流程

调度者按上方 1-5 必修 + 6-10 应修做修订,完成后**重走 meta-review**(可降级为 2-3 挑战者复核必修部分,N 弹性按 D6)。

### 元层洞察

本次 meta-review 是 **Pathological Optimist 公设的第 6 次活例**(本会话内):
- 第 1 次:codex URL 没查就下结论
- 第 2 次:GateGuard 偏入实现细节
- 第 3 次:"23 条够了"乐观判断
- 第 4 次:推 A+B 合体当成"精细"
- 第 5 次:推 B 分组嫁接 ECC 模板字段
- **第 6 次:做完 A 组改动后自评"完成",5 挑战者发现 24 问题 5 高**

公设效用得到再次验证 — **separate evaluator 不可替代**。

## 关联文件

- 来源决策:`docs/decisions/2026-05-12-ecc-analysis-snapshot.md`(§4 §5 §11 §12)
- 改动主体:本 audit covers 字段列出的 4 个 meta 文件
- bootstrap 4 维基线依据:`docs/governance/meta-review-rules.md` §6

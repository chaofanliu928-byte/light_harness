---
meta-review: true
covers:
  - setup.sh
---

# meta-review:glassbox 角色 reframe(用户级工具,推荐不分发)

## 1. 元信息

- **审查日期**:2026-04-28(同日 P2 双层 commit `1144f6a` 后约 1 小时)
- **审查触发**:scope=mixed — meta 部分 `setup.sh`(F 组),其他 4 文件 scope=none(`docs/references/recommended-tools.md` / `docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md` / `docs/ROADMAP.md` / `docs/decision-trail.md`)
- **流程归属**:M1 §3 Step B → M2 §3 流程
- **流程架构**:扁平 fork(M2 §3.1 工具层并行 — 单 turn 一次 4 调用)
- **挑战者数量**:4(D6 弹性 N — 主题为快速 reframe,采用 bootstrap 4 维基线)
- **agent 模态**:对抗式(M2 §6 子节 1)
- **改动主题**:glassbox 角色从"P2 集成空间维度"reframe 为"用户级外部工具,harness 推荐不分发"。harness 仅:`docs/references/recommended-tools.md` 永久记录 URL(harness 仓库内,**不分发下游**)+ setup.sh 末尾 echo 推荐段(下游可见)
- **背景**:用户(2026-04-28)指出 glassbox 是个人工具不归项目管,推动 P2 空间维度从"集成依赖"降级为"用户级推荐"

## 2. 维度选取

### A. 推荐维度清单

- 核心原则合规:F 系列 / 用户 feedback memory / 1 小时内 reframe 节奏 [默认启用: 是]
- 目的达成度:防找错 / 提示安装 / 用户实际是否会装 [默认启用: 是]
- 副作用:URL 散落同步成本 / 维护规则完整性 / 下游污染 / scope=mixed covers 范围 [默认启用: 是]
- scope 漂移:setup.sh cp 行为 / scope.conf 边界 / 下游分发清单 / 上游 decision 关系 [默认启用: 是]

### B. 最低必选维度(bootstrap 4 维基线 — 强制)

- 核心原则合规
- 目的达成度
- 副作用
- scope 漂移

### C. 本次定制

- 启用的推荐维度:全 4 维(=B 段最低必选)
- 禁用的推荐维度 + 理由:无
- 新增的定制维度 + 理由:无

## 3. 挑战者执行记录

### 挑战者 1:核心原则合规(verdict: 待修)

**问题清单**:
- [Low] decision file 整体 — judgment_basis 通过(理由基于事实 + 逻辑,无市场判断)
- [Medium] decision file §问题 + §方案 — choice_visualization 表面达标(A/B/C/D 都列 ✅/❌),但缺 4 维一致量化对照轴,§决定理由几乎全是 D 优点
- [High] decision file §决定 — dimension_addition_judgment 反向追问未显式记录(用户给"glassbox 是用户级工具"判断后直接接受为前提)
- [Medium] decision file §唯一维护负担 — spec_gap_masking 边缘:"完全符合不强加精神"是封闭式陈述,1 小时前刚立 P2 没经任何真实用户尝试就断言
- [Low] §后续 — realworld_testing 通过(链接保鲜 / 用户使用反馈推 P1)
- [Low] 全方案 — skill_no_cross_project 通过(不分发外部工具到目标项目)
- [High] 节奏问题 — 1 小时内 reframe 自己刚立的 P2,decision file §关联 仅间接提及,应显式承认上游 1144f6a 未推演 glassbox 形态

**理由**:choice_visualization 对比轴未一致量化 + dimension_addition_judgment 反向追问未显式记录 + 1 小时内 reframe 因果链未在 decision file 显式承认上游推演不足

### 挑战者 2:目的达成度(verdict: 待修)

**问题清单**:
- [Medium] URL 在 4 处出现(setup.sh + recommended-tools.md + decision file + ROADMAP)— 无单一权威源,链接保鲜规则虽写在 recommended-tools.md 但仅"手工"约束
- [Low] setup.sh 末尾推荐段位置:第 7 屏 echo 后,被读到概率 OK 但易被当作"额外信息"忽略
- [Low] decision file §不做 — 漏列"不做使用文档示例"(harness 不写"装了 glassbox 后怎么配合 harness 流程用")
- [Low] recommended-tools.md "使用关系"段没说**怎么用** / 对哪类 session 有帮助 / 哪个阶段用得上 — 防找错 ✅ 但促装 ✗
- [信] ROADMAP P2 commit timing — "立 + 同日 reframe"已 transparently 记入 ROADMAP L188,不构成"承诺反复"
- [信] decision file §维护负担 — "零成本"略乐观,实际还有推荐文案润色 / 用户问询响应

**理由**:"防找错"基本达成,但"促装"不足 — 装它解决什么具体问题没说,建议 recommended-tools.md 加 1-2 句"装了能干什么"的具体场景

### 挑战者 3:副作用(verdict: 待修)

**问题清单**:
- [Medium] recommended-tools.md §维护规则 — 漏列 ROADMAP / decision file 同步点(实际同步 4 处不是 2 处),低估同步成本
- [Medium] URL 在 3 处 hardcoded(setup.sh / recommended-tools.md / ROADMAP)— 改名 / 迁移需 3 同步,无单一权威源;可让 setup.sh echo 改为指向 recommended-tools.md 不重复 URL,降低 80% 同步面
- [Low] setup.sh 末尾 6 行 echo 当前仅 1 个推荐工具尚未屎山;5+ 项时退化为单 echo + 引用文件
- [Medium] recommended-tools.md 全文缺"链接活性校验机制" — 无 hook / cron 检查 URL 200,长期会出现 glassbox 仓库消失而 harness 不知道
- [Low] docs/references/ 选址 — 它们是项目内复用模板,本文件是外部链接索引,但 multi-agent-review-guide 也是非模板说明文档,选址尚算合理
- [Medium] scope=mixed → covers 应只列 setup.sh,不列其他 4 个 none 文件 — 调度者发起本审时若把 5 文件全 cover 即违 §7.4
- [Low] decision-trail append 在自指条上方插 — 不破坏自指起点语义(自指条仍是最早引入条)

**理由**:URL 3-4 处散落 + 维护规则段漏列同步点,长期同步成本被低估,需补 4 处同步点 + 降级 setup.sh 末尾 echo 不重复 URL

### 挑战者 4:scope 漂移(verdict: 待修)

**问题清单**:
- [Low] scope.conf 不需要更新 — recommended-tools.md 是链接清单非治理模板,与 multi-agent-review-guide / testing-standard / MODULE_DOC_TEMPLATE 同型(均在 references/ 但均不在 scope 内)
- [Low] D12 命名前缀过滤不影响 — recommended-tools.md 不带 meta-* 前缀
- [Medium] **下游污染语义边界** — recommended-tools.md L1 "**不归任何项目管**" 与 setup.sh cp 把它分发进每个目标项目自相矛盾;用户级工具应只在 harness 仓库内**单点**记录,setup.sh `echo` 输出 URL 即够
- [Medium] setup.sh echo 段引入 P2 概念到下游 stdout — `echo "P2 空间维度"` 把 P0/P1/P2 治理体系阶段名暴露给下游用户(下游用户没有 P0/P1/P2 上下文),应改为纯功能描述
- [Low] ROADMAP P2 reframe 语气已收敛(从"双层闭环 P1 跑 1 次"承诺降为纯否定承诺易兑现);残余"P1 至少跑 1 次"已限定到 decision-trail 而非 glassbox 集成
- [Low] 与上游 decision 关系:`2026-04-28-decision-trail-introduction.md` 仅声明 glassbox "外部仓库参考"未指定形态,本 decision 真细化"形态=纯推荐",非重复;§关联 已显式标注"二者并列",pass
- [Low] audit covers 范围:本次 covers 应只列 `setup.sh`,其他 4 文件 scope=none 信息走 ROADMAP / decision-trail 索引

**理由**:scope.conf / D12 / 上游 decision 关系均 pass,但 setup.sh `cp recommended-tools.md` 把"不归项目管"的工具表强制分发进每个目标项目自相矛盾 + echo 段暴露 P2 阶段名给下游 — 属轻度 scope 漂移到下游污染

## 4. 综合

### 共识发现(高一致性)

| 共识点 | 挑战者交叉 | 严重性 |
|---|---|---|
| **setup.sh cp recommended-tools.md 与 "不归项目管" 自相矛盾(下游污染)** | 4(单挑战者发现,但语义结构性) | High(自相矛盾) |
| **setup.sh echo 暴露 P2 阶段名给下游** | 4 | Medium |
| **URL 散落 3-4 处,无单一权威源,同步成本被低估** | 2 + 3 | Medium |
| **recommended-tools.md 维护规则段漏列 ROADMAP / decision file 同步点** | 3 | Medium |
| **decision file choice_visualization 缺一致量化对照轴** | 1 | Medium |
| **decision file §关联 应显式承认上游 1144f6a 未推演 glassbox 形态** | 1 | High |
| **recommended-tools.md 缺"装了能干什么"具体场景**(降低促装动机) | 2 | Low |

### 分歧

无重大分歧。4 挑战者 verdict 一致"待修",修补方向明确。

### 盲区

- **链接活性校验**:挑战者 3 提"无 hook / cron 检查 URL 200"— 但 P0.9.1 治理原则是"光谱 B+ 最小硬 hook",不应轻易加 hook。推 P0.9.2 诊断阶段评估
- **多推荐工具屎山风险**:挑战者 3 提 5+ 项时 setup.sh echo 段会臃肿 — 但当前仅 1 项,推后续累积时再考虑

## 5. 判定

### 初判:needs-revision

**理由**:setup.sh cp recommended-tools.md 与"不归项目管"自相矛盾(High);setup.sh echo 暴露 P2 阶段名给下游污染(Medium);维护规则段漏列同步点(Medium);choice_visualization / dimension_addition_judgment / 节奏承认等 polish(Low-Medium)

### 修订动作(P0+P1+P2)

**P0(必修 — 自相矛盾 + 下游污染)**:
- ✅ setup.sh 删除 `cp recommended-tools.md` 行,加注释说明"不分发下游"
- ✅ setup.sh 末尾 echo 改"P2 空间维度"为"AI 工作 session 内可视化"(去 P 阶段名)
- ✅ recommended-tools.md 维护规则段补"本文件不分发下游"声明

**P1(必修 — 维护成本)**:
- ✅ recommended-tools.md 维护规则段 URL 同步点列 4 处(本文件主权威源 + setup.sh + ROADMAP + decision file)

**P2(选修 — polish)**:
- ⏳ recommended-tools.md 加"装了能干什么"具体场景(挑战者 2 动机增强)— 未做(选修,不影响主功能)
- ⏳ decision file §不做 加"不做使用文档示例"(挑战者 2)— 未做(选修)
- ⏳ decision file §关联 加"承认上游 1144f6a 未推演 glassbox 形态"(挑战者 1)— 未做(选修,本 audit 已记录因果)
- ⏳ decision file 方案 A/B/C/D 4 维一致量化对照轴(挑战者 1)— 未做(选修)

### 终判:pass(after revision)

P0 + P1 修补落地后,自相矛盾已解(setup.sh 不分发 recommended-tools.md;echo 段不暴露 P2 阶段名);维护成本可控(同步点 4 处显式列)。P2 polish 项不影响主功能,后续累积反馈再补。

### 后续

- **链接保鲜**:每次 P0.9.x 落地或 P1 启动时复核 URL 有效性
- **多工具扩张**:第 2 个推荐工具加入时,重审 setup.sh 末尾 echo 段策略(单 echo + 引用文件 vs 多行)
- **用户实际使用反馈**:P1 真实项目验证时观察用户是否真去装 glassbox / 装了用得多不多(数据反哺 P0.9.x 后续)

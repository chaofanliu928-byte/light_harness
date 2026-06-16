---
audit: true
covers:
  - docs/governance/touchpoint-registry.md
  - docs/governance/credentials-rules.md
---

# audit:触点机读注册表(知识系统 Step2 ③a — 治理面收口凭证)

> 本批 = 知识系统 Step2「★ 设计层到手边」的 **③a 触点机读注册表(地基)**:新建 `docs/governance/touchpoint-registry.md`(13 触点机读表 = credentials §8 的机读派生形 + 体检散落触点)+ credentials §8 加第9条(§8↔registry 派生双写)& 半句指针。**MVP 只建注册表数据,不建检测机制**(那是 ③b);现状列全标"待③b查"。它是 ③b 漂移检测的喂料地基。covers = 命中凭证的 2 governance 文件。

## 1. 元信息

- 批次:触点机读注册表(③a);分支 `touchpoint-registry`
- 审查对象:touchpoint-registry.md 新建(13 行)+ credentials-rules §8(+指针 +第9条)+ 收口 2🟡 修订
- 凭证类型:对抗审查 audit(命中 credentials.conf:`docs/governance/*.md`×2)
- 模态:对抗式;治理审查 N=4(核心原则合规 / 副作用守住 / scope 漂移 / 触点完整性);单 turn 并行 fork(workflow `registry-audit`);synthesis-rules 事前中性 + 事后按证据综合
- **方向评估站位**:③a 是用户已拍板执行序(①修复→②B→③a→③b)中的地基步,无新方向;格式(结构化 markdown 表)用户已批准。故不跑方向评估,治理审查核"派生方向正确 + 守住不退化 + 注册表内部契约自洽"。
- 时间:2026-06-16 19:21

## 2. 维度选取

- B(bootstrap)取 核心原则合规 / 副作用守住 / scope 漂移;A 取 **触点完整性维**(本批本身即"触点登记表",其内部契约一致性是核心,必选)。目的达成度退化(=注册表准确即达成,由触点完整性核)。
- 禁用:安全扫描 / 流程审计 / 方向评估

## 3. 挑战者执行记录(4 独立 fork;git diff + 端点对源逐项实核)

- **核心原则合规**:verdict=**concern→已修订**(1🟡+2🟢)。最小变更(仅 ADD registry + §8 第9条/半句指针,§8 1-8 逐字零改)、派生方向(§8 上游/本表派生、反双写腐守则到位)、角色分离均合规。**1🟡(已修)**:registry L39 维护节判据"查 §8 条目数与本表行数对齐"自相矛盾(§8=9 条 vs registry=13 行,TP-09~12 来自体检无 §8 对应,计数恒不等),作为 ③b 权威 spec 会误导实现者 → **修订为覆盖/子集判据**("每条 §8 条目映射到本表唯一一行,§8⊆本表,不要求计数相等")。🟢:TP-03 硬行号锚(下方修订)。
- **副作用守住**:verdict=**pass**(5🟢)。`diff §8 第1-8条` = BYTE-IDENTICAL;12 个拷贝组对端文件(credentials.conf/review-rules/CLAUDE×2/AGENTS×2/workflow.js/setup.sh/freshness-rules/scout/design-review·evaluate SKILL)git diff 全 UNCHANGED;对账三命令零改;preferences frontmatter 零改;本批纯 ADD(registry 新建 + §8 +3 行,0 删改);抽样端点对端核无悬空。
- **scope 漂移**:verdict=**pass**(5🟢)。MVP 守住(无 hook/scout/.sh 被加,grep 全文无检测代码;13 行现状全"待③b查");13 触点端点全真实(12 distinct 端点文件存在 + 锚实证,无臆造);去重正确(AGENTS.md 按子锚 TP-05/08/10 区分三个互不重叠同步面;TP-06/07=§8#6/7 未在体检行重列);§8 第1-8条零删除、第9条显式自限"与第5条独立不并入"。
- **触点完整性**:verdict=**concern→已修订**(1🟡+2🟢)。抽样 6 行端点对真实文件存在、判据类型恰当;§8 第9条↔TP-13 互指闭环、派生口径两侧一致;§8 第9条"与第5条独立"成立;现状全"待③b查"。**1🟡(已修)**:TP-12 类型列填了"单源派生一致"(一个判据值,不在类型 enum{双写对/同核拷贝组/分发链/漂移点})→ ③b 解析会撞未识别类型 → **修订 TP-12 类型=漂移点(spec↔代码)**(freshness-rules=spec 权威/scout=派生),判据保留"单源派生一致"。🟢:TP-13 来源"本表自身"→**修订为"§8 第9条"**(与全表口径规整);TP-03 行号锚(同上)。

## 4. 综合(synthesis-rules 事后规则,按证据不数票)

- **共识**:副作用守住 + scope 漂移 pass(§8 1-8 字节零改、12 端点文件 UNCHANGED、MVP 无检测代码、13 触点真实去重正确);核心原则 + 触点完整性 concern,2🟡 均关乎"注册表作为 ③b 机读喂料地基的内部契约自洽"——这正是触点完整性维该抓的(本表是触点登记表,自身契约破坏 = ③b 地基不可靠)。
- **真修订(2🟡,已落地)**:① L39 判据 计数相等→覆盖/子集判据(§8⊆registry,不要求计数等)② TP-12 类型 判据值→漂移点(spec↔代码) enum 值。+ 2🟢 顺手修(TP-13 来源→§8 第9条 / TP-03 去行号锚留语义锚)。修订仍命中凭证(registry governance glob,已在 covers)。
- **meta**:③a 把人工散文双写对结构化成 ③b 可机械消费的注册表——这次审查恰好暴露并修掉了"注册表自身的列契约/判据契约"两处不自洽,正是 registry 作为机读 spec 必须自洽的体现。
- 无新决策拐点(③a 是已拍板执行序的地基步)。

## 5. 判定

**verdict: pass-after-revision**(4/4 挑战者:副作用守住/scope pass;核心原则/触点完整性 concern→2🟡 收口修订落地)。本 audit covers 命中凭证 2 文件(touchpoint-registry.md / credentials-rules.md)。守住:credentials §8 第1-8条逐字零改 + 12 拷贝组对端文件 + 对账三命令 + preferences 零改实证。13 触点机读表内部契约修订后自洽(类型/判据 enum 守、覆盖判据可实现、自登记口径规整)。MVP 守住(只建数据,现状全待③b查)。知识系统 Step2 ③a 地基 可收口;下一步 ③b 漂移检测机制(注册表之上)。

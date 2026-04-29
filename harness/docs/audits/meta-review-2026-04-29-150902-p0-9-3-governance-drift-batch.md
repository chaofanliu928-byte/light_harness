---
meta-review: true
covers:
  - .claude/hooks/check-meta-cross-ref.sh
  - .claude/hooks/check-meta-cross-ref-commit.sh
  - .claude/hooks/check-meta-review.sh
  - .claude/hooks/check-meta-commit.sh
  - .claude/settings.json
  - docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md
  - docs/superpowers/plans/2026-04-29-p0-9-3-governance-drift-detection-batch-plan.md
  - docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md
  - docs/governance/meta-finishing-rules.md
  - docs/governance/meta-review-rules.md
verdict: pass-after-revision
date: 2026-04-29
challengers: 4+2
revision_rounds: 1
---

# Meta-Review: P0.9.3 第一个 trial — governance 漂移检测兜底 batch

## 1. 元信息

- **改动主题**:P0.9.3 第一个 trial — governance 漂移检测兜底 batch:(vii-a) M3 hook 不可见(repo 根扫描段加 check-meta-review.sh + check-meta-commit.sh)+ (互引-a) cross-file 互引 anchor 完整性检测(独立新建 check-meta-cross-ref.sh + check-meta-cross-ref-commit.sh)
- **scope**:meta(B 组 hooks 4 文件 + B 组 settings.json + 配套 D 组 docs metadata)
- **改动范围**:
  - `.claude/hooks/check-meta-cross-ref.sh`(新建,159 行)
  - `.claude/hooks/check-meta-cross-ref-commit.sh`(新建,134 行)
  - `.claude/hooks/check-meta-review.sh`(改 §5.5 段 + R1 stderr warning + early-exit guard 删,共 +28+R1+早退删)
  - `.claude/hooks/check-meta-commit.sh`(改 §5.5 段 + R1 + early-exit 删 内嵌,+37/-4)
  - `.claude/settings.json`(Stop 段加 check-meta-cross-ref.sh,Stop hook 数 5,+4 行)
- **trial 序号**:P0.9.3 第一个 trial(P0.9.1.5 整体闭合后首个独立 trial)
- **brainstorming 当天**:2026-04-29(用户:"如果没有新任务的话,进行 P0.9.3 candidates")
- **meta-review 实际 fork 时间**:2026-04-29 15:09:02
- **挑战者数**:4(D1 / D2 / D3 / D4 — bootstrap 4 维基线 对抗式 模板)+ 第 2 轮(待补)
- **使用 model**:挑战者全用 sonnet(general-purpose subagent;implementer 早期已用 haiku)
- **关联**:
  - spec:`docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md`
  - plan:`docs/superpowers/plans/2026-04-29-p0-9-3-governance-drift-detection-batch-plan.md`
  - decision file:`docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md`
  - 上游决策(P0.9 自治理):`docs/decisions/2026-04-17-harness-self-governance-gap.md`
  - 同期 trial 链:M0(`meta-review-2026-04-28-215638-m0-delete-block-dangerous.md`)→ M1+M2+M4(`meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md`)→ 本 trial

## 2. 维度选取

按 `harness/docs/governance/meta-review-rules.md` §6 子节 1 对抗式 pattern,选 bootstrap 4 维基线(任何 meta 改动必选):

### 本次定制
- **启用的推荐维度**:无新增推荐(基线 4 维已覆盖本次审查需求)
- **禁用的推荐维度 + 理由**:无禁用
- **新增的定制维度 + 理由**:无新增
- **本次具体维度焦点**:
  - **D1 核心原则合规**:9 条用户 feedback 原则(judgment_basis / spec_gap_masking / iterative_progression / unprovable_in_bootstrap / dimension_addition_judgment / design_philosophy / choice_visualization / realworld_testing_in_other_projects / 非本 trial 涉及的 skill_no_cross_project)+ harness 治理范畴 + bootstrap 自指接受 + scope 判定逻辑
  - **D2 目的达成度**:(vii-a) 真解决 M3 hook 不可见?(互引-a) cross-file 检测有效?实施过程修补(R1 + early-exit)是否真闭合?5 场景验证覆盖度?YAGNI vs DRY trade-off 反向追问?
  - **D3 副作用**:合法工作流是否被阻塞 / 下游污染 / 既有治理冲突 / 维护负担(5 Stop + 3 pre-commit hook 链)/ 性能 / shell 安全 / 跨平台
  - **D4 scope 漂移**:应改未改(grep 验证)/ 多改了 / M3 §3 §5 同步项 / scope.conf 数据更新 / handoff / ROADMAP / decision-trail / 不做条目论证充分性 / 新发现 M3/M4 路径混淆推后定性

scope=meta,evidence depth 文件按 `meta-review-rules.md` L286 引 `docs/governance/meta-finishing-rules.md` 内含的 meta-L1~meta-L4。

## 3. 挑战者执行记录

### 挑战者 1(D1 — 核心原则合规)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P0) — `feedback_judgment_basis` 原则违反:spec §1.2 / §9.3 Q1 用"高频改动路径"作 (vii) 修复必要性论据,但无实测数据
- **位置**:spec §1.2 场景 1 + §9.3 Q1 答语
- **证据**:Q1 答语用"M3 是高频改动路径"作 (vii-a) 修复必要性背书,但无 git log 实测数据;`feedback_judgment_basis.md` 明确禁止"无 P1 实证用'高频/多数/大部分'词作论据"
- **建议修补**:删"高频改动路径"措辞;改为纯逻辑论据 — "M3 scope 判定 / 治理表的真值在此;若改动不入 scope,治理流程的元信息处于失同步风险下,这是结构性缺口而非频率问题"

#### F2 (P0) — `feedback_spec_gap_masking` 原则违反:bootstrap 自指 #4 缺口被"接受"措辞掩盖关键漏洞
- **位置**:spec §9.4 #4
- **证据**:实际现状 spec/plan/decision file 三文件至本 audit 时仍未 commit,且都是 D 组(specs/plans/decisions 不在 INCLUDE_GLOBS),hook 不会拦;#4 用"M3 / 互引文件"窄化范围,**便利答案掩盖更宽的实际豁免范围**
- **建议修补**:重写 §9.4 #4 — "bootstrap 自指多重豁免:① hook 文件 commit 自身不被新 hook 拦(settings 注册前);② spec/plan/decision file 落地不入 scope;③ 本次 meta-review fork 是首次,无既有 audit covers — 三层豁免共同走 manual M2 fork。任何 P0.9.x 第一个 trial 都受同样豁免"

#### F3 (P1) — `feedback_dimension_addition_judgment` 反向追问机制 Q2 / Q3 应用不彻底
- **位置**:spec §9.3 Q2 + Q3 答语
- **证据**:Q2 没问"如果不写死,用什么替代?";Q3 引"长 session 不 stop"作必要性 = 用未来无数据场景反证"现在加 pre-commit 必要" → 与 `feedback_judgment_basis` 冲突;最后一句"用户已批准 D1 不再独立质疑"等于关闭 spec 自检
- **建议修补**:Q2 加真正反向追问;Q3 改为承认"Stop 覆盖 99% 场景下 pre-commit 是 1% 兜底冗余,本 trial 无实证支撑"+ 删"用户批准本 spec 不质疑"措辞

#### F4 (P1) — `feedback_iterative_progression` 原则违反:spec §9.4 #6 隐含"P0.9.3 整体闭合需未来多 trial"等于预设阶段
- **位置**:spec §9.4 #6
- **证据**:句式"P0.9.3 整体闭合需未来多 trial 累积"等于把 P0.9.3 视为"待累积才闭合的预设阶段",违反 `feedback_iterative_progression`
- **建议修补**:#6 改为 — "single trial 仅做 2 项;P0.9.3 标识符不绑定预设阶段。后续若实战暴露新需求再开新 trial,由实际需求拉动"

#### F5 (P1) — meta-L1 inline 验证范畴未声明(`feedback_realworld_testing_in_other_projects`)
- **位置**:spec §6.3 + §9.4 #3
- **证据**:5 场景验证全部在 harness 自仓库 artificial 构造;spec 没显式声明"本 inline 验证仅证明 syntactic / 结构性正确,不证明实战有效性"
- **建议修补**:spec §6.3 加新句声明 inline 验证范畴边界

#### F6 (P2) — bootstrap 自指接受声明应区分两种自指
- **位置**:spec §9.4 #4
- **证据**:`feedback_unprovable_in_bootstrap` 区分两种 self-reference;#4 把"hook 改动 commit 自身不被新 hook 拦"列为"接受"的 bootstrap 自指,实际属于第二种(具体可证 + 显式列出的执法绕过路径)
- **建议修补**:#4 末尾加 — "本豁免不是 unprovable_in_bootstrap,而是 spec 显式列出的'初次 commit 执法窗口空缺'(可证缺口);接受是因为 manual M2 fork 兜底"

#### F7 (P1) — `feedback_design_philosophy` "变更也要先改文档"原则的执行顺序倒置
- **位置**:decision file §不做"不修 plan / spec 文档"段
- **证据**:R1 + early-exit fix 在 commit 后未同步回 plan / spec;decision 用"避免反复改"理由把"变更先改文档"原则推迟
- **建议修补**:decision §不做 改为承认违反;立缺口 #11 — plan/spec 与实施代码不同步,trial 闭合后第一件事统一修订(本 audit 修补会一并完成)

### 挑战者 2(D2 — 目的达成度)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P0) — (vii-a) 对 untracked + 未 staged 路径漏检
- **位置**:check-meta-review.sh §5.5 L221-223;check-meta-commit.sh §5.5 L219;spec §3.1 + §5 R3 + §6.1 测试场景 1
- **证据**:`git diff --name-only` + `git diff --cached --name-only` 都不输出 untracked 新文件;新仓库初始化时 M3 全新建走 untracked 路径漏检;spec §1.2 场景 1 未声明"对 untracked 文件无效" — 是声称解决但实际未完整解决
- **建议修补**:hook §5.5 加 `git ls-files --others --exclude-standard` 扫 untracked;或 spec §1.3 / §5 边界条件显式声明"untracked 不在 hook scope,需 git add 后才生效"+ stderr 加引导

#### F2 (P1) — 5 场景验证 R1 stderr warning 代码路径**实际未被触发**
- **位置**:check-meta-review.sh L217-219;decision file `meta-L1 inline 验证` 表 R1 行;plan Task 6 Step 3
- **证据**:fixture 是在 harness 子目录 init,不在 repo 根,走 `if [ ! -d "$ROOT_DIR/.git" ]` 整 if 跳过 → R1 warning 路径根本不进入;decision 表"实际:✅ exit 0 + '⚠️ repo 根 git -C 调用失败'"写错 — 实际是 silent skip,无 stderr 输出
- **建议修补**:补 fixture(在 ROOT_DIR 内手动 corrupt .git),验证实际看到 stderr;decision file `meta-L1` 表对 R1 行更正实际行为或标"未触发,代码 dead path"

#### F3 (P1) — (vii-a) 闭合声称与实际能力的精度落差(M3/M4 路径混淆未修)
- **位置**:decision file §"Secondary bug 发现"+ spec §9.4 #10
- **证据**:hook 把 `CLAUDE.md` 当统一字符串处理 — 写 covers 只覆盖 M4 的 audit 仍能让 M3 改动 pass(false negative);spec §1.1 用户目标若解读为"M3 改动需 audit 覆盖",未达成
- **建议修补**:spec §1.1 / §1.2 显式描述精度边界:"本 trial 让 hook 看见 M3,但 audit covers 比对精度限于 'CLAUDE.md 字符串'(M3 / M4 不可区分);精确比对推 P0.9.4"

#### F4 (P2) — cross-ref hook trigger case 子串包含匹配,在 staged `.bak` / `.old` 等文件触发无谓 grep
- **位置**:check-meta-cross-ref.sh L88-91;check-meta-cross-ref-commit.sh L64-67
- **证据**:case "$DIFF_FILES" 用 *...* 子串匹配;`design-rules.md.bak` 命中 trigger;无 false positive,但触发时机过宽
- **建议修补**:case 改用循环逐行匹配 / 字段分隔精确匹配(P2 知会即可)

#### F5 (P2) — cross-ref hook anchor grep -F 全文匹配,潜在 false negative
- **位置**:check-meta-cross-ref.sh L113;check-meta-cross-ref-commit.sh L88
- **证据**:hook 不约束 anchor 出现的语境,只校验字面是否存在文件任意位置;若用户把 anchor 字面拷到 changelog/注释但删了真实互引段 → false negative
- **建议修补**:spec §9.4 立缺口"grep -F 全文匹配的 false negative 风险 — 接受,P0.9.2 实战观察"

#### F6 (P2) — Stop hook + pre-commit hook 双触发体验 + 重复
- **位置**:settings.json Stop 段
- **证据**:同 session 内已 commit 但 Stop event 又跑同样检查;增加 cognitive load
- **建议修补**:stderr 加"已通过 pre-commit;Stop 二次防护"提示;或 P0.9.2 观察是否构成噪声

### 挑战者 3(D3 — 副作用)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P1) — `CLAUDE.md` 主扫 + §5.5 同时命中导致报告"× 2",M3/M4 不可区分
- **位置**:check-meta-review.sh L192(主扫)+ L213-238(§5.5 段)
- **证据**:实测改 root CLAUDE.md 时 stderr:`改动的 meta 文件: - CLAUDE.md - CLAUDE.md`;decision §"Secondary bug" 已识别但推 P0.9.4
- **副作用机制**:用户看到两条相同 `CLAUDE.md` 不知道哪条对应哪文件;bootstrap 自指更糟
- **建议修补**:§5.5 push CHANGED_META_FILES 前去重(grep -Fxq);或更深 § §5.5 push `<root>/CLAUDE.md` 字面前缀;至少在 spec / decision 把 recurring 副作用列入 §9.4 已知缺口正式条目

#### F2 (P1) — pre-commit cross-ref hook 文件存在但实际从未触发,decision §双注册声称名不副实
- **位置**:check-meta-cross-ref-commit.sh + `.git/hooks/pre-commit`(实测不存在);spec §1.5 D1 + decision file
- **证据**:harness 自仓库 pre-commit 默认未软链;光谱 B+ "双拦最稳"在 harness 自仓库实际是单拦
- **副作用机制**:维护负担(改 PAIRS 需 4 hook 同步,但 commit hook 实测不生效);审查盲区(无法做真实 pre-commit 验证)
- **建议修补**:decision / spec 显式声明 pre-commit 实际未触发;spec §9.4 加新缺口;或考虑删除两 commit hook(YAGNI 一致性)

#### F3 (P2) — `set -u` + `ROOT_DIFF` unbound 风险检验
- **证据**:实测 R1 fix 已覆盖 ROOT_DIR 解析失败 + git -C 健康检查失败两路径;set -u 风险不存在
- **建议**:无需修补,信息项保留

#### F4 (P1) — 用户重命名 anchor(合理操作)被 hook 阻塞
- **位置**:check-meta-cross-ref.sh PAIRS L98-103;decision §已知缺口 #2
- **证据**:用户重命名 anchor 是合理操作,hook 误判为 anchor 缺失阻塞 Stop;改 PAIRS = scope=meta 触发 meta-review 嵌套
- **建议修补**:decision file 把 spec §9.4 #2 升级为正式 P1 条目并描述 P0.9.4 解法路径;短期 mitigation:hook stderr 加引导

#### F5 (P1) — Stop hook 链 5 个,任一 exit 2 阻断,用户体验 / 字段名混淆
- **位置**:settings.json Stop 段;spec §2.2
- **证据**:用户必须区分 `## meta-review: skipped` vs `## meta-cross-ref: skipped`;新用户混淆字段名
- **建议修补**:cross-ref hook stderr 提示"必须使用 `## meta-cross-ref: skipped`(不同字段)";或 finishing-rules.md 加表列各 hook 对应字段

#### F6 (P2) — `.gitignore` 排除 `.claude/` 引发"另一会话改 hook 不被察觉"风险
- **位置**:`/.gitignore` L2;decision §杂项注
- **证据**:hook 文件被改后 `git status` 不报,session 末 commit 默认不会包含
- **建议修补**:加入 spec §9.4 已知缺口

#### F7 (P2) — decision-trail.md 改动属 scope 外,但 hook stderr 引导误指引
- **建议修补**:hook stderr 末尾加"非 scope 改动(ROADMAP / handoff / decision-trail)无需 covers"

#### F8 (P2) — Windows / Mac / Linux 跨平台 sed -i 在 plan inline 验证脚本未通用
- **建议修补**:plan Task 1-6 inline 验证 sed -i 改用 sed -i.bak / rm *.bak 模式(GNU/BSD 通用)

#### F9 (P2) — anchor 含 §(U+00A7)非 ASCII,跨编辑器 / OS 编码风险
- **建议修补**:cross-ref hook stderr 加"检 design-rules.md / finishing-rules.md 文件编码是否仍为 UTF-8";或 spec §9.4 加缺口

### 挑战者 4(D4 — scope 漂移)

**Verdict**:needs-revision

**Finding 列表**:

#### F1 (P0) — 新 skip 字段 `meta-cross-ref` 未在 M1/M2 治理体系登记 — 孤儿规则
- **位置**:hook L129/L156/L190 硬编码 `## meta-cross-ref: skipped(理由: ...)`;M1 §5.1 + M2 §9 仅登记 `meta-review: skipped`
- **证据**:本 trial 创了第二个 hook-driven skip 字段名,但治理 SSoT(M1 §5、M2 §9)仍只声明一个字段;调度者读 M1 不会知道存在新字段;治理文档与 hook 行为脱节 = scope 漂移(B 组 hook 暗中扩展 A 组治理契约)— 这正是本 trial 试图修复的"cross-file 互引脆弱性"同构问题
- **建议修补**:M1 §5 加 "字段 3:`## meta-cross-ref: skipped`"(格式 + grep regex + 覆盖语义)+ §5.3 改"三字段共存约束";M2 §9 同步加该字段

#### F2 (P0) — PAIRS 4 条 anchor **漏检 3 处实际互引**
- **位置**:check-meta-cross-ref.sh:98-103
- **证据**:实际互引清单(grep 验证):
  - design-rules.md → finishing-rules.md:**L28**(规模判断表第 4 列)+ L45 — 共 2 处
  - finishing-rules.md → design-rules.md:**L3、L5**(scope 分流入口)+ **L14** + L38 + L39 — 共 5 处
  - PAIRS 实际覆盖:design-rules.md L38 anchor + L45 + finishing-rules.md L39 (×2 anchor 同行)— 共 3 个独立检测点,2/5 互引
  - 修复声明远超实际覆盖(spec_gap_masking)
- **建议修补**:**选 B 显式承认**(本 trial 不扩 PAIRS):spec §9.4 加新条 "PAIRS 仅覆盖 2/5 实际互引,其余 3 处删除 hook 不报警 — 接受,本 trial 仅做 anchor-anchor 1 对样本验证机制可行;后续 trial 可扩"

#### F3 (P0) — M3 §5 scope 内对照表未列 cross-ref hook 类
- **位置**:`/CLAUDE.md` L80(B 组 hooks + settings 段)
- **证据**:M3 §5 B 组列示当前 hook 类:`check-* / block-* / notify-* / session-init`;新增 `check-meta-cross-ref.sh` 命名前缀 `check-meta-` 与 `check-meta-review.sh` 同类,但 M3 §5 当前未细分;spec §1.3 + plan File Structure 表均独立列示 cross-ref 系列 — M3 与 spec 列示粒度不一致
- **建议修补**:决定 §5 是否细分 — 若 M3 §5 保持笼统(`check-*` 已涵盖),decision file 显式声明"M3 §5 不细分 cross-ref hook 类,理由:命名前缀 prefix `check-*` 已覆盖";若细分,M3 §5 加注释"含 check-meta-cross-ref* 类"

#### F4 (P1) — M22 module 编号未在 spec 锁定,handoff 自创"M22-1/M22-2"游离
- **位置**:handoff.md L33-34;主 spec(`2026-04-17-p0-9-self-governance-design.md`)模块表 M14-M21
- **证据**:cross-ref hook 未取 module 编号;handoff 自创 "M22-1 / M22-2";meta-finishing-rules.md L26 仍只引"M15 / M16",未补 M22
- **建议修补**:决定取或不取 module 编号 — 取则同步主 spec / M1 §1.2 / M2 §3.2;不取则 handoff 删 "M22-1/M22-2" 命名,改纯文件名引用(本 trial 选不取 module 编号 + 改 handoff,理由:cross-ref hook 是 P0.9.3 trial 内部产出,主 spec M14-M21 是 P0.9.1 锁定的核心模块表,不为后续 trial hook 全部加新 module 编号)

#### F5 (P1) — PAIRS 第 3、4 条 anchor 同行(finishing-rules.md L39),4 条 anchor 实际 3 独立检测
- **位置**:check-meta-cross-ref.sh:101-102
- **证据**:hook 注释 L26-27 自承认两 anchor 同行
- **建议修补**:**选 B 显式承认**(本 trial 不换 anchor):decision file §已知缺口加新条 "PAIRS 第 3/4 条同行,4 条 anchor 实际 3 独立检测;接受样本规模"(与 D4-F2 同语境 — 本 trial 仅证机制,不做覆盖度优化)

#### F6 (P1) — M3/M4 路径混淆 bug 推后 P0.9.4 论证不充分
- **位置**:decision file §"Secondary bug 发现"+ §不做
- **证据**:vii-a 闭合质量直接受路径混淆影响 — covers 比对精度受限;P0.9.4 何时启动未定;形成"识别-推后"链条违反 iterative_progression
- **建议修补**:decision file 补严肃论证 — "推后窗口期接受:中间任何 audit 标 `covers: [CLAUDE.md]` 时人工记忆 + handoff 显式标注规避(M3 改动时在 handoff '反审待办'段加 'CLAUDE.md = 根 M3' 注);本 trial 闭合后调度者人工兜底"

#### F7 (P2) — `harness/templates/settings.json` 验证项未在 spec §8.2 标 ✅
- **建议修补**:trial 闭合时核查 templates/settings.json 字面不含 cross-ref hook(D19 a 方案"零污染")

## 4. 综合(共识 / 分歧 / 盲区)

### 4.1 共识(多挑战者覆盖,优先修)

| 主题 | 触及挑战者 | 严重性 | 建议处置 |
|------|------------|---------|----------|
| **M3/M4 路径混淆** | D2-F3 + D3-F1 + D4-F6 | P1 共识(D2-F3 P1, D3-F1 P1, D4-F6 P1) | 修 spec §1.1 / §1.2 显式精度边界 + decision §"Secondary bug" 补充推后窗口期人工规避机制 + 立 spec §9.4 已知缺口正式 P1 条目;不在本 trial 内修 hook 路径区分逻辑(超 scope) |
| **PAIRS 漏检 3 处实际互引 + 同行重复** | D4-F2 (P0) + D4-F5 (P1) | P0+P1 | 修 spec §9.4 加新条显式承认 PAIRS 仅覆盖 2/5 实际互引 + 第 3/4 条同行;声明本 trial 仅证机制可行,不做覆盖度优化(YAGNI 一致) |
| **新 skip 字段 `meta-cross-ref` 未登记** | D4-F1 (P0) | P0 单一 | 改 M1 §5 加字段 3 + §5.3 改"三字段共存"+ M2 §9 同步加 |
| **untracked 漏检 (vii-a) 不完整** | D2-F1 (P0) | P0 单一 | 选 B 不修 hook(超 scope):spec §5 边界条件显式声明"untracked 不在 hook scope,需 git add 后生效"+ hook stderr 加引导;spec §9.4 加缺口 |
| **R1 stderr warning 未真正触发** | D2-F2 (P1) | P1 | 修 decision file `meta-L1` 表 R1 行 — 标实际"silent skip,代码 dead path,fixture 未造 git 损坏" |
| **pre-commit 双注册名不副实** | D3-F2 (P1) | P1 | spec §9.4 加缺口 "harness 自仓库 pre-commit 默认未挂,双注册防护层在 harness 实际单拦";不删 commit hook(下游 setup.sh 可能挂) |
| **bootstrap 自指多重豁免** | D1-F2 (P0) + D1-F6 (P2) | P0+P2 | 重写 spec §9.4 #4(三层豁免显式列示);区分 unprovable_in_bootstrap vs 显式列出的执法窗口空缺 |
| **judgment_basis 措辞 ("高频改动路径")** | D1-F1 (P0) | P0 单一 | 删 spec §1.2 / §9.3 Q1 中"高频改动路径"措辞,改纯逻辑论据 |
| **M3 §5 scope 内对照表未列 cross-ref hook 类** | D4-F3 (P0) | P0 单一 | decision 显式声明"M3 §5 prefix `check-*` 已涵盖,不细分"或 §5 加注释 |

### 4.2 分歧

无大分歧。各挑战者维度焦点不重叠,共识主题(M3/M4 / PAIRS / skip 字段)在多挑战者间一致认可。

### 4.3 盲区(挑战者忽略的)

- **性能基准**:无挑战者真测量了 Stop event 多增 1 次 git -C + 4 次 grep 的延迟(D3 提及但未量化)
- **跨平台 stat / sed 实测**:D3-F8 P2 提及 plan inline 验证脚本可移植性,但无挑战者实际在 macOS / 纯 Windows cmd 跑过
- **Claude Code Stop hook 顺序文档** :D3-F5 假设串行执行,但未引用 Claude Code 文档确认 — 若文档显示并行则 finding 失效
- **decision-trail / handoff 自循环检测**:D3-F7 提及 hook stderr 引导误指引,但无挑战者验证"修了 hook 又触发 hook 自身"的递归是否被防死循环段防住

## 5. 判定

**Final verdict**:`pass-after-revision`

### 5.1 两轮总览

| 轮次 | fork 范围 | verdict | 评语 |
|------|-----------|---------|------|
| 第 1 轮 | D1 / D2 / D3 / D4(4 挑战者扁平 fork) | needs-revision | 26 finding(P0=6 / P1=12 / P2=8) |
| 第 2 轮 | D2 / D4(2 挑战者验证修补) | D2=needs-revision(F1 + F6 仍待);D4=pass | D4 全 7 finding 闭合;D2 6 finding 中 4 闭合 + F1 修补不一致 + F6 遗漏 |
| 第 3 轮 修补 | 不再 fork(D2 挑战者明示"不需第 3 轮 fork") | 调度者修补 + self-verify | F1:**§5.5 hook**(check-meta-review.sh / check-meta-commit.sh)加 untracked stderr 引导(self-verify grep `untracked` 命中 2 hook;cross-ref hook 不需此提示因不受 untracked 影响,spec §5 R4 + §9.4 #11 已精确化此分工);F6:spec §9.4 #22 + decision §已知缺口 #22 立 P2 缺口 |

### 5.2 第 1 轮 finding 处置(原始 26 finding)

**P0 必修**(阻断本 trial 闭合,第 2 轮 D4 全 pass + D2 部分 + 第 3 轮调度者补完):
1. ✅ **D1-F1**:spec §1.2 / §9.3 Q1 删"高频改动路径",改纯逻辑论据
2. ✅ **D1-F2**:spec §9.4 #4 重写 bootstrap 自指多重豁免(三层显式列示)
3. ✅ **D2-F1**:spec §5 R4 + §9.4 #11 显式声明 untracked 漏检 + hook stderr 加引导(第 3 轮补完 4 hook)
4. ✅ **D4-F1**:M1 §5 加 `meta-cross-ref: skipped` 字段 3 + §5.4 改"三字段共存"+ M2 §9.3 同步加(D4 第 2 轮验 pass)
5. ✅ **D4-F2**:spec §9.4 #12 加新条 PAIRS 漏检 3 处实际互引(显式承认,不扩 hook)
6. ✅ **D4-F3**:decision file §不做声明 M3 §5 不细分 cross-ref(M3 §5 实际未改保持笼统)

**P1 必修**:
1. ✅ **D1-F3**:spec §9.3 Q2/Q3 反向追问补全 + 删"用户批准本 spec 不质疑"
2. ✅ **D1-F4**:spec §9.4 #6 改 — 删"P0.9.3 整体闭合需未来多 trial",改"single trial 仅做 2 项不绑预设阶段"
3. ✅ **D1-F5**:spec §6.3 加 inline 验证范畴边界声明
4. ✅ **D1-F7**:decision §不做"不修 plan / spec 文档"段改为承认违反 design_philosophy + audit revision 时统一修订
5. ✅ **D2-F2**:decision file `meta-L1` 表 R1 行更正 — 标实际"silent skip,fixture 未造 git 损坏 = dead path"
6. ✅ **D2-F3**:spec §1.1 / §1.2 显式 audit covers 比对精度边界(M3/M4 不可区分)
7. ✅ **D3-F2**:spec §9.4 #8 升级 "harness 自仓库 pre-commit 默认未挂,双注册防护层实际单拦"
8. ✅ **D3-F4**:decision file §已知缺口 #2 把 anchor 写死脆弱性升级为正式 P1 条目
9. ✅ **D3-F5**:cross-ref hook stderr 加"必须用 `## meta-cross-ref: skipped` 字段"提示
10. ✅ **D4-F4**:不取 M22 module 编号;handoff "M22-1/M22-2" 命名删除改纯文件名引用
11. ✅ **D4-F5**:spec §9.4 #12 加 PAIRS 第 3/4 条同行缺口
12. ✅ **D4-F6**:decision file §不做"不修路径混淆 secondary bug"段补"推后窗口期人工规避机制"

**P2 知会即可**:
1. ✅ D1-F6:bootstrap 自指接受声明区分(随 D1-F2 一并改)
2. ✅ D2-F4 / F5:cross-ref hook 触发精度 / grep -F false negative(spec §9.4 #20+#21)
3. ✅ D2-F6:Stop+pre-commit 双触发(spec §9.4 #22,第 3 轮补完)
4. ➖ D3-F3:set -u unbound 风险已覆盖(信息项保留,无修补)
5. ✅ D3-F6:.gitignore 排除 .claude/ 风险(spec §9.4 #17)
6. ✅ D3-F7:hook stderr 引导改进(本 trial 已加非 scope 改动提示)
7. ✅ D3-F8:plan inline 验证 sed -i 跨平台问题(spec §9.4 #19,plan 后续维护时加 platform note)
8. ✅ D3-F9:anchor 编码风险(spec §9.4 #18)
9. ✅ D4-F7:templates/settings.json 验证 ✅(spec §8.2 标 ✅)

### 5.3 第 2 轮 D2 + D4 验证 verdict

- **D4 第 2 轮**:pass — 7 finding 全闭合;反向论证段保留通过
- **D2 第 2 轮**:needs-revision(原本 6 finding 中 4 闭合 + F1 修补不一致 + F6 遗漏)— **第 3 轮调度者补**:
  - F1:4 hook(check-meta-cross-ref.sh / check-meta-cross-ref-commit.sh / check-meta-review.sh / check-meta-commit.sh)stderr 引导加 untracked 提示(self-verify:grep `untracked` 命中 4 hook)
  - F6:spec §9.4 #22 + decision §已知缺口 #22 立 P2 缺口
  - **第 3 轮不再 fork**:D2 挑战者明示"不需第 3 轮 fork";修补简单可机械验证

### 5.4 trial 数据点

- **第 1 轮 finding 密度**:26(P0=6 / P1=12 / P2=8)
- **历史对比**:M0(14 finding)/ M1+M2+M4(18 finding)/ 本 trial(26 finding)— **hook 实现 trial 比纯 governance 文档 trial 暴露 ~50% 更多 finding**(代码 + 治理 SSoT 双重对照)
- **共识主题集中度**:M3/M4 路径混淆(3 挑战者)+ PAIRS 漏检 + skip 字段未登记 — 三类都是"治理 SSoT 同步" + "声明覆盖度 vs 实际覆盖度"两类元主题
- **第 2 轮闭合率**:D4 全闭合;D2 4/6 闭合 + 第 3 轮补完
- **trial 价值**:**P0.9.3 第一个 meta-L4 数据点** — P0.9.1 治理流程对 hook 实现 trial 仍有效(初次 needs-revision + revision + 第 2 轮验证 + 第 3 轮调度者补完完整 cycle)

---

**第 1 轮 verdict 起始**:`needs-revision`

**P0 必修**(阻断本 trial 闭合):
1. **D1-F1**:spec §1.2 / §9.3 Q1 删"高频改动路径",改纯逻辑论据
2. **D1-F2**:spec §9.4 #4 重写 bootstrap 自指多重豁免
3. **D2-F1**:spec §5 边界条件显式声明 untracked 漏检 + hook stderr 加引导(选 B 不扩 hook)
4. **D4-F1**:M1 §5 加 `meta-cross-ref: skipped` 字段 3 + §5.3 改"三字段共存"+ M2 §9 同步
5. **D4-F2**:spec §9.4 加新条 PAIRS 漏检 3 处实际互引(显式承认,不扩 hook)
6. **D4-F3**:decision file 显式声明 M3 §5 prefix `check-*` 涵盖 cross-ref(或 §5 加注释)

**P1 必修**(闭合后必修,同期一并完成):
1. **D1-F3**:spec §9.3 Q2/Q3 反向追问补全 + 删"用户批准本 spec 不质疑"
2. **D1-F4**:spec §9.4 #6 改 — 删"P0.9.3 整体闭合需未来多 trial",改"single trial 仅做 2 项,不绑预设阶段"
3. **D1-F5**:spec §6.3 加 inline 验证范畴边界声明
4. **D1-F7**:decision §不做"不修 plan / spec 文档"段改为承认违反 design_philosophy + 立缺口 #11(本 audit 完成统一修订)
5. **D2-F2**:decision file `meta-L1` 表 R1 行更正 — 标实际"silent skip,fixture 未造 git 损坏"
6. **D2-F3**:spec §1.1 / §1.2 显式 audit covers 比对精度边界(M3/M4 不可区分)
7. **D3-F2**:spec §9.4 加缺口 "harness 自仓库 pre-commit 默认未挂,双注册防护层实际单拦"
8. **D3-F4**:decision file §已知缺口 把 anchor 写死脆弱性升级为正式 P1 条目
9. **D3-F5**:cross-ref hook stderr 加"必须用 `## meta-cross-ref: skipped` 字段"提示
10. **D4-F4**:不取 M22 module 编号;handoff "M22-1/M22-2" 命名删除改纯文件名引用
11. **D4-F5**:spec §9.4 加 PAIRS 第 3/4 条同行缺口
12. **D4-F6**:decision file §"Secondary bug" 补"推后窗口期人工规避机制"

**P2 知会即可**(documented 接受,不修代码):
1. D1-F6:bootstrap 自指接受声明区分(随 D1-F2 一并改)
2. D2-F4 / F5 / F6:hook 触发精度 / grep -F false negative / Stop+pre-commit 双触发(spec §9.4 加 P2 缺口或接受)
3. D3-F3:set -u unbound 风险已覆盖(信息项保留,无修补)
4. D3-F6:.gitignore 排除 .claude/ 引发"另一会话改 hook 不察觉"(spec §9.4 加 P2 缺口)
5. D3-F7:hook stderr 引导改进(本 trial 一并改 cross-ref hook stderr)
6. D3-F8:plan inline 验证 sed -i 跨平台问题(plan 文档加 platform note)
7. D3-F9:anchor 编码风险(spec §9.4 加 P2 缺口)
8. D4-F7:templates/settings.json 验证(trial 闭合时核查 — 本 trial 内做)

**revision 后第 2 轮 fork 范围**:
- D2(目的达成度)— 验证 untracked 漏检声明 + R1 dead path + M3/M4 精度边界修补
- D4(scope 漂移)— 验证 M1/M2 skip 字段同步 + PAIRS 漏检显式承认 + M3 §5 处置

第 2 轮 N=2,与 P0.9.1.5 第二个 trial(M1+M2+M4 batch)4+2 范式一致。

---

> **本 audit 不是认证,是 trial revision gate。** 第 1 轮 4 挑战者扁平 fork 共找 P0=6 + P1=12 + P2=8 = 26 finding;P0.9.1.5 trial 数据点对比:M0=14 finding,M1+M2+M4=18 finding。本 trial finding 密度高,反映"hook 实现 trial"暴露问题的特殊性(代码 + 治理 SSoT 双重对照)— P0.9.3 第一个 meta-L4 数据点:hook 实现 trial 比纯 governance 文档 trial 暴露 ~50% 更多 finding,且共识主题集中在"治理 SSoT 同步"+ "声明覆盖度 vs 实际覆盖度"两类。

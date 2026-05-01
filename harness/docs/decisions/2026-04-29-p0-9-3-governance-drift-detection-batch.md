# 决策: P0.9.3 第一个 trial — governance 漂移检测兜底 batch

**状态**:🟢 已决定(2026-04-29 用户拍板 + 实施完成)

**类型**:方案选择型(范围 A/B/C 选 A;形态 (vii-a)+(互引-a) 推荐组合)

**日期**:2026-04-29

**关联功能**:P0.9.3 第一个 trial — fix-9 (vii) M3 hook 不可见缺口修复 + audit §9.4 #6 cross-file 互引脆弱性 hook 兜底

## 问题

P0.9.3 ROADMAP 候选 5 项(我在本对话开始时新加 1 条 B 方案),brainstorming Q1 阶段按 fix-9 历史决策 + 当下可做性重排,识别 3 类:

- **当下真正可做**:
  - (vii) M3 hook 不可见(spec §1.3 fix-9 (vii)):有具体技术解(hook 加扫 repo 根)
  - cross-file 互引 hook 检测(2026-04-29 audit §9.4 #6):有具体技术解(独立 hook 写死 anchor)
- **占位等数据**:
  - (i) `--no-verify` 绕 pre-commit:推 P0.9.3,无实战数据不预防(`feedback_judgment_basis`)
  - (ii) 长 session 不 stop 漏 Stop hook:推 P0.9.3,光谱 B+ 设计代价
- **已 accept 关闭**:
  - (iv) 理由质量自律:spec §5 B18 + decision `2026-04-26-bypass-paths-handling.md` accept(governance 层 M2/M9 负责)
  - (vi) 下游改 harness 副本:同上 accept(setup.sh 末尾打印提示已实施)
- **弱主动需求**:
  - B 方案(主仓库 ↔ 下游版本漂移检测):用户原话"没有回流机制是没有问题的",`feedback_judgment_basis` 一致

## 范围决策(brainstorming Q1)

候选:
- **A. 仅做"当下真正可做"2 项**((vii) + 互引)
- B. A + B 方案
- C. 全 5 项强行 batch

**选择**:**A**

**理由**:
- (i)(ii) 等 P0.9.2 实战观察期数据(`feedback_judgment_basis`:无实战数据不预防)
- (iv)(vi) spec 已 accept 关闭,ROADMAP 列入是误登(本 trial 副产物:推 trial 完成后修正 ROADMAP)
- B 方案主动需求弱,`feedback_judgment_basis` 同样适用
- C 强行 batch 违反 `feedback_judgment_basis` + 重复 spec 已 accept 的(iv)(vi)

## 形态决策(brainstorming Q2)

### (vii) M3 hook 不可见修复

候选:
- **(vii-a) ⭐ hook 加 repo 根扫描段 + 失败降级**
- (vii-b) hook cwd 切 repo 根
- (vii-c) scope.conf 加 `../CLAUDE.md`

**选择**:(vii-a)

**理由**:localized 改动,与现有"双层 / 单层兼容"逻辑无冲突;失败降级保证 R1/R2 场景主扫不破坏

### cross-file 互引检测

候选:
- **(互引-a) ⭐ 独立 hook 写死 1 对**
- (互引-b) 配置化(YAGNI 不足)
- (互引-c) 嵌入 check-meta-review.sh(职责膨胀)
- (互引-d) 不加 hook,作为 meta-review fork 维度(执法延迟)

**选择**:(互引-a)

**理由**:YAGNI(当前实证仅 1 对 audit §9.4 #6);未来扩第 2 对每对 +4 行 PAIRS 数组,扩展代价低;与 M15/M16 模式一致(独立 hook 职责单一)

## 设计决策(spec §7.1 D1-D6)

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| **D1** | cross-ref hook 注册时机 | Stop + pre-commit 双注册(2 文件) | 与 M15/M16 模式一致(光谱 B+ 双 hook 防护) |
| **D2** | anchor 写死 vs 配置化 | 写死 1 对 | YAGNI |
| **D3** | (vii-a) 新增段失败时降级 | 跳过新增段,主扫继续 | 防御性,符合 M15/M16 graceful degrade 范式 |
| **D4** | settings 改动范围 | 只动 settings.json,不动 settings.local.json | local.json 是 user override,与 D19 a 方案"双轨"一致 |
| **D5** | anchor 缺失行为 | exit 2 阻断 + handoff skip 逃生通道 | 与 M15/M16 hook 兜底语义一致 |
| **D6** | 单文件双 mode vs 2 文件 | 2 文件 | 与 M15/M16 一致,简单清晰胜过 DRY 节流 |

## 实施过程发现 + 修补(spec / plan 缺陷)

### 修补 1:R1 stderr warning 缺失

**发现**:Task 3 code-quality review(spec reviewer 之后)发现 — spec §3.1 + §5 R1 + §5.2 + hook 内注释都要求 R1(`git -C` 失败)→ stderr warning + 跳过段;但 plan Task 3 / Task 4 Step 2 new_string 中 `2>/dev/null` 吞 stderr,实际无 warning。注释 aspirational 代码未实现。

**修补**:加 `git -C "$ROOT_DIR" rev-parse --is-inside-work-tree` 健康检查;失败 → stderr warning `⚠️ repo 根 git -C 调用失败,§5.5 跳过(主扫继续)` + `ROOT_DIFF=""` 跳过段。

**Commits**:
- Task 3 fix:`54190d6` fix(p0.9.3): check-meta-review.sh §5.5 加 R1 git -C 失败 stderr warning
- Task 4 内嵌:`65bcf9b` 中已含修补(controller 在 dispatch Task 4 时给 corrected new_string)

### 修补 2:§5 early-exit guard latent bug

**发现**:Task 4 implementer DONE_WITH_CONCERNS 报告 — `check-meta-commit.sh` §5 内有 `if [ -z "$DIFF_FILES" ]; then exit 0; fi` early-exit(L193-195)。staged 仅 root CLAUDE.md(harness/ 内 DIFF_FILES=空)→ early-exit → §5.5 永远不跑 → vii-a 失效。

调度者验证:`check-meta-review.sh` 同源 latent bug 也存在(L195-197),实际未触发是因为 working tree 有别的 unstaged 文件让 DIFF_FILES 非空(掩盖)。

**修补**:删 early-exit guard,让 §5 主扫(空时 no-op)+ §5.5 都跑,最终 CHANGED_META_FILES 空检查统一处理。

**Commits**:
- Task 4 内嵌:`65bcf9b`(implementer 主动修补,spec reviewer 批准 deviation)
- Task 3 后补:`0e2bc0c` fix(p0.9.3): check-meta-review.sh 删 §5 early-exit guard(latent vii-a bug)

### Secondary bug 发现:M3 / M4 路径混淆

**发现**:Task 3 latent fix subagent 验证时发现 — `CLAUDE.md`(根 M3,从 hook cwd=harness/ 视角 + repo 根扫描 = 字面 `CLAUDE.md` 无前缀)与 `harness/CLAUDE.md`(M4 分发模板,从 cwd=harness/ 视角 = 字面 `CLAUDE.md` 无前缀)在 hook 内**不可区分**。

**影响**:audit covers 字段写 `CLAUDE.md` 时,hook 无法区分这是 M3 还是 M4 的覆盖 — 可能造成 false positive(audit 实际只覆盖 M4 但被视为也覆盖 M3)或 false negative。

**当前 trial 中**:vii-a 修复 M3 入 CHANGED_META_FILES 仍正确(hook 检测到 root CLAUDE.md 改动并报警);但 audit covers 比对的精度受限。

**处理**:**不在本 trial 修补范围**(超 scope);documented 推 P0.9.4 或后续 trial。

## 反向追问(`feedback_dimension_addition_judgment.md`)

(详见 spec §9.3 Q1-Q4 — audit revision 后已与本节同步)

**Q1**:M3 hook 不可见缺口实战中是否有人改 M3?无数据预防是否违反 `feedback_judgment_basis`?
**A**:M3 是 harness 自治理入口,scope 判定 / 治理表 / scope 触发判定的真值在此;若它改动不入 scope,治理流程的元信息处于失同步风险下 — 这是**结构性缺口**而非频率问题(`feedback_judgment_basis` 禁止"高频/多数"作论据,本论据是逻辑必要性)。**反向追问**:不修复 (vii),"改 M3 不触发 meta-review" 问题如何解决?**无替代解法**(hook cwd 在 harness/ 子目录是历史结构性约束)。故修复必要。

**Q2**:cross-ref hook 写死 1 对是否过严?
**A**:当前实证仅 1 对(audit §9.4 #6);立即配置化 = 凭空预防多对场景。**反向追问**:不写死,用什么替代?**无更简方案** — 配置化(YAML/JSON)需引入 parser 层 + schema 维护成本,1 对 anchor 不值;每对 +4 行写死最简。接受未来扩第 2 对时改 hook 文件(每对 +4 行)。

**Q3**:cross-ref pre-commit hook 是否过度?Stop 是否够?
**A**:Stop 已覆盖 99% 场景;pre-commit 是 1% 长 session 不 stop 场景的兜底冗余,**此场景属 fix-9 (ii) 占位等 P0.9.2 数据,本 trial 在 P0.9.2 数据来前是无实证支撑的预防**(光谱 B+ 设计代价的诚实承认)。如 P0.9.2 显示 long-session 实战不发生,P0.9.4 可考虑撤回 pre-commit cross-ref 文件。本 trial 沿用 M15/M16 双 hook 模式,接受"代码重复 ~80%"代价换"双拦"覆盖。

**Q4**:本 trial 自身需走 design-review?
**A**:scope=meta(改 hook + settings),走 **meta-review**(M2 fork N 挑战者),与 design-review 不互替。

**Q5**(audit revision 后补):本 trial 是否真闭合 (vii-a) M3 hook 不可见?
**A**:**部分闭合**。详见 spec §9.3 Q4(audit revision 后补充)。两个精度边界:① untracked 漏检(spec §9.4 #11);② M3/M4 路径混淆(spec §9.4 #10)。本 trial 闭合声明限于"modified + staged-ACMR 路径生效"。

## 不做(防 scope 扩散)

- **不修 (i)(ii)(iv)(vi)**:
  - (i)(ii) 占位等 P0.9.2 数据
  - (iv)(vi) 已 accept 关闭(spec §5 B18)
- **不做 B 方案(主仓库↔下游版本漂移)**:用户原话接受现状,主动需求弱
- **不修 ROADMAP 副产物**(把 (iv)(vi) 移出候选 + (i)(ii) 标占位):trial 完成后独立小改(scope=none,不需 audit)— 已在本 audit revision 时一并处理(ROADMAP 已更新)
- **修 plan / spec 文档**(audit D1-F7 修订承认):R1 + early-exit fix 在 commit 后未同步回 plan / spec,本 trial 暂时违反 `feedback_design_philosophy` "变更先改文档"原则。**承认违反**;本 audit revision 时统一修订(spec / decision file / handoff / hook stderr / M1 / M2 / decision-trail / ROADMAP),不再以"避免反复改"为延后理由
- **不修路径混淆 secondary bug**(audit D4-F6 修订):超本 trial scope,推 P0.9.4 / 后续 trial。**推后窗口期接受机制**:中间任何 audit 标 `covers: [CLAUDE.md]` 时**调度者人工记忆 + handoff 显式标注**(M3 改动时在 handoff "反审待办" 段加 `CLAUDE.md = 根 M3` 注;M4 改动时加 `CLAUDE.md = harness/CLAUDE.md M4` 注),依赖人工兜底直至 P0.9.4 加路径前缀绝对化
- **不修 untracked 漏检**(audit D2-F1 修订):本 trial 选 B 显式承认(见 spec §9.4 #11);新仓库初始化场景在 harness 自仓库实战频率低;P0.9.4 候选可加 `git ls-files --others --exclude-standard` 扫 untracked
- **不扩 PAIRS 覆盖完整 5 处实际互引**(audit D4-F2 修订):本 trial 选 B 显式承认(见 spec §9.4 #12);仅证 anchor-anchor 1 对样本机制可行,不做覆盖度优化(YAGNI 一致)
- **不细分 M3 §5 cross-ref hook 类**(audit D4-F3 修订):决定保持 M3 §5 笼统(`check-*` prefix 已涵盖 cross-ref hook);若后续 trial 加更多 cross-ref 类 hook 累积到一定数量再细分
- **不取 M22 module 编号**(audit D4-F4 修订):cross-ref hook 是 P0.9.3 trial 内部产出;主 spec M14-M21 是 P0.9.1 锁定的核心模块表,不为后续 trial hook 全部加新 module 编号;handoff "M22-1/M22-2" 命名删除改纯文件名引用(本 audit revision 时一并处理)
- **不解 (vi) 升级路径(B 方案)**:用户接受现状

## 已知缺口

继承 spec §9.4 21 条(audit revision 后由原 9 条扩至 21 条):

1. agent 自律依赖减弱 — (i)(ii) 仍待 P0.9.2 数据(spec §9.4 #1)
2. **anchor 写死脆弱性 P1**(spec §9.4 #2;audit D3-F4 升级为 P1):用户重命名 anchor(合理操作)被 hook 阻塞;改 PAIRS = scope=meta 触发 meta-review 嵌套;推 P0.9.4 解法路径(配置化 PAIRS / 元数据 YAML / 废 hook 改 governance 显式约定层)
3. harness self-trial 验证局限(spec §9.4 #3,继承 P0.9.1.5 #5)
4. **bootstrap 自指多重豁免**(spec §9.4 #4;audit D1-F2 重写):三层豁免共同走 manual M2 fork — ① hook 文件 commit 自身不被新 hook 拦(settings 注册前)② spec/plan/decision file 落地不入 scope ③ 本次 meta-review fork 是首次,无既有 audit covers。**注**:本豁免不是 unprovable_in_bootstrap,而是 spec 显式列出的"初次 commit 执法窗口空缺"(可证缺口)
5. grep -F 字面匹配 anchor 容忍度局限(spec §9.4 #5)
6. **single trial 仅做 2 项**(spec §9.4 #6;audit D1-F4 修订):P0.9.3 标识符不绑定预设阶段,不预设"P0.9.3 整体闭合需多 trial 累积"
7. 下游 retrospective 引用不可见(spec §9.4 #7,继承 P0.9.1.5 #7)
8. **pre-commit hook 默认未挂 + 双注册防护层在 harness 实际单拦**(spec §9.4 #8;audit D3-F2 升级):harness 自仓库 `.git/hooks/pre-commit` 默认不软链;`check-meta-cross-ref-commit.sh` / `check-meta-commit.sh` 在 harness 自仓库**实际不触发**;光谱 B+ "双拦最稳"在 harness 自仓库实际是单拦
9. 挑战者有效性元疑问(spec §9.4 #9,继承 P0.9.1.5 #9)
10. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30)**:hook §5.5 加 `<root>/` sentinel 前缀;audit covers 约定 M3 用 `<root>/CLAUDE.md` / M4 用 `CLAUDE.md`;原识别保留作记录:**M3/M4 路径混淆**(spec §9.4 #10;audit D2-F3 + D3-F1 + D4-F6 共识):hook 输出 `CLAUDE.md` 字面对应 M3 / M4 两文件;covers 比对精度受限;推 P0.9.4;**推后窗口期接受机制**:调度者人工记忆 + handoff 显式标注规避
11. **untracked 漏检**(spec §9.4 #11;audit D2-F1):新仓库初始化时 M3 全新建未 git add 路径走 untracked 漏检;hook stderr 已加引导;本 trial 选 B 显式承认
12. **🟢 已修(P0.9.3 第二个 trial — 2026-04-30)**:cross-ref PAIRS 4 → 6 条,扩 finishing `## 反模式约束` + design `**轻量级**` anchor,实际 4 处互引全覆盖(audit 原 5 处 经重审实为 4 处;详 spec 2026-04-30 §9.4 #25 留痕);原识别保留:**PAIRS 仅覆盖 2/5 实际互引**(spec §9.4 #12;audit D4-F2 + D4-F5):design ↔ finishing 实际互引清单 5 处(L28 / L3 / L5 / L14 / L45);PAIRS 实际只覆盖 2 处 + 同行重复;本 trial 选 B 显式承认
13. **R1 stderr warning 实际 dead path**(spec §9.4 #13;audit D2-F2):5 场景 fixture 未触发 R1 路径(.git 损坏 case 未造);代码逻辑正确但实测未跑;接受
14. **新 skip 字段 `meta-cross-ref` 已在 M1/M2 同步**(spec §9.4 #14;audit D4-F1):本 audit revision 已修补
15. **M3 §5 处置:不细分 cross-ref hook 类**(spec §9.4 #15;audit D4-F3):decision file 显式声明
16. **M22 module 编号决策:不取**(spec §9.4 #16;audit D4-F4):handoff M22-1/M22-2 命名已删
17. **`.gitignore` 排除 `.claude/` 风险**(spec §9.4 #17;audit D3-F6 P2):hook 文件改动 `git status` 不报;本 trial 7 commit 都用 `git add -f`;P0.9.4 候选改 .gitignore 精确化
18. **anchor 含 §(U+00A7) 编码风险**(spec §9.4 #18;audit D3-F9 P2):非 UTF-8 编辑器保存可能改 anchor 字节流;hook stderr 已加提示
19. **跨平台 sed -i 未通用**(spec §9.4 #19;audit D3-F8 P2):plan inline 验证脚本在 macOS BSD sed 失败;接受,plan 文档加 platform note
20. **cross-ref trigger case 子串包含匹配**(spec §9.4 #20;audit D2-F4 P2):`design-rules.md.bak` 等命中 trigger;无 false positive,触发时机过宽;接受,P0.9.4 改用循环精确匹配
21. **grep -F 全文匹配 false negative**(spec §9.4 #21;audit D2-F5 P2):若 anchor 字面拷到 changelog/注释但删了真实互引段 → false negative;接受,P0.9.2 观察
22. **Stop + pre-commit 双触发体验**(spec §9.4 #22;audit D2-F6 P2):同 session 内已 commit 但 Stop event 又跑同样检查;harness 自仓库 pre-commit 默认未挂实战不会双触发;接受,P0.9.2 观察是否构成噪声

## meta-L1 inline 验证(spec §6.1 — audit D2-F2 修订后:5 场景中 4 场景实跑 / 1 场景 dead path)

| 场景 | 期望 | 实际 |
|------|------|------|
| 场景 1 — M3 改动触发 | exit 2 + stderr 含 CLAUDE.md | ✅ exit 2 |
| 场景 2 — anchor 缺失 | exit 2 + stderr 列具体缺失 | ✅ exit 2 |
| 场景 R1 — git -C 失败 fixture | exit 0 + stderr warning | ⚠️ **dead path**:fixture 是"在 harness 子目录 init,不在 repo 根",走 `[ ! -d "$ROOT_DIR/.git" ]` 整 if 跳过 → R1 warning 路径**根本不进入** → silent skip,无 stderr 输出。R1 fix 代码逻辑正确(覆盖 .git 损坏 / submodule 未初始化场景),但本 trial 5 场景 fixture 未触发此路径(spec §9.4 #13);接受,P0.9.2 候选场景 |
| 场景 C7 — handoff skip 兜底 | exit 0 | ✅ exit 0 |
| 场景 R2 — 单层下游 | exit 0 | ✅ exit 0 |

**inline 验证范畴声明**(audit D1-F5 修订):本 5 场景全部在 harness 自仓库 artificial 构造,仅证明 hook 在 harness 自仓库的 syntactic / 结构性正确;**不证明实战是否需要这两条防护**(此问题归 P0.9.2 数据)。本 inline 验证不构成 `feedback_realworld_testing_in_other_projects` 原则下的实战数据(spec §6.3 同步声明)。

**未实测路径**(audit revision 后):
- R1 stderr warning 路径(.git 损坏 case 未造,代码 dead path)
- untracked 文件漏检(spec §9.4 #11,新仓库 init 未 git add fixture 未造)
- M3/M4 路径混淆 false negative(spec §9.4 #10,covers 字段精度比对未造)
- PAIRS 漏检 3 处实际互引(spec §9.4 #12,L28 / L3 / L5 / L14 改动 fixture 未造)

## 后续影响

- **7 commits 落地**(P0.9.1.5 闭合 commit `656ea28` 之后):
  - `d91546c` Task 1: 新建 check-meta-cross-ref.sh(Stop)
  - `6330d60` Task 2: 新建 check-meta-cross-ref-commit.sh(pre-commit)
  - `e1691c3` Task 3: check-meta-review.sh §5.5 段
  - `54190d6` Task 3 R1 fix
  - `65bcf9b` Task 4: check-meta-commit.sh §5.5 段(含 R1 + early-exit fix)
  - `0e2bc0c` Task 3 latent early-exit fix
  - `8a08676` Task 5: settings.json Stop 段注册 cross-ref hook
- **5 文件改动**:2 改(check-meta-review/commit.sh)+ 2 新建(cross-ref + cross-ref-commit)+ 1 settings.json
- **ROADMAP**:P0.9.3 第一个 trial 标 🟢 闭合
- **decision-trail.md**:append 1 条新抉择
- **handoff.md**:目标段 + 已完成段 + 推后续段 + 反审待办段 + Evidence Depth 段更新
- **meta-L4 数据点**:**P0.9.3 第一条 trial 数据** — P0.9.1 治理流程对 hook 改动 trial 仍有效(brainstorming → spec → plan → subagent-driven → meta-review fork → finishing 完整 cycle)

## 关联

- **spec**:`docs/superpowers/specs/2026-04-29-p0-9-3-governance-drift-detection-batch-design.md`
- **plan**:`docs/superpowers/plans/2026-04-29-p0-9-3-governance-drift-detection-batch-plan.md`
- **audit**:`docs/audits/meta-review-2026-04-29-150902-p0-9-3-governance-drift-batch.md`(verdict=pass-after-revision,4+2 挑战者,第 1 轮 26 finding → 第 2 轮 D4 pass + D2 部分 → 第 3 轮调度者补完 F1+F6)
- **上游 spec**:`docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`(fix-9 (vii) 来源)
- **上游 decision**:`docs/decisions/2026-04-26-bypass-paths-handling.md`(fix-9 6 路径决议)
- **上游 audit**:`docs/audits/meta-review-2026-04-29-095821-m1-m2-m4-governance-batch.md`(audit §9.4 #6 cross-file 互引脆弱性识别)
- **trial 序列**:M0(2026-04-28)→ M1+M2+M4 batch(2026-04-28~29)→ **本 trial**(2026-04-29)

## 杂项注

- **subagent-driven implementation**:6 task fresh subagent + spec reviewer + code quality reviewer 双 review(skill `superpowers:subagent-driven-development`);Task 1/3/4/5 通过 review,Task 2 通过 1 critical 修补(R1 fix);Task 6 验证型 task 跳过 formal review(纯验证)
- **plan 偏离**:Task 3 / Task 4 实际实施超出 plan Step 2 new_string 范围(R1 + early-exit fix);spec reviewer 批准 deviations 必要;trial 完成后 plan 文档修订时同步
- **手动操作**:Task 1/2/4 用 `git add -f` 因为 root .gitignore 有 `.claude/` pattern;无 GPG bypass(commit 正常 sign)

---

**结束。**

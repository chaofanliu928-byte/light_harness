# 决策: P0.9.3 第二个 trial — D 类技术债 batch(D1+D4)

**状态**:🟢 已决定(2026-04-30 用户拍板 + 2026-05-06 实施完成 + meta-review pass-after-revision)

**类型**:方案选择型(D1 形态 A/B/C 选 B;D4 形态 A/B 选 B 加 2 条 PAIRS)

**日期**:2026-04-30 ~ 2026-05-06

**关联功能**:P0.9.3 第二个 trial — 闭合 P0.9.3 第一个 trial §9.4 #10(M3/M4 路径混淆)+ #12(PAIRS 覆盖度 2/4 不足)两条已知缺口

## 问题

P0.9.3 第一个 trial(2026-04-29 commit `c0810e8`)实施完后留下 22 条已知缺口(§9.4 #1-22),其中:

- **#10 M3/M4 路径混淆**:hook §5.5 段输出的 `CLAUDE.md` 字面对应 M3(repo 根 = 治理入口)和 M4(harness/CLAUDE.md = 分发模板)两个文件;hook 不区分 → audit covers 字段写 `CLAUDE.md` 时 hook 无法静态判断指 M3 还是 M4。**(vii-a) 闭合质量受限**:write covers 只覆盖 M4 的 audit 仍能让 M3 改动 pass(false negative);反向同 false negative。
- **#12 PAIRS 覆盖度 2/4 不足**:design ↔ finishing 实际互引清单 4 处(audit 原写"5 处"经第二个 trial 第三次审查重审为 4 处),PAIRS 现覆盖 2 处 + 同行重复;漏检 design L28+L45 + finishing L38 共 4 处 stale anchor 风险。

P0.9.3 第一个 trial spec §1.3 明确这两条**推 P0.9.4 / 后续 trial**;**推后窗口期接受机制**:调度者人工记忆 + handoff 显式标注规避(M3/M4 改动手动注明指向)。

实战 4 个月后(2026-04-30)用户判定:**"调度者人工记忆"作为兜底机制脆弱**(对其他用户 / 未来调度者 session 无效);D 类技术债积累到一定程度,值得做 D1+D4 batch trial 闭合。D2(untracked 漏检)+ D3(anchor 写死)+ D6(case 子串包含)留作不修(spec §1.3 不做段)。

## 范围决策(brainstorming Q1-Q3)

候选:
- **A. 仅 D5(.gitignore 精确化)**:0 风险,15 行
- **B. D1 + D4 batch**:~30 行 hook 改动 + governance 章节 + spec/decision 措辞
- **C. D1 + D4 + D2 + D3 + D6 全 batch**:~80 行,含 untracked 扫 / anchor 配置化

**选择**:**A 先做 → C 进 spec 再进 trial**,实际拆为 **D5 单独 commit `0e8283d`(P0.9.3 第一个 trial 后立即修)+ D1+D4 batch trial 走完整 spec→plan→implementation→meta-review 流程**

**理由**:
- D5 是机械修复(`.gitignore` 精确化 + 补加 11 个 historical untracked governance 文件入仓),无 spec 必要,直接 commit
- D1 涉及多模块共用接口(audit covers ↔ hook 比对协议)→ design-rules 第 4 列硬条件 (3) 默认升级标准级 spec
- D4 是 PAIRS anchor 选择 + 互引覆盖度判断 → 涉及 design-rules / finishing-rules 实际字面验证,必须 spec 化
- D2/D3/D6 实战暴露面接近 0(D5 修后 untracked 漏检场景概率极低),YAGNI 不修 — 用户明示 `feedback_judgment_basis` 不预防

## 形态决策

### D1 形态(M3/M4 路径混淆修复)— DD1 / DD3

候选:
- **A. 全仓库相对路径**:hook 主扫 + §5.5 都输出仓库相对(`harness/CLAUDE.md` vs `CLAUDE.md`);需 backfill 5/6 历史 audit covers
- **B. ⭐ `<root>/` sentinel 前缀**:hook §5.5 段对 root 级文件加 `<root>/` 前缀;主扫不变;0 backfill
- C. scope.conf 锚点 glob:fnmatch 不支持锚点,技术不可行

**选择**:**B**

**理由**:
- 0 backfill — 5/6 历史 audit covers 用 harness 内部相对路径(无前缀),自动命中 M4 语义;唯 P0.9.1 用仓库相对(`harness/...`)作为孤例不 backfill
- `<root>/` 字面独占性:7-byte ASCII,与 git 实际路径不冲突(`<` 字符在文件名罕见 + 跨平台兼容性问题保证不出现);spec §9.4 #23 接受边缘 case
- C 不可行 — fnmatch 不支持路径锚点,glob 无法表达"仅 repo 根级"

**辅助决策 DD3**(sentinel 字面格式):`<root>/` 7 字节 ASCII,与 git 路径不冲突,字面独占,跨 OS 一致

### D4 形态(PAIRS 覆盖度修复)— DD2

候选:
- A. 不扩 PAIRS:接受 4 处只覆 2 — 不修
- **B. ⭐ PAIRS 加 2 条 anchor**:覆盖剩余 2 处实际互引,4 处全覆盖
- C. PAIRS 重设计为语义比对:复杂度过高,无价值

**选择**:**B**

**理由**:
- 实际互引重审(第三次审查):4 处而非原 audit 的 5 处(详 spec §9.4 #25 第三次仔细审查留痕)
- 加 2 条 PAIRS = `finishing-rules.md|## 反模式约束`(覆盖 design L28+L45 间接引用)+ `design-rules.md|**轻量级**`(覆盖 finishing L38 间接引用)
- C 引入语义比对 LLM-call,远超 anchor 字面比对的 grep 简洁性,YAGNI

### 辅助决策 DD4 / DD5 / DD6(不做 / 不 backfill / governance 文档化)

- **DD4 不修 D2 untracked**:D5 修后 harness/.claude/ 不再默认 untracked,实际暴露面接近 0;commit 时 pre-commit 兜底;`feedback_judgment_basis` 不预防
- **DD5 不 backfill 5 历史 audit**:P0.9.1 audit covers 仓库相对路径异常但孤例;后续 5 audit 沿用 harness 内部相对,符合本 trial 协议
- **DD6 M2 §7.3 加 sentinel 协议章节**:audit covers 路径规则首次显式 documented;支撑后续 trial 协议稳定性

## 不做(防 scope 扩散)

- **不**修 D2 untracked 漏检:D5 修后实际暴露面接近 0;P0.9.3 spec §9.4 #11 documented 接受
- **不**修 D3 anchor 写死(YAGNI 一致):用户拍板接受现状
- **不**修 D6 cross-ref hook trigger case 子串包含:无 false positive,纯性能微浪费,不值得动
- **不** backfill 5 个历史 audit covers:接受历史快照
- **不**改下游分发:命名前缀 `check-meta-*` 自动过滤,setup.sh 不分发
- **不**改 root `.gitignore`:D5 已独立 commit `0e8283d`
- **不**预设 P0.9.4 必修条目:`feedback_iterative_progression` 一致,由实际需求拉动

## 实施清单

| commit | 内容 |
|--------|------|
| `d54754f` | spec(标准级)+ §0 偏离说明 + DD1-DD6 + §6.1 8 测试场景 + §9.4 22+3 已知缺口 |
| `0982b2a` | plan(bite-sized TDD)+ Pre-Task handoff skip + Task 1-5 + Post-Implementation 引导 |
| `38e0f7e` | Task 1: 2 hooks §5.5 加 `<root>/` sentinel 前缀 + stderr 引导 |
| `5eb7882` | Task 2: 2 cross-ref hooks PAIRS 4 → 6 |
| `0189599` | spec/plan correction:`"轻量级"判定` → `**轻量级**`(implementer Step 2.4 grep 暴露第四次错)|
| `02a53ea` | Task 3: M2 §7.3 加 sentinel 协议规则节(第 5 条)|
| `a8e4dac` | Task 4: P0.9.3 spec §9.4 #10 + #12 标 🟢 已修 |
| `947049a` | Task 5: P0.9.3 decision §已知缺口 #10 + #12 同步 |
| `785f6a7` | 扫除 6 处遗漏 anchor 引用(final code reviewer 暴露第五次错)|
| `2af3fd6` | spec §9.4 #25 加第五次错留痕 + 教训第 4 条 |
| `1ded935` | audit revision F3.1/F3.2/F3.3/F3.4/F3.5(meta-review challenger 3 暴露第六次错)|
| `f5b8c40` | audit revision F1.1 hook stderr 行号 + F4.4 root CLAUDE.md M3 描述 |
| `ee02aa5` | meta-review audit 入仓(verdict=pass-after-revision)|

合计 13 commits;~36 行 hook + governance 改动 + 多处文档同步。

## 已知缺口(继承 P0.9.3 第一个 trial 22 条 + 本 trial 新增 4 条)

继承 22 条详 P0.9.3 spec §9.4 #1-22。本 trial 新增:

- **#23 `<root>/` sentinel 跨 OS 行为**:`<` 字符在 ext4/NTFS 等理论支持但实际罕见;若用户真创建以 `<root>/` 开头的路径,与协议冲突。接受边缘 case,P0.9.2 实战观察
- **#24 PAIRS 第 5/6 条选择的局限性**:grep -F 字面比对,不是语义比对(同 P0.9.3 #5)
- **#25 审查过程留痕(4 错 + 1 纠正,共 5 个留痕点)**:`feedback_spec_gap_masking` 元数据点 — 5 错链 + 教训 5 条详 spec §9.4 #25
- **#26 实现期 inline 验证受 handoff skip 字段干扰**:plan 注释了但未回写 spec §6.1 → meta-review challenger 3 F3.4 暴露后回写;教训扩"测试场景预期列必须标外部状态依赖"

## 教训留痕(meta 过程)

本 trial 的 spec_gap_masking 错误链已累积到 **6 错** + 1 纠正 + 5 教训:

1. **第 1 错**(P0.9.3 audit revision):接受 audit "3/5 漏检"叙事未自 grep
2. **第 2 错**(本 trial brainstorming):视觉跳过 finishing L38 间接引用
3. **(纠正)第 3 次审查**:用户提示后 grep -nE + 逐行上下文,4 处而非 5 处
4. **第 4 错**(spec 写 §3.1 PAIRS 第 6 条 anchor):`"轻量级"判定` 未 grep 验证字面;implementer Step 2.4 暴露
5. **第 5 错**(correction commit `0189599` sweep 不全):漏 6 处 stale ref;final code reviewer 暴露 → commit `785f6a7` 扫除
6. **第 6 错**(meta-review challenger 3 F3.1+F3.2):sweep scope 仍局限本 trial 文件,漏上游 P0.9.3 第一个 trial spec L23 + decision L141 同字面 stale ref;audit revision commit `1ded935` 扫除

5 教训(spec §9.4 #25):
1. 写 PAIRS 时**当场** grep 验 anchor 字面在目标文件存在
2. 区分**形式声明**(被引方权威定义)vs **引用文字**(引用方文字);anchor 应在形式声明 site
3. 区分**直接引用 vs 间接引用**;PAIRS 应覆盖互引方向 + 形式声明 site 两者
4. 修字面错时**全仓库 grep 扫**(包含跨 trial 上游文件 + 引用方文字镜像 + commit msg template),不限本 trial 文件
5. 测试场景预期列必须标"是否依赖外部状态"(handoff 字段、git 工作树状态等),否则形成 spec_gap_masking 测试层变体

## 关联

- **上游**:P0.9.3 第一个 trial decision `docs/decisions/2026-04-29-p0-9-3-governance-drift-detection-batch.md`(§9.4 #10 + #12 闭合)
- **依赖 commit**:`0e8283d`(D5 .gitignore 精确化 + 11 historical untracked 治理文件入仓)
- **本 trial spec**:`docs/superpowers/specs/2026-04-30-d-class-tech-debt-batch-design.md`
- **本 trial plan**:`docs/superpowers/plans/2026-04-30-d-class-tech-debt-batch.md`
- **本 trial audit**:`docs/audits/meta-review-2026-05-06-143426-d-class-tech-debt-batch.md`(verdict=pass-after-revision,4 challengers,3 Important + 9 Minor)
- **trial 序列**:M0(2026-04-28)→ M1+M2+M4 batch(2026-04-28~29)→ P0.9.3 第一个 trial(2026-04-29)→ **本 trial / P0.9.3 第二个 trial**(2026-04-30 ~ 2026-05-06)
- **decision-trail**:落地后 append 2 条新抉择(本 trial 闭合 + meta-review 元过程留痕)

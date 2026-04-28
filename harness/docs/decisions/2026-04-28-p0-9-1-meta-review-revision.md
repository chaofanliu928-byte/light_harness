# P0.9.1 落地反审 meta-review 决策汇总

> **类型**:根源承认型(D9 范式)+ 多条子决策合并
>
> **触发**:P0.9.1 self-governance 实施完成后,M1 §3 Step B → M2 流程 fork 4 个挑战者(对抗式 bootstrap 4 维基线)的 meta-review,审查 audit `harness/docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md` 综合 verdict=needs-revision。本 decision 文件汇总 audit 暴露的 4 项需 decision 留痕的子决策 + 1 项根源承认。
>
> **关联 audit**:`harness/docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`
>
> **关联 spec**:`harness/docs/superpowers/specs/2026-04-17-p0-9-self-governance-design.md`(P0.9.1 主 spec)

---

## Bootstrap 声明

本 decision 是 P0.9.1 落地反审的 ad-hoc bootstrap 动作 — P0.9.1 自身设计了 meta-review 流程(M1 + M2),P0.9.1 落地后用自己的流程审自己产出本 decision。后续治理规范(P0.9.1.5 / P0.9.2 / P0.9.3)不应追溯性要求本 decision 通过流程 — 因为本 decision 是流程**首次启用**的产出物,流程的"上一版本"是用户与 designer 的 ad-hoc 多轮对抗(spec §1.6 leverage 4 事实点 4)。

---

## 子决策 1:scope.conf F 组 glob 路径前缀语义对齐(D-fix-T4-4)

### 问题

实施末段 T4 集成测试 case 4 暴露:`harness/.claude/hooks/meta-scope.conf` 第 28-29 行原写 `harness/CLAUDE.md` 和 `harness/templates/*.json` 含 `harness/` 前缀,但 hook cwd=harness/ 时 `git diff --relative` 输出无前缀,glob 不匹配 → F 组只有 `setup.sh` 能正确触发。

### 决定

**已修复**(commit `34129ae`):F 组 glob 改为 harness 视角(strip `harness/` 前缀)。

- `harness/CLAUDE.md`(M4)由 A 组 `CLAUDE.md` glob 已覆盖,F 组不重复列
- `harness/templates/*.json` → `templates/*.json`

同步更新 M3 §3 F-row glob 列 + §5 F 组与 A 组说明文字。

### 根本原因

spec → scope.conf → hook 三者间路径前缀语义不对齐:
- spec §3.1.8 line 773 早已说明 `$SCRIPT_DIR = <repo-root>/harness/`(cwd 锚点)
- 但 spec §4.1.2 scope.conf 模板没把 cwd 锚点反映到 glob 写法
- 实施层抄 spec 字面写 `harness/...`,实际不匹配

### 后续动作

- spec §6 测试节加"路径前缀语义对齐"项(后续修订)
- spec §7 决策表加 D-fix-T4-4 编号(本 decision 即此条)

---

## 子决策 2:templates/README.md plan 外建接受

### 问题

commit `7c4d81e`(I7.2)创建了 `harness/templates/README.md`(43 行),plan §4 任务 I7.2 line 827 明确写"无需另建 README"(契约要求是"模板顶部注释")。

### 决定

**接受 plan 外建**。理由:

1. **规约位置实际可读性更好**:JSON 文件不支持注释,把双轨规约 + 维护方式 + 自检 jq 脚本 + scope 守门段塞进 settings.json 的 `_comment` / `_meta` key 是 workaround,可读性差;独立 README.md 更清晰
2. **不污染下游**:templates/ 文件夹本身就不分发(D12 命名前缀过滤 + setup.sh 只读 `templates/settings.json`),README.md 仅 harness 维护者可见,无副作用
3. **plan 文本 vs 实施差异是轻量**:plan 写"无需另建 README"是契约的 hint,不是硬约束;实施层选择稍微偏离的成本远小于把规约塞进 JSON workaround 的成本

### 不做(防 scope 扩散)

- **不**删除 README.md 回退到 settings.json `_meta` key
- **不**用 lint 自动检查"plan 文本约束 vs 实施文件清单"(过度工程化,B11 反向追问适用 — 没有此 lint 之前也能靠 audit/code review 抓到)

### 后续动作

- plan §4 I7.2 后续修订时注明"已立 decision 接受 README.md"(指向本 decision)

---

## 子决策 3:scope.conf B 组 glob 扩展(`*.sh` → `*`)

### 问题

spec C1 字面契约 line 142 锁定 B 组 glob 为 `.claude/hooks/*.sh`,但实施 `harness/.claude/hooks/meta-scope.conf:14` 扩为 `.claude/hooks/*`。plan §4 I2.1 line 405-406 实现 agent 注意事项指出"`.conf` 不命中 `*.sh`,需补漏",但选取扩 glob 路径未立 decision。

### 决定

**接受扩 glob 选项**。理由:

1. **覆盖目标清晰**:扩 glob 为 `.claude/hooks/*` 的目的是让 `meta-scope.conf` 自身入 scope(D22 fix-9 (v) 治理文件入 scope)— 同一目录下任何治理 hook 配置(.sh / .conf / 未来 .json / .yaml)都应入 scope
2. **替代方案(显式追加单行 `meta-scope.conf`)更脆弱**:未来加新 hook 配置类型(如 .json)需再追加,容易漏;扩 `*` 一劳永逸
3. **scope 扩张风险极低**:`.claude/hooks/` 目录结构稳定,所有文件天然属 meta 治理范畴;不会有"突然加无关文件"的场景

### 不做

- **不**改回 `.claude/hooks/*.sh + meta-scope.conf` 显式列(脆弱)
- **不**追加 lint 检查"`.claude/hooks/` 下文件类型必须 meta-* 前缀"(过度工程化)

### 后续动作

- spec §4.1.2 后续修订时注明"C1 B 组 glob 实施层扩为 `*`,理由见本 decision"

---

## 子决策 4:M18 SessionStart 数组追加 follow-on 接受

### 问题

plan §4 I7.1 line 797-803 约束"在 `hooks.Stop` 数组追加 M15 条目,不改其他段",但 commit `7e04d70` 同时改了 SessionStart 数组(追加 `meta-self-review-detect.sh`)。

### 决定

**接受 follow-on**。理由:I6.3 选定 D.1 选项 2(M20 拆分两文件)后,M20 必须在某 hook 数组注册才生效;SessionStart 是 M20 唯一合理位置(§3.1.10 锁定);plan I7.1 文本"不改其他段"约束在 D.1 选定前写,follow-on 是必然连锁。

### 后续动作

- plan §6.5 决策映射表后续修订时注明"D.1 follow-on:I7.1 同时改 Stop + SessionStart 数组"

---

## 根源承认:M3(repo 根 CLAUDE.md)hook 不可见缺口

### 问题(audit 4 维交叉共识 — Challenger 1 Y2 + 3 Y2 + 4 Y3)

M3 (`/CLAUDE.md`,self-governance 入口)改动 hook 完全不可见,因 hook cwd=harness/ 时 `git diff --relative` 不输出 repo 根文件 → M15 Stop hook + M16 pre-commit hook 检不出 M3 改动 → 用户改 M3 可绕过 meta-review,违反 spec §1.6 leverage 4 "audit 必走"承诺。

### 根源(承认存在性问题)

P0.9.1 hook 设计选择 cwd=harness/(双层 harness 自身仓库结构 + 单层下游分发兼容),代价是 repo 根文件失去 hook 检测覆盖。M3 是这个代价的最大单点 — 它本身就是 self-governance 入口,绕过它就是绕过整个治理。

### 决定:接受 + 推 P0.9.3

- **本阶段(P0.9.1)接受此缺口** — 已添加到 spec §1.3 fix-9 (vii) 边界声明
- **推 P0.9.3 governance 漂移检测兜底** — 类比 fix-9 (i)(ii)(iv)(vi) 处理思路:接受不防 + P0.9.3 时序覆盖
- **本 audit 显式 covers `/CLAUDE.md`**(本 decision 同 audit 关联,M3 改动在本次反审 scope 内被审查)

### 不做(防 scope 扩散)

- **不**让 hook 加扫 repo 根 git diff(成本:hook 双 cwd 模式 + 路径前缀解析 + scope.conf glob 双视角语义)— P0.9.3 阶段评估
- **不**在 M3 顶部加 manual reminder ("改本文件请先 ./review-script.sh")— manual reminder 易被忽略,与 hook enforcement 等价于 0

### 缓解措施(本阶段已落地)

1. M3 §5 已显式标"hook 不可见 — 已知缺口"+ 技术原因 + 补救方向
2. spec §1.3 fix-9 (vii) 已加 acceptance 声明(2026-04-28 修订,本 decision 同步触发)
3. M3 改动频率实证极低(P-1 / P0 / P0.5 / P0.9 阶段累计改 M3 共 < 10 次,基本都伴随大幅 spec 改动 — 都会触发 meta-review,M3 自身入 scope 与否实质影响小)
4. P0.9.3 governance 漂移检测落地后,可识别此类 hook 绕过(grep `/CLAUDE.md` 改动 vs `/CLAUDE.md` 关联 audit 缺失)

---

## 突破模板骨架的说明

本 decision 不沿用标准 "问题 / 方案 A/B / 决定 / 后续" 模板,因为:

1. **多条子决策合并 + 1 条根源承认型**:标准模板按单决策展开;合并 5 条会冗余
2. **根源承认型不存在 A/B 选择**:M3 hook 不可见缺口的"方案 A"是补 hook(过度工程化)、"方案 B"是接受(本选择)— 但这不是真实 A/B 而是 1 真选项 + 1 反例;采用 D9 范式"问题 / 根源 / 决定 / 不做"更准确
3. **每条子决策内部仍按 standard 4 节结构**(问题 / 决定 / 不做 / 后续动作),保留模板核心语义

---

## 关联

- **触发 audit**:`harness/docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`
- **本 decision 修复的 audit P1 项**:子决策 1-4 + 根源承认 = audit § 5.2 P1+P2 的"决策立档"行
- **审计依据**:M1 `harness/docs/governance/meta-finishing-rules.md` §3 Step C 模板范式选择(D9 范式)
- **范式参考**:`harness/docs/decisions/2026-04-17-harness-self-governance-gap.md`(D9 原范式)
- **D21 反审待办字段**:本 decision 落地后,audit § 5 升 verdict=pass,handoff 反审待办字段更新为"已完成 — audit:`harness/docs/audits/meta-review-2026-04-28-102359-p0-9-1-self-review.md`"

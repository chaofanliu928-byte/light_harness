# Model-Route 治理规则

> **[2026-05-24] codex 接入搁置** — fork 子任务维持全 Claude。本文件保留作日后基线,不预设重启时间(`feedback_iterative_progression`)。详见 `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点。

> **何时读本文件**:进入 P2 codex 接入实施时 — **[2026-05-24] codex 接入搁置,本文件保留作日后基线;若重启接入,详见 spec `docs/superpowers/specs/2026-05-24-codex-shelved-batch-design.md` + `decision-trail.md` 2026-05-24 拐点回溯本搁置背景。**
>
> **来源决策**:`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11(P2 实施路径)+ 必做 #5
>
> **2026-05-13 引入** — P2 codex 接入的 model-route 自定义。

---

## 1. P2 目的 + 设计原则

### 1.1 P2 目的(核心)

**成本节省为主,跨模型对抗为副产品**。用 codex 干部分 sub-agent 活,Claude 同等能力比 codex 贵。

### 1.2 设计原则(来源:二公设 + synthesis-rules.md)

1. **调度者不 swap**(保 Claude)— 综合阶段是聚合多 agent 结论的关键节点,公设 1 + synthesis-rules.md 事后规则要求
2. **关键决策不 swap**(保 Claude)— evaluate 关键维度 / meta-review / process-audit / security-scan 凭证档
3. **单 agent / 单挑战者优先 swap**(无社交压力,公设 1 在单 agent 场景下不触发)
4. **多挑战者并行扁平 fork 可 swap**(prompt 隔离已防污染,但综合阶段保 Claude)
5. **harness 自治理核心不 swap**(meta-review / process-audit — 闭环独立性)

---

## 2. 完整 swap 决策表

按角色类型 + 任务复杂度分配:

| 角色 | swap codex? | sandbox | approval | --write? | model | effort | 理由 |
|---|---|---|---|---|---|---|---|
| **调度者**(主对话) | ❌ 保 Claude | — | — | — | — | — | 综合阶段保 Claude(synthesis-rules.md);公设 1 |
| **designer**(单 agent 写设计) | ✅ swap | workspace-write | on-failure | `--write` | gpt-5.4 | high | 单 agent 无社交压力;复杂任务用 high |
| **planner**(writing-plans 写计划) | ✅ swap | read-only | never | 不加 | gpt-5.4 | medium | 单 agent 写计划,无社交压力;中等复杂 |
| **implementer**(写代码 subagent-driven-development) | ✅ swap | workspace-write | on-failure | `--write` | gpt-5.4 | high | **P2 核心目的**(成本节省);单 agent 写代码 |
| **testing**(test-driven-development 写测试) | ✅ swap | workspace-write | on-failure | `--write` | gpt-5.4 | medium | 单 agent;中等复杂 |
| **设计自检挑战者** | ✅ swap | read-only | never | 不加 | gpt-5.4 | medium | 单挑战者;比 designer 简单 |
| **design-review 4 挑战者** | ✅ swap(并行 fork) | read-only | never | 不加 | gpt-5.4 | high | 关键决策,P2 价值最大;扁平 fork |
| **code-reviewer**(requesting-code-review) | ✅ swap | read-only | never | 不加 | gpt-5.4 | high | 对抗类挑战者;实现后审代码 |
| **evaluate 非关键维度** | ✅ swap | read-only | never | 不加 | gpt-5.4-mini | medium | 维度评分,中等复杂 |
| **evaluate 关键评分维度** | ❌ 保 Claude | — | — | — | — | — | 关键决策不 swap |
| **silent-failure-hunter** | ✅ swap | read-only | never | 不加 | gpt-5.4-mini | low | 5 类 pattern grep,简单任务 |
| **security-scan 危险操作** | ✅ swap | read-only | never | 不加 | gpt-5.4-mini | low | pattern 类 |
| **security-scan 注入混淆** | ✅ swap | read-only | never | 不加 | gpt-5.4-mini | low | pattern 类 |
| **security-scan 凭证档** | ❌ 保 Claude | — | — | — | — | — | 降级保护需求(原 audit 决定) |
| **meta-review N 挑战者** | ❌ 保 Claude | — | — | — | — | — | harness 自治理核心 |
| **process-audit 挑战者** | ❌ 保 Claude | — | — | — | — | — | 闭环独立性 |
| **综合阶段**(所有 fork 之后,跨角色) | ❌ 保 Claude | — | — | — | — | — | synthesis-rules.md 事后规则 4 条 |

### 2.1 swap 列表汇总

**Swap 列表**(11 个角色 — 2026-05-22 加入 planner/implementer/testing/code-reviewer 4 个实现链路角色):

*实现链路*:designer / **planner** / **implementer** / **testing**
*审查链路*:设计自检挑战者 / design-review 4 挑战者 / **code-reviewer** / evaluate 非关键维度 / silent-failure-hunter / security-scan 危险操作 / security-scan 注入混淆

**不 swap 列表**(6 个角色):调度者 / evaluate 关键评分维度 / security-scan 凭证档 / meta-review N 挑战者 / process-audit 挑战者 / 综合阶段

---

## 3. codex 接入默认配置

### 3.0 模型兼容性约束(2026-05-22 实证验证)

ChatGPT 订阅 + codex CLI 0.106.0 下的实证结果:

| 模型 | 可用? | 备注 |
|---|---|---|
| **gpt-5.4** | ✅ 验证可用(10,098 tokens for "2+2=4") | 推荐主用(designer / design-review / 设计自检) |
| **gpt-5.4-mini** | ✅ 验证可用(9,748 tokens) | 简单任务用,略省 token(silent-failure-hunter / security-scan / evaluate 非关键) |
| gpt-5.5 | ❌ "requires a newer version of Codex" | 等待 codex CLI 升级后再启用 |
| spark | ❌ "not supported when using Codex with a ChatGPT account" | 仅 OpenAI API key 支持;ChatGPT 订阅不可用 |

**重要**:如果用户全局 `~/.codex/config.toml` 默认 `model = "gpt-5.5"` 配合 0.106.0 CLI,**所有 codex 调用都会失败**。在 CLI 升级之前,需在调用时用 `--model gpt-5.4` 显式覆盖,或修改用户 config 默认。

### 3.1 全局默认(`~/.codex/config.toml`)— 用户当前实际

```toml
model = "gpt-5.5"                    # ⚠️ 当前用户配置,但 codex CLI 0.106.0 不支持;实际调用必须 --model 显式覆盖
model_reasoning_effort = "xhigh"     # 比 high 更高,谨慎使用(usage 消耗大)
personality = "pragmatic"
```

### 3.2 harness 项目级覆盖(推荐,`.codex/config.toml` at harness root)

为绕过用户全局 gpt-5.5 失败,在 harness 项目根建项目级 config:

```toml
model = "gpt-5.4"                # 验证可用,替代 gpt-5.5
model_reasoning_effort = "high"  # 比全局 xhigh 低一档(usage 节省)
```

### 3.3 角色级覆盖(命令行 flag)

每次调用通过 `--model` / `-c model_reasoning_effort=...` / `-s` 覆盖(注意:codex exec **无 --effort flag,需用 -c**):

```bash
codex exec --model gpt-5.4-mini -c model_reasoning_effort=low -s read-only <prompt>
```

---

## 4. swap 实施清单(P2 极简方案 — 一次性扩范围 + git 兜底)

按 `decisions/2026-05-12-ecc-analysis-snapshot.md` §11:**直接扩范围 + git 兜底**,**不预设观察期**,**不分波**。

> **2026-05-22 修订记录**:删除原"第一波 / 第二波"分类。原 §4 隐含"第一波观察后才进第二波"语义,违反用户 2026-05-13 "不分波"决策 + `feedback_iterative_progression`(不预设固化阶段)。本次修订与 ECC §11 完全对齐 — 一次性 swap 全部 10 角色,git revert 单 commit 是唯一回退机制。

### 4.1 实施步骤

```bash
git tag pre-codex-swap
```

逐角色独立 commit(commit 顺序无强制约束;提供精确 revert 能力,不构成"观察期"约束):

**read-only 角色(7 个;codex 不写文件)**:

1. **silent-failure-hunter** — `task --model gpt-5.4-mini -c model_reasoning_effort=low -s read-only`
2. **security-scan 危险/注入** — `task --model gpt-5.4-mini -c model_reasoning_effort=low -s read-only`(2 挑战者)
3. **planner**(2026-05-22 加入)— `task --model gpt-5.4 -c model_reasoning_effort=medium -s read-only`
4. **设计自检挑战者** — `task --model gpt-5.4 -c model_reasoning_effort=medium -s read-only`
5. **evaluate 非关键维度** — `task --model gpt-5.4-mini -c model_reasoning_effort=medium -s read-only`
6. **design-review 4 挑战者** — `task --model gpt-5.4 -c model_reasoning_effort=high -s read-only`(并行 4 个,单 turn 内发起)
7. **code-reviewer**(2026-05-22 加入)— `task --model gpt-5.4 -c model_reasoning_effort=high -s read-only`

**workspace-write 角色(3 个;codex 可写文件)**:

8. **designer** — `task --model gpt-5.4 -c model_reasoning_effort=high -s workspace-write --write --background`
9. **implementer**(2026-05-22 加入;**P2 核心**)— `task --model gpt-5.4 -c model_reasoning_effort=high -s workspace-write --write --background`
10. **testing**(2026-05-22 加入)— `task --model gpt-5.4 -c model_reasoning_effort=medium -s workspace-write --write --background`

### 4.2 不进入 swap(永久保 Claude)

- 调度者(主对话)
- evaluate 关键评分维度
- security-scan 凭证档
- meta-review N 挑战者
- process-audit 挑战者
- 综合阶段(所有 fork 之后)

---

## 5. Trust + Sandbox 配置

### 5.1 项目 trust 设置

第一次在新项目跑 codex 会询问 trust level。harness 项目首次:

```toml
# ~/.codex/config.toml 加
[projects.'D:\个人\harness']
trust_level = "trusted"
```

### 5.2 Review Gate hook(已启用)

`/codex:setup --enable-review-gate` 启用 Stop hook 后接管。注意:可能耗 ChatGPT 订阅 usage limit。

### 5.3 Network access

默认 `networkAccess: false`(防 codex 出网)。如需 WebFetch,通过 sandbox 配置开。harness 大部分角色不需要 codex 联网。

### 5.4 OS-level sandbox(Windows)

```bash
codex sandbox windows  # Windows Restricted token
```

---

## 6. 反向规则(防滑)

按 `/CLAUDE.md` §1 二公设的反向规则,适用 model-route:

1. **任何主张"让综合阶段 swap codex"** — 违反 synthesis-rules.md 事后规则 + 公设 1,**默认拒绝**
2. **任何主张"让 meta-review / process-audit / security-scan 凭证档 swap codex"** — 违反闭环独立性,**默认拒绝**
3. **任何主张"让单 fork 既 fork codex 又综合 codex 输出"** — 违反扁平 fork 架构(2026-04-16),**默认拒绝**

除非有新事实推翻这些原则的来源依据,**否则不进入辩论**。

---

## 7. 失效条件 + 回退机制

### 7.1 单角色回退(精确)

```bash
git revert <commit-hash>   # revert 单个角色 swap commit
```

### 7.2 整体回退

```bash
git checkout pre-codex-swap  # 回到 swap 之前的基线 tag(单 tag,不分波 — 见 §4)
```

### 7.3 触发回退的信号

- 实际跑出 silent failure(codex 漏真问题但表现"正常")
- ChatGPT 订阅 usage 烧得过快(需观察 1-2 周)
- 用户决定停止 P2

### 7.4 监控信号(轻量,非强制)

按 P2 决策"不监控同质化信号"(已剔除),但 process-audit 抽查时可对比 codex 挑战者结论 vs Claude 挑战者结论。

---

## 8. 下游使用本规则

本文件无 `meta-` 前缀,经 setup.sh `governance/*.md` glob 自动分发下游。下游项目可:

- **跟随本规则**:swap 列表 + 不 swap 列表完全照搬
- **下游裁剪**:下游若无某些 fork 角色(例如不用 meta-review),对应行删除即可
- **下游覆盖**:下游可定义自己的 `.codex/config.toml` 项目级默认覆盖全局

---

## 9. 相关 spec / decision

- 来源决策:`docs/decisions/2026-05-12-ecc-analysis-snapshot.md` §11(P2 实施路径)+ 必做 #5(本文件)
- 二公设:`/CLAUDE.md` §1(harness 自仓库 M3)/ `CLAUDE.md` §角色分离原则(下游 M4)
- 综合阶段规则:`docs/governance/synthesis-rules.md`(事前 + 事后规则)
- 论文来源(仅作现象观察,不作决策依据):滑铁卢大学多 Agent 旁观者效应 arXiv:2605.10698

# 挑战者导览体系 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立挑战者侧导览体系 — 1 个文件 4 节方法论 / 数据来源向导 / 输入策略 / 常见陷阱;同 batch 改 4 agent 文件 include 模式顺手解 KG3(~176 行 governance 实文重复)。

**Architecture:** 纯 documentation + governance 改动,无代码 / 无 hook / 无 skill 新增。改动按 spec §9 切 3 commits:Commit 1 新建主文件 / Commit 2 改 4 agent 文件 / Commit 3 governance + README + 引用对齐。

**Tech Stack:** Markdown / Bash grep 验证 / git。所有改动在 harness/ 仓库内,无外部依赖。

**Spec 来源:** `harness/docs/superpowers/specs/2026-05-26-challenger-orientation-design.md`(每 task 按 spec 节号引用)

---

## File Structure

**新建** 1 个:
- `harness/docs/references/challenger-orientation.md` — 挑战者侧导览主文件,4 节,400-600 行

**改动** 7 个:
- `harness/.claude/agents/design-reviewer.md` — 删 governance 实文 + 加 include + 4 挑战者输出格式加必填段
- `harness/.claude/agents/evaluator.md` — 同上(4 挑战者)
- `harness/.claude/agents/process-auditor.md` — 同上(2 挑战者,但保留预处理 JSONL Node.js 脚本段)
- `harness/.claude/agents/security-reviewer.md` — 同上(3 挑战者)
- `harness/docs/governance/synthesis-rules.md` — 加事后规则 5(校验挑战者"已对照用户原话" section)
- `harness/docs/references/multi-agent-review-guide.md` — 加 1 段对称引用说明
- `README.md` — §4 原理段加 §4.X 挑战者导览体系一节

**Finishing(后续 meta-finishing 阶段产)** 2 个:
- `harness/docs/decision-trail.md` — append 2026-05-26 拐点
- `harness/docs/active/handoff.md` — update

---

## Commit 策略(按 spec §9.1)

| Commit | Task 范围 | 提交内容 |
|---|---|---|
| **Commit 1** | Task 1-5 | challenger-orientation.md 新建(4 节 + frontmatter + 导读) |
| **Commit 2** | Task 6-9 | 4 个 agent 文件改 include 模式 + 输出格式加必填段 |
| **Commit 3** | Task 10-12 | synthesis-rules.md + multi-agent-review-guide.md + README.md 同步 |

每 Commit 内最后 Task 含 commit 步;每 Commit 提交后跑 `git log --stat` 验证。

---

## Task 1: 创建 challenger-orientation.md 骨架(frontmatter + 导读 + 4 节标题)

**Files:**
- Create: `harness/docs/references/challenger-orientation.md`

**Spec 来源:** §3.1.1(顶部 frontmatter + 文件导读)+ §3.1.2-3.1.5(4 节标题结构)

- [ ] **Step 1: 创建文件骨架**

```markdown
---
audience: 挑战者(fork 出的 subagent)
purpose: 给挑战者(子智能体)提供方法论 / 数据来源 / 输入策略 / 陷阱避坑的"入门必读"
when_to_read: fork 你的时候,prompt 内含 "先 Read `harness/docs/references/challenger-orientation.md`" — 这是必读第一步
not_distributed: 本文件分发到下游(setup.sh 复制 references/)
---

# 挑战者导览(Challenger Orientation)

> 你是 fork 出来的挑战者(子智能体)。本文件告诉你 4 件事:
> 1. **怎么找问题**(§1 方法论)
> 2. **去哪找信息**(§2 数据来源向导)
> 3. **怎么看调度者给你的输入**(§3 输入策略)
> 4. **避哪些陷阱**(§4 常见陷阱)
>
> 不读本文件就开始审查 = 你处于 freestyle 状态,你的输出会被调度者综合时退回。

---

## §1 方法论(怎么找问题)

### §1.1 通用(13 挑战者全适用)

(Task 2 填充)

### §1.2 design-review 4 挑战者专属

(Task 2 填充)

### §1.3 evaluator 4 挑战者专属

(Task 2 填充)

### §1.4 process-audit 2 挑战者专属

(Task 2 填充)

### §1.5 security-scan 3 挑战者专属

(Task 2 填充)

### §1.6 实操技巧(通用)

(Task 2 填充)

---

## §2 数据来源向导(去哪找)

### §2.1 harness 全局架构

(Task 3 填充)

### §2.2 文档索引(找 X 去哪)

(Task 3 填充)

### §2.3 跨平台路径(关键!)

(Task 3 填充)

### §2.4 常见审查问题对应的数据源

(Task 3 填充)

### §2.5 实操命令模板

(Task 3 填充)

---

## §3 输入策略(怎么看调度者给你的输入)

### §3.1 调度者给你什么(预期清单)

(Task 4 填充)

### §3.2 你要批判看调度者给的输入

(Task 4 填充)

### §3.3 必做动作 — 自取用户原话

(Task 4 填充)

### §3.4 输出必填:`### 已对照用户原话` section

(Task 4 填充)

---

## §4 常见陷阱(挑战者也是 AI)

### §4.1 公设 1 应用(挑战者乐观偏差)

(Task 5 填充)

### §4.2 spec_gap_masking 检测(便利答案掩盖缺口)

(Task 5 填充)

### §4.3 framing 警惕(措辞引导)

(Task 5 填充)

### §4.4 反对而反对(挑战者过度否定)

(Task 5 填充)

### §4.5 越权设计(挑战者超出找问题边界)

(Task 5 填充)
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la harness/docs/references/challenger-orientation.md`
Expected: 文件存在,~80 行(骨架,后续 Task 2-5 填充内容)

---

## Task 2: 填充 §1 方法论(6 子节,约 220 行)

**Files:**
- Modify: `harness/docs/references/challenger-orientation.md`(§1.1-§1.6)

**Spec 来源:** §3.1.2 §1 方法论(每子节有行数预算)

- [ ] **Step 1: 填充 §1.1 通用(~50 行)**

内容要求:
- **对抗-决策分离原则**:1 段引用 `multi-agent-review-guide.md` 的核心
- **4 个原则**:1 行 1 个(独立视角不重叠 / 对抗不验证 / 可验证输出 / 结论可争议)
- **通用自检清单**(以下 6 条逐字嵌入):
  ```
  - [ ] 真读了调度者给的待审对象原文(spec / agent 文件 / 代码 / diff)?
  - [ ] 对照过用户原话原文(从会话 JSONL 自取,不依赖调度者"主线"字段)?
  - [ ] 每个发现指向 file:line 或文档:章节,附原文 quote?
  - [ ] 严重程度判定有客观标准,不靠"感觉"?
  - [ ] 是否做假设(应改用客观证据)?
  - [ ] 是否提了替代方案(应只找问题,不写新方案)?
  ```

- [ ] **Step 2: 填充 §1.2 design-review 4 挑战者专属(~40 行)**

内容:4 挑战者各占 1 段(8-10 行):
- 挑战者 1(自洽性) — **矛盾追踪法**:把 spec 各章节内容映射到表(章节 → 关键概念 → 描述)→ 跨章节比对 → 找接口双方对齐 / 数据模型一致 / 状态机完整 / 模块依赖循环 / 错误传播连贯
- 挑战者 2(完整性) — **场景遍历法**:把 spec §1.2 核心场景逐条列出 → 每个场景遍历(模块 → 接口 → 数据流 → 边界 → 测试)→ 找"模糊到要猜"的描述(可猜测度高 = 完整性差)
- 挑战者 3(过度工程化) — **反向追问法**:找疑似过度结构 → 对每个反问"不用这个方式,之前的问题怎么解?"(参 `[[feedback_dimension_addition_judgment]]`)→ 有清晰替代解法 → 标过度;无 → 标必要
- 挑战者 4(RUBRIC 对齐) — **条款对照法**:逐条对照 RUBRIC.md 惩罚项 / 奖励项 / 设计 §7 应对方式 vs 实际设计

- [ ] **Step 3: 填充 §1.3 evaluator 4 挑战者专属(~40 行)**

内容:
- 挑战者 1(RUBRIC 合规) — 条款对照 + **测试充分性专项**(按 scope 引 evidence depth 文件:feature → testing-standard.md / meta → meta-finishing-rules.md / mixed → 双套均评)
- 挑战者 2(架构一致性) — **路径追踪法**:找 import 路径违反 ARCHITECTURE.md 分层 / 找模块划分实现 vs spec §2 偏离 / 找接口签名实现 vs spec §3 不匹配
- 挑战者 3(文档健康) — **README 对照法**:涉及模块 README 存在性 / 描述 vs 代码实际导出一致 / 变更历史更新
- 挑战者 4(Slop 检测) — **模式扫描法**:Grep 命名一致性 / 重复实现 / 僵尸依赖 / 过时模式 / README 行数 / 格式 / 变更历史归档

- [ ] **Step 4: 填充 §1.4 process-audit 2 挑战者专属(~30 行)**

内容:
- 挑战者 1(流程遵从度) — **治理对照法**:把 governance 规则列出(brainstorming-rules / design-rules / etc) → 对照对话摘要 → ✅ 遵守 / ❌ 违反 / ⚠️ 部分遵守 / ➖ 不适用
- 挑战者 2(效果满意度) — **情绪信号识别法 + 关键词语境区分**:对话摘要中找显式否定 / 重复请求 / 用户接管 / 方向推翻 / 精磨轮次 → **关键**区分"用户对 AI 产出回应" vs "用户描述需求"(关键词同形语境异)→ 不确定时不标(宁可漏报不误报)

- [ ] **Step 5: 填充 §1.5 security-scan 3 挑战者专属(~30 行)**

内容:
- 3 挑战者(凭证数据 / 危险操作 / 注入混淆) — **模式扫描法**:硬编码 grep pattern → 命中后**场景判定**(测试 / 演示 / 生产)→ 风险等级判定
- **凭证扫描场景判定不可绕**(M8 永远不可绕,即使其他挑战者也要含此最低必选维度)

- [ ] **Step 6: 填充 §1.6 实操技巧(通用,~30 行)**

内容(以下表格 + 段落):

```markdown
**证据深度等级**:

| 等级 | 形态 | 示例 |
|---|---|---|
| 🟢 弱 | 仅描述位置 | "spec 第 3 节" |
| 🟡 中 | 位置 + 关键词 | "spec §3.1.5 第 2 段 提到 X" |
| 🔴 强 | 位置 + 原文 quote | 'spec §3.1.5: "...完整原话..."' |

**追求 🔴 强证据**;弱证据相当于没证据(调度者综合时可能 reject)。

**严重程度判定**(客观标准,不靠"感觉"):

| 级别 | 客观条件 |
|---|---|
| 🔴 必修(阻塞) | 违反核心原则 / 触发 RUBRIC 惩罚项 / 内部自相矛盾 / 跟用户原话结构性偏离 |
| 🟡 建议(不阻塞但应改) | 次要不一致 / 可读性 / 边界未明 / 缺奖励项 |
| 🟢 轻微(可忽略) | 风格 / 命名细节 / 文档冗余 |
```

- [ ] **Step 7: 验证 §1 行数**

Run: `awk '/^## §1 /,/^## §2 /' harness/docs/references/challenger-orientation.md | wc -l`
Expected: 200-240 行(预算 220 行 ± 10%)

---

## Task 3: 填充 §2 数据来源向导(5 子节,约 140 行)

**Files:**
- Modify: `harness/docs/references/challenger-orientation.md`(§2.1-§2.5)

**Spec 来源:** §3.1.3 §2 数据来源向导

- [ ] **Step 1: 填充 §2.1 harness 全局架构(~30 行)**

内容:text 树形描述(以下结构):

```text
harness/                          # 项目根
├── CLAUDE.md                     # M3 自治理入口(harness 仓库内,不分发下游)
├── README.md                     # 项目说明
├── harness/                      # 框架源码,setup.sh 复制到下游
│   ├── CLAUDE.md                 # M4 分发模板
│   ├── docs/
│   │   ├── governance/           # 治理规则 7+2 个
│   │   │   ├── brainstorming-rules.md / design-rules.md / planning-rules.md
│   │   │   ├── implementation-rules.md / testing-rules.md
│   │   │   ├── review-rules.md / finishing-rules.md
│   │   │   ├── meta-review-rules.md / meta-finishing-rules.md
│   │   │   └── synthesis-rules.md(综合阶段中性化)
│   │   ├── references/           # 参考文档(本文件 / DESIGN_TEMPLATE / multi-agent-review-guide)
│   │   ├── audits/               # meta-review audit 历史
│   │   ├── decisions/            # 决策记录
│   │   ├── decision-trail.md     # 决策追溯链(append-only)
│   │   ├── active/handoff.md     # 当前交接状态
│   │   ├── superpowers/
│   │   │   ├── specs/            # 设计文档
│   │   │   └── plans/            # 实施计划
│   │   ├── RUBRIC.md             # 评分标准
│   │   └── ARCHITECTURE.md       # 架构规范(若有)
│   ├── .claude/
│   │   ├── agents/               # 领审员 agent
│   │   ├── skills/               # SKILL.md 集合
│   │   ├── hooks/                # check-* / block-* / notify-* / session-init
│   │   └── settings.json         # hook 注册
│   └── setup.sh                  # 复制 harness/ 到下游项目的脚本
```

- [ ] **Step 2: 填充 §2.2 文档索引(~30 行)**

完整表格(spec §3.1.3 已列):

```markdown
| 找什么 | 去哪看 |
|---|---|
| 项目核心原则 / 角色分离 / 公设 1+2 | `CLAUDE.md`(根级,harness 自治理入口) |
| 治理规则 | `harness/docs/governance/<阶段>-rules.md` |
| 评分标准(RUBRIC) | `harness/docs/RUBRIC.md` |
| 架构规范 | `harness/docs/ARCHITECTURE.md`(若存在) |
| 设计文档模板 | `harness/docs/references/DESIGN_TEMPLATE.md` |
| 多挑战者审查指南(领审员视角) | `harness/docs/references/multi-agent-review-guide.md` |
| 当前批 spec | `harness/docs/superpowers/specs/YYYY-MM-DD-*-design.md`(取最新) |
| 当前批 plan | `harness/docs/superpowers/plans/YYYY-MM-DD-*.md` |
| 当前批交接状态 | `harness/docs/active/handoff.md` |
| 历史 meta-review audit | `harness/docs/audits/meta-review-*.md` |
| 历史决策 | `harness/docs/decision-trail.md` + `harness/docs/decisions/*.md` |
| 用户校准 memory(跨平台路径!) | 见 §2.3 |
| 用户原话(会话 JSONL,跨平台路径!) | 见 §2.3 |
```

- [ ] **Step 3: 填充 §2.3 跨平台路径(~30 行)**

完整内容:

```markdown
### §2.3 跨平台路径(关键!)

**memory(用户校准记录)位置**:
- Windows: `C:\Users\<user>\.claude\projects\<project-slug>\memory\`
- Linux/Mac: `~/.claude/projects/<project-slug>/memory/`
- **不在 harness 仓库内**,在用户 home dir 的 `.claude/` 下

**会话 JSONL(用户原话)位置**:
- Windows: `C:\Users\<user>\.claude\projects\<project-slug>\*.jsonl`
- Linux/Mac: `~/.claude/projects/<project-slug>/*.jsonl`
- 多个 JSONL(每次会话一个),按 mtime 排序找最新
- **当前会话的 JSONL** 通常是 mtime 最新那个;**上一会话的 JSONL** 是次新那个

**`<project-slug>` 推断**:Claude Code 把项目路径特殊字符(中文 / 空格 / 冒号 / 反斜杠)替换为连字符。**不要 basename 猜**,用以下 Node.js 健康检测脚本定位(参 `harness/.claude/agents/process-auditor.md` §2.1):

```javascript
// 写到 /tmp/find-project-dir.js,然后 node 执行
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const projectsDir = path.join(require('os').homedir(), '.claude', 'projects');
const cwd = process.cwd();

function normalize(p) {
  return p.replace(/[\\\/]+/g, '/').toLowerCase();
}

const dirs = fs.readdirSync(projectsDir).filter(d => {
  try { return fs.statSync(path.join(projectsDir, d)).isDirectory(); }
  catch(e) { return false; }
});

(async () => {
  for (const dir of dirs) {
    const full = path.join(projectsDir, dir);
    const jsonls = fs.readdirSync(full).filter(f => f.endsWith('.jsonl'));
    if (jsonls.length === 0) continue;
    const rl = readline.createInterface({
      input: fs.createReadStream(path.join(full, jsonls[0])),
      crlfDelay: Infinity
    });
    for await (const line of rl) {
      try {
        const obj = JSON.parse(line);
        if (obj.cwd) {
          if (normalize(obj.cwd) === normalize(cwd)) {
            console.log(full);
            process.exit(0);
          }
          break;
        }
      } catch(e) {}
    }
    rl.close();
  }
  console.error('未找到匹配的项目目录');
  process.exit(1);
})();
```
```

- [ ] **Step 4: 填充 §2.4 常见审查问题对应的数据源(~20 行)**

内容(表格):

```markdown
| 你要审什么 | 优先查 |
|---|---|
| spec 是否对齐用户原话 | 会话 JSONL(本 batch 所有 user message,按时间序) |
| 调度者主线段是否 framing | 1. 调度者注入的"主线-支线-关系"段 vs 2. JSONL 用户原话 |
| 历史类似决策怎么做的 | `decision-trail.md` 时间序 + `decisions/*.md` |
| 治理规则真实约束 | `governance/<阶段>-rules.md` 原文(不是 spec 引用版) |
| 上 batch known-gap 未解决 | 最新 `meta-review-*.md` audit §6 KG 表 |
| 项目核心原则是否被违反 | `CLAUDE.md` §1 角色分离 + 公设 1+2 |
| 用户在本会话的关键决策 | grep `type=user` in 当前 JSONL,按时间序 |
```

- [ ] **Step 5: 填充 §2.5 实操命令模板(~30 行)**

完整内容:

```markdown
### §2.5 实操命令模板

**找当前会话 JSONL**(取最新):

```bash
# 1. 通过 §2.3 脚本找项目目录
PROJECT_DIR=$(node /tmp/find-project-dir.js)

# 2. 当前会话 = 最新 jsonl(mtime 最新)
CURRENT_JSONL=$(ls -t "$PROJECT_DIR"/*.jsonl | head -1)

# 3. 上一会话 = 次新 jsonl
PREV_JSONL=$(ls -t "$PROJECT_DIR"/*.jsonl | sed -n '2p')
```

**找 user message(按时间序)**:

```bash
node -e "
const fs = require('fs');
const readline = require('readline');
const rl = readline.createInterface({ input: fs.createReadStream(process.argv[1]), crlfDelay: Infinity });
(async () => {
  for await (const line of rl) {
    try {
      const obj = JSON.parse(line);
      if (obj.type === 'user' && obj.message) {
        const c = obj.message.content;
        const text = typeof c === 'string' ? c : Array.isArray(c)
          ? c.filter(b => b.type === 'text').map(b => b.text).join(' ')
          : '';
        const isToolResult = Array.isArray(c) && c.some(b => b.type === 'tool_result');
        if (text.trim() && !isToolResult) {
          console.log(\`[\${obj.timestamp}] \${text.slice(0, 2000)}\`);
        }
      }
    } catch (e) {}
  }
})();
" "$CURRENT_JSONL"
```

**找历史 audit**:

```bash
ls -t harness/docs/audits/meta-review-*.md | head -5
```

**找最新 spec / plan**:

```bash
ls -t harness/docs/superpowers/specs/*-design.md | head -1
ls -t harness/docs/superpowers/plans/*.md | head -1
```
```

- [ ] **Step 6: 验证 §2 行数**

Run: `awk '/^## §2 /,/^## §3 /' harness/docs/references/challenger-orientation.md | wc -l`
Expected: 130-160 行(预算 140 行 ± 15%)

---

## Task 4: 填充 §3 输入策略(4 子节,约 120 行)

**Files:**
- Modify: `harness/docs/references/challenger-orientation.md`(§3.1-§3.4)

**Spec 来源:** §3.1.4 §3 输入策略

- [ ] **Step 1: 填充 §3.1 调度者给你什么(预期清单,~20 行)**

内容(列表):

```markdown
调度者 fork 你时,prompt 内含:

- **"主线-支线-关系"段**(synthesis-rules.md 事前规则 5 注入)— 调度者的视角
- **维度推荐**(A/B/C 三段对抗式 / N/G 段事实统计式)— 调度者的视角
- **待审对象**(spec / agent 文件 / 代码 diff / 摘要文件等)
- **配套资料**(RUBRIC.md / ARCHITECTURE.md / governance 必要节 / evidence depth 文件)
- **必读提示**:1 行 "先 Read `harness/docs/references/challenger-orientation.md`,然后再开始审查;输出格式必填末尾 section `### 已对照用户原话`"

> 注:调度者侧也是 AI,公设 1 适用(自评有乐观偏差)— 上述内容均带 selection / framing 风险。你要批判看,见 §3.2。
```

- [ ] **Step 2: 填充 §3.2 你要批判看调度者给的输入(~30 行)**

完整表格(spec §3.1.4 已列):

```markdown
**核心警惕**:调度者也是 AI,公设 1 适用;调度者写"主线"必带 selection + framing。

**具体动作**(✅/❌ 对照):

| 调度者写 | ❌ 直接采信 | ✅ 批判看 |
|---|---|---|
| "主线:本会话整体在做 X(落地路径选方向「Y」)" | 接受"路径 Y 已定" | "方向「Y」"是结论引导,我应从 JSONL 看用户原话怎么提的 |
| "主线:用户需要 GateGuard 完整设计" | 接受"用户要 GateGuard" | "GateGuard"是调度者命名,用户可能没用这词 — 从 JSONL grep |
| "支线:审 X spec 的自洽性,重点关注 Y" | 把 Y 当审查焦点 | "重点关注 Y"违反 synthesis-rules 事前规则 3,我独立判 |
| "主线:fork 前意图识别 + 报告通俗化两件事" | 接受"两件事是这次 batch 的目标" | "两件事"是调度者归纳;原话可能是更具体的诉求 — 校验 |

**违反 synthesis-rules 事前规则 1-3 的引导词**(出现即 framing 警告):"显然 / 实际上 / 重点是 / 关键问题是 / 应该 / 需要严查"。
```

- [ ] **Step 3: 填充 §3.3 必做动作 — 自取用户原话(~30 行)**

完整内容:

```markdown
### §3.3 必做动作 — 自取用户原话

fork 你的时候,**你必须做的事**(在审查 spec / 代码 / 文档之前):

1. **定位会话 JSONL**:按 §2.3 + §2.5 命令找当前会话 JSONL(mtime 最新)
2. **提取所有 user message**:按 §2.5 命令 grep,按时间序输出
3. **筛选关注两类**:
   - 用户**原诉求**句(本 batch 起点的 user message — 通常是 `/clear` 后第一条非系统消息)
   - 用户**关键决策**句(选项题选择 / 否决某方案 / 加约束的话)
4. **校验调度者主线-支线-关系段**:
   - 主线是否覆盖用户原诉求?
   - 主线是否扩展了用户没说的内容(framing)?
   - 关系字段是否反映用户的关注点?

**两条边界**:
- 找不到用户原话(JSONL 损坏 / 当前会话第一条消息就是 fork prompt)→ 在输出 section 标 "⚠️ 无法定位会话 JSONL,跳过主线校验",**不要伪造**
- 多 batch 共享 session(罕见)→ 用 timestamp 切分(本 batch 起点 = 上次 handoff 提交 timestamp 之后)

**反例(伪造的占位填充)**:
- ❌ "已对照用户原话 ✅"(无具体 quote / timestamp)
- ❌ "用户原诉求:让挑战者更可靠"(无原文,你的解读)

**正例**:
- ✅ "用户原话 #1 [2026-05-26T05:51:20.627Z]:'议题 C:挑战者拿什么输入?这个我很感兴趣。'"
```

- [ ] **Step 4: 填充 §3.4 输出必填:`### 已对照用户原话` section(~40 行)**

完整内容:

````markdown
### §3.4 输出必填:`### 已对照用户原话` section

挑战者输出**最末必填一个 section**(放在所有 finding 之后):

```markdown
### 已对照用户原话

**从 JSONL 抽取的用户原话**(N 条,按时间序;snippet 完整 quote,不解读):
1. [timestamp] "原话片段 1"
2. [timestamp] "原话片段 2"
...

**主线-支线-关系校验结论**:
- 主线对应用户原诉求:✅ 一致 / 🟡 部分覆盖 / 🔴 偏离(理由:...)
- 支线对应调度者意图:✅ 任务边界 / 🟡 含选择性
- 关系字段是任务边界:✅ 中性 / 🟡 含倾向引导

**(如发现主线偏离 🔴)主线偏离 finding**:
- 位置:[主线段哪一行 / 具体引用]
- 偏离描述:[调度者写什么 vs 用户原话什么]
- 原话证据:[timestamp + 完整 quote]
- 影响:[挑战者后续审查会被怎么 anchor]
- 严重程度:🟡 / 🔴
```

**调度者综合阶段会做的事**(由 `synthesis-rules.md` 事后规则 5 规定):

- 缺失本 section → reject 该挑战者输出,要求重审
- section 内容空泛(无具体 timestamp + 完整 quote)→ reject
- 主线-支线-关系全 ✅ 但 finding 中含主线偏离 → 自相矛盾,reject
- section 显示主线偏离 🔴 → 升级为综合阶段 finding,可能触发主线段重写

**为什么必填**:挑战者是 AI,公设 1 适用 — 没有强制留痕,容易跑了不读 / 读了不校验 / 校验了不输出。本 section 是**校验留痕**,让"对照过用户原话"这件事可被调度者综合时机械校验。
````

- [ ] **Step 5: 验证 §3 行数**

Run: `awk '/^## §3 /,/^## §4 /' harness/docs/references/challenger-orientation.md | wc -l`
Expected: 110-140 行(预算 120 行 ± 15%)

---

## Task 5: 填充 §4 常见陷阱(5 子节,约 105 行)+ Commit 1

**Files:**
- Modify: `harness/docs/references/challenger-orientation.md`(§4.1-§4.5)

**Spec 来源:** §3.1.5 §4 常见陷阱

- [ ] **Step 1: 填充 §4.1 公设 1 应用(挑战者乐观偏差,~20 行)**

内容:

```markdown
### §4.1 公设 1 应用(挑战者乐观偏差)

挑战者也是 AI,也有"自评乐观"偏差 — 倾向于"找不到问题就说没问题"(尤其本身确实没什么问题时,会"凑数式找问题"或"宣告完美")。

**公设 1 原话**(`CLAUDE.md` 顶部):AI 评估自己的产出存在系统性乐观偏差。

**应用到挑战者**:
- 你跑完审查觉得"产出 0 个 finding,没问题" — **必须说明**:你具体检查了什么(对照表)/ 为什么认为没问题(逐项)。
- 不附检查清单的"✅ 全部通过"等于没做。
- 产出 0 finding ≠ 产出弱(可以是"我覆盖了 X / Y / Z,逐项检查通过");但不附检查清单的 0 finding = 跑过场。

**反例(便利答案)**:
- ❌ "整体审查通过,无重大问题"
- ❌ "spec 写得不错,4 节齐全"

**正例(有据可依)**:
- ✅ "我检查了:(1) 自洽性 — §1 G1 vs §3.1.2 对应,无矛盾;(2) 完整性 — §1.2 5 场景全部对应 §3 详细设计某节;(3) 边界 — §2.2 不在 scope 内 6 项与 §1 用户否决对得上;均通过 → 0 finding。"
```

- [ ] **Step 2: 填充 §4.2 spec_gap_masking 检测(~30 行)**

完整内容(包含两个信号 + 反例):

```markdown
### §4.2 spec_gap_masking 检测(便利答案掩盖缺口)

**来源**:用户 2026-04-17 三次纠正(`[[feedback_spec_gap_masking]]`)— 遇到 spec 内的缺口,不承认,而是包装成"动作已做"。**meta-level 工作的常见陷阱,与 rule-negotiation 同构**。

**信号 A — 调度者用"动作"包装缺口**:
- spec 写"我们在 X 节加了 Y 占位符 / 警告 / 措辞调整,所以问题解决了"
- 实际:占位符 / 警告 / 措辞 ≠ 真解决问题
- **你要标 finding**:"缺口未承认,用动作包装"(附 spec 原文 quote)

**信号 B — 你自己(挑战者)写"已确认"占位**:
- 信息不足时,**不要**写"我已确认这点 ✅"
- 应写"⚠️ 信息不足,无法判断"(承认不知)
- 例:挑战者要校验"X 节是否与上游对齐",但找不到上游文档 → 不写 "✅ 已对齐",写 "⚠️ 找不到上游 docs/X.md,无法校验"

**反例**:
- ❌ "spec §7.2 R4 风险已通过 ✅/❌ 例兜底,该风险已缓解"(挑战者直接采信 spec 的话)
- ✅ "spec §7.2 R4 风险兜底用 ✅/❌ 例;但用户 2026-05-26 audit KG1 已记录该兜底不够硬,挑战者认为规则 5 推 framing 与规则 1-3 反 framing 目标方向反"(挑战者带证据反驳)
```

- [ ] **Step 3: 填充 §4.3 framing 警惕(~20 行)**

完整内容:

```markdown
### §4.3 framing 警惕(措辞引导)

**警惕的引导词**(违反 `synthesis-rules.md` 事前规则 3 措辞中性):
- "显然 / 实际上 / 重点是 / 关键问题是 / 重点关注 / 应该 / 需要严查 / 务必"
- "X 是核心,要重点审"
- "Y 已经讨论过了"
- "Z 不用再深究"

**出现在调度者 prompt(支线 / 关系字段 / 维度推荐)**:
- 标 finding "调度者 prompt 违反 synthesis-rules 事前规则 3"
- **不接受引导,独立判断**

**出现在 spec / 设计文档**:
- 不标 finding(spec 可以有主观立场),但 **批判性看**
- 例:spec §7 写"显然这是个非问题" → 不要采信"显然",要看证据是否充分

**特例 — 你自己用引导词**:
- 你输出 finding 时,也不要用"显然 / 实际上"等引导词
- 用"客观证据 + 严重程度判定"代替主观断言
```

- [ ] **Step 4: 填充 §4.4 反对而反对(挑战者过度否定,~20 行)**

完整内容:

```markdown
### §4.4 反对而反对(挑战者过度否定)

挑战者带"对抗者"立场,可能产生"为找问题而找问题"的倾向。

**自检**:
- 这个 finding 有事实和逻辑支撑,还是只是"听起来不对"?
- 如果对方给出充分证据反驳我的 finding,我会撤回吗?
  - ✅ 会撤回 = 基于证据的反对(正常)
  - ❌ 不会撤回 = 立场化反对(危险信号)
- 我提的 finding 是否带有"我必须找出问题来证明我有用"的潜意识?

**不要做**:
- 写"应该重构成 X" / "应该用 Y 方案" / "应该改成 Z 风格"
- 你的职责是**找问题附证据**,不是**提替代方案**

**核心边界**:挑战者 = 对抗者,不是评审委员会。
```

- [ ] **Step 5: 填充 §4.5 越权设计(~15 行)**

完整内容:

```markdown
### §4.5 越权设计(挑战者超出找问题边界)

**你只做**:
- 找问题
- 附证据(file:line + 原文 quote)
- 标严重程度(🔴 / 🟡 / 🟢)

**你不做**:
- 提替代方案("应该改用 X")
- 给整体打分("总体 7/10")
- 决定是否通过("该 finding 应该升 P0 阻塞")
- 修改 spec / 代码 / 文档
- 跟其他挑战者协商("我看到挑战者 1 说...")

**为什么**:对抗-决策分离原则(`multi-agent-review-guide.md`)— 你是对抗者,领审员(调度者)是决策者。你越权 = 决策不独立 = 公设 1 失效。
```

- [ ] **Step 6: 验证 §4 + 全文行数**

Run: `awk '/^## §4 /,/EOF/' harness/docs/references/challenger-orientation.md | wc -l`
Expected: 95-120 行(预算 105 行 ± 15%)

Run: `wc -l harness/docs/references/challenger-orientation.md`
Expected: 580-640 行(总预算 400-600 行,实际略超因 §1+§2+§3+§4 含表格 + 代码块)

- [ ] **Step 7: 全文自检**

Run 三个 grep:

```bash
# 1. 4 节标题齐全
grep -c "^## §[1-4] " harness/docs/references/challenger-orientation.md
# Expected: 4

# 2. 跨平台路径双版本
grep -c "Windows\|Linux/Mac" harness/docs/references/challenger-orientation.md
# Expected: ≥ 2(§2.3 含 Windows + Linux/Mac 各 2 次)

# 3. 输出必填 section 模板含 timestamp + quote
grep -c '\[timestamp\]' harness/docs/references/challenger-orientation.md
# Expected: ≥ 1
```

- [ ] **Step 8: Commit 1**

```bash
git add harness/docs/references/challenger-orientation.md
git commit -m "$(cat <<'EOF'
docs(challenger-orientation): 新建 challenger-orientation.md — 4 节挑战者侧导览

新建 harness/docs/references/challenger-orientation.md(~600 行),挑战者(fork 出的
subagent)的"入门必读"。4 节内容:

- §1 方法论:通用自检清单 6 条 + 4 agent 角色专属技巧(矛盾追踪 / 场景遍历 /
  反向追问 / 条款对照 / 路径追踪 / 模式扫描 / 治理对照 / 情绪信号 等)+ 实操技巧
  (证据深度 🟢 弱 / 🟡 中 / 🔴 强;严重程度 🔴 必修 / 🟡 建议 / 🟢 轻微)
- §2 数据来源向导:harness 全局架构 + 文档索引 + 跨平台路径(Windows + Linux/Mac)
  + 项目 slug 推断脚本(参 process-auditor.md)+ 常见审查问题对应数据源 +
  实操命令模板(node grep user message)
- §3 输入策略:调度者给你什么 + 批判看调度者(✅/❌ 对照)+ 自取用户原话 +
  输出必填 `### 已对照用户原话` section(reject 条件)
- §4 常见陷阱:公设 1 应用 / spec_gap_masking 检测(信号 A + B)/ framing 警惕 /
  反对反对 / 越权设计(对抗-决策分离)

对称主智能体侧 CLAUDE.md + Skill 地图 — 挑战者跟 governance 之间的"知识传递"机制。
本 commit 仅新建文件;Commit 2 改 4 agent 文件 include 引用,Commit 3 governance
+ README 同步。

spec: harness/docs/superpowers/specs/2026-05-26-challenger-orientation-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

# Verify
git log --stat -1
```

Expected: 1 file changed, ~580+ insertions(+)

---

## Task 6: 改 design-reviewer.md(删 governance 实文 + include 引用 + 4 挑战者输出必填段)

**Files:**
- Modify: `harness/.claude/agents/design-reviewer.md`(336 行 → ~265 行)

**Spec 来源:** §3.2.2 / §4.2

- [ ] **Step 1: Read 当前文件,定位待删段**

Run: `grep -n "^### 第一步前 \|^### 第五步 " harness/.claude/agents/design-reviewer.md`

Expected output(确认两段位置):
```
37:### 第一步前 — fork 前意图识别(synthesis-rules 事前规则 5)
314:### 第五步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)
```

- [ ] **Step 2: 删除 "第一步前 — fork 前意图识别" 整节(行 37-55,约 19 行)**

删除范围:从 `### 第一步前 — fork 前意图识别` 开始,到下一节 `### 第一步:在一条消息中并行 fork 4 个挑战者` 之前(不含)。

- [ ] **Step 3: 删除 "第五步 — 综合后给用户的口语报告" 整节(行 314-337,约 24 行)**

删除范围:从 `### 第五步 — 综合后给用户的口语报告` 开始,到文件末尾(该节是最后一节)。

- [ ] **Step 4: 在原 "第一步前" 位置加新段 "Fork 流程协议"**

在原 "第一步前" 位置(现在变成 `### 第一步:在一条消息中并行 fork 4 个挑战者` 之前)插入新段:

```markdown
### Fork 流程协议(synthesis-rules + challenger-orientation 引用)

本 agent fork 4 个挑战者时遵守以下协议:

- **事前**:`harness/docs/governance/synthesis-rules.md` 事前规则 5(fork 前意图识别)— prompt 注入"主线-支线-关系"段(在每个挑战者 prompt 的 A/B/C 三段或 N/G 段之前)
- **挑战者侧导览**:每个挑战者 prompt 必含 1 行 "**先 Read `harness/docs/references/challenger-orientation.md`**,然后再开始审查;输出格式必填末尾 section `### 已对照用户原话`"
- **事后**:`synthesis-rules.md` 综合输出表达准则(用户报告 4 段)+ 综合时校验挑战者 "已对照用户原话" section(缺失或空泛 reject,见 synthesis-rules.md 事后规则 5)

> **静态约束(fix-2 恢复)**:本 agent 文件不抄 synthesis-rules / challenger-orientation 实文,只引用路径(第七轮 fix-2 静态约束;本 batch 2026-05-26 KG3 fix 落实)。
```

- [ ] **Step 5: 4 挑战者 prompt 头部加 1 行 include**

定位每个挑战者 prompt 块(共 4 个,搜索 `#### 挑战者 [1-4]:`):

```bash
grep -n "^#### 挑战者 [1-4]:" harness/.claude/agents/design-reviewer.md
```

在每个挑战者 prompt 块的 ` ``` ` 起始行之后(prompt 内第一行),加 1 行:

```
**先 Read `harness/docs/references/challenger-orientation.md`(挑战者导览),然后再开始审查。**
```

- [ ] **Step 6: 4 挑战者 prompt 输出格式段加必填段**

定位每个挑战者 prompt 的 `## 输出格式` 段:

```bash
grep -n "^## 输出格式" harness/.claude/agents/design-reviewer.md
```

在每个 `## 输出格式` 段的"对每个发现,输出:"+ 示例后,加一段(在 prompt 闭合 ``` 之前):

````markdown
**输出最末必填 section**(挑战者侧 spec_gap_masking 防御 — 跟用户原话留痕):

```markdown
### 已对照用户原话

**从 JSONL 抽取的用户原话**(N 条,按时间序;详 challenger-orientation.md §3.4):
1. [timestamp] "原话片段 1"
...

**主线-支线-关系校验结论**:
- 主线对应用户原诉求:✅ / 🟡 / 🔴
- 支线对应调度者意图:✅ / 🟡
- 关系字段是任务边界:✅ / 🟡

(如发现偏离 🔴)主线偏离 finding 详细。
```

> 缺失或空泛(无 timestamp + 完整 quote)→ 调度者综合时 reject,要求重审。
````

- [ ] **Step 7: 综合阶段段加 reject 逻辑**

定位 `### 第二步:汇总——共识/分歧/盲区`:

```bash
grep -n "^### 第二步:汇总" harness/.claude/agents/design-reviewer.md
```

在该节首段后(`挑战者返回后(至少 3 个成功),按三层汇总:` 之前),加一段:

```markdown
**预校验(挑战者输出完整性)**:汇总前先校验每个挑战者输出:

- 缺末尾 `### 已对照用户原话` section → reject 该挑战者,要求重审(参 `synthesis-rules.md` 事后规则 5)
- section 内容空泛(无 timestamp + 完整 quote)→ reject
- section 显示主线偏离 🔴 → 升级为共识阶段 finding,可能触发主线段重写
```

- [ ] **Step 8: 验证改动**

Run 3 个 grep 验证:

```bash
# 1. governance 实文已删
grep -c "事前规则 5 — fork 前必做意图识别" harness/.claude/agents/design-reviewer.md
# Expected: 0

grep -c "综合输出表达准则" harness/.claude/agents/design-reviewer.md
# Expected: ≤ 1(只剩"Fork 流程协议"段的引用)

# 2. include 引用齐全
grep -c "challenger-orientation.md" harness/.claude/agents/design-reviewer.md
# Expected: ≥ 5(1 流程协议段 + 4 挑战者 prompt 头各 1)

# 3. 4 挑战者必填段齐全
grep -c "### 已对照用户原话" harness/.claude/agents/design-reviewer.md
# Expected: ≥ 5(1 综合阶段引用 + 4 挑战者 prompt 必填段)
```

- [ ] **Step 9: 行数核对**

Run: `wc -l harness/.claude/agents/design-reviewer.md`
Expected: 260-280 行(原 336 行,净减 ~50-70 行)

---

## Task 7: 改 evaluator.md(同 Task 6 模式,4 挑战者)

**Files:**
- Modify: `harness/.claude/agents/evaluator.md`(480 行 → ~410 行)

**Spec 来源:** §3.2.2 / §4.3

- [ ] **Step 1: Read 当前文件,定位待删段**

Run: `grep -n "^### 第二步前 \|^### 第九步 " harness/.claude/agents/evaluator.md`

Expected output:
```
44:### 第二步前 — fork 前意图识别(synthesis-rules 事前规则 5)
458:### 第九步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)
```

- [ ] **Step 2: 删除 "第二步前 — fork 前意图识别" 整节(行 44-62,约 19 行)**

删除范围:从 `### 第二步前 — fork 前意图识别` 到 `### 第二步:在一条消息中并行 fork 4 个挑战者` 之前。

- [ ] **Step 3: 删除 "第九步 — 综合后给用户的口语报告" 整节(行 458-481,约 24 行)**

删除范围:从 `### 第九步 — 综合后给用户的口语报告` 到文件末尾。

- [ ] **Step 4-7: 同 Task 6 Step 4-7**

- Step 4: 在原 "第二步前" 位置加 "Fork 流程协议" 段(注意:evaluator 这里是第二步前,不是第一步前)
- Step 5: 4 挑战者 prompt 头部加 include 引用(注意 evaluator 4 挑战者结构含 scope 参数处理段,挑战者 prompt 块定位:`grep -n "^#### 挑战者 [1-4]:" harness/.claude/agents/evaluator.md`)
- Step 6: 4 挑战者 prompt 输出格式段加必填段
- Step 7: 综合阶段段加 reject 逻辑(定位 `### 第三步:汇总——共识/分歧/盲区`)

- [ ] **Step 8: 验证改动(同 Task 6 Step 8 模式)**

Run:
```bash
grep -c "事前规则 5 — fork 前必做意图识别" harness/.claude/agents/evaluator.md
# Expected: 0

grep -c "challenger-orientation.md" harness/.claude/agents/evaluator.md
# Expected: ≥ 5

grep -c "### 已对照用户原话" harness/.claude/agents/evaluator.md
# Expected: ≥ 5
```

- [ ] **Step 9: 行数核对**

Run: `wc -l harness/.claude/agents/evaluator.md`
Expected: 395-425 行(原 480 行,净减 ~55-85 行)

---

## Task 8: 改 process-auditor.md(同 Task 6 模式,2 挑战者;保留预处理 JSONL 脚本段)

**Files:**
- Modify: `harness/.claude/agents/process-auditor.md`(446 行 → ~385 行)

**Spec 来源:** §3.2.2 / §4.4

**注意**:process-auditor.md §2"预处理会话 JSONL"段(约 120 行 Node.js 脚本)是 process-audit 专用(处理整 session 摘要,不与 challenger-orientation §2.5 命令模板重复),**保留不删**。

- [ ] **Step 1: Read 当前文件,定位待删段**

Run: `grep -n "^### 第三步前 \|^### 第六步 " harness/.claude/agents/process-auditor.md`

Expected output:
```
184:### 第三步前 — fork 前意图识别(synthesis-rules 事前规则 5)
424:### 第六步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)
```

- [ ] **Step 2: 删除 "第三步前 — fork 前意图识别" 整节(行 184-203,约 19 行)**

- [ ] **Step 3: 删除 "第六步 — 综合后给用户的口语报告" 整节(行 424-447,约 24 行)**

- [ ] **Step 4: 在原 "第三步前" 位置加 "Fork 流程协议" 段**

(同 Task 6 Step 4 模板,但 process-audit 是事实统计式 D2 模态,prompt 含 N1/N2/G 段而非 A/B/C 三段。"主线-支线-关系"段位置改为"在 N1/N2/G 段之前")

- [ ] **Step 5: 2 挑战者 prompt 头部加 include 引用**

定位:`grep -n "^#### 挑战者 [1-2]:" harness/.claude/agents/process-auditor.md`

- [ ] **Step 6: 2 挑战者 prompt 输出格式段加必填段**

定位:`grep -n "^### 流程遵从度\|^### 效果与满意度" harness/.claude/agents/process-auditor.md`(process-auditor 输出格式段用 ### 级标题)

- [ ] **Step 7: 综合阶段段加 reject 逻辑**

定位:`grep -n "^### 第四步:汇总报告" harness/.claude/agents/process-auditor.md`

- [ ] **Step 8: 验证改动(同 Task 6 Step 8)**

注意:由于 process-auditor.md 内部脚本含 `console.log` 等代码,grep "事前规则 5" 时可能命中代码内字符串(若有)。验证时:

```bash
grep -c "事前规则 5 — fork 前必做意图识别" harness/.claude/agents/process-auditor.md
# Expected: 0(完整的节标题不应留存)

grep -c "challenger-orientation.md" harness/.claude/agents/process-auditor.md
# Expected: ≥ 3(1 流程协议段 + 2 挑战者 prompt 头各 1)

grep -c "### 已对照用户原话" harness/.claude/agents/process-auditor.md
# Expected: ≥ 3(1 综合阶段引用 + 2 挑战者必填段)
```

- [ ] **Step 9: 行数核对**

Run: `wc -l harness/.claude/agents/process-auditor.md`
Expected: 375-400 行(原 446 行,净减 ~45-70 行)

---

## Task 9: 改 security-reviewer.md(同 Task 6 模式,3 挑战者)+ Commit 2

**Files:**
- Modify: `harness/.claude/agents/security-reviewer.md`(298 行 → ~245 行)

**Spec 来源:** §3.2.2 / §4.5

- [ ] **Step 1: Read 当前文件,定位待删段**

Run: `grep -n "^### 第二步前 \|^### 第六步 " harness/.claude/agents/security-reviewer.md`

Expected output:
```
33:### 第二步前 — fork 前意图识别(synthesis-rules 事前规则 5)
276:### 第六步 — 综合后给用户的口语报告(synthesis-rules 综合输出表达准则)
```

- [ ] **Step 2: 删除 "第二步前 — fork 前意图识别" 整节(行 33-52,约 19 行)**

- [ ] **Step 3: 删除 "第六步 — 综合后给用户的口语报告" 整节(行 276-299,约 24 行)**

- [ ] **Step 4: 在原 "第二步前" 位置加 "Fork 流程协议" 段**

(同 Task 6 Step 4 模板,security-scan 是混合式 D2 模态,prompt 含 X 段硬编码 pattern + A/B/C 对抗维度部分。"主线-支线-关系"段位置改为"在该 prompt 主体之前")

- [ ] **Step 5: 3 挑战者 prompt 头部加 include 引用**

定位:`grep -n "^#### 挑战者 [1-3]:" harness/.claude/agents/security-reviewer.md`

- [ ] **Step 6: 3 挑战者 prompt 输出格式段加必填段**

定位每个挑战者 prompt 内 "输出:" 或 "## 输出" 段。

- [ ] **Step 7: 综合阶段段加 reject 逻辑**

定位:`grep -n "^### 第三步:汇总结果" harness/.claude/agents/security-reviewer.md`

- [ ] **Step 8: 验证改动(同 Task 6 Step 8)**

```bash
grep -c "事前规则 5 — fork 前必做意图识别" harness/.claude/agents/security-reviewer.md
# Expected: 0

grep -c "challenger-orientation.md" harness/.claude/agents/security-reviewer.md
# Expected: ≥ 4(1 流程协议段 + 3 挑战者 prompt 头各 1)

grep -c "### 已对照用户原话" harness/.claude/agents/security-reviewer.md
# Expected: ≥ 4(1 综合阶段引用 + 3 挑战者必填段)
```

- [ ] **Step 9: 行数核对**

Run: `wc -l harness/.claude/agents/security-reviewer.md`
Expected: 230-260 行(原 298 行,净减 ~40-70 行)

- [ ] **Step 10: 4 agent 文件全局自检(KG3 fix 验证)**

跑 4 agent 文件总行数 + governance 实文残留检查:

```bash
# 1. 4 agent 总行数(原 1560 行)
wc -l harness/.claude/agents/{design-reviewer,evaluator,process-auditor,security-reviewer}.md
# Expected: ~1260-1370 行(净减 ~190-300 行,目标 ≈ 上 batch KG3 报的 176 行)

# 2. governance 实文残留(预期 0 节完整复制)
for f in harness/.claude/agents/{design-reviewer,evaluator,process-auditor,security-reviewer}.md; do
  echo "=== $f ==="
  grep -c "事前规则 5 — fork 前必做意图识别" "$f"
  grep -c "综合输出表达准则" "$f"
done
# Expected: 4 个 0 + 4 个 ≤ 1
```

- [ ] **Step 11: Commit 2**

```bash
git add harness/.claude/agents/design-reviewer.md harness/.claude/agents/evaluator.md \
        harness/.claude/agents/process-auditor.md harness/.claude/agents/security-reviewer.md
git commit -m "$(cat <<'EOF'
docs(challenger-orientation): 4 agent 文件改 include 模式 — KG3 顺手解

4 agent 文件 prompt 改 include 模式,删 ~190-300 行 governance 实文重复(KG3
上 batch 报 ~176 行重复落实,fix-2 静态约束恢复)。

每文件改动:
- 删 "第 X 步前 — fork 前意图识别" 整节(~19 行)
- 删 "第 N 步 — 综合后给用户的口语报告" 整节(~24 行)
- 加 "Fork 流程协议" 段(~10 行)— 引用 synthesis-rules.md 路径 +
  挑战者侧 challenger-orientation.md 路径,不抄实文
- 4(或 2 / 3)挑战者 prompt 头部加 1 行 "先 Read challenger-orientation.md"
- 4(或 2 / 3)挑战者 prompt 输出格式段加必填末尾 section `### 已对照用户原话`
- 综合阶段段加 reject 逻辑(缺/空 section 视为未完成)

涉及:
- design-reviewer.md(336 → ~265 行,4 挑战者)
- evaluator.md(480 → ~410 行,4 挑战者)
- process-auditor.md(446 → ~385 行,2 挑战者;保留预处理 JSONL 脚本段)
- security-reviewer.md(298 → ~245 行,3 挑战者)

spec: harness/docs/superpowers/specs/2026-05-26-challenger-orientation-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

# Verify
git log --stat -1
```

Expected: 4 files changed, ~60-100 insertions(+), ~250-360 deletions(-)

---

## Task 10: 改 synthesis-rules.md(加事后规则 5)

**Files:**
- Modify: `harness/docs/governance/synthesis-rules.md`(+30 行)

**Spec 来源:** §3.3

- [ ] **Step 1: Read 当前文件,定位事后规则节末尾**

Run: `grep -n "^### [0-9]\. \|^## " harness/docs/governance/synthesis-rules.md | head -20`

定位 "事后规则" 节 + 现有 4 条规则的末尾(规则 4 节末尾,在 `## 综合输出表达准则` 之前)。

- [ ] **Step 2: 在事后规则 4 节后追加规则 5**

完整内容追加(在 "### 4. 避免先入为主" 节末尾,`---` 分隔符之前):

```markdown
### 5. 校验挑战者"已对照用户原话"section(挑战者侧自取机制的综合阶段落地)

调度者综合每个挑战者输出时,**必须校验末尾 `### 已对照用户原话` section**:

**reject 条件**(任一命中 → 要求该挑战者重审):
- section 缺失
- section 内容空泛(无 timestamp + 完整 quote)
- "用户原话" 列出 < 1 条
- 主线-支线-关系校验结论全部 ✅ 但 finding 中含主线偏离问题(自相矛盾)

**升级条件**:section 显示主线偏离 🔴 → 升为综合阶段 finding,可能触发主线段重写。

**适用范围**:design-review / evaluate / process-audit / security-scan / meta-review 所有 fork 场景 — 与事前规则 5 同步生效。

**与挑战者侧导览的关系**:本规则的挑战者侧动作落入 `harness/docs/references/challenger-orientation.md` §3.3(自取用户原话)+ §3.4(输出必填 section)。本规则是调度者综合阶段的校验落地。

**例外**:
- 若挑战者明确标 "⚠️ 无法定位会话 JSONL,跳过主线校验" 且解释合理 → 不 reject,但在 audit trail 记录
- 若挑战者标 "⚠️ 信息不足无法判断" 但解释合理 → 不 reject(信号 B 防 spec_gap_masking)
```

- [ ] **Step 3: 验证改动**

Run:
```bash
grep -c "^### 5\. 校验挑战者" harness/docs/governance/synthesis-rules.md
# Expected: 1

grep -c "challenger-orientation.md" harness/docs/governance/synthesis-rules.md
# Expected: ≥ 1
```

---

## Task 11: 改 multi-agent-review-guide.md(加对称引用段)

**Files:**
- Modify: `harness/docs/references/multi-agent-review-guide.md`(+6 行)

**Spec 来源:** §3.4

- [ ] **Step 1: Read 当前文件顶部**

Run: `head -10 harness/docs/references/multi-agent-review-guide.md`

定位 "> 所有审查类 agent" 段 + "> 本文件定义审查原则" 段。

- [ ] **Step 2: 在文件顶部 blockquote 段后,加 1 段对称引用**

在第 4-5 行(原 `> 本文件定义审查原则和操作模式...` 之后)插入新段:

```markdown
> **本指南面向"领审员"视角**(谁来设计审查 agent / 怎么切分维度 / 怎么综合)。
>
> **挑战者(fork 出的子智能体)视角的导览**另见 `harness/docs/references/challenger-orientation.md`(方法论 / 数据来源向导 / 输入策略 / 常见陷阱)— **挑战者必读**。
>
> 两者对称:本指南管"领审员侧 / 调度者侧",challenger-orientation.md 管"挑战者侧"。
```

- [ ] **Step 3: 验证改动**

Run:
```bash
grep -c "challenger-orientation.md" harness/docs/references/multi-agent-review-guide.md
# Expected: ≥ 1

head -15 harness/docs/references/multi-agent-review-guide.md
# 确认新段格式 + 位置正确
```

---

## Task 12: 改 README.md(加 §4.X 挑战者导览体系一节)+ Commit 3

**Files:**
- Modify: `README.md`(根级,+20 行)

**Spec 来源:** §3.5

- [ ] **Step 1: Read README.md §4 原理段**

Run: `grep -n "^## \|^### " README.md | head -30`

定位 §4 原理段及其子节末尾(§4.X 一节将在最后追加)。

- [ ] **Step 2: 在 §4 原理段末尾追加新小节**

新小节完整内容:

```markdown
### 4.X 挑战者导览体系(挑战者侧基础设施)

主智能体(调度者)进项目时读 `CLAUDE.md` 知道项目结构 / Skill 地图 / 文档索引。挑战者(fork 出的子智能体)对称地需要一份"挑战者侧导览" — 知道:

- **怎么找问题**(方法论 — 通用自检清单 + 角色专属技巧:矛盾追踪 / 场景遍历 / 反向追问 / 条款对照 等)
- **去哪找信息**(数据来源向导 — 跨平台路径 + 命令模板 + 项目 slug 推断脚本)
- **怎么看调度者输入**(批判看 + 自取用户原话校验主线 framing)
- **哪些陷阱要避**(公设 1 / spec_gap_masking / framing / 反对反对 / 越权)

实现在 `harness/docs/references/challenger-orientation.md`。fork 挑战者时 prompt 内含"先 Read 此文件";挑战者输出格式末尾必填 `### 已对照用户原话` section,调度者综合时校验(`synthesis-rules.md` 事后规则 5 落地)。

**与下游的关系**:本文件属 `references/`,setup.sh 复制下游 — 下游项目的挑战者也用同一份导览。
```

(注意:数字 X 的具体值在 README 现有 §4 结构内确定,保持与现有子节连续编号)

- [ ] **Step 3: 验证改动**

Run:
```bash
grep -c "挑战者导览体系" README.md
# Expected: ≥ 1

grep -c "challenger-orientation.md" README.md
# Expected: ≥ 1
```

- [ ] **Step 4: Commit 3(governance + 引用 + README 同步)**

```bash
git add harness/docs/governance/synthesis-rules.md \
        harness/docs/references/multi-agent-review-guide.md \
        README.md
git commit -m "$(cat <<'EOF'
docs(challenger-orientation): synthesis-rules 事后规则 5 + 引用对齐 + README 同步

3 文件同步本 batch 主体改动:

1. synthesis-rules.md 加事后规则 5(+30 行):
   - 校验挑战者输出末尾 `### 已对照用户原话` section
   - reject 条件:缺失 / 空泛 / 自相矛盾
   - 升级条件:主线偏离 🔴 → 综合阶段 finding
   - 适用 design-review / evaluate / process-audit / security-scan / meta-review
   - 例外:⚠️ 信息不足 / JSONL 不可定位的解释合理不 reject

2. multi-agent-review-guide.md 加对称引用段(+6 行):
   - 明确两文件对称(领审员侧 vs 挑战者侧)
   - 引用 challenger-orientation.md 路径

3. README.md §4.X 加挑战者导览体系一节(+20 行):
   - 原理段透出新机制
   - 主智能体侧 CLAUDE.md ↔ 挑战者侧 challenger-orientation.md 的对称关系

spec: harness/docs/superpowers/specs/2026-05-26-challenger-orientation-design.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

# Verify
git log --stat -1
```

Expected: 3 files changed, ~50-60 insertions(+)

---

## Task 13: 全局自检 + 闭环准备(meta-finishing 前置)

**Files:**
- Read-only verification across all changed files

**Spec 来源:** §6.2 验收清单 + §10 验收 Checklist

- [ ] **Step 1: spec G1-G6 目标核对**

逐目标 grep 验证落地:

```bash
# G1 — 挑战者有统一方法论
grep -c "^### §1\.[1-6]" harness/docs/references/challenger-orientation.md
# Expected: 6

# G2 — 数据来源向导
grep -c "^### §2\.[1-5]" harness/docs/references/challenger-orientation.md
# Expected: 5

# G3 — 输入策略
grep -c "^### §3\.[1-4]" harness/docs/references/challenger-orientation.md
# Expected: 4

# G4 — 常见陷阱
grep -c "^### §4\.[1-5]" harness/docs/references/challenger-orientation.md
# Expected: 5

# G5 — KG3 顺手解(4 agent governance 实文 0 残留)
for f in harness/.claude/agents/{design-reviewer,evaluator,process-auditor,security-reviewer}.md; do
  if grep -q "事前规则 5 — fork 前必做意图识别" "$f"; then
    echo "FAIL: $f 还含完整事前规则 5 节"
  fi
done
# Expected: 无 FAIL 输出

# G6 — 不引入新 skill / hook
test ! -e harness/.claude/skills/*orientation* && \
test ! -e harness/.claude/hooks/*orientation* && \
echo "G6 PASS: 无新 skill / hook"
```

- [ ] **Step 2: synthesis-rules.md 事后规则数核对**

```bash
grep -c "^### [0-9]\. " harness/docs/governance/synthesis-rules.md
# Expected: 9(事前 5 条 + 事后 4+1=5 条 — 看具体编号风格,以原编号为准)
# 主要确认事后规则数加了 1 条
```

- [ ] **Step 3: multi-agent-review-guide.md / README.md 引用核对**

```bash
grep -c "challenger-orientation.md" harness/docs/references/multi-agent-review-guide.md
# Expected: ≥ 1

grep -c "challenger-orientation\|挑战者导览" README.md
# Expected: ≥ 1
```

- [ ] **Step 4: 全 commit 历史核对**

```bash
git log --oneline -5
# Expected:
# <commit3 hash> docs(challenger-orientation): synthesis-rules 事后规则 5 + 引用对齐 + README 同步
# <commit2 hash> docs(challenger-orientation): 4 agent 文件改 include 模式 — KG3 顺手解
# <commit1 hash> docs(challenger-orientation): 新建 challenger-orientation.md — 4 节挑战者侧导览
# d0da183 docs(challenger-orientation): spec 立 — 4 节导览 + 4 agent KG3 顺手解 + 挑战者侧自取
# e9d8b2b docs(fork-intent): meta-review pass-after-revision — fix + audit + handoff

git log --stat --oneline -4 | head -50
# 确认 4 commit 总改动:1 新建文件(~600 行)+ 8 改动文件(~-200/+100 行)
```

- [ ] **Step 5: 准备 meta-finishing 输入**

确认以下准备就绪(meta-finishing 阶段会用):
- spec 路径:`harness/docs/superpowers/specs/2026-05-26-challenger-orientation-design.md`
- plan 路径:本文件
- 改动 commit 范围:`d0da183..HEAD`(spec + 3 实施 commits)
- Evidence Depth 目标:meta-L2(参 spec §6.1)
- Meta-review 模态:对抗式 D2,fork 4 挑战者(spec §5.3)

输出准备段(给 meta-finishing 用):

```text
## meta-finishing 准备

- batch_name: challenger-orientation-system
- scope: meta
- commits: d0da183..HEAD(4 个)
- 涉及文件: 8(1 新建 + 7 改动)
- finishing 路径: M1(meta-finishing-rules.md)+ M2(meta-review-rules.md)
- Evidence Depth 目标: meta-L2
- Meta-review 模态: 对抗式 D2,4 挑战者(C1 核心原则 + C2 目的达成 + C3 副作用 + scope 漂移 + C4 挑战者侧自取可执行性定制专项)
- 已知预期 audit finding 类: 同 spec §6.3 KG-A/B/C/D + R1-R5 风险
```

- [ ] **Step 6: 闭环通知**

实施完成。下一步进 **meta-finishing 流程**(`harness/docs/governance/meta-finishing-rules.md`):
- Step A: scope 判定(scope=meta 已确认)
- Step B: meta-review fork(对抗式 D2,4 挑战者)
- Step C: 综合 findings + 修订
- Step D: decision-trail / handoff append + push origin/main

---

## 后置 — 已知边界 / 不在本 plan 范围内

- **decision-trail.md / handoff.md 更新**:这两个文件在 meta-finishing Step D 同步,不在本 plan 范围(避免本 plan 跑完前 decision-trail 提前 append)
- **meta-review 自己**:M1+M2 流程在本 plan 外,由 finishing 阶段触发
- **push origin/main**:meta-review pass 后才执行,本 plan 不含
- **dogfooding 验证**(挑战者真按导览做事):依赖本 plan 完成后跑 meta-review 那次 fork — 是 meta-L2 实战验证的内容,不在本 plan 范围

---

## Spec ↔ Plan 对照(self-review)

| Spec 节 | 对应 Task | 备注 |
|---|---|---|
| §3.1.1 frontmatter + 导读 | Task 1 | 骨架 |
| §3.1.2 §1 方法论 6 子节 | Task 2 | 填充 |
| §3.1.3 §2 数据来源向导 5 子节 | Task 3 | 填充 |
| §3.1.4 §3 输入策略 4 子节 | Task 4 | 填充 |
| §3.1.5 §4 常见陷阱 5 子节 | Task 5 | 填充 + Commit 1 |
| §3.2 4 agent 文件改造 | Task 6-9 | 各文件 1 task + Commit 2 |
| §3.3 synthesis-rules 事后规则 5 | Task 10 | |
| §3.4 multi-agent-review-guide 引用 | Task 11 | |
| §3.5 README.md 原理段 | Task 12 | + Commit 3 |
| §6 验收 / Evidence Depth | Task 13 | 自检 |
| §9 commit 策略 | Task 5/9/12 commit 步 | 3 commits |
| §10 验收 Checklist | Task 13 自检步 | meta-finishing 前置 |

**Spec 全覆盖** ✅

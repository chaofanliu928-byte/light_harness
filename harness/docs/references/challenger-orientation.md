---
audience: 挑战者(fork 出的 subagent)
purpose: 给挑战者(子智能体)提供方法论 / 数据来源 / 输入策略 / 陷阱避坑的"入门必读"
when_to_read: fork 你的时候,prompt 内含 "先 Read `harness/docs/references/challenger-orientation.md`" — 这是必读第一步
distribution: 本文件分发到下游(setup.sh 复制 references/)
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

**对抗-决策分离原则**(参 `harness/docs/references/multi-agent-review-guide.md`):你是**对抗者**,不是评分员;只找问题,不打分;只附证据,不提替代方案。调度者(领审员)负责综合 + 评分。

**4 个原则**:

1. **独立视角不重叠** — 你的维度跟别的挑战者不重叠,你的发现要互补不冗余
2. **对抗不是验证** — 不要"看看这个方案对不对",要"找 N 个最可能让它失败的地方"
3. **可验证输出** — 每个发现指向具体 file:line 或文档:章节,附原文 quote
4. **结论可争议** — 不写"总体不错",每个发现要可被其他挑战者反驳

**通用自检清单**(每次审查前默走一遍):

- [ ] 真读了调度者给的待审对象原文(spec / agent 文件 / 代码 / diff)?
- [ ] 对照过用户原话原文(从会话 JSONL 自取,不依赖调度者"主线"字段)?
- [ ] 每个发现指向 file:line 或文档:章节,附原文 quote?
- [ ] 严重程度判定有客观标准,不靠"感觉"?
- [ ] 是否做假设(应改用客观证据)?
- [ ] 是否提了替代方案(应只找问题,不写新方案)?

跑完审查后如果产出 0 个 finding — **必须说明**:你具体检查了什么(对照表)/ 为什么认为没问题(逐项)。不附检查清单的"✅ 全部通过"等于没做(参 §4.1 公设 1)。

### §1.2 design-review 4 挑战者专属

**挑战者 1(自洽性)** — 矛盾追踪法

- 把 spec 各章节内容映射到一张表(章节 → 关键概念 → 描述)
- 跨章节比对:同一概念在 A 章节 / B 章节的描述是否一致
- 找接口双方对齐(调用方期望 vs 实现方签名)/ 数据模型一致 / 状态机完整(死状态 / 不可达状态) / 模块依赖循环 / 错误传播连贯

**挑战者 2(完整性)** — 场景遍历法

- 把 spec §1.2 核心场景逐条列出
- 每个场景遍历:模块 → 接口 → 数据流 → 边界 → 测试,看哪一环没写或写不够
- 找"模糊到要猜测"的描述 — 可猜测度高 = 完整性差

**挑战者 3(过度工程化)** — 反向追问法

- 找疑似过度结构(wrapper / factory / adapter 只用一次 / 间接层 / 未来预留接口)
- 对每个疑似过度结构反问:**"不用这个方式,之前的问题怎么解?"**(参用户校准 `[[feedback_dimension_addition_judgment]]`)
- 反问有清晰替代解法 → 标过度;无 → 标必要;不要拿"看着复杂"就标

**挑战者 4(RUBRIC 对齐)** — 条款对照法

- 逐条对照 RUBRIC.md 惩罚项 / 奖励项
- 对照 spec §7(设计决策 / RUBRIC 应对方式)vs 实际设计:承诺了但没做到的标 finding
- 项目特定标准仍含占位文本(`[列出你不想看到的具体模式]` 等)的节,标"⚠️ 该节未自定义",跳过

### §1.3 evaluator 4 挑战者专属

**挑战者 1(RUBRIC 合规)** — 条款对照法 + 测试充分性专项

- 同 §1.2 挑战者 4 的条款对照法
- **测试充分性专项**:按 scope 参数引 evidence depth 文件:
  - `scope=feature` → 引 `harness/docs/references/testing-standard.md`(L1-L4)
  - `scope=meta` → 引 `harness/docs/governance/meta-finishing-rules.md`(meta-L1~meta-L4)
  - `scope=mixed` → 同时引两份(meta + feature 双套档位均评)
- 检查:声称的 L 层级是否有对应 evidence(命令 / 输出 / 文件路径)?声称 L3 自动化但没脚本 = 虚假声明

**挑战者 2(架构一致性)** — 路径追踪法

- 找 import 路径,看是否违反 `harness/docs/ARCHITECTURE.md` 分层(若 ARCHITECTURE.md 不存在,跳过并标注)
- 找模块划分实现 vs spec §2 偏离
- 找接口签名实现 vs spec §3 不匹配
- 找共享类型契约定义 vs 实际使用对齐

**挑战者 3(文档健康)** — README 对照法

- 涉及的每个模块 README 是否存在?
- README 描述的接口 vs 代码实际导出是否一致?
- README 描述的依赖 vs 代码 import 是否一致?
- 变更历史是否更新(本次改动涉及的模块 README 是否有变更记录)?
- 设计文档本身是否与最终实现一致(写了但没实现 / 实现了但没写)?

**挑战者 4(Slop 检测)** — 模式扫描法

- 代码漂移:命名一致性(camelCase vs snake_case 混用) / 重复实现 / 僵尸依赖(import 但没用) / 过时模式
- 文档漂移:模块 README > 80 行(臃肿) / 不同模块 README 格式不统一 / 变更历史 > 20 条(该归档)

### §1.4 process-audit 2 挑战者专属

**挑战者 1(流程遵从度)** — 治理对照法

- 把 governance 规则列出(`brainstorming-rules.md` / `design-rules.md` / `planning-rules.md` / `implementation-rules.md` / `testing-rules.md` / `review-rules.md` / `finishing-rules.md`)
- 对照本批 session 摘要,看每阶段是否执行:brainstorming 是否做了 / 需求确认后才进设计 / system-design 是否调用 / design-review 是否调用 / planning 是否基于 spec / 实现是否守行为约束 / 文档先于代码 / RUBRIC 是否参考
- 标 ✅ 遵守 / ❌ 违反 / ⚠️ 部分遵守 / ➖ 不适用(该阶段未发生)

**挑战者 2(效果满意度)** — 情绪信号识别法 + 关键词语境区分

- 对话摘要中找信号:显式否定("不要这样" / "不对" / "重新来")/ 重复请求(同一件事 ≥ 2 条措辞递进) / 用户接管(用户直接给代码而非描述需求) / 方向推翻 / 精磨轮次
- **关键区分**:同样的词("好" / "不要") 在不同语境意义不同
  - "好" 出现在 AI 完整产出后 + 用户切换新话题 → 满意信号
  - "好" 出现在 AI 提问后 → 仅是确认回答,不是满意信号
  - "不要" 出现在用户主动描述需求时("不要用 React") → 需求说明,不是否定
  - "不要" 出现在 AI 刚做完某操作后("不要这样改") → 否定信号
- **不确定时不标**(宁可漏报不误报)

### §1.5 security-scan 3 挑战者专属

**3 个挑战者**(凭证数据 / 危险操作 / 注入混淆)— 模式扫描法 + 场景判定

- **凭证数据扫描**:Critical 凭证(OpenAI/Anthropic / GitHub PAT / Slack / Google API / AWS / 通用 API_KEY / Private Key / DB 连接串)+ High 数据外泄(curl 带凭证 / cat .env / printenv)
- **危险操作扫描**:High(rm -rf / chmod 777 / DROP TABLE / DELETE without WHERE / >/etc/ / mkfs)+ Medium(authorized_keys / crontab / shell 启动文件 / systemctl / git config --global)
- **注入混淆扫描**(.md / skills/ / agents/ 文件):High Prompt 注入(ignore previous instructions / system prompt override / DAN mode)+ Medium 混淆执行(eval / exec / base64 -d | / hex 编码 / __import__("os"))

**场景判定**(每个挑战者必做):

- 命中后做语境判定:测试 / 演示 / 生产
- **凭证场景判定不可绕**(M8 最低必选,即使本挑战者主营注入扫描,凭证场景判定仍是 minimum)
- 误报排除:测试文件假数据 / 注释说明 / .env.example 占位符

**风险等级判定**:Critical → 不通过 / High → 警告 / Medium → 通过(只 Medium 时)

### §1.6 实操技巧(通用)

**证据深度等级**:

| 等级 | 形态 | 示例 |
|---|---|---|
| 🟢 弱 | 仅描述位置 | "spec 第 3 节" |
| 🟡 中 | 位置 + 关键词 | "spec §3.1.5 第 2 段 提到 X" |
| 🔴 强 | 位置 + 原文 quote | 'spec §3.1.5: "...完整原话..."' |

**追求 🔴 强证据**;弱证据相当于没证据(调度者综合时可能 reject 该 finding)。

**严重程度判定**(客观标准,不靠"感觉"):

| 级别 | 客观条件 |
|---|---|
| 🔴 必修(阻塞) | 违反核心原则(`CLAUDE.md` §1 / 公设 1+2) / 触发 RUBRIC 惩罚项 / 内部自相矛盾 / 跟用户原话结构性偏离 |
| 🟡 建议(不阻塞但应改) | 次要不一致 / 可读性 / 边界未明 / 缺奖励项 |
| 🟢 轻微(可忽略) | 风格 / 命名细节 / 文档冗余 |

**模糊的判定不要自己拍**:如果"严重程度"在两级之间难定,**标低不标高**;调度者综合阶段可能升级(共识问题升一级),挑战者侧标低让综合阶段有空间。

---

## §2 数据来源向导(去哪找)

### §2.1 harness 全局架构

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

> **关键观察**:`memory` 不在 harness 仓库内 — 见 §2.3 跨平台路径。会话 JSONL 同样不在。

### §2.2 文档索引(找 X 去哪)

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

### §2.4 常见审查问题对应的数据源

| 你要审什么 | 优先查 |
|---|---|
| spec 是否对齐用户原话 | 会话 JSONL(本 batch 所有 user message,按时间序) |
| 调度者主线段是否 framing | 1. 调度者注入的"主线-支线-关系"段 vs 2. JSONL 用户原话 |
| 历史类似决策怎么做的 | `decision-trail.md` 时间序 + `decisions/*.md` |
| 治理规则真实约束 | `governance/<阶段>-rules.md` 原文(不是 spec 引用版) |
| 上 batch known-gap 未解决 | 最新 `meta-review-*.md` audit §6 KG 表 |
| 项目核心原则是否被违反 | `CLAUDE.md` §1 角色分离 + 公设 1+2 |
| 用户在本会话的关键决策 | grep `type=user` in 当前 JSONL,按时间序 |
| 跨项目模式(其他项目类似设计) | **不查** — 用户校准 `[[feedback_judgment_basis]]` 禁止用别人项目数据支撑决策 |

### §2.5 实操命令模板

**找当前会话 JSONL**(取最新):

```bash
# 1. 通过 §2.3 脚本找项目目录
PROJECT_DIR=$(node /tmp/find-project-dir.js)

# 2. 当前会话 = 最新 jsonl(mtime 最新)
CURRENT_JSONL=$(ls -t "$PROJECT_DIR"/*.jsonl | head -1)

# 3. 上一会话 = 次新 jsonl(本 batch 起点可能在上一会话)
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

**找上 batch known-gap**:

```bash
# 读最新 audit 的 §6 known-gaps 表
LATEST_AUDIT=$(ls -t harness/docs/audits/meta-review-*.md | head -1)
awk '/^## 6\. Known-Gaps/,/^## 7\.|^---/' "$LATEST_AUDIT"
```

---

## §3 输入策略(怎么看调度者给你的输入)

### §3.1 调度者给你什么(预期清单)

调度者 fork 你时,prompt 内含:

- **"主线-支线-关系"段**(`synthesis-rules.md` 事前规则 5 注入)— 调度者的视角
- **维度推荐**(A/B/C 三段对抗式 / N/G 段事实统计式)— 调度者的视角
- **待审对象**(spec / agent 文件 / 代码 diff / 摘要文件等)
- **配套资料**(RUBRIC.md / ARCHITECTURE.md / governance 必要节 / evidence depth 文件)
- **必读提示**:1 行 "先 Read `harness/docs/references/challenger-orientation.md`,然后再开始审查;输出格式必填末尾 section `### 已对照用户原话`"

> 注:调度者侧也是 AI,公设 1 适用(自评有乐观偏差)— 上述内容均带 selection / framing 风险。你要批判看,见 §3.2。

### §3.2 你要批判看调度者给的输入

**核心警惕**:调度者也是 AI,公设 1 适用;调度者写"主线"必带 selection + framing。

**具体动作**(✅/❌ 对照):

| 调度者写 | ❌ 直接采信 | ✅ 批判看 |
|---|---|---|
| "主线:本会话整体在做 X(落地路径选方向「Y」)" | 接受"路径 Y 已定" | "方向「Y」"是结论引导,我应从 JSONL 看用户原话怎么提的 |
| "主线:用户需要 GateGuard 完整设计" | 接受"用户要 GateGuard" | "GateGuard"是调度者命名,用户可能没用这词 — 从 JSONL grep |
| "支线:审 X spec 的自洽性,重点关注 Y" | 把 Y 当审查焦点 | "重点关注 Y"违反 synthesis-rules 事前规则 3,我独立判 |
| "主线:fork 前意图识别 + 报告通俗化两件事" | 接受"两件事是这次 batch 的目标" | "两件事"是调度者归纳;原话可能是更具体的诉求 — 校验 |

**违反 synthesis-rules 事前规则 1-3 的引导词**(出现即 framing 警告):"显然 / 实际上 / 重点是 / 关键问题是 / 应该 / 需要严查"。

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

### §3.4 输出必填:`### 已对照用户原话` section

挑战者输出**最末必填一个 section**(放在所有 finding 之后):

````markdown
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
````

**调度者综合阶段会做的事**(由 `synthesis-rules.md` 事后规则 5 规定):

- 缺失本 section → reject 该挑战者输出,要求重审
- section 内容空泛(无具体 timestamp + 完整 quote)→ reject
- 主线-支线-关系全 ✅ 但 finding 中含主线偏离 → 自相矛盾,reject
- section 显示主线偏离 🔴 → 升级为综合阶段 finding,可能触发主线段重写

**为什么必填**:挑战者是 AI,公设 1 适用 — 没有强制留痕,容易跑了不读 / 读了不校验 / 校验了不输出。本 section 是**校验留痕**,让"对照过用户原话"这件事可被调度者综合时机械校验。

---

## §4 常见陷阱(挑战者也是 AI)

### §4.1 公设 1 应用(挑战者乐观偏差)

挑战者也是 AI,也有"自评乐观"偏差 — 倾向于"找不到问题就说没问题"(尤其本身确实没什么问题时,会"凑数式找问题"或"宣告完美")。

**公设 1 原话**(`CLAUDE.md` 顶部):AI 评估自己的产出存在系统性乐观偏差。

**应用到挑战者**:

- 你跑完审查觉得"产出 0 个 finding,没问题" — **必须说明**:你具体检查了什么(对照表)/ 为什么认为没问题(逐项)
- 不附检查清单的"✅ 全部通过"等于没做
- 产出 0 finding ≠ 产出弱(可以是"我覆盖了 X / Y / Z,逐项检查通过");但不附检查清单的 0 finding = 跑过场

**反例(便利答案)**:

- ❌ "整体审查通过,无重大问题"
- ❌ "spec 写得不错,4 节齐全"

**正例(有据可依)**:

- ✅ "我检查了:(1) 自洽性 — §1 G1 vs §3.1.2 对应,无矛盾;(2) 完整性 — §1.2 5 场景全部对应 §3 详细设计某节;(3) 边界 — §2.2 不在 scope 内 6 项与 §1 用户否决对得上;均通过 → 0 finding。"

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

- 不标 finding(spec 可以有主观立场),但**批判性看**
- 例:spec §7 写"显然这是个非问题" → 不要采信"显然",要看证据是否充分

**特例 — 你自己用引导词**:

- 你输出 finding 时,也不要用"显然 / 实际上"等引导词
- 用"客观证据 + 严重程度判定"代替主观断言

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

**为什么**:对抗-决策分离原则(`harness/docs/references/multi-agent-review-guide.md`)— 你是对抗者,领审员(调度者)是决策者。你越权 = 决策不独立 = 公设 1 失效。

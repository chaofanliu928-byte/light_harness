# 反腐烂 / 新鲜度机制(freshness)规则
<!-- owner: 调度者; last-reviewed: 2026-06-16; 生命周期: evolving -->

> 本文件是新鲜度机制的**单一权威住址**——frontmatter 三字段语义+取值域、范围清单(核心集/增量/不纳入)、owner 二分+routeTo 三值映射(单源权威)、N=90 初值、复核动作、§6/§8 边界声明、字段→kind 映射(单源)。`.claude/agents/freshness-scout.md`(子智能体契约)+ 入口规程接线(根 CLAUDE 第 3 步 + AGENTS×2 新鲜度侦察节)引本文件指针,不各自重定义。
>
> 锁定 spec(唯一权威源):`harness/docs/superpowers/specs/2026-06-16-freshness-mechanism-design.md`。

---

## 定位

本文件 = 新鲜度机制的**单一权威住址**(约定 / 范围 / owner / 阈值 / 子智能体契约指针 / 复核动作)。

- **软机制**:报告 / 提醒,**不阻断、不自动修复**。绝不 exit 2 挡会话、不挡收口。
- **执行方式**:开场由调度者 **fork `freshness-scout` 子智能体**执行(需 agent 运行时;**无 agent 运行时则跳过**,同 hook 降级——丢自动触发,不丢可校验性)。
- **与对账三命令的区别**:对账三命令(check-handoff / check-shelf-registry / check-audit-coverage)是机械 bash hook 查凭证/台账文法(只读账本);新鲜度要**读文档内容做判断**(缺 owner?日期超期?该有 frontmatter 却没有?),故用子智能体(更聪明、少误报、能干净静默),**不是第四个 hook**。新鲜度第 3 步与对账第 2 步**并列**(时序对账在前),互不依赖、互不调用。

---

## frontmatter 数据契约(= 第三份契约,HTML 注释格式)

活文档头带一行新鲜度标签,放文档标题(`# …`)的**下一行**(逐字同 `harness/docs/preferences.md` L2,不另造):

```markdown
<!-- owner: <谁>; last-reviewed: YYYY-MM-DD; 生命周期: evolving|immutable -->
```

三字段语义 + 取值域 + 必填 + 缺失时怎么判:

| 字段 | 语义 | 取值域 | 必填 | 缺失时怎么判 |
|---|---|---|---|---|
| `owner` | 谁有权确认"这份还准" | `用户` \| `调度者` | ✅ | 缺 = **孤儿**(kind="孤儿") |
| `last-reviewed` | 上次有人确认还准的日期 | `YYYY-MM-DD`(半角连字符) | ✅(evolving 类) | 缺或不可解析 = **时间腐**(kind="时间腐") |
| `生命周期` | 这份会不会演进 | `evolving` \| `immutable` | ✅ | 缺 → 默认按 `evolving` 处理(保守纳入时间腐) |

- **HTML 注释形式渲染不可见、对正文零干扰**;放文档标题(`# …`)的**下一行**(同 preferences L2)。
- **HTML 注释标签 ≠ YAML `---` custom-agent frontmatter,无解析冲突**——`.claude/agents/*.md`(含 `freshness-scout.md`)带此 HTML 注释新鲜度标签**不破坏**「非 custom agent type」约定。既有 agent 文件 L2 声明的「不是带 frontmatter 的 custom agent type」防的是 YAML `---` 块被 Claude Code 解析成 custom agent;本机制标签是 HTML 注释 `<!-- … -->`,不是 YAML `---`,不会被解析成 custom agent type。
- **格式硬约束**:半角 `:` `;`,日期半角 `YYYY-MM-DD`(半角连字符)。**全角符号**(中文 IME 默认全角,机读静默漏 — check-context-chain 教训)按"不可解析"处理,见 `freshness-scout.md` 边界条件。
- **`immutable` 语义**:该文档是留痕/快照,**不参与时间腐检查**(它本就不该更新,推日期对它无意义),但**仍查 owner**(孤儿检查:一份没人认领的留痕件也值得提醒补 owner)。注:references 带日期前缀的 immutable 留痕件**不在本机制范围内**(用过时横幅那套,见下文范围清单排除);此处 immutable 仅指"被纳入范围、但标了 immutable"的边缘个案。

---

## 字段→kind 映射(单源权威住此)

- 缺 `owner` → **孤儿**
- `last-reviewed` 缺或不可解析,或 `today − last-reviewed > N` → **时间腐**(边界 `== N` 仍新鲜,`> N` 才报)
- 核心集成员无标签(无 `<!-- owner… -->` 行)→ **缺 frontmatter**

> 此映射的**单一权威住址 = 本文件**;`freshness-scout.md` / spec 各处(§3.1 / §4.1 / §4.3 / §5.1)对它的重述均"**派生自 freshness-rules**",非第二权威。**改判据先改本文件。**

---

## 范围清单(哪些是活文档)

> 判据 = **范围清单(路径白名单 + frontmatter 存在性),不靠"有没有 frontmatter"反推**(否则核心集成员缺 frontmatter 就永远扫不到,自我消解)。

| 类别 | 路径 | 纳入方式 | 缺 frontmatter 时 |
|---|---|---|---|
| 治理规则 | `docs/governance/*.md` | **核心集**(本轮回填) | 报"缺 frontmatter"(核心集必须有) |
| 架构 | `docs/ARCHITECTURE.md` | **核心集**(本轮回填) | 同上 |
| 方向盘 | `docs/RUBRIC.md` | **核心集**(本轮回填,**owner=用户**) | 同上 |
| 偏好 | `docs/preferences.md` | **核心集**(已有,沿用) | —(已有) |
| 模块 README | `**/README.md` | **增量采纳** | 标"缺 frontmatter"(温和,不算硬欠账) |
| 标准件 | `docs/references/` 内**无日期前缀** | **增量采纳** | 标"缺 frontmatter"(增量长) |
| agent/skill 契约 | `.claude/agents/*.md` + `.claude/skills/*/*.md` | **增量采纳**(本轮不批量回填) | 标"缺 frontmatter"(折叠一行,owner=调度者) |

**明确不纳入**(子智能体跳过,不扫不报):

- `docs/references/` **带日期前缀**留痕件(`YYYY-MM-DD-*.md` / `.html`)→ immutable,用既有**过时横幅**约定。
- `docs/audits/` → 已有 **audit 失效判定**(credentials §5)管。
- `docs/decisions/` → 历史决策记录,定了就不腐(append-only)。
- `docs/active/handoff.md` → 工作记忆,每会话覆写,无保质期语义。
- `docs/ROADMAP.md` / `docs/PROGRESS.md` → 台账 / append 记录,不腐。

**路径前缀约定**(双层仓,scout 据此解析,无歧义):

- `docs/...` 一律指 harness 自仓库的 `harness/docs/...`;
- `.claude/...` 一律指 `harness/.claude/...`;
- 根级 `/CLAUDE.md` · `/AGENTS.md` = **仓库根两份**(`<root>/CLAUDE.md` · `<root>/AGENTS.md`);
- 分发下游同形**去 `harness/` 前缀**。

**核心集 vs 增量的处理差异**:

- **核心集**成员缺 frontmatter = **"该有却没有"的真问题**(本轮就该回填,报出来催补)。
- **增量**类成员缺 frontmatter = **温和提示**(owner 顺手补、自然长,不算欠账、不刷紧迫感)。
- 子智能体报告时 detail 区分这两种语气。

---

## owner 二分 + routeTo 三值映射(单源权威住此)

| owner | routeTo(三值之一) | 谁动手 |
|---|---|---|
| `用户` | `报给用户拍` | 用户确认还准 / 拍要不要改;**AI 不自证**(方向级只有用户能自证) |
| `调度者` | `调度者自己复核` | AI 自己复核内容是否还准;真要改走凭证义务(governance 改动 → audit) |
| `未知`(孤儿/缺 frontmatter) | `报给用户拍 owner 归属` | 默认升给用户决定该文档归谁(owner 二分的兜底) |

- **routeTo 三值** = `报给用户拍` / `调度者自己复核` / `报给用户拍 owner 归属`(取值域与 `freshness-scout.md` 出参逐字一致)。
- **owner 词诚实说明**:`调度者` owner ≈ **无专人、AI 日常维护 + 机制兜底**(对齐 CLAUDE.md「防遗忘靠机制不靠纪律」)。本质是**二分:谁有权确认还准** —— `用户`(只有用户能自证的方向级)vs `调度者`(AI 日常能复核的执行级)。"调度者"虽是临时角色名、非"有个叫调度者的专人",二分语义清晰即可。
- **`调度者` owner 自评加固**(对齐公设 1「AI 自评有系统性乐观偏差」):调度者 owner 文档的"还准"确认是**软自评**——AI 复核内容是否还准、顺手推 `last-reviewed`,**可独走**。但**自评不替代对抗审查**:`调度者` owner 文档**真要改时**(改正文 / 改规矩,非仅推日期)由凭证义务的 **audit 独立审兜底**(governance 改动 → audit)。即:**推日期 = 软自评可独走;改内容 = 须走对抗审查**。这条防止"AI 自己说还准就算数"的乐观偏差闭环。

---

## 阈值 N = 90(初值)

一季度没回头看就提醒,N = **90** 天作**初值**。

- **90 非实证最优**:首批实战观察(误报率 / 漏报率 / 刷屏感)后标定,像 review-scout / research-scout「阈值不写死、实战调」那样处理。
- **不**把"季度 = 自然复核节奏"当成立依据(那是便利论证,避 spec_gap_masking)——它只是初值的来源直觉,真值待实战标定。过短刷屏、过长失效是调参方向,非 90 已证最优。
- 边界:`today − last-reviewed == 90` 仍**新鲜**(`> N` 才报;满 90 当天不催,第 91 天催)。

---

## 复核动作 = 推日期

owner 确认还准(或顺手修了)→ `last-reviewed` 推到今天。

- **收口搭便车**:收口时若本批动过某活文档,顺手把它的 `last-reviewed` 推到今天(复核搭收口便车,**不另起独立动作**)。
- governance 文档推日期的 commit 走凭证义务(governance 改动 → audit);仅推日期是软自评、可独走,改正文须走对抗审查(见上文「`调度者` owner 自评加固」)。

---

## §6 / §8 边界声明

显式写出,不靠读者推(对齐 spec §8.1 边界表态):

- credentials-rules **§6(开场对账规程权威)仅管对账三命令**;新鲜度开场步的权威住**本文件**(子智能体契约 + 范围 + 判据),**不写入 §6 正文**。
- credentials-rules **§8 既有对账拷贝组(第 5 条)保持锚对账三命令不变**;新鲜度只在 §8 **新增独立一条**(「新鲜度开场步三处同改」),不并入、不动既有第 5 条。
- 即:freshness **既不进 §6 正文、也不进 §8 既有对账拷贝组**,只在 §8 末另立一条新拷贝组。

---

## 不做清单(守 MVP「小而快」)

| 不做 | 理由 | 留给 |
|---|---|---|
| 漂移检测(文档 ↔ 代码不一致) | 需读代码判文档是否还描述对实现,大、需 brainstorm 收敛 | 后续 ★ 设计层子项 |
| 硬阻断(exit 2 挡会话/收口) | 强度 = 软;doc 新鲜不是凭证义务 | 不做(永久) |
| 自动修复(LLM doc-gardening 自动改文档内容) | 软强度;改由 owner 决定,子智能体只报不改 | 不做(本轮) |
| 一次性回填全仓 frontmatter | 守小而快;全仓回填大、易引噪声 | 增量采纳(自然长) |
| 重复管 immutable 留痕件 | references 带日期前缀件用过时横幅 | 过时横幅约定 |
| 重复管 audit 漂移 | 凭证 covered 文件改了 audit 失效已 credentials §5 管 | credentials §5 失效判定 |

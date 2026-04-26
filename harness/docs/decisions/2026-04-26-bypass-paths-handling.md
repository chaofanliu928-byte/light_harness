# 决策: P0.9.1 6 项执法绕过路径的处理

> 由 P0.9.1 spec 第七轮 fix-9 创建,**升 🟡 待用户决定**(逐项);第八轮用户拍板 → 🟢 已决定。

**状态**:🟢 已决定(2026-04-26 第八轮用户拍板,6 子项各自决策)

**日期**:2026-04-26

**关联功能**:P0.9.1 self-governance(spec §3.1.9 hook 执法 + §1.3 兼容性 + §5 边界)

## 问题

第七轮 spec /design-review 第二轮多个挑战者(D2 完整性 / D3 副作用)指出:即使 P0.9.1 加了 Stop + pre-commit 双 hook(光谱 B+),仍存在 6 条执法绕过路径。每条性质不同(技术绕 / 自律绕 / 设计内置盲区),处理方式不同。

本 decision 把 6 条逐项陈列,给 designer 倾向 + 论证,请用户审视。

## 6 条绕过路径 + designer 逐项倾向

### (i) `--no-verify` 绕 pre-commit

**问题**:`git commit --no-verify` 跳过 M16 pre-commit hook,任何 scope 内文件改动都可绕过 audit 要求。

**候选**:
- (i-a) **接受 + 留痕**:不在 P0.9.1 防,改在 SessionStart hook 检 `git reflog` / `git log` 找近期 `--no-verify` 痕迹(commit 信息含 "[no-verify]" 或通过 commit 间隔 vs hook log 比对);若发现,SessionStart 注入提醒"近期有 --no-verify commit,请补 audit"
- (i-b) **推 P0.9.3**:P0.9.1 不防(`--no-verify` 是 git 用户主动绕,本质上是用户级绕,非 AI 调度者);P0.9.3 兜底时基于实战数据(用户是否真的用了)再决定是否加防御
- (i-c) 不防

**designer 倾向**:**(i-b) 推 P0.9.3**

**论证**:
1. `--no-verify` 是 git 用户级操作,需要用户主动加 flag — AI 调度者(主对话)默认不会用这个 flag(setup.sh / hook 默认不写 --no-verify)
2. 防御 `--no-verify` 需要在 SessionStart hook 加 reflog 解析,实现复杂度高,且**不可靠**(用户可改 reflog,或用其他 git 操作绕)
3. 与"光谱 B+ 最小硬 hook"原则一致:P0.9.1 不防用户级技术绕路,留给 P0.9.3 视实战决定
4. **`feedback_judgment_basis` 原则**:无实战数据(P0.9.1 落地后是否真的有人用 --no-verify 绕),不应预先加防御

---

### (ii) 长 session 不 stop 漏 Stop hook

**问题**:Stop hook 只在 session 末触发(`stop_hook_active=true` 防死循环)。若用户长 session 内多次 commit 但中途不 stop,Stop hook 检测的是 session 末快照,中途 commit 未走 audit 不会被 Stop hook 拦(由 pre-commit hook 兜底)。但若用户既 --no-verify 又长 session 不 stop,双绕。

**候选**:
- (ii-a) **接受**:这是光谱 B+ 的设计代价 — Stop + pre-commit 是最小集,长 session 内 --no-verify commit 是用户级双绕,不在 P0.9.1 防御内
- (ii-b) 加第三 hook(SessionStart 检 git diff vs audit covers)— 但 §3.1.9 已说明此为 SessionStart 跨 session 复杂度过高
- (ii-c) 推 P0.9.3

**designer 倾向**:**(ii-a) 接受 + 推 P0.9.3**

**论证**:
1. spec §1.3 + D17 已论证"光谱 B+ 最小硬 hook" — Stop + pre-commit 是 2 hook 最小集;加第三 hook(SessionStart 跨 session)违反最小集原则
2. 长 session 不 stop 是非正常使用模式(harness 默认引导 /clear / handoff 切换 session),这种边缘场景不应让 hook 复杂度膨胀
3. 与 (i) 同理:若用户既 --no-verify 又长 session,本质是用户主动绕路 — 留 P0.9.3 视实战数据再说

---

### (iii) covers 填错(hook 不主动校验)

**问题**:audit YAML `covers:` 字段由调度者填写,hook 仅扫并集,不校验"covers 中列的文件是否真在本次改动中"。即:调度者可填错(漏列改动文件 / 列错路径),hook 仍认为已覆盖,放行。

**候选**:
- (iii-a) **修**:hook 加 changed_files vs covers 比对 — M15/M16 扫 git diff 得到 changed_files,逐文件检 audit covers 是否含该文件;若有 changed_file 不在任何 audit covers 中 → 视为未覆盖,触发引导
- (iii-b) 接受(光谱 B+ 代价)
- (iii-c) 推 P0.9.3

**designer 倾向**:**(iii-a) 修**(在 §3.1.9 改)

**论证**:
1. 这是 hook 设计内置缺陷(逻辑漏洞,非用户绕),修补成本低 — §3.1.9 已有"扫 git diff 文件,过滤命中 scope 内 glob 的文件集 changed_meta_files",再加一步比对 covers 即可
2. 修补无副作用:严格不放松要求,只是把"audit 存在"升级为"audit 真实覆盖本次改动"
3. 不修则 covers 字段沦为形式,违反 §1.5"audit trail 机制 — 每次 meta 改动必须产出 audit"的实质语义
4. spec §3.1.9 应增补:"5.b uncovered = changed_meta_files - covered_files(失效后)"已隐含此校验,但需明示"covered_files 是 audit covers 中实际列出的文件,不是 audit 存在即视为覆盖"

**实施位置**:§3.1.9 M15/M16 hook 逻辑步骤 5.b 改造(明示 covered_files 计算用 audit covers 字段实际列出的文件路径,不是 audit 存在 + 主题相关)

---

### (iv) 理由质量自律(grep 只检非空)

**问题**:handoff `## meta-review: skipped(理由: ...)` 字段 hook 只 grep 检"理由非空",不检"理由质量"。调度者可填"理由: 不需要"等水文绕过。

**候选**:
- (iv-a) **接受**:理由质量是治理(governance)要求,hook(执法)不强制 — 落地后由 process-audit 反向审 audit covers + skip 理由质量
- (iv-b) 加质量 hook(检理由长度 ≥ N 字符 / 含特定关键词)— 但语义模糊,易误伤
- (iv-c) 推 P0.9.3

**designer 倾向**:**(iv-a) 接受**

**论证**:
1. spec §1.5 + A5 决策已锁:"理由必填,可 grep 检空 reason" — 设计上就是"hook 检空,质量靠治理"
2. 理由质量(语义判断)不是 hook 适合做的事 — 若加长度 hook,水文照样过(填 200 字废话);若加关键词 hook,语义判断错误率高
3. governance 层(M2 meta-review-rules + M9 process-auditor)负责理由质量审视,这是合理分工
4. 与 spec §1.6 leverage 4 事实"跳过必须留痕"一致 — 留痕是底线,质量在落地后实战反馈中演化
5. 真水文 skip 多了,会在 process-audit 报告中暴露 → 反过来推动 governance 收紧

---

### (v) M17 scope.conf + audit 自身排除区(改它们不触发 hook)

**问题**:M17 scope.conf 中 `!meta-*` 排除规则把 meta-* 文件本身(包括 scope.conf 自己 + audit 文件本身)排除,改它们不触发 hook。即:有人改 scope.conf(放宽 scope)不触发 meta-review,有人改/伪造 audit 也不触发。

**候选**:
- (v-a) **修**:scope.conf 包含自身但避免循环 — 把 `meta-scope.conf` 自身入 scope(改它要走 meta-review),仅 audit 文件保留排除(audit 是流程产出物,不能要求"产出 audit 自身要 audit");M17 / governance/meta-*.md 也类似处理 — 治理文件入 scope,产出物排除
- (v-b) 接受(spec §3.1.1"排除自身避免自循环")
- (v-c) 推 P0.9.3

**designer 倾向**:**(v-a) 修**

**论证**:
1. 这是 hook 设计内置缺陷而非用户绕路 — `!meta-*` 排除过宽,把"治理文件"和"流程产出物"混为一类
2. **关键区分**:
   - **流程产出物(audit 文件本身)**:必须排除自循环 — 若 audit 文件改动也要触发 audit,无穷递归
   - **治理文件(scope.conf / meta-finishing-rules.md / meta-review-rules.md)**:**应该入 scope** — 改它们直接改变治理规则,等同于改 governance,必须走 meta-review
3. 修补方案:
   - M17 scope.conf 排除规则改为只排除 `!docs/audits/meta-review-*.md`(audit 文件)和 `!docs/audits/archive/`(归档 audit)
   - **不再排除** `meta-scope.conf` / `meta-*.sh` / `meta-*.md`(治理文件)— 改它们走 meta-review,符合 §1.3 scope 内 A+B+C+D+F 语义
   - 但**循环风险**:改 meta-scope.conf 会触发 meta-review,但 meta-review 流程定义在 meta-review-rules.md,改 meta-review-rules.md 会触发 meta-review(用旧规则审新规则)— 这是 bootstrap 必然循环,可接受(类似编译器自举)
4. 修补影响:§3.1.1 排除规则 + §4.1.2 M17 conf 内排除 glob + §3.1.9 hook 逻辑(对 scope 内的 meta 治理文件按"治理文件"路径走;对 audit 文件按"产出物"路径排除)

**实施位置**:§3.1.1 / §4.1.2 / §3.1.9 同步改;**注意**:这是设计层修补,涉及 §1.3 兼容性 — 若用户选 (v-a),需在 §1.3 边界声明加一行"meta 治理文件改动也走 meta-review,bootstrap 循环视为可接受"

---

### (vi) 下游用户(理论上)改 harness scope 文件无拦

**问题**:下游目标项目用 harness 但**不改 harness 自身**是 §1.3 兼容性假设。但理论上下游用户可能改 setup.sh 拷贝来的 governance / hooks 等(下游本地副本),这类改动在下游本地不触发 meta-review hook(下游不分发 meta hook,M19 a 方案)。

**候选**:
- (vi-a) **接受**:§1.3 兼容性假设"下游不应改 harness" — 这是设计假设,不是技术约束。下游若改 harness 副本,自负其责
- (vi-b) 加防御(下游 hook 也含 meta-review 检测)— 但与 D19 a 方案"零污染"冲突
- (vi-c) 推 P0.9.3

**designer 倾向**:**(vi-a) 接受**

**论证**:
1. spec §1.3 兼容性已明示"下游项目不受 meta 治理污染" — 反过来意味着"下游不归 harness 治理"
2. D19 a 方案锁定"零污染优于软污染" — 下游不应有 meta hook 注册;若加防御就违反 a 方案
3. "下游不应改 harness"是 harness 设计哲学(harness 是框架,改 harness 应通过 PR 回上游而非本地分叉),这条假设合理
4. 实施层备注:setup.sh 末尾打印消息可加一行"提示:harness 治理文件不应在下游本地修改,如有改动需求请回 harness 仓库 PR"
5. **`feedback_design_philosophy` 原则**:不过度防御 — 把假设当假设(声明 + 留痕),不试图技术封堵

---

## 决定(逐项)

| 子项 | 选择 | 原因 |
|---|---|---|
| (i) --no-verify | **(i-b) 推 P0.9.3** | AI 调度者(主对话)默认不主动用此 flag(setup.sh / hook 默认不写 --no-verify);无实战数据不预防;`feedback_judgment_basis` 原则禁止凭空预防。P0.9.3 兜底视实战数据再决定 |
| (ii) 长 session 不 stop | **(ii-a) 接受 + 推 P0.9.3** | 光谱 B+ 最小集设计代价(D17:Stop + pre-commit 是 2 hook 最小集);加第三 hook(SessionStart 跨 session)违反最小集原则。视实战数据 P0.9.3 再加防御 |
| (iii) covers 填错 | **(iii-a) 修(§3.1.9)** | 设计层漏洞(非用户绕),修补成本低 — §3.1.9 已有 changed_meta_files 扫描,加 covers vs changed_files 比对一步即可;不修则 covers 字段沦为形式,违反 §1.5"audit 必走"实质语义 |
| (iv) 理由质量自律 | **(iv-a) 接受** | 语义判断不是 hook 适合做的(检长度水文照样过,关键词错误率高);治理层(M2 meta-review-rules + M9 process-auditor)负责理由质量,落地后 process-audit 反向审 audit covers + skip 理由质量 |
| (v) scope.conf + audit 自身 | **(v-a) 修** | self-reference 漏洞 — `!meta-*` 排除把"治理文件"和"流程产出物"混为一类。**治理文件入 scope**(改它们走 meta-review)— 改治理文件等同改 governance,必须走流程;**只排除流程产出物**(audit / archive — audit 自审无穷递归);bootstrap 循环(改 meta-review-rules 走 meta-review)可接受(类似编译器自举) |
| (vi) 下游改 harness | **(vi-a) 接受** | §1.3 兼容性假设"下游不应改 harness 自身"+ D19 a 方案"零污染"前提;不试图技术封堵,声明 + 留痕(setup.sh 末尾打印消息提示);`feedback_design_philosophy` 原则不过度防御 |

## 后续影响

### spec 落地
- **(iii) 修 spec §3.1.9 hook 逻辑** — 明示 `covered_files` 计算用 audit covers 字段实际列出的文件路径(不是"audit 存在 + 主题相关")。hook 步骤 5.b 改:`uncovered = changed_meta_files - 所有有效 audit covers 并集`(失效后);若 changed_meta_files 中有文件不在任何有效 audit covers 中 → 触发引导/拦截
- **(v) 修 spec §3.1.1 + §4.1.2 + §3.1.9 + §1.3** — 排除规则改:**治理文件入 scope**(`meta-scope.conf` / `meta-*.sh` / `meta-*.md`),**只排除流程产出物**(`docs/audits/meta-review-*.md` / `docs/audits/archive/`);§1.3 加边界声明"meta 治理文件改动也走 meta-review,bootstrap 循环视为可接受(类似编译器自举)"

### 登记 spec
- **(i)(ii)(iv)(vi) 推 P0.9.3 / 接受登记 spec §5 边界 + §1.3** — 加 B14a/B14b/B14c/B14d(或合并为 B18 "已识别绕过路径推 P0.9.3 兜底")
- **§1.3 兼容性要求加(vi)声明** — "下游不应改 harness 副本(设计假设),如有改动需求请回 harness 仓库 PR"

### 实施层
- **(vi) setup.sh 末尾打印消息加一行**(实施 M14 时):"提示:harness 治理文件不应在下游本地修改,如有改动需求请回 harness 仓库 PR"
- **(iv) 落地后 process-audit 反向追踪** — 绕路实战数据(skip 理由水文统计)→ 反馈 P0.9.3 / governance 收紧

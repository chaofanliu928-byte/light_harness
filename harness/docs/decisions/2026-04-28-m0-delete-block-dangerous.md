# M0 — 删除 block-dangerous hook

**类型**:方案选择型 + P0.9.1.5 第一个 trial(用 harness 治理 harness 自身)
**日期**:2026-04-28
**触发**:用户(2026-04-28)启动 M0(2026-04-17 起草的 M0-M4 治理修改批次第一项)
**关联**:
- 上游 decision:`2026-04-17-harness-self-governance-gap.md`(M0 起草)
- 上游 spec:`2026-04-17-p0-9-self-governance-design.md` §1.3 + §1.6(M0 在 P0.9.1 落地后首批使用)
- 用户原则:`feedback_iterative_progression.md`(P0.9.1.5 启动由 P0.9.1 暴露,非预设)

---

## 问题

`block-dangerous` 是 PreToolUse hook(matcher: Bash),exit 2 阻断匹配 9 类危险 patterns 的 Bash 命令:
- `rm -rf /` / `rm -rf *`
- `DROP TABLE` / `DROP DATABASE` / `TRUNCATE TABLE`
- `curl ... | bash` / `wget ... | bash`
- `chmod 777`
- `mkfs.`
- fork bomb `:(){:|:&};:`

2026-04-17 self-governance 缺口 decision 起草时,M0 已被列为"P0.9 落地后首批使用"动作之一,具体动机 retrospective 驱动但未在 decision 展开。

## 方案

**A. 删除**(本次选定)
- 删 hook 文件 + 取消 M18+M19 注册
- 基础防御责任移交下游用户 / 上游 Claude Code permission 机制

**B. 改 advisory**
- 保留 hook,改 exit 2(阻断)为 exit 0 + stderr 警告
- 提示用户但不阻断 — 仍有"我注意到了"价值

**C. 缩 patterns**
- 保留 hook,只留最不可逆的(如 fork bomb / `rm -rf /`),去掉 SQL / chmod 等
- 减少误拦风险,保留核心防御

**D. 保留模板,patterns 默认全空**
- 保留 hook 框架供用户自填,默认不拦截任何

## 决定

**采用 A(删除)**。

### 理由(用户 Q1 D + 反向追问后细化)

1. **基础防御责任移交**:危险 bash 命令的拦截不应该由 harness(治理框架)承担 — 应由:
   - **用户自身**(知道自己的项目什么命令真正危险)
   - **上游 Claude Code permission 机制**(Bash 调用默认需用户授权,除非 allowlist)
   - **专业安全工具**(若需更强防御,装专门的安全 hook,不在 harness 默认装)
2. **harness 不替用户做危险拦截**:每个项目的"危险命令"清单不同(.env 路径 / 数据库表名 / 凭证文件路径都项目特异),hard-coded 9 类 pattern 既不全面又易误拦
3. **9 类 patterns 实际价值低**:
   - `rm -rf /`:Claude Code permission 已会询问授权
   - `DROP TABLE` / `chmod 777`:在脚本中是合法操作,误拦影响开发流程
   - `curl | bash`:常见的安装命令(npm install / pip install 等通过 curl|bash),误拦阻塞合法工作
4. **设计哲学**:harness 是治理框架,不是安全产品 — 范畴清晰

### 反向追问(dimension_addition_judgment 原则要求)

**"不删而改 advisory(B)是否就解决?"**
- B 仍引入"提醒噪音" — 9 类 pattern 误判率高(如 chmod 777 在某些临时调试场景合法),advisory 信息过载
- B 维护者仍需维护 9 类 patterns 列表的合理性,长期负担
- 删除 = 责任明确归属(用户 + 上游),advisory = 责任模糊

**"缩 patterns(C)是否更好?"**
- C 保留 fork bomb / `rm -rf /` 等极少数 — 但 Claude Code permission 已能拦截这些
- C 实质等价于"上游 permission 已做的事 harness 重复做",冗余

**结论**:A 在"责任清晰化 + 维护负担最小化"两维度都优于 B/C/D

## 不做(防 scope 扩散)

- **不在 setup.sh 加迁移提示给已装下游用户**(Q4 用户拍板)— 下游本地副本不会因 harness 主仓改动自动消失,但下次跑 setup.sh 重新安装时:
  - 新 settings.json 覆盖(取消 PreToolUse Bash 注册)
  - 旧 block-dangerous.sh 文件留在下游 .claude/hooks/(setup.sh 不做反向同步删除)
  - 行为:下游 PreToolUse Bash hook **不再激活**(因 settings 取消注册),即使文件还在
- **不改 .gitignore .claude/ 规则**:本次发现"`.claude/hooks/` 整目录被 .gitignore 忽略"是更深层问题(P0.9.2/3 候选,见后续段),不在 M0 scope 内
- **不批量改 spec / plan / decision / completed handoff 中 stale "block-dangerous" 文字**:这些是 historical artifact

## 已知缺口(显式承认 — spec_gap_masking 原则要求)

1. **下游失去基础预警**:删除后,下游用户 / AI 调度者跑危险 bash 命令(如 misclick `rm -rf /`)无 PreToolUse 阶段拦截,只剩上游 Claude Code permission 兜底。**接受**:harness 范畴是治理不是安全,基础防御交还用户/上游
2. **block-dangerous 源码无 git history**:`harness/.claude/hooks/` 整体被 `.gitignore` 排除 — 该 hook 从未进 git tracking。删除事件 git 不留 audit trail。**补救**:本 decision file §备份段附完整源码,作为唯一历史保留位置
3. **`.gitignore .claude/` 全局问题**:更深层的 governance 缺口 — harness 在做 self-governance,但治理变更若涉及 hook(.claude/hooks/) 改动,git 看不到。**推 P0.9.2/3**:评估是否要 `.claude/hooks/` allow-list 或 force-add 关键 hook
4. **下游 stale 文件无清理路径**:setup.sh 不做反向同步删除,已装下游本地仍有 stale block-dangerous.sh 文件(虽不激活)。**接受**:与 P0.9.1 整体设计一致(下游不读 harness CHANGELOG,stale 是常态)

## 完整源码备份(因 git 不留 history,这里是唯一保留位置)

```bash
#!/bin/bash
# block-dangerous.sh
# PreToolUse hook：拦截危险的 bash 命令
#
# 退出码：
#   0 = 放行
#   2 = 阻止（stderr 内容反馈给 Claude）

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# 如果解析失败或命令为空，放行
if [ -z "$COMMAND" ]; then
    exit 0
fi

# ============================================
# 危险命令模式（根据项目需要增删）
# ============================================
DANGEROUS_PATTERNS=(
    'rm -rf /'
    'rm -rf \*'
    'DROP TABLE'
    'DROP DATABASE'
    'TRUNCATE TABLE'
    'curl[^|]*\|[[:space:]]*(ba)?sh\b'
    'wget[^|]*\|[[:space:]]*(ba)?sh\b'
    'chmod 777'
    'mkfs\.'
    ':(){:|:&};:'       # fork bomb
)

for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$PATTERN"; then
        echo "🚫 危险命令已拦截: $COMMAND" >&2
        echo "匹配到的危险模式: $PATTERN" >&2
        exit 2
    fi
done

# ============================================
# 受保护文件/目录（根据项目需要填写）
# 留空数组 = 不保护任何特定文件
# ============================================
PROTECTED_PATHS=(
    # 在这里添加你项目需要保护的文件/目录
)

for PROTECTED in "${PROTECTED_PATHS[@]}"; do
    if echo "$COMMAND" | grep -qE "(rm|mv|cp|cat\s*>|>\s*).*$PROTECTED"; then
        echo "🔒 受保护的文件/路径: $PROTECTED" >&2
        echo "命令: $COMMAND" >&2
        exit 2
    fi
done

# 通过所有检查，放行
exit 0
```

## 关联

- decision-trail append 一条新抉择"M0 — 删除 block-dangerous hook(P0.9.1.5 第一个 trial)"
- handoff:M0 完成留痕(P0.9.1.5 段更新)
- ROADMAP P0.9.1.5 段:M0 状态 🟢 已完成

## 后续

- **P0.9.1.5 第二个 trial**(M1-M4 之一):由用户决定何时启动
- **P0.9.2/3 候选**:`.gitignore .claude/` 全局问题 — hook 改动无 git audit trail,影响 self-governance 完整性。本 audit 已识别,推后续阶段评估
- **链接保鲜**:无 — 本 decision 不依赖外部 URL
- **用户实际反馈**:删除后是否真的没遇到危险命令拦截需求?P0.9.2 实战观察期收集

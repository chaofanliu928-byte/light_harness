# harness/templates/ — 分发模板

本目录含 setup.sh 分发到下游的模板文件(D19 a 方案,P0.9.1 引入)。

## settings.json — 分发模板(M19)

- 与 harness 自身的 `.claude/settings.json`(M18)结构基本一致
- **唯一差异**:不含 meta hook 注册(`check-meta-review.sh` / `meta-self-review-detect.sh`)
- setup.sh 从本路径拷贝到目标项目 `.claude/settings.json`(避免下游被 meta 治理污染)

### 差异详解

| 数组 | M18(harness 自身) | M19(分发模板) |
|------|---|---|
| `PostToolUse` | prettier / check-module-docs | **同 M18**(无差异) |
| `SessionStart` | session-init.sh + meta-self-review-detect.sh | 仅 session-init.sh(无 meta hook) |
| `Stop` | check-handoff / check-finishing-skills / check-evidence-depth / **check-meta-review** | check-handoff / check-finishing-skills / check-evidence-depth(无 meta hook) |

## 维护规约

- **加 meta hook**(P0.9.2 / P0.9.3 等)→ 只改 M18,不动 M19(M19 永远不含 meta hook 注册段)
- **加 feature hook**(罕见)→ 同步改 M18 + M19
- **校对**:`jq diff M18 M19` 应只显示 meta hook 段差异(其他段一致)

### 自检脚本(可选)

```bash
# 验证 M18 vs M19 差异
jq '.hooks.PostToolUse' ../../.claude/settings.json > /tmp/m18_post.json
jq '.hooks.PostToolUse' settings.json > /tmp/m19_post.json
diff /tmp/m18_post.json /tmp/m19_post.json  # 应无差异

jq '.hooks.Stop[0].hooks | length' ../../.claude/settings.json  # 应为 4(含 meta)
jq '.hooks.Stop[0].hooks | length' settings.json                # 应为 3(无 meta)

jq '.hooks.SessionStart[0].hooks | length' ../../.claude/settings.json  # 应为 2(含 meta)
jq '.hooks.SessionStart[0].hooks | length' settings.json                # 应为 1(无 meta)
```

## scope 守门

本目录文件入 P0.9.1 scope F 组(`harness/templates/*.json`)— 改 M19 必须触发 meta-review,无后门(配合 fix-1 修补)。

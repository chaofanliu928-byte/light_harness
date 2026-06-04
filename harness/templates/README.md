# harness/templates/ — 分发模板

本目录含 setup.sh 分发到下游的模板文件(D19 a 方案,P0.9.1 引入)。

## settings.json — 分发模板(M19)

- 与 harness 自身的 `.claude/settings.json`(M18)结构基本一致
- **唯一差异**:不含 meta hook 注册(`check-meta-review.sh` / `check-meta-cross-ref.sh`)
- setup.sh 从本路径拷贝到目标项目 `.claude/settings.json`(避免下游被 meta 治理污染)

### 差异详解

| 数组 | M18(harness 自身) | M19(分发模板) |
|------|---|---|
| `PostToolUse` | prettier / check-module-docs | **同 M18**(无差异) |
| `SessionStart` | session-init.sh | session-init.sh(同 M18) |
| `Stop` | check-handoff / check-evidence-depth / **check-meta-review** / **check-meta-cross-ref** | check-handoff / check-evidence-depth(无 meta hook) |

## 维护规约

- **加 meta hook**(P0.9.2 / P0.9.3 等)→ 只改 M18,不动 M19(M19 永远不含 meta hook 注册段)
- **加 feature hook**(罕见)→ 同步改 M18 + M19
- **校对**:`jq diff M18 M19` 应只在 Stop 段显示 meta hook(check-meta-review / check-meta-cross-ref)差异;SessionStart 两侧已相同

### 自检脚本(可选)

```bash
# 验证 M18 vs M19 差异
jq '.hooks.PostToolUse' ../../.claude/settings.json > /tmp/m18_post.json
jq '.hooks.PostToolUse' settings.json > /tmp/m19_post.json
diff /tmp/m18_post.json /tmp/m19_post.json  # 应无差异

jq '.hooks.Stop[0].hooks | length' ../../.claude/settings.json  # 应为 4(含 2 个 meta:check-meta-review + check-meta-cross-ref)
jq '.hooks.Stop[0].hooks | length' settings.json                # 应为 2(无 meta)

jq '.hooks.SessionStart[0].hooks | length' ../../.claude/settings.json  # 应为 1(无 meta)
jq '.hooks.SessionStart[0].hooks | length' settings.json                # 应为 1(无 meta)
```

## scope 守门

本目录文件入 P0.9.1 scope F 组(`harness/templates/*.json`)— 改 M19 必须触发 meta-review,无后门(配合 fix-1 修补)。

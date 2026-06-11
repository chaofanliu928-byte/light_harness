# harness/templates/ — 分发模板

本目录含 setup.sh 分发到下游的模板文件(D19 a 方案,P0.9.1 引入)。

## settings.json — 分发模板(M19)

- 本文件是**下游项目唯一的 settings 来源**:setup.sh 从本路径拷贝到目标项目 `.claude/settings.json`
- 不含 meta hook 注册(`check-meta-review.sh` / `check-meta-cross-ref.sh`)— meta 治理仅 harness 自仓库用,下游零痕迹
- harness 自仓库**无 settings 接线**(2026-06-12 撤除,C 案:hook=工具箱,手工模式为正身;详 `harness/docs/decisions/2026-06-11-session-chain-reconciliation.md` 追记①),本文件没有自仓库对照件

## 维护规约

- **增删下游 hook** → 改本模板(templates/settings.json),并确认 hook 脚本文件名无 `meta-` / `check-meta-` 前缀(setup.sh 按前缀过滤,带前缀的脚本不分发下游,注册了也是空指)
- **meta hook 永不入本文件**(自仓库 meta hook 以手工/工具箱模式运行,不走 settings 接线,更不分发)

### 自检(可选)

```bash
jq empty settings.json  # JSON 合法性
```

## scope 守门

本目录文件入 P0.9.1 scope F 组(`harness/templates/*.json`)— 改 M19 必须触发 meta-review,无后门(配合 fix-1 修补)。

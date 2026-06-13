# harness/templates/ — 分发模板

本目录含 setup.sh 分发到下游的模板文件(D19 a 方案,P0.9.1 引入)。

## settings.json — 分发模板(M19)

- 本文件是**下游项目唯一的 settings 来源**:setup.sh 从本路径拷贝到目标项目 `.claude/settings.json`
- hooks 全量分发(无排除机制,R14——前缀过滤已退役)
- harness 自仓库**无 settings 接线**(2026-06-12 撤除,C 案:hook=工具箱,手工模式为正身;详 `harness/docs/decisions/2026-06-11-session-chain-reconciliation.md` 追记①),本文件没有自仓库对照件

## 维护规约

- **增删下游 hook** → 改本模板(templates/settings.json),并确认脚本随 hooks 循环分发(无排除机制)
- **无 hook 分发排除**(治理同层 2026-06-13:上下游同一套 hook,对账工具 check-audit-coverage 随全量分发;前缀过滤机制已退役)

### 自检(可选)

```bash
jq empty settings.json  # JSON 合法性
```

## scope 守门

本目录文件入凭证义务(credentials.conf templates/*.json 行)— 改模板必触发审查凭证。

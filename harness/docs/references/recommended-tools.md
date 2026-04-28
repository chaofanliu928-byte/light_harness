# 推荐工具(用户级,可选)

> 本文件记录 harness 推荐的**用户个人工具**链接,**不归任何项目管**。harness 仅"推荐 + 记录链接,防找错",不做集成 / 分发 / 依赖管理。
>
> 安装与否、装在哪、装哪个版本,完全由用户自己决定。harness 治理流程**不依赖**这些工具在场。

---

## glassbox — AI 工作可观测层

- **仓库**:https://github.com/chaofanliu928-byte/glassbox
- **作用**:生成 7 类 HTML 页面 + lint 工具,辅助审查 AI 工作的真实性 / 流程透明度(P2 可观测性的**空间维度** — session 内可视化)
- **定位**:用户个人工具,与 harness 治理框架**互补但解耦**
- **建议安装位置**:`~/tools/glassbox/` 或 `~/code/tools/glassbox/` 等全局位置(不与具体项目绑定)
- **安装方式**:由用户自行执行(harness 不代为安装)
  ```bash
  git clone https://github.com/chaofanliu928-byte/glassbox.git ~/tools/glassbox
  ```
- **使用关系**:用户在跑 harness 治理流程时(包括开发 harness 自身或用 harness 治理目标项目),装了 glassbox 即可同时用其可视化能力;不装也不影响 harness 治理流程

## P2 可观测性双层(对照)

| 维度 | 工具 | 归属 | harness 角色 |
|---|---|---|---|
| **时间(跨 session)** | `docs/decision-trail.md` | 项目内置 | harness 自带 + 自动维护(M1/M5 finishing append) |
| **空间(session 内)** | glassbox | **用户级外部工具** | harness 推荐 + 链接记录(本文件) |

详见 `docs/ROADMAP.md` P2 段 + `docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md`。

---

## 维护规则

- **本文件不分发下游**:仅 harness 仓库内可见,setup.sh 不 cp 到目标项目;下游用户从 setup.sh 末尾 echo 获取 URL 摘要
- 本文件记录的是**当前推荐的用户级工具**,不是 harness 依赖
- **URL 同步点**(链接失效 / 工具迁移 / 改名 时**手工**逐处更新):
  1. 本文件(主权威源)
  2. `setup.sh` 末尾 echo 段
  3. `docs/ROADMAP.md` P2 段
  4. `docs/decisions/2026-04-28-glassbox-recommendation-not-integration.md` 顶部"关联"+§"问题"段
- 新增推荐工具:append 到本文件即可(无需 meta-review,scope=none);若要在 setup.sh 末尾提示,改 setup.sh 走 scope=meta
- 工具如何使用 / 配置细节归各工具自身文档,本文件不抄
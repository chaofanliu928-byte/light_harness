# glassbox 角色定位 — 推荐外部工具,非集成依赖

**类型**:方案选择型
**日期**:2026-04-28
**触发**:用户(2026-04-28)指出 glassbox 不应作为项目级集成依赖,而应作为用户级个人工具,harness 仅"提示安装 + 记录链接,防找错"
**关联**:
- 上游 decision:`2026-04-28-decision-trail-introduction.md`(P2 可观测性双层框架)
- 用户原则:`feedback_skill_no_cross_project.md`(harness 不应自动跨项目分发外部 skill)
- 上游 audit 共识:`meta-review-2026-04-28-174615-decision-trail-introduction.md`(挑战者 4 注意 ROADMAP P2 描述对 glassbox 集成承诺未达成)

---

## 问题

P2 可观测性双层框架已立(2026-04-28 上午):时间维度 = decision-trail(项目内置),空间维度 = glassbox(外部仓库)。**但 glassbox 以什么形态进入 harness 用户的工作流?**

可能的依赖管理方式(业内成熟方案):
- Git Submodule(在某仓库内嵌指针指向另一仓库的 commit)
- Git Subtree / Vendored(把 B 文件复制进 A 仓库)
- 包管理器(npm / pip 等中央仓库)— glassbox 未发布,不适用
- 配置驱动安装(setup.sh 时 git clone)
- 纯推荐(仅记录链接,不分发)

每种方案对应不同的:升级路径 / 仓库大小 / 离线可用性 / 版本谁说了算 / 用户决策权。

## 方案

**A. Submodule(harness 内嵌)**:harness 仓库挂 glassbox 为 submodule,setup.sh 时复制副本到目标项目
- ✅ 版本统一,harness 维护者锁定
- ✅ 离线可装
- ❌ harness 仓库变重(clone 时需 `--recurse-submodules`)
- ❌ 强制目标项目持有 glassbox(用户被动接受)

**B. Submodule(目标项目内嵌)**:setup.sh 时在目标项目跑 `git submodule add`
- ✅ 各项目独立选版本
- ❌ 要求目标项目是 git 仓库
- ❌ 升级管理分散

**C. 配置驱动安装(setup.sh 询问 + clone)**:setup.sh 询问"是否安装",y 则 git clone glassbox 到目标项目子目录
- ✅ 用户主动选择
- ❌ glassbox 仍被绑到项目,用户其他项目要再装一份

**D. 纯推荐 + 链接记录**(本 decision 选定):harness 不分发 glassbox,仅:
- 在 `docs/references/recommended-tools.md` 永久记录 URL + 简介
- setup.sh 末尾 echo 推荐提示
- 用户自己决定装哪、装啥版本、何时升级
- glassbox 是**用户级个人工具**,可被用户用在多个项目 + harness 之外的场景

## 决定

**采用 D**。

理由:
- **glassbox 本质就是用户工具**:不依附任何项目,装在 ~/tools/ 之类全局位置最自然 — 一次装,处处可用
- **harness 仓库零变化**:不挂 submodule / 不复制文件 / 不改依赖图 / clone 体积不变
- **完全符合"不强加"精神**:harness 不替用户决策,不绑用户版本,不锁用户位置
- **升级解耦**:用户 git pull glassbox 自己升,harness 不用动
- **glassbox 可用范围大于 harness**:它是用户工具,在 harness 之外也能用(如直接评审某个非 harness 项目的 AI 工作产出)
- A/B/C 都把 glassbox 绑到项目层 — 与"用户级工具"的本质不符

## 不做(防 scope 扩散)

- **不做依赖管理**:harness 不挂 submodule / 不 clone / 不锁版本 / 不维护安装路径
- **不做使用集成**:harness 治理流程不调用 glassbox API,不依赖 glassbox 在场
- **不做升级提醒**:harness 不监控 glassbox 仓库变化,不主动通知用户升级
- **不做版本兼容性测试**:glassbox 升级若与 harness 工作流不兼容,由用户发现 + 报 harness issue
- **不做强制安装**:setup.sh 仅 echo 提示,不交互式询问(询问式即变相强求决策)

## 唯一的 harness 维护负担

链接保鲜:若 glassbox 仓库改名 / 迁移 / 废弃,harness 这边的 `recommended-tools.md` + `setup.sh` 末尾段 + ROADMAP P2 描述需手工同步更新。比 submodule 维护轻得多(submodule 还要管 commit hash)。

## 关联

- ROADMAP P2 空间维度描述同步重写(glassbox 从"集成的空间维度"改为"推荐的用户级工具")
- decision-trail append 一条新抉择"glassbox 角色 reframe — 用户级工具,harness 推荐不分发"
- 本 decision 不替代上游 `2026-04-28-decision-trail-introduction.md`,二者并列 — 时间维度归 decision-trail(项目内置),空间维度归 glassbox(用户级)

## 后续

- **链接保鲜监控**:每次 P0.9.x 落地或 P1 真实迁移时复核 glassbox URL 是否仍有效
- **推荐工具列表扩展**:若未来出现其他用户级 AI 工具(如可视化 / 监控类),可 append 到 `recommended-tools.md`,无需 meta-review(scope=none)
- **用户实际使用反馈**:P1 真实项目验证时观察用户是否真去装 glassbox / 装了用得多不多(数据反哺 P0.9.x 后续)
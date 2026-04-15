# 架构规范

> 所有代码修改必须遵循本文件定义的分层和约束。
> 违反分层规则的代码在评估时"一致性"维度直接扣分。

## 分层架构

<!-- 根据你的项目自定义。以下是一个常见示例。 -->
<!-- 核心原则：每一层只能依赖它下面的层，不能反向依赖。 -->

```
┌─────────────────────────┐
│         UI / Pages       │  ← 页面和路由，只调用 Services
├─────────────────────────┤
│       Components         │  ← 可复用 UI 组件，无业务逻辑
├─────────────────────────┤
│        Services          │  ← 业务逻辑，调用 Repository
├─────────────────────────┤
│       Repository         │  ← 数据访问，封装 API/DB 调用
├─────────────────────────┤
│     Types / Config       │  ← 类型定义和配置，无运行时依赖
└─────────────────────────┘
```

### 依赖规则

| 层 | 可以依赖 | 不可以依赖 |
|----|---------|-----------|
| UI / Pages | Components, Services, Types | Repository（必须经过 Service） |
| Components | Types | Services, Repository |
| Services | Repository, Types, Config | UI, Components |
| Repository | Types, Config | UI, Components, Services |
| Types / Config | 无 | 所有其他层 |

### 违规示例

```
❌ 组件直接调用 API：UserCard 里写 fetch('/api/users')
✅ 组件通过 Service：UserCard 调用 userService.getUser()

❌ 反向依赖：Repository import 了 Service 的函数
✅ 单向依赖：Service import Repository 的函数
```

## 目录结构约定

<!-- 根据你的项目自定义 -->

```
src/
├── pages/          # UI / Pages 层
├── components/     # Components 层
│   ├── common/     # 跨页面共享组件
│   └── [feature]/  # 按功能分组的组件
├── services/       # Services 层
├── repositories/   # Repository 层
├── types/          # Types 层
├── config/         # Config 层
├── utils/          # 纯工具函数（无业务语义）
└── hooks/          # 自定义 hooks（如 React 项目）
```

## 命名规范

<!-- 根据你的项目自定义 -->

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件名 | [待定义] | [待定义] |
| 组件 | [待定义] | [待定义] |
| 函数 | [待定义] | [待定义] |
| 类型 | [待定义] | [待定义] |
| 常量 | [待定义] | [待定义] |

## 前后端类型契约

> 前端和后端必须共享同一份类型定义，防止字段名不一致。

**契约位置**：`types/` 目录（或项目约定的共享类型目录）

**规则**：
- 所有 API 的请求/响应类型必须在共享类型目录中定义
- 前端和后端的代码都从同一个类型文件 import，不各自定义
- 新增/修改 API 字段时，**先改共享类型，再改前后端代码**
- [待定义：具体的共享方式，如 monorepo 共享包 / OpenAPI schema 生成 / tRPC 等]

## 关键约束

<!-- 项目特有的硬性规则，写在这里。示例： -->

1. [待定义，例如：所有 API 调用必须经过 Repository 层]
2. [待定义，例如：状态管理只用 Zustand，不用 Redux]
3. [待定义，例如：所有异步操作必须有 loading / error / success 三态]

## 新增模块的检查清单

添加新文件前，确认：
- [ ] 它属于哪一层？
- [ ] 它只依赖了下层模块？
- [ ] 同层已有模块中没有重复功能？
- [ ] 文件名和位置符合目录结构约定？

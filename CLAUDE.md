# AI Dev Harness

> 本文件是仓库根目录的导航。实际的 CLAUDE.md 模板在 `harness/CLAUDE.md`。

## 结构

```
harness/              ← 框架源码，setup.sh 从这里复制文件到目标项目
  CLAUDE.md           ← 安装到目标项目的 CLAUDE.md 模板
  QUICKREF.md         ← 速查卡
  README.md           ← 完整说明
  setup.sh            ← 安装脚本
  .claude/            ← skills, hooks, agents, settings
  docs/               ← 治理规则, 文档模板
```

## 快速开始

```bash
cd harness
./setup.sh /path/to/your-project
```

详见 `harness/README.md`。

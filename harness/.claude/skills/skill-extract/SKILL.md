---
name: skill-extract
description: "技能自归纳。功能分支完成、方向评估通过后触发。分析本次开发过程，提取可复用的模式保存为新 skill 或参考文档。"
---

# 技能自归纳

> 灵感来源：Hermes Agent 的 skill self-extraction 系统。
> 核心思想：开发经验不应该随会话消失，可复用的模式应沉淀为 skill。

## 触发时机

- evaluate 通过后（finishing 阶段）——精磨/推翻时不触发，代码还会变
- 用户手动调用 `/skill-extract`

## 输入上下文

!`cat docs/active/evaluation-result.md 2>/dev/null || echo "无评估结果"`

!`f=$(ls -t docs/superpowers/specs/*.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无设计文档"`

!`f=$(ls -t docs/superpowers/plans/*.md 2>/dev/null | head -1); [ -n "$f" ] && cat "$f" || echo "无实现计划"`

## 已有技能（避免重复）

!`find .claude/skills -name "SKILL.md" -exec echo "---" \; -exec head -5 {} \; 2>/dev/null || echo "无自定义技能"`

## 已有参考文档

!`ls docs/references/ 2>/dev/null || echo "无参考文档"`

---

## 执行流程

### 第一步：回顾开发过程

1. 读取本次功能的设计文档（docs/superpowers/specs/）
2. 读取实现计划（docs/superpowers/plans/）
3. 读取评估结果（docs/active/evaluation-result.md）
4. 查看本次改动范围：
   - `git log --oneline -20` 查看提交历史
   - `git diff $(git rev-parse --verify main 2>/dev/null || git rev-parse --verify master 2>/dev/null || echo HEAD~10)...HEAD --stat` 查看改动文件
   - 如果都失败（首次提交），用 `git log --stat -10` 替代

### 第二步：识别可提取的模式

判断标准——**同时满足以下三条才值得提取**：

1. **项目特定**：不是通用编程知识（"怎么写 React 组件"不值得提取，"本项目的表单验证套路"值得）
2. **可复用**：未来大概率会再遇到类似场景
3. **可操作**：能写成具体步骤，不是泛泛的原则

模式类型示例：
- 调试套路（"这个项目遇到 X 类错误时，先查 Y 再查 Z"）
- 架构模板（"新增一个 API 端点需要改这 4 个文件，按这个顺序"）
- 集成流程（"接入第三方服务 X 的标准流程"）
- 测试策略（"这类组件的测试重点是 A 和 B，mock 这些依赖"）
- 数据迁移（"改数据库 schema 时的标准操作流程"）

### 第三步：决定输出形式

| 模式特征 | 输出到哪里 |
|---------|-----------|
| 可操作的多步骤流程（≥3 步） | 新建 `.claude/skills/{name}/SKILL.md` |
| 知识性参考（API 细节、配置说明） | 新建 `docs/references/{name}.md` |
| 对现有 skill 的补充 | 就地修补现有 SKILL.md |

### 第四步：写入

**新 Skill 格式：**

```markdown
---
name: {skill-name}
description: "{一句话描述用途和触发场景}"
---

# {技能名称}

> 从 [功能名称] 的开发中提取。

## 适用场景

[什么时候该用这个技能]

## 步骤

1. [具体步骤]
2. [具体步骤]
...

## 注意事项

- [踩过的坑或关键约束]
```

**参考文档格式：**

```markdown
# {主题}

> 从 [功能名称] 的开发中提取。[日期]

## 内容

[具体知识]
```

### 第五步：汇报

输出一份简短总结：
- 提取了什么（skill 名称 / 参考文档名称）
- 为什么值得提取（复用场景）
- 没有提取什么以及为什么（避免用户疑惑）

如果本次开发没有可提取的模式，说明原因后正常结束，**不要强行提取**。

## 安全规则

- 不把密钥、token、内部 URL 写入 skill 或参考文档
- 不重复已存在的 skill（先检查 .claude/skills/ 和 docs/references/）
- skill 名称用小写英文 + 连字符，如 `api-endpoint-scaffold`

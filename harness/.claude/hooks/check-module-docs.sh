#!/bin/bash
# check-module-docs.sh
# PostToolUse hook：代码文件被修改时，检查同模块的 README.md 是否也被修改
#
# 不阻断操作（exit 0），但会在 stderr 输出提醒，Claude 会看到并补上
# 如果想改为强制阻断，把提醒部分的 exit 0 改成 exit 2

INPUT=$(cat)

# 只关注文件写入操作
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [ "$TOOL" != "Write" ] && [ "$TOOL" != "Edit" ] && [ "$TOOL" != "MultiEdit" ]; then
    exit 0
fi

# 获取被修改的文件路径
FILEPATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$FILEPATH" ]; then
    exit 0
fi

# 只检查代码文件（根据项目需要调整扩展名）
CODE_EXTENSIONS="ts tsx js jsx py rb go rs java kt swift cs"
FILE_EXT="${FILEPATH##*.}"

IS_CODE=false
for EXT in $CODE_EXTENSIONS; do
    if [ "$FILE_EXT" = "$EXT" ]; then
        IS_CODE=true
        break
    fi
done

if [ "$IS_CODE" != "true" ]; then
    exit 0
fi

# 获取文件所在目录
DIR=$(dirname "$FILEPATH")
README="$DIR/README.md"

# 检查该目录是否有 README.md
if [ ! -f "$README" ]; then
    echo "📝 模块文档缺失: $DIR/README.md 不存在。请按 docs/references/MODULE_DOC_TEMPLATE.md 创建。" >&2
    exit 0
fi

# 检查 README.md 最近 2 分钟内是否被修改过
if stat --version &>/dev/null 2>&1; then
    MODIFIED=$(stat -c %Y "$README" 2>/dev/null)
else
    MODIFIED=$(stat -f %m "$README" 2>/dev/null)
fi

if [ -n "$MODIFIED" ]; then
    NOW=$(date +%s)
    DIFF=$((NOW - MODIFIED))

    if [ "$DIFF" -gt 120 ]; then
        echo "📝 模块文档可能过期: $DIR/README.md 在本轮未更新。如果本次修改涉及接口、依赖或设计变更，请同步更新。" >&2
    fi
fi

# 默认提醒模式（exit 0）。如需强制阻断，改为 exit 2。
# 阻断模式会要求每次代码修改都同步更新 README，可能对纯内部逻辑修复造成摩擦。
exit 0

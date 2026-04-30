#!/bin/bash
# Stop hook: 检查 finishing 阶段的 skill 是否都执行了
# 只在 evaluate 通过时检查

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EVAL_FILE="$PROJECT_DIR/docs/active/evaluation-result.md"
HANDOFF_FILE="$PROJECT_DIR/docs/active/handoff.md"
COMPLETED_DIR="$PROJECT_DIR/docs/completed"

# 没有评估结果，不检查
if [ ! -f "$EVAL_FILE" ]; then
  exit 0
fi

# "不通过" 也包含 "通过" 子串，必须先排除
if grep -q "不通过" "$EVAL_FILE" 2>/dev/null; then
  exit 0
fi
if ! grep -q "通过" "$EVAL_FILE" 2>/dev/null; then
  exit 0
fi

WARNINGS=""

# 检查 structured-handoff 是否执行了：
# 1. docs/completed/ 有今天的归档，或
# 2. handoff.md 已更新（不再包含初始模板占位符 "[待更新]"）
TODAY=$(date +%Y%m%d)
HAS_ARCHIVE=false
HAS_UPDATED_HANDOFF=false

if ls "$COMPLETED_DIR"/handoff-${TODAY}*.md 2>/dev/null | grep -q .; then
  HAS_ARCHIVE=true
fi
if [ -f "$HANDOFF_FILE" ] && ! grep -q "\[待更新\]" "$HANDOFF_FILE" 2>/dev/null; then
  HAS_UPDATED_HANDOFF=true
fi

if [ "$HAS_ARCHIVE" = false ] && [ "$HAS_UPDATED_HANDOFF" = false ]; then
  WARNINGS="${WARNINGS}\n- structured-handoff 未执行：交接文档未更新"
fi

# 检查 handoff.md 是否用了结构化模板（检查必需的 section header）
if [ -f "$HANDOFF_FILE" ]; then
  if ! grep -q "## 目标" "$HANDOFF_FILE" 2>/dev/null; then
    WARNINGS="${WARNINGS}\n- handoff.md 未使用结构化模板（缺少 '## 目标' section）"
  fi
fi

if [ -n "$WARNINGS" ]; then
  printf "finishing 阶段有 skill 未执行：%b\n" "$WARNINGS"
  printf "建议在结束前运行 /structured-handoff 和 /skill-extract\n"
  exit 0
fi

exit 0

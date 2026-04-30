#!/bin/bash
# Stop hook: 检查 Evidence Depth 和 CI 阻断字段是否已填写
# 只在 finishing 阶段(evaluate 结果存在时)检查
# exit 2 = 阻断,exit 0 = 通过

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EVAL_FILE="$PROJECT_DIR/docs/active/evaluation-result.md"
HANDOFF_FILE="$PROJECT_DIR/docs/active/handoff.md"

# 没有评估结果(不在 finishing 阶段),不检查
if [ ! -f "$EVAL_FILE" ]; then
  exit 0
fi

# handoff 文件不存在,不检查(check-handoff.sh 会拦)
if [ ! -f "$HANDOFF_FILE" ]; then
  exit 0
fi

ERRORS=""

# 检查 Evidence Depth 字段是否存在且非空
if ! grep -q "## Evidence Depth" "$HANDOFF_FILE" 2>/dev/null; then
  ERRORS="${ERRORS}\n- handoff.md 缺少 '## Evidence Depth' 字段"
elif grep -A 4 "## Evidence Depth" "$HANDOFF_FILE" 2>/dev/null | grep -q "\[待填\]"; then
  ERRORS="${ERRORS}\n- Evidence Depth 字段未填写(仍为 [待填])"
fi

# 检查 CI 阻断字段是否存在且非空
if ! grep -q "## CI 阻断" "$HANDOFF_FILE" 2>/dev/null; then
  ERRORS="${ERRORS}\n- handoff.md 缺少 '## CI 阻断' 字段"
elif grep -A 1 "## CI 阻断" "$HANDOFF_FILE" 2>/dev/null | grep -q "\[待填\]"; then
  ERRORS="${ERRORS}\n- CI 阻断字段未填写(仍为 [待填])"
fi

if [ -n "$ERRORS" ]; then
  printf "Evidence Depth 检查未通过:%b\n" "$ERRORS"
  printf "请按 docs/references/testing-standard.md 的格式填写后再继续。\n"
  exit 2
fi

exit 0

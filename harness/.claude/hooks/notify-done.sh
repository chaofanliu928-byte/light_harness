#!/bin/bash
# notify-done.sh
# Notification hook（可选）：Claude 需要你注意时发桌面通知
#
# 使用方式：在 settings.json 的 hooks 中添加：
# "Notification": [
#   {
#     "matcher": "",
#     "hooks": [
#       { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/notify-done.sh" }
#     ]
#   }
# ]

INPUT=$(cat)
MSG=$(echo "$INPUT" | jq -r '.message // "Claude Code 需要你的注意"' 2>/dev/null)

# macOS
if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$MSG\" with title \"Claude Code\"" 2>/dev/null
# Linux (需要 libnotify)
elif command -v notify-send &>/dev/null; then
    notify-send "Claude Code" "$MSG" 2>/dev/null
# Windows (WSL)
elif command -v powershell.exe &>/dev/null; then
    powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$MSG', 'Claude Code')" 2>/dev/null
fi

exit 0

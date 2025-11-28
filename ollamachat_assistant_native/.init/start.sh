#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
# Start helper: launch VS Code in development mode via code CLI (non-blocking) - explicit failure if code CLI missing
if ! command -v code >/dev/null 2>&1; then
  echo "Error: 'code' CLI not found; interactive start unavailable" >&2
  exit 6
fi
# Launch VS Code with extension development host; runs in foreground, detach is left to the caller
code --extensionDevelopmentPath="${WS_DIR}" --disable-extensions &
PID=$!
echo "$PID" > /tmp/ollama_vscode_devhost.pid
sleep 2
ps -p ${PID} >/dev/null 2>&1 || { echo "Error: VS Code process failed to start" >&2; exit 8; }
echo "Started VS Code PID ${PID}"
exit 0

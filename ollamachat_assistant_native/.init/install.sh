#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
# ensure node and npm available
command -v node >/dev/null 2>&1 || { echo "node not found on PATH" >&2; exit 2; }
command -v npm >/dev/null 2>&1 || { echo "npm not found on PATH" >&2; exit 3; }
[ -f package.json ] || { echo "package.json missing; run scaffold step" >&2; exit 6; }
# dev dependencies to install when no lockfile
DEV_DEPS=(esbuild ts-node typescript "@types/vscode" "@vscode/test-electron" mocha)
if [ -f package-lock.json ]; then
  npm ci --no-audit --no-fund --silent
else
  echo "Warning: package-lock.json missing; install will create/update lockfile and may be non-reproducible" >&2
  # expand array safely
  npm i --no-audit --no-fund --silent --save-dev "${DEV_DEPS[@]}"
fi
exit 0

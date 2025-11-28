#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
# Build project (assumes package.json scripts.build exists and runs tsc/esbuild)
npm run build --silent || { echo "Error: build failed" >&2; exit 7; }
# Basic artifact checks
[ -f dist/webview.js ] || echo "Warning: dist/webview.js not found" >&2
[ -f out/extension.js ] || echo "Warning: out/extension.js not found" >&2
exit 0

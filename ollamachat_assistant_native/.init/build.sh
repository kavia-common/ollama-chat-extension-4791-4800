#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "$WS"
# Use local tsc if available; otherwise leave JS fallback
if [ -x "./node_modules/.bin/tsc" ]; then
  ./node_modules/.bin/tsc -p tsconfig.json --pretty false
else
  echo "build: local tsc not present, using JS fallback"
fi
# Ensure build output exists
if [ ! -f out/extension.js ]; then
  echo "build: error - build output out/extension.js not found" >&2
  exit 20
fi

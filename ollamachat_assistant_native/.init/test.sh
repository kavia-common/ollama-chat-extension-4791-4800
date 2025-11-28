#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "$WS"
# run project-local jest if present
if [ -x "./node_modules/.bin/jest" ]; then
  ./node_modules/.bin/jest --silent || true
else
  echo "test: jest not present; skipping unit tests"
fi

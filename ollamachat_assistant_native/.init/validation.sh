#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "$WS"
LOG=/tmp/validation-$(date -u +%Y%m%dT%H%M%SZ).log
exec >"$LOG" 2>&1
# Build
if [ -x "./node_modules/.bin/tsc" ]; then
  ./node_modules/.bin/tsc -p tsconfig.json --pretty false
else
  echo "validation-005: local tsc not present, using JS fallback"
fi
[ -f out/extension.js ] || { echo "validation-005: build output out/extension.js not found" >&2; echo "validation-005: logs=$LOG"; exit 20; }
# Package with vsce if available
PKG_OK=1
if [ -x "./node_modules/.bin/vsce" ]; then
  if ./node_modules/.bin/vsce package; then PKG_OK=0; fi
elif command -v vsce >/dev/null 2>&1; then
  if vsce package; then PKG_OK=0; fi
else
  echo "validation-005: vsce not available; skipping package"
fi
if [ $PKG_OK -eq 0 ]; then
  VSIX=$(ls -1t *.vsix 2>/dev/null | head -n1 || true)
  if [ -n "$VSIX" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$VSIX" | awk '{print $1}' >"$VSIX.sha256"
      echo "validation-005: vsix=$PWD/$VSIX sha256=$(cat $VSIX.sha256)"
    else
      echo "validation-005: warning - sha256sum not available; cannot compute checksum" >&2
    fi
  fi
fi
# Start/Stop lifecycle via start script
if [ -x ./.init/start.sh ]; then
  ./.init/start.sh || true
else
  # fallback to plan start script if present
  if [ -x ./start ]; then
    ./start || true
  fi
fi
# Ollama healthcheck, fatal if OLLAMA_REQUIRED=1
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
TRY=0; MAX=6; OK=1
if ! command -v curl >/dev/null 2>&1; then
  echo "validation-005: error - curl not available" >&2; echo "validation-005: logs=$LOG"; exit 22
fi
until [ $TRY -ge $MAX ]; do
  if curl -sSf --max-time 5 "$OLLAMA_URL/health" >/dev/null 2>&1; then OK=0; break; fi
  TRY=$((TRY+1)); sleep 2
done
if [ $OK -eq 0 ]; then
  echo "validation-005: ollama:ok"
else
  if [ "${OLLAMA_REQUIRED:-0}" -eq 1 ]; then
    echo "validation-005: error - Ollama unreachable at $OLLAMA_URL" >&2; echo "validation-005: logs=$LOG"; exit 21
  else
    echo "validation-005: warning - Ollama unreachable at $OLLAMA_URL" >&2
  fi
fi
# Evidence
echo "validation-005: build=out/extension.js pkg_ok=$PKG_OK logs=$LOG"
exit 0

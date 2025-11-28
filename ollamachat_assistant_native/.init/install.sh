#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "$WS"
# Deterministic install respecting lockfile
if [ -f yarn.lock ]; then
  if command -v yarn >/dev/null 2>&1; then
    yarn install --frozen-lockfile --silent
  else
    echo "deps-003: yarn.lock present but yarn not available; falling back to npm ci" >&2
    npm ci --no-audit --no-fund --silent
  fi
elif [ -f package-lock.json ]; then
  npm ci --no-audit --no-fund --silent
else
  npm i --no-audit --no-fund --silent
fi
# Verify required CLIs
command -v sha256sum >/dev/null || { echo "deps-003: sha256sum missing (coreutils)" >&2; exit 5; }
command -v curl >/dev/null || { echo "deps-003: curl missing" >&2; exit 6; }
# Ensure project-local binaries exist; if missing, update package.json deterministically and run npm ci
ensure_dev_dep(){ name="$1" ver="$2"; if [ ! -x "./node_modules/.bin/$name" ]; then echo "deps-003: adding $name@$ver to devDependencies and running npm ci" >&2; node -e "const fs=require('fs');const p='package.json';if(!fs.existsSync(p)){console.error('package.json missing');process.exit(7);}let pj=JSON.parse(fs.readFileSync(p,'utf8'));pj.devDependencies=pj.devDependencies||{};pj.devDependencies['$1']='$2';fs.writeFileSync(p,JSON.stringify(pj,null,2));"; npm ci --no-audit --no-fund --silent; fi }
# Check vsce and jest (project-local)
ensure_dev_dep vsce ^2.1.0 || true
ensure_dev_dep jest ^29.0.0 || true
# Report core versions
echo "deps-003: node $(node --version) npm $(npm --version)"
# Ollama healthcheck (informational)
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
if curl -sSf --max-time 5 "$OLLAMA_URL/health" >/dev/null 2>&1; then
  echo "deps-003: ollama:ok"
else
  echo "deps-003: warning - Ollama unreachable at $OLLAMA_URL (this is informational; validation will enforce if required)" >&2
fi

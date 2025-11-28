#!/usr/bin/env bash
set -euo pipefail

# Simple build script to be used inside or outside Docker
if command -v npm >/dev/null 2>&1; then
  if [[ -f package-lock.json ]]; then
    npm ci --no-audit --no-fund
  else
    npm install --no-audit --no-fund
  fi
  npm run build || echo "No build script; compiled TypeScript if configured."
else
  echo "npm is not available. Use Docker build for packaging."
fi

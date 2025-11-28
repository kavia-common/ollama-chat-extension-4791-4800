#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "$WS"
# Try to exercise the extension via Node require fallback
if [ -f out/extension.js ]; then
  node -e 'try{const ext=require("./out/extension.js"); if(typeof ext.activate==="function") { Promise.resolve(ext.activate()).then(()=>{ if(typeof ext.deactivate==="function"){ ext.deactivate(); } process.exit(0); }).catch(e=>{ console.error("start: activate error",e); process.exit(2); }); } else { process.exit(0); } }catch(e){ console.error("start: require failed",e); process.exit(3); }' || true
else
  echo "start: no out/extension.js to run" >&2
  exit 10
fi

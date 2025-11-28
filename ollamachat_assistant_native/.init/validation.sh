#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
# Run build
bash .init/build.sh
# Run tests (which start and stop headless VS Code via the provided runner)
bash .init/test.sh
# After tests ensure extension host was started/stopped by scanning the integration log
TEST_LOG=/tmp/vscode_integration.log
if [ -f "${TEST_LOG}" ]; then
  if grep -qE "Extension host" "${TEST_LOG}" || grep -qE "Running tests" "${TEST_LOG}"; then
    true
  else
    echo "Warning: integration log lacks expected VS Code extension host traces" >&2
  fi
else
  echo "Warning: integration log ${TEST_LOG} missing" >&2
fi
# Ollama health-check with retries and Node fallback that writes full JSON response to TMPRESP
if [ -f /etc/profile.d/ollama.sh ]; then source /etc/profile.d/ollama.sh; fi
ENDPOINT=${OLLAMA_HTTP_ENDPOINT:-http://localhost:11434}
MODEL=${OLLAMA_MODEL:-llama3.1}
RETRIES=3; SLEEP=2; TMPRESP="/tmp/ollama_models.json"; HTTP_CODE=000
for i in $(seq 1 ${RETRIES}); do
  if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o "${TMPRESP}" -w "%{http_code}" --max-time 5 "${ENDPOINT}/v1/models" 2>/dev/null || echo 000)
  else
    # Node fallback: GET and write body to TMPRESP
    HTTP_CODE=$(node - <<'NODE'
const u=process.argv[1], out=process.env.TMPRESP||'/tmp/ollama_models.json';
const fs=require('fs'), http=require('http'), https=require('https');
const url=new URL(u); const proto = url.protocol==='https:'?https:http;
proto.get(u, res=>{ let b=''; res.on('data',c=>b+=c); res.on('end', ()=>{ try{ fs.writeFileSync(out, b); }catch(e){}; console.log(res.statusCode); }); }).on('error', ()=>{ console.log('000'); });
NODE
    "${ENDPOINT}/v1/models") || HTTP_CODE=000
  fi
  if [ "${HTTP_CODE}" = "200" ]; then break; fi
  sleep ${SLEEP}
done
if [ "${HTTP_CODE}" != "200" ]; then
  if [ "${OLLAMA_CHECK_OPTIONAL:-0}" = "1" ]; then
    echo "Warning: Ollama endpoint ${ENDPOINT} not reachable (HTTP ${HTTP_CODE}); continuing due to OLLAMA_CHECK_OPTIONAL=1" >&2
  else
    echo "Error: Ollama endpoint ${ENDPOINT} not reachable (HTTP ${HTTP_CODE})" >&2
    exit 9
  fi
else
  if [ -f "${TMPRESP}" ]; then
    if grep -q "${MODEL}" "${TMPRESP}"; then
      echo "Ollama endpoint reachable and model ${MODEL} appears in response"
    else
      echo "Warning: Ollama reachable but model ${MODEL} not found in /v1/models response" >&2
    fi
    rm -f "${TMPRESP}" || true
  else
    echo "Warning: Ollama reachable (HTTP 200) but response body not captured" >&2
  fi
fi
# Evidence summary
echo "Artifacts:"; ls -lh dist/webview.js out/extension.js 2>/dev/null || true
echo "Integration log (head):"; sed -n '1,200p' "${TEST_LOG}" || true
exit 0

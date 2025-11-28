#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
TEST_LOG=/tmp/vscode_integration.log
# Run integration tests via provided dev-scripts runner; capture stdout/stderr
node ./dev-scripts/run-integration-tests.js >"${TEST_LOG}" 2>&1 || { echo "Error: integration tests failed; see ${TEST_LOG}" >&2; cat "${TEST_LOG}" >&2; exit 8; }
# Quick evidence extraction (non-fatal)
grep -E "Downloading|Starting|Exiting|Running tests|Extension host" "${TEST_LOG}" >/dev/null 2>&1 || true
# Print a short tail for review
sed -n '1,200p' "${TEST_LOG}" || true
exit 0

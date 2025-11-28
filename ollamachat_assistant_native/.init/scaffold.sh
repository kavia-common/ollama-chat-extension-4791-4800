#!/usr/bin/env bash
set -euo pipefail
WS_DIR="/home/kavia/workspace/code-generation/ollama-chat-extension-4791-4800/ollamachat_assistant_native"
cd "${WS_DIR}"
mkdir -p src webview-src test dev-scripts out dist
# package.json minimal and idempotent; include conservative devDependency version hints (not enforced)
if [ ! -f package.json ]; then
  cat > package.json <<'JSON'
{
  "name": "ollamachat-assistant-native",
  "publisher": "localdev",
  "version": "0.0.1",
  "private": true,
  "main": "out/extension.js",
  "engines": { "vscode": "1.80.0" },
  "scripts": {
    "build:webview": "esbuild webview-src/index.tsx --bundle --outfile=dist/webview.js --platform=browser --format=esm --loader:.tsx=tsx --loader:.ts=ts",
    "build:ts": "tsc -p tsconfig.json",
    "build": "npm run build:webview && npm run build:ts",
    "build:tests": "tsc --project tsconfig.tests.json",
    "pretest": "npm run build",
    "test:integration": "node ./dev-scripts/run-integration-tests.js",
    "test": "npm run test:integration",
    "start:dev": "code --extensionDevelopmentPath=${WS_DIR} || (echo 'VS Code CLI missing' && exit 1)"
  }
}
JSON
fi
# tsconfig for main sources
if [ ! -f tsconfig.json ]; then
  cat > tsconfig.json <<'TS'
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2020",
    "outDir": "out",
    "rootDir": "src",
    "sourceMap": true,
    "strict": true,
    "jsx": "react",
    "lib": ["es2020", "dom"]
  },
  "include": ["src/**/*"]
}
TS
fi
# separate tsconfig for tests to compile into out/test
if [ ! -f tsconfig.tests.json ]; then
  cat > tsconfig.tests.json <<'TS'
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2020",
    "outDir": "out/test",
    "rootDir": "test",
    "sourceMap": true,
    "strict": true,
    "lib": ["es2020", "dom"]
  },
  "include": ["test/**/*"]
}
TS
fi
# minimal extension entry
if [ ! -f src/extension.ts ]; then
  cat > src/extension.ts <<'TS'
import * as vscode from 'vscode';
export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('localdev.ollamaStart', () => {
    vscode.window.showInformationMessage('Ollama Assistant activated');
  });
  context.subscriptions.push(disposable);
}
export function deactivate() {}
TS
fi
# simple webview entry
if [ ! -f webview-src/index.tsx ]; then
  cat > webview-src/index.tsx <<'TSX'
const el = document.createElement('div'); el.textContent = 'Ollama Webview'; document.body.appendChild(el);
TSX
fi
# run-integration-tests: default VSCODE_VERSION numeric to match engines.vscode
cat > dev-scripts/run-integration-tests.js <<'JS'
const path = require('path'); const { runTests } = require('@vscode/test-electron');
(async ()=>{
  try{
    const v = process.env.VSCODE_VERSION || '1.80.0';
    const extensionDevelopmentPath = path.resolve(__dirname, '..');
    const extensionTestsPath = path.resolve(__dirname, '../out/test');
    await runTests({ extensionDevelopmentPath, extensionTestsPath, version: v });
    process.exit(0);
  }catch(err){ console.error(err); process.exit(1); }
})();
JS
chmod a+x dev-scripts/run-integration-tests.js || true
exit 0

"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
/**
 * PUBLIC_INTERFACE
 * activate
 * This function is called when the extension is activated.
 * It registers the Ollama Chat view and a command to open it.
 */
function activate(context) {
    var _a;
    const provider = new (_a = class {
            resolveWebviewView(webviewView) {
                webviewView.webview.options = { enableScripts: true };
                webviewView.webview.html = `
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Ollama Chat</title>
            <style>
              body { font-family: system-ui, sans-serif; margin:0; padding:12px; background:#f9fafb; color:#111827; }
              .card { background:#fff; border-radius:12px; box-shadow: 0 1px 3px rgba(0,0,0,.08); padding:12px; }
              .header { font-weight:600; color:#2563EB; margin-bottom:8px; }
            </style>
          </head>
          <body>
            <div class="card">
              <div class="header">Ollama Chat</div>
              <div>Extension scaffold is installed. Full UI implementation pending.</div>
            </div>
          </body>
        </html>`;
            }
        },
        _a.viewType = 'ollamaChatView',
        _a)();
    context.subscriptions.push(vscode.window.registerWebviewViewProvider('ollamaChatView', provider), vscode.commands.registerCommand('ollamaChat.open', async () => {
        await vscode.commands.executeCommand('workbench.view.extension.ollamaChatContainer');
    }));
}
/**
 * PUBLIC_INTERFACE
 * deactivate
 * Called when the extension is deactivated.
 */
function deactivate() {
    // no-op
}
//# sourceMappingURL=extension.js.map
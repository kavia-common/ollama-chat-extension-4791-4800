import * as vscode from 'vscode';

/**
 * PUBLIC_INTERFACE
 * activate
 * This function is called when the extension is activated.
 * It registers the Ollama Chat view and a command to open it.
 */
export function activate(context: vscode.ExtensionContext) {
  const provider = new (class implements vscode.WebviewViewProvider {
    public static readonly viewType = 'ollamaChatView';

    resolveWebviewView(webviewView: vscode.WebviewView): void | Thenable<void> {
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
  })();

  context.subscriptions.push(
    vscode.window.registerWebviewViewProvider('ollamaChatView', provider),
    vscode.commands.registerCommand('ollamaChat.open', async () => {
      await vscode.commands.executeCommand('workbench.view.extension.ollamaChatContainer');
    })
  );
}

/**
 * PUBLIC_INTERFACE
 * deactivate
 * Called when the extension is deactivated.
 */
export function deactivate() {
  // no-op
}

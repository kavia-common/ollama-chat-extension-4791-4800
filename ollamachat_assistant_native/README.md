# Ollama Chat VS Code Extension - Docker Build

This container is intended for building and packaging the extension in CI or locally without requiring a full local toolchain.

## Build Image

```bash
docker build -t ollama-chat-ext .
```

## Package Extension

```bash
docker run --rm -v "$PWD":/workspace ollama-chat-ext vsce package
```

This will produce a `.vsix` file under the workspace.

Notes:
- The Dockerfile uses non-interactive installs and single, well-formed RUN commands to avoid shell syntax errors.
- If your extension grows additional build steps, add them as separate script invocations or guarded checks, not inline multi-line RUN with unterminated syntax.

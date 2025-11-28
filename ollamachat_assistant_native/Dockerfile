# syntax=docker/dockerfile:1.7
#
# Dockerfile for building the VS Code extension (packaging and linting).
# This container is designed for CI build/verification and vsix packaging.
# It avoids any malformed RUN commands and uses explicit, non-interactive installs.

FROM node:18-bullseye AS base

# Set a non-root working directory
WORKDIR /workspace

# Ensure non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install minimal deps (git and zip for packaging)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates zip \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency manifests first for better caching
COPY package.json package-lock.json* ./

# Install dependencies if manifests exist; tolerate absence gracefully
# We use a small script-like pattern but keep it as one RUN with valid bash.
RUN if [[ -f package.json ]]; then \
      if [[ -f package-lock.json ]]; then npm ci --no-audit --no-fund; \
      else npm install --no-audit --no-fund; fi; \
    fi

# Copy extension source
COPY . .

# Build step (if the project has a build script). Do not fail if it doesn't.
RUN if jq -e '.scripts.build' package.json >/dev/null 2>&1; then \
      npm run build; \
    else \
      echo "No build script found, skipping build"; \
    fi

# Install vsce for packaging if needed
RUN npm install -g @vscode/vsce --no-audit --no-fund

# Default command provides help on how to package
CMD ["/bin/bash", "-lc", "echo 'Use: docker build -t ollama-ext . && docker run --rm -v $PWD:/workspace ollama-ext vsce package' && vsce --help"]

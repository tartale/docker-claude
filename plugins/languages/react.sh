#!/usr/bin/env bash
set -euo pipefail

# Chromium (for headless browser testing with Playwright/Puppeteer)
apt-get update
apt-get install -y chromium
rm -rf /var/lib/apt/lists/*

# TypeScript (React projects are almost exclusively TypeScript)
npm install -g \
  typescript \
  ts-node \
  tsx \
  @types/node

# Package managers (yarn is pre-installed in node:22-slim base image)
npm install -g \
  pnpm

# Build tooling & scaffolding
npm install -g \
  vite \
  create-next-app

# Code quality
npm install -g \
  eslint \
  prettier

# Utilities
npm install -g \
  serve \
  npm-check-updates \
  depcheck

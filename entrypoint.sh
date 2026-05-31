#!/bin/bash
set -e

if [ -n "$GITHUB_TOKEN" ]; then
    printf '[credential "https://github.com"]\n\thelper = !f() { echo username=x-access-token; echo password=%s; }; f\n' "$GITHUB_TOKEN" > /tmp/gitconfig
    export GIT_CONFIG_GLOBAL=/tmp/gitconfig
fi

node -e "
const fs = require('fs');
const cfgPath = '/home/node/.claude.json';
let cfg = {};
try { cfg = JSON.parse(fs.readFileSync(cfgPath, 'utf8')); } catch(e) {}
if (!cfg.projects) cfg.projects = {};
if (!cfg.projects['/workspace']) cfg.projects['/workspace'] = {};
cfg.projects['/workspace'].hasTrustDialogAccepted = true;
fs.writeFileSync(cfgPath, JSON.stringify(cfg));
"

exec claude --dangerously-skip-permissions "$@"

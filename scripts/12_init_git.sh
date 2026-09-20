#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
if [ ! -d .git ]; then
  git init
fi
git add .
git status
echo
echo "When ready:"
echo "  git commit -m 'Initialize YAM bimanual bring-up and real2sim2real stack'"

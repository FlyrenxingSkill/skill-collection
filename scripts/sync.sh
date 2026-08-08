#!/usr/bin/env bash
# Update skill-collection and ensure every assistant sees all skills.
# Usage: ~/.agents/skills/scripts/sync.sh
#        (or: git pull  with hooks installed — see install-git-hooks.sh)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

echo "[sync] pull skill-collection..."
git pull --rebase --autostash || git pull --autostash

echo "[sync] update submodules..."
git submodule sync --recursive
git submodule update --init --recursive --remote

echo "[sync] link into assistants..."
bash "$ROOT/scripts/link-agents.sh"

echo "[sync] done."

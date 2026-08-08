#!/usr/bin/env bash
# Install hooks so `git pull` refreshes submodules and re-links all assistants.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_DIR="$ROOT/.git/hooks"
mkdir -p "$HOOK_DIR"

write_hook() {
  local name="$1"
  cat > "$HOOK_DIR/$name" << 'HOOK'
#!/usr/bin/env bash
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[[ -f "$ROOT/scripts/link-agents.sh" ]] || exit 0
export PATH="/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"
# Fetch latest of each skill submodule + init any newly added ones
git -C "$ROOT" submodule sync --recursive 2>/dev/null || true
git -C "$ROOT" submodule update --init --recursive --remote 2>/dev/null || true
bash "$ROOT/scripts/link-agents.sh" || true
HOOK
  chmod +x "$HOOK_DIR/$name"
  echo "installed $HOOK_DIR/$name"
}

write_hook post-merge
write_hook post-checkout
write_hook post-rewrite
echo "Hooks installed."

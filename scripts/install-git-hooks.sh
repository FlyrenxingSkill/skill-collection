#!/usr/bin/env bash
# Install post-merge / post-checkout hooks so `git pull` auto-runs link-agents.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_DIR="$ROOT/.git/hooks"
mkdir -p "$HOOK_DIR"

write_hook() {
  local name="$1"
  cat > "$HOOK_DIR/$name" << 'HOOK'
#!/usr/bin/env bash
# Auto-maintained by skill-collection scripts/install-git-hooks.sh
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
# Only act on this collection repo
if [[ ! -f "$ROOT/scripts/link-agents.sh" ]]; then
  exit 0
fi
# After pull/checkout: submodules may need update (pull often already does --recurse)
export PATH="/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"
# Quiet submodule init for new modules added on remote
git -C "$ROOT" submodule update --init --recursive 2>/dev/null || true
bash "$ROOT/scripts/link-agents.sh" || true
HOOK
  chmod +x "$HOOK_DIR/$name"
  echo "installed $HOOK_DIR/$name"
}

write_hook post-merge
write_hook post-checkout
# post-rewrite covers rebase pulls
write_hook post-rewrite

echo "Hooks installed. Plain \`git pull\` will re-link skills into assistants."

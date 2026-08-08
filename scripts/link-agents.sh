#!/usr/bin/env bash
# Discover skills under collection SSOT and symlink into each assistant.
# - Thin:     <name>/SKILL.md
# - Monorepo: <repo>/skills/<name>/SKILL.md  → link name <name>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"

# Build name -> path lines; monorepo nested wins over top-level for same name if we process nested first...
# Prefer: if both top-level SKILL and nested, nested is the agent skill for monorepos that also might have root docs.
# Order: first nested skills/*, then top-level SKILL.md only if name not already taken.

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Nested monorepo skills first
while IFS= read -r -d '' dir; do
  name=$(basename "$dir")
  case "$name" in .git|scripts) continue ;; esac
  if [[ -d "$dir/skills" ]]; then
    while IFS= read -r -d '' sdir; do
      sname=$(basename "$sdir")
      [[ -f "$sdir/SKILL.md" ]] || continue
      echo "${sname}|${sdir}" >> "$tmp"
    done < <(find "$dir/skills" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

# Thin top-level (skip if name already listed)
while IFS= read -r -d '' dir; do
  name=$(basename "$dir")
  case "$name" in .git|scripts) continue ;; esac
  [[ -f "$dir/SKILL.md" ]] || continue
  if grep -q "^${name}|" "$tmp" 2>/dev/null; then
    continue
  fi
  echo "${name}|${dir}" >> "$tmp"
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

link_one() {
  local target_dir="$1" name="$2" src="$3"
  mkdir -p "$target_dir"
  local dest="${target_dir}/${name}"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "skip non-symlink: $dest" >&2
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "link $dest -> $src"
}

targets=(
  "${HOME}/.grok/skills"
  "${HOME}/.hermes/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.cursor/skills"
  "${HOME}/.buzz/.agents/skills"
  "${HOME}/.buzz/.claude/skills"
  "${HOME}/.buzz/.codex/skills"
  "${HOME}/.buzz/.goose/skills"
  "${HOME}/.cc-switch/skills"
)

while IFS='|' read -r name src; do
  [[ -n "$name" ]] || continue
  for t in "${targets[@]}"; do
    case "$t" in
      "${HOME}/.grok/skills"|"${HOME}/.codex/skills"|"${HOME}/.hermes/skills"|"${HOME}/.claude/skills"|"${HOME}/.cursor/skills")
        mkdir -p "$t" ;;
      *)
        [[ -d "$(dirname "$t")" ]] || continue
        mkdir -p "$t" ;;
    esac
    link_one "$t" "$name" "$src"
  done
done < "$tmp"

echo "Done. SSOT=$ROOT"
echo "skills:"
cut -d'|' -f1 "$tmp" | tr '\n' ' '
echo

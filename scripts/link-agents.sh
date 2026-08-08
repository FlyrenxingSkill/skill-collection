#!/usr/bin/env bash
# Discover skills under collection SSOT and symlink into each assistant.
# - Thin:     <name>/SKILL.md
# - Monorepo: <repo>/skills/<name>/SKILL.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"

entries=()
while IFS= read -r -d '' dir; do
  name=$(basename "$dir")
  case "$name" in .git|scripts) continue ;; esac
  if [[ -f "$dir/SKILL.md" ]]; then
    entries+=("${name}|${dir}")
  fi
  if [[ -d "$dir/skills" ]]; then
    while IFS= read -r -d '' sdir; do
      sname=$(basename "$sdir")
      [[ -f "$sdir/SKILL.md" ]] || continue
      entries+=("${sname}|${sdir}")
    done < <(find "$dir/skills" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

declare -A seen=()
pairs=()
for e in "${entries[@]}"; do
  n="${e%%|*}"
  [[ -n "${seen[$n]:-}" ]] && continue
  seen[$n]=1
  pairs+=("$e")
done

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

for t in "${targets[@]}"; do
  case "$t" in
    "${HOME}/.grok/skills"|"${HOME}/.codex/skills"|"${HOME}/.hermes/skills"|"${HOME}/.claude/skills"|"${HOME}/.cursor/skills")
      mkdir -p "$t" ;;
    *)
      [[ -d "$(dirname "$t")" ]] || continue
      mkdir -p "$t" ;;
  esac
  for e in "${pairs[@]}"; do
    link_one "$t" "${e%%|*}" "${e#*|}"
  done
done

echo "Done. SSOT=$ROOT"
echo -n "skills: "
for e in "${pairs[@]}"; do echo -n "${e%%|*} "; done
echo

#!/usr/bin/env bash
# Symlink every skill entry (dirs or aliases with SKILL.md) into assistant skill roots.
# Safe to run repeatedly. Called by sync.sh and git hooks after pull.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ ! -d "$ROOT" ]]; then
  echo "Missing $ROOT" >&2
  exit 1
fi

link_skill() {
  local target_dir="$1" name="$2"
  mkdir -p "$target_dir"
  local dest="${target_dir}/${name}"
  local src="${ROOT}/${name}"
  # Resolve to real path for stability across relative monorepo aliases
  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "skip missing: $name"
    return 0
  fi
  # Never clobber a real directory (e.g. Grok built-ins, codex .system sibling dirs)
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "skip non-symlink: $dest" >&2
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "link $dest -> $src"
}

# Top-level entries that expose SKILL.md (including symlinks into monorepos)
skills=()
while IFS= read -r -d '' path; do
  name=$(basename "$path")
  case "$name" in
    .git|scripts|projects|repos|.*) continue ;;
  esac
  if [[ -f "$path/SKILL.md" ]]; then
    skills+=("$name")
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -print0 2>/dev/null)

if [[ ${#skills[@]} -eq 0 ]]; then
  echo "No skills found under $ROOT" >&2
  exit 0
fi

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
  parent=$(dirname "$t")
  # create target if parent exists OR it's a known home agent path we want to create
  case "$t" in
    "${HOME}/.grok/skills"|"${HOME}/.codex/skills"|"${HOME}/.hermes/skills"|"${HOME}/.claude/skills")
      mkdir -p "$t"
      ;;
    *)
      [[ -d "$parent" ]] || continue
      mkdir -p "$t"
      ;;
  esac
  for name in "${skills[@]}"; do
    link_skill "$t" "$name"
  done
done

echo "Done. SSOT=$ROOT"
echo "skills: ${skills[*]}"

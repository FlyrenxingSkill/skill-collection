#!/usr/bin/env bash
# One-time / when collection gains new skill names: link into assistant skill dirs.
# Daily updates: only `git pull` + `git submodule update` in ~/.agents/skills.
set -euo pipefail
ROOT="${HOME}/.agents/skills"
if [[ ! -d "$ROOT" ]]; then
  echo "Missing $ROOT — clone skill-collection first" >&2
  exit 1
fi

link_skill() {
  local target_dir="$1" name="$2"
  mkdir -p "$target_dir"
  local dest="${target_dir}/${name}"
  local src="${ROOT}/${name}"
  [[ -e "$src" || -L "$src" ]] || { echo "skip missing: $name"; return 0; }
  # Always (re)point symlink to canonical path
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "exists (not symlink), skip: $dest" >&2
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "link $dest -> $src"
}

skills=()
while IFS= read -r d; do
  name=$(basename "$d")
  case "$name" in .git|scripts|.*) continue ;; esac
  # dir or symlink to dir with SKILL.md
  if [[ -f "$d/SKILL.md" ]] || [[ -L "$d" && -f "$d/SKILL.md" ]]; then
    skills+=("$name")
  fi
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 \( -type d -o -type l \))

targets=(
  "${HOME}/.grok/skills"
  "${HOME}/.hermes/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.buzz/.agents/skills"
  "${HOME}/.buzz/.claude/skills"
  "${HOME}/.buzz/.codex/skills"
  "${HOME}/.buzz/.goose/skills"
)

for t in "${targets[@]}"; do
  parent=$(dirname "$t")
  [[ -d "$parent" ]] || continue
  for name in "${skills[@]}"; do
    link_skill "$t" "$name"
  done
done

echo "Done. SSOT=$ROOT  skills=${skills[*]}"
echo "Note: after git pull you do NOT need this script unless names were added."

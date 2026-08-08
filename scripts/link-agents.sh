#!/usr/bin/env bash
# Link other assistants' user-skill paths to ~/.agents/skills entries.
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
  [[ -d "$src" ]] || { echo "skip missing skill: $name"; return 0; }
  if [[ -L "$dest" ]]; then
    ln -sfn "$src" "$dest"
    echo "relink $dest -> $src"
  elif [[ -e "$dest" ]]; then
    echo "exists (not symlink), skip: $dest" >&2
  else
    ln -sfn "$src" "$dest"
    echo "link $dest -> $src"
  fi
}

# Discover skill dirs (submodules / dirs with SKILL.md)
skills=()
while IFS= read -r d; do
  name=$(basename "$d")
  [[ "$name" == .* || "$name" == scripts ]] && continue
  [[ -f "$d/SKILL.md" ]] && skills+=("$name")
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d)

# Grok user skills (keep non-collection skills intact)
for name in "${skills[@]}"; do
  link_skill "${HOME}/.grok/skills" "$name"
done

# Hermes
for name in "${skills[@]}"; do
  link_skill "${HOME}/.hermes/skills" "$name"
done

# Codex user skills (preserve .system)
for name in "${skills[@]}"; do
  link_skill "${HOME}/.codex/skills" "$name"
done

# Claude Code style
if [[ -d "${HOME}/.claude" ]]; then
  for name in "${skills[@]}"; do
    link_skill "${HOME}/.claude/skills" "$name"
  done
fi

# Buzz nested agents (if present)
for base in "${HOME}/.buzz/.agents/skills" "${HOME}/.buzz/.claude/skills" "${HOME}/.buzz/.codex/skills" "${HOME}/.buzz/.goose/skills"; do
  [[ -d "$(dirname "$base")" ]] || continue
  for name in "${skills[@]}"; do
    link_skill "$base" "$name"
  done
done

echo "Done. Canonical skills: $ROOT"

# Agent instructions — skill-collection

## On any skill mention

When the user mentions a skill by name, purpose, or asks to use/update a skill from this machine:

1. Ensure you are operating against `~/.agents/skills` (this repo).
2. **Pull latest before using:**

```bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
cd "$HOME/.agents/skills" || exit 1
git pull --rebase --autostash
git submodule update --init --recursive --remote
```

3. Then read `~/.agents/skills/<skill-name>/SKILL.md` and follow it.
4. If the named skill directory is missing after update, say so and list available skills (`ls -1` dirs with `SKILL.md`).

## Do not

- Invent skill content if `SKILL.md` is missing
- Skip pull when the user is explicitly asking to use a skill that may have been updated on GitHub
- Commit secrets into this repo or skill submodules

## Paths

- Canonical: `~/.agents/skills`
- Other agent UIs should symlink here (see README / `scripts/link-agents.sh`)

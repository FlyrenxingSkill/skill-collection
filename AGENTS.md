# Agent instructions — skill-collection

## When user mentions a skill

1. Canonical root: `~/.agents/skills`
2. **Pull first** (symlinks do not need re-creating):

```bash
cd "$HOME/.agents/skills" || exit 1
git pull --rebase --autostash
git submodule update --init --recursive --remote
```

3. Load `~/.agents/skills/<name>/SKILL.md` (aliases like `wechat-rag` resolve into monorepos).
4. For monorepo skills, code lives under the project submodule (e.g. `wechat-memory/`); the flat name is only the skill entry.

## Do not

- Copy vendor/assistant built-in skills into this repo
- Re-run multi-app link scripts after every pull
- Treat `FlyrenxingSkill/wechat-rag` thin repo as source of truth (use `wechat-memory`)

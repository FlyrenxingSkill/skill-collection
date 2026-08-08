# Agent instructions — skill-collection

## Single source of truth

`~/.agents/skills` = this git repo (skill-collection + submodules).

## When user mentions any skill / wants latest skills

Prefer:

```bash
bash "$HOME/.agents/skills/scripts/sync.sh"
```

This: `git pull` → submodule update → **auto symlink into every assistant**.

Fallback if sync.sh missing:

```bash
cd "$HOME/.agents/skills" && git pull --rebase --autostash
git submodule update --init --recursive --remote
bash scripts/link-agents.sh
```

Then open `~/.agents/skills/<skill>/SKILL.md`.

## New skills appearing after pull

`link-agents.sh` (via hooks or sync.sh) creates/updates symlinks for **all** top-level entries that contain `SKILL.md`, including new ones. Do not manually ln unless hooks failed.

## Monorepos

- Full code: e.g. `projects/tgctl/`, `wechat-memory/`
- Agent entry: flat alias e.g. `tgctl` → `projects/tgctl/skills/tgctl`

## Do not

- Copy assistant built-in skills into this repo
- Maintain a second skill tree under `~/.cc-switch` as content SSOT

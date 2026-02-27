# worktree-ops-skill

Git worktree operations skill for creating worktrees and syncing local-only files safely.

[![license](https://img.shields.io/github/license/monymony/worktree-ops-skill)](https://github.com/monymony/worktree-ops-skill/blob/main/LICENSE)

## Features

- Create new worktrees with predictable commands
- Sync local-only files with `.worktreeinclude`
- Optional helper script to create + sync in one command
- Optional Husky `post-checkout` hook for first-checkout include sync

## Install

Codex (skill-installer UI):
- Run `$skill-installer`
- Ask: install GitHub repo `monymony/worktree-ops-skill` path `worktree-ops`

Manual (Codex):
```bash
mkdir -p ~/.codex/skills
git clone https://github.com/monymony/worktree-ops-skill.git /tmp/worktree-ops-skill
rsync -a /tmp/worktree-ops-skill/skills/worktree-ops/ ~/.codex/skills/worktree-ops/
```

Manual (Claude Code):
```bash
mkdir -p ~/.claude/skills
git clone https://github.com/monymony/worktree-ops-skill.git /tmp/worktree-ops-skill
rsync -a /tmp/worktree-ops-skill/skills/worktree-ops/ ~/.claude/skills/worktree-ops/
```

## Use

- Skill name: `worktree-ops`
- Skill file: `skills/worktree-ops/SKILL.md`

Core commands:
```bash
git worktree add <path> <branch>
git worktree add -b <branch> <path> <start-point>
./scripts/worktree-include.sh
```

## `.worktreeinclude` format

One rule per line:

```txt
<mode> <source> [dest]
```

- `mode`: `copy|symlink`
- `source` and `dest`: paths relative to main worktree root
- Keep paths space-free (simple parser)

Example:

```txt
copy .env.local
symlink .vscode/settings.json .vscode/settings.json
```

## Optional setup in target repos

```bash
cp ~/.codex/skills/worktree-ops/scripts/worktree-include.sh ./scripts/worktree-include.sh
cp ~/.codex/skills/worktree-ops/scripts/worktree-add.sh ./scripts/worktree-add.sh
cp ~/.codex/skills/worktree-ops/scripts/husky-post-checkout.sh ./.husky/post-checkout
chmod +x ./scripts/worktree-include.sh ./scripts/worktree-add.sh ./.husky/post-checkout
```

## Safety

- Keep secrets/configs out of Git and list them in `.worktreeinclude`.
- Prefer `copy` for environment and key files.
- Use `symlink` only when shared updates are intentional.

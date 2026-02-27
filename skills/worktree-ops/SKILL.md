---
name: worktree-ops
description: "Manage Git worktrees: create worktrees, sync local-only files via .worktreeinclude, handle hooks, and use helper scripts. Use when asked about worktree workflows, .worktreeinclude, or setting up worktree tooling."
---

# Worktree Ops

## Quick start

- Create worktree (required when skill used): `git worktree add <path> <branch>` (or `-b <branch> <start-point>`)
- Sync local-only files: copy `scripts/worktree-include.sh` from this skill into repo, then run `./scripts/worktree-include.sh`
- Optional wrapper: copy `scripts/worktree-add.sh` from this skill into repo
- Optional hook: copy `scripts/husky-post-checkout.sh` to `.husky/post-checkout`
- Add local-only files to `.worktreeinclude` (format below)

## Requirements

- Git installed
- `bash` available (for `worktree-include.sh` and `worktree-add.sh`)
- Husky optional (the hook only runs if Husky is installed/enabled)

## Conventions

- When this skill is invoked, create a new worktree by default. If path/branch not specified, ask for them.
- Keep local-only secrets/configs out of git; list in `.worktreeinclude`
- Prefer `copy` for env/profiles/keys; use `symlink` only when safe
- Use hook behavior: `.husky/post-checkout` runs include once on fresh worktree (hook file stored in this skill)

## Details

- `.worktreeinclude` format: `<mode> <source> [dest]`, mode = `copy|symlink`, paths relative to main worktree root
  - Paths cannot contain spaces (simple parser)
- Example `.worktreeinclude`:
  - `copy .env.local`
  - `symlink .vscode/settings.json .vscode/settings.json`
- `scripts/worktree-include.sh`:
  - resolve main root via `git rev-parse --git-common-dir`
  - copy/symlink from main to current worktree
  - skip if src missing or dest exists
- `scripts/worktree-add.sh`:
  - `git worktree add -b` if start-point provided
  - run include script in new worktree

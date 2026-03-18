---
name: worktree-ops
description: "Manage Git worktrees: create worktrees, sync local-only files via .worktreeinclude, handle hooks, and use helper scripts. Use when asked about worktree workflows, .worktreeinclude, or setting up worktree tooling."
---

# Worktree Ops

## Quick start

- Standard layout: keep main clones wherever they already live, and keep worktrees under `$HOME/worktrees/<repo>/<normalized-branch>`
- Create worktree (preferred when skill used): `./scripts/worktree-add.sh <branch> [start-point]`
- Create worktree at an explicit path: `./scripts/worktree-add.sh <branch> [start-point] --path /custom/path`
- Raw git equivalent: `git worktree add "$HOME/worktrees/<repo>/<normalized-branch>" <branch>` (or `-b <branch> <path> <start-point>`)
- Sync local-only files: copy `scripts/worktree-include.sh` from this skill into repo, then run `./scripts/worktree-include.sh`
- Optional wrapper: copy `scripts/worktree-add.sh` from this skill into repo
- Optional hook: copy `scripts/husky-post-checkout.sh` to `.husky/post-checkout`
- Add local-only files to `.worktreeinclude` (format below)

## Requirements

- Git installed
- `bash` available (for `worktree-include.sh` and `worktree-add.sh`)
- Husky optional (the hook only runs if Husky is installed/enabled)

## Conventions

- When this skill is invoked, create a new worktree under `$HOME/worktrees/<repo>/<normalized-branch>` by default. If only a raw `git worktree add` command is used, keep that same layout.
- Keep the main checkout outside the worktree root; do not nest worktrees inside another repository's working tree.
- Repositories that also appear as submodules should still keep their own worktrees under `$HOME/worktrees`, not under the parent superproject checkout.
- Keep local-only secrets/configs out of git; list in `.worktreeinclude`
- Prefer `copy` for env/profiles/keys; use `symlink` only when safe
- Use hook behavior: `.husky/post-checkout` runs include once on fresh worktree (hook file stored in this skill)
- Branch names map to a single directory name by replacing `/` with `__`, for example `feature/foo` -> `feature__foo`.
- Reserve `__` in branch names when using the default layout so the mapping stays unambiguous.

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
  - default root is `$HOME/worktrees`
  - derive the repo directory name from the current git root
  - create `$HOME/worktrees/<repo>/<normalized-branch>` when no explicit path is provided
  - normalize branch names by replacing `/` with `__` in the directory name
  - reject default-layout branch names that already contain `__`
  - `git worktree add -b` if start-point provided
  - run include script in new worktree

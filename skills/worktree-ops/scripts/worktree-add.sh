#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $(basename "$0") <path> <branch> [start-point]" >&2
  exit 1
fi

worktree_path="$1"
branch="$2"
start_point="${3:-}"

if [ -n "$start_point" ]; then
  git worktree add -b "$branch" "$worktree_path" "$start_point"
else
  git worktree add "$worktree_path" "$branch"
fi

if [ -f "$worktree_path/scripts/worktree-include.sh" ]; then
  (cd "$worktree_path" && ./scripts/worktree-include.sh)
fi

#!/usr/bin/env sh

# Auto-sync local-only files into new worktrees only.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ]; then
  exit 0
fi

cd "$repo_root"

if [ ! -x "./scripts/worktree-include.sh" ]; then
  exit 0
fi

head_log=$(git rev-parse --git-path logs/HEAD 2>/dev/null || true)
marker=$(git rev-parse --git-path worktreeinclude.applied 2>/dev/null || true)

if [ -z "$head_log" ] || [ -z "$marker" ]; then
  exit 0
fi

if [ -f "$marker" ] || [ ! -f "$head_log" ]; then
  exit 0
fi

line_count=$(wc -l <"$head_log" | tr -d ' ')
if [ "$line_count" -le 1 ]; then
  ./scripts/worktree-include.sh
  : >"$marker"
fi

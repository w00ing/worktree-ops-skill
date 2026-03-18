#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <branch> [start-point] [--path <path>]" >&2
  echo "Defaults to \$HOME/worktrees/<repo>/<normalized-branch> when --path is not provided." >&2
  echo "Normalized branch names replace '/' with '__'." >&2
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

branch="$1"
shift
start_point=""
worktree_path=""

if [ $# -gt 0 ] && [ "$1" != "--path" ]; then
  start_point="$1"
  shift
fi

while [ $# -gt 0 ]; do
  case "$1" in
  --path)
    if [ $# -lt 2 ]; then
      usage
      exit 1
    fi
    worktree_path="$2"
    shift 2
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
worktree_root="${WORKTREE_ROOT:-$HOME/worktrees}"

if [ -z "$worktree_path" ]; then
  if [[ "$branch" == *"__"* ]]; then
    echo "Branch names containing '__' are not supported by the default worktree layout." >&2
    echo "Use --path for a custom location or rename the branch." >&2
    exit 1
  fi

  normalized_branch="${branch//\//__}"
  worktree_path="$worktree_root/$repo_name/$normalized_branch"
fi

mkdir -p "$(dirname "$worktree_path")"

if [ -n "$start_point" ]; then
  git worktree add -b "$branch" "$worktree_path" "$start_point"
else
  git worktree add "$worktree_path" "$branch"
fi

if [ -f "$worktree_path/scripts/worktree-include.sh" ]; then
  (cd "$worktree_path" && ./scripts/worktree-include.sh)
fi

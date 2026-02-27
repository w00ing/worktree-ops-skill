#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
common_dir=$(git rev-parse --git-common-dir)
main_root=$(cd "$common_dir/.." && pwd -P)
config="$repo_root/.worktreeinclude"

if [ ! -f "$config" ]; then
  exit 0
fi

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  if [ -z "$line" ]; then
    continue
  fi

  set -- $line
  mode="${1:-}"
  src="${2:-}"
  dest="${3:-}"

  if [ -z "$mode" ] || [ -z "$src" ]; then
    echo "worktree-include: invalid line: $line" >&2
    continue
  fi

  if [ -z "$dest" ]; then
    dest="$src"
  fi

  src_path="$main_root/$src"
  dest_path="$repo_root/$dest"

  if [ ! -e "$src_path" ]; then
    continue
  fi

  if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
    continue
  fi

  mkdir -p "$(dirname "$dest_path")"

  case "$mode" in
  copy | cp)
    if command -v rsync >/dev/null 2>&1; then
      rsync -a "$src_path" "$dest_path"
    else
      cp -pR "$src_path" "$dest_path"
    fi
    ;;
  symlink | link | ln)
    ln -s "$src_path" "$dest_path"
    ;;
  *)
    echo "worktree-include: unknown mode '$mode'" >&2
    ;;
  esac
done <"$config"

#!/usr/bin/env sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mode="${1:-fast}"
case "$mode" in
  fast) cargo xtask check-fast ;;
  core) cargo xtask check-core ;;
  workspace) cargo xtask check-workspace ;;
  compat) cargo xtask check-sui-compat ;;
  full) cargo xtask check-full ;;
  *) echo "usage: scripts/check.sh [fast|core|workspace|compat|full]" >&2; exit 2 ;;
esac

#!/usr/bin/env sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

if [ -f ".cargo/env-linux.sh" ]; then
  # shellcheck disable=SC1091
  . ".cargo/env-linux.sh"
fi

mode="${1:-fast}"
case "$mode" in
  fast) cargo test --no-run ;;
  workspace) cargo test --workspace --no-run ;;
  full) cargo test --workspace --all-targets --no-run ;;
  run) cargo test ;;
  *) echo "usage: scripts/test.sh [fast|workspace|full|run]" >&2; exit 2 ;;
esac

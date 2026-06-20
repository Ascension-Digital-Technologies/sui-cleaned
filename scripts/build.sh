#!/usr/bin/env sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

# If scripts/setup-linux.sh generated a libclang environment file, load it.
if [ -f ".cargo/env-linux.sh" ]; then
  # shellcheck disable=SC1091
  . ".cargo/env-linux.sh"
fi

mode="${1:-debug}"
case "$mode" in
  debug|fast) cargo build ;;
  release) cargo build --release ;;
  workspace) cargo build --workspace ;;
  full) cargo build --workspace --all-targets ;;
  check) cargo check ;;
  *) echo "usage: scripts/build.sh [debug|release|workspace|full|check]" >&2; exit 2 ;;
esac

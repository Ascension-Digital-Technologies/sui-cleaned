#!/usr/bin/env sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

mode="${1:-target}"
case "$mode" in
  target) cargo clean ;;
  native)
    cargo clean -p librocksdb-sys || true
    cargo clean -p rocksdb || true
    cargo clean -p tikv-jemalloc-sys || true
    ;;
  xtask) rm -rf target/xtask-output ;;
  *) echo "usage: scripts/clean.sh [target|native|xtask]" >&2; exit 2 ;;
esac

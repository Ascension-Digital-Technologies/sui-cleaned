#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
grep -RInE 'rocksdb.*jemalloc|tikv-jemalloc' Cargo.toml crates upstream 2>/dev/null || true
cargo tree -i tikv-jemalloc-sys --target "${1:-$(rustc -vV | sed -n 's/^host: //p')}" || true

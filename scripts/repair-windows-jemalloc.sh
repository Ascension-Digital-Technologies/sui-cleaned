#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python "$ROOT/scripts/repair-windows-jemalloc.py"
echo
echo "IMPORTANT: if tikv-jemalloc-sys already started compiling, run:"
echo "  cargo clean -p tikv-jemalloc-sys"
echo "  cargo clean -p tikv-jemallocator"
echo "  cargo clean -p tikv-jemalloc-ctl"
echo "then rerun cargo."

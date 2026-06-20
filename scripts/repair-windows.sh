#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
python3 "$ROOT/scripts/lib/repair-windows-jemalloc.py"
python3 "$ROOT/scripts/lib/repair-move-uint-version.py"
echo "Windows repair passes complete. libclang/RocksDB PowerShell fixes are Windows-only."

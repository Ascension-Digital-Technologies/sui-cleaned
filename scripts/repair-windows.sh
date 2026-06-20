#!/usr/bin/env sh
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
"$SCRIPT_DIR/repair-windows-bindgen-libclang.sh"
"$SCRIPT_DIR/repair-windows-jemalloc.sh"
"$SCRIPT_DIR/repair-windows-rocksdb-cstdint.sh"
"$SCRIPT_DIR/repair-move-uint-version.sh"
echo "Windows repair passes complete."

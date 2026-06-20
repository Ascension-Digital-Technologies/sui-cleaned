#!/usr/bin/env bash
set -euo pipefail
cargo tree -i tikv-jemalloc-sys --target "${1:-$(rustc -vV | sed -n 's/^host: //p')}"

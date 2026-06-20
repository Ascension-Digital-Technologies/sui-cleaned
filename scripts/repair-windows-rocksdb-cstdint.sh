#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .cargo
touch .cargo/config.toml
if ! grep -q 'CXXFLAGS_x86_64_pc_windows_gnu' .cargo/config.toml; then
  cat >> .cargo/config.toml <<'EOF'

# Windows GNU RocksDB fix. librocksdb-sys 0.16 / RocksDB 8.10 can fail on
# x86_64-pc-windows-gnu because rocksdb/options/offpeak_time_info.h uses
# int64_t without pulling in <cstdint>. cc-rs passes these flags to g++.
[env]
"CXXFLAGS_x86_64_pc_windows_gnu" = { value = "-include cstdint", force = false }
"CXXFLAGS_x86_64-pc-windows-gnu" = { value = "-include cstdint", force = false }
EOF
  echo 'patched .cargo/config.toml with Windows RocksDB cstdint flags'
else
  echo 'Windows RocksDB cstdint flags already present'
fi
echo 'Next: cargo clean -p librocksdb-sys && cargo check'

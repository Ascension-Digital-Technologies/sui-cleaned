#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${1:-}"
TMP="$ROOT/.upstream-tmp/sui"

if [[ -z "$SRC" ]]; then
  if [[ ! -d "$TMP/.git" ]]; then
    git clone --depth 1 https://github.com/MystenLabs/sui.git "$TMP"
  else
    git -C "$TMP" fetch --depth 1 origin main
    git -C "$TMP" checkout FETCH_HEAD
  fi
  SRC="$TMP"
fi

if [[ ! -f "$SRC/Cargo.toml" ]]; then
  echo "error: upstream Sui source not found at $SRC" >&2
  exit 1
fi

# Canonical cleaned layout:
#   crates/execution/move-vm/move      upstream external-crates/move
#   domain folders under crates/        synced Sui crates by domain
rm -rf "$ROOT/crates/execution/move-vm/move"
mkdir -p "$ROOT/crates/execution/move-vm"
if [[ -d "$SRC/external-crates/move" ]]; then
  cp -a "$SRC/external-crates/move" "$ROOT/crates/execution/move-vm/move"
else
  echo "warning: upstream external-crates/move not found" >&2
fi

python "$ROOT/scripts/sync-upstream-domain-crates.py" "$SRC"
python "$ROOT/scripts/repair-upstream-direct-paths.py"
python "$ROOT/scripts/repair-move-uint-version.py"
python "$ROOT/scripts/repair-windows-jemalloc.py"
python "$ROOT/scripts/audit-workspace-inheritance.py"
python "$ROOT/scripts/audit-direct-paths.py"

echo "Upstream deps synced into clean domain folders."
echo "Next: cargo metadata --format-version 1 --no-deps"

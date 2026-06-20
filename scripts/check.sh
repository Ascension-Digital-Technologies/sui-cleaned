#!/usr/bin/env bash
set -euo pipefail
mkdir -p reports
python "$ROOT/scripts/audit-workspace-inheritance.py"
python "$ROOT/scripts/audit-direct-paths.py"
cargo metadata --format-version 1 --no-deps > reports/cargo-metadata.json
cargo check --workspace --all-targets

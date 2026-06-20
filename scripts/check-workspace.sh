#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Workspace check: all active packages, normal lib/bin targets only."
cargo check --workspace

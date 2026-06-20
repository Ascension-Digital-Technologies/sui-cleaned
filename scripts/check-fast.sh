#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Fast check: workspace.default-members only, normal lib/bin targets."
cargo check

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "Full upstream parity check: all workspace packages and all test/bench/example targets."
echo "This is intentionally huge and can build thousands of crates."
cargo check --workspace --all-targets

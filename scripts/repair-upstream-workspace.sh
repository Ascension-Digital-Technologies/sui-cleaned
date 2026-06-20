#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python "$ROOT/scripts/audit-workspace-inheritance.py"
python "$ROOT/scripts/repair-upstream-direct-paths.py"
echo "Repaired upstream workspace paths."

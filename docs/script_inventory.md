# Script inventory

The script surface is intentionally small. Prefer `cargo xtask` for repository automation and use `scripts/` only as shell-friendly wrappers.

## Public scripts

| Script | Purpose |
|---|---|
| `scripts/check.bat` / `scripts/check.sh` | Run build tiers. |
| `scripts/fmt.bat` / `scripts/fmt.sh` | Format the workspace. |
| `scripts/status.bat` / `scripts/status.sh` | Print repo status. |
| `scripts/repair-windows.bat` / `scripts/repair-windows.sh` | Apply Windows GNU native-build fixes. |

## Internal helpers

Internal helpers live under `scripts/lib/` and support audits or Windows build setup.

This repository intentionally does not include upstream sync/fetch scripts. Embedded source refreshes should happen deliberately in a maintenance branch.

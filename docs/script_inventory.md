# Script inventory

The script surface is intentionally small. Prefer `cargo xtask` for repository automation and use `scripts/` only as shell-friendly wrappers.

## Public scripts

| Script | Purpose |
|---|---|
| `scripts/setup-linux.sh` | Install Linux native build dependencies and write optional `.cargo/env-linux.sh`. |
| `scripts/setup-windows.bat` / `scripts/setup-windows.ps1` | Install/prepare MSYS2/MinGW64 dependencies and write `.cargo/env-windows.ps1`. |
| `scripts/build.bat` / `scripts/build.sh` | Build modes: `debug`, `release`, `workspace`, `full`, `check`. |
| `scripts/check.bat` / `scripts/check.sh` | Check tiers: `fast`, `core`, `workspace`, `compat`, `full`. |
| `scripts/test.bat` / `scripts/test.sh` | Test build modes: `fast`, `workspace`, `full`, `run`. |
| `scripts/fmt.bat` / `scripts/fmt.sh` | Format the workspace. |
| `scripts/clean.bat` / `scripts/clean.sh` | Clean modes: `target`, `native`, `xtask`. |
| `scripts/status.bat` / `scripts/status.sh` | Print repo status. |
| `scripts/repair-windows.bat` / `scripts/repair-windows.sh` | Apply Windows GNU native-build fixes. |

## Internal helpers

Internal helpers live under `scripts/lib/` and support audits or Windows build setup.

This repository intentionally does not include upstream sync/fetch scripts. Embedded source refreshes should happen deliberately in a maintenance branch.

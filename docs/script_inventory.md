# Script Inventory

Script categories are printed directly by `xtask`. Use:

```powershell
cargo xtask scripts
```

to print the inventory from the task runner.

## Categories

- `check`: legacy wrappers for build tiers.
- `sync`: upstream sync wrappers.
- `repair`: deterministic source repair passes.
- `audit`: find/status/audit utilities.
- `utility`: formatting and package-map helpers.

Prefer `cargo xtask` commands for normal work.

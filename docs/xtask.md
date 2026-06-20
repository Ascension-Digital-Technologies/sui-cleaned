# Xtask Command Runner

`sui-clean` uses a small dependency-free Rust `xtask` crate for repeatable repository operations.
It does not replace Cargo. It gives the repo one clean command surface for common checks,
Windows repairs, layout checks, build tiers, and status reporting.

## Common commands

```powershell
cargo xtask status
cargo xtask repair-windows
cargo xtask check-fast
cargo xtask check-core
cargo xtask check-workspace
cargo xtask check-sui-compat
cargo xtask check-full
```

## Build tiers

- `check-fast` runs `cargo check` against workspace default members.
- `check-core` checks the first-party core package set explicitly.
- `check-workspace` checks every active workspace package without tests, benches, or examples.
- `check-sui-compat` checks the main protocol/execution compatibility packages.
- `check-full` runs the full all-targets compatibility gate with `--workspace --all-targets`.

Use `check-full` deliberately. It pulls in Sui/Move tests, fuzzers, indexers,
bridge, faucet, Rosetta, analyzer, simulator, and benchmark targets.


## Hygiene commands

```powershell
cargo xtask tiers
cargo xtask scripts
cargo xtask check-root
cargo xtask audit
```

- `tiers` prints the build-tier model without building.
- `scripts` prints the built-in script inventory.
- `check-root` enforces the built-in root policy.
- `audit` runs the stricter static status report.

## Layout commands

```powershell
cargo xtask domains
cargo xtask tree
cargo xtask tree execution
cargo xtask check-layout
cargo xtask check-domain runtime
cargo xtask check-domain execution --all-targets
```

These commands keep the cleaned monorepo structure enforceable after the v19-v23 domain cleanup.

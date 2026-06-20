# Contributing

Thanks for improving Sui Clean.

This repository is a cleaned-up Sui Rust workspace. Contributions should preserve that goal: make the repo easier to navigate, build, audit, and maintain without hiding upstream compatibility.

## Ground rules

- Keep `crates/` limited to the approved domains: `api`, `crypto`, `config`, `runtime`, `consensus`, `execution`, `network`, `protocol`, and `storage`.
- Keep `bench/`, `tests/`, and `tools/` at the root.
- Do not recreate root-level `vendor/`, `upstream/`, or `manifests/` folders.
- Put Move VM and Move execution sources under `crates/execution/move-vm/`.
- Preserve upstream package names when Cargo compatibility requires them.
- Keep cleanup changes separate from behavioral changes whenever possible.

## Before opening a pull request

Run:

```powershell
cargo xtask check-layout
cargo xtask status
cargo check
```

For domain-specific changes, also run one of:

```powershell
cargo xtask check-domain api
cargo xtask check-domain execution
cargo xtask check-domain runtime
cargo xtask check-domain storage
```

On Windows GNU, run:

```powershell
scripts\repair-windows.bat
cargo check
```

## Pull request style

A good PR explains:

1. What was cleaned up or fixed.
2. Whether source behavior changed.
3. Which commands were run.
4. Whether the change affects upstream sync paths.

## Commit style

Use clear, boring commit messages:

```text
Clean runtime crate layout
Fix Move VM path aliases
Add xtask layout checks
Document Windows bindgen setup
```

## Upstream sync changes

If a PR updates embedded upstream Sui/Move code, include:

- the upstream source or checkout used,
- any repair scripts run,
- the result of `cargo xtask check-layout`, and
- the result of `cargo check`.

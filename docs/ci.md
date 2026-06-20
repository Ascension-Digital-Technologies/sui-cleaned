# CI

This repository uses a small GitHub Actions workflow for layout and default build checks.

## Why CI does not use `--locked`

The cleaned workspace embeds Sui and Move source under a reorganized domain layout. During cleanup passes, Cargo can need to refresh `Cargo.lock` even when no intentional dependency version change was made. For that reason, CI runs:

```bash
cargo check
```

instead of:

```bash
cargo check --locked
```

For release stabilization, run `cargo check` locally and commit any intentional `Cargo.lock` update.

## Local checks

```bash
cargo xtask check-layout
cargo xtask status
cargo check
```

On Windows GNU, run the repair first:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo check
```

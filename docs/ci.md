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
scripts/check.sh fast
```

On Windows GNU, run the repair first:

```powershell
scripts\repair-windows.bat
scripts\check.bat fast
```


## Windows native environment

Windows jobs should either use `scripts\build.bat` / `scripts\check.bat` or dot-source `.cargo\env-windows.ps1` before direct Cargo commands. This ensures MSYS2 `mingw64\bin` is on `PATH` so bindgen can load `libclang.dll`.

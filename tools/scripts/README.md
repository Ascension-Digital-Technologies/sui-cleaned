# Scripts

`scripts/` contains the public workflow entrypoints for local development and GitHub CI. Most repository automation lives in `cargo xtask`; these scripts are convenience wrappers that prepare native build environments before invoking Cargo.

## Public entrypoints

| Script | Purpose |
|---|---|
| `setup-linux.sh` | Install Linux native build dependencies such as clang, libclang, pkg-config, cmake, and compression libraries. |
| `setup-windows.bat` / `setup-windows.ps1` | Install MSYS2 native build dependencies and generate the Windows Cargo environment. |
| `build.bat` / `build.ps1` / `build.sh` | Build modes: `debug`, `release`, `workspace`, `full`, or `check`. Windows discovers MSYS2/LLVM libclang dynamically before Cargo runs. |
| `check.bat` / `check.ps1` / `check.sh` | Check tiers: `fast`, `core`, `workspace`, `compat`, or `full`. Windows loads the same MSYS2/libclang environment automatically. |
| `fmt.bat` / `fmt.sh` | Run formatting through `cargo xtask fmt`. |
| `status.bat` / `status.sh` | Run `cargo xtask status`. |
| `repair-windows.bat` / `repair-windows.sh` | Apply Windows GNU native-build fixes and regenerate `.cargo/env-windows.*`. |

## Windows examples

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
scripts\build.bat release
scripts\check.bat fast
scripts\repair-windows.bat
scripts\status.bat
```

For direct `cargo build` or `cargo check` commands on Windows GNU, run this once per PowerShell session first:

```powershell
. .\.cargo\env-windows.ps1
```

The wrapper scripts do this environment setup automatically. Prefer the wrappers when building RocksDB or anything that uses bindgen.

## Linux/macOS examples

```bash
scripts/setup-linux.sh
scripts/build.sh debug
scripts/build.sh release
scripts/check.sh fast
scripts/status.sh
```

## Internals

Implementation helpers live in `scripts/lib/`. They are not public workflow commands.

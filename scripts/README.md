# Scripts

`scripts/` contains a small public wrapper surface for common local workflows. Most repository automation lives in `cargo xtask`; these scripts are convenience entrypoints for Windows and Unix shells.

## Public entrypoints

| Script | Purpose |
|---|---|
| `setup-linux.sh` | Install Linux native build dependencies such as clang, libclang, pkg-config, cmake, and compression libraries. |
| `setup-windows.bat` / `setup-windows.ps1` | Install MSYS2/MinGW64 native build dependencies and generate the Windows Cargo environment. |
| `build.bat` / `build.sh` | Build modes: `debug`, `release`, `workspace`, `full`, or `check`. |
| `check.bat` / `check.sh` | Check tiers: `fast`, `core`, `workspace`, `compat`, or `full`. |
| `test.bat` / `test.sh` | Test build modes: `fast`, `workspace`, `full`, or `run`. The default compiles tests without running them. |
| `fmt.bat` / `fmt.sh` | Run formatting through `cargo xtask fmt`. |
| `clean.bat` / `clean.sh` | Clean build output: `target`, `native`, or `xtask`. |
| `status.bat` / `status.sh` | Run `cargo xtask status`. |
| `repair-windows.bat` / `repair-windows.sh` | Apply Windows GNU native-build fixes. |

## Windows examples

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
scripts\build.bat release
scripts\check.bat fast
scripts\test.bat fast
scripts\clean.bat native
scripts\repair-windows.bat
scripts\status.bat
```

For direct `cargo build` or `cargo check` commands on Windows GNU, run this once per PowerShell session first:

```powershell
. .\.cargo\env-windows.ps1
```

The wrapper scripts do this environment setup automatically.

## Linux/macOS examples

```bash
scripts/setup-linux.sh
scripts/build.sh debug
scripts/build.sh release
scripts/check.sh fast
scripts/test.sh fast
scripts/clean.sh native
scripts/status.sh
```

## Internals

Implementation helpers live in `scripts/lib/`. They are not public workflow commands.

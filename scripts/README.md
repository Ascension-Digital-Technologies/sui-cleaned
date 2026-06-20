# Scripts

`scripts/` contains a small public wrapper surface. Most repository automation lives in `cargo xtask`; these scripts are convenience entrypoints for Windows and Unix shells.

## Public entrypoints

| Script | Purpose |
|---|---|
| `build.bat` / `build.sh` | Build modes: `debug`, `release`, `workspace`, `full`, or `check`. Windows loads MSYS2/libclang automatically. |
| `check.bat` / `check.sh` | Check tiers: `fast`, `core`, `workspace`, `compat`, or `full`. Windows loads MSYS2/libclang automatically. |
| `fmt.bat` / `fmt.sh` | Run formatting through `cargo xtask fmt`. |
| `status.bat` / `status.sh` | Run `cargo xtask status`. |
| `repair-windows.bat` / `repair-windows.sh` | Apply Windows GNU native-build fixes. |

## Windows examples

```powershell
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

The wrapper scripts do this environment setup automatically.

## Linux/macOS examples

```bash
scripts/build.sh debug
scripts/build.sh release
scripts/check.sh fast
scripts/status.sh
```

## Internals

Implementation helpers live in `scripts/lib/`. They are not public workflow commands.

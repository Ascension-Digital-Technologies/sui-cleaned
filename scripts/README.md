# Scripts

`scripts/` contains a small public wrapper surface. Most repository automation lives in `cargo xtask`; these scripts are convenience entrypoints for Windows and Unix shells.

## Public entrypoints

| Script | Purpose |
|---|---|
| `check.bat` / `check.sh` | Run build tiers: `fast`, `core`, `workspace`, `compat`, `full`, or Windows wrapper. |
| `fmt.bat` / `fmt.sh` | Run formatting through `cargo xtask fmt`. |
| `status.bat` / `status.sh` | Run `cargo xtask status`. |
| `repair-windows.bat` / `repair-windows.sh` | Apply Windows GNU native-build fixes. |

## Examples

Windows:

```powershell
scripts\check.bat fast
scripts\repair-windows.bat
scripts\status.bat
```

Linux/macOS:

```bash
scripts/check.sh fast
scripts/status.sh
```

## Internals

Implementation helpers live in `scripts/lib/`. They are not public workflow commands.

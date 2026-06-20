# Build guide

This repo includes thin build wrappers for common local and CI workflows.

## Windows GNU

Use the wrapper scripts because native dependencies such as `librocksdb-sys` use bindgen and need MSYS2/MinGW64 `libclang.dll` and its dependent DLLs on `PATH`.

```powershell
scripts\repair-windows.bat
scripts\build.bat debug
```

Build modes:

```powershell
scripts\build.bat debug
scripts\build.bat release
scripts\build.bat workspace
scripts\build.bat full
scripts\build.bat check
```

For direct Cargo commands, load the Windows environment first:

```powershell
. .\.cargo\env-windows.ps1
cargo build
cargo check
```

## Linux/macOS

```bash
scripts/build.sh debug
scripts/build.sh release
scripts/check.sh fast
```

## Recommended checks before pushing

```bash
cargo xtask check-layout
scripts/check.sh fast
```

On Windows:

```powershell
cargo xtask check-layout
scripts\check.bat fast
```

# Windows GNU Toolchain

This repo uses MSYS2/MinGW for Windows GNU native builds. The build wrappers no longer assume clang is located at one fixed path. They search these directories in order:

- `C:\msys64\mingw64\bin`
- `C:\msys64\ucrt64\bin`
- `C:\msys64\clang64\bin`
- `C:\msys64\usr\bin`
- `C:\Program Files\LLVM\bin`

The wrappers set `LIBCLANG_PATH`, optional `CLANG_PATH`, bindgen target args, and the RocksDB `-include cstdint` workaround before running Cargo.

Use:

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
```

For direct Cargo commands, run:

```powershell
. .\.cargo\env-windows.ps1
cargo build
```

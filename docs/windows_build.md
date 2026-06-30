# Windows build notes

Windows GNU builds need MSYS2/MinGW available to native build scripts. In particular, `librocksdb-sys` uses bindgen, and bindgen must be able to load `libclang.dll` plus its dependent DLLs.

## Recommended path

Use the wrapper scripts instead of direct Cargo commands:

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
```

The wrapper dynamically searches for a loadable `libclang*.dll` in:

```text
%LIBCLANG_PATH%
%MSYS2_ROOT%\mingw64\bin
%MSYS2_ROOT%\ucrt64\bin
%MSYS2_ROOT%\clang64\bin
%MSYS2_ROOT%\usr\bin
C:\Program Files\LLVM\bin
```

It then prepends the selected libclang directory and `%MSYS2_ROOT%\usr\bin` to `PATH` before Cargo starts. This avoids the common `LoadLibraryExW failed` bindgen error.

If MSYS2 is installed somewhere other than `C:\msys64`, set `MSYS2_ROOT` first.

## Direct Cargo commands

If you want to run Cargo directly, dot-source the generated environment first:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo build
cargo check
```

## Build modes

```powershell
scripts\build.bat debug
scripts\build.bat release
scripts\build.bat workspace
scripts\build.bat full
scripts\check.bat fast
scripts\check.bat workspace
```

## What the Windows repair does

`repair-windows.bat` consolidates native build fixes:

- removes stale machine-specific `LIBCLANG_PATH` / `CLANG_PATH` entries from committed Cargo config;
- generates `.cargo/env-windows.ps1` and `.cargo/env-windows.bat` delegators;
- discovers a loadable MSYS2/LLVM libclang at build time;
- removes `tikv-jemalloc-*` from the Windows dependency graph;
- keeps RocksDB jemalloc Linux-only;
- force-includes `<cstdint>` for RocksDB on Windows GNU;
- pins the Move `uint` dependency where needed.

## If bindgen cannot load libclang

Use the wrapper:

```powershell
scripts\build.bat debug
```

If direct Cargo fails, reset and load the environment:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
cargo build
```

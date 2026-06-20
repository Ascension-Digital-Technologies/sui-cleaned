# Windows build notes

Windows GNU builds need MSYS2/MinGW64 available to native build scripts. In particular, `librocksdb-sys` uses bindgen, and bindgen must be able to load `libclang.dll` plus its dependent DLLs.

## Recommended path

Use the wrapper scripts instead of direct Cargo commands:

```powershell
scripts\repair-windows.bat
scripts\build.bat debug
```

The wrapper loads:

```text
C:\msys64\mingw64\bin
C:\msys64\usr\bin
```

onto `PATH` for the Cargo process. This avoids the common `LoadLibraryExW failed` bindgen error.

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

- configures MSYS2/MinGW64 `libclang.dll` for bindgen;
- generates `.cargo/env-windows.ps1` and `.cargo/env-windows.bat`;
- removes `tikv-jemalloc-*` from the Windows dependency graph;
- keeps RocksDB jemalloc Linux-only;
- force-includes `<cstdint>` for RocksDB on Windows GNU;
- pins the Move `uint` dependency where needed.

## If bindgen cannot load libclang

Check the expected files:

```powershell
Test-Path C:\msys64\mingw64\bin\libclang.dll
Test-Path C:\msys64\mingw64\bin\clang.exe
```

If either is missing, install the MSYS2 MinGW64 clang/libclang packages. If both exist but Cargo still fails, make sure you use `scripts\build.bat` or dot-source `.cargo\env-windows.ps1` before running direct Cargo commands.

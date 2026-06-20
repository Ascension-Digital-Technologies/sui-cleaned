# Windows build notes

The fast/default build should work on Windows after the repair pass:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo check
```

The full all-targets compatibility gate is intentionally huge:

```powershell
cargo xtask check-full
```

## What the Windows repair does

`repair-windows.bat` consolidates the old one-off fixes:

- configures MSYS2/MinGW64 `libclang.dll` for bindgen
- removes `tikv-jemalloc-*` from the Windows dependency graph
- keeps RocksDB jemalloc Linux-only
- force-includes `<cstdint>` for RocksDB on Windows GNU
- pins the Move `uint` dependency where needed

## If jemalloc appears again

```powershell
cargo tree -i tikv-jemalloc-sys --target x86_64-pc-windows-gnu
scripts\repair-windows.bat
cargo clean -p librocksdb-sys
cargo clean -p rocksdb
cargo clean -p tikv-jemalloc-sys
cargo check
```

## If bindgen cannot find libclang

Make sure MSYS2 has the mingw64 clang/libclang packages and that this file exists:

```powershell
Test-Path C:\msys64\mingw64\bin\libclang.dll
```

Then run:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
cargo check
```

For a single wrapped check:

```powershell
scripts\check.bat windows
```

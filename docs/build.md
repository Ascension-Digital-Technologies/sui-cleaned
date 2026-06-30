# Build guide

This repo includes thin build wrappers for common local and CI workflows.

## Windows GNU

Use the wrapper scripts because native dependencies such as `librocksdb-sys` use bindgen and need MSYS2/MinGW `libclang.dll` and its dependent DLLs on `PATH`.

One-time setup on a Windows machine with MSYS2 installed:

```powershell
scripts\setup-windows.bat
```

Then build:

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

On Debian/Ubuntu, install native build dependencies first. This provides the system `libclang` required by bindgen and the native libraries used by RocksDB/compression crates.

```bash
scripts/setup-linux.sh
```

Then build:

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

## GitHub Actions native dependencies

The CI workflow installs native dependencies before `cargo check` because `librocksdb-sys` runs bindgen and bindgen requires a system libclang shared library.

Linux installs:

```text
build-essential clang cmake libbz2-dev libclang-dev libsnappy-dev libzstd-dev llvm-dev pkg-config zlib1g-dev
```

Windows installs MSYS2/MinGW packages:

```text
mingw-w64-x86_64-gcc mingw-w64-x86_64-clang mingw-w64-x86_64-llvm mingw-w64-x86_64-pkgconf make diffutils pkgconf
```

The workflow then exports `LIBCLANG_PATH` and updates `PATH` so Linux can load `libclang.so` and Windows can load `libclang.dll`.

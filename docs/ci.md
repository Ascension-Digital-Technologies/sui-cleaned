# CI

This repository uses a small GitHub Actions workflow for layout and default build checks.

## Why CI does not use `--locked`

The cleaned workspace embeds Sui and Move source under a reorganized domain layout. During cleanup passes, Cargo can need to refresh `Cargo.lock` even when no intentional dependency version change was made. For that reason, CI runs:

```bash
cargo check
```

instead of:

```bash
cargo check --locked
```

For release stabilization, run `cargo check` locally and commit any intentional `Cargo.lock` update.

## Local checks

```bash
cargo xtask check-layout
cargo xtask status
scripts/check.sh fast
```

On Windows GNU, run the repair first:

```powershell
scripts\repair-windows.bat
scripts\check.bat fast
```


## Windows native environment

Windows jobs should either use `scripts\build.bat` / `scripts\check.bat` or dot-source `.cargo\env-windows.ps1` before direct Cargo commands. This ensures MSYS2 `mingw64\bin` is on `PATH` so bindgen can load `libclang.dll`.

## Native system dependencies

The CI jobs install native dependencies before Cargo runs. This is required because `librocksdb-sys` uses bindgen, and bindgen needs a system libclang shared library at build time.

### Linux

The Linux job installs clang/libclang and RocksDB-related native build dependencies with apt:

```text
build-essential clang cmake libbz2-dev libclang-dev libsnappy-dev libzstd-dev llvm-dev pkg-config zlib1g-dev
```

It then sets `LIBCLANG_PATH` from `llvm-config --libdir`.

### Windows GNU

The Windows GNU job installs MSYS2/MinGW compiler and libclang packages, searches common MSYS2/LLVM tool directories, adds the selected libclang directory plus `C:\msys64\usr\bin` to PATH, and exports the discovered `LIBCLANG_PATH` before running the Windows repair/build wrappers.

## Native libclang setup

The Linux job installs `clang`, `libclang-dev`, `llvm-dev`, and native compression/build packages before `cargo check`. The Windows GNU job uses MSYS2 and then searches common MSYS2/LLVM directories for `libclang*.dll` and `clang*.exe` instead of assuming `C:\msys64\mingw64\bin\clang.exe` exists.

If Windows CI fails before Cargo with a missing clang path, inspect the `Configure Windows GNU libclang` step. It prints candidate directories and installed clang-related MSYS2 packages.

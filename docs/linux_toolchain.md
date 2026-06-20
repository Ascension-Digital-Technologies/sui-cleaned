# Linux Toolchain

Linux builds need Rust plus native development packages used by RocksDB, bindgen, compression libraries, and C/C++ build scripts.

## Debian/Ubuntu setup

```bash
scripts/setup-linux.sh
```

Equivalent packages:

```bash
sudo apt-get update
sudo apt-get install -y   build-essential   clang   cmake   libbz2-dev   libclang-dev   libsnappy-dev   libzstd-dev   llvm-dev   pkg-config   zlib1g-dev
```

`setup-linux.sh` also writes `.cargo/env-linux.sh` when it can discover `llvm-config`, so local shell scripts can source the correct `LIBCLANG_PATH` and `CLANG_PATH`.

## Build

```bash
scripts/build.sh debug
scripts/check.sh fast
scripts/test.sh fast
```

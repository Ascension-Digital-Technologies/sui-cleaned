# Windows build notes

The fast/default build should work on Windows without jemalloc:

```powershell
cargo check
```

The full upstream parity gate is intentionally huge:

```powershell
cargo check --workspace --all-targets
```

If Cargo tries to build `tikv-jemalloc-sys` on `x86_64-pc-windows-gnu`, run:

```powershell
scripts\repair-windows-jemalloc.bat
cargo clean -p tikv-jemalloc-sys
cargo clean -p tikv-jemallocator
cargo clean -p tikv-jemalloc-ctl
cargo check
```

If it still appears, identify the exact dependency path:

```powershell
scripts\find-jemalloc-dependents.bat
```

`tikv-jemalloc-*` is a Linux allocator/profiling optimization in this cleaned reference repo. It is not required for Windows correctness.

## v9: RocksDB jemalloc on Windows GNU

If `cargo tree -i tikv-jemalloc-sys --target x86_64-pc-windows-gnu` shows:

```text
tikv-jemalloc-sys
`-- librocksdb-sys
    `-- rocksdb
        `-- typed-store
```

then the problem is RocksDB's `features = ["jemalloc"]`, not a direct `tikv-jemalloc-*` dependency. Run:

```powershell
scripts\repair-windows-jemalloc.bat
cargo clean -p librocksdb-sys
cargo clean -p rocksdb
cargo clean -p tikv-jemalloc-sys
cargo check
```

The repair retargets RocksDB's jemalloc feature to Linux only while keeping the normal non-jemalloc RocksDB dependency available on Windows.

## MSYS2 libclang for bindgen

`librocksdb-sys` uses `bindgen`, and `bindgen` needs `libclang.dll`. On Windows GNU, make sure the MSYS2 mingw64 bin directory is visible to the build process.

One-time repair/config check:

```powershell
scripts\repair-windows-bindgen-libclang.bat
```

For direct `cargo` commands in the current PowerShell session:

```powershell
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
cargo check
```

Or use the wrapper for a single check:

```powershell
scripts\check-windows.bat
```

If `libclang.dll` is missing, install the MSYS2 mingw64 clang/libclang packages, then rerun the repair script.

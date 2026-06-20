# Scripts

Scripts are thin wrappers around repo setup, repair, and audit tasks. Prefer `cargo xtask ...` for day-to-day use.

Important scripts:

```text
fetch-upstream-deps.bat/.sh       sync upstream Sui support into crates/
repair-upstream-direct-paths.py   fix direct paths in domain folders under crates//*
repair-upstream-workspace.*       audit/repair synced upstream workspace paths
repair-move-upstream-paths.*      repair Move/external-crate direct paths
repair-windows-jemalloc.py        remove jemalloc from Windows dependency graph
repair-windows-rocksdb-cstdint.*  add Windows GNU RocksDB cstdint workaround
audit-workspace-inheritance.py    ensure synced upstream crates are workspace members
audit-direct-paths.py             ensure direct path dependencies exist
```
## Windows GNU helpers

Use these when native crates such as `librocksdb-sys` need MSYS2/MinGW tools:

```powershell
scripts\repair-windows-bindgen-libclang.bat
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
cargo check
```

Or run the wrapper, which injects MSYS2 `mingw64\bin` and `usr\bin` into `PATH` for that command:

```powershell
scripts\check-windows.bat
```

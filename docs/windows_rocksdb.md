# Windows GNU RocksDB build note

On `x86_64-pc-windows-gnu`, `librocksdb-sys 0.16.0+8.10.0` can fail while compiling
`rocksdb/options/offpeak_time_info.cc` with an error like:

```text
rocksdb/options/offpeak_time_info.h:33:44: error: 'int64_t' does not name a type
```

This is a C++ translation-unit issue in the RocksDB C++ source as built by `cc-rs`:
the header uses `int64_t`, but the compiler path does not include the header that
provides it early enough for MinGW.

The repo config sets target-specific C++ flags for Windows GNU:

```toml
[env]
"CXXFLAGS_x86_64_pc_windows_gnu" = { value = "-include cstdint", force = false }
"CXXFLAGS_x86_64-pc-windows-gnu" = { value = "-include cstdint", force = false }
```

After applying the fix, rebuild RocksDB:

```powershell
cargo clean -p librocksdb-sys
cargo check
```

The RocksDB format warnings on MinGW are noisy but non-fatal; the failure to fix is
the missing `int64_t` type.

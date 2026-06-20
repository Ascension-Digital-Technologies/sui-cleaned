# Troubleshooting

## `Unable to find libclang`

`librocksdb-sys` uses `bindgen`, and `bindgen` needs a system `libclang` shared library at build time.

Linux:

```bash
scripts/setup-linux.sh
scripts/build.sh debug
```

Windows PowerShell:

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
```

If using direct Cargo on Windows, load the environment first:

```powershell
. .\.cargo\env-windows.ps1
cargo build
```

## RocksDB fails on Windows GNU

Run the Windows repair wrapper and rebuild the native crate:

```powershell
scripts\repair-windows.bat
scripts\clean.bat native
scripts\build.bat debug
```

## `Cargo.lock needs to be updated but --locked was passed`

This cleaned workspace may update `Cargo.lock` when package paths or dependency features change. CI intentionally avoids `--locked` until the lockfile is refreshed and committed for a release branch.

To refresh locally:

```bash
cargo check
git status Cargo.lock
```

Commit `Cargo.lock` if the change is intentional.

## First build takes a long time

The workspace includes native dependencies and a large Rust graph. The first build may compile RocksDB, compression libraries, crypto crates, and Move/Sui crates. Later incremental builds are much faster.

## Use scripts instead of raw Cargo for platform setup

Raw Cargo is fine after the platform environment is configured. For fewer native-build surprises, use:

```powershell
scripts\build.bat debug
scripts\check.bat fast
```

or:

```bash
scripts/build.sh debug
scripts/check.sh fast
```

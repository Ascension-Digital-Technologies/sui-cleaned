# Support

This repository is an unofficial cleaned-up Rust workspace for Sui. It is maintained as a source-layout and developer-experience cleanup, not as an official Mysten Labs or Sui Foundation release channel.

## Where to ask questions

- For issues specific to this cleaned repository layout, open a GitHub issue in this repository.
- For upstream Sui protocol behavior, official releases, validators, ecosystem questions, or production network support, use the official Sui resources linked from the upstream repository and documentation.

## Maintainer

Maintainer: **Mario Vinciguerra** (`@mariovinci`)

## Good issue reports include

- Operating system and shell.
- Rust toolchain version.
- The command you ran.
- The first real error message, not only the full dependency build log.
- Whether the issue happens with `cargo check`, `scripts/check.*`, or GitHub Actions.

## Native build notes

This workspace contains Rust crates that build native dependencies such as RocksDB and use `bindgen`, which requires `libclang` at build time. Use the provided setup and build scripts before filing a native-build issue:

```powershell
scripts\setup-windows.bat
scripts\build.bat debug
```

```bash
scripts/setup-linux.sh
scripts/build.sh debug
```

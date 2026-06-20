# Changelog

This project follows a simple, human-readable changelog format for cleanup releases.

## Unreleased

- Continue GitHub polish and documentation cleanup.

## v33

- Fixed Windows `scripts\build.bat` so it actually runs Cargo after repair passes, even when launched from inside the `scripts/` directory.
- Added PowerShell-backed Windows wrappers for build/check/test flows.
- Made Windows Cargo environment loading dynamic for `libclang*.dll` / `clang*.exe`, including `libclang-cpp.dll`.
- Cleaned README and script docs that contained accidental control characters in Windows path examples.

## v32

- Added GitHub `CODEOWNERS` using **Mario Vinciguerra** / `@mariovinci`.
- Added `SUPPORT.md`, `RELEASE.md`, `.gitattributes`, and expanded GitHub-facing documentation.
- Added `scripts/test.*` and `scripts/clean.*` wrapper scripts.
- Added architecture, source-map, troubleshooting, Linux toolchain, official Sui, and release checklist docs.
- Expanded the README with richer upstream Sui context and full build instructions.

## v31 and earlier

- Reorganized the workspace into clean Rust source domains.
- Embedded Sui and Move source needed by the cleaned workspace.
- Removed root `vendor/`, `upstream/`, `manifests/`, `reports/`, and root `xtask/` folders.
- Moved `xtask` under `crates/runtime/xtask`.
- Added Windows GNU repair scripts for RocksDB, bindgen, libclang, and jemalloc-related native build issues.

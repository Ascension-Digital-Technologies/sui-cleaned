# Rust workspace

Use the repository root for Cargo commands.

The workspace is organized by role:

- `crates/<domain>/...` for reusable libraries/runtime packages.
- `domain folders under crates//*` for synced upstream Sui support crates.
- `bench/`, `tests/`, and `tools/` for non-library workspace packages.

Run `cargo xtask status` for a static health check.

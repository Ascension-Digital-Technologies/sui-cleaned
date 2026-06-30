# Rust workspace

Use the repository root for Cargo commands.

The workspace is organized by role:

- `crates/<domain>/...` for reusable libraries/runtime packages.
- `crates/execution/move/language/vm/` for embedded Move VM and Move execution sources.
- `bench/`, `tests/`, and `tools/` for non-library workspace packages.

Run `cargo xtask status` for a static health check.

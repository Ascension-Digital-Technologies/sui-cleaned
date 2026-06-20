# Repo cleanup policy

The cleaned workspace keeps source layout simple:

- `crates/` contains reusable crates and embedded Sui support crates, grouped by domain.
- `bench/`, `tests/`, and `tools/` live at the root.
- `crates/runtime/xtask/` contains repository automation.
- Generated audits and metadata should go under `target/xtask-output/`, not a root `reports/` folder.
- There is no root `vendor/`, `upstream/`, `manifests/`, `reports/`, or root `xtask/` directory.

Embedded Sui-compatible source is distributed into the domain layout. Avoid broad reshuffles without updating Cargo paths and layout docs.

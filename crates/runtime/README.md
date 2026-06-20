# crates/runtime

Node, CLI, service, simulator, telemetry, metrics, common, futures, and version crates.

## Rules

- Keep reusable Rust source in this domain.
- Do not put benchmarks, standalone integration tests, or developer tools here; use root `bench/`, `tests/`, and `tools/`.
- Keep upstream compatibility crates in the domain that best matches their purpose.
- Run `cargo xtask check-layout` after moving packages.
- Run `cargo xtask check-domain runtime` to check this domain only.

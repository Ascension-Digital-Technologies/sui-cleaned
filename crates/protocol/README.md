# crates/protocol

Protocol types, JSON-RPC types, transaction checks/builders, bridge/name/display/cost helpers, and macros.

## Rules

- Keep reusable Rust source in this domain.
- Do not put benchmarks, standalone integration tests, or developer tools here; use root `bench/`, `tests/`, and `tools/`.
- Keep upstream compatibility crates in the domain that best matches their purpose.
- Run `cargo xtask check-layout` after moving packages.
- Run `cargo xtask check-domain protocol` to check this domain only.

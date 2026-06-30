# Crates

This is the canonical Rust package root for the cleaned Sui reference workspace.

The layout is domain-first and subsystem-first. Rust package names stay
Cargo-compatible; the source is treated as owned and only folders plus Cargo path references were reorganized.

```text
crates/
  api/          public API surfaces, RPC, clients, indexers, ingestion, services
  core/         reusable foundation crates shared across the workspace
  config/       node, consensus, protocol, and runtime configuration packages
  consensus/    consensus engine implementation
  crypto/       identity, TLS, signing, and crypto primitives
  execution/    authority execution, Move tooling, framework, packages, validation
  network/      transport, edge proxying, authority aggregation
  protocol/     bridge, economics, naming, transactions, rendering, codegen
  metrics/      metrics, telemetry, indexer metrics, observability tools
  runtime/      executable app/node crates and simulation harnesses
  storage/      stores, snapshots, indexer storage, SQL, typed-store, search
  types/        shared Sui, consensus, RPC, compatibility, and reflection types
```

Root-level operational package areas remain outside `crates/`:

```text
bench/      benchmark and load-generation crates
tests/      standalone integration, fuzz, transactional, compatibility crates
tools/      operator and developer CLIs
```

Keep `crates/` focused on reusable first-party packages. Put binaries, repo
maintenance tools, and end-to-end harnesses under `tools/`, `tests/`, or
`bench/` unless they are actual reusable runtime crates.

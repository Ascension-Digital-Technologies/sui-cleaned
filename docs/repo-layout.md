# Repository Layout

This repository uses an owned, domain-first layout. Source is not separated into vendor or third-party buckets; every crate in this tree is treated as part of the maintained codebase.

## Main crate domains

```text
crates/
  api/        external-facing APIs, RPC surfaces, clients, ingestion, services
  core/       low-level shared utilities that should remain dependency-light
  config/     protocol, node, consensus, and default runtime configuration
  consensus/  consensus engine and consensus-owned logic
  crypto/     keys, signatures, shared crypto, transport crypto
  execution/  authority, Move, Sui execution, frameworks, packages, validation
  network/    transport, peer/network services, edge/proxy support
  protocol/   transaction, bridge, economics, naming, rendering, codegen rules
  metrics/    metrics, telemetry, push clients, metric tooling
  runtime/    runnable apps, node binaries, CLI, simulators
  storage/    stores, snapshots, indexing storage, typed/sql/key-value layers
  types/      shared Sui/RPC/consensus/reflection/compatibility types
```

## Owned Move layout

Move is organized as owned source under `crates/execution/move/`. The language/runtime source lives under `crates/execution/move/language/` and is split by subsystem instead of being kept as a flat `crates/*` dump.

```text
crates/execution/move/
  tools/       Sui-specific Move build/lsp/cli integration
  language/
    api/
    benchmarks/
    compiler/
    core/
    fuzz/
    packages/
    stdlib/
    testing/
    tools/
    verifier/
    vm/
    versions/
```

## Tooling, tests, and bench layout

```text
tools/
  dev/
  execution/
  network/
  packages/

tests/
  api/
  consensus/
  execution/
  fixtures/
  fuzz/
  runtime/

bench/
  api/
  network/
  runtime/
```

## Maintenance rules

- Do not add new crates directly under `crates/`; choose a domain.
- Do not add `vendor/`, `third-party/`, or `external/` buckets for owned source.
- Avoid folders named only `crates` beneath domain folders. Use subsystem names instead.
- Keep package names stable unless a real Rust crate rename is intended.
- When moving a crate, update workspace members and local Cargo path dependencies.

## Polish pass: redundant wrapper flattening

The layout intentionally avoids empty one-crate wrappers. If a domain contains a single primary crate, that crate may live directly at the domain root, for example:

```text
crates/consensus/
crates/metrics/
crates/storage/
crates/protocol/bridge/
```

Use extra folders only when they group multiple sibling crates or carry real architectural meaning.


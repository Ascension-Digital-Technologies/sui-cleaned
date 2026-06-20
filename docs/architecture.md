# Architecture and Repository Layout

Sui Clean is organized as a domain-oriented Rust workspace. The goal is to make Sui source easier to navigate without changing the conceptual boundaries of the upstream system.

## Domain layout

```text
crates/
  api/        public APIs, RPC, SDK, faucet, Rosetta, indexers, ingestion services
  crypto/     keys, signatures, TLS, shared crypto wrappers
  config/     protocol and consensus configuration, defaults, config macros
  runtime/    CLI, node runtime, services, simulator, telemetry, metrics, common utilities, xtask
  consensus/  consensus core and consensus types
  execution/  authority core, framework, Move build/CLI, package resolution, Sui execution, Move VM
  network/    network clients, authority aggregation, HTTP, proxy, transport support
  protocol/   Sui types, protocol macros, bridge/display/name-service helpers
  storage/    typed-store, RocksDB-backed storage, snapshots, indexer schemas/stores, SQL helpers
```

Root work areas:

```text
bench/      benchmark and load-generation crates
tests/      integration, transactional, fuzz, and fixture crates
tools/      developer and operator tools
scripts/    human-facing workflow wrappers
docs/       human-maintained documentation
```

## Design rules

- Keep reusable Rust library/runtime code under `crates/`.
- Keep benchmarks, tests, and developer tools at the root.
- Keep `crates/` limited to the approved domain names.
- Keep `xtask` under `crates/runtime/xtask` because it is repository runtime tooling.
- Do not reintroduce root `vendor/`, `upstream/`, `manifests/`, or `reports/` folders.
- Generated output belongs under `target/`.

## Why this helps

The upstream Sui repository is a large production monorepo. This cleaned workspace keeps the code recognizable while grouping it by engineering domain so new readers can quickly locate API, execution, network, storage, protocol, and runtime code.

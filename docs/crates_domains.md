# Crate domains

The cleaned workspace keeps `crates/` limited to twelve top-level source domains.

```text
crates/
  api/
  core/
  config/
  consensus/
  crypto/
  execution/
  metrics/
  network/
  protocol/
  runtime/
  storage/
  types/
```

## Domain ownership

| Domain | Belongs here |
|---|---|
| `api` | RPC, SDK, indexers, faucet, Rosetta, ingestion APIs, and external service surfaces |
| `core` | dependency-light shared utilities and foundational helpers |
| `config` | protocol config, node config, consensus config, defaults, and config macros |
| `consensus` | consensus engine, consensus-owned logic, and consensus-specific support |
| `crypto` | keys, signatures, TLS, shared crypto, and crypto helpers |
| `execution` | authority core, framework, Sui execution, package resolution, Move integration, Move VM |
| `metrics` | metrics, telemetry, observability, monitoring, and metric push/export helpers |
| `network` | networking primitives, authority aggregation, HTTP, proxy, and network services |
| `protocol` | transaction checks/builders, bridge, economics, display, name service, and protocol rules |
| `runtime` | runnable apps, node/CLI entrypoints, simulator, service glue, and `xtask` |
| `storage` | typed-store, data stores, snapshots, indexer stores/schemas, SQL helpers |
| `types` | shared Sui/RPC/consensus/reflection types and schema/model crates |

## Rules

- Do not add new top-level folders under `crates/` without updating `scripts/check-layout.py`, `cargo xtask check-layout`, and this document.
- Keep `bench/`, `tests/`, and `tools/` at the repository root.
- Keep Move language/runtime sources under `crates/execution/move/language/`.
- Do not recreate root `vendor/`, `third-party/`, `external/`, `upstream/`, `manifests/`, or `reports/` buckets.
- Avoid empty wrapper folders. A folder should group multiple crates or have real architectural meaning.

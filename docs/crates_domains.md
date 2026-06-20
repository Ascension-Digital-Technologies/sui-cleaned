# Crate domains

The cleaned Sui workspace keeps `crates/` limited to nine top-level source domains.

```text
crates/
  api/
  crypto/
  config/
  runtime/
  consensus/
  execution/
  network/
  protocol/
  storage/
```

## Domain ownership

| Domain | Belongs here |
|---|---|
| `api` | RPC, SDK, indexers, faucet, Rosetta, ingestion APIs |
| `crypto` | keys, TLS, shared crypto, crypto helpers |
| `config` | protocol config, consensus config, defaults, config macros |
| `runtime` | node, CLI, simulator, telemetry, metrics, service glue, common runtime helpers |
| `consensus` | consensus core, consensus types, sim-facing consensus code |
| `execution` | authority core, framework, Sui execution, package resolution, Move build/CLI, Move VM |
| `network` | networking primitives, authority aggregation, HTTP, proxy, network services |
| `protocol` | Sui types, transaction checks/builders, bridge, display, name service, macro utilities |
| `storage` | typed-store, data stores, snapshots, indexer stores/schemas, SQL helpers |

## Rules

- Do not add new top-level folders under `crates/` without updating `xtask check-layout` and this document.
- Keep `bench/`, `tests/`, and `tools/` at the repository root.
- Keep Move VM sources under `crates/execution/move-vm/`.
- Do not recreate `crates/runtime/sui/`, root `vendor/`, root `upstream/`, or root `manifests/`.

# Sui Repo Cleanup Strategy

## Goal

Create a clean, professional Sui reference tree that is useful for a low-level C port without carrying all monorepo clutter into the implementation.

This is not a rewrite of Sui. It is a curated extraction:

- Keep protocol-critical source.
- Keep exact behavior references.
- Keep tests, fixtures, fuzzer inputs, replay tools, and benchmarks that matter.
- Move product/UI/indexer/ecosystem code out of the main path.
- Preserve attribution and license files.

## Output layout

```text
sui-reference-clean/
  protocol/              # Sui canonical types/config/transaction surfaces
  crypto/                # shared crypto/key/signature references
  consensus/             # consensus config/core/types/simtests
  execution/             # authority core, Sui execution, framework, natives
  storage/               # object/checkpoint/storage/typed-store references
  network/            # validator/fullnode network reference
  api/                   # RPC/json-rpc/light-client surfaces
  tools/                 # genesis/replay/swarm/test-validator tools
  tests/                 # e2e, differential, fuzz, consensus/execution fixtures
  bench/                 # performance baselines
  docs/                  # generated cleanup reports and mapping docs
  _manifest/             # copied/missing path reports
```

## Cleanup model

The first pass is deliberately conservative:

1. Copy selected upstream paths.
2. Generate a manifest of copied and missing paths.
3. Generate inventory and extension statistics.
4. Leave imports unchanged.
5. Use the cleaned tree as a reading/reference tree, not a directly buildable fork yet.

A buildable fork is phase two. A C port is a separate phase.

## Why this is better

The upstream repo is a large Rust workspace. The root `Cargo.toml` contains many workspace members across consensus, Sui crates, indexers, RPC, benchmarks, tests, Move execution, and other supporting packages. The clean tree turns that into an intentional protocol/runtime reference map.

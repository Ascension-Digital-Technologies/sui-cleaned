# Source Map

This map explains how major Sui source areas are represented in the cleaned workspace.

| Upstream-style area | Cleaned location |
|---|---|
| CLI package (`sui`) | `crates/runtime/cli` |
| Node runtime (`sui-node`) | `crates/runtime/node` |
| Simulator packages | `crates/runtime/simulator` |
| Common Mysten utilities | `crates/runtime/common` |
| Metrics and telemetry | `crates/runtime/metrics`, `crates/runtime/telemetry` |
| Sui JSON/RPC/API packages | `crates/api/*` |
| SDK and client-facing crates | `crates/api/sdk`, `crates/api/*` |
| Sui configuration | `crates/config/*` |
| Consensus packages | `crates/consensus/*` and `crates/config/consensus` |
| Sui execution/authority core | `crates/execution/*` |
| Move VM and Move crates | `crates/execution/move-vm` |
| Networking and HTTP support | `crates/network/*` |
| Protocol types/macros/display/bridge | `crates/protocol/*` |
| Typed store and RocksDB storage | `crates/storage/*` |
| Benchmarks | `bench/*` |
| Integration/fuzz/transactional tests | `tests/*` |
| Developer/operator tools | `tools/*` |

This repository is self-contained. The Sui and Move source needed by the workspace is embedded directly into this cleaned layout.

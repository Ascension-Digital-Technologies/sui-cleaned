# Workspace Build Tiers

The repo intentionally separates daily work from full upstream parity.

| Tier | Command | Scope | Expected use |
| --- | --- | --- | --- |
| Fast | `cargo xtask check-fast` | `workspace.default-members` only | normal edit/build loop |
| Core | `cargo xtask check-core` | explicit first-party consensus, crypto, protocol, storage, network crates | core cleanup and refactor validation |
| Workspace | `cargo xtask check-workspace` | every active package, normal lib/bin targets only | broad repo validation |
| Sui compatibility | `cargo xtask check-sui-compat` | protocol/execution compatibility packages | upstream parity work without the full blast radius |
| Full | `cargo xtask check-full` | `--workspace --all-targets` | slow upstream parity gate |

Do not use the full tier as the default development loop. It can compile thousands of
crates because upstream test, bench, fuzz, tool, and service targets become reachable.

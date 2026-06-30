# Project identity

Sui Clean is an unofficial cleaned-up Rust workspace for Sui. The official Sui repository is maintained at <https://github.com/MystenLabs/sui>.

The official Sui project describes Sui as a smart contract platform focused on high throughput, low latency, and an asset-oriented programming model powered by Move. This repository keeps that Sui-compatible Rust/Move source material but reorganizes it into clearer source domains.

## What this repo is

- A cleaned-up Sui repository layout.
- A Rust workspace organized by source ownership and runtime role.
- A local development and audit-friendly reference tree.
- A self-contained repo with embedded Sui and Move source code placed into domain folders.

## What this repo is not

- It is not an official Mysten Labs repository.
- It is not an official Sui Foundation repository.
- It is not a new blockchain or fork brand by itself.
- It is not intended to hide upstream package identity where Cargo compatibility requires it.

## Domain layout

```text
api, core, config, consensus, crypto, execution, metrics, network, protocol, runtime, storage, types
```

## Naming policy

Public-facing docs should describe this as a cleaned-up Sui workspace or cleaned-up Sui repository.

Cargo package names may remain upstream-compatible. Folder names should be cleaner and domain-based.

## Attribution

Upstream license and attribution are preserved through `LICENSE`, `NOTICE`, and `docs/license_attribution.md`.

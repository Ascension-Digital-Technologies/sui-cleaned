# Project identity

Sui Clean is an unofficial cleaned-up Rust workspace for Sui.

It exists to make a Sui-compatible Rust codebase easier to understand and maintain by reorganizing crates into explicit domains:

```text
api, crypto, config, runtime, consensus, execution, network, protocol, storage
```

## What this repo is

- A cleaned-up Sui repository layout.
- A Rust workspace organized by source ownership and runtime role.
- A local development and audit-friendly reference tree.
- A repo with embedded upstream Sui/Move code placed into domain folders.

## What this repo is not

- It is not an official Mysten Labs repository.
- It is not an official Sui Foundation repository.
- It is not a new blockchain or fork brand by itself.
- It is not intended to hide upstream package identity where Cargo compatibility requires it.

## Naming policy

Public-facing docs should describe this as a cleaned-up Sui workspace or cleaned-up Sui repository.

Cargo package names may remain upstream-compatible. Folder names should be cleaner and domain-based.

## Attribution

Upstream license and attribution are preserved through `LICENSE`, `NOTICE`, and `docs/license_attribution.md`.

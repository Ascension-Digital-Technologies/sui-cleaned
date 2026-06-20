# Sui Cleaned

**Sui-Cleaned** is an unofficial, cleaned-up Rust workspace for [Sui](https://github.com/MystenLabs/sui).

This repository keeps the Sui codebase recognizable and Cargo-compatible while presenting it in a cleaner, domain-oriented layout. It is meant to be easier to browse, build, audit, and maintain than a large historical monorepo tree.

> This project is not an official Mysten Labs or Sui Foundation repository. It is an unofficial cleaned-up layout derived from Sui-compatible source code. Upstream package identity, license notices, and attribution are preserved where needed.

## Official upstream

The official Sui repository is maintained by Mysten Labs:

- Official Sui repository: <https://github.com/MystenLabs/sui>
- Sui website: <https://sui.io>
- Sui documentation: <https://docs.sui.io>

## What is Sui?

Sui is a smart contract platform built around high throughput, low latency, and an asset-oriented programming model powered by the Move programming language. The official Sui README describes Sui as a next-generation smart contract platform written in Rust, with Move smart contracts used to define assets and the rules for creating, transferring, and mutating them.

Sui is designed around a permissionless set of authorities, similar in role to validators or miners in other blockchain systems. Its architecture is built to process many common transactions in parallel, making better use of hardware resources. For simple common use cases such as payments and asset transfers, Sui can use lower-latency primitives instead of forcing every transaction through the same consensus path.

At a high level, Sui focuses on:

- high throughput and low latency;
- an asset-oriented object model;
- Move-based smart contracts;
- rich and composable on-chain assets;
- improved user experience for web3 applications;
- parallel processing for many independent transactions;
- a native SUI token used for gas and delegated stake.

This repository does not change Sui's protocol goals. It only reorganizes the Rust workspace so the source tree is easier to understand.

## Why this cleanup exists

Large blockchain repositories tend to grow around teams, release machinery, generated code, experiments, and historical layout decisions. That can make the source tree difficult to understand even when the code itself is valuable.

Sui Clean keeps the useful Rust code and reshapes the workspace around clear ownership boundaries:

```text
crates/
  api/        RPC, SDK, indexer-facing, faucet, Rosetta, ingestion, and service APIs
  crypto/     keys, signatures, TLS, shared crypto helpers
  config/     protocol, consensus, defaults, and config macros
  runtime/    node, CLI, simulator, telemetry, metrics, service glue, common utilities, xtask
  consensus/  consensus core and consensus types
  execution/  authority core, framework, Move build/CLI, package resolution, Sui execution, Move VM
  network/    network clients, authority aggregation, HTTP, proxy, networking primitives
  protocol/   Sui types, transaction checks/builders, display, bridge, macro utilities
  storage/    stores, typed-store, snapshots, indexer schemas/stores, SQL helpers
```

Root-level supporting crates stay outside `crates/`:

```text
bench/      benchmark and load-generation crates
tests/      integration, transactional, fuzz, and fixture crates
tools/      operational and developer tool crates
scripts/    small wrapper scripts for common workflows
docs/       human-maintained documentation
```

There is no root `vendor/`, `upstream/`, `manifests/`, `reports/`, or root-level `xtask/` folder. The Sui and Move sources needed by this workspace are embedded directly into the cleaned domain layout.

## Current status

The current baseline has been validated locally on Windows with:

```powershell
cargo check
```

The default check focuses on the active workspace. Full all-target checks are intentionally separate because they are much larger.

## Quick start

### Windows PowerShell

```powershell
git clone <your-repo-url> sui-clean
cd sui-clean

scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo xtask check-layout
cargo check
```

### Linux/macOS

```bash
git clone <your-repo-url> sui-clean
cd sui-clean

cargo xtask check-layout
cargo check
```

## Common commands

```powershell
cargo xtask status              # repo status summary
cargo xtask tree                # print the cleaned tree
cargo xtask domains             # list crate domains
cargo xtask check-layout        # enforce top-level layout rules
cargo xtask check-domain runtime
cargo xtask check-domain execution
cargo xtask repair-windows      # run Windows native-build repairs
cargo xtask check-fast          # daily check
cargo xtask check-workspace     # broader workspace check
cargo xtask check-full          # huge all-targets gate
```

## Repository rules

The `crates/` folder is limited to these domains only:

```text
api, crypto, config, runtime, consensus, execution, network, protocol, storage
```

`bench/`, `tests/`, and `tools/` stay at the repository root. They should not be placed under `crates/`.

`crates/runtime/xtask/` contains the repository automation crate used by `cargo xtask`.

`crates/execution/move-vm/` is the canonical location for embedded Move VM and Move execution sources.


## Cargo.lock and CI

The GitHub workflow runs `cargo check` without `--locked`. This is intentional for this cleaned workspace because large source-layout moves can make the checked-in `Cargo.lock` stale even when the Rust source is otherwise valid. For release branches, run:

```powershell
cargo check
git status Cargo.lock
```

If `Cargo.lock` changed because of a real dependency graph update, commit it with the cleanup.

## Documentation

Start here:

- [`docs/project_identity.md`](docs/project_identity.md) — what this repo is and is not
- [`docs/root_layout.md`](docs/root_layout.md) — root-level structure
- [`docs/crates_domains.md`](docs/crates_domains.md) — domain layout rules
- [`docs/domain_commands.md`](docs/domain_commands.md) — `xtask` domain commands
- [`docs/embedded_sources.md`](docs/embedded_sources.md) — embedded Sui/Move source placement
- [`docs/windows_build.md`](docs/windows_build.md) — Windows build notes
- [`docs/github.md`](docs/github.md) — GitHub workflow and contribution expectations
- [`docs/ci.md`](docs/ci.md) — CI and Cargo.lock behavior
- [`docs/license_attribution.md`](docs/license_attribution.md) — upstream license/attribution notes

## Relationship to upstream Sui

Sui Clean is a cleaned-up, domain-organized Sui workspace. It preserves upstream package names where needed for Cargo compatibility, but folder names and domain placement are intentionally clearer than the original source layout.

This repository is self-contained. It does not include sync scripts or automatic upstream refresh tooling. Future source refreshes should be handled deliberately in a separate maintenance branch and reviewed like a normal code import.

## Scripts

The top-level `scripts/` folder is intentionally small:

```text
check.*           build tier wrapper
fmt.*             cargo fmt wrapper
status.*          cargo xtask status wrapper
repair-windows.* Windows GNU native-build repair wrapper
```

Implementation helpers live under `scripts/lib/`.

## License and attribution

This repository keeps Apache-2.0 licensing and upstream attribution. See [`LICENSE`](LICENSE), [`NOTICE`](NOTICE), and [`docs/license_attribution.md`](docs/license_attribution.md).

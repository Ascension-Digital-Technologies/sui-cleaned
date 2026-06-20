# Sui Clean

**Sui Clean** is an unofficial, cleaned-up Rust workspace for Sui.

The goal of this repository is simple: keep the Sui codebase recognizable and compatible while making the repository easier to navigate, build, audit, and maintain. Instead of mirroring the original monorepo shape, this repo organizes Rust crates by domain.

> This project is not an official Mysten Labs or Sui Foundation repository. It is a cleaned-up repository layout derived from Sui-compatible source code and keeps upstream license attribution intact.

## Why this exists

Large blockchain repositories tend to grow around teams, history, generated code, experiments, and release machinery. That can make the source tree difficult to understand. Sui Clean keeps the useful Rust code, but reshapes the workspace around clear ownership boundaries:

```text
crates/
  api/        RPC, SDK, indexer-facing, faucet, Rosetta, ingestion, and service APIs
  crypto/     keys, signatures, TLS, shared crypto helpers
  config/     protocol, consensus, defaults, and config macros
  runtime/    node, CLI, simulator, telemetry, metrics, service glue, common runtime utilities
  consensus/  consensus core and consensus types
  execution/  authority core, framework, Move build/CLI, package resolution, Sui execution, Move VM
  network/    network clients, authority aggregation, HTTP, proxy, networking primitives
  protocol/   Sui types, transaction checks/builders, display, bridge, macro utilities
  storage/    stores, typed-store, snapshots, indexer schemas/stores, SQL helpers
```

Root-level supporting crates are intentionally separated:

```text
bench/      benchmark and load-generation crates
tests/      integration, transactional, fuzz, and fixture crates
tools/      operational and developer tool crates
xtask/      Rust repository automation
scripts/    thin wrapper scripts for Windows/Linux workflows
docs/       human-maintained documentation
reports/    generated cleanup and validation reports
```

There is no root `vendor/`, `upstream/`, or `manifests/` folder. Upstream Sui and Move code that this workspace needs is embedded directly into the domain layout.

## Current status

The current GitHub-ready baseline has been validated locally on Windows with:

```powershell
cargo check
```

The default check focuses on the active core workspace. Full upstream parity checks are intentionally separate because they are much larger.

## Quick start

### Windows PowerShell

```powershell
git clone <your-repo-url> sui-clean
cd sui-clean

scripts\repair-windows.bat
cargo xtask check-layout
cargo check
```

If RocksDB/bindgen reports a missing `libclang.dll`, run:

```powershell
scripts\repair-windows-bindgen-libclang.bat
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
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

`crates/execution/move-vm/` is the canonical location for embedded Move VM and Move execution sources.

## Documentation

Start here:

- [`docs/project_identity.md`](docs/project_identity.md) — what this repo is and is not
- [`docs/root_layout.md`](docs/root_layout.md) — root-level structure
- [`docs/crates_domains.md`](docs/crates_domains.md) — domain layout rules
- [`docs/domain_commands.md`](docs/domain_commands.md) — `xtask` domain commands
- [`docs/windows_build.md`](docs/windows_build.md) — Windows build notes
- [`docs/github.md`](docs/github.md) — GitHub workflow and contribution expectations
- [`docs/license_attribution.md`](docs/license_attribution.md) — upstream license/attribution notes

## Upstream relationship

Sui Clean is designed as a cleaned-up, domain-organized Sui workspace. It preserves upstream package identities where needed for Cargo compatibility, but folder names and domain placement are intentionally cleaner than the original source layout.

When syncing from a newer Sui checkout, use the sync/repair scripts and then validate with:

```powershell
cargo xtask check-layout
cargo xtask status
cargo check
```

## License

This repository keeps Apache-2.0 licensing and upstream attribution. See [`LICENSE`](LICENSE), [`NOTICE`](NOTICE), and [`docs/license_attribution.md`](docs/license_attribution.md).

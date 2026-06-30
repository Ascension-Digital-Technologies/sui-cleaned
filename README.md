# Sui Clean

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-1.92%2B-orange.svg)](rust-toolchain.toml)

**Sui Clean** is an unofficial, domain-organized Rust workspace for Sui-compatible source code. It keeps upstream attribution and compatibility while making the repository easier to navigate, build, audit, and maintain.

> **Important:** This is not an official Mysten Labs, Sui Foundation, or Sui Network repository. Use official upstream channels for production validator releases, security disclosures, and protocol decisions.

## What this repository is for

- A cleaner source layout for studying, building, and maintaining Sui-compatible Rust code.
- A GitHub-ready workspace with CI, issue templates, contribution docs, and Windows/Linux build wrappers.
- A domain-first structure that keeps large subsystems discoverable without hiding Cargo package compatibility.

## Current status

The repository has been validated locally with `cargo build -p sui-node` after the clean-zip fixes for `toml_edit` compatibility and Git-revision fallback behavior. The most recent uploaded build log shows the project progressing through the main Sui node dependency graph after those fixes. See the release checklist before publishing a GitHub tag.

## Repository layout

```text
crates/
  api/        RPC, SDK, indexer-facing, faucet, Rosetta, ingestion, and service APIs
  config/     protocol, node, consensus, and default runtime configuration
  consensus/  consensus engine and consensus-owned logic
  core/       low-level shared utilities and foundations
  crypto/     keys, signatures, TLS, and shared crypto helpers
  execution/  authority, Move, Sui execution, frameworks, packages, and validation
  metrics/    telemetry, observability, metrics, and monitoring helpers
  network/    transport, peer/network services, authority aggregation, HTTP, and proxy support
  protocol/   transactions, bridge, economics, naming, rendering, and protocol rules
  runtime/    runnable apps, node binaries, CLI, simulators, and xtask
  storage/    stores, snapshots, indexing storage, typed/sql/key-value layers
  types/      shared data types, schema surfaces, and protocol-facing models

bench/        benchmark and load-generation crates
tests/        integration, transactional, fuzz, and fixture crates
tools/        operational and developer tool crates
scripts/      public workflow wrappers plus private helpers
docs/         human-maintained documentation
```

There is no root `vendor/`, `third-party/`, `external/`, `upstream/`, `manifests/`, `reports/`, or root-level `xtask/` folder. Sui and Move sources required by this workspace are represented inside the cleaned domain layout.

## Move layout

Move source is owned under `crates/execution/move/` and split by subsystem instead of living in a nested source dump.

```text
crates/execution/move/
  tools/       Sui-specific Move build/lsp/cli integration
  language/
    api/
    benchmarks/
    compiler/
    core/
    documentation/
    fuzz/
    packages/
    stdlib/
    testing/
    tools/
    verifier/
    vm/
    versions/
```

## Quick start

### Windows GNU/MSYS2

Use the wrappers instead of raw Cargo. They locate a loadable `libclang*.dll`, update `PATH`, apply the Windows GNU RocksDB include fix, and then run Cargo.

```powershell
scripts\setup-windows.bat     # one-time dependency setup if MSYS2 packages are missing
scripts\repair-windows.bat    # refresh .cargo/env-windows.*
scripts\build.bat debug
scripts\check.bat fast
```

For direct Cargo commands on Windows GNU, load the generated environment first:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo build -p sui-node
```

If MSYS2 is not installed at `C:\msys64`, set `MSYS2_ROOT` before running the scripts.

### Linux/macOS

```bash
scripts/setup-linux.sh
scripts/build.sh debug
scripts/check.sh fast
```

## Build and check modes

| Command | Purpose |
|---|---|
| `scripts/build.bat debug` / `scripts/build.sh debug` | Default development build. |
| `scripts/build.bat release` / `scripts/build.sh release` | Optimized release build. |
| `scripts/build.bat workspace` / `scripts/build.sh workspace` | Build all active workspace members. |
| `scripts/build.bat full` / `scripts/build.sh full` | Build workspace all-targets; expensive. |
| `scripts/check.bat fast` / `scripts/check.sh fast` | Fast default check through `xtask`. |
| `scripts/check.bat workspace` / `scripts/check.sh workspace` | Workspace-level check. |
| `scripts/check.bat full` / `scripts/check.sh full` | Full all-targets check; expensive. |

## Repository validation

Run these before pushing major layout or dependency changes:

```bash
python scripts/check-layout.py
python scripts/lib/audit-direct-paths.py
python scripts/lib/audit-workspace-inheritance.py
python scripts/lib/audit-crates-domains.py
```

When Rust/Cargo are available:

```bash
cargo xtask status
cargo xtask check-layout
cargo xtask tree
cargo xtask domains
cargo xtask check-fast
```

## Documentation

Start here:

- [`docs/build.md`](docs/build.md) — local build guide
- [`docs/windows_build.md`](docs/windows_build.md) — Windows-specific build notes
- [`docs/repo-layout.md`](docs/repo-layout.md) — current domain-first layout
- [`docs/crate-boundaries.md`](docs/crate-boundaries.md) — dependency boundary rules
- [`docs/github.md`](docs/github.md) — GitHub repository setup notes
- [`docs/github_upload.md`](docs/github_upload.md) — upload/readiness checklist
- [`docs/release.md`](docs/release.md) — release checklist
- [`docs/license_attribution.md`](docs/license_attribution.md) — license and attribution notes

## Contributing

Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening issues or pull requests. Keep cleanup changes separate from behavioral changes whenever possible, and include the commands you ran in each PR.

## Security

This repository is not the official security-reporting channel for upstream Sui. See [`SECURITY.md`](SECURITY.md) for what should be reported here versus upstream.

## License and attribution

This repository preserves Apache-2.0 licensing and upstream attribution. See [`LICENSE`](LICENSE), [`NOTICE`](NOTICE), and [`docs/license_attribution.md`](docs/license_attribution.md).

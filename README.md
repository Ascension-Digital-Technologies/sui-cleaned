# Sui Clean

**Sui Clean** is an unofficial, cleaned-up Rust workspace for [Sui](https://github.com/MystenLabs/sui). It keeps Sui source recognizable and Cargo-compatible while presenting the code in a cleaner, domain-oriented layout for browsing, building, auditing, and development.

> This project is **not** an official Mysten Labs or Sui Foundation repository. It is an unofficial cleaned-up layout derived from Sui-compatible source code. Upstream package identity, license notices, and attribution are preserved where needed.

## Official upstream

The official Sui repository is maintained by Mysten Labs:

- Official Sui repository: <https://github.com/MystenLabs/sui>
- Sui website: <https://sui.io>
- Sui documentation: <https://docs.sui.io>

## What is Sui?

The official Sui README describes Sui as a next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language.

Sui is written in Rust and supports smart contracts written in Move. Move programs define assets and the rules for creating, transferring, and mutating those assets. Sui is maintained by a permissionless set of authorities, similar in role to validators or miners in other blockchain systems.

A major Sui design goal is parallel transaction processing. Many common transactions can be processed independently, which lets the system make better use of available hardware resources. For common payments and asset transfers, Sui can use lower-latency primitives instead of sending every transaction through a single uniform consensus path.

Sui uses the native SUI token for gas and delegated stake. Authority voting power within an epoch is based on delegated stake, and authorities are periodically reconfigured. The official README also highlights Sui's focus on rich composable on-chain assets, instant settlement for many common operations, and better user experience for web3 applications.

## What this repository changes

This repository does **not** redefine Sui's protocol, token model, or production release process. It is a source-layout cleanup that makes the Rust workspace easier to understand.

The cleanup focuses on:

- domain-oriented crate placement;
- fewer generated or historical root folders;
- embedded Sui and Move source needed by the workspace;
- platform-aware build scripts;
- GitHub-ready documentation and workflow files;
- clear attribution back to the official Sui repository.

## Repository layout

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

bench/      benchmark and load-generation crates
tests/      integration, transactional, fuzz, and fixture crates
tools/      operational and developer tool crates
scripts/    small wrapper scripts for common workflows
docs/       human-maintained documentation
```

There is no root `vendor/`, `upstream/`, `manifests/`, `reports/`, or root-level `xtask/` folder. Repository automation lives at `crates/runtime/xtask`, and generated output belongs under `target/`.

## Quick start

### Windows PowerShell

```powershell
git clone <your-repo-url> sui-clean
cd sui-clean

scripts\setup-windows.bat
scripts\build.bat debug
```

For a fast validation pass:

```powershell
scripts\check.bat fast
```

For tests without running all test binaries:

```powershell
scripts\test.bat fast
```

### Linux/macOS

```bash
git clone <your-repo-url> sui-clean
cd sui-clean

scripts/setup-linux.sh
scripts/build.sh debug
```

For a fast validation pass:

```bash
scripts/check.sh fast
```

For tests without running all test binaries:

```bash
scripts/test.sh fast
```

## Build scripts

Use the scripts instead of raw Cargo commands when building on Windows GNU. The scripts load MSYS2/MinGW64 and libclang into the process environment so native dependencies such as RocksDB can build correctly. You can run them from the repository root or from inside `scripts/`; they resolve the repo root automatically.

| Command | Purpose |
|---|---|
| `scripts\setup-windows.bat` | Install/prepare Windows native build dependencies and generate `.cargo\env-windows.ps1`. |
| `scripts\build.bat debug` | Debug build with Windows native environment loaded. |
| `scripts\build.bat release` | Optimized release build. |
| `scripts\check.bat fast` | Daily fast check. |
| `scripts\test.bat fast` | Compile tests without running every test binary. |
| `scripts\clean.bat native` | Clean native RocksDB/jemalloc-related packages. |
| `scripts/setup-linux.sh` | Install Linux native build dependencies. |
| `scripts/build.sh debug` | Debug build on Unix shells. |
| `scripts/check.sh fast` | Daily fast check on Unix shells. |
| `scripts/test.sh fast` | Compile tests on Unix shells. |

Build modes:

```powershell
scripts\build.bat debug
scripts\build.bat release
scripts\build.bat workspace
scripts\build.bat full
scripts\build.bat check
```

```bash
scripts/build.sh debug
scripts/build.sh release
scripts/build.sh workspace
scripts/build.sh full
scripts/build.sh check
```

## Direct Cargo commands

Raw Cargo works after the platform environment is configured.

On Windows GNU, load the generated environment first:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo build
cargo check
```

On Linux/macOS, `scripts/setup-linux.sh` writes `.cargo/env-linux.sh` when it can discover LLVM/libclang. The shell scripts source it automatically.

Useful Cargo commands:

```bash
cargo build
cargo build --release
cargo check
cargo check --workspace
cargo test --no-run
cargo xtask check-layout
cargo xtask status
```

## `xtask` commands

```bash
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

## CI

GitHub Actions runs layout checks plus Linux and Windows GNU Cargo checks. Linux CI installs `clang`, `libclang-dev`, and native compression/build dependencies before Cargo. Windows GNU CI installs MSYS2 packages and discovers `libclang*.dll` dynamically instead of relying on a single hardcoded path.

See [`docs/ci.md`](docs/ci.md) for details.

## Troubleshooting

Common native-build issues are documented in [`docs/troubleshooting.md`](docs/troubleshooting.md).

Frequent fixes:

```powershell
scripts\repair-windows.bat
scripts\clean.bat native
scripts\build.bat debug
```

```bash
scripts/setup-linux.sh
scripts/clean.sh native
scripts/build.sh debug
```

## Documentation

- [`docs/architecture.md`](docs/architecture.md) - cleaned repository architecture.
- [`docs/source_map.md`](docs/source_map.md) - map from upstream-style Sui areas to cleaned locations.
- [`docs/official_sui.md`](docs/official_sui.md) - official Sui overview and links.
- [`docs/build.md`](docs/build.md) - build instructions.
- [`docs/troubleshooting.md`](docs/troubleshooting.md) - common build failures.
- [`docs/windows_toolchain.md`](docs/windows_toolchain.md) - Windows GNU/MSYS2 setup.
- [`docs/linux_toolchain.md`](docs/linux_toolchain.md) - Linux setup.
- [`docs/release_checklist.md`](docs/release_checklist.md) - release preparation.

## Maintainer

Maintainer: **Mario Vinciguerra** (`@mariovinci`)

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Keep changes focused on cleanup, source organization, build reliability, documentation, and maintainability unless a separate feature direction is explicitly opened.

## Security

See [`SECURITY.md`](SECURITY.md). For upstream Sui protocol/security concerns, use official Sui channels.

## License and attribution

This repository preserves upstream license notices and attribution. See [`LICENSE`](LICENSE), [`NOTICE`](NOTICE), and [`docs/license_attribution.md`](docs/license_attribution.md).

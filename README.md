# Sui Clean

**Sui Clean** is an unofficial, cleaned-up Rust workspace for [Sui](https://github.com/MystenLabs/sui).

This repository keeps the Sui codebase recognizable and Cargo-compatible while presenting it in a cleaner, domain-oriented layout. It is meant to be easier to browse, build, audit, and maintain than a large historical monorepo tree.

> This project is not an official Mysten Labs or Sui Foundation repository. It is an unofficial cleaned-up layout derived from Sui-compatible source code. Upstream package identity, license notices, and attribution are preserved where needed.

## Official upstream

The official Sui repository is maintained by Mysten Labs:

- Official Sui repository: <https://github.com/MystenLabs/sui>
- Sui website: <https://sui.io>
- Sui documentation: <https://docs.sui.io>

## What is Sui?

Sui is a next-generation smart contract platform with high throughput, low latency, and an asset-oriented programming model powered by the Move programming language. The official Sui repository describes Sui as a Rust codebase where Move smart contracts define assets and the rules for creating, transferring, and mutating them.

Sui is maintained by a permissionless set of authorities, similar in role to validators or miners in other blockchain systems. Its architecture is designed so many common transactions can be processed in parallel, allowing better use of hardware resources. For common payments and asset transfers, Sui can use lower-latency primitives instead of forcing every transaction through the same consensus path.

Sui's high-level architecture includes clients such as CLI, REST, and RPC clients; a client service; an authority aggregator; authority clients; and authority state on validator/authority nodes. This cleaned repo keeps those concepts but places the Rust source into clearer domains.

At a high level, Sui focuses on:

- high throughput and low latency;
- instant settlement for many common operations;
- an asset-oriented object model;
- Move-based smart contracts;
- rich and composable on-chain assets;
- improved user experience for web3 applications;
- parallel processing for many independent transactions;
- a native SUI token used for gas and delegated stake;
- authority reconfiguration across epochs based on delegated stake.

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

The default check focuses on the active workspace. Full workspace and all-target builds are intentionally separate because they are much larger.

## Build scripts

Use the scripts instead of raw Cargo commands when building on Windows GNU. The scripts load MSYS2/MinGW64 and libclang into the process environment so native dependencies such as RocksDB can build correctly.

```powershell
scripts\setup-windows.bat     # one-time dependency setup, when MSYS2 is installed
scripts\build.bat debug
scripts\build.bat release
scripts\check.bat fast
```

On Linux/macOS, use the matching shell scripts:

```bash
scripts/setup-linux.sh        # one-time dependency setup on Debian/Ubuntu
scripts/build.sh debug
scripts/build.sh release
scripts/check.sh fast
```

Raw `cargo build` also works after your environment is configured. On Windows GNU, dot-source `.cargo\env-windows.ps1` first.

## Build instructions

### Prerequisites

Install Rust using `rustup`. The repository includes `rust-toolchain.toml`, so Cargo will use the pinned toolchain configuration when available.

For Linux builds, install clang/libclang and native compression/database build dependencies. On Debian/Ubuntu this repo provides:

```bash
scripts/setup-linux.sh
```

For Windows GNU builds, install MSYS2 with MinGW64 GCC and clang/libclang. If MSYS2 is already installed, this repo provides:

```powershell
scripts\setup-windows.bat
```

The build scripts expect the default MSYS2 layout:

```text
C:\msys64\mingw64\bin\clang.exe
C:\msys64\mingw64\bin\libclang.dll
```

If MSYS2 is installed somewhere else, set `MSYS2_ROOT` before running the Windows scripts.

### Windows PowerShell

Recommended build path:

```powershell
git clone <your-repo-url> sui-clean
cd sui-clean

scripts\setup-windows.bat
scripts\repair-windows.bat
scripts\build.bat debug
```

The Windows build script loads the MSYS2/MinGW64 DLL path before running Cargo. This is important because `librocksdb-sys` uses bindgen, and bindgen needs to load `libclang.dll`.

Other Windows build modes:

```powershell
scripts\build.bat release      # cargo build --release
scripts\build.bat workspace    # cargo build --workspace
scripts\build.bat full         # cargo build --workspace --all-targets
scripts\build.bat check        # cargo check through the build wrapper
```

If you want to run Cargo directly instead of using the wrappers, load the generated Windows environment first:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo build
cargo check
```

### Linux/macOS

```bash
git clone <your-repo-url> sui-clean
cd sui-clean

scripts/setup-linux.sh
scripts/build.sh debug
scripts/check.sh fast
```

Other Unix build modes:

```bash
scripts/build.sh release
scripts/build.sh workspace
scripts/build.sh full
scripts/build.sh check
```

### Cargo-only commands

These are useful after your environment is already configured:

```powershell
cargo build                 # normal debug build
cargo build --release       # optimized build
cargo check                 # fast validation
cargo check --workspace     # broader workspace validation
cargo xtask check-layout    # enforce cleaned layout
cargo xtask status          # repo status summary
```

### Common `xtask` commands

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

### Troubleshooting Linux native builds

If Linux CI or a local Linux build fails with `Unable to find libclang`, install the system development packages and regenerate the optional environment file:

```bash
scripts/setup-linux.sh
source .cargo/env-linux.sh
cargo clean -p librocksdb-sys
cargo build
```

The GitHub Actions Linux job installs the same dependency set before running Cargo: `clang`, `libclang-dev`, `llvm-dev`, `build-essential`, `pkg-config`, `cmake`, `zlib1g-dev`, `libbz2-dev`, `libsnappy-dev`, and `libzstd-dev`.

### Troubleshooting Windows native builds

If `librocksdb-sys` or bindgen cannot load `libclang.dll`, use the wrapper instead of direct Cargo:

```powershell
scripts\build.bat debug
```

Or manually load the environment in the current PowerShell session:

```powershell
. .\.cargo\env-windows.ps1
cargo clean -p librocksdb-sys
cargo build
```

The error usually means `C:\msys64\mingw64\bin` is not on `PATH` for the running Cargo process, even if `LIBCLANG_PATH` points to the right folder.

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
- [`docs/build.md`](docs/build.md) — full local build guide
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
setup-linux.sh   install Linux native dependencies
setup-windows.*  install MSYS2/MinGW64 native dependencies
build.*          cargo build wrapper with debug/release/workspace/full modes
check.*          cargo check wrapper with fast/core/workspace/compat/full modes
fmt.*            cargo fmt wrapper
status.*         cargo xtask status wrapper
repair-windows.* Windows GNU native-build repair wrapper
```

Implementation helpers live under `scripts/lib/`.

## License and attribution

This repository keeps Apache-2.0 licensing and upstream attribution. See [`LICENSE`](LICENSE), [`NOTICE`](NOTICE), and [`docs/license_attribution.md`](docs/license_attribution.md).

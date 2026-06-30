# GitHub Repository Guide

This repository is prepared for normal GitHub usage with CI, issue templates, a pull request template, dependency-update configuration, and community health files.

## Recommended repository description

```text
A cleaned, domain-organized Rust workspace for Sui-compatible source code.
```

## Recommended topics

```text
sui, rust, blockchain, move-vm, cleaned-repo, monorepo, workspace, crypto
```

## Recommended settings

- Enable branch protection on `main`.
- Require the `Layout and metadata` CI job before merging.
- Require Linux and Windows GNU checks for build-affecting PRs.
- Enable private vulnerability reporting if the repository is public.
- Disable force pushes on protected branches.
- Require pull requests for changes to `Cargo.lock`, `.github/workflows/`, and build scripts.

## Pull request checks

Before opening a PR, run:

```bash
python scripts/check-layout.py
cargo xtask check-layout
cargo xtask status
cargo xtask check-fast
```

For Windows GNU builds, run:

```powershell
scripts\repair-windows.bat
scripts\check.bat fast
```

For the main node build path, run:

```powershell
cargo build -p sui-node
```

## CI expectations

The starter CI focuses on repository hygiene and default build health:

- static layout validation,
- `cargo xtask check-layout`,
- `cargo xtask status`,
- Linux fast check,
- Windows GNU fast check.

The full all-targets gate is intentionally left as a manual/local workflow because it can pull in many test, benchmark, indexer, bridge, faucet, Rosetta, analyzer, fuzz, and Move targets.

## Branch naming

Suggested branch names:

```text
cleanup/runtime-layout
fix/move-package-toml
fix/windows-gnu-build
docs/github-readiness
ci/windows-gnu-check
```

## Suggested labels

```text
bug
build
cleanup
docs
enhancement
needs-triage
security
windows
linux
cargo
layout
```

## Release notes

Use [`docs/release.md`](release.md) before publishing a source archive or GitHub release.

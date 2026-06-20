# GitHub workflow

This repository is prepared for normal GitHub usage with issue templates, a pull request template, and a starter CI workflow.

## Recommended repository description

```text
A cleaned-up, domain-organized Rust workspace for Sui.
```

## Recommended topics

```text
sui, rust, blockchain, move-vm, cleaned-repo, monorepo, workspace, crypto
```

## Pull request checks

Before opening a PR, run:

```powershell
cargo xtask check-layout
cargo xtask status
cargo check
```

For Windows GNU builds, run:

```powershell
scripts\repair-windows.bat
cargo check
```

## CI expectations

The starter CI focuses on layout and default `cargo check`. It intentionally does not pass `--locked` because this cleaned workspace may need to refresh `Cargo.lock` after domain moves or dependency-path cleanup. When dependency versions actually change, run `cargo check` locally and commit the updated `Cargo.lock`.

The full all-targets gate is intentionally left as a manual/local workflow because it is much larger and slower.

## Branch naming

Suggested branch names:

```text
cleanup/runtime-layout
fix/move-vm-paths
docs/github-readiness
ci/windows-gnu-build
```

## PR labels

Suggested labels:

```text
cleanup
docs
build
windows
layout
cargo
```

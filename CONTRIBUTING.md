# Contributing

Thanks for improving **Sui Clean**. This repository is a cleaned-up Sui Rust workspace, so contributions should make the repo easier to navigate, build, audit, and maintain while preserving upstream compatibility.

## Contribution principles

- Keep cleanup changes separate from behavior changes whenever possible.
- Preserve upstream package names when Cargo compatibility requires them.
- Keep source ownership clear: no hidden vendor dumps, stale generated folders, or duplicate root-level source buckets.
- Prefer small, reviewable PRs with explicit validation notes.
- Do not remove upstream copyright notices, license headers, or attribution.

## Layout rules

- Keep `crates/` limited to the approved domains: `api`, `config`, `consensus`, `core`, `crypto`, `execution`, `metrics`, `network`, `protocol`, `runtime`, `storage`, and `types`.
- Keep `bench/`, `tests/`, `tools/`, `scripts/`, and `docs/` at the root.
- Do not recreate root-level `vendor/`, `third-party/`, `external/`, `upstream/`, or `manifests/` folders.
- Keep Move VM and Move execution sources under `crates/execution/move/`.
- Update documentation when changing folder layout, build scripts, or public workflow commands.

## Before opening a pull request

Run the static checks:

```bash
python scripts/check-layout.py
python scripts/lib/audit-direct-paths.py
python scripts/lib/audit-workspace-inheritance.py
python scripts/lib/audit-crates-domains.py
```

Run the Rust checks that match the change:

```bash
cargo xtask check-layout
cargo xtask status
cargo xtask check-fast
```

For domain-specific changes, also run one of:

```bash
cargo xtask check-domain api
cargo xtask check-domain execution
cargo xtask check-domain runtime
cargo xtask check-domain storage
```

On Windows GNU/MSYS2, prefer the wrappers:

```powershell
scripts\repair-windows.bat
scripts\check.bat fast
```

For the main node build path:

```powershell
cargo build -p sui-node
```

## Pull request checklist

Every PR should explain:

- what changed,
- whether runtime behavior changed,
- which commands were run,
- whether the change affects upstream sync paths,
- whether `Cargo.lock` changed and why.

## Commit style

Use clear, boring commit messages:

```text
Clean runtime crate layout
Fix Move package TOML compatibility
Add Windows GNU build notes
Document GitHub release checklist
```

## Upstream sync changes

If a PR updates embedded upstream Sui/Move code, include:

- the upstream checkout or source reference used,
- any repair or rewrite scripts run,
- the result of `python scripts/check-layout.py`,
- the result of the relevant Cargo check/build command.

## Security-sensitive changes

For changes touching crypto, consensus, networking, signatures, key handling, validator behavior, or build supply chain logic, be extra explicit in the PR description. Include threat-model notes when relevant, and avoid mixing those changes with cosmetic cleanup.

# GitHub release checklist

Use this before tagging a cleaned repo baseline.

## Required

```powershell
cargo xtask check-layout
cargo xtask status
cargo check
```

## Recommended

```powershell
cargo xtask tree
cargo xtask check-domain api
cargo xtask check-domain execution
cargo xtask check-domain runtime
cargo xtask check-domain storage
```

## Manual review

- README describes this as an unofficial cleaned-up Sui repository.
- `crates/` only contains approved domain folders.
- `bench/`, `tests/`, and `tools/` are root-level folders.
- No root `vendor/`, `upstream/`, or `manifests/` folders exist.
- `crates/execution/move/language/vm/` exists and replaces old external-crates paths.
- `LICENSE` and `NOTICE` are present.
- `docs/license_attribution.md` is present.
- GitHub templates are present under `.github/`.

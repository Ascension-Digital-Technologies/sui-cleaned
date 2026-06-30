# Release Checklist

Use this checklist before publishing a GitHub release or sharing a fresh source zip.

## Required local checks

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
cargo xtask check-fast
cargo build -p sui-node
```

On Windows GNU/MSYS2:

```powershell
scripts\repair-windows.bat
scripts\check.bat fast
cargo build -p sui-node
```

## GitHub readiness

- `README.md` describes the project, status, layout, build flow, license, and attribution.
- `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`, `LICENSE`, and `NOTICE` are present.
- `.github/workflows/ci.yml` runs static layout checks plus Linux and Windows GNU check jobs.
- Issue templates cover bug reports, build failures, feature requests, and cleanup requests.
- `Cargo.lock` is committed when dependency resolution changes.
- No generated `target/`, local caches, editor files, or secrets are included.

## Source zip checklist

Before zipping:

```bash
rm -rf target
find . -name '*.profraw' -delete
find . -name '*.profdata' -delete
```

Then verify the archive:

```bash
python -m zipfile --test path/to/archive.zip
```

## Release notes template

```markdown
## Highlights

- 

## Validation

- `python scripts/check-layout.py`
- `cargo xtask check-fast`
- `cargo build -p sui-node`

## Known notes

- This is an unofficial cleaned workspace, not an official Sui release.
```


## Windows release benchmark note

Some release-only builds compile `sui-data-store`, which uses the GraphQL schema during code generation. This tree keeps a fallback schema lookup so clean zip builds can find `crates/api/indexing/surfaces/indexer-graphql/schema.graphql` without requiring the old generated `sui-indexer-alt-graphql` folder layout.

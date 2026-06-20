# Build Guide

## 1. Install Rust

The repository preserves upstream's `rust-toolchain.toml`, currently pinned to Rust 1.92.

## 2. Populate upstream support crates

```bash
scripts/fetch-upstream-deps.sh
```

Or use a local Sui source tree:

```bash
scripts/fetch-upstream-deps.sh /path/to/sui
```

## 3. Validate metadata

```bash
cargo metadata --format-version 1 --no-deps
```

## 4. Build/check

```bash
cargo check --workspace --all-targets
```

For faster iteration, check one package:

```bash
cargo check -p consensus-core
cargo check -p sui-types
cargo check -p sui-core
```

## Known limitation

This cleaned workspace is source-complete for the extracted Sui domains, but it intentionally
does not inline every upstream support/indexer/tool crate. Run the upstream sync step before
expecting full workspace checks to resolve all path dependencies.

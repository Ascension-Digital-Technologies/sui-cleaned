# Build Guide

This repository includes the Sui compatibility crates and Move VM dependency tree directly in the cleaned domain layout. A normal build does **not** require downloading upstream files.

## 1. Install Rust

The repository preserves upstream's `rust-toolchain.toml`. Rustup will install the pinned toolchain automatically when needed.

## 2. Check the layout

```bash
cargo xtask check-layout
cargo xtask status
```

## 3. Build/check

Fast daily check:

```bash
cargo check
# or
scripts/check.sh fast
```

Broader workspace check:

```bash
cargo xtask check-workspace
# or
scripts/check.sh workspace
```

Full all-targets parity gate:

```bash
cargo xtask check-full
# or
scripts/check.sh full
```


# Domain commands

The repository is organized around a small fixed set of source domains under `crates/`.

```text
crates/
  api/
  crypto/
  config/
  runtime/
  consensus/
  execution/
  network/
  protocol/
  storage/
```

`bench/`, `tests/`, and `tools/` are intentionally root-level work areas, not `crates/` domains.

## Inspect the tree

```powershell
cargo xtask tree
cargo xtask tree execution
cargo xtask tree runtime
cargo xtask tree tools
```

## Enforce the layout

```powershell
cargo xtask check-layout
```

This fails if a new top-level folder is added under `crates/` outside the allowed domain set, or if old staging folders like `vendor/`, `upstream/`, `manifests/`, `crates/runtime/sui/`, or `crates/execution/external-crates/` come back.

## Check a domain

```powershell
cargo xtask check-domain consensus
cargo xtask check-domain execution
cargo xtask check-domain runtime
cargo xtask check-domain storage
```

For a full target check of one domain:

```powershell
cargo xtask check-domain execution --all-targets
```

Domain checks discover package names from `Cargo.toml` files below the selected domain and invoke `cargo check --package ...` for those packages.

# Upstream Sui support crates

Some upstream Sui support crates still need to participate in the root Cargo workspace because their manifests use `workspace = true`.

They live under:

```text
domain folders under crates//<crate>/
```

The persistent sync list lives next to that subtree:

```text
domain folders under crates/.txt
```

Run:

```powershell
cargo xtask sync C:\path\to\sui-main
```

The sync step copies upstream Sui support crates into `domain folders under crates/`, copies Move/external crates into `crates/execution/move-vm`, then runs path repair and audit scripts.

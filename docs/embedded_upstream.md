# Embedded upstream files

This repo includes the upstream Sui compatibility crates and Move VM dependency tree directly.

Canonical locations:

```text
domain folders under crates//   upstream Sui compatibility crates
crates/execution/move-vm/    upstream Move VM and external runtime crates
```

`fetch-upstream-deps.bat` is now optional. Use it only when refreshing from a newer upstream Sui checkout.

The cleaned repo keeps root folders focused and keeps all Rust crate code under the requested top-level `crates/` domains.

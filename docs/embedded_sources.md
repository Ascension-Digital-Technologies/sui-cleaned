# Embedded sources

Sui Clean is self-contained and based on the official Sui source project at <https://github.com/MystenLabs/sui>. The Sui and Move sources needed by the workspace are embedded directly in the cleaned domain layout.

Important locations:

```text
crates/<domain>/...             Sui-compatible Rust crates distributed by domain
crates/execution/move/language/vm/       Move VM and Move execution sources
```

There is no root `vendor/`, `upstream/`, or `manifests/` folder, and there are no sync scripts in this repository.

Source refreshes should be performed deliberately in a separate maintenance branch, reviewed as a normal code import, and followed by:

```powershell
cargo xtask check-layout
cargo xtask status
cargo check
```

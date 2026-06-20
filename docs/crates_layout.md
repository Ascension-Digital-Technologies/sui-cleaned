# Crates layout

`crates/` is organized into a fixed set of domain folders:

```text
crates/api/
crates/crypto/
crates/config/
crates/runtime/
crates/consensus/
crates/execution/
crates/network/
crates/protocol/
crates/storage/
```

No other top-level folders should be added under `crates/`.

Root-level `bench/`, `tests/`, and `tools/` are intentionally outside `crates/`.

Embedded Sui-compatible crates live directly under the appropriate `crates/<domain>/` folders.

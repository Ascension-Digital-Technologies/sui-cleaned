# Upstream direct path repair

Some upstream Sui support crates contain direct relative paths such as:

```text
../../../../execution/move-vm/...
../../../../execution/sui-execution/...
```

Inside this cleaned repo those canonical copies live at:

```text
crates/execution/move-vm/
crates/execution/sui-execution/
```

`scripts/repair-upstream-direct-paths.py` rewrites synced upstream manifests under `domain folders under crates//*` after every sync.

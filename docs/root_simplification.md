# Root simplification

Removed generated/root clutter:

- no `upstream/` root
- no `manifests/` root
- no `vendor/` root
- no `reports/` root
- no root-level `xtask/` folder

Repository automation lives under `crates/runtime/apps/xtask/`.

Upstream Sui support crates are embedded directly into the relevant `crates/<domain>/...` folders. Move and Move execution sources live under `crates/execution/move/language/vm/`.

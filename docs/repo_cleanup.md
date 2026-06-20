# Repo cleanup policy

The cleaned workspace keeps source layout simple:

- `crates/` contains reusable crates and synced upstream Sui support crates.
- `bench/`, `tests/`, and `tools/` live at the root.
- `reports/` contains generated audits and cleanup notes.
- There is no root `vendor/`, `upstream/`, or `manifests/` directory.

Upstream support code is sync-managed under `crates/runtime/`. Avoid hand-editing it unless the change is also captured in a repair script.

# Vendored Sui Compatibility Area

This directory contains upstream Sui support crates after running the sync command.
It is intentionally isolated from first-party cleaned crates under `crates/`.

## Sync

```powershell
cargo xtask sync C:\path\to\sui
```

The sync command copies selected upstream crates, Move external crates, and compatibility
paths, then applies repair passes needed by this cleaned workspace.

## Policy

- Treat `vendor/sui/` as upstream-managed compatibility code.
- Prefer scripted repair passes over manual edits.
- Keep first-party cleanup and new organization under `crates/`, `docs/`, `scripts/`,
  `manifests/`, `reports/`, and `xtask/`.

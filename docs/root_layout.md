# Root layout

Sui Clean is a cleaned-up Sui Rust workspace. The root is intentionally small and source-focused.

```text
sui-clean/
  crates/     reusable Rust library/runtime crates grouped by domain
  bench/      benchmark and load-generation crates
  tests/      integration, transactional, fuzz, and fixture crates
  tools/      operational and developer tool crates
  xtask/      Rust repo automation
  scripts/    thin wrappers and sync/repair helpers
  docs/       human-maintained documentation
  reports/    generated validation and cleanup reports
```

There is no root `vendor/`, `upstream/`, or `manifests/` folder.

Embedded upstream Sui and Move code is placed into the same cleaned domain layout as the rest of the workspace. The canonical Move location is:

```text
crates/execution/move-vm/
```

The only allowed top-level folders under `crates/` are listed in `docs/crates_domains.md`.

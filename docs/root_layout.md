# Root layout

Sui Clean is a cleaned-up Sui Rust workspace. The root is intentionally small and source-focused.

```text
sui-clean/
  crates/     reusable Rust library/runtime crates grouped by domain
  bench/      benchmark and load-generation crates
  tests/      integration, transactional, fuzz, and fixture crates
  tools/      operational and developer tool crates
  scripts/    thin wrapper scripts
  docs/       human-maintained documentation
```

There is no root `vendor/`, `upstream/`, `manifests/`, `reports/`, or root `xtask/` folder. Repository automation lives in `crates/runtime/apps/xtask/`.

Embedded upstream Sui and Move code is placed into the same cleaned domain layout as the rest of the workspace. The canonical Move location is:

```text
crates/execution/move/language/vm/
```

The only allowed top-level folders under `crates/` are listed in `docs/crates_domains.md`.

# Crates

This is the canonical Rust package root for the cleaned Sui reference workspace.

The layout keeps the domain grouping readable while still matching normal Rust workspace expectations:

```text
crates/
  api/
  bench/
  consensus/
  crypto/
  execution/
  network/
  protocol/
  storage/
  tests/
  tools/
```

Root-level `api/`, `consensus/`, `execution/`, etc. are intentionally not used as active workspace members anymore.

## Root-level non-library packages

Benchmark, standalone test, and tool packages are intentionally kept outside this
folder:

- `../bench/` for benchmark/load-generation crates
- `../tests/` for standalone integration/fuzz/transactional test crates
- `../tools/` for operational and developer CLIs

Keep `crates/` focused on reusable first-party library/runtime packages.

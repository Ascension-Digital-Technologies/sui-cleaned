# Benchmarks

Root-level benchmark and load-generation crates live here.

These are active workspace packages, but they are intentionally outside `crates/` so
production library code stays separated from performance and load-test tooling.

Common commands:

```powershell
cargo xtask check-fast
cargo xtask check-workspace
cargo xtask check-full
```

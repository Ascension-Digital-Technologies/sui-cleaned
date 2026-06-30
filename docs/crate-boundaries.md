# Crate Boundaries

These are layout/dependency rules for keeping the workspace clean. They are intentionally architectural and should guide future crate placement.

## Dependency direction

```text
types      -> may depend only on core/crypto/config-level primitives when necessary
core       -> should stay dependency-light and must not depend on runtime/api/storage/execution
crypto     -> may depend on core/types/config, but not runtime/api
config     -> may depend on types/core, but should avoid execution/runtime cycles
protocol   -> may depend on types/core/crypto/config
consensus  -> may depend on protocol/types/crypto/network where required
execution  -> may depend on protocol/types/storage/crypto/config
storage    -> may depend on types/core/metrics/config
network    -> may depend on crypto/protocol/types/metrics/config
api        -> may depend outward on runtime/execution/storage/protocol/types
runtime    -> may wire everything together, but should not leak runtime-only deps downward
metrics    -> should stay safe to import from most domains
```

## Placement rule of thumb

- Reusable model/schema: `crates/types/`
- Runtime-independent utility: `crates/core/`
- Wire format or transaction/protocol rule: `crates/protocol/`
- Actual execution/state transition logic: `crates/execution/`
- Persistent data implementation: `crates/storage/`
- External-facing surface: `crates/api/`
- Binary orchestration: `crates/runtime/`
- Developer or ops command: `tools/`
- Test harness/fixture/fuzzer: `tests/`
- Benchmark/load generator: `bench/`

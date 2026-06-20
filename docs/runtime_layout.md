# Runtime Layout

The runtime domain is intentionally flat under `crates/runtime`.

```text
crates/runtime/
  cli/
  node/
  service/
  simulator/
    simulacrum/
  telemetry/
    subscribers/
  metrics/
    push-client/
    prometheus-closure/
  version/
  common/
  futures/
```

`crates/runtime/` was removed. The repo uses domain folders, not an upstream namespace bucket.

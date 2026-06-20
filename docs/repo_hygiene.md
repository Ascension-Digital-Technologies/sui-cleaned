# Repo hygiene

Keep the root focused on source, scripts, and human-maintained documentation. Do not add generated scratch directories or report folders to the root.

Allowed major roots:

```text
crates/ bench/ tests/ tools/ scripts/ docs/
```

Repository automation lives under `crates/runtime/xtask/`. Generated metadata or audits should be written under `target/xtask-output/`, not a root `reports/` directory.

Embedded Sui-compatible crates are kept directly in the cleaned domain layout.

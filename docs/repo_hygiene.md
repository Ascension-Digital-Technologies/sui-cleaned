# Repo hygiene

Keep the root focused on source, automation, docs, and reports. Do not add generated scratch directories to the root.

Allowed major roots:

```text
crates/ bench/ tests/ tools/ xtask/ scripts/ docs/ reports/
```

Upstream Sui compatibility crates are sync-managed under `crates/runtime/`. Local clone scratch space belongs in `.upstream-tmp/`, which is ignored.

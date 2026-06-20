# Build Modes

Use `cargo xtask` for the named workflows.

```powershell
cargo xtask status
cargo xtask check-fast
cargo xtask check-core
cargo xtask check-workspace
cargo xtask check-sui-compat
cargo xtask check-full
```

## Recommended loop

```powershell
cargo xtask check-fast
```

This is equivalent to `cargo check` and uses the root `workspace.default-members`.

## Core cleanup loop

```powershell
cargo xtask check-core
```

This checks the explicit first-party core package set.

## Full parity gate

```powershell
cargo xtask check-full
```

This runs `cargo check --workspace --all-targets`. It is intentionally huge and should be
used only when validating full upstream compatibility.

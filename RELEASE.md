# Release Process

This repository is a cleaned-up Sui Rust workspace. Releases should prove that the source layout, scripts, and platform setup still work before tagging.

## Release checklist

Run from the repository root:

```bash
cargo xtask check-layout
cargo xtask status
scripts/check.sh fast
scripts/test.sh fast
scripts/build.sh debug
```

On Windows PowerShell:

```powershell
cargo xtask check-layout
cargo xtask status
scripts\check.bat fast
scripts\test.bat fast
scripts\build.bat debug
```

Before tagging a public release:

```bash
cargo fmt --all --check
cargo check --workspace
```

Optional large gates:

```bash
cargo check --workspace --all-targets
scripts/build.sh release
```

## Version notes

A release note should mention:

- Workspace layout changes.
- Build/CI changes.
- Script changes.
- Any known platform-specific native build requirements.
- Whether `Cargo.lock` changed intentionally.

## Attribution

Keep upstream Sui attribution intact. This repository is unofficial and should continue to link to the official Sui repository and documentation.

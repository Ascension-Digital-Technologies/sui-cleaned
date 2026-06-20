# Release Checklist

Before publishing a GitHub release or tagging a cleanup baseline, run the appropriate gates.

## Fast local gate

```bash
cargo xtask check-layout
cargo xtask status
scripts/check.sh fast
scripts/test.sh fast
```

Windows:

```powershell
cargo xtask check-layout
cargo xtask status
scripts\check.bat fast
scripts\test.bat fast
```

## Build gate

```bash
scripts/build.sh debug
scripts/build.sh release
```

Windows:

```powershell
scripts\build.bat debug
scripts\build.bat release
```

## Broader validation

```bash
cargo fmt --all --check
cargo check --workspace
cargo test --workspace --no-run
```

## Release notes

Update:

- `CHANGELOG.md`
- `README.md`, if build or layout behavior changed
- `docs/`, if platform setup changed

Then confirm:

```bash
git status
```

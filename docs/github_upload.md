# GitHub Upload Checklist

This repository is ready to upload when the following checks pass from the repository root.

## Static layout checks

```bash
python scripts/check-layout.py
python scripts/lib/audit-direct-paths.py
python scripts/lib/audit-workspace-inheritance.py
python scripts/lib/audit-crates-domains.py
```

## Windows GNU build flow

Use the wrapper instead of raw Cargo on Windows:

```powershell
scripts\setup-windows.bat      # one-time, if MSYS2 dependencies are not installed
scripts\build.bat debug
scripts\check.bat fast
```

The Windows wrappers dynamically find a loadable `libclang*.dll` under `MSYS2_ROOT`, common MSYS2 toolchain directories, or `C:\Program Files\LLVM\bin`. They also prepend the selected directory to `PATH` before Cargo runs so `librocksdb-sys` and bindgen can load libclang plus its dependent DLLs.

For direct Cargo commands on Windows GNU:

```powershell
scripts\repair-windows.bat
. .\.cargo\env-windows.ps1
cargo build -p sui-node
```

## Linux build flow

```bash
scripts/setup-linux.sh
scripts/build.sh debug
scripts/check.sh fast
```

## GitHub community files

Confirm these files exist before the first push:

- `README.md`
- `LICENSE`
- `NOTICE`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `SUPPORT.md`
- `CODE_OF_CONDUCT.md`
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/*.yml`
- `.github/workflows/ci.yml`
- `.github/dependabot.yml`

## CI

The GitHub Actions workflow runs layout/status checks, Linux Cargo check, and Windows GNU Cargo check using the same native dependency setup used by the local scripts.

The full all-targets gate is intentionally left as a manual/local workflow because it is much larger and slower.

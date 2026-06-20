# Move upstream path handling

Move/external crates are synced into one canonical location:

```text
crates/execution/move-vm/
```

Synced upstream Sui support crates under `domain folders under crates//*` are repaired to point at that canonical copy. Run:

```powershell
scripts\repair-move-upstream-paths.bat
```

or through xtask:

```powershell
cargo xtask repair-upstream
```

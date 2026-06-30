## Summary

Describe what this PR changes and why.

## Type of change

- [ ] Repository layout cleanup
- [ ] Build or dependency fix
- [ ] Documentation
- [ ] Test, benchmark, or tooling
- [ ] Security-sensitive change
- [ ] Other

## Behavior impact

- [ ] No runtime behavior change
- [ ] Runtime behavior changed intentionally
- [ ] Not sure / needs reviewer attention

## Validation

Check every command that was run:

- [ ] `python scripts/check-layout.py`
- [ ] `python scripts/lib/audit-direct-paths.py`
- [ ] `cargo xtask check-layout`
- [ ] `cargo xtask status`
- [ ] `cargo xtask check-fast`
- [ ] `cargo build -p sui-node`
- [ ] Windows repair/check was run, if relevant

## Notes for reviewers

Mention path rewrites, package aliases, `Cargo.lock` changes, Windows build changes, or upstream sync concerns.

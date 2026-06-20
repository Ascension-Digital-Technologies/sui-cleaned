# License and Attribution Notes

This cleanup kit creates a reference extraction from the upstream Sui repository. Preserve license files, notices, and original file headers.

Rules:

1. Keep root `LICENSE`/`NOTICE` and preserve upstream file headers.
2. Do not strip copyright headers.
3. Do not present copied upstream Rust as original C code.
4. For the C port, use the extracted tree as a behavior/reference map and keep `docs/sui_mapping.md` updated.
5. When moving files, prefer copy-first extraction so the original upstream checkout remains untouched.

The extraction script is intentionally non-destructive.

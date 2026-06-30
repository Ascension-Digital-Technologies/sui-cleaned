#!/usr/bin/env python3
"""Repair Sui/Move workspace dependency mismatch after extraction.

Why this exists:
  The cleaned repo combines Sui's root workspace with the upstream Move
  workspace. Sui's root workspace currently wants uint 0.10.x, while upstream
  Move's move-core-types expects its direct uint dependency to match the uint
  version pulled by primitive-types 0.10.x, which resolves in practice to
  uint 0.9.x. If move-core-types inherits uint from the cleaned Sui root, Rust
  sees two different FromStrRadixErr types and fails in u256.rs.

This script patches only fetched Move manifests; it does not change Sui's root
workspace uint version, because Sui crates such as typed-store may still expect
that newer workspace dependency.
"""
from __future__ import annotations
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
CANDIDATES = [
    ROOT / "crates/execution/move/language/core/move-core-types/Cargo.toml",
]

changed = []
missing = []
for path in CANDIDATES:
    if not path.exists():
        missing.append(path)
        continue
    text = path.read_text(encoding="utf-8")
    original = text
    text = text.replace("uint.workspace = true", 'uint = "0.9.5"')
    if text != original:
        path.write_text(text, encoding="utf-8")
        changed.append(path)

if changed:
    for path in changed:
        print(f"patched Move uint dependency: {path.relative_to(ROOT)}")
else:
    present = [p for p in CANDIDATES if p.exists()]
    if present:
        print("Move uint dependency already repaired")
    else:
        print("Move language sources not present yet; verify crates/execution/move/language is present")

# Success even when Move language sources are not present yet; fetch scripts call this after copying.
sys.exit(0)

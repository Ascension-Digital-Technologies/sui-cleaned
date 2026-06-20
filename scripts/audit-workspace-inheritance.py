#!/usr/bin/env python3
"""Verify synced upstream Sui crates are workspace members.

The cleaned repo keeps upstream Sui support crates under domain folders under crates//*.
Those crates still use `workspace = true`, so they must remain explicit root
workspace members after every sync.
"""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_LIST = ROOT / "crates" / "sui" / "crates.txt"
CARGO = ROOT / "Cargo.toml"

text = CARGO.read_text(encoding="utf-8")
errors: list[str] = []

if not UPSTREAM_LIST.exists():
    errors.append(f"missing upstream crate list: {UPSTREAM_LIST}")
else:
    for raw in UPSTREAM_LIST.read_text(encoding="utf-8").splitlines():
        crate = raw.strip()
        if not crate or crate.startswith("#"):
            continue
        member = f"domain folders under crates//{crate}"
        if f'"{member}"' not in text:
            errors.append(f"missing workspace member: {member}")
        manifest = ROOT / member / "Cargo.toml"
        if not manifest.exists():
            errors.append(f"missing synced upstream manifest after sync: {member}/Cargo.toml")

for manifest in (ROOT / "crates" / "sui" / "crates").glob("*/Cargo.toml"):
    rel = manifest.parent.relative_to(ROOT).as_posix()
    body = manifest.read_text(encoding="utf-8", errors="ignore")
    if "workspace = true" in body and f'"{rel}"' not in text:
        errors.append(f"synced upstream manifest uses workspace inheritance but is not a root member: {rel}")

out = ROOT / "reports" / "workspace-deps-audit.txt"
out.parent.mkdir(parents=True, exist_ok=True)
if errors:
    out.write_text("Workspace inheritance audit failed:\n" + "\n".join(errors) + "\n", encoding="utf-8")
    print(out.read_text(encoding="utf-8"), end="")
    sys.exit(1)
else:
    out.write_text("Workspace inheritance audit passed.\n", encoding="utf-8")
    print("workspace inheritance audit passed")

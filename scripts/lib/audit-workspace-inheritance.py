#!/usr/bin/env python3
"""Verify root workspace members with workspace inheritance are present.

The cleaned repo distributes Sui/Move crates into domain folders. This audit keeps
sync mistakes from leaving a root workspace member missing while avoiding false
positives from upstream nested test/fuzzer crates that are intentionally not root
workspace members.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
CARGO = ROOT / "Cargo.toml"
MEMBER_RE = re.compile(r'"([^"]+)"')

text = CARGO.read_text(encoding="utf-8")
errors: list[str] = []
members: list[str] = []
inside = False
for raw in text.splitlines():
    line = raw.strip()
    if line.startswith("members") and "[" in line:
        inside = True
    if inside:
        for item in MEMBER_RE.findall(line):
            members.append(item)
    if inside and "]" in line:
        inside = False

checked = 0
for member in members:
    manifest = ROOT / member / "Cargo.toml"
    if not manifest.exists():
        errors.append(f"missing workspace member manifest: {member}/Cargo.toml")
        continue
    body = manifest.read_text(encoding="utf-8", errors="ignore")
    if "workspace = true" in body:
        checked += 1

out = ROOT / "target" / "xtask-output" / "workspace-deps-audit.txt"
out.parent.mkdir(parents=True, exist_ok=True)
if errors:
    out.write_text("Workspace inheritance audit failed:\n" + "\n".join(errors) + "\n", encoding="utf-8")
    print(out.read_text(encoding="utf-8"), end="")
    sys.exit(1)

out.write_text(
    f"Workspace inheritance audit passed. {len(members)} members present; {checked} use workspace inheritance.\n",
    encoding="utf-8",
)
print(f"workspace inheritance audit passed ({len(members)} members, {checked} inheriting)")

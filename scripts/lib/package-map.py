#!/usr/bin/env python3
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
rows = []
for cargo in sorted(root.rglob("Cargo.toml")):
    if any(part in {"target", ".upstream-tmp"} for part in cargo.parts):
        continue
    text = cargo.read_text(errors="ignore")
    m = re.search(r'^name\s*=\s*"([^"]+)"', text, re.M)
    if m:
        rows.append((m.group(1), cargo.parent.relative_to(root).as_posix()))

out = root / "target" / "xtask-output" / "package-map.csv"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text("package,path\n" + "".join(f"{name},{path}\n" for name, path in rows), encoding="utf-8")
print(f"wrote {out} ({len(rows)} packages)")

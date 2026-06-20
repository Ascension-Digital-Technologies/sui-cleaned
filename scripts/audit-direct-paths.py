#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SKIP_MANIFESTS = {
    ROOT / 'crates/execution/move-vm/move/Cargo.toml',
    ROOT / 'crates/execution/move-vm/move/tooling/tree-sitter/Cargo.toml',
}
manifest_paths = [
    p for p in ROOT.rglob('Cargo.toml')
    if 'target' not in p.parts
    and '.upstream-tmp' not in p.parts
    and p not in SKIP_MANIFESTS
]
missing: list[str] = []
path_re = re.compile(r'path\s*=\s*"([^"]+)"')
for manifest in manifest_paths:
    text = manifest.read_text(encoding='utf-8', errors='replace')
    for m in path_re.finditer(text):
        rel = m.group(1)
        if rel.startswith(('http://', 'https://')):
            continue
        target = (manifest.parent / rel).resolve()
        # Only audit local dependency paths, not comments or weird generated snippets.
        line_start = text.rfind('\n', 0, m.start()) + 1
        line_end = text.find('\n', m.end())
        if line_end == -1:
            line_end = len(text)
        line = text[line_start:line_end].strip()
        if line.startswith('#'):
            continue
        if not (target / 'Cargo.toml').exists() and not target.exists():
            missing.append(f'{manifest.relative_to(ROOT)} -> {rel}')

out = ROOT / 'reports' / 'direct-paths-audit.txt'
out.parent.mkdir(exist_ok=True)
if missing:
    out.write_text('Missing local Cargo path dependencies:\n' + '\n'.join(missing) + '\n')
    print(f'error: missing local Cargo path dependencies: {len(missing)}')
    print(f'see {out}')
    sys.exit(1)
out.write_text('No missing local Cargo path dependencies found in present manifests.\n')
print('direct path audit: ok')

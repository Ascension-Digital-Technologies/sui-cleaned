#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {
    'api', 'crypto', 'config', 'runtime', 'consensus', 'execution', 'network', 'protocol', 'storage'
}
crates = ROOT / 'crates'
seen = sorted(p.name for p in crates.iterdir() if p.is_dir())
extra = [x for x in seen if x not in ALLOWED]
missing = sorted(ALLOWED - set(seen))
if extra or missing:
    print('crates domain audit failed')
    if extra:
        print('unexpected:', ', '.join(extra))
    if missing:
        print('missing:', ', '.join(missing))
    sys.exit(1)
print('crates domain audit passed')
for x in seen:
    print(' ', x)

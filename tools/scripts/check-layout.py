#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APPROVED_CRATE_DOMAINS = {
    'api', 'core', 'config', 'consensus', 'crypto', 'execution',
    'network', 'protocol', 'metrics', 'runtime', 'storage', 'types',
}
DISALLOWED_ROOTS = {'vendor', 'third-party', 'third_party', 'external'}

errors: list[str] = []

for name in DISALLOWED_ROOTS:
    if (ROOT / name).exists():
        errors.append(f'disallowed owned-source bucket exists: {name}/')

crates = ROOT / 'crates'
if not crates.is_dir():
    errors.append('missing crates/ directory')
else:
    for child in crates.iterdir():
        if child.is_dir() and child.name not in APPROVED_CRATE_DOMAINS:
            errors.append(f'unapproved crates/ domain: crates/{child.name}')
        if child.is_file() and child.name != 'README.md':
            errors.append(f'file directly under crates/: {child}')

for bad in ROOT.glob('crates/**/crates'):
    if bad.is_dir():
        errors.append(f'nested crates bucket should be renamed by subsystem: {bad.relative_to(ROOT)}')

# Guard against architecture-level one-crate wrapper folders such as
# crates/consensus/core/ when crates/consensus/ is clearer. Source/test/data
# internals are intentionally ignored because they often use generated or
# fixture directory chains.
WRAPPER_EXEMPT_PARTS = {
    'src', 'tests', 'benches', 'proto', 'design', 'docs', 'data',
    'fixtures', 'fixture', 'unit_tests', 'abi', 'bindings', 'editors', 'target',
}
if crates.is_dir():
    for folder in crates.rglob('*'):
        if not folder.is_dir():
            continue
        if (folder / 'Cargo.toml').exists():
            continue
        rel_parts = folder.relative_to(ROOT).parts
        if any(part in WRAPPER_EXEMPT_PARTS for part in rel_parts):
            continue
        entries = [child for child in folder.iterdir() if child.name != 'README.md']
        dirs = [child for child in entries if child.is_dir()]
        files = [child for child in entries if child.is_file()]
        if len(dirs) == 1 and not files:
            errors.append(
                f'redundant one-child wrapper folder: {folder.relative_to(ROOT)} -> {dirs[0].name}'
            )

root_cargo = ROOT / 'Cargo.toml'
if root_cargo.exists():
    data = tomllib.loads(root_cargo.read_text(encoding='utf-8'))
    workspace = data.get('workspace', {})
    for member in workspace.get('members', []):
        if '*' in member:
            continue
        cargo = ROOT / member / 'Cargo.toml'
        if not cargo.exists():
            errors.append(f'workspace member missing Cargo.toml: {member}')

# Validate local Cargo dependency path entries in dependency-like tables only.
def walk_dep_tables(obj, prefix=''):
    if not isinstance(obj, dict):
        return
    for k, v in obj.items():
        key = f'{prefix}.{k}' if prefix else str(k)
        if isinstance(v, dict):
            if 'dependencies' in str(k) or str(k) in {'patch', 'replace'} or 'dependencies' in key:
                yield key, v
            yield from walk_dep_tables(v, key)

for manifest in ROOT.rglob('Cargo.toml'):
    try:
        data = tomllib.loads(manifest.read_text(encoding='utf-8'))
    except Exception as exc:
        errors.append(f'failed to parse {manifest.relative_to(ROOT)}: {exc}')
        continue
    for _, table in walk_dep_tables(data):
        for dep_name, spec in table.items():
            if isinstance(spec, dict) and 'path' in spec:
                p = spec['path']
                if not isinstance(p, str) or '$' in p:
                    continue
                target = (manifest.parent / p).resolve()
                if not (target / 'Cargo.toml').exists():
                    errors.append(
                        f'local dependency path missing: {manifest.relative_to(ROOT)} -> {dep_name} = {p}'
                    )

if errors:
    print('Layout check failed:')
    for err in errors:
        print(f'  - {err}')
    sys.exit(1)

print('Layout check passed.')

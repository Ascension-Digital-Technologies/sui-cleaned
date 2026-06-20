#!/usr/bin/env python3
"""Repair direct relative paths after the cleaned domain layout moves.

This keeps synced upstream Sui/Move Cargo manifests buildable after we place code
under the clean domains:

  crates/execution/move-vm/
  crates/execution/sui-execution/
  crates/runtime/
  crates/api/
  crates/storage/
  ...

The repair is intentionally path-based and layout-aware instead of using one
fixed replacement string, because manifests live at different depths.
"""
from __future__ import annotations
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PATH_RE = re.compile(r'path\s*=\s*"([^"]+)"')

# Active manifests only. Skip target/build outputs and temporary upstream clones.
SKIP_PARTS = {'target', '.upstream-tmp'}


def rel_to_manifest(manifest: Path, target: Path) -> str:
    return Path(target).resolve().relative_to(ROOT).as_posix() if False else __import__('os').path.relpath(target.resolve(), manifest.parent.resolve()).replace('\\', '/')


def rewrite_path(manifest: Path, rel: str) -> str | None:
    """Return a replacement for rel, or None when rel should stay unchanged."""
    if rel.startswith(('http://', 'https://')) or '$' in rel:
        return None

    normalized = rel.replace('\\', '/')

    # Upstream Sui crates commonly reference ../../external-crates/... . In the
    # cleaned repo, external-crates/move became crates/execution/move-vm/move.
    marker = 'external-crates/'
    if marker in normalized:
        suffix = normalized.split(marker, 1)[1]
        target = ROOT / 'crates' / 'execution' / 'move-vm' / suffix
        return rel_to_manifest(manifest, target)

    # Upstream Sui crates reference ../../sui-execution/... . In the cleaned repo
    # that is crates/execution/sui-execution/...
    marker = 'sui-execution/'
    if marker in normalized:
        suffix = normalized.split(marker, 1)[1]
        target = ROOT / 'crates' / 'execution' / 'sui-execution' / suffix
        return rel_to_manifest(manifest, target)

    # Old generated cleanup passes sometimes left paths like
    # ../../../../../execution/move-vm/... which escape to repo-root/execution.
    marker = 'execution/move-vm/'
    if marker in normalized and not normalized.startswith('../move-vm/'):
        suffix = normalized.split(marker, 1)[1]
        target = ROOT / 'crates' / 'execution' / 'move-vm' / suffix
        return rel_to_manifest(manifest, target)

    marker = 'execution/sui-execution/'
    if marker in normalized and not normalized.startswith('../sui-execution/'):
        suffix = normalized.split(marker, 1)[1]
        target = ROOT / 'crates' / 'execution' / 'sui-execution' / suffix
        return rel_to_manifest(manifest, target)

    # Upstream latest sui-execution cuts sometimes used path="../../../../.." to
    # mean a latest Move crate in the original upstream layout. Replace the known
    # package dependency names when they appear in that exact form.
    line_target = {
        'move-abstract-interpreter': ROOT / 'crates/execution/move-vm/move/crates/move-abstract-interpreter',
        'move-bytecode-verifier': ROOT / 'crates/execution/move-vm/move/crates/move-bytecode-verifier',
        'move-vm-runtime': ROOT / 'crates/execution/move-vm/move/crates/move-vm-runtime',
        'move-vm-profiler': ROOT / 'crates/execution/move-vm/move/crates/move-vm-profiler',
        'move-regex-borrow-graph': ROOT / 'crates/execution/move-vm/move/crates/move-regex-borrow-graph',
    }
    if normalized in {'../../..', '../../../../..'}:
        # Let the caller line-context handler deal with this; returning None here
        # prevents blind root rewrites.
        return None

    return None


def patch_known_root_paths(manifest: Path, text: str) -> str:
    # Direct known fixes from the domain layout move.
    known = {
        'move-bytecode-verifier = { path = "../../.." }': 'move-bytecode-verifier = { path = "../move-vm/move/crates/move-bytecode-verifier" }',
        'move-vm-runtime = { path = "../../..", features = ["tiered-gas"] }': 'move-vm-runtime = { path = "../move-vm/move/crates/move-vm-runtime", features = ["tiered-gas"] }',
        'move-abstract-interpreter-latest = { path = "../../..", package = "move-abstract-interpreter" }': 'move-abstract-interpreter-latest = { path = "../move-vm/move/crates/move-abstract-interpreter", package = "move-abstract-interpreter" }',
        'move-bytecode-verifier-latest = { path = "../../..", package = "move-bytecode-verifier" }': 'move-bytecode-verifier-latest = { path = "../move-vm/move/crates/move-bytecode-verifier", package = "move-bytecode-verifier" }',
        'move-vm-runtime-latest = { path = "../../..", package = "move-vm-runtime" }': 'move-vm-runtime-latest = { path = "../move-vm/move/crates/move-vm-runtime", package = "move-vm-runtime" }',
        'move-bytecode-verifier = { path = "../../../../.." }': 'move-bytecode-verifier = { path = "../../../move-vm/move/crates/move-bytecode-verifier" }',
        'move-vm-runtime = { path = "../../../../.." }': 'move-vm-runtime = { path = "../../../move-vm/move/crates/move-vm-runtime" }',
        'move-vm-profiler = { path = "../../../../.." }': 'move-vm-profiler = { path = "../../../move-vm/move/crates/move-vm-profiler" }',
        'move-regex-borrow-graph = { path = "../../../../.." }': 'move-regex-borrow-graph = { path = "../../../move-vm/move/crates/move-regex-borrow-graph" }',
    }
    for old, new in known.items():
        text = text.replace(old, new)
    return text


changed: list[str] = []
for cargo in ROOT.rglob('Cargo.toml'):
    if any(part in SKIP_PARTS for part in cargo.parts):
        continue
    text = cargo.read_text(encoding='utf-8', errors='replace')
    new = patch_known_root_paths(cargo, text)

    pieces: list[str] = []
    last = 0
    for m in PATH_RE.finditer(new):
        rel = m.group(1)
        repl = rewrite_path(cargo, rel)
        if repl is None:
            continue
        pieces.append(new[last:m.start(1)])
        pieces.append(repl)
        last = m.end(1)
    if pieces:
        pieces.append(new[last:])
        new = ''.join(pieces)

    if new != text:
        cargo.write_text(new, encoding='utf-8')
        changed.append(str(cargo.relative_to(ROOT)))

out = ROOT / 'reports' / 'upstream-direct-path-repair.txt'
out.parent.mkdir(parents=True, exist_ok=True)
if changed:
    out.write_text('Rewritten direct Cargo paths:\n' + '\n'.join(changed) + '\n', encoding='utf-8')
    print(f'upstream direct path repair: rewritten {len(changed)} manifests')
else:
    out.write_text('No Cargo direct path rewrites were needed.\n', encoding='utf-8')
    print('upstream direct path repair: no rewrites needed')

#!/usr/bin/env python3
"""
Remove jemalloc from the Windows dependency graph.

This handles both forms exposed by the cleaned Sui repo:
1. Direct tikv-jemalloc-* dependencies.
2. Indirect RocksDB jemalloc via `rocksdb = { features = ["jemalloc"] }`, which
   resolves to librocksdb-sys -> tikv-jemalloc-sys and fails on Windows GNU.

The repair keeps jemalloc available for Linux builds but prevents Windows GNU from
attempting to run jemalloc's Unix configure script.

Safe to run repeatedly.
"""
from __future__ import annotations

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PLAIN_KINDS = {"dependencies", "dev-dependencies", "build-dependencies"}
WORKSPACE_KINDS = {"workspace.dependencies"}
LINUX_TARGET = {
    "dependencies": "[target.'cfg(target_os = \"linux\")'.dependencies]",
    "dev-dependencies": "[target.'cfg(target_os = \"linux\")'.dev-dependencies]",
    "build-dependencies": "[target.'cfg(target_os = \"linux\")'.build-dependencies]",
}
SECTION_RE = re.compile(r"^\s*\[(?P<header>[^\]]+)\]\s*$")
TARGET_KIND_RE = re.compile(r"^target\..*\.(?P<kind>dependencies|dev-dependencies|build-dependencies)$")
ROCKS_JEM_RE = re.compile(r"^\s*rocksdb\s*=.*features\s*=\s*\[[^\]]*\bjemalloc\b[^\]]*\]", re.M)
DIRECT_JEM_RE = re.compile(r"tikv-jemalloc")


def has_jemalloc_text(text: str) -> bool:
    return bool(DIRECT_JEM_RE.search(text) or ROCKS_JEM_RE.search(text))


def line_is_jemalloc_dep(line: str) -> bool:
    return "tikv-jemalloc" in line or bool(ROCKS_JEM_RE.search(line))


def section_kind(header: str) -> str | None:
    h = header.strip()
    if h in PLAIN_KINDS or h in WORKSPACE_KINDS:
        return h
    m = TARGET_KIND_RE.match(h)
    if m:
        return m.group("kind")
    return None


def is_target_header(header: str) -> bool:
    return header.strip().startswith("target.")

changed: list[str] = []
reports: list[str] = []

for manifest in ROOT.rglob("Cargo.toml"):
    rel = manifest.relative_to(ROOT)
    if "target" in rel.parts or ".upstream-tmp" in rel.parts:
        continue
    text = manifest.read_text(encoding="utf-8", errors="replace")
    if not has_jemalloc_text(text):
        continue

    lines = text.splitlines(keepends=True)
    sections: list[tuple[int, int, str]] = []
    cur_start = None
    cur_header = None
    for idx, line in enumerate(lines):
        m = SECTION_RE.match(line)
        if m:
            if cur_start is not None and cur_header is not None:
                sections.append((cur_start, idx, cur_header))
            cur_start = idx
            cur_header = m.group("header")
    if cur_start is not None and cur_header is not None:
        sections.append((cur_start, len(lines), cur_header))

    out: list[str] = []
    last = 0
    moved: dict[str, list[str]] = {k: [] for k in PLAIN_KINDS}
    did_change = False

    for start, end, header in sections:
        out.extend(lines[last:start])
        block = lines[start:end]
        block_text = "".join(block)
        kind = section_kind(header)

        if kind == "workspace.dependencies":
            # Workspace keys are declarations only. Keep them so Linux-only sections
            # can still inherit and Cargo manifests still parse.
            out.extend(block)
        elif is_target_header(header) and kind in PLAIN_KINDS and has_jemalloc_text(block_text):
            # Any target section containing direct jemalloc or rocksdb's jemalloc
            # feature must be Linux-only. cfg(not(target_env="msvc")) matches
            # Windows GNU, so it is not enough.
            new_header = LINUX_TARGET[kind]
            if block[0].strip() != new_header:
                block[0] = re.sub(r"^\s*\[[^\]]+\]", new_header, block[0])
                reports.append(f"{rel}: retargeted [{header}] to Linux-only")
                did_change = True
            out.extend(block)
        elif header.strip() in PLAIN_KINDS and has_jemalloc_text(block_text):
            # Move plain package lines that introduce jemalloc into Linux-only
            # target sections.
            new_block = [block[0]]
            for line in block[1:]:
                if line_is_jemalloc_dep(line):
                    moved[header.strip()].append(line)
                    reports.append(f"{rel}: moved `{line.strip()}` from [{header.strip()}] to Linux-only target section")
                    did_change = True
                else:
                    new_block.append(line)
            out.extend(new_block)
        else:
            out.extend(block)
        last = end
    out.extend(lines[last:])

    for kind in ("dependencies", "dev-dependencies", "build-dependencies"):
        vals = []
        seen = set()
        for line in moved[kind]:
            key = line.strip()
            if key and key not in seen:
                vals.append(line)
                seen.add(key)
        if vals:
            out.append("\n" + LINUX_TARGET[kind] + "\n")
            out.extend(vals)

    new_text = "".join(out)
    if new_text != text:
        manifest.write_text(new_text, encoding="utf-8")
        changed.append(str(rel))

report = ROOT / "reports" / "windows-jemalloc-repair.txt"
report.parent.mkdir(parents=True, exist_ok=True)
body = []
if changed:
    body.append("Patched manifests so direct jemalloc and RocksDB jemalloc are Linux-only:\n")
    body.extend(f"- {p}\n" for p in changed)
else:
    body.append("No manifest changes were needed.\n")
if reports:
    body.append("\nDetails:\n")
    body.extend(f"- {r}\n" for r in reports)
report.write_text("".join(body), encoding="utf-8")
print(f"windows jemalloc repair patched {len(changed)} manifest(s)")

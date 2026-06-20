#!/usr/bin/env python3
"""Sync upstream Sui crates into the cleaned domain layout.

This script is intentionally optional: the repository includes the upstream files.
Run it only when refreshing from a newer Sui checkout.
"""
from __future__ import annotations
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else None
if SRC is None or not (SRC / 'Cargo.toml').exists():
    print('error: pass the upstream Sui source root', file=sys.stderr)
    sys.exit(1)

# (upstream crates/<name>, cleaned destination)
CRATE_MAP: list[tuple[str, str]] = [
    ('sui-analytics-indexer', 'crates/api/analytics-indexer'),
    ('sui-analytics-indexer-derive', 'crates/api/analytics-indexer-derive'),
    ('sui-data-ingestion-core', 'crates/api/data-ingestion'),
    ('sui-faucet', 'crates/api/faucet'),
    ('sui-indexer-alt', 'crates/api/indexer'),
    ('sui-indexer-alt-consistent-api', 'crates/api/indexer-consistent-api'),
    ('sui-indexer-alt-framework', 'crates/api/indexer-framework'),
    ('sui-indexer-alt-graphql', 'crates/api/indexer-graphql'),
    ('sui-indexer-alt-jsonrpc', 'crates/api/indexer-jsonrpc'),
    ('sui-indexer-alt-metrics', 'crates/api/indexer-metrics'),
    ('sui-indexer-alt-reader', 'crates/api/indexer-reader'),
    ('sui-json', 'crates/api/json'),
    ('sui-json-rpc', 'crates/api/json-rpc'),
    ('sui-json-rpc-api', 'crates/api/json-rpc-api'),
    ('sui-kv-rpc', 'crates/api/kv-rpc'),
    ('sui-light-client', 'crates/api/light-client'),
    ('sui-open-rpc', 'crates/api/open-rpc'),
    ('sui-open-rpc-macros', 'crates/api/open-rpc-macros'),
    ('sui-rosetta', 'crates/api/rosetta'),
    ('sui-rpc-api', 'crates/api/rpc-api'),
    ('sui-rpc-resolver', 'crates/api/rpc-resolver'),
    ('sui-rpc-store', 'crates/api/rpc-store'),
    ('sui-sdk', 'crates/api/sdk'),
    ('sui-synthetic-ingestion', 'crates/api/synthetic-ingestion'),
    ('consensus-config', 'crates/config/consensus'),
    ('sui-default-config', 'crates/config/defaults'),
    ('sui-metric-checker', 'crates/config/metric-checker'),
    ('sui-protocol-config', 'crates/config/protocol'),
    ('sui-protocol-config-macros', 'crates/config/protocol-macros'),
    ('sui-config', 'crates/config/sui'),
    ('consensus-core', 'crates/consensus/core'),
    ('consensus-types', 'crates/consensus/types'),
    ('sui-fork', 'crates/crypto/fork'),
    ('sui-keys', 'crates/crypto/keys'),
    ('shared-crypto', 'crates/crypto/shared-crypto'),
    ('sui-tls', 'crates/crypto/tls'),
    ('sui-core', 'crates/execution/authority-core'),
    ('sui-framework', 'crates/execution/framework'),
    ('sui-framework-snapshot', 'crates/execution/framework-snapshot'),
    ('sui-move-build', 'crates/execution/move-build'),
    ('sui-move', 'crates/execution/move-cli'),
    ('sui-move-lsp', 'crates/execution/move-lsp'),
    ('sui-package-alt', 'crates/execution/package-alt'),
    ('sui-package-resolver', 'crates/execution/package-resolver'),
    ('sui-source-validation', 'crates/execution/source-validation'),
    ('sui-execution', 'crates/execution/sui-execution'),
    ('sui-execution-cut', 'crates/execution/sui-execution/cut'),
    ('sui-adapter-latest', 'crates/execution/sui-execution/latest/sui-adapter'),
    ('sui-move-natives-latest', 'crates/execution/sui-execution/latest/sui-move-natives'),
    ('sui-verifier-latest', 'crates/execution/sui-execution/latest/sui-verifier'),
    ('sui-adapter-v0', 'crates/execution/sui-execution/v0/sui-adapter'),
    ('sui-move-natives-v0', 'crates/execution/sui-execution/v0/sui-move-natives'),
    ('sui-verifier-v0', 'crates/execution/sui-execution/v0/sui-verifier'),
    ('sui-adapter-v1', 'crates/execution/sui-execution/v1/sui-adapter'),
    ('sui-move-natives-v1', 'crates/execution/sui-execution/v1/sui-move-natives'),
    ('sui-verifier-v1', 'crates/execution/sui-execution/v1/sui-verifier'),
    ('sui-adapter-v2', 'crates/execution/sui-execution/v2/sui-adapter'),
    ('sui-move-natives-v2', 'crates/execution/sui-execution/v2/sui-move-natives'),
    ('sui-verifier-v2', 'crates/execution/sui-execution/v2/sui-verifier'),
    ('sui-adapter-v3', 'crates/execution/sui-execution/v3/sui-adapter'),
    ('sui-move-natives-v3', 'crates/execution/sui-execution/v3/sui-move-natives'),
    ('sui-verifier-v3', 'crates/execution/sui-execution/v3/sui-verifier'),
    ('sui-authority-aggregation', 'crates/network/authority-aggregation'),
    ('sui-http', 'crates/network/http'),
    ('mysten-network', 'crates/network/mysten-network'),
    ('sui-proxy', 'crates/network/proxy'),
    ('sui-network', 'crates/network/sui-network'),
    ('sui-bridge', 'crates/protocol/bridge'),
    ('sui-bridge-schema', 'crates/protocol/bridge-schema'),
    ('sui-cost', 'crates/protocol/cost'),
    ('sui-display', 'crates/protocol/display'),
    ('sui-enum-compat-util', 'crates/protocol/enum-compat'),
    ('sui-field-count', 'crates/protocol/field-count'),
    ('sui-field-count-derive', 'crates/protocol/field-count-derive'),
    ('sui-json-rpc-types', 'crates/protocol/json-rpc-types'),
    ('sui-macros', 'crates/protocol/macros'),
    ('sui-name-service', 'crates/protocol/name-service'),
    ('sui-proc-macros', 'crates/protocol/proc-macros'),
    ('sui-transaction-builder', 'crates/protocol/transaction-builder'),
    ('sui-transaction-checks', 'crates/protocol/transaction-checks'),
    ('sui-types', 'crates/protocol/types'),
    ('sui', 'crates/runtime/cli'),
    ('mysten-common', 'crates/runtime/common'),
    ('sui-futures', 'crates/runtime/futures'),
    ('mysten-metrics', 'crates/runtime/metrics'),
    ('prometheus-closure-metric', 'crates/runtime/metrics/prometheus-closure'),
    ('sui-metrics-push-client', 'crates/runtime/metrics/push-client'),
    ('sui-node', 'crates/runtime/node'),
    ('mysten-service', 'crates/runtime/service'),
    ('sui-simulator', 'crates/runtime/simulator'),
    ('simulacrum', 'crates/runtime/simulator/simulacrum'),
    ('sui-telemetry', 'crates/runtime/telemetry'),
    ('telemetry-subscribers', 'crates/runtime/telemetry/subscribers'),
    ('bin-version', 'crates/runtime/version'),
    ('sui-consistent-store', 'crates/storage/consistent-store'),
    ('sui-data-store', 'crates/storage/data-store'),
    ('sui-indexer-alt-consistent-store', 'crates/storage/indexer-consistent-store'),
    ('sui-indexer-alt-object-store', 'crates/storage/indexer-object-store'),
    ('sui-indexer-alt-schema', 'crates/storage/indexer-schema'),
    ('sui-indexer-alt-framework-store-traits', 'crates/storage/indexer-store-traits'),
    ('sui-inverted-index', 'crates/storage/inverted-index'),
    ('sui-kvstore', 'crates/storage/kvstore'),
    ('sui-pg-db', 'crates/storage/pg-db'),
    ('sui-snapshot', 'crates/storage/snapshot'),
    ('sui-sql-macro', 'crates/storage/sql-macro'),
    ('sui-storage', 'crates/storage/sui-storage'),
    ('typed-store', 'crates/storage/typed-store'),
    ('typed-store-derive', 'crates/storage/typed-store-derive'),
    ('typed-store-error', 'crates/storage/typed-store-error'),
    ('anemo-benchmark', 'bench/network/anemo'),
    ('sui-rpc-benchmark', 'bench/rpc'),
    ('sui-rpc-loadgen', 'bench/rpc-loadgen'),
    ('sui-single-node-benchmark', 'bench/single-node'),
    ('sui-benchmark', 'bench/sui-benchmark'),
    ('consensus-simtests', 'tests/consensus/simtests'),
    ('sui-e2e-tests', 'tests/e2e'),
    ('sui-cluster-test', 'tests/e2e/cluster'),
    ('sui-adapter-transactional-tests', 'tests/execution/adapter-transactional'),
    ('sui-framework-tests', 'tests/execution/framework'),
    ('sui-transactional-test-runner', 'tests/execution/transactional-runner'),
    ('sui-upgrade-compatibility-transactional-tests', 'tests/execution/upgrade-compatibility'),
    ('sui-verifier-transactional-tests', 'tests/execution/verifier-transactional'),
    ('sui-test-transaction-builder', 'tests/fixtures/transaction-builder'),
    ('transaction-fuzzer', 'tests/fuzz/transaction-fuzzer'),
    ('sui-json-rpc-tests', 'tests/json-rpc'),
    ('sui-genesis-builder', 'tools/genesis-builder'),
    ('sui-package-dump', 'tools/package-dump'),
    ('sui-package-management', 'tools/package-management'),
    ('sui-replay', 'tools/replay'),
    ('sui-replay-2', 'tools/replay-2'),
    ('sui-tool', 'tools/sui-tool'),
    ('sui-surfer', 'tools/surfer'),
    ('sui-swarm', 'tools/swarm'),
    ('sui-swarm-config', 'tools/swarm-config'),
    ('test-cluster', 'tools/test-cluster'),
    ('sui-test-validator', 'tools/test-validator'),
    ('x', 'tools/x'),
]

changed: list[str] = []
missing: list[str] = []
for upstream_name, dest_rel in CRATE_MAP:
    src = SRC / 'crates' / upstream_name
    dest = ROOT / dest_rel
    if not src.exists():
        missing.append(upstream_name)
        continue
    if dest.exists():
        shutil.rmtree(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(src, dest)
    changed.append(dest_rel)

if (SRC / 'NOTICE').exists():
    shutil.copy2(SRC / 'NOTICE', ROOT / 'NOTICE.upstream')

out = ROOT / 'reports' / 'sync-upstream-domain-crates.txt'
out.parent.mkdir(parents=True, exist_ok=True)
lines = ['Synced upstream Sui crates into clean domains:', *changed, '']
if missing:
    lines += ['Missing optional upstream crates:', *missing, '']
out.write_text('
'.join(lines), encoding='utf-8')
print(f'synced {len(changed)} upstream crates into clean domain layout')
if missing:
    print(f'warning: {len(missing)} optional upstream crates were not present; see {out}')

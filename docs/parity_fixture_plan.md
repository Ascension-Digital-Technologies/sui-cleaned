# Differential Fixture Plan

## Fixture classes

1. BCS primitives and enum variant boundaries.
2. TransactionData and TransactionKind variants.
3. User signatures, multisig, zkLogin/passkey/authenticator variants when supported by protocol version.
4. Object layouts, object refs, owners, packages, dynamic fields.
5. TransactionEffects V1/V2 bytes and digests.
6. Events and event digest parity.
7. Checkpoint contents, checkpoint summary, signatures, end-of-epoch payloads.
8. Genesis, committee, validator metadata, protocol config snapshots.
9. Consensus blocks, ancestors, votes, commits, rejected transactions, commit timestamps.
10. Replay traces: input transaction + starting state -> exact effects/checkpoint output.

## Output format

```text
fixtures/
  bcs/
  tx/
  auth/
  objects/
  effects/
  events/
  checkpoints/
  genesis/
  consensus/
  replay/
```

Each fixture should have:

```json
{
  "name": "string",
  "upstream_commit": "sha",
  "protocol_version": 0,
  "input_hex": "...",
  "expected_hex": "...",
  "expected_digest": "...",
  "notes": "..."
}
```

## Rule

No synthetic fixture can replace an official upstream-generated fixture. Synthetic fixtures are allowed only for local negative tests.

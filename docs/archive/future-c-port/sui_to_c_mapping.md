# Sui Reference to Suidancer C Mapping

This document is the bridge between the cleaned Sui reference tree and the low-level C implementation.

| Clean reference | C target | Required parity gate |
|---|---|---|
| `protocol/types` | `src/protocol/` + `include/suidancer/protocol.h` | Decode/encode/hash parity for transaction/object/effects/checkpoint bytes |
| `protocol/config` | `src/protocol/config.c` | Protocol version feature/gas config parity |
| `crypto/shared-crypto` | `src/crypto/` + `include/suidancer/crypto.h` | Signature verification and digest parity |
| `consensus/core` | `src/consensus/` + `include/suidancer/consensus.h` | Mysticeti/universal committer decision parity |
| `execution/authority-core` | `src/execution/` | Transaction validity, object lock, effects, checkpoint ordering parity |
| `execution/sui-execution` | `src/execution/move_adapter.c` | Full Move execution adapter parity |
| `execution/framework` | `src/execution/natives/` | Sui framework native function parity |
| `storage/sui-storage` | `src/state/` + `src/checkpoint/` | Durable object/effects/checkpoint storage parity |
| `network/sui-network` | `src/net/` | Handshake, transaction submission, state sync, consensus transport parity |
| `tools/replay` | `tests/differential/` | Captured upstream traces replay to identical outputs |

## C repo shape

```text
suidancer/
  include/suidancer/
    protocol.h
    bcs.h
    crypto.h
    consensus.h
    execution.h
    checkpoint.h
    state.h
    net.h
  src/
    core/
    crypto/
    bcs/
    protocol/
    consensus/
    execution/
    state/
    checkpoint/
    net/
    runtime/
  apps/
    validator/
    client/
  tests/
    unit/
    differential/
  bench/
  docs/
```

## Completion standard

A C module is not complete because it parses a shape. It is complete when the same Sui input bytes, epoch/protocol config, and state produce the same validity result, execution result, events, effects bytes, checkpoint contents, consensus commit order, and recovery behavior.

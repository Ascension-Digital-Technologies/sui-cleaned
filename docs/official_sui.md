# Official Sui Context

This repository is an unofficial cleaned-up workspace derived from Sui-compatible source code. The official project is maintained by Mysten Labs.

- Official repository: <https://github.com/MystenLabs/sui>
- Website: <https://sui.io>
- Documentation: <https://docs.sui.io>

## Overview

The official Sui README describes Sui as a next-generation smart contract platform focused on high throughput, low latency, and an asset-oriented programming model powered by Move.

Sui is written in Rust and supports smart contracts written in Move. Move programs define assets and the rules for creating, transferring, and mutating those assets.

Sui is maintained by a permissionless set of authorities. Its design allows many common transactions to be processed in parallel, and common payment or asset-transfer paths can use lower-latency primitives rather than routing every transaction through one uniform consensus path.

The official README also describes SUI as the native token used for gas and delegated stake. Authority voting power is based on delegated stake within an epoch, and authorities are periodically reconfigured.

## Relationship to this repository

Sui Clean does not replace official Sui releases. It provides a cleaner source layout for browsing, building, auditing, and experimenting with a Sui-compatible Rust workspace.

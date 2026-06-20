# Security Policy

Sui Clean is an unofficial cleaned-up Sui workspace. It is not an official Sui or Mysten Labs security-reporting channel.

## Reporting security issues

If a vulnerability is in upstream Sui behavior or code, report it through the official upstream Sui/Mysten Labs security process.

If a vulnerability is introduced by this cleaned-up repository layout, scripts, GitHub workflow, or local build tooling, open a private report through the repository's GitHub security advisory flow if available, or contact the repository maintainer directly.

## What belongs here

Security reports for this repo should focus on:

- unsafe or incorrect local scripts,
- broken supply-chain assumptions,
- accidental credential exposure,
- malicious workflow behavior,
- incorrect vendoring/sync logic,
- layout changes that silently alter security-sensitive behavior.

## What does not belong here

Do not use this repository as the primary disclosure channel for vulnerabilities in official Sui releases, validators, wallets, bridges, or production networks.

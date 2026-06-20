# Vendor Manifest

Primary synced paths:

```text
vendor/sui/crates/*
vendor/sui/move-vm/*
```

Canonical cleaned paths used by rewritten dependencies:

```text
crates/execution/move-vm/*
crates/execution/sui-execution/*
```

The exact copied crate list is generated from `manifests/vendor_sui_crates.txt` and the
sync scripts in `scripts/fetch-upstream-deps.*`.

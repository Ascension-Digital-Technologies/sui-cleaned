SHELL := /bin/sh

.PHONY: status audit tiers scripts check-root check-layout repair repair-windows metadata check check-fast check-core check-workspace check-sui-compat check-full fmt clippy clippy-workspace clippy-full package-map

status:
	cargo xtask status

audit:
	cargo xtask audit

tiers:
	cargo xtask tiers

scripts:
	cargo xtask scripts

check-root:
	cargo xtask check-root

check-layout:
	cargo xtask check-layout

repair: repair-windows

repair-windows:
	cargo xtask repair-windows

metadata:
	mkdir -p target/xtask-output
	cargo xtask metadata > target/xtask-output/cargo-metadata.json

check: check-fast

check-fast:
	cargo xtask check-fast

check-core:
	cargo xtask check-core

check-workspace:
	cargo xtask check-workspace

check-sui-compat:
	cargo xtask check-sui-compat

check-full:
	cargo xtask check-full

fmt:
	cargo xtask fmt

clippy: clippy-workspace

clippy-workspace:
	cargo xtask clippy-workspace

clippy-full:
	cargo xtask clippy-full

package-map:
	python3 scripts/lib/package-map.py

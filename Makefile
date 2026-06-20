SHELL := /bin/sh

.PHONY: status audit tiers scripts check-root sync repair-windows metadata check check-fast check-core check-workspace check-sui-compat check-full fmt clippy clippy-workspace clippy-full fetch-upstream-deps package-map repair-move-uint

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

sync:
	cargo xtask sync $(SUI)

repair-windows:
	cargo xtask repair-windows

metadata:
	cargo xtask metadata > reports/cargo-metadata.json

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

fetch-upstream-deps:
	scripts/fetch-upstream-deps.sh $(SUI)

repair-move-uint:
	python3 scripts/repair-move-uint-version.py

package-map:
	python3 scripts/package-map.py

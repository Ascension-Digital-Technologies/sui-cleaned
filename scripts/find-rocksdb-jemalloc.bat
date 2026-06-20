@echo off
set ROOT=%~dp0..
cd /d "%ROOT%"
findstr /S /N /I "rocksdb.*jemalloc tikv-jemalloc" Cargo.toml crates\*.toml 2>nul
cargo tree -i tikv-jemalloc-sys --target x86_64-pc-windows-gnu

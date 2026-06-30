# Run tests for owned Move language crates
set -e
echo "Running owned Move language tests"
cd "$(dirname "$0")"
echo "Excluding prover Move tests"
cargo nextest run -E '!test(run_all::simple_build_with_docs/args.txt) and !test(run_test::nested_deps_bad_parent/Move.toml)' --workspace --no-fail-fast --retries 3
echo "Running tracing-specific tests"
cargo nextest run -p move-cli --features tracing

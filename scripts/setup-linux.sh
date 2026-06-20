#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "scripts/setup-linux.sh currently supports Debian/Ubuntu apt-based systems." >&2
  echo "Install clang, libclang-dev, build-essential, pkg-config, cmake, zlib, bz2, snappy, and zstd development packages manually." >&2
  exit 1
fi

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

$SUDO apt-get update
$SUDO apt-get install -y \
  build-essential \
  clang \
  cmake \
  libbz2-dev \
  libclang-dev \
  libsnappy-dev \
  libzstd-dev \
  llvm-dev \
  pkg-config \
  zlib1g-dev

mkdir -p .cargo
LLVM_LIBDIR="$(llvm-config --libdir)"
CLANG_BIN="$(command -v clang)"
cat > .cargo/env-linux.sh <<EOF
# Source before direct Cargo commands on Linux if bindgen cannot find libclang:
#   source .cargo/env-linux.sh
export LIBCLANG_PATH="${LLVM_LIBDIR}"
export CLANG_PATH="${CLANG_BIN}"
EOF

echo "Linux native build dependencies installed."
echo "LIBCLANG_PATH=${LLVM_LIBDIR}"
echo "CLANG_PATH=${CLANG_BIN}"
echo "For direct cargo commands, optionally run: source .cargo/env-linux.sh"

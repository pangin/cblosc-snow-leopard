#!/bin/bash
set -euo pipefail
set +o pipefail   # 'unzip -Z1 | head' etc. must not abort
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPS_BUILD="$ROOT/build"
DEPS_PREFIX="$ROOT/prefix"
SL="$ROOT"
TOOLCHAIN="$ROOT/toolchain/i386-darwin10.cmake"
MP=/opt/local
export PATH="$ROOT/toolchain/bin:$PATH"
export MACOSX_DEPLOYMENT_TARGET=10.6
mkdir -p "$DEPS_BUILD" "$DEPS_PREFIX"

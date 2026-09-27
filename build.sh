#!/bin/bash
# Build c-blosc 1.17.0 static for i386/10.6 (zstd off), and install a
# BloscConfig.cmake providing Blosc::blosc (OpenVDB wants CONFIG-mode Blosc,
# which upstream c-blosc does not ship).
. "$(dirname "$0")/common.sh"
set +o pipefail
SRCDIR="$DEPS_BUILD/c-blosc-1.17.0"
URL="https://github.com/Blosc/c-blosc/archive/refs/tags/v1.17.0.zip"
mkdir -p "$DEPS_BUILD" "$DEPS_PREFIX"; cd "$DEPS_BUILD"
[ -d "$SRCDIR" ] || { [ -f c-blosc-1.17.0.zip ] || curl -fL -o c-blosc-1.17.0.zip "$URL"; unzip -q c-blosc-1.17.0.zip; }
cmake -S "$SRCDIR" -B "$DEPS_BUILD/c-blosc-1.17.0-build" \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_PREFIX_PATH="$DEPS_PREFIX;$MP" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_BENCHMARKS=OFF -DBUILD_SHARED=OFF -DBUILD_STATIC=ON -DBUILD_TESTS=OFF \
  -DDEACTIVATE_AVX2=ON -DDEACTIVATE_SSE2=ON -DDEACTIVATE_ZSTD=ON -DPREFER_EXTERNAL_ZLIB=ON
cmake --build "$DEPS_BUILD/c-blosc-1.17.0-build" -j2 && cmake --install "$DEPS_BUILD/c-blosc-1.17.0-build"
rc=$?
# CONFIG package for OpenVDB (Blosc::blosc)
CFG="$DEPS_PREFIX/lib/cmake/Blosc"; mkdir -p "$CFG"
cat > "$CFG/BloscConfig.cmake" <<CFGEOF
set(Blosc_FOUND TRUE)
set(Blosc_VERSION 1.17.0)
get_filename_component(_blosc_pfx "\${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
set(Blosc_INCLUDE_DIRS "\${_blosc_pfx}/include")
set(Blosc_LIBRARIES "\${_blosc_pfx}/lib/libblosc.a")
if(NOT TARGET Blosc::blosc)
  add_library(Blosc::blosc STATIC IMPORTED)
  set_target_properties(Blosc::blosc PROPERTIES
    IMPORTED_LOCATION "\${_blosc_pfx}/lib/libblosc.a"
    INTERFACE_INCLUDE_DIRECTORIES "\${_blosc_pfx}/include")
endif()
CFGEOF
cat > "$CFG/BloscConfigVersion.cmake" <<CFGEOF
set(PACKAGE_VERSION 1.17.0)
if(PACKAGE_VERSION VERSION_LESS PACKAGE_FIND_VERSION)
  set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
  if(PACKAGE_VERSION VERSION_EQUAL PACKAGE_FIND_VERSION)
    set(PACKAGE_VERSION_EXACT TRUE)
  endif()
endif()
CFGEOF
echo "BLOSC-DONE rc=$rc"; ls "$CFG"/*.cmake "$DEPS_PREFIX/lib/libblosc.a" 2>/dev/null

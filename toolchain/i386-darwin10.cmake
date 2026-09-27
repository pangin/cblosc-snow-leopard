# Cross/native toolchain: 32-bit Intel, Mac OS X 10.6, clang-16 (MacPorts).
# Key trick: the system /usr/lib/libc++ (2011-era) lacks std::filesystem and
# <charconv> symbols that libslic3r needs, so we link the LLVM-16 libc++.
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR i386)

set(MP        /opt/local)
set(LLVM      /opt/local/libexec/llvm-16)
set(LLVMCXX   ${LLVM}/lib/libc++)

# Wrappers force the newer MacPorts linker (ld64-274). The default ld64-127 hits
# "ld: internal error: atom not found in symbolIndex" on clang-16 i386
# exception-unwind output (it fails to link boost's b2, libslic3r, etc.).
set(CMAKE_C_COMPILER   ${CMAKE_CURRENT_LIST_DIR}/bin/clang)
set(CMAKE_CXX_COMPILER ${CMAKE_CURRENT_LIST_DIR}/bin/clang++)

set(CMAKE_OSX_ARCHITECTURES     i386  CACHE STRING "" FORCE)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.6  CACHE STRING "" FORCE)

# MacPorts legacy-support backfills libc/posix symbols missing on 10.6.
set(_ls_inc "-I${MP}/include/LegacySupport")
set(_c_flags   "${_ls_inc}")
set(_cxx_flags "${_ls_inc} -stdlib=libc++ -faligned-allocation")  # C++17 aligned new/delete via LLVM-16 libc++ (TBB over-aligned types); overrides the 10.13 availability check
set(CMAKE_C_FLAGS_INIT   "${_c_flags}"   CACHE STRING "")
set(CMAKE_CXX_FLAGS_INIT "${_cxx_flags}" CACHE STRING "")

# Link the modern libc++ first, then legacy-support; keep an rpath to the dylib.
set(_ld "-L${LLVMCXX} -Wl,-search_paths_first -Wl,-rpath,${LLVMCXX} -L${MP}/lib -lMacportsLegacySupport")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${_ld}" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${_ld}" CACHE STRING "")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${_ld}" CACHE STRING "")

# Find MacPorts-provided dependencies, then our own source-built prefix.
list(APPEND CMAKE_PREFIX_PATH ${MP})

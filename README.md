# cblosc-snow-leopard

Build **c-blosc 1.17.0** static for **Mac OS X 10.6.8 / i386**, and install a
`BloscConfig.cmake` exposing `Blosc::blosc` (OpenVDB wants CONFIG-mode Blosc,
which upstream c-blosc does not ship).

```sh
./build.sh      # -> prefix/lib/libblosc.a (i386) + prefix/lib/cmake/Blosc/
```

Key 10.6/i386 fixes: SSE2/AVX2 disabled; **zstd disabled** (its bundled
zstd-1.4.1 conflicts with a newer system zstd header); external zlib.

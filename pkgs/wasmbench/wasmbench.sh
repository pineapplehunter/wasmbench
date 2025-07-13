#!/usr/bin/env bash

set -euo pipefail

PATH=@path@

if [ -z "$1" ]; then
  echo no wasm specified
  exit 1
fi

TMP_WAMR_AOT=$(mktemp --suffix .aot)
TMP_WASMTIME_CWASM=$(mktemp --suffix .cwasm)

cleanup() {
  echo cleaning tmporal files
  rm "$TMP_WAMR_AOT" "$TMP_WASMTIME_CWASM"
}

trap cleanup SIGINT

wamrc -o "$TMP_WAMR_AOT" "$1"
wasmtime compile -o "$TMP_WASMTIME_CWASM" "$1"

hyperfine --export-json time.json --warmup 2 -i \
  "wasmtime run $1" \
  "wasmtime run --allow-precompiled $TMP_WASMTIME_CWASM" \
  "wasmer run $1" \
  "wasmer run --singlepass $1" \
  "wasmer run --cranelift $1" \
  "wasmer run --llvm $1" \
  "wamr-aot $TMP_WAMR_AOT" \
  "wamr-classic $1" \
  "wamr-fast-interp $1" \
  # "wamr-fast-jit $1"
  # "wamr-lazy-jit $1" \
  # "wamr-jit $1" \

cleanup

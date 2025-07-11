#!/usr/bin/env bash

PATH=@path@

if [ -z "$1" ]; then
  echo no wasm specified
  exit 1
fi

TMP_AOT=$(mktemp --suffix .aot)

wamrc -o "$TMP_AOT" "$1"

hyperfine --export-json time.json --warmup 2 -i \
  "wasmtime run $1" \
  "wasmer run $1" \
  "wasmer run --singlepass $1" \
  "wasmer run --cranelift $1" \
  "wasmer run --llvm $1" \
  "wamr-classic $1" \
  "wamr-fast-interp $1" \
  "wamr-aot $TMP_AOT" \
  # "wamr-fast-jit $1"
  # "wamr-lazy-jit $1" \
  # "wamr-jit $1" \

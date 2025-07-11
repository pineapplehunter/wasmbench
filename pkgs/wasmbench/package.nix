{
  bash,
  hyperfine,
  lib,
  replaceVarsWith,
  wamr,
  wamrc,
  wasmer,
  wasmtime,
  writeShellScriptBin,
}:
let
  wrap-iwasm =
    name: package:
    writeShellScriptBin name ''
      ${package}/bin/iwasm "$@"
    '';

  wamr-classic = wrap-iwasm "wamr-classic" (
    wamr.override {
      enable_interp = true;
      enable_fast_interp = false;
      enable_aot = false;
      enable_jit = false;
      enable_fast_jit = false;
      enable_lazy_jit = false;
    }
  );
  wamr-fast-interp = wrap-iwasm "wamr-fast-interp" (
    wamr.override {
      enable_interp = true;
      enable_fast_interp = true;
      enable_aot = false;
      enable_jit = false;
      enable_fast_jit = false;
      enable_lazy_jit = false;
    }
  );
  wamr-aot = wrap-iwasm "wamr-aot" (
    wamr.override {
      enable_interp = false;
      enable_fast_interp = false;
      enable_aot = true;
      enable_jit = false;
      enable_fast_jit = false;
      enable_lazy_jit = false;
    }
  );
  wamr-jit = wrap-iwasm "wamr-jit" (
    wamr.override {
      enable_interp = false;
      enable_fast_interp = false;
      enable_aot = false;
      enable_jit = true;
      enable_fast_jit = false;
      enable_lazy_jit = false;
    }
  );
  wamr-lazy-jit = wrap-iwasm "wamr-lazy-jit" (
    wamr.override {
      enable_interp = false;
      enable_fast_interp = false;
      enable_aot = false;
      enable_jit = true;
      enable_fast_jit = false;
      enable_lazy_jit = true;
    }
  );

in

replaceVarsWith {
  src = ./wasmbench.sh;

  replacements = {
    path = lib.makeBinPath [
      bash
      hyperfine
      wamr-aot
      wamr-classic
      wamr-fast-interp
      wamr-jit
      wamr-lazy-jit
      wamrc
      wasmer
      wasmtime
    ];
  };

  name = "wasmbench";
  dir = "bin";
  isExecutable = true;
  meta.mainProgram = "wasmbench";
}

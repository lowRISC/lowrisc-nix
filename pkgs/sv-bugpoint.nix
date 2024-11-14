# SPDX-FileCopyrightText: lowRISC contributors
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  sv-lang,
  fmt_11,
  python3,
}:
stdenv.mkDerivation {
  pname = "sv-bugpoint";
  version = "0-unstable-2025-11-25-bugpoint";

  src = fetchFromGitHub {
    owner = "antmicro";
    repo = "sv-bugpoint";
    rev = "1e078fa961ac5ade9e2506ce63c091b53ad9dbdb";
    hash = "sha256-HGWPtadi+L+cXHSWSPelOv0KOPnkjVGKchRaYfZwwFg=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_SLANG=${sv-lang.src}"
    "-DFETCHCONTENT_SOURCE_DIR_FMT=${fmt_11.src}"
    "-DSLANG_USE_MIMALLOC=OFF"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
    sv-lang
  ];

  meta = with lib; {
    description = "Minimizes SystemVerilog code while preserving a user-defined property of that code.";
    homepage = "https://github.com/antmicro/sv-bugpoint";
    license = licenses.asl20;
    maintainers = [];
    mainProgram = "sv-bugpoint";
    broken = sv-lang.meta.broken;
  };
}

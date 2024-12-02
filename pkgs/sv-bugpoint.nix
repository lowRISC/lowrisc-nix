# SPDX-FileCopyrightText: lowRISC contributors
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  sv-lang,
  fmt_10,
  python3,
}: let
  rev = "1e078fa961ac5ade9e2506ce63c091b53ad9dbdb";
in
  stdenv.mkDerivation {
    pname = "sv-bugpoint";
    # take the first 10 characters of the revision
    version = builtins.head (builtins.match "(.{10}).*" rev);

    src = fetchFromGitHub {
      owner = "antmicro";
      repo = "sv-bugpoint";
      inherit rev;
      hash = "sha256-HGWPtadi+L+cXHSWSPelOv0KOPnkjVGKchRaYfZwwFg=";
    };

    cmakeFlags = [
      "-DFETCHCONTENT_SOURCE_DIR_SLANG=${sv-lang.src.outPath}"
      "-DFETCHCONTENT_SOURCE_DIR_FMT=${fmt_10.src.outPath}"
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
      platforms = platforms.all;
    };
  }

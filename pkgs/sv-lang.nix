# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  fetchFromGitHub,
  boost182,
  catch2_3,
  fmt_10,
  cmake,
  ninja,
  python3,
}: let
  svLangDerivation = version: hash:
    stdenv.mkDerivation rec {
      pname = "sv-lang";
      inherit version;

      src = fetchFromGitHub {
        owner = "MikePopoloski";
        repo = "slang";
        rev = "v${version}";
        inherit hash;
      };

      cmakeFlags = [
        # fix for https://github.com/NixOS/nixpkgs/issues/144170
        "-DCMAKE_INSTALL_INCLUDEDIR=include"
        "-DCMAKE_INSTALL_LIBDIR=lib"

        "-DFETCHCONTENT_SOURCE_DIR_FMT=${fmt_10.src.outPath}"
        "-DFETCHCONTENT_SOURCE_DIR_CATCH2=${catch2_3.src.outPath}"

        "-DSLANG_INCLUDE_TESTS=${
          if doCheck
          then "ON"
          else "OFF"
        }"
        "-DSLANG_USE_MIMALLOC=OFF"
      ];

      nativeBuildInputs = [
        cmake
        python3
        ninja

        # though only used in tests, cmake will complain its absence when configuring
        catch2_3
      ];

      buildInputs = [
        boost182
      ];

      # TODO: a mysterious linker error occurs when building the unittests on darwin.
      # The error occurs when using catch2_3 in nixpkgs, not when fetching catch2_3 using CMake
      doCheck = !stdenv.isDarwin;

      meta = with lib; {
        description = "SystemVerilog compiler and language services";
        homepage = "https://github.com/MikePopoloski/slang";
        license = licenses.mit;
        maintainers = with maintainers; [sharzy];
        mainProgram = "slang";
        broken = stdenv.isDarwin;
        platforms = platforms.all;
      };
    };
in {
  sv-lang_6 = svLangDerivation "6.0" "sha256-mT8sfUz0H4jWM/SkV/uW4kmVKE9UQy6XieG65yJvIA8=";
  sv-lang_7 = svLangDerivation "7.0" "sha256-msSc6jw2xbEZfOwtqwFEDIKcwf5SDKp+j15lVbNO98g=";
}

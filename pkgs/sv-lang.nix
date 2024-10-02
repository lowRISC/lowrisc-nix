# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  fetchFromGitHub,
  boost182,
  catch2_3,
  cmake,
  ninja,
  python3,
}: let
  fmt = fetchFromGitHub {
    owner = "fmtlib";
    repo = "fmt";
    rev = "10.2.1";
    hash = "sha256-pEltGLAHLZ3xypD/Ur4dWPWJ9BGVXwqQyKcDWVmC3co=";
  };
  catch2 = fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    rev = "v3.5.3";
    hash = "sha256-A7vVRHMabm75Udy0fXwsPw4/JkXfjQq/MwmJukdS1Ic=";
  };
in
  stdenv.mkDerivation rec {
    pname = "sv-lang";
    version = "6.0";

    src = fetchFromGitHub {
      owner = "MikePopoloski";
      repo = "slang";
      rev = "v${version}";
      sha256 = "sha256-mT8sfUz0H4jWM/SkV/uW4kmVKE9UQy6XieG65yJvIA8=";
    };

    cmakeFlags = [
      # fix for https://github.com/NixOS/nixpkgs/issues/144170
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
      "-DCMAKE_INSTALL_LIBDIR=lib"

      "-DFETCHCONTENT_SOURCE_DIR_FMT=${fmt}"
      "-DFETCHCONTENT_SOURCE_DIR_CATCH2=${catch2}"

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
  }

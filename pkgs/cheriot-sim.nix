# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  lib,
  fetchFromGitHub,
  stdenv,
  zlib,
  gmp,
  ocaml,
  ocamlPackages,
  pkg-config,
  gnumake,
  z3,
}: let
  inherit (ocamlPackages) sail;
in
  stdenv.mkDerivation rec {
    pname = "cheriot-sim";
    version = "ade1ab2";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "cheriot-sail";
      rev = "ade1ab26dea99e5123477a2fa3563fd21e555470";
      fetchSubmodules = true;
      hash = "sha256-t/ABzvKc1W2MNkBgj4kZz0hpRONyzdM0YvD3YZQJUBE=";
    };

    buildInputs = [
      zlib
      gmp
    ];

    nativeBuildInputs = [
      ocaml
      pkg-config
      gnumake
      z3
    ];

    postPatch = lib.optionalString stdenv.isDarwin ''
      # If LTO is enabled, LLVM bitcode is produced and linking produces unrecognized file error.
      substituteInPlace Makefile --replace-fail " -flto=auto" ""
    '';

    makeFlags = [
      "SAIL=${sail}/bin/sail"
      "SAIL_DIR=${sail}/share/sail"
      "LEM_DIR=${ocamlPackages.lem}/share/lem"
      "csim"
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp c_emulator/cheriot_sim $out/bin/
    '';

    meta = {
      description = "Simulator built from the sail code model of the CHERIoT ISA";
      homepage = "https://github.com/microsoft/cheriot-sail";
      license = lib.licenses.bsd2;
      mainProgram = "cheriot_sim";
    };
  }

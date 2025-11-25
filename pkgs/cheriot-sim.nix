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
    version = "1.0";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "cheriot-sail";
      rev = "b9e7ab7dc9a3d13c045410c2431977237548d92f";
      fetchSubmodules = true;
      hash = "sha256-p9LEKihJBo3mP3pxJoq7ikV1sYxNtY/2w3OVvQz+Mvk=";
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

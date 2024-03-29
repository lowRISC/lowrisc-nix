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
}:
stdenv.mkDerivation rec {
  pname = "cheriot-sim";
  version = "e5038a0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "cheriot-sail";
    rev = "e5038a0ec5fcdf2f672d0a7ddf8446225fd86cf7";
    fetchSubmodules = true;
    hash = "sha256-umMN2ktOeV2Queocgi8qlYO464v/98+uTgbCkO9yLBA=";
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

  postPatch = ''
    for file in riscv_patches/*.patch; do
      (cd sail-riscv; patch -p1 < "../$file")
    done
  '';

  makeFlags = [
    "SAIL=${ocamlPackages.sail}/bin/sail"
    "SAIL_DIR=${ocamlPackages.sail}/share/sail"
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

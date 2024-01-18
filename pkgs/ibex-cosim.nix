# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  stdenv,
  dtc,
}:
stdenv.mkDerivation rec {
  pname = "ibex-cosim";
  version = "15fbd56";

  src = fetchFromGitHub {
    owner = "lowRISC";
    repo = "riscv-isa-sim";
    # branch ibex_cosim
    rev = "15fbd5680e44da699f828c67db15345822a47ef6";
    hash = "sha256-LK/IXmRHrGxaMRudcUYmeZV5eXU8eH7ruIw7kliumdY=";
  };

  nativeBuildInputs = [
    dtc
  ];

  configureFlags = [
    "--enable-commitlog"
    "--enable-misaligned"
  ];

  enableParallelBuilding = true;
}

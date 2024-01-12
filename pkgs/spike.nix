# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  spike,
}:
# The lowRISC Ibex processor (https://github.com/lowRISC/ibex) uses a fork of
# spike as an Instruction Set Simulator (ISS) for a cosimulation testbench in
# its Design Verification (DV) environment.
spike.overrideAttrs (_: prev: {
  src = fetchFromGitHub {
    owner = "lowRISC";
    repo = "riscv-isa-sim";
    rev = "ibex-cosim-v0.5";
    sha256 = "sha256-LK/IXmRHrGxaMRudcUYmeZV5eXU8eH7ruIw7kliumdY=";
  };
  configureFlags = (prev.configureFlags or []) ++ ["--enable-commitlog" "--enable-misaligned"];
})

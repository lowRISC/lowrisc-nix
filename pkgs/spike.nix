# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  fetchpatch,
  spike,
}:
# The lowRISC Ibex processor (https://github.com/lowRISC/ibex) uses a fork of
# spike as an Instruction Set Simulator (ISS) for a cosimulation testbench in
# its Design Verification (DV) environment.
spike.overrideAttrs (_: prev: {
  pname = "spike-ibex-cosim";
  version = "0.5-dev";

  src = fetchFromGitHub {
    owner = "lowRISC";
    repo = "riscv-isa-sim";
    # Changes for cosimulation currently track the head of the 'ibex-cosim' branch.
    rev = "4b97396656485a129119deaec2ba35e5bf354841";
    sha256 = "sha256-oF2poKMYoYXytqo/t6eqngJgrr4WFHvKj/cKsGQ88DQ=";
  };

  configureFlags = (prev.configureFlags or []) ++ ["--enable-commitlog" "--enable-misaligned"];
})

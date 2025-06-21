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
    rev = "6d5b660865d4941cc7847fb52d8aa6e8148c1dd5";
    sha256 = "sha256-weIHJLlh/e7YqPR0JQMLOCXbR38B1w0/ONlFAaf7Oww=";
  };

  configureFlags = (prev.configureFlags or []) ++ ["--enable-commitlog" "--enable-misaligned"];
})

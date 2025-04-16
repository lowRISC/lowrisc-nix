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
    rev = "39612f93837122a980395487f55b2d97d29d70c1";
    sha256 = "sha256-GjOaaBggqU0eNXL2wsATNDaSEjVi6Kwaj8y2khx+4gA=";
  };

  configureFlags = (prev.configureFlags or []) ++ ["--enable-commitlog" "--enable-misaligned"];
})

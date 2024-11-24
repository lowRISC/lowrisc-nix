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
  version = "0.5";

  src = fetchFromGitHub {
    owner = "lowRISC";
    repo = "riscv-isa-sim";
    rev = "ibex-cosim-v0.5";
    sha256 = "sha256-LK/IXmRHrGxaMRudcUYmeZV5eXU8eH7ruIw7kliumdY=";
  };

  patches = [
    (fetchpatch {
      name = "fesvr-fix-compilation-with-gcc-13.patch";
      url = "https://github.com/riscv-software-src/riscv-isa-sim/commit/0a7bb5403d0290cea8b2356179d92e4c61ffd51d.patch";
      hash = "sha256-JUMTbGawvLkoOWKkruzLzUFQytVR3wqTlGu/eegRFEE=";
    })
  ];

  configureFlags = (prev.configureFlags or []) ++ ["--enable-commitlog" "--enable-misaligned"];
})

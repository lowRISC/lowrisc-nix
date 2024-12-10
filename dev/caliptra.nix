# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  verilator_caliptra,
  riscv64-gcc_caliptra,
}:
pkgs.mkShell {
  name = "caliptra";

  nativeBuildInputs = with pkgs; [
    verilator_caliptra
    riscv64-gcc_caliptra
    hjson
  ];
}

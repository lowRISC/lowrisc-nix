# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  verilator_caliptra,
  riscv64-gcc_caliptra,
  python3,
}: let
  pyEnv = python3.withPackages (
    ps:
      with ps; [
        pyyaml
      ]
  );
in
  pkgs.mkShell {
    name = "caliptra";

    nativeBuildInputs = with pkgs; [
      verilator_caliptra
      riscv64-gcc_caliptra
      hjson
      pyEnv
    ];
  }

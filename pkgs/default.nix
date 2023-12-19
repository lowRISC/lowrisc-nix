# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  pkgs,
  inputs,
  ...
}: {
  verilator_ot = import ./verilator {inherit pkgs;};
  python_ot = pkgs.callPackage ./python_ot {inherit inputs;};
}

# Copyright lowRISC Contributors.
# Licensed under both the MIT License and the Apache License, Version 2.
# See LICENSE-MIT and LICENSE-APACHE for details.
# SPDX-License-Identifier: MIT OR Apache-2.0
{
  pkgs,
  inputs,
  ...
}: {
  verilator_ot = import ./verilator {inherit pkgs;};
  python_ot = pkgs.callPackage ./python_ot {inherit inputs;};
}

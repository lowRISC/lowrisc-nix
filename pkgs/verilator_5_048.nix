# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  verilator,
}:
verilator.overrideAttrs (_old: {
  version = "5.048";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v5.048";
    sha256 = "sha256-xvqqgbW7L07+NBYzGN2KLhwir58ByShxo4VVPI3pgZk=";
  };
})

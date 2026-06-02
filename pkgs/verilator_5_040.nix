# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  verilator,
}:
verilator.overrideAttrs rec {
  version = "5.040";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v${version}";
    sha256 = "sha256-S+cDnKOTPjLw+sNmWL3+Ay6+UM8poMadkyPSGd3hgnc=";
  };
}

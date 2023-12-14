# Copyright lowRISC Contributors.
# Licensed under both the MIT License and the Apache License, Version 2.
# See LICENSE-MIT and LICENSE-APACHE for details.
# SPDX-License-Identifier: MIT OR Apache-2.0
{pkgs, ...}:
pkgs.verilator.overrideAttrs rec {
  version = "4.210";
  src = pkgs.fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v${version}";
    sha256 = "sha256-evOV+mo+9VfKAEUSZJRT0O3AIVRS8GO4408vDxVmjrU=";
  };
  patches = [./fix.patch];
  doCheck = false;
}

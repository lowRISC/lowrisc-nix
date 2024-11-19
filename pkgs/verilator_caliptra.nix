# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  pkgs,
  systemc,
  gcc12Stdenv,
}:
(pkgs.verilator.override {
  # Long symbols are broken when compiled with GCC 13: https://github.com/verilator/verilator/issues/4204
  stdenv = gcc12Stdenv;
  systemc = systemc.override {stdenv = gcc12Stdenv;};
})
.overrideAttrs rec {
  version = "5.012";
  src = pkgs.fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v${version}";
    sha256 = "sha256-Y6GkIgkauayJmGhOQg2kWjbcxYVIob6InMopv555Lb8=";
  };
  patches = [];
  meta = {
    broken = gcc12Stdenv.isDarwin;
  };
}

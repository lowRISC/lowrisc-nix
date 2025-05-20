# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  systemc,
  gcc12Stdenv,
  fetchFromGitHub,
  verilator,
}:
(verilator.override {
  # Long symbols are broken when compiled with GCC 13: https://github.com/verilator/verilator/issues/4204
  stdenv = gcc12Stdenv;
  systemc = (systemc.override {stdenv = gcc12Stdenv;}).overrideAttrs rec {
    version = "2.3.4";

    src = fetchFromGitHub {
      owner = "accellera-official";
      repo = "systemc";
      rev = version;
      sha256 = "0sj8wlkp68cjhmkd9c9lvm3lk3sckczpz7w9vby64inc1f9fnf0b";
    };
  };
})
.overrideAttrs (prev: rec {
  version = "5.012";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v${version}";
    sha256 = "sha256-Y6GkIgkauayJmGhOQg2kWjbcxYVIob6InMopv555Lb8=";
  };
  # New verilator uses driver.py now, this old version still uses driver.pl.
  postPatch =
    prev.postPatch
    + ''
      patchShebangs test_regress/driver.pl
    '';
  meta = {
    broken = gcc12Stdenv.isDarwin;
  };
})

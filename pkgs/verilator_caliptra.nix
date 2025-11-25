# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  systemc,
  fetchFromGitHub,
  verilator,
  inputs,
  stdenv,
}: let
  # Use legacy Nixpkgs for
  # * GCC 12: needed to build verilator and is not supported anymore in nixpkgs 25.11.
  # * CMake 3: nixpkgs has CMake 4 which removes support for CMake <3.5. 25.05 uses 3.31 which maintains the support.
  old-pkgs = import inputs.nixpkgs-2505 {inherit (stdenv) system;};
  inherit (old-pkgs) cmake gcc12Stdenv;
in
  (verilator.override {
    # Long symbols are broken when compiled with GCC 13: https://github.com/verilator/verilator/issues/4204
    stdenv = gcc12Stdenv;
    systemc =
      (systemc.override {
        stdenv = gcc12Stdenv;
        inherit cmake;
      }).overrideAttrs rec {
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
    # Drop patches that are specific to new version.
    patches = [];
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

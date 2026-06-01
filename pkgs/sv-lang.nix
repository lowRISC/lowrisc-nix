# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{pkgs}: let
  # slang 7.0's tools fail to compile under GCC 15's stricter template-body
  # checking, so build with GCC 14 as it did before the NixOS 26.05 bump.
  sv-lang = pkgs.sv-lang.override {
    stdenv = pkgs.gcc14Stdenv;
  };
in
  sv-lang.overrideAttrs (prev: rec {
    version = "7.0";
    src = pkgs.fetchFromGitHub {
      owner = "MikePopoloski";
      repo = "slang";
      rev = "v${version}";
      sha256 = "sha256-msSc6jw2xbEZfOwtqwFEDIKcwf5SDKp+j15lVbNO98g=";
    };

    # Upstream has a patch for mimalloc, which we aren't using.
    postPatch = "";

    # Detrimental when using sv-lang as library.
    cmakeFlags =
      prev.cmakeFlags
      ++ [
        "-DSLANG_USE_MIMALLOC=OFF"
      ];

    # Needed by dependent project.
    propagatedBuildInputs =
      (prev.propagatedBuildInputs or [])
      ++ [
        pkgs.fmt
      ];

    # Time out specific to sv-lang 7, see https://github.com/nixos/nixpkgs/issues/451986.
    doCheck = false;
  })

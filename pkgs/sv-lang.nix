# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{pkgs}:
pkgs.sv-lang.overrideAttrs (prev: rec {
  version = "7.0";
  src = pkgs.fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "slang";
    rev = "v${version}";
    sha256 = "sha256-msSc6jw2xbEZfOwtqwFEDIKcwf5SDKp+j15lVbNO98g=";
  };

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
      pkgs.fmt_11
    ];
})

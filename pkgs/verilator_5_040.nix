# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  verilator,
}:
verilator.overrideAttrs (old: rec {
  version = "5.040";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v${version}";
    sha256 = "sha256-S+cDnKOTPjLw+sNmWL3+Ay6+UM8poMadkyPSGd3hgnc=";
  };
  # On Darwin uintptr_t is `unsigned long`, which matches none of V3Hash's
  # integer constructors exactly, making the void* constructor ambiguous.
  # Upstream fixed this in v5.042 by casting through uint64_t.
  postPatch =
    (old.postPatch or "")
    + ''
      substituteInPlace src/V3Hash.h \
        --replace-fail 'V3Hash{reinterpret_cast<uintptr_t>(val)}' \
                       'V3Hash{static_cast<uint64_t>(reinterpret_cast<uintptr_t>(val))}'
    '';
})

# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  verilator,
}:
verilator.overrideAttrs (old: {
  version = "5.054";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "v5.054";
    sha256 = "sha256-YCCcFA7Mq7SjK6yHldT0rpS1FwXc5C8mgzcJD/imbEw=";
  };
  # nixpkgs' postPatch rewrites "/bin/echo" in bin/verilator, but upstream
  # Verilatorswitched that check to /bin/sh, so the substitution no longer
  # matches. Downgrade it to a warning.
  postPatch = builtins.replaceStrings ["--replace-fail"] ["--replace-warn"] old.postPatch;
})

# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  fetchFromGitHub,
  verilator,
}:
# A snapshot of Verilator master after v5.052, for UVM testbench fixes that are
# not in a release yet. Replace it with a release package once one has them.
verilator.overrideAttrs (old: {
  version = "5.052-unstable-2026-10-03";
  src = fetchFromGitHub {
    owner = "verilator";
    repo = "verilator";
    rev = "9f72509635ee19da76bc72cd723f0e5f21ea50e6";
    sha256 = "sha256-3F3juY+1o5AYFoljFBBNWS1sbZ1xAJBujdAvR2WrJsk=";
  };
  # nixpkgs rewrites a /bin/echo that `verilator --gdbbt` used to call. The
  # call is gone upstream, so its --replace-fail would fail the build.
  postPatch = builtins.replaceStrings ["--replace-fail"] ["--replace-quiet"] old.postPatch;
})

# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{pkgs}:
pkgs.xmake.overrideAttrs (prev: {
  # Remove the cjson lua package from the dependancies.
  buildInputs = builtins.filter (input: input != pkgs.lua.pkgs.cjson) prev.buildInputs;
  # Reset the configure flags so they don't contain `external=y`.
  configureFlags = [];
  enableParallelBuilding = true;
})

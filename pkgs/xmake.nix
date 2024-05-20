# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{pkgs}:
pkgs.xmake.overrideAttrs (prev: {
  # Reset the configure flags so they don't contain `external=y`.
  # This will cause vendored packages to be used instead of external (Nix-built packages).
  # We need this because lua-cjson is different from xmake's vendored cjson when it comes to hex literals.
  configureFlags = [];
  # Remove vendored packages from the dependencies.
  buildInputs = builtins.filter (input: !(builtins.elem input.pname ["lua-cjson" "tbox" "xmake-core-sv"])) prev.buildInputs;
  enableParallelBuilding = true;
})

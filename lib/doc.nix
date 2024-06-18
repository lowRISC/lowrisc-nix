# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{pkgs}: let
  fs = pkgs.lib.fileset;
  # Returns true if a file has an extension in the array `exts`.
  hasExts = exts: file: builtins.any file.hasExt exts;
in {
  inherit hasExts;

  standardMdbookFileset = root:
    fs.unions [
      (root + /book.toml)
      (fs.fileFilter (hasExts ["md" "svg" "png" "jpeg" "jpg" "webp" "avif"]) root)
    ];

  # A helper function to create mdBook site builds.
  buildMdbookSite = {
    pname,
    version,
    src,
    ...
  } @ inputs:
    pkgs.stdenv.mkDerivation ({
        dontFixup = true;
        buildPhase = "${pkgs.mdbook}/bin/mdbook build";
        installPhase = ''
          mkdir $out
          cp -r book/* $out
        '';
      }
      // inputs);
}

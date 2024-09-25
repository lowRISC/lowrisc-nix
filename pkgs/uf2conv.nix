# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  python3Packages,
  fetchFromGitHub,
  stdenv,
  lib,
}: let
  app = python3Packages.buildPythonApplication rec {
    name = "uf2conv";
    version = "0.0.1";
    src = fetchFromGitHub {
      owner = "makerdiary";
      repo = "uf2utils";
      rev = "61d9f3ff4913461b9813e666cce62b022652144a";
      hash = "sha256-3mXOvzkHmTV0k8qoy2k5TGBFX2l9EgPuaZPLyTdBHzQ=";
    };
    meta = {
      description = "uf2conv is an open source Python based tool for packing and unpacking UF2 files.";
      homepage = "https://github.com/makerdiary/uf2utils";
      license = lib.licenses.mit;
    };
  };
in
  # `buildPythonApplication` sets `propagatedBuildInputs` which in turn pulls Python into path
  # when used in `mkShell`. Launder it through custom derivation to remove it.
  stdenv.mkDerivation {
    inherit (app) name version meta;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${app}/bin/uf2conv $out/bin
    '';
  }

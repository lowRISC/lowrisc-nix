# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  inputs,
  pkgs,
  python3,
  ...
}: let
  poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
  poetryOverrides = inputs.self.poetryOverrides {inherit pkgs;};
in
  poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    overrides = [
      poetryOverrides
      poetry2nix.defaultPoetryOverrides
    ];
  }

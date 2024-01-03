# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    no_system_outputs = {
      lib.poetryOverrides = import ./poetryOverrides.nix {inherit nixpkgs;};
    };

    all_system_outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = import ./pkgs {inherit pkgs inputs;};
      formatter = pkgs.alejandra;
    });
  in
    # Recursive-merge attrsets to compose the final flake outputs attrset.
    builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate {} [
      no_system_outputs
      all_system_outputs
    ];
}

# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  description = "lowRISC CIC's Nix Packages and Environments";

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
      lib.poetryOverrides = import ./lib/poetryOverrides.nix;
    };

    all_system_outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      lowrisc_pkgs = import ./pkgs {inherit pkgs inputs;};
    in {
      packages = lowrisc_pkgs;
      devShells = {
        opentitan = pkgs.callPackage ./dev/opentitan.nix {
          inherit (lowrisc_pkgs) ncurses5-fhs bazel_ot verilator_ot python_ot;
        };
      };
      formatter = pkgs.alejandra;
    });
  in
    # Recursive-merge attrsets to compose the final flake outputs attrset.
    builtins.foldl' nixpkgs.lib.attrsets.recursiveUpdate {} [
      no_system_outputs
      all_system_outputs
    ];
}

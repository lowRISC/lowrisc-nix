# Copyright lowRISC Contributors.
# Licensed under both the MIT License and the Apache License, Version 2.
# See LICENSE-MIT and LICENSE-APACHE for details.
# SPDX-License-Identifier: MIT OR Apache-2.0
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
    all_system_outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = import ./pkgs {inherit pkgs inputs;};
      formatter = pkgs.alejandra;
    });
  in
    all_system_outputs;
}

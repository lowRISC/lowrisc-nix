# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  description = "lowRISC CIC's Nix Packages and Environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";

    # We also have some additional dependencies in private/flake.nix.
    # They're not exposed to the user to save downstream user from having a
    # bloating flake.lock and having to override them.
  };

  nixConfig = {
    extra-substituters = ["https://nix-cache.lowrisc.org/public/"];
    extra-trusted-public-keys = ["nix-cache.lowrisc.org-public-1:O6JLD0yXzaJDPiQW1meVu32JIDViuaPtGDfjlOopU7o="];
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ publicInputs: let
    evalFlake = import ./lib/evalFlake.nix;

    isNixOS = builtins.pathExists "/etc/NIXOS";

    inputs =
      (evalFlake {
        src = ./private;
        inputOverride = {
          inherit nixpkgs;
        };
      }).inputs
      // publicInputs;

    no_system_outputs = {
      lib = {
        poetryOverrides = import ./lib/poetryOverrides.nix;
        pyprojectOverrides = import ./lib/pyprojectOverrides.nix;
        doc = import ./lib/doc.nix;
        buildFHSEnvOverlay = import ./lib/buildFHSEnvOverlay.nix;
        inherit evalFlake;
      };
    };

    all_system_outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            buildFHSEnvOverlay =
              if isNixOS
              then final.buildFHSEnv
              else final.callPackage no_system_outputs.lib.buildFHSEnvOverlay {};
          })
        ];
      };
      lowrisc_pkgs = import ./pkgs {inherit pkgs inputs;};
    in {
      checks = {
        license = pkgs.stdenv.mkDerivation {
          name = "license-check";
          src = ./.;
          dontBuild = true;
          doCheck = true;
          nativeBuildInputs = with pkgs; [reuse];
          checkPhase = ''
            reuse lint
          '';
          installPhase = ''
            mkdir $out
          '';
        };
      };
      packages = flake-utils.lib.filterPackages system lowrisc_pkgs;
      devShells = {
        opentitan = let
          branches = ["main" "earlgrey_1.0.0"];
          genDevShell = branch:
            pkgs.callPackage ./dev/opentitan.nix {
              inherit (lowrisc_pkgs) ncurses5-fhs ncurses6-fhs bazel_ot verilator_ot verible_ot lowrisc-toolchain-gcc-rv32imcb;
              python_ot = lowrisc_pkgs.python_ot.${branch};
            };
          devShells = pkgs.lib.genAttrs branches (
            branch:
              genDevShell branch
          );
        in
          devShells."main"
          // devShells;
        cheriot = pkgs.mkShell {
          name = "cheriot";
          packages =
            (with lowrisc_pkgs; [llvm_cheriot])
            ++ (with pkgs; [
              xmake
              gnumake
              magic-enum
              srecord
            ]);
        };
        caliptra = pkgs.callPackage ./dev/caliptra.nix {
          inherit (lowrisc_pkgs) verilator_caliptra riscv64-gcc_caliptra;
        };
        qemu = pkgs.mkShell {
          name = "qemu";
          buildInputs = with pkgs; [
            pkg-config
            ninja
            meson
            python3
            glib
            pixman
            zlib
            libffi
          ];
        };
        llvm_cheri = pkgs.mkShell {
          name = "llvm_cheri";
          packages = with lowrisc_pkgs; [llvm_cheri];
        };
      };
      formatter = pkgs.alejandra;
    });
  in
    no_system_outputs // all_system_outputs;
}

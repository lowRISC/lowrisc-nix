# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  inputs,
  pkgs,
  python310,
  lib,
  ...
}: let
  pythonSets = {
    "main" = python310;
    "earlgrey_1.0.0" = python310;
  };

  mkEnv = workspaceRoot: python: let
    workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
      workspaceRoot = ./. + "/${workspaceRoot}";
    };
    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = "sdist";
    };

    pythonSet =
      (pkgs.callPackage inputs.pyproject-nix.build.packages {
        inherit python;
      })
          .overrideScope
      (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          overlay
          (inputs.self.lib.pyprojectOverrides {inherit pkgs;})
        ]
      );

    env = pythonSet.mkVirtualEnv "opentitan-env" workspace.deps.default;
  in
    env;
in let
  sets = lib.genAttrs (builtins.attrNames pythonSets) (
    set: let
      env = mkEnv set (pythonSets.${set});
    in
      env
      // {
        meta =
          env.meta
          // {
            platforms = lib.platforms.linux;
          };
      }
  );
in
  sets."main"
  // sets

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
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "sdist";
  };

  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages {
      python = python310;
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
  env
  // {
    meta =
      env.meta
      // {
        platforms = lib.platforms.linux;
      };
  }

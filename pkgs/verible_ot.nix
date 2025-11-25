# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  lib,
  fetchFromGitHub,
  verible,
  bazel_7,
  stdenv,
}:
verible.override (prev: {
  buildBazelPackage = args:
    prev.buildBazelPackage (args
      // rec {
        GIT_DATE = "2024-03-13";
        GIT_VERSION = "v0.0-3622-g07b310a3";

        version = builtins.concatStringsSep "." (lib.take 3 (lib.drop 1 (builtins.splitVersion GIT_VERSION)));

        src = fetchFromGitHub {
          owner = "chipsalliance";
          repo = "verible";
          rev = GIT_VERSION;
          sha256 = "sha256-pfFb2tuT7F7SpGMXElsVAHxO6xGQrVC15EyYxPSKaK8=";
        };

        fetchAttrs = {
          hash =
            {
              aarch64-linux = "sha256-igGOwq+RKHlvGsR01JlQlasccbeOe3MIMnpGKQHjwk0=";
              x86_64-linux = "sha256-JaAb80YGRqB2sgZiwmqWvCNETachdxV34cwFUuV/2gg=";
              aarch64-darwin = "sha256-FoTsIEF+HAFRrUmiuiPjxZnm9hirq25qgmP5JhSXiEA=";
            }
      .${
              stdenv.system
            } or (throw "No hash for system: ${stdenv.system}");
        };

        patches = [];

        bazel = pkgs.bazel_7;

        # Disable tests (takes ~30m to run locally on a laptop)
        bazelTestTargets = [];

        meta =
          args.meta
          // {
            broken = stdenv.isDarwin;
          };
      });
})

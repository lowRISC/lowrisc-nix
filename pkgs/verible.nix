# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  lib,
  fetchFromGitHub,
  verible,
  bazel_6,
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
          sha256 = "sha256-bKASgc5KftCWtMvJkGA4nweBAtgdnyC9uXIJxPjKYS0=";
        };

        patches = [];

        bazel = bazel_6;
      });
})

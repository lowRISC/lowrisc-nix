# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  verible,
  bazel_7,
  stdenv,
}:
verible.override (prev: {
  buildBazelPackage = args: let
    GIT_DATE = "2026-06-16";
    GIT_VERSION = "v0.0-4080-ga0a8d8eb";

    # v0.0-4023's MODULE.bazel pins bazel_dep versions (nlohmann_json
    # 3.12.0.bcr.1, abseil-cpp 20250814.1, protobuf 31.0-rc2, ...) that are
    # newer than the bazel-central-registry snapshot nixpkgs vendors for
    # verible-0.0.4023, so it needs a newer registry checkout.
    registry = fetchFromGitHub {
      owner = "bazelbuild";
      repo = "bazel-central-registry";
      rev = "5623a9df147c644a3d46b6f715c923d2b0d174ff";
      hash = "sha256-C0+9TLmGMn2I6mrTM6tFLJkU3DENVel/37SNU1cTA54=";
    };
  in
    prev.buildBazelPackage (args
      // {
        env =
          (args.env or {})
          // {
            inherit GIT_DATE GIT_VERSION;
          };

        version = builtins.concatStringsSep "." (lib.take 3 (lib.drop 1 (builtins.splitVersion GIT_VERSION)));

        src = fetchFromGitHub {
          owner = "chipsalliance";
          repo = "verible";
          rev = GIT_VERSION;
          sha256 = "sha256-QvEmqrVgCTVQVPPaLWIdVAoc4EliFi9ObQlURhXqDlk=";
        };

        bazelFlags = [
          "--//bazel:use_local_flex_bison"
          "--registry"
          "file://${registry}"
        ];

        fetchAttrs =
          (args.fetchAttrs or {})
          // {
            # TODO: aarch64-linux/aarch64-darwin hashes are unfilled; only
            # x86_64-linux has been built and verified so far.
            hash =
              {
                aarch64-linux = "sha256-0000000000000000000000000000000000000000000=";
                x86_64-linux = "sha256-Rc6Iu8W1uJTlE8TzofJy7ZIJFtzdAQeU30KNeKtlWZI=";
                aarch64-darwin = "sha256-0000000000000000000000000000000000000000000=";
              }
        .${
                stdenv.system
              } or (throw "No hash for system: ${stdenv.system}");
          };

        patches = [];

        bazel = bazel_7;

        # Disable tests (takes ~30m to run locally on a laptop)
        bazelTestTargets = [];

        meta =
          args.meta
          // {
            broken = stdenv.system != "x86_64-linux";
          };
      });
})

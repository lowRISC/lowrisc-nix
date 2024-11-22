# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  stdenv,
  go_1_23,
  gcsfuse,
  fetchFromGitHub,
}:
gcsfuse.override (prev: {
  buildGoModule = args:
    (prev.buildGoModule.override {go = go_1_23;}) (args
      // rec {
        # This is the upstream version, but we pin it.
        version = "2.5.1";

        src = fetchFromGitHub {
          owner = "googlecloudplatform";
          repo = "gcsfuse";
          rev = "v${version}";
          hash = "sha256-4UzRg6fNKBrTSoimJ9jURW9oPRhUOAUDMG3JaM7f100=";
        };

        vendorHash = "sha256-QrpILFzgUQwmrvjCdtrlgq1zSW7f82qMHsifI39WaB0=";

        patches = [
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2269
          ./dentry-cache.patch
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2285
          ./symlink-cache.patch
        ];

        meta =
          args.meta
          // {
            mainProgram = "gcsfuse";
            broken = stdenv.hostPlatform.isDarwin;
          };
      });
})

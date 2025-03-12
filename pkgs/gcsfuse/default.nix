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
        version = "2.10.0";

        src = fetchFromGitHub {
          owner = "googlecloudplatform";
          repo = "gcsfuse";
          rev = "v${version}";
          hash = "sha256-gKKsUihV/YiIYbdTPjOXl/SEmi7dTAncNEAnAS/42VY=";
        };

        vendorHash = "sha256-/9LhIZ/KThuTI1OYfdZHfV9Ad70gw4Yii3MsE5ZVLSI=";

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

# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  gcsfuse,
  fetchFromGitHub,
}:
gcsfuse.override (prev: {
  buildGoModule = args:
    prev.buildGoModule (args
      // rec {
        version = "2.4.0";

        src = fetchFromGitHub {
          owner = "googlecloudplatform";
          repo = "gcsfuse";
          rev = "v${version}";
          hash = "sha256-4susiXFe1aBcakxRkhmOe7dvcwsNfam4KKyFFzYXhcU=";
        };

        vendorHash = "sha256-uOr929RS8q7LB+WDiyxEIyScE/brmvPJKfnq28PfsDM=";

        patches = [
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2269
          ./dentry-cache.patch
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2285
          ./symlink-cache.patch
        ];
      });
})

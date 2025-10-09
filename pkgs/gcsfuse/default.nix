# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  stdenv,
  go_1_24,
  gcsfuse,
  fetchFromGitHub,
}:
gcsfuse.override (prev: {
  buildGoModule = args:
    (prev.buildGoModule.override {go = go_1_24;}) (args
      // rec {
        version = "3.4.0";

        src = fetchFromGitHub {
          owner = "googlecloudplatform";
          repo = "gcsfuse";
          rev = "v${version}";
          hash = "sha256-PdYHsHIlq77QnsjD1z3KliW3JHLZ0M26I4Z7v0SuvlU=";
        };

        vendorHash = "sha256-w5EOHPOJLfINILrP3ipZwYUAcAJIlGw1HlVAUAzW3x4=";

        patches = [
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2269
          ./dentry-cache.patch
          # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2285
          ./symlink-cache.patch
          ./turn-knob.patch
        ];

        meta =
          args.meta
          // {
            mainProgram = "gcsfuse";
            broken = stdenv.hostPlatform.isDarwin;
          };
      });
})

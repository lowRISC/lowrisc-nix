# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  nebula,
  fetchFromGitHub,
}:
nebula.override (prev: {
  buildGoModule = args:
    prev.buildGoModule (args
      // rec {
        # Picks a version that supports v2 certificates.
        # Update to a stable version as soon as it's released.
        version = "1.10.0-dev";

        src = fetchFromGitHub {
          owner = "slackhq";
          repo = "nebula";
          rev = "7da79685fff9b34c30b3c6786ebf4b97b091daa1";
          hash = "sha256-jk9aVkQe4klqeWVMop/HLxqr0flgEKiOSTBndHRAIG0=";
        };

        vendorHash = "sha256-dtjxzRRQagkXFLQGwE//apon7kFuxYJXT9KLhJS7m5k=";

        ldflags = ["-X main.Build=${version}"];
      });
})

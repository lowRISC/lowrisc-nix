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
          rev = "8536c5764565fcb0381c37772811b92c001d1b89";
          hash = "sha256-o6/4R5qwLl00CWHlP/bdju/7k5PhlXyazB+cYIePVY0=";
        };

        vendorHash = "sha256-X4hnVilPFDaF6QUbjNZqvbk9Jmd+iTL2Ij7Tv5SXrbg=";

        ldflags = ["-X main.Build=${version}"];
      });
})

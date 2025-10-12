# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  surfer,
  fetchFromGitLab,
}:
surfer.override (prev: {
  rustPlatform =
    prev.rustPlatform
    // {
      buildRustPackage = args:
        prev.rustPlatform.buildRustPackage (args
          // {
            version = "0.4.0-dev";

            src = fetchFromGitLab {
              owner = "surfer-project";
              repo = "surfer";
              rev = "1d83e7c22dffa8801e3a37966bc70427e92dce4f";
              hash = "sha256-56fNyNm+6LL/aHaJU+QSUjcdimc4tfUXSlqxRwfFoGc=";
              fetchSubmodules = true;
            };

            cargoHash = "sha256-mx1UuyAohB2knrh57XfiVRdDGGX6ndkKJg0IPCWPJ8o=";
          });
    };
})

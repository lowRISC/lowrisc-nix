# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "parallel-cp";
  version = "0.0.0-unstable-20250704";

  src = fetchFromGitHub {
    owner = "lowRISC";
    repo = "parallel-cp";
    rev = "bb75686feb8aeb2fe17d0a1435dbf931e9adff9c";
    hash = "sha256-7+CrkxbX59Hj52x0VDtEQ/ogDAQ0+byOecdaRajX1Cw=";
  };

  cargoHash = "sha256-K9NSf20r1JEJDJ69J3chCz5Vp+X9KMKTznXU3sWNiAw=";

  meta = {
    description = "A tiny parallel file copy utility";
    homepage = "https://github.com/lowRISC/parallel-cp";
    license = [lib.licenses.mit lib.licenses.asl20];
    mainProgram = "parallel-cp";
  };
}

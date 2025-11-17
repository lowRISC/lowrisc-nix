# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchzip,
  stdenv,
  zlib,
  zstd,
  ncurses6,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  name = "cheri-llvm";
  version = "17.0.1.r01";
  src = fetchzip {
    # We build the toolchain in another repository because derivations doesn't allow internet
    # connection, which is required by cheribuild.
    url = "https://github.com/engdoreis/cheribuild/releases/download/v${version}/cheri-std093-sdk.tar.gz";
    hash = "sha256-/6FGm1Ot9sFZ71FIThtLV2KFjhSfnc5w32OucCZmDfc=";
  };

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [
    stdenv.cc.cc.lib
    ncurses6
    zlib
    zstd
  ];
  nativeBuildInputs = [autoPatchelfHook];

  installPhase = ''
    mkdir -p $out
    cp -R ./cheri-std093-sdk/* $out
  '';

  meta = {
    platforms = ["x86_64-linux"];
  };
}

# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchzip,
  stdenv,
  lib,
  ncurses5,
}:
stdenv.mkDerivation rec {
  name = "lowrisc-toolchain-gcc-rv32imcb";
  version = "20230427-1";
  src = fetchzip {
    url = "https://github.com/lowRISC/lowrisc-toolchains/releases/download/${version}/lowrisc-toolchain-gcc-rv32imcb-${version}.tar.xz";
    sha256 = "sha256-DwecY4WUqenpRHUIjWdybhOVJwzT173HO7S02KQcpb4=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true; # We will do this manually in preFixup
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
  preFixup = ''
    find $out -type f ! -name ".o" | while read f; do
      patchelf "$f" > /dev/null 2>&1                                                  || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f"  || true
      patchelf --set-rpath ${lib.makeLibraryPath ["$out" stdenv.cc.cc ncurses5]} "$f" || true
    done
  '';
}

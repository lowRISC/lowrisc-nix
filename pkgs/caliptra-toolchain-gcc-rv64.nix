# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  stdenv,
  lib,
  ncurses5,
}:
stdenv.mkDerivation {
  name = "caliptra-toolchain-gcc-rv64";
  version = "2023.04.29";
  src = builtins.fetchTarball {
    url = "https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.04.29/riscv32-elf-ubuntu-22.04-nightly-2023.04.29-nightly.tar.gz";
    sha256 = "08l0rg3aawl634hfjvxxf9ry4y6dr1r3lyimd6fzzszdm6y21k8k";
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

  meta = {
    platforms = ["x86_64-linux"];
  };
}

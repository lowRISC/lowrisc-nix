# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  stdenv,
  fetchFromGitHub,
  pkgs,
}:
stdenv.mkDerivation rec {
  name = "riscv64-gcc_caliptra";
  version = "2023.04.29";

  src = fetchFromGitHub {
    owner = "riscv-collab";
    repo = "riscv-gnu-toolchain";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-S88sYWFtoypKvnSGQD71VRbANdjZT0wIv6NBGzZHv1s=";
  };

  patches = [
    # Remove the need for a network fetcher and using Git to fetch submodules.
    # There's no network access in the build sandbox.
    ./remove-fetcher.patch
  ];
  postPatch = "patchShebangs .";

  preConfigure = ''
    configureFlagsArray+=(--enable-multilib --with-multilib-generator="rv32imc-ilp32--a*zicsr*zifencei")
  '';

  enableParallelBuilding = true;

  # GCC 15 defaults to -std=gnu23, where empty-parens declarations like
  # `extern int tputs ();` become zero-argument prototypes. The bundled GDB's
  # readline still calls these with arguments, so force the pre-C23 dialect for
  # host C compilation. Only affects C; the gcc C++ sources use CXXFLAGS.
  CFLAGS = "-O2 -g -std=gnu17";

  hardeningDisable = ["format"];
  buildInputs = with pkgs; [
    gmp
    mpfr
    libmpc
    expat
    zlib
  ];
  nativeBuildInputs = with pkgs; [
    python3
    flex
    bison
    texinfo
    which
  ];

  meta = {
    description = "RISC-V multilib toolchain for Caliptra development";
    platforms = ["x86_64-linux"];
  };
}

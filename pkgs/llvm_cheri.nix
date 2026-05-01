# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  python3,
  zlib,
  lld,
  stdenv,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "llvm-cheri";
  version = "19.0.0";

  src = fetchFromGitHub {
    owner = "qwattash";
    repo = "cheri-alliance-llvm-project";
    rev = "7dc859cb98e10b0e8dec4fed62185cc543ff31cd";
    fetchSubmodules = true;
    hash = "sha256-91GI7YtigLEund7zjbSktbroFhla713CBHH10Bh6/a8=";
  };

  sourceRoot = "${src.name}/llvm";

  nativeBuildInputs = [
    cmake
    ninja
    lld
    python3
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
  ];

  preBuild = ''
    export LD_LIBRARY_PATH=${lib.makeLibraryPath [zlib stdenv.cc.cc.lib]}:$LD_LIBRARY_PATH
  '';

  cmakeFlags = [
    "-DLLVM_ENABLE_PROJECTS=llvm;clang;lld;clang-tools-extra"
    "-DLLVM_TARGETS_TO_BUILD=RISCV;host"

    "-DLLVM_ENABLE_ZLIB=FORCE_ON"
    "-DLLVM_ENABLE_LIBXML2=FALSE"
    "-DLLVM_ENABLE_OCAMLDOC=FALSE"
    "-DLLVM_ENABLE_BINDINGS=FALSE"
    "-DLLVM_INCLUDE_EXAMPLES=FALSE"
    "-DLLVM_INCLUDE_DOCS=FALSE"
    "-DLLVM_INCLUDE_BENCHMARKS=FALSE"
    "-DLLVM_INSTALL_UTILS=TRUE"
    "-DLLVM_INSTALL_BINUTILS_SYMLINKS=TRUE"
    "-DCLANG_ENABLE_STATIC_ANALYZER=FALSE"
    "-DCLANG_ENABLE_ARCMT=FALSE"
    "-DLLVM_ENABLE_Z3_SOLVER=FALSE"
    "-DLLVM_TOOL_LLVM_MCA_BUILD=FALSE"
    "-DLLVM_TOOL_LLVM_EXEGESIS_BUILD=FALSE"
    "-DLLVM_TOOL_LLVM_RC_BUILD=FALSE"
    "-DLLVM_ENABLE_LLD=TRUE"
    "-DLLVM_OPTIMIZED_TABLEGEN=FALSE"
    "-DLLVM_USE_SPLIT_DWARF=TRUE"
    "-DLLVM_ENABLE_ASSERTIONS=TRUE"
    "-DCLANG_ROUND_TRIP_CC1_ARGS=FALSE"
    "-DLLVM_PARALLEL_LINK_JOBS=4"
  ];
}

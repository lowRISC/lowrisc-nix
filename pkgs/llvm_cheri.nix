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
  version = "19.1.7";
  src = fetchFromGitHub {
    owner = "CHERI-Alliance";
    repo = "llvm-project";
    rev = "88b862c4d6df60fb7d70a3c509fdfc91bd0a105d";
    fetchSubmodules = true;
    hash = "sha256-3j3ItOdHslmzwPrCYDqZgBQeevU5sylWjvCjTzgUzfQ=";
  };

  sourceRoot = "${src.name}/llvm";

  nativeBuildInputs =
    [
      cmake
      ninja
      lld
      python3
    ]
    ++ lib.optionals (!stdenv.isDarwin) [autoPatchelfHook];

  buildInputs = [
    zlib
  ];

  preBuild = ''
    export LD_LIBRARY_PATH=${lib.makeLibraryPath [zlib stdenv.cc.cc.lib]}:$LD_LIBRARY_PATH
  '';

  cmakeFlags = with lib; [
    (cmakeFeature "LLVM_ENABLE_PROJECTS" "llvm;clang;lld;clang-tools-extra")
    (cmakeFeature "LLVM_TARGETS_TO_BUILD" "RISCV;host")

    (cmakeFeature "LLVM_ENABLE_ZLIB" "FORCE_ON")
    (cmakeBool "LLVM_ENABLE_LIBXML2" false)
    (cmakeBool "LLVM_ENABLE_OCAMLDOC" false)
    (cmakeBool "LLVM_ENABLE_BINDINGS" false)
    (cmakeBool "LLVM_INCLUDE_EXAMPLES" false)
    (cmakeBool "LLVM_INCLUDE_DOCS" false)
    (cmakeBool "LLVM_INCLUDE_BENCHMARKS" false)
    (cmakeBool "LLVM_INSTALL_UTILS" true)
    (cmakeBool "LLVM_INSTALL_BINUTILS_SYMLINKS" true)
    (cmakeBool "CLANG_ENABLE_STATIC_ANALYZER" false)
    (cmakeBool "CLANG_ENABLE_ARCMT" false)
    (cmakeBool "LLVM_ENABLE_Z3_SOLVER" false)
    (cmakeBool "LLVM_TOOL_LLVM_MCA_BUILD" false)
    (cmakeBool "LLVM_TOOL_LLVM_EXEGESIS_BUILD" false)
    (cmakeBool "LLVM_TOOL_LLVM_RC_BUILD" false)
    (cmakeBool "LLVM_ENABLE_LLD" true)
    (cmakeBool "LLVM_OPTIMIZED_TABLEGEN" false)
    (cmakeBool "LLVM_USE_SPLIT_DWARF" true)
    (cmakeBool "LLVM_ENABLE_ASSERTIONS" true)
    (cmakeBool "CLANG_ROUND_TRIP_CC1_ARGS" false)

    (cmakeFeature "LLVM_PARALLEL_LINK_JOBS" "4")
  ];

  meta = {
    description = "The clang/LLVM compiler with CHERI support.";
    broken = stdenv.hostPlatform.isDarwin;
  };
}

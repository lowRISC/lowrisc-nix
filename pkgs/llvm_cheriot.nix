# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  ninja,
  lld,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "llvm-cheriot";
  version = "13.0.0";
  src = fetchFromGitHub {
    owner = "CHERIoT-Platform";
    repo = "llvm-project";
    rev = "dfbd2b1fdd33746ca9e615feb7852013e8f3966a";
    hash = "sha256-L0ska5LVv5bUQuA4B8JW5xL156xyJw+2asDR8VA31Fw=";
  };
  sourceRoot = "${src.name}/llvm";
  nativeBuildInputs = [cmake ninja lld python3];
  cmakeFlags = with lib; [
    (cmakeFeature "LLVM_TARGETS_TO_BUILD" "RISCV")
    (cmakeFeature "LLVM_ENABLE_PROJECTS" "clang;clang-tools-extra;lld")
    (cmakeFeature "LLVM_DISTRIBUTION_COMPONENTS" "clang;clangd;lld;llvm-objdump")
    (cmakeBool "LLVM_ENABLE_ASSERTIONS" true)
    (cmakeBool "LLVM_LINK_LLVM_DYLIB" true)
    (cmakeBool "LLVM_ENABLE_UNWIND_TABLES" false)
  ];
  meta = {
    description = "The clang/LLVM compiler with CHERIoT support.";
    homepage = "https://github.com/CHERIoT-Platform/llvm-project";
    license = lib.licenses.asl20-llvm;
  };
}

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
    rev = "08a91532cb502a4b575b77d8eb62b1d1862b0c4b";
    hash = "sha256-kEhX6WsHNV+yvM278hTkssGROw9i4KlbDgi5epw7Ns0=";
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

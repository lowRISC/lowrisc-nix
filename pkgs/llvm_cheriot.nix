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
  version = "20.0.0";
  src = fetchFromGitHub {
    owner = "CHERIoT-Platform";
    repo = "llvm-project";
    rev = "07e8964835826ac9c2dd86c310b4813a546881e3";
    hash = "sha256-0mM1jPTwt51EHVGATZvd0TUQ/kq1eE9V7LoqXaSiuUI=";
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
    license = lld.meta.license;
  };
}

# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
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
    rev = "432ef65c96c9f8be8b7802a8bfb9bcf3609b2b79";
    hash = "sha256-ddLnG1olyRYxvKJ0zKEbThq/ZnxP68X32+1ws76WeV4=";
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

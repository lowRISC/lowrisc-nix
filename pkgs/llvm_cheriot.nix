# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  name = "llvm-cheriot";
  src = pkgs.fetchFromGitHub {
    owner = "CHERIoT-Platform";
    repo = "llvm-project";
    rev = "432ef65c96c9f8be8b7802a8bfb9bcf3609b2b79";
    sha256 = "sha256-ddLnG1olyRYxvKJ0zKEbThq/ZnxP68X32+1ws76WeV4=";
  };
  sourceRoot = "${src.name}/llvm";
  nativeBuildInputs = with pkgs; [cmake ninja lld python3];
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLVM_ENABLE_ASSERTIONS=True"
    "-DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;lld'"
    "-DLLVM_ENABLE_UNWIND_TABLES=NO"
    "-DLLVM_TARGETS_TO_BUILD=RISCV"
    "-DLLVM_DISTRIBUTION_COMPONENTS='clang;clangd;lld;llvm-objdump'"
  ];
  meta = {
    description = "The clang/LLVM compiler with CHERIoT support.";
    homepage = "https://cheriot.org/";
    license = pkgs.lib.licenses.asl20-llvm;
  };
}

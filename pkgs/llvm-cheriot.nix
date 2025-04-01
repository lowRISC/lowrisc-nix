# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  stdenv,
  darwin,
  fetchFromGitHub,
  lib,
  cmake,
  ninja,
  lld,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "llvm-cheriot";
  version = "19.0.0";
  src = fetchFromGitHub {
    owner = "CHERIoT-Platform";
    repo = "llvm-project";
    rev = "d94219e399453f5e4f584809b6c898ce7b9fd5b0";
    hash = "sha256-9LQOHLRMtJimgMfv0ZMEDz7/2ruuisGxBbNgn/iC39Q=";
  };
  sourceRoot = "${src.name}/llvm";
  nativeBuildInputs = [cmake ninja lld python3] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.libs.xpc;
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

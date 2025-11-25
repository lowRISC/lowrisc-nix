# Copyright lowRISC contributors.
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  llvmPackages,
  verilator,
  verible,
  cmake,
  boost182,
  sv-lang_7,
}:
rustPlatform.buildRustPackage {
  pname = "veridian";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vivekmalneedi";
    repo = "veridian";
    rev = "d094c9d2fa9745b2c4430eef052478c64d5dd3b6";
    hash = "sha256-3KjUunXTqdesvgDSeQMoXL0LRGsGQXZJGDt+xLWGovM=";
  };

  # We don't want the `veridian-slang`'s to `build.rs`
  # to override the prefix path we've set up nicely here.
  patches = [./no-override-prefix-path.patch];

  # Verilator and Verible are used in the test suit
  nativeBuildInputs = [pkg-config cmake verilator verible];
  buildInputs = [openssl boost182 sv-lang_7];

  cargoLock.lockFile = ./Cargo.lock;
  buildFeatures = ["slang"];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  SLANG_INSTALL_PATH = "${sv-lang_7}";

  # The check doesn't build, so we don't bother checking.
  doCheck = false;

  meta = {
    description = "A SystemVerilog Language Server";
    homepage = "https://github.com/vivekmalneedi/veridian";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "veridian";
  };
}

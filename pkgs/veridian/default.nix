# Copyright lowRISC contributors.
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  libclang,
  verilator,
  verible,
  cmake,
  boost182,
  sv-lang_6,
}:
rustPlatform.buildRustPackage {
  pname = "veridian";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vivekmalneedi";
    repo = "veridian";
    rev = "e156ac3f97408c816883659035687aa704064415";
    hash = "sha256-brILumMj2OIEVksGM4JHNkITheL6h4o7amnZ1ZRyb+M=";
  };

  # We don't want the `veridian-slang`'s to `build.rs`
  # to override the prefix path we've set up nicely here.
  patches = [./no-override-prefix-path.patch];

  # Verilator and Verible are used in the test suit
  nativeBuildInputs = [pkg-config cmake verilator verible];
  buildInputs = [openssl libclang boost182 sv-lang_6];

  cargoLock.lockFile = ./Cargo.lock;
  buildFeatures = ["slang"];

  LIBCLANG_PATH = "${libclang.lib}/lib";
  SLANG_INSTALL_PATH = "${sv-lang_6}";

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

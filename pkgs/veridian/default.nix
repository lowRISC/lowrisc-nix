# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  fetchurl,
  rustPlatform,
  pkg-config,
  openssl,
  libclang,
  verilator,
  verible,
}: let
  slangRelease = fetchurl {
    url = "https://github.com/MikePopoloski/slang/releases/download/v0.7/slang-linux.tar.gz";
    hash = "sha256-Mrfh9Ngg4jqHCJ90W9a4hirVtMi4t2CoLRaDLdOMl7M=";
  };
in
  rustPlatform.buildRustPackage {
    pname = "veridian";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "vivekmalneedi";
      repo = "veridian";
      rev = "48db56d9ec2520ae4691aaa691b85adc93649e7a";
      hash = "sha256-bvJL9T0hcfVVSaJdlxwo35dQOQVqKPCk5RwMoRqiopU=";
    };

    patches = [./no-download.patch];
    postUnpack = "tar xf ${slangRelease} -C source/veridian-slang/slang_wrapper/";

    LIBCLANG_PATH = "${libclang.lib}/lib";

    buildFeatures = ["slang"];

    # Verilator and Verible used in the test suit
    nativeBuildInputs = [pkg-config verilator verible];
    buildInputs = [openssl libclang];

    cargoLock.lockFile = ./Cargo.lock;

    meta = {
      description = "A SystemVerilog Language Server";
      homepage = "https://github.com/vivekmalneedi/veridian";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "veridian";
    };
  }

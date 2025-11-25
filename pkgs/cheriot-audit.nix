# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  pkgs,
  stdenv,
  fetchFromGitHub,
  lib,
  cmake,
  git,
}: let
  # Source dependencies of cheriot-audit
  regocpp = fetchFromGitHub {
    owner = "microsoft";
    repo = "rego-cpp";
    rev = "v1.0.1";
    hash = "sha256-vD0k5oZEbkiUhcNrugFvltrQPvuRY/OEjrbPHHyiJYo=";
  };
  nlohmann_json = builtins.fetchTarball {
    url = "https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz";
    sha256 = "078fymbb5jzhg69bvwp1fr79rmcyy1nz7cjnwkisgkjpb24rywbj";
  };

  # Source dependencies of rego-cpp
  cmake_utils = fetchFromGitHub {
    owner = "mjp41";
    repo = "cmake_utils";
    rev = "2bf98b5773ea7282197c823e205547d8c2e323c0";
    hash = "sha256-BW7F30/6nOY4Q2dIlROfGdHp32s3QB5t7cS4QynR0G8=";
  };
  trieste = fetchFromGitHub {
    owner = "microsoft";
    repo = "trieste";
    rev = "7aa3079fbdb02229e473785f53414417916b26e3";
    hash = "sha256-AHtzBqtEvTyUvHdfKBsm5VHogJYYstqXrpAAntzawag=";
  };

  # Source dependencies of trieste
  snmalloc = fetchFromGitHub {
    owner = "microsoft";
    repo = "snmalloc";
    rev = "b8e28be14b3fd98e27c2fe87c0296570f6d3990e";
    hash = "sha256-m4B+zGNIsQUr+EueTDVloyycVpYe8rwLq1oa7843oxc=";
  };
  re2 = fetchFromGitHub {
    owner = "google";
    repo = "re2";
    rev = "2022-12-01";
    hash = "sha256-RmPXfavSKVnnl/RJ5aTjc/GbkPz+EXiFg1n5e4s6wjw=";
  };
  cli11 = fetchFromGitHub {
    owner = "CLIUtils";
    repo = "CLI11";
    rev = "4160d259d961cd393fd8d67590a8c7d210207348";
    hash = "sha256-73dfpZDnKl0cADM4LTP3/eDFhwCdiHbEaGRF7ZyWsdQ=";
  };
in
  stdenv.mkDerivation rec {
    pname = "cheriot-audit";
    version = "0-unstable-2025-11-04";

    src = fetchFromGitHub {
      owner = "CHERIoT-Platform";
      repo = "cheriot-audit";
      rev = "79d91acd2a57e57ab0b753f50c094a9217fc5ebd";
      hash = "sha256-cTO1MvAgSidvwmCPodnSRwy0ILfR3npnBIjLt+3z4QE=";
    };

    nativeBuildInputs = [cmake git];
    cmakeFlags = [
      "-DFETCHCONTENT_SOURCE_DIR_REGOCPP=${regocpp}"
      "-DFETCHCONTENT_SOURCE_DIR_NLOHMANN_JSON=${nlohmann_json}"
      "-DFETCHCONTENT_SOURCE_DIR_CMAKE_UTILS=${cmake_utils}"
      "-DFETCHCONTENT_SOURCE_DIR_TRIESTE=${trieste}"
      "-DFETCHCONTENT_SOURCE_DIR_SNMALLOC=${snmalloc}"
      "-DFETCHCONTENT_SOURCE_DIR_RE2=${re2}"
      "-DFETCHCONTENT_SOURCE_DIR_CLI11=${cli11}"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp cheriot-audit $out/bin
      runHook postInstall
    '';

    meta = {
      description = "Auditing tooling for CHEIRoT firmware images.";
      homepage = "https://github.com/CHERIoT-Platform/cheriot-audit";
      license = lib.licenses.mit;
      mainProgram = "cheriot-audit";
    };
  }

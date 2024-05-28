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
  darwin,
}: let
  # Source dependencies of cheriot-audit
  regocpp = fetchFromGitHub {
    owner = "microsoft";
    repo = "rego-cpp";
    rev = "cb967637dbf7cee25117203bbdf9c10b62dfb25a";
    hash = "sha256-0JLnk+qr991aKWjzTrG4JE0L5e2NrcOstT8+ggjzKr0=";
  };
  nlohmann_json = builtins.fetchTarball {
    url = "https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz";
    sha256 = "078fymbb5jzhg69bvwp1fr79rmcyy1nz7cjnwkisgkjpb24rywbj";
  };

  # Source dependencies of rego-cpp
  trieste = fetchFromGitHub {
    owner = "microsoft";
    repo = "trieste";
    rev = "58a6eeeaeda4f5c96dad30c23b2d4e3feae7a60c";
    hash = "sha256-uCyJiNRG6R/tyhewQR4hTrO+CnEVpZmFubZMMH6mAwg=";
  };

  # Source dependencies of trieste
  snmalloc = fetchFromGitHub {
    owner = "microsoft";
    repo = "snmalloc";
    rev = "846a926155976b07a16425352dd5fed0858c5c97";
    hash = "sha256-Dc8CKaYPPAYfY83Nsv+KqDJoihK8zXrRacVLugWzJY4=";
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
    rev = "b9be5b9444772324459989177108a6a65b8b2769";
    hash = "sha256-emTIaoUyTINbAAn9tw1r3zLTQt58N8A1zoP+0y41yKo=";
  };

  mkDerivation =
    if stdenv.isDarwin
    then darwin.apple_sdk_11_0.stdenv.mkDerivation
    else stdenv.mkDerivation;
in
  mkDerivation rec {
    pname = "cheriot-audit";
    version = "0.0.0";

    src = fetchFromGitHub {
      owner = "CHERIoT-Platform";
      repo = "cheriot-audit";
      rev = "6120dea317a18d0ef6bf7e63a75636b0ed91ede9";
      hash = "sha256-wk/kPvsixd0jw82GsOsg/Z/iDrcKNoMnPaCubJsUbRE=";
    };

    nativeBuildInputs = [cmake git];
    cmakeFlags = [
      "-DFETCHCONTENT_SOURCE_DIR_REGOCPP=${regocpp}"
      "-DFETCHCONTENT_SOURCE_DIR_NLOHMANN_JSON=${nlohmann_json}"
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

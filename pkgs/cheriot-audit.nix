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
    rev = "v0.4.6"; # Bumped from cheriot-audit's pinned 0.4.5 to remove a dependency.
    hash = "sha256-gS2HbSBMgCejA8m+TZ0/vDjBUE2cSxSujQDm+tzIbk8=";
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
    rev = "70a4d5f79cb574070ff69b2517b422c5126e2024";
    hash = "sha256-RMQyrzZw+k6IVw6Wl0qKDZjoms55HVNBlN811fxjv7w=";
  };

  # Source dependencies of trieste
  snmalloc = fetchFromGitHub {
    owner = "microsoft";
    repo = "snmalloc";
    rev = "0.7.1"; # Bumped from triesta's pinned hash to fix clang 19 build.
    hash = "sha256-zbOaHwby8NqfLtiZUybwqaw/03xMUTdsyIGUr9pZRlo=";
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

  # clang 19 build on darwin is failing due to cryptic "error: implicit instantiation of undefined template 'std::char_traits<unsigned char>'" error.
  # https://github.com/NixOS/nixpkgs/issues/339576#issuecomment-2574076670
  mkDerivation =
    if stdenv.isDarwin
    then pkgs.clang18Stdenv.mkDerivation
    else stdenv.mkDerivation;
in
  mkDerivation rec {
    pname = "cheriot-audit";
    version = "0.0.0";

    src = fetchFromGitHub {
      owner = "CHERIoT-Platform";
      repo = "cheriot-audit";
      rev = "743566f85fa716f408360b55582fd9bfdb61cef4";
      hash = "sha256-Hwl9isxtF2eX6wUcyWUBWgiw4/G/27AdtCPj9VGh43w=";
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

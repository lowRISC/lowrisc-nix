# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitLab,
  rustPlatform,
  pkg-config,
  openssl,
  wayland,
  libxkbcommon,
  libGL,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "surfer";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "surfer-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mvHyljAEVi1FMkEbKsPmCNx2Cg0/Ydw3ZQCZsowEKGc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl wayland libxkbcommon libGL] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.AppKit;

  # These libraries are dlopen'ed at runtime, but they won't be able to find anything in
  # NixOS's path. So force them to be linked.
  # This could alternatively be a wrapper which adds LD_LIBRARY_PATH.
  RUSTFLAGS = lib.optionals stdenv.isLinux (map (a: "-C link-arg=${a}") [
    "-Wl,--push-state,--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-lxkbcommon"
    "-Wl,--pop-state"
  ]);

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "codespan-0.12.0" = "sha256-3F2006BR3hyhxcUTaQiOjzTEuRECKJKjIDyXonS/lrE=";
      "egui_skia_renderer-0.2.0" = "sha256-1l8iluTHDYZGRkKWnurRMj4iHljogPWs26pzkUtIGwY=";
      "spade-0.10.0" = "sha256-nl9MsrV68mE7hVEBFF/WdasUXCJoUazCFg4xG+2MOEY=";
    };
  };

  doCheck = false;

  meta = {
    description = "An Extensible and Snappy Waveform Viewer";
    homepage = "http://surfer-project.org/";
    license = lib.licenses.eupl12;
    mainProgram = "surfer";
  };
}

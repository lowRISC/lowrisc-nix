# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  lua,
  readline,
  ncurses,
  lz4,
}:
stdenv.mkDerivation rec {
  pname = "xmake";
  version = "2.9.1";

  src = fetchurl {
    url = "https://github.com/xmake-io/xmake/releases/download/v${version}/xmake-v${version}.tar.gz";
    hash = "sha256-ox2++MMDrqEmgGi0sawa7BQqxBJMfLfZx+61fEFPjRU=";
  };

  # This patch is needed because, when building with Nix,
  # coreutils' and findutils' versions of date and find are provided,
  # which have slightly different behaviour to the macOS versions.
  patches = [./macosx.patch];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    lua
    readline
    ncurses
    lz4
  ];

  strictDeps = true;

  meta = with lib; {
    description = "A cross-platform build utility based on Lua";
    homepage = "https://xmake.io";
    license = licenses.asl20;
    platforms = lua.meta.platforms;
  };
}

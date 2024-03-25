# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchurl,
  stdenv,
  lib,
  udev,
  docker,
  makeWrapper,
  autoPatchelfHook,
}:
# We currently fetch from container-hotplug directly due to complexity in building bpf-linker.
stdenv.mkDerivation rec {
  name = "container-hotplug";
  version = "20240319-2";
  src = fetchurl {
    url = "https://github.com/lowRISC/container-hotplug/releases/download/${version}/container-hotplug";
    sha256 = "sha256-1LWPYssU4HGw4C85mKq/lFtfQMhtexA2Qc87j4OIh0Y=";
  };

  buildInputs = [
    udev
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [makeWrapper autoPatchelfHook];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -R $src $out/bin/container-hotplug
    chmod +x $out/bin/container-hotplug

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/container-hotplug --prefix PATH : "${lib.makeBinPath [docker]}"
  '';
}

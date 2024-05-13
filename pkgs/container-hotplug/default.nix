# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  fetchurl,
  stdenv,
  lib,
  udev,
  runc,
  # This must be makeBinaryWrapper since podman will refuse to execute a script
  makeBinaryWrapper,
  autoPatchelfHook,
}:
# We currently fetch from container-hotplug directly due to complexity in building bpf-linker.
stdenv.mkDerivation rec {
  name = "container-hotplug";
  version = "20240513-1";
  src = fetchurl {
    url = "https://github.com/lowRISC/container-hotplug/releases/download/${version}/container-hotplug";
    hash = "sha256-EwOaxpc5aJt+lMoz4emfOYH0+kQFaHJFAXfXFjb1r5A=";
  };

  buildInputs = [
    udev
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [makeBinaryWrapper autoPatchelfHook];

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
    wrapProgram $out/bin/container-hotplug --prefix PATH : "${lib.makeBinPath [runc]}"
  '';

  meta = {
    description = "Hot-plug devices into a container as they are plugged";
    homepage = "https://github.com/lowRISC/container-hotplug";
    license = lib.licenses.asl20;
    mainProgram = "container-hotplug";
  };
}

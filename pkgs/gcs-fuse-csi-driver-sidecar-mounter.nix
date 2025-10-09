# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gcsfuse,
  dockerTools,
  runCommandLocal,
  cacert,
}: let
  mounter = buildGoModule rec {
    pname = "gcs-fuse-csi-driver-sidecar-mounter";
    version = "1.19.4";

    src = fetchFromGitHub {
      owner = "googlecloudplatform";
      repo = "gcs-fuse-csi-driver";
      rev = "v${version}";
      hash = "sha256-v4TuRCq/YVl4WrIiiGuq4/TE12wkSgen7mc3rD7quf0=";
    };
    vendorHash = null;

    subPackages = ["cmd/sidecar_mounter"];

    ldflags = ["-s" "-w" "-X main.version=${version}"];

    postInstall = ''
      mv $out/bin/sidecar_mounter $out/bin/gcs-fuse-csi-driver-sidecar-mounter
    '';

    dontCheck = true;

    meta.mainProgram = pname;
  };
in
  dockerTools.buildLayeredImage {
    name = "gcs-fuse-csi-driver-sidecar-mounter";
    tag = "latest";
    contents = [
      (runCommandLocal "root" {} ''
        mkdir -p $out/etc/ssl/certs
        ln -s ${lib.getExe gcsfuse} $out/
        ln -s ${lib.getExe mounter} $out/
        # Ensure SSL can still find certificates
        ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt $out/etc/ssl/certs/ca-certificates.crt
      '')
    ];
    config = {
      Entrypoint = ["/gcs-fuse-csi-driver-sidecar-mounter"];
    };
  }
  // {
    meta = with lib; {
      description = "Sidecar mounter for the Google Cloud Storage FUSE Container Storage Interface (CSI) Plugin";
      homepage = "https://github.com/GoogleCloudPlatform/gcs-fuse-csi-driver";
      changelog = "https://github.com/GoogleCloudPlatform/gcs-fuse-csi-driver/releases/tag/v${version}";
      license = licenses.asl20;
      platforms = ["x86_64-linux"];
    };
  }

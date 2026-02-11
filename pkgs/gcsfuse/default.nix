# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  stdenv,
  buildGo124Module,
  fetchFromGitHub,
  lib,
}:
buildGo124Module rec {
  pname = "gcsfuse";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "googlecloudplatform";
    repo = "gcsfuse";
    rev = "v${version}";
    hash = "sha256-PdYHsHIlq77QnsjD1z3KliW3JHLZ0M26I4Z7v0SuvlU=";
  };

  vendorHash = "sha256-w5EOHPOJLfINILrP3ipZwYUAcAJIlGw1HlVAUAzW3x4=";

  patches = [
    # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2269
    ./dentry-cache.patch
    # https://github.com/GoogleCloudPlatform/gcsfuse/pull/2285
    ./symlink-cache.patch
    ./turn-knob.patch
  ];

  meta = {
    description = "User-space file system for interacting with Google Cloud Storage";
    homepage = "https://cloud.google.com/storage/docs/gcs-fuse";
    changelog = "https://github.com/GoogleCloudPlatform/gcsfuse/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [];
    # internal/cache/file/downloader/job.go:386:77: undefined: syscall.O_DIRECT
    mainProgram = "gcsfuse";
    broken = stdenv.hostPlatform.isDarwin;
  };

  subPackages = [
    "."
    "tools/mount_gcsfuse"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.gcsfuseVersion=${version}"
  ];

  checkFlags = let
    skippedTests = [
      # Disable flaky tests
      "Test_Main"
      "TestFlags"
    ];
  in ["-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"];

  postInstall = ''
    ln -s $out/bin/mount_gcsfuse $out/bin/mount.gcsfuse
    ln -s $out/bin/mount_gcsfuse $out/bin/mount.fuse.gcsfuse
  '';
}

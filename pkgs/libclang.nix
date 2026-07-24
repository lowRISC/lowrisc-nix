# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
#
# LLVM file tree (clang binary + libclang.so + C++ runtime) that can saved in
# the nix-cache for Bazel to use. The package is sourced from nixpkgs.
# This module is a generic builder which takes the LLVM release version, e.g.
#   libclang_21 = pkgs.callPackage ./libclang.nix { llvmPackages = pkgs.llvmPackages_21; };
#
# Motivation: OpenTitan's bazel rules_rust bindgen toolchain uses dlopen to open
# libclang.so and we can configure Bazel to use this nix packaged version
# instead.
# The version Bazel would otherwise download has RUNPATH `$ORIGIN/../lib` and
# relies on the system loader to find libtinfo/libstdc++ which fails under Nix,
# where bindgen-cli uses the nixpkgs glibc loader that ignores /etc/ld.so.cache.
# The nixpkgs libclang.so instead carries an absolute nix-store RUNPATH, so it
# resolves its own dependencies with no env fix-ups.
#
# The layout mirrors the three targets that a bindgen toolchain references:
#   bin/clang, lib/libclang.so, lib/libc++.so
{
  lib,
  runCommand,
  llvmPackages,
  stdenv,
}: let
  inherit (llvmPackages) libclang clang-unwrapped;
  # The C++ runtime against which the nixpkgs libclang is actually linked (because its RUNPATH
  # points here), but exposed under the `libc++.so` name that a toolchain expects.
  cxxLib = stdenv.cc.cc.lib;
in
  runCommand "libclang-${libclang.version}" {
    passthru = {inherit (libclang) version;};
    meta.description = "nixpkgs libclang ${libclang.version} tree for a Bazel bindgen toolchain";
  } ''
    mkdir -p $out/bin $out/lib
    ln -s ${clang-unwrapped}/bin/clang $out/bin/clang
    ln -s ${lib.getLib libclang}/lib/libclang.so $out/lib/libclang.so
    ln -s ${cxxLib}/lib/libstdc++.so $out/lib/libc++.so
  ''

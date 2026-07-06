# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
#
# Generic FHS runtime-library superset for commercial EDA tools.
#
# EDA vendors ship pre-compiled binaries that expect a traditional FHS layout
# (/usr/lib, /bin, ...) populated with a broad set of shared libraries. This
# file returns the union of the runtime libraries needed to run the EDA tools
# lowRISC uses, so a single shared FHS env (see edaShell.nix) can host any of
# them.
#
# NOTE: this contains only generic nixpkgs packages — no site paths, license
# servers or per-tool layout. All of that is supplied at runtime via the config
# file consumed by `mkEdaShell` (see edaShell.nix). Deliberately a broad
# superset: including a library a given tool does not need is harmless.
{pkgs}: let
  # ncurses5/6 are patched to carry the correct SONAMEs so they resolve under
  # FHS ldconfig. Both must coexist; combining them via symlinkJoin avoids a
  # buildFHSEnv infinite-recursion quirk when the same store path is reachable
  # by two routes.
  ncurses-fhs = pkgs.symlinkJoin {
    name = "ncurses-fhs";
    paths = [
      (pkgs.callPackage ../pkgs/ncurses5-fhs.nix {})
      (pkgs.callPackage ../pkgs/ncurses6-fhs.nix {})
    ];
  };
in
  with pkgs;
    [
      # jq drives the runtime config parsing in the generated profile.
      jq

      # Shells / core userland the tools shell out to.
      bash
      coreutils
      ksh
      perl
      bc
      time
      hostname
      procps
      util-linux.lib
      lsb-release # some tools probe the host OS even when unsupported

      # Toolchain (tools invoke a compiler/linker for DPI, cosim models, etc.).
      stdenv.cc
      # A modern, *unwrapped* binutils so /usr/bin/{ld,as,ar,objdump,...} are
      # plain system-style tools. stdenv.cc alone provides a wrapped `ld` that
      # injects Nix-specific dynamic-linker/rpath flags — unwanted by vendor
      # toolchains that shell out to a bare `ld`. hiPrio makes these win the
      # collision with the cc-wrapper's binaries. (This covers linkers resolved
      # via PATH only; a vendor toolchain's own bundled `ld`, invoked by absolute
      # path, is unaffected — that was the job of the removed `ldRelink` shim.)
      (lib.hiPrio binutils-unwrapped)

      # Compression / math / misc core libraries
      zlib
      lz4
      zstd
      brotli.lib
      gmp
      pcre2
      readline
      expat
      sqlite
      libssh

      # Crypto / auth / system integration
      libxcrypt
      libxcrypt-legacy
      libgpg-error
      libgcrypt
      krb5.lib
      libidn2
      nss
      nspr
      keyutils.lib
      libselinux
      libcap
      attr
      acl
      libuuid
      numactl
      curl
      elfutils
      e2fsprogs
      systemd
      dbus.lib
      alsa-lib
      gdb

      # XML
      libxml2
      libxml2_13

      # Fonts / 2D / GTK stack
      freetype
      fontconfig
      graphite2
      libpng
      libjpeg
      gd
      cairo
      pango
      gdk-pixbuf
      glib
      gtk2
      at-spi2-atk
      motif

      # OpenGL
      libGL
      libGLU

      # X11 client libraries and helpers (GUIs, waveform viewers, ...)
      libx11
      libxext
      libxrender
      libxtst
      libxi
      libxft
      libxp
      libxt
      libxmu
      libsm
      libice
      libxkbcommon
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxfixes
      libxscrnsaver
      libxrandr
      libxau
      libxdmcp
      libxinerama
      libxcb-wm
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
    ]
    ++ [ncurses-fhs]

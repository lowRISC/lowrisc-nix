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

  # Some vendor tool scripts have a `#!/bin/csh` shebang. nixpkgs' tcsh does
  # not itself provide a `csh` name, so add one.
  tcsh-fhs = pkgs.symlinkJoin {
    name = "tcsh-fhs";
    paths = [pkgs.tcsh];
    postBuild = ''
      ln -s ${pkgs.tcsh}/bin/tcsh $out/bin/csh
    '';
  };

  # The Nix cc-wrapper knows nothing about the FHS tree. buildFHSEnv teaches it
  # by exporting `NIX_CFLAGS_COMPILE=-idirafter /usr/include` and
  # `NIX_LDFLAGS=-L/usr/lib ...` from the profile, so any build that sanitises
  # the environment before invoking the compiler loses /usr/include and
  # /usr/lib. Bazel is the case in point: with `--incompatible_strict_action_env`
  # and an explicit action `env`, the compiler is handed nothing but PATH and
  # HOME, and a Bazel-driven Verilator build fails on `#include <libelf.h>` even
  # though libelf is right there in the sandbox.
  #
  # Bake the FHS search paths into the wrapper instead, so the compiler behaves
  # like a system compiler no matter what environment it is invoked from. The
  # wrapper's add-flags.sh reads `nix-support/cc-cflags` and `cc-ldflags`
  # unconditionally — unlike the generic `NIX_*` variables, which it only
  # consumes when the matching `NIX_{CC,BINTOOLS}_WRAPPER_TARGET_HOST_<salt>`
  # role variable is also set. `-idirafter` keeps /usr/include last in the
  # search order, after the wrapper's own libc headers and any package's -I.
  # Same intent as the pkg-config and aclocal wrappers below.
  cc-fhs = pkgs.stdenv.cc.override (old: {
    extraBuildCommands =
      (old.extraBuildCommands or "")
      + ''
        echo "-idirafter /usr/include" >> $out/nix-support/cc-cflags
        echo "-L/usr/lib -L/usr/lib32" >> $out/nix-support/cc-ldflags
      '';
  });

  # Bazel filters out all environment including PKG_CONFIG_PATH. Append this inside wrapper.
  pkg-config-patched = pkgs.pkg-config.override {
    extraBuildCommands = ''
      # nixpkgs installs utils.bash read-only (install -m444), so make it
      # writable to append, then restore the original mode.
      chmod +w $out/nix-support/utils.bash
      echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig" >> $out/nix-support/utils.bash
      chmod 444 $out/nix-support/utils.bash
    '';
  };

  # Wrap automake's aclocal to set the default macro search path to the FHSenv pre-populated value
  # The nixpkgs default is to use ACLOCAL_PATH to override this default, but this avoids passing another
  # environment into the sandbox non-hermetically.
  automake' = pkgs.automake.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/aclocal --add-flags "--system-acdir=/usr/share/aclocal"
      '';
  });
in
  with pkgs;
    [
      # jq drives the runtime config parsing in the generated profile.
      jq

      # Shells / core userland the tools shell out to.
      bash
      coreutils
      file
      tree
      zip
      ksh
      tcsh-fhs
      perl
      bc
      time
      hostname
      procps
      util-linux.lib
      lsb-release # some tools probe the host OS even when unsupported

      # Toolchain (tools invoke a compiler/linker for DPI, cosim models, etc.).
      # Wrapped above so it finds /usr/include and /usr/lib without relying on
      # the profile's NIX_CFLAGS_COMPILE / NIX_LDFLAGS reaching the compiler.
      cc-fhs
      # A modern, *unwrapped* binutils so /usr/bin/{ld,as,ar,objdump,...} are
      # plain system-style tools. stdenv.cc alone provides a wrapped `ld` that
      # injects Nix-specific dynamic-linker/rpath flags — unwanted by vendor
      # toolchains that shell out to a bare `ld`. hiPrio makes these win the
      # collision with the cc-wrapper's binaries. (This covers linkers resolved
      # via PATH only; a vendor toolchain's own bundled `ld`, invoked by absolute
      # path, is unaffected — that was the job of the removed `ldRelink` shim.)
      (lib.hiPrio binutils-unwrapped)
      # Build drivers and helpers the flows routinely shell out to (make-based
      # sim harnesses, fusesoc, version stamping, third-party autotools/cmake
      # builds, ...). Without these in the base env they only happened to resolve
      # via a configured vendor tool's own bundled PATH, which silently broke
      # whenever no such tool was active.
      automake'
      gnumake
      git
      cmake
      pkg-config-patched
      autoconf
      libtool

      # Compression / math / misc core libraries
      zlib
      lz4
      zstd
      brotli.lib
      brotli # the `brotli` CLI (brotli.lib above is only the shared library)
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
      libxslt.bin # provides xsltproc (binaries live in the `bin` output)
      xmlstarlet

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

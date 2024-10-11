# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
#
# This is a buildFHSEnvBubblewrap alternative which tries to overlay /usr
# on top of what's already available instead of replacing it.
#
# The default buildFHSEnvBubblewrap works very well under NixOS since /usr
# is empty, but it can cause issues inside already FHS distros because the
# root /usr is not longer available inside FHS env. Instead of replacing, this
# buildFHSEnvOverlay uses overlayfs to add things on top.
#
# Note that /usr for the host must not contain mountpoints otherwise overlay
# will fail to work inside a new mount namespace (which is needed to avoid
# root privilege).
#
# Some additional features:
# * pname/version must be used instead of setting name.
# * The binary name will follow meta.mainProgram if set, otherwise use pname.
# * A `preExecHook` can be set to be executed before control is transferred to
#   `runScript`. It has access to the following helper functions:
#   * `tmpfs a`: mount a tmpfs on the given location `a`.
#   * `bind a b`: bind mount location `a` to location `b`.
# * The `env` attribute would set `SHELL` to the invoking shell. The normal
#   FHS env would either keep it unchanged, or with newer nix version, set it
#   to a non-interactive bash.
{
  lib,
  stdenv,
  callPackage,
  runCommandLocal,
  writeShellScript,
  glibc,
  pkgsi686Linux,
  coreutils,
  buildFHSEnv,
  util-linux,
}: {
  pname,
  version,
  runScript ? "bash",
  preExecHook ? "",
  meta ? {},
  passthru ? {},
  ...
} @ args: let
  inherit (lib) optionalString removeAttrs;

  name = "${pname}-${version}";
  exeName = meta.mainProgram or pname;

  # Build a FHS directory structure only, without any wrappers. This is passed through by upstream nixpkgs's buildFHSEnv.
  buildFHSEnvEnv = args: (buildFHSEnv args).fhsenv;

  # We don't want to maintain a buildFHSEnv.nix ourselves, so pass the arguments through the nixpkgs buildFHSEnv
  # and steal the built FHS env out.
  fhsenv = buildFHSEnvEnv (removeAttrs args [
    "runScript"
    "preExecHook"
    "meta"
    "passthru"
  ]);

  initCmd =
    ''
      tmpfs() {
        ${coreutils}/bin/mkdir -p "$1"
        ${util-linux}/bin/mount none -t tmpfs "$1"
      }

      bind() {
        if [[ -d "$1" ]]; then
          ${coreutils}/bin/mkdir -p "$2"
        else
          ${coreutils}/bin/touch "$2"
        fi
        ${util-linux}/bin/mount --rbind "$1" "$2"
      }

      # We need a directory for the temporary root. Use /tmp because it'll always exist.
      tmpfs /tmp

      # Mount /nix first so the commands can keep execution after root pivoting before
      # environment setup.
      bind /nix /tmp/nix

      # Pivot root
      ${coreutils}/bin/mkdir /tmp/.host-root
      ${util-linux}/bin/pivot_root /tmp /tmp/.host-root

      # We want to mask out /usr/include/<arch> since
      # NixOS doesn't provide these directories. If they exist it may
      # cause headers from multiple glibc version to be mixed.
      # Shadow them with white-out node.
      tmpfs /usr
      ${coreutils}/bin/mkdir /usr/include
      ${coreutils}/bin/mknod /usr/include/x86_64-linux-gnu c 0 0
      ${coreutils}/bin/mknod /usr/include/i386-linux-gnu c 0 0

      # Merge /usr between the FHS env and the root.
      ${util-linux}/bin/mount none -t overlay -o lowerdir=/usr:${fhsenv}/usr:/.host-root/usr /usr

      # Mount a new /etc because we want to write ld caches.
      tmpfs /etc

      # Loop through all entries in host /etc and make it available under FHS.
      for i in /.host-root/etc/*; do
        path="/etc/''${i##*/}"
        case "$path" in
          # Provided by FHS
          /etc/profile | /etc/profile.d)
            continue
            ;;
          # Populated later
          /etc/ld.so*)
            continue
            ;;
        esac

        if [[ -L $i ]]; then
          ${coreutils}/bin/cp -P $i $path
        else
          bind "$i" "$path"
        fi
      done

      # Make /etc/profile and /etc/profile.d from FHS env available.
      for i in ${fhsenv}/etc/{profile,profile.d}; do
        path="/etc/''${i##*/}"
        if [[ -L $i ]]; then
          ${coreutils}/bin/cp -P $i $path
        else
          bind "$i" "$path"
        fi
      done

      # Symlink /{bin,lib,lib64,sbin} (merged /usr).
      for i in /{bin,lib,lib64,sbin}; do
          ${coreutils}/bin/ln -s /usr$i $i
      done

      # Loop through all other entries in the root.
      for i in /.host-root/*; do
        path="/''${i##*/}"
        if [[ -L $path ]] || [[ -e $path ]]; then
          :
        elif [[ -L $i ]]; then
          ${coreutils}/bin/cp -P "$i" "$path"
        else
          bind "$i" "$path"
        fi
      done

      # Since we have pivoted root, our CWD points to /.host-root/xxx
      cd $PWD

      # Build LD cache so libraries under /lib and others can be found.
      # See buildFHSEnvBubblewrap.
      tmpfs ${glibc}/etc
      ${coreutils}/bin/ln -s /etc/ld.so.conf ${glibc}/etc/ld.so.conf
      ${coreutils}/bin/ln -s /etc/ld.so.cache ${glibc}/etc/ld.so.cache
      bind ${glibc}/etc/rpc ${glibc}/etc/rpc
    ''
    + optionalString fhsenv.isMultiBuild ''
      tmpfs ${pkgsi686Linux.glibc}/etc
      ${coreutils}/bin/ln -s /etc/ld.so.conf ${pkgsi686Linux.glibc}/etc/ld.so.conf
      ${coreutils}/bin/ln -s /etc/ld.so.cache ${pkgsi686Linux.glibc}/etc/ld.so.cache
      bind ${pkgsi686Linux.glibc}/etc/rpc ${pkgsi686Linux.glibc}/etc/rpc
    ''
    + ''
      source /etc/profile

      cat > /etc/ld.so.conf <<EOF
      /lib
      /lib/x86_64-linux-gnu
      /lib64
      /usr/lib
      /usr/lib/x86_64-linux-gnu
      /usr/lib64
      /lib/i386-linux-gnu
      /lib32
      /usr/lib/i386-linux-gnu
      /usr/lib32
      /run/opengl-driver/lib
      /run/opengl-driver-32/lib
      EOF
      ldconfig &> /dev/null

      ${preExecHook}
      exec unshare -c -- ${runScript} "$@"
    '';

  init = writeShellScript "${name}-init" initCmd;
  bin = writeShellScript "${name}-wrap" ''
    ${util-linux}/bin/unshare --map-current-user --mount --keep-caps -- ${init} "$@"
  '';
in
  runCommandLocal name {
    inherit pname version meta;

    passthru =
      passthru
      // {
        env =
          runCommandLocal name {
            shellHook = ''
              # Detect the parent shell. New versions of nix will set SHELL variable to non-interactive bash so we need to detect
              # using other mechanism.
              parent_shell=$(${coreutils}/bin/readlink /proc/$PPID/exe)
              case "$parent_shell" in
                # If the parent shell is one of the recognised shells
                *bash | *fish | *zsh)
                  export SHELL="$parent_shell"
                  ;;

                # If we cannot recognise, then unset it to avoid using the non-interactive bash.
                *)
                  unset SHELL
                  ;;
              esac
              exec ${bin}
            '';
          } ''
            echo >&2 ""
            echo >&2 "*** buildFHSEnvOverlay 'env' attributes are intended for interactive nix-shell sessions, not for building! ***"
            echo >&2 ""
            exit 1
          '';
        inherit args fhsenv;
      };
  } ''
    mkdir -p $out/bin
    ln -s ${bin} $out/bin/${exeName}
  ''

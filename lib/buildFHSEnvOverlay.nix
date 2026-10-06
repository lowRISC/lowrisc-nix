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
  gnugrep,
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
  fhsenv = buildFHSEnvEnv ((removeAttrs args [
      "runScript"
      "preExecHook"
      "meta"
      "passthru"
    ])
    // {
      extraBuildCommands =
        (args.extraBuildCommands or "")
        + ''
          rm $out/usr/lib
          cp -r $out/usr/lib64 $out/usr/lib
        '';
    });

  initCmd =
    ''
      # Guard the overlay stacking depth. This MUST be the very first thing the
      # hook does: it has to run before any mount so that, on refusal, exiting
      # cleanly drops the user back into the sandbox they were already in.
      #
      # Why there is a hard ceiling: overlayfs is a *stacking* filesystem -- it
      # implements each operation by calling the same operation on its underlying
      # layer. So one VFS call entering the top overlay descends through every
      # layer in the stack, and each stacked layer the call passes through pushes
      # its own frames onto the kernel's call stack. That stack is small and
      # fixed (a couple of pages), so a deep tower of stacked filesystems can
      # overflow it. To bound that, the kernel caps the *total* filesystem stack
      # at FILESYSTEM_MAX_STACK_DEPTH = 2 (tracked per-superblock as
      # s_stack_depth, checked at mount time): enough for two stacked layers'
      # frames, no more. overlayfs returns EINVAL ("maximum fs stacking depth
      # exceeded") for anything that would reach depth 3.
      #
      # The breadcrumb variables are re-exported just before we exec the
      # runScript, so a nested `nix develop` inherits them and the depth count
      # stays accurate. Best-effort: if nix ever scrubs them the depth reads 0
      # and we fall through to the normal setup (whose own mount guards and
      # diagnostics still apply).
      _fhs_depth="''${LOWRISC_FHS_OVERLAY_DEPTH:-0}"
      _fhs_stack="''${LOWRISC_FHS_OVERLAY_STACK:-}"
      _fhs_max_depth=2
      if (( _fhs_depth >= _fhs_max_depth )); then
        echo "" >&2
        echo "ERROR: refusing to start another nested FHS overlay sandbox." >&2
        echo "" >&2
        echo "You are already inside $_fhs_depth FHS overlay sandbox(es):" >&2
        echo "    $_fhs_stack" >&2
        echo "" >&2
        echo "Starting another would stack overlay filesystems beyond the kernel's limit" >&2
        echo "(FILESYSTEM_MAX_STACK_DEPTH=$_fhs_max_depth) and the mount would fail mid-setup." >&2
        echo "This almost always means an earlier 'nix develop' session is still active in" >&2
        echo "this terminal." >&2
        echo "" >&2
        echo "Run 'exit' to leave a sandbox before starting a new one in this shell." >&2
        echo "" >&2
        exit 1
      fi

      tmpfs() {
        ${coreutils}/bin/mkdir -p "$1"
        ${util-linux}/bin/mount none -t tmpfs "$1"
      }

      bind() {
        if [[ -d "$1" ]]; then
          ${coreutils}/bin/mkdir -p "$2"
        elif ! [[ -e "$2" ]]; then
          ${coreutils}/bin/touch "$2"
        fi
        ${util-linux}/bin/mount --rbind "$1" "$2"
      }

      # Emit detailed diagnostics when the /usr overlay mount fails, so the user
      # is not left guessing why `jq` and every other FHS tool suddenly vanished.
      diagnose_usr_failure() {
        echo "" >&2
        echo "ERROR: buildFHSEnvOverlay could not overlay /usr; this sandbox cannot start." >&2
        echo "" >&2
        echo "The overlay mount of /usr failed (typically EINVAL, shown above as 'wrong fs" >&2
        echo "type, bad option, bad superblock'). An op descending through stacked filesystems" >&2
        echo "pushes frames per layer onto the fixed kernel stack, so the kernel caps the stack" >&2
        echo "at FILESYSTEM_MAX_STACK_DEPTH (2); overlayfs also cannot use a lowerdir that is" >&2
        echo "itself a mountpoint. The usual trigger is a host where /usr (or the dirs we fold" >&2
        echo "in) is already a separate mount or overlay, leaving no layer left for this env's" >&2
        echo "own overlay." >&2
        if (( _fhs_depth > 0 )); then
          echo "" >&2
          echo "You are already inside $_fhs_depth FHS overlay sandbox(es):" >&2
          echo "    ''${_fhs_stack:-(names unavailable)}" >&2
          echo "One nested env is allowed, but it spends the last of the two stacked layers, so" >&2
          echo "there is no headroom: if the host already stacks filesystems under /usr this" >&2
          echo "env tips over the limit. Run 'exit' to leave the sandbox(es) and retry from" >&2
          echo "your login shell." >&2
        fi
        echo "" >&2
        echo "Filesystems currently stacked at/under /usr (overlay rows list their lower layers):" >&2
        if ! ${lib.getExe gnugrep} -E ' /\.host-root/usr(/| )| - overlay ' /.host-root/proc/self/mountinfo >&2; then
          echo "    (could not read /proc/self/mountinfo)" >&2
        fi
        echo "" >&2
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

      # Overlay /usr from FHS env on top of existing /usr.
      USR_LOWERDIR=/usr:${fhsenv}/usr

      # overlayfs does not cross mounts inside a lowerdir, and it cannot stack on
      # top of a lowerdir that is itself a mountpoint. Only fold the host /usr in
      # when it is a plain directory with no mounts at or beneath it. The pattern
      # matches the /usr mountpoint itself (trailing space) as well as anything
      # beneath it (trailing slash).
      if ! ${lib.getExe gnugrep} -qE ' /\.host-root/usr(/| )' /.host-root/proc/mounts; then
        USR_LOWERDIR=$USR_LOWERDIR:/.host-root/usr
      else
        # The parent /usr is a mountpoint we cannot use as a lowerdir -- either a
        # standalone /usr partition, or (when nested inside another overlay env)
        # the parent env's own /usr overlay. Proceed with the FHS /usr only; any
        # parent tools the child needs are passed in explicitly.
        #
        # Only warn when this is unexpected, i.e. in a top-level env (depth 0)
        # where a standalone /usr partition silently costs the user the host's
        # /usr tools. When nested (depth > 0) it is the normal, documented
        # consequence of running an overlay env inside another.
        if (( _fhs_depth == 0 )); then
          echo "buildFHSEnvOverlay: host /usr is a standalone mountpoint; not layering it into this sandbox." >&2
        fi
      fi

      if ! ${util-linux}/bin/mount none -t overlay -o lowerdir=$USR_LOWERDIR /usr; then
        diagnose_usr_failure
        exit 1
      fi

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
          # /etc/ssl needs to be writable so preExecHook and similar can create new
          # files within it (e.g. symlinking CA certs or openssl.cnf). A writable
          # overlay keeps all host content visible without copying, which avoids
          # permission errors on restricted subdirectories such as /etc/ssl/private
          # that exist (mode 700, root-owned) on most Linux distributions.
          /etc/ssl)
            ${coreutils}/bin/mkdir -p /etc/ssl
            if [[ -d "$i" ]]; then
              ${coreutils}/bin/mkdir -p /etc/.ssl-overlay/upper /etc/.ssl-overlay/work
              ${util-linux}/bin/mount none -t overlay -o lowerdir="$i",upperdir=/etc/.ssl-overlay/upper,workdir=/etc/.ssl-overlay/work /etc/ssl
            fi
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

      # Record our nesting depth/name so any sandbox launched from within this
      # one can detect it (see the breadcrumb read and diagnostics above).
      export LOWRISC_FHS_OVERLAY_DEPTH=$(( _fhs_depth + 1 ))
      export LOWRISC_FHS_OVERLAY_STACK="''${_fhs_stack:+$_fhs_stack > }${name}"

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
          (runCommandLocal name {
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
            '')
          // {
            # Parallel env built with upstream nixpkgs `buildFHSEnv` instead of
            # the overlay sandbox, exposed unconditionally so any consumer can
            # opt into a hermetic comparison shell via `.env.hermetic` (i.e.
            # `nix develop .#<name>.hermetic` when the consumer returns `.env`).
            #
            # `preExecHook` is overlay-only (upstream `buildFHSEnv` does not
            # recognise it). To keep the consumer-facing API identical, its
            # contents are appended to `profile` for the hermetic env so any
            # portable setup (e.g. /etc/ssl symlinks) still runs. Setup that
            # relies on mount-namespace privileges (the `tmpfs`/`bind` helpers
            # only available in `preExecHook`) will silently no-op in the
            # hermetic shell — those flows need to be tested in the overlay env.
            hermetic = (
              (buildFHSEnv (
                (removeAttrs args ["preExecHook"])
                // {
                  profile =
                    (args.profile or "")
                    + optionalString (args ? preExecHook) ''

                      # Appended from `preExecHook` by buildFHSEnvOverlay so the
                      # hermetic env runs the same portable setup as the overlay env.
                      ${args.preExecHook}
                    '';
                }
              )).env.overrideAttrs (old: {
                # Recover the user's real interactive shell so `runScript`
                # (which expands `$SHELL`) does not exec the non-interactive
                # bash that `nix develop` injects. Without this, readline
                # builtins like `bind` and `shopt -s progcomp` fail when
                # bashrc files run inside the env. Matches the SHELL handling
                # the overlay env does in its own shellHook.
                shellHook =
                  ''
                    parent_shell=$(${coreutils}/bin/readlink /proc/$PPID/exe)
                    case "$parent_shell" in
                      *bash | *fish | *zsh)
                        export SHELL="$parent_shell"
                        ;;
                      *)
                        unset SHELL
                        ;;
                    esac
                  ''
                  + (old.shellHook or "");
              })
            );
          };
        inherit args fhsenv;
      };
  } ''
    mkdir -p $out/bin
    ln -s ${bin} $out/bin/${exeName}
  ''

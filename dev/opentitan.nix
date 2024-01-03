{
  pkgs,
  ncurses5-fhs,
  bazel_ot,
  python_ot,
  verilator_ot,
  edaTools ? [],
  wrapCCWith,
  gcc-unwrapped,
  pkg-config,
  ...
}: let
  edaExtraDeps = with pkgs; [elfutils openssl];

  # Bazel rules_rust expects build PIE binary in opt build but doesn't request PIE/PIC, so force PIC
  gcc-patched = wrapCCWith {
    cc = gcc-unwrapped;
    nixSupport.cc-cflags = ["-fPIC"];
  };

  # Bazel filters out all environment including PKG_CONFIG_PATH. Append this inside wrapper.
  pkg-config-patched = pkg-config.override {
    extraBuildCommands = ''
      echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig" >> $out/nix-support/utils.bash
    '';
  };
in
  (pkgs.buildFHSEnv {
    name = "opentitan";
    targetPkgs = _:
      with pkgs;
        [
          bazel_ot
          python_ot
          verilator_ot

          # For serde-annotate which can be built with just cargo
          rustup

          # Bazel downloads Rust compilers which are not patchelfed and they need this.
          zlib
          openssl
          curl

          gcc-patched
          pkg-config-patched

          libxcrypt-legacy
          udev
          libftdi1
          libusb1 # needed for libftdi1 pkg-config
          ncurses5-fhs

          srecord

          # For documentation
          hugo
          doxygen
        ]
        ++ map (tool:
          tool.override {
            extraDependencies = edaExtraDeps;
          })
        edaTools;
    extraOutputsToInstall = ["dev"];

    extraBwrapArgs = [
      # OpenSSL included in the Python downloaded by Bazel makes use of these paths.
      "--symlink ${pkgs.openssl.out}/etc/ssl/openssl.cnf /etc/ssl/openssl.cnf"
      "--symlink /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem"
    ];
  })
  .env

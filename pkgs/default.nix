# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  pkgs,
  inputs,
  ...
}: rec {
  ncurses5-fhs = pkgs.callPackage ./ncurses5-fhs.nix {};
  ncurses6-fhs = pkgs.callPackage ./ncurses6-fhs.nix {};
  fpga-udev-rules = pkgs.callPackage ./fpga-udev-rules {};

  # OpenTitan packages
  verilator_ot = import ./verilator {inherit pkgs;};
  python_ot = pkgs.callPackage ./python_ot {inherit inputs;};
  bazel_ot = pkgs.callPackage ./bazel_ot {};
  verible_ot = pkgs.callPackage ./verible_ot.nix {};

  # CherIoT packages
  spike-ibex-cosim = pkgs.callPackage ./spike.nix {};
  llvm_cheriot = pkgs.callPackage ./llvm_cheriot.nix {};
  cheriot-sim = pkgs.callPackage ./cheriot-sim.nix {};
  cheriot-audit = pkgs.callPackage ./cheriot-audit.nix {};

  verilator_caliptra = pkgs.callPackage ./verilator_caliptra.nix {inherit inputs;};

  # IT packages
  gcsfuse = pkgs.callPackage ./gcsfuse {};
  gcs-fuse-csi-driver-sidecar-mounter = pkgs.callPackage ./gcs-fuse-csi-driver-sidecar-mounter.nix {inherit gcsfuse;};
  container-hotplug = pkgs.callPackage ./container-hotplug {};
  nebula = pkgs.callPackage ./nebula.nix {};
  parallel-cp = pkgs.callPackage ./parallel-cp.nix {};

  uf2conv = pkgs.callPackage ./uf2conv.nix {};
  sv-lang_7 = import ./sv-lang.nix {inherit pkgs;};
  sv-bugpoint = pkgs.callPackage ./sv-bugpoint.nix {sv-lang = sv-lang_7;};
  veridian = pkgs.callPackage ./veridian/default.nix {inherit sv-lang_7;};
  peakrdl = pkgs.callPackage ./peakrdl.nix {};

  riscv64-gcc = pkgs.pkgsCross.riscv64.buildPackages.gcc;
  riscv64-gcc_caliptra = pkgs.callPackage ./riscv64-gcc_caliptra {};
  lowrisc-toolchain-gcc-rv32imcb = pkgs.callPackage ./lowrisc-toolchain-gcc-rv32imcb.nix {};
  lowrisc-toolchain-gcc-rv64imac = pkgs.callPackage ./lowrisc-toolchain-gcc-rv64imac.nix {};
}

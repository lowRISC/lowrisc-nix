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
  verible_ot = pkgs.callPackage ./verible.nix {};

  # CherIoT packages
  spike-ibex-cosim = pkgs.callPackage ./spike.nix {};
  llvm_cheriot = pkgs.callPackage ./llvm_cheriot.nix {};
  xmake = pkgs.callPackage ./xmake {};
  cheriot-sim = pkgs.callPackage ./cheriot-sim.nix {};
  cheriot-audit = pkgs.callPackage ./cheriot-audit.nix {};

  container-hotplug = pkgs.callPackage ./container-hotplug {};
  surfer = pkgs.callPackage ./surfer/default.nix {};
  uf2conv = pkgs.callPackage ./uf2conv.nix {};
  sv-lang_6 = pkgs.callPackage ./sv-lang.nix {};
  veridian = pkgs.callPackage ./veridian/default.nix {inherit sv-lang_6;};
  peakrdl = pkgs.callPackage ./peakrdl.nix {};

  riscv64-gcc = pkgs.pkgsCross.riscv64.buildPackages.gcc;
  lowrisc-toolchain-gcc-rv32imcb = pkgs.callPackage ./lowrisc-toolchain-gcc-rv32imcb.nix {};
  lowrisc-toolchain-gcc-rv64imac = pkgs.callPackage ./lowrisc-toolchain-gcc-rv64imac.nix {};
}

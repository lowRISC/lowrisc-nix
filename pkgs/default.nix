# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  pkgs,
  inputs,
  ...
}:
{
  ncurses5-fhs = pkgs.callPackage ./ncurses5-fhs.nix {};

  # OpenTitan packages
  verilator_ot = import ./verilator {inherit pkgs;};
  python_ot = pkgs.callPackage ./python_ot {inherit inputs;};
  bazel_ot = pkgs.callPackage ./bazel_ot {};
  verible_ot = pkgs.callPackage ./verible.nix {};

  # CherIoT packages
  spike-ibex-cosim = pkgs.callPackage ./spike.nix {};
  llvm_cheriot = pkgs.callPackage ./llvm_cheriot.nix {};
  xmake = import ./xmake.nix {inherit pkgs;};
  cheriot-sim = pkgs.callPackage ./cheriot-sim.nix {};

  container-hotplug = pkgs.callPackage ./container-hotplug {};
  surfer = pkgs.callPackage ./surfer/default.nix {};
}
// pkgs.lib.optionalAttrs (pkgs.system == "x86_64-linux") {
  lowrisc-toolchain-gcc-rv32imcb = pkgs.callPackage ./lowrisc-toolchain-gcc-rv32imcb.nix {};
  lowrisc-toolchain-gcc-rv64imac = pkgs.callPackage ./lowrisc-toolchain-gcc-rv64imac.nix {};
}

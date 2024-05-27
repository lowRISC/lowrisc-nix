# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  runCommand,
  lib,
}:
runCommand "fpga-udev-rules" {
  meta.platforms = lib.platforms.linux;
} ''
  mkdir -p $out/etc/udev/rules.d
  cp ${./.}/*.rules $out/etc/udev/rules.d/
''

# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{runCommand}:
runCommand "fpga-udev-rules" {} ''
  mkdir -p $out/etc/udev/rules.d
  cp ${./.}/*.rules $out/etc/udev/rules.d/
''

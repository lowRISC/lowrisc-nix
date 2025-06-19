# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  runCommand,
  ncurses5,
  patchelf,
  lib,
  ...
}:
# If SONAME is specified, lookup cache files created by ldconfig will only use the SONAME and will ignore
# the filename. This can prevent libtinfo.so and libncurses.so from being found under FHS.
# Patch the ncurses package to provide libs with the correct SONAMEs.
runCommand "ncurses5" {
  outputs = ["out" "dev" "man"];
  meta.platforms = lib.platforms.linux;
} ''
  cp -r ${ncurses5} $out
  chmod +w $out/lib
  cp -L --no-preserve=mode --remove-destination `realpath $out/lib/libtinfo.so.5` $out/lib/libtinfo.so.5
  ${patchelf}/bin/patchelf --set-soname libtinfo.so.5 $out/lib/libtinfo.so.5
  cp -L --no-preserve=mode --remove-destination `realpath $out/lib/libncurses.so.5` $out/lib/libncurses.so.5
  ${patchelf}/bin/patchelf --set-soname libncurses.so.5 $out/lib/libncurses.so.5
  cp -r ${ncurses5.dev} $dev
  cp -r ${ncurses5.man} $man
''

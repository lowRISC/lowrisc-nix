# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  runCommand,
  ncurses6,
  patchelf,
  lib,
  ...
}:
# If SONAME is specified, lookup cache files created by ldconfig will only use the SONAME and will ignore
# the filename, this casues libtinfo.so to not be found under FHS. Patch ncurses5 to provide a libtinfo.so
# with proper SONAME.
runCommand "ncurses6" {
  outputs = ["out" "dev" "man"];
  meta.platforms = lib.platforms.linux;
} ''
  cp -r ${ncurses6} $out
  chmod +w $out/lib
  cp -L --no-preserve=mode --remove-destination `realpath $out/lib/libtinfo.so.6` $out/lib/libtinfo.so.6
  ${patchelf}/bin/patchelf --set-soname libtinfo.so.6 $out/lib/libtinfo.so.6
  cp -r ${ncurses6.dev} $dev
  cp -r ${ncurses6.man} $man
''

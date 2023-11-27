{pkgs, ...}: {
  verilator_ot = import ./verilator {inherit pkgs;};
}

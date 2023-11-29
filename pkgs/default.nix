{
  pkgs,
  inputs,
  ...
}: {
  verilator_ot = import ./verilator {inherit pkgs;};
  python_ot = pkgs.callPackage ./python_ot {inherit inputs;};
}

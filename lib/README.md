# lowRISC Nix Libraries

## The Documentation Library

The `doc` library contains `buildMdbookSite`, which is a helper function for creating mdBook site builds.
An example of it's use is below.

```nix
let
  fs = pkgs.lib.fileset;
in {
  docs_build = doc.buildMdbookSite {
    pname = "documentation";
    version = "0.0.1";
    nativeBuildInputs = [pkgs.python311];
    src = fs.toSource {
      root = ./.;
      fileset = fs.unions [
        (doc.standardMdbookFileset ./.)
        ./util/mdbook
        ./util/mdbook_wavejson.py
      ];
    };
  };
}
```

*Note: `pkgs.mdbook` is not required in nativeBuildInputs.*

`standardMdbookFileset` and `hasExts` are also provided to further help in creating derivations.

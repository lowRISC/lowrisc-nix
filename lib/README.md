# lowRISC Nix Libraries

## The Documentation Library

The `doc` library contains `buildMdbookSite`, which is a helper function for creating mdBook site builds.
An example of its use is below.

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

Notice, that `pkgs.mdbook` doesn't need to be given as part of the `nativeBuildInputs`, so one only needs to provide dependencies of preprocessors run by mdBook.
In this case, just python.

`standardMdbookFileset` and `hasExts` are also provided to further help in creating derivations.

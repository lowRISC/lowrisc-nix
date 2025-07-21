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

## `evalFlake` function

The `lowrisc-nix` provides a `evalFlake` function which is a more powerful version than the nix's `builtins.getFlake` function:
* It allows a store path to be used (this includes flake sources which are copied to the store), which `builtins.getFlake` does not.
* It allows dependency to be overriden, similar to `inputs.<name>.follows`.

The signature is `{ src: path, inputOverride: attrsOf flake } -> flake`. An example of it use:
```nix
lib.evalFlake {
    src = /path/to/flake;
    inputOverride = {
        nixpkgs = inputs.nixpkgs;
    };
}
```


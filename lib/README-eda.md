<!--
Copyright lowRISC Contributors.
Licensed under the MIT License, see LICENSE for details.
SPDX-License-Identifier: MIT
-->
# Generic EDA development shell (`lib.mkEdaShell`)

`mkEdaShell` builds a Nix development shell for running commercial EDA tools. The
tools themselves are **not** built by Nix — they are pre-compiled vendor binaries
installed on shared storage. The shell provides:

1. an FHS environment (`/usr/lib`, `/bin`, …) populated with the shared
   libraries those binaries need (`lib/edaFhsPackages.nix`), and
2. a runtime profile that sets each tool's `PATH`, home variable and license
   environment from a **site config file**.

The builder contains **no site or vendor secrets**. A project declares only
*which tools and versions it needs*. Everything site-specific (install paths,
license servers, per-tool layout) comes from a JSON config file located at
runtime via an environment variable (default `LOWRISC_EDA_CONFIG`). Anyone can
use the shell by writing their own config and pointing the variable at it.

If the config file is unset or missing, the shell still works — the base Nix
tools remain on `PATH` — and prints a warning instead of configuring EDA tools.

## Usage

```nix
# flake.nix of a project
{
  inputs.lowrisc-nix.url = "github:lowRISC/lowrisc-nix";
  outputs = { self, nixpkgs, lowrisc-nix, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.eda = lowrisc-nix.lib.mkEdaShell {
      inherit pkgs;
      name = "myproject";
      # <vendor>.<tool> = "<version>"; — must match the keys in the config file.
      tools = {
        vendor_a.simulator = "2025.03";
        vendor_a.debugger  = "2025.03";
        vendor_b.synth     = "4.2";
      };
      # Optional: extra FHS packages / project build deps.
      extraDeps = with pkgs; [ python3 ];
      # Optional: appended after EDA setup.
      profile = ''export FOO=bar'';
    };
  };
}
```

`mkEdaShell` takes a plain nixpkgs set — it builds the FHS-env wrapper itself,
so no overlay wiring is needed. Arguments:

| arg            | required | meaning                                                        |
|----------------|----------|----------------------------------------------------------------|
| `pkgs`         | yes      | a nixpkgs package set (plain; no overlay required)            |
| `name`         | yes      | shell / FHS `pname`                                            |
| `tools`        | yes      | `{ <vendor>.<tool> = "<version>"; }` — the requested selectors |
| `configEnvVar` | no       | env var naming the config file (default `LOWRISC_EDA_CONFIG`)  |
| `extraDeps`    | no       | extra packages added to the FHS env                            |
| `extraPkgs`    | no       | extra packages added to the FHS env (alias of `extraDeps`)     |
| `profile`      | no       | bash fragment appended after EDA setup                         |

## Config file contract

Point `LOWRISC_EDA_CONFIG` at a JSON file matching this schema. `home` is the
fully-resolved absolute install directory for that tool version. The vendor,
tool and version keys are arbitrary strings that must match the `tools` selector
in the project flake.

```json
{
  "vendors": {
    "vendor_a": {
      "license": { "envVars": { "VENDOR_A_LICENSE_FILE": "1717@license.example.com" } },
      "tools": {
        "simulator": {
          "homeVar": "SIMULATOR_HOME",
          "pathDirs": ["bin", "tools/bin"],
          "executables": ["sim", "sim-gui"],
          "extraEnvVars": {},
          "extraPaths": {},
          "requires": [],
          "capabilities": { "ldRelink": ["toolchain/gcc/bin/ld"] },
          "versions": {
            "2025.03": { "home": "/tools/vendor_a/simulator/2025.03" }
          }
        }
      }
    }
  }
}
```

Per-tool fields (all optional except `versions`):

- `homeVar` — env var set to the resolved `home` (e.g. `SIMULATOR_HOME`). A user
  may override the directory at runtime by exporting `USER_<homeVar>`.
- `pathDirs` — directories under `home` prepended to `PATH` (default `["bin"]`).
- `executables` — binaries this tool provides; each is sanity-checked to resolve
  on `PATH` (a miss warns, it does not fail the shell).
- `extraEnvVars` — literal `VAR=value` exports.
- `extraPaths` — `VAR=subdir`; `home/subdir` is prepended to `VAR`.
- `requires` — companion tools; a warning is printed if one is not also in the
  shell's `tools` set.
- `capabilities` — allowlisted runtime workarounds (see below).
- `versions.<v>.home` — absolute install directory.

Per-vendor `license.envVars` are exported once, and only if at least one of that
vendor's tools resolved.

### Capabilities

The config only *names* a workaround; the builder supplies the implementation,
so no executable code is ever taken from the config file.

- `ldPreload: "gmp"` — wraps the tool's executables to `LD_PRELOAD` the FHS
  `libgmp` (some tools' loaders need it), scoped to those binaries only.
- `ldRelink: ["<glob>", ...]` — globs (relative to the tool `home`) of bundled
  linkers that are too old for modern relative relocations (some vendor
  toolchains ship such a linker). Each match is bind-replaced, inside the FHS
  mount namespace, with a shim that unsets `LD_LIBRARY_PATH` and execs the system
  `/usr/bin/ld`.

## Deploying the config

Generate the JSON from your own tool inventory and place it on your machines,
then set the env var through your usual site mechanism (a NixOS module, an
`/etc/profile.d` snippet, or a modulefile). The public shell only ever *reads*
the variable; it never defines it. See `lib/eda-config.example.json` for a
minimal starting point.

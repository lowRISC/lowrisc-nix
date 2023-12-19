# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{
  inputs,
  pkgs,
  python3,
  ...
}: let
  poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};

  # https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md
  # poetry2nix tries to build the python packages based on the information
  # given in their own build description files (setup.py etc.)
  # Sometimes, the inputs are incomplete. Add missing inputs here.
  pypkgs-missing-build-requirements = {
    # package: build-requirements #
    attrs = ["hatchling" "hatch-fancy-pypi-readme" "hatch-vcs"];
    beautifulsoup4 = ["hatchling"];
    pyfinite = ["setuptools"];
    zipfile2 = ["setuptools"];
    okonomiyaki = ["setuptools"];
    simplesat = ["setuptools"];
    urllib3 = ["hatchling"];
    fusesoc = ["setuptools" "setuptools-scm"];
    chipwhisperer = ["setuptools"];
  };
  buildreqs-overlay = (
    final: prev:
      builtins.mapAttrs (
        package: build-requirements:
          (builtins.getAttr package prev).overridePythonAttrs (old: {
            buildInputs =
              (old.buildInputs or [])
              ++ (
                builtins.map
                (pkg: builtins.getAttr pkg final)
                build-requirements
              );
          })
      )
      pypkgs-missing-build-requirements
  );

  # The following modules are very slow to build or are otherwise broken.
  # For now, preferWheel to pull the binary dist.
  preferwheel-overlay = final: prev: {
    mypy = prev.mypy.override {
      # Very slow build.
      preferWheel = true;
    };
    libcst = prev.libcst.override {
      # Missing rustc/cargo etc.
      # buildInputs = (old.buildInputs or []) ++ [ final.setuptools-rust ];
      preferWheel = true;
    };
    isort = prev.isort.override {
      # Some problem building due to a malformed semantic version string.
      preferWheel = true;
    };
  };
in
  poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    python = import ./python.nix {python = python3;};
    overrides = [
      preferwheel-overlay
      buildreqs-overlay
      poetry2nix.defaultPoetryOverrides
    ];
  }

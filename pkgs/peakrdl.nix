# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{
  pkgs,
  lib,
  python3Packages,
  fetchFromGitHub,
}: let
  systemrdl-compiler = python3Packages.buildPythonPackage {
    name = "systemrdl-compiler";
    version = "1.27.3";
    src = fetchFromGitHub {
      owner = "SystemRDL";
      repo = "systemrdl-compiler";
      rev = "191f4dd9bc093920720ddd47e8a15be97e6c5a25";
      hash = "sha256-HEDN2VeYEA5ZJFCzk4ifhr8VVd8G+NVa/y/kK4ux2BY=";
    };
    propagatedBuildInputs = with python3Packages; [
      antlr4-python3-runtime
      colorama
    ];
    enableParallelBuilding = true;
    doCheck = false;
    meta = {
      description = "SystemRDL 2.0 language compiler front-end ";
      homepage = "https://systemrdl-compiler.readthedocs.io";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };

  peakRdlPackage = {
    name,
    version,
    rev,
    hash,
    description,
    additionalInputs ? [],
    mainProgram ? null,
  }:
    python3Packages.buildPythonPackage {
      inherit name version;
      src = fetchFromGitHub {
        owner = "SystemRDL";
        repo = name;
        inherit rev hash;
      };
      propagatedBuildInputs = with python3Packages;
        [
          setuptools
          setuptools-scm
          systemrdl-compiler
        ]
        ++ additionalInputs;
      format = "pyproject";
      meta = {
        inherit description mainProgram;
        homepage = "https://github.com/SystemRDL/${name}";
        license = lib.licenses.gpl3;
        platforms = lib.platforms.all;
      };
    };

  peakrdl-regblock = peakRdlPackage {
    name = "peakrdl-regblock";
    version = "0.22.0";
    rev = "ceb1f9b0c112798b32ded3c4a42f037c1130b1dc";
    hash = "sha256-WYMHLz8pVlEaoKIjlB23eKMU/kxEVvQy144rgvv1XN4=";
    description = "Control and status register code generator toolchain";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-html = peakRdlPackage {
    name = "peakrdl-html";
    version = "2.10.1";
    rev = "2204134e6442c526bf158bbf51bcc24085c22b5a";
    hash = "sha256-tFTvzug1dUhd6D1nr0wWpkEBYHW4erkW4zQJBRDm1SY=";
    description = "Generate address space documentation HTML from compiled SystemRDL input";
    additionalInputs = with python3Packages; [
      jinja2
      markdown
      git-me-the-url
      python-markdown-math
    ];
  };
  peakrdl-systemrdl = peakRdlPackage {
    name = "peakrdl-systemrdl";
    version = "0.3.0";
    rev = "92036db0faafb49c5809a5e8b22d697816d96c5f";
    hash = "sha256-pnq7Ak0QXjTC+/TswNd0g8orYj0dpgh81iXHqdVO2JE=";
    description = "Convert a compiled register model into SystemRDL code.";
  };
  peakrdl-uvm = peakRdlPackage {
    name = "peakrdl-uvm";
    version = "2.3.0";
    rev = "fbb1dde704f8259fc2072d939bad3b0e1ecfa9b2";
    hash = "sha256-NLPsJZDQ2d3oezOLB+pWU2x9m12gS5MKZ5rUSCrBqt4=";
    description = "Generate UVM register model from compiled SystemRDL input.";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-cheader = peakRdlPackage {
    name = "peakrdl-cheader";
    version = "1.0.0";
    rev = "db696fc95a657168de7ee8ecec8d92e0cb696adc";
    hash = "sha256-BaGlgnU0EJj40Z9+fwVStVpgfM0ja0EQDCoHLXPGM28=";
    description = "Generate C Headers from compiled SystemRDL input.";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-ipxact = peakRdlPackage {
    name = "peakrdl-ipxact";
    version = "3.4.4";
    rev = "cf961d8d172de1f1f7b9adca95ffda08a71b167b";
    hash = "sha256-UxdW8tudFKiD5FP4smKePt3IJxYCweVyOXj8LL978RE=";
    description = "Import and export IP-XACT XML register models ";
  };

  git-me-the-url = python3Packages.buildPythonPackage {
    name = "git-me-the-url";
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "amykyta3";
      repo = "git-me-the-url";
      rev = "ec468a26e1de9cbbe037132aefbbee4ca479474a";
      hash = "sha256-k9oTCrsgG8Nqe3AJJSUkEJaljzQldSSg36k5oWz5fXU=";
    };
    propagatedBuildInputs = with python3Packages; [
      setuptools
      setuptools-scm
      gitpython
    ];
    format = "pyproject";
    meta = {
      description = "Create shareable URLs to your Git files";
      homepage = "https://github.com/amykyta3/git-me-the-url";
      license = lib.licenses.gpl3;
    };
  };

  peakrdl = peakRdlPackage {
    name = "peakrdl";
    version = "1.1.0";
    rev = "8b22af7771d595eb8619790492e0482a80a0196e";
    hash = "sha256-8bft0RmKfFmQedPc2wEojss3iyGs3uSrEflriqlu+tY=";
    description = "Control and status register code generator toolchain.";
    additionalInputs = [
      peakrdl-html
      peakrdl-ipxact
      peakrdl-regblock
      peakrdl-systemrdl
      peakrdl-uvm
      peakrdl-cheader
    ];
    mainProgram = "peakrdl";
  };
in
  peakrdl

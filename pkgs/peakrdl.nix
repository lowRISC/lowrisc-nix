# Copyright lowRISC Contributors.
# SPDX-License-Identifier: MIT
{
  pkgs,
  lib,
  python3Packages,
  fetchFromGitHub,
}: let
  systemrdl-compiler = python3Packages.buildPythonPackage rec {
    pname = "systemrdl-compiler";
    version = "1.29.3";
    src = fetchFromGitHub {
      owner = "SystemRDL";
      repo = "systemrdl-compiler";
      rev = "v${version}";
      hash = "sha256-nsamrlnY6nPtACX6Dfb+1yHpxuNhD0N4aidY3wSiIwE=";
    };
    propagatedBuildInputs = with python3Packages; [
      setuptools
      setuptools-scm
      antlr4-python3-runtime
      colorama
      markdown
    ];
    enableParallelBuilding = true;
    doCheck = false;
    format = "pyproject";
    meta = {
      description = "SystemRDL 2.0 language compiler front-end ";
      homepage = "https://systemrdl-compiler.readthedocs.io";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };

  git-me-the-url = python3Packages.buildPythonPackage rec {
    pname = "git-me-the-url";
    version = "2.1.0";
    src = fetchFromGitHub {
      owner = "amykyta3";
      repo = "git-me-the-url";
      rev = "v${version}";
      hash = "sha256-pJszlCQdaiSWzXnmr5vyS+HL45OEnKGmyQ7UkA70gU0=";
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

  peakRdlPackage = {
    pname,
    version,
    rev ? "v${version}",
    hash,
    description,
    additionalInputs ? [],
    mainProgram ? null,
    ...
  } @ args:
    python3Packages.buildPythonPackage ({
        src = fetchFromGitHub {
          owner = "SystemRDL";
          repo = pname;
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
          homepage = "https://github.com/SystemRDL/${pname}";
          license = lib.licenses.gpl3;
          platforms = lib.platforms.all;
        };
      }
      // (removeAttrs args [
        "rev"
        "hash"
        "description"
        "mainProgram"
        "additionalInputs"
      ]));

  peakrdl-regblock = peakRdlPackage {
    pname = "peakrdl-regblock";
    version = "1.1.0";
    hash = "sha256-ccs7D/tlXvr3w2mkD4pDRsQMNcKxUZcv+QCUA9iHwbg=";
    description = "Control and status register code generator toolchain";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-html = peakRdlPackage {
    pname = "peakrdl-html";
    version = "2.11.0";
    hash = "sha256-WlAOnn7h0o53hooh65KFN+WGsS64F6NZ5ALueS0NU+4=";
    description = "Generate address space documentation HTML from compiled SystemRDL input";
    additionalInputs = with python3Packages; [
      jinja2
      markdown
      git-me-the-url
      python-markdown-math
    ];
  };
  peakrdl-systemrdl = peakRdlPackage {
    pname = "peakrdl-systemrdl";
    version = "1.0.0";
    hash = "sha256-8Z7MEELxzYsViQUhfoCa2dZte5SGNsDUFuS/b+AdijE=";
    description = "Convert a compiled register model into SystemRDL code.";
  };
  peakrdl-uvm = peakRdlPackage {
    pname = "peakrdl-uvm";
    version = "2.3.0";
    hash = "sha256-IDVAvfxoUVb3fn3KqJBKyas1bnQjCvqgFP4M+wXU/ws=";
    description = "Generate UVM register model from compiled SystemRDL input.";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-cheader = peakRdlPackage {
    pname = "peakrdl-cheader";
    version = "1.0.0";
    hash = "sha256-1LxKGCea5ClKmrArl+CM6ZRpiTh2ThbYSe9TYYHjRlY=";
    description = "Generate C Headers from compiled SystemRDL input.";
    additionalInputs = with python3Packages; [jinja2];
  };
  peakrdl-ipxact = peakRdlPackage {
    pname = "peakrdl-ipxact";
    version = "3.5.0";
    hash = "sha256-GFHgIyK82dt+/t0XbDdk61q0DXUOabxtjlhZhgacUVA=";
    description = "Import and export IP-XACT XML register models ";
  };
  peakrdl = peakRdlPackage {
    pname = "peakrdl";
    version = "1.4.0";
    hash = "sha256-md2YRyvGje1cEhrlSLe5OID3mDR1Tm+x/DwqMfi6QaE=";
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

    preBuild = "cd peakrdl-cli";
  };
in
  peakrdl

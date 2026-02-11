# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
{pkgs, ...}: let
  # uv.lock doesn't contain build dependencies, so we need to specify how each
  # package needs to be built.
  # https://pyproject-nix.github.io/uv2nix/patterns/overriding-build-systems.html
  #
  # This list here is long so that it supports building packages from source if possible.
  buildSystemOverrides = {
    antlr4-python3-runtime.setuptools = [];
    anytree.setuptools = [];
    annotated-types.hatchling = [];
    argcomplete.hatchling = [];
    attrs = {
      hatchling = [];
      hatch-fancy-pypi-readme = [];
    };
    beautifulsoup4.hatchling = [];
    blessed.setuptools = [];
    cachetools.setuptools = [];
    certifi.setuptools = [];
    charset-normalizer.setuptools = [];
    chipwhisperer.setuptools = [];
    click.flit-core = [];
    colorama.hatchling = [];
    commonmark.setuptools = [];
    crcmod.setuptools = [];
    cssselect.setuptools = [];
    cssutils.setuptools = [];
    cython.setuptools = [];
    dvplan.hatchling = [];
    dvsim.hatchling = [];
    edalize.setuptools = [];
    enlighten.setuptools = [];
    exceptiongroup = {
      flit-core = [];
      flit-scm = [];
    };
    fastjsonschema.setuptools = [];
    flake8.setuptools = [];
    fusesoc.setuptools = [];
    git-me-the-url.setuptools = [];
    gitdb.setuptools = [];
    gitpython.setuptools = [];
    hjson.setuptools = [];
    idna.flit-core = [];
    iniconfig = {
      hatchling = [];
      hatch-vcs = [];
    };
    isort.poetry-core = [];
    importlib-resources.setuptools = [];
    jinja2.flit-core = [];
    jsonschema = {
      hatchling = [];
      hatch-fancy-pypi-readme = [];
    };
    jsonschema2md = {
      poetry-core = [];
      babel = [];
    };
    libcst.setuptools = [];
    libcst.setuptools-rust = [];
    libusb1.setuptools = [];
    lizard.setuptools = [];
    logzero.setuptools = [];
    lxml.setuptools = [];
    mako.setuptools = [];
    markdown.setuptools = [];
    markupsafe.setuptools = [];
    mccabe.setuptools = [];
    mistletoe.setuptools = [];
    more-itertools.flit-core = [];
    msgpack-python.setuptools = [];
    mypy.setuptools = [];
    mypy-extensions.setuptools = [];
    ninja = {
      scikit-build = [];
      setuptools = [];
    };
    okonomiyaki.setuptools = [];
    packaging.flit-core = [];
    pathspec.flit-core = [];
    peakrdl-systemrdl.setuptools = [];
    peakrdl-uvm.setuptools = [];
    pluggy.setuptools = [];
    pluralizer.setuptools = [];
    prefixed.setuptools = [];
    premailer.setuptools = [];
    prompt-toolkit.setuptools = [];
    pycodestyle.setuptools = [];
    pycryptodome.setuptools = [];
    pydantic = {
      hatchling = [];
      hatch-fancy-pypi-readme = [];
    };
    pydantic-core.maturin = [];
    pydriller.setuptools = [];
    pyelftools.setuptools = [];
    pyfinite.setuptools = [];
    pyflakes.setuptools = [];
    pygments.hatchling = [];
    pyparsing.flit-core = [];
    pyrsistent.setuptools = [];
    pyserial.setuptools = [];
    pytest.setuptools = [];
    pytest-timeout.setuptools = [];
    pytz.setuptools = [];
    pyyaml.setuptools = [];
    questionary.poetry-core = [];
    requests.setuptools = [];
    reuse.poetry-core = [];
    rich.poetry-core = [];
    ruff.maturin = [];
    semantic-version.setuptools = [];
    simplesat.setuptools = [];
    siphash.setuptools = [];
    six.setuptools = [];
    smmap.setuptools = [];
    soupsieve.hatchling = [];
    systemrdl-compiler.setuptools = [];
    tabulate.setuptools = [];
    termcolor.setuptools = [];
    tockloader.setuptools = [];
    toml.setuptools = [];
    tomli.flit-core = [];
    tqdm.setuptools = [];
    typer.flit-core = [];
    types-pytz.setuptools = [];
    types-pyyaml.setuptools = [];
    types-tabulate.setuptools = [];
    typing-extensions.flit-core = [];
    typing-inspect.setuptools = [];
    typing-inspection.hatchling = [];
    urllib3 = {
      hatchling = [];
      hatch-vcs = [];
    };
    uv.maturin = [];
    wcwidth.setuptools = [];
    yapf.setuptools = [];
  };

  buildSystemOverlay = (
    final: prev:
      builtins.mapAttrs (
        name: spec:
          prev.${name}.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ (final.resolveBuildSystem spec);
          })
      )
      buildSystemOverrides
  );

  buildInputOverlay = final: prev: {
    pluralizer = prev.pluralizer.overrideAttrs {
      PYPI_VERSION = prev.pluralizer.version;
    };
    lxml = prev.lxml.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ (with pkgs; [libxslt libxml2 libz]);

      # GCC 14+ has this as the default.
      env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
    });
    ninja = prev.ninja.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [cmake]);
    });
    libcst = prev.libcst.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [rustc cargo]);
    });
    ruff = prev.ruff.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [rustc cargo]);
    });
    uv = prev.uv.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [rustc cargo]);
    });
    maturin = prev.maturin.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [rustc cargo]);
    });
    pydantic-core = prev.pydantic-core.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with pkgs; [rustc cargo]);
    });
  };

  preferWheelOverrides = {
    # Some problem building due to a malformed semantic version string.
    isort = {};
    # requirements.txt not distributed.
    pydriller = {};
    # These are trying to download dependencies during build.
    ninja = {};
    libcst = {};
    ruff = {};
    uv = {};
    pydantic-core = {};
  };

  preferWheelOverlay = (
    final: prev:
      builtins.mapAttrs (
        name: _:
          prev.${name}.override {
            sourcePreference = "wheel";
          }
      )
      preferWheelOverrides
  );
in
  pkgs.lib.composeManyExtensions [
    buildSystemOverlay
    buildInputOverlay
    preferWheelOverlay
  ]

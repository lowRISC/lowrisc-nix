# Copyright lowRISC Contributors.
# Licensed under both the MIT License and the Apache License, Version 2.
# See LICENSE-MIT and LICENSE-APACHE for details.
# SPDX-License-Identifier: MIT OR Apache-2.0
#
# Hack, see https://github.com/charlottia/hdx/pull/1
{...} @ inputs: let
  python =
    (inputs.python.override {
      includeSiteCustomize = false;
    })
    .overrideAttrs (final: prev: {
      postInstall =
        prev.postInstall
        + ''
          # Override sitecustomize.py with our NIX_PYTHONPATH-preserving variant.
          cp ${./sitecustomize.py} $out/${final.passthru.sitePackages}/sitecustomize.py
        '';
    });
in
  python.override {self = python;}

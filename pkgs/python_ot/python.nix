# Copyright lowRISC Contributors.
# Licensed under the MIT License, see LICENSE for details.
# SPDX-License-Identifier: MIT
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

# Copyright lowRISC contributors.
#
# SPDX-License-Identifier: MIT
{
  runCommand,
  bazelisk,
  bazel_7,
  ...
}:
# OpenTitan requires a specific version of Bazel.
# We *could* package our own Bazel, but it can't be a simple override since Bazel build process
# require a lot of Internet dependencies.
#
# For simplicity we'll just let bazelisk do the heavyloading.
#
# This package basically just creates an alias from bazel to bazelisk and adds the auto completion
# which is absent in bazelisk.
runCommand "bazel" {} ''
  cp -r ${bazelisk} $out
  chmod -R +w $out
  ln -s $out/bin/bazelisk $out/bin/bazel
  cp -r ${bazel_7}/share $out/share
''

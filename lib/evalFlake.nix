# Copyright (c) 2020-2021 Eelco Dolstra and the flake-compat contributors.
# Copyright lowRISC Contributors.
#
# SPDX-License-Identifier: MIT
#
# This is modified from edolstra's flake-compat to perform input override.
{
  src,
  inputOverride ? {},
}: let
  lockFilePath = src + "/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);

  rootSrc = let
    # Try to clean the source tree by using fetchGit, if this source
    # tree is a valid git repository.
    tryFetchGit = src:
      if isGit && !isShallow
      then let
        res = builtins.fetchGit src;
      in
        if res.rev == "0000000000000000000000000000000000000000"
        then removeAttrs res ["rev" "shortRev"]
        else res
      else {
        outPath =
          # Massage `src` into a store path.
          if builtins.isPath src
          then
            if dirOf (toString src) == builtins.storeDir
            then
              # If it's already a store path, don't copy it again.
              builtins.storePath src
            else "${src}"
          else src;
      };
    # NB git worktrees have a file for .git, so we don't check the type of .git
    isGit = builtins.pathExists (src + "/.git");
    isShallow = builtins.pathExists (src + "/.git/shallow");
  in
    {
      lastModified = 0;
      lastModifiedDate = formatSecondsSinceEpoch 0;
    }
    // (
      if src ? outPath
      then src
      else tryFetchGit src
    );

  # Format number of seconds in the Unix epoch as %Y%m%d%H%M%S.
  formatSecondsSinceEpoch = t: let
    rem = x: y: x - x / y * y;
    days = t / 86400;
    secondsInDay = rem t 86400;
    hours = secondsInDay / 3600;
    minutes = (rem secondsInDay 3600) / 60;
    seconds = rem t 60;

    # Courtesy of https://stackoverflow.com/a/32158604.
    z = days + 719468;
    era =
      (
        if z >= 0
        then z
        else z - 146096
      )
      / 146097;
    doe = z - era * 146097;
    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    y = yoe + era * 400;
    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    mp = (5 * doy + 2) / 153;
    d = doy - (153 * mp + 2) / 5 + 1;
    m =
      mp
      + (
        if mp < 10
        then 3
        else -9
      );
    y' =
      y
      + (
        if m <= 2
        then 1
        else 0
      );

    pad = s:
      if builtins.stringLength s < 2
      then "0" + s
      else s;
  in "${toString y'}${pad (toString m)}${pad (toString d)}${pad (toString hours)}${pad (toString minutes)}${pad (toString seconds)}";

  allNodes =
    builtins.mapAttrs
    (
      key: node: let
        sourceInfo =
          if key == lockFile.root
          then rootSrc
          else fetchTree (node.info or {} // removeAttrs node.locked ["dir"]);

        subdir =
          if key == lockFile.root
          then ""
          else node.locked.dir or "";

        outPath =
          sourceInfo
          + ((
              if subdir == ""
              then ""
              else "/"
            )
            + subdir);

        flake = import (outPath + "/flake.nix");

        inputs =
          builtins.mapAttrs
          (inputName: inputSpec:
            if inputOverride ? ${inputName}
            then inputOverride.${inputName}
            else allNodes.${resolveInput inputSpec})
          (node.inputs or {});

        # Resolve a input spec into a node name. An input spec is
        # either a node name, or a 'follows' path from the root
        # node.
        resolveInput = inputSpec:
          if builtins.isList inputSpec
          then getInputByPath lockFile.root inputSpec
          else inputSpec;

        # Follow an input path (e.g. ["dwarffs" "nixpkgs"]) from the
        # root node, returning the final node.
        getInputByPath = nodeName: path:
          if path == []
          then nodeName
          else
            getInputByPath
            # Since this could be a 'follows' input, call resolveInput.
            (resolveInput lockFile.nodes.${nodeName}.inputs.${builtins.head path})
            (builtins.tail path);

        outputs = flake.outputs (inputs // {self = result;});

        result =
          outputs
          # We add the sourceInfo attribute for its metadata, as they are
          # relevant metadata for the flake. However, the outPath of the
          # sourceInfo does not necessarily match the outPath of the flake,
          # as the flake may be in a subdirectory of a source.
          # This is shadowed in the next //
          // sourceInfo
          // {
            # This shadows the sourceInfo.outPath
            inherit outPath;

            inherit inputs;
            inherit outputs;
            inherit sourceInfo;
            _type = "flake";
          };
      in
        if node.flake or true
        then assert builtins.isFunction flake.outputs; result
        else sourceInfo
    )
    lockFile.nodes;
in
  allNodes.${lockFile.root}

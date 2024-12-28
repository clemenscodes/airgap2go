{pkgs, ...}: flake: let
  flakesClosure = flakes:
    if flakes == []
    then []
    else
      pkgs.lib.unique (flakes
        ++ flakesClosure (pkgs.lib.concatMap (flake:
          if flake ? inputs
          then builtins.attrValues flake.inputs
          else [])
        flakes));
in
  pkgs.writeText "flake-closure" (pkgs.lib.concatStringsSep "\n" (flakesClosure [flake]) + "\n")

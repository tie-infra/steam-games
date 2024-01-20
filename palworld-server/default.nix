{ lib, package-sets-lib, ... }:
let
  inherit (package-sets-lib)
    concatFilteredPackages
    availableOnHostPlatform;
in
{
  flake.overlays.palworld-server = final: prev: {
    palworld-server = final.callPackage ./pkgs/palworld-server { };
  };

  perSystem = { config, ... }: {
    checks = concatFilteredPackages availableOnHostPlatform
      ({ name, pkgs, ... }: {
        "palworld-server-${name}" = pkgs.palworld-server;
      })
      config.packageSets;
  };
}

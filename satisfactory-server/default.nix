{ lib, package-sets-lib, ... }:
let
  inherit (package-sets-lib)
    concatFilteredPackages
    availableOnHostPlatform;
in
{
  flake.overlays.satisfactory-server = final: prev: {
    satisfactory-server = final.callPackage ./pkgs/satisfactory-server { };
  };

  perSystem = { config, ... }: {
    checks = concatFilteredPackages availableOnHostPlatform
      ({ name, pkgs, ... }: {
        "satisfactory-server-${name}" = pkgs.satisfactory-server;
      })
      config.packageSets;
  };
}

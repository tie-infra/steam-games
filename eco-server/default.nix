{ lib, package-sets-lib, ... }:
let
  inherit (package-sets-lib)
    concatFilteredPackages
    availableOnHostPlatform;
in
{
  flake.overlays.eco-server = final: prev: {
    eco-server = final.callPackage ./pkgs/eco-server { };
  };

  perSystem = { config, ... }: {
    checks = concatFilteredPackages availableOnHostPlatform
      ({ name, pkgs, ... }: {
        "eco-server-${name}" = pkgs.eco-server;
      })
      config.packageSets;
  };
}

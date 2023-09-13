{ lib, package-sets-lib, ... }:
let
  inherit (package-sets-lib)
    concatFilteredPackages
    availableOnHostPlatform;
in
{
  flake.overlays.steamworks-sdk-redist = final: prev: {
    steamworks-sdk-redist = final.callPackage ./pkgs/steamworks-sdk-redist { };
  };

  perSystem = { config, ... }: {
    checks = concatFilteredPackages availableOnHostPlatform
      ({ name, pkgs, ... }: {
        "steamworks-sdk-redist-${name}" = pkgs.steamworks-sdk-redist;
      })
      config.packageSets;
  };
}

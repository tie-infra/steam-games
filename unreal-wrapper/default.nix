{ lib, package-sets-lib, ... }:
let
  inherit (package-sets-lib)
    concatFilteredPackages
    availableOnHostPlatform;
in
{
  flake.overlays.unreal-wrapper = final: prev: {
    unreal-wrapper = final.callPackage ./pkgs/unreal-wrapper { };
  };

  perSystem = { config, ... }: {
    checks = concatFilteredPackages availableOnHostPlatform
      ({ name, pkgs, ... }: {
        "unreal-wrapper-${name}" = pkgs.unreal-wrapper;
      })
      config.packageSets;
  };
}

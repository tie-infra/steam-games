{
  flake.overlays.steamworks-sdk-redist = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.steamworks-sdk-redist-x86-64 = pkgsCross.x86-64.gameServerPackages.steamworks-sdk-redist;
      packages.steamworks-sdk-redist-x86-32 = pkgsCross.x86-32.gameServerPackages.steamworks-sdk-redist;
    };
}

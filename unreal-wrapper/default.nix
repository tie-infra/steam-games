{
  flake.overlays.unreal-wrapper = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.unreal-wrapper-x86-64 = pkgsCross.x86-64.gameServerPackages.unreal-wrapper;
      packages.unreal-wrapper-x86-32 = pkgsCross.x86-32.gameServerPackages.unreal-wrapper;
    };
}

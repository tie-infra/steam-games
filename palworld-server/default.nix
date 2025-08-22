{
  flake.overlays.palworld-server = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.palworld-server = pkgsCross.x86-64.palworld-server;
    };
}

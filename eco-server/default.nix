{
  flake.overlays.eco-server = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.eco-server = pkgsCross.x86-64.eco-server;
    };
}

{
  flake.overlays.satisfactory-server = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.satisfactory-server = pkgsCross.x86-64.satisfactory-server;
    };
}

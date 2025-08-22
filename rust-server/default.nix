{
  flake.overlays.rust-server = import ./overlay.nix;
  perSystem =
    { pkgsCross, ... }:
    {
      packages.rust-server = pkgsCross.x86-64.rust-server;
      checks.rust-server-oxide = pkgsCross.x86-64.rust-server.oxide;
    };
}

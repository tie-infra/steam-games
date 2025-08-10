{
  flake.overlays.rust-server = final: _: { rust-server = final.callPackage ./pkgs/rust-server { }; };

  perSystem =
    { pkgsCross, ... }:
    {
      packages.rust-server = pkgsCross.x86-64.rust-server;
    };
}

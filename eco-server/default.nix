{
  flake.overlays.eco-server = final: _: { eco-server = final.callPackage ./pkgs/eco-server { }; };

  perSystem =
    { pkgsCross, ... }:
    {
      packages.eco-server = pkgsCross.x86-64.eco-server;
    };
}

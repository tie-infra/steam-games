{
  flake.overlays.palworld-server = final: _: {
    palworld-server = final.callPackage ./pkgs/palworld-server { };
  };

  perSystem =
    { pkgsCross, ... }:
    {
      packages.palworld-server = pkgsCross.x86-64.palworld-server;
    };
}

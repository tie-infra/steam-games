{
  flake.overlays.satisfactory-server = final: _: {
    satisfactory-server = final.callPackage ./pkgs/satisfactory-server { };
  };

  perSystem = { pkgsCross, ... }: {
    packages.satisfactory-server = pkgsCross.x86-64.satisfactory-server;
  };
}

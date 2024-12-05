{
  flake.overlays.steamworks-sdk-redist = final: _: {
    steamworks-sdk-redist = final.callPackage ./pkgs/steamworks-sdk-redist { };
  };

  perSystem =
    { pkgsCross, ... }:
    {
      packages = {
        steamworks-sdk-redist-x86-64 = pkgsCross.x86-64.steamworks-sdk-redist;
        steamworks-sdk-redist-x86 = pkgsCross.x86.steamworks-sdk-redist;
      };
    };
}

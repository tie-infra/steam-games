{
  flake.overlays.unreal-wrapper = final: _: {
    unreal-wrapper = final.callPackage ./pkgs/unreal-wrapper { };
  };

  perSystem =
    { pkgsCross, ... }:
    {
      packages = {
        unreal-wrapper-x86-64 = pkgsCross.x86-64.unreal-wrapper;
        unreal-wrapper-x86 = pkgsCross.x86.unreal-wrapper;
      };
    };
}

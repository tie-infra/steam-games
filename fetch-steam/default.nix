{
  flake.overlays.fetch-steam = final: _: { fetchSteam = final.callPackage ./pkgs/fetch-steam { }; };
}

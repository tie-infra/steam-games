{
  flake.overlays.fetch-steam = final: prev: {
    fetchSteam = final.callPackage ./pkgs/fetch-steam { };
  };
}

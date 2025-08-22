final: _: {
  eco-server = final.callPackage ./pkgs/eco-server/package.nix { };
  eco-wrapper = final.callPackage ./pkgs/eco-wrapper/package.nix { };
}

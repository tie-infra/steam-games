final: _: {
  rust-server = final.callPackage ./pkgs/rust-server/package.nix { };
  rust-wrapper = final.callPackage ./pkgs/rust-wrapper/package.nix { };
  oxide-compiler = final.callPackage ./pkgs/oxide-compiler/package.nix { };
}

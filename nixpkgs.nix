{ self, inputs, ... }: {
  perSystem = { system, ... }:
    let
      nixpkgsArgs = {
        localSystem = { inherit system; };
        overlays = [ self.overlays.default ];
        config.allowUnfreePredicate = self.lib.unfreePredicate;
      };

      nixpkgsFun = newArgs: import inputs.nixpkgs (nixpkgsArgs // newArgs);
    in
    {
      _module.args = {
        pkgs = nixpkgsFun { };
        pkgsCross = {
          x86-64 = nixpkgsFun {
            crossSystem.config = "x86_64-unknown-linux-gnu";
          };
          x86 = nixpkgsFun {
            crossSystem.config = "i686-unknown-linux-gnu";
          };
        };
      };
    };
}

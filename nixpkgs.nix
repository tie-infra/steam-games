{ self, inputs, lib, ... }: {
  perSystem = { system, config, ... }:
    let
      nixpkgsArgs = {
        localSystem = { inherit system; };
        overlays = [ self.overlays.default ];
        config.allowUnfreePredicate = self.lib.unfreePredicate;
      };
      nixpkgsFun = newArgs: import inputs.nixpkgs (nixpkgsArgs // newArgs);

      pkgs = nixpkgsFun { };
    in
    {
      _module.args.pkgs = pkgs;

      packageSets = {
        default = { inherit pkgs; };
        unstable.pkgs = import inputs.nixpkgs-unstable nixpkgsArgs;
      } // lib.optionalAttrs (system != "x86_64-linux") {
        gnu64.pkgs = nixpkgsFun {
          crossSystem.config = "x86_64-unknown-linux-gnu";
        };
      } // lib.optionalAttrs (system != "i686-linux") {
        gnu32.pkgs = nixpkgsFun {
          crossSystem.config = "i686-unknown-linux-gnu";
        };
      };
    };
}

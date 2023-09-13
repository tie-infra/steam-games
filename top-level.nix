{ self, lib, ... }: {
  imports = [
    ./fetch-steam
    ./steamworks-sdk-redist
    ./satisfactory-server
    ./eco-server
  ];

  flake = {
    overlays.default = lib.composeManyExtensions (with self.overlays; [
      fetch-steam
      steamworks-sdk-redist
      satisfactory-server
      eco-server
    ]);

    # A function that returns `true` for unfree packages defined in this flake.
    # Intended to be used in `config.allowUnfreePredicate` when evaluating
    # Nixpkgs.
    lib.unfreePredicate =
      pkg: builtins.elem (lib.getName pkg) [
        "steamworks-sdk-redist"
        "satisfactory-server"
        "eco-server"
      ];
  };

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixpkgs-fmt;
    legacyPackages = pkgs;
  };
}

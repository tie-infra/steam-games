{
  description = "Steam games and game servers";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    systems.url = "systems";

    flake-parts.url = "flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    package-sets.url = "github:tie-infra/package-sets";

    # TODO: there are some minor incompatibilities between our current
    # implementation and steam-fetcher.
    #steam-fetcher.url = "github:nix-community/steam-fetcher";
    #steam-fetcher.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [
      inputs.package-sets.flakeModule
      ./nixpkgs.nix
      ./top-level.nix
    ];
  };
}

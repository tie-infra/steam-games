{
  description = "Steam games and game servers";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    flake-parts.url = "flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: there are some minor incompatibilities between our current
    # implementation and steam-fetcher.
    #steam-fetcher.url = "github:nix-community/steam-fetcher";
    #steam-fetcher.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    imports = [
      inputs.treefmt-nix.flakeModule
      ./nixpkgs.nix
      ./top-level.nix
    ];

    perSystem.treefmt = {
      projectRootFile = "flake.nix";
      programs.deadnix.enable = true;
      programs.nixpkgs-fmt.enable = true;
    };
  };
}

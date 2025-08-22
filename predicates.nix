{
  lib,
}:
let
  inherit (builtins) elem;
  inherit (lib) getName getVersion;
  inherit (lib.versions) major;
in
{
  # A convenience function that returns `true` for unfree packages defined in
  # this flake. Intended to be used in `config.allowUnfreePredicate` when
  # evaluating Nixpkgs.
  unfreePredicate =
    pkg:
    elem (getName pkg) [
      "eco-server"
      "palworld-server"
      "rust-server"
      "satisfactory-server"
      "steamworks-sdk-redist"
    ];

  # A convenience function that returns `true` for insecure packages used in
  # this flake. Intended to be used in `config.allowInsecurePredicate` when
  # evaluating Nixpkgs.
  insecurePredicate =
    pkg:
    elem (getName pkg) [
      "dotnet-runtime"
      "dotnet-sdk"
    ]
    && major (getVersion pkg) == "7";
}

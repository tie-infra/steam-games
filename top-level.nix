{ self, lib, ... }:
{
  imports = [
    ./eco-server
    ./fetch-steam
    ./palworld-server
    ./rust-server
    ./satisfactory-server
    ./steamworks-sdk-redist
    ./unreal-wrapper
  ];

  flake.lib = import ./predicates.nix {
    inherit lib;
  };

  flake.overlays.default =
    let
      scope =
        {
          generateSplicesForMkScope,
          makeScopeWithSplicing',
          attributePathToSplice,
        }:
        makeScopeWithSplicing' {
          otherSplices = generateSplicesForMkScope attributePathToSplice;
          f = self: extension self { };
        };
      extension = lib.composeManyExtensions (
        lib.attrValues (lib.removeAttrs self.overlays [ "default" ])
      );
    in
    final: _: {
      gameServerPackages = lib.recurseIntoAttrs (
        final.callPackage scope {
          attributePathToSplice = [ "gameServerPackages" ];
        }
      );
      inherit (final.gameServerPackages)
        eco-server
        palworld-server
        rust-server
        satisfactory-server
        ;
    };

  perSystem =
    { self', ... }:
    {
      checks = self'.packages;
    };
}

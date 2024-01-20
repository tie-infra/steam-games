{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "unreal-wrapper";
  src = ./.;

  cargoHash = "sha256-MP//SMGaKYfC8h0UGQmebPD8HbfrnUhDMKgtjWsAbak=";

  meta = {
    description = "A wrapper that sets up environment for Unreal Engine dedicated servers";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "unreal-wrapper";
  };
}

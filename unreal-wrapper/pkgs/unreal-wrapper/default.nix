{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "unreal-wrapper";
  src = ./.;

  cargoHash = "sha256-Xn0NGLjADU9Sr8NecvvtAHsJ0StzhxOspjeb22f6xig=";

  meta = {
    description = "A wrapper that sets up environment for Unreal Engine dedicated servers";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "unreal-wrapper";
  };
}

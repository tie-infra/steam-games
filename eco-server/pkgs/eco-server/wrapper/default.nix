{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "eco-server-wrapper";
  src = ./.;

  cargoHash = "sha256-2Zo7kYvErmgqt3YvhelfbxDIuI0BGFRO8DGb+iTtHn0=";

  meta = {
    description = "Set up environment for Eco Server";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "wrapper";
  };
}

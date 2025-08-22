{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "eco-wrapper";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  meta = {
    description = "Wrapper that sets up environment for Eco Server";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "eco-wrapper";
  };
}

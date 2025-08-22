{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "unreal-wrapper";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  meta = {
    description = "Wrapper that sets up environment for Unreal Engine dedicated servers";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "unreal-wrapper";
  };
}

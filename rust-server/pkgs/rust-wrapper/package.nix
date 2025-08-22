{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "rust-wrapper";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
  meta = {
    description = "Wrapper that sets up environment for Rust dedicated servers";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "rust-wrapper";
  };
}

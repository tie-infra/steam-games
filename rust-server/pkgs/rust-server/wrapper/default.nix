{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  name = "rust-server-wrapper";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "A wrapper that sets up environment for Rust dedicated servers";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.tie ];
    platforms = lib.platforms.linux;
    mainProgram = "wrapper";
  };
}

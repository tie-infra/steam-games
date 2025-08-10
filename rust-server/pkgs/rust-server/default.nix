{
  lib,
  stdenv,
  fetchSteam,
  makeBinaryWrapper,
  autoPatchelfHook,
  gcc-unwrapped,
  zlib,
  xorg,
  alsa-lib,
  libpulseaudio,
  unreal-wrapper,
}:
let
  projectRoot = "${placeholder "out"}/share/rust-server";
in
stdenv.mkDerivation {
  pname = "rust-server";
  version = "unstable-2025-08-10";

  # See https://steamdb.info/app/258550 for a list of manifest IDs.
  srcs = [
    (fetchSteam {
      appId = "258550";
      depotId = "258552";
      manifestId = "8605191920159531309";
      hash = "sha256-MPbIHrkOwiMg0yE9VLCriRllyQH/o+T8R3IkayHhAao=";
    })
    # See https://steamdb.info/depot/258554 for a list of manifest IDs.
    (fetchSteam {
      appId = "258550";
      depotId = "258554";
      manifestId = "8018265440864919917";
      hash = "sha256-Sg/z0Koyzr0nfdGPwZxZGhMewYcQTs+0V9PygjdJUW4=";
    })
  ];

  inherit projectRoot;
  __structuredAttrs = true;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [
    (lib.getLib gcc-unwrapped)
    zlib
    alsa-lib
    xorg.libX11
    libpulseaudio
  ];

  appendRunpaths = [
    "${projectRoot}/RustDedicated_Data/Plugins"
    "${projectRoot}/RustDedicated_Data/Plugins/x86_64"
  ];

  wrapper = lib.getExe unreal-wrapper;

  installPhase = ''
    runHook preInstall

    mkdir -p -- "$projectRoot"
    for d in "''${srcs[@]}"; do
      cp -r -T -- "$d" "$projectRoot"
    done
    chmod -R +w -- "$projectRoot"

    rm -- "$projectRoot/runds.sh"
    chmod +x -- "$projectRoot/RustDedicated"

    # Mountpoints for wrapper.
    mkdir -- "$projectRoot"/{HarmonyMods,server}

    makeWrapper "$wrapper" "$out/bin/rust-server" \
      --inherit-argv0 \
      --add-flags -c \
      --add-flags -p \
      --add-flags "$projectRoot" \
      --add-flags -e \
      --add-flags "$projectRoot/RustDedicated" \
      --add-flags -s \
      --add-flags HarmonyMods \
      --add-flags -s \
      --add-flags server

    runHook postInstall
  '';

  meta = {
    description = "Rust Dedicated Server";
    homepage = "https://rust.facepunch.com";
    maintainers = [ lib.maintainers.tie ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    badPlatforms = [ { hasSharedLibraries = false; } ];
  };
}

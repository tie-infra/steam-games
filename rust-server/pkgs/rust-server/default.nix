{
  lib,
  stdenv,
  callPackage,
  fetchSteam,
  makeBinaryWrapper,
  autoPatchelfHook,
  gcc-unwrapped,
  zlib,
  xorg,
  alsa-lib,
  libpulseaudio,
}:
let
  serverDir = "${placeholder "out"}/share/rust-server";
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

  inherit serverDir;
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
    "${serverDir}/RustDedicated_Data/Plugins"
    "${serverDir}/RustDedicated_Data/Plugins/x86_64"
  ];

  wrapper = callPackage ./wrapper { };

  installPhase = ''
    runHook preInstall

    mkdir -p -- "$serverDir"
    for d in "''${srcs[@]}"; do
      cp -r -T -- "$d" "$serverDir"
    done
    chmod -R +w -- "$serverDir"

    rm -- "$serverDir/runds.sh"
    chmod +x -- "$serverDir/RustDedicated"

    # Mountpoints for wrapper.
    mkdir -- "$serverDir"/{HarmonyMods,server}

    makeWrapper "$wrapper/bin/wrapper" "$out/bin/rust-server" \
      --inherit-argv0 \
      --add-flags -s \
      --add-flags "$serverDir" \
      --add-flags --

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

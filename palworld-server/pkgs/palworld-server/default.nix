{
  lib,
  stdenv,
  fetchSteam,
  makeBinaryWrapper,
  autoPatchelfHook,
  gcc-unwrapped,
  steamworks-sdk-redist,
  xdg-user-dirs,
  unreal-wrapper,
}:
let
  projectRoot = "${placeholder "out"}/share/palworld-server";
  serverFile = "${projectRoot}/Pal/Binaries/Linux/PalServer-Linux-Shipping";

  appId = "2394010";
in
stdenv.mkDerivation {
  pname = "palworld-server";
  # See https://store.steampowered.com/news/app/1623730?updates=true
  version = "0.6.0";

  # See https://steamdb.info/app/2394010 for a list of manifest IDs.
  src = fetchSteam {
    inherit appId;
    depotId = "2394012";
    manifestId = "3764729529995383980";
    hash = "sha256-neklGv3GOy8wWjArKskISXALeX3uzTVt+BWC4Tr/ri4=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];
  buildInputs = [ (lib.getLib gcc-unwrapped) ];
  appendRunpaths = [ "${steamworks-sdk-redist}/lib" ];

  installPhase = ''
    runHook preInstall

    rm PalServer.sh

    mkdir -p ${projectRoot}
    cp -r . ${projectRoot}

    chmod +x ${serverFile}

    # Mountpoints for wrapper.
    mkdir ${projectRoot}/{Engine,Pal}/Saved

    makeWrapper ${lib.getExe unreal-wrapper} $out/bin/palworld-server \
      --suffix PATH : ${lib.makeBinPath [ xdg-user-dirs ]} \
      --inherit-argv0 \
      --add-flags -p \
      --add-flags ${projectRoot} \
      --add-flags -e \
      --add-flags ${serverFile} \
      --add-flags -s \
      --add-flags Engine/Saved \
      --add-flags -s \
      --add-flags Pal/Saved \
      --add-flags Pal

    runHook postInstall
  '';

  meta = {
    description = "Palworld Dedicated Server";
    homepage = "https://pocketpair.jp/palworld";
    maintainers = [ lib.maintainers.tie ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    badPlatforms = [ { hasSharedLibraries = false; } ];
  };
}

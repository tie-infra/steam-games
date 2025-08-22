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
  projectRoot = "${placeholder "out"}/share/satisfactory-server";
  serverFile = "Engine/Binaries/Linux/FactoryServer-Linux-Shipping";

  appId = "1690800";
in
stdenv.mkDerivation {
  pname = "satisfactory-server";
  # See https://store.steampowered.com/news/app/526870?updates=true
  version = "1.1.1.2";

  # See https://steamdb.info/app/1690800 for a list of manifest IDs.
  src = fetchSteam {
    inherit appId;
    depotId = "1690802";
    manifestId = "5693629351763493998";
    hash = "sha256-0svLwO4JYKIPwoNCRfT9+pocZ0n1QpSEqP41DdUhEac=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];
  buildInputs = [
    (lib.getLib gcc-unwrapped)
  ];
  appendRunpaths = [
    "${steamworks-sdk-redist}/lib"
  ];

  inherit projectRoot;

  wrapper = unreal-wrapper;

  binPath = lib.makeBinPath [ xdg-user-dirs ];

  installPhase = ''
    runHook preInstall

    rm FactoryServer.sh

    mkdir -p -- "$projectRoot"
    cp -r -T -- . "$projectRoot"

    chmod +x -- "$projectRoot"/${serverFile}

    # Mountpoints for wrapper.
    mkdir -- "$projectRoot"/{Engine,FactoryGame}/Saved \
      "$projectRoot"/FactoryGame/{Intermediate,Certificates}

    makeWrapper "$wrapper/bin/unreal-wrapper" "$out/bin/satisfactory-server" \
      --suffix PATH : "$binPath" \
      --set-default SteamAppId ${appId} \
      --inherit-argv0 \
      --add-flags -p \
      --add-flags "$projectRoot" \
      --add-flags -e \
      --add-flags "$projectRoot"/${serverFile} \
      --add-flags -s \
      --add-flags Engine/Saved \
      --add-flags -s \
      --add-flags FactoryGame/Saved \
      --add-flags -s \
      --add-flags FactoryGame/Intermediate \
      --add-flags -s \
      --add-flags FactoryGame/Certificates \
      --add-flags FactoryGame

    runHook postInstall
  '';

  meta = {
    description = "Satisfactory Dedicated Server";
    homepage = "https://satisfactorygame.com";
    maintainers = [ lib.maintainers.tie ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "satisfactory-server";
  };
}

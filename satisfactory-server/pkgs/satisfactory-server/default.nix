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
  serverFile = "${projectRoot}/Engine/Binaries/Linux/FactoryServer-Linux-Shipping";

  appId = "1690800";
in
stdenv.mkDerivation {
  pname = "satisfactory-server";
  # See https://store.steampowered.com/news/app/526870?updates=true
  version = "1.0.1.4";

  # See https://steamdb.info/app/1690800 for a list of manifest IDs.
  src = fetchSteam {
    inherit appId;
    depotId = "1690802";
    manifestId = "6204133154971956314";
    hash = "sha256-DeboG3ku37MhQZFj/Y0Hr+kU96Vj8l6DMzZj4Mn4src=";
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

    rm FactoryServer.sh

    mkdir -p ${projectRoot}
    cp -r . ${projectRoot}

    chmod +x ${serverFile}

    # Mountpoints for wrapper.
    mkdir ${projectRoot}/{Engine,FactoryGame}/Saved
    mkdir ${projectRoot}/FactoryGame/{Intermediate,Certificates}

    makeWrapper ${lib.getExe unreal-wrapper} $out/bin/satisfactory-server \
      --suffix PATH : ${lib.makeBinPath [ xdg-user-dirs ]} \
      --set-default SteamAppId ${appId} \
      --inherit-argv0 \
      --add-flags -p \
      --add-flags ${projectRoot} \
      --add-flags -e \
      --add-flags ${serverFile} \
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
    badPlatforms = [ { hasSharedLibraries = false; } ];
  };
}

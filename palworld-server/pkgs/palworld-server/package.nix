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
  serverFile = "Pal/Binaries/Linux/PalServer-Linux-Shipping";

  appId = "2394010";
in
stdenv.mkDerivation {
  pname = "palworld-server";
  # See https://store.steampowered.com/news/app/1623730?updates=true
  version = "0.6.5";

  # See https://steamdb.info/app/2394010 for a list of manifest IDs.
  src = fetchSteam {
    inherit appId;
    depotId = "2394012";
    manifestId = "5432643748200410263";
    hash = "sha256-mcdhPnvg1FVHdMaxq/iJvoTSw0jwiuXPuQOMFNfDcek=";
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

    rm PalServer.sh

    mkdir -p -- "$projectRoot"
    cp -r -T -- . "$projectRoot"

    chmod +x -- "$projectRoot"/${serverFile}

    # Mountpoints for wrapper.
    mkdir -- "$projectRoot"/{Engine,Pal}/Saved

    makeWrapper "$wrapper/bin/unreal-wrapper" "$out/bin/palworld-server" \
      --suffix PATH : "$binPath" \
      --inherit-argv0 \
      --add-flags -p \
      --add-flags "$projectRoot" \
      --add-flags -e \
      --add-flags "$projectRoot"/${serverFile} \
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
    mainProgram = "palworld-server";
  };
}

{ lib
, stdenv
, fetchSteam
, makeBinaryWrapper
, autoPatchelfHook
, gcc-unwrapped
, steamworks-sdk-redist
, xdg-user-dirs
, unreal-wrapper
}:
let
  projectRoot = "${placeholder "out"}/share/palworld-server";
  serverFile = "${projectRoot}/Pal/Binaries/Linux/PalServer-Linux-Test";

  appId = "2394010";
in
stdenv.mkDerivation {
  pname = "palworld-server";
  version = "0.1.4.0";

  # See https://steamdb.info/app/2394010 for a list of manifest IDs.
  src = fetchSteam {
    inherit appId;
    depotId = "2394012";
    manifestId = "4190579964382773830";
    hash = "sha256-f8cRdFesSInHrZicIOrwWW1j5bTng8Vq3eUs3MZ6dOE=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ autoPatchelfHook makeBinaryWrapper ];
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
    badPlatforms = [{ hasSharedLibraries = false; }];
  };
}

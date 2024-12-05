{
  lib,
  stdenv,
  fetchSteam,
}:
stdenv.mkDerivation {
  pname = "steamworks-sdk-redist";
  version = "unstable-2024-05-30";

  # Steamworks SDK Redist with steamclient.so.
  # https://steamdb.info/app/1007/depots
  src = fetchSteam {
    appId = "1007";
    depotId = "1006";
    manifestId = "7138471031118904166";
    hash = "sha256-OtPI1kAx6+9G09IEr2kYchyvxlPl3rzx/ai/xEVG4oM=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp ${lib.optionalString stdenv.hostPlatform.is64bit "linux64/"}steamclient.so $out/lib
    chmod +x $out/lib/steamclient.so

    runHook postInstall
  '';

  meta = {
    description = "Steamworks SDK Redist";
    maintainers = [ lib.maintainers.tie ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    badPlatforms = [ { hasSharedLibraries = false; } ];
  };
}

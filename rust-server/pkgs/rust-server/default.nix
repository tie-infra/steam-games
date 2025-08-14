{
  lib,
  stdenv,
  callPackage,
  fetchSteam,
  fetchzip,
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
stdenv.mkDerivation (
  finalAttrs:
  # TODO: also support carbon mod loader.
  # See https://github.com/CarbonCommunity/Carbon
  # Needs a tag per release (currently old releases are deleted, so we can’t
  # fetch them with Nix). Should be trivial to implement. Alternatively, build
  # both Oxide and Carbon from source.
  let
    isOxide = finalAttrs.modLoader == "oxide";
    modLoadersList = [
      "oxide"
    ];
    moddedPackage =
      modLoader:
      finalAttrs.finalPackage.overrideAttrs (oldAttrs: {
        inherit modLoader;
        passthru = builtins.removeAttrs oldAttrs.passthru modLoadersList;
      });
  in
  {
    pname = "rust-server";
    version = "unstable-2025-08-11";

    # See https://steamdb.info/app/258550/depots/?branch=public for a list of manifest IDs.
    srcs =
      [
        # rust dedicated - linux64
        (fetchSteam {
          appId = "258550";
          depotId = "258552";
          manifestId = "3627494758718149740";
          hash = "sha256-wGhz6X6b/tz0E1bqvS06lQ3hfwVzKtol1iyqLdzt9Os=";
        })
        # rust dedicated - common
        (fetchSteam {
          appId = "258550";
          depotId = "258554";
          manifestId = "3006784168988183666";
          hash = "sha256-RjmeabAkkG+Toluxrhq1u3sfNGx4AfsT2PTsF9N3sJE=";
        })
      ]
      ++ lib.optionals isOxide [
        (fetchzip {
          url = "https://github.com/OxideMod/Oxide.Rust/releases/download/2.0.6547/Oxide.Rust-linux.zip";
          hash = "sha256-XV4AfJnIqO7Makq1xvfPL029mJCD0qqcbZWr5ccRn6A=";
          stripRoot = false;
        })
      ];

    oxideCompiler = lib.optionalDrvAttr isOxide (callPackage ./oxide-compiler { });

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

    modLoader = null;

    wrapper = callPackage ./wrapper { };

    installPhase =
      ''
        runHook preInstall

        mkdir -p -- "$serverDir"
        for d in "''${srcs[@]}"; do
          cp -r -T -- "$d" "$serverDir"
          chmod -R +w -- "$serverDir"
        done
      ''
      + lib.optionalString isOxide ''
        ln -s -t "$serverDir" -- "$oxideCompiler/bin/Oxide.Compiler"
        extDir=$serverDir/RustDedicated_Data/Managed
        # https://github.com/OxideMod/Oxide.SQLite/blob/fbd3f8edc4e30153e39941e114e15ac297f2f6a2/src/SQLiteExtension.cs#L53
        printf "<configuration>
        <dllmap dll=\"sqlite3\" target=\"$extDir/x86/libsqlite3.so\" os=\"!windows,osx\" cpu=\"x86\" />
        <dllmap dll=\"sqlite3\" target=\"$extDir/x64/libsqlite3.so\" os=\"!windows,osx\" cpu=\"x86-64\" />
        </configuration>" >"$extDir/System.Data.SQLite.dll.config"
        # https://github.com/OxideMod/Oxide.CSharp/blob/21282428c94be50f49c38e931f597906f36869dc/src/CSharpExtension.cs#L58
        printf "<configuration>
        <dllmap dll=\"MonoPosixHelper\" target=\"$extDir/x86/libMonoPosixHelper.so\" os=\"!windows,osx\" wordsize=\"32\" />
        <dllmap dll=\"MonoPosixHelper\" target=\"$extDir/x64/libMonoPosixHelper.so\" os=\"!windows,osx\" wordsize=\"64\" />
        </configuration>" >"$extDir/Oxide.References.dll.config"
      ''
      + ''
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

    passthru = {
      oxide = moddedPackage "oxide";
    };

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
)

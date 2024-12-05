{ lib, runCommand, depotdownloader, cacert }:
lib.makeOverridable (
  { name ? "steamapp-${appId}-${depotId}-${manifestId}"
  , hash ? lib.fakeHash
  , appId
  , depotId
  , manifestId
  , branch ? null
  , fileList ? null
  , debug ? false
  , passthru ? { }
  , meta ? { }
  }@args:
  let
    fileListArg =
      if lib.isList fileList
      then builtins.toFile "steam-files-list.txt" (lib.concatLines fileList)
      else fileList;

    downloadArgs = [
      "-app"
      appId
      "-depot"
      depotId
      "-manifest"
      manifestId
    ] ++ lib.optionals (branch != null) [
      "-beta"
      branch
    ] ++ lib.optionals (fileList != null) [
      "-filelist"
      fileListArg
    ] ++ lib.optionals debug [
      "-debug"
    ];

    drvArgs = {
      depsBuildBuild = [ depotdownloader ];

      strictDeps = true;

      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = hash;

      env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

      pos = builtins.unsafeGetAttrPos "manifestId" args;

      inherit passthru;
    } // lib.optionalAttrs (args ? meta) {
      inherit meta;
    };
  in
  runCommand name drvArgs ''
    HOME=$PWD DepotDownloader -dir "$out" ${lib.escapeShellArgs downloadArgs}
    rm -r "$out"/.DepotDownloader
  ''
)

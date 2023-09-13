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
    # Set meta.position similar to fetchFromGitHub.
    position =
      if args.meta.description or null != null
      then builtins.unsafeGetAttrPos "description" args.meta
      else builtins.unsafeGetAttrPos "appId" args;
    newMeta = {
      position = "${position.file}:${toString position.line}";
    } // meta;

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
      fileList
    ] ++ lib.optionals (debug) [
      "-debug"
    ];
  in
  runCommand name
  {
    depsBuildBuild = [ depotdownloader ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = hash;

    inherit passthru;
    meta = newMeta;
  } ''
    export HOME=$PWD
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    DepotDownloader -dir $out ${lib.escapeShellArgs downloadArgs}
    rm -r $out/.DepotDownloader
  ''
)

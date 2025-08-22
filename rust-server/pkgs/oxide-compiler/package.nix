{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "oxide-compiler";
  version = "1.0.32";
  src = fetchFromGitHub {
    owner = "OxideMod";
    repo = "Oxide.Compiler";
    rev = "fb1c73883e5becc1d00ec40a81801984c2cc6328"; # master branch
    hash = "sha256-6lMKBFZ1Vktzn9qFImHWzslI7isP/BORtNOiqubk8/4=";
  };

  strictDeps = true;
  __structuredAttrs = true; # for Copyright property that contains spaces

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  projectFile = [
    "src/Oxide.Compiler.csproj"
  ];

  dotnetFlags = [
    "--property:Copyright=(c) 2013-2024 OxideMod"
    "--property:Version=${version}"
    "--property:SelfContained=false"
    "--property:PublishReadyToRun=false"
    "--property:PublishSingleFile=false"
  ];

  meta = {
    description = "Custom roslyn compiler for use with Oxide C# plugins";
    homepage = "https://github.com/OxideMod/Oxide.Compiler";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.tie ];
    mainProgram = "Oxide.Compiler";
  };
}

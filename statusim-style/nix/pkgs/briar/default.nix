{ stdenv
, pkgs
, deps
, lib
, callPackage
, version
, src
, sdk
, android
, patchMavenSources
, gradleFlags ? [ ]
}:
let
  inherit (builtins) concatStringsSep;
  name = "briar-${version}";
in
stdenv.mkDerivation {
  inherit name;
  inherit src;

  nativeBuildInputs = with pkgs; [
    bash
    gradle
    unzip
  ];

  ANDROID_SDK_ROOT = "${sdk.androidsdk}";

  phases = [
    "unpackPhase"
    "buildPhase"
    "installPhase"
  ];

  unpackPhase = ''
    cp -ar $src/. ./
    chmod u+w -R ./
    runHook postUnpack
  '';

  postUnpack = ''
    # Patch build.gradle to use local repo
    ${patchMavenSources} ./build.gradle
  '';

  buildPhase = ''
    # Fixes issue with failing to load libnative-platform.so
    export GRADLE_USER_HOME=$(mktemp -d)
    export ANDROID_SDK_HOME=$(mktemp -d)

    ${pkgs.gradle}/bin/gradle \
      --console=plain \
      --offline --stacktrace \
      -Dorg.gradle.daemon=false \
      -Dmaven.repo.local='${deps.gradle}' \
      ${concatStringsSep " " gradleFlags}
      || exit 1
  '';

  installPhase = ''
    mkdir -p $out
    cp ./build/outputs/apk/*/*/*.apk $out/;
  '';

}

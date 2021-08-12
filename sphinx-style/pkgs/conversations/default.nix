{ version, src, sdk, android, callPackage }:
let buildGradle = callPackage ./gradle-env.nix { };
in
buildGradle {
  inherit version src;

  envSpec = ./gradle-env.json; # todo: updaate gradle2nix?

  preBuild = ''
    # Make gradle aware of Android SDK.
    # See https://github.com/tadfisher/gradle2nix/issues/13
    echo "sdk.dir = ${sdk.androidsdk}/libexec/android-sdk" > local.properties
    printf "\nandroid.aapt2FromMavenOverride=${sdk.androidsdk}/libexec/android-sdk/build-tools/${android.versions.buildTools}/aapt2" >> gradle.properties
  '';

  gradleFlags = [
    "check"
  ];

  installPhase = ''
    mkdir -p $out
    find . -name '*.apk' -exec cp {} $out \;
  '';
}

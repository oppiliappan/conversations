## Status-im style build

This attempt was inspired by the nix setup on the
[`status-im/status-react`](https://github.com/status-im/status-react)
repository. Their setup is pretty dense, relevant parts have been
extracted and converted into a nix flake.

The process is similar to the sphinx-style build. There is
one step to generate a locked artifacts file and another to
convert those into nix derivations and build the android
application.

### Sources

Placed the patched source into the `android/` directory,
such that the path to `build.gradle` is
`android/build.gradle`.

### Maven resolver

Under `pkgs/go-maven-resolver` is a fork of
`status-im/go-maven-resolver` with a couple of hardcoded
paths to non-standard maven repositories. The resolver will
look through certain repositories for dependencies and fetch
metadata. Running `nix/deps/gradle/generate.sh` will produce
a `deps.json` file containing artifact metadata.

```
# bring nerdypepper/go-maven-resolver into scope
$ nix develop

# attempt to generate deps.json
# this script requires build.gradle to be present at $GIT_ROOT/android/build.gradle
$ ./nix/deps/gradle/generate.sh
```

The above steps successfully detects sub-projects and their
dependencies, but the resolver fails to fetch metadata for
non-standard maven packages that do not provide
`maven-metadata.xml` files. I dug through
`status-im/go-maven-resolver` briefly, but I lack the
context required to fix the resolver myself.

```
./nix/deps/gradle/generate.sh
Regenerating Nix files...
Found 0 sub-projects...
Found 213 direct dependencies...
finder.go:121: error: 'no pom data' for: <Dep ID=com.aar.app:google-webrtc:M83 O=false S= >
finder.go:121: error: 'no pom data' for: <Dep ID=com.android.tools.build:builder-model:4.2.1 O=false S= >
finder.go:121: error: 'no pom data' for: <Dep ID=androidx.emoji:emoji-bundled:1.1.0 O=false S= >
```

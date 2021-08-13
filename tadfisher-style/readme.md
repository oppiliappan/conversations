## `tadfisher` style build

This attempt was inspired by [`tadfisher`'s gist](https://gist.github.com/tadfisher/17000caf8653019a9a98fd9b9b921d93) on building
android applications. 

This process is similar to the statusim-style build,
`go-maven-resolver` is replaced by a nix derivation
`buildMavenRepo`. It extracts each dependency from
`build.gradle`, tries to trace it back to the repo from a
list of `repos`. If found, it extracts artifact data from
the repo, along with the SHA for each artifact.

The process is a little hacky though. Different
compilations of the same maven packages that use the same
name and version have different SHA sums are uploaded to
different repos. In order to get the SHAs to match, you have
to reorder the repos.

Place the patched source directly in this directory such
that `build.gradle` is in the same directory as `flake.nix`.

### Producing `deps.json`

The nix flake includes an app to update `deps.json`, run it
with:

```
# bring sdk and jdk into scope
$ nix develop

# update deps.json
$ nix run .#update-locks
```

### Building the app

This step may fail if any of the SHAs are mismatched (the
one produced by `updateLocks` and the one produced by
`buildMavenRepo`. If it does succeed however, the gradle
build fails with:

```
* What went wrong:
A problem occurred configuring root project 'Conversations'.
> Could not resolve all artifacts for configuration ':classpath'.
   > Could not resolve com.android.tools.build:gradle:4.2.1.
      Required by:
          project :
       > No cached version of com.android.tools.build:gradle:4.2.1 available for offline mode.
       > No cached version of com.android.tools.build:gradle:4.2.1 available for offline mode.
```

My speculation is that the `updateLocks` app does not
correctly register `buildScript` dependencies. (However,
`deps.json` has a line with this entry, this is the only
dependency that is never "available for offline mode"?). The
gist also makes use of a `gradle lock` task which I couldn't
find much about but seemingly has no effect on the
`updateLocks` script.

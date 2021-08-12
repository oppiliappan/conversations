## Sphinx style build

This attempt was inspired by the androsphinx flake, which in
turn uses a fork of `gradle2nix` that handles buildscript
dependencies well.

By running `gradle2nix` on our project source, we collect
all our project dependencies into a `gradle-env.json` file
and also generate a `gradle-env.nix` file that produces
derivations for every dependency in `gradle-env.json`.

### Build the custom `gradle2nix` derivation

This step builds a fork of `gradle2nix`. Resulting binary is
available in the nix store.

```
$ nix-build "https://github.com/eyJhb/gradle2nix/archive/buildscript-fix.tar.gz"
/nix/store/...-gradle2nix-1.0.0-rc2
```

### Enter a devshell

This brings android sdk as well as gradle into scope. This
is only required to run `gradle2nix`.

```
$ nix develop
```

### Run `gradle2nix` on project source

```
$ /nix/store/...-gradle2nix-1.0.0-rc2/bin/gradle2nix \
    -c assembleConversationsFreeSystemDebug \
    src
```

Ideally this should produce a `gradle-env.json` and a
`gradle-env.nix`, which you can then place inside the
`pkgs/conversations` directory.

### Run `nix build`

This step fails with errors like:

```
> Could not resolve androidx.databinding:databinding-runtime:4.2.1.
  Required by:
      project :
   > No cached version of androidx.databinding:databinding-runtime:4.2.1 available for offline mode.
   > No cached version of androidx.databinding:databinding-runtime:4.2.1 available for offline mode.
   > No cached version of androidx.databinding:databinding-runtime:4.2.1 available for offline mode.
   > No cached version of androidx.databinding:databinding-runtime:4.2.1 available for offline mode.
```

My speculation here is:

- sdk residing in the nix store and being read-only causes
  some errors? (I see a lot of warnings from this part)
- the gradle init script declared by `gradle-env.nix` has no
  effect on the build somehow

That being said, [similar
errors](https://github.com/tadfisher/gradle2nix/issues/13#issuecomment-797498156)
have been reported for this method previously.

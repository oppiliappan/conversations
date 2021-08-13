## Android on Nix

This repo summarizes my several attempts at packaging
android applications as nix flakes:

- [sphinx-style](./sphinx-style): replicating the
  androsphinx nix flake, that uses a fork of
  [gradle2nix](https://github.com/tadfisher/gradle2nix)
- [statsim-style](./statusim-style): replicating the [nix workflow at status-im](https://github.com/status-im/status-react/tree/develop/nix#readme)
- [tadfisher-style](./tadfisher-style): replicating [this gist](https://gist.github.com/tadfisher/17000caf8653019a9a98fd9b9b921d93) by tadfisher

All attempts were unsuccessful with semi-complex
application configurations that use any of the following:

 - subprojects
 - gradle build configurations
 - buildscript dependencies
 - custom maven repositories (tend to lack a
   `maven-metadata.xml`)

### Conversations.im specific nits

The Conversations application vendors in `libwebrtc` because
it is not provided as a consumable library via a maven
repository. Build instructions suggest downloading the
`.aar` file and placing it inside `/libs`. To side step
this, make use of the following patch that fetches
`libwebrtc` from an unofficial maven repo:

```diff
20a21,23
>     maven {
>         url 'https://raw.github.com/abdularis/libwebrtc-android/repo/'
>     }
36a40
>     implementation 'com.aar.app:google-webrtc:M83'
81d84
<     implementation fileTree(include: ['libwebrtc-m90.aar'], dir: 'libs')
293d295
< 
```

Entering a nix-shell with the android sdk and gradle should
now allow you to build the application with:

```
./gradlew assembleConversationsFreeSystemDebug
```

### General notes

- all project sources are loaded from local directories, a
  local copy of `build.gradle` is required to run any form
  of gradle locking + SHA calculation
- gradle v7 has an internal lock mechanism but unlike
  tools like `cargo` or `yarn`, lock files aren't as useful
  because `gradle` further resolves these dependencies into
  "artifacts". Additionally, `gradle` gives projects the
  ability to modify this resolution process (resolution
  strategies, dependency substitution, module replacement),
  making it pretty complex to replicate in nix.

## Android on Nix

This repo summarizes my several attempts at packaging
android applications as nix flakes:

- [sphinx-style](): replicating the androsphinx nix flake,
  that uses a fork of [gradle2nix]()
- [statsim-style](): replicating the [nix workflow at status-im]()
- [tadfisher-style](): replicating [this gist]() by tadfisher

All attempts were unsuccessful with semi-complex
application configurations that use any of the following:

 - subprojects
 - gradle build configurations
 - buildscript dependencies
 - custom maven repositories (tend to lack a
   `maven-metadata.xml`)

### Conversations.im specific gripes

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

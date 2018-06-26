# Copyright 2017 Xored Software, Inc.

import nake
import os, ospaths, times
import godotapigen

proc genGodotApi() =
  let godotBin = getEnv("GODOT_BIN")
  if godotBin.isNil or godotBin.len == 0:
    echo "GODOT_BIN environment variable is not set"
    quit(-1)
  if not fileExists(godotBin):
    echo "Invalid GODOT_BIN path: " & godotBin
    quit(-1)

  const targetDir = "_godotapi"
  createDir(targetDir)
  const jsonFile = targetDir/"api.json"
  if not fileExists(jsonFile) or
     godotBin.getLastModificationTime() > jsonFile.getLastModificationTime():
    direShell(godotBin, "--gdnative-generate-json-api", getCurrentDir()/jsonFile)
    if not fileExists(jsonFile):
      echo "Failed to generate api.json"
      quit(-1)

    genApi(targetDir, jsonFile)

task "build", "Builds the client for the current platform":
  genGodotApi()
  let bitsPostfix = when sizeof(int) == 8: "_64" else: "_32"
  let libFile =
    when defined(windows):
      "nim" & bitsPostfix & ".dll"
    elif defined(ios):
      "nim_ios" & bitsPostfix & ".dylib"
    elif defined(macosx):
      "nim_mac.dylib"
    elif defined(android):
      "libnim_android.so"
    elif defined(linux):
      "nim_linux" & bitsPostfix & ".so"
    else: nil
  createDir("_dlls")
  withDir "src":
    direShell(["nimble", "c", ".."/"src"/"stub.nim", "-o:.."/"_dlls"/libFile, "--threads:off", "--tlsEmulation:off"])

task "build-android", "Builds the client for android-arm platform":
  genGodotApi()
  createDir("_dlls")
  withDir "src":
    putEnv("ANDROID_TOOLCHAIN", "/opt/android-ndk-r14b/toolchains/x86-4.9/prebuilt/darwin-x86_64")
    direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/libnim_android-x86.so", "--os:linux -d:android --cpu:i386 --threads:off --tlsEmulation:off"])
  #withDir "src":
  #  putEnv("ANDROID_TOOLCHAIN", "/opt/android-ndk-r14b/toolchains/x86_64-4.9/prebuilt/darwin-x86_64")
  #  direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/libnim_android-x86_64.so", "--os:linux -d:android --cpu:amd64 --threads:off --tlsEmulation:off"])
  withDir "src":
    putEnv("ANDROID_TOOLCHAIN", "/opt/android-ndk-r14b/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64")
    direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/libnim_android-arm.so", "--os:linux -d:android --cpu:arm --threads:off --tlsEmulation:off"])
  withDir "src":
    putEnv("ANDROID_TOOLCHAIN", "/opt/android-ndk-r14b/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64")
    direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/libnim_android-arm64.so", "--os:linux -d:android --cpu:arm64 --threads:off --tlsEmulation:off"])

task "build-ios", "Builds the client for iphone-arm platform":
  genGodotApi()
  var libFile = "nim_ios_64.dylib"
  createDir("_dlls")
  withDir "src":
    direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/"&libFile, "--os:macosx -d:ios --cpu:arm64 --threads:off --tlsEmulation:off"])
  libFile = "nim_ios_32.dylib"
  withDir "src":
    direShell(["nimble", "c", r"../src/stub.nim", r"-o:../_dlls/"&libFile, "--os:macosx -d:ios --cpu:arm --threads:off --tlsEmulation:off"])
  #withDir "_dll":
  #  direShell(["lipo", "-create -output nim_ios.dylib nim_ios_64.dylib nim_ios_32.dylib"])

task "clean", "Remove files produced by build":
  removeDir(".nimcache")
  removeDir("src"/".nimcache")
  removeDir("_godotapi")
  removeDir("_dlls")
  removeFile("nakefile")

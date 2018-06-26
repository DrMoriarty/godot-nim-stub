import ospaths

switch("nimcache", ".nimcache"/hostOS/hostCPU)

when defined(macosx):
  when defined(ios):
    if hostCPU == "arm64":
      switch("passC", "-arch arm64")
      switch("passL", "-arch arm64")
    elif hostCPU == "arm":
      switch("passC", "-arch armv7")
      switch("passL", "-arch armv7")
    switch("passC", "-mios-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk")
    switch("passL", "-mios-version-min=9.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk")
  else:
    switch("passL", "-framework Cocoa")
elif defined(android):
  let ndk = getEnv("ANDROID_NDK_ROOT")
  let toolchain = getEnv("ANDROID_TOOLCHAIN")
  if ndk.len == 0:
    raise newException(OSError,
      "ANDROID_NDK_ROOT environment variable is necessary for android build")
  if toolchain.len == 0:
    raise newException(OSError,
      "ANDROID_TOOLCHAIN environment variable is necessary for android build")

  const level = $21 # change this to the necessary API level
  var arch = "x86"
  var cpu = "i686"
  if hostCPU == "i386":
    arch = "x86"
    cpu = "i686"
  elif hostCPU == "amd64":
    arch = "x86_64"
    cpu = "x86_64"
  elif hostCPU == "arm":
    arch = "arm"
    cpu = "arm"
  elif hostCPU == "arm64":
    arch = "arm64"
    cpu = "aarch64"

  let sysroot = "--sysroot=\"" & ndk & "/platforms/android-" & level & "/arch-" & arch & "/\""
  switch("passL", sysroot)
  switch("passC", sysroot)

  switch("cc", "gcc")
  switch("arm.linux.gcc.path", toolchain / "bin")
  switch("arm.linux.gcc.exe", cpu & "-linux-androideabi-gcc")
  switch("arm.linux.gcc.compilerexe", cpu & "-linux-androideabi-gcc")
  switch("arm.linux.gcc.linkerexe", cpu & "-linux-androideabi-gcc")
  switch("arm64.linux.gcc.path", toolchain / "bin")
  switch("arm64.linux.gcc.exe", cpu & "-linux-android-gcc")
  switch("arm64.linux.gcc.compilerexe", cpu & "-linux-android-gcc")
  switch("arm64.linux.gcc.linkerexe", cpu & "-linux-android-gcc")
  switch("i386.linux.gcc.path", toolchain / "bin")
  switch("i386.linux.gcc.exe", cpu & "-linux-android-gcc")
  switch("i386.linux.gcc.compilerexe", cpu & "-linux-android-gcc")
  switch("i386.linux.gcc.linkerexe", cpu & "-linux-android-gcc")
  switch("amd64.linux.gcc.path", toolchain / "bin")
  switch("amd64.linux.gcc.exe", cpu & "-linux-android-gcc")
  switch("amd64.linux.gcc.compilerexe", cpu & "-linux-android-gcc")
  switch("amd64.linux.gcc.linkerexe", cpu & "-linux-android-gcc")
elif defined(windows):
  assert(sizeof(int) == 8)
  switch("cc", "vcc")
elif defined(linux):
  switch("passC", "-fPIC")
else:
  raise newException(OSError, "Unsupported platform: " & hostOS)

when not defined(release):
  switch("debugger", "native")

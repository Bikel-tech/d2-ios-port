# vcpkg triplet: arm64-ios
# Builds AbyssEngine's four vcpkg dependencies (sdl2, libarchive, zlib, ffmpeg)
# as arm64 iOS libraries.
#
# Build with:  vcpkg install --triplet arm64-ios   (run from the engine repo)
#
# RISK: ffmpeg on iOS via vcpkg is historically the flaky one. If it fails in
# CI or locally, use a prebuilt iOS ffmpeg instead (see README-iOS.md,
# "ffmpeg fallback") and remove ffmpeg from vcpkg.json for the iOS build.

set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME iOS)

# Hand the iOS flags down to every port's own CMake configure step.
set(VCPKG_CMAKE_CONFIGURE_OPTIONS
    ${VCPKG_CMAKE_CONFIGURE_OPTIONS}
    -DCMAKE_SYSTEM_NAME=iOS
    -DCMAKE_OSX_ARCHITECTURES=arm64
    -DCMAKE_OSX_SYSROOT=iphoneos
    -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0
)

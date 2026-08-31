# ios.toolchain.cmake
# Minimal, self-contained iOS cross-compile toolchain for AbyssEngine.
#
# Usage (from the engine repo root, with this port repo checked out beside it):
#   cmake -B build-ios -S engine \
#     -DCMAKE_TOOLCHAIN_FILE=../ios-port/ios.toolchain.cmake \
#     -DVCPKG_TARGET_TRIPLET=arm64-ios \
#     -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=../ios-port/ios.toolchain.cmake
#
# For full features (automatic device+simulator fat binaries, code signing
# variables, etc.) prefer https://github.com/leetal/ios-cmake (iOS.cmake) as
# the toolchain instead — drop it in the same place and keep the flags below.

cmake_minimum_required(VERSION 3.20)

# Identify the target platform to CMake.
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_VERSION 15.0 CACHE STRING "Build for iOS 15.0+ (A-series / M-series devices)")
set(CMAKE_OSX_SYSROOT iphoneos CACHE STRING "Use the iOS device SDK")
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Target Apple Silicon / A-series")

# Build against the static vcpkg dependencies to simplify IPA signing.
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Bitcode is deprecated/removed in recent Xcode toolchains.
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "YES")

# Make sure we only pull iOS sysroot headers/libs, never host ones.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

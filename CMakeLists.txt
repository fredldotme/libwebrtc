cmake_minimum_required(VERSION 3.9)

set(CMAKE_CONFIGURATION_TYPES Debug Release CACHE STRING INTERNAL FORCE)

project(libwebrtc)

option(GN_EXTRA_ARGS "Extra 'gn gen' arguments to pass when configuring WebRTC" "")
option(NINJA_ARGS "Ninja arguments to pass when compiling WebRTC" "")

# Allow the use of IN_LIST operand
cmake_policy(SET CMP0057 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(FindLibraries)
include(TargetOsAndCpu)

set(ENV{PATH} "${CMAKE_SOURCE_DIR}/depot_tools:$ENV{PATH}")
set(WEBRTC_SOURCE_DIR "${CMAKE_SOURCE_DIR}/webrtc/src")
set(WEBRTC_BUILD_DIR "${CMAKE_BINARY_DIR}/webrtc")

include(Version)
get_webrtc_version_from_git(WEBRTC_VERSION)
message(STATUS "WebRTC version: ${WEBRTC_VERSION}")

if (MSVC)
    # Always build with dynamic runtime on MSVC
    include(PatchFile)
    patch_file(${WEBRTC_SOURCE_DIR}/build/config/win/BUILD.gn ":static_crt" ":dynamic_crt")
endif ()

include(AddWebRTCTarget)
add_webrtc_target(${WEBRTC_SOURCE_DIR} ${WEBRTC_BUILD_DIR})

add_subdirectory(libwebrtc)

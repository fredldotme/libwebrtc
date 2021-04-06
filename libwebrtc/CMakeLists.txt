# Prepare CMake exports
configure_file(LibWebRTCConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake @ONLY)
configure_file(LibWebRTCConfigVersion.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake @ONLY)
configure_file(LibWebRTCTargets.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCTargets.cmake @ONLY)

######################
#  INSTALL SECTION
######################

# Install headers
install(DIRECTORY
	"${WEBRTC_SOURCE_DIR}/api"
	"${WEBRTC_SOURCE_DIR}/base"
	"${WEBRTC_SOURCE_DIR}/call"
	"${WEBRTC_SOURCE_DIR}/common_audio"
	"${WEBRTC_SOURCE_DIR}/common_video"
	"${WEBRTC_SOURCE_DIR}/logging"
	"${WEBRTC_SOURCE_DIR}/media"
	"${WEBRTC_SOURCE_DIR}/modules"
	"${WEBRTC_SOURCE_DIR}/p2p"
	"${WEBRTC_SOURCE_DIR}/pc"
	"${WEBRTC_SOURCE_DIR}/rtc_base"
	"${WEBRTC_SOURCE_DIR}/system_wrappers"
	DESTINATION "include/webrtc"
	FILES_MATCHING PATTERN "*.h"
)

if (EXISTS "${WEBRTC_SOURCE_DIR}/common_types.h")
	install(FILES "${WEBRTC_SOURCE_DIR}/common_types.h" DESTINATION "include/webrtc")
endif ()

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/jsoncpp"
	DESTINATION "include/webrtc/third_party"
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/libyuv"
	DESTINATION "include/webrtc/third_party"
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/abseil-cpp/absl"
	DESTINATION "include/webrtc"
	FILES_MATCHING PATTERN "*.h"
)

# Install pdb files
if (MSVC)
	# TODO: fix install on first run
	file(GLOB_RECURSE PDB_FILES "${WEBRTC_BUILD_DIR}/Debug/*.pdb")
	install(FILES DESTINATION lib CONFIGURATIONS Debug)
endif()

# Install library
if (MSVC)
	install(FILES ${WEBRTC_BUILD_DIR}/Debug/obj/webrtc.lib DESTINATION lib RENAME "webrtcd.lib" CONFIGURATIONS Debug)
	install(FILES ${WEBRTC_BUILD_DIR}/Release/obj/webrtc.lib DESTINATION lib RENAME "webrtc.lib" CONFIGURATIONS Release)
else ()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib RENAME "libwebrtcd.a")
	else ()
		install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib RENAME "libwebrtc.a")
	endif ()
endif ()

install(FILES
	UseLibWebRTC.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCTargets.cmake
	DESTINATION "lib/cmake/LibWebRTC"
)

if (MSVC)
	install(FILES LibWebRTCTargets-debug.cmake DESTINATION "lib/cmake/LibWebRTC" CONFIGURATIONS Debug)
	install(FILES LibWebRTCTargets-release.cmake DESTINATION "lib/cmake/LibWebRTC" CONFIGURATIONS Release)
else ()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		install(FILES LibWebRTCTargets-debug.cmake DESTINATION "lib/cmake/LibWebRTC")
	else ()
		install(FILES LibWebRTCTargets-release.cmake DESTINATION "lib/cmake/LibWebRTC")
	endif ()
endif ()


set(TARGET_FILE ${CMAKE_BINARY_DIR}/lib/cmake/LibWebRTC/LibWebRTCTargets.cmake)

file(READ ${TARGET_FILE} filedata)
string(REGEX REPLACE ${CMAKE_BINARY_DIR} ${CMAKE_INSTALL_PREFIX} filedata "${filedata}")
file(WRITE ${TARGET_FILE} "${filedata}")

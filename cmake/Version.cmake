function(get_webrtc_version_from_git OUT_VAR)

	find_package(Git REQUIRED)

	execute_process(
		COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
		OUTPUT_VARIABLE WEBRTC_BRANCH
		WORKING_DIRECTORY ${WEBRTC_SOURCE_DIR}
	)

	string(REGEX REPLACE "\n$" "" WEBRTC_BRANCH "${WEBRTC_BRANCH}")
	set(${OUT_VAR} ${WEBRTC_BRANCH} PARENT_SCOPE)

endfunction()

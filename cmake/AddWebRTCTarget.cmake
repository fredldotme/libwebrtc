function(add_webrtc_target SOURCE_DIR BUILD_DIR)

	set(GEN_ARGS_COMMON "target_cpu=\"${TARGET_CPU}\" target_os=\"${TARGET_OS}\" is_component_build=false use_gold=false use_custom_libcxx=false use_custom_libcxx_for_host=false rtc_enable_protobuf=false")

	if (MSVC)
		set(GEN_ARGS_COMMON "${GEN_ARGS_COMMON} is_clang=false")
	endif ()

	set(GEN_ARGS_DEBUG "${GEN_ARGS_COMMON} is_debug=true")
	set(GEN_ARGS_RELEASE "${GEN_ARGS_COMMON} is_debug=false")

	if (MSVC)
		set(GEN_ARGS_DEBUG "${GEN_ARGS_DEBUG} enable_iterator_debugging=true")
	endif ()

	if (WIN32)
		set(GN_EXECUTABLE gn.bat)
	else ()
		set(GN_EXECUTABLE gn)
	endif ()

	if (MSVC)
		# Debug config
		message(STATUS "Running gn for debug configuration...")
		set(GEN_ARGS "${GEN_ARGS_DEBUG}")
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		execute_process(COMMAND ${GN_EXECUTABLE} gen ${BUILD_DIR}/Debug "--args=${GEN_ARGS}" WORKING_DIRECTORY ${SOURCE_DIR})
		
		# Release config
		message(STATUS "Running gn for release configuration...")
		set(GEN_ARGS "${GEN_ARGS_RELEASE}")
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		execute_process(COMMAND ${GN_EXECUTABLE} gen ${BUILD_DIR}/Release "--args=${GEN_ARGS}" WORKING_DIRECTORY ${SOURCE_DIR})
	else ()
		message(STATUS "Running gn...")
		if (CMAKE_BUILD_TYPE STREQUAL "Debug")
			set(GEN_ARGS "${GEN_ARGS_DEBUG}")
		else ()
			set(GEN_ARGS "${GEN_ARGS_RELEASE}")
		endif ()
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		execute_process(COMMAND ${GN_EXECUTABLE} gen ${BUILD_DIR} "--args=${GEN_ARGS}" WORKING_DIRECTORY ${SOURCE_DIR})
	endif ()

	if (MSVC)
		add_custom_target(webrtc-build ALL ninja -C "${BUILD_DIR}/$<CONFIG>" :webrtc jsoncpp libyuv)
		add_custom_target(webrtc-clean ${GN_EXECUTABLE} clean "${BUILD_DIR}/$<CONFIG>" WORKING_DIRECTORY ${SOURCE_DIR})
	else ()
		add_custom_target(webrtc-build ALL ninja -C "${BUILD_DIR}" :webrtc jsoncpp libyuv)
		add_custom_target(webrtc-clean ${GN_EXECUTABLE} clean "${BUILD_DIR}" WORKING_DIRECTORY ${SOURCE_DIR})
	endif ()

endfunction()

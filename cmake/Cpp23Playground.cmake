function(cpp23playground_add_executable)
    cmake_parse_arguments(
        arg
        ""
        "NAME"
        "SOURCES"
        ${ARGN}
    )

    add_executable("${arg_NAME}")
    target_sources("${arg_NAME}" PRIVATE "${arg_SOURCES}")
    target_compile_features("${arg_NAME}" PRIVATE cxx_std_23)
    set_target_properties("${arg_NAME}" PROPERTIES
        COMPILE_WARNING_AS_ERROR ON
        CXX_EXTENSIONS OFF
        CXX_MODULE_STD ON
        LINK_WARNING_AS_ERROR ON
    )

    if(CPP23_PLAYGROUND_WITH_CLANG_TIDY)
        set_target_properties("${arg_NAME}" PROPERTIES
            CXX_CLANG_TIDY "${CPP23_PLAYGROUND_CLANG_TIDY}"
        )
    endif()

    if(CPP23_PLAYGROUND_WITH_COMPILE_COMMANDS)
        set_target_properties("${arg_NAME}" PROPERTIES
            EXPORT_COMPILE_COMMANDS ON
        )
    endif()

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options("${arg_NAME}" PRIVATE
            "-external:W3"
            "-permissive-"
            "-sdl"
            "-utf-8"
            "-W4"
            "/w44365"
        )

        target_compile_definitions("${arg_NAME}" PRIVATE
            "_UNICODE"
            "UNICODE"
        )
    elseif(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU" OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT MATCHES "Clang")
        target_compile_options("${arg_NAME}" PRIVATE
            "-pedantic"
            "-Wconversion"
            "-Wall"
            "-Weffc++"
            "-Wextra"
            "-Wsign-conversion"
        )
    else()
        message(WARNING "Unexpected compiler frontend variant: '${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}'; some additional compilation options are skipped")
    endif()

endfunction()

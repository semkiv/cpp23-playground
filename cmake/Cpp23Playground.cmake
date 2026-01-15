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
        # FIXME: Clang refuses to compile dur to GNU extensions being enabled in the precompiled
        # std module
        # CXX_EXTENSIONS OFF
        CXX_MODULE_STD ON
        CXX_VISIBILITY_PRESET hidden
        LINK_WARNING_AS_ERROR ON
        LINKER_TYPE "${CPP23_PLAYGROUND_LINKER_TYPE}"
        POSITION_INDEPENDENT_CODE ON
        VISIBILITY_INLINES_HIDDEN ON
    )

    if(CPP23_PLAYGROUND_WITH_LTO)
        include(CheckIPOSupported)
        check_ipo_supported(RESULT IPO_RESULT OUTPUT IPO_OUTPUT)
        if(IPO_RESULT)
            set_target_properties("${arg_NAME}" PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
        else()
            message(WARNING "IPO is not supported: ${IPO_OUTPUT}")
        endif()
    endif()

    if(CPP23_PLAYGROUND_WITH_CLANG_TIDY)
        # FIXME: run-clang-tidy gets confused about '--extra-arg-before=driver-mode=g++' passed by CMake
        # if(CPP23_PLAYGROUND_RUN_CLANG_TIDY)
        #     set_target_properties("${arg_NAME}" PROPERTIES
        #         CXX_CLANG_TIDY "${CPP23_PLAYGROUND_RUN_CLANG_TIDY};-j;${CPP23_PLAYGROUND_TOOLS_CONCURENCY}"
        #     )
        # else()
        #     set_target_properties("${arg_NAME}" PROPERTIES
        #         CXX_CLANG_TIDY "${CPP23_PLAYGROUND_CLANG_TIDY}"
        #     )
        # endif()
        set_target_properties("${arg_NAME}" PROPERTIES
            CXX_CLANG_TIDY "${CPP23_PLAYGROUND_CLANG_TIDY}"
        )
    endif()

    if(CPP23_PLAYGROUND_WITH_ASAN)
        target_compile_options("${arg_NAME}" PRIVATE "-fsanitize=address")
        if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            target_link_libraries("${arg_NAME}" PRIVATE "asan")
        endif()
    endif()

    if(CPP23_PLAYGROUND_WITH_TSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support ThreadSanitizer")
        endif()

        target_compile_options("${arg_NAME}" PRIVATE "-fsanitize=thread")
        target_link_libraries("${arg_NAME}" PRIVATE "tsan")
    endif()

    if(CPP23_PLAYGROUND_WITH_MSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support MemorySanitizer")
        endif()

        target_compile_options("${arg_NAME}" PRIVATE "-fsanitize=memory")
        # FIXME: cannot install on my Fedora
        # target_link_libraries("${arg_NAME}" PRIVATE "msan")
    endif()

    if(CPP23_PLAYGROUND_WITH_LSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support LeakSanitizer")
        endif()

        target_compile_options("${arg_NAME}" PRIVATE "-fsanitize=leak")
        target_link_libraries("${arg_NAME}" PRIVATE "lsan")
    endif()

    if(CPP23_PLAYGROUND_WITH_UBSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support UndefinedBehaviorSanitizer")
        endif()

        target_compile_options("${arg_NAME}" PRIVATE "-fsanitize=undefined")
        target_link_libraries("${arg_NAME}" PRIVATE "ubsan")
    endif()

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        target_compile_options("${arg_NAME}" PRIVATE
            "$<$<CONFIG:Debug>:-GS>"
            "$<$<CONFIG:Debug>:-RTCcsu>"
            "$<$<CONFIG:Debug>:-sdl>"
            "-external:W3"
            "-utf-8"
            "-Wall"
            "-WX"
        )

        target_compile_definitions("${arg_NAME}" PRIVATE
            "_UNICODE"
            "UNICODE"
        )
    elseif(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
        target_compile_options("${arg_NAME}" PRIVATE
            "-Wall"
            "-Wcast-align"
            "-Wcast-qual"
            "-Wconversion"
            "-Wctor-dtor-privacy"
            "-Wdeprecated-copy-dtor"
            "-Weffc++"
            "-Wextra"
            "-Wdate-time"
            "-Wextra-semi"
            "-Wfloat-equal"
            "-Wformat=2"
            "-Wimplicit-fallthrough"
            "-Wmain"
            "-Wmissing-include-dirs"
            "-Wmissing-noreturn"
            "-Wnull-dereference"
            "-Wold-style-cast"
            "-Woverloaded-virtual"
            "-Wpedantic"
            "-Wpointer-arith"
            "-Wredundant-decls"
            "-Wshadow"
            "-Wsign-conversion"
            "-Wsign-promo"
            "-Wsuggest-override"
            "-Wswitch-enum"
            "-Wundef"
            "-Wunused-macros"
            "-Wzero-as-null-pointer-constant"
        )

        target_compile_definitions("${arg_NAME}" PRIVATE
            "$<$<CONFIG:Debug>:_GLIBCXX_DEBUG>"
        )

        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            target_compile_options("${arg_NAME}" PRIVATE
                "-Wcast-align=strict"
                "-Wduplicated-branches"
                "-Wduplicated-cond"
                "-Wlogical-op"
                "-Wnoexcept"
                "-Wstrict-null-sentinel"
                "-Wstringop-truncation"
                "-Wsuggest-final-methods"
                "-Wsuggest-final-types"
                "-Wunused-const-variable=2"
                "-Wuseless-cast"
            )
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            target_compile_options("${arg_NAME}" PRIVATE
                "-Warray-bounds-pointer-arithmetic"
                "-Wassign-enum"
                "-Wcomma"
                "-Wconditional-uninitialized"
                "-Wconsumed"
                "-Wcoroutine"
                "-Wcovered-switch-default"
                "-Wctad-maybe-unsupported"
                "-Wdeprecated"
                "-Wdocumentation"
                "-Wdocumentation-pedantic"
                "-Wduplicate-enum"
                "-Wduplicate-method-arg"
                "-Wheader-hygiene"
                "-Widiomatic-parentheses"
                "-Wincompatible-function-pointer-types-strict"
                "-Wincompatible-pointer-types"
                "-Wincomplete-module"
                "-Winconsistent-missing-destructor-override"
                "-Winvalid-or-nonexistent-directory"
                "-Wloop-analysis"
                "-Wmain-return-type"
                "-Wmethod-signatures"
                "-Wmicrosoft"
                "-Wmissing-variable-declarations"
                "-Wmodule-file-mapping-mismatch"
                "-Wnewline-eof"
                "-Wnonportable-system-include-path"
                "-Wnrvo"
                "-Woverriding-method-mismatch"
                "-Wpedantic-core-features"
                "-Wpoison-system-directories"
                "-Wpragmas"
                "-Wredundant-parens"
                "-Wreinterpret-base-class"
                "-Wreserved-identifier"
                "-Wshadow-all"
                "-Wshift-bool"
                "-Wshift-sign-overflow"
                "-Wsigned-enum-bitfield"
                "-Wsuggest-destructor-override"
                "-Wtautological-constant-in-range-compare"
                "-Wthread-safety"
                "-Wthread-safety-pointer"
                "-Wunaligned-access"
                "-Wundef-prefix"
                "-Wundefined-func-template"
                "-Wundefined-reinterpret-cast"
                "-Wunique-object-duplication"
                "-Wunreachable-code-aggressive"
                "-Wunsafe-buffer-usage"
                "-Wunused-exception-parameter"
                "-Wunused-member-function"
                "-Wunused-template"
                "-Wused-but-marked-unused"
            )
        endif()
    else()
        message(WARNING "Unexpected compiler frontend variant: '${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}'; some additional compilation options are skipped")
    endif()

endfunction()

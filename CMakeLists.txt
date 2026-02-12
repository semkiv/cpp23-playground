cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

# Set experimental flag to enable `import std` support from CMake.
# This must be enabled before C++ language support.
# This specific value changes as experimental support evolves. See
# `Help/dev/experimental.rst` in the CMake source corresponding to
# your CMake build for the exact value to use.
if(NOT DEFINED CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD d0edc3af-4c50-42ea-a356-e2862fe7a444)
    message(STATUS "Set experimental CMake gate for 'import std' support to ${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD}")
else()
    message(STATUS "User-defined experimental CMake gate for 'import std' support: ${CMAKE_EXPERIMENTAL_CXX_IMPORT_STD}")
endif()

project(cpp23-playground LANGUAGES CXX)

include(CTest)
include(CMakeDependentOption)

option(CPP23_PLAYGROUND_WITH_UNICODE_SUPPORT
    "Controls whether to enable Unicode support"
    ON
)

option(CPP23_PLAYGROUND_WITH_TESTS
    "Controls whether to enable tests"
    OFF
)

option(CPP23_PLAYGROUND_WITH_RELEASE_LTO
    "Controls the link time optimization in Release builds"
    ON
)

option(CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    "Controls stricter build options that enable safer code"
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_WERROR
    "Controls whether warnings should be treated as errors"
    ON
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_CLANG_TIDY
    "Controls whether clang-tidy should be run as a part of the build"
    ON
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_ASAN
    "Controls whether to use AddressSanitizer"
    OFF
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_TSAN
    "Controls whether to use ThreadSanitizer"
    OFF
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_MSAN
    "Controls whether to use MemorySanitizer"
    OFF
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_LSAN
    "Controls whether to use LeakSanitizer"
    OFF
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

cmake_dependent_option(CPP23_PLAYGROUND_WITH_UBSAN
    "Controls whether to use UndefinedBehaviorSanitizer"
    OFF
    CPP23_PLAYGROUND_WITH_EXTRA_HARDENING
    OFF
)

if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 23)
    message(STATUS "Set C++ standard to C++${CMAKE_CXX_STANDARD}")
else()
    message(STATUS "User-defined C++ standard: ${CMAKE_CXX_STANDARD}")
endif()

if(NOT DEFINED CMAKE_CXX_MODULE_STD)
    set(CMAKE_CXX_MODULE_STD ON)
    message(STATUS "Enabled support for 'import std'")
else()
    message(STATUS "User-defined support for 'import std': ${CMAKE_CXX_MODULE_STD}")
endif()

if(NOT DEFINED CMAKE_CXX_VISIBILITY_PRESET)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    message(STATUS "Set defalt visibility of symbols to ${CMAKE_CXX_VISIBILITY_PRESET}")
else()
    message(STATUS "User-defined visibility of symbols: ${CMAKE_CXX_VISIBILITY_PRESET}")
endif()

if(NOT DEFINED CMAKE_POSITION_INDEPENDENT_CODE)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    message(STATUS "Enabled position-independent code (PIC)")
else()
    message(STATUS "User-defined position-independent code (PIC): ${CMAKE_POSITION_INDEPENDENT_CODE}")
endif()

if(NOT DEFINED CMAKE_VISIBILITY_INLINES_HIDDEN)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
    message(STATUS "Enabled hidden visibility of inline symbols")
else()
    message(STATUS "User-defined hidden visibility of inline symbols: ${CMAKE_VISIBILITY_INLINES_HIDDEN}")
endif()

if(CPP23_PLAYGROUND_WITH_RELEASE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT IPO_RESULT OUTPUT IPO_OUTPUT)
    if(IPO_RESULT)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
        message(STATUS "Enabled IPO/LTO for release builds")
    else()
        message(FATAL_ERROR "IPO/LTO is not supported: ${IPO_OUTPUT}")
    endif()
endif()

if(CPP23_PLAYGROUND_WITH_UNICODE_SUPPORT)
    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        add_compile_options(-utf-8)
        add_compile_definitions(_UNICODE UNICODE)
    endif()
endif()

if(CPP23_PLAYGROUND_WITH_EXTRA_HARDENING)
    # FIXME: Clang refuses to compile due to GNU extensions being enabled in the precompiled std module
    # set(CMAKE_CXX_EXTENSIONS OFF)
    # message(STATUS "Disallowed non-standard C++ extensions:")

    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        add_compile_options(
            $<$<CONFIG:Debug>:-GS>
            $<$<CONFIG:Debug>:-RTCcsu>
            $<$<CONFIG:Debug>:-sdl>
            -external:W3
            -Wall
            -wd5050 # FIXME: disable "Possible incompatible environment..." caused by the precompiled std module
            -WX
        )

        add_compile_definitions(
            _ALLOW_RTCc_IN_STL
        )
    elseif(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
        add_compile_options(
            -Wall
            -Wcast-align
            -Wcast-qual
            -Wconversion
            -Wctor-dtor-privacy
            -Wdeprecated-copy-dtor
            -Weffc++
            -Wextra
            -Wdate-time
            -Wextra-semi
            -Wfloat-equal
            -Wformat=2
            -Wimplicit-fallthrough
            -Wmain
            -Wmissing-include-dirs
            -Wmissing-noreturn
            -Wnull-dereference
            -Wold-style-cast
            -Woverloaded-virtual
            -Wpedantic
            -Wpointer-arith
            -Wredundant-decls
            -Wshadow
            -Wsign-conversion
            -Wsign-promo
            -Wsuggest-override
            -Wswitch-enum
            -Wundef
            -Wunused-macros
            -Wzero-as-null-pointer-constant
        )

        add_compile_definitions(
            $<$<CONFIG:Debug>:_GLIBCXX_DEBUG>
        )

        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            add_compile_options(
                -Wcast-align=strict
                -Wduplicated-branches
                -Wduplicated-cond
                -Wlogical-op
                -Wnoexcept
                -Wstrict-null-sentinel
                -Wstringop-truncation
                -Wsuggest-final-methods
                -Wsuggest-final-types
                -Wunused-const-variable=2
                -Wuseless-cast
            )
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            add_compile_options(
                -Warray-bounds-pointer-arithmetic
                -Wassign-enum
                -Wcomma
                -Wconditional-uninitialized
                -Wconsumed
                -Wcoroutine
                -Wcovered-switch-default
                -Wctad-maybe-unsupported
                -Wdeprecated
                -Wdocumentation
                -Wdocumentation-pedantic
                -Wduplicate-enum
                -Wduplicate-method-arg
                -Wheader-hygiene
                -Widiomatic-parentheses
                -Wincompatible-function-pointer-types-strict
                -Wincompatible-pointer-types
                -Wincomplete-module
                -Winconsistent-missing-destructor-override
                -Winvalid-or-nonexistent-directory
                -Wloop-analysis
                -Wmain-return-type
                -Wmethod-signatures
                -Wmicrosoft
                -Wmissing-variable-declarations
                -Wmodule-file-mapping-mismatch
                -Wnewline-eof
                -Wnonportable-system-include-path
                -Wnrvo
                -Woverriding-method-mismatch
                -Wpedantic-core-features
                -Wpoison-system-directories
                -Wpragmas
                -Wredundant-parens
                -Wreinterpret-base-class
                -Wreserved-identifier
                -Wshadow-all
                -Wshift-bool
                -Wshift-sign-overflow
                -Wsigned-enum-bitfield
                -Wsuggest-destructor-override
                -Wtautological-constant-in-range-compare
                -Wthread-safety
                -Wthread-safety-pointer
                -Wunaligned-access
                -Wundef-prefix
                -Wundefined-func-template
                -Wundefined-reinterpret-cast
                -Wunique-object-duplication
                -Wunreachable-code-aggressive
                -Wunsafe-buffer-usage
                -Wunused-exception-parameter
                -Wunused-member-function
                -Wunused-template
                -Wused-but-marked-unused
            )
        endif()
    else()
        message(WARNING "Unexpected compiler frontend variant: '${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}'; some additional compilation options are skipped")
    endif()

    if(CPP23_PLAYGROUND_WITH_WERROR)
        set(CMAKE_COMPILE_WARNING_AS_ERROR ON)
        message(STATUS "Enabled treating of compiler warnings as errors")
        set(CMAKE_LINK_WARNING_AS_ERROR ON)
        message(STATUS "Enabled treating of linker warnings as errors")
    endif()

    if(CPP23_PLAYGROUND_WITH_CLANG_TIDY)
        find_program(CPP23_PLAYGROUND_CLANG_TIDY NAMES clang-tidy REQUIRED)
        set(CMAKE_CXX_CLANG_TIDY "${CPP23_PLAYGROUND_CLANG_TIDY}")
        message(STATUS "Using clang-tidy: '${CPP23_PLAYGROUND_CLANG_TIDY}'")
    endif()

    if(CPP23_PLAYGROUND_WITH_ASAN)
        add_compile_options(-fsanitize=address)
        if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            link_libraries(asan)
        endif()
        message(STATUS "Enabled AddressSanitizer")
    endif()

    if(CPP23_PLAYGROUND_WITH_TSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support ThreadSanitizer")
        endif()

        add_compile_options(-fsanitize=thread)
        link_libraries(tsan)
        message(STATUS "Enabled ThreadSanitizer")
    endif()

    if(CPP23_PLAYGROUND_WITH_MSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support MemorySanitizer")
        endif()

        # FIXME: cannot install on my Fedora
        # add_compile_options(-fsanitize=memory)
        # link_libraries(msan)
        # message(STATUS "Enabled MemorySanitizer")
    endif()

    if(CPP23_PLAYGROUND_WITH_LSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support LeakSanitizer")
        endif()

        add_compile_options(-fsanitize=leak)
        link_libraries(lsan)
        message(STATUS "Enabled LeakSanitizer")
    endif()

    if(CPP23_PLAYGROUND_WITH_UBSAN)
        if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
            message(FATAL_ERROR "MSVC does not support UndefinedBehaviorSanitizer")
        endif()

        add_compile_options(-fsanitize=undefined)
        link_libraries(ubsan)
        message(STATUS "Enabled UndefinedBehaviorSanitizer")
    endif()
endif()

add_subdirectory(src)

if(CPP23_PLAYGROUND_WITH_TESTS)
    find_package(GTest CONFIG REQUIRED)
    add_subdirectory(tests)
endif()

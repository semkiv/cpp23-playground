cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

# Set experimental flag to enable `import std` support from CMake.
# This must be enabled before C++ language support.
# This specific value changes as experimental support evolves. See
# `Help/dev/experimental.rst` in the CMake source corresponding to
# your CMake build for the exact value to use.
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")

project(cpp23-playground LANGUAGES CXX)

set(CPP23_PLAYGROUND_TOOLS_CONCURENCY
    "1"
    CACHE
    STRING
    "Controls the number of concurrent processes that are spawned when running tools that support it"
)

set(CPP23_PLAYGROUND_LINKER_TYPE
    "DEFAULT"
    CACHE
    STRING
    "Controls which linker will be used for the link step"
)

option(CPP23_PLAYGROUND_WITH_LTO
    "Controls the link time optimization (applicable only to Release builds)"
    ON
)

option(CPP23_PLAYGROUND_WITH_CLANG_TIDY
    "Controls running clang-tidy as part of the build"
    OFF
)

option(CPP23_PLAYGROUND_WITH_ASAN
    "Controls AddressSanitizer"
    OFF
)

option(CPP23_PLAYGROUND_WITH_TSAN
    "Controls ThreadSanitizer"
    OFF
)

option(CPP23_PLAYGROUND_WITH_MSAN
    "Controls MemorySanitizer"
    OFF
)

option(CPP23_PLAYGROUND_WITH_LSAN
    "Controls LeakSanitizer"
    OFF
)

option(CPP23_PLAYGROUND_WITH_UBSAN
    "Controls UndefinedBehaviorSanitizer"
    OFF
)

option(CPP23_PLAYGROUND_ENABLE_IPO
    "Enable IPO/LTO (Release builds only)"
    ON
)

if(CPP23_PLAYGROUND_WITH_CLANG_TIDY)
    find_program(CPP23_PLAYGROUND_CLANG_TIDY NAMES "clang-tidy" REQUIRED)
    find_program(CPP23_PLAYGROUND_RUN_CLANG_TIDY NAMES "run-clang-tidy")
endif()

add_subdirectory(src)

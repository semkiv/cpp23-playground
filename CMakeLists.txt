cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

# Set experimental flag to enable `import std` support from CMake.
# This must be enabled before C++ language support.
# This specific value changes as experimental support evolves. See
# `Help/dev/experimental.rst` in the CMake source corresponding to
# your CMake build for the exact value to use.
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")

project(cpp23-playground LANGUAGES CXX)

include(cmake/Cpp23Playground.cmake)

option(CPP23_PLAYGROUND_WITH_COMPILE_COMMANDS
    "Controls generation of compile_commands.json file"
    OFF
)
option(CPP23_PLAYGROUND_WITH_CLANG_TIDY
    "Controls running clang-tidy as part of the build; requires compile_commands.json and thus enabling it implicitly enables the CPP23_PLAYGROUND_WITH_COMPILE_COMMANDS option"
    OFF
)

if(CPP23_PLAYGROUND_WITH_CLANG_TIDY)
    set(CPP23_PLAYGROUND_WITH_COMPILE_COMMANDS ON)
    find_program(CPP23_PLAYGROUND_CLANG_TIDY NAMES "clang-tidy" REQUIRED)
endif()

add_subdirectory(src)

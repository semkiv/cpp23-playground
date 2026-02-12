include(GoogleTest)

add_library(cpp23playgroundtestscommon INTERFACE)
target_link_libraries(cpp23playgroundtestscommon
    INTERFACE
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
        GTest::gmock_main
)

function(cpp23playground_add_test)
    cmake_parse_arguments(
        arg
        ""
        "NAME"
        "SOURCES;DEPENDS"
        ${ARGN}
    )

    add_executable("${arg_NAME}")
    target_sources("${arg_NAME}"
        PRIVATE
            "${arg_SOURCES}"
    )
    target_link_libraries("${arg_NAME}"
        PRIVATE
            cpp23playgroundtestscommon
            "${arg_DEPENDS}"
    )
    gtest_discover_tests("${arg_NAME}")
endfunction(cpp23playground_add_test)

cpp23playground_add_test(
    NAME addtest
    SOURCES add.cpp
)

# Cannot use GTest because it clashes 'import std'
add_executable(versiontest)
target_sources(versiontest
    PRIVATE
        version.cpp
)
target_link_libraries(versiontest
    PRIVATE
        version
        compat
)
add_test(NAME Version COMMAND versiontest)

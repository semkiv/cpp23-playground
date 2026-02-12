add_executable(runme)
target_sources(runme
    PRIVATE
        main.cpp
)
target_link_libraries(runme
    PRIVATE
        compat
        version
)

add_subdirectory(compat)
add_subdirectory(version)

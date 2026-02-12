add_library(version STATIC)

target_sources(version
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            version.cppm
)

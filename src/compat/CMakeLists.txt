add_library(compat STATIC)

target_sources(compat
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            compat.cppm
)

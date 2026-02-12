module;

#include <cstdlib>

export module compat;

export namespace compat {
    inline constexpr auto exit_success = EXIT_SUCCESS;
    inline constexpr auto exit_failure = EXIT_FAILURE;
}
